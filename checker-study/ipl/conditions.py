"""The four conditions (SPEC.md, "Conditions") and their shared plumbing.

Budget unit: one multinomial draw from the model. C1's budget for a prompt
is the number of draws its N samples took (EOS draws included). C3 spends
exactly that number of draws on the same prompt.

C1  unguided: N independent samples at temperature T.
C2  filtered: C1's valid samples (derived, not re-sampled).
C3  guided:   token-by-token sampling at temperature T with prefix
              checking. A drawn token whose prefix is refuted is masked at
              that position and the position is redrawn (repair). When
              every token at a position is refuted, the previous token is
              popped and forbidden at its position (backtrack). A complete
              valid prefix admits only EOS. A token sequence that already
              produced a completion forbids EOS, so the search must
              diverge; completions are distinct by construction. After a
              completion the search restarts from the empty prefix. It
              stops when the budget is spent.
C4  grammar null: exhaustive size-indexed enumeration of normal proofs in
              the fragment (depth <= DEPTH_MAX, as the generator), in
              eta-long form, then matched per prompt to C2's unique valid
              outputs by count within proof-size tertiles whose boundaries
              are fixed on the full held-out set.

Novelty is computed by one function, novelty_key, for every arm.
"""
from __future__ import annotations

import random
from dataclasses import dataclass, field
from typing import Optional

import numpy as np
import torch
import torch.nn.functional as F

from .check import _has_hole, is_valid, normal_form, prefix_ok
from .gen import DEPTH_MAX
from .model import EOS, PAD, SEP, GPT, decode
from .terms import (
    Abort, And, App, Bot, Case, Formula, Fst, Imp, Inl, Inr, Lam, Or, Pair,
    Snd, Term, Var, parse_formula, parse_term, parse_term_full, term_depth, term_size, term_tokens,
)

# C4 enumeration (spec postscript 2026-09-29 "Conditions", item 3; "Resolutions", item E)
C4_MAX_COUNT = 400
C4_SIZE_CAP = 32


def c4_size_cap(c2_sizes: list[int]) -> int:
    """min(32, max(12, max C2 size + 2)); excludes only proofs larger than
    anything C2 produced plus two, which tertile matching never selects."""
    return min(C4_SIZE_CAP, max(12, (max(c2_sizes) + 2) if c2_sizes else 12))


def conditions_name(profile: str, seed: int, temperature: float) -> str:
    """Output stem shared by 06/07/08, so a sensitivity run at another
    temperature cannot overwrite the registered one."""
    return f"conditions-{profile}-seed{seed}-T{temperature:g}"


# ----------------------------------------------------------------------------
# Novelty (spec "Definitions": eta-long, alpha-normal term not identical to
# any training proof term, whatever formula either proves)


def novelty_key(t: Term, goal: Formula) -> tuple:
    return tuple(term_tokens(normal_form(t, goal)))


def train_term_set(train_items: list[dict]) -> frozenset:
    """Training proofs are stored in eta-long form; their token tuples are
    the novelty reference. assert_train_eta_long checks the premise."""
    return frozenset(tuple(it["proof"]) for it in train_items)


def assert_train_eta_long(train_items: list[dict]) -> int:
    """Halting check: every stored training proof equals its own eta-long
    normal form, so raw stored tokens are a valid novelty reference."""
    for it in train_items:
        try:
            goal, _ = parse_formula(it["formula"])
            t = parse_term_full(it["proof"])
            nf = tuple(term_tokens(normal_form(t, goal)))
        except Exception as exc:  # parse failure or checker Reject: not a proof of its formula
            raise AssertionError(f"training item is not a proof of its formula ({exc}): " + " ".join(it["proof"]))
        if nf != tuple(it["proof"]):
            raise AssertionError("training proof is not stored in eta-long normal form: " + " ".join(it["proof"]))
    return len(train_items)


def train_set_fingerprint(train_terms: frozenset) -> str:
    import hashlib
    h = hashlib.sha256()
    for k in sorted(train_terms):
        h.update(" ".join(k).encode("utf-8"))
        h.update(b"\n")
    return h.hexdigest()


