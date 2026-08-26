// Cell-composition study: do the four cells, computed from imports alone,
// align with the human conceptual taxonomy expressed in module name paths?
//
// PRE-REGISTRATION (written before first run, 2026-08-26; structural
// pre-check 09-cell-precheck.mjs committed first — it counts cell
// occupancy only and never computes the name-proximity measure predicted
// here, so these predictions are blind to outcomes).
//
// WHAT IS AND IS NOT AT STAKE. The four-position partition itself is [K]
// (four_position_partition); no corpus can validate a theorem. What this
// study tests is the DICTIONARY — the [A]-graded claim that the cells'
// names (Infrastructure / Refusal / Exploitation / Distribution) describe
// what falls in them. Stated honestly up front: for a principal kernel
// a = ↓x on an import poset, the I cell is definitionally x's foundation
// and the R cell is definitionally the foundation-disjoint modules, so
// "I is name-close to x, R is name-far" is a near-tautology about
// directory-local importing and is reported as CALIBRATION (C0), not
// scored. The contentful cells are E and D — the two that exist only
// because the algebra is non-Boolean — and the dictionary makes
// falsifiable claims about them:
//   E ("Exploitation: territory the kernel claims but does not settle")
//     -> E-modules work the kernel's own conceptual area WITHOUT being in
//        its foundation: name-proximity to x HIGH (above D and R).
//   D ("Distribution: carrying the commitment across its own boundary")
//     -> D-modules straddle: name-proximity INTERMEDIATE (above R,
//        below E).
//
// CORPUS. HEAD pin (1fb6b28816), namespaces Order, Topology, Algebra;
// same modeling choices as all prior scripts (namespace-internal imports,
// foundations = transitive imports, kernels = principal down-sets). Cell
// classification at the identity world of the full namespace algebra,
// verbatim semantics of 09 (and of 01's occupancy).
//
// EVALUABLE POPULATION (pinned from the committed pre-check): every
// ordinary kernel with E, D, R all nonempty — 286 (Order), 643
// (Topology), 1274 (Algebra).
//
// MEASURE. prox(y, x) = number of shared leading dotted components of the
// full module names (e.g. Mathlib.Order.Hom.Basic vs Mathlib.Order.Hom.Set
// -> 3). Per kernel: medProx(C) over each cell C (apex x excluded from I).
//   dED = medProx(E) - medProx(D);  dDR = medProx(D) - medProx(R).
// Namespace summary: median over evaluable kernels of dED and of dDR, and
// the fraction of kernels with the predicted strict sign.
//
// NULL (the control that kills cell-size artifacts). Name-permutation:
// reassign the module-name list to graph nodes by a uniform permutation
// (mulberry32 seed 20260826501, 100 permutations per namespace, one
// stream), keep the import structure and hence the cells fixed, recompute
// both namespace summary medians. Cell sizes, name multiset, and all
// import structure are preserved; only the alignment between names and
// graph position is destroyed.
//
// PREDICTIONS.
//   C1 (Exploitation is on-territory — primary): median dED > 0 in all
//      three namespaces, AND the observed median dED exceeds the 95th
//      percentile of its 100-permutation null in at least 2 of 3
//      namespaces. HARD FAIL in addition if any namespace sits at or
//      below its null's 5th percentile (significant reversal).
//   C2 (Distribution straddles — secondary, same criteria on dDR).
//   C0 (calibration, reported not scored): medProx(I) is the largest of
//      the four cell medians per namespace.
//
// INTERPRETATION, FIXED IN ADVANCE.
//   C1 and C2 hold -> the dictionary's contentful cell readings have
//     corpus-level empirical support: the algebra's non-Boolean cells
//     recover the human conceptual organization from imports alone.
//     Grade of the cell dictionary moves from bare [A] to [A] with
//     [computed] support on this corpus. It does NOT validate any other
//     domain's dictionary (music included); it validates the protocol.
//   C1 fails -> the "Exploitation = on-territory" reading is not
//     supported where it is most checkable; the cell names stay, flagged
//     as unsupported-on-Mathlib, in every outward document.
//   Observed inside the permutation null -> any raw gradient is a
//     cell-size artifact; report as artifact caught by control.
//
// Output: mathlib-study/results-cell-composition.json (raw, committed).

import { readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const NAMESPACES = ["Order", "Topology", "Algebra"];
const HEADBASE = "lean/.lake/packages/mathlib/Mathlib";
const PERMS = 100;
const SEED = 20260826501;

let rngState = SEED;
const rand = () => {
  rngState |= 0; rngState = (rngState + 0x6d2b79f5) | 0;
  let t = Math.imul(rngState ^ (rngState >>> 15), 1 | rngState);
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};

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

// bitset helpers (as 09)
const W = (n) => (n + 31) >> 5;
const bsNew = (w) => new Uint32Array(w);
const bsSet = (b, i) => { b[i >> 5] |= 1 << (i & 31); };
const bsOrInto = (dst, src) => { for (let k = 0; k < dst.length; k++) dst[k] |= src[k]; };
const bsIntersects = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] & b[k]) return true; return false; };
const bsSubset = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] & ~b[k]) return false; return true; };
const bsEq = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] !== b[k]) return false; return true; };
const bsAny = (a) => { for (let k = 0; k < a.length; k++) if (a[k]) return true; return false; };

const median = (xs) => {
  const s = [...xs].sort((a, b) => a - b);
  return s.length % 2 ? s[(s.length - 1) / 2] : (s[s.length / 2 - 1] + s[s.length / 2]) / 2;
};
const pctile = (arr, v) => {
  const s = [...arr].sort((a, b) => a - b);
  const below = s.filter((x) => x < v).length;
  const eq = s.filter((x) => x === v).length;
  return ((below + eq / 2) / s.length) * 100;
};

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

  // foundations (as 09)
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

  // cells per evaluable kernel (verbatim semantics of 09)
  const kernels = []; // { x, cells: Int8Array (0=I,1=R,2=E,3=D) }
  for (let x = 0; x < n; x++) {
    const a = down[x];
    const notA = bsNew(w);
    for (let y = 0; y < n; y++) if (!bsIntersects(down[y], a)) bsSet(notA, y);
    if (!bsAny(notA)) continue;
    const nnA = bsNew(w);
    for (let y = 0; y < n; y++) if (!bsIntersects(down[y], notA)) bsSet(nnA, y);
    if (bsEq(nnA, a)) continue;
    const cells = new Int8Array(n);
    let hasR = false, hasE = false, hasD = false;
    for (let y = 0; y < n; y++) {
      if (bsSubset(down[y], a)) cells[y] = 0;
      else if (bsSubset(down[y], notA)) { cells[y] = 1; hasR = true; }
      else if (bsSubset(down[y], nnA)) { cells[y] = 2; hasE = true; }
      else { cells[y] = 3; hasD = true; }
    }
    if (hasR && hasE && hasD) kernels.push({ x, cells });
  }

  // name components (split once)
  const comps = mods.map((m) => m.split("."));
  const proxOf = (nameIdxOf) => {
    // per-kernel medians and deltas under a node->name assignment
    const dEDs = [], dDRs = [], medI = [], medE = [], medD = [], medR = [];
    for (const { x, cells } of kernels) {
      const cx = comps[nameIdxOf(x)];
      const buckets = [[], [], [], []];
      for (let y = 0; y < cells.length; y++) {
        if (y === x) continue; // apex excluded from I
        const cy = comps[nameIdxOf(y)];
        let s = 0;
        const L = Math.min(cx.length, cy.length);
        while (s < L && cx[s] === cy[s]) s++;
        buckets[cells[y]].push(s);
      }
      const m = buckets.map((b) => (b.length ? median(b) : NaN));
      medI.push(m[0]); medR.push(m[1]); medE.push(m[2]); medD.push(m[3]);
      dEDs.push(m[2] - m[3]);
      dDRs.push(m[3] - m[1]);
    }
    return {
      medDED: median(dEDs), medDDR: median(dDRs),
      fracED: dEDs.filter((v) => v > 0).length / dEDs.length,
      fracDR: dDRs.filter((v) => v > 0).length / dDRs.length,
      cellMedians: { I: median(medI), R: median(medR), E: median(medE), D: median(medD) },
    };
  };

  const obs = proxOf((i) => i);

  // name-permutation null
  const nullDED = [], nullDDR = [];
  for (let p = 0; p < PERMS; p++) {
    const perm = [...Array(n).keys()];
    for (let i = n - 1; i > 0; i--) {
      const j = Math.floor(rand() * (i + 1));
      [perm[i], perm[j]] = [perm[j], perm[i]];
    }
    const r = proxOf((i) => perm[i]);
    nullDED.push(r.medDED); nullDDR.push(r.medDDR);
  }

  out[ns] = {
    evaluableKernels: kernels.length,
    observed: obs,
    null: {
      dED: { p5: [...nullDED].sort((a, b) => a - b)[4], p95: [...nullDED].sort((a, b) => a - b)[94], obsPctile: pctile(nullDED, obs.medDED) },
      dDR: { p5: [...nullDDR].sort((a, b) => a - b)[4], p95: [...nullDDR].sort((a, b) => a - b)[94], obsPctile: pctile(nullDDR, obs.medDDR) },
    },
  };
  console.log(
    `${ns}: kernels=${kernels.length}  cell medProx I/E/D/R = ` +
    `${obs.cellMedians.I.toFixed(2)}/${obs.cellMedians.E.toFixed(2)}/${obs.cellMedians.D.toFixed(2)}/${obs.cellMedians.R.toFixed(2)}\n` +
    `  dED: obs median=${obs.medDED.toFixed(3)} (frac>0: ${obs.fracED.toFixed(2)})  null[5,95]=[${out[ns].null.dED.p5.toFixed(3)}, ${out[ns].null.dED.p95.toFixed(3)}]  obs pctile=${out[ns].null.dED.obsPctile.toFixed(1)}\n` +
    `  dDR: obs median=${obs.medDDR.toFixed(3)} (frac>0: ${obs.fracDR.toFixed(2)})  null[5,95]=[${out[ns].null.dDR.p5.toFixed(3)}, ${out[ns].null.dDR.p95.toFixed(3)}]  obs pctile=${out[ns].null.dDR.obsPctile.toFixed(1)}`
  );
}

