// Growth-dynamics replication on Mathlib history: blind pre-check.
//
// WHAT IS BEING REPLICATED (registered in 18, not here): the AFP
// growth-engine study (afp-study/07) found, against its own registered
// prediction, that DISTRIBUTION-cell members — not Exploitation-cell
// members — become load-bearing at matched degree and neighborhood
// (G_ED = -0.33, percentile 0; ordering D > E > R). One corpus, one
// flagged confound (E-members ~2 years older than matched D-siblings).
// Mathlib's six checkpoints (2023-09 .. 2026-05) are the only other
// dependency corpus with committed history in this program.
//
// BLINDNESS DISCIPLINE (as afp-study/06): marginals and feasibility
// only. The cell-x-outcome join that 18 scores is never computed here.
// This pre-check reports, per baseline x namespace:
//   - module survival to t+2 checkpoints (Mathlib RENAMES modules;
//     renames count as death+birth, a stated approximation AFP did not
//     need),
//   - evaluable kernels; survivor (kernel, member) pairs per cell,
//   - matched E/D and E/R cell counts and weights under THREE
//     stratification options, so 18 can pin the finest feasible one:
//       S1: in-degree bin only (0, 1-2, 3-7, 8+ — AFP's bins),
//       S2: degree bin x coarse age (first seen at 2023-09 vs later),
//       S3: degree bin x exact first-seen checkpoint,
//     (age stratification is the upgrade the AFP postscript required:
//     the confound is matched away rather than guarded),
//   - age and gain marginals (never joined to cells).
//
// Baselines: t in {2023-09, 2024-03, 2024-09, 2025-03}, horizon +2
// checkpoints (~1 year — Mathlib's history is 2.7 years deep; the AFP
// horizon of 4 years is not available and this is a stated scope
// difference).
//
// Writes mathlib-study/results-growth-precheck.json.

import { readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const CHECKPOINTS = [
  ["2023-09", ".scratch_mathlib_hist/2023-09/Mathlib"],
  ["2024-03", ".scratch_mathlib_hist/2024-03/Mathlib"],
  ["2024-09", ".scratch_mathlib_hist/2024-09/Mathlib"],
  ["2025-03", ".scratch_mathlib_hist/2025-03/Mathlib"],
  ["2025-09", ".scratch_mathlib_hist/2025-09/Mathlib"],
  ["2026-05", "lean/.lake/packages/mathlib/Mathlib"],
];
const NAMESPACES = ["Order", "Topology", "Algebra"];
const BASELINE_IDX = [0, 1, 2, 3];
const HORIZON = 2;
const BIN = (d) => (d === 0 ? 0 : d <= 2 ? 1 : d <= 7 ? 2 : 3);

// namespace-internal graph loader (verbatim modeling of 06/12)
const importRe = /^(?:(?:public|private|meta)\s+)*import\s+([\w.]+)/gm;
const loadGraph = (base, ns) => {
  const root = join(base, ns);
  const files = [];
  const walk = (dir) => {
    for (const name of readdirSync(dir)) {
      const p = join(dir, name);
      if (statSync(p).isDirectory()) walk(p);
      else if (name.endsWith(".lean")) files.push(p);
    }
  };
  walk(root);
  files.sort();
  const modOf = (p) =>
    "Mathlib." + p.replaceAll("\\", "/").split("Mathlib/").pop().replace(/\.lean$/, "").replaceAll("/", ".");
  const mods = files.map(modOf);
  const midx = new Map(mods.map((m, i) => [m, i]));
  const n = mods.length;
  const adjIn = Array.from({ length: n }, () => []);
  const dependents = new Map(mods.map((m) => [m, 0]));
  files.forEach((p, i) => {
    const src = readFileSync(p, "utf8");
    for (const m of src.matchAll(importRe)) {
      const j = midx.get(m[1]);
      if (j !== undefined && j !== i) {
        adjIn[i].push(j);
        dependents.set(mods[j], (dependents.get(mods[j]) ?? 0) + 1);
      }
    }
  });
  return { n, mods, midx, adjIn, dependents };
};

const bsNew = (w) => new Uint32Array(w);
const bsSet = (b, i) => { b[i >> 5] |= 1 << (i & 31); };
const bsOrInto = (d, s) => { for (let k = 0; k < d.length; k++) d[k] |= s[k]; };
const bsIntersects = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] & b[k]) return true; return false; };
const bsSubset = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] & ~b[k]) return false; return true; };
const bsEq = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] !== b[k]) return false; return true; };
const bsAny = (a) => { for (let k = 0; k < a.length; k++) if (a[k]) return true; return false; };

// DAG foundations (Mathlib namespace imports are acyclic)
const downOf = (g) => {
  const { n, adjIn } = g;
  const w = (n + 31) >> 5;
  const down = new Array(n);
  const state = new Uint8Array(n);
  const stack = [];
  for (let s = 0; s < n; s++) {
    if (state[s] === 2) continue;
    stack.push(s);
    while (stack.length) {
      const i = stack[stack.length - 1];
      if (state[i] === 2) { stack.pop(); continue; }
      if (state[i] === 0) {
        state[i] = 1;
        for (const j of adjIn[i]) if (state[j] !== 2) stack.push(j);
        continue;
      }
      const b = bsNew(w);
      bsSet(b, i);
      for (const j of adjIn[i]) bsOrInto(b, down[j]);
      down[i] = b; state[i] = 2; stack.pop();
    }
  }
  return { down, w };
};

