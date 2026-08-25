// Study 10, script 02 — cone-size census (v1.1 §4: census before budget).
//
// For every condition seed: run Life, apply the unified focus rule, report
// counterfactual-cone size at every depth d = 1..T, and record the chosen
// exhaustive-tier depth (largest d with n <= 18) and sampled-tier depth
// (largest d with n <= 40, if beyond the exhaustive depth). No apertures are
// computed here. Output: results/census.json + a console table.

import { writeFileSync, mkdirSync } from "node:fs";
import { join } from "node:path";
import { STUDY_DIR, buildRuns, censusFor } from "./ca-lib.mjs";

const runs = buildRuns();
const out = [];
console.log("cond  seed              focus(r,c,t)   sizes at d=1..T          d_ex  n_ex  d_sam");
for (const run of runs) {
  const cen = censusFor(run);
  if (!cen.defined) {
    console.log(`${run.cond}     ${run.name.padEnd(16)} UNDEFINED (no live cells at t=T)`);
    out.push({ cond: run.cond, name: run.name, defined: false });
    continue;
  }
  const nEx = cen.sizes[cen.exhaustiveDepth - 1];
  console.log(
    `${run.cond}     ${run.name.padEnd(16)} (${cen.focus[0]},${cen.focus[1]},${cen.focus[2]})`.padEnd(40) +
    ` ${cen.sizes.join(",").padEnd(24)} ${String(cen.exhaustiveDepth).padEnd(5)} ${String(nEx).padEnd(5)} ${cen.sampledDepth ?? "-"}`
  );
  out.push({
    cond: run.cond, name: run.name, defined: true,
    focus: cen.focus, sizes: cen.sizes,
    exhaustiveDepth: cen.exhaustiveDepth, sampledDepth: cen.sampledDepth,
  });
}

mkdirSync(join(STUDY_DIR, "results"), { recursive: true });
writeFileSync(join(STUDY_DIR, "results", "census.json"), JSON.stringify(out, null, 1));
console.log(`\nwritten: results/census.json (${out.length} runs)`);
