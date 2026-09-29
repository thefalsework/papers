"""Registered analysis (SPEC.md, "Measures and analysis", "Kill conditions",
postscript 2026-09-29 on B).

Input: out/zones-<profile>-seed<k>.json from 07-embed-zones.py. Output:
out/analysis-<profile>-seed<k>.json. Every quantity is computed under both
calibration rules and all three PCA dimensions; the registered verdicts
(K1, K1m, K-H2, length-control robustness) are read at the primary rule
and d = 16, and rule-dependence is flagged when the alternative rule
disagrees.

Unit of analysis: the prompt. A prompt contributes the zone fraction of its
unique valid novel outputs in an arm; a prompt enters a contrast only if
every arm in the contrast has at least one such output. B's unit is the
held-out formula; B is the term-novel subset of held-out proofs (postscript
2026-09-29), with all-held-out B reported as a secondary descriptive.

What is computed, with the spec location that fixes each choice:
  * H1 ("Measures and analysis"; postscript 2026-09-29 on B): joint
    (both-embedding) exterior fraction, mean over prompts where C3 has a
    unique valid novel output, minus the mean over term-novel B formulas.
    Independent bootstrap of the two means, 10,000 resamples, 95%
    percentile CI. K1 fires if the CI includes zero or is negative.
  * H1m (postscript "Conditions", item 7): C3 - C2 (= C3 - C1-valid) on the
    prompts where both have a unique valid novel output, paired bootstrap
    over prompts. One statistic, reported once as H1m. K1m fires if H1
    survives and H1m's CI includes zero.
  * Length control ("Measures and analysis"): H1's difference within
    proof-size tertiles fixed on the full held-out set; robust if positive
    in at least two of three bands.
  * H2 (postscript "Conditions", item 8): per embedding at the primary rule
    and d = 16; per-prompt crack fraction of C1's unique valid novel
    outputs minus that of C4's novel outputs within tertiles, pooled over
    (prompt, tertile) cells, cluster bootstrap over prompts. H2 passes in an
    embedding if the difference CI lies above zero; K-H2 fires in an
    embedding if C1's point estimate is not above C4's CI upper bound. H2
    passes only if it passes in both E1 and E2; one embedding only is
    "embedding-dependent"; K-H2 is read the same way. C4 over all outputs
    and crack-in-both are descriptive.
  * H3 ("Hypotheses", H3): among raw C1 samples that parse, invalid rate by
    zone divided by the overall invalid rate, per embedding; cluster
    bootstrap over prompts. The unparseable fraction is reported.
  * Kappa between E1 and E2 zone labels per condition and rule ("Kill
    conditions", K-agree, extended to every condition).
  * Meehan Z_U ("Measures and analysis"): z-scored Mann-Whitney U on
    nearest-training-point distance, condition rows vs B rows, per
    embedding; Z_U << 0 means closer to training than B, >> 0 further.

Usage: python 08-analysis.py --profile main --seed 0 [--n-boot 10000]
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
ARMS = ("B", "C1", "C2", "C3", "C4")
EMB = ("E1", "E2")


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


# ----------------------------------------------------------------------------
# analysis


def analyze(Z: dict, n_boot: int = N_BOOT, seed: int = BOOT_SEED) -> dict:
    rows = Z["rows"]
    arm = np.array([r["arm"] for r in rows])
    prompt = np.array([r["prompt"] for r in rows], dtype=int)
    valid = np.array([bool(r["valid"]) for r in rows])
    novel = np.array([bool(r["novel"]) if r["novel"] is not None else False for r in rows])
    size = np.array([r["term_size"] for r in rows], dtype=float)
    tb = Z["tertile_bounds"]
    lo, hi = float(tb["lo"]), float(tb["hi"])
    dims = [str(Z["registered"]["d"])] + [str(d) for d in Z["registered"]["d_sensitivity"]]
    rules = tuple(Z["registered"]["rules"])
    d_reg = str(Z["registered"]["d"])

    # ---- halting assertions
    chk = Z.get("checks", {})
    if not (chk.get("fingerprint_match") and chk.get("tertiles_from_full_heldout")):
        raise AssertionError("zones file does not certify identical novelty and full-held-out tertiles")
    if tb["n_heldout_used"] != tb["n_heldout"] or tb["n_heldout"] != int((arm == "B").sum()):
        raise AssertionError("tertile boundaries were not computed on the full held-out set")
    b_sizes = np.sort(size[arm == "B"])
    if abs(np.quantile(b_sizes, 1 / 3) - lo) > 1e-9 or abs(np.quantile(b_sizes, 2 / 3) - hi) > 1e-9:
        raise AssertionError("tertile boundaries do not match the held-out proof sizes in the file")
    bc = chk.get("budget", {})
    if "prompts" not in bc:
        raise AssertionError("zones file does not certify the draw-budget check")
    for e in EMB:
        for d in dims:
            nn = np.asarray(Z["nn_dist"][e][d])
            for rule in rules:
                lab = np.asarray(Z["labels"][e][d][rule])
                r = Z["radii"][e][d][rule]
                if not np.array_equal(lab == INSIDE, nn <= r):
                    raise AssertionError(f"{e} d={d} {rule}: inside label inconsistent with nn distance and r")
                # inside <= closing was asserted when labels were made; the label set
                # {inside, crack, exterior} is the only witness left here
                if not np.all(np.isin(lab, [INSIDE, CRACK, EXTERIOR])):
                    raise AssertionError("unknown zone label")

    tert = tertile_of(size, lo, hi)
    rng = np.random.default_rng(seed)
    out = {"by_setting": {}, "descriptives": {}}

    # populations (novelty-filtered, unique outputs: rows are already unique per prompt in C2/C3/C4)
    pop = {
        "B_novel": (arm == "B") & novel, "B_all": arm == "B",
        "U2": (arm == "C2") & novel, "U3": (arm == "C3") & novel,
        "U4": (arm == "C4") & novel, "C4_all": arm == "C4",
        "C1_parsed": arm == "C1",
    }

    for rule in rules:
        out["by_setting"][rule] = {}
        for d in dims:
            L = {e: np.asarray(Z["labels"][e][d][rule]) for e in EMB}
            joint_ext = (L["E1"] == EXTERIOR) & (L["E2"] == EXTERIOR)
            S: dict = {}

            # ---- H1: C3 vs B (joint exterior)
            def h1_block(Bmask):
                b = joint_ext[Bmask].astype(float)
                p3, f3 = per_prompt_fraction(prompt[pop["U3"]], joint_ext[pop["U3"]])
                point = float(f3.mean() - b.mean()) if len(f3) and len(b) else None
                boot = boot_means(f3, n_boot, rng) - boot_means(b, n_boot, rng)
                ci = ci95(boot)
                return {"n_prompts_C3": int(len(f3)), "n_B": int(len(b)),
                        "C3_joint_exterior": fnum(f3.mean() if len(f3) else None),
                        "B_joint_exterior": fnum(b.mean() if len(b) else None),
                        "diff": point, "ci95": ci,
                        "K1_fired": None if ci[0] is None else bool(ci[0] <= 0)}
            S["H1"] = h1_block(pop["B_novel"])
            S["H1_B_all_descriptive"] = h1_block(pop["B_all"])

            # ---- H1m: C3 - C2 on the matched set (postscript item 7: one statistic, reported once)
            p2, f2 = per_prompt_fraction(prompt[pop["U2"]], joint_ext[pop["U2"]])
            p3, f3 = per_prompt_fraction(prompt[pop["U3"]], joint_ext[pop["U3"]])
            both = np.intersect1d(p2, p3)
            d23 = f3[np.isin(p3, both)] - f2[np.isin(p2, both)]
            ci23 = ci95(boot_means(d23, n_boot, rng))
            k1 = S["H1"]["K1_fired"]
            S["H1m"] = {
                "n_prompts": int(len(both)), "C3": fnum(f3[np.isin(p3, both)].mean() if len(both) else None),
                "C2_equals_C1_valid": fnum(f2[np.isin(p2, both)].mean() if len(both) else None),
                "diff": fnum(d23.mean() if len(both) else None), "ci95": ci23,
                "K1m_fired": None if (k1 is None or ci23[0] is None) else bool((not k1) and ci23[0] <= 0)}

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

            # ---- H2 within tertiles: C1 valid novel crack vs C4 crack
            def crack_ind(e):
                if e == "both":
                    return (L["E1"] == CRACK) & (L["E2"] == CRACK)
                return L[e] == CRACK

            S["H2"] = {}
            for c4name in ("U4", "C4_all"):
                S["H2"][c4name] = {}
                for e in ("E1", "E2", "both"):
                    ci_ = crack_ind(e)
                    bands2, cells = [], []  # cells: (prompt, c1_frac, c4_frac) per (prompt, tertile)
                    for t in range(3):
                        m2 = pop["U2"] & (tert == t)
                        m4 = pop[c4name] & (tert == t)
                        q2, g2 = per_prompt_fraction(prompt[m2], ci_[m2])
                        q4, g4 = per_prompt_fraction(prompt[m4], ci_[m4])
                        common = np.intersect1d(q2, q4)
                        a2, a4 = g2[np.isin(q2, common)], g4[np.isin(q4, common)]
                        cells.extend(zip(common.tolist(), a2.tolist(), a4.tolist()))
                        bands2.append({
                            "tertile": t, "n_prompts": int(len(common)),
                            "C1_crack": fnum(a2.mean() if len(common) else None),
                            "C4_crack": fnum(a4.mean() if len(common) else None),
                            "diff": fnum((a2 - a4).mean() if len(common) else None)})
                    # pooled over (prompt, tertile) cells; cluster bootstrap over prompts
                    if cells:
                        cp = np.array([c[0] for c in cells])
                        c1v = np.array([c[1] for c in cells])
                        c4v = np.array([c[2] for c in cells])
                        pid, inv_c = np.unique(cp, return_inverse=True)
                        P2 = len(pid)
                        cnt = np.bincount(inv_c, minlength=P2).astype(float)
                        s1 = np.bincount(inv_c, weights=c1v, minlength=P2)
                        s4 = np.bincount(inv_c, weights=c4v, minlength=P2)
                        bd, b4 = np.empty(n_boot), np.empty(n_boot)
                        for a in range(0, n_boot, 1000):
                            b = min(n_boot, a + 1000)
                            w = rng.multinomial(P2, np.full(P2, 1.0 / P2), size=b - a).astype(float)
                            tot = w @ cnt
                            bd[a:b] = (w @ (s1 - s4)) / tot
                            b4[a:b] = (w @ s4) / tot
                        c1_point, c4_point, diff = float(c1v.mean()), float(c4v.mean()), float((c1v - c4v).mean())
                        diff_ci, c4_ci = ci95(bd), ci95(b4)
                        passes = bool(diff_ci[0] > 0)
                        fired = bool(c1_point <= c4_ci[1])
                    else:
                        c1_point = c4_point = diff = None
                        diff_ci = c4_ci = [None, None]
                        passes = fired = None
                    S["H2"][c4name][e] = {
                        "bands": bands2, "n_cells": len(cells), "n_prompts": int(len({c[0] for c in cells})),
                        "C1_crack": c1_point, "C4_crack": c4_point, "C4_ci95": c4_ci,
                        "diff": diff, "diff_ci95": diff_ci, "passes": passes, "K_H2_fired": fired}
                # postscript item 8: pass requires both embeddings; one only is embedding-dependent
                pe = {e: S["H2"][c4name][e]["passes"] for e in EMB}
                fe = {e: S["H2"][c4name][e]["K_H2_fired"] for e in EMB}

                def read(flags, yes, no):
                    vals = list(flags.values())
                    if any(v is None for v in vals):
                        return None
                    return yes if all(vals) else (no if not any(vals) else "embedding-dependent")
                # the pass test (difference CI above zero) and the kill test (C1 point vs C4's
                # CI) are different tests as the spec defines them and can disagree; report it
                disagree = {e: (pe[e] is not None and fe[e] is not None and pe[e] == fe[e]) for e in EMB}
                S["H2"][c4name]["verdict"] = {
                    "passes_by_embedding": pe, "H2": read(pe, "pass", "fail"),
                    "K_H2_fired_by_embedding": fe, "K_H2": read(fe, "fired", "not fired"),
                    "pass_and_kill_disagree_by_embedding": disagree,
                    "pass_and_kill_disagree": bool(any(disagree.values()))}

            # ---- H3: invalid rate by zone among parsed C1 samples
            m1 = pop["C1_parsed"]
            inv = (~valid[m1]).astype(float)
            pr1 = prompt[m1]
            c1c = Z.get("c1_counts")
            S["H3"] = {"n_parsed": int(m1.sum()), "overall_invalid_rate": fnum(inv.mean() if m1.sum() else None),
                       "unparseable_fraction": fnum(1 - c1c["parsed"] / c1c["samples"]) if c1c else None}
            # cluster bootstrap over prompts via per-prompt counts and multinomial weights
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
                S["H3"][e] = per_zone

            # ---- kappa per condition, zone fractions per condition
            S["kappa"], S["zone_fractions"] = {}, {}
            for name, m in pop.items():
                if m.sum() == 0:
                    S["kappa"][name] = None
                    continue
                S["kappa"][name] = fnum(cohen_kappa(L["E1"][m], L["E2"][m]))
                zf = {}
                for e in EMB:
                    zf[e] = {zn: fnum((L[e][m] == k).mean()) for k, zn in enumerate(ZONE_NAMES)}
                zf["joint_exterior"] = fnum(joint_ext[m].mean())
                if name in ("U2", "U3", "U4", "C4_all"):
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
                for name in ("U2", "U3", "U4", "C4_all", "C1_parsed"):
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
        "K1_fired": reg["H1"]["K1_fired"], "H1_diff": reg["H1"]["diff"], "H1_ci95": reg["H1"]["ci95"],
        "K1m_fired": reg["H1m"]["K1m_fired"], "H1m_diff": reg["H1m"]["diff"], "H1m_ci95": reg["H1m"]["ci95"],
        "H1_length_control_robust": reg["H1_length_control"]["robust"],
        "H2": reg["H2"]["U4"]["verdict"],  # postscript item 8: C4 novel-only, both embeddings
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
            "H2": alt["H2"]["U4"]["verdict"]["H2"] != reg["H2"]["U4"]["verdict"]["H2"],
            "K_H2": alt["H2"]["U4"]["verdict"]["K_H2"] != reg["H2"]["U4"]["verdict"]["K_H2"]}
    out["registered_verdicts"] = verdicts
    out["n_boot"] = n_boot
    out["boot_seed"] = seed
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--profile", default="main")
    ap.add_argument("--seed", type=int, default=0)
    ap.add_argument("--n-boot", type=int, default=N_BOOT)
    ap.add_argument("--zones", default=None)
    args = ap.parse_args()
    t0 = time.time()
    path = Path(args.zones) if args.zones else HERE / "out" / f"zones-{args.profile}-seed{args.seed}.json"
    Z = json.loads(path.read_text(encoding="utf-8"))
    res = analyze(Z, n_boot=args.n_boot)
    res.update({"ranAt": datetime.now(timezone.utc).isoformat(), "profile": Z["profile"],
                "model_seed": Z["model_seed"], "zones_file": path.name, "zones_ranAt": Z["ranAt"],
                "conditions_file": Z.get("conditions_file"), "seconds": round(time.time() - t0, 1)})
    out = HERE / "out" / f"analysis-{Z['profile']}-seed{Z['model_seed']}.json"
    out.write_text(json.dumps(res, indent=1), encoding="utf-8")
    print(json.dumps(res["registered_verdicts"], indent=2))
    print("wrote", out)
    return 0


if __name__ == "__main__":
    sys.exit(main())
