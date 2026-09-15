# Deflation check (written after external review of the Phase-1
# postscript; registered intent: interrogate the 100% before a
# referee does).
#
# D1  The future-watcher S = {b} commutes with every step. Hand proof
#     (recorded in the spec amendment): adding a < b changes nothing
#     at or above b, so j_{b} has the same closed form on both sides,
#     and cl' never moves its image.
# D1b Stronger forced family: every singleton {x} with NOT (x <= a)
#     commutes. Hand proof sketch: up'(x) = up(x) and downset(a) is
#     disjoint from up(x), so cl' absorbs downset(a) into P \ up(x)
#     harmlessly.
# D2  Discrimination: per-step count of compatible observers beyond
#     the forced supply (non-singleton, nontrivial). If this excess
#     has spread (some steps near zero, some large), the definition
#     discriminates; if it is uniformly large, pockets are free.
# D3  Q3 whisper with a denominator: phantom change stratified by
#     support size |S|, compatible vs incompatible within strata.
#
# Usage: python 03-deflation-check.py

import importlib.util
import os
import statistics

HERE = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location(
    "oracle", os.path.join(HERE, "01-commutation-oracle.py"))
oracle = importlib.util.module_from_spec(spec)
oracle.__name__ = "oracle"
spec.loader.exec_module(oracle)

d1_fail = d1b_fail = 0
excess_list = []
zero_excess = 0
sing_pred_mism = []          # singletons: compatible vs (x <= a) pattern
strat = {}                   # |S| -> {True: [dpm], False: [dpm]}

for n, down in oracle.all_posets_upto(5):
    full = (1 << n) - 1
    ds = oracle.downsets(n, down)
    for (a, b) in oracle.incomparable_pairs(n, down):
        down2 = oracle.add_edge(n, down, a, b)
        clp = oracle.make_clp(n, down, a, b)
        comp = set()
        for S in range(1 << n):
            if oracle.compatible(n, down, down2, clp, ds, S):
                comp.add(S)
        # D1
        if (1 << b) not in comp:
            d1_fail += 1
        # D1b + singleton census
        forced_singletons = 0
        for x in range(n):
            below_a = bool((down[a] >> x) & 1)   # x <= a
            is_comp = (1 << x) in comp
            if not below_a:
                forced_singletons += 1
                if not is_comp:
                    d1b_fail += 1
            elif is_comp:
                sing_pred_mism.append((n, down, (a, b), x))
        # D2: nontrivial, non-singleton compatibles
        excess = sum(1 for S in comp
                     if S not in (0, full) and bin(S).count("1") != 1)
        excess_list.append(excess)
        if excess == 0:
            zero_excess += 1
        # D3: phantom change by |S| and compatibility
        for S in range(1 << n):
            size = bin(S).count("1")
            d = 0
            for p in range(n):
                k0, k1 = down[p], down2[p]
                pm0 = oracle.rel_downset_count(
                    down, oracle.nucleus_apply(n, down, S, k0) & ~k0)
                pm1 = oracle.rel_downset_count(
                    down2, oracle.nucleus_apply(n, down2, S, k1) & ~k1)
                d += pm1 - pm0
            strat.setdefault(size, {True: [], False: []})[S in comp].append(d)

print("=== D1: future-watcher universality ===")
print(f"  steps where S={{b}} failed to commute: {d1_fail}  "
      f"({'CONFIRMS hand proof' if d1_fail == 0 else 'CONTRADICTS'})")

print("\n=== D1b: forced singletons (x not <= a) ===")
print(f"  violations: {d1b_fail}  "
      f"({'CONFIRMS' if d1b_fail == 0 else 'CONTRADICTS'})")
print(f"  compatible singletons with x <= a (not forced, still "
      f"compatible): {len(sing_pred_mism)} instances "
      f"(condition sufficient, not necessary)")

print("\n=== D2: excess beyond the forced supply ===")
print(f"  steps: {len(excess_list)}")
print(f"  non-singleton nontrivial compatibles per step: "
      f"min {min(excess_list)}, median {statistics.median(excess_list)}, "
      f"max {max(excess_list)}")
print(f"  steps with ZERO excess: {zero_excess} "
      f"({zero_excess / len(excess_list):.1%})")

print("\n=== D3: phantom change stratified by |S| ===")
print(f"  {'|S|':>4} {'n_comp':>7} {'mean_comp':>10} "
      f"{'n_incomp':>9} {'mean_incomp':>12}")
for size in sorted(strat):
    c = strat[size][True]
    i = strat[size][False]
    mc = sum(c) / len(c) if c else float('nan')
    mi = sum(i) / len(i) if i else float('nan')
    print(f"  {size:>4} {len(c):>7} {mc:>10.3f} {len(i):>9} {mi:>12.3f}")
