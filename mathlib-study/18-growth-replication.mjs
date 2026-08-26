// Growth-dynamics replication: does "Distribution grows, Exploitation
// doesn't" hold on a second corpus, with age matched away?
//
// PRE-REGISTRATION (written before first run, 2026-08-26; committed with
// the blind pre-check 17 — marginals and feasibility only, the
// cell-x-outcome join scored below never computed).
//
// WHAT IS BEING REPLICATED. The AFP growth-engine study (afp-study/07)
// registered "E-cell members become load-bearing" and got a percentile-0
// REVERSAL: at matched degree, within the same kernel's neighborhood,
// DISTRIBUTION-cell members gained future dependents (G_ED = -0.33);
// the secondary E > R held at percentile 100. Matched ordering:
// D > E > R. One corpus, one flagged confound (E-members ~2 years older
// than matched D-siblings). This study registers that reversal AS THE
// HYPOTHESIS on Mathlib's history, with the confound matched away:
// strata are degree-bin x EXACT first-seen checkpoint (pre-check 17:
// the finest stratification costs <5% of matched weight; wED 2.4k-262k
// per baseline x namespace, ample everywhere).
//
// DESIGN (constants pinned by pre-check 17):
//   Corpus: Mathlib namespace-internal graphs (Order, Topology,
//     Algebra), checkpoints 2023-09 .. 2026-05.
//   Baselines: t in {2023-09, 2024-03, 2024-09, 2025-03}, horizon +2
//     checkpoints (~1 year; the AFP 4-year horizon does not exist here —
//     stated scope difference). Renamed modules count as death+birth
//     (survival 0.79-0.98, stated approximation AFP did not need).
//   Unit: (t, namespace, evaluable kernel, stratum) cells containing
//     both E and D survivors (resp. E and R).
//   Statistic: G_ED = sum over cells of min(nE, nD) x
//     [meanGain(E) - meanGain(D)] / sum of min(nE, nD), pooled over all
//     baselines and namespaces (per-namespace values reported, scored on
//     the pooled statistic). G_ER identically.
//   Null: within-cell label permutation (counts preserved), 1000
//     permutations, mulberry32 seed 20260826971, one stream.
//
// PREDICTIONS (the AFP result, transplanted):
//   MG1 (D grows, primary): G_ED < 0 AND at or below the 5th percentile
//       of its permutation null.
//   MG2 (E > R, secondary, scored separately): G_ER > 0 AND at or above
//       the 95th percentile of its null.
//
// INTERPRETATION, FIXED IN ADVANCE:
//   MG1 and MG2 hold -> the dynamical ordering D > E > R is cross-corpus
//     with age matched away; the division of labor (Exploitation owns
//     the geography, Distribution owns the dynamics) may enter outward
//     documents citing both corpora and both designs.
//   MG1 fails inside the null -> the AFP dynamics is corpus-specific;
//     it stays scoped to AFP and no division-of-labor claim ships.
//   MG1 significantly REVERSED (E outgrows D here) -> the dynamics is
//     corpus-contingent, as the R/D geography was; no dynamical claim
//     survives, both results reported side by side.
//   MG2 alone proves nothing (color either way).
//
// Output: mathlib-study/results-growth-replication.json (raw, committed).

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
const PERMS = 1000;
const SEED = 20260826971;

let rngState = SEED;
const rand = () => {
  rngState |= 0; rngState = (rngState + 0x6d2b79f5) | 0;
  let t = Math.imul(rngState ^ (rngState >>> 15), 1 | rngState);
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};

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

const firstSeen = new Map();
for (let ci = 0; ci < CHECKPOINTS.length; ci++)
  for (const ns of NAMESPACES)
    for (const m of graphOf(ci, ns).mods) {
      const key = ns + "/" + m;
      if (!firstSeen.has(key)) firstSeen.set(key, ci);
    }

// ---- collect matched cells: { gains: Float64Array, nA } (A = E side) ----
const cellsED = [], cellsER = [];
const perNs = {};
for (const ns of NAMESPACES) {
  perNs[ns] = { cellsED: [], cellsER: [] };
  for (const ti of BASELINE_IDX) {
    const tk = ti + HORIZON;
    const g = graphOf(ti, ns), gk = graphOf(tk, ns);
    const { n, w, down, mods, dependents } = g;
    const gainOf = (y) => (gk.dependents.get(mods[y]) ?? 0) - (dependents.get(mods[y]) ?? 0);

    for (let x = 0; x < n; x++) {
      const a = down[x];
      const notA = bsNew(w);
      for (let y = 0; y < n; y++) if (!bsIntersects(down[y], a)) bsSet(notA, y);
      if (!bsAny(notA)) continue;
      const nnA = bsNew(w);
      for (let y = 0; y < n; y++) if (!bsIntersects(down[y], notA)) bsSet(nnA, y);
      if (bsEq(nnA, a)) continue;
      let hasR = false, hasE = false, hasD = false;
      const strata = new Map(); // "bin|fs" -> {E:[],D:[],R:[]}
      for (let y = 0; y < n; y++) {
        if (bsSubset(down[y], a)) continue;
        let cell;
        if (bsSubset(down[y], notA)) { cell = "R"; hasR = true; }
        else if (bsSubset(down[y], nnA)) { cell = "E"; hasE = true; }
        else { cell = "D"; hasD = true; }
        const m = mods[y];
        if (!gk.midx.has(m)) continue;
        const key = `${BIN(dependents.get(m) ?? 0)}|${firstSeen.get(ns + "/" + m)}`;
        if (!strata.has(key)) strata.set(key, { E: [], D: [], R: [] });
        strata.get(key)[cell].push(y);
      }
      if (!(hasR && hasE && hasD)) continue;
      for (const [, s] of strata) {
        if (s.E.length && s.D.length) {
          const c = { gains: Float64Array.from([...s.E, ...s.D].map(gainOf)), nA: s.E.length };
          cellsED.push(c); perNs[ns].cellsED.push(c);
        }
        if (s.E.length && s.R.length) {
          const c = { gains: Float64Array.from([...s.E, ...s.R].map(gainOf)), nA: s.E.length };
          cellsER.push(c); perNs[ns].cellsER.push(c);
        }
      }
    }
  }
}
console.log(`matched cells: ED=${cellsED.length} ER=${cellsER.length}`);

