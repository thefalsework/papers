// Role-classified cone study: does the flat (wide-aperture) regime track
// ROLE (definitional interface) rather than AGE?
//
// PRE-REGISTRATION (written before first run, 2026-08-19):
//
// Corpus: HEAD pin (1fb6b28816), namespaces Order, Topology, Algebra.
// Cones: every module whose foundation has size in [10, 18], deduplicated by
//   cone content (first apex in alphabetical order keeps the cone), capped at
//   80 per namespace by seeded random sample (seed 20260821) if over.
//
// Role (primary, content-based): cone defFrac = (# def-like declarations) /
//   (# def-like + # theorem-like), aggregated over all modules in the cone.
//   def-like: def, abbrev, structure, class, instance, inductive.
//   theorem-like: theorem, lemma.
//   INTERFACE iff defFrac >= 0.5, CONTENT otherwise.
// Role (secondary, name-based): apex has a path component in
//   {Defs, Notation, Init}.
// Age: apex present in the 2023-09 or 2024-03 snapshot = OLD; else YOUNG.
//   (Snapshots already extracted in .scratch_mathlib_hist/.)
//
// Predictions (fixed in advance):
//   R1: INTERFACE cones have HIGHER median meanApFrac than CONTENT cones,
//       pooled and in >= 2/3 namespaces where both classes have n >= 3.
//   R2: Spearman(defFrac, meanApFrac) > 0 pooled.
//   R3 (role vs age disentangling): R1's direction holds WITHIN the OLD
//       subset and WITHIN the YOUNG subset separately — i.e. role predicts
//       flatness at fixed age. If instead age predicts flatness at fixed
//       role and role adds nothing, the life-cycle story wins and the
//       role story dies.
// Failure is reported as failure; no post-hoc re-thresholding of defFrac.

import { readdirSync, readFileSync, statSync, existsSync } from "node:fs";
import { join } from "node:path";

const NAMESPACES = ["Order", "Topology", "Algebra"];
const HEADBASE = "lean/.lake/packages/mathlib/Mathlib";
const OLDSNAPS = [".scratch_mathlib_hist/2023-09/Mathlib", ".scratch_mathlib_hist/2024-03/Mathlib"];
const MINCONE = 10, MAXCONE = 18, CAP = 80;

let rngState = 20260821;
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

// old-module name set (for age)
const oldMods = new Set();
for (const base of OLDSNAPS) {
  for (const ns of NAMESPACES) {
    const root = join(base, ns);
    if (!existsSync(root)) continue;
    for (const p of walkLean(root)) oldMods.add(modOf(p));
  }
}

const importRe = /^(?:(?:public|private|meta)\s+)*import\s+([\w.]+)/gm;
const declRe = /^\s*(?:@\[[^\]]*\]\s*)?(?:(?:private|protected|noncomputable|public|scoped|local|partial|unsafe)\s+)*(def|abbrev|structure|class|instance|inductive|theorem|lemma)\b/gm;

const spearman = (xs, ys) => {
  const rank = (a) => {
    const idx = [...a.keys()].sort((i, j) => a[i] - a[j]);
    const r = new Array(a.length);
    idx.forEach((i, k) => (r[i] = k));
    return r;
  };
  const rx = rank(xs), ry = rank(ys);
  const m = (rx.length - 1) / 2;
  let num = 0, dx = 0, dy = 0;
  for (let i = 0; i < rx.length; i++) {
    num += (rx[i] - m) * (ry[i] - m);
    dx += (rx[i] - m) ** 2; dy += (ry[i] - m) ** 2;
  }
  return num / Math.sqrt(dx * dy);
};
const median = (a) => {
  const s = [...a].sort((x, y) => x - y);
  return s.length % 2 ? s[(s.length - 1) / 2] : (s[s.length / 2 - 1] + s[s.length / 2]) / 2;
};

