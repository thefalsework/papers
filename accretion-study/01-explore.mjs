// Accretion study, Phase A — EXPLORATORY TIER (SPEC 6, Phase A).
//
// LABELED EXPLORATION: nothing here carries confirmatory weight. This
// tier maps the landscape over the rule grid, doubles as the
// feasibility census (kernel evaluability, candidate populations, pair
// counts, balance), and doubles as the INSTRUMENT SELF-TEST: under C1,
// U and PA must come out NULL — if PA shows a battery-proof cell
// effect, the estimator leaks and the field results need re-audit.
//
// Seed set A (this tier only; Phase B uses fresh seeds):
//   growth seed = 900001 + 10 * configIndex, estimator seed = 900777.
//
// Grid (SPEC 3): U, PA, PC(0), PC(0.25), PC(0.5), PC(0.75), PC(1).
// N = 30,000; schedule 5k/10k/15k/20k/25k/30k; horizon +2;
// baselines 0..3; kernel cap 300 per baseline.
//
// Writes accretion-study/results-explore.json.

import { writeFileSync } from "node:fs";
import { grow, toSnaps, runEstimator } from "./sim-lib.mjs";

const N = 30000;
const SCHEDULE = [5000, 10000, 15000, 20000, 25000, 30000];
const BASELINES = [0, 1, 2, 3];
const HORIZON = 2;
const KERNEL_CAP = 300;
const EST_SEED = 900777;

const GRID = [
  ["U", "U"], ["PA", "PA"],
  ["PC(0)", 0], ["PC(0.25)", 0.25], ["PC(0.5)", 0.5],
  ["PC(0.75)", 0.75], ["PC(1)", 1],
];

const out = {};
GRID.forEach(([label, rule], gi) => {
  const t0 = Date.now();
  const grown = grow(rule, N, SCHEDULE, 900001 + 10 * gi);
  const snaps = toSnaps(grown, SCHEDULE);
  const res = runEstimator(snaps, { baselines: BASELINES, horizon: HORIZON, kernelCap: KERNEL_CAP, seed: EST_SEED });
  out[label] = res;
  const fmt = (r) => r.verdict === "UNINFORMATIVE" || r.verdict === "INFEASIBLE"
    ? `${r.verdict} (${r.pairs} pairs${r.maxSmd ? `, maxSMD ${r.maxSmd}` : ""})`
    : `${r.verdict} obs=${r.obs} null=[${r.lo},${r.hi}] pct=${r.pct} pairs=${r.pairs} maxSMD=${r.maxSmd}`;
  console.log(`${label}: kernels=${res.kernels} cand E/R/D=${res.candE}/${res.candR}/${res.candD} (${((Date.now() - t0) / 1000).toFixed(0)}s)`);
  console.log(`  ER: ${fmt(res.ER)}`);
  console.log(`  ED: ${fmt(res.ED)}`);
});
writeFileSync("accretion-study/results-explore.json", JSON.stringify(out, null, 1));
console.log("wrote accretion-study/results-explore.json");
