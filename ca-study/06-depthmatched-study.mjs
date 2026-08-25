// Study 10, script 06 — the depth-matched study (v1.2 §2, §4).
//
// Every defined cone at d = 2 exactly (F at its d = 1 singleton, control).
// Mixed estimator per v1.2 §2: exact for n <= 18, sampled (2^18 worlds,
// mulberry32 seed 20260825201, one stream in cone order) for 19 <= n <= 31.
// Evaluates P1' (gate), P2'-P4' only under P1', P5' and P6' always.
// Writes results/study-v12.json.

import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { join } from "node:path";
import {
  STUDY_DIR, buildRuns, pastCone, conePoset, coneStudyMixed,
  mulberry32, lifeRule, mannWhitney, median,
} from "./ca-lib.mjs";

const census = JSON.parse(readFileSync(join(STUDY_DIR, "results", "census.json"), "utf8"));
const runs = buildRuns();
const byName = new Map(runs.map((r) => [`${r.cond}/${r.name}`, r]));
const SAMPLES = 262144;
const rng = mulberry32(20260825201);

const cones = [];
for (const c of census) {
  if (!c.defined) { cones.push({ cond: c.cond, name: c.name, defined: false }); continue; }
  const run = byName.get(`${c.cond}/${c.name}`);
  const depth = c.cond === "F" ? 1 : 2;
  const P = conePoset(pastCone(run.hist, lifeRule, c.focus, depth));
  const st = coneStudyMixed(P, 18, SAMPLES, rng);
  cones.push({ cond: c.cond, name: c.name, defined: true, focus: c.focus, depth, ...st });
  console.log(
    `${c.cond}/${c.name}  n=${st.n} d=${depth} [${st.estimator}]  ` +
    `ordinary@id=${st.ordinaryAtIdCount}/${st.n}  latent=${st.latentCount}/${st.n}  ` +
    `medAp=${st.medianApFraction.toFixed(5)}  maxAp=${st.maxApFraction.toFixed(5)}`
  );
}

mkdirSync(join(STUDY_DIR, "results"), { recursive: true });

const defined = cones.filter((c) => c.defined);
const grp = (conds) => defined.filter((c) => conds.includes(c.cond));
const AD = grp(["A", "B", "C", "D"]), B = grp(["B"]), CGRP = grp(["C"]);
const E = grp(["E"]), F = grp(["F"]);

console.log("\n=== PRE-REGISTERED PREDICTIONS (v1.2 §4) ===");

// P1'
const mw1 = mannWhitney(AD.map((c) => c.medianApFraction), E.map((c) => c.medianApFraction));
const p1 = mw1.p < 0.01;
console.log(`P1' differentiation: A-D medians ${AD.map((c) => c.medianApFraction.toFixed(5)).join(",")}`);
console.log(`                     E medians   ${E.map((c) => c.medianApFraction.toFixed(5)).join(",")}`);
console.log(`  Mann-Whitney U=${mw1.U1} z=${mw1.z.toFixed(3)} p=${mw1.p.toExponential(3)}  -> P1' ${p1 ? "HOLDS" : "FAILS"}`);

// P2'-P4' gated
if (p1) {
  const eLatMed = median(E.map((c) => c.latentFraction));
  const wit = AD.filter((c) => c.latentFraction > eLatMed);
  console.log(`P2' latency: E median latent fraction ${eLatMed.toFixed(4)}; A-D above: ` +
    (wit.length ? wit.map((c) => `${c.cond}/${c.name}(${c.latentFraction.toFixed(3)})`).join(", ") : "none") +
    `  -> ${wit.length ? "HOLDS" : "FAILS"}`);
  const move = grp(["A", "D"]).map((c) => c.medianApFraction);
  const statc = grp(["B", "C"]).map((c) => c.medianApFraction);
  const lo = Math.min(...statc), hi = Math.max(...statc);
  const above = move.every((v) => v > hi), below = move.every((v) => v < lo);
  console.log(`P4' motion: A,D ${move.map((v) => v.toFixed(5)).join(",")}; B∪C range [${lo.toFixed(5)}, ${hi.toFixed(5)}]` +
    `  -> ${above || below ? "HOLDS" : "INCONCLUSIVE"}`);
} else {
  console.log("P2'-P4': not evaluated (P1' gate).");
}

// P5'
const p5 = F.every((c) => c.ordinaryAtIdCount === 0 && c.latentCount === 0);
console.log(`P5' control: F ordinary=${F.map((c) => c.ordinaryAtIdCount).join(",")} latent=${F.map((c) => c.latentCount).join(",")}  -> ${p5 ? "HOLDS" : "FAILS (bug)"}`);

// P6' (always evaluated)
const bMed = median(B.map((c) => c.medianApFraction));
const eMed = median(E.map((c) => c.medianApFraction));
const mw6 = mannWhitney(B.map((c) => c.medianApFraction), E.map((c) => c.medianApFraction));
const p6 = bMed > eMed;
console.log(`P6' figure-vs-ground: median(B medians)=${bMed.toFixed(5)} vs median(E medians)=${eMed.toFixed(5)}; ` +
  `MW B-vs-E U=${mw6.U1} z=${mw6.z.toFixed(3)} p=${mw6.p.toExponential(3)}` +
  `  -> P6' ${p6 ? "HOLDS (direction)" : "FAILS"}${p6 && mw6.p < 0.05 ? ", significant at 0.05" : ""}`);

writeFileSync(join(STUDY_DIR, "results", "study-v12.json"),
  JSON.stringify({ cones, P1: { ...mw1, holds: p1 }, P5: p5, P6: { bMed, eMed, ...mw6, holds: p6 } }, null, 1));
console.log(`\nwritten: results/study-v12.json`);
console.log(`gate for script 07 (nulls): ${p1 || p6 ? "OPEN (P1' or P6' holds)" : "CLOSED"}`);
