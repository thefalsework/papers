"""Tests of 07-embed-zones.py's halting checks, without a model: a small
corpus from the proof generator, a conditions-shaped file built from it,
then each check corrupted in turn.

Usage: python tests/test_checks.py
"""
from __future__ import annotations

import copy
import importlib.util
import json
import random
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(HERE))
from ipl.terms import (  # noqa: E402
    canonical_formula, formula_size, formula_tokens, parse_formula, parse_term_full, term_depth, term_size, term_tokens,
)
from ipl.check import is_valid, normal_form  # noqa: E402
from ipl.gen import random_formula, random_proof  # noqa: E402
from ipl.conditions import (  # noqa: E402
    novelty_key, tertile_boundaries, train_set_fingerprint, train_term_set,
)

spec = importlib.util.spec_from_file_location("embed_zones", HERE / "07-embed-zones.py")
ez = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ez)

N_CHECKS = [0]


def expect(cond, msg, fails):
    N_CHECKS[0] += 1
    print(("ok   " if cond else "FAIL ") + msg)
    if not cond:
        fails.append(msg)


def corpus(n: int, seed: int) -> list[dict]:
    rng = random.Random(seed)
    pool: dict[tuple, dict] = {}
    while len(pool) < n:
        f = random_formula(rng)
        t = random_proof(f, rng)
        if t is None:
            continue
        cf = canonical_formula(f)
        key = tuple(formula_tokens(cf))
        if key in pool:
            continue
        nf = normal_form(t, cf)
        pool[key] = {"formula": list(key), "proof": term_tokens(nf), "formula_size": formula_size(cf),
                     "term_size": term_size(nf), "term_depth": term_depth(nf)}
    return list(pool.values())


def find_invalid_parseable(formula: list[str], rng: random.Random) -> list[str]:
    """A parseable term that fails the checker for this formula: try
    proofs of other random formulas, and a stray variable."""
    goal, _ = parse_formula(formula)
    for _ in range(200):
        f2 = random_formula(rng)
        t2 = random_proof(f2, rng)
        if t2 is not None and not is_valid(t2, goal):
            return term_tokens(t2)
    return ["v3"]


def make_conditions(train, held, prompts, train_terms, rng) -> dict:
    """Conditions-shaped record: each prompt's 'C1' has its own proof (valid)
    and one invalid parseable sample; C2/C3/C4 are the proof itself."""
    lo, hi = tertile_boundaries([h["term_size"] for h in held])
    P = []
    for i, h in enumerate(prompts):
        goal, _ = parse_formula(h["formula"])
        nov = novelty_key(parse_term_full(h["proof"]), goal) not in train_terms
        o = {"key": h["proof"], "novel": nov, "term_size": h["term_size"], "count": 1}
        good = {"sample_index": 0, "tokens": h["proof"], "n_drawn": len(h["proof"]) + 1, "terminated": True,
                "parsed": True, "valid": True, "novel": nov, "key": h["proof"], "term_size": h["term_size"]}
        bad_toks = find_invalid_parseable(h["formula"], rng)
        bad = {"sample_index": 1, "tokens": bad_toks, "n_drawn": len(bad_toks) + 1, "terminated": True,
               "parsed": True, "valid": False, "novel": None, "key": None, "term_size": None}
        budget = good["n_drawn"] + bad["n_drawn"]
        P.append({"prompt_index": i, "formula": h["formula"], "budget_draws": budget,
                  "C1": {"n_samples": 2, "samples": [good, bad], "n_parsed": 2, "n_valid": 1},
                  "C2": {"outputs": [o]},
                  "C3": {"draws": budget, "exhausted_root": False, "restarts_on_cap": 0, "outputs": [o]},
                  "C4": {"enumeration": {"caps_hit": {"node_cap": False, "list_cap": False, "max_count": False}},
                         "matching": {"shortfall": [0, 0, 0]}, "outputs": [dict(o)]}})
    return {"ranAt": "test", "mechanics_test": False, "settings": {"temperature": 1.0, "c3_mode": "mask"},
            "train_terms": {"fingerprint_sha256": train_set_fingerprint(train_terms)},
            "tertile_bounds": {"lo": lo, "hi": hi, "n_heldout_used": len(held), "n_heldout": len(held)},
            "prompts": P}