const analyzeCone = (cone, found) => {
  const cn = cone.length;
  const localIdx = new Map(cone.map((g, i) => [g, i]));
  const down = cone.map((g) => {
    let m = 0;
    for (const k of found[g]) if (localIdx.has(k)) m |= 1 << localIdx.get(k);
    return m;
  });
  const full = (1 << cn) - 1;
  let latent = 0;
  const fracs = [];
  for (let x = 0; x < cn; x++) {
    const B = down[x];
    let ap = 0;
    for (let S = 0; S <= full; S++) {
      const Bs = B & S;
      let notB = 0;
      for (let p = 0; p < cn; p++) if ((S & (1 << p)) && (down[p] & Bs) === 0) notB |= 1 << p;
      if (notB === 0) continue;
      let nnB = 0;
      for (let p = 0; p < cn; p++) if ((S & (1 << p)) && (down[p] & notB) === 0) nnB |= 1 << p;
      if (nnB !== Bs) ap++;
    }
    let notB = 0;
    for (let p = 0; p < cn; p++) if ((down[p] & B) === 0) notB |= 1 << p;
    let idOrd = false;
    if (notB !== 0) {
      let nnB = 0;
      for (let p = 0; p < cn; p++) if ((down[p] & notB) === 0) nnB |= 1 << p;
      idOrd = nnB !== B;
    }
    if (!idOrd && ap > 0) latent++;
    fracs.push(ap / (full + 1));
  }
  return { latentFrac: latent / cn, meanApFrac: fracs.reduce((a, b) => a + b, 0) / cn };
};

const declCache = new Map();
const declCounts = (path) => {
  if (!declCache.has(path)) {
    const src = readFileSync(path, "utf8");
    let d = 0, t = 0;
    for (const m of src.matchAll(declRe)) {
      if (m[1] === "theorem" || m[1] === "lemma") t++;
      else d++;
    }
    declCache.set(path, { d, t });
  }
  return declCache.get(path);
};

const rows = [];
for (const ns of NAMESPACES) {
  const files = walkLean(join(HEADBASE, ns));
  const mods = files.map(modOf);
  const midx = new Map(mods.map((m, i) => [m, i]));
  const n = mods.length;
  const edges = Array.from({ length: n }, () => []);
  files.forEach((p, i) => {
    const src = readFileSync(p, "utf8");
    for (const m of src.matchAll(importRe)) {
      const j = midx.get(m[1]);
      if (j !== undefined && j !== i) edges[i].push(j);
    }
  });
  // foundations
  const found = new Array(n);
  const state = new Uint8Array(n);
  const stack = [];
  for (let s = 0; s < n; s++) {
    if (state[s] === 2) continue;
    stack.push(s);
    while (stack.length) {
      const i = stack[stack.length - 1];
      if (state[i] === 2) { stack.pop(); continue; }
      if (state[i] === 0) { state[i] = 1; for (const j of edges[i]) if (state[j] !== 2) stack.push(j); continue; }
      const set = new Set([i]);
      for (const j of edges[i]) for (const k of found[j]) set.add(k);
      found[i] = set; state[i] = 2; stack.pop();
    }
  }
  // candidate cones, deduped by content
  const seen = new Set();
  let cands = [];
  for (let i = 0; i < n; i++) {
    const sz = found[i].size;
    if (sz < MINCONE || sz > MAXCONE) continue;
    const key = [...found[i]].sort((a, b) => a - b).join(",");
    if (seen.has(key)) continue;
    seen.add(key);
    cands.push(i);
  }
  if (cands.length > CAP) {
    // seeded sample without replacement
    const picked = [];
    const pool = [...cands];
    while (picked.length < CAP) picked.push(pool.splice(Math.floor(rand() * pool.length), 1)[0]);
    cands = picked;
  }
  console.log(`${ns}: ${cands.length} deduped cones in size band [${MINCONE},${MAXCONE}]`);
  for (const x of cands) {
    const cone = [...found[x]].sort((a, b) => a - b);
    const m = analyzeCone(cone, found);
    let d = 0, t = 0;
    for (const g of cone) { const c = declCounts(files[g]); d += c.d; t += c.t; }
    const defFrac = d + t === 0 ? 0.5 : d / (d + t);
    const nameInterface = mods[x].split(".").some((c) => ["Defs", "Notation", "Init"].includes(c));
    rows.push({
      ns, apex: mods[x],
      meanApFrac: m.meanApFrac, latentFrac: m.latentFrac,
      defFrac, roleInterface: defFrac >= 0.5, nameInterface,
      old: oldMods.has(mods[x]),
    });
  }
}

