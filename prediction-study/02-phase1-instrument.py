"""Phase 1: instrument validation (SPEC.md, frozen). No outcomes touched.

E-P1 (stability): Spearman(cap16, cap12) >= 0.7 on 200 population
packages, seed 20260913. Reported without threshold: cap16 vs cap20
on the first 50.
E-P2 (non-degeneracy): no single cap-16 value covers > 90%.
Kills: K1 = E-P1 fail, K2 = E-P2 fail.
"""

import json
import os
import time
from collections import Counter, defaultdict

import numpy as np

from aperture_lib import ego_aperture, aperture_bruteforce_check

SEED = 20260913
N_SAMPLE = 200


def spearman(a, b):
    def rank(v):
        v = np.asarray(v, dtype=float)
        order = np.argsort(v, kind="stable")
        ranks = np.empty(len(v))
        ranks[order] = np.arange(len(v), dtype=float)
        # average ties
        for val in np.unique(v):
            m = v == val
            ranks[m] = ranks[m].mean()
        return ranks
    ra, rb = rank(a), rank(b)
    ra -= ra.mean()
    rb -= rb.mean()
    d = np.sqrt((ra ** 2).sum() * (rb ** 2).sum())
    return float((ra * rb).sum() / d) if d > 0 else float("nan")


def main():
    assert aperture_bruteforce_check()
    print("motif sanity: engine matches kernel-checked values", flush=True)

    z = np.load("data/graph-t0.npz", allow_pickle=False)
    names_arr = z["names"]
    src, dst = z["edge_src"], z["edge_dst"]
    n = len(names_arr)
    names = {i: str(names_arr[i]) for i in range(n)}

    deps = defaultdict(list)   # p -> its dependencies
    rdeps = defaultdict(list)  # q -> its dependents
    for a, b in zip(src.tolist(), dst.tolist()):
        deps[a].append(b)
        rdeps[b].append(a)
    dependents_count = np.zeros(n, dtype=np.int64)
    np.add.at(dependents_count, dst, 1)
    indeg = {i: int(dependents_count[i]) for i in range(n)}

    population = np.flatnonzero(dependents_count >= 1)
    print(f"population (>=1 dependent at T0): {len(population)}", flush=True)

    rng = np.random.default_rng(SEED)
    sample = rng.choice(population, size=N_SAMPLE, replace=False)

    rows = []
    t0 = time.time()
    for k, p in enumerate(sample.tolist()):
        a16 = ego_aperture(p, deps, rdeps, indeg, names, 16)
        a12 = ego_aperture(p, deps, rdeps, indeg, names, 12)
        a20 = ego_aperture(p, deps, rdeps, indeg, names, 20) if k < 50 else None
        rows.append({"crate": names[p], "cap16": a16, "cap12": a12,
                     "cap20": a20})
        if (k + 1) % 25 == 0:
            print(f"  {k + 1}/{N_SAMPLE}  ({time.time() - t0:.1f}s)",
                  flush=True)

    c16 = [r["cap16"] for r in rows]
    c12 = [r["cap12"] for r in rows]
    rho_16_12 = spearman(c16, c12)
    sub = [(r["cap16"], r["cap20"]) for r in rows if r["cap20"] is not None]
    rho_16_20 = spearman([a for a, _ in sub], [b for _, b in sub])

    counts = Counter(c16)
    top_val, top_n = counts.most_common(1)[0]
    top_share = top_n / len(c16)

    ep1 = rho_16_12 >= 0.7
    ep2 = top_share <= 0.9

    print(f"\nE-P1 stability: Spearman(cap16, cap12) = {rho_16_12:.3f} "
          f"(threshold 0.7) -> {'PASS' if ep1 else 'FAIL (K1)'}")
    print(f"  reported: Spearman(cap16, cap20) = {rho_16_20:.3f} on n=50")
    print(f"E-P2 degeneracy: top value {top_val} covers {top_share:.1%} "
          f"(threshold 90%) -> {'PASS' if ep2 else 'FAIL (K2)'}")
    print(f"  cap16 distribution: zeros {counts[0]}/{len(c16)}, "
          f"distinct values {len(counts)}, max {max(c16)}, "
          f"median {sorted(c16)[len(c16)//2]}")

    os.makedirs("out", exist_ok=True)
    with open("out/phase1.json", "w") as f:
        json.dump({"seed": SEED, "population": int(len(population)),
                   "rho_16_12": rho_16_12, "rho_16_20": rho_16_20,
                   "top_value": int(top_val), "top_share": top_share,
                   "E_P1_pass": bool(ep1), "E_P2_pass": bool(ep2),
                   "rows": rows}, f, indent=1)
    print("wrote out/phase1.json")


if __name__ == "__main__":
    main()