# ----------------------------------------------------------------------------
# Seeding: every random stream is seeded from the prompt's formula, an arm
# tag and (for C1) the sample index, so prompt order and batch layout cannot
# change outputs (spec postscript 2026-09-29, "Conditions").


def prompt_seed(formula: list[str], arm: str, k: int = 0) -> int:
    import hashlib
    h = hashlib.sha256(f"{' '.join(formula)}|{arm}|{k}".encode("utf-8")).digest()
    return int.from_bytes(h[:8], "big") % (2 ** 62)


class UniformStream:
    """Per-sample uniform stream on the CPU generator, so draws are
    identical whatever device runs the model and however samples are
    batched."""

    def __init__(self, seed: int):
        self.g = torch.Generator(device="cpu").manual_seed(seed)

    def next(self) -> float:
        return float(torch.rand(1, generator=self.g).item())


def inverse_cdf_sample(probs: torch.Tensor, u: torch.Tensor) -> torch.Tensor:
    """probs (n, V) rows summing to ~1; u (n,) uniforms. Returns (n,) token
    ids: the smallest index whose cumulative mass exceeds u."""
    cdf = probs.cumsum(dim=-1)
    idx = torch.searchsorted(cdf, u.to(cdf.dtype).unsqueeze(1), right=True).squeeze(1)
    idx = idx.clamp(max=probs.shape[1] - 1)
    # rounding can leave u above the last cumulative value; never return a
    # zero-mass (masked) token: fall back to the last token with mass
    zero = probs.gather(1, idx.unsqueeze(1)).squeeze(1) <= 0
    if bool(zero.any()):
        last_nonzero = (probs > 0).to(torch.int64).cumsum(dim=-1).argmax(dim=-1)
        idx = torch.where(zero, last_nonzero, idx)
    return idx


# ----------------------------------------------------------------------------
# C1: unguided sampling with per-sample draw counts


@dataclass
class Sample:
    tokens: list[str]
    n_drawn: int
    terminated: bool  # EOS drawn before the length limit
    sample_index: int = 0
    parsed: bool = False
    valid: bool = False
    key: Optional[tuple] = None  # novelty key when valid
    novel: Optional[bool] = None
    term_size: Optional[int] = None


@torch.no_grad()
def sample_counted(model: GPT, formula: list[str], formula_ids: list[int], sample_indices: list[int],
                   temperature: float, max_new: int, device) -> list[Sample]:
    """Samples with the given indices for one formula. Sample j's draws come
    from UniformStream(prompt_seed(formula, 'C1', j)), so running the indices
    in one batch or many gives identical outputs."""
    model.eval()
    n = len(sample_indices)
    streams = [UniformStream(prompt_seed(formula, "C1", j)) for j in sample_indices]
    prompt = torch.tensor(formula_ids, dtype=torch.long, device=device).unsqueeze(0).repeat(n, 1)
    out = prompt
    done = torch.zeros(n, dtype=torch.bool, device=device)
    drawn = torch.zeros(n, dtype=torch.long, device=device)
    for _ in range(max_new):
        logits, _ = model(out)
        logits = logits[:, -1, :] / max(temperature, 1e-6)
        logits[:, PAD] = -float("inf")
        logits[:, SEP] = -float("inf")
        probs = F.softmax(logits, dim=-1)
        u = torch.tensor([s.next() if not d else 0.0 for s, d in zip(streams, done.tolist())],
                         dtype=probs.dtype, device=device)
        nxt = inverse_cdf_sample(probs, u)
        drawn += (~done).long()
        nxt = torch.where(done, torch.full_like(nxt, PAD), nxt)
        out = torch.cat([out, nxt.unsqueeze(1)], dim=1)
        done |= nxt == EOS
        if done.all() or out.shape[1] >= model.c.block_size:
            break
    res = []
    L = len(formula_ids)
    for j, row, nd, term in zip(sample_indices, out.tolist(), drawn.tolist(), done.tolist()):
        toks = []
        for t in row[L:]:
            if t == EOS or t == PAD:
                break
            toks.append(t)
        res.append(Sample(tokens=decode(toks), n_drawn=int(nd), terminated=bool(term), sample_index=j))
    return res


