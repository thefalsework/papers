// Accretion study, Phase B-prime — REPLICATE-BASED CONFIRMATION
// (registered before first run; supersedes the cancelled single-universe
// Phase B; see SPEC.md postscripts of 2026-09-01).
//
// DESIGN PRINCIPLE, LEARNED THE HARD WAY: a single universe cannot
// certify a generator. Every verdict below is computed ACROSS
// INDEPENDENT UNIVERSES grown from seeds never used in Phase A
// (fresh base 910000; Phase A used 900xxx/905xxx). The statistic per
// rule and contrast is the across-universe mean of the Debian-grade
// estimator's point value (which Phase A's calibration showed to be
// unbiased on null generators), judged against its across-universe
// standard error. No within-universe permutation percentile appears
// anywhere in this file's verdicts.
//
// REGISTERED PREDICTIONS (thresholds fixed now):
//   B1 (null confirmation, fresh seeds): U and PA, R = 20 universes
//     each — both contrasts come out |t| < 2 (t = mean/SE). If any
//     |t| >= 3, the estimator is BIASED (not just miscalibrated) and
//     every field point estimate is suspect: report at full volume.
//   B2 (the Phase-A discovery, fresh seeds): PC(0), R = 20 —
//     t_ER <= -3 AND t_ED >= +3 (the replicated R > E > D signature).
//     CONFIRMS establishes the program's first generator-level theorem
//     target: cone-local accretion favors, at matched battery, the
//     members OUTSIDE the kernel's claimed territory, inverting the
//     field pattern of Go/Debian. FAILS (opposite signs at |t| >= 3)
//     sends the conjecture back again; anything else is NULL.
//   B3 (descriptive, scores nothing): beta gradient, PC(0.25/0.5/
//     0.75/1), R = 10 each — the across-universe mean curve of both
//     contrasts, to locate where (if anywhere) the R > E > D signature
//     dies as footprint breadth grows.
//
// Constants: N = 30,000; schedule 5k..30k step 5k; baselines 0..3;
// horizon +2; kernel cap 300; estimator = sim-lib runEstimator
// (caliper 0.5, SMD gate 0.10, side cap 300), point values only.
//
// Writes accretion-study/results-confirm.json.

import { writeFileSync } from "node:fs";
import { grow, toSnaps, runEstimator } from "./sim-lib.mjs";

const N = 30000;
const SCHEDULE = [5000, 10000, 15000, 20000, 25000, 30000];
const OPTS = { baselines: [0, 1, 2, 3], horizon: 2, kernelCap: 300 };

const CONFIGS = [
  ["U", "U", 20, 0], ["PA", "PA", 20, 1], ["PC(0)", 0, 20, 2],
  ["PC(0.25)", 0.25, 10, 3], ["PC(0.5)", 0.5, 10, 4],
  ["PC(0.75)", 0.75, 10, 5], ["PC(1)", 1, 10, 6],
];

const summarize = (xs) => {
  const R = xs.length;
  const mu = xs.reduce((s, v) => s + v, 0) / R;
  const sd = Math.sqrt(xs.reduce((s, v) => s + (v - mu) * (v - mu), 0) / (R - 1));
  const se = sd / Math.sqrt(R);
  return { R, mu: +mu.toFixed(4), sd: +sd.toFixed(4), se: +se.toFixed(4),
           t: +(mu / se).toFixed(2), pos: xs.filter((v) => v > 0).length };
};

const out = {};
for (const [label, rule, R, off] of CONFIGS) {
  const er = [], ed = [];
  let pairsER = 0, pairsED = 0, used = 0;
  for (let r = 0; r < R; r++) {
    const grown = grow(rule, N, SCHEDULE, 910000 + 100 * r + off);
    const snaps = toSnaps(grown, SCHEDULE);
    const res = runEstimator(snaps, { ...OPTS, seed: 915000 + 100 * r + off });
    if (res.ER.obs !== undefined && res.ED.obs !== undefined) {
      er.push(res.ER.obs); ed.push(res.ED.obs);
      pairsER += res.ER.pairs; pairsED += res.ED.pairs; used++;
    }
  }
  const sER = summarize(er), sED = summarize(ed);
  out[label] = { universes: used, ER: sER, ED: sED,
                 meanPairsER: Math.round(pairsER / used), meanPairsED: Math.round(pairsED / used) };
  console.log(`${label}: R=${used} | ER mu=${sER.mu} sd=${sER.sd} t=${sER.t} (${sER.pos}/${sER.R} pos) | ED mu=${sED.mu} sd=${sED.sd} t=${sED.t} (${sED.pos}/${sED.R} pos)`);
}

