# Arrangement scaling census. Registered: SPEC.md amendment of
# 2026-09-15 (E5 validation, E6 census, E7 Glivenko bridge, E3' seam
# exactness, K2), committed before this file existed.
#
# Generic lines, exact rational arithmetic throughout:
#   n=3: x, y, x+y-1
#   n=4: + 2x+y-3
#   n=5: + 3x-y+2
#
# Faces constructed from exact vertex/edge/cell sampling; E5 validates
# against closed forms (C(n,2), n^2, 1+n+C(n,2)) before any census.
#
# Usage: python 02-scaling-census.py

from fractions import Fraction
import itertools
import json
import os

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "out")
ENUM_CAP = 30_000_000   # exact-census cap on number of opens

LINES = [  # (A, B, C) meaning A x + B y + C
    (Fraction(1), Fraction(0), Fraction(0)),
    (Fraction(0), Fraction(1), Fraction(0)),
    (Fraction(1), Fraction(1), Fraction(-1)),
    (Fraction(2), Fraction(1), Fraction(-3)),
    (Fraction(3), Fraction(-1), Fraction(2)),
]

def sign(v):
    return 0 if v == 0 else (1 if v > 0 else -1)

def build_faces(n):
    """Exact face construction; returns list of sign vectors."""
    lines = LINES[:n]
    def sigma(x, y):
        return tuple(sign(A * x + B * y + C) for A, B, C in lines)
    # vertices: pairwise intersections
    verts = []
    for i, j in itertools.combinations(range(n), 2):
        A1, B1, C1 = lines[i]; A2, B2, C2 = lines[j]
        det = A1 * B2 - A2 * B1
        assert det != 0, "parallel lines"
        x = (B1 * C2 - B2 * C1) / det
        y = (A2 * C1 - A1 * C2) / det
        verts.append((x, y))
    assert len(set(verts)) == len(verts), "concurrent lines"
    faces = {sigma(x, y) for x, y in verts}
    # edges: sample points on each line between/beyond its vertices
    eps = Fraction(1, 1 << 20)
    for i, (A, B, C) in enumerate(lines):
        # param direction d = (B, -A); base point on line
        if B != 0:
            base = (Fraction(0), -C / B)
        else:
            base = (-C / A, Fraction(0))
        d = (B, -A)
        ts = []
        for (x, y) in verts:
            if A * x + B * y + C == 0:
                t = (x - base[0]) * d[0] + (y - base[1]) * d[1]
                ts.append(t / (d[0] * d[0] + d[1] * d[1]))
        ts.sort()
        samples = [ts[0] - 1] + \
            [(ts[k] + ts[k + 1]) / 2 for k in range(len(ts) - 1)] + \
            [ts[-1] + 1]
        for t in samples:
            p = (base[0] + t * d[0], base[1] + t * d[1])
            faces.add(sigma(*p))
            # cells adjacent to this edge point: normal offsets
            for s in (eps, -eps):
                faces.add(sigma(p[0] + s * A, p[1] + s * B))
    for (x, y) in verts:
        faces.add(sigma(x, y))
    return sorted(faces)

def face_dim(f):
    return 2 - sum(1 for s in f if s == 0)

def face_le(F, G):
    return all(fi == 0 or fi == gi for fi, gi in zip(F, G))

