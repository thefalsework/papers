"""Independent completeness cross-check for unique-ordinary-search.py.

The minimality claim ("H8 is the minimal counterexample, by exhaustive
enumeration of all finite Heyting algebras of cardinality <= 12") depends on
the enumeration being complete.  Finite Heyting algebras = finite
distributive lattices, and by Birkhoff duality these are in bijection (up to
isomorphism) with finite posets (of join-irreducibles).  So the enumeration
is complete iff it generates EVERY poset P with |D(P)| <= 12, up to iso.

This script re-runs the same generation, canonicalizes each poset up to
isomorphism, and compares the per-size counts of distinct distributive
lattices against the published reference values:

    OEIS A006982 (number of unlabeled distributive lattices on n nodes):
    n  = 1  2  3  4  5  6  7  8   9  10  11  12
    a  = 1  1  1  2  3  5  8 15  26  47  82 151     (total 342)

(Erne, Heitzig & Reinhold, "On the Number of Distributive Lattices",
Electron. J. Combin. 9 (2002), #R24.)

If the counts match at every size, the generation provably visited every
finite Heyting algebra of cardinality <= 12 at least once, and the
minimality of the 8-element counterexample is confirmed against an
external, independently computed census.

Also re-reports the counterexample landscape up to isomorphism.
"""

from itertools import permutations

MAX_SIZE = 12
OEIS_A006982 = {1: 1, 2: 1, 3: 1, 4: 2, 5: 3, 6: 5,
                7: 8, 8: 15, 9: 26, 10: 47, 11: 82, 12: 151}


def downsets(downs):
    n = len(downs)
    result = []
    for mask in range(1 << n):
        ok = True
        for i in range(n):
            if (mask >> i) & 1 and (downs[i] & mask) != downs[i]:
                ok = False
                break
        if ok:
            result.append(mask)
    return result


def relation(downs):
    """Strict order as a set of pairs (i < j)."""
    n = len(downs)
    return {(i, j) for j in range(n) for i in range(n)
            if i != j and (downs[j] >> i) & 1}


def canonical(downs):
    """Canonical form of the poset up to isomorphism: iterated invariant
    refinement, then minimum relation-encoding over the (small) residual
    permutation group.  Falls back to full permutation search only within
    refinement classes."""
    n = len(downs)
    if n == 0:
        return ()
    rel = relation(downs)
    ups = [sum(1 for (i, j) in rel if i == k) for k in range(n)]
    dws = [sum(1 for (i, j) in rel if j == k) for k in range(n)]
    # iterated refinement (1-dim Weisfeiler-Leman on the order relation)
    color = [(dws[k], ups[k]) for k in range(n)]
    for _ in range(n):
        new = []
        for k in range(n):
            below = tuple(sorted(color[i] for (i, j) in rel if j == k))
            above = tuple(sorted(color[j] for (i, j) in rel if i == k))
            new.append((color[k], below, above))
        # compress colors to ranks for stability
        ranks = {c: r for r, c in enumerate(sorted(set(new)))}
        new = [ranks[c] for c in new]
        if new == color:
            break
        color = new
    # group elements by final color; candidate orderings permute within color
    order = sorted(range(n), key=lambda k: (color[k], k))
    classes = []
    for k in order:
        if classes and color[classes[-1][-1]] == color[k]:
            classes[-1].append(k)
        else:
            classes.append([k])
    best = None
    # cartesian product of within-class permutations
    def rec(idx, perm):
        nonlocal best
        if idx == len(classes):
            pos = {v: p for p, v in enumerate(perm)}
            enc = tuple(sorted((pos[i], pos[j]) for (i, j) in rel))
            if best is None or enc < best:
                best = enc
            return
        for p in permutations(classes[idx]):
            rec(idx + 1, perm + list(p))
    rec(0, [])
    return (n, best)


def analyze(downs):
    n = len(downs)
    dsets = downsets(downs)
    size = len(dsets)
    full = (1 << n) - 1

    def neg(s):
        out = 0
        for p in range(n):
            if downs[p] & s == 0:
                out |= 1 << p
        return out

    def himp(s, t):
        out = 0
        for p in range(n):
            if downs[p] & s & ~t == 0:
                out |= 1 << p
        return out

    ordinary = [s for s in dsets if neg(s) != 0 and neg(neg(s)) != s]
    if len(ordinary) != 1:
        return size, False, None
    a = ordinary[0]
    closure = {0, a, full}
    changed = True
    while changed:
        changed = False
        items = list(closure)
        for x in items:
            for y in items:
                for z in (x & y, x | y, himp(x, y)):
                    if z not in closure:
                        closure.add(z)
                        changed = True
    return size, True, len(closure) == size


def main():
    per_size = {}        # size -> set of canonical poset forms
    cex_per_size = {}    # size -> set of canonical forms of counterexamples
    stack = [()]
    seen_labeled = set()
    while stack:
        downs = stack.pop()
        if downs in seen_labeled:
            continue
        seen_labeled.add(downs)
        dsets = downsets(list(downs))
        if len(dsets) > MAX_SIZE:
            continue
        size = len(dsets)
        can = canonical(list(downs))
        per_size.setdefault(size, set()).add(can)
        s, uniq, onegen = analyze(list(downs))
        if uniq and not onegen:
            cex_per_size.setdefault(size, set()).add(can)
        i = len(downs)
        for d in dsets:
            stack.append(downs + (d | (1 << i),))

    print("size | found (iso classes) | OEIS A006982 | match")
    all_match = True
    for n in range(1, MAX_SIZE + 1):
        found = len(per_size.get(n, set()))
        ref = OEIS_A006982[n]
        ok = found == ref
        all_match = all_match and ok
        print(f"{n:4} | {found:19} | {ref:12} | {'OK' if ok else 'MISMATCH'}")
    total = sum(len(v) for v in per_size.values())
    print(f"total distinct distributive lattices <= {MAX_SIZE}: {total} "
          f"(reference: {sum(OEIS_A006982.values())})")
    print()
    print("counterexamples (unique ordinary element, NOT one-generated by it),")
    print("up to isomorphism:")
    for n in sorted(cex_per_size):
        print(f"  size {n}: {len(cex_per_size[n])} iso class(es)")
    if cex_per_size:
        print(f"MINIMAL counterexample cardinality: {min(cex_per_size)}")
    print()
    print("CENSUS CROSS-CHECK:", "PASS" if all_match else "FAIL")


if __name__ == "__main__":
    main()