// ---- verdicts ----
const evalPred = (key) => {
  const allPos = NAMESPACES.every((ns) => out[ns].observed[key === "dED" ? "medDED" : "medDDR"] > 0);
  const beat95 = NAMESPACES.filter((ns) => out[ns].null[key].obsPctile > 95).length;
  const rev5 = NAMESPACES.some((ns) => out[ns].null[key].obsPctile <= 5);
  const holds = allPos && beat95 >= 2 && !rev5;
  return { allPos, beat95, rev5, holds };
};
const c1 = evalPred("dED");
const c2 = evalPred("dDR");
console.log(`\nC1 (E on-territory): all-positive=${c1.allPos}, beats-95th in ${c1.beat95}/3, reversal=${c1.rev5}  -> ${c1.holds ? "HOLDS" : "FAILS"}`);
console.log(`C2 (D straddles):    all-positive=${c2.allPos}, beats-95th in ${c2.beat95}/3, reversal=${c2.rev5}  -> ${c2.holds ? "HOLDS" : "FAILS"}`);
const c0 = NAMESPACES.every((ns) => {
  const m = out[ns].observed.cellMedians;
  return m.I >= m.E && m.I >= m.D && m.I >= m.R;
});
console.log(`C0 (calibration, I highest): ${c0 ? "as expected" : "VIOLATED — inspect before interpreting C1/C2"}`);

writeFileSync("mathlib-study/results-cell-composition.json", JSON.stringify({ seed: SEED, perms: PERMS, out, C1: c1, C2: c2, C0: c0 }, null, 1));
console.log("\nwritten: mathlib-study/results-cell-composition.json");