def analyze(n):
    print(f"\n================ n = {n} lines ================")
    faces = build_faces(n)
    N = len(faces)
    nv = sum(1 for f in faces if face_dim(f) == 0)
    ne = sum(1 for f in faces if face_dim(f) == 1)
    nc = sum(1 for f in faces if face_dim(f) == 2)
    from math import comb
    exp_v, exp_e, exp_c = comb(n, 2), n * n, 1 + n + comb(n, 2)
    print(f"E5: faces {N} = {nv}v + {ne}e + {nc}c "
          f"(closed form {exp_v}/{exp_e}/{exp_c})")
    assert (nv, ne, nc) == (exp_v, exp_e, exp_c), "E5 FAILED — stop"
    print("E5 PASS")

    UP = [sum(1 << j for j, G in enumerate(faces) if face_le(F, G))
          for F in faces]
    CELLS = [i for i, F in enumerate(faces) if face_dim(F) == 2]
    EDGES = [i for i, F in enumerate(faces) if face_dim(F) == 1]
    VERTS = [i for i, F in enumerate(faces) if face_dim(F) == 0]
    cellmask = sum(1 << c for c in CELLS)

    def neg(U):
        r = 0
        for x in range(N):
            if UP[x] & U == 0:
                r |= 1 << x
        return r

    def classify(U):  # dense-first (registered convention)
        r = neg(U)
        if r == 0:
            return "dense"
        return "regular" if neg(r) == U else "ordinary"

    # E3': all adjacent pairs, seam exactness
    ok_pairs = 0
    for e in EDGES:
        cs = [c for c in CELLS if (UP[e] >> c) & 1]
        assert len(cs) == 2
        U = (1 << cs[0]) | (1 << cs[1])
        nn = neg(neg(U))
        if classify(U) == "ordinary" and nn & ~U == (1 << e):
            ok_pairs += 1
    print(f"E3': phantom pairs ordinary with exact seam: "
          f"{ok_pairs}/{len(EDGES)}")

    # half-planes and cells (E1/E2 analogues)
    hp_ok = all(classify(sum(1 << j for j, F in enumerate(faces)
                             if F[i] == s)) == "regular"
                for i in range(n) for s in (1, -1))
    cell_ok = all(classify(1 << c) == "regular" for c in CELLS)
    print(f"E1/E2 analogues: half-planes regular {hp_ok}, "
          f"cells regular {cell_ok}")

    # ---- counts via stratum decomposition (exact, no enumeration) ----
    # up-set = (C, E, V): E subset of A(C) = edges with both cells in C;
    # V subset of {v : edges(v) subset of E}. Total =
    # sum_C sum_{W subset verts, edges(W) subset A(C)} 2^(|A(C)|-|edges(W)|)
    edges_of_vert = {v: [e for e in EDGES if (UP[v] >> e) & 1]
                     for v in VERTS}
    vmask = {v: sum(1 << e for e in edges_of_vert[v]) for v in VERTS}
    cells_of_edge = {e: [c for c in CELLS if (UP[e] >> c) & 1]
                     for e in EDGES}

    def count_upsets_with_cellset(Cset):
        A = [e for e in EDGES if all(c in Cset for c in cells_of_edge[e])]
        Amask = sum(1 << e for e in A)
        total = 0
        for r in range(len(VERTS) + 1):
            for W in itertools.combinations(VERTS, r):
                em = 0
                for v in W:
                    em |= vmask[v]
                if em & ~Amask:
                    continue
                total += 1 << (bin(Amask & ~em).count("1"))
        return total

    total_opens = 0
    dense_count = None
    for bits in range(1 << len(CELLS)):
        Cset = {CELLS[t] for t in range(len(CELLS)) if (bits >> t) & 1}
        cnt = count_upsets_with_cellset(Cset)
        total_opens += cnt
        if len(Cset) == len(CELLS):
            dense_count = cnt   # dense <=> all cells present
    print(f"E6 counts: opens {total_opens}, dense {dense_count} "
          f"(dense = up-sets containing all cells)")

    # ---- exact census by enumeration, if affordable ----
    census = None
    regulars_cellsets = None
    if total_opens <= ENUM_CAP:
        census = {"dense": 0, "regular": 0, "ordinary": 0}
        regulars = []
        for bits in range(1 << len(CELLS)):
            Cm = sum(1 << CELLS[t] for t in range(len(CELLS))
                     if (bits >> t) & 1)
            Cset = {CELLS[t] for t in range(len(CELLS)) if (bits >> t) & 1}
            A = [e for e in EDGES
                 if all(c in Cset for c in cells_of_edge[e])]
            Amask = sum(1 << e for e in A)
            E = Amask
            while True:
                elig = [v for v in VERTS if vmask[v] & ~E == 0]
                for r in range(len(elig) + 1):
                    for W in itertools.combinations(elig, r):
                        U = Cm | E | sum(1 << v for v in W)
                        cls = classify(U)
                        census[cls] += 1
                        if cls == "regular":
                            regulars.append(U)
                if E == 0:
                    break
                E = (E - 1) & Amask
        print(f"E6 census (dense-first): {census}  "
              f"ordinary fraction {census['ordinary']/total_opens:.1%}")
        # E7: Glivenko bridge (regular-inclusive: regulars + top)
        reg_incl = set(regulars)
        top = (1 << N) - 1
        reg_incl.add(top)  # top is dense-first-classified as dense
        cellsets = {U & cellmask for U in reg_incl}
        e7 = (len(reg_incl) == (1 << len(CELLS))
              and len(cellsets) == len(reg_incl))
        print(f"E7: regulars (incl. top) {len(reg_incl)} vs "
              f"2^cells = {1 << len(CELLS)}; cell-set map injective: "
              f"{len(cellsets) == len(reg_incl)}  -> "
              f"{'HOLDS' if e7 else 'FAILS'}")
        regulars_cellsets = e7
    else:
        print(f"E6: enumeration skipped (opens > cap {ENUM_CAP}); "
              f"census derived below if E7 held at smaller n")

    return dict(n=n, faces=N, opens=total_opens, dense=dense_count,
                census=census, e3p=(ok_pairs, len(EDGES)),
                hp_ok=hp_ok, cell_ok=cell_ok, e7=regulars_cellsets,
                n_cells=len(CELLS))

if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    results = [analyze(n) for n in (3, 4, 5)]

    print("\n================ summary ================")
    e7_all = all(r["e7"] for r in results if r["e7"] is not None)
    for r in results:
        if r["census"]:
            frac = r["census"]["ordinary"] / r["opens"]
            src = "exact"
        elif e7_all:
            # ordinary = total - dense - (2^cells - 1)  [dense-first]
            ordn = r["opens"] - r["dense"] - ((1 << r["n_cells"]) - 1)
            frac = ordn / r["opens"]
            r["census"] = dict(dense=r["dense"],
                               regular=(1 << r["n_cells"]) - 1,
                               ordinary=ordn, derived=True)
            src = "derived via E7"
        else:
            frac, src = None, "unavailable"
        print(f"  n={r['n']}: opens {r['opens']:,}, "
              f"ordinary fraction "
              f"{frac:.1%} ({src})" if frac is not None else
              f"  n={r['n']}: opens {r['opens']:,} (census unavailable)")
        print(f"        E3' {r['e3p'][0]}/{r['e3p'][1]}, "
              f"half-planes {r['hp_ok']}, cells {r['cell_ok']}, "
              f"E7 {r['e7']}")
    k2 = any(r["census"] and r["n"] == 4 and
             r["census"]["ordinary"] / r["opens"] < 1 / 3
             for r in results)
    print(f"\nK2 (mid-tone thins): {'FIRES' if k2 else 'does not fire'}")

    with open(os.path.join(OUT, "scaling-results.json"), "w") as fh:
        json.dump(results, fh, indent=1, default=str)
    print(f"results written to {OUT}")
