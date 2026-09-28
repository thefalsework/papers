"""K-check: Python checker vs Lean on 1,000 valid and 1,000 mutated
invalid terms (SPEC.md, "Domain and checker"). Any disagreement stops
the study.

Usage: python 01-crosscheck.py [--seed N] [--n 1000] [--toolchain T]
Writes out/crosscheck.lean, out/crosscheck.json. Exit 1 on disagreement.
"""
from __future__ import annotations

import argparse
import json
import random
import re
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from ipl.terms import (  # noqa: E402
    formula_size, formula_str, formula_tokens, term_depth, term_size, term_str,
)
from ipl.check import is_valid, Reject, check  # noqa: E402
from ipl.gen import DEFAULT_BUDGET, mutate, random_formula, random_proof  # noqa: E402
from ipl.lean_export import HEADER, LEAN_FLAGS, lean_decl  # noqa: E402

OUT = Path(__file__).parent / "out"
SEED = 20260928
TOOLCHAIN = "leanprover/lean4:v4.30.0-rc2"


def reject_reason(t, f) -> str:
    try:
        check((), t, f)
        return ""
    except Reject as e:
        return str(e)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--seed", type=int, default=SEED)
    ap.add_argument("--n", type=int, default=1000)
    ap.add_argument("--toolchain", default=TOOLCHAIN)
    args = ap.parse_args()
    OUT.mkdir(exist_ok=True)
    rng = random.Random(args.seed)

    t0 = time.time()
    valid: list = []
    tried = 0
    while len(valid) < args.n:
        f = random_formula(rng)
        tried += 1
        t = random_proof(f, rng)
        if t is not None:
            valid.append((f, t))

    invalid: list = []
    reasons: dict[str, int] = {}
    out_of_fragment = 0
    while len(invalid) < args.n:
        f, t = rng.choice(valid)
        m = mutate(t, rng)
        # up to three stacked edits if one edit leaves the term valid
        for _ in range(2):
            if not is_valid(m, f):
                break
            m = mutate(m, rng)
        if is_valid(m, f):
            continue
        r = reject_reason(m, f)
        if r.startswith("non-neutral in inference position"):
            # Beta-redex: outside the normal-form fragment. Lean would judge
            # it by type alone, so it is not a typing comparison; skipped
            # and counted.
            out_of_fragment += 1
            continue
        reasons[r] = reasons.get(r, 0) + 1
        invalid.append((f, m))
    gen_secs = time.time() - t0

    # All items are well-formed by construction (mutation preserves the
    # grammar); SPEC requires at least half well-formed-but-ill-typed.
    unbound = reasons.get("unbound variable", 0)

    items = [("ok", f, t) for f, t in valid] + [("bad", f, t) for f, t in invalid]
    lines = HEADER.split("\n")
    decl_line: dict[int, int] = {}
    for idx, (kind, f, t) in enumerate(items):
        decl_line[len(lines) + 1] = idx  # 1-based line numbers
        lines.append(lean_decl(f"chk_{kind}_{idx:04d}", f, t))
    lean_path = OUT / "crosscheck.lean"
    lean_path.write_text("\n".join(lines) + "\n", encoding="utf-8")

    t1 = time.time()
    proc = subprocess.run(
        ["elan", "run", args.toolchain, "lean", *LEAN_FLAGS, str(lean_path)],
        capture_output=True, text=True, encoding="utf-8", errors="replace",
    )
    lean_secs = time.time() - t1
    ver = subprocess.run(["elan", "run", args.toolchain, "lean", "--version"],
                         capture_output=True, text=True).stdout.strip()

    if "maximum number of errors" in proc.stdout + proc.stderr:
        print("Lean stopped early at maxErrors; results incomplete", file=sys.stderr)
        return 2
    lean_rejects: set[int] = set()
    for mline in re.finditer(r"crosscheck\.lean:(\d+):\d+: error", proc.stdout + proc.stderr):
        ln = int(mline.group(1))
        if ln in decl_line:
            lean_rejects.add(decl_line[ln])
        else:
            print(f"error on non-declaration line {ln}", file=sys.stderr)
            return 2

    disagreements = []
    for idx, (kind, f, t) in enumerate(items):
        py_ok = kind == "ok"
        lean_ok = idx not in lean_rejects
        if py_ok != lean_ok:
            disagreements.append({
                "idx": idx, "python_valid": py_ok, "lean_valid": lean_ok,
                "formula": formula_str(f), "term": term_str(t),
            })

    result = {
        "ranAt": datetime.now(timezone.utc).isoformat(),
        "seed": args.seed,
        "n_valid": len(valid), "n_invalid": len(invalid),
        "formulas_tried_for_valid": tried,
        "search_budget": DEFAULT_BUDGET,
        "lean_toolchain": args.toolchain, "lean_version": ver,
        "lean_exit_code": proc.returncode,
        "lean_accepted_valid": sum(1 for i in range(len(valid)) if i not in lean_rejects),
        "lean_rejected_invalid": sum(1 for i in range(len(valid), len(items)) if i in lean_rejects),
        "disagreements": disagreements,
        "agree_all": not disagreements,
        "invalid_reject_reasons": reasons,
        "invalid_unbound_variable": unbound,
        "mutants_skipped_out_of_fragment": out_of_fragment,
        "invalid_well_formed_ill_typed": len(invalid) - unbound,
        "valid_size_stats": _stats([term_size(t) for _, t in valid]),
        "valid_depth_stats": _stats([term_depth(t) for _, t in valid]),
        "formula_size_stats": _stats([formula_size(f) for f, _ in valid]),
        "gen_seconds": round(gen_secs, 2), "lean_seconds": round(lean_secs, 2),
    }
    (OUT / "crosscheck.json").write_text(json.dumps(result, indent=2), encoding="utf-8")
    print(json.dumps({k: v for k, v in result.items() if k != "disagreements"}, indent=2))
    if disagreements:
        print(f"K-check FIRED: {len(disagreements)} disagreements", file=sys.stderr)
        for d in disagreements[:10]:
            print(d, file=sys.stderr)
        return 1
    print("K-check passed: Python and Lean agree on all", len(items))
    return 0


def _stats(xs: list[int]) -> dict:
    xs = sorted(xs)
    n = len(xs)
    return {"min": xs[0], "median": xs[n // 2], "max": xs[-1], "mean": round(sum(xs) / n, 2)}


if __name__ == "__main__":
    sys.exit(main())
