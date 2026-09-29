"""Synthetic test of 08-analysis.py. No model, no corpus: builds a
zones-shaped dictionary with planted effects and checks that the analysis
recovers them, then checks that each halting assertion trips.

Usage: python tests/test_analysis.py
"""
from __future__ import annotations

import copy
import importlib.util
import json
import sys
from pathlib import Path

import numpy as np

HERE = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(HERE))
spec = importlib.util.spec_from_file_location("analysis", HERE / "08-analysis.py")
analysis = importlib.util.module_from_spec(spec)
spec.loader.exec_module(analysis)
from ipl.zones import CRACK, EXTERIOR, INSIDE  # noqa: E402

RULES = ("primary", "alternative")
DIMS = ("16", "8", "32")


def make_zones(rng, n_prompts=300, n_B=1000, p_ext_C3=0.7, p_ext_B=0.35, p_ext_C2=0.35,
               p_crack_C1=0.5, p_crack_C4=0.2, h3_ratio_crack=2.0, e2_same_as_e1=True,
               nn_shift_C3=0.0):
    """Rows: B (n_B, ~40% novel), per prompt: 8 parsed C1 samples (half
    invalid), 2 C2 novel, 2 C3 novel, 2 C4 novel. Labels drawn per row with
    the planted rates; the same labels are used for every rule and d."""
    rows, lab, nn = [], [], []

    def zone(p_ext, p_crack):
        u = rng.random()
        return EXTERIOR if u < p_ext else (CRACK if u < p_ext + p_crack else INSIDE)

    def add(arm, prompt, valid, novel, size, z, dist):
        rows.append({"arm": arm, "prompt": prompt, "valid": valid, "novel": novel, "term_size": size,
                     "count": 1, "sample_index": None})
        lab.append(z)
        nn.append(dist)

    sizes_B = rng.integers(3, 16, size=n_B)
    for j in range(n_B):
        add("B", j, True, bool(rng.random() < 0.4), int(sizes_B[j]), zone(p_ext_B, 0.3), rng.random() * 3)
    for p in range(n_prompts):
        for k in range(8):
            invalid = k % 2 == 0
            # invalid samples are h3_ratio_crack times as likely in cracks
            z = zone(0.3, 0.6 if invalid else 0.6 / h3_ratio_crack)
            add("C1", p, not invalid, (not invalid) and bool(rng.random() < 0.3), int(rng.integers(3, 16)), z,
                rng.random() * 3)
        for k in range(2):
            add("C2", p, True, True, int(rng.integers(3, 16)), zone(p_ext_C2, p_crack_C1), rng.random() * 3)
        for k in range(2):
            add("C3", p, True, True, int(rng.integers(3, 16)), zone(p_ext_C3, 0.15), rng.random() * 3 + nn_shift_C3)
        for k in range(2):
            add("C4", p, True, True, int(rng.integers(3, 16)), zone(0.35, p_crack_C4), rng.random() * 3)

    lab = np.array(lab)
    r = 0.9  # any consistent radius: inside labels must have nn <= r and vice versa
    nn = np.where(lab == INSIDE, rng.random(len(lab)) * r, r + 0.01 + rng.random(len(lab)) * 2)
    is_c3 = np.array([r_["arm"] == "C3" for r_ in rows])
    nn = nn + np.where(is_c3 & (lab != INSIDE), nn_shift_C3, 0.0)
    e2 = lab if e2_same_as_e1 else rng.permutation(lab)
    labels = {"E1": {d: {ru: lab.tolist() for ru in RULES} for d in DIMS},
              "E2": {d: {ru: e2.tolist() for ru in RULES} for d in DIMS}}
    nn_e2 = nn if e2_same_as_e1 else np.where(e2 == INSIDE, rng.random(len(nn)) * r, r + 0.01 + rng.random(len(nn)) * 2)
    nn_dist = {"E1": {d: nn.tolist() for d in DIMS}, "E2": {d: nn_e2.tolist() for d in DIMS}}
    b_sizes = np.array([r_["term_size"] for r_ in rows if r_["arm"] == "B"], dtype=float)
    lo, hi = float(np.quantile(b_sizes, 1 / 3)), float(np.quantile(b_sizes, 2 / 3))
    return {
        "profile": "synthetic", "model_seed": 0, "ranAt": "test",
        "registered": {"d": 16, "d_sensitivity": [8, 32], "rules": list(RULES)},
        "tertile_bounds": {"lo": lo, "hi": hi, "n_heldout_used": n_B, "n_heldout": n_B},
        "checks": {"fingerprint_match": True, "tertiles_from_full_heldout": True,
                   "budget": {"prompts": n_prompts, "exhausted_root": 0}},
        "c1_counts": {"samples": n_prompts * 10, "parsed": n_prompts * 8},
        "rows": rows, "labels": labels, "nn_dist": nn_dist,
        "radii": {e: {d: {ru: r for ru in RULES} for d in DIMS} for e in ("E1", "E2")},
    }


def expect(cond, msg, fails):
    print(("ok   " if cond else "FAIL ") + msg)
    if not cond:
        fails.append(msg)