const graphs = new Map();
const graphOf = (ci, ns) => {
  const key = ci + "/" + ns;
  if (!graphs.has(key)) {
    const g = loadGraph(CHECKPOINTS[ci][1], ns);
    const { down, w } = downOf(g);
    graphs.set(key, { ...g, down, w });
  }
  return graphs.get(key);
};

// first-seen checkpoint per module per namespace
const firstSeen = new Map(); // "ns/mod" -> checkpoint index
for (let ci = 0; ci < CHECKPOINTS.length; ci++)
  for (const ns of NAMESPACES)
    for (const m of graphOf(ci, ns).mods) {
      const key = ns + "/" + m;
      if (!firstSeen.has(key)) firstSeen.set(key, ci);
    }

const out = {};
for (const ns of NAMESPACES) {
  out[ns] = {};
  for (const ti of BASELINE_IDX) {
    const tk = ti + HORIZON;
    const g = graphOf(ti, ns), gk = graphOf(tk, ns);
    const { n, w, down, mods, dependents } = g;

    const survived = mods.filter((m) => gk.midx.has(m)).length;

    let evaluable = 0;
    const pairCount = { R: 0, E: 0, D: 0 };
    const cellAge = { R: {}, E: {}, D: {} };
    // matched-cell tallies under the three stratification options
    const tally = {
      S1: { ED: 0, ER: 0, wED: 0, wER: 0 },
      S2: { ED: 0, ER: 0, wED: 0, wER: 0 },
      S3: { ED: 0, ER: 0, wED: 0, wER: 0 },
    };
    const strat = {
      S1: (bin) => `${bin}`,
      S2: (bin, fs) => `${bin}|${fs === 0 ? "old" : "young"}`,
      S3: (bin, fs) => `${bin}|${fs}`,
    };

    for (let x = 0; x < n; x++) {
      const a = down[x];
      const notA = bsNew(w);
      for (let y = 0; y < n; y++) if (!bsIntersects(down[y], a)) bsSet(notA, y);
      if (!bsAny(notA)) continue;
      const nnA = bsNew(w);
      for (let y = 0; y < n; y++) if (!bsIntersects(down[y], notA)) bsSet(nnA, y);
      if (bsEq(nnA, a)) continue;
      let hasR = false, hasE = false, hasD = false;
      const cellsByStrat = { S1: new Map(), S2: new Map(), S3: new Map() };
      for (let y = 0; y < n; y++) {
        if (bsSubset(down[y], a)) continue;
        let cell;
        if (bsSubset(down[y], notA)) { cell = "R"; hasR = true; }
        else if (bsSubset(down[y], nnA)) { cell = "E"; hasE = true; }
        else { cell = "D"; hasD = true; }
        const m = mods[y];
        if (!gk.midx.has(m)) continue;
        const bin = BIN(dependents.get(m) ?? 0);
        const fs = firstSeen.get(ns + "/" + m);
        pairCount[cell]++;
        cellAge[cell][fs] = (cellAge[cell][fs] ?? 0) + 1;
        for (const S of ["S1", "S2", "S3"]) {
          const key = strat[S](bin, fs);
          if (!cellsByStrat[S].has(key)) cellsByStrat[S].set(key, { E: 0, D: 0, R: 0 });
          cellsByStrat[S].get(key)[cell]++;
        }
      }
      if (!(hasR && hasE && hasD)) continue;
      evaluable++;
      for (const S of ["S1", "S2", "S3"])
        for (const [, c] of cellsByStrat[S]) {
          if (c.E && c.D) { tally[S].ED++; tally[S].wED += Math.min(c.E, c.D); }
          if (c.E && c.R) { tally[S].ER++; tally[S].wER += Math.min(c.E, c.R); }
        }
    }

    const gains = mods.filter((m) => gk.midx.has(m))
      .map((m) => (gk.dependents.get(m) ?? 0) - (dependents.get(m) ?? 0));
    gains.sort((a, b) => a - b);
    const q = (p) => gains[Math.min(gains.length - 1, Math.floor(p * gains.length))];

    out[ns][CHECKPOINTS[ti][0]] = {
      horizon: CHECKPOINTS[tk][0], modules: n, survived,
      survivalFrac: +(survived / n).toFixed(3),
      evaluableKernels: evaluable, survivorPairsPerCell: pairCount, cellAge,
      matched: tally,
      gainMarginal: { median: q(0.5), p90: q(0.9), max: gains[gains.length - 1], fracPositive: +(gains.filter((x) => x > 0).length / gains.length).toFixed(3) },
    };
    const b = out[ns][CHECKPOINTS[ti][0]];
    console.log(
      `${ns} ${CHECKPOINTS[ti][0]}->${b.horizon}: mods=${n} surv=${b.survivalFrac} evalK=${evaluable} ` +
      `pairs E/D/R=${pairCount.E}/${pairCount.D}/${pairCount.R}\n` +
      `  matched wED: S1=${tally.S1.wED} S2=${tally.S2.wED} S3=${tally.S3.wED}  ` +
      `wER: S1=${tally.S1.wER} S2=${tally.S2.wER} S3=${tally.S3.wER}  ` +
      `gain frac+=${b.gainMarginal.fracPositive} p90=${b.gainMarginal.p90}`
    );
  }
}

writeFileSync("mathlib-study/results-growth-precheck.json", JSON.stringify(out, null, 1));
console.log("\nwritten: mathlib-study/results-growth-precheck.json (marginals and feasibility only)");
