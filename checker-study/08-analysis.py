"""Registered analysis (SPEC.md: "Measures and analysis", "Kill conditions
and decision rules", postscripts 2026-09-29 on B, "Conditions" and
"Resolutions of the independent review").

Input: out/zones-<profile>-seed<k>-T<temp>[-mc<n>].json from 07-embed-zones.py.
Output: out/analysis-<profile>-seed<k>-T<temp>[-mc<n>].json. Every quantity is
computed under both calibration rules and all three PCA dimensions; the
registered verdicts are read at the primary rule and d = 16, and
rule-dependence is flagged when the alternative rule disagrees. Three seeds
are aggregated by 09-seeds.py.

What is computed, with the spec location that fixes each choice:
  * Gates on the main-run held-out set ("Resolutions", item B): K2 (an
    embedding whose held-out crack fraction is below 5% under both rules;
    one rule only is rule-dependent) and K-agree (kappa between E1 and E2
    on held-out below 0.2, primary rule, d = 16). K-agree fired makes H1
    descriptive only.
  * H1 ("Measures and analysis"; postscript on B): joint (both-embedding)
    exterior fraction, mean over prompts where C3 has a unique valid novel
    output, minus the mean over term-novel B formulas. Independent
    two-sample percentile bootstrap, 10,000 resamples ("Resolutions", G).
    K1 fires if the CI includes zero or is negative.
  * H1m ("Conditions", item 7; "Resolutions", F): C3 - C2 on the prompts
    where both have a unique valid novel output, paired bootstrap over
    prompts. K1m is null when K1 fired; otherwise it fires if the CI
    includes zero, or if the CI is entirely negative, which is also
    flagged "reversed".
  * Length control ("Measures and analysis"): H1's difference within
    proof-size tertiles fixed on the full held-out set (linear-interpolation
    quantiles, <= edges; "Resolutions", G); robust if positive in at least
    two of three bands.
  * H2 ("Conditions", item 8; "Resolutions", A, D, I): per embedding at the
    primary rule and d = 16. Within each tertile, per-prompt crack fraction
    of C1's unique valid novel outputs and of C4's novel outputs; a
    prompt's cell fractions are averaged within the prompt, then pooled
    with equal prompt weight; bootstrap over prompts. K-H2 is H2's only
    decision rule: fired (C1's point estimate not above C4's CI upper
    bound) -> dead, else survives; overall survives only in both
    embeddings, dead in both -> dead, else embedding-dependent. The
    difference CI, C4 over all outputs and crack-in-both are descriptive.
    Prompts dropped for no common tertile, and per-band C2 / C4-novel
    counts, are reported.
  * H3 ("Hypotheses", H3; "Resolutions", C): among raw C1 samples that
    parse, embedded as sampled, invalid rate by zone divided by the overall
    invalid rate, per embedding; cluster bootstrap over prompts.
  * Kappa between E1 and E2 per condition and rule; Z_U per condition
    against B in each embedding ("Measures and analysis").
  * Monte Carlo rerun trigger ("Resolutions", H): a registered verdict
    whose CI bound is within 0.02 of its threshold, or a K2 crack fraction
    within 0.02 of 0.05, recommends the 1,024-sample rerun.

Usage: python 08-analysis.py --profile main --seed 0 [--temperature 1.0] [--n-mc 256]
"""
from __future__ import annotations

import argparse
import json
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

import numpy as np
from scipy.stats import mannwhitneyu

sys.path.insert(0, str(Path(__file__).parent))
from ipl.zones import CRACK, EXTERIOR, INSIDE, ZONE_NAMES, cohen_kappa  # noqa: E402

HERE = Path(__file__).parent
N_BOOT = 10_000
BOOT_SEED = 20260928
EMB = ("E1", "E2")
K2_THRESHOLD = 0.05
K_AGREE_THRESHOLD = 0.2
NARROW = 0.02
REGISTERED_PROFILES = ("main",)


