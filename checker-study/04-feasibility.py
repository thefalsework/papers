"""Feasibility phase (SPEC.md, "Feasibility phase"), steps 3-6.

3. E1 (model) and E2 (structural) embeddings for training and held-out.
4. Calibrate r under both rules; held-out zone fractions.
5. K2 and K-agree.
6. Valid rate: unguided sampling, 16 per formula, 200 held-out formulas.

Also reports the Meehan et al. (2020) Z_U for held-out vs a random split
of training (a sanity reference; should be near zero by construction).

Usage: python 04-feasibility.py --profile feasibility --seed 0
Writes out/feasibility-seed<k>.json.
"""
from __future__ import annotations

import argparse
import json
import random
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

import numpy as np
import torch
from scipy.stats import mannwhitneyu

sys.path.insert(0, str(Path(__file__).parent))
from ipl.terms import parse_formula, parse_term_full, term_tokens  # noqa: E402
from ipl.check import is_valid, normal_form  # noqa: E402
from ipl.features import structural_features, FEATURE_NAMES  # noqa: E402
from ipl.model import GPT, GPTConfig, decode, encode_pair, proof_embedding, sample_proofs  # noqa: E402
from ipl.zones import (  # noqa: E402
    N_MC, Reducer, ZoneModel, ZONE_NAMES, cohen_kappa, zone_fractions,
)

