// Study 10, script 05 — sampling-estimator calibration (v1.2 §1.2).
//
// Runs BEFORE the v1.2 study and is committed with its registration.
// On every v1.1 cone with depth >= 2 and n <= 18 (exact tier), compare the
// sampled estimator (2^18 uniform worlds with replacement, mulberry32 seed
// 20260825201) against the exact exhaustive aperture fraction, per kernel.
// PASS requirement: >= 95% of per-kernel estimates lie within their
// binomial 95% CI of the exact value (kernels with exact fraction 0 and 0
// hits count as inside). Exit 1 on failure.

import { readFileSync } from "node:fs";
import { join } from "node:path";
import {
  STUDY_DIR, buildRuns, pastCone, conePoset, apertureExhaustive,
  kernelSampled, mulberry32, lifeRule,
} from "./ca-lib.mjs";

const census = JSON.parse(readFileSync(join(STUDY_DIR, "results", "census.json"), "utf8"));
const runs = buildRuns();
const byName = new Map(runs.map((r) => [`${r.cond}/${r.name}`, r]));
const SAMPLES = 262144;
const rng = mulberry32(20260825201);

let total = 0, inside = 0;
const rows = [];
for (const c of census) {
  if (!c.defined || c.exhaustiveDepth < 2) continue;
  const run = byName.get(`${c.cond}/${c.name}`);
  const P = conePoset(pastCone(run.hist, lifeRule, c.focus, c.exhaustiveDepth));
  if (P.n > 18) continue;
  for (let x = 0; x < P.n; x++) {
    const exact = apertureExhaustive(P, P.down[x]).apFraction;
    const s = kernelSampled(P, P.down[x], SAMPLES, rng);
    const ok = Math.abs(s.apFraction - exact) <= Math.max(s.ci95, 1e-12) ||
               (exact === 0 && s.apHits === 0);
    total++; if (ok) inside++;
    rows.push({ cone: `${c.cond}/${c.name}`, x, exact, sampled: s.apFraction, ci95: s.ci95, ok });
    if (!ok) console.log(`OUTSIDE  ${c.cond}/${c.name} kernel ${x}: exact=${exact.toFixed(6)} sampled=${s.apFraction.toFixed(6)} ±${s.ci95.toFixed(6)}`);
  }
  console.log(`${c.cond}/${c.name}  n=${P.n} d=${c.exhaustiveDepth}: calibrated ${P.n} kernels`);
}
const frac = inside / total;
console.log(`\nCALIBRATION: ${inside}/${total} per-kernel estimates inside their 95% CI (${(frac * 100).toFixed(1)}%)`);
console.log(frac >= 0.95 ? "PASS — sampled estimator cleared for the v1.2 study" : "*** FAIL — do not run 06 ***");
process.exit(frac >= 0.95 ? 0 : 1);
