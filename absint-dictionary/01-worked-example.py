# Phase 1 worked example. Registered spec: PHASE1-SPEC.md in this
# folder (committed before this file existed).
#
# Question: does the intrinsic per-element phantom count s_rho(V) =
# |rho(V) \ V| predict the run-level completeness error of stepwise
# best-correct-approximation analysis?
#
# Usage: python 01-worked-example.py

import itertools
import json
import os
import random

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "out")
SEED = 20260916
LO, HI = -8, 8
SIGMA = frozenset(range(LO, HI + 1))

def sat(x):
    return max(LO, min(HI, x))

# ---------------- domains (ucos on P(Sigma)) ----------------

def partition_closure(classes):
    cls = [frozenset(c) for c in classes]
    def rho(U):
        out = set()
        for c in cls:
            if U & c:
                out |= c
        return frozenset(out)
    return rho

parity = partition_closure([{x for x in SIGMA if x % 2 == 0},
                            {x for x in SIGMA if x % 2 != 0}])
mod3 = partition_closure([{x for x in SIGMA if x % 3 == r}
                          for r in range(3)])
sign = partition_closure([{x for x in SIGMA if x < 0}, {0},
                          {x for x in SIGMA if x > 0}])
signparity = partition_closure(
    [{x for x in SIGMA if x < 0 and x % 2 == 0},
     {x for x in SIGMA if x < 0 and x % 2 != 0},
     {0},
     {x for x in SIGMA if x > 0 and x % 2 == 0},
     {x for x in SIGMA if x > 0 and x % 2 != 0}])

def interval(U):
    if not U:
        return frozenset()
    lo, hi = min(U), max(U)
    return frozenset(range(lo, hi + 1))

DOMAINS = [("Parity", parity), ("Mod3", mod3), ("Sign", sign),
           ("SignXParity", signparity), ("Interval", interval)]

# ---------------- operations ----------------

def lift(g):
    return lambda U: frozenset(sat(g(x)) for x in U)

OPS = {
    "inc": lift(lambda x: x + 1),
    "dec": lift(lambda x: x - 1),
    "double": lift(lambda x: 2 * x),
    "neg": lift(lambda x: -x),
    "abs": lift(lambda x: abs(x)),
    "square": lift(lambda x: x * x),
    "halve": lift(lambda x: int(x / 2)),   # toward 0
    "mod3": lift(lambda x: x % 3),
    "guard_pos": lambda U: frozenset(x for x in U if x > 0),
    "guard_even": lambda U: frozenset(x for x in U if x % 2 == 0),
}

# ---------------- programs and inputs ----------------

rng = random.Random(SEED)
op_names = sorted(OPS)
programs = [[name] for name in op_names]
while len(programs) < 50:
    ln = rng.randint(2, 4)
    programs.append([rng.choice(op_names) for _ in range(ln)])

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

# ---------------- statistics ----------------

def ranks_with_ties(vals):
    order = sorted(range(len(vals)), key=lambda i: vals[i])
    r = [0.0] * len(vals)
    i = 0
    while i < len(order):
        j = i
        while j + 1 < len(order) and vals[order[j + 1]] == vals[order[i]]:
            j += 1
        avg = (i + j) / 2 + 1
        for t in range(i, j + 1):
            r[order[t]] = avg
        i = j + 1
    return r

def spearman(xs, ys):
    if len(xs) < 3 or len(set(xs)) < 2 or len(set(ys)) < 2:
        return None
    rx, ry = ranks_with_ties(xs), ranks_with_ties(ys)
    mx, my = sum(rx) / len(rx), sum(ry) / len(ry)
    num = sum((a - mx) * (b - my) for a, b in zip(rx, ry))
    dx = sum((a - mx) ** 2 for a in rx) ** 0.5
    dy = sum((b - my) ** 2 for b in ry) ** 0.5
    return num / (dx * dy) if dx and dy else None

def kendall(xs, ys):
    n = len(xs)
    num = den = 0
    for i in range(n):
        for j in range(i + 1, n):
            a = (xs[i] > xs[j]) - (xs[i] < xs[j])
            b = (ys[i] > ys[j]) - (ys[i] < ys[j])
            if a and b:
                den += 1
                num += 1 if a == b else -1
    return num / den if den else None

# ---------------- the run ----------------

def run(p, U, rho):
    """Returns (eps_complete, eps_alarm, P_traj, s_input)."""
    V = U
    a = rho(U)
    s_input = len(rho(U) - U)
    P = s_input                       # k = 0 term
    for k, name in enumerate(p):
        f = OPS[name]
        if k > 0:
            P += len(rho(V) - V)
        V = f(V)
        a = rho(f(a))
    eps_complete = len(a - rho(V))
    eps_alarm = len(a - V)
    return eps_complete, eps_alarm, P, s_input

