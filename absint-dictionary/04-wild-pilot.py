# Phase 3: the wild pilot. Registered spec: PHASE3-SPEC.md (committed
# before this file existed and before the corpus was cloned).
#
# Real integer functions from TheAlgorithms/Python; exhaustive
# concrete collecting semantics as ground truth; realistic
# non-relational interval analysis (closed-form transfer, widening,
# var-vs-const guard refinement only) as the analyzer under test.
#
# One datum per function: (eps, P, W). Primary claim H-W1 lives in
# the widening-quiet stratum. All conventions here are the spec's.
#
# Usage: python 04-wild-pilot.py

import ast
import importlib.util
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "out")
# Amendment 2: second source, union corpus, cross-source dedupe
SOURCES = [
    ("https://github.com/TheAlgorithms/Python",
     os.path.join(HERE, "wild-corpus")),
    ("https://github.com/keon/algorithms",
     os.path.join(HERE, "wild-corpus-2")),
]

spec = importlib.util.spec_from_file_location(
    "worked", os.path.join(HERE, "01-worked-example.py"))
w1 = importlib.util.module_from_spec(spec)
w1.__name__ = "worked"
spec.loader.exec_module(w1)
spearman = w1.spearman

STEP_CAP = 10_000
MAG_CAP = 10 ** 6
WIDE = 10 ** 6          # widening jump target (the +-inf stand-in)
PRIMARY_BOX = (-8, 8)
FALLBACK_BOX = (0, 16)

# ---------------------------------------------------------------
# AST filter (the registered whitelist)
# ---------------------------------------------------------------

ALLOWED_BINOPS = (ast.Add, ast.Sub, ast.Mult, ast.FloorDiv, ast.Mod)
ALLOWED_CMPS = (ast.Lt, ast.LtE, ast.Gt, ast.GtE, ast.Eq, ast.NotEq)
ALLOWED_CALLS = {"abs", "min", "max"}

def ok_expr(e):
    if isinstance(e, ast.Constant):
        return type(e.value) is int
    if isinstance(e, ast.Name):
        return isinstance(e.ctx, ast.Load)
    if isinstance(e, ast.BinOp):
        return (isinstance(e.op, ALLOWED_BINOPS) and ok_expr(e.left)
                and ok_expr(e.right))
    if isinstance(e, ast.UnaryOp):
        return isinstance(e.op, ast.USub) and ok_expr(e.operand)
    if isinstance(e, ast.Call):
        return (isinstance(e.func, ast.Name)
                and e.func.id in ALLOWED_CALLS and not e.keywords
                and len(e.args) >= 1 and all(ok_expr(a) for a in e.args))
    return False

def ok_test(e):
    if isinstance(e, ast.Compare):
        return (len(e.ops) == 1 and isinstance(e.ops[0], ALLOWED_CMPS)
                and ok_expr(e.left) and ok_expr(e.comparators[0]))
    if isinstance(e, ast.BoolOp):
        return all(ok_test(v) for v in e.values)
    if isinstance(e, ast.Constant):
        return e.value is True or e.value is False
    return False

def ok_range(e):
    return (isinstance(e, ast.Call) and isinstance(e.func, ast.Name)
            and e.func.id == "range" and not e.keywords
            and 1 <= len(e.args) <= 2 and all(ok_expr(a) for a in e.args))

def ok_stmt(s):
    if isinstance(s, ast.Return):
        return s.value is not None and ok_expr(s.value)
    if isinstance(s, ast.Assign):
        if len(s.targets) != 1:
            return False
        t = s.targets[0]
        if isinstance(t, ast.Name):
            return ok_expr(s.value)
        if isinstance(t, ast.Tuple) and isinstance(s.value, ast.Tuple):
            return (len(t.elts) == len(s.value.elts)
                    and all(isinstance(x, ast.Name) for x in t.elts)
                    and all(ok_expr(v) for v in s.value.elts))
        return False
    if isinstance(s, ast.AugAssign):
        return (isinstance(s.target, ast.Name)
                and isinstance(s.op, ALLOWED_BINOPS) and ok_expr(s.value))
    if isinstance(s, ast.If):
        return (ok_test(s.test) and all(ok_stmt(x) for x in s.body)
                and all(ok_stmt(x) for x in s.orelse))
    if isinstance(s, ast.While):
        return (ok_test(s.test) and not s.orelse
                and all(ok_stmt(x) for x in s.body))
    if isinstance(s, ast.For):
        return (isinstance(s.target, ast.Name) and ok_range(s.iter)
                and not s.orelse and all(ok_stmt(x) for x in s.body))
    if isinstance(s, (ast.Break, ast.Continue)):
        return True
    # Amendment 1: docstrings are semantically inert no-ops
    if isinstance(s, ast.Expr) and isinstance(s.value, ast.Constant) \
            and isinstance(s.value.value, str):
        return True
    return False

