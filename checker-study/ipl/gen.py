"""Random (formula, proof) generation and mutation.

Pipeline: random formula of odd size in [3, 19] over atoms p1..p6 →
classical truth-table prefilter (necessary for IPL provability) →
randomised bounded search for a normal proof term of depth ≤ DEPTH_MAX
under a node budget. Formulas that exhaust the budget are discarded; the
budget is recorded with every corpus.
"""
from __future__ import annotations

import itertools
import random
from typing import Optional

from .terms import (
    BOT, Abort, And, App, Atom, Bot, Case, Formula, Fst, Imp, Inl, Inr, Lam,
    N_ATOMS, Or, Pair, Snd, Term, Var, formula_atoms, term_depth,
)
from .check import is_valid, Reject, infer

DEPTH_MAX = 10
SIZE_MIN = 3
SIZE_MAX = 20  # binary connectives make sizes odd: 3,5,...,19
DEFAULT_BUDGET = 4000


# ----------------------------------------------------------------------------
# Formulas


def random_formula(rng: random.Random, size: Optional[int] = None) -> Formula:
    if size is None:
        size = rng.choice([s for s in range(SIZE_MIN, SIZE_MAX + 1) if s % 2 == 1])
    return _rand_formula_of_size(rng, size)


def _rand_formula_of_size(rng: random.Random, size: int) -> Formula:
    if size == 1:
        # bot is one of seven leaves
        k = rng.randrange(N_ATOMS + 1)
        return BOT if k == N_ATOMS else Atom(k + 1)
    # size = 1 + s1 + s2, both odd
    odd_splits = [(s1, size - 1 - s1) for s1 in range(1, size - 1, 2)]
    s1, s2 = rng.choice(odd_splits)
    cls = rng.choice([Imp, And, Or])
    return cls(_rand_formula_of_size(rng, s1), _rand_formula_of_size(rng, s2))


def classically_valid(f: Formula) -> bool:
    atoms = formula_atoms(f)
    for bits in itertools.product((False, True), repeat=len(atoms)):
        env = dict(zip(atoms, bits))
        if not _eval(f, env):
            return False
    return True


def _eval(f: Formula, env: dict) -> bool:
    if isinstance(f, Atom):
        return env[f.i]
    if isinstance(f, Bot):
        return False
    a, b = _eval(f.a, env), _eval(f.b, env)
    if isinstance(f, Imp):
        return (not a) or b
    if isinstance(f, And):
        return a and b
    return a or b


# ----------------------------------------------------------------------------
# Randomised bounded proof search for normal terms


class _Budget:
    def __init__(self, n: int):
        self.left = n


class OutOfBudget(Exception):
    pass


def random_proof(f: Formula, rng: random.Random, budget: int = DEFAULT_BUDGET,
                 depth_max: int = DEPTH_MAX) -> Optional[Term]:
    """A random normal proof of f with depth ≤ depth_max, or None."""
    if not classically_valid(f):
        return None
    b = _Budget(budget)
    try:
        t = _gen(rng, (), f, depth_max, b)
    except OutOfBudget:
        return None
    if t is None:
        return None
    assert is_valid(t, f), "generator produced an invalid term"
    # The search bound limits recursion, not constructor nesting exactly;
    # spine arguments can stack. Enforce the registered depth bound on the
    # finished term (about 0.1% of proofs are dropped by this).
    if term_depth(t) > depth_max:
        return None
    return t


def _tick(b: _Budget) -> None:
    b.left -= 1
    if b.left <= 0:
        raise OutOfBudget


def _gen(rng: random.Random, ctx: tuple, goal: Formula, depth: int, b: _Budget) -> Optional[Term]:
    _tick(b)
    if depth <= 0:
        return None
    if isinstance(goal, Imp):
        body = _gen(rng, ctx + (goal.a,), goal.b, depth - 1, b)
        return None if body is None else Lam(body)
    if isinstance(goal, And):
        a = _gen(rng, ctx, goal.a, depth - 1, b)
        if a is None:
            return None
        c = _gen(rng, ctx, goal.b, depth - 1, b)
        return None if c is None else Pair(a, c)
    # atom / or / bot: choose among spines from context variables and injections
    options: list = [("var", k) for k in range(len(ctx))]
    if isinstance(goal, Or):
        options += [("inl", None), ("inr", None)]
    rng.shuffle(options)
    for kind, k in options:
        if kind == "var":
            t = _spine(rng, ctx, Var(k), ctx[-1 - k], goal, depth - 1, b)
        elif kind == "inl":
            u = _gen(rng, ctx, goal.a, depth - 1, b)
            t = None if u is None else Inl(u)
        else:
            u = _gen(rng, ctx, goal.b, depth - 1, b)
            t = None if u is None else Inr(u)
        if t is not None:
            return t
    return None


