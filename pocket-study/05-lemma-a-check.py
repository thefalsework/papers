# Lemma A check (2026-09-16, before the Lean formalization).
#
# Hand proof found while scoping the meet-lemma. Two statements:
#
# Lemma A: if S is compatible with step (a, b), U is a down-set,
#   b is in j_S U, and b is NOT in U, then downset(a) is contained
#   in j_S U.
#   (Derivation: compatibility at U with cl'U = U gives
#   j_S U ∪ downset(a) = j'_S U; for x <= a we have down'(x) =
#   down(x), so membership in j'_S U at x reduces to membership in
#   j_S U; hence every x <= a lands in j_S U.)
#
# Theorem (meet half): S, T compatible implies S ∪ T compatible.
#   (Cases on b's membership in A = j_S U, B = j_T U; the mixed
#   case is closed by Lemma A since downset(a) ∩ B ⊆ A ∩ B.)
#
# This script verifies Lemma A and re-verifies the meet half on
# every step of the exhaustive survey, as a guard against a hand
# error before the Lean work starts.
#
# Usage: python 05-lemma-a-check.py

import importlib.util
import os

HERE = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location(
    "oracle", os.path.join(HERE, "01-commutation-oracle.py"))
oracle = importlib.util.module_from_spec(spec)
oracle.__name__ = "oracle"
spec.loader.exec_module(oracle)

lemma_a_checked = lemma_a_failed = 0
meet_checked = meet_failed = 0

for n, down in oracle.all_posets_upto(5):
    full = (1 << n) - 1
    ds = oracle.downsets(n, down)
    for (a, b) in oracle.incomparable_pairs(n, down):
        down2 = oracle.add_edge(n, down, a, b)
        clp = oracle.make_clp(n, down, a, b)
        comp = [S for S in range(1 << n)
                if oracle.compatible(n, down, down2, clp, ds, S)]
        comp_set = set(comp)
        da = down[a]  # downset of a, including a
        for S in comp:
            for U in ds:
                jU = oracle.nucleus_apply(n, down, S, U)
                if (jU >> b) & 1 and not (U >> b) & 1:
                    lemma_a_checked += 1
                    if (jU & da) != da:
                        lemma_a_failed += 1
        # meet half: union of compatible supports is compatible
        for i, S in enumerate(comp):
            for T in comp[i + 1:]:
                meet_checked += 1
                if (S | T) not in comp_set:
                    meet_failed += 1

print("=== Lemma A ===")
print(f"  instances (S compatible, b in jU, b not in U): "
      f"{lemma_a_checked}")
print(f"  failures of downset(a) <= j_S U: {lemma_a_failed}  "
      f"({'CONFIRMS hand proof' if lemma_a_failed == 0 else 'HAND ERROR'})")

print("\n=== Meet half (union of compatible supports compatible) ===")
print(f"  pairs: {meet_checked}, failures: {meet_failed}  "
      f"({'CONFIRMS' if meet_failed == 0 else 'CONTRADICTS'})")
