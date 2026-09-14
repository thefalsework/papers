# Perturbation-study oracle. Registered spec: SPEC.md in this folder
# (committed before this file existed; E0 amendment also pre-code).
#
# One step of dynamics: for finite posets, add a single relation
# (a < b) between incomparable elements, take the transitive closure,
# and measure what happens to each principal cone's class
# (ordinary / regular / dense), aperture, and cone co-aperture.
#
# Aperture via the kernel-checked characterization
# (aperture_eq_card_ordinary_traces): aperture(dn p) =
# #{ S subset of P : trace of dn p on S is ordinary in D(S) }.
# Phantom mass via the verified E6 identity: phantomMass(j_S, k) =
# number of relative down-sets on j_S(k) \ k.
#
# Usage: python 01-edge-oracle.py

import itertools
import json
import os
import random

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "out")
SEED = 20260914
SAMPLE_SPECS = [(6, 120), (7, 60)]   # (n, number of random posets)
EDGE_PROBS = [0.2, 0.35, 0.5]
MAX_EDGES_SAMPLED = 8                # incomparable pairs tried per sampled poset

# ---------------- poset core (bitmask down-sets) ----------------

def close_upper(n, strict_edges):
    """strict_edges: set of (i, j), i < j as labels, meaning i < j in P.
    Returns down[x] = bitmask of {y : y <= x} (transitively closed)."""
    down = [1 << x for x in range(n)]
    for j in range(n):
        for i in range(j):
            if (i, j) in strict_edges:
                down[j] |= down[i]
    # iterate to closure (edges are topologically ordered, one pass works,
    # but iterate to be safe)
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
    """Add relation a < b to a transitively closed poset; return closed
    down'. leq'(y,x) iff leq(y,x) or (y <= a and b <= x)."""
    da = down[a]
    return tuple(down[x] | da if (down[x] >> b) & 1 else down[x]
                 for x in range(n))

def incomparable_pairs(n, down):
    out = []
    for a in range(n):
        for b in range(n):
            if a != b and not (down[b] >> a) & 1 and not (down[a] >> b) & 1:
                out.append((a, b))
    return out

def count_downsets(n, down):
    c = 0
    for m in range(1 << n):
        ok = True
        mm = m
        while mm:
            b = mm & -mm
            if down[b.bit_length() - 1] & ~m:
                ok = False
                break
            mm ^= b
        if ok:
            c += 1
    return c

def is_downset(n, down, m):
    mm = m
    while mm:
        b = mm & -mm
        if down[b.bit_length() - 1] & ~m:
            return False
        mm ^= b
    return True

# ---------------- invariants ----------------

def neg_in(down, S, T):
    """Heyting negation of down-set T inside D(S) (S, T bitmasks)."""
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
    """Class of T in D(S): returns 'dense' / 'regular' / 'ordinary'."""
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
    """Number of down-sets of the induced subposet on mask F."""
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
    """j_S(K) = {x : dn x cap S subset of K}."""
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

def heyting_imp(n, down, full, U, V):
    m = 0
    for x in range(n):
        if down[x] & U & ~V & full == 0:
            m |= 1 << x
    return m

# ---------------- E0: engine validation ----------------

def e0():
    print("=== E0: engine validation against recorded bridge-study values ===")
    # H3 motif: P = {p=0 < b=1, q=2 isolated}
    n = 3
    down = close_upper(n, {(0, 1)})
    K = {name: down[i] for name, i in (("p", 0), ("b", 1), ("q", 2))}
    expect = {"p": ("ordinary", 1, 18), "b": ("regular", 0, 12),
              "q": ("regular", 0, 14)}
    full = (1 << n) - 1
    for name, k in K.items():
        cls = classify(down, full, k)
        ap = aperture(n, down, k)
        co = coaperture(n, down, k)
        e = expect[name]
        assert (cls, ap, co) == e, f"H3 {name}: got {(cls, ap, co)} != {e}"
        print(f"  H3 {name}: {cls}, aperture {ap}, coaperture {co}  OK")
    print("E0 PASS\n")

# ---------------- L0-L3 registered witnesses ----------------

