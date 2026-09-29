"""Embed and zone every output of the four conditions plus the base rate.

Input: out/conditions-<profile>-seed<k>-T<temp>.json (from 06-conditions.py,
test prompts). Output: out/zones-<profile>-seed<k>-T<temp>[-mc<n>].json with
one row per output and zone labels / nearest-training distances per
embedding, PCA dimension and calibration rule. 08-analysis.py consumes the
output; this script computes no hypothesis statistic.

Rows:
  B    every held-out proof (unit: held-out formula); 'novel' marks the
       term-novel subset that is H1's base rate (postscript 2026-09-29 on B)
  C1   every raw C1 sample that parses (valid or not), one row per sample,
       embedded AS SAMPLED (postscript "Resolutions", item C); H3's
       population. Size of the sampled token sequence is 'sampled_length';
       'term_size' is the normal-form size for valid rows and null otherwise
  C2   unique valid outputs of C1 per prompt, eta-long normal form
  C3   unique valid completions of guided search per prompt, normal form
  C4   size-matched enumerated proofs per prompt, normal form

Halting checks (spec postscripts 2026-09-29), all in check_conditions and
build_rows so tests/test_checks.py can exercise them without a model:
  * not a mechanics-test file
  * K-check: out/crosscheck.json shows Python and Lean agreeing on all
    2,000 cross-check terms
  * minimum competence: at least 20% of C1 samples valid (spec "Model")
  * identical novelty: training-term fingerprint matches the corpus, the
    training proofs are stored eta-long, and every arm's novelty flag is
    re-derived with conditions.novelty_key
  * every recorded-valid output re-passes the checker; every recorded
    invalid parsed sample re-fails it
  * exact draw budget: C1 draws == recorded budget == C3 draws per prompt
    (unless the search exhausted the space, which is recorded)
  * tertile boundaries come from the full held-out set
  * inside <= closing, asserted in ZoneModel.zones at label time

Usage: python 07-embed-zones.py --profile main --seed 0 [--temperature 1.0] [--n-mc 256]
"""
from __future__ import annotations

import argparse
import json
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).parent))
from ipl.terms import parse_formula, parse_term_full  # noqa: E402
from ipl.check import is_valid  # noqa: E402
from ipl.conditions import (  # noqa: E402
    assert_train_eta_long, conditions_name, novelty_key, tertile_boundaries, train_set_fingerprint,
    train_term_set,
)

HERE = Path(__file__).parent
D_REGISTERED = 16
D_SENSITIVITY = [8, 32]
ZONE_SEED = 20260928  # same as 04-feasibility.py
RULES = ("primary", "alternative")
MIN_COMPETENCE = 0.20
KCHECK_TERMS = 2000


def load_jsonl(p: Path):
    with p.open(encoding="utf-8") as fh:
        return [json.loads(line) for line in fh]


# ----------------------------------------------------------------------------
# halting checks on the conditions file (no model needed)


