// Forward-registration scorer (see REGISTER.md §3). Written and frozen
// 2026-08-27, before any horizon data exists. Do not edit at scoring time;
// deviations forced by data-format drift are logged as dated postscripts
// in REGISTER.md.
//
// Usage (run after 2028-07-01, with horizon snapshots extracted by the
// existing tooling at the horizon pins):
//   node predictions/02-score-2028.mjs \
//     --go software-study/history/go-2028.json \
//     --crates software-study/history/crates-2028.json \
//     --afp afp-study/history/2028.json \
//     --mathlib <path to horizon Mathlib dir (containing Order/ etc.)>
//
// Any subset may be supplied; missing corpora are skipped (scored later).
// Horizon in-degree conventions per corpus match the baseline extractors:
//   go/crates: software-study/01 history format ({nodes, edges:[[a,b]]},
//     in-degree by name over raw nodes);
//   afp: afp-study/04 format ({entries, edges:["A>B"]});
//   mathlib: per-namespace module graphs, dependents within the namespace
//     subgraph (mathlib-study/18 loader, reproduced here).
//
// Statistic and null (frozen): per (kernel x stratum) cell, drop members
// absent at horizon; if both sides nonempty, gains = horizonDeg - d0,
// weight = min(nE, nD); G_ED = sum w*(meanE - meanD) / sum w. Null:
// within-cell label permutation, 1000 draws, mulberry32 seed 20280701.
// Verdicts: P1 go / P2 crates / P3 mathlib: G_ED > 0 at >= 97.5th pct.
// P4 afp: G_ED < 0 at <= 2.5th pct. A corpus with < 30 scorable cells is
// UNINFORMATIVE, not failed.

import { readdirSync, readFileSync, statSync } from "node:fs";
import { join } from "node:path";

const PERMS = 1000;
const SEED = 20280701;
const MIN_CELLS = 30;

let rngState = SEED;
const rand = () => {
  rngState |= 0; rngState = (rngState + 0x6d2b79f5) | 0;
  let t = Math.imul(rngState ^ (rngState >>> 15), 1 | rngState);
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};

const args = {};
for (let i = 2; i < process.argv.length; i += 2)
  args[process.argv[i].replace(/^--/, "")] = process.argv[i + 1];

const frozen = JSON.parse(readFileSync("predictions/frozen-2026.json", "utf8"));

// ---- horizon in-degree extractors ----
const horizonDegSoftware = (path) => {
  const raw = JSON.parse(readFileSync(path, "utf8"));
  const inDeg = new Map(raw.nodes.map((nm) => [nm, 0]));
  for (const [a, b] of raw.edges)
    inDeg.set(raw.nodes[b], inDeg.get(raw.nodes[b]) + 1);
  return inDeg;
};
const horizonDegAfp = (path) => {
  const raw = JSON.parse(readFileSync(path, "utf8"));
  const inDeg = new Map(raw.entries.map((e) => [e, 0]));
  for (const s of raw.edges) {
    const [, b] = s.split(">");
    if (inDeg.has(b)) inDeg.set(b, inDeg.get(b) + 1);
  }
  return inDeg;
};
const horizonDegMathlib = (base) => {
  const importRe = /^(?:(?:public|private|meta)\s+)*import\s+([\w.]+)/gm;
  const inDeg = new Map();
  for (const ns of ["Order", "Topology", "Algebra"]) {
    const root = join(base, ns);
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
    const modOf = (p) =>
      "Mathlib." + p.replaceAll("\\", "/").split("Mathlib/").pop().replace(/\.lean$/, "").replaceAll("/", ".");
    const mods = files.map(modOf);
    const midx = new Map(mods.map((m, i) => [m, i]));
    for (const m of mods) inDeg.set(ns + "/" + m, 0);
    files.forEach((p, i) => {
      const src = readFileSync(p, "utf8");
      for (const m of src.matchAll(importRe)) {
        const j = midx.get(m[1]);
        if (j !== undefined && j !== i) {
          const key = ns + "/" + mods[j];
          inDeg.set(key, inDeg.get(key) + 1);
        }
      }
    });
  }
  return inDeg;
};

// ---- frozen statistic ----
const statIdentity = (cells) => {
  let num = 0, den = 0;
  for (const c of cells) {
    const m = c.gains.length, nA = c.nA, nB = m - nA;
    const wgt = Math.min(nA, nB);
    let sA = 0;
    for (let i = 0; i < nA; i++) sA += c.gains[i];
    let sT = sA;
    for (let i = nA; i < m; i++) sT += c.gains[i];
    num += wgt * (sA / nA - (sT - sA) / nB);
    den += wgt;
  }
  return num / den;
};
const statPermuted = (cells) => {
  let num = 0, den = 0;
  for (const c of cells) {
    const m = c.gains.length, nA = c.nA, nB = m - nA;
    const wgt = Math.min(nA, nB);
    const idx = c.scratch ?? (c.scratch = Uint32Array.from({ length: m }, (_, i) => i));
    for (let i = 0; i < nA; i++) {
      const j = i + Math.floor(rand() * (m - i));
      const t = idx[i]; idx[i] = idx[j]; idx[j] = t;
    }
    let sA = 0;
    for (let i = 0; i < nA; i++) sA += c.gains[idx[i]];
    let sT = 0;
    for (let i = 0; i < m; i++) sT += c.gains[i];
    num += wgt * (sA / nA - (sT - sA) / nB);
    den += wgt;
  }
  return num / den;
};

const score = (corpus, horizonDeg, direction) => {
  const fz = frozen[corpus];
  const cells = [];
  for (const cell of fz.cells) {
    const alive = (names) => names.filter((nm) => horizonDeg.has(nm));
    const E = alive(cell.E), D = alive(cell.D);
    if (!E.length || !D.length) continue;
    const gains = Float64Array.from(
      [...E, ...D].map((nm) => horizonDeg.get(nm) - fz.deg[nm]),
    );
    cells.push({ gains, nA: E.length });
  }
  if (cells.length < MIN_CELLS) {
    console.log(`${corpus}: UNINFORMATIVE (${cells.length} scorable cells < ${MIN_CELLS})`);
    return;
  }
  const obs = statIdentity(cells);
  const nulls = [];
  for (let p = 0; p < PERMS; p++) nulls.push(statPermuted(cells));
  nulls.sort((a, b) => a - b);
  let below = 0;
  for (const v of nulls) if (v < obs) below++;
  const pct = (100 * below) / PERMS;
  const pass = direction > 0 ? obs > 0 && pct >= 97.5 : obs < 0 && pct <= 2.5;
  console.log(
    `${corpus}: cells=${cells.length} G_ED=${obs.toFixed(4)} pct=${pct.toFixed(1)} ` +
    `prediction(${direction > 0 ? "E grows" : "reversal persists"}): ${pass ? "HOLDS" : "FAILS"}`,
  );
};

if (args.go) score("go", horizonDegSoftware(args.go), +1);
if (args.crates) score("crates", horizonDegSoftware(args.crates), +1);
if (args.mathlib) score("mathlib", horizonDegMathlib(args.mathlib), +1);
if (args.afp) score("afp", horizonDegAfp(args.afp), -1);
if (!args.go && !args.crates && !args.mathlib && !args.afp)
  console.log("no horizon inputs supplied; see usage in header");
