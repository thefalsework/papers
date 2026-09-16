# Phase 2: loops and widening. Registered spec: PHASE2-SPEC.md
# (committed before this file existed).
#
# Does the Interval predictor survive widening? A-W (hand anchor):
# widening manufactures error at zero intrinsic phantom, so T0 is
# provably false here; the question is whether that mechanism
# dominates statistically (K-W) or the intrinsic signal survives.
#
# Usage: python 03-phase2-loops.py

import importlib.util
import json
import os
import random

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "out")

spec = importlib.util.spec_from_file_location(
    "worked", os.path.join(HERE, "01-worked-example.py"))
w1 = importlib.util.module_from_spec(spec)
w1.__name__ = "worked"
spec.loader.exec_module(w1)

spearman = w1.spearman

LO, HI = -8, 8
SIGMA = frozenset(range(LO, HI + 1))
SEED = 20260918

def sat(x):
    return max(LO, min(HI, x))

def lift(g):
    return lambda U: frozenset(sat(g(x)) for x in U)

OPS = {
    "inc": lift(lambda x: x + 1),
    "dec": lift(lambda x: x - 1),
    "double": lift(lambda x: 2 * x),
    "neg": lift(lambda x: -x),
    "abs": lift(lambda x: abs(x)),
    "square": lift(lambda x: x * x),
    "halve": lift(lambda x: int(x / 2)),
    "mod3": lift(lambda x: x % 3),
    "guard_pos": lambda U: frozenset(x for x in U if x > 0),
    "guard_even": lambda U: frozenset(x for x in U if x % 2 == 0),
}

# loop guards: concrete set, best-interval of G, best-interval of not-G
GUARDS = {
    "x>0":  (frozenset(x for x in SIGMA if x > 0),  (1, HI),  (LO, 0)),
    "x<0":  (frozenset(x for x in SIGMA if x < 0),  (LO, -1), (0, HI)),
    "x<3":  (frozenset(x for x in SIGMA if x < 3),  (LO, 2),  (3, HI)),
    "x>-3": (frozenset(x for x in SIGMA if x > -3), (-2, HI), (LO, -3)),
    "even": (frozenset(x for x in SIGMA if x % 2 == 0),
             (LO, HI), (LO, HI)),   # intervals cannot see parity
}

# ---------------- interval lattice ----------------
# abstract value: None (bottom) or (lo, hi)

def rho(V):
    if not V:
        return None
    return (min(V), max(V))

def gamma(a):
    if a is None:
        return frozenset()
    return frozenset(range(a[0], a[1] + 1))

def imeet(a, b):
    if a is None or b is None:
        return None
    lo, hi = max(a[0], b[0]), min(a[1], b[1])
    return (lo, hi) if lo <= hi else None

def ijoin(a, b):
    if a is None:
        return b
    if b is None:
        return a
    return (min(a[0], b[0]), max(a[1], b[1]))

def ileq(a, b):
    if a is None:
        return True
    if b is None:
        return False
    return b[0] <= a[0] and a[1] <= b[1]

def widen(a, b):
    """a = previous iterate, b = next candidate; jump unstable
    bounds to the world bounds (finite stand-in for +-inf)."""
    if a is None:
        return b
    if b is None or ileq(b, a):
        return a
    lo = a[0] if b[0] >= a[0] else LO
    hi = a[1] if b[1] <= a[1] else HI
    return (lo, hi)

def bca(op, a):
    return rho(OPS[op](gamma(a)))

def s_of(V):
    return len(gamma(rho(V)) - V)

# ---------------- programs ----------------
# item = ("op", name) | ("loop", guard_name, [op, ...])

def run_program(items, U):
    """Returns (eps, P, W): completeness error, trajectory phantom
    (sum of s over every concrete op-application argument), widening
    jump mass."""
    V = U
    a = rho(U)
    P = 0
    W = 0
    for item in items:
        if item[0] == "op":
            P += s_of(V)
            V = OPS[item[1]](V)
            a = bca(item[1], a)
        else:
            _, gname, body = item
            gset, gint, ngint = GUARDS[gname]
            # concrete collecting fixpoint
            R = V
            while True:
                B = R & gset
                Rb = B
                for op in body:
                    P += s_of(Rb)
                    Rb = OPS[op](Rb)
                Rn = R | Rb
                if Rn == R:
                    break
                R = Rn
            V = R - gset
            # abstract widening iteration
            a_in = a
            X = a_in
            while True:
                Yb = imeet(X, gint)
                for op in body:
                    Yb = bca(op, Yb)
                Y = ijoin(a_in, Yb)
                Xn = widen(X, Y)
                if Xn == X:
                    break
                W += len(gamma(Xn)) - len(gamma(ijoin(X, Y)))
                X = Xn
            a = imeet(X, ngint)
    eps = len(gamma(a) - gamma(rho(V)))
    return eps, P, W

# ---------------- corpora ----------------

rng = random.Random(SEED)
op_names = sorted(OPS)
guard_names = sorted(GUARDS)

control = []
while len(control) < 30:
    ln = rng.randint(2, 4)
    control.append([("op", rng.choice(op_names)) for _ in range(ln)])

loops = [[("loop", g, [b])] for g in guard_names for b in ("inc", "dec")]
while len(loops) < 50:
    ln = rng.randint(2, 4)
    prog = []
    for _ in range(ln):
        if rng.random() < 0.5:
            body = [rng.choice(op_names)
                    for _ in range(rng.randint(1, 2))]
            prog.append(("loop", rng.choice(guard_names), body))
        else:
            prog.append(("op", rng.choice(op_names)))
    if any(it[0] == "loop" for it in prog):
        loops.append(prog)

