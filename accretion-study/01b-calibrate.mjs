// Accretion study, Phase A addendum — NULL CALIBRATION BY REPLICATE
// UNIVERSES (exploratory tier; instrument audit).
//
// WHY THIS EXISTS: the first exploratory grid showed the estimator
// returning significant verdicts on PROVABLY NULL generators:
//   U  ER: obs -0.0286, sign-flip band ±0.009  -> "REVERSES"
//   PA ER: obs +0.0604, sign-flip band ±0.011  -> "HOLDS"
// Under U, every alive node has identical expected gain conditional on
// the baseline graph (each future edge lands uniformly), so ANY
// systematic verdict is an estimator artifact. Under PA at matched
// baseline in-degree, the two members' gain processes are exchangeable
// (attachment reads evolving degree only, and matched members start at
// equal degree), so the same holds. The suspected mechanism: the
// within-pair sign-flip null assumes independent pairs, but members
// recur across kernels and pairs share the one realized universe, so
// the reported null band understates the true sampling variance of the
// paired-mean statistic.
//
// THE CALIBRATION: for each rule, grow R = 20 independent universes
// (fresh seeds), compute the OBSERVED Delta_ER and Delta_ED point
// estimates in each, and compare the across-universe spread with the
// within-universe sign-flip band. If the across-universe SD is several
// times the sign-flip band and the across-universe mean is ~0 for U
// and PA, the estimator's point statistic is unbiased but its
// significance calibration is broken — for synthetic AND field
// results alike. Field re-calibration follows separately.
//
// Exploratory tier: no confirmatory weight; seed set A continues.

import { writeFileSync } from "node:fs";
import { grow, toSnaps, runEstimator } from "./sim-lib.mjs";

const N = 30000;
const SCHEDULE = [5000, 10000, 15000, 20000, 25000, 30000];
const BASELINES = [0, 1, 2, 3];
const HORIZON = 2;
const KERNEL_CAP = 300;
const REPLICATES = 20;

const RULES = [["U", "U"], ["PA", "PA"], ["PC(0)", 0]];

const stats = (xs) => {
  const mu = xs.reduce((s, v) => s + v, 0) / xs.length;
  const sd = Math.sqrt(xs.reduce((s, v) => s + (v - mu) * (v - mu), 0) / (xs.length - 1));
  return { mu: +mu.toFixed(4), sd: +sd.toFixed(4), min: +Math.min(...xs).toFixed(4), max: +Math.max(...xs).toFixed(4) };
};

const out = {};
for (const [label, rule] of RULES) {
  const er = [], ed = [], bandsER = [], bandsED = [];
  for (let r = 0; r < REPLICATES; r++) {
    const grown = grow(rule, N, SCHEDULE, 905000 + 100 * r + (label === "U" ? 1 : label === "PA" ? 2 : 3));
    const snaps = toSnaps(grown, SCHEDULE);
    const res = runEstimator(snaps, { baselines: BASELINES, horizon: HORIZON, kernelCap: KERNEL_CAP, seed: 905999 + r });
    if (res.ER.obs !== undefined) { er.push(res.ER.obs); bandsER.push((res.ER.hi - res.ER.lo) / 2); }
    if (res.ED.obs !== undefined) { ed.push(res.ED.obs); bandsED.push((res.ED.hi - res.ED.lo) / 2); }
  }
  const sER = stats(er), sED = stats(ed);
  const bER = +(bandsER.reduce((s, v) => s + v, 0) / bandsER.length).toFixed(4);
  const bED = +(bandsED.reduce((s, v) => s + v, 0) / bandsED.length).toFixed(4);
  out[label] = { er: sER, ed: sED, meanSignFlipHalfBandER: bER, meanSignFlipHalfBandED: bED,
                 inflationER: +(sER.sd / (bER / 1.96)).toFixed(2), inflationED: +(sED.sd / (bED / 1.96)).toFixed(2) };
  console.log(`${label}: Delta_ER across ${er.length} universes: mu=${sER.mu} sd=${sER.sd} range=[${sER.min},${sER.max}] | sign-flip half-band ${bER} | variance inflation x${out[label].inflationER}`);
  console.log(`     Delta_ED: mu=${sED.mu} sd=${sED.sd} range=[${sED.min},${sED.max}] | half-band ${bED} | inflation x${out[label].inflationED}`);
}
writeFileSync("accretion-study/results-calibrate.json", JSON.stringify(out, null, 1));
console.log("wrote accretion-study/results-calibrate.json");
