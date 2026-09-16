# Phase 1b. Registered spec: PHASE1B-SPEC.md (committed before this
# file existed).
#
# R1: does the Interval pass survive a fresh world (World B: bigger
#     Sigma, new seed, saturation) and what does wrap-around do to it
#     (World C, exploratory)?
# R2: does the corrected partition predictor (count of partially-met
#     classes) recover signal in the original World A?
#
# Usage: python 02-phase1b.py

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

# ---------------- fresh-world factory (Worlds B and C) ----------------

def make_world(lo, hi, seed, wrap):
    sigma = frozenset(range(lo, hi + 1))
    m = hi - lo + 1

    def norm(x):
        if wrap:
            return ((x - lo) % m) + lo
        return max(lo, min(hi, x))

    def lift(g):
        return lambda U: frozenset(norm(g(x)) for x in U)

    ops = {
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

    def interval(U):
        if not U:
            return frozenset()
        return frozenset(range(min(U), max(U) + 1))

    rng = random.Random(seed)
    op_names = sorted(ops)
    programs = [[n] for n in op_names]
    while len(programs) < 50:
        ln = rng.randint(2, 4)
        programs.append([rng.choice(op_names) for _ in range(ln)])

    inputs = [frozenset([x]) for x in sorted(sigma)]
    inputs += [frozenset(), sigma,
               frozenset(x for x in sigma if x % 2 == 0),
               frozenset(x for x in sigma if x % 2 != 0),
               frozenset(x for x in sigma if x > 0),
               frozenset(x for x in sigma if x < 0)]
    seen = set(inputs)
    target = len(inputs) + 25
    while len(inputs) < target:
        U = frozenset(x for x in sigma if rng.random() < 0.35)
        if U not in seen:
            seen.add(U)
            inputs.append(U)

    return dict(ops=ops, interval=interval, programs=programs,
                inputs=inputs)

def run_world(world, rho):
    """Sweep one domain in one world. Returns rows + T0 stats."""
    rows = []
    t0_checked = t0_failed = 0
    for pi, p in enumerate(world["programs"]):
        for U in world["inputs"]:
            V = U
            a = rho(U)
            P = len(rho(U) - U)
            for k, name in enumerate(p):
                f = world["ops"][name]
                if k > 0:
                    P += len(rho(V) - V)
                V = f(V)
                a = rho(f(a))
            eps = len(a - rho(V))
            rows.append(dict(ln=len(p), eps=eps, P=P))
            if P == 0:
                t0_checked += 1
                if eps != 0:
                    t0_failed += 1
    return rows, t0_checked, t0_failed

def h1_stats(rows, xkey="P"):
    pooled = spearman([r[xkey] for r in rows], [r["eps"] for r in rows])
    strat = []
    for ln in (1, 2, 3, 4):
        rs = [r for r in rows if r["ln"] == ln]
        s = spearman([r[xkey] for r in rs], [r["eps"] for r in rs])
        if s is not None:
            strat.append(s)
    med = sorted(strat)[len(strat) // 2] if strat else None
    return pooled, strat, med

# ---------------- R1: Worlds B and C, Interval only ----------------

def r1():
    print("=== R1: Interval robustness ===")
    out = {}
    for label, wrap in (("WorldB_sat", False), ("WorldC_wrap", True)):
        world = make_world(-12, 12, 20260917, wrap)
        rows, t0c, t0f = run_world(world, world["interval"])
        assert t0f == 0, f"T0 violated in {label}"
        nz = sum(1 for r in rows if r["eps"] > 0)
        assert nz > 0, f"no error exists in {label}: study vacuous"
        pooled, strat, med = h1_stats(rows)
        out[label] = dict(pooled=pooled, strat=strat, med=med,
                          runs=len(rows), nonzero=nz, t0=t0c)
        print(f"  {label}: runs {len(rows)}, eps>0 {nz} "
              f"({nz/len(rows):.1%}), T0 exact-runs {t0c} clean")
        print(f"    pooled {pooled:+.3f}, stratified "
              f"{[f'{s:+.3f}' for s in strat]}, median {med:+.3f}")
    b = out["WorldB_sat"]
    r1a = b["pooled"] >= 0.5 and b["med"] >= 0.3
    kr = b["pooled"] < 0.3
    c = out["WorldC_wrap"]
    r1b = ("shape-robust" if c["pooled"] >= 0.3
           else "pass depends on op-hull alignment")
    print(f"  R1a (World B, unchanged thresholds): "
          f"{'PASS' if r1a else 'fail'}")
    print(f"  K-R kill: {'FIRES' if kr else 'does not fire'}")
    print(f"  R1b (World C, exploratory): {r1b}")
    out["R1a"] = "PASS" if r1a else "fail"
    out["K-R"] = "FIRES" if kr else "does not fire"
    out["R1b_reading"] = r1b
    return out

# ---------------- R2: corrected partition predictor, World A ----------

SIGMA_A = w1.SIGMA

PART_CLASSES = {
    "Parity": [frozenset(x for x in SIGMA_A if x % 2 == 0),
               frozenset(x for x in SIGMA_A if x % 2 != 0)],
    "Mod3": [frozenset(x for x in SIGMA_A if x % 3 == r)
             for r in range(3)],
    "Sign": [frozenset(x for x in SIGMA_A if x < 0), frozenset([0]),
             frozenset(x for x in SIGMA_A if x > 0)],
    "SignXParity": [
        frozenset(x for x in SIGMA_A if x < 0 and x % 2 == 0),
        frozenset(x for x in SIGMA_A if x < 0 and x % 2 != 0),
        frozenset([0]),
        frozenset(x for x in SIGMA_A if x > 0 and x % 2 == 0),
        frozenset(x for x in SIGMA_A if x > 0 and x % 2 != 0)],
}

PART_DOMAINS = {"Parity": w1.parity, "Mod3": w1.mod3, "Sign": w1.sign,
                "SignXParity": w1.signparity}

def c_of(V, classes):
    return sum(1 for C in classes if V & C and not C <= V)

def r2():
    print("\n=== R2: corrected partition predictor (World A) ===")
    out = {}
    passes = 0
    all_below_02 = True
    for dname, rho in PART_DOMAINS.items():
        classes = PART_CLASSES[dname]
        rows = []
        for p in w1.programs:
            for U in w1.inputs:
                V = U
                a = rho(U)
                P = len(rho(U) - U)
                P2 = c_of(U, classes)
                for k, name in enumerate(p):
                    f = w1.OPS[name]
                    if k > 0:
                        P += len(rho(V) - V)
                        P2 += c_of(V, classes)
                    V = f(V)
                    a = rho(f(a))
                rows.append(dict(ln=len(p), eps=len(a - rho(V)),
                                 P=P, P2=P2))
        pooled2, strat2, med2 = h1_stats(rows, "P2")
        pooled1, _, _ = h1_stats(rows, "P")
        ok = pooled2 >= 0.3 and med2 >= 0.2
        passes += ok
        if pooled2 >= 0.2:
            all_below_02 = False
        out[dname] = dict(P_pooled=pooled1, P2_pooled=pooled2,
                          P2_strat=strat2, P2_med=med2,
                          verdict="pass" if ok else "fail")
        print(f"  {dname}: P pooled {pooled1:+.3f}  ->  P2 pooled "
              f"{pooled2:+.3f}, strat median {med2:+.3f}  "
              f"[{'pass' if ok else 'fail'}]")
    r2v = passes >= 3
    print(f"  R2 (>= 3 of 4 domains): {'PASS' if r2v else 'fail'} "
          f"({passes} of 4)")
    print(f"  K-P (partition-side closure): "
          f"{'FIRES' if all_below_02 else 'does not fire'}")
    out["R2"] = "PASS" if r2v else "fail"
    out["K-P"] = "FIRES" if all_below_02 else "does not fire"
    return out

def main():
    os.makedirs(OUT, exist_ok=True)
    res = {"R1": r1(), "R2": r2()}
    with open(os.path.join(OUT, "phase1b-results.json"), "w") as fh:
        json.dump(res, fh, indent=1, default=str)
    print(f"\nresults written to {OUT}")

if __name__ == "__main__":
    main()
