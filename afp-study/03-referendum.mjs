// AFP referendum, part 1: does the cell finding survive a different proof
// assistant, community, and ground-truth instrument? And does the
// foundational-strata reading of R/D geography — post-hoc on Mathlib,
// untestable there — hold when registered in advance?
//
// PRE-REGISTRATION (written before first run, 2026-08-26; committed with
// the blind census 01 and pre-check 02, which touched only corpus sizes,
// parse rates, gate counts, and pair-level topic statistics).
//
// WHY THIS IS A REFERENDUM. Everything the program has found empirically,
// it has found on one corpus (Mathlib), one community, one grain, one
// ground-truth instrument (name prefixes). The Archive of Formal Proofs
// is a different proof assistant (Isabelle), a different community, a
// different grain (entries = refereed contributions, not modules), and a
// different ground truth (author-assigned topic labels from a curated
// taxonomy, assigned for the archive's own purposes, blind to us).
// Nothing about Mathlib's outcomes leaks here.
//
// CORPUS: AFP git mirror, HEAD pin 1e072b5cc6b4a19ed1f4f905feddb07b884c9f2c
// (2026-08-25), at .scratch_afp (untracked; regeneration: clone
// github.com/isabelle-prover/mirror-afp-devel, checkout the pin).
// Entry-level import graph: edge A -> B when any theory of A imports a
// theory of B (resolution rules and their measured rates in census 01;
// 8% of import tokens unresolved is a stated approximation, as
// namespace-internal edges were on Mathlib). The one 4-entry import knot
// is handled by the cycle-tolerant down-closure (preorder reflection).
// Stated approximation: the Isabelle distribution (HOL itself) is outside
// the corpus; "foundational" is operationalized WITHIN the archive by
// topic, not by distance to HOL.
//
// INSTRUMENT (verbatim protocol of mathlib-study 12/14/16, new measure):
//   sameArea(y, x) = entries y and x share >= 1 full topic path
//     (pre-check 02: pair fraction 0.055 overall, 0.096-0.157 in strata —
//     real dynamic range, no saturation).
//   Pooled per-cell fractions over evaluable kernels (ordinary, E/D/R
//   nonempty; populations pinned by 02: ALL 553, Logic 54, Mathematics
//   172, Computer science 208).
//   Null: topic-permutation — reassign entries' topic lists uniformly
//   among the graph's members (within-stratum for strata), cells fixed;
//   100 permutations; mulberry32 seed 20260826901, one stream.
//
// PREDICTIONS:
//   R1 (Exploitation on-territory, cross-assistant): on the full entry
//      graph, sED = pooled(E) - pooled(D) > 0 AND above the 95th
//      percentile of its null. On Mathlib this held 16/16; this is its
//      first out-of-ecosystem test.
//   R2 (foundational strata, the Mathlib post-hoc pattern registered):
//      with sRD = pooled(R) - pooled(D) per stratum:
//        R2a: Logic (the archive's foundational stratum): sRD > 0 AND
//             above the 95th percentile of its null.
//        R2b: Mathematics AND Computer science (working strata):
//             sRD < 0 in both, AND at least one at or below the 5th
//             percentile.
//      R2 holds iff R2a and R2b both hold. This is a sharp compound
//      prediction and the prior is genuinely uncertain: on Mathlib the
//      pattern was 4 foundational namespaces R-proximate vs 8 working
//      namespaces D-nearer, all observed post hoc.
//
// INTERPRETATION, FIXED IN ADVANCE:
//   R1 holds -> "Exploitation is on-territory" graduates from a Mathlib
//     fact to a claim about collective formal work across ecosystems;
//     outward documents may say so, citing both corpora.
//   R1 fails -> it is demoted to a Lean/Mathlib-specific fact everywhere
//     it appears, including the 16/16 sentence.
//   R2 holds -> the R/D geography is not namespace-contingent noise but
//     structured by foundational-vs-applied character; the Mathlib
//     post-hoc observation is confirmed as a cross-corpus regularity.
//   R2 fails -> the foundational-strata reading is recorded as not
//     replicating; R/D geography stays dead as registered on Mathlib.
//   Partial R2 (a or b alone): FAILS, no partial credit; components
//     reported.
//
// Output: afp-study/results-referendum.json (raw, committed).
//
// POSTSCRIPT (2026-08-26, after execution — run as registered, no
// deviations). R1 HOLDS at the 100th percentile: sED = +0.0334 on the
// full entry graph against a null band of ±0.0055 — and descriptively at
// the 100th percentile inside every stratum (Logic +0.3853, Mathematics
// +0.1232, Computer science +0.0309). "Exploitation is on-territory" has
// now survived: two proof assistants, two communities, two grains
// (module and refereed entry), and two ground-truth instruments (name
// paths and curated topic labels). Per the fixed interpretation, it
// graduates to a claim about collective formal work across ecosystems.
//
// R2 FAILS. R2a: Logic's sRD = -0.0320 at percentile 20 — inside the
// null, wrong sign; the archive's foundational stratum shows no
// refusal-proximity. R2b held (Mathematics -0.1366 and Computer science
// -0.0859, both at percentile 0), but the compound prediction fails
// without partial credit. The foundational-strata reading of R/D
// geography, post-hoc on Mathlib, does not replicate when registered.
// R/D geography stays dead as scored there. POST-HOC, flagged: on AFP
// the D-nearer-than-R direction is significant everywhere it can be
// (ALL/Math/CS at percentile 0) with Logic inside the null — AFP as a
// whole resembles Mathlib's working namespaces, and the R-proximate
// phenomenon has now been seen nowhere outside four Mathlib namespaces.

import { readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { join, basename } from "node:path";

const ROOT = ".scratch_afp/thys";
const META = ".scratch_afp/metadata/entries";
const PERMS = 100;
const SEED = 20260826901;

let rngState = SEED;
const rand = () => {
  rngState |= 0; rngState = (rngState + 0x6d2b79f5) | 0;
  let t = Math.imul(rngState ^ (rngState >>> 15), 1 | rngState);
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};

const entries = readdirSync(ROOT).filter((d) => statSync(join(ROOT, d)).isDirectory()).sort();
const topicsOf = new Map();
for (const e of entries) {
  try {
    const toml = readFileSync(join(META, `${e}.toml`), "utf8");
    const tm = toml.match(/topics\s*=\s*\[([\s\S]*?)\]/);
    if (tm) {
      const t = [...tm[1].matchAll(/"([^"]+)"/g)].map((x) => x[1]);
      if (t.length) topicsOf.set(e, t);
    }
  } catch { /* absent */ }
}

// entry-level edges (verbatim 01/02 resolution)
const thyFiles = [];
for (const e of entries) {
  const walk = (dir) => {
    for (const f of readdirSync(dir)) {
      const p = join(dir, f);
      if (statSync(p).isDirectory()) walk(p);
      else if (f.endsWith(".thy")) thyFiles.push({ entry: e, name: basename(f, ".thy"), path: p });
    }
  };
  walk(join(ROOT, e));
}
const byName = new Map();
const nodeId = new Map();
thyFiles.forEach((t, i) => {
  nodeId.set(`${t.entry}/${t.name}`, i);
  if (!byName.has(t.name)) byName.set(t.name, []);
  byName.get(t.name).push(i);
});
const stripComments = (s) => {
  let out = "", d = 0;
  for (let i = 0; i < s.length; i++) {
    if (s[i] === "(" && s[i + 1] === "*") { d++; i++; continue; }
    if (s[i] === "*" && s[i + 1] === ")" && d > 0) { d--; i++; continue; }
    if (d === 0) out += s[i];
  }
  return out;
};
const DIST_SESSIONS = /^(HOL|Pure|FOL|ZF|CCL|CTT|Cube|FOLP|LCF|Sequents|Tools|Doc)\b/;
const crossEntryPairs = new Set();
for (const t of thyFiles) {
  const src = readFileSync(t.path, "utf8");
  const head = stripComments(src.slice(0, 20000));
  const m = head.match(/\btheory\b[\s\S]*?\bimports\b([\s\S]*?)\bbegin\b/);
  if (!m) continue;
  const re = /"([^"]+)"|([\w.\-/]+)/g;
  let g;
  while ((g = re.exec(m[1])) !== null) {
    const tok = (g[1] ?? g[2]).trim();
    if (tok === "keywords" || tok === "abbrevs") break;
    const clean = tok.replace(/\.thy$/, "");
    const last = clean.split("/").pop();
    const dot = last.lastIndexOf(".");
    if (dot > 0) {
      const sess = last.slice(0, dot), thy = last.slice(dot + 1);
      if (DIST_SESSIONS.test(sess)) continue;
      if (nodeId.has(`${sess}/${thy}`) && sess !== t.entry) crossEntryPairs.add(`${t.entry}>${sess}`);
      continue;
    }
    if (nodeId.has(`${t.entry}/${last}`)) continue;
    const global = byName.get(last);
    if (global && global.length === 1 && thyFiles[global[0]].entry !== t.entry)
      crossEntryPairs.add(`${t.entry}>${thyFiles[global[0]].entry}`);
  }
}

const bsNew = (w) => new Uint32Array(w);
const bsSet = (b, i) => { b[i >> 5] |= 1 << (i & 31); };
const bsHas = (b, i) => (b[i >> 5] >>> (i & 31)) & 1;
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

