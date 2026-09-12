# Phase 3: the depth test. Registered spec: SPEC.md, Phase 3
# (E0''-sanity, E7-E9, kills K7-K8).
#
# Computes aperture(cone p) via the Phase-2 characterization —
# count subsets S whose trace (down(p) & S) is ordinary in D(S),
# using the polynomial ordinariness predicate — and compares the
# ranking against standard centralities.
#
# Usage: python 03-depth-test.py

import itertools
import json
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
mod = __import__("01-downset-pilot")

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "out")
SEED = 20260912
RHO_KILL = 0.95

# ---------------- aperture via the subset formula ----------------

def down_masks(n, leq):
    return [sum(1 << i for i in range(n) if leq[i][x]) for x in range(n)]

def neg_in(S_bits, down, T):
    """Negation of down-set T inside the subposet on S (list of nodes)."""
    out = 0
    for x in S_bits:
        if down[x] & T == 0:          # down[x] & S already folded into T's frame
            out |= 1 << x
    return out

def trace_ordinary(S_mask, S_bits, down, T):
    """Is the down-set T (mask, subset of S_mask) ordinary in D(S)?
    Dense: negation empty. Regular: double negation returns T.
    All within the induced subposet: down_x within S = down[x] & S_mask."""
    # not-T = {x in S : down(x) & S & T == 0}
    nT = 0
    for x in S_bits:
        if down[x] & S_mask & T == 0:
            nT |= 1 << x
    if nT == 0:
        return False                   # dense
    nnT = 0
    for x in S_bits:
        if down[x] & S_mask & nT == 0:
            nnT |= 1 << x
    return nnT != T                    # ordinary iff also not regular

def apertures(n, leq):
    down = down_masks(n, leq)
    ap = [0] * n
    for S_mask in range(1, 1 << n):
        S_bits = [x for x in range(n) if S_mask >> x & 1]
        for p in range(n):
            T = down[p] & S_mask
            if trace_ordinary(S_mask, S_bits, down, T):
                ap[p] += 1
    return ap

# ---------------- centralities ----------------

def centralities(n, edges, leq):
    # edges: (p, q) = p depends on q. leq[i][j] = i <= j (i below j).
    down = down_masks(n, leq)
    up = [sum(1 << i for i in range(n) if leq[x][i]) for x in range(n)]
    dep_out = [0] * n; dep_in = [0] * n
    adj_dep = [[] for _ in range(n)]   # p -> its direct dependencies
    adj_dpt = [[] for _ in range(n)]   # q -> its direct dependents
    for p, q in set(edges):
        dep_out[p] += 1; dep_in[q] += 1
        adj_dep[p].append(q); adj_dpt[q].append(p)

    def bfs_dists(adj, s):
        d = {s: 0}; front = [s]
        while front:
            nxt = []
            for u in front:
                for v in adj[u]:
                    if v not in d:
                        d[v] = d[u] + 1; nxt.append(v)
            front = nxt
        return d

    # directed betweenness (Brandes) on dependency edges
    bet = [0.0] * n
    for s in range(n):
        stack, preds = [], [[] for _ in range(n)]
        sigma = [0.0] * n; sigma[s] = 1.0
        dist = [-1] * n; dist[s] = 0
        front = [s]
        while front:
            nxt = []
            for u in front:
                stack.append(u)
                for v in adj_dep[u]:
                    if dist[v] < 0:
                        dist[v] = dist[u] + 1; nxt.append(v)
                    if dist[v] == dist[u] + 1:
                        sigma[v] += sigma[u]; preds[v].append(u)
            front = nxt
        delta = [0.0] * n
        for u in reversed(stack):
            for v in preds[u]:
                delta[v] += sigma[v] / sigma[u] * (1 + delta[u])
            if u != s:
                bet[u] += delta[u]

    # harmonic closeness, dependents direction
    harm = [0.0] * n
    for s in range(n):
        for v, d in bfs_dists(adj_dpt, s).items():
            if v != s:
                harm[s] += 1.0 / d

    # Katz and PageRank, dependents direction
    katz = [1.0] * n
    for _ in range(200):
        katz = [1.0 + 0.1 * sum(katz[u] for u in adj_dpt[v]) for v in range(n)]
    pr = [1.0 / n] * n
    outdeg_dpt = [max(len(adj_dpt[v]), 1) for v in range(n)]
    for _ in range(200):
        pr = [(1 - 0.85) / n + 0.85 * sum(pr[u] / outdeg_dpt[u]
              for u in range(n) if v in adj_dpt[u]) for v in range(n)]

    return {
        "in_degree": dep_in, "out_degree": dep_out,
        "dep_cone": [bin(down[p]).count("1") for p in range(n)],
        "dept_cone": [bin(up[p]).count("1") for p in range(n)],
        "betweenness": bet, "harmonic": harm, "katz": katz, "pagerank": pr,
        "incomparables": [n - bin(down[p] | up[p]).count("1") for p in range(n)],
    }

