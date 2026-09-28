"""Formulas and proof terms for the checker study.

Fragment: implication, conjunction, disjunction, falsum over atoms p1..p6.
Terms use de Bruijn indices (v0 = innermost binder), so alpha-normal form
is the identity. Both formulas and terms serialise to fixed-arity prefix
token sequences; the same tokens are the model vocabulary.

Normal-form fragment accepted by the checker (SPEC: "valid" = type-checks):

    v ::= lam v | pair v v | inl v | inr v | case n v v | abort n | n
    n ::= vK | app n v | fst n | snd n

Heads of app/fst/snd and scrutinees of case/abort must be neutral, so
beta-redexes are not in the fragment and are rejected as invalid.
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Optional, Union

# ----------------------------------------------------------------------------
# Formulas


@dataclass(frozen=True)
class Atom:
    i: int  # 1..6


@dataclass(frozen=True)
class Imp:
    a: "Formula"
    b: "Formula"


@dataclass(frozen=True)
class And:
    a: "Formula"
    b: "Formula"


@dataclass(frozen=True)
class Or:
    a: "Formula"
    b: "Formula"


@dataclass(frozen=True)
class Bot:
    pass


Formula = Union[Atom, Imp, And, Or, Bot]
BOT = Bot()
N_ATOMS = 6


def formula_size(f: Formula) -> int:
    """Symbols: atoms + connectives; bot counts one."""
    if isinstance(f, (Atom, Bot)):
        return 1
    return 1 + formula_size(f.a) + formula_size(f.b)


def formula_depth(f: Formula) -> int:
    if isinstance(f, (Atom, Bot)):
        return 1
    return 1 + max(formula_depth(f.a), formula_depth(f.b))


def formula_atoms(f: Formula, acc: Optional[list] = None) -> list:
    """Atoms in first-occurrence (left-to-right) order, without repeats."""
    if acc is None:
        acc = []
    if isinstance(f, Atom):
        if f.i not in acc:
            acc.append(f.i)
    elif isinstance(f, (Imp, And, Or)):
        formula_atoms(f.a, acc)
        formula_atoms(f.b, acc)
    return acc


def canonical_formula(f: Formula) -> Formula:
    """Atom-order canonicalisation: rename atoms to p1, p2, ... by first
    occurrence. Used for deduplication and cross-set disjointness."""
    order = formula_atoms(f)
    ren = {a: k + 1 for k, a in enumerate(order)}

    def go(g: Formula) -> Formula:
        if isinstance(g, Atom):
            return Atom(ren[g.i])
        if isinstance(g, Bot):
            return g
        return type(g)(go(g.a), go(g.b))

    return go(f)


def formula_tokens(f: Formula) -> list[str]:
    if isinstance(f, Atom):
        return [f"p{f.i}"]
    if isinstance(f, Bot):
        return ["bot"]
    head = {Imp: "imp", And: "and", Or: "or"}[type(f)]
    return [head] + formula_tokens(f.a) + formula_tokens(f.b)


def formula_str(f: Formula) -> str:
    if isinstance(f, Atom):
        return f"p{f.i}"
    if isinstance(f, Bot):
        return "⊥"
    sym = {Imp: "→", And: "∧", Or: "∨"}[type(f)]
    return f"({formula_str(f.a)} {sym} {formula_str(f.b)})"


def parse_formula(tokens: list[str], pos: int = 0) -> tuple[Formula, int]:
    t = tokens[pos]
    if t == "bot":
        return BOT, pos + 1
    if t.startswith("p") and t[1:].isdigit():
        return Atom(int(t[1:])), pos + 1
    cls = {"imp": Imp, "and": And, "or": Or}.get(t)
    if cls is None:
        raise ValueError(f"bad formula token {t!r} at {pos}")
    a, pos = parse_formula(tokens, pos + 1)
    b, pos = parse_formula(tokens, pos)
    return cls(a, b), pos


# ----------------------------------------------------------------------------
# Terms


@dataclass(frozen=True)
class Var:
    k: int  # de Bruijn index


@dataclass(frozen=True)
class Lam:
    body: "Term"


@dataclass(frozen=True)
class App:
    f: "Term"
    a: "Term"


@dataclass(frozen=True)
class Fst:
    n: "Term"


@dataclass(frozen=True)
class Snd:
    n: "Term"


@dataclass(frozen=True)
class Pair:
    a: "Term"
    b: "Term"


@dataclass(frozen=True)
class Inl:
    a: "Term"


@dataclass(frozen=True)
class Inr:
    a: "Term"


@dataclass(frozen=True)
class Case:
    n: "Term"
    l: "Term"  # binds v0 : left summand
    r: "Term"  # binds v0 : right summand


@dataclass(frozen=True)
class Abort:
    n: "Term"


@dataclass(frozen=True)
class Hole:
    """Unfinished position in a partial (prefix) term."""


Term = Union[Var, Lam, App, Fst, Snd, Pair, Inl, Inr, Case, Abort, Hole]
HOLE = Hole()

MAX_VAR = 11  # v0..v11; depth bound 10 makes indices above 9 unreachable

TERM_ARITY = {
    "lam": 1, "app": 2, "fst": 1, "snd": 1, "pair": 2,
    "inl": 1, "inr": 1, "case": 3, "abort": 1,
}


def is_neutral(t: Term) -> bool:
    return isinstance(t, (Var, App, Fst, Snd))


def term_size(t: Term) -> int:
    if isinstance(t, (Var, Hole)):
        return 1
    return 1 + sum(term_size(c) for c in children(t))


def term_depth(t: Term) -> int:
    if isinstance(t, (Var, Hole)):
        return 1
    return 1 + max(term_depth(c) for c in children(t))


def children(t: Term) -> tuple:
    if isinstance(t, (Var, Hole)):
        return ()
    if isinstance(t, Lam):
        return (t.body,)
    if isinstance(t, App):
        return (t.f, t.a)
    if isinstance(t, (Fst, Snd, Abort)):
        return (t.n,)
    if isinstance(t, Pair):
        return (t.a, t.b)
    if isinstance(t, (Inl, Inr)):
        return (t.a,)
    if isinstance(t, Case):
        return (t.n, t.l, t.r)
    raise TypeError(t)


def constructor_counts(t: Term) -> dict[str, int]:
    """Structural-embedding features: count of each constructor."""
    counts = {k: 0 for k in list(TERM_ARITY) + ["var"]}

    def go(u: Term) -> None:
        if isinstance(u, Var):
            counts["var"] += 1
            return
        if isinstance(u, Hole):
            return
        counts[term_head(u)] += 1
        for c in children(u):
            go(c)

    go(t)
    return counts


def term_head(t: Term) -> str:
    return {
        Lam: "lam", App: "app", Fst: "fst", Snd: "snd", Pair: "pair",
        Inl: "inl", Inr: "inr", Case: "case", Abort: "abort",
    }[type(t)]


def term_tokens(t: Term) -> list[str]:
    if isinstance(t, Var):
        return [f"v{t.k}"]
    if isinstance(t, Hole):
        raise ValueError("cannot serialise a hole")
    return [term_head(t)] + [tok for c in children(t) for tok in term_tokens(c)]


def term_str(t: Term) -> str:
    return " ".join(term_tokens(t))


_TERM_CLS = {
    "lam": Lam, "app": App, "fst": Fst, "snd": Snd, "pair": Pair,
    "inl": Inl, "inr": Inr, "case": Case, "abort": Abort,
}


def parse_term(tokens: list[str], pos: int = 0, allow_partial: bool = False) -> tuple[Term, int]:
    """Parse a prefix token sequence. With allow_partial, running out of
    tokens yields Hole at every unfilled position (prefix checking)."""
    if pos >= len(tokens):
        if allow_partial:
            return HOLE, pos
        raise ValueError("unexpected end of term")
    t = tokens[pos]
    if t.startswith("v") and t[1:].isdigit():
        k = int(t[1:])
        if k > MAX_VAR:
            raise ValueError(f"variable index {k} out of vocabulary")
        return Var(k), pos + 1
    cls = _TERM_CLS.get(t)
    if cls is None:
        raise ValueError(f"bad term token {t!r} at {pos}")
    args = []
    pos += 1
    for _ in range(TERM_ARITY[t]):
        c, pos = parse_term(tokens, pos, allow_partial)
        args.append(c)
    return cls(*args), pos


def parse_term_full(tokens: list[str]) -> Term:
    t, pos = parse_term(tokens, 0, allow_partial=False)
    if pos != len(tokens):
        raise ValueError(f"trailing tokens after position {pos}")
    return t


def shift(t: Term, d: int, cutoff: int = 0) -> Term:
    """Shift free indices >= cutoff by d."""
    if isinstance(t, Var):
        return Var(t.k + d) if t.k >= cutoff else t
    if isinstance(t, Hole):
        return t
    if isinstance(t, Lam):
        return Lam(shift(t.body, d, cutoff + 1))
    if isinstance(t, App):
        return App(shift(t.f, d, cutoff), shift(t.a, d, cutoff))
    if isinstance(t, Fst):
        return Fst(shift(t.n, d, cutoff))
    if isinstance(t, Snd):
        return Snd(shift(t.n, d, cutoff))
    if isinstance(t, Pair):
        return Pair(shift(t.a, d, cutoff), shift(t.b, d, cutoff))
    if isinstance(t, Inl):
        return Inl(shift(t.a, d, cutoff))
    if isinstance(t, Inr):
        return Inr(shift(t.a, d, cutoff))
    if isinstance(t, Case):
        return Case(shift(t.n, d, cutoff), shift(t.l, d, cutoff + 1), shift(t.r, d, cutoff + 1))
    if isinstance(t, Abort):
        return Abort(shift(t.n, d, cutoff))
    raise TypeError(t)


VOCAB = (
    ["imp", "and", "or", "bot"] + [f"p{i}" for i in range(1, N_ATOMS + 1)]
    + list(TERM_ARITY) + [f"v{k}" for k in range(MAX_VAR + 1)]
)