def passes_filter(fn):
    a = fn.args
    if (a.posonlyargs or a.kwonlyargs or a.vararg or a.kwarg
            or a.defaults or a.kw_defaults):
        return False
    if not (1 <= len(a.args) <= 3):
        return False
    return all(ok_stmt(s) for s in fn.body)

# ---------------------------------------------------------------
# Concrete interpreter with per-point collection
# ---------------------------------------------------------------

class Cap(Exception):
    pass

class RunFail(Exception):
    def __init__(self, reason):
        self.reason = reason

class Concrete:
    def __init__(self):
        self.steps = 0
        self.collect = {}    # (node_id, keys) -> set of value tuples

    def tick(self):
        self.steps += 1
        if self.steps > STEP_CAP:
            raise Cap

    def record(self, node, env):
        keys = tuple(sorted(env))
        self.collect.setdefault((id(node), keys), set()).add(
            tuple(env[k] for k in keys))

    def ev(self, e, env):
        self.tick()
        if isinstance(e, ast.Constant):
            return e.value
        if isinstance(e, ast.Name):
            if e.id not in env:
                raise RunFail("unbound name")
            return env[e.id]
        if isinstance(e, ast.BinOp):
            l, r = self.ev(e.left, env), self.ev(e.right, env)
            try:
                if isinstance(e.op, ast.Add):
                    v = l + r
                elif isinstance(e.op, ast.Sub):
                    v = l - r
                elif isinstance(e.op, ast.Mult):
                    v = l * r
                elif isinstance(e.op, ast.FloorDiv):
                    v = l // r
                else:
                    v = l % r
            except ZeroDivisionError:
                raise RunFail("raises")
            if abs(v) > MAG_CAP:
                raise RunFail("magnitude")
            return v
        if isinstance(e, ast.UnaryOp):
            return -self.ev(e.operand, env)
        if isinstance(e, ast.Call):
            args = [self.ev(a, env) for a in e.args]
            return {"abs": abs, "min": min, "max": max}[e.func.id](*args)
        raise RunFail("expr")

    def test(self, t, env):
        self.tick()
        if isinstance(t, ast.Constant):
            return t.value
        if isinstance(t, ast.Compare):
            l = self.ev(t.left, env)
            r = self.ev(t.comparators[0], env)
            op = t.ops[0]
            if isinstance(op, ast.Lt):
                return l < r
            if isinstance(op, ast.LtE):
                return l <= r
            if isinstance(op, ast.Gt):
                return l > r
            if isinstance(op, ast.GtE):
                return l >= r
            if isinstance(op, ast.Eq):
                return l == r
            return l != r
        if isinstance(t, ast.BoolOp):
            if isinstance(t.op, ast.And):
                return all(self.test(v, env) for v in t.values)
            return any(self.test(v, env) for v in t.values)
        raise RunFail("test")

    def run_block(self, body, env):
        """Returns ('normal'|'break'|'continue'|'return', value)."""
        for s in body:
            self.record(s, env)
            self.tick()
            if isinstance(s, ast.Return):
                v = self.ev(s.value, env)
                if type(v) is not int:
                    raise RunFail("returns non-int")
                return ("return", v)
            elif isinstance(s, ast.Assign):
                t = s.targets[0]
                if isinstance(t, ast.Name):
                    env[t.id] = self.ev(s.value, env)
                else:
                    vals = [self.ev(v, env) for v in s.value.elts]
                    for nm, v in zip(t.elts, vals):
                        env[nm.id] = v
            elif isinstance(s, ast.AugAssign):
                node = ast.BinOp(ast.Name(s.target.id, ast.Load()),
                                 s.op, s.value)
                env[s.target.id] = self.ev(node, env)
            elif isinstance(s, ast.If):
                br = s.body if self.test(s.test, env) else s.orelse
                sig = self.run_block(br, env)
                if sig[0] != "normal":
                    return sig
            elif isinstance(s, ast.While):
                while self.test(s.test, env):
                    sig = self.run_block(s.body, env)
                    if sig[0] == "break":
                        break
                    if sig[0] == "return":
                        return sig
            elif isinstance(s, ast.For):
                args = [self.ev(a, env) for a in s.iter.args]
                lo, hi = (0, args[0]) if len(args) == 1 else args
                v = lo
                while v < hi:
                    env[s.target.id] = v
                    sig = self.run_block(s.body, env)
                    if sig[0] == "break":
                        break
                    if sig[0] == "return":
                        return sig
                    v += 1
            elif isinstance(s, ast.Break):
                return ("break", None)
            elif isinstance(s, ast.Continue):
                return ("continue", None)
        return ("normal", None)