def main() -> int:
    fails = []
    rng = random.Random(2026)
    items = corpus(140, seed=99)
    train, held, prompts = items[:80], items[80:120], items[120:140]
    train_terms = train_term_set(train)
    cond = make_conditions(train, held, prompts, train_terms, rng)
    crosscheck = {"agree_all": True, "n_valid": 1000, "n_invalid": 1000, "disagreements": [], "ranAt": "x"}

    checks = ez.check_conditions(cond, train, held, crosscheck)
    rows, items_, nov = ez.build_rows(cond, held, train_terms)
    rec = ez.run_record(cond)
    expect(checks["k_check"]["certified"] and checks["minimum_competence"]["certified"]
           and checks["train_eta_long_checked"] == 80 and checks["budget"]["prompts"] == 20, "clean file passes every check", fails)
    expect(nov["invalid_rechecked"] == 20 and nov["checked"] == 40 + 20 * 4 and nov["heldout_novel"] >= 0, f"rows built: {len(rows)}; novelty re-derived {nov['checked']}, invalid re-checked {nov['invalid_rechecked']}", fails)
    c1_rows = [r for r in rows if r["arm"] == "C1"]
    expect(all(r["sampled_length"] is not None for r in c1_rows)
           and all(r["term_size"] is None for r in c1_rows if not r["valid"])
           and all(r["term_size"] is not None for r in c1_rows if r["valid"]), "C1 rows: sampled_length on every row, term_size only when valid (item C)", fails)
    c1_items = [it for r, it in zip(rows, items_) if r["arm"] == "C1"]
    expect(all(list(tok) == list(s["tokens"]) for (f, tok), s in zip(c1_items, [s for p in cond["prompts"] for s in p["C1"]["samples"]])), "C1 rows embedded as sampled, not normalized", fails)
    expect(rec["c3_restarts_on_cap"] == 0 and rec["c4_shortfall_by_tertile"] == [0, 0, 0] and rec["c1_valid"] == 20, "run record carried", fails)

    def trips_check(mutate, msg, cc=crosscheck, tr=None):
        c = copy.deepcopy(cond)
        t = copy.deepcopy(train) if tr is None else tr
        mutate(c, t)
        try:
            ez.check_conditions(c, t, held, cc)
            expect(False, msg, fails)
        except AssertionError:
            expect(True, msg, fails)

    trips_check(lambda c, t: c.__setitem__("mechanics_test", True), "assertion: mechanics-test file refused")
    trips_check(lambda c, t: None, "assertion: K-check missing", cc=None)
    trips_check(lambda c, t: None, "assertion: K-check with a disagreement", cc=dict(crosscheck, agree_all=False, disagreements=[{"i": 1}]))
    trips_check(lambda c, t: None, "assertion: K-check on fewer than 2,000 terms", cc=dict(crosscheck, n_valid=500))
    trips_check(lambda c, t: [p["C1"].__setitem__("n_valid", 0) for p in c["prompts"]], "assertion: minimum competence (valid rate below 20%)")
    trips_check(lambda c, t: c["train_terms"].__setitem__("fingerprint_sha256", "0" * 64), "assertion: training fingerprint mismatch")
    def not_eta_long(c, t):
        # a valid proof of some other formula: fingerprint updated so only the eta-long check can trip
        t[0]["proof"] = find_invalid_parseable(t[0]["formula"], random.Random(5))
        c["train_terms"]["fingerprint_sha256"] = train_set_fingerprint(train_term_set(t))
    trips_check(not_eta_long, "assertion: training item not the eta-long proof of its formula")

    def wrong_form(c, t):
        # lam v0 proves (p1 -> p2) -> (p1 -> p2) but its eta-long form is lam lam app v1 v0
        f = ["imp", "imp", "p1", "p2", "imp", "p1", "p2"]
        goal, _ = parse_formula(f)
        assert is_valid(parse_term_full(["lam", "v0"]), goal)
        t.append({"formula": f, "proof": ["lam", "v0"], "term_size": 2})
        c["train_terms"]["fingerprint_sha256"] = train_set_fingerprint(train_term_set(t))
    trips_check(wrong_form, "assertion: valid training proof not in eta-long form for its formula")
    trips_check(lambda c, t: c["tertile_bounds"].__setitem__("n_heldout_used", 5), "assertion: tertiles not from the full held-out set")
    trips_check(lambda c, t: c["tertile_bounds"].__setitem__("hi", c["tertile_bounds"]["hi"] + 0.5), "assertion: tertile boundary value differs")
    trips_check(lambda c, t: c["prompts"][3]["C1"]["samples"][0].__setitem__("n_drawn", 999), "assertion: C1 draws differ from recorded budget")
    trips_check(lambda c, t: c["prompts"][3]["C3"].__setitem__("draws", c["prompts"][3]["budget_draws"] - 1), "assertion: C3 draws differ from budget")

    def c3_over(c, t):
        c["prompts"][3]["C3"]["exhausted_root"] = True
        c["prompts"][3]["C3"]["draws"] = c["prompts"][3]["budget_draws"] + 1
    trips_check(c3_over, "assertion: C3 overspent after exhausting the space")

    def trips_rows(mutate, msg):
        c = copy.deepcopy(cond)
        mutate(c)
        try:
            ez.build_rows(c, held, train_terms)
            expect(False, msg, fails)
        except AssertionError:
            expect(True, msg, fails)

    trips_rows(lambda c: c["prompts"][0]["C2"]["outputs"][0].__setitem__("novel", not c["prompts"][0]["C2"]["outputs"][0]["novel"]), "assertion: novelty flag differs from shared recomputation")
    trips_rows(lambda c: c["prompts"][0]["C3"]["outputs"][0].__setitem__("key", c["prompts"][0]["C1"]["samples"][1]["tokens"]), "assertion: recorded-valid output fails the checker")
    trips_rows(lambda c: c["prompts"][0]["C1"]["samples"][1].__setitem__("tokens", c["prompts"][0]["C1"]["samples"][0]["tokens"]), "assertion: recorded-invalid parsed sample passes the checker")

    print(json.dumps({"checks": N_CHECKS[0], "failures": fails}))
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