// registered verdicts
const v = {};
const nullOk = (s) => Math.abs(s.t) < 2;
const biased = (s) => Math.abs(s.t) >= 3;
v.B1_U = nullOk(out.U.ER) && nullOk(out.U.ED) ? "CONFIRMS-NULL"
  : biased(out.U.ER) || biased(out.U.ED) ? "BIAS DETECTED" : "INDETERMINATE";
v.B1_PA = nullOk(out.PA.ER) && nullOk(out.PA.ED) ? "CONFIRMS-NULL"
  : biased(out.PA.ER) || biased(out.PA.ED) ? "BIAS DETECTED" : "INDETERMINATE";
v.B2 = out["PC(0)"].ER.t <= -3 && out["PC(0)"].ED.t >= 3 ? "CONFIRMS"
  : out["PC(0)"].ER.t >= 3 && out["PC(0)"].ED.t <= -3 ? "FAILS BY REVERSAL" : "NULL";
console.log(JSON.stringify(v, null, 1));
out.verdicts = v;
writeFileSync("accretion-study/results-confirm.json", JSON.stringify(out, null, 1));
console.log("wrote accretion-study/results-confirm.json");

// ---------------------------------------------------------------------
// POSTSCRIPT (2026-09-01, written after the single registered run;
// results-confirm.json is the artifact; 37 minutes, 100 universes).
//
// ALL THREE REGISTERED VERDICTS LANDED.
//
// B1 CONFIRMS-NULL, both rules. U: t_ER = -0.89, t_ED = -1.78.
// PA: t_ER = -1.22, t_ED = -1.34. On seeds no exploratory eye ever
// saw, the estimator reads zero where zero is the truth — the
// empirical half of THEORY.md Propositions 1-2.
//
// B2 CONFIRMS, far past threshold. PC(0): t_ER = -10.23 with 0 of 20
// universes positive; t_ED = +10.77 with 20 of 20 positive. Cone-local
// accretion forces R > E > D at matched battery as a GENERATOR-LEVEL
// fact — the program's first confirmed theorem target about growth
// rules, and the constructive proof that a baseline-definable cell can
// out-inform the full reviewer battery (per the THEORY.md flux law:
// the flux tracks up-set size, which the battery does not carry).
//
// B3 (descriptive): the two contrasts DECOUPLE across the beta
// gradient, and not in the naively expected way.
//   ER mean: -0.172 (beta 0) -> -0.117 -> -0.083 -> -0.043 -> -0.008
//     (beta 1): fades smoothly to zero as footprint breadth grows.
//   ED mean: +0.067 / +0.068 / +0.072 / +0.084 (beta <= 0.75), then
//     DEAD at beta 1 (-0.000, t = -0.03).
// So E-over-D tolerates substantial breadth but requires SOME cone
// component; R-over-E requires a lot of it; and at beta 1 (platform
// pick + uniform deps) BOTH die, meaning the uniform platform pick
// alone contributes nothing — every signature in this family is
// cone-locality's. The synthetic family reproduces the field's central
// dissociation (E-vs-R and E-vs-D as independent axes, cf. Debian
// holding one and reversing the other) from a single dial.
//
// Nothing here models Go/Debian (the field ordering is E > R; this
// family's is R > E). The open generative question stands as specced:
// which rule families force E > R. Registered next measurable for the
// sign problem: baseline up-set size by cell at matched battery in
// PC(0) universes (THEORY.md section 3).
// ---------------------------------------------------------------------