console.log(`\ntotal cones: ${rows.length}`);

// ---- R1: interface vs content medians ----
const report = (label, subset) => {
  const I = subset.filter((r) => r.roleInterface), C = subset.filter((r) => r.roleInterface === false);
  if (I.length < 3 || C.length < 3) {
    console.log(`  ${label}: insufficient (interface n=${I.length}, content n=${C.length})`);
    return null;
  }
  const mi = median(I.map((r) => r.meanApFrac)), mc = median(C.map((r) => r.meanApFrac));
  const li = median(I.map((r) => r.latentFrac)), lc = median(C.map((r) => r.latentFrac));
  const pass = mi > mc;
  console.log(
    `  ${label}: interface n=${I.length} medAp=${mi.toFixed(4)} medLat=${li.toFixed(3)}` +
    ` | content n=${C.length} medAp=${mc.toFixed(4)} medLat=${lc.toFixed(3)}` +
    `  -> interface ${pass ? "WIDER (as predicted)" : "not wider"}`
  );
  return pass;
};

console.log(`\nR1: interface (defFrac >= 0.5) vs content cones, meanApFrac medians`);
const pooledPass = report("pooled", rows);
let nsPass = 0, nsTotal = 0;
for (const ns of NAMESPACES) {
  const p = report(ns, rows.filter((r) => r.ns === ns));
  if (p !== null) { nsTotal++; if (p) nsPass++; }
}
console.log(`R1 verdict: pooled ${pooledPass ? "pass" : "FAIL"}, namespaces ${nsPass}/${nsTotal} (need >= 2/3)`);

console.log(`\nR2: Spearman(defFrac, meanApFrac) pooled = ${spearman(rows.map((r) => r.defFrac), rows.map((r) => r.meanApFrac)).toFixed(3)} (prediction: > 0)`);
console.log(`    Spearman(defFrac, latentFrac) pooled = ${spearman(rows.map((r) => r.defFrac), rows.map((r) => r.latentFrac)).toFixed(3)} (prediction: < 0)`);

console.log(`\nR3: role effect within age strata`);
report("OLD cones", rows.filter((r) => r.old));
report("YOUNG cones", rows.filter((r) => r.old === false));
console.log(`    age effect within role strata (control):`);
const ageReport = (label, subset) => {
  const O = subset.filter((r) => r.old), Y = subset.filter((r) => r.old === false);
  if (O.length < 3 || Y.length < 3) { console.log(`  ${label}: insufficient (old n=${O.length}, young n=${Y.length})`); return; }
  console.log(
    `  ${label}: old n=${O.length} medAp=${median(O.map((r) => r.meanApFrac)).toFixed(4)}` +
    ` | young n=${Y.length} medAp=${median(Y.map((r) => r.meanApFrac)).toFixed(4)}`
  );
};
ageReport("within INTERFACE", rows.filter((r) => r.roleInterface));
ageReport("within CONTENT", rows.filter((r) => r.roleInterface === false));

// name-based secondary
console.log(`\nsecondary (name-based interface = path component in {Defs, Notation, Init}):`);
const NI = rows.filter((r) => r.nameInterface), NC = rows.filter((r) => r.nameInterface === false);
if (NI.length >= 3) {
  console.log(
    `  name-interface n=${NI.length} medAp=${median(NI.map((r) => r.meanApFrac)).toFixed(4)}` +
    ` | rest n=${NC.length} medAp=${median(NC.map((r) => r.meanApFrac)).toFixed(4)}`
  );
} else console.log(`  insufficient name-interface cones (n=${NI.length})`);

// extremes for eyeballing
const sorted = [...rows].sort((a, b) => b.meanApFrac - a.meanApFrac);
console.log(`\nwidest 8 cones:`);
for (const r of sorted.slice(0, 8))
  console.log(`  ${r.apex}  ap=${r.meanApFrac.toFixed(3)} defFrac=${r.defFrac.toFixed(2)} ${r.old ? "old" : "young"}`);
console.log(`narrowest 8 cones:`);
for (const r of sorted.slice(-8))
  console.log(`  ${r.apex}  ap=${r.meanApFrac.toFixed(3)} defFrac=${r.defFrac.toFixed(2)} ${r.old ? "old" : "young"}`);