HERE = Path(__file__).parent
D_REGISTERED = 16
D_SENSITIVITY = [8, 32]
K2_MIN_CRACK = 0.05
KAPPA_MIN = 0.2
VALID_RATE_MIN = 0.20
N_VALID_FORMULAS, N_VALID_SAMPLES, VALID_TEMPERATURE = 200, 16, 1.0
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
    ap.add_argument("--threads", type=int, default=2)
    ap.add_argument("--quick", action="store_true", help="debug run on a subsample; never for a verdict")
    args = ap.parse_args()
    torch.set_num_threads(args.threads)
    t_start = time.time()

    data_dir = HERE / "data" / args.profile
    train = parse_items(load_jsonl(data_dir / "train.jsonl"))
    held = parse_items(load_jsonl(data_dir / "heldout.jsonl"))
    n_valid_formulas = N_VALID_FORMULAS
    if args.quick:
        train, held, n_valid_formulas = train[:800], held[:200], 10
    ck = torch.load(HERE / "models" / args.profile / f"seed{args.seed}.pt", map_location=args.device)
    model = GPT(GPTConfig(**ck["config"])).to(args.device)
    model.load_state_dict(ck["state"])
    model.eval()
    train_terms = {tuple(it["proof"]) for _, _, it in train}

    # ---- embeddings
    def e1(items):
        rows = []
        for f, t, it in items:
            fid = encode_pair(it["formula"], None)
            pid = encode_pair([], it["proof"])[1:-1]  # strip leading SEP and EOS
            rows.append(proof_embedding(model, fid, pid, args.device).cpu().numpy())
        return np.stack(rows)

    def e2(items):
        return np.stack([structural_features(t, f) for f, t, _ in items])

    t0 = time.time()
    E = {"E1": (e1(train), e1(held)), "E2": (e2(train), e2(held))}
    embed_secs = time.time() - t0

    # ---- zones per embedding, per dimension, per rule
    results = {"embeddings": {}}
    for name, (Xtr, Xhe) in E.items():
        results["embeddings"][name] = {"raw_dim": int(Xtr.shape[1]), "by_dim": {}}
        for d in [D_REGISTERED] + D_SENSITIVITY:
            red = Reducer(Xtr, d)
            Ztr, Zhe = red.transform(Xtr), red.transform(Xhe)
            zm = ZoneModel(Ztr, seed=ZONE_SEED + d)
            d_held = zm.nn_dist(Zhe)
            d_train_loo = zm.train_nn_dist_loo()
            r_primary = zm.calibrate_primary(Zhe, 0.5)
            r_alt = zm.calibrate_alternative(0.9)
            per_rule = {}
            for rule, r in (("primary", r_primary), ("alternative", r_alt)):
                z = zm.zones(Zhe, r)
                per_rule[rule] = {
                    "r": r, "heldout_zones": zone_fractions(z), "zone_labels": z.tolist(),
                }
            results["embeddings"][name]["by_dim"][str(d)] = {
                "d_used": red.d, "explained_variance": red.explained,
                "heldout_nn_dist": _quant(d_held), "train_nn_dist_loo": _quant(d_train_loo),
                "rules": per_rule,
            }
            print(f"{name} d={red.d:2d}  r_primary={r_primary:.3f} r_alt={r_alt:.3f}  "
                  f"held zones primary={_fmt(per_rule['primary']['heldout_zones'])}  "
                  f"alt={_fmt(per_rule['alternative']['heldout_zones'])}")

    # ---- K2 and K-agree at the registered dimension
    k2_fired_embeddings = []
    for name in E:
        rules = results["embeddings"][name]["by_dim"][str(D_REGISTERED)]["rules"]
        thin = [rule for rule in ("primary", "alternative")
                if rules[rule]["heldout_zones"]["crack"] < K2_MIN_CRACK]
        results["embeddings"][name]["k2_thin_rules"] = thin
        if len(thin) == 2:
            k2_fired_embeddings.append(name)
    kappa = {}
    for rule in ("primary", "alternative"):
        za = np.array(results["embeddings"]["E1"]["by_dim"][str(D_REGISTERED)]["rules"][rule]["zone_labels"])
        zb = np.array(results["embeddings"]["E2"]["by_dim"][str(D_REGISTERED)]["rules"][rule]["zone_labels"])
        kappa[rule] = cohen_kappa(za, zb)
        # joint exterior on held-out (used by H1's B term)
        results.setdefault("heldout_joint_exterior", {})[rule] = float(((za == 2) & (zb == 2)).mean())
    # strip bulky labels from the JSON
    for name in E:
        for d in results["embeddings"][name]["by_dim"].values():
            for rule in d["rules"].values():
                rule.pop("zone_labels")

    # ---- Meehan Z_U reference: held-out vs a random half of training
    zu = {}
    for name, (Xtr, Xhe) in E.items():
        red = Reducer(Xtr, D_REGISTERED)
        Ztr, Zhe = red.transform(Xtr), red.transform(Xhe)
        rng = np.random.default_rng(ZONE_SEED)
        perm = rng.permutation(len(Ztr))
        ref, rest = Ztr[perm[: len(Ztr) // 2]], Ztr[perm[len(Ztr) // 2:]]
        zm = ZoneModel(ref, seed=ZONE_SEED)
        d_rest, d_held = zm.nn_dist(rest), zm.nn_dist(Zhe)
        u = mannwhitneyu(d_held, d_rest, alternative="two-sided")
        n1, n2 = len(d_held), len(d_rest)
        zu[name] = float((u.statistic - n1 * n2 / 2) / np.sqrt(n1 * n2 * (n1 + n2 + 1) / 12))

    # ---- valid rate (step 6)
    rs = random.Random(ZONE_SEED + args.seed)
    gen = torch.Generator(device=args.device).manual_seed(ZONE_SEED + args.seed)
    formulas = rs.sample(held, n_valid_formulas)
    n_tot = n_parse = n_valid = n_novel = 0
    n_per_formula_solved = 0
    t0 = time.time()
    for f, _, it in formulas:
        fid = encode_pair(it["formula"], None)
        samples = sample_proofs(model, fid, N_VALID_SAMPLES, VALID_TEMPERATURE,
                                max_new=model.c.block_size - len(fid) - 1, device=args.device,
                                generator=gen)
        solved = False
        for ids in samples:
            n_tot += 1
            toks = decode(ids)
            try:
                t = parse_term_full(toks)
            except ValueError:
                continue
            n_parse += 1
            if is_valid(t, f):
                n_valid += 1
                solved = True
                if tuple(term_tokens(normal_form(t, f))) not in train_terms:
                    n_novel += 1
        n_per_formula_solved += solved
    sample_secs = time.time() - t0
    valid_rate = n_valid / n_tot

    verdict = {
        "K2_fired": bool(k2_fired_embeddings),
        "K2_embeddings": k2_fired_embeddings,
        "K_agree_fired_primary": bool(kappa["primary"] < KAPPA_MIN),
        "kappa": kappa,
        "valid_rate": valid_rate,
        "valid_rate_below_min": bool(valid_rate < VALID_RATE_MIN),
    }
    if verdict["K2_fired"]:
        verdict["go_no_go"] = "NO-GO: K2 fired (zones unmeasurable)"
    elif verdict["K_agree_fired_primary"]:
        verdict["go_no_go"] = "GO (descriptive only): K-agree fired, no H1 claim possible"
    elif verdict["valid_rate_below_min"]:
        verdict["go_no_go"] = "GO after scaling: zones measurable, model below 20% valid rate"
    else:
        verdict["go_no_go"] = "GO"

    results.update({
        "ranAt": datetime.now(timezone.utc).isoformat(), "profile": args.profile,
        "model_seed": args.seed, "model_val_loss": ck["val_loss"], "model_epoch": ck["epoch"],
        "n_train": len(train), "n_heldout": len(held),
        "registered": {"d": D_REGISTERED, "d_sensitivity": D_SENSITIVITY, "n_mc": N_MC,
                       "k2_min_crack": K2_MIN_CRACK, "kappa_min": KAPPA_MIN,
                       "valid_rate_min": VALID_RATE_MIN, "zone_seed": ZONE_SEED,
                       "valid_check": {"formulas": N_VALID_FORMULAS, "samples": N_VALID_SAMPLES,
                                       "temperature": VALID_TEMPERATURE}},
        "e2_feature_names": FEATURE_NAMES,
        "meehan_ZU_heldout_vs_train_half": zu,
        "valid_check": {"samples": n_tot, "parsed": n_parse, "valid": n_valid,
                        "valid_novel": n_novel, "formulas_with_a_valid_sample": n_per_formula_solved,
                        "valid_rate": valid_rate, "parse_rate": n_parse / n_tot},
        "verdict": verdict,
        "seconds": {"embed": round(embed_secs, 1), "sample": round(sample_secs, 1),
                    "total": round(time.time() - t_start, 1)},
    })
    results["quick_debug_run"] = args.quick
    out = HERE / "out" / (f"feasibility-seed{args.seed}.json" if not args.quick else "feasibility-QUICK-DEBUG.json")
    out.write_text(json.dumps(results, indent=2), encoding="utf-8")
    print(json.dumps(verdict, indent=2))
    print("joint exterior held-out:", results["heldout_joint_exterior"])
    print("Z_U:", zu)
    print("wrote", out)
    return 0


def _quant(x: np.ndarray) -> dict:
    return {q: float(np.quantile(x, float(q))) for q in ("0.1", "0.5", "0.9", "0.99")}


def _fmt(zf: dict) -> str:
    return "/".join(f"{zf[k]:.2f}" for k in ZONE_NAMES)


if __name__ == "__main__":
    sys.exit(main())
