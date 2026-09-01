// Accretion study, Phase D — EXPLORATORY grid (SPEC-D sections 2-3).
// Replicate-first, battery v2, scores nothing: maps which candidate
// rules move mean Delta_ER positive (the field ordering) at matched
// six-feature battery. Any rule at mean > 0 with |t| >= 3 graduates
// to a sealed confirmatory run on seeds this tier never touched.
//
// R = 5 universes per rule; seeds 930000+100r+off (grow),
// 935000+100r+off (estimator); N = 30k; battery: 6.

import { writeFileSync } from "node:fs";
import { grow, toSnaps, runEstimator } from "./sim-lib.mjs";

const N = 30000;
const SCHEDULE = [5000, 10000, 15000, 20000, 25000, 30000];
const OPTS = { baselines: [0, 1, 2, 3], horizon: 2, kernelCap: 300, battery: 6 };

const CONFIGS = [
  ["SIB", { type: "SIB" }, 0],
  ["FRONT(2000)", { type: "FRONT", K: 2000 }, 1],
  ["MIX(0.5)", { type: "MIX", p: 0.5 }, 2],
];
const R = 5;

const summarize = (xs) => {
  const n = xs.length;
  if (!n) return { R: 0 };
  const mu = xs.reduce((s, v) => s + v, 0) / n;
  const sd = n > 1 ? Math.sqrt(xs.reduce((s, v) => s + (v - mu) * (v - mu), 0) / (n - 1)) : 0;
  return { R: n, mu: +mu.toFixed(4), sd: +sd.toFixed(4), t: sd ? +(mu / (sd / Math.sqrt(n))).toFixed(2) : null };
};

const out = {};
for (const [label, rule, off] of CONFIGS) {
  const er = [], ed = [];
  let evaluable = 0, pairsER = 0;
  for (let r = 0; r < R; r++) {
    const grown = grow(rule, N, SCHEDULE, 930000 + 100 * r + off);
    const snaps = toSnaps(grown, SCHEDULE);
    const res = runEstimator(snaps, { ...OPTS, seed: 935000 + 100 * r + off });
    const line = `  ${label} u${r}: kernels=${res.kernels} ER=${res.ER.verdict ?? res.ER.obs} ED=${res.ED.verdict ?? res.ED.obs}`;
    console.log(line + (res.ER.obs !== undefined ? ` | ER obs=${res.ER.obs} pairs=${res.ER.pairs} | ED obs=${res.ED.obs}` : ""));
    if (res.ER.obs !== undefined) { er.push(res.ER.obs); pairsER += res.ER.pairs; evaluable++; }
    if (res.ED.obs !== undefined) ed.push(res.ED.obs);
  }
  out[label] = { evaluable, meanPairsER: evaluable ? Math.round(pairsER / evaluable) : 0,
                 ER: summarize(er), ED: summarize(ed) };
  console.log(`${label}: ER ${JSON.stringify(out[label].ER)} | ED ${JSON.stringify(out[label].ED)}`);
}
writeFileSync("accretion-study/results-explore-d.json", JSON.stringify(out, null, 1));
console.log("wrote accretion-study/results-explore-d.json");