// ---- statistic and permutation (flat, no Sets) ----
const statIdentity = (cells) => {
  let num = 0, den = 0;
  for (const c of cells) {
    const m = c.gains.length, nA = c.nA, nB = m - nA;
    const wgt = Math.min(nA, nB);
    let sA = 0;
    for (let i = 0; i < nA; i++) sA += c.gains[i];
    let sT = sA;
    for (let i = nA; i < m; i++) sT += c.gains[i];
    num += wgt * (sA / nA - (sT - sA) / nB);
    den += wgt;
  }
  return num / den;
};
const statPermuted = (cells) => {
  let num = 0, den = 0;
  for (const c of cells) {
    const m = c.gains.length, nA = c.nA, nB = m - nA;
    const wgt = Math.min(nA, nB);
    // choose nA of m by partial Fisher-Yates over an index scratch
    const idx = c.scratch ?? (c.scratch = Uint32Array.from({ length: m }, (_, i) => i));
    for (let i = 0; i < nA; i++) {
      const j = i + Math.floor(rand() * (m - i));
      const t = idx[i]; idx[i] = idx[j]; idx[j] = t;
    }
    let sA = 0;
    for (let i = 0; i < nA; i++) sA += c.gains[idx[i]];
    let sT = 0;
    for (let i = 0; i < m; i++) sT += c.gains[i];
    num += wgt * (sA / nA - (sT - sA) / nB);
    den += wgt;
  }
  return num / den;
};

const runTest = (cells) => {
  const obs = statIdentity(cells);
  const nulls = [];
  for (let p = 0; p < PERMS; p++) nulls.push(statPermuted(cells));
  const sorted = [...nulls].sort((a, b) => a - b);
  const below = sorted.filter((x) => x < obs).length;
  const eq = sorted.filter((x) => x === obs).length;
  return {
    obs,
    p5: sorted[Math.floor(PERMS * 0.05)],
    p95: sorted[Math.floor(PERMS * 0.95)],
    obsPctile: ((below + eq / 2) / PERMS) * 100,
  };
};

const ed = runTest(cellsED);
const er = runTest(cellsER);
const mg1 = { ...ed, holds: ed.obs < 0 && ed.obsPctile <= 5 };
const mg2 = { ...er, holds: er.obs > 0 && er.obsPctile >= 95 };

const nsBreakdown = {};
for (const ns of NAMESPACES)
  nsBreakdown[ns] = {
    G_ED: statIdentity(perNs[ns].cellsED),
    G_ER: statIdentity(perNs[ns].cellsER),
    cellsED: perNs[ns].cellsED.length, cellsER: perNs[ns].cellsER.length,
  };

console.log(
  `\nMG1 (D grows, replication): G_ED=${ed.obs.toFixed(4)}  null[5,95]=[${ed.p5.toFixed(4)}, ${ed.p95.toFixed(4)}]  pctile=${ed.obsPctile.toFixed(1)}  -> ${mg1.holds ? "HOLDS" : "FAILS"}` +
  `\nMG2 (E > R, secondary):     G_ER=${er.obs.toFixed(4)}  null[5,95]=[${er.p5.toFixed(4)}, ${er.p95.toFixed(4)}]  pctile=${er.obsPctile.toFixed(1)}  -> ${mg2.holds ? "holds" : "fails"}`
);
for (const ns of NAMESPACES)
  console.log(`  ${ns}: G_ED=${nsBreakdown[ns].G_ED.toFixed(4)} (${nsBreakdown[ns].cellsED} cells)  G_ER=${nsBreakdown[ns].G_ER.toFixed(4)} (${nsBreakdown[ns].cellsER} cells)`);

writeFileSync("mathlib-study/results-growth-replication.json", JSON.stringify({
  seed: SEED, perms: PERMS,
  matchedCells: { ED: cellsED.length, ER: cellsER.length },
  MG1: mg1, MG2: mg2, nsBreakdown,
}, null, 1));
console.log("\nwritten: mathlib-study/results-growth-replication.json");
