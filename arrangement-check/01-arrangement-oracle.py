# Arrangement-check oracle. Registered spec: SPEC.md in this folder,
# committed before this file existed.
#
# Three lines in general position (x = 0, y = 0, x + y = 1). Faces as
# sign vectors, face order = covector order (F <= G iff F_i in
# {0, G_i}), opens = up-sets of the face poset, Heyting negation
# neg(U) = {F : up(F) cap U = empty}.
#
# E1 half-planes regular; E2 cells regular; E3 phantom pairs
# (two cells adjacent across an edge, edge excluded) ordinary;
# E4 full census of all opens. K1 fires if no open is ordinary.
#
# Usage: python 01-arrangement-oracle.py

from fractions import Fraction
import itertools
import json
import os

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "out")

# ---------------- faces via exact sign vectors ----------------

def sign(v):
    return 0 if v == 0 else (1 if v > 0 else -1)

def sigma(x, y):
    return (sign(x), sign(y), sign(x + y - 1))

def sample_points():
    pts = []
    vals = [Fraction(n, 4) for n in range(-8, 13)]  # -2 .. 3 step 1/4
    for x in vals:
        for y in vals:
            pts.append((x, y))
    # exact points on each line, including beyond the vertices
    ts = [Fraction(n, 4) for n in range(-8, 13)]
    for t in ts:
        pts.append((Fraction(0), t))              # x = 0
        pts.append((t, Fraction(0)))              # y = 0
        pts.append((t, 1 - t))                    # x + y = 1
    pts += [(Fraction(0), Fraction(0)), (Fraction(0), Fraction(1)),
            (Fraction(1), Fraction(0))]           # vertices
    return pts

FACES = sorted({sigma(x, y) for x, y in sample_points()})
N = len(FACES)
IDX = {f: i for i, f in enumerate(FACES)}
FULL = (1 << N) - 1

def face_dim(f):
    return 2 - sum(1 for s in f if s == 0)

assert N == 19, f"expected 19 faces, got {N}"
assert sorted(face_dim(f) for f in FACES).count(0) == 3
assert sorted(face_dim(f) for f in FACES).count(1) == 9
assert sorted(face_dim(f) for f in FACES).count(2) == 7
print(f"faces: {N} (3 vertices, 9 edges, 7 cells)  OK")

# covector order: F <= G iff for all i, F_i in {0, G_i}
def face_le(F, G):
    return all(fi == 0 or fi == gi for fi, gi in zip(F, G))

UP = [sum(1 << j for j, G in enumerate(FACES) if face_le(F, G))
      for F in FACES]  # UP[i] = mask of faces whose closure contains F

# ---------------- opens = up-sets; Heyting ops ----------------

def is_open(m):
    mm = m
    while mm:
        b = mm & -mm
        if UP[b.bit_length() - 1] & ~m:
            return False
        mm ^= b
    return True

def neg_in(S, U):
    """Negation of up-set U inside the algebra of up-sets of the
    induced subposet on mask S (S = FULL for the ambient algebra)."""
    r = 0
    mm = S
    while mm:
        b = mm & -mm
        if UP[b.bit_length() - 1] & S & U == 0:
            r |= b
        mm ^= b
    return r

def classify(S, U):
    r = neg_in(S, U)
    if r == 0:
        return "dense"
    return "regular" if neg_in(S, r) == U else "ordinary"

def aperture(K):
    ap = 0
    for S in range(1 << N):
        if classify(S, K & S) == "ordinary":
            ap += 1
    return ap

# ---------------- named elements ----------------

def half_plane(i, s):
    return sum(1 << j for j, F in enumerate(FACES) if F[i] == s)

CELLS = [i for i, F in enumerate(FACES) if face_dim(F) == 2]
EDGES = [i for i, F in enumerate(FACES) if face_dim(F) == 1]

def cells_of_edge(e):
    return [c for c in CELLS if (UP[e] >> c) & 1]

# ---------------- E1: half-planes ----------------

print("\n=== E1: half-planes (single threshold units) ===")
e1_ok = True
for i in range(3):
    for s in (1, -1):
        U = half_plane(i, s)
        assert is_open(U), f"half-plane({i},{s}) not open"
        cls = classify(FULL, U)
        opp = half_plane(i, -s)
        neg_is_opp = neg_in(FULL, U) == opp
        print(f"  line {i} sign {s:+d}: {cls}, neg = opposite half-plane: "
              f"{neg_is_opp}")
        if cls != "regular" or not neg_is_opp:
            e1_ok = False
print(f"E1 {'PASS' if e1_ok else 'FAIL'}")

# ---------------- E2: single cells ----------------

print("\n=== E2: single open cells (Cover's regions) ===")
e2_ok = True
for c in CELLS:
    U = 1 << c
    cls = classify(FULL, U)
    if cls != "regular":
        e2_ok = False
    print(f"  cell {FACES[c]}: {cls}")
print(f"E2 {'PASS' if e2_ok else 'FAIL'}")

# ---------------- E3: phantom pairs ----------------

print("\n=== E3: phantom pairs (adjacent cells, seam excluded) ===")
e3_ok = True
pairs = []
for e in EDGES:
    cs = cells_of_edge(e)
    assert len(cs) == 2, f"edge {FACES[e]} borders {len(cs)} cells"
    U = (1 << cs[0]) | (1 << cs[1])
    assert is_open(U)
    cls = classify(FULL, U)
    nn = neg_in(FULL, neg_in(FULL, U))
    added = nn & ~U
    added_is_seam = added == (1 << e)
    pairs.append((e, cs, cls, added_is_seam))
    print(f"  cells across edge {FACES[e]}: {cls}, "
          f"neg-neg adds exactly the seam: {added_is_seam}")
    if cls != "ordinary":
        e3_ok = False
print(f"E3 {'PASS' if e3_ok else 'FAIL'}")

# ---------------- E4: full census ----------------

print("\n=== E4: census of every open ===")
census = {"dense": 0, "regular": 0, "ordinary": 0}
n_opens = 0
for m in range(1 << N):
    if is_open(m):
        n_opens += 1
        census[classify(FULL, m)] += 1
print(f"  opens: {n_opens}")
print(f"  census: {census}")

k1 = census["ordinary"] == 0
print(f"\nK1 (seam closed): {'FIRES' if k1 else 'does not fire'}")

# ---------------- descriptive: spot apertures ----------------

print("\n=== descriptive spot apertures (unregistered) ===")
spots = {
    "half-plane(0,+)": half_plane(0, 1),
    f"cell {FACES[CELLS[0]]}": 1 << CELLS[0],
    "phantom pair (first)": (1 << pairs[0][1][0]) | (1 << pairs[0][1][1]),
}
spot_out = {}
for name, K in spots.items():
    ap = aperture(K)
    spot_out[name] = ap
    print(f"  aperture({name}) = {ap} of {1 << N}")

os.makedirs(OUT, exist_ok=True)
with open(os.path.join(OUT, "arrangement-results.json"), "w") as fh:
    json.dump(dict(
        n_faces=N, n_opens=n_opens, census=census,
        e1=e1_ok, e2=e2_ok, e3=e3_ok, k1=k1,
        phantom_pairs=[dict(edge=str(FACES[e]), cells=[str(FACES[c])
                       for c in cs], cls=cls, seam_exact=si)
                       for e, cs, cls, si in pairs],
        spot_apertures=spot_out), fh, indent=1)
print(f"\nresults written to {OUT}")