const study = (members) => {
  const idx = new Map(members.map((e, i) => [e, i]));
  const n = members.length, w = (n + 31) >> 5;
  const adjIn = Array.from({ length: n }, () => new Set());
  for (const pair of crossEntryPairs) {
    const [a, b] = pair.split(">");
    if (idx.has(a) && idx.has(b)) adjIn[idx.get(a)].add(idx.get(b));
  }
  // cycle-tolerant down-closure (preorder reflection; unsigned coercion!)
  const down = Array.from({ length: n }, (_, i) => { const b = bsNew(w); bsSet(b, i); return b; });
  let changed = true;
  while (changed) {
    changed = false;
    for (let i = 0; i < n; i++)
      for (const j of adjIn[i])
        for (let k = 0; k < w; k++) {
          const nv = (down[i][k] | down[j][k]) >>> 0;
          if (nv !== down[i][k]) { down[i][k] = nv; changed = true; }
        }
  }
  // evaluable kernels + cells
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
  // topic-share bitsets over member names
  const share = new Array(n);
  for (let i = 0; i < n; i++) {
    const b = bsNew(w);
    const ti = topicsOf.get(members[i]);
    for (let j = 0; j < n; j++) {
      if (i === j) continue;
      const tj = topicsOf.get(members[j]);
      if (ti.some((t) => tj.includes(t))) bsSet(b, j);
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
  return {
    evaluableKernels: kernels.length,
    observed: obs,
    null: { sED: band(nullSED, obs.sED), sRD: band(nullSRD, obs.sRD) },
  };
};

const topOf = (e) => topicsOf.get(e)?.[0]?.split("/")[0] ?? null;
const groups = {
  ALL: entries.filter((e) => topicsOf.has(e)),
  Logic: entries.filter((e) => topOf(e) === "Logic"),
  Mathematics: entries.filter((e) => topOf(e) === "Mathematics"),
  ComputerScience: entries.filter((e) => topOf(e) === "Computer science"),
};
const out = {};
for (const [name, members] of Object.entries(groups)) {
  out[name] = study(members);
  const r = out[name];
  console.log(
    `${name}: kernels=${r.evaluableKernels}  pooled I/E/D/R = ` +
    `${r.observed.I.toFixed(4)}/${r.observed.E.toFixed(4)}/${r.observed.D.toFixed(4)}/${r.observed.R.toFixed(4)}\n` +
    `  sED: obs=${r.observed.sED.toFixed(4)}  null[5,95]=[${r.null.sED.p5.toFixed(4)}, ${r.null.sED.p95.toFixed(4)}]  pctile=${r.null.sED.obsPctile.toFixed(1)}\n` +
    `  sRD: obs=${r.observed.sRD.toFixed(4)}  null[5,95]=[${r.null.sRD.p5.toFixed(4)}, ${r.null.sRD.p95.toFixed(4)}]  pctile=${r.null.sRD.obsPctile.toFixed(1)}`
  );
}

const r1 = {
  sED: out.ALL.observed.sED,
  pctile: out.ALL.null.sED.obsPctile,
  holds: out.ALL.observed.sED > 0 && out.ALL.null.sED.obsPctile > 95,
};
const r2a = {
  sRD: out.Logic.observed.sRD,
  pctile: out.Logic.null.sRD.obsPctile,
  holds: out.Logic.observed.sRD > 0 && out.Logic.null.sRD.obsPctile > 95,
};
const r2b = {
  math: { sRD: out.Mathematics.observed.sRD, pctile: out.Mathematics.null.sRD.obsPctile },
  cs: { sRD: out.ComputerScience.observed.sRD, pctile: out.ComputerScience.null.sRD.obsPctile },
  holds:
    out.Mathematics.observed.sRD < 0 && out.ComputerScience.observed.sRD < 0 &&
    (out.Mathematics.null.sRD.obsPctile <= 5 || out.ComputerScience.null.sRD.obsPctile <= 5),
};
const r2 = { r2a, r2b, holds: r2a.holds && r2b.holds };
console.log(`\nR1 (E on-territory, cross-assistant): sED=${r1.sED.toFixed(4)} pctile=${r1.pctile.toFixed(1)}  -> ${r1.holds ? "HOLDS" : "FAILS"}`);
console.log(`R2a (Logic: R proximate):  sRD=${r2a.sRD.toFixed(4)} pctile=${r2a.pctile.toFixed(1)}  -> ${r2a.holds ? "holds" : "fails"}`);
console.log(`R2b (working: D nearer):   Math sRD=${r2b.math.sRD.toFixed(4)} p=${r2b.math.pctile.toFixed(1)}; CS sRD=${r2b.cs.sRD.toFixed(4)} p=${r2b.cs.pctile.toFixed(1)}  -> ${r2b.holds ? "holds" : "fails"}`);
console.log(`R2 (foundational strata): ${r2.holds ? "HOLDS" : "FAILS"}`);

writeFileSync("afp-study/results-referendum.json", JSON.stringify({ seed: SEED, perms: PERMS, out, R1: r1, R2: r2 }, null, 1));
console.log("\nwritten: afp-study/results-referendum.json");
