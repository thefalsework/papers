# Pocket-study oracle. Registered spec: SPEC.md in this folder,
# committed before this file existed.
#
# For each poset, each single-edge step (a, b), each observer support
# S: test dynamical compatibility
#
#     for all U in D(P):  cl'( j_S(U) ) == j'_S( cl'(U) )
#
# where cl' is down-closure in the extended order (on a single added
# edge: cl'(U) = U | downset(a) if U meets upset(b), else U).
#
# Poset core copied verbatim from perturbation-study/01-edge-oracle.py
# (E0 here re-validates against this study's registered hand lemmas).
#
# Usage: python 01-commutation-oracle.py

import json
import os
import random

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "out")
SEED = 20260915
SAMPLE_N6 = 100
EDGE_PROBS = [0.2, 0.35, 0.5]

# ---------------- poset core (perturbation-study, verbatim) ----------------

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

def add_edge(n, down, a, b):
    da = down[a]
    return tuple(down[x] | da if (down[x] >> b) & 1 else down[x]
                 for x in range(n))

def incomparable_pairs(n, down):
    return [(a, b) for a in range(n) for b in range(n)
            if a != b and not (down[b] >> a) & 1 and not (down[a] >> b) & 1]

def downsets(n, down):
    out = []
    for m in range(1 << n):
        ok = True
        mm = m
        while mm:
            bb = mm & -mm
            if down[bb.bit_length() - 1] & ~m:
                ok = False
                break
            mm ^= bb
        if ok:
            out.append(m)
    return out

def nucleus_apply(n, down, S, U):
    jk = 0
    for x in range(n):
        if down[x] & S & ~U == 0:
            jk |= 1 << x
    return jk

def neg_in(down, S, T):
    r = 0
    mm = S
    while mm:
        bb = mm & -mm
        x = bb.bit_length() - 1
        if down[x] & S & T == 0:
            r |= bb
        mm ^= bb
    return r

def trace_ordinary(down, S, K):
    T = K & S
    r = neg_in(down, S, T)
    if r == 0:
        return False
    return neg_in(down, S, r) != T

def rel_downset_count(down, F):
    cnt = 0
    X = F
    while True:
        ok = True
        mm = X
        while mm:
            bb = mm & -mm
            if down[bb.bit_length() - 1] & F & ~X:
                ok = False
                break
            mm ^= bb
        if ok:
            cnt += 1
        if X == 0:
            return cnt
        X = (X - 1) & F

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

# ---------------- the step map cl' ----------------

def make_clp(n, down, a, b):
    upb = sum(1 << x for x in range(n) if (down[x] >> b) & 1)
    da = down[a]
    def clp(U):
        return U | da if U & upb else U
    return clp

def compatible(n, down, down2, clp, ds, S):
    for U in ds:
        if clp(nucleus_apply(n, down, S, U)) != \
                nucleus_apply(n, down2, S, clp(U)):
            return False
    return True

# ---------------- E0: registered hand lemmas ----------------

def e0():
    print("=== E0: hand lemmas on the 2-antichain step ===")
    n = 2
    down = close_upper(n, set())
    down2 = add_edge(n, down, 0, 1)          # step a=0 < b=1
    clp = make_clp(n, down, 0, 1)
    ds = downsets(n, down)
    comp = {S for S in range(1 << n)
            if compatible(n, down, down2, clp, ds, S)}
    # P0 endpoints; P1 future-watcher S={b}={bit1}; P2 past-watcher fails
    expect = {0b00, 0b10, 0b11}
    assert comp == expect, f"compatible set {comp} != {expect}"
    print(f"  compatible supports = {sorted(comp)} "
          f"(endpoints + future-watcher; past-watcher excluded)  OK")
    print("E0 PASS\n")

# ---------------- survey ----------------

