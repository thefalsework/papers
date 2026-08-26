// Structural pre-check for the cell-composition study (counts only).
//
// BLINDNESS DISCIPLINE (as ca-study/08): this script computes, for every
// principal kernel in each HEAD namespace, the ordinariness verdict and the
// four-cell occupancy COUNTS (|I|, |R|, |E|, |D| over all modules of the
// namespace). It never reads module names' path structure beyond building
// the graph, and never computes any name-proximity measure — the quantity
// the forthcoming registration predicts. Output pins the evaluable kernel
// population (which kernels have nonempty E and D cells) before any
// prediction is registered.
//
// Cell classification at the identity world of the full namespace down-set
// algebra (the classification of 01, restated):
//   a = foundation(x) (principal down-set of kernel apex x)
//   notA = { y : down(y) ∩ a = ∅ }         (¬a)
//   nnA  = { y : down(y) ∩ notA = ∅ }      (¬¬a)
//   ordinary iff notA ≠ ∅ and nnA ≠ a
//   I: down(y) ⊆ a;  R: down(y) ⊆ notA;  E: down(y) ⊆ nnA and not I;
//   D: otherwise.
// Writes mathlib-study/results-cell-precheck.json.

import { readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const NAMESPACES = ["Order", "Topology", "Algebra"];
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

// ---- bitset helpers (Uint32Array words) ----
const W = (n) => (n + 31) >> 5;
const bsNew = (w) => new Uint32Array(w);
const bsSet = (b, i) => { b[i >> 5] |= 1 << (i & 31); };
const bsHas = (b, i) => (b[i >> 5] >>> (i & 31)) & 1;
const bsOrInto = (dst, src) => { for (let k = 0; k < dst.length; k++) dst[k] |= src[k]; };
const bsIntersects = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] & b[k]) return true; return false; };
const bsSubset = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] & ~b[k]) return false; return true; };
const bsEq = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] !== b[k]) return false; return true; };
const bsAny = (a) => { for (let k = 0; k < a.length; k++) if (a[k]) return true; return false; };
const bsCount = (a) => { let c = 0; for (let k = 0; k < a.length; k++) { let v = a[k]; v -= (v >>> 1) & 0x55555555; v = (v & 0x33333333) + ((v >>> 2) & 0x33333333); c += (((v + (v >>> 4)) & 0x0f0f0f0f) * 0x01010101) >>> 24; } return c; };

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

  // foundations as bitsets, DFS over the DAG
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

  const kernels = [];
  for (let x = 0; x < n; x++) {
    const a = down[x];
    const notA = bsNew(w);
    for (let y = 0; y < n; y++) if (!bsIntersects(down[y], a)) bsSet(notA, y);
    if (!bsAny(notA)) { kernels.push({ x, verdict: "dense" }); continue; }
    const nnA = bsNew(w);
    for (let y = 0; y < n; y++) if (!bsIntersects(down[y], notA)) bsSet(nnA, y);
    if (bsEq(nnA, a)) { kernels.push({ x, verdict: "regular" }); continue; }
    let I = 0, R = 0, E = 0, D = 0;
    for (let y = 0; y < n; y++) {
      if (bsSubset(down[y], a)) I++;
      else if (bsSubset(down[y], notA)) R++;
      else if (bsSubset(down[y], nnA)) E++;
      else D++;
    }
    kernels.push({ x, mod: mods[x], verdict: "ordinary",
      foundation: bsCount(a), I, R, E, D });
  }

  const ord = kernels.filter((k) => k.verdict === "ordinary");
  const withE = ord.filter((k) => k.E > 0);
  const withD = ord.filter((k) => k.D > 0);
  const withED = ord.filter((k) => k.E > 0 && k.D > 0 && k.R > 0);
  out[ns] = {
    modules: n,
    dense: kernels.filter((k) => k.verdict === "dense").length,
    regular: kernels.filter((k) => k.verdict === "regular").length,
    ordinary: ord.length,
    ordinaryWithE: withE.length,
    ordinaryWithD: withD.length,
    evaluable_EDR: withED.length,
    eSizes: withE.map((k) => k.E).sort((a, b) => a - b),
    kernels: ord,
  };
  console.log(
    `${ns}: ${n} modules; kernels dense/regular/ordinary = ` +
    `${out[ns].dense}/${out[ns].regular}/${out[ns].ordinary}; ` +
    `E nonempty: ${withE.length}; D nonempty: ${withD.length}; ` +
    `E,D,R all nonempty (evaluable): ${withED.length}`
  );
  if (withE.length) {
    const es = out[ns].eSizes;
    console.log(`  E-cell sizes: min=${es[0]} med=${es[Math.floor(es.length / 2)]} max=${es[es.length - 1]}`);
  }
}

writeFileSync("mathlib-study/results-cell-precheck.json", JSON.stringify(out, null, 1));
console.log("\nwritten: mathlib-study/results-cell-precheck.json (counts only; no name proximity computed)");
