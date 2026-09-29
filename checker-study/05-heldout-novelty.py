"""Held-out novelty descriptive (SPEC.md postscript 2026-09-29).

The corpus is split by canonical formula, not by proof term, so a held-out
proof can be identical as a term to a training proof. H1's base rate B is
restricted to held-out proofs that are novel as terms (spec definition:
eta-long alpha-normalised term not identical to any training term).

This script recomputes the d = 16 zone labels for held-out proofs with the
same seeds and the same call order as 04-feasibility.py, checks that the
all-held-out fractions and radii match out/feasibility-seed<k>.json, then
reports zone fractions and the joint exterior over novel-only (and, as a
secondary descriptive, reused-only and all) held-out proofs. Calibration is
unchanged: both radius rules are fitted on the full held-out set.

Usage: python 05-heldout-novelty.py --profile feasibility --seed 0 --threads 1
Writes out/heldout-novelty-seed<k>.json.
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
from ipl.terms import parse_formula, parse_term_full, term_tokens  # noqa: E402
from ipl.check import normal_form  # noqa: E402
from ipl.features import structural_features  # noqa: E402
from ipl.model import GPT, GPTConfig, encode_pair, proof_embedding  # noqa: E402
from ipl.zones import EXTERIOR, Reducer, ZoneModel, cohen_kappa, zone_fractions  # noqa: E402

HERE = Path(__file__).parent
D_REGISTERED = 16
ZONE_SEED = 20260928


def load_jsonl(p: Path):
    with p.open(encoding="utf-8") as fh:
        return [json.loads(line) for line in fh]


def parse_items(items):
    out = []
    for it in items:
        f, _ = parse_formula(it["formula"])
        t = parse_term_full(it["proof"])
        out.append((f, t, it))
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--profile", default="feasibility")
    ap.add_argument("--seed", type=int, default=0)
    ap.add_argument("--device", default="cpu")
    ap.add_argument("--threads", type=int, default=1)
    args = ap.parse_args()
    torch.set_num_threads(args.threads)
    t_start = time.time()

    data_dir = HERE / "data" / args.profile
    train = parse_items(load_jsonl(data_dir / "train.jsonl"))
    held = parse_items(load_jsonl(data_dir / "heldout.jsonl"))
    feas = json.loads((HERE / "out" / f"feasibility-seed{args.seed}.json").read_text(encoding="utf-8"))

    # ---- novelty of held-out proofs as terms (spec definition)
    train_terms = {tuple(it["proof"]) for _, _, it in train}
    novel = np.array([tuple(term_tokens(normal_form(t, f))) not in train_terms for f, t, _ in held])
    stored_matches_normal = all(term_tokens(normal_form(t, f)) == it["proof"] for f, t, it in held)

    # ---- embeddings (same as 04-feasibility.py)
    ck = torch.load(HERE / "models" / args.profile / f"seed{args.seed}.pt", map_location=args.device)
    model = GPT(GPTConfig(**ck["config"])).to(args.device)
    model.load_state_dict(ck["state"])
    model.eval()

    def e1(items):
        rows = []
        for f, t, it in items:
            fid = encode_pair(it["formula"], None)
            pid = encode_pair([], it["proof"])[1:-1]
            rows.append(proof_embedding(model, fid, pid, args.device).cpu().numpy())
        return np.stack(rows)

    def e2(items):
        return np.stack([structural_features(t, f) for f, t, _ in items])

    E = {"E1": (e1(train), e1(held)), "E2": (e2(train), e2(held))}

    # ---- zones at d = 16, same seed and same call order as 04-feasibility.py
    labels = {}
    radii = {}
    mismatches = []
    for name, (Xtr, Xhe) in E.items():
        red = Reducer(Xtr, D_REGISTERED)
        Ztr, Zhe = red.transform(Xtr), red.transform(Xhe)
        zm = ZoneModel(Ztr, seed=ZONE_SEED + D_REGISTERED)
        zm.nn_dist(Zhe)
        zm.train_nn_dist_loo()
        r_primary = zm.calibrate_primary(Zhe, 0.5)
        r_alt = zm.calibrate_alternative(0.9)
        labels[name], radii[name] = {}, {}
        ref = feas["embeddings"][name]["by_dim"][str(D_REGISTERED)]["rules"]
        for rule, r in (("primary", r_primary), ("alternative", r_alt)):
            z = zm.zones(Zhe, r)
            labels[name][rule], radii[name][rule] = z, r
            if abs(r - ref[rule]["r"]) > 1e-9 or zone_fractions(z) != ref[rule]["heldout_zones"]:
                mismatches.append({"embedding": name, "rule": rule, "r": r, "r_ref": ref[rule]["r"],
                                   "zones": zone_fractions(z), "zones_ref": ref[rule]["heldout_zones"]})

    if mismatches:
        print("REPRODUCTION MISMATCH against feasibility JSON; not reporting", file=sys.stderr)
        print(json.dumps(mismatches, indent=2), file=sys.stderr)
        return 1

    subsets = {"novel": novel, "reused": ~novel, "all": np.ones(len(held), dtype=bool)}
    per_subset = {}
    for sname, mask in subsets.items():
        entry = {"n": int(mask.sum()), "zones": {}, "joint_exterior": {}, "kappa": {}}
        for rule in ("primary", "alternative"):
            za, zb = labels["E1"][rule][mask], labels["E2"][rule][mask]
            entry["zones"][rule] = {"E1": zone_fractions(za), "E2": zone_fractions(zb)}
            entry["joint_exterior"][rule] = float(((za == EXTERIOR) & (zb == EXTERIOR)).mean())
            entry["kappa"][rule] = cohen_kappa(za, zb)
        per_subset[sname] = entry

    vc = feas["valid_check"]
    results = {
        "ranAt": datetime.now(timezone.utc).isoformat(), "profile": args.profile, "model_seed": args.seed,
        "feasibility_results_file": f"out/feasibility-seed{args.seed}.json",
        "reproduced_feasibility_zones": True,
        "d": D_REGISTERED, "zone_seed": ZONE_SEED, "radii": radii,
        "counts": {
            "train_pairs": len(train), "train_distinct_terms": len(train_terms),
            "heldout_pairs": len(held), "heldout_distinct_terms": len({tuple(it["proof"]) for _, _, it in held}),
            "heldout_novel": int(novel.sum()), "heldout_reused": int((~novel).sum()),
            "heldout_novel_rate": float(novel.mean()),
            "stored_proofs_already_normal_form": bool(stored_matches_normal),
        },
        "heldout_by_subset": per_subset,
        "novelty_rate_comparison": {
            "heldout_proofs_novel_rate": float(novel.mean()),
            "model_valid_samples_novel_rate": vc["valid_novel"] / vc["valid"],
            "model_valid_novel": vc["valid_novel"], "model_valid": vc["valid"],
        },
        "seconds": round(time.time() - t_start, 1),
    }
    out = HERE / "out" / f"heldout-novelty-seed{args.seed}.json"
    out.write_text(json.dumps(results, indent=2), encoding="utf-8")
    print(json.dumps({"counts": results["counts"],
                      "joint_exterior": {s: per_subset[s]["joint_exterior"] for s in per_subset},
                      "kappa_novel": per_subset["novel"]["kappa"]}, indent=2))
    print("wrote", out)
    return 0


if __name__ == "__main__":
    sys.exit(main())
