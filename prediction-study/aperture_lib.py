"""Shared instrument code for the prediction study.

Ego-aperture per the registered spec (SPEC.md, frozen 2026-09-13):
ego-poset by capped BFS (fill order: p, dep-layer1, dept-layer1,
dep-layer2, dept-layer2; within layer by direct dependents desc, name
asc), SCC condensation, aperture(down-cone of p) via the
kernel-checked subset formula (aperture_eq_card_ordinary_traces):

    aperture(k) = #{ S : k cap S ordinary in D(S) }

with ordinariness of the trace T = down(p) & S decided by the O(|S|^2)
bitmask predicate verified in bridge-study Phase 2:
    notT    = { x in S : down(x) & S & T == 0 }      (Heyting negation)
    dense   iff notT == 0
    regular iff notnotT == T
    ordinary iff not dense and not regular.
"""

import numpy as np


def ego_nodes(p, deps, rdeps, indeg, names, cap):
    """Select ego-net nodes per the registered fill order.

    Instrument v2 (SPEC Amendment 1): p, dep-L1, dept-L1, sibling-up
    (dependents of dep-L1), sibling-down (dependencies of dept-L1),
    dep-L2, dept-L2.  Sibling layers supply elements incomparable to
    p, which the H3 condition requires for any nonzero aperture.
    """
    chosen = [p]
    seen = {p}

    def layer(frontier, adj):
        out = set()
        for u in frontier:
            out.update(adj.get(u, ()))
        return sorted(out - seen, key=lambda u: (-indeg[u], names[u]))

    def take(nodes):
        for u in nodes:
            if len(chosen) >= cap:
                return True
            chosen.append(u)
            seen.add(u)
        return len(chosen) >= cap

    d1 = layer([p], deps)
    if take(d1):
        return chosen
    u1 = layer([p], rdeps)
    if take(u1):
        return chosen
    if take(layer(d1, rdeps)):   # sibling-up: co-users of p's deps
        return chosen
    if take(layer(u1, deps)):    # sibling-down: what p's dependents also use
        return chosen
    if take(layer(d1, deps)):    # dep-L2
        return chosen
    take(layer(u1, rdeps))       # dept-L2
    return chosen


def _tarjan_scc(n, adj):
    """Iterative Tarjan; adj is list of lists. Returns comp id per node."""
    index = [-1] * n
    low = [0] * n
    on_stack = [False] * n
    stack = []
    comp = [-1] * n
    counter = [0]
    ncomp = [0]

    for root in range(n):
        if index[root] != -1:
            continue
        work = [(root, 0)]
        while work:
            v, pi = work[-1]
            if pi == 0:
                index[v] = low[v] = counter[0]
                counter[0] += 1
                stack.append(v)
                on_stack[v] = True
            recurse = False
            for i in range(pi, len(adj[v])):
                w = adj[v][i]
                if index[w] == -1:
                    work[-1] = (v, i + 1)
                    work.append((w, 0))
                    recurse = True
                    break
                elif on_stack[w]:
                    low[v] = min(low[v], index[w])
            if recurse:
                continue
            if low[v] == index[v]:
                while True:
                    w = stack.pop()
                    on_stack[w] = False
                    comp[w] = ncomp[0]
                    if w == v:
                        break
                ncomp[0] += 1
            work.pop()
            if work:
                u, _ = work[-1]
                low[u] = min(low[u], low[v])
    return comp, ncomp[0]


