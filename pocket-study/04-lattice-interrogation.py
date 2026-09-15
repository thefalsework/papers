# Lattice interrogation (external review, 2026-09-15 evening).
#
# The corrected picture from review: compatible nuclei are closed
# under (pointwise) meet whenever the step preserves binary meets.
# Hand fact, proved before this run: cl' does NOT preserve binary
# meets in general — universal witness U = down(a), V = down(b):
# cl'U ∩ cl'V = down(a) but cl'(U ∩ V) = down(a) ∩ down(b), and
# a is in the former, not the latter. So the three-line route is
# dead. Yet the survey found closure exceptionlessly. Hence:
#
# V1  Confirm the universal meet-failure witness on every step.
# V2  Candidate lemma: for COMPATIBLE S, T the step preserves the
#     meet of their images — cl'(j_S U ∩ j_T U) =
#     cl'(j_S U) ∩ cl'(j_T U) for all U. If exceptionless, this
#     is the real lemma behind the observed closure (meet half =
#     this + three lines), recorded [O], Lean target.
# V3  The review's third-hat worry: among EXCESS compatibles
#     (non-singleton, nontrivial), do meets (support unions) and
#     joins (support intersections) land back in the excess, or
#     always in the forced set? If always forced, the lattice
#     result is the singleton artifact wearing a third hat.
#
# Usage: python 04-lattice-interrogation.py

import importlib.util
import os
from itertools import combinations

HERE = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location(
    "oracle", os.path.join(HERE, "01-commutation-oracle.py"))
oracle = importlib.util.module_from_spec(spec)
oracle.__name__ = "oracle"
spec.loader.exec_module(oracle)

v1_witness_ok = 0
v1_total = 0
v2_violations = []
v2_pairs_checked = 0
v3_meet_excess = v3_meet_trivial = 0
v3_join_excess = v3_join_forced = 0


def is_excess(S, n, full):
    return S not in (0, full) and bin(S).count("1") != 1


for n, down in oracle.all_posets_upto(5):
    full = (1 << n) - 1
    ds = oracle.downsets(n, down)
    for (a, b) in oracle.incomparable_pairs(n, down):
        down2 = oracle.add_edge(n, down, a, b)
        clp = oracle.make_clp(n, down, a, b)
        v1_total += 1

        # V1: the universal witness down(a), down(b)
        Ua, Ub = down[a], down[b]
        lhs = clp(Ua & Ub)
        rhs = clp(Ua) & clp(Ub)
        if lhs != rhs and (rhs >> a) & 1 and not (lhs >> a) & 1:
            v1_witness_ok += 1

        comp = [S for S in range(1 << n)
                if oracle.compatible(n, down, down2, clp, ds, S)]
        comp_set = set(comp)

        # V2: image meet-preservation on compatible pairs
        images = {S: {U: oracle.nucleus_apply(n, down, S, U) for U in ds}
                  for S in comp}
        for S, T in combinations(comp, 2):
            v2_pairs_checked += 1
            for U in ds:
                A, B = images[S][U], images[T][U]
                if clp(A & B) != clp(A) & clp(B):
                    v2_violations.append((n, down, (a, b), S, T, U))
                    break

        # V3: where do meets/joins of excess pairs land?
        excess = [S for S in comp if is_excess(S, n, full)]
        for S, T in combinations(excess, 2):
            m = S | T          # nucleus meet = support union
            j = S & T          # nucleus join = support intersection
            if is_excess(m, n, full):
                v3_meet_excess += 1
            else:
                v3_meet_trivial += 1
            if is_excess(j, n, full):
                v3_join_excess += 1
            else:
                v3_join_forced += 1

print("=== V1: universal meet-failure witness (down(a), down(b)) ===")
print(f"  steps: {v1_total}, witness fired: {v1_witness_ok} "
      f"({v1_witness_ok / v1_total:.1%})")
print("  (cl' provably fails binary meet-preservation; the three-line")
print("   route to meet-closure is dead)")

print("\n=== V2: image meet-preservation on compatible pairs ===")
print(f"  compatible pairs checked: {v2_pairs_checked}")
print(f"  violations of cl'(jS U meet jT U) = cl'(jS U) meet cl'(jT U): "
      f"{len(v2_violations)}")
if v2_violations:
    n_, d_, e_, S_, T_, U_ = v2_violations[0]
    print(f"  first: n={n_} down={list(d_)} edge={e_} "
          f"S={S_:b} T={T_:b} U={U_:b}")
else:
    print("  EXCEPTIONLESS: candidate lemma stands — compatibility")
    print("  implies the step preserves the meet of the two images.")

print("\n=== V3: meets/joins of excess-compatible pairs ===")
tm = v3_meet_excess + v3_meet_trivial
tj = v3_join_excess + v3_join_forced
print(f"  pairs: {tm}")
print(f"  meet (support union): excess {v3_meet_excess} "
      f"({v3_meet_excess / tm:.1%}), trivial/forced {v3_meet_trivial}")
print(f"  join (support intersection): excess {v3_join_excess} "
      f"({v3_join_excess / tj:.1%}), forced {v3_join_forced}")