def classify(sample: Sample, goal: Formula, train_terms: frozenset) -> Sample:
    try:
        t = parse_term_full(sample.tokens)
    except ValueError:
        return sample
    sample.parsed = True
    if is_valid(t, goal):
        sample.valid = True
        sample.key = novelty_key(t, goal)
        sample.novel = sample.key not in train_terms
        sample.term_size = term_size(normal_form(t, goal))
    return sample


# ----------------------------------------------------------------------------
# C3: guided search


@dataclass
class Completion:
    key: tuple
    raw_tokens: list[str]
    novel: bool
    term_size: int
    found_at_draw: int


@dataclass
class SearchStats:
    draws: int = 0
    accepted: int = 0
    pruned: int = 0
    backtracks: int = 0
    restarts: int = 0            # after a completion
    restarts_on_cap: int = 0     # attempt hit the per-attempt draw cap
    exhausted_root: bool = False


def _prefix_status(tokens: list[str], goal: Formula, depth_max: int = DEPTH_MAX) -> str:
    """'refuted' | 'complete' | 'open' for a proof-token prefix. A partial
    term deeper than depth_max is refuted: holes have depth 1, so every
    completion is at least as deep, and the corpus term class is depth <=
    DEPTH_MAX (spec "Generator")."""
    if not tokens:
        return "open"
    try:
        t, pos = parse_term(tokens, 0, allow_partial=True)
    except ValueError:
        return "refuted"
    if pos != len(tokens):
        return "refuted"
    if term_depth(t) > depth_max:
        return "refuted"
    if not prefix_ok(t, goal):
        return "refuted"
    return "complete" if not _has_hole(t) else "open"


@torch.no_grad()
def guided_search(model: GPT, goal: Formula, formula: list[str], formula_ids: list[int], budget: int,
                  temperature: float, max_new: int, device, train_terms: frozenset,
                  mode: str = "mask", depth_max: int = DEPTH_MAX,
                  ) -> tuple[list[Completion], SearchStats]:
    """mode 'mask': the checker filters the vocabulary before each draw, so
    every draw is a non-refuted token and backtracks cost no draws.
    mode 'prune': draw first, then refute; a refuted token is masked at its
    position and costs one draw (kept for comparison).

    An attempt is a descent from the empty prefix. Backtracking is
    chronological (pop the last token, forbid it at its position), which is
    a depth-first traversal; without a cap it can spend the whole budget in
    one subtree the checker cannot refute (an application whose head is
    still a hole). Each attempt is therefore capped at max_new draws, the
    most a single C1 sample can cost; at the cap the attempt is abandoned
    and the search restarts from the empty prefix. Found token sequences are
    remembered across attempts and forbid EOS, so completions are distinct."""
    assert mode in ("mask", "prune")
    model.eval()
    stream = UniformStream(prompt_seed(formula, "C3"))
    stats = SearchStats()
    completions: list[Completion] = []
    found_paths: set[tuple] = set()
    prefix: list[int] = []
    forbidden: list[set[int]] = [set()]
    attempt_draws = 0
    vocab = model.c.vocab_size
    base_mask = torch.zeros(vocab, dtype=torch.bool, device=device)
    base_mask[PAD] = True
    base_mask[SEP] = True

    def viable_mask(pos: int, status: str) -> torch.Tensor:
        """True = masked out."""
        mask = base_mask.clone()
        for tok in forbidden[pos]:
            mask[tok] = True
        if status == "complete":
            mask[:] = True
            if tuple(prefix) not in found_paths and EOS not in forbidden[pos]:
                mask[EOS] = False
            return mask
        mask[EOS] = True
        if pos >= max_new - 1:
            mask[:] = True
            return mask
        if mode == "mask":
            toks = decode(prefix)
            for tok in range(vocab):
                if not mask[tok] and _prefix_status(toks + decode([tok]), goal, depth_max) == "refuted":
                    mask[tok] = True
        return mask

    while stats.draws < budget:
        if attempt_draws >= max_new and prefix:
            prefix, forbidden, attempt_draws = [], [set()], 0
            stats.restarts_on_cap += 1
            continue
        pos = len(prefix)
        status = _prefix_status(decode(prefix), goal, depth_max)
        mask = viable_mask(pos, status)
        if bool(mask.all()):
            if pos == 0:
                stats.exhausted_root = True
                break
            last = prefix.pop()
            forbidden.pop()
            forbidden[-1].add(last)
            stats.backtracks += 1
            continue

        ids = torch.tensor(formula_ids + prefix, dtype=torch.long, device=device).unsqueeze(0)
        logits, _ = model(ids)
        logits = logits[0, -1, :] / max(temperature, 1e-6)
        logits[mask] = -float("inf")
        probs = F.softmax(logits, dim=-1)
        u = torch.tensor([stream.next()], dtype=probs.dtype, device=device)
        tok = int(inverse_cdf_sample(probs.unsqueeze(0), u).item())
        assert not bool(mask[tok]), "sampled a masked token"
        stats.draws += 1
        attempt_draws += 1

        if tok == EOS:
            t = parse_term_full(decode(prefix))
            assert is_valid(t, goal), "complete unrefuted prefix must be valid"
            key = novelty_key(t, goal)
            completions.append(Completion(
                key=key, raw_tokens=decode(prefix), novel=key not in train_terms,
                term_size=term_size(normal_form(t, goal)), found_at_draw=stats.draws))
            found_paths.add(tuple(prefix))
            stats.accepted += 1
            stats.restarts += 1
            prefix, forbidden, attempt_draws = [], [set()], 0
            continue

        if mode == "prune":
            cand = decode(prefix + [tok])
            if _prefix_status(cand, goal, depth_max) == "refuted":
                forbidden[pos].add(tok)
                stats.pruned += 1
                continue
        prefix.append(tok)
        forbidden.append(set())
        stats.accepted += 1

    return completions, stats


