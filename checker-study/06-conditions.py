"""Run the four conditions (SPEC.md, "Conditions") on a set of prompts and
record raw outputs. No zones, no hypothesis statistics: those are computed
downstream by 07-embed-zones.py and 08-analysis.py from this file.

Prompt sources:
  --prompts test   the profile's registered test prompts (data/<profile>/test.jsonl)
  --prompts fresh  N freshly generated provable formulas whose canonical form
                   is in none of the profile's sets (mechanics test only; the
                   output is marked mechanics_test and is never analysed)

Usage: python 06-conditions.py --profile feasibility --seed 0 --prompts fresh --n-prompts 20
Writes out/conditions-<profile>-seed<k>-T<temperature>[-mechanics-<mode>].json
(the two committed mechanics files predate the temperature suffix).
"""
from __future__ import annotations

import argparse
import json
import random
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

import torch

sys.path.insert(0, str(Path(__file__).parent))
from ipl.terms import (  # noqa: E402
    canonical_formula, formula_size, formula_tokens, parse_formula, parse_term_full, term_depth,
)
from ipl.check import is_valid  # noqa: E402
from ipl.gen import DEPTH_MAX, random_formula, random_proof  # noqa: E402
from ipl.model import GPT, GPTConfig, encode_pair  # noqa: E402
from ipl.conditions import (  # noqa: E402
    C4_MAX_COUNT, C4_SIZE_CAP, c4_size_cap, classify, conditions_name, enumerate_proofs, guided_search,
    match_by_tertile, prompt_seed, sample_counted, tertile_boundaries, train_set_fingerprint, train_term_set,
)

HERE = Path(__file__).parent
N_SAMPLES = 64
TEMPERATURE = 1.0
SEED_BASE = 20260929


def load_jsonl(p: Path):
    if not p.exists():
        return []
    with p.open(encoding="utf-8") as fh:
        return [json.loads(line) for line in fh]


