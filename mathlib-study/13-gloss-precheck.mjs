// Structural pre-check for the gloss-confirmation study (script 14).
//
// BLINDNESS DISCIPLINE (as 09 and 11, both lessons applied): this script
// computes, per HELD-OUT namespace, (a) the evaluable-kernel population
// (ordinary kernels with E, D, R all nonempty — occupancy COUNTS only,
// no name measure touches any cell) and (b) the resolution of the
// same-area measure (fraction of ALL module pairs sharing >= k leading
// name components — pair-level only, no kernels, no cells). Neither
// computation can leak the R-vs-D alignment that script 14 predicts.
//
// Held-out namespaces, fixed by neutral rule: every top-level Mathlib
// directory with >= 100 .lean files at the HEAD pin, excluding the three
// already studied (Order, Topology, Algebra) and tooling directories
// (Tactic — imports reflect build machinery, not mathematical dependency).
// The rule admits: CategoryTheory, Analysis, RingTheory, Data,
// LinearAlgebra, MeasureTheory, NumberTheory, Combinatorics, GroupTheory,
// AlgebraicTopology, Geometry, AlgebraicGeometry, Probability.
//
// Writes mathlib-study/results-gloss-precheck.json.

import { readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const NAMESPACES = [
  "CategoryTheory", "Analysis", "RingTheory", "Data", "LinearAlgebra",
  "MeasureTheory", "NumberTheory", "Combinatorics", "GroupTheory",
  "AlgebraicTopology", "Geometry", "AlgebraicGeometry", "Probability",
];
const HEADBASE = "lean/.lake/packages/mathlib/Mathlib";

const walkLean = (root) => {
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
  return files;
};
const modOf = (p) =>
  "Mathlib." + p.replaceAll("\\", "/").split("Mathlib/").pop().replace(/\.lean$/, "").replaceAll("/", ".");
const importRe = /^(?:(?:public|private|meta)\s+)*import\s+([\w.]+)/gm;

const W = (n) => (n + 31) >> 5;
const bsNew = (w) => new Uint32Array(w);
const bsSet = (b, i) => { b[i >> 5] |= 1 << (i & 31); };
const bsOrInto = (dst, src) => { for (let k = 0; k < dst.length; k++) dst[k] |= src[k]; };
const bsIntersects = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] & b[k]) return true; return false; };
const bsSubset = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] & ~b[k]) return false; return true; };
const bsEq = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] !== b[k]) return false; return true; };
const bsAny = (a) => { for (let k = 0; k < a.length; k++) if (a[k]) return true; return false; };

const out = {};
for (const ns of NAMESPACES) {
  const files = walkLean(join(HEADBASE, ns));
  const mods = files.map(modOf);
  const midx = new Map(mods.map((m, i) => [m, i]));
  const n = mods.length, w = W(n);
  const adjIn = Array.from({ length: n }, () => []);
  files.forEach((p, i) => {
    const src = readFileSync(p, "utf8");
    for (const m of src.matchAll(importRe)) {
      const j = midx.get(m[1]);
      if (j !== undefined && j !== i) adjIn[i].push(j);
    }
  });

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

  // (a) evaluable-kernel count (occupancy counts only)
  let ordinary = 0, evaluable = 0;
  for (let x = 0; x < n; x++) {
    const a = down[x];
    const notA = bsNew(w);
    for (let y = 0; y < n; y++) if (!bsIntersects(down[y], a)) bsSet(notA, y);
    if (!bsAny(notA)) continue;
    const nnA = bsNew(w);
    for (let y = 0; y < n; y++) if (!bsIntersects(down[y], notA)) bsSet(nnA, y);
    if (bsEq(nnA, a)) continue;
    ordinary++;
    let hasR = false, hasE = false, hasD = false;
    for (let y = 0; y < n; y++) {
      if (bsSubset(down[y], a)) continue;
      else if (bsSubset(down[y], notA)) hasR = true;
      else if (bsSubset(down[y], nnA)) hasE = true;
      else hasD = true;
    }
    if (hasR && hasE && hasD) evaluable++;
  }

  // (b) resolution: pair-level shared-prefix fractions (no kernels, no cells)
  const comps = mods.map((m) => m.split("."));
  const maxDepth = Math.max(...comps.map((c) => c.length));
  const countAtLeast = new Array(maxDepth + 2).fill(0);
  let pairs = 0;
  for (let i = 0; i < n; i++)
    for (let j = 0; j < n; j++) {
      if (i === j) continue;
      pairs++;
      let s = 0;
      const L = Math.min(comps[i].length, comps[j].length);
      while (s < L && comps[i][s] === comps[j][s]) s++;
      for (let k = 0; k <= s; k++) countAtLeast[k]++;
    }
  const frac = countAtLeast.map((c) => c / pairs);
  let kStar = null;
  for (let k = 3; k <= maxDepth; k++)
    if (frac[k] > 0.02 && frac[k] <= 0.5) { kStar = k; break; }

  out[ns] = { modules: n, ordinary, evaluable, kStar, fracAtLeast: frac.slice(0, Math.min(8, maxDepth + 1)) };
  console.log(
    `${ns.padEnd(18)} mods=${String(n).padStart(4)} ordinary=${String(ordinary).padStart(4)} ` +
    `evaluable=${String(evaluable).padStart(4)} k*=${kStar ?? "NONE"} ` +
    `frac>=3: ${frac[3]?.toFixed(3) ?? "n/a"}`
  );
}

writeFileSync("mathlib-study/results-gloss-precheck.json", JSON.stringify(out, null, 1));
console.log("\nwritten: mathlib-study/results-gloss-precheck.json (counts and pair-level resolution only)");