def survey(posets, tag):
    print(f"=== survey [{tag}] ===")
    st = dict(steps=0, endpoints_ok=0,
              middle_nonempty=0, nontrivial_total=0,
              lattice_ok=0, lattice_fail=0, lattice_fail_witness=None,
              q3_comp=[], q3_incomp=[],
              q4_pockets=0, q4_step_kernels=0, q4_witness=None)
    for n, down in posets:
        full = (1 << n) - 1
        ds = downsets(n, down)
        for (a, b) in incomparable_pairs(n, down):
            st["steps"] += 1
            down2 = add_edge(n, down, a, b)
            clp = make_clp(n, down, a, b)
            comp = [S for S in range(1 << n)
                    if compatible(n, down, down2, clp, ds, S)]
            cset = set(comp)
            if 0 in cset and full in cset:
                st["endpoints_ok"] += 1
            nontriv = [S for S in comp if S not in (0, full)]
            if nontriv:
                st["middle_nonempty"] += 1
                st["nontrivial_total"] += len(nontriv)
            # Q2 lattice closure
            ok = all(((S | T) in cset and (S & T) in cset)
                     for S in comp for T in comp)
            if ok:
                st["lattice_ok"] += 1
            else:
                st["lattice_fail"] += 1
                if st["lattice_fail_witness"] is None:
                    bad = next(((S, T) for S in comp for T in comp
                                if (S | T) not in cset or (S & T) not in cset))
                    st["lattice_fail_witness"] = dict(
                        n=n, down=list(down), edge=[a, b],
                        S=bad[0], T=bad[1], compatible=sorted(comp))
            # Q3 phantom-change by compatibility (descriptive, n<=5 only)
            if n <= 5:
                for S in range(1 << n):
                    d = 0
                    for p in range(n):
                        k0, k1 = down[p], down2[p]
                        pm0 = rel_downset_count(
                            down, nucleus_apply(n, down, S, k0) & ~k0)
                        pm1 = rel_downset_count(
                            down2, nucleus_apply(n, down2, S, k1) & ~k1)
                        d += pm1 - pm0
                    (st["q3_comp"] if S in cset else st["q3_incomp"]).append(d)
            # Q4 dynamical pockets
            for p in range(n):
                st["q4_step_kernels"] += 1
                cnt = sum(1 for S in nontriv
                          if trace_ordinary(down, S, down[p])
                          and trace_ordinary(down2, S, down2[p]))
                if cnt:
                    st["q4_pockets"] += cnt
                    if st["q4_witness"] is None:
                        Sw = next(S for S in nontriv
                                  if trace_ordinary(down, S, down[p])
                                  and trace_ordinary(down2, S, down2[p]))
                        st["q4_witness"] = dict(
                            n=n, down=list(down), edge=[a, b], p=p, S=Sw)
    mean = lambda v: sum(v) / len(v) if v else 0.0
    print(f"  steps {st['steps']}, endpoints commute in "
          f"{st['endpoints_ok']}/{st['steps']}")
    print(f"  Q1 middle non-empty: {st['middle_nonempty']}/{st['steps']} "
          f"({st['middle_nonempty']/st['steps']:.1%}), "
          f"nontrivial compatible total {st['nontrivial_total']}")
    print(f"  Q2 lattice closure: ok {st['lattice_ok']}, "
          f"FAIL {st['lattice_fail']}"
          + (f", witness {st['lattice_fail_witness']}"
             if st["lattice_fail_witness"] else ""))
    if st["q3_comp"] or st["q3_incomp"]:
        print(f"  Q3 mean total phantom change: compatible "
              f"{mean(st['q3_comp']):+.3f} (n={len(st['q3_comp'])}), "
              f"incompatible {mean(st['q3_incomp']):+.3f} "
              f"(n={len(st['q3_incomp'])})")
    print(f"  Q4 dynamical pockets: {st['q4_pockets']} over "
          f"{st['q4_step_kernels']} (step, kernel) pairs"
          + (f", first witness {st['q4_witness']}"
             if st["q4_witness"] else ""))
    print()
    return st

# ---------------- main ----------------

if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    rng = random.Random(SEED)
    e0()
    ex = survey(all_posets_upto(5), "exhaustive n<=5")
    sample = []
    seen = set()
    while len(seen) < SAMPLE_N6:
        p = rng.choice(EDGE_PROBS)
        edges = {(i, j) for j in range(6) for i in range(j)
                 if rng.random() < p}
        d = close_upper(6, edges)
        if d not in seen:
            seen.add(d)
            sample.append((6, d))
    sm = survey(sample, "sampled n=6")

    print("=== verdicts ===")
    v = {}
    v["K0"] = "pass (E0 matched hand lemmas)"
    frac = ex["middle_nonempty"] / ex["steps"]
    v["K2_vacuity"] = "FIRES" if frac < 0.01 else \
        f"does not fire (middle non-empty in {frac:.1%} of steps)"
    v["K1_lattice"] = "FIRES (set, not lattice)" \
        if ex["lattice_fail"] + sm["lattice_fail"] else \
        "does not fire (closure held on every step)"
    v["K3_pockets"] = "FIRES (no dynamical pockets)" \
        if ex["q4_pockets"] + sm["q4_pockets"] == 0 else \
        f"does not fire ({ex['q4_pockets'] + sm['q4_pockets']} found)"
    for k, val in v.items():
        print(f"  {k}: {val}")

    with open(os.path.join(OUT, "pocket-results.json"), "w") as fh:
        json.dump(dict(
            exhaustive={k: val for k, val in ex.items()
                        if not k.startswith("q3_")},
            q3=dict(comp_mean=(sum(ex["q3_comp"]) / len(ex["q3_comp"])
                               if ex["q3_comp"] else None),
                    incomp_mean=(sum(ex["q3_incomp"]) / len(ex["q3_incomp"])
                                 if ex["q3_incomp"] else None),
                    comp_n=len(ex["q3_comp"]),
                    incomp_n=len(ex["q3_incomp"])),
            sampled={k: val for k, val in sm.items()
                     if not k.startswith("q3_")},
            verdicts=v), fh, indent=1, default=str)
    print(f"\nresults written to {OUT}")
