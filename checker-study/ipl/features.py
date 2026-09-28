"""E2, the structural embedding: constructor counts, term depth and size,
formula features (distinct atoms, connective counts, depth, size)."""
from __future__ import annotations

import numpy as np

from .terms import (
    And, Atom, Bot, Formula, Imp, Or, TERM_ARITY, Term, constructor_counts,
    formula_atoms, formula_depth, formula_size, term_depth, term_size,
)

CONSTRUCTORS = list(TERM_ARITY) + ["var"]
FEATURE_NAMES = (
    [f"n_{c}" for c in CONSTRUCTORS] + ["term_depth", "term_size"]
    + ["f_atoms_distinct", "f_atom_occ", "f_imp", "f_and", "f_or", "f_bot", "f_depth", "f_size"]
)


def _connectives(f: Formula, acc: dict) -> dict:
    if isinstance(f, Atom):
        acc["atom_occ"] += 1
    elif isinstance(f, Bot):
        acc["bot"] += 1
    else:
        acc[{Imp: "imp", And: "and", Or: "or"}[type(f)]] += 1
        _connectives(f.a, acc)
        _connectives(f.b, acc)
    return acc


def structural_features(t: Term, f: Formula) -> np.ndarray:
    cc = constructor_counts(t)
    conn = _connectives(f, {"atom_occ": 0, "imp": 0, "and": 0, "or": 0, "bot": 0})
    row = [cc[c] for c in CONSTRUCTORS] + [term_depth(t), term_size(t)] + [
        len(formula_atoms(f)), conn["atom_occ"], conn["imp"], conn["and"], conn["or"], conn["bot"],
        formula_depth(f), formula_size(f),
    ]
    return np.array(row, dtype=float)
