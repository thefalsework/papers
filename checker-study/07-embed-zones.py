"""Embed and zone every output of the four conditions plus the base rate.

Input: out/conditions-<profile>-seed<k>.json (from 06-conditions.py, test
prompts). Output: out/zones-<profile>-seed<k>.json with one row per output
and zone labels / nearest-training distances per embedding, PCA dimension
and calibration rule. 08-analysis.py consumes the output; this script
computes no hypothesis statistic.

Rows:
  B    every held-out proof (unit: held-out formula); 'novel' marks the
       term-novel subset that is H1's base rate (postscript 2026-09-29)
  C1   every raw C1 sample that parses (valid or not), one row per sample
       (H3's population); unique valid novel outputs are the C2 rows
  C2   unique valid outputs of C1 per prompt
  C3   unique valid completions of guided search per prompt
  C4   size-matched enumerated proofs per prompt

Halting assertions (spec postscripts 2026-09-29):
  * exact draw budget: C3 draws == C1 draws per prompt (unless the search
    exhausted the space, which is recorded), and C1 draws sum as recorded
  * identical novelty: the training-term fingerprint matches the corpus,
    and every arm's novelty flag is re-derived with conditions.novelty_key
  * tertile boundaries come from the full held-out set
  * inside <= closing, asserted in ZoneModel.zones

Usage: python 07-embed-zones.py --profile main --seed 0 [--threads 1]
"""
from __future__ import annotations

import argparse
import json
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

import numpy as np
import torch

sys.path.insert(0, str(Path(__file__).parent))
from ipl.terms import parse_formula, parse_term_full  # noqa: E402
from ipl.check import is_valid  # noqa: E402
from ipl.features import structural_features  # noqa: E402
from ipl.model import GPT, GPTConfig, encode_pair, proof_embedding  # noqa: E402
from ipl.zones import N_MC, Reducer, ZoneModel  # noqa: E402
from ipl.conditions import (  # noqa: E402
    novelty_key, tertile_boundaries, train_set_fingerprint, train_term_set,
)

HERE = Path(__file__).parent
D_REGISTERED = 16
D_SENSITIVITY = [8, 32]
ZONE_SEED = 20260928  # same as 04-feasibility.py
RULES = ("primary", "alternative")