# ----------------------------------------------------------------------------
# C4: bounded enumeration of normal proofs


class EnumBudget(Exception):
    pass


def enumerate_proofs(goal: Formula, max_size: int, max_count: int,
                     depth_max: int = DEPTH_MAX, node_cap: int = 300_000,
                     list_cap: int = 2_000) -> tuple[list[tuple[tuple, int]], dict]:
    """Distinct eta-long proofs of goal with term size <= max_size, in order
    of increasing raw size. Returns [(novelty_key, size_of_normal_form)] and
    a record of the bounds actually hit. list_cap bounds each memo entry, so
    the enumeration is exhaustive only while no cap is reported."""
    memo_v: dict = {}
    memo_n: dict = {}
    nodes = [0]
    caps_hit = {"node_cap": False, "list_cap": False, "max_count": False}

    def tick():
        nodes[0] += 1
        if nodes[0] > node_cap:
            raise EnumBudget

    def cap(lst):
        if len(lst) > list_cap:
            caps_hit["list_cap"] = True
            return lst[:list_cap]
        return lst

    def neutrals(ctx: tuple, s: int, depth: int) -> list:
        key = (ctx, s, depth)
        if key in memo_n:
            return memo_n[key]
        tick()
        out = []
        if depth >= 1 and s == 1:
            out = [(Var(k), ctx[-1 - k]) for k in range(len(ctx))]
        elif depth >= 2 and s >= 2:
            for n, tn in neutrals(ctx, s - 1, depth - 1):
                if isinstance(tn, And):
                    out.append((Fst(n), tn.a))
                    out.append((Snd(n), tn.b))
            for s1 in range(1, s - 1):
                s2 = s - 1 - s1
                for n, tn in neutrals(ctx, s1, depth - 1):
                    if isinstance(tn, Imp):
                        for a in values(ctx, tn.a, s2, depth - 1):
                            out.append((App(n, a), tn.b))
        out = cap(out)
        memo_n[key] = out
        return out

    def values(ctx: tuple, goal: Formula, s: int, depth: int) -> list:
        key = (ctx, goal, s, depth)
        if key in memo_v:
            return memo_v[key]
        tick()
        out: list = []
        if depth >= 1 and s >= 1:
            if isinstance(goal, Imp):
                out = [Lam(b) for b in values(ctx + (goal.a,), goal.b, s - 1, depth - 1)]
            elif isinstance(goal, And):
                for s1 in range(1, s - 1):
                    s2 = s - 1 - s1
                    lefts = values(ctx, goal.a, s1, depth - 1)
                    if not lefts:
                        continue
                    for b in values(ctx, goal.b, s2, depth - 1):
                        out.extend(Pair(a, b) for a in lefts)
            else:
                if isinstance(goal, Or):
                    out.extend(Inl(a) for a in values(ctx, goal.a, s - 1, depth - 1))
                    out.extend(Inr(a) for a in values(ctx, goal.b, s - 1, depth - 1))
                out.extend(n for n, tn in neutrals(ctx, s, depth) if tn == goal)
                out.extend(Abort(n) for n, tn in neutrals(ctx, s - 1, depth - 1) if isinstance(tn, Bot))
                for sn in range(1, s - 2):
                    ors = [(n, tn) for n, tn in neutrals(ctx, sn, depth - 1) if isinstance(tn, Or)]
                    if not ors:
                        continue
                    for sl in range(1, s - 1 - sn):
                        sr = s - 1 - sn - sl
                        for n, tn in ors:
                            ls = values(ctx + (tn.a,), goal, sl, depth - 1)
                            if not ls:
                                continue
                            rs = values(ctx + (tn.b,), goal, sr, depth - 1)
                            for l in ls:
                                out.extend(Case(n, l, r) for r in rs)
        out = cap(out)
        memo_v[key] = out
        return out

    found: dict[tuple, int] = {}
    max_size_reached = 0
    try:
        for s in range(1, max_size + 1):
            for t in values((), goal, s, depth_max):
                assert is_valid(t, goal), "enumerator produced an invalid term"
                nf = normal_form(t, goal)
                k = tuple(term_tokens(nf))
                if k not in found:
                    found[k] = term_size(nf)
                    if len(found) >= max_count:
                        caps_hit["max_count"] = True
                        raise EnumBudget
            max_size_reached = s
    except EnumBudget:
        if nodes[0] > node_cap:
            caps_hit["node_cap"] = True
    record = {"max_size": max_size, "max_size_completed": max_size_reached, "nodes": nodes[0],
              "node_cap": node_cap, "list_cap": list_cap, "max_count": max_count, "caps_hit": caps_hit}
    return list(found.items()), record


