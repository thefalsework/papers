// AFP referendum, phase 0b: blind resolution pre-check for the
// topic-sharing measure and the three strata.
//
// BLINDNESS DISCIPLINE: pair-level topic statistics and per-stratum gate
// COUNTS only. No cell's topic alignment is computed; no aperture.
//
// The registered study (03) will use, at the ENTRY grain (1,014 entries,
// condensation of the one 4-cycle, per census 01):
//   sameArea(y, x) = entries y and x share >= 1 full topic path
//   strata        = top-level of first topic: Logic / Mathematics /
//                   Computer science (Tools excluded, n = 24)
// This script verifies the measure has dynamic range (lesson of
// mathlib-study v1: a measure pinned at 0 or 1 makes the null immovable)
// and that each stratum's subgraph has an evaluable population.
//
// Writes afp-study/results-referendum-precheck.json.

import { readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { join, basename } from "node:path";

const ROOT = ".scratch_afp/thys";
const META = ".scratch_afp/metadata/entries";

const entries = readdirSync(ROOT).filter((d) => statSync(join(ROOT, d)).isDirectory()).sort();

// topics per entry
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

// entry-level import edges (same resolution as census 01)
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
  let out = "", depth = 0;
  for (let i = 0; i < s.length; i++) {
    if (s[i] === "(" && s[i + 1] === "*") { depth++; i++; continue; }
    if (s[i] === "*" && s[i + 1] === ")" && depth > 0) { depth--; i++; continue; }
    if (depth === 0) out += s[i];
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

// bitset + gate machinery (verbatim census 01 / mathlib-study)
const bsNew = (w) => new Uint32Array(w);
const bsSet = (b, i) => { b[i >> 5] |= 1 << (i & 31); };
const bsOrInto = (d, s) => { for (let k = 0; k < d.length; k++) d[k] |= s[k]; };
const bsIntersects = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] & b[k]) return true; return false; };
const bsSubset = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] & ~b[k]) return false; return true; };
const bsEq = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] !== b[k]) return false; return true; };
const bsAny = (a) => { for (let k = 0; k < a.length; k++) if (a[k]) return true; return false; };

const analyze = (members) => {
  // condense cycles among members first (census found one 4-knot globally)
  const idx = new Map(members.map((e, i) => [e, i]));
  const n = members.length;
  const adjIn = Array.from({ length: n }, () => new Set());
  for (const pair of crossEntryPairs) {
    const [a, b] = pair.split(">");
    if (idx.has(a) && idx.has(b)) adjIn[idx.get(a)].add(idx.get(b));
  }
  // iterative cycle-tolerant closure: repeat until fixpoint (small graphs)
  const w = (n + 31) >> 5;
  const down = Array.from({ length: n }, (_, i) => { const b = bsNew(w); bsSet(b, i); return b; });
  let changed = true;
  while (changed) {
    changed = false;
    for (let i = 0; i < n; i++)
      for (const j of adjIn[i]) {
      for (let k = 0; k < w; k++) {
        // >>> 0: | yields a SIGNED int32, Uint32Array reads are unsigned;
        // without the coercion the comparison never stabilizes once bit 31
        // is set and the fixpoint loop spins forever.
        const nv = (down[i][k] | down[j][k]) >>> 0;
        if (nv !== down[i][k]) { down[i][k] = nv; changed = true; }
      }
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
  // pair-level topic-sharing fraction
  let pairs = 0, sharing = 0;
  for (let i = 0; i < n; i++) {
    const ti = topicsOf.get(members[i]);
    if (!ti) continue;
    for (let j = 0; j < n; j++) {
      if (i === j) continue;
      const tj = topicsOf.get(members[j]);
      if (!tj) continue;
      pairs++;
      if (ti.some((t) => tj.includes(t))) sharing++;
    }
  }
  return { n, edges: [...crossEntryPairs].filter((p) => { const [a, b] = p.split(">"); return idx.has(a) && idx.has(b); }).length, ordinary, evaluable, shareFrac: pairs ? sharing / pairs : null };
};

const topOf = (e) => topicsOf.get(e)?.[0]?.split("/")[0] ?? null;
const strata = {
  ALL: entries.filter((e) => topicsOf.has(e)),
  Logic: entries.filter((e) => topOf(e) === "Logic"),
  Mathematics: entries.filter((e) => topOf(e) === "Mathematics"),
  ComputerScience: entries.filter((e) => topOf(e) === "Computer science"),
};

const out = {};
for (const [name, members] of Object.entries(strata)) {
  out[name] = analyze(members);
  const r = out[name];
  console.log(
    `${name.padEnd(16)} n=${String(r.n).padStart(4)} edges=${String(r.edges).padStart(4)} ` +
    `ordinary=${String(r.ordinary).padStart(3)} evaluable=${String(r.evaluable).padStart(3)} ` +
    `topic-share frac=${r.shareFrac?.toFixed(4)}`
  );
}
writeFileSync("afp-study/results-referendum-precheck.json", JSON.stringify(out, null, 1));
console.log("\nwritten: afp-study/results-referendum-precheck.json (counts and pair-level stats only)");
