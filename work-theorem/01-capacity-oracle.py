"""Capacity oracle for the work-theorem spec (W1-W4).

Registered: preprints/aperture/work-theorem-spec.md (committed before
this file). Exhaustive check on the down-set algebras of all posets on
<= 4 elements, plus all posets on 5 elements (every finite Heyting
algebra of size <= 32 arising as D(P), |P| <= 5; by Birkhoff every
finite distributive lattice is D(P) for some P, so this sweeps all
finite Heyting algebras with <= 5 join-irreducibles).

For every element k of every algebra:
  class(k): dense (~k = bot), regular (~~k = k), ordinary (neither)
  capacity(k) = |closure of {bot, top, k} under meet, join, himp|

Kill W-K1 fires if:
  - any dense element has capacity > 3
  - any regular element has capacity > 5
  - any ordinary element has capacity < 6
"""

import itertools
import sys

def all_posets(n):
    """Yield strict-order relations (as sets of (i,j) meaning i < j)
    for all partial orders on range(n)."""
    pairs = [(i, j) for i in range(n) for j in range(n) if i != j]
    npairs = len(pairs)
    for bits in range(1 << npairs):
        rel = set()
        for idx in range(npairs):
            if bits >> idx & 1:
                rel.add(pairs[idx])
        # antisymmetry
        ok = True
        for (i, j) in rel:
            if (j, i) in rel:
                ok = False
                break
        if not ok:
            continue
        # transitivity
        for (i, j) in rel:
            if not ok:
                break
            for (j2, l) in rel:
                if j2 == j and (i, l) not in rel:
                    ok = False
                    break
        if ok:
            yield rel

def canonical(rel, n):
    """Canonical form of a poset under relabeling (for dedup)."""
    best = None
    for perm in itertools.permutations(range(n)):
        img = frozenset((perm[i], perm[j]) for (i, j) in rel)
        key = tuple(sorted(img))
        if best is None or key < best:
            best = key
    return best

def downsets(rel, n):
    """All down-sets of the poset as bitmasks."""
    below = [0] * n  # below[j] = mask of i with i < j
    for (i, j) in rel:
        below[j] |= 1 << i
    result = []
    for mask in range(1 << n):
        ok = True
        for j in range(n):
            if mask >> j & 1 and (below[j] & mask) != below[j]:
                ok = False
                break
        if ok:
            result.append(mask)
    return result

def build_algebra(rel, n):
    """Return (elements, himp, bot, top). Meet/join are &/| on masks."""
    elems = downsets(rel, n)
    elemset = set(elems)
    top = (1 << n) - 1
    # down-closure of each point
    below = [0] * n
    for (i, j) in rel:
        below[j] |= 1 << i
    dn = [below[x] | (1 << x) for x in range(n)]
    def himp(u, v):
        # largest down-set w with w & u <= v : w = {x | dn(x) & u <= v}
        w = 0
        for x in range(n):
            if (dn[x] & u) | v == v:
                w |= 1 << x
        assert w in elemset
        return w
    return elems, himp, 0, top

def capacity(k, elems, himp, bot, top):
    S = {bot, top, k}
    changed = True
    while changed:
        changed = False
        cur = list(S)
        for a in cur:
            for b in cur:
                for v in (a & b, a | b, himp(a, b)):
                    if v not in S:
                        S.add(v)
                        changed = True
    return len(S)

def main():
    max_n = 5
    seen = set()
    counts = {"dense": 0, "regular": 0, "ordinary": 0}
    capstats = {"dense": [], "regular": [], "ordinary": []}
    kills = []
    n_algebras = 0
    for n in range(1, max_n + 1):
        for rel in all_posets(n):
            key = (n, canonical(rel, n))
            if key in seen:
                continue
            seen.add(key)
            n_algebras += 1
            elems, himp, bot, top = build_algebra(rel, n)
            for k in elems:
                nk = himp(k, bot)
                nnk = himp(nk, bot)
                if nk == bot:
                    cls = "dense"
                elif nnk == k:
                    cls = "regular"
                else:
                    cls = "ordinary"
                cap = capacity(k, elems, himp, bot, top)
                counts[cls] += 1
                capstats[cls].append(cap)
                if cls == "dense" and cap > 3:
                    kills.append((n, sorted(rel), k, cls, cap))
                if cls == "regular" and cap > 5:
                    kills.append((n, sorted(rel), k, cls, cap))
                if cls == "ordinary" and cap < 6:
                    kills.append((n, sorted(rel), k, cls, cap))
        print(f"n={n}: cumulative posets={n_algebras}", flush=True)

    print()
    print(f"algebras checked: {n_algebras}")
    for cls in ("dense", "regular", "ordinary"):
        caps = capstats[cls]
        if caps:
            print(f"  {cls:8s}: elements={counts[cls]:6d}  "
                  f"cap min={min(caps)} max={max(caps)}")
    if kills:
        print()
        print("KILL W-K1 FIRED:")
        for kk in kills[:20]:
            print("  ", kk)
        sys.exit(1)
    print()
    print("No kill fired: dense <= 3, regular <= 5, ordinary >= 6 "
          "on every element of every algebra.")

if __name__ == "__main__":
    main()
