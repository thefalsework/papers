// Study 10, script 03 — the aperture study, exhaustive tier (v1.1 §5, §7).
//
// Requires results/census.json (script 02). Per defined cone, at its
// exhaustive-tier depth: all principal kernels, full 2^n observer census
// each; per-kernel raw output written to results/study-raw.json. Then the
// pre-registered predictions:
//   P1: per-cone median aperture fraction, pooled A-D vs E, two-sided
//       Mann-Whitney U (normal approx, tie correction), alpha = 0.01.
//   P2: some A-D cone's latent fraction > median E latent fraction.
//   P4: A and D both outside [min,max] of B∪C median aperture fractions,
//       same side; else inconclusive.
//   P5: F has no ordinary kernels and no latency.
// (P3 lives in script 04, which owns the nulls.)
// Sampled tier (secondary): only with --sampled, per v1.1 §4.

import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { join } from "node:path";
import {
  STUDY_DIR, SEEDS, buildRuns, pastCone, conePoset, coneStudy,
  apertureSampled, mulberry32, lifeRule, mannWhitney, median,
} from "./ca-lib.mjs";

const census = JSON.parse(readFileSync(join(STUDY_DIR, "results", "census.json"), "utf8"));
const wantSampled = process.argv.includes("--sampled");
const runs = buildRuns();
const byName = new Map(runs.map((r) => [`${r.cond}/${r.name}`, r]));

const cones = [];
for (const c of census) {
  if (!c.defined) { cones.push({ cond: c.cond, name: c.name, defined: false }); continue; }
  const run = byName.get(`${c.cond}/${c.name}`);
  const cone = pastCone(run.hist, lifeRule, c.focus, c.exhaustiveDepth);
  const P = conePoset(cone);
  const study = coneStudy(P);
  const rec = {
    cond: c.cond, name: c.name, defined: true,
    focus: c.focus, depth: c.exhaustiveDepth, ...study,
  };
  if (wantSampled && c.sampledDepth) {
    const coneS = pastCone(run.hist, lifeRule, c.focus, c.sampledDepth);
    if (coneS.nodes.size <= 30) {
      const PS = conePoset(coneS);
      const rng = mulberry32(SEEDS.sampledTier.prngSeed);
      rec.sampled = {
        depth: c.sampledDepth, n: PS.n,
        focusKernel: apertureSampled(PS, PS.down[PS.focusIdx], SEEDS.sampledTier.samples, rng),
      };
    } else {
      rec.sampled = { depth: c.sampledDepth, n: coneS.nodes.size, skipped: "n > 30 exceeds 32-bit mask engine" };
    }
  }
  cones.push(rec);
  console.log(
    `${c.cond}/${c.name}  n=${study.n} d=${c.exhaustiveDepth}  ` +
    `ordinary@id=${study.ordinaryAtIdCount}/${study.n}  latent=${study.latentCount}/${study.n}  ` +
    `medAp=${study.medianApFraction.toFixed(4)}  maxAp=${study.maxApFraction.toFixed(4)}`
  );
}

mkdirSync(join(STUDY_DIR, "results"), { recursive: true });
writeFileSync(join(STUDY_DIR, "results", "study-raw.json"), JSON.stringify(cones, null, 1));

// ---------------- predictions ----------------
const defined = cones.filter((c) => c.defined);
const grp = (conds) => defined.filter((c) => conds.includes(c.cond));
const AD = grp(["A", "B", "C", "D"]);
const E = grp(["E"]);
const F = grp(["F"]);

console.log("\n=== PRE-REGISTERED PREDICTIONS (v1.1 §7) ===");

// P1
const mw = mannWhitney(AD.map((c) => c.medianApFraction), E.map((c) => c.medianApFraction));
const p1 = mw.p < 0.01;
console.log(`P1 differentiation: A-D medians ${AD.map((c) => c.medianApFraction.toFixed(4)).join(",")}`);
console.log(`                    E medians   ${E.map((c) => c.medianApFraction.toFixed(4)).join(",")}`);
console.log(`  Mann-Whitney U=${mw.U1} z=${mw.z.toFixed(3)} p=${mw.p.toExponential(3)} (n1=${mw.n1}, n2=${mw.n2})  -> P1 ${p1 ? "HOLDS" : "FAILS"}`);

// P2
const eLatMed = median(E.map((c) => c.latentFraction));
const p2Wit = grp(["A", "B", "C", "D"]).filter((c) => c.latentFraction > eLatMed);
console.log(`P2 latency: E median latent fraction = ${eLatMed.toFixed(4)}; A-D cones above it: ` +
  (p2Wit.length ? p2Wit.map((c) => `${c.cond}/${c.name}(${c.latentFraction.toFixed(3)})`).join(", ") : "none") +
  `  -> P2 ${p2Wit.length ? "HOLDS" : "FAILS"}`);

// P4
const move = grp(["A", "D"]).map((c) => c.medianApFraction);
const stat = grp(["B", "C"]).map((c) => c.medianApFraction);
const lo = Math.min(...stat), hi = Math.max(...stat);
const above = move.every((v) => v > hi), below = move.every((v) => v < lo);
console.log(`P4 motion: A,D medians ${move.map((v) => v.toFixed(4)).join(",")}; B∪C range [${lo.toFixed(4)}, ${hi.toFixed(4)}]` +
  `  -> ${above ? "HOLDS (movers above)" : below ? "HOLDS (movers below)" : "INCONCLUSIVE"}`);

// P5
const p5 = F.every((c) => c.ordinaryAtIdCount === 0 && c.latentCount === 0);
console.log(`P5 degenerate control: F ordinary=${F.map((c) => c.ordinaryAtIdCount).join(",")} latent=${F.map((c) => c.latentCount).join(",")}  -> P5 ${p5 ? "HOLDS" : "FAILS (bug)"}`);

const undef = cones.filter((c) => !c.defined);
if (undef.length) console.log(`\nundefined cones (logged per §3): ${undef.map((c) => `${c.cond}/${c.name}`).join(", ")}`);
console.log(`\nwritten: results/study-raw.json`);