def kp0():
    print("=== KP0: hand anchors ===")
    # T0 assertion is checked inside the main sweep (below).
    # A1 (as corrected by Amendment 1): Parity/neg, Parity/abs and
    # Sign/neg have eps = 0 on every input, with phantom > 0 somewhere.
    some_phantom = False
    for U in inputs:
        for op in ("neg", "abs"):
            e, _, P, s0 = run([op], U, parity)
            assert e == 0, f"A1 broken: Parity/{op} eps={e} on {sorted(U)}"
            if s0 > 0:
                some_phantom = True
    assert some_phantom
    print("  A1: Parity/neg and Parity/abs eps == 0 on all inputs, "
          "phantom > 0 exists  OK")
    for U in inputs:
        e, _, _, _ = run(["neg"], U, sign)
        assert e == 0, f"A1 broken: Sign/neg eps={e} on {sorted(U)}"
    print("  A1: Sign/neg eps == 0 on all inputs  OK")
    # A2: Sign, {-1}, inc: eps > 0.
    e, _, _, _ = run(["inc"], frozenset([-1]), sign)
    assert e > 0, "A2 broken: no error at Sign/{-1}/inc"
    print(f"  A2: Sign/{{-1}}/inc eps = {e} > 0  OK")
    print("KP0 PASS\n")

def main():
    os.makedirs(OUT, exist_ok=True)
    kp0()
    results = {}
    t0_checked = t0_failed = 0
    for dname, rho in DOMAINS:
        rows = []
        for pi, p in enumerate(programs):
            for U in inputs:
                e, ea, P, s0 = run(p, U, rho)
                rows.append(dict(prog=pi, ln=len(p), eps=e,
                                 eps_alarm=ea, P=P, s0=s0))
                # T0: exact trajectory (P == 0, covering k = 0..n-1)
                # implies eps == 0
                if P == 0:
                    t0_checked += 1
                    if e != 0:
                        t0_failed += 1
        pooled = spearman([r["P"] for r in rows],
                          [r["eps"] for r in rows])
        strat = []
        for ln in (1, 2, 3, 4):
            rs = [r for r in rows if r["ln"] == ln]
            rho_l = spearman([r["P"] for r in rs],
                             [r["eps"] for r in rs])
            if rho_l is not None:
                strat.append(rho_l)
        strat_sorted = sorted(strat)
        strat_median = strat_sorted[len(strat) // 2] if strat else None
        h1b = spearman([r["s0"] for r in rows],
                       [r["eps"] for r in rows])
        nonzero_eps = sum(1 for r in rows if r["eps"] > 0)
        results[dname] = dict(
            pooled=pooled, strat=strat, strat_median=strat_median,
            h1b=h1b, runs=len(rows), nonzero_eps=nonzero_eps,
            mean_phantom=sum(r["s0"] for r in rows) / len(rows),
            mean_eps=sum(r["eps"] for r in rows) / len(rows))
        print(f"=== {dname} ===")
        print(f"  runs {len(rows)}, eps>0 in {nonzero_eps} "
              f"({nonzero_eps/len(rows):.1%})")
        print(f"  H1 pooled Spearman(P, eps) = {pooled:+.3f}" if pooled
              is not None else "  H1 pooled: undefined")
        print(f"  H1 length-stratified: "
              f"{[f'{r:+.3f}' for r in strat]} median "
              f"{strat_median:+.3f}" if strat_median is not None else
              "  H1 stratified: undefined")
        print(f"  H1b input-only Spearman(s0, eps) = {h1b:+.3f}"
              if h1b is not None else "  H1b: undefined")
        print()

    print("=== T0 assertion ===")
    print(f"  exact-trajectory runs: {t0_checked}, eps != 0 among "
          f"them: {t0_failed}  "
          f"({'HOLDS' if t0_failed == 0 else 'VIOLATED - KP0'})")
    assert t0_failed == 0

    # H2 (descriptive)
    names = [d for d, _ in DOMAINS]
    mp = [results[d]["mean_phantom"] for d in names]
    me = [results[d]["mean_eps"] for d in names]
    tau = kendall(mp, me)
    print("\n=== H2 (descriptive, deflation pre-registered) ===")
    for d in names:
        print(f"  {d}: mean intrinsic phantom {results[d]['mean_phantom']:.2f}, "
              f"mean eps {results[d]['mean_eps']:.2f}")
    print(f"  Kendall tau (phantom rank vs error rank): {tau:+.3f}")

    # verdicts
    print("\n=== verdicts ===")
    h1_pass = {d: (results[d]["pooled"] is not None and
                   results[d]["pooled"] >= 0.5 and
                   results[d]["strat_median"] is not None and
                   results[d]["strat_median"] >= 0.3)
               for d in names}
    kp1 = all(results[d]["pooled"] is None or results[d]["pooled"] < 0.3
              for d in names)
    for d in names:
        print(f"  H1 {d}: {'PASS' if h1_pass[d] else 'fail'} "
              f"(pooled {results[d]['pooled']:+.3f}, strat median "
              f"{results[d]['strat_median']:+.3f})")
    print(f"  KP1 (definition-not-predictor kill): "
          f"{'FIRES' if kp1 else 'does not fire'}")
    results["H2_tau"] = tau
    results["KP1"] = "FIRES" if kp1 else "does not fire"
    with open(os.path.join(OUT, "worked-example-results.json"), "w") as fh:
        json.dump(results, fh, indent=1, default=str)
    print(f"\nresults written to {OUT}")

if __name__ == "__main__":
    main()
