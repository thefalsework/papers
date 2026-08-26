// Structural pre-check for the R/D-ordering study (script 16).
//
// BLINDNESS DISCIPLINE (as 13): occupancy COUNTS and pair-level name
// resolution only. Nothing here can leak the R-vs-D alignment that
// script 16 predicts.
//
// Corpus pool: the LAST fresh Mathlib namespaces — every top-level dir
// with 30-99 .lean files at the HEAD pin, mathematical content only
// (excluding Lean and Util tooling): FieldTheory, Logic, SetTheory,
// RepresentationTheory, Computability, ModelTheory, Condensed, Dynamics.
// Inclusion rule for the study, fixed here: a namespace enters script 16
// iff it has >= 30 evaluable kernels AND a resolvable k* (smallest k >= 3
// with pair fraction in (0.02, 0.5], the rule of script 11).
//
// Writes mathlib-study/results-smallns-precheck.json.

import { readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const NAMESPACES = [
  "FieldTheory", "Logic", "SetTheory", "RepresentationTheory",
  "Computability", "ModelTheory", "Condensed", "Dynamics",
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

  const included = evaluable >= 30 && kStar !== null;
  out[ns] = { modules: n, ordinary, evaluable, kStar, included, fracAtLeast: frac.slice(0, Math.min(8, maxDepth + 1)) };
  console.log(
    `${ns.padEnd(21)} mods=${String(n).padStart(3)} ordinary=${String(ordinary).padStart(3)} ` +
    `evaluable=${String(evaluable).padStart(3)} k*=${kStar ?? "NONE"} frac>=3: ${frac[3]?.toFixed(3) ?? "n/a"} ` +
    `-> ${included ? "INCLUDED" : "excluded"}`
  );
}

writeFileSync("mathlib-study/results-smallns-precheck.json", JSON.stringify(out, null, 1));
console.log("\nwritten: mathlib-study/results-smallns-precheck.json (counts and pair-level resolution only)");