# ----------------------------------------------------------------------------
# helpers


def boot_means(x: np.ndarray, n_boot: int, rng: np.random.Generator, chunk: int = 1000) -> np.ndarray:
    """Bootstrap distribution of the mean of x (resampling its elements)."""
    n = len(x)
    if n == 0:
        return np.full(n_boot, np.nan)
    out = np.empty(n_boot)
    for a in range(0, n_boot, chunk):
        b = min(n_boot, a + chunk)
        w = rng.multinomial(n, np.full(n, 1.0 / n), size=b - a)
        out[a:b] = (w @ x) / n
    return out


def ci95(samples: np.ndarray) -> list:
    s = samples[~np.isnan(samples)]
    if len(s) == 0:
        return [None, None]
    return [float(np.quantile(s, 0.025)), float(np.quantile(s, 0.975))]


def per_prompt_fraction(prompts: np.ndarray, indicator: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    """Mean of indicator within each prompt id present. Returns (prompt ids, fractions)."""
    if len(prompts) == 0:
        return np.array([], dtype=int), np.array([])
    ids, inv = np.unique(prompts, return_inverse=True)
    s = np.bincount(inv, weights=indicator.astype(float), minlength=len(ids))
    c = np.bincount(inv, minlength=len(ids))
    return ids, s / c


def tertile_of(sizes: np.ndarray, lo: float, hi: float) -> np.ndarray:
    return np.where(sizes <= lo, 0, np.where(sizes <= hi, 1, 2))


def fnum(x) -> float | None:
    return None if x is None or (isinstance(x, float) and np.isnan(x)) else float(x)


def near(value, threshold, tol=NARROW) -> bool:
    return value is not None and threshold is not None and abs(float(value) - float(threshold)) <= tol


# ----------------------------------------------------------------------------
# analysis


def analyze(Z: dict, n_boot: int = N_BOOT, seed: int = BOOT_SEED) -> dict:
    rows = Z["rows"]
    arm = np.array([r["arm"] for r in rows])
    prompt = np.array([r["prompt"] for r in rows], dtype=int)
    valid = np.array([bool(r["valid"]) for r in rows])
    novel = np.array([bool(r["novel"]) if r["novel"] is not None else False for r in rows])
    size = np.array([np.nan if r["term_size"] is None else r["term_size"] for r in rows], dtype=float)
    tb = Z["tertile_bounds"]
    lo, hi = float(tb["lo"]), float(tb["hi"])
    dims = [str(Z["registered"]["d"])] + [str(d) for d in Z["registered"]["d_sensitivity"]]
    rules = tuple(Z["registered"]["rules"])
    d_reg = str(Z["registered"]["d"])

    # ---- halting assertions on the certification carried by the zones file
    chk = Z.get("checks", {})
    for key in ("fingerprint_match", "tertiles_from_full_heldout"):
        if not chk.get(key):
            raise AssertionError(f"zones file does not certify {key}")
    if not chk.get("k_check", {}).get("certified"):
        raise AssertionError("zones file does not certify K-check")
    if not chk.get("minimum_competence", {}).get("certified"):
        raise AssertionError("zones file does not certify minimum competence")
    if not chk.get("train_eta_long_checked"):
        raise AssertionError("zones file does not certify that training proofs are stored eta-long")
    if "prompts" not in chk.get("budget", {}):
        raise AssertionError("zones file does not certify the draw-budget check")
    if tb["n_heldout_used"] != tb["n_heldout"] or tb["n_heldout"] != int((arm == "B").sum()):
        raise AssertionError("tertile boundaries were not computed on the full held-out set")
    b_sizes = np.sort(size[arm == "B"])
    if abs(np.quantile(b_sizes, 1 / 3) - lo) > 1e-9 or abs(np.quantile(b_sizes, 2 / 3) - hi) > 1e-9:
        raise AssertionError("tertile boundaries do not match the held-out proof sizes in the file")
    if np.isnan(size[valid]).any():
        raise AssertionError("a valid row has no term_size")
    for e in EMB:
        for d in dims:
            nn = np.asarray(Z["nn_dist"][e][d])
            for rule in rules:
                lab = np.asarray(Z["labels"][e][d][rule])
                r = Z["radii"][e][d][rule]
                if not np.array_equal(lab == INSIDE, nn <= r):
                    raise AssertionError(f"{e} d={d} {rule}: inside label inconsistent with nn distance and r")
                if not np.all(np.isin(lab, [INSIDE, CRACK, EXTERIOR])):
                    raise AssertionError("unknown zone label")

    tert = tertile_of(np.nan_to_num(size, nan=-1.0), lo, hi)
    rng = np.random.default_rng(seed)
    out = {"by_setting": {}, "descriptives": {}}

    pop = {
        "B_novel": (arm == "B") & novel, "B_all": arm == "B",
        "U2": (arm == "C2") & novel, "C2_all": arm == "C2",
        "U3": (arm == "C3") & novel,
        "U4": (arm == "C4") & novel, "C4_all": arm == "C4",
        "C1_parsed": arm == "C1",
    }

    # ---- gates on the main-run held-out set (item B), read at d_reg
    Lreg = {rule: {e: np.asarray(Z["labels"][e][d_reg][rule]) for e in EMB} for rule in rules}
    k2 = {"threshold": K2_THRESHOLD, "crack_fraction": {}, "fired_embeddings": [], "rule_dependent_embeddings": []}
    for e in EMB:
        k2["crack_fraction"][e] = {rule: fnum((Lreg[rule][e][pop["B_all"]] == CRACK).mean()) for rule in rules}
        below = [k2["crack_fraction"][e][rule] < K2_THRESHOLD for rule in rules]
        if all(below):
            k2["fired_embeddings"].append(e)
        elif any(below):
            k2["rule_dependent_embeddings"].append(e)
    k2["fired"] = bool(k2["fired_embeddings"])
    kappa_B = fnum(cohen_kappa(Lreg["primary"]["E1"][pop["B_all"]], Lreg["primary"]["E2"][pop["B_all"]]))
    k_agree = {"kappa_heldout": kappa_B, "threshold": K_AGREE_THRESHOLD, "fired": bool(kappa_B < K_AGREE_THRESHOLD)}
    out["gates"] = {"setting": {"rule": "primary", "d": int(d_reg)}, "K2": k2, "K_agree": k_agree}

    for rule in rules:
        out["by_setting"][rule] = {}
        for d in dims:
            L = {e: np.asarray(Z["labels"][e][d][rule]) for e in EMB}
            joint_ext = (L["E1"] == EXTERIOR) & (L["E2"] == EXTERIOR)
            S: dict = {}

            # ---- H1: C3 vs B (joint exterior)
            def h1_block(Bmask):
                b = joint_ext[Bmask].astype(float)
                _, f3 = per_prompt_fraction(prompt[pop["U3"]], joint_ext[pop["U3"]])
                point = float(f3.mean() - b.mean()) if len(f3) and len(b) else None
                ci = ci95(boot_means(f3, n_boot, rng) - boot_means(b, n_boot, rng))
                return {"n_prompts_C3": int(len(f3)), "n_B": int(len(b)),
                        "C3_joint_exterior": fnum(f3.mean() if len(f3) else None),
                        "B_joint_exterior": fnum(b.mean() if len(b) else None),
                        "diff": point, "ci95": ci,
                        "K1_fired": None if ci[0] is None else bool(ci[0] <= 0)}
            S["H1"] = h1_block(pop["B_novel"])
            S["H1_B_all_descriptive"] = h1_block(pop["B_all"])

            # ---- H1m (item 7; item F)
            p2, f2 = per_prompt_fraction(prompt[pop["U2"]], joint_ext[pop["U2"]])
            p3, f3 = per_prompt_fraction(prompt[pop["U3"]], joint_ext[pop["U3"]])
            both = np.intersect1d(p2, p3)
            d23 = f3[np.isin(p3, both)] - f2[np.isin(p2, both)]
            ci23 = ci95(boot_means(d23, n_boot, rng))
            k1 = S["H1"]["K1_fired"]
            if k1 is None or k1 or ci23[0] is None:
                k1m, reversed_ = None, None
            else:
                reversed_ = bool(ci23[1] < 0)
                k1m = bool(ci23[0] <= 0 <= ci23[1]) or reversed_
            S["H1m"] = {
                "n_prompts": int(len(both)), "C3": fnum(f3[np.isin(p3, both)].mean() if len(both) else None),
                "C2_equals_C1_valid": fnum(f2[np.isin(p2, both)].mean() if len(both) else None),
                "diff": fnum(d23.mean() if len(both) else None), "ci95": ci23,
                "K1m_fired": k1m, "reversed": reversed_}

            # ---- length control: H1 per tertile
            bands = []
            for t in range(3):
                m3 = pop["U3"] & (tert == t)
                mb = pop["B_novel"] & (tert == t)
                _, f3t = per_prompt_fraction(prompt[m3], joint_ext[m3])
                bt = joint_ext[mb].astype(float)
                diff = fnum(f3t.mean() - bt.mean()) if len(f3t) and len(bt) else None
                bands.append({"tertile": t, "n_prompts_C3": int(len(f3t)), "n_B": int(len(bt)), "diff": diff})
            pos = sum(1 for b in bands if b["diff"] is not None and b["diff"] > 0)
            S["H1_length_control"] = {"bands": bands, "positive_bands": pos,
                                      "robust": bool(pos >= 2) if any(b["diff"] is not None for b in bands) else None}

            # ---- H2 (items 8, A, D, I)
            def crack_ind(e):
                if e == "both":
                    return (L["E1"] == CRACK) & (L["E2"] == CRACK)
                return L[e] == CRACK

            S["H2"] = {}
            for c4name in ("U4", "C4_all"):
                S["H2"][c4name] = {}
                entered = np.intersect1d(np.unique(prompt[pop["U2"]]), np.unique(prompt[pop[c4name]]))
                for e in ("E1", "E2", "both"):
                    ci_ = crack_ind(e)
                    bands2 = []
                    # per-prompt accumulators over cells: sums and counts of cell fractions
                    acc: dict[int, list] = {}
                    for t in range(3):
                        m2 = pop["U2"] & (tert == t)
                        m4 = pop[c4name] & (tert == t)
                        q2, g2 = per_prompt_fraction(prompt[m2], ci_[m2])
                        q4, g4 = per_prompt_fraction(prompt[m4], ci_[m4])
                        common = np.intersect1d(q2, q4)
                        a2, a4 = g2[np.isin(q2, common)], g4[np.isin(q4, common)]
                        for pid, x2, x4 in zip(common.tolist(), a2.tolist(), a4.tolist()):
                            s = acc.setdefault(pid, [0.0, 0.0, 0])
                            s[0] += x2
                            s[1] += x4
                            s[2] += 1
                        bands2.append({
                            "tertile": t, "n_prompts": int(len(common)),
                            "n_C2_unique": int((pop["C2_all"] & (tert == t)).sum()),
                            "n_C2_novel": int(m2.sum()),
                            "n_C4_all": int((pop["C4_all"] & (tert == t)).sum()),
                            "n_C4_novel": int((pop["U4"] & (tert == t)).sum()),
                            "C1_crack": fnum(a2.mean() if len(common) else None),
                            "C4_crack": fnum(a4.mean() if len(common) else None),
                            "diff": fnum((a2 - a4).mean() if len(common) else None)})
                    if acc:
                        c1v = np.array([s[0] / s[2] for s in acc.values()])
                        c4v = np.array([s[1] / s[2] for s in acc.values()])
                        c1_point, c4_point = float(c1v.mean()), float(c4v.mean())
                        c4_ci = ci95(boot_means(c4v, n_boot, rng))
                        diff_ci = ci95(boot_means(c1v - c4v, n_boot, rng))
                        fired = bool(c1_point <= c4_ci[1])
                        diff = float((c1v - c4v).mean())
                    else:
                        c1_point = c4_point = diff = fired = None
                        c4_ci = diff_ci = [None, None]
                    S["H2"][c4name][e] = {
                        "bands": bands2, "n_prompts": len(acc),
                        "n_prompts_entered": int(len(entered)),
                        "n_prompts_dropped_no_common_tertile": int(len(entered) - len(acc)),
                        "C1_crack": c1_point, "C4_crack": c4_point, "C4_ci95": c4_ci,
                        "diff_descriptive": diff, "diff_ci95_descriptive": diff_ci,
                        "K_H2_fired": fired, "status": None if fired is None else ("dead" if fired else "survives")}
                st = {e: S["H2"][c4name][e]["status"] for e in EMB}
                if any(v is None for v in st.values()):
                    overall = None
                elif all(v == "survives" for v in st.values()):
                    overall = "survives"
                elif all(v == "dead" for v in st.values()):
                    overall = "dead"
                else:
                    overall = "embedding-dependent"
                S["H2"][c4name]["verdict"] = {"by_embedding": st, "H2": overall,
                                              "K_H2_fired_by_embedding": {e: S["H2"][c4name][e]["K_H2_fired"] for e in EMB}}

            # ---- H3: invalid rate by zone among parsed C1 samples (as sampled)
            m1 = pop["C1_parsed"]
            inv = (~valid[m1]).astype(float)
            pr1 = prompt[m1]
            c1c = Z.get("c1_counts")
            S["H3"] = {"n_parsed": int(m1.sum()), "overall_invalid_rate": fnum(inv.mean() if m1.sum() else None),
                       "unparseable_fraction": fnum(1 - c1c["parsed"] / c1c["samples"]) if c1c else None}
            ids, inv_p = np.unique(pr1, return_inverse=True) if m1.sum() else (np.array([]), np.array([]))
            P = len(ids)
            n_p = np.bincount(inv_p, minlength=P).astype(float) if P else np.array([])
            i_p = np.bincount(inv_p, weights=inv, minlength=P) if P else np.array([])
            for e in EMB:
                z = L[e][m1]
                per_zone = {}
                for k, name in enumerate(ZONE_NAMES):
                    sel = z == k
                    rate = fnum(inv[sel].mean() if sel.sum() else None)
                    ratio = fnum(rate / inv.mean()) if (rate is not None and inv.mean() > 0) else None
                    ratios = np.full(n_boot, np.nan)
                    if P and sel.sum():
                        n_pk = np.bincount(inv_p, weights=sel.astype(float), minlength=P)
                        i_pk = np.bincount(inv_p, weights=inv * sel, minlength=P)
                        for a in range(0, n_boot, 1000):
                            b = min(n_boot, a + 1000)
                            w = rng.multinomial(P, np.full(P, 1.0 / P), size=b - a).astype(float)
                            ov = (w @ i_p) / (w @ n_p)
                            nk = w @ n_pk
                            with np.errstate(divide="ignore", invalid="ignore"):
                                zk = np.where(nk > 0, (w @ i_pk) / nk, np.nan)
                                ratios[a:b] = np.where(ov > 0, zk / ov, np.nan)
                    per_zone[name] = {"n": int(sel.sum()), "invalid_rate": rate, "enrichment": ratio,
                                      "enrichment_ci95": ci95(ratios)}
                ce, ee = per_zone["crack"]["enrichment"], per_zone["exterior"]["enrichment"]
                per_zone["crack_minus_exterior_enrichment"] = fnum(ce - ee) if (ce is not None and ee is not None) else None
                S["H3"][e] = per_zone

            # ---- kappa and zone fractions per condition
            S["kappa"], S["zone_fractions"] = {}, {}
            for name, m in pop.items():
                if m.sum() == 0:
                    S["kappa"][name] = None
                    continue
                S["kappa"][name] = fnum(cohen_kappa(L["E1"][m], L["E2"][m]))
                zf = {e: {zn: fnum((L[e][m] == k).mean()) for k, zn in enumerate(ZONE_NAMES)} for e in EMB}
                zf["joint_exterior"] = fnum(joint_ext[m].mean())
                if name not in ("B_novel", "B_all"):
                    _, fr = per_prompt_fraction(prompt[m], joint_ext[m])
                    zf["joint_exterior_per_prompt_mean"] = fnum(fr.mean())
                    zf["n_prompts"] = int(len(fr))
                zf["n_rows"] = int(m.sum())
                S["zone_fractions"][name] = zf

            out["by_setting"][rule][d] = S

    # ---- descriptives independent of the rule: Z_U and nn-distance quantiles per condition
    for e in EMB:
        out["descriptives"][e] = {}
        for d in dims:
            nn = np.asarray(Z["nn_dist"][e][d])
            block = {"radii": Z["radii"][e][d], "reduction": Z.get("reduction", {}).get(e, {}).get(d)}
            for bname in ("B_novel", "B_all"):
                dB = nn[pop[bname]]
                zu = {}
                for name in ("U2", "C2_all", "U3", "U4", "C4_all", "C1_parsed"):
                    dC = nn[pop[name]]
                    if len(dC) < 2 or len(dB) < 2:
                        zu[name] = None
                        continue
                    u = mannwhitneyu(dC, dB, alternative="two-sided")
                    n1, n2 = len(dC), len(dB)
                    zu[name] = fnum((u.statistic - n1 * n2 / 2) / np.sqrt(n1 * n2 * (n1 + n2 + 1) / 12))
                block[f"Z_U_vs_{bname}"] = zu
            block["nn_dist_quantiles"] = {
                name: {q: fnum(np.quantile(nn[m], float(q))) for q in ("0.1", "0.5", "0.9", "0.99")}
                for name, m in pop.items() if m.sum()}
            out["descriptives"][e][d] = block

    # ---- registered verdicts at (primary, d_reg) with rule dependence
    reg = out["by_setting"]["primary"][d_reg]
    alt = out["by_setting"]["alternative"][d_reg] if "alternative" in out["by_setting"] else None
    verdicts = {
        "setting": {"rule": "primary", "d": int(d_reg)},
        "K2_fired": k2["fired"], "K_agree_fired": k_agree["fired"],
        "H1_status": "descriptive only (K-agree fired)" if k_agree["fired"] else ("dead (K1)" if reg["H1"]["K1_fired"] else "survives"),
        "K1_fired": reg["H1"]["K1_fired"], "H1_diff": reg["H1"]["diff"], "H1_ci95": reg["H1"]["ci95"],
        "K1m_fired": reg["H1m"]["K1m_fired"], "H1m_reversed": reg["H1m"]["reversed"],
        "H1m_diff": reg["H1m"]["diff"], "H1m_ci95": reg["H1m"]["ci95"],
        "H1_length_control_robust": reg["H1_length_control"]["robust"],
        "H2": reg["H2"]["U4"]["verdict"],
        "n_prompts_H1": reg["H1"]["n_prompts_C3"], "n_prompts_H1m": reg["H1m"]["n_prompts"],
    }
    if alt is not None:
        verdicts["alternative_rule"] = {
            "K1_fired": alt["H1"]["K1_fired"], "K1m_fired": alt["H1m"]["K1m_fired"],
            "H2": alt["H2"]["U4"]["verdict"],
            "H1_length_control_robust": alt["H1_length_control"]["robust"]}
        verdicts["rule_dependent"] = {
            "K1": alt["H1"]["K1_fired"] != reg["H1"]["K1_fired"],
            "K1m": alt["H1m"]["K1m_fired"] != reg["H1m"]["K1m_fired"],
            "H1_length_control_robust": alt["H1_length_control"]["robust"] != reg["H1_length_control"]["robust"],
            "H2": alt["H2"]["U4"]["verdict"]["H2"] != reg["H2"]["U4"]["verdict"]["H2"],
            "K2": bool(k2["rule_dependent_embeddings"])}

    # ---- Monte Carlo rerun trigger (item H)
    reasons = []
    if near(reg["H1"]["ci95"][0], 0):
        reasons.append("H1 CI lower bound within 0.02 of zero")
    if reg["H1m"]["K1m_fired"] is not None and (near(reg["H1m"]["ci95"][0], 0) or near(reg["H1m"]["ci95"][1], 0)):
        reasons.append("H1m CI bound within 0.02 of zero")
    for e in EMB:
        h2e = reg["H2"]["U4"][e]
        if near(h2e["C4_ci95"][1], h2e["C1_crack"]):
            reasons.append(f"K-H2 {e}: C4 CI upper bound within 0.02 of C1's crack fraction")
        for rule in rules:
            if near(k2["crack_fraction"][e][rule], K2_THRESHOLD):
                reasons.append(f"K2 {e} {rule}: held-out crack fraction within 0.02 of 0.05")
    n_mc = Z.get("n_mc", Z["registered"].get("n_mc"))
    out["mc_rerun"] = {"n_mc_used": n_mc, "recommended": bool(reasons) and n_mc != 1024, "reasons": reasons,
                       "is_rerun": n_mc == 1024}

    out["registered_verdicts"] = verdicts
    out["profile"] = Z["profile"]
    out["model_seed"] = Z["model_seed"]
    out["run_record"] = Z.get("run_record")
    out["heldout_novel_count"] = int(pop["B_novel"].sum())
    out["temperature"] = Z.get("temperature")
    out["n_mc"] = n_mc
    out["n_boot"] = n_boot
    out["boot_seed"] = seed
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--profile", default="main")
    ap.add_argument("--seed", type=int, default=0)
    ap.add_argument("--temperature", type=float, default=1.0)
    ap.add_argument("--n-mc", type=int, default=256)
    ap.add_argument("--n-boot", type=int, default=N_BOOT)
    ap.add_argument("--zones", default=None)
    args = ap.parse_args()
    t0 = time.time()
    suffix = "" if args.n_mc == 256 else f"-mc{args.n_mc}"
    stem = f"{args.profile}-seed{args.seed}-T{args.temperature:g}{suffix}"
    path = Path(args.zones) if args.zones else HERE / "out" / f"zones-{stem}.json"
    Z = json.loads(path.read_text(encoding="utf-8"))
    if Z["profile"] in REGISTERED_PROFILES and args.n_boot != N_BOOT:
        raise AssertionError(f"registered runs use {N_BOOT} resamples; --n-boot override refused (postscript G)")
    res = analyze(Z, n_boot=args.n_boot)
    res.update({"ranAt": datetime.now(timezone.utc).isoformat(), "profile": Z["profile"],
                "model_seed": Z["model_seed"], "zones_file": path.name, "zones_ranAt": Z["ranAt"],
                "conditions_file": Z.get("conditions_file"), "seconds": round(time.time() - t0, 1)})
    zmc = Z.get("n_mc", 256)
    out = HERE / "out" / f"analysis-{Z['profile']}-seed{Z['model_seed']}-T{Z.get('temperature', 1.0):g}" \
                         f"{'' if zmc == 256 else f'-mc{zmc}'}.json"
    out.write_text(json.dumps(res, indent=1), encoding="utf-8")
    print(json.dumps(res["registered_verdicts"], indent=2))
    print(json.dumps(res["mc_rerun"]))
    print("wrote", out)
    return 0


if __name__ == "__main__":
    sys.exit(main())
