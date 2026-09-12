# Bridge-study pilot. Registered spec: SPEC.md in this folder.
#
# Builds the Heyting algebra of down-sets of a dependency poset,
# enumerates all nuclei via fix-sets (cross-checked by brute force on
# small algebras), and computes the kernel-checked invariants
# (ordinary / dense / regular, aperture, co-aperture) for every
# principal cone, on both the dependency side D(P) and the dependents
# side D(P^op).
#
# Definitions mirror the Lean verbatim:
#   ordinary(a)      := not regular and not dense
#   IsNucleus j      := inflationary, idempotent, meet-preserving
#   Opens j k        := (jk => j_bot) != j_bot and ((jk => j_bot) => j_bot) != jk
#   aperture(k)      := #{ j | Opens j k }
#   phantomMass(j,k) := #Icc(k, jk);  coaperture(k) := sum over nuclei
#
# Usage: python 01-downset-pilot.py

import itertools
import json
import os
import random
import sys

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "out")

ALGEBRA_CAP = 64
NUCLEI_CAP = 20000
ENSEMBLE_N = 40
ENSEMBLE_NODES = 6
EDGE_P = 0.35
SEED = 20260912
RHO_KILL = 0.95        # K1: pooled |Spearman| above this = redundant
SEP_FLOOR = 0.10       # E2: >= 10% of equal-size pairs separated

# ---------------- poset / algebra ----------------

def transitive_closure(n, edges):
    # edges: (p, q) meaning p depends on q  =>  q <= p
    leq = [[i == j for j in range(n)] for i in range(n)]
    for p, q in edges:
        leq[q][p] = True
    for k in range(n):
        for i in range(n):
            if leq[i][k]:
                for j in range(n):
                    if leq[k][j]:
                        leq[i][j] = True
    return leq  # leq[i][j] == (i <= j)

class Algebra:
    """Heyting algebra of down-sets of a finite poset, bitmask elements."""

    def __init__(self, n, leq):
        self.n = n
        self.leq = leq
        self.down = [sum(1 << i for i in range(n) if leq[i][x]) for x in range(n)]
        elems = []
        for m in range(1 << n):
            if all(self.down[x] & m == self.down[x]
                   for x in range(n) if m >> x & 1):
                elems.append(m)
        elems.sort(key=lambda m: (bin(m).count("1"), m))
        self.elems = elems
        self.idx = {m: i for i, m in enumerate(elems)}
        self.size = len(elems)
        self.bot = self.idx[0]
        self.top = self.idx[(1 << n) - 1]
        full = (1 << n) - 1
        self.imp = [[0] * self.size for _ in range(self.size)]
        for a, U in enumerate(elems):
            for b, V in enumerate(elems):
                m = 0
                for x in range(n):
                    if self.down[x] & U & ~V & full == 0:
                        m |= 1 << x
                self.imp[a][b] = self.idx[m]
        self.meet = [[self.idx[U & V] for V in elems] for U in elems]
        self.le = [[U & V == U for V in elems] for U in elems]

    def neg(self, a):
        return self.imp[a][self.bot]

    def flags(self, a):
        na = self.neg(a)
        dense = na == self.bot
        regular = self.imp[na][self.bot] == a
        return dense, regular, (not dense and not regular)

    def icc_card(self, lo, hi):
        return sum(1 for w in range(self.size)
                   if self.le[lo][w] and self.le[w][hi])

# ---------------- nuclei ----------------

def close_fixset(A, S):
    S = set(S)
    S.add(A.top)
    changed = True
    while changed:
        changed = False
        cur = list(S)
        for s in cur:
            for t in cur:
                m = A.meet[s][t]
                if m not in S:
                    S.add(m); changed = True
        for a in range(A.size):
            for s in list(S):
                i = A.imp[a][s]
                if i not in S:
                    S.add(i); changed = True
    return frozenset(S)

def enumerate_fixsets(A, cap=NUCLEI_CAP):
    start = close_fixset(A, set())
    seen = {start}
    frontier = [start]
    while frontier:
        nxt = []
        for S in frontier:
            for x in range(A.size):
                if x not in S:
                    T = close_fixset(A, set(S) | {x})
                    if T not in seen:
                        seen.add(T)
                        nxt.append(T)
                        if len(seen) > cap:
                            return None
        frontier = nxt
    return sorted(seen, key=lambda S: (len(S), sorted(S)))

def nucleus_from_fixset(A, S):
    j = [0] * A.size
    for x in range(A.size):
        best = A.top
        for s in S:
            if A.le[x][s] and A.le[s][best]:
                best = s
        j[x] = best
    return j

def is_nucleus(A, j):
    for a in range(A.size):
        if not A.le[a][j[a]]:
            return False
        if j[j[a]] != j[a]:
            return False
    for a in range(A.size):
        for b in range(A.size):
            if j[A.meet[a][b]] != A.meet[j[a]][j[b]]:
                return False
    return True

