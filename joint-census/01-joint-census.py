# Joint aperture/co-aperture census. Registered spec: SPEC.md in this
# folder (committed before this file existed).
#
# For every poset (n = 2..5 exhaustive, n = 6 sampled) and every
# kernel K in D(P): class, aperture (kernel-checked characterization
# aperture_eq_card_ordinary_traces), co-aperture (verified E6
# identity: phantomMass(j_S, K) = number of relative down-sets on
# j_S K \ K; cross-checked against the direct |Icc(K, j_S K)| count
# on all n <= 4 posets).
#
# Poset core copied verbatim from perturbation-study/01-edge-oracle.py.
#
# Usage: python 01-joint-census.py

import itertools
import json
import os
import random

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "out")
SEED = 20260916
SAMPLE_SPECS = [(6, 100)]            # (n, number of random posets)
EDGE_PROBS = [0.2, 0.35, 0.5]

# ---------------- poset core (verbatim) ----------------

def close_upper(n, strict_edges):
    down = [1 << x for x in range(n)]
    for j in range(n):
        for i in range(j):
            if (i, j) in strict_edges:
                down[j] |= down[i]
    changed = True
    while changed:
        changed = False
        for x in range(n):
            m = down[x]
            acc = m
            mm = m
            while mm:
                b = mm & -mm
                acc |= down[b.bit_length() - 1]
                mm ^= b
            if acc != m:
                down[x] = acc
                changed = True
    return tuple(down)

def is_downset(n, down, m):
    mm = m
    while mm:
        b = mm & -mm
        if down[b.bit_length() - 1] & ~m:
            return False
        mm ^= b
    return True

def all_downsets(n, down):
    return [m for m in range(1 << n) if is_downset(n, down, m)]

def neg_in(down, S, T):
    r = 0
    mm = S
    while mm:
        b = mm & -mm
        x = b.bit_length() - 1
        if down[x] & S & T == 0:
            r |= b
        mm ^= b
    return r

def classify(down, S, T):
    r = neg_in(down, S, T)
    if r == 0:
        return "dense"
    return "regular" if neg_in(down, S, r) == T else "ordinary"

def aperture(n, down, K):
    ap = 0
    for S in range(1 << n):
        if classify(down, S, K & S) == "ordinary":
            ap += 1
    return ap

def rel_downset_count(down, F):
    cnt = 0
    X = F
    while True:
        ok = True
        mm = X
        while mm:
            b = mm & -mm
            if down[b.bit_length() - 1] & F & ~X:
                ok = False
                break
            mm ^= b
        if ok:
            cnt += 1
        if X == 0:
            return cnt
        X = (X - 1) & F

def nucleus_apply(n, down, S, K):
    jk = 0
    for x in range(n):
        if down[x] & S & ~K == 0:
            jk |= 1 << x
    return jk

def coaperture(n, down, K):
    co = 0
    for S in range(1 << n):
        co += rel_downset_count(down, nucleus_apply(n, down, S, K) & ~K)
    return co

def coaperture_direct(n, down, K, downsets):
    """Direct |Icc(K, j_S K)| in D(P), for the E6 cross-check."""
    co = 0
    for S in range(1 << n):
        jk = nucleus_apply(n, down, S, K)
        co += sum(1 for D in downsets if D & ~jk == 0 and K & ~D == 0)
    return co

def all_posets_upto(nmax):
    out = []
    for n in range(2, nmax + 1):
        pairs = [(i, j) for j in range(n) for i in range(j)]
        seen = set()
        for bits in range(1 << len(pairs)):
            edges = {pairs[t] for t in range(len(pairs)) if (bits >> t) & 1}
            down = close_upper(n, edges)
            if down not in seen:
                seen.add(down)
                out.append((n, down))
    return out

def sampled_posets(rng):
    out = []
    for n, count in SAMPLE_SPECS:
        seen = set()
        while len(seen) < count:
            p = rng.choice(EDGE_PROBS)
            edges = {(i, j) for j in range(n) for i in range(j)
                     if rng.random() < p}
            down = close_upper(n, edges)
            if down not in seen:
                seen.add(down)
                out.append((n, down))
    return out

# ---------------- statistics helpers ----------------

def ranks_with_ties(vals):
    order = sorted(range(len(vals)), key=lambda i: vals[i])
    r = [0.0] * len(vals)
    i = 0
    while i < len(order):
        j = i
        while j + 1 < len(order) and vals[order[j + 1]] == vals[order[i]]:
            j += 1
        avg = (i + j) / 2 + 1
        for t in range(i, j + 1):
            r[order[t]] = avg
        i = j + 1
    return r

def spearman(xs, ys):
    if len(xs) < 3:
        return None
    rx, ry = ranks_with_ties(xs), ranks_with_ties(ys)
    mx = sum(rx) / len(rx)
    my = sum(ry) / len(ry)
    num = sum((a - mx) * (b - my) for a, b in zip(rx, ry))
    dx = sum((a - mx) ** 2 for a in rx) ** 0.5
    dy = sum((b - my) ** 2 for b in ry) ** 0.5
    if dx == 0 or dy == 0:
        return None
    return num / (dx * dy)