# ----------------------------------------------------------------------------
# Size tertiles and C4 matching


def tertile_boundaries(sizes: list[int]) -> tuple[float, float]:
    """Boundaries fixed on the full held-out set (spec "Length control")."""
    a = np.asarray(sizes, dtype=float)
    return float(np.quantile(a, 1 / 3)), float(np.quantile(a, 2 / 3))


def tertile_of(size: int, bounds: tuple[float, float]) -> int:
    return 0 if size <= bounds[0] else (1 if size <= bounds[1] else 2)


def match_by_tertile(pool: list[tuple[tuple, int]], target_sizes: list[int],
                     bounds: tuple[float, float], rng: random.Random,
                     ) -> tuple[list[tuple[tuple, int]], dict]:
    """Sample from pool (key, size) without replacement so that the count per
    tertile equals that of target_sizes, as far as the pool allows."""
    want = [0, 0, 0]
    for s in target_sizes:
        want[tertile_of(s, bounds)] += 1
    by_band: list[list] = [[], [], []]
    for k, s in pool:
        by_band[tertile_of(s, bounds)].append((k, s))
    chosen, got, short = [], [0, 0, 0], [0, 0, 0]
    for b in range(3):
        cand = by_band[b][:]
        rng.shuffle(cand)
        take = cand[: want[b]]
        chosen.extend(take)
        got[b] = len(take)
        short[b] = want[b] - len(take)
    return chosen, {"want": want, "got": got, "shortfall": short, "pool_by_band": [len(x) for x in by_band]}