def fresh_prompts(n: int, exclude: set, seed: int) -> list[dict]:
    rng = random.Random(seed)
    out, seen, tried = [], set(), 0
    while len(out) < n:
        f = random_formula(rng)
        tried += 1
        if random_proof(f, rng) is None:
            continue
        cf = canonical_formula(f)
        key = tuple(formula_tokens(cf))
        if key in exclude or key in seen:
            continue
        seen.add(key)
        out.append({"formula": list(key), "formula_size": formula_size(cf)})
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--profile", default="feasibility")
    ap.add_argument("--seed", type=int, default=0, help="model seed")
    ap.add_argument("--prompts", choices=["test", "fresh"], default="test")
    ap.add_argument("--n-prompts", type=int, default=20, help="fresh mode only")
    ap.add_argument("--prompt-seed", type=int, default=SEED_BASE + 777, help="fresh mode only")
    ap.add_argument("--n-samples", type=int, default=N_SAMPLES)
    ap.add_argument("--temperature", type=float, default=TEMPERATURE)
    ap.add_argument("--c3-mode", choices=["mask", "prune"], default="mask",
                    help="mask: checker filters the vocabulary before each draw; prune: draw then refute")
    ap.add_argument("--device", default="cpu")
    ap.add_argument("--threads", type=int, default=1)
    args = ap.parse_args()
    torch.set_num_threads(args.threads)
    t_start = time.time()
    mechanics = args.prompts == "fresh"

    data_dir = HERE / "data" / args.profile
    train = load_jsonl(data_dir / "train.jsonl")
    held = load_jsonl(data_dir / "heldout.jsonl")
    test = load_jsonl(data_dir / "test.jsonl")
    train_terms = train_term_set(train)
    fingerprint = train_set_fingerprint(train_terms)

    # tertile boundaries: fixed once on the FULL held-out set
    held_sizes = [it["term_size"] for it in held]
    assert len(held_sizes) == len(held), "tertiles must use every held-out proof"
    bounds = tertile_boundaries(held_sizes)

    if mechanics:
        exclude = {tuple(it["formula"]) for it in train + held + test}
        prompts = fresh_prompts(args.n_prompts, exclude, args.prompt_seed)
    else:
        prompts = test
        assert prompts, "no test prompts for this profile"

    ck = torch.load(HERE / "models" / args.profile / f"seed{args.seed}.pt", map_location=args.device)
    model = GPT(GPTConfig(**ck["config"])).to(args.device)
    model.load_state_dict(ck["state"])
    model.eval()
    block = model.c.block_size

    records = []
    totals = {"budget": 0, "c3_draws": 0, "c1_valid": 0, "c1_novel": 0, "c2_unique": 0,
              "c3_completions": 0, "c3_unique": 0, "c3_novel_unique": 0, "c4_outputs": 0,
              "c4_shortfall": 0, "budget_mismatch": 0, "c3_exhausted_root": 0}
    for i, p in enumerate(prompts):
        goal, _ = parse_formula(p["formula"])
        fid = encode_pair(p["formula"], None)
        max_new = block - len(fid) - 1
        t0 = time.time()

        # ---- C1 (sample j is seeded by (formula, 'C1', j); batch layout is irrelevant)
        samples = [classify(s, goal, train_terms)
                   for s in sample_counted(model, p["formula"], fid, list(range(args.n_samples)),
                                           args.temperature, max_new, args.device)]
        assert len(samples) == args.n_samples
        budget = sum(s.n_drawn for s in samples)

        # ---- C2: unique valid outputs of C1
        c2: dict[tuple, dict] = {}
        for s in samples:
            if s.valid:
                e = c2.setdefault(s.key, {"key": list(s.key), "novel": s.novel, "term_size": s.term_size, "count": 0})
                e["count"] += 1
        c1_valid_deeper_than_bound = 0
        for e in c2.values():
            t = parse_term_full(e["key"])
            assert is_valid(t, goal), "C2 output failed re-check"
            assert e["novel"] == (tuple(e["key"]) not in train_terms), "C2 novelty inconsistent"
            c1_valid_deeper_than_bound += int(term_depth(t) > DEPTH_MAX)

        # ---- C3 (seeded by (formula, 'C3'))
        comps, st = guided_search(model, goal, p["formula"], fid, budget, args.temperature, max_new,
                                  args.device, train_terms, mode=args.c3_mode)
        if not st.exhausted_root:
            assert st.draws == budget, f"C3 spent {st.draws} draws, budget {budget}"
        else:
            totals["c3_exhausted_root"] += 1
        c3: dict[tuple, dict] = {}
        for c in comps:
            t = parse_term_full(list(c.key))
            assert is_valid(t, goal), "C3 completion failed re-check"
            assert c.novel == (c.key not in train_terms), "C3 novelty inconsistent"
            e = c3.setdefault(c.key, {"key": list(c.key), "novel": c.novel, "term_size": c.term_size,
                                      "count": 0, "first_found_at_draw": c.found_at_draw})
            e["count"] += 1

        # ---- C4
        c2_sizes = [e["term_size"] for e in c2.values()]
        max_size = c4_size_cap(c2_sizes)  # postscript "Resolutions", item E
        pool, enum_rec = enumerate_proofs(goal, max_size=max_size, max_count=C4_MAX_COUNT)
        for k, _ in pool:
            assert is_valid(parse_term_full(list(k)), goal), "C4 proof failed re-check"
        rng4 = random.Random(prompt_seed(p["formula"], "C4"))
        chosen, match_rec = match_by_tertile(pool, c2_sizes, bounds, rng4)
        c4 = [{"key": list(k), "novel": k not in train_terms, "term_size": s} for k, s in chosen]

        rec = {
            "prompt_index": i, "formula": p["formula"], "formula_size": p["formula_size"],
            "max_new": max_new, "budget_draws": budget,
            "C1": {
                "n_samples": args.n_samples, "temperature": args.temperature,
                "samples": [{"sample_index": s.sample_index, "tokens": s.tokens, "n_drawn": s.n_drawn,
                             "terminated": s.terminated,
                             "parsed": s.parsed, "valid": s.valid, "novel": s.novel,
                             "key": list(s.key) if s.key else None, "term_size": s.term_size}
                            for s in samples],
                "n_parsed": sum(s.parsed for s in samples), "n_valid": sum(s.valid for s in samples),
                "n_valid_novel": sum(bool(s.valid and s.novel) for s in samples),
            },
            "C2": {"outputs": list(c2.values()), "n_unique": len(c2),
                   "n_unique_novel": sum(e["novel"] for e in c2.values()),
                   "n_unique_deeper_than_depth_max": c1_valid_deeper_than_bound},
            "C3": {"mode": args.c3_mode, "depth_max": DEPTH_MAX,
                   "draws": st.draws, "accepted": st.accepted, "pruned": st.pruned,
                   "backtracks": st.backtracks, "restarts": st.restarts,
                   "restarts_on_cap": st.restarts_on_cap, "attempt_cap_draws": max_new,
                   "exhausted_root": st.exhausted_root, "n_completions": len(comps),
                   "outputs": list(c3.values()), "n_unique": len(c3),
                   "n_unique_novel": sum(e["novel"] for e in c3.values())},
            "C4": {"enumeration": enum_rec, "pool_size": len(pool), "matching": match_rec,
                   "outputs": c4, "n_outputs": len(c4), "n_novel": sum(e["novel"] for e in c4)},
            "seconds": round(time.time() - t0, 1),
        }
        records.append(rec)
        totals["budget"] += budget
        totals["c3_draws"] += st.draws
        totals["c1_valid"] += rec["C1"]["n_valid"]
        totals["c1_novel"] += rec["C1"]["n_valid_novel"]
        totals["c2_unique"] += len(c2)
        totals["c3_completions"] += len(comps)
        totals["c3_unique"] += len(c3)
        totals["c3_novel_unique"] += rec["C3"]["n_unique_novel"]
        totals["c4_outputs"] += len(c4)
        totals["c4_shortfall"] += sum(match_rec["shortfall"])
        totals["budget_mismatch"] += int(st.draws != budget)
        print(f"[{i:3d}] size={p['formula_size']:2d} budget={budget:5d} C1 valid={rec['C1']['n_valid']:2d} "
              f"novel={rec['C1']['n_valid_novel']:2d} | C2 uniq={len(c2):2d} | C3 draws={st.draws:5d} "
              f"comp={len(comps):3d} uniq={len(c3):3d} novel={rec['C3']['n_unique_novel']:3d} "
              f"pruned={st.pruned:4d} bt={st.backtracks:3d} cap={st.restarts_on_cap:2d} | C4 pool={len(pool):3d} got={len(c4):2d} "
              f"short={sum(match_rec['shortfall'])} | {rec['seconds']}s", flush=True)

    out = {
        "ranAt": datetime.now(timezone.utc).isoformat(), "profile": args.profile, "model_seed": args.seed,
        "mechanics_test": mechanics, "prompt_source": args.prompts,
        "prompt_seed": args.prompt_seed if mechanics else None,
        "model": {"config": ck["config"], "val_loss": ck["val_loss"], "epoch": ck["epoch"]},
        "settings": {"n_samples": args.n_samples, "temperature": args.temperature,
                     "c3_mode": args.c3_mode, "c3_depth_max": DEPTH_MAX,
                     "seeding": "sha256(formula|arm|k): C1 per sample k, C3 and C4 per prompt; "
                                "uniforms from a CPU generator, inverse-CDF sampling",
                     "c4_max_count": C4_MAX_COUNT, "c4_size_cap": C4_SIZE_CAP},
        "tertile_bounds": {"lo": bounds[0], "hi": bounds[1], "n_heldout_used": len(held_sizes),
                           "n_heldout": len(held)},
        "train_terms": {"n": len(train_terms), "fingerprint_sha256": fingerprint},
        "n_prompts": len(prompts), "totals": totals,
        "prompts": records,
        "seconds": round(time.time() - t_start, 1),
    }
    name = conditions_name(args.profile, args.seed, args.temperature) + (f"-mechanics-{args.c3_mode}" if mechanics else "")
    path = HERE / "out" / f"{name}.json"
    path.write_text(json.dumps(out, indent=1), encoding="utf-8")
    print(json.dumps(totals, indent=2))
    print("wrote", path)
    return 0


if __name__ == "__main__":
    sys.exit(main())
