"""Minimal decoder-only transformer (nanoGPT-style) plus encoding,
sampling and hidden-state extraction for the checker study.

Sequence layout: formula tokens, SEP, proof tokens, EOS. Loss is taken on
the proof tokens and EOS only; the formula is context.
"""
from __future__ import annotations

import math
from dataclasses import dataclass

import torch
import torch.nn as nn
import torch.nn.functional as F

from .terms import VOCAB

SPECIAL = ["<pad>", "<sep>", "<eos>"]
ITOS = SPECIAL + VOCAB
STOI = {s: i for i, s in enumerate(ITOS)}
PAD, SEP, EOS = STOI["<pad>"], STOI["<sep>"], STOI["<eos>"]
VOCAB_SIZE = len(ITOS)


@dataclass
class GPTConfig:
    n_layer: int
    n_embd: int
    n_head: int
    block_size: int
    dropout: float = 0.0
    vocab_size: int = VOCAB_SIZE


CONFIGS = {
    "feasibility": dict(n_layer=4, n_embd=128, n_head=4),
    "main": dict(n_layer=6, n_embd=256, n_head=8),
}


def encode_pair(formula: list[str], proof: list[str] | None) -> list[int]:
    ids = [STOI[t] for t in formula] + [SEP]
    if proof is not None:
        ids += [STOI[t] for t in proof] + [EOS]
    return ids


class Block(nn.Module):
    def __init__(self, c: GPTConfig):
        super().__init__()
        self.ln1 = nn.LayerNorm(c.n_embd)
        self.attn = nn.MultiheadAttention(c.n_embd, c.n_head, dropout=c.dropout, batch_first=True)
        self.ln2 = nn.LayerNorm(c.n_embd)
        self.mlp = nn.Sequential(
            nn.Linear(c.n_embd, 4 * c.n_embd), nn.GELU(), nn.Linear(4 * c.n_embd, c.n_embd),
            nn.Dropout(c.dropout),
        )

    def forward(self, x, causal_mask, key_padding_mask):
        h = self.ln1(x)
        a, _ = self.attn(h, h, h, attn_mask=causal_mask, key_padding_mask=key_padding_mask,
                         need_weights=False)
        x = x + a
        x = x + self.mlp(self.ln2(x))
        return x


class GPT(nn.Module):
    def __init__(self, c: GPTConfig):
        super().__init__()
        self.c = c
        self.tok = nn.Embedding(c.vocab_size, c.n_embd)
        self.pos = nn.Embedding(c.block_size, c.n_embd)
        self.drop = nn.Dropout(c.dropout)
        self.blocks = nn.ModuleList([Block(c) for _ in range(c.n_layer)])
        self.ln_f = nn.LayerNorm(c.n_embd)
        self.head = nn.Linear(c.n_embd, c.vocab_size, bias=False)
        self.head.weight = self.tok.weight  # weight tying
        self.apply(self._init)

    @staticmethod
    def _init(m):
        if isinstance(m, (nn.Linear, nn.Embedding)):
            nn.init.normal_(m.weight, mean=0.0, std=0.02)
            if isinstance(m, nn.Linear) and m.bias is not None:
                nn.init.zeros_(m.bias)

    def n_params(self) -> int:
        return sum(p.numel() for p in self.parameters())

    def hidden(self, idx: torch.Tensor) -> torch.Tensor:
        """Final-layer hidden states (after ln_f), shape (B, T, C)."""
        B, T = idx.shape
        assert T <= self.c.block_size
        pos = torch.arange(T, device=idx.device)
        x = self.drop(self.tok(idx) + self.pos(pos))
        causal = torch.triu(torch.ones(T, T, dtype=torch.bool, device=idx.device), diagonal=1)
        kpm = idx == PAD
        # a fully masked query row would give NaN; PAD queries are ignored downstream
        for blk in self.blocks:
            x = blk(x, causal, kpm)
        return self.ln_f(x)

    def forward(self, idx: torch.Tensor, targets: torch.Tensor | None = None):
        logits = self.head(self.hidden(idx))
        loss = None
        if targets is not None:
            loss = F.cross_entropy(logits.view(-1, logits.size(-1)), targets.view(-1), ignore_index=-100)
        return logits, loss


def make_batch(seqs: list[list[int]], sep_positions: list[int], block_size: int, device):
    """Pad to block, build inputs/targets with loss only after SEP."""
    B = len(seqs)
    x = torch.full((B, block_size), PAD, dtype=torch.long)
    y = torch.full((B, block_size), -100, dtype=torch.long)
    for i, (s, sp) in enumerate(zip(seqs, sep_positions)):
        s = s[:block_size + 1]
        n = len(s) - 1
        x[i, :n] = torch.tensor(s[:-1])
        tgt = torch.tensor(s[1:])
        y[i, :n] = tgt
        y[i, :sp] = -100  # predictions of formula tokens and of SEP itself are not scored
    return x.to(device), y.to(device)


@torch.no_grad()
def sample_proofs(model: GPT, formula_ids: list[int], n: int, temperature: float,
                  max_new: int, device, generator: torch.Generator | None = None) -> list[list[int]]:
    """n independent samples of proof tokens (without EOS) for one formula.
    Returns token-id lists; a list hitting max_new without EOS is returned
    as is (the caller's parser will reject it if incomplete)."""
    model.eval()
    prompt = torch.tensor(formula_ids, dtype=torch.long, device=device).unsqueeze(0).repeat(n, 1)
    out = prompt
    done = torch.zeros(n, dtype=torch.bool, device=device)
    for _ in range(max_new):
        logits, _ = model(out)
        logits = logits[:, -1, :] / max(temperature, 1e-6)
        logits[:, PAD] = -float("inf")
        logits[:, SEP] = -float("inf")
        probs = F.softmax(logits, dim=-1)
        nxt = torch.multinomial(probs, 1, generator=generator).squeeze(1)
        nxt = torch.where(done, torch.full_like(nxt, PAD), nxt)
        out = torch.cat([out, nxt.unsqueeze(1)], dim=1)
        done |= nxt == EOS
        if done.all() or out.shape[1] >= model.c.block_size:
            break
    res = []
    L = len(formula_ids)
    for row in out.tolist():
        toks = []
        for t in row[L:]:
            if t == EOS or t == PAD:
                break
            toks.append(t)
        res.append(toks)
    return res


@torch.no_grad()
def proof_embedding(model: GPT, formula_ids: list[int], proof_ids: list[int], device) -> torch.Tensor:
    """E1: final-layer hidden states mean-pooled over the proof tokens
    (positions whose input token is a proof token; SEP and EOS excluded)."""
    model.eval()
    seq = formula_ids + proof_ids  # formula already ends with SEP
    x = torch.tensor(seq, dtype=torch.long, device=device).unsqueeze(0)
    h = model.hidden(x)[0]
    L = len(formula_ids)
    if len(proof_ids) == 0:
        return h[L - 1]
    return h[L:L + len(proof_ids)].mean(dim=0)


def decode(ids: list[int]) -> list[str]:
    return [ITOS[i] for i in ids]


def lr_at(step: int, total: int, warmup: int, lr_max: float, lr_min: float) -> float:
    if step < warmup:
        return lr_max * (step + 1) / warmup
    if step >= total:
        return lr_min
    frac = (step - warmup) / max(1, total - warmup)
    return lr_min + 0.5 * (lr_max - lr_min) * (1 + math.cos(math.pi * frac))