inputs = [frozenset([x]) for x in sorted(SIGMA)]
inputs += [frozenset(), SIGMA,
           frozenset(x for x in SIGMA if x % 2 == 0),
           frozenset(x for x in SIGMA if x % 2 != 0),
           frozenset(x for x in SIGMA if x > 0),
           frozenset(x for x in SIGMA if x < 0)]
seen = set(inputs)
target = len(inputs) + 25
while len(inputs) < target:
    U = frozenset(x for x in SIGMA if rng.random() < 0.35)
    if U not in seen:
        seen.add(U)
        inputs.append(U)

# ---------------- sweeps and verdicts ----------------

def sweep(progs):
    rows = []
    for prog in progs:
        for U in inputs:
            eps, P, W = run_program(prog, U)
            rows.append(dict(items=len(prog), eps=eps, P=P, W=W))
    return rows

def stats(rows, xkey="P"):
    pooled = spearman([r[xkey] for r in rows], [r["eps"] for r in rows])
    strat = []
    for k in sorted(set(r["items"] for r in rows)):
        rs = [r for r in rows if r["items"] == k]
        s = spearman([r[xkey] for r in rs], [r["eps"] for r in rs])
        if s is not None:
            strat.append(s)
    med = sorted(strat)[len(strat) // 2] if strat else None
    return pooled, strat, med

def main():
    os.makedirs(OUT, exist_ok=True)
    res = {}

    # --- A-W hand anchor ---
    eps, P, W = run_program([("loop", "x<3", ["inc"])], frozenset([0]))
    assert P == 0 and eps == 5, f"A-W anchor broken: P={P}, eps={eps}"
    print(f"A-W anchor: while(x<3) inc on {{0}}: P = {P}, eps = {eps}, "
          f"widening mass W = {W}  OK (error at zero phantom exists)")

    # --- H-L0 (as amended): exact cross-engine equality on the
    # loop-free control corpus against the Phase 1 engine; control
    # correlation recorded descriptively. See spec Amendment 1.
    rows = sweep(control)
    t0_viol = sum(1 for r in rows if r["P"] == 0 and r["eps"] != 0)
    assert t0_viol == 0, f"T0 violated on loop-free control: {t0_viol}"
    mismatch = 0
    for prog in control:
        names = [it[1] for it in prog]
        for U in inputs:
            e1, _, P1, _ = w1.run(names, U, w1.interval)
            e2, P2, _ = run_program(prog, U)
            if e1 != e2 or P1 != P2:
                mismatch += 1
    assert mismatch == 0, f"cross-engine mismatches: {mismatch}"
    pooled, strat, med = stats(rows)
    print(f"\nH-L0 control (loop-free, {len(rows)} runs): "
          f"cross-engine mismatches 0, T0 holds  -> PASS")
    print(f"  descriptive: pooled {pooled:+.3f}, strat "
          f"{[f'{x:+.3f}' for x in strat]}, median {med:+.3f}")
    res["HL0"] = dict(pooled=pooled, strat=strat, med=med,
                      cross_engine_mismatches=0, verdict="PASS")

    # --- H-L1: loop corpus ---
    rows = sweep(loops)
    nz = sum(1 for r in rows if r["eps"] > 0)
    zero_p_err = sum(1 for r in rows if r["P"] == 0 and r["eps"] > 0)
    pooled, strat, med = stats(rows)
    print(f"\nH-L1 loop corpus ({len(rows)} runs, {len(loops)} "
          f"programs): eps>0 in {nz} ({nz/len(rows):.1%}); "
          f"A-W-type runs (error at P=0): {zero_p_err}")
    print(f"  pooled Spearman(P, eps) = {pooled:+.3f}")
    print(f"  item-count strata: {[f'{x:+.3f}' for x in strat]}, "
          f"median {med:+.3f}")
    if pooled >= 0.5 and med >= 0.3:
        v = "PASS"
    elif pooled >= 0.3:
        v = "ATTENUATED"
    else:
        v = "K-W FIRES"
    print(f"  verdict: {v}")
    res["HL1"] = dict(pooled=pooled, strat=strat, med=med, verdict=v,
                      nonzero=nz, zero_phantom_error=zero_p_err)

    # --- D-W: autopsy ---
    sw = spearman([r["W"] for r in rows], [r["eps"] for r in rows])
    print(f"\nD-W autopsy: Spearman(W, eps) = {sw:+.3f}")
    ws = sorted(r["W"] for r in rows)
    t1, t2 = ws[len(ws) // 3], ws[2 * len(ws) // 3]
    terciles = [
        [r for r in rows if r["W"] <= t1],
        [r for r in rows if t1 < r["W"] <= t2],
        [r for r in rows if r["W"] > t2],
    ]
    tstats = []
    for i, rs in enumerate(terciles):
        s = spearman([r["P"] for r in rs], [r["eps"] for r in rs])
        tstats.append(s)
        print(f"  Spearman(P, eps) within W-tercile {i + 1} "
              f"(n={len(rs)}): "
              f"{f'{s:+.3f}' if s is not None else 'undefined'}")
    res["DW"] = dict(w_eps=sw, terciles=tstats)

    with open(os.path.join(OUT, "phase2-results.json"), "w") as fh:
        json.dump(res, fh, indent=1, default=str)
    print(f"\nresults written to {OUT}")

if __name__ == "__main__":
    main()
