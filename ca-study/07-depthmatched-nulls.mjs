// Study 10, script 07 — v1.2 nulls (v1.2 §3). Runs iff P1' or P6' held.
//
// Five primary cones at d = 2. Estimator-matched comparison: real cone
// re-measured at 2^14 samples/kernel (seed 20260825203); N1 = 100 degree-
// preserving rewirings (seed 20260825202) at 2^14; N2 = 20 random
// totalistic rules (seed 20260825204), full pipeline at d = 2, 2^14.
// P3' (real below N1 median in >= 3/4 primary A-D cones) only under P1'.

import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { join } from "node:path";
import {
  STUDY_DIR, SEEDS, buildRuns, pastCone, conePoset, posetFromEdges,
  coneStudyMixed, mulberry32, lifeRule, totalisticRule, median,
  placeCentered, soupGrid, runCA, pickFocus,
} from "./ca-lib.mjs";

const study = JSON.parse(readFileSync(join(STUDY_DIR, "results", "study-v12.json"), "utf8"));
if (!study.P1.holds && !study.P6.holds) {
  console.log("Gate closed (neither P1' nor P6' held); per v1.2 §4 the nulls do not run.");
  process.exit(0);
}
const census = JSON.parse(readFileSync(join(STUDY_DIR, "results", "census.json"), "utf8"));
const PRIMARY = [["A", "glider"], ["B", "block"], ["C", "blinker"], ["D", "lwss"], ["E", "soup-20260825001"]];
const runs = buildRuns();
const byName = new Map(runs.map((r) => [`${r.cond}/${r.name}`, r]));
const cenByName = new Map(census.map((c) => [`${c.cond}/${c.name}`, c]));
const NS = 16384; // 2^14, pinned

// sampled-everywhere study at 2^14 (exactMaxN = 0 forces sampling uniformly)
const measure = (P, rng) => coneStudyMixed(P, 0, NS, rng);

const rewire = (P, rng) => {
  const byLayer = new Map();
  P.edges.forEach(([u, v], i) => {
    const t = P.list[v].t;
    if (!byLayer.has(t)) byLayer.set(t, []);
    byLayer.get(t).push(i);
  });
  const edges = P.edges.map((e) => [...e]);
  const has = new Set(edges.map(([u, v]) => u * 64 + v));
  for (const idxs of byLayer.values()) {
    for (let a = 0, lim = 10 * idxs.length; a < lim; a++) {
      const i = idxs[Math.floor(rng() * idxs.length)];
      const j = idxs[Math.floor(rng() * idxs.length)];
      if (i === j) continue;
      const [u1, v1] = edges[i], [u2, v2] = edges[j];
      if (u1 === u2 || v1 === v2) continue;
      if (has.has(u1 * 64 + v2) || has.has(u2 * 64 + v1)) continue;
      has.delete(u1 * 64 + v1); has.delete(u2 * 64 + v2);
      edges[i] = [u1, v2]; edges[j] = [u2, v1];
      has.add(u1 * 64 + v2); has.add(u2 * 64 + v1);
    }
  }
  return edges;
};

console.log("=== N1: 100 degree-preserving rewirings per primary cone (2^14 samples/kernel) ===");
const rngReal = mulberry32(20260825203);
const rngN1 = mulberry32(20260825202);
const n1out = [];
for (const [cond, name] of PRIMARY) {
  const cen = cenByName.get(`${cond}/${name}`);
  if (!cen?.defined) { console.log(`${cond}/${name}: undefined, skipped`); continue; }
  const run = byName.get(`${cond}/${name}`);
  const P = conePoset(pastCone(run.hist, lifeRule, cen.focus, 2));
  const real = measure(P, rngReal);
  const nullMed = [];
  for (let r = 0; r < SEEDS.nulls.N1.rewirings; r++) {
    const P2 = posetFromEdges(P.n, P.list, rewire(P, rngN1));
    nullMed.push(measure(P2, rngN1).medianApFraction);
  }
  nullMed.sort((a, b) => a - b);
  const below = nullMed.filter((v) => v < real.medianApFraction).length;
  const rec = {
    cond, name, n: P.n, edges: P.edges.length,
    realMedianAp: real.medianApFraction,
    nullMedian: median(nullMed),
    nullP5: nullMed[Math.floor(0.05 * nullMed.length)],
    nullP95: nullMed[Math.floor(0.95 * nullMed.length)],
    percentileOfReal: below / nullMed.length,
  };
  n1out.push(rec);
  console.log(
    `${cond}/${name}  n=${P.n} |E|=${P.edges.length}  real=${rec.realMedianAp.toFixed(5)}  ` +
    `null med=${rec.nullMedian.toFixed(5)} [${rec.nullP5.toFixed(5)}, ${rec.nullP95.toFixed(5)}]  real at pct ${(rec.percentileOfReal * 100).toFixed(1)}`
  );
}

if (study.P1.holds) {
  const votes = n1out.filter((r) => r.cond !== "E" && r.realMedianAp < r.nullMedian);
  console.log(`\nP3' narrowness: real below null median in ${votes.length}/4 primary A-D cones -> ${votes.length >= 3 ? "HOLDS" : "FAILS"}`);
} else {
  console.log("\nP3': not evaluated (P1' gate).");
}

console.log("\n=== N2: 20 random totalistic rules per primary seed (separate comparison) ===");
const rngN2 = mulberry32(20260825204);
const rules = [];
while (rules.length < SEEDS.nulls.N2.rules) {
  const b = 1 + Math.floor(rngN2() * 8);
  const s1 = Math.floor(rngN2() * 9);
  let s2 = Math.floor(rngN2() * 9);
  if (s2 === s1) continue;
  rules.push({ B: [b], S: [Math.min(s1, s2), Math.max(s1, s2)] });
}
const { H, W } = SEEDS.grid;
const gridFor = (cond, name) =>
  cond === "E"
    ? soupGrid(SEEDS.conditions.E.seeds[0], H, W, SEEDS.conditions.E.region, SEEDS.conditions.E.density)
    : placeCentered(SEEDS.conditions[cond].find((s) => s.name === name).cells, H, W);

const n2out = [];
for (const [cond, name] of PRIMARY) {
  const grid = gridFor(cond, name);
  const vals = [];
  let undef = 0, oversize = 0;
  for (const rspec of rules) {
    const rule = totalisticRule(rspec.B, rspec.S);
    const hist = runCA(grid, SEEDS.T, rule);
    const focus = pickFocus(hist, SEEDS.T);
    if (!focus) { undef++; continue; }
    const cone = pastCone(hist, rule, focus, 2);
    if (cone.nodes.size > 31) { oversize++; continue; }
    const P = conePoset(cone);
    vals.push({ rule: rspec, n: P.n, medianApFraction: measure(P, rngN2).medianApFraction });
  }
  const rec = { cond, name, undefinedFoci: undef, oversize, values: vals, medianOfMedians: median(vals.map((v) => v.medianApFraction)) };
  n2out.push(rec);
  console.log(`${cond}/${name}  defined ${vals.length}/${rules.length} (undef ${undef}, oversize ${oversize})  median-of-medians=${(rec.medianOfMedians ?? NaN).toFixed?.(5) ?? "n/a"}`);
}

mkdirSync(join(STUDY_DIR, "results"), { recursive: true });
writeFileSync(join(STUDY_DIR, "results", "nulls-v12.json"), JSON.stringify({ NS, rules, N1: n1out, N2: n2out }, null, 1));
console.log(`\nwritten: results/nulls-v12.json`);