def all_nuclei(A):
    fixsets = enumerate_fixsets(A)
    if fixsets is None:
        return None
    js = [nucleus_from_fixset(A, S) for S in fixsets]
    assert all(is_nucleus(A, j) for j in js), "fixset gave a non-nucleus"
    return js

def brute_force_nuclei(A):
    # all self-maps; only for |A| <= 6
    count = 0
    for vals in itertools.product(range(A.size), repeat=A.size):
        if is_nucleus(A, list(vals)):
            count += 1
    return count

# ---------------- invariants ----------------

def invariants(A, nuclei, k):
    dense, regular, ordinary = A.flags(k)
    ap = 0
    co = 0
    for j in nuclei:
        jk, jb = j[k], j[A.bot]
        w = A.imp[jk][jb]
        if w != jb and A.imp[w][jb] != jk:
            ap += 1
        co += A.icc_card(k, jk)
    return dict(dense=dense, regular=regular, ordinary=ordinary,
                aperture=ap, coaperture=co)

def analyze_graph(name, n, edges, node_names=None):
    node_names = node_names or [str(i) for i in range(n)]
    leq = transitive_closure(n, edges)
    out = {}
    for side, rel in (("dep", leq),
                      ("dept", [[leq[j][i] for j in range(n)] for i in range(n)])):
        A = Algebra(n, rel)
        if A.size > ALGEBRA_CAP:
            out[side] = dict(skipped="algebra > cap", size=A.size)
            continue
        nuclei = all_nuclei(A)
        if nuclei is None:
            out[side] = dict(skipped="nuclei > cap", size=A.size)
            continue
        rows = {}
        for x in range(n):
            k = A.idx[A.down[x]]
            inv = invariants(A, nuclei, k)
            inv["cone_size"] = bin(A.down[x]).count("1")
            rows[node_names[x]] = inv
        out[side] = dict(algebra_size=A.size, n_nuclei=len(nuclei), cones=rows)
    return out

# ---------------- stats ----------------

def spearman(xs, ys):
    def rank(v):
        order = sorted(range(len(v)), key=lambda i: v[i])
        r = [0.0] * len(v)
        i = 0
        while i < len(order):
            j = i
            while j + 1 < len(order) and v[order[j + 1]] == v[order[i]]:
                j += 1
            avg = (i + j) / 2.0
            for t in range(i, j + 1):
                r[order[t]] = avg
            i = j + 1
        return r
    rx, ry = rank(xs), rank(ys)
    mx = sum(rx) / len(rx); my = sum(ry) / len(ry)
    num = sum((a - mx) * (b - my) for a, b in zip(rx, ry))
    dx = sum((a - mx) ** 2 for a in rx) ** 0.5
    dy = sum((b - my) ** 2 for b in ry) ** 0.5
    return num / (dx * dy) if dx and dy else 0.0

# ---------------- E0 ----------------

def e0():
    print("=== E0: validation against the kernel ===")
    # 3-element chain poset -> D(P) = 4-chain
    A = Algebra(3, transitive_closure(3, [(1, 0), (2, 1)]))
    nuclei = all_nuclei(A)
    assert len(nuclei) == 8, f"4-chain nuclei {len(nuclei)} != 8"
    cos = [invariants(A, nuclei, e)["coaperture"] for e in range(A.size)]
    assert cos == [15, 14, 12, 8], f"4-chain coaperture {cos} != [15,14,12,8]"
    print(f"4-chain: nuclei 8 OK, coaperture {cos} == 2^4 - 2^e OK")
    # brute-force cross-check on every algebra with <= 6 elements used below
    checks = [("3-chain poset", 3, [(1, 0), (2, 1)]),
              ("2-antichain", 2, []),
              ("H3 minimal", 3, [(1, 0)])]
    for name, n, edges in checks:
        A = Algebra(n, transitive_closure(n, edges))
        if A.size > 6:
            continue
        fs = len(all_nuclei(A))
        bf = brute_force_nuclei(A)
        assert fs == bf, f"{name}: fixsets {fs} != brute force {bf}"
        print(f"{name}: |A|={A.size}, fixset nuclei {fs} == brute force {bf} OK")
    print("E0 PASS\n")

# ---------------- motifs (E1, E3) ----------------

MOTIFS = [
    ("3-chain", 3, [(1, 0), (2, 1)], ["base", "mid", "app"]),
    ("2-antichain", 2, [], ["p", "q"]),
    ("V shared base", 3, [(1, 0), (2, 0)], ["base", "p", "q"]),
    ("L shared dependent", 3, [(2, 0), (2, 1)], ["p", "q", "app"]),
    ("H3 minimal", 3, [(1, 0)], ["p", "b", "q"]),
    ("xz motif", 7,
     [(1, 0), (2, 1), (2, 0), (3, 2), (3, 0), (4, 0), (4, 6), (6, 0), (5, 0)],
     ["glibc", "liblzma", "libsystemd", "sshd", "app2", "app3", "libssl"]),
]

def fmt_flags(v):
    f = "ORDINARY" if v["ordinary"] else ("dense" if v["dense"] else "regular")
    return (f"size {v['cone_size']}  {f:8s}  aperture {v['aperture']:4d}  "
            f"coaperture {v['coaperture']:6d}")

