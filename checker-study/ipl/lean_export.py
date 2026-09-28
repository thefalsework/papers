"""Translate formulas and terms to Lean 4 core (no Mathlib).

Atoms become explicit Type parameters; → is →, ∧ is ×, ∨ is ⊕, ⊥ is Empty.
Terms use fun / application / .1 .2 / (u, v) / Sum.inl Sum.inr /
Sum.elim / Empty.elim. De Bruijn indices become x0, x1, ... by binder depth.
"""
from __future__ import annotations

from .terms import (
    Abort, And, App, Atom, Bot, Case, Formula, Fst, Imp, Inl, Inr, Lam, N_ATOMS,
    Or, Pair, Snd, Term, Var,
)

HEADER = (
    "set_option linter.unusedVariables false\n"
    "set_option maxHeartbeats 400000\n\n"
)
# maxErrors must be raised on the command line (-DmaxErrors=...); the
# in-file set_option is accepted but does not lift the frontend's cap.
LEAN_FLAGS = ["-DmaxErrors=100000"]
PARAMS = "(" + " ".join(f"p{i}" for i in range(1, N_ATOMS + 1)) + " : Type)"


def lean_formula(f: Formula) -> str:
    if isinstance(f, Atom):
        return f"p{f.i}"
    if isinstance(f, Bot):
        return "Empty"
    sym = {Imp: "→", And: "×", Or: "⊕"}[type(f)]
    return f"({lean_formula(f.a)} {sym} {lean_formula(f.b)})"


def lean_term(t: Term, depth: int = 0) -> str:
    if isinstance(t, Var):
        # Out-of-scope indices (possible in mutants) become an identifier
        # that is never bound, so Lean rejects them as unknown.
        return f"x{depth - 1 - t.k}" if t.k < depth else f"unbound{t.k}"
    if isinstance(t, Lam):
        return f"(fun x{depth} => {lean_term(t.body, depth + 1)})"
    if isinstance(t, App):
        return f"({lean_term(t.f, depth)} {lean_term(t.a, depth)})"
    if isinstance(t, Fst):
        return f"({lean_term(t.n, depth)}).1"
    if isinstance(t, Snd):
        return f"({lean_term(t.n, depth)}).2"
    if isinstance(t, Pair):
        return f"({lean_term(t.a, depth)}, {lean_term(t.b, depth)})"
    if isinstance(t, Inl):
        return f"(Sum.inl {lean_term(t.a, depth)})"
    if isinstance(t, Inr):
        return f"(Sum.inr {lean_term(t.a, depth)})"
    if isinstance(t, Case):
        l = lean_term(t.l, depth + 1)
        r = lean_term(t.r, depth + 1)
        return f"(Sum.elim (fun x{depth} => {l}) (fun x{depth} => {r}) {lean_term(t.n, depth)})"
    if isinstance(t, Abort):
        return f"(Empty.elim {lean_term(t.n, depth)})"
    raise TypeError(t)


def lean_decl(name: str, f: Formula, t: Term) -> str:
    """One declaration on one line, so Lean error lines map to declarations."""
    return f"def {name} {PARAMS} : {lean_formula(f)} := {lean_term(t)}"