# ---------------------------------------------------------------
# Interval (box) abstract interpreter
# ---------------------------------------------------------------
# interval: None (bottom) or (lo, hi); env: dict or None (bottom)

def inorm(lo, hi):
    return None if lo > hi else (max(lo, -WIDE), min(hi, WIDE))

def ijoin(a, b):
    if a is None:
        return b
    if b is None:
        return a
    return (min(a[0], b[0]), max(a[1], b[1]))

def envjoin(e1, e2):
    if e1 is None:
        return e2
    if e2 is None:
        return e1
    keys = set(e1) & set(e2)
    return {k: ijoin(e1[k], e2[k]) for k in keys}

def envwiden(old, new):
    if old is None:
        return new
    if new is None:
        return old
    out = {}
    for k in set(old) & set(new):
        (ol, oh), (nl, nh) = old[k], new[k]
        out[k] = (ol if nl >= ol else -WIDE, oh if nh <= oh else WIDE)
    return out

def envle(e1, e2):
    if e1 is None:
        return True
    if e2 is None:
        return False
    for k in e2:
        if k not in e1:
            return False
        if not (e2[k][0] <= e1[k][0] and e1[k][1] <= e2[k][1]):
            return False
    return True

class Abstract:
    def __init__(self):
        self.ret = None       # join of return intervals
        self.wmass = 0        # widening jump mass (volume, bigint)

    def ev(self, e, env):
        if isinstance(e, ast.Constant):
            return (e.value, e.value)
        if isinstance(e, ast.Name):
            return env.get(e.id)
        if isinstance(e, ast.UnaryOp):
            v = self.ev(e.operand, env)
            return None if v is None else (-v[1], -v[0])
        if isinstance(e, ast.Call):
            vs = [self.ev(a, env) for a in e.args]
            if any(v is None for v in vs):
                return None
            f = e.func.id
            if f == "abs":
                (l, h) = vs[0]
                if l >= 0:
                    return (l, h)
                if h <= 0:
                    return (-h, -l)
                return (0, max(-l, h))
            if f == "min":
                return (min(v[0] for v in vs), min(v[1] for v in vs))
            return (max(v[0] for v in vs), max(v[1] for v in vs))
        if isinstance(e, ast.BinOp):
            a, b = self.ev(e.left, env), self.ev(e.right, env)
            if a is None or b is None:
                return None
            (al, ah), (bl, bh) = a, b
            if isinstance(e.op, ast.Add):
                return inorm(al + bl, ah + bh)
            if isinstance(e.op, ast.Sub):
                return inorm(al - bh, ah - bl)
            if isinstance(e.op, ast.Mult):
                ps = [al * bl, al * bh, ah * bl, ah * bh]
                return inorm(min(ps), max(ps))
            if isinstance(e.op, ast.FloorDiv):
                out = None
                for (dl, dh) in ((max(bl, 1), bh), (bl, min(bh, -1))):
                    if dl > dh:
                        continue
                    cs = [al // dl, al // dh, ah // dl, ah // dh]
                    out = ijoin(out, (min(cs), max(cs)))
                return None if out is None else inorm(*out)
            # Mod, Python sign convention (sign of divisor)
            out = None
            if bh >= 1:                     # positive divisor part
                out = ijoin(out, (0, min(bh, WIDE) - 1))
            if bl <= -1:                    # negative divisor part
                out = ijoin(out, (max(bl, -WIDE) + 1, 0))
            return None if out is None else inorm(*out)
        return None

    def refine(self, t, env, truth):
        """Sound var-vs-const refinement per the registered convention."""
        if env is None:
            return None
        if isinstance(t, ast.Constant):
            return env if bool(t.value) == truth else None
        if isinstance(t, ast.BoolOp):
            isand = isinstance(t.op, ast.And)
            if isand == truth:              # conjunction of refinements
                out = env
                for v in t.values:
                    out = self.refine(v, out, truth)
                return out
            out = None                      # disjunction: join
            for v in t.values:
                out = envjoin(out, self.refine(v, env, truth))
            return out
        if isinstance(t, ast.Compare):
            l, r = t.left, t.comparators[0]
            op = t.ops[0]
            flip = {ast.Lt: ast.Gt, ast.Gt: ast.Lt, ast.LtE: ast.GtE,
                    ast.GtE: ast.LtE, ast.Eq: ast.Eq, ast.NotEq: ast.NotEq}
            if isinstance(r, ast.Name) and isinstance(l, ast.Constant):
                l, r, op = r, l, flip[type(op)]()
            if not (isinstance(l, ast.Name) and isinstance(r, ast.Constant)
                    and l.id in env):
                return env                  # var-var etc.: no refinement
            c = r.value
            iv = env[l.id]
            if iv is None:
                return None
            lo, hi = iv
            neg = {ast.Lt: ast.GtE, ast.LtE: ast.Gt, ast.Gt: ast.LtE,
                   ast.GtE: ast.Lt, ast.Eq: ast.NotEq, ast.NotEq: ast.Eq}
            if not truth:
                op = neg[type(op)]()
            if isinstance(op, ast.Lt):
                hi = min(hi, c - 1)
            elif isinstance(op, ast.LtE):
                hi = min(hi, c)
            elif isinstance(op, ast.Gt):
                lo = max(lo, c + 1)
            elif isinstance(op, ast.GtE):
                lo = max(lo, c)
            elif isinstance(op, ast.Eq):
                lo, hi = max(lo, c), min(hi, c)
            else:                           # NotEq
                if lo == hi == c:
                    return None
                if lo == c:
                    lo += 1
                if hi == c:
                    hi -= 1
            if lo > hi:
                return None
            out = dict(env)
            out[l.id] = (lo, hi)
            return out
        return env

    def block(self, body, env):
        """Returns (fallthrough env, break env, continue env)."""
        brk = cont = None
        for s in body:
            if env is None:
                break
            if isinstance(s, ast.Return):
                v = self.ev(s.value, env)
                self.ret = ijoin(self.ret, v)
                env = None
            elif isinstance(s, ast.Assign):
                t = s.targets[0]
                if isinstance(t, ast.Name):
                    env = dict(env)
                    env[t.id] = self.ev(s.value, env)
                else:
                    vals = [self.ev(v, env) for v in s.value.elts]
                    env = dict(env)
                    for nm, v in zip(t.elts, vals):
                        env[nm.id] = v
            elif isinstance(s, ast.AugAssign):
                node = ast.BinOp(ast.Name(s.target.id, ast.Load()),
                                 s.op, s.value)
                env = dict(env)
                env[s.target.id] = self.ev(node, env)
            elif isinstance(s, ast.If):
                thn, tb, tc = self.block(
                    s.body, self.refine(s.test, env, True))
                els, eb, ec = self.block(
                    s.orelse, self.refine(s.test, env, False))
                env = envjoin(thn, els)
                brk = envjoin(brk, envjoin(tb, eb))
                cont = envjoin(cont, envjoin(tc, ec))
            elif isinstance(s, ast.While):
                env = self.loop(env, s.test, s.body)
            elif isinstance(s, ast.For):
                env = self.forloop(env, s)
            elif isinstance(s, ast.Break):
                brk = envjoin(brk, env)
                env = None
            elif isinstance(s, ast.Continue):
                cont = envjoin(cont, env)
                env = None
        return env, brk, cont

    def loop(self, entry, test, body):
        X = entry
        breaks = None
        for _ in range(200):                # widening guarantees quick stop
            inb = self.refine(test, X, True)
            after, b, c = self.block(body, inb)
            breaks = envjoin(breaks, b)
            cand = envjoin(entry, envjoin(after, c))
            Xn = envwiden(X, cand)
            if X is not None and Xn is not None and \
                    envle(Xn, X) and envle(X, Xn):
                break
            if X is not None and Xn is not None:
                self.wmass += vol(Xn) - vol(envjoin(X, cand))
            X = Xn
        exit_env = self.refine(test, X, False)
        return envjoin(exit_env, breaks)

    def forloop(self, entry, s):
        args = [self.ev(a, entry) for a in s.iter.args]
        if any(a is None for a in args) or entry is None:
            return entry
        lo, hi = ((0, 0), args[0]) if len(args) == 1 else args
        env = dict(entry)
        env[s.target.id] = lo
        test = ast.Compare(ast.Name(s.target.id, ast.Load()),
                           [ast.Lt()],
                           [ast.Constant(hi[1])] if hi[0] == hi[1]
                           else [ast.Name("__hi", ast.Load())])
        if hi[0] != hi[1]:
            env["__hi"] = hi
        inc = ast.AugAssign(ast.Name(s.target.id, ast.Store()),
                            ast.Add(), ast.Constant(1))
        out = self.loop(env, test, list(s.body) + [inc])
        if out is not None:
            out = {k: v for k, v in out.items() if k != "__hi"}
        return out

def vol(env):
    if env is None:
        return 0
    v = 1
    for (l, h) in env.values():
        v *= (h - l + 1)
    return v

# ---------------------------------------------------------------
# Per-function pipeline
# ---------------------------------------------------------------

def analyze(fn, box):
    """Returns dict or raises RunFail/Cap."""
    params = [a.arg for a in fn.args.args]
    lo, hi = box
    conc = Concrete()
    returns = set()
    import itertools
    for vals in itertools.product(range(lo, hi + 1), repeat=len(params)):
        conc.steps = 0
        env = dict(zip(params, vals))
        sig = conc.run_block(fn.body, env)
        if sig[0] != "return":
            raise RunFail("returns None")
        returns.add(sig[1])
    # P from collecting sets
    P = 0
    hullsum = 0
    for (_, keys), tuples in conc.collect.items():
        if not keys:
            continue
        hull = 1
        for i in range(len(keys)):
            vs = [t[i] for t in tuples]
            hull *= (max(vs) - min(vs) + 1)
        P += hull - len(tuples)
        hullsum += hull
    # abstract run
    ab = Abstract()
    env0 = {p: (lo, hi) for p in params}
    ab.block(fn.body, env0)
    if ab.ret is None:
        raise RunFail("abstract bottom return")
    rl, rh = ab.ret
    # soundness
    if not (rl <= min(returns) and max(returns) <= rh):
        raise RunFail("SOUNDNESS")
    exit_size = rh - rl + 1
    eps = exit_size - (max(returns) - min(returns) + 1)
    return dict(eps=eps, P=P, W=ab.wmass, exit_size=exit_size,
                hullsum=hullsum)

def kp0():
    print("=== hand anchors ===")
    sq = ast.parse("def f(x):\n    return x * x").body[0]
    r = analyze(sq, PRIMARY_BOX)
    assert r["eps"] == 64, f"A-corr broken: eps={r['eps']}"
    print(f"  A-corr: f(x)=x*x on [-8,8]: eps = {r['eps']} (expected 64) OK")
    inc = ast.parse("def f(x):\n    return x + 1").body[0]
    r = analyze(inc, PRIMARY_BOX)
    assert r["eps"] == 0, f"A-complete broken: eps={r['eps']}"
    print("  A-complete: f(x)=x+1: eps = 0  OK")

# ---------------------------------------------------------------
# Corpus
# ---------------------------------------------------------------

def get_corpus():
    hashes = {}
    fns = []
    seen = set()
    for repo, corpus in SOURCES:
        if not os.path.isdir(corpus):
            subprocess.run(["git", "clone", "--depth", "1", repo, corpus],
                           check=True)
        h = subprocess.run(["git", "-C", corpus, "rev-parse", "HEAD"],
                           capture_output=True, text=True).stdout.strip()
        hashes[repo] = h
        for root, _dirs, files in os.walk(corpus):
            if ".git" in root:
                continue
            for f in sorted(files):
                if not f.endswith(".py"):
                    continue
                path = os.path.join(root, f)
                try:
                    with open(path, encoding="utf-8",
                              errors="replace") as fh:
                        tree = ast.parse(fh.read())
                except SyntaxError:
                    continue
                for node in tree.body:
                    if not isinstance(node, ast.FunctionDef):
                        continue
                    if not passes_filter(node):
                        continue
                    key = ast.dump(ast.Module(node.body, [])) + \
                        str(len(node.args.args))
                    if key in seen:
                        continue
                    seen.add(key)
                    rel = os.path.join(os.path.basename(corpus),
                                       os.path.relpath(path, corpus))
                    fns.append((rel, node.name, node))
    return hashes, fns

def main():
    os.makedirs(OUT, exist_ok=True)
    kp0()
    hashes, fns = get_corpus()
    print()
    for repo, h in hashes.items():
        print(f"corpus: {repo} @ {h}")
    print(f"functions passing the AST whitelist (deduped): {len(fns)}")
    commit = hashes

    rows, excluded = [], []
    for rel, name, node in fns:
        rec = None
        for box in (PRIMARY_BOX, FALLBACK_BOX):
            try:
                rec = analyze(node, box)
                rec.update(file=rel, name=name, box=list(box),
                           arity=len(node.args.args))
                break
            except Cap:
                reason = "step cap"
            except RunFail as e:
                reason = e.reason
                if reason == "SOUNDNESS":
                    raise AssertionError(
                        f"soundness violated at {rel}:{name}")
        if rec:
            rows.append(rec)
        else:
            excluded.append(dict(file=rel, name=name, reason=reason))

    n = len(rows)
    print(f"included: {n}; excluded: {len(excluded)}")
    from collections import Counter
    print("  exclusion reasons:",
          dict(Counter(e['reason'] for e in excluded)))

    res = dict(commit=commit, included=n, excluded=excluded, rows=rows)

    if n < 20:
        print("\nVIABILITY GATE: corpus too thin (< 20). "
              "Recorded, no verdict.")
        res["verdict"] = "thin corpus - no verdict"
    else:
        nz = [r for r in rows if r["eps"] > 0]
        print(f"\neps > 0 in {len(nz)} of {n} functions "
              f"({len(nz)/n:.0%}); eps == 0 rate {(n-len(nz))/n:.0%}")
        if len(nz) < 10:
            print("VIABILITY GATE: corpus essentially complete at this "
                  "box (< 10 with eps > 0). Recorded, no verdict.")
            res["verdict"] = "mostly complete - no verdict"
        else:
            quiet = [r for r in rows if r["W"] == 0]
            active = [r for r in rows if r["W"] > 0]
            print(f"widening-quiet stratum: {len(quiet)}; "
                  f"widening-active: {len(active)}")
            res["quiet_n"] = len(quiet)
            if len(quiet) < 15:
                print("stratum n < 15: no H-W1 verdict (recorded).")
                res["verdict"] = "quiet stratum too thin - no verdict"
            else:
                raw = spearman([r["P"] for r in quiet],
                               [r["eps"] for r in quiet])
                norm = spearman(
                    [r["P"] / max(1, r["hullsum"]) for r in quiet],
                    [r["eps"] / max(1, r["exit_size"]) for r in quiet])
                res["HW1_raw"] = raw
                res["HW1_norm"] = norm
                rs = f"{raw:+.3f}" if raw is not None else "undefined"
                ns = f"{norm:+.3f}" if norm is not None else "undefined"
                print(f"  H-W1 quiet stratum (n={len(quiet)}): raw "
                      f"Spearman(P, eps) = {rs}, normalized "
                      f"Spearman(P', eps') = {ns}")
                if raw is None:
                    v = "undefined - no verdict"
                elif raw >= 0.40 and norm is not None and norm >= 0.25:
                    v = "H-W1 PASS"
                elif raw >= 0.25:
                    v = "ATTENUATED (recorded, no verdict spin)"
                else:
                    v = "K-W1 FIRES: instrument is toy-bound"
                print(f"  verdict: {v}")
                res["verdict"] = v
            pooled = spearman([r["P"] for r in rows],
                              [r["eps"] for r in rows])
            res["D_pooled"] = pooled
            ps = f"{pooled:+.3f}" if pooled is not None else "undefined"
            print(f"  D: pooled all functions = {ps}")
            if len(active) >= 3:
                sw = spearman([r["W"] for r in active],
                              [r["eps"] for r in active])
                res["D_W_eps_active"] = sw
                ss = f"{sw:+.3f}" if sw is not None else "undefined"
                print(f"  D: Spearman(W, eps) widening-active "
                      f"(n={len(active)}) = {ss}")

    with open(os.path.join(OUT, "wild-pilot-results.json"), "w") as fh:
        json.dump(res, fh, indent=1, default=str)
    print(f"\nresults written to {OUT}")

if __name__ == "__main__":
    main()
