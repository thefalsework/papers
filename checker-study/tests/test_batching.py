"""Batch-layout and prompt-order independence of the condition samplers
(spec postscript 2026-09-29, "Conditions", seeding).

Runs C1 for a few fresh formulas as one batch, as several batches, as
singles, and with the prompts in reverse order; every layout must give the
same tokens and draw counts. Runs C3 twice; completions must be identical.

Usage: python tests/test_batching.py [--profile feasibility --seed 0 --n-prompts 3]
"""
from __future__ import annotations

import argparse
import json
import random
import sys
from pathlib import Path

import torch

HERE = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(HERE))
from ipl.terms import canonical_formula, formula_tokens, parse_formula  # noqa: E402
from ipl.gen import random_formula, random_proof  # noqa: E402
from ipl.model import GPT, GPTConfig, encode_pair  # noqa: E402
from ipl.conditions import guided_search, sample_counted  # noqa: E402


def fresh(n: int, seed: int) -> list[list[str]]:
    rng = random.Random(seed)
    out, seen = [], set()
    while len(out) < n:
        f = random_formula(rng)
        if random_proof(f, rng) is None:
            continue
        key = tuple(formula_tokens(canonical_formula(f)))
        if key not in seen:
            seen.add(key)
            out.append(list(key))
    return out


def c1_signature(samples) -> list[tuple]:
    return sorted((s.sample_index, tuple(s.tokens), s.n_drawn, s.terminated) for s in samples)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--profile", default="feasibility")
    ap.add_argument("--seed", type=int, default=0)
    ap.add_argument("--n-prompts", type=int, default=3)
    ap.add_argument("--n-samples", type=int, default=64)
    ap.add_argument("--threads", type=int, default=1)
    args = ap.parse_args()
    torch.set_num_threads(args.threads)

    ck = torch.load(HERE / "models" / args.profile / f"seed{args.seed}.pt", map_location="cpu")
    model = GPT(GPTConfig(**ck["config"]))
    model.load_state_dict(ck["state"])
    model.eval()
    block = model.c.block_size
    formulas = fresh(args.n_prompts, seed=424242)
    N = args.n_samples

    failures = 0
    for formula in formulas:
        goal, _ = parse_formula(formula)
        fid = encode_pair(formula, None)
        max_new = block - len(fid) - 1
        one = c1_signature(sample_counted(model, formula, fid, list(range(N)), 1.0, max_new, "cpu"))
        quarters = c1_signature(
            s for a in range(0, N, N // 4)
            for s in sample_counted(model, formula, fid, list(range(a, a + N // 4)), 1.0, max_new, "cpu"))
        singles = c1_signature(
            s for j in range(N) for s in sample_counted(model, formula, fid, [j], 1.0, max_new, "cpu"))
        ok = one == quarters == singles
        budget = sum(x[2] for x in one)
        c3a, sta = guided_search(model, goal, formula, fid, budget, 1.0, max_new, "cpu", frozenset())
        c3b, stb = guided_search(model, goal, formula, fid, budget, 1.0, max_new, "cpu", frozenset())
        ok3 = [(c.key, c.found_at_draw) for c in c3a] == [(c.key, c.found_at_draw) for c in c3b] and sta == stb
        print(f"{' '.join(formula)}\n  C1 one==quarters==singles: {ok}  budget={budget}  "
              f"C3 repeat identical: {ok3} ({len(c3a)} completions)")
        failures += (not ok) + (not ok3)

    # prompt order: run the set reversed and compare per formula
    forward = {tuple(f): c1_signature(sample_counted(model, f, encode_pair(f, None), list(range(N)), 1.0,
                                                    block - len(encode_pair(f, None)) - 1, "cpu"))
               for f in formulas}
    backward = {tuple(f): c1_signature(sample_counted(model, f, encode_pair(f, None), list(range(N)), 1.0,
                                                     block - len(encode_pair(f, None)) - 1, "cpu"))
                for f in reversed(formulas)}
    order_ok = forward == backward
    print(f"prompt order independence: {order_ok}")
    failures += not order_ok

    print(json.dumps({"formulas": len(formulas), "failures": failures}))
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
