// Study 10, script 04 — nulls N1 and N2 (v1.1 §6) and prediction P3.
//
// Both nulls run on the primary cone of each condition A-E (A glider,
// B block, C blinker, D lwss, E soup-20260825001), at its exhaustive depth.
//
// N1: 100 degree-preserving rewirings of the cone's direct edges (double-
//     edge swaps within each consecutive-layer bipartite graph, 10|E|
//     attempts each), node set fixed, seed 20260825101. Same measures on
//     each rewired poset.
// N2: 20 random totalistic rules (B={b}, b~U{1..8}; S = uniform 2-subset of
//     {0..8}), seed 20260825102. Full pipeline rerun per rule; undefined
//     foci counted.
// P3 (pre-registered): for >= 3 of the 4 primary A-D cones, the real
//     median aperture fraction is below the median of its 100 N1 rewirings.

import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { join } from "node:path";
import {
  STUDY_DIR, SEEDS, buildRuns, pastCone, conePoset, posetFromEdges,
  coneStudy, mulberry32, lifeRule, totalisticRule, median,
  placeCentered, soupGrid, runCA, censusFor,
} from "./ca-lib.mjs";

const census = JSON.parse(readFileSync(join(STUDY_DIR, "results", "census.json"), "utf8"));
const PRIMARY = [["A", "glider"], ["B", "block"], ["C", "blinker"], ["D", "lwss"], ["E", "soup-20260825001"]];
const runs = buildRuns();
const byName = new Map(runs.map((r) => [`${r.cond}/${r.name}`, r]));
const cenByName = new Map(census.map((c) => [`${c.cond}/${c.name}`, c]));

// ---------------- N1 ----------------
const rewire = (P, rng) => {
  // group direct edges by child layer t
  const byLayer = new Map();
  P.edges.forEach(([u, v], i) => {
    const t = P.list[v].t;
    if (!byLayer.has(t)) byLayer.set(t, []);
    byLayer.get(t).push(i);
  });
  const edges = P.edges.map((e) => [...e]);
  const has = new Set(edges.map(([u, v]) => u * 64 + v));
  for (const idxs of byLayer.values()) {
    const attempts = 10 * idxs.length;
    for (let a = 0; a < attempts; a++) {
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

console.log("=== N1: degree-preserving rewiring (100 per primary cone) ===");
const n1out = [];
const rngN1 = mulberry32(SEEDS.nulls.N1.prngSeed);
for (const [cond, name] of PRIMARY) {
  const cen = cenByName.get(`${cond}/${name}`);
  if (!cen?.defined) { console.log(`${cond}/${name}: undefined cone, skipped`); continue; }
  const run = byName.get(`${cond}/${name}`);
  const cone = pastCone(run.hist, lifeRule, cen.focus, cen.exhaustiveDepth);
  const P = conePoset(cone);
  const real = coneStudy(P);
  const nullMed = [], nullLat = [];
  for (let r = 0; r < SEEDS.nulls.N1.rewirings; r++) {
    const P2 = posetFromEdges(P.n, P.list, rewire(P, rngN1));
    const st = coneStudy(P2);
    nullMed.push(st.medianApFraction);
    nullLat.push(st.latentFraction);
  }
  nullMed.sort((a, b) => a - b);
  const below = nullMed.filter((v) => v < real.medianApFraction).length;
  const rec = {
    cond, name, n: P.n, edges: P.edges.length,
    realMedianAp: real.medianApFraction, realLatentFraction: real.latentFraction,
    nullMedianAp: { median: median(nullMed), p5: nullMed[Math.floor(0.05 * nullMed.length)], p95: nullMed[Math.floor(0.95 * nullMed.length)] },
    nullLatentFraction: { median: median(nullLat) },
    percentileOfReal: below / nullMed.length,
  };
  n1out.push(rec);
  console.log(
    `${cond}/${name}  n=${P.n} |E|=${P.edges.length}  realMedAp=${real.medianApFraction.toFixed(4)}  ` +
    `null med=${rec.nullMedianAp.median.toFixed(4)} [p5 ${rec.nullMedianAp.p5.toFixed(4)}, p95 ${rec.nullMedianAp.p95.toFixed(4)}]  ` +
    `real at pct ${(rec.percentileOfReal * 100).toFixed(1)}  latent real=${real.latentFraction.toFixed(3)} nullMed=${rec.nullLatentFraction.median.toFixed(3)}`
  );
}

// P3
const p3votes = n1out.filter((r) => r.cond !== "E" && r.realMedianAp < r.nullMedianAp.median);
console.log(`\nP3 narrowness: real below null median in ${p3votes.length}/4 primary A-D cones ` +
  `(${p3votes.map((r) => r.cond).join(",") || "none"})  -> P3 ${p3votes.length >= 3 ? "HOLDS" : "FAILS"}`);

// ---------------- N2 ----------------
console.log("\n=== N2: rule randomization (20 rules, primary seeds, separate comparison) ===");
const rngN2 = mulberry32(SEEDS.nulls.N2.prngSeed);
const rules = [];
while (rules.length < SEEDS.nulls.N2.rules) {
  const b = 1 + Math.floor(rngN2() * 8);
  const s1 = Math.floor(rngN2() * 9);
  let s2 = Math.floor(rngN2() * 9);
  if (s2 === s1) continue;
  rules.push({ B: [b], S: [Math.min(s1, s2), Math.max(s1, s2)] });
}
const { H, W } = SEEDS.grid;
const primaryGrid = (cond, name) => {
  if (cond === "E") return soupGrid(SEEDS.conditions.E.seeds[0], H, W, SEEDS.conditions.E.region, SEEDS.conditions.E.density);
  const spec = SEEDS.conditions[cond].find((s) => s.name === name);
  return placeCentered(spec.cells, H, W);
};

const n2out = [];
for (const [cond, name] of PRIMARY) {
  const grid = primaryGrid(cond, name);
  const perRule = [];
  let undefinedCount = 0;
  for (const rspec of rules) {
    const rule = totalisticRule(rspec.B, rspec.S);
    const run = { cond, name, grid, T: SEEDS.T, hist: runCA(grid, SEEDS.T, rule) };
    const cen = censusFor(run, rule);
    if (!cen.defined) { undefinedCount++; perRule.push(null); continue; }
    const cone = pastCone(run.hist, rule, cen.focus, cen.exhaustiveDepth);
    const P = conePoset(cone);
    const st = coneStudy(P);
    perRule.push({ rule: rspec, n: P.n, depth: cen.exhaustiveDepth, medianApFraction: st.medianApFraction, latentFraction: st.latentFraction });
  }
  const live = perRule.filter(Boolean);
  const rec = {
    cond, name, undefinedCount,
    medAp: { median: median(live.map((x) => x.medianApFraction)), values: live.map((x) => x.medianApFraction) },
    latent: { median: median(live.map((x) => x.latentFraction)) },
    perRule,
  };
  n2out.push(rec);
  console.log(
    `${cond}/${name}  defined ${live.length}/${rules.length} (undef ${undefinedCount})  ` +
    `medAp median=${(rec.medAp.median ?? NaN).toFixed?.(4) ?? "n/a"}  latent median=${(rec.latent.median ?? NaN).toFixed?.(3) ?? "n/a"}`
  );
}

mkdirSync(join(STUDY_DIR, "results"), { recursive: true });
writeFileSync(join(STUDY_DIR, "results", "nulls.json"), JSON.stringify({ rules, N1: n1out, N2: n2out }, null, 1));
console.log(`\nwritten: results/nulls.json`);