def ego_aperture(p, deps, rdeps, indeg, names, cap):
    """Ego-aperture of package p at the given cap. Returns int."""
    nodes = ego_nodes(p, deps, rdeps, indeg, names, cap)
    idx = {u: i for i, u in enumerate(nodes)}
    n = len(nodes)
    adj = [[] for _ in range(n)]
    for u in nodes:
        for w in deps.get(u, ()):
            if w in idx:
                adj[idx[u]].append(idx[w])

    comp, ncomp = _tarjan_scc(n, adj)
    cadj = [set() for _ in range(ncomp)]
    for u in range(n):
        for w in adj[u]:
            if comp[u] != comp[w]:
                cadj[comp[u]].add(comp[w])
    m = ncomp

    # down[i] = bitmask of condensed nodes reachable from i (deps below), incl. i
    down = [0] * m
    # process in reverse topological order: Tarjan numbers components in
    # reverse topological order of the condensation (successors first)
    for i in range(m):
        mask = 1 << i
        for w in cadj[i]:
            mask |= down[w]
        down[i] = mask

    down_p = down[comp[idx[p]]]
    return _aperture_from_masks(np.array(down, dtype=np.uint32), down_p, m)


def _aperture_from_masks(down, down_p, m):
    """Count subsets S of an m-node poset whose trace of down_p is ordinary."""
    S = np.arange(1 << m, dtype=np.uint32)
    T = down_p & S
    notT = np.zeros_like(S)
    for x in range(m):
        bit = np.uint32(1 << x)
        in_S = (S & bit) != 0
        empty = (down[x] & S & T) == 0
        notT |= bit * (in_S & empty).astype(np.uint32)
    notnotT = np.zeros_like(S)
    for x in range(m):
        bit = np.uint32(1 << x)
        in_S = (S & bit) != 0
        empty = (down[x] & S & notT) == 0
        notnotT |= bit * (in_S & empty).astype(np.uint32)
    ordinary = (notT != 0) & (notnotT != T)
    return int(ordinary.sum())


def aperture_bruteforce_check():
    """Sanity: reproduce bridge-study motif apertures with this engine.

    Minimal motif {p < b} + isolated q: apertures 1, 0, 0.
    xz motif (7 nodes): apertures {liblzma 21, libsystemd 21, libssl 15,
    base/apps 0} - from bridge-study Phase 1/3 (E0'' cross-checked).
    """
    # minimal motif: 0 = p, 1 = b (depends on p), 2 = q
    deps = {1: [0]}
    rdeps = {0: [1]}
    indeg = {0: 1, 1: 0, 2: 0}
    names = {0: "p", 1: "b", 2: "q"}
    got_min = []
    for node in (0, 1, 2):
        # build by hand: full 3-node poset (cap large enough)
        got_min.append(ego_aperture_full([0, 1, 2], node, deps))
    assert got_min == [1, 0, 0], got_min

    # xz motif, exact shape from bridge-study/01-downset-pilot.py:
    # 0 glibc, 1 liblzma, 2 libsystemd, 3 sshd, 4 app2, 5 app3, 6 libssl
    # edges (dependent -> dependency)
    deps_xz = {
        1: [0], 2: [1, 0], 3: [2, 0], 4: [0, 6], 6: [0], 5: [0],
    }
    # pilot/Phase-3 E0'' values: liblzma 21, libsystemd 21, libssl 15, rest 0
    expect = {1: 21, 2: 21, 6: 15, 0: 0, 3: 0, 4: 0, 5: 0}
    for node, want in expect.items():
        got = ego_aperture_full(list(range(7)), node, deps_xz)
        assert got == want, (node, got, want)
    return True


def ego_aperture_full(nodes, p, deps):
    """Aperture on an explicitly-given node set (no BFS/cap): test helper."""
    idx = {u: i for i, u in enumerate(nodes)}
    n = len(nodes)
    adj = [[idx[w] for w in deps.get(u, ()) if w in idx] for u in nodes]
    comp, ncomp = _tarjan_scc(n, adj)
    cadj = [set() for _ in range(ncomp)]
    for u in range(n):
        for w in adj[u]:
            if comp[u] != comp[w]:
                cadj[comp[u]].add(comp[w])
    down = [0] * ncomp
    for i in range(ncomp):
        mask = 1 << i
        for w in cadj[i]:
            mask |= down[w]
        down[i] = mask
    return _aperture_from_masks(
        np.array(down, dtype=np.uint32), down[comp[idx[p]]], ncomp)
