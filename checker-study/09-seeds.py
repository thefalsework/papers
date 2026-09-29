"""Three-seed aggregation (SPEC.md "Model": every main result is reported
per seed; a claim requires the same direction in all three).

Input: out/analysis-<profile>-seed{0,1,2}-T<temp>.json. Output:
out/seeds-<profile>-T<temp>.json with, per registered quantity, the
per-seed values, whether the direction is the same in every seed, and
whether the per-seed verdicts agree. Nothing here changes a verdict; the
per-seed files remain the results of record.

Usage: python 09-seeds.py --profile main --seeds 0 1 2 [--temperature 1.0]
"""
from __future__ import annotations

import argparse
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).parent


def sign(x) -> int | None:
    if x is None:
        return None
    return (x > 0) - (x < 0)


def same_direction(values: list) -> bool | None:
    s = [sign(v) for v in values]
    if any(v is None for v in s):
        return None
    return bool(len(set(s)) == 1 and s[0] != 0)


def aggregate(results: list[dict]) -> dict:
    if not results:
        raise AssertionError("no per-seed results")
    seeds = [r["model_seed"] for r in results]
    if len(set(seeds)) != len(seeds):
        raise AssertionError(f"duplicate seeds {seeds}")
    settings = {json.dumps(r["registered_verdicts"]["setting"], sort_keys=True) for r in results}
    if len(settings) != 1:
        raise AssertionError("per-seed results were read at different settings")
    V = [r["registered_verdicts"] for r in results]
    reg = [r["by_setting"]["primary"][str(r["registered_verdicts"]["setting"]["d"])] for r in results]

    def per_seed(get):
        return {str(s): get(i) for i, s in enumerate(seeds)}

    def agree(vals: dict):
        v = list(vals.values())
        return None if any(x is None for x in v) else bool(len({json.dumps(x, sort_keys=True) for x in v}) == 1)

    h1 = per_seed(lambda i: V[i]["H1_diff"])
    h1m = per_seed(lambda i: V[i]["H1m_diff"])
    h2 = {e: per_seed(lambda i, e=e: reg[i]["H2"]["U4"][e]["diff_descriptive"]) for e in ("E1", "E2")}
    h3 = {e: per_seed(lambda i, e=e: (None if reg[i]["H3"][e]["crack"]["enrichment"] is None
                                       else reg[i]["H3"][e]["crack"]["enrichment"] - 1.0)) for e in ("E1", "E2")}
    out = {
        "seeds": seeds, "n_seeds": len(seeds), "three_seeds": len(seeds) == 3,
        "setting": V[0]["setting"],
        "H1": {"diff_by_seed": h1, "same_direction": same_direction(list(h1.values())),
               "K1_fired_by_seed": per_seed(lambda i: V[i]["K1_fired"]),
               "verdict_agrees": agree(per_seed(lambda i: V[i]["K1_fired"])),
               "status_by_seed": per_seed(lambda i: V[i]["H1_status"])},
        "H1m": {"diff_by_seed": h1m, "same_direction": same_direction(list(h1m.values())),
                "K1m_fired_by_seed": per_seed(lambda i: V[i]["K1m_fired"]),
                "reversed_by_seed": per_seed(lambda i: V[i]["H1m_reversed"]),
                "verdict_agrees": agree(per_seed(lambda i: V[i]["K1m_fired"]))},
        "H1_length_control": {"robust_by_seed": per_seed(lambda i: V[i]["H1_length_control_robust"]),
                              "agrees": agree(per_seed(lambda i: V[i]["H1_length_control_robust"]))},
        "H2": {"diff_descriptive_by_seed": h2,
               "same_direction": {e: same_direction(list(h2[e].values())) for e in ("E1", "E2")},
               "verdict_by_seed": per_seed(lambda i: V[i]["H2"]["H2"]),
               "verdict_agrees": agree(per_seed(lambda i: V[i]["H2"]["H2"]))},
        "H3": {"crack_enrichment_minus_1_by_seed": h3,
               "same_direction": {e: same_direction(list(h3[e].values())) for e in ("E1", "E2")}},
        "gates": {"K2_fired_by_seed": per_seed(lambda i: V[i]["K2_fired"]),
                  "K_agree_fired_by_seed": per_seed(lambda i: V[i]["K_agree_fired"])},
        "mc_rerun_recommended_by_seed": per_seed(lambda i: results[i]["mc_rerun"]["recommended"]),
    }
    # postscript "Resolutions", item B: K2 fired in any seed -> no claim
    k2_clear = all(v is False for v in out["gates"]["K2_fired_by_seed"].values())
    out["claim_eligible"] = {
        "K2_clear_in_every_seed": k2_clear,
        "H1": bool(out["three_seeds"] and k2_clear and out["H1"]["same_direction"] and out["H1"]["verdict_agrees"]
                   and all(v == "survives" for v in out["H1"]["status_by_seed"].values())),
        "H2": bool(out["three_seeds"] and k2_clear and out["H2"]["verdict_agrees"]
                   and all(v == "survives" for v in out["H2"]["verdict_by_seed"].values())),
    }
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--profile", default="main")
    ap.add_argument("--seeds", type=int, nargs="+", default=[0, 1, 2])
    ap.add_argument("--temperature", type=float, default=1.0)
    args = ap.parse_args()
    files = [HERE / "out" / f"analysis-{args.profile}-seed{s}-T{args.temperature:g}.json" for s in args.seeds]
    results = [json.loads(f.read_text(encoding="utf-8")) for f in files]
    out = aggregate(results)
    out.update({"ranAt": datetime.now(timezone.utc).isoformat(), "profile": args.profile,
                "temperature": args.temperature, "files": [f.name for f in files]})
    path = HERE / "out" / f"seeds-{args.profile}-T{args.temperature:g}.json"
    path.write_text(json.dumps(out, indent=1), encoding="utf-8")
    print(json.dumps({k: out[k] for k in ("seeds", "claim_eligible")}, indent=2))
    print("wrote", path)
    return 0


if __name__ == "__main__":
    sys.exit(main())