def hand_lemmas():
    print("=== L0-L3: registered hand witnesses ===")
    results = {}

    # L0: edge addition is not a nucleus. P = antichain {a=0, b=1},
    # add 0 < 1. U = {0}, V = empty: U => V = {1}, not in D(P').
    n = 2
    down = close_upper(n, set())
    full = (1 << n) - 1
    U, V = 0b01, 0b00
    imp = heyting_imp(n, down, full, U, V)
    assert imp == 0b10, f"L0: U=>V = {imp:b} != 10"
    down2 = add_edge(n, down, 0, 1)
    in_dp2 = is_downset(n, down2, imp)
    assert not in_dp2, "L0 witness FAILED: {b} is a down-set of P'"
    print("  L0: on 2-antichain + (a<b), U=>V = {b} is not in D(P')  OK")
    results["L0"] = True

    # L1 is checked at scale in the survey (zero tolerance there).

    # L2: 3-antichain + (p<b) = H3 motif; dn p flips regular -> ordinary.
    n = 3
    down = close_upper(n, set())
    full = (1 << n) - 1
    before = classify(down, full, down[0])
    down2 = add_edge(n, down, 0, 1)
    after = classify(down2, full, down2[0])
    assert (before, after) == ("regular", "ordinary"), (before, after)
    print(f"  L2: 3-antichain + (p<b): dn p {before} -> {after}  OK")
    results["L2"] = (before, after)

    # L3: H3 motif + (q<p) = 3-chain; no ordinary cones remain.
    n = 3
    down = close_upper(n, {(0, 1)})
    full = (1 << n) - 1
    assert classify(down, full, down[0]) == "ordinary"
    down2 = add_edge(n, down, 2, 0)
    classes = [classify(down2, full, down2[x]) for x in range(n)]
    assert "ordinary" not in classes, classes
    print(f"  L3: H3 + (q<p) -> 3-chain, classes {classes}, no ordinary  OK")
    results["L3"] = classes
    print("hand lemmas PASS\n")
    return results

# ---------------- poset generation ----------------

def all_posets_upto(nmax):
    """All posets on n = 2..nmax up to iso (via upper-triangular edge
    subsets + dedupe on the closed down-tuple; iso duplicates remain
    but exact duplicates are removed — harmless for a survey)."""
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

# ---------------- survey ----------------

def survey(posets, rng, with_coap, tag):
    print(f"=== survey [{tag}] (coaperture={'on' if with_coap else 'off'}) ===")
    stats = dict(
        triples=0, edges=0,
        l1_violations=0,
        dap_pos=0, dap_neg=0, dap_zero=0,
        dco_pos=0, dco_neg=0, dco_zero=0,
        ratchet_violations=[],
        class_changes={},              # (before, after) -> count
        q2=dict(a=dict(total=0, changed=0),
                b=dict(total=0, changed=0),
                c=dict(total=0, changed=0)),
        q2_c_witnesses=[],
        max_rel_jump=0.0, max_jump_witness=None,
        collapse_witnesses=[],         # ordinary & max-aperture -> 0
        imp_closed=0, imp_total=0,     # K2: fraction of edge-adds that are
                                       # nuclei-like (D(P') closed under =>)
    )
    for n, down in posets:
        full = (1 << n) - 1
        pairs = incomparable_pairs(n, down)
        if tag == "sampled" and len(pairs) > MAX_EDGES_SAMPLED:
            pairs = rng.sample(pairs, MAX_EDGES_SAMPLED)
        pre = {}
        for p in range(n):
            K = down[p]
            pre[p] = (classify(down, full, K), aperture(n, down, K),
                      coaperture(n, down, K) if with_coap else None)
        nds_before = count_downsets(n, down)
        for (a, b) in pairs:
            stats["edges"] += 1
            down2 = add_edge(n, down, a, b)
            # L1
            if count_downsets(n, down2) >= nds_before:
                stats["l1_violations"] += 1
            # K2 input: is D(P') closed under => of D(P)? test on all
            # pairs of down-sets of P' (n <= 5 only; expensive otherwise)
            if n <= 4:
                ds2 = [m for m in range(1 << n) if is_downset(n, down2, m)]
                closed = all(
                    is_downset(n, down2, heyting_imp(n, down, full, U, V))
                    for U in ds2 for V in ds2)
                stats["imp_total"] += 1
                stats["imp_closed"] += closed
            for p in range(n):
                stats["triples"] += 1
                cls0, ap0, co0 = pre[p]
                K2 = down2[p]
                cls1 = classify(down2, full, K2)
                ap1 = aperture(n, down2, K2)
                dap = ap1 - ap0
                if dap > 0: stats["dap_pos"] += 1
                elif dap < 0: stats["dap_neg"] += 1
                else: stats["dap_zero"] += 1
                if with_coap:
                    co1 = coaperture(n, down2, K2)
                    dco = co1 - co0
                    if dco > 0: stats["dco_pos"] += 1
                    elif dco < 0: stats["dco_neg"] += 1
                    else: stats["dco_zero"] += 1
                # Q4 ratchet
                if cls0 == "dense" and cls1 != "dense":
                    stats["ratchet_violations"].append(
                        dict(n=n, down=list(down), edge=[a, b], p=p,
                             before=cls0, after=cls1))
                key = f"{cls0}->{cls1}"
                stats["class_changes"][key] = \
                    stats["class_changes"].get(key, 0) + 1
                # Q2 locality type
                cmp_a = bool((down[p] >> a) & 1 or (down[a] >> p) & 1)
                cmp_b = bool((down[p] >> b) & 1 or (down[b] >> p) & 1)
                typ = "a" if (cmp_a and cmp_b) else \
                      ("b" if (cmp_a or cmp_b) else "c")
                stats["q2"][typ]["total"] += 1
                if cls0 != cls1:
                    stats["q2"][typ]["changed"] += 1
                    if typ == "c" and len(stats["q2_c_witnesses"]) < 5:
                        stats["q2_c_witnesses"].append(
                            dict(n=n, down=list(down), edge=[a, b], p=p,
                                 before=cls0, after=cls1))
                # Q3 jump
                rel = abs(dap) / (1 << n)
                if rel > stats["max_rel_jump"]:
                    stats["max_rel_jump"] = rel
                    stats["max_jump_witness"] = dict(
                        n=n, down=list(down), edge=[a, b], p=p,
                        ap_before=ap0, ap_after=ap1)
                if cls0 == "ordinary" and ap1 == 0 and ap0 > 0 and \
                        len(stats["collapse_witnesses"]) < 5:
                    stats["collapse_witnesses"].append(
                        dict(n=n, down=list(down), edge=[a, b], p=p,
                             ap_before=ap0, ap_after=ap1,
                             before=cls0, after=cls1))
    print(f"  posets {len(posets)}, edge-additions {stats['edges']}, "
          f"triples {stats['triples']}")
    print(f"  L1 violations (down-set count non-decreasing): "
          f"{stats['l1_violations']}")
    print(f"  Q1 signs  d-aperture:  +{stats['dap_pos']} "
          f"-{stats['dap_neg']} 0:{stats['dap_zero']}")
    if with_coap:
        print(f"  Q1 signs  d-coaperture: +{stats['dco_pos']} "
              f"-{stats['dco_neg']} 0:{stats['dco_zero']}")
    print(f"  Q2 class-change rates by edge type: " + ", ".join(
        f"{t}: {v['changed']}/{v['total']}" for t, v in stats["q2"].items()))
    print(f"  Q3 max relative aperture jump: {stats['max_rel_jump']:.3f} "
          f"witness {stats['max_jump_witness']}")
    print(f"  Q4 ratchet violations: {len(stats['ratchet_violations'])}")
    if stats["imp_total"]:
        print(f"  K2 input: D(P') closed under => in "
              f"{stats['imp_closed']}/{stats['imp_total']} edge-additions")
    print(f"  class transitions: {stats['class_changes']}")
    print()
    return stats