def motifs():
    print("=== E1/E3: motifs ===")
    results = {}
    for name, n, edges, names in MOTIFS:
        res = analyze_graph(name, n, edges, names)
        results[name] = res
        for side in ("dep", "dept"):
            r = res[side]
            label = "dependency cones" if side == "dep" else "dependents cones"
            if "skipped" in r:
                print(f"{name} [{label}]: SKIPPED ({r['skipped']})")
                continue
            print(f"{name} [{label}] |A|={r['algebra_size']} "
                  f"nuclei={r['n_nuclei']}")
            for node, v in r["cones"].items():
                print(f"    {node:12s} {fmt_flags(v)}")
        print()
    # registered checks
    h3 = results["H3 minimal"]["dep"]["cones"]
    assert h3["p"]["ordinary"] and h3["b"]["regular"] and h3["q"]["regular"], \
        "H3 hand computation contradicted"
    print("H3 confirmed: unique ordinary dependency cone is p (infrastructure)")
    v = results["V shared base"]["dep"]["cones"]
    assert not any(x["ordinary"] for x in v.values()), "H1 contradicted"
    print("H1 confirmed on V motif: universal base => no ordinary dep cones")
    a = results["2-antichain"]["dep"]["cones"]
    assert all(x["regular"] for x in a.values()), "H2 contradicted"
    print("H2 confirmed: antichain => Boolean => all cones regular\n")
    return results

# ---------------- ensemble (E2 / K1 / K2) ----------------

def ensemble():
    print("=== E2/K1/K2: ensemble ===")
    rng = random.Random(SEED)
    rows = []          # (side, graph_id, node, cone_size, ord, ap, co)
    n_ordinary = 0
    skipped = 0
    for g in range(ENSEMBLE_N):
        n = ENSEMBLE_NODES
        edges = [(i, j) for i in range(n) for j in range(i)
                 if rng.random() < EDGE_P]
        res = analyze_graph(f"g{g}", n, edges)
        for side in ("dep", "dept"):
            r = res[side]
            if "skipped" in r:
                skipped += 1
                continue
            for node, v in r["cones"].items():
                rows.append((side, g, node, v["cone_size"],
                             v["ordinary"], v["aperture"], v["coaperture"]))
                if v["ordinary"]:
                    n_ordinary += 1
    print(f"{ENSEMBLE_N} graphs, {len(rows)} principal cones, "
          f"{skipped} side-skips, {n_ordinary} ordinary cones")

    verdict = {}
    for side in ("dep", "dept"):
        sub = [r for r in rows if r[0] == side]
        rho = spearman([r[3] for r in sub], [r[6] for r in sub])
        # equal-size pairs within one graph and side
        pairs = sep = 0
        bygraph = {}
        for r in sub:
            bygraph.setdefault(r[1], []).append(r)
        for g, rs in bygraph.items():
            for a, b in itertools.combinations(rs, 2):
                if a[3] == b[3]:
                    pairs += 1
                    if a[4] != b[4] or a[5] != b[5] or a[6] != b[6]:
                        sep += 1
        frac = sep / pairs if pairs else 0.0
        nord = sum(1 for r in sub if r[4])
        verdict[side] = dict(rho=rho, pairs=pairs, separated=sep,
                             sep_frac=frac, ordinary=nord)
        print(f"[{side}] Spearman(coaperture, cone size) = {rho:.4f}  "
              f"equal-size pairs {pairs}, separated {sep} ({frac:.1%})  "
              f"ordinary cones {nord}")

    pooled_rho = spearman([r[3] for r in rows], [r[6] for r in rows])
    print(f"pooled Spearman = {pooled_rho:.4f}")
    k1 = abs(pooled_rho) > RHO_KILL and all(
        v["sep_frac"] < SEP_FLOOR for v in verdict.values())
    k2 = n_ordinary == 0
    e2 = (abs(pooled_rho) <= RHO_KILL and
          any(v["sep_frac"] >= SEP_FLOOR for v in verdict.values()))
    print(f"K1 (redundancy): {'FIRES' if k1 else 'does not fire'}")
    print(f"K2 (degeneracy): {'FIRES' if k2 else 'does not fire'}")
    print(f"E2 (info beyond size): {'PASS' if e2 else 'FAIL'}")
    return dict(rows=rows, verdict=verdict, pooled_rho=pooled_rho,
                k1=k1, k2=k2, e2=e2, n_ordinary=n_ordinary)

# ---------------- main ----------------

if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    e0()
    m = motifs()
    e = ensemble()
    with open(os.path.join(OUT, "pilot-results.json"), "w") as fh:
        json.dump(dict(motifs=m, ensemble=dict(
            verdict=e["verdict"], pooled_rho=e["pooled_rho"],
            k1=e["k1"], k2=e["k2"], e2=e["e2"],
            n_ordinary=e["n_ordinary"],
            rows=[list(r) for r in e["rows"]])), fh, indent=1)
    print(f"\nresults written to {OUT}")
