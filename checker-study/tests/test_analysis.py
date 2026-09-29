"""Synthetic tests of 08-analysis.py and 09-seeds.py. No model, no corpus:
builds zones-shaped dictionaries with planted effects and checks that every
decision rule reaches every one of its states, then checks that each
halting assertion trips.

Usage: python tests/test_analysis.py
"""
from __future__ import annotations

import copy
import importlib.util
import json
import sys
import tempfile
from pathlib import Path

import numpy as np

HERE = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(HERE))


def load(name):
    spec = importlib.util.spec_from_file_location(name.replace("-", "_"), HERE / f"{name}.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


analysis = load("08-analysis")
seeds_mod = load("09-seeds")
from ipl.zones import CRACK, EXTERIOR, INSIDE  # noqa: E402

RULES = ("primary", "alternative")
DIMS = ("16", "8", "32")
R_PRIMARY = 0.9


def make_zones(rng, n_prompts=300, n_B=1000, ext_C3=0.7, ext_B=0.35, crack_B=0.3, ext_C2=0.35, crack_C2=0.5,
               ext_C4=0.35, crack_C4=0.2, crack_C4_nonnovel=None, h3_ratio_crack=2.0, h3_ratio_ext=1.0,
               e2_same_as_e1=True, alt_all_inside=False, c3_missing_every=None, nn_shift_C3=0.0,
               n_mc=256, profile="synthetic", model_seed=0):
    """Rows: B (n_B, ~40% novel); per prompt 8 parsed C1 samples (half
    invalid), 2 C2 novel, 2 C3 (novel unless the prompt is excluded), 2 C4
    (novel; plus 2 non-novel when crack_C4_nonnovel is set). ext_C3 may be a
    list of three per-tertile rates."""
    rows, lab = [], []

    def zone(p_ext, p_crack):
        u = rng.random()
        return EXTERIOR if u < p_ext else (CRACK if u < p_ext + p_crack else INSIDE)

    def add(arm, prompt, valid, novel, size, z, sampled_length=None):
        rows.append({"arm": arm, "prompt": prompt, "valid": valid, "novel": novel, "term_size": size,
                     "sampled_length": sampled_length, "count": 1, "sample_index": None})
        lab.append(z)

    sizes_B = rng.integers(3, 16, size=n_B)
    lo, hi = float(np.quantile(sizes_B, 1 / 3)), float(np.quantile(sizes_B, 2 / 3))

    def band(s):
        return 0 if s <= lo else (1 if s <= hi else 2)

    for j in range(n_B):
        add("B", j, True, bool(rng.random() < 0.4), int(sizes_B[j]), zone(ext_B, crack_B))
    for p in range(n_prompts):
        for k in range(8):
            invalid = k % 2 == 0
            z = zone(0.3 * (h3_ratio_ext if invalid else 1.0), 0.3 * (h3_ratio_crack if invalid else 1.0))
            add("C1", p, not invalid, (not invalid) and bool(rng.random() < 0.3),
                None if invalid else int(rng.integers(3, 16)), z, sampled_length=int(rng.integers(3, 20)))
        for k in range(2):
            add("C2", p, True, True, int(rng.integers(3, 16)), zone(ext_C2, crack_C2))
        c3_novel = not (c3_missing_every and p % c3_missing_every == 0)
        for k in range(2):
            s = int(rng.integers(3, 16))
            e3 = ext_C3[band(s)] if isinstance(ext_C3, (list, tuple)) else ext_C3
            add("C3", p, True, c3_novel, s, zone(e3, 0.15))
        for k in range(2):
            add("C4", p, True, True, int(rng.integers(3, 16)), zone(ext_C4, crack_C4))
        if crack_C4_nonnovel is not None:
            for k in range(2):
                add("C4", p, True, False, int(rng.integers(3, 16)), zone(ext_C4, crack_C4_nonnovel))

    lab = np.array(lab)
    nn = np.where(lab == INSIDE, rng.random(len(lab)) * R_PRIMARY, R_PRIMARY + 0.01 + rng.random(len(lab)) * 2)
    is_c3 = np.array([r["arm"] == "C3" for r in rows])
    nn = nn + np.where(is_c3 & (lab != INSIDE), nn_shift_C3, 0.0)
    e2 = lab if e2_same_as_e1 else rng.permutation(lab)
    nn_e2 = nn if e2_same_as_e1 else np.where(e2 == INSIDE, rng.random(len(nn)) * R_PRIMARY,
                                              R_PRIMARY + 0.01 + rng.random(len(nn)) * 2)
    alt_e1 = np.full(len(lab), INSIDE) if alt_all_inside else lab
    alt_e2 = np.full(len(lab), INSIDE) if alt_all_inside else e2
    r_alt = 1e9 if alt_all_inside else R_PRIMARY
    labels = {"E1": {d: {"primary": lab.tolist(), "alternative": alt_e1.tolist()} for d in DIMS},
              "E2": {d: {"primary": e2.tolist(), "alternative": alt_e2.tolist()} for d in DIMS}}
    return {
        "profile": profile, "model_seed": model_seed, "ranAt": "test", "temperature": 1.0, "n_mc": n_mc,
        "registered": {"d": 16, "d_sensitivity": [8, 32], "rules": list(RULES), "n_mc": n_mc},
        "tertile_bounds": {"lo": lo, "hi": hi, "n_heldout_used": n_B, "n_heldout": n_B},
        "checks": {"fingerprint_match": True, "tertiles_from_full_heldout": True,
                   "k_check": {"certified": True, "terms": 2000},
                   "minimum_competence": {"certified": True, "c1_valid_rate": 0.5},
                   "train_eta_long_checked": 10,
                   "budget": {"prompts": n_prompts, "exhausted_root": 0}},
        "run_record": {"c3_restarts_on_cap": 1, "c4_shortfall_by_tertile": [0, 0, 0], "c4_caps_hit_prompts": {}},
        "c1_counts": {"samples": n_prompts * 10, "parsed": n_prompts * 8},
        "rows": rows, "labels": labels,
        "nn_dist": {"E1": {d: nn.tolist() for d in DIMS}, "E2": {d: nn_e2.tolist() for d in DIMS}},
        "radii": {e: {d: {"primary": R_PRIMARY, "alternative": r_alt} for d in DIMS} for e in ("E1", "E2")},
    }


N_CHECKS = [0]


def expect(cond, msg, fails):
    N_CHECKS[0] += 1
    print(("ok   " if cond else "FAIL ") + msg)
    if not cond:
        fails.append(msg)


def main() -> int:
    fails = []
    NB = 400

    def run(Z, seed=1, nb=NB):
        R = analysis.analyze(Z, n_boot=nb, seed=seed)
        return R, R["by_setting"]["primary"]["16"], R["registered_verdicts"]

    # 1. planted effects: H1, H1m, length control, H2 survives, H3, kappa, gates
    Z = make_zones(np.random.default_rng(7))
    R, reg, V = run(Z)
    expect(V["K1_fired"] is False and reg["H1"]["ci95"][0] > 0.2, f"H1 effect recovered: {reg['H1']['diff']:.3f} ci {reg['H1']['ci95']}", fails)
    expect(abs(reg["H1"]["C3_joint_exterior"] - 0.7) < 0.05, f"C3 exterior near 0.7: {reg['H1']['C3_joint_exterior']:.3f}", fails)
    expect(reg["H1"]["n_prompts_C3"] == 300 and reg["H1"]["n_B"] == sum(1 for r in Z["rows"] if r["arm"] == "B" and r["novel"]), "H1 entry counts: all prompts enter; B novel-only", fails)
    expect(reg["H1m"]["ci95"][0] > 0 and V["K1m_fired"] is False and V["H1m_reversed"] is False, "H1m positive; K1m not fired, not reversed", fails)
    expect(V["H1_length_control_robust"] is True, f"length control robust ({reg['H1_length_control']['positive_bands']} bands positive)", fails)
    expect(all(v is False for v in V["rule_dependent"].values()), "no rule dependence when labels identical across rules", fails)
    h2 = reg["H2"]["U4"]["E1"]
    expect(h2["K_H2_fired"] is False and h2["status"] == "survives" and all(b["diff"] > 0.15 for b in h2["bands"]), f"H2 E1 survives: C1 {h2['C1_crack']:.3f} vs C4 ci {h2['C4_ci95']}, bands {[round(b['diff'], 3) for b in h2['bands']]}", fails)
    expect(V["H2"]["H2"] == "survives" and V["H2"]["by_embedding"] == {"E1": "survives", "E2": "survives"}, f"H2 verdict survives in both: {V['H2']}", fails)
    expect(h2["n_prompts_entered"] == 300 and h2["n_prompts_dropped_no_common_tertile"] > 0
           and h2["n_prompts"] + h2["n_prompts_dropped_no_common_tertile"] == 300 and "diff_ci95_descriptive" in h2,
           f"H2 prompt-weighted; {h2['n_prompts_dropped_no_common_tertile']} prompts with no common tertile counted; difference CI descriptive", fails)
    expect(all(k in h2["bands"][0] for k in ("n_C2_unique", "n_C2_novel", "n_C4_all", "n_C4_novel")), "per-band C2 / C4-novel counts reported (item I)", fails)
    h3 = reg["H3"]["E1"]
    expect(h3["crack"]["enrichment"] > 1.2 and h3["crack"]["enrichment_ci95"][0] > 1.0, f"H3 crack enrichment {h3['crack']['enrichment']:.3f} ci {h3['crack']['enrichment_ci95']}", fails)
    expect(abs(reg["H3"]["unparseable_fraction"] - 0.2) < 1e-9, "unparseable fraction reported", fails)
    expect(reg["kappa"]["U3"] == 1.0 and reg["kappa"]["B_all"] == 1.0, "kappa 1.0 with identical labels", fails)
    expect(V["K2_fired"] is False and V["K_agree_fired"] is False and V["H1_status"] == "survives", f"gates: K2 {V['K2_fired']}, K-agree {V['K_agree_fired']}, H1 {V['H1_status']}", fails)
    expect(abs(R["gates"]["K2"]["crack_fraction"]["E1"]["primary"] - 0.3) < 0.05, "K2 held-out crack fraction near planted 0.3", fails)
    expect(R["mc_rerun"]["recommended"] is False and R["run_record"]["c3_restarts_on_cap"] == 1 and R["heldout_novel_count"] == reg["H1"]["n_B"], "no rerun trigger; run record and held-out novelty count carried", fails)

    # 2. null H1: K1 fires, K1m null (item F)
    Rn, regn, Vn = run(make_zones(np.random.default_rng(11), ext_C3=0.35), seed=2)
    expect(Vn["K1_fired"] is True and Vn["H1_status"] == "dead (K1)", f"null H1: K1 fires, diff {regn['H1']['diff']:.3f} ci {regn['H1']['ci95']}", fails)
    expect(Vn["K1m_fired"] is None and Vn["H1m_reversed"] is None, "K1m null when K1 fired", fails)

    # 3. K1m fired: C3 and C2 share the exterior rate, both above B
    Rk, regk, Vk = run(make_zones(np.random.default_rng(13), ext_C3=0.7, ext_C2=0.7), seed=3)
    expect(Vk["K1_fired"] is False and Vk["K1m_fired"] is True and Vk["H1m_reversed"] is False, f"K1m fires: H1m diff {regk['H1m']['diff']:.3f} ci {regk['H1m']['ci95']}", fails)

    # 4. reversed: C2 far above C3, C3 above B
    Rr, regr, Vr = run(make_zones(np.random.default_rng(17), ext_C3=0.6, ext_C2=0.9), seed=4)
    expect(Vr["K1_fired"] is False and Vr["K1m_fired"] is True and Vr["H1m_reversed"] is True, f"K1m fires and reversed: H1m ci {regr['H1m']['ci95']}", fails)

    # 5. length control not robust: effect only in the first tertile
    Rl, regl, Vl = run(make_zones(np.random.default_rng(19), ext_C3=[0.95, 0.2, 0.2]), seed=5)
    expect(Vl["K1_fired"] is False and Vl["H1_length_control_robust"] is False, f"length control not robust: bands {[round(b['diff'], 3) for b in regl['H1_length_control']['bands']]}, H1 ci {regl['H1']['ci95']}", fails)

    # 6. rule dependence: alternative rule puts everything inside
    Ra, rega, Va = run(make_zones(np.random.default_rng(23), alt_all_inside=True), seed=6)
    expect(Va["rule_dependent"]["K1"] is True and Va["alternative_rule"]["K1_fired"] is True and Va["K1_fired"] is False, "rule dependence detected for K1", fails)
    expect(Va["rule_dependent"]["K2"] is True and Va["K2_fired"] is False, "K2 rule-dependent when cracks vanish under one rule only", fails)
    expect(Va["alternative_rule"]["K1m_fired"] is None and Va["rule_dependent"]["K1m"] is None, "rule_dependent.K1m is None when one rule's K1m is null (note d)", fails)

    # 7. K-H2 fired in both embeddings, consistent labels -> dead
    Rd, regd, Vd = run(make_zones(np.random.default_rng(29), crack_C2=0.3, crack_C4=0.3), seed=7)
    expect(Vd["H2"]["H2"] == "dead" and Vd["H2"]["K_H2_fired_by_embedding"] == {"E1": True, "E2": True}, f"H2 dead when C1 crack equals C4's: {Vd['H2']}", fails)

    # 8. entry rule excludes prompts with no valid novel C3 output
    Re, rege, Ve = run(make_zones(np.random.default_rng(31), c3_missing_every=10), seed=8)
    expect(rege["H1"]["n_prompts_C3"] == 270 and rege["H1m"]["n_prompts"] == 270, f"entry rule excludes 30 prompts: H1 {rege['H1']['n_prompts_C3']}, H1m {rege['H1m']['n_prompts']}", fails)

    # 9. U4 differs from C4_all: non-novel C4 proofs are crack-heavy
    Ru, regu, Vu = run(make_zones(np.random.default_rng(37), crack_C4_nonnovel=0.7), seed=9)
    u4, c4a = regu["H2"]["U4"]["E1"], regu["H2"]["C4_all"]["E1"]
    expect(u4["status"] == "survives" and c4a["C4_crack"] > u4["C4_crack"] + 0.15 and Vu["H2"] == regu["H2"]["U4"]["verdict"], f"U4 vs C4_all differ: C4 crack {u4['C4_crack']:.3f} vs {c4a['C4_crack']:.3f}; registered verdict from U4", fails)
    expect(u4["bands"][0]["n_C4_all"] > u4["bands"][0]["n_C4_novel"] > 0, "per-band C4-novel count below C4-all count", fails)

    # 10. H3 null: no enrichment
    Rh, regh, _ = run(make_zones(np.random.default_rng(41), h3_ratio_crack=1.0), seed=10)
    cr = regh["H3"]["E1"]["crack"]
    expect(cr["enrichment_ci95"][0] < 1.0 < cr["enrichment_ci95"][1], f"H3 null: crack enrichment ci {cr['enrichment_ci95']} includes 1", fails)

    # 11. H3 exterior enrichment
    Rx, regx, _ = run(make_zones(np.random.default_rng(43), h3_ratio_crack=1.0, h3_ratio_ext=2.0), seed=11)
    ex = regx["H3"]["E1"]
    expect(ex["exterior"]["enrichment_ci95"][0] > 1.0 and ex["crack_minus_exterior_enrichment"] < 0, f"H3 exterior enrichment {ex['exterior']['enrichment']:.3f}, crack minus exterior {ex['crack_minus_exterior_enrichment']:.3f}", fails)

    # 12. shuffled E2: embedding-dependent H2, kappa ~ 0, K-agree fires, H1 descriptive only; Z_U shift
    Rs, regs, Vs = run(make_zones(np.random.default_rng(3), e2_same_as_e1=False, nn_shift_C3=2.0), seed=12, nb=100)
    expect(abs(regs["kappa"]["B_all"]) < 0.1 and Vs["K_agree_fired"] is True and Vs["H1_status"].startswith("descriptive"), f"K-agree fires with shuffled E2 (kappa {regs['kappa']['B_all']:.3f}); H1 {Vs['H1_status']}", fails)
    expect(Vs["H2"]["by_embedding"] == {"E1": "survives", "E2": "dead"} and Vs["H2"]["H2"] == "embedding-dependent", f"H2 embedding-dependent: {Vs['H2']['by_embedding']}", fails)
    zus = Rs["descriptives"]["E1"]["16"]["Z_U_vs_B_novel"]["U3"]
    expect(zus > 10, f"Z_U strongly positive when C3 sits further from training: {zus:.1f}", fails)
    Zz = make_zones(np.random.default_rng(5), crack_C4=0.3)
    Rz, _, _ = run(Zz, seed=13, nb=50)
    zu = Rz["descriptives"]["E1"]["16"]["Z_U_vs_B_novel"]["U4"]
    expect(abs(zu) < 3.0, f"Z_U near zero when C4 has B's zone mix: {zu:.2f}", fails)

    # 13. K2 fires: held-out cracks vanish under both rules -> H1 and H2 unmeasurable, no claim (item B)
    R2, _, V2 = run(make_zones(np.random.default_rng(47), crack_B=0.01), seed=14, nb=50)
    expect(V2["K2_fired"] is True and R2["gates"]["K2"]["fired_embeddings"] == ["E1", "E2"], f"K2 fires: {R2['gates']['K2']['crack_fraction']}", fails)
    expect(V2["H1_status"] == "unmeasurable (K2)" and V2["H2"]["H2"] == "unmeasurable (K2)"
           and V2["H2"]["by_embedding"] == {"E1": "survives", "E2": "survives"}, f"K2 fired: H1 {V2['H1_status']}, H2 {V2['H2']['H2']} (per-embedding K-H2 still recorded)", fails)
    k2_three = [analysis.analyze(make_zones(np.random.default_rng(300 + s), crack_B=0.01, model_seed=s), n_boot=50, seed=s) for s in range(3)]
    aggk = seeds_mod.aggregate(k2_three)
    expect(aggk["claim_eligible"]["K2_clear_in_every_seed"] is False and aggk["claim_eligible"]["H1"] is False and aggk["claim_eligible"]["H2"] is False, "K2 fired in every seed: no claim eligible", fails)

    # 13b. no C3 data at all: K1 undefined, H1_status None (note a)
    Zno = make_zones(np.random.default_rng(59), c3_missing_every=1)
    Rno, regno, Vno = run(Zno, seed=16, nb=50)
    expect(Vno["K1_fired"] is None and Vno["H1_status"] is None and Vno["K1m_fired"] is None, f"no C3 novel output anywhere: K1 {Vno['K1_fired']}, H1_status {Vno['H1_status']}", fails)

    # 14. MC rerun trigger: held-out crack fraction near 0.05; rerun file does not re-trigger
    R3, _, _ = run(make_zones(np.random.default_rng(53), crack_B=0.06), seed=15, nb=50)
    expect(R3["mc_rerun"]["recommended"] is True and any("K2" in s for s in R3["mc_rerun"]["reasons"]), f"rerun recommended near K2 threshold: {R3['mc_rerun']['reasons']}", fails)
    R4, _, _ = run(make_zones(np.random.default_rng(53), crack_B=0.06, n_mc=1024), seed=15, nb=50)
    expect(R4["mc_rerun"]["is_rerun"] is True and R4["mc_rerun"]["recommended"] is False, "1,024-sample file marked as the rerun, no further trigger", fails)

    # 15. three-seed aggregation
    three = [analysis.analyze(make_zones(np.random.default_rng(100 + s), model_seed=s), n_boot=100, seed=s) for s in range(3)]
    agg = seeds_mod.aggregate(three)
    expect(agg["H1"]["same_direction"] is True and agg["claim_eligible"]["H1"] is True and agg["claim_eligible"]["H2"] is True, "three seeds same direction: claims eligible", fails)
    mixed = three[:2] + [analysis.analyze(make_zones(np.random.default_rng(999), ext_C3=0.2, model_seed=2), n_boot=100, seed=9)]
    aggm = seeds_mod.aggregate(mixed)
    expect(aggm["H1"]["same_direction"] is False and aggm["claim_eligible"]["H1"] is False, "one seed reversed: H1 direction disagrees, no claim", fails)
    expect(seeds_mod.aggregate(three[:2])["claim_eligible"]["H1"] is False, "two seeds only: no claim", fails)
    try:
        seeds_mod.aggregate([three[0], three[0]])
        expect(False, "assertion: duplicate seeds refused", fails)
    except AssertionError:
        expect(True, "assertion: duplicate seeds refused", fails)

    # 16. --n-boot override refused for registered profiles
    Zm = make_zones(np.random.default_rng(1), n_prompts=20, n_B=60, profile="main")
    with tempfile.TemporaryDirectory() as td:
        pth = Path(td) / "z.json"
        pth.write_text(json.dumps(Zm), encoding="utf-8")
        sys.argv = ["08-analysis.py", "--zones", str(pth), "--n-boot", "10"]
        try:
            analysis.main()
            expect(False, "assertion: --n-boot override refused for profile main", fails)
        except AssertionError:
            expect(True, "assertion: --n-boot override refused for profile main", fails)

    # 17. halting assertions trip on corrupted input
    def trips(mutate, msg):
        Zc = copy.deepcopy(Z)
        mutate(Zc)
        try:
            analysis.analyze(Zc, n_boot=10, seed=0)
            expect(False, msg, fails)
        except AssertionError:
            expect(True, msg, fails)

    trips(lambda z: z["tertile_bounds"].__setitem__("n_heldout_used", 999), "assertion: tertiles not from full held-out")
    trips(lambda z: z["tertile_bounds"].__setitem__("lo", z["tertile_bounds"]["lo"] + 1), "assertion: tertile boundary value differs from held-out sizes")
    trips(lambda z: z["rows"].pop(0), "assertion: held-out row count differs from n_heldout")
    trips(lambda z: z["checks"].__setitem__("fingerprint_match", False), "assertion: novelty fingerprint not certified")
    trips(lambda z: z["checks"].pop("budget"), "assertion: draw budget not certified")
    trips(lambda z: z["checks"].pop("k_check"), "assertion: K-check not certified")
    trips(lambda z: z["checks"]["minimum_competence"].__setitem__("certified", False), "assertion: minimum competence not certified")
    trips(lambda z: z["checks"].__setitem__("train_eta_long_checked", 0), "assertion: training eta-long form not certified")
    trips(lambda z: z["labels"]["E1"]["16"]["primary"].__setitem__(0, INSIDE if z["labels"]["E1"]["16"]["primary"][0] != INSIDE else EXTERIOR), "assertion: inside label inconsistent with nn distance")
    trips(lambda z: z["labels"]["E1"]["16"]["primary"].__setitem__(0, 7) or z["nn_dist"]["E1"]["16"].__setitem__(0, 5.0), "assertion: unknown zone label")

    def no_size(z):
        for r in z["rows"]:
            if r["arm"] == "C2":
                r["term_size"] = None
                break
    trips(no_size, "assertion: valid row without term_size")

    print(json.dumps({"checks": N_CHECKS[0], "failures": fails}))
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
