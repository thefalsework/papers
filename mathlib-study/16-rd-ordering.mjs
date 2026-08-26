// R/D-ordering study: is Distribution name-closer than Refusal — the
// ORIGINAL dictionary ordering — a corpus regularity?
//
// PRE-REGISTRATION (written before first run, 2026-08-26; committed with
// the blind pre-check 15-smallns-precheck.mjs).
//
// PROVENANCE, STATED PLAINLY. Script 12 (Order/Topology/Algebra) failed
// to establish the original ordering sDR = pooled(D) - pooled(R) > 0
// (2 of 3 namespaces negative-inside-null). Its post-hoc reading — R
// proximate — was registered as G2 in script 14 on thirteen held-out
// namespaces and REFUTED by significant reversal in 8 of 13. The
// reversal direction is the original ordering. That makes the original
// ordering twice-observed but never scored: once as a failed prediction
// on three namespaces, once as the unpredicted failure mode of its
// negation. This study scores it on the ONLY remaining fresh corpora:
// the five sub-100-file namespaces that pass the pre-check's inclusion
// rule (>= 30 evaluable kernels, resolvable k*): FieldTheory, Logic,
// SetTheory, RepresentationTheory, ModelTheory (all k* = 3). After this
// run there are no fresh Mathlib namespaces left; whatever the verdict,
// it is final for this corpus.
//
// INSTRUMENT: verbatim scripts 12/14. sameArea at k* = 3; pooled
// per-cell fractions over evaluable kernels; name-permutation null
// (100 permutations per namespace; mulberry32 seed 20260826801, one
// stream). Statistic: sDR = pooled(D) - pooled(R).
//
// PREDICTION:
//   G3 (Distribution nearer than Refusal): sDR > 0 in >= 4 of 5
//      namespaces, AND observed sDR above the 95th percentile of its
//      null in >= 2 of 5, AND no namespace at or below the 5th
//      percentile.
//
// INTERPRETATION, FIXED IN ADVANCE:
//   G3 holds -> the original dictionary ordering (Refusal farthest from
//     the kernel's named territory, Distribution nearer) is a Mathlib
//     corpus regularity, with Order and Topology recorded as named
//     exceptions; outward documents state it in that form.
//   G3 fails -> the R/D geography is namespace-contingent full stop; no
//     ordering claim survives, and every outward gloss of R and D drops
//     spatial language entirely.
//   sED is reported per namespace as descriptive replication color, not
//   scored (G1 already holds 16/16).
//
// Output: mathlib-study/results-rd-ordering.json (raw, committed).
//
// POSTSCRIPT (2026-08-26, after execution — run as registered, no
// deviations). G3 FAILS: sDR positive in 2/5 (FieldTheory at the 99th
// percentile, ModelTheory inside the null), zero in RepresentationTheory
// (both cells fully off-territory), significantly REVERSED in Logic
// (pctile 0) and SetTheory (pctile 2). Per the fixed interpretation: the
// R/D geography is namespace-contingent full stop, no ordering claim
// survives in either direction, and outward glosses of Refusal and
// Distribution drop spatial language entirely. Mathlib is now exhausted
// as a corpus for this question — 21 namespaces, all used, none fresh.
//
// POST-HOC observation, flagged as such and untestable on this corpus:
// the four R-proximate namespaces (Order, Topology, Logic, SetTheory)
// are Mathlib's foundational strata, while D-nearer namespaces are
// working mathematics (Analysis, RingTheory, NumberTheory, Geometry...).
// If the R/D geography tracks foundational-vs-applied character, only a
// different corpus can say so.
//
// DESCRIPTIVE replication color: sED positive at the 99th-100th
// percentile in 4 of 5 (ModelTheory inside the null at 31, the smallest
// evaluable population in the whole program). Across every registered
// run, "Exploitation on-territory" now stands at 20 of 21 namespaces
// with zero significant reversals.

import { readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const NAMESPACES = ["FieldTheory", "Logic", "SetTheory", "RepresentationTheory", "ModelTheory"];
const HEADBASE = "lean/.lake/packages/mathlib/Mathlib";
const KSTAR = 3;
const PERMS = 100;
const SEED = 20260826801;

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
    return { I: f[0], R: f[1], E: f[2], D: f[3], sED: f[2] - f[3], sDR: f[3] - f[1] };
  };

  const obs = pooled((i) => i);

  const nullSDR = [], nullSED = [];
  for (let p = 0; p < PERMS; p++) {
    const perm = [...Array(n).keys()];
    for (let i = n - 1; i > 0; i--) {
      const j = Math.floor(rand() * (i + 1));
      [perm[i], perm[j]] = [perm[j], perm[i]];
    }
    const r = pooled((i) => perm[i]);
    nullSDR.push(r.sDR); nullSED.push(r.sED);
  }

  const band = (arr, v) => ({
    p5: [...arr].sort((a, b) => a - b)[4],
    p95: [...arr].sort((a, b) => a - b)[94],
    obsPctile: pctile(arr, v),
  });
  out[ns] = {
    evaluableKernels: kernels.length,
    observed: obs,
    null: { sDR: band(nullSDR, obs.sDR), sED: band(nullSED, obs.sED) },
  };
  console.log(
    `${ns}: kernels=${kernels.length}  pooled I/E/D/R = ` +
    `${obs.I.toFixed(4)}/${obs.E.toFixed(4)}/${obs.D.toFixed(4)}/${obs.R.toFixed(4)}\n` +
    `  sDR: obs=${obs.sDR.toFixed(4)}  null[5,95]=[${out[ns].null.sDR.p5.toFixed(4)}, ${out[ns].null.sDR.p95.toFixed(4)}]  pctile=${out[ns].null.sDR.obsPctile.toFixed(1)}\n` +
    `  sED (descriptive): obs=${obs.sED.toFixed(4)}  pctile=${out[ns].null.sED.obsPctile.toFixed(1)}`
  );
}

const positive = NAMESPACES.filter((ns) => out[ns].observed.sDR > 0).length;
const beat95 = NAMESPACES.filter((ns) => out[ns].null.sDR.obsPctile > 95).length;
const rev5 = NAMESPACES.filter((ns) => out[ns].null.sDR.obsPctile <= 5).length;
const g3 = { positive, beat95, rev5, holds: positive >= 4 && beat95 >= 2 && rev5 === 0 };
console.log(`\nG3 (D nearer than R): positive ${positive}/5, beats-95th ${beat95}/5, reversals ${rev5}  -> ${g3.holds ? "HOLDS" : "FAILS"}`);

writeFileSync("mathlib-study/results-rd-ordering.json", JSON.stringify({ seed: SEED, perms: PERMS, kStar: KSTAR, out, G3: g3 }, null, 1));
console.log("\nwritten: mathlib-study/results-rd-ordering.json");
