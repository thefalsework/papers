# Decomposition check (2026-09-16, after the KD2 literature read;
# see absint-dictionary/SPEC.md Postscript 2).
#
# Two hand proofs marked [H] there, re-checked against the survey
# machinery per house rules before being treated as fact:
#
# 1. Decomposition: compatibility (cl' o j_S = j'_S o cl') holds iff
#    BOTH backward completeness (j'_S o cl' = j'_S o cl' o j_S) AND
#    forward completeness (cl' o j_S = j'_S o cl' o j_S) hold.
#    (Hand proof: two lines from idempotence.)
#
# 2. The reduced-product reading: pointwise j_{S∪T} U = j_S U ∩ j_T U,
#    and Fix(j_{S∪T}) = {A ∩ B : A in Fix(j_S), B in Fix(j_T)}
#    (products direction checked directly; the other containment is
#    constructive from the pointwise identity: U fixed implies
#    U = j_S U ∩ j_T U with both factors fixed by idempotence).
#
# Exhaustive at n <= 4; seeded sampling of support pairs at n = 5.
#
# Usage: python 06-decomposition-check.py

import importlib.util
import os
import random

HERE = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location(
    "oracle", os.path.join(HERE, "01-commutation-oracle.py"))
oracle = importlib.util.module_from_spec(spec)
oracle.__name__ = "oracle"
spec.loader.exec_module(oracle)

SEED = 20260916
PAIR_SAMPLE_N5 = 60

rng = random.Random(SEED)

# ---- check 1: compatibility == backward AND forward ----

triples = mismatches = 0
bw_only = fw_only = both_fail = 0

for n, down in oracle.all_posets_upto(5):
    ds = oracle.downsets(n, down)
    for (a, b) in oracle.incomparable_pairs(n, down):
        down2 = oracle.add_edge(n, down, a, b)
        clp = oracle.make_clp(n, down, a, b)
        for S in range(1 << n):
            compat = backward = forward = True
            for U in ds:
                jU = oracle.nucleus_apply(n, down, S, U)
                lhs = clp(jU)                                  # cl' o j
                rhs = oracle.nucleus_apply(n, down2, S, clp(U))  # j' o cl'
                mid = oracle.nucleus_apply(n, down2, S, clp(jU))  # j' cl' j
                if lhs != rhs:
                    compat = False
                if rhs != mid:
                    backward = False
                if lhs != mid:
                    forward = False
            triples += 1
            if compat != (backward and forward):
                mismatches += 1
            if not compat:
                if backward and not forward:
                    fw_only += 1
                elif forward and not backward:
                    bw_only += 1
                elif not backward and not forward:
                    both_fail += 1

print("=== Check 1: compatibility == backward AND forward ===")
print(f"  (step, S) pairs: {triples}, decomposition mismatches: "
      f"{mismatches}  "
      f"({'CONFIRMS hand proof' if mismatches == 0 else 'HAND ERROR'})")
print(f"  incompatible pairs split: backward-fails-only {bw_only}, "
      f"forward-fails-only {fw_only}, both fail {both_fail}")
print(f"  (both notions independently violable: "
      f"{'yes' if bw_only > 0 and fw_only > 0 else 'NO - check'})")

# ---- check 2: reduced-product reading ----

pw_checked = pw_failed = 0
fix_checked = fix_failed = 0

for n, down in oracle.all_posets_upto(5):
    ds = oracle.downsets(n, down)
    supports = list(range(1 << n))
    if n <= 4:
        pairs = [(S, T) for i, S in enumerate(supports)
                 for T in supports[i:]]
    else:
        pairs = [tuple(rng.sample(supports, 2))
                 for _ in range(PAIR_SAMPLE_N5)]
    # precompute fixpoint sets
    fix = {S: [U for U in ds
               if oracle.nucleus_apply(n, down, S, U) == U]
           for S in supports}
    for (S, T) in pairs:
        # pointwise identity
        for U in ds:
            pw_checked += 1
            if oracle.nucleus_apply(n, down, S | T, U) != \
               (oracle.nucleus_apply(n, down, S, U) &
                    oracle.nucleus_apply(n, down, T, U)):
                pw_failed += 1
        # products land in Fix(j_{S|T})
        fixST = set(fix[S | T])
        for A in fix[S]:
            for B in fix[T]:
                fix_checked += 1
                if (A & B) not in fixST:
                    fix_failed += 1

print("\n=== Check 2: reduced-product reading ===")
print(f"  pointwise j_(S|T) U == j_S U & j_T U: {pw_checked} checked, "
      f"{pw_failed} failures  "
      f"({'CONFIRMS' if pw_failed == 0 else 'HAND ERROR'})")
print(f"  products A&B land in Fix(j_(S|T)): {fix_checked} checked, "
      f"{fix_failed} failures  "
      f"({'CONFIRMS' if fix_failed == 0 else 'HAND ERROR'})")
