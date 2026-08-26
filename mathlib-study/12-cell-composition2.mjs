// Cell-composition study v2: do the non-Boolean cells align with the
// human conceptual taxonomy in module names? (v1 = script 10, dead by
// instrument saturation; see its postscript.)
//
// PRE-REGISTRATION (written before first run, 2026-08-26; resolution
// pre-check 11-cell-precheck2.mjs committed first — pair-level name
// statistics only, no kernels, no cells, so these predictions stay blind
// to the alignment under test while the measure's dynamic range is now
// verified rather than assumed).
//
// WHAT CHANGED FROM v1, AND WHY (both changes forced by v1's failure
// mode, neither by any outcome knowledge):
//   1. MEASURE. sameArea(y, x) = [y and x share >= k* leading name
//      components], with k* = 3 pinned per namespace by the committed
//      pre-check (fraction of pairs sharing >= 3: Order 0.057, Topology
//      0.092, Algebra 0.079 — real range; >= 4 is degenerate at < 0.011).
//      "Same area" = same named subarea of the namespace.
//   2. STATISTIC. Pooled, not per-kernel-median: per cell C in
//      {I, R, E, D}, pooled(C) = (Σ over evaluable kernels of # members of
//      C sharing area with the apex) / (Σ of |C|). Sparse fractions
//      zero-inflate per-kernel medians (v1's saturation, one level up);
//      pooled fractions cannot saturate. Per-kernel sign fractions are
//      reported as descriptive color only.
//
// EVERYTHING ELSE IS v1's UNCHANGED: corpus (HEAD pin 1fb6b28816; Order,
// Topology, Algebra; namespace-internal imports), cell classification at
// the identity world (verbatim 09), evaluable population = ordinary
// kernels with E, D, R nonempty (286/643/1274, pinned by committed
// pre-check 09), apex excluded from I, name-permutation null (reassign
// names to nodes uniformly, cells fixed; 100 permutations, mulberry32
// seed 20260826601, one stream).
//
// PREDICTIONS (the dictionary's contentful claims, as v1):
//   C1' (Exploitation is on-territory — primary):
//      sED = pooled(E) - pooled(D) > 0 in all three namespaces, AND
//      observed sED above the 95th percentile of its permutation null in
//      >= 2 of 3 namespaces. HARD FAIL in addition if any namespace at or
//      below the 5th percentile (significant reversal).
//   C2' (Distribution straddles — secondary): same criteria on
//      sDR = pooled(D) - pooled(R).
//   C0' (calibration, reported not scored): pooled(I) is the largest of
//      the four pooled fractions per namespace (near-definitional: I is
//      the apex's own foundation).
//
// INTERPRETATION, FIXED IN ADVANCE (as v1): both hold -> the cell
// dictionary gains corpus-level [computed] support on Mathlib (protocol
// validated; no other domain's dictionary inherits it). C1' fails against
// a live null -> "Exploitation = on-territory" is unsupported where most
// checkable, flagged in every outward document. Observed inside the null
// -> raw gradient is a cell-size artifact, reported as caught.
//
// Output: mathlib-study/results-cell-composition2.json (raw, committed).

import { readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const NAMESPACES = ["Order", "Topology", "Algebra"];
const HEADBASE = "lean/.lake/packages/mathlib/Mathlib";
const KSTAR = 3;
const PERMS = 100;
const SEED = 20260826601;

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

// bitset helpers (verbatim 09)
const W = (n) => (n + 31) >> 5;
const bsNew = (w) => new Uint32Array(w);
const bsSet = (b, i) => { b[i >> 5] |= 1 << (i & 31); };
const bsHas = (b, i) => (b[i >> 5] >>> (i & 31)) & 1;
const bsOrInto = (dst, src) => { for (let k = 0; k < dst.length; k++) dst[k] |= src[k]; };
const bsIntersects = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] & b[k]) return true; return false; };
const bsSubset = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] & ~b[k]) return false; return true; };
const bsEq = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] !== b[k]) return false; return true; };
const bsAny = (a) => { for (let k = 0; k < a.length; k++) if (a[k]) return true; return false; };

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

  // foundations (verbatim 09)
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

  // evaluable kernels and cells (verbatim semantics of 09/10)
  const kernels = [];
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

  // sameArea matrix at k* (bitset per node: which nodes share >= k* comps)
  const comps = mods.map((m) => m.split("."));
  const share = new Array(n);
  for (let i = 0; i < n; i++) {
    const b = bsNew(w);
    for (let j = 0; j < n; j++) {
      if (i === j) continue;
      let s = 0;
      const L = Math.min(comps[i].length, comps[j].length);
      while (s < L && comps[i][s] === comps[j][s]) s++;
      if (s >= KSTAR) bsSet(b, j);
    }
    share[i] = b;
  }

  // pooled cell fractions under a node->name assignment
  const pooled = (nameOf) => {
    const num = [0, 0, 0, 0], den = [0, 0, 0, 0];
    for (const { x, cells } of kernels) {
      const sx = share[nameOf(x)];
      for (let y = 0; y < n; y++) {
        if (y === x) continue;
        const c = cells[y];
        den[c]++;
        if (bsHas(sx, nameOf(y))) num[c]++;
      }
    }
    const f = num.map((v, i) => v / den[i]);
    return { I: f[0], R: f[1], E: f[2], D: f[3], sED: f[2] - f[3], sDR: f[3] - f[1] };
  };

  const obs = pooled((i) => i);

  const nullSED = [], nullSDR = [];
  for (let p = 0; p < PERMS; p++) {
    const perm = [...Array(n).keys()];
    for (let i = n - 1; i > 0; i--) {
      const j = Math.floor(rand() * (i + 1));
      [perm[i], perm[j]] = [perm[j], perm[i]];
    }
    const r = pooled((i) => perm[i]);
    nullSED.push(r.sED); nullSDR.push(r.sDR);
  }

  out[ns] = {
    evaluableKernels: kernels.length,
    observed: obs,
    null: {
      sED: { p5: [...nullSED].sort((a, b) => a - b)[4], p95: [...nullSED].sort((a, b) => a - b)[94], obsPctile: pctile(nullSED, obs.sED) },
      sDR: { p5: [...nullSDR].sort((a, b) => a - b)[4], p95: [...nullSDR].sort((a, b) => a - b)[94], obsPctile: pctile(nullSDR, obs.sDR) },
    },
  };
  console.log(
    `${ns}: kernels=${kernels.length}  pooled sameArea I/E/D/R = ` +
    `${obs.I.toFixed(4)}/${obs.E.toFixed(4)}/${obs.D.toFixed(4)}/${obs.R.toFixed(4)}\n` +
    `  sED: obs=${obs.sED.toFixed(4)}  null[5,95]=[${out[ns].null.sED.p5.toFixed(4)}, ${out[ns].null.sED.p95.toFixed(4)}]  obs pctile=${out[ns].null.sED.obsPctile.toFixed(1)}\n` +
    `  sDR: obs=${obs.sDR.toFixed(4)}  null[5,95]=[${out[ns].null.sDR.p5.toFixed(4)}, ${out[ns].null.sDR.p95.toFixed(4)}]  obs pctile=${out[ns].null.sDR.obsPctile.toFixed(1)}`
  );
}

// ---- verdicts ----
const evalPred = (key) => {
  const allPos = NAMESPACES.every((ns) => out[ns].observed[key] > 0);
  const beat95 = NAMESPACES.filter((ns) => out[ns].null[key].obsPctile > 95).length;
  const rev5 = NAMESPACES.some((ns) => out[ns].null[key].obsPctile <= 5);
  return { allPos, beat95, rev5, holds: allPos && beat95 >= 2 && !rev5 };
};
const c1 = evalPred("sED");
const c2 = evalPred("sDR");
const c0 = NAMESPACES.every((ns) => {
  const o = out[ns].observed;
  return o.I >= o.E && o.I >= o.D && o.I >= o.R;
});
console.log(`\nC1' (E on-territory): all-positive=${c1.allPos}, beats-95th in ${c1.beat95}/3, reversal=${c1.rev5}  -> ${c1.holds ? "HOLDS" : "FAILS"}`);
console.log(`C2' (D straddles):    all-positive=${c2.allPos}, beats-95th in ${c2.beat95}/3, reversal=${c2.rev5}  -> ${c2.holds ? "HOLDS" : "FAILS"}`);
console.log(`C0' (calibration, I highest): ${c0 ? "as expected" : "VIOLATED — inspect before interpreting C1'/C2'"}`);

writeFileSync("mathlib-study/results-cell-composition2.json", JSON.stringify({ seed: SEED, perms: PERMS, kStar: KSTAR, out, C1: c1, C2: c2, C0: c0 }, null, 1));
console.log("\nwritten: mathlib-study/results-cell-composition2.json");