def _spine(rng: random.Random, ctx: tuple, n: Term, tn: Formula, goal: Formula,
           depth: int, b: _Budget) -> Optional[Term]:
    """Eliminate neutral n : tn until it proves goal."""
    _tick(b)
    if tn == goal:
        return n
    if depth <= 0:
        return None
    if isinstance(tn, Bot):
        return Abort(n)
    if isinstance(tn, Imp):
        arg = _gen(rng, ctx, tn.a, depth - 1, b)
        if arg is None:
            return None
        return _spine(rng, ctx, App(n, arg), tn.b, goal, depth - 1, b)
    if isinstance(tn, And):
        first, second = (Fst, Snd) if rng.random() < 0.5 else (Snd, Fst)
        for proj in (first, second):
            sub = tn.a if proj is Fst else tn.b
            t = _spine(rng, ctx, proj(n), sub, goal, depth - 1, b)
            if t is not None:
                return t
        return None
    if isinstance(tn, Or):
        from .terms import shift
        l = _gen(rng, ctx + (tn.a,), goal, depth - 1, b)
        if l is None:
            return None
        r = _gen(rng, ctx + (tn.b,), goal, depth - 1, b)
        if r is None:
            return None
        return Case(n, l, r)
    return None  # atom that is not the goal


# ----------------------------------------------------------------------------
# Mutations (well-formed, usually ill-typed)


def mutate(t: Term, rng: random.Random) -> Term:
    """One random local edit. Result is well-formed; validity must be
    re-checked by the caller."""
    nodes = _paths(t)
    path = rng.choice(nodes)
    return _replace(t, path, lambda sub: _mutate_node(sub, rng))


def _paths(t: Term, prefix: tuple = ()) -> list[tuple]:
    from .terms import children
    out = [prefix]
    for i, c in enumerate(children(t)):
        out += _paths(c, prefix + (i,))
    return out


def _replace(t: Term, path: tuple, fn) -> Term:
    from .terms import children
    if not path:
        return fn(t)
    i, rest = path[0], path[1:]
    cs = list(children(t))
    cs[i] = _replace(cs[i], rest, fn)
    return type(t)(*cs)


def _mutate_node(t: Term, rng: random.Random) -> Term:
    kinds = []
    if isinstance(t, Var):
        kinds = ["var_shift"]
    if isinstance(t, Inl):
        kinds = ["swap_inj"]
    if isinstance(t, Inr):
        kinds = ["swap_inj"]
    if isinstance(t, Fst):
        kinds = ["swap_proj"]
    if isinstance(t, Snd):
        kinds = ["swap_proj"]
    if isinstance(t, Pair):
        kinds = ["swap_pair", "drop_pair"]
    if isinstance(t, Lam):
        kinds = ["drop_lam"]
    if isinstance(t, Case):
        kinds = ["swap_branches", "drop_case"]
    if isinstance(t, App):
        kinds = ["drop_app"]
    if isinstance(t, Abort):
        kinds = ["drop_abort"]
    kinds.append("wrap_lam")
    kinds.append("wrap_fst")
    kind = rng.choice(kinds)
    if kind == "var_shift":
        return Var(max(0, t.k + rng.choice([-1, 1, 2])))
    if kind == "swap_inj":
        return Inr(t.a) if isinstance(t, Inl) else Inl(t.a)
    if kind == "swap_proj":
        return Snd(t.n) if isinstance(t, Fst) else Fst(t.n)
    if kind == "swap_pair":
        return Pair(t.b, t.a)
    if kind == "drop_pair":
        return t.a
    if kind == "drop_lam":
        return t.body
    if kind == "swap_branches":
        return Case(t.n, t.r, t.l)
    if kind == "drop_case":
        return t.l
    if kind == "drop_app":
        return t.f
    if kind == "drop_abort":
        return t.n
    if kind == "wrap_lam":
        return Lam(t)
    if kind == "wrap_fst":
        return Fst(t) if isinstance(t, (Var, App, Fst, Snd)) else Pair(t, t)
    raise AssertionError(kind)