def main() -> int:
    fails = []
    rng = np.random.default_rng(7)
    NB = 400

    # 1. planted H1 effect (C3 0.7 vs B 0.35 joint exterior) is recovered, CI excludes zero
    Z = make_zones(rng)
    R = analysis.analyze(Z, n_boot=NB, seed=1)
    reg = R["by_setting"]["primary"]["16"]
    expect(reg["H1"]["K1_fired"] is False and reg["H1"]["ci95"][0] > 0.2, f"H1 effect recovered: {reg['H1']['diff']:.3f} ci {reg['H1']['ci95']}", fails)
    expect(abs(reg["H1"]["C3_joint_exterior"] - 0.7) < 0.05, f"C3 exterior near 0.7: {reg['H1']['C3_joint_exterior']:.3f}", fails)
    expect(reg["H1"]["n_prompts_C3"] == 300 and reg["H1"]["n_B"] == sum(1 for r in Z["rows"] if r["arm"] == "B" and r["novel"]), "H1 entry counts (all prompts enter; B novel-only)", fails)
    expect(reg["H1m"]["ci95"][0] > 0 and reg["H1m"]["K1m_fired"] is False and reg["H1m"]["n_prompts"] == 300, "H1m (C3 - C2 on matched set) positive; K1m not fired", fails)
    expect(reg["H1_length_control"]["robust"] is True, f"length control robust ({reg['H1_length_control']['positive_bands']} bands positive)", fails)
    expect(R["registered_verdicts"]["rule_dependent"]["K1"] is False, "no rule dependence when labels identical across rules", fails)

    # 2. H2: C1 crack 0.5 vs C4 crack 0.2 within tertiles; K-H2 must not fire in any band
    h2 = reg["H2"]["U4"]["E1"]
    expect(h2["K_H2_fired"] is False and h2["passes"] is True and all(b["diff"] > 0.15 for b in h2["bands"]), f"H2 E1 recovered: pooled diff {h2['diff']:.3f} ci {h2['diff_ci95']}, bands {[round(b['diff'], 3) for b in h2['bands']]}", fails)
    v = reg["H2"]["U4"]["verdict"]
    expect(v["H2"] == "pass" and v["K_H2"] == "not fired" and v["pass_and_kill_disagree"] is False, f"H2 verdict with identical E1/E2 labels: {v['H2']}, K-H2 {v['K_H2']}, disagree {v['pass_and_kill_disagree']}", fails)
    expect(R["registered_verdicts"]["H2"] == v, "registered verdict uses C4 novel-only at (primary, 16)", fails)

    # 3. H3: invalid samples planted twice as crack-prone -> crack enrichment > 1 with CI above 1
    h3 = reg["H3"]["E1"]
    expect(h3["crack"]["enrichment"] > 1.2 and h3["crack"]["enrichment_ci95"][0] > 1.0, f"H3 crack enrichment {h3['crack']['enrichment']:.3f} ci {h3['crack']['enrichment_ci95']}", fails)
    expect(abs(reg["H3"]["unparseable_fraction"] - 0.2) < 1e-9, "unparseable fraction reported", fails)

    # 4. kappa = 1 when E2 labels equal E1; Z_U ~ 0 for identical distance distributions
    expect(reg["kappa"]["U3"] == 1.0 and reg["kappa"]["B_novel"] == 1.0, "kappa 1.0 with identical labels", fails)
    # C4 with B's zone mix (0.35 exterior, 0.3 crack) has B's distance distribution
    Zz = make_zones(np.random.default_rng(5), p_crack_C4=0.3)
    Rz = analysis.analyze(Zz, n_boot=50, seed=5)
    zu = Rz["descriptives"]["E1"]["16"]["Z_U_vs_B_novel"]["U4"]
    expect(abs(zu) < 3.0, f"Z_U near zero for identical distance distributions: {zu:.2f}", fails)
    zu3 = Rz["descriptives"]["E1"]["16"]["Z_U_vs_B_novel"]["U3"]
    expect(zu3 > 3.0, f"Z_U positive when the arm has fewer inside points than B: {zu3:.2f}", fails)

    # 5. null: no effect -> CI includes zero (single seed; a 5% flake is possible, so use a wide null)
    Zn = make_zones(np.random.default_rng(11), p_ext_C3=0.35, p_ext_B=0.35)
    Rn = analysis.analyze(Zn, n_boot=NB, seed=2)
    h1n = Rn["by_setting"]["primary"]["16"]["H1"]
    expect(h1n["K1_fired"] is True, f"null H1: K1 fires, diff {h1n['diff']:.3f} ci {h1n['ci95']}", fails)

    # 6. shuffled E2 -> kappa near 0; shifted C3 distances -> Z_U strongly positive
    Zs = make_zones(np.random.default_rng(3), e2_same_as_e1=False, nn_shift_C3=2.0)
    Rs = analysis.analyze(Zs, n_boot=100, seed=3)
    expect(abs(Rs["by_setting"]["primary"]["16"]["kappa"]["B_all"]) < 0.1, "kappa near 0 with shuffled E2", fails)
    vs = Rs["by_setting"]["primary"]["16"]["H2"]["U4"]["verdict"]
    expect(vs["passes_by_embedding"]["E1"] is True and vs["passes_by_embedding"]["E2"] is False
           and vs["H2"] == "embedding-dependent" and vs["K_H2"] == "embedding-dependent",
           f"H2 embedding-dependent when only E1 carries the effect: {vs}", fails)
    zus = Rs["descriptives"]["E1"]["16"]["Z_U_vs_B_novel"]["U3"]
    expect(zus > 10, f"Z_U strongly positive when C3 sits further from training: {zus:.1f}", fails)

    # 7. halting assertions trip on corrupted input
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
    trips(lambda z: z["checks"].__setitem__("fingerprint_match", False), "assertion: novelty fingerprint not certified")
    trips(lambda z: z["checks"].pop("budget"), "assertion: draw budget not certified")
    trips(lambda z: z["labels"]["E1"]["16"]["primary"].__setitem__(0, INSIDE if z["labels"]["E1"]["16"]["primary"][0] != INSIDE else EXTERIOR), "assertion: inside label inconsistent with nn distance")

    print(json.dumps({"failures": fails}))
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