# ---------------- J0: validation gate ----------------

def j0():
    print("=== J0: validation gate ===")
    # E4 witnesses. chain3 | chain1: 0<1<2, 3.
    n = 4
    down = close_upper(n, {(0, 1), (1, 2)})
    for K, ap_e, co_e, name in ((0b0001, 3, 42, "Div24 kernel (1,0)"),
                                (0b0011, 3, 36, "Div24 kernel (2,0)")):
        ap, co = aperture(n, down, K), coaperture(n, down, K)
        assert (ap, co) == (ap_e, co_e), f"{name}: {(ap, co)} != {(ap_e, co_e)}"
        print(f"  {name}: aperture {ap}, coaperture {co}  OK")
    # chain3 | chain2: 0<1<2, 3<4.
    n = 5
    down = close_upper(n, {(0, 1), (1, 2), (3, 4)})
    for K, ap_e, co_e, name in ((0b00011, 9, 84, "Div72 kernel (2,0)"),
                                (0b01001, 6, 84, "Div72 kernel (1,1)")):
        ap, co = aperture(n, down, K), coaperture(n, down, K)
        assert (ap, co) == (ap_e, co_e), f"{name}: {(ap, co)} != {(ap_e, co_e)}"
        print(f"  {name}: aperture {ap}, coaperture {co}  OK")
    # H3 motif recorded values.
    n = 3
    down = close_upper(n, {(0, 1)})
    full = (1 << n) - 1
    expect = {0: ("ordinary", 1, 18), 1: ("regular", 0, 12),
              2: ("regular", 0, 14)}
    for p, e in expect.items():
        K = down[p]
        got = (classify(down, full, K), aperture(n, down, K),
               coaperture(n, down, K))
        assert got == e, f"H3 p={p}: {got} != {e}"
        print(f"  H3 cone {p}: {got}  OK")
    print("J0 PASS\n")

def e6_crosscheck(posets):
    print("=== E6 cross-check (n <= 4, direct Icc vs relative down-sets) ===")
    checked = 0
    for n, down in posets:
        if n > 4:
            continue
        ds = all_downsets(n, down)
        for K in ds:
            assert coaperture(n, down, K) == coaperture_direct(n, down, K, ds)
            checked += 1
    print(f"  {checked} kernels, zero mismatches\n")

# ---------------- census ----------------

def census(posets, tag):
    print(f"=== census [{tag}] ===")
    rows = []          # per-kernel records
    per_poset = []     # per-poset J1/J4 summaries
    for n, down in posets:
        full = (1 << n) - 1
        ds = all_downsets(n, down)
        principal = set(down)
        recs = []
        for K in ds:
            cls = classify(down, full, K)
            ap = aperture(n, down, K)
            co = coaperture(n, down, K)
            recs.append(dict(n=n, K=K, size=bin(K).count("1"),
                             principal=K in principal, cls=cls,
                             ap=ap, co=co))
        rows.extend(recs)
        # J1 fibers among ap > 0 kernels
        pos = [r for r in recs if r["ap"] > 0]
        ap_fibers = {}
        co_fibers = {}
        for r in pos:
            ap_fibers.setdefault(r["ap"], set()).add(r["co"])
            co_fibers.setdefault(r["co"], set()).add(r["ap"])
        dir_a = any(len(v) >= 2 for v in ap_fibers.values())
        dir_b = any(len(v) >= 2 for v in co_fibers.values())
        # within-poset Spearman (>= 3 distinct values each coordinate)
        aps = [r["ap"] for r in recs]
        cos = [r["co"] for r in recs]
        rho_w = spearman(aps, cos) if (len(set(aps)) >= 3 and
                                       len(set(cos)) >= 3) else None
        # J4 extremal kernels
        max_ap = max(aps)
        argmax = [r for r in recs if r["ap"] == max_ap]
        min_co_pos = min((r["co"] for r in pos), default=None)
        argmin = [r for r in pos if r["co"] == min_co_pos] if pos else []
        per_poset.append(dict(
            n=n, downsets=len(ds), dir_a=dir_a, dir_b=dir_b,
            both=dir_a and dir_b, rho_w=rho_w, max_ap=max_ap,
            argmax_principal=sum(r["principal"] for r in argmax),
            argmax_count=len(argmax),
            argmax_sizes=[r["size"] for r in argmax],
            argmin_principal=sum(r["principal"] for r in argmin),
            argmin_count=len(argmin)))
    print(f"  posets {len(posets)}, kernels {len(rows)}")
    return rows, per_poset

# ---------------- verdicts ----------------