def check_conditions(cond: dict, train: list[dict], held: list[dict], crosscheck: dict | None) -> dict:
    if cond.get("mechanics_test"):
        raise AssertionError("refusing to zone a mechanics-test file; zones are for test prompts only")

    # K-check (spec kill table)
    if crosscheck is None:
        raise AssertionError("K-check not certified: out/crosscheck.json missing")
    n_terms = crosscheck.get("n_valid", 0) + crosscheck.get("n_invalid", 0)
    if not (crosscheck.get("agree_all") is True and n_terms == KCHECK_TERMS and not crosscheck.get("disagreements")):
        raise AssertionError(f"K-check not certified: agree_all={crosscheck.get('agree_all')} terms={n_terms}")

    # minimum competence (spec "Model")
    n_samples = sum(p["C1"]["n_samples"] for p in cond["prompts"])
    n_valid = sum(p["C1"]["n_valid"] for p in cond["prompts"])
    valid_rate = n_valid / n_samples if n_samples else 0.0
    if valid_rate < MIN_COMPETENCE:
        raise AssertionError(f"minimum competence not met: C1 valid rate {valid_rate:.3f} < {MIN_COMPETENCE}")

    # identical novelty reference
    train_terms = train_term_set(train)
    fp = train_set_fingerprint(train_terms)
    if fp != cond["train_terms"]["fingerprint_sha256"]:
        raise AssertionError("training-term fingerprint differs between corpus and conditions file")
    n_eta = assert_train_eta_long(train)

    # tertile boundaries from the full held-out set
    bounds = tertile_boundaries([it["term_size"] for it in held])
    tb = cond["tertile_bounds"]
    if not (tb["n_heldout_used"] == tb["n_heldout"] == len(held)
            and abs(tb["lo"] - bounds[0]) < 1e-12 and abs(tb["hi"] - bounds[1]) < 1e-12):
        raise AssertionError(f"tertile boundaries {tb} do not match the full held-out set {bounds} n={len(held)}")

    # exact draw budget
    budget = {"prompts": 0, "exhausted_root": 0, "total_draws": 0}
    for p in cond["prompts"]:
        c1_draws = sum(s["n_drawn"] for s in p["C1"]["samples"])
        if c1_draws != p["budget_draws"]:
            raise AssertionError(f"prompt {p['prompt_index']}: C1 draws {c1_draws} != recorded budget {p['budget_draws']}")
        if p["C3"]["exhausted_root"]:
            budget["exhausted_root"] += 1
            if p["C3"]["draws"] > p["budget_draws"]:
                raise AssertionError(f"prompt {p['prompt_index']}: C3 overspent after exhausting the space")
        elif p["C3"]["draws"] != p["budget_draws"]:
            raise AssertionError(f"prompt {p['prompt_index']}: C3 draws {p['C3']['draws']} != budget {p['budget_draws']}")
        budget["prompts"] += 1
        budget["total_draws"] += p["budget_draws"]

    return {
        "k_check": {"certified": True, "terms": n_terms, "crosscheck_ranAt": crosscheck.get("ranAt")},
        "minimum_competence": {"certified": True, "c1_valid_rate": valid_rate, "threshold": MIN_COMPETENCE,
                               "n_samples": n_samples, "n_valid": n_valid},
        "fingerprint_match": True, "train_eta_long_checked": n_eta,
        "tertiles_from_full_heldout": True, "budget": budget,
    }


def build_rows(cond: dict, held: list[dict], train_terms: frozenset) -> tuple[list[dict], list[tuple], dict]:
    """Rows and (formula, tokens) pairs to embed. Re-derives every novelty
    flag with the shared function and re-checks every validity flag."""
    rows, items = [], []
    novelty = {"checked": 0, "invalid_rechecked": 0, "heldout_novel": 0}

    def add(arm, prompt, formula, tokens, valid, novel_recorded, term_size, count=1, sample_index=None,
            sampled_length=None):
        goal, _ = parse_formula(formula)
        t = parse_term_full(tokens)
        if valid:
            if not is_valid(t, goal):
                raise AssertionError(f"{arm} prompt {prompt}: recorded valid output fails the checker")
            novel = novelty_key(t, goal) not in train_terms
            if novel_recorded is not None and novel != novel_recorded:
                raise AssertionError(f"{arm} prompt {prompt}: novelty flag differs from shared recomputation")
            novelty["checked"] += 1
        else:
            if is_valid(t, goal):
                raise AssertionError(f"{arm} prompt {prompt}: recorded invalid sample passes the checker")
            novelty["invalid_rechecked"] += 1
            novel = None
        rows.append({"arm": arm, "prompt": prompt, "valid": bool(valid), "novel": novel,
                     "term_size": term_size, "sampled_length": sampled_length, "count": count,
                     "sample_index": sample_index})
        items.append((formula, tokens))

    for j, it in enumerate(held):
        add("B", j, it["formula"], it["proof"], True, None, it["term_size"])
        novelty["heldout_novel"] += int(rows[-1]["novel"])
    for p in cond["prompts"]:
        f = p["formula"]
        for s in p["C1"]["samples"]:
            if s["parsed"]:
                add("C1", p["prompt_index"], f, s["tokens"], s["valid"], s["novel"],
                    s["term_size"] if s["valid"] else None, 1, s["sample_index"], len(s["tokens"]))
        for o in p["C2"]["outputs"]:
            add("C2", p["prompt_index"], f, o["key"], True, o["novel"], o["term_size"], o["count"])
        for o in p["C3"]["outputs"]:
            add("C3", p["prompt_index"], f, o["key"], True, o["novel"], o["term_size"], o["count"])
        for o in p["C4"]["outputs"]:
            add("C4", p["prompt_index"], f, o["key"], True, o["novel"], o["term_size"], 1)
    return rows, items, novelty