def load_jsonl(p: Path):
    with p.open(encoding="utf-8") as fh:
        return [json.loads(line) for line in fh]


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--profile", default="main")
    ap.add_argument("--seed", type=int, default=0)
    ap.add_argument("--device", default="cpu")
    ap.add_argument("--threads", type=int, default=1)
    ap.add_argument("--conditions", default=None, help="override the conditions file path")
    args = ap.parse_args()
    torch.set_num_threads(args.threads)
    t_start = time.time()

    cond_path = Path(args.conditions) if args.conditions else HERE / "out" / f"conditions-{args.profile}-seed{args.seed}.json"
    cond = json.loads(cond_path.read_text(encoding="utf-8"))
    if cond.get("mechanics_test"):
        raise AssertionError("refusing to zone a mechanics-test file; zones are for test prompts only")

    data_dir = HERE / "data" / args.profile
    train = load_jsonl(data_dir / "train.jsonl")
    held = load_jsonl(data_dir / "heldout.jsonl")
    train_terms = train_term_set(train)

    # ---- assertion: identical novelty reference
    fp = train_set_fingerprint(train_terms)
    if fp != cond["train_terms"]["fingerprint_sha256"]:
        raise AssertionError("training-term fingerprint differs between corpus and conditions file")

    # ---- assertion: tertile boundaries from the full held-out set
    bounds = tertile_boundaries([it["term_size"] for it in held])
    tb = cond["tertile_bounds"]
    if not (tb["n_heldout_used"] == tb["n_heldout"] == len(held)
            and abs(tb["lo"] - bounds[0]) < 1e-12 and abs(tb["hi"] - bounds[1]) < 1e-12):
        raise AssertionError(f"tertile boundaries {tb} do not match the full held-out set {bounds} n={len(held)}")

    # ---- assertion: exact draw budget
    budget_check = {"prompts": 0, "exhausted_root": 0}
    for p in cond["prompts"]:
        c1_draws = sum(s["n_drawn"] for s in p["C1"]["samples"])
        if c1_draws != p["budget_draws"]:
            raise AssertionError(f"prompt {p['prompt_index']}: C1 draws {c1_draws} != recorded budget {p['budget_draws']}")
        if p["C3"]["exhausted_root"]:
            budget_check["exhausted_root"] += 1
            if p["C3"]["draws"] > p["budget_draws"]:
                raise AssertionError(f"prompt {p['prompt_index']}: C3 overspent after exhausting the space")
        elif p["C3"]["draws"] != p["budget_draws"]:
            raise AssertionError(f"prompt {p['prompt_index']}: C3 draws {p['C3']['draws']} != budget {p['budget_draws']}")
        budget_check["prompts"] += 1

    # ---- rows, with novelty re-derived by the shared function for every arm
    rows, items = [], []  # items: (formula_tokens, proof_tokens) for embedding
    novelty_check = {"checked": 0}

    def add(arm, prompt, formula, proof_tokens, valid, novel_recorded, term_size, count=1, sample_index=None):
        goal, _ = parse_formula(formula)
        t = parse_term_full(proof_tokens)
        if valid:
            if not is_valid(t, goal):
                raise AssertionError(f"{arm} prompt {prompt}: recorded valid output fails the checker")
            k = novelty_key(t, goal)
            novel = k not in train_terms
            if novel_recorded is not None and novel != novel_recorded:
                raise AssertionError(f"{arm} prompt {prompt}: novelty flag differs from shared recomputation")
            novelty_check["checked"] += 1
        else:
            novel = None
        rows.append({"arm": arm, "prompt": prompt, "valid": bool(valid), "novel": novel,
                     "term_size": term_size, "count": count, "sample_index": sample_index})
        items.append((formula, proof_tokens))

    for j, it in enumerate(held):
        add("B", j, it["formula"], it["proof"], True, None, it["term_size"])
    for p in cond["prompts"]:
        f = p["formula"]
        for s in p["C1"]["samples"]:
            if s["parsed"]:
                # valid samples are embedded in eta-long normal form like every other arm;
                # invalid ones have no normal form and are embedded as sampled
                toks = s["key"] if s["valid"] else s["tokens"]
                ts = s["term_size"] if s["valid"] else len(s["tokens"])
                add("C1", p["prompt_index"], f, toks, s["valid"], s["novel"], ts, 1, s["sample_index"])
        for o in p["C2"]["outputs"]:
            add("C2", p["prompt_index"], f, o["key"], True, o["novel"], o["term_size"], o["count"])
        for o in p["C3"]["outputs"]:
            add("C3", p["prompt_index"], f, o["key"], True, o["novel"], o["term_size"], o["count"])
        for o in p["C4"]["outputs"]:
            add("C4", p["prompt_index"], f, o["key"], True, o["novel"], o["term_size"], 1)

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
            zm = ZoneModel(Ztr, seed=ZONE_SEED + d)
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
        "conditions_file": str(cond_path.name), "conditions_ranAt": cond["ranAt"],
        "registered": {"d": D_REGISTERED, "d_sensitivity": D_SENSITIVITY, "n_mc": N_MC, "zone_seed": ZONE_SEED,
                       "rules": list(RULES)},
        "tertile_bounds": tb,
        "train_terms": {"n": len(train_terms), "fingerprint_sha256": fp},
        "checks": {"budget": budget_check, "novelty": novelty_check, "fingerprint_match": True,
                   "tertiles_from_full_heldout": True},
        "c1_counts": {"samples": sum(p["C1"]["n_samples"] for p in cond["prompts"]),
                      "parsed": sum(p["C1"]["n_parsed"] for p in cond["prompts"])},
        "n_rows": len(rows), "rows": rows,
        "labels": labels, "nn_dist": nn, "radii": radii, "reduction": explained,
        "seconds": {"embed": round(embed_secs, 1), "total": round(time.time() - t_start, 1)},
    }
    path = HERE / "out" / f"zones-{args.profile}-seed{args.seed}.json"
    path.write_text(json.dumps(out), encoding="utf-8")
    print(json.dumps(out["checks"]), "rows", len(rows))
    print("wrote", path)
    return 0


if __name__ == "__main__":
    sys.exit(main())