def report(rows, per_poset):
    print("=== results ===")
    out = {}

    # forced-anchor sanity (F1-F4 restated, not findings)
    bot_top_ap = [r["ap"] for r in rows if r["K"] == 0 or
                  r["size"] == r["n"]]
    print(f"  F1 sanity: max aperture at bottom/top kernels = "
          f"{max(bot_top_ap)} (must be 0)")
    assert max(bot_top_ap) == 0
    ord_ap0 = sum(1 for r in rows if r["cls"] == "ordinary" and r["ap"] == 0)
    print(f"  F4 sanity: ordinary kernels with aperture 0 = {ord_ap0} "
          f"(must be 0)")
    assert ord_ap0 == 0

    # J1
    print("  --- J1: fibers in the wild (among ap > 0 kernels) ---")
    out["J1"] = {}
    for n in sorted({p["n"] for p in per_poset}):
        ps = [p for p in per_poset if p["n"] == n]
        both = sum(p["both"] for p in ps)
        a = sum(p["dir_a"] for p in ps)
        b = sum(p["dir_b"] for p in ps)
        out["J1"][n] = dict(posets=len(ps), dir_a=a, dir_b=b, both=both)
        print(f"    n={n}: {len(ps)} posets | same-ap-diff-co in {a}, "
              f"same-co-diff-ap in {b}, both in {both} "
              f"({both/len(ps):.1%})")

    # J2
    print("  --- J2: bulk redundancy (Spearman) ---")
    out["J2"] = {}
    for n in sorted({r["n"] for r in rows}):
        rs = [r for r in rows if r["n"] == n]
        rho = spearman([r["ap"] for r in rs], [r["co"] for r in rs])
        out["J2"][n] = rho
        rho_s = f"{rho:+.3f}" if rho is not None else "undefined (constant coordinate)"
        print(f"    n={n}: rho = {rho_s}  ({len(rs)} kernels)")
    within = [p["rho_w"] for p in per_poset if p["rho_w"] is not None]
    if within:
        within_sorted = sorted(within)
        med = within_sorted[len(within) // 2]
        out["J2"]["within_poset"] = dict(
            count=len(within), median=med,
            min=min(within), max=max(within),
            frac_abs_ge_95=sum(1 for r in within if abs(r) >= 0.95)
            / len(within))
        print(f"    within-poset: {len(within)} posets, median "
              f"{med:+.3f}, range [{min(within):+.3f}, {max(within):+.3f}], "
              f"|rho|>=0.95 in {out['J2']['within_poset']['frac_abs_ge_95']:.1%}")

    # J3
    print("  --- J3: class x coordinates ---")
    out["J3"] = {}
    for cls in ("dense", "regular", "ordinary"):
        rs = [r for r in rows if r["cls"] == cls]
        pos = sum(1 for r in rs if r["ap"] > 0)
        mean_ap = sum(r["ap"] for r in rs) / len(rs)
        mean_co = sum(r["co"] for r in rs) / len(rs)
        out["J3"][cls] = dict(kernels=len(rs), ap_pos=pos,
                              frac_ap_pos=pos / len(rs),
                              mean_ap=mean_ap, mean_co=mean_co)
        print(f"    {cls}: {len(rs)} kernels, aperture>0 in {pos} "
              f"({pos/len(rs):.1%}), mean ap {mean_ap:.2f}, "
              f"mean co {mean_co:.1f}")

    # J4
    print("  --- J4: extremal profiles (descriptive) ---")
    tot_max = sum(p["argmax_count"] for p in per_poset)
    tot_max_pr = sum(p["argmax_principal"] for p in per_poset)
    tot_min = sum(p["argmin_count"] for p in per_poset)
    tot_min_pr = sum(p["argmin_principal"] for p in per_poset)
    all_pr = sum(1 for r in rows if r["principal"])
    out["J4"] = dict(
        argmax_kernels=tot_max, argmax_principal=tot_max_pr,
        argmin_co_kernels=tot_min, argmin_co_principal=tot_min_pr,
        principal_base_rate=all_pr / len(rows))
    print(f"    max-aperture kernels: {tot_max}, principal "
          f"{tot_max_pr} ({tot_max_pr/tot_max:.1%}); base rate of "
          f"principality {all_pr/len(rows):.1%}")
    print(f"    min-co-aperture (ap>0) kernels: {tot_min}, principal "
          f"{tot_min_pr} ({tot_min_pr/tot_min:.1%})")

    # kills
    print("  --- kills ---")
    k1 = all(abs(v) >= 0.95 for k, v in out["J2"].items()
             if isinstance(v, float))
    out["K1"] = "FIRES" if k1 else "does not fire"
    n5 = out["J1"].get(5)
    k2 = n5 is not None and n5["both"] / n5["posets"] < 0.05
    out["K2"] = "FIRES" if k2 else "does not fire"
    print(f"    K1 (statistical redundancy): {out['K1']}")
    print(f"    K2 (witness exoticism): {out['K2']}")
    return out

# ---------------- main ----------------

if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    rng = random.Random(SEED)
    j0()
    exhaustive = all_posets_upto(5)
    print(f"exhaustive posets n<=5: {len(exhaustive)}\n")
    e6_crosscheck(exhaustive)
    rows_e, pp_e = census(exhaustive, "exhaustive")
    rows_s, pp_s = census(sampled_posets(rng), "sampled n=6")
    rows = rows_e + rows_s
    per_poset = pp_e + pp_s
    out = report(rows, per_poset)
    with open(os.path.join(OUT, "joint-census-results.json"), "w") as fh:
        json.dump(dict(verdicts=out, per_poset=per_poset), fh, indent=1,
                  default=str)
    print(f"\nresults written to {OUT}")