# ---------------- graph generators ----------------

def random_dag(rng, n, p):
    return [(i, j) for i in range(n) for j in range(i) if rng.random() < p]

def base_rooted(rng, n, p):
    # node 0 is the universal base
    edges = [(i, 0) for i in range(1, n)]
    edges += [(i, j) for i in range(1, n) for j in range(1, i)
              if rng.random() < p]
    return edges

def xz_family(rng, idx):
    # base 0; middle chain m1 <- m2 (<- m3); leaf apps fan onto top of
    # chain and base; independent cluster of libs+apps on the base.
    n = 12 + (idx % 3)
    chain_len = 2 + idx % 2
    mids = list(range(1, 1 + chain_len))
    edges = [(mids[0], 0)]
    for a, b in zip(mids[1:], mids):
        edges.append((a, b))
    rest = list(range(1 + chain_len, n))
    n_apps = max(3, len(rest) // 2)
    apps, others = rest[:n_apps], rest[n_apps:]
    for a in apps:
        edges.append((a, mids[-1]))
        edges.append((a, 0))
    for i, o in enumerate(others):
        edges.append((o, 0))
        if i > 0 and rng.random() < 0.5:
            edges.append((o, others[i - 1]))
    return n, edges, mids, apps

# ---------------- stats ----------------

def spearman(a, b):
    return mod.spearman(list(map(float, a)), list(map(float, b)))

def ranks(v):
    order = sorted(range(len(v)), key=lambda i: v[i])
    r = [0.0] * len(v)
    i = 0
    while i < len(order):
        j = i
        while j + 1 < len(order) and v[order[j + 1]] == v[order[i]]:
            j += 1
        for t in range(i, j + 1):
            r[order[t]] = (i + j) / 2.0
        i = j + 1
    return r

# ---------------- E0'' sanity ----------------

def sanity():
    print("=== E0'' sanity: subset formula vs Phase-1 nuclei enumeration ===")
    for name, n, edges, names in mod.MOTIFS:
        leq = mod.transitive_closure(n, edges)
        ap = apertures(n, leq)
        # Phase-1 engine on the dependency side
        A = mod.Algebra(n, leq)
        nuclei = mod.all_nuclei(A)
        ap_ref = [mod.invariants(A, nuclei, A.idx[A.down[x]])["aperture"]
                  for x in range(n)]
        tag = "OK" if ap == ap_ref else f"MISMATCH {ap} vs {ap_ref}"
        print(f"{name}: {dict(zip(names, ap))} {tag}")
        assert ap == ap_ref, "E0'' failed - engines disagree"
    print("E0'' PASS\n")

# ---------------- main ----------------

def main():
    os.makedirs(OUT, exist_ok=True)
    sanity()
    rng = random.Random(SEED)
    graphs = []
    for g in range(30):
        graphs.append(("random", random_dag(rng, 12, 0.25), 12))
    for g in range(10):
        graphs.append(("base-rooted", base_rooted(rng, 12, 0.25), 12))

    print("=== E7/E8: ensemble ===")
    rho_by_measure = {}
    e8_ap_up = e8_ap_dn = 0
    degen = 0
    per_graph = []
    for gi, (kind, edges, n) in enumerate(graphs):
        leq = mod.transitive_closure(n, edges)
        ap = apertures(n, leq)
        cents = centralities(n, edges, leq)
        vals = sorted(set(ap))
        if len(vals) == 1 or sorted(ap).count(min(ap)) * 2 >= n and len(vals) <= 2:
            if len(set(ap)) == 1:
                degen += 1
        rho_g = {}
        for mname, mv in cents.items():
            rho = spearman(ap, mv)
            rho_by_measure.setdefault(mname, []).append(rho)
            rho_g[mname] = rho
        # E8 witnesses: pairs ordered the same by every measure,
        # opposite by aperture (both directions)
        for u, v in itertools.combinations(range(n), 2):
            sgns = set()
            for mv in cents.values():
                d = mv[u] - mv[v]
                sgns.add(0 if d == 0 else (1 if d > 0 else -1))
            if 1 in sgns and -1 in sgns:
                continue                      # measures disagree already
            consensus = 1 if 1 in sgns else (-1 if -1 in sgns else 0)
            d_ap = ap[u] - ap[v]
            if d_ap == 0:
                continue
            ap_sign = 1 if d_ap > 0 else -1
            if consensus == 0 or ap_sign != consensus:
                if ap_sign > 0:
                    e8_ap_up += 1
                else:
                    e8_ap_dn += 1
        per_graph.append(dict(kind=kind, aperture=ap, rho=rho_g))
        if gi % 10 == 0:
            print(f"  graph {gi} ({kind}): aperture range "
                  f"{min(ap)}..{max(ap)}, distinct {len(set(ap))}/{n}")

    print("\nmedian |Spearman(aperture, measure)| over 40 graphs:")
    verdict_rho = {}
    for mname, rhos in sorted(rho_by_measure.items()):
        srt = sorted(abs(r) for r in rhos)
        med = srt[len(srt) // 2]
        verdict_rho[mname] = med
        print(f"  {mname:14s} {med:.3f}")
    k7_candidates = [m for m, r in verdict_rho.items() if r >= RHO_KILL]
    print(f"\nE8 witnesses (consensus one way or tied, aperture strictly "
          f"other/decisive): {e8_ap_up} up, {e8_ap_dn} down")
    print(f"K8 degenerate graphs (constant aperture): {degen}/40")

    print("\n=== E9: xz family ===")
    rng9 = random.Random(SEED + 1)
    e9_pass = True
    k7_load_ok = {m: True for m in verdict_rho}
    for idx in range(5):
        n, edges, mids, apps = xz_family(rng9, idx)
        leq = mod.transitive_closure(n, edges)
        ap = apertures(n, leq)
        r = ranks(ap)
        mid_rank = sum(r[m] for m in mids) / len(mids)
        app_rank = sum(r[a] for a in apps) / len(apps)
        ok = mid_rank > app_rank
        e9_pass &= ok
        cents = centralities(n, edges, leq)
        for mname, mv in cents.items():
            rm = ranks(mv)
            if not (sum(rm[m] for m in mids) / len(mids)
                    > sum(rm[a] for a in apps) / len(apps)):
                k7_load_ok[mname] = False
        print(f"  instance {idx} (n={n}): middle mean rank {mid_rank:.1f} "
              f"vs apps {app_rank:.1f} -> {'PASS' if ok else 'FAIL'} "
              f"(apertures mids {[ap[m] for m in mids]}, "
              f"apps {[ap[a] for a in apps[:3]]}...)")

    print("\n=== verdicts ===")
    k7 = [m for m in k7_candidates if k7_load_ok.get(m)]
    print(f"E7 (no measure >= {RHO_KILL} median |rho|): "
          f"{'PASS' if not k7_candidates else 'FAIL: ' + str(k7_candidates)}")
    print(f"E8 (two-sided witnesses): "
          f"{'PASS' if e8_ap_up > 0 and e8_ap_dn > 0 else 'FAIL'}")
    print(f"E9 (load tracking in all xz instances): "
          f"{'PASS' if e9_pass else 'FAIL'}")
    print(f"K7 (translation): {'FIRES: ' + str(k7) if k7 else 'does not fire'}")
    print(f"K8 (degeneracy): "
          f"{'FIRES' if degen * 2 >= len(graphs) else 'does not fire'}")

    json.dump(dict(median_rho=verdict_rho, e8=[e8_ap_up, e8_ap_dn],
                   degenerate=degen, per_graph=per_graph),
              open(os.path.join(OUT, "depth-test.json"), "w"), indent=1)
    print(f"\nresults written to {OUT}")

if __name__ == "__main__":
    main()
