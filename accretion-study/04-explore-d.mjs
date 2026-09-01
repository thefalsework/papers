// Accretion study, Phase D — EXPLORATORY grid (SPEC-D sections 2-3).
// Replicate-first, battery v2, scores nothing: maps which candidate
// rules move mean Delta_ER positive (the field ordering) at matched
// six-feature battery. Any rule at mean > 0 with |t| >= 3 graduates
// to a sealed confirmatory run on seeds this tier never touched.
//
// R = 5 universes per rule; seeds 930000+100r+off (grow),
// 935000+100r+off (estimator); N = 30k; battery: 6.
//
// ---------------------------------------------------------------------
// POSTSCRIPT (2026-09-01, after the single exploratory run; 15
// universes, all 1200 kernels evaluable everywhere)
//
//   SIB:         Delta_ER mean -0.330, t = -10.9 (5/5 negative);
//                Delta_ED mean +0.119, t = +6.5. R > E > D, strongly —
//                the co-user channel REWARDS the refusal cell, the
//                prior in SPEC-D 2 was wrong.
//   FRONT(2000): both contrasts null (t = -1.0, +0.3). Frontier
//                platforms erase the signature entirely.
//   MIX(0.5):    Delta_ER -0.181, t = -4.6; Delta_ED +0.169, t = +8.4.
//                Half a dose of the co-user channel, same sign.
//
// NOTHING GRADUATES. The exploratory result, per SPEC-D's honesty
// clause, IS the result: every cone-flavored accretion rule yet built
// (PC family, SIB, MIX) forces R > E at matched battery v2, and
// diffuse rules (U, PA, FRONT) force nothing. The field ordering
// E > R — Go at battery v1, Debian at v1 and v2 — is now UNEXPLAINED
// BY SEVEN MECHANISM FAMILIES. Whatever grows real package
// ecosystems toward their Exploitation cells, it is none of these.
// Combined with 03-sign's residual, the honest state of theory:
// cone-locality explains why cells CAN beat batteries, and nothing
// yet explains why the field's winner is E rather than R. Candidate
// channels for a future tier, named now: territory-anchored choice
// (newcomers pick platforms then deepen INTO the platform's unmet
// region — requires care not to beg the question), two-platform
// integration (straddling), and popularity-weighted platforms with
// root-mass protection against the universal-ancestor degeneracy.
// ---------------------------------------------------------------------

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
