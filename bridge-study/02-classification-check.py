# Phase 2 verification. Registered spec: SPEC.md, Phase 2 (C1-C3,
# E4-E6, kills K4-K6). Reuses the Phase-1 engine.
#
# E4: on every Phase-1 algebra, the exhaustively enumerated nuclei
#     coincide bijectively with { j_S : S subset of P },
#     j_S(U) = { x : down(x) & S <= U }.
# E5: Opens j_S k  <=>  the trace k & S is ordinary in D(S).
# E6: phantomMass(j_S, k) = #D(induced poset on j_S(k) \ k).
#
# Usage: python 02-classification-check.py

import itertools
import random
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
mod = __import__("01-downset-pilot")

SEED = 20260912


def j_S_table(A, S_mask):
    """The nucleus j_S as a table over algebra element indices."""
    n = A.n
    tab = []
    for U in A.elems:
        m = 0
        for x in range(n):
            if A.down[x] & S_mask & ~U == 0:
                m |= 1 << x
        tab.append(A.idx[m])
    return tuple(tab)


def sub_algebra(n, leq, S_mask):
    """Down-set algebra of the induced subposet on S (as an Algebra
    over the same n nodes, with non-S nodes removed by restriction)."""
    nodes = [x for x in range(n) if S_mask >> x & 1]
    k = len(nodes)
    sub_leq = [[leq[nodes[i]][nodes[j]] for j in range(k)] for i in range(k)]
    return mod.Algebra(k, sub_leq), nodes


def check_graph(name, n, edges):
    leq = mod.transitive_closure(n, edges)
    fails = []
    for side, rel in (("dep", leq),
                      ("dept", [[leq[j][i] for j in range(n)] for i in range(n)])):
        A = mod.Algebra(n, rel)
        nuclei = mod.all_nuclei(A)
        enumerated = {tuple(j) for j in nuclei}
        # ---- E4: bijection ----
        from_subsets = {}
        for S in range(1 << n):
            t = j_S_table(A, S)
            if t in from_subsets:
                fails.append((name, side, "K4 collision", S, from_subsets[t]))
            from_subsets[t] = S
        if set(from_subsets) != enumerated:
            fails.append((name, side, "K4 mismatch",
                          len(from_subsets), len(enumerated)))
            continue
        # ---- E5 / E6 per principal cone and subset ----
        for S in range(1 << n):
            t = from_subsets_inv = j_S_table(A, S)
            B, nodes = sub_algebra(n, rel, S)
            jbot = t[A.bot]
            for x in range(n):
                k = A.idx[A.down[x]]
                jk = t[k]
                # Opens in D(P): world-negation twice, ambient himp
                w = A.imp[jk][jbot]
                opens = (w != jbot) and (A.imp[w][jbot] != jk)
                # trace k & S as element of D(S)
                trace = 0
                for i, nd in enumerate(nodes):
                    if A.elems[k] >> nd & 1:
                        trace |= 1 << i
                tr_idx = B.idx[trace]
                _, _, tr_ordinary = B.flags(tr_idx)
                if opens != tr_ordinary:
                    fails.append((name, side, "K5", S, x, opens, tr_ordinary))
                # E6: phantom mass vs relative down-sets of j_S(k) \ k
                pm = A.icc_card(k, jk)
                diff_mask = A.elems[jk] & ~A.elems[k]
                D, _ = sub_algebra(n, rel, diff_mask)
                if pm != D.size:
                    fails.append((name, side, "K6", S, x, pm, D.size))
    return fails


def main():
    all_fails = []
    checked = 0
    for name, n, edges, _ in mod.MOTIFS:
        f = check_graph(name, n, edges)
        all_fails += f
        checked += 1
        print(f"{name}: {'OK' if not f else f'{len(f)} FAILURES'}")
    rng = random.Random(SEED)
    for g in range(mod.ENSEMBLE_N):
        n = mod.ENSEMBLE_NODES
        edges = [(i, j) for i in range(n) for j in range(i)
                 if rng.random() < mod.EDGE_P]
        f = check_graph(f"g{g}", n, edges)
        all_fails += f
        checked += 1
        if f:
            print(f"g{g}: {len(f)} FAILURES: {f[:3]}")
    print(f"\n{checked} graphs checked (both sides each).")
    if all_fails:
        print(f"KILLED: {len(all_fails)} failures. First: {all_fails[0]}")
    else:
        print("E4 PASS (bijection nuclei <-> subsets, all algebras)")
        print("E5 PASS (Opens j_S k <=> trace (k meet S) ordinary in D(S), "
              "all cones, all subsets)")
        print("E6 PASS (phantomMass(j_S,k) = #D(j_S(k) \\ k), "
              "all cones, all subsets)")
        print("No kill fired. C1-C3 verified on every Phase-1 algebra.")


if __name__ == "__main__":
    main()
