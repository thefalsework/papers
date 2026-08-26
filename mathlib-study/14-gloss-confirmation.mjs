// Gloss-confirmation study: do the corrected R/D readings replicate
// out-of-sample?
//
// PRE-REGISTRATION (written before first run, 2026-08-26; committed with
// the blind pre-check 13-gloss-precheck.mjs, which touched only occupancy
// counts and pair-level name resolution — nothing that can leak the
// alignment predicted below).
//
// WHY THIS STUDY EXISTS. Script 12 (v2 cell composition, Order/Topology/
// Algebra) ended in a split verdict: C1' (Exploitation on-territory) held
// decisively; C2' (Distribution at intermediate proximity) failed. Its
// postscript recorded a POST-HOC observation: in Order and Topology the
// Refusal cell was name-CLOSER to the apex than Distribution — suggesting
// corrected glosses ("refusal happens on-territory; distribution lives
// abroad") — while Algebra showed the strong reverse. A post-hoc reading
// from 2 of 3 namespaces earns nothing. This study registers it as a
// prediction on THIRTEEN held-out namespaces never used in any cell
// study: CategoryTheory, Analysis, RingTheory, Data, LinearAlgebra,
// MeasureTheory, NumberTheory, Combinatorics, GroupTheory,
// AlgebraicTopology, Geometry, AlgebraicGeometry, Probability (neutral
// rule: every top-level Mathlib dir with >= 100 .lean files at the HEAD
// pin, minus the three already studied and minus Tactic tooling). The
// pre-check found all thirteen evaluable (91-1074 kernels) with k* = 3.
//
// INSTRUMENT: verbatim script 12. sameArea at k* = 3; pooled per-cell
// fractions over evaluable kernels (ordinary, E/D/R nonempty); name-
// permutation null (names reassigned to nodes uniformly, cells fixed;
// 100 permutations per namespace; mulberry32 seed 20260826701, one
// stream). Statistics per namespace:
//   sED = pooled(E) - pooled(D)   (replication of C1')
//   sRD = pooled(R) - pooled(D)   (the corrected glosses, new claim)
//
// PREDICTIONS:
//   G1 (out-of-sample replication of "Exploitation on-territory"):
//      sED > 0 in >= 10 of 13 namespaces, AND observed sED above the 95th
//      percentile of its null in >= 7 of 13, AND no namespace at or below
//      the 5th percentile. This is the flagship cell finding facing 13
//      corpora it has never seen; failure here must be flagged in every
//      outward document that cites it.
//   G2 (corrected glosses — refusal proximate, distribution abroad):
//      sRD > 0 in >= 9 of 13 namespaces, AND the count of namespaces above
//      the 95th percentile is >= 3 AND strictly exceeds the count at or
//      below the 5th. Prior evidence is genuinely mixed (2 of 3, one
//      strong reversal), so this is written to be able to fail.
//
// INTERPRETATION, FIXED IN ADVANCE:
//   G2 holds -> the R and D glosses are rewritten in outward documents
//     (briefs, study READMEs): Refusal glossed as on-territory
//     self-containment, Distribution as off-territory partial dependence;
//     any reversal namespaces named alongside. G2 fails -> the post-hoc
//     observation is recorded as not replicating, the v2 postscript's
//     flag stands, and no gloss is rewritten.
//   G1 fails -> "Exploitation on-territory" is demoted from corpus
//     regularity to fact-about-three-namespaces everywhere it appears.
//   Directional-but-thin outcomes (majority sign, insufficient null
//   exceedance) score as FAILS; no partial credit.
//
// Output: mathlib-study/results-gloss-confirmation.json (raw, committed).

import { readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const NAMESPACES = [
  "CategoryTheory", "Analysis", "RingTheory", "Data", "LinearAlgebra",
  "MeasureTheory", "NumberTheory", "Combinatorics", "GroupTheory",
  "AlgebraicTopology", "Geometry", "AlgebraicGeometry", "Probability",
];
const HEADBASE = "lean/.lake/packages/mathlib/Mathlib";
const KSTAR = 3;
const PERMS = 100;
const SEED = 20260826701;

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

// bitset helpers (verbatim 09/12)
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

  // foundations (verbatim 09/12)
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

  // evaluable kernels and cells (verbatim 09/12)
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

  // sameArea matrix at k* (verbatim 12)
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
    return { I: f[0], R: f[1], E: f[2], D: f[3], sED: f[2] - f[3], sRD: f[1] - f[3] };
  };

  const obs = pooled((i) => i);

  const nullSED = [], nullSRD = [];
  for (let p = 0; p < PERMS; p++) {
    const perm = [...Array(n).keys()];
    for (let i = n - 1; i > 0; i--) {
      const j = Math.floor(rand() * (i + 1));
      [perm[i], perm[j]] = [perm[j], perm[i]];
    }
    const r = pooled((i) => perm[i]);
    nullSED.push(r.sED); nullSRD.push(r.sRD);
  }

  const band = (arr, v) => ({
    p5: [...arr].sort((a, b) => a - b)[4],
    p95: [...arr].sort((a, b) => a - b)[94],
    obsPctile: pctile(arr, v),
  });
  out[ns] = {
    evaluableKernels: kernels.length,
    observed: obs,
    null: { sED: band(nullSED, obs.sED), sRD: band(nullSRD, obs.sRD) },
  };
  console.log(
    `${ns}: kernels=${kernels.length}  pooled I/E/D/R = ` +
    `${obs.I.toFixed(4)}/${obs.E.toFixed(4)}/${obs.D.toFixed(4)}/${obs.R.toFixed(4)}\n` +
    `  sED: obs=${obs.sED.toFixed(4)}  null[5,95]=[${out[ns].null.sED.p5.toFixed(4)}, ${out[ns].null.sED.p95.toFixed(4)}]  pctile=${out[ns].null.sED.obsPctile.toFixed(1)}\n` +
    `  sRD: obs=${obs.sRD.toFixed(4)}  null[5,95]=[${out[ns].null.sRD.p5.toFixed(4)}, ${out[ns].null.sRD.p95.toFixed(4)}]  pctile=${out[ns].null.sRD.obsPctile.toFixed(1)}`
  );
}

// ---- verdicts ----
const NNS = NAMESPACES.length;
const stats = (key) => ({
  positive: NAMESPACES.filter((ns) => out[ns].observed[key] > 0).length,
  beat95: NAMESPACES.filter((ns) => out[ns].null[key].obsPctile > 95).length,
  rev5: NAMESPACES.filter((ns) => out[ns].null[key].obsPctile <= 5).length,
});
const g1s = stats("sED");
const g1 = { ...g1s, holds: g1s.positive >= 10 && g1s.beat95 >= 7 && g1s.rev5 === 0 };
const g2s = stats("sRD");
const g2 = { ...g2s, holds: g2s.positive >= 9 && g2s.beat95 >= 3 && g2s.beat95 > g2s.rev5 };
console.log(`\nG1 (E on-territory, out-of-sample): positive ${g1.positive}/${NNS}, beats-95th ${g1.beat95}/${NNS}, reversals ${g1.rev5}  -> ${g1.holds ? "HOLDS" : "FAILS"}`);
console.log(`G2 (R proximate, D abroad):         positive ${g2.positive}/${NNS}, beats-95th ${g2.beat95}/${NNS}, reversals ${g2.rev5}  -> ${g2.holds ? "HOLDS" : "FAILS"}`);

writeFileSync("mathlib-study/results-gloss-confirmation.json", JSON.stringify({ seed: SEED, perms: PERMS, kStar: KSTAR, out, G1: g1, G2: g2 }, null, 1));
console.log("\nwritten: mathlib-study/results-gloss-confirmation.json");