def run_record(cond: dict) -> dict:
    """Condition-run facts the spec lists as always reported, carried into
    the analysis chain (review item 12)."""
    P = cond["prompts"]
    caps = {}
    for p in P:
        for k, v in p["C4"]["enumeration"].get("caps_hit", {}).items():
            caps[k] = caps.get(k, 0) + int(bool(v))
    return {
        "n_prompts": len(P),
        "temperature": cond["settings"]["temperature"],
        "c3_mode": cond["settings"]["c3_mode"],
        "c3_restarts_on_cap": sum(p["C3"]["restarts_on_cap"] for p in P),
        "c3_exhausted_root": sum(int(p["C3"]["exhausted_root"]) for p in P),
        "c4_shortfall_by_tertile": [sum(p["C4"]["matching"]["shortfall"][b] for p in P) for b in range(3)],
        "c4_caps_hit_prompts": caps,
        "c1_samples": sum(p["C1"]["n_samples"] for p in P),
        "c1_parsed": sum(p["C1"]["n_parsed"] for p in P),
        "c1_valid": sum(p["C1"]["n_valid"] for p in P),
    }


# ----------------------------------------------------------------------------


def main() -> int:
    import torch
    from ipl.features import structural_features
    from ipl.model import GPT, GPTConfig, encode_pair, proof_embedding
    from ipl.zones import Reducer, ZoneModel

    ap = argparse.ArgumentParser()
    ap.add_argument("--profile", default="main")
    ap.add_argument("--seed", type=int, default=0)
    ap.add_argument("--temperature", type=float, default=1.0)
    ap.add_argument("--n-mc", type=int, default=256, help="Monte Carlo samples per ball (1024 for the rerun)")
    ap.add_argument("--device", default="cpu")
    ap.add_argument("--threads", type=int, default=1)
    ap.add_argument("--conditions", default=None, help="override the conditions file path")
    args = ap.parse_args()
    torch.set_num_threads(args.threads)
    t_start = time.time()

    stem = conditions_name(args.profile, args.seed, args.temperature)
    cond_path = Path(args.conditions) if args.conditions else HERE / "out" / f"{stem}.json"
    cond = json.loads(cond_path.read_text(encoding="utf-8"))
    if abs(cond["settings"]["temperature"] - args.temperature) > 1e-9:
        raise AssertionError("conditions file temperature differs from --temperature")

    data_dir = HERE / "data" / args.profile
    train = load_jsonl(data_dir / "train.jsonl")
    held = load_jsonl(data_dir / "heldout.jsonl")
    cc_path = HERE / "out" / "crosscheck.json"
    crosscheck = json.loads(cc_path.read_text(encoding="utf-8")) if cc_path.exists() else None

    checks = check_conditions(cond, train, held, crosscheck)
    train_terms = train_term_set(train)
    rows, items, novelty = build_rows(cond, held, train_terms)
    checks["novelty"] = novelty
    record = run_record(cond)

    # ---- embeddings
    ck = torch.load(HERE / "models" / args.profile / f"seed{args.seed}.pt", map_location=args.device)
    model = GPT(GPTConfig(**ck["config"])).to(args.device)
    model.load_state_dict(ck["state"])
    model.eval()

    def e1(pairs):
        out = []
        for formula, proof in pairs:
            fid = encode_pair(formula, None)
            pid = encode_pair([], proof)[1:-1]
            out.append(proof_embedding(model, fid, pid, args.device).cpu().numpy())
        return np.stack(out)

    def e2(pairs):
        out = []
        for formula, proof in pairs:
            goal, _ = parse_formula(formula)
            out.append(structural_features(parse_term_full(proof), goal))
        return np.stack(out)

    train_pairs = [(it["formula"], it["proof"]) for it in train]
    t0 = time.time()
    E = {"E1": (e1(train_pairs), e1(items)), "E2": (e2(train_pairs), e2(items))}
    embed_secs = time.time() - t0

    # ---- zones: same seeds and call order as 04-feasibility.py, calibrated on the full held-out rows
    is_B = np.array([r["arm"] == "B" for r in rows])
    labels, nn, radii, explained = {}, {}, {}, {}
    for name, (Xtr, Xout) in E.items():
        labels[name], nn[name], radii[name], explained[name] = {}, {}, {}, {}
        for d in [D_REGISTERED] + D_SENSITIVITY:
            red = Reducer(Xtr, d)
            Ztr, Zout = red.transform(Xtr), red.transform(Xout)
            zm = ZoneModel(Ztr, seed=ZONE_SEED + d, n_mc=args.n_mc)
            Zhe = Zout[is_B]
            zm.nn_dist(Zhe)
            zm.train_nn_dist_loo()
            r_primary = zm.calibrate_primary(Zhe, 0.5)
            r_alt = zm.calibrate_alternative(0.9)
            labels[name][str(d)], radii[name][str(d)] = {}, {}
            for rule, r in (("primary", r_primary), ("alternative", r_alt)):
                z = zm.zones(Zout, r)  # asserts inside <= closing
                labels[name][str(d)][rule] = z.astype(int).tolist()
                radii[name][str(d)][rule] = r
            nn[name][str(d)] = zm.nn_dist(Zout).tolist()
            explained[name][str(d)] = {"d_used": red.d, "explained_variance": red.explained}
            print(f"{name} d={red.d:2d} r_primary={r_primary:.3f} r_alt={r_alt:.3f}", flush=True)

    out = {
        "ranAt": datetime.now(timezone.utc).isoformat(), "profile": args.profile, "model_seed": args.seed,
        "temperature": args.temperature, "n_mc": args.n_mc,
        "conditions_file": str(cond_path.name), "conditions_ranAt": cond["ranAt"],
        "registered": {"d": D_REGISTERED, "d_sensitivity": D_SENSITIVITY, "n_mc": args.n_mc, "zone_seed": ZONE_SEED,
                       "rules": list(RULES), "calibration": "primary: 20-step bisection to 50% inside-or-crack on "
                       "held-out; alternative: 90th percentile of training LOO nn distance"},
        "tertile_bounds": cond["tertile_bounds"],
        "train_terms": {"n": len(train_terms), "fingerprint_sha256": cond["train_terms"]["fingerprint_sha256"]},
        "checks": checks, "run_record": record,
        "c1_counts": {"samples": record["c1_samples"], "parsed": record["c1_parsed"]},
        "n_rows": len(rows), "rows": rows,
        "labels": labels, "nn_dist": nn, "radii": radii, "reduction": explained,
        "seconds": {"embed": round(embed_secs, 1), "total": round(time.time() - t_start, 1)},
    }
    suffix = "" if args.n_mc == 256 else f"-mc{args.n_mc}"
    path = HERE / "out" / f"zones-{args.profile}-seed{args.seed}-T{args.temperature:g}{suffix}.json"
    path.write_text(json.dumps(out), encoding="utf-8")
    print(json.dumps({k: v for k, v in checks.items() if k != "novelty"}), "rows", len(rows))
    print("wrote", path)
    return 0


if __name__ == "__main__":
    sys.exit(main())