# ---------------- verdicts ----------------

def verdicts(ex, sm):
    print("=== verdicts ===")
    v = {}
    v["K0"] = "pass (E0 matched recorded values)"
    ratchet = len(ex["ratchet_violations"]) + len(sm["ratchet_violations"])
    v["K1_ratchet"] = "FIRES" if ratchet else \
        "does not fire (L4 holds on the full survey)"
    frac_closed = (ex["imp_closed"] / ex["imp_total"]) if ex["imp_total"] else 0
    v["K2_reduction"] = "FIRES" if frac_closed >= 0.99 else \
        f"does not fire (D(P') closed under => in {frac_closed:.1%} of cases)"
    both_signs = ex["dap_pos"] > 0 and ex["dap_neg"] > 0
    v["K3_monotone"] = "does not fire (both signs occur)" if both_signs \
        else "FIRES (aperture single-signed!)"
    v["Q1"] = dict(dap=(ex["dap_pos"] + sm["dap_pos"],
                        ex["dap_neg"] + sm["dap_neg"],
                        ex["dap_zero"] + sm["dap_zero"]),
                   dco=(ex["dco_pos"], ex["dco_neg"], ex["dco_zero"]))
    c_changes = ex["q2"]["c"]["changed"] + sm["q2"]["c"]["changed"]
    v["Q2"] = ("NON-LOCAL: distant edges (type c) change class "
               f"{c_changes} times") if c_changes else \
        "LOCAL: no type-c edge ever changed a class (invariance candidate)"
    v["Q3"] = dict(max_rel_jump=max(ex["max_rel_jump"], sm["max_rel_jump"]),
                   collapse_witnesses=len(ex["collapse_witnesses"]) +
                   len(sm["collapse_witnesses"]))
    l1 = ex["l1_violations"] + sm["l1_violations"]
    v["L1"] = "holds (strict decrease everywhere)" if l1 == 0 else \
        f"VIOLATED {l1} times"
    for k, val in v.items():
        print(f"  {k}: {val}")
    return v

# ---------------- main ----------------

if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    rng = random.Random(SEED)
    e0()
    hand = hand_lemmas()
    exhaustive = all_posets_upto(5)
    print(f"exhaustive posets n<=5: {len(exhaustive)}")
    ex = survey(exhaustive, rng, with_coap=True, tag="exhaustive")
    sm = survey(sampled_posets(rng), rng, with_coap=False, tag="sampled")
    v = verdicts(ex, sm)
    with open(os.path.join(OUT, "perturbation-results.json"), "w") as fh:
        json.dump(dict(hand=hand, exhaustive=ex, sampled=sm, verdicts=v),
                  fh, indent=1, default=str)
    print(f"\nresults written to {OUT}")
