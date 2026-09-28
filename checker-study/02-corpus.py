"""Build the three disjoint corpora (SPEC.md, "Corpus").

Pool: unique (canonical formula, eta-long proof) pairs from the generator.
Formulas are atom-order canonicalised and deduplicated (one proof per
formula); proofs stored in eta-long normal form. Sets are split within
formula-size bands so bands are comparable across sets; no formula
appears in more than one set.

Usage: python 02-corpus.py --profile feasibility|main [--seed N]
Writes data/<profile>/{train,heldout,test}.jsonl and meta.json.
"""
from __future__ import annotations

import argparse
import json
import random
import sys
import time
from collections import Counter, defaultdict
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from ipl.terms import (  # noqa: E402
    canonical_formula, formula_size, formula_tokens, term_depth, term_size,
    term_tokens,
)
from ipl.check import is_valid, normal_form  # noqa: E402
from ipl.gen import DEFAULT_BUDGET, DEPTH_MAX, random_formula, random_proof  # noqa: E402

PROFILES = {
    "feasibility": {"train": 5_000, "heldout": 1_000, "test": 0},
    "main": {"train": 100_000, "heldout": 5_000, "test": 2_000},
}
SEED = 20260928


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--profile", choices=PROFILES, required=True)
    ap.add_argument("--seed", type=int, default=SEED)
    args = ap.parse_args()
    sizes = PROFILES[args.profile]
    total = int(sum(sizes.values()) * 1.03) + 10  # slack so rounding never leaves a set short
    rng = random.Random(args.seed)
    out = Path(__file__).parent / "data" / args.profile
    out.mkdir(parents=True, exist_ok=True)

    t0 = time.time()
    pool: dict[tuple, dict] = {}
    tried = 0
    proved = 0
    while len(pool) < total:
        f = random_formula(rng)
        tried += 1
        t = random_proof(f, rng)
        if t is None:
            continue
        proved += 1
        cf = canonical_formula(f)
        key = tuple(formula_tokens(cf))
        if key in pool:
            continue
        # the proof term does not mention atoms, so it proves cf as well
        nf = normal_form(t, cf)
        assert is_valid(nf, cf)
        pool[key] = {
            "formula": list(key),
            "proof": term_tokens(nf),
            "formula_size": formula_size(cf),
            "term_size": term_size(nf),
            "term_depth": term_depth(nf),
        }
    gen_secs = time.time() - t0

    # stratified disjoint split by formula size
    by_size: dict[int, list] = defaultdict(list)
    for item in pool.values():
        by_size[item["formula_size"]].append(item)
    for lst in by_size.values():
        rng.shuffle(lst)

    splits: dict[str, list] = {k: [] for k in sizes}
    for s, lst in sorted(by_size.items()):
        share = len(lst) / len(pool)
        # per-band allocation proportional to overall set sizes (rounded up
        # for the small sets); remainder to train; exact sizes trimmed below
        alloc = {k: -(-n * len(lst) // len(pool)) for k, n in sizes.items()}
        cursor = 0
        for k in ("test", "heldout", "train"):
            take = lst[cursor: cursor + alloc[k]] if k != "train" else lst[cursor:]
            splits[k].extend(take)
            cursor += len(take)
    # trim to exact sizes; the trim is a uniform random subsample, so band
    # proportions are preserved in expectation
    for k, n in sizes.items():
        assert len(splits[k]) >= n, (k, len(splits[k]), n)
        rng.shuffle(splits[k])
        splits[k] = splits[k][:n]

    fset = set()
    for k, items in splits.items():
        for it in items:
            key = tuple(it["formula"])
            assert key not in fset, "formula in two sets"
            fset.add(key)

    for k, items in splits.items():
        with (out / f"{k}.jsonl").open("w", encoding="utf-8") as fh:
            for it in items:
                rec = it if k != "test" else {"formula": it["formula"], "formula_size": it["formula_size"]}
                fh.write(json.dumps(rec) + "\n")

    def band_hist(items):
        return dict(sorted(Counter(i["formula_size"] for i in items).items()))

    meta = {
        "builtAt": datetime.now(timezone.utc).isoformat(),
        "profile": args.profile, "seed": args.seed,
        "sizes": {k: len(v) for k, v in splits.items()},
        "formulas_tried": tried, "proofs_found": proved, "unique_formulas": len(pool),
        "search_budget": DEFAULT_BUDGET, "depth_max": DEPTH_MAX,
        "formula_size_hist": {k: band_hist(v) for k, v in splits.items()},
        "term_size_stats": {k: _stats([i["term_size"] for i in v]) for k, v in splits.items() if k != "test"},
        "max_sequence_tokens": max(
            len(i["formula"]) + 1 + len(i["proof"]) + 1 for k, v in splits.items() if k != "test" for i in v
        ),
        "gen_seconds": round(gen_secs, 1),
    }
    (out / "meta.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")
    print(json.dumps(meta, indent=2))
    return 0


def _stats(xs):
    xs = sorted(xs)
    n = len(xs)
    return {"min": xs[0], "median": xs[n // 2], "p90": xs[int(n * 0.9)], "max": xs[-1],
            "mean": round(sum(xs) / n, 2)}


if __name__ == "__main__":
    sys.exit(main())
