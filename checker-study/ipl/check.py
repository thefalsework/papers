"""Bidirectional type-checker for the normal-form fragment, with prefix
checking for guided search.

check(ctx, t, A): t is checked against A (introductions + case/abort +
neutrals). infer(ctx, n): n must be neutral (var / app / fst / snd).

Prefix checking: a partial term contains Hole at unfilled positions.
Holes cannot be refuted; a Hole in inference position yields the unknown
type None, which propagates. A prefix is "refuted" only when a fully
determined sub-derivation fails. A refuted prefix has no valid completion
(soundness of pruning); an unrefuted prefix may still have none.
"""
from __future__ import annotations

from typing import Optional

from .terms import (
    Abort, And, App, Atom, Bot, Case, Formula, Fst, Hole, Imp, Inl, Inr, Lam,
    Or, Pair, Snd, Term, Var, is_neutral,
)

Ctx = tuple  # innermost binder last; Var(k) refers to ctx[-1-k]; entries may be None (unknown)


class Reject(Exception):
    pass


def _eq(a: Optional[Formula], b: Optional[Formula]) -> bool:
    return a is None or b is None or a == b


def infer(ctx: Ctx, t: Term) -> Optional[Formula]:
    if isinstance(t, Hole):
        return None
    if isinstance(t, Var):
        if t.k >= len(ctx):
            raise Reject("unbound variable")
        return ctx[-1 - t.k]
    if isinstance(t, App):
        tf = infer(ctx, t.f)
        if tf is None:
            check(ctx, t.a, None)
            return None
        if not isinstance(tf, Imp):
            raise Reject("application of non-function")
        check(ctx, t.a, tf.a)
        return tf.b
    if isinstance(t, Fst):
        tn = infer(ctx, t.n)
        if tn is None:
            return None
        if not isinstance(tn, And):
            raise Reject("fst of non-pair")
        return tn.a
    if isinstance(t, Snd):
        tn = infer(ctx, t.n)
        if tn is None:
            return None
        if not isinstance(tn, And):
            raise Reject("snd of non-pair")
        return tn.b
    raise Reject("non-neutral in inference position (not in fragment)")


def check(ctx: Ctx, t: Term, goal: Optional[Formula]) -> None:
    if isinstance(t, Hole):
        return
    if isinstance(t, Lam):
        if goal is None:
            check(ctx + (None,), t.body, None)
            return
        if not isinstance(goal, Imp):
            raise Reject("lambda against non-implication")
        check(ctx + (goal.a,), t.body, goal.b)
        return
    if isinstance(t, Pair):
        if goal is None:
            check(ctx, t.a, None)
            check(ctx, t.b, None)
            return
        if not isinstance(goal, And):
            raise Reject("pair against non-conjunction")
        check(ctx, t.a, goal.a)
        check(ctx, t.b, goal.b)
        return
    if isinstance(t, (Inl, Inr)):
        if goal is None:
            check(ctx, t.a, None)
            return
        if not isinstance(goal, Or):
            raise Reject("injection against non-disjunction")
        check(ctx, t.a, goal.a if isinstance(t, Inl) else goal.b)
        return
    if isinstance(t, Case):
        tn = infer(ctx, t.n)
        if tn is None:
            check(ctx + (None,), t.l, goal)
            check(ctx + (None,), t.r, goal)
            return
        if not isinstance(tn, Or):
            raise Reject("case on non-disjunction")
        check(ctx + (tn.a,), t.l, goal)
        check(ctx + (tn.b,), t.r, goal)
        return
    if isinstance(t, Abort):
        tn = infer(ctx, t.n)
        if tn is not None and not isinstance(tn, Bot):
            raise Reject("abort on non-falsum")
        return
    if is_neutral(t):
        tn = infer(ctx, t)
        if not _eq(tn, goal):
            raise Reject("neutral has wrong type")
        return
    raise Reject(f"unknown term {t!r}")


def is_valid(t: Term, goal: Formula) -> bool:
    """Closed complete term t proves goal. Terms with holes are invalid."""
    if _has_hole(t):
        return False
    try:
        check((), t, goal)
        return True
    except Reject:
        return False


def prefix_ok(t: Term, goal: Formula) -> bool:
    """Partial term (may contain holes) is not yet refuted against goal."""
    try:
        check((), t, goal)
        return True
    except Reject:
        return False


def _has_hole(t: Term) -> bool:
    if isinstance(t, Hole):
        return True
    from .terms import children
    return any(_has_hole(c) for c in children(t))


# ----------------------------------------------------------------------------
# Eta-long normal form (for duplicate detection)
#
# At goal P→Q a neutral is expanded to lam (app (shift n) v0); at P∧Q to
# pair (fst n) (snd n); case/abort at those goals are normalised in their
# branches (each branch is normalised at the same goal). Commuting
# conversions between case and lam/pair are NOT identified; two proofs
# differing only by such a conversion count as distinct. Idempotent.


def eta_long(ctx: Ctx, t: Term, goal: Formula) -> Term:
    if isinstance(goal, Imp):
        if isinstance(t, Lam):
            return Lam(eta_long(ctx + (goal.a,), t.body, goal.b))
        if isinstance(t, Case):
            return _eta_case(ctx, t, goal)
        if isinstance(t, Abort):
            return Abort(_eta_neutral(ctx, t.n))
        # neutral
        n1 = _eta_neutral(ctx, t)
        from .terms import shift
        return Lam(eta_long(ctx + (goal.a,), App(shift(n1, 1), Var(0)), goal.b))
    if isinstance(goal, And):
        if isinstance(t, Pair):
            return Pair(eta_long(ctx, t.a, goal.a), eta_long(ctx, t.b, goal.b))
        if isinstance(t, Case):
            return _eta_case(ctx, t, goal)
        if isinstance(t, Abort):
            return Abort(_eta_neutral(ctx, t.n))
        n1 = _eta_neutral(ctx, t)
        return Pair(eta_long(ctx, Fst(n1), goal.a), eta_long(ctx, Snd(n1), goal.b))
    # atom, or, bot
    if isinstance(t, Inl):
        return Inl(eta_long(ctx, t.a, goal.a))
    if isinstance(t, Inr):
        return Inr(eta_long(ctx, t.a, goal.b))
    if isinstance(t, Case):
        return _eta_case(ctx, t, goal)
    if isinstance(t, Abort):
        return Abort(_eta_neutral(ctx, t.n))
    return _eta_neutral(ctx, t)


def _eta_case(ctx: Ctx, t: Case, goal: Formula) -> Term:
    tn = infer(ctx, t.n)
    assert isinstance(tn, Or)
    return Case(
        _eta_neutral(ctx, t.n),
        eta_long(ctx + (tn.a,), t.l, goal),
        eta_long(ctx + (tn.b,), t.r, goal),
    )


def _eta_neutral(ctx: Ctx, n: Term) -> Term:
    """Normalise arguments inside a neutral spine."""
    if isinstance(n, Var):
        return n
    if isinstance(n, App):
        tf = infer(ctx, n.f)
        assert isinstance(tf, Imp)
        return App(_eta_neutral(ctx, n.f), eta_long(ctx, n.a, tf.a))
    if isinstance(n, Fst):
        return Fst(_eta_neutral(ctx, n.n))
    if isinstance(n, Snd):
        return Snd(_eta_neutral(ctx, n.n))
    raise Reject("eta_long: not neutral")


def normal_form(t: Term, goal: Formula) -> Term:
    """Eta-long form of a valid closed proof of goal (alpha-normal by de Bruijn)."""
    return eta_long((), t, goal)
