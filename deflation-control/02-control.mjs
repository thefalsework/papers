// Deflation control — THE REGISTERED RUN: does E > R survive exact
// distance matching?
//
// PRE-REGISTRATION (header written before first run; committed with the
// blind pre-check 01, which touched only structural occupancy and
// distance distributions — no gain was computed anywhere).
//
// WHAT IS AT STAKE: E > R — Exploitation-cell members out-grow matched
// Refusal-cell members — is the program's only dynamical statement that
// has held on every corpus measured (Mathlib, AFP, Go, crates, Isabelle
// distribution). The skeptic's compression: "connected periphery grows,
// disconnected periphery doesn't" — E-members are by construction
// downward-connected to the kernel, R-members are not, and degree
// matching cannot dispose of that because degree is local and
// connectivity is global. The pre-check confirmed the confound is real
// (E masses at undirected distance 1-4; R spreads to 15+ with large
// unreachable populations) AND that the matched comparison exists on
// all five corpora (420 .. 110,174 matched cells).
//
// DESIGN: identical to the growth studies (mathlib-study/18 estimator)
// with ONE change — the stratum key gains EXACT undirected distance:
//   stratum = degree bin (0/1-2/3-7/8+) x exact first-seen checkpoint
//             x exact undirected BFS distance from the kernel's down-set
//             (unreachable = its own value "inf").
// Same baselines/horizons per corpus as the originals; all evaluable
// kernels (crates: 300-kernel seeded sample per baseline, as 04); only
// singleton components carry names; members absent at horizon excluded;
// gains = in-degree deltas; weight min(nA, nB); nulls = within-cell
// label permutation, 1000 draws, one seeded stream (mulberry32, seed
// 20260830223). Side cap 500 per (cell, side), seeded uniform — declared
// for ALL corpora here (memory), label-blind, unbiased, power-only.
//
// REGISTERED PREDICTIONS:
//   DC1 (primary, per corpus): G_ER > 0 at or above the 97.5th
//     percentile of its null — the cell effect survives at matched
//     connectivity. Five verdicts, no pooling. Uninformative floor:
//     < 30 matched cells (pre-check says this cannot bind).
//   DC2 (registered descriptive, scores nothing): G_ED under the same
//     distance-matched strata, per corpus — does the corpus-contingent
//     E-vs-D ordering change when connectivity is matched away?
//
// OPERATOR PRIOR, ON THE RECORD: leaning deflation — stated 2026-08-30
// in session ("I'd put real probability on the second outcome"). The
// registered-directional record stands at 1 for 13.
//
// INTERPRETATION TABLE (fixed in advance):
//   DC1 holds on all five -> E > R is not a connectivity artifact: at
//     identical degree, age, and graph distance, the algebraic cell
//     still predicts growth. The law survives its hardest control and
//     the briefs may say so.
//   DC1 null on some, no reversals -> partial deflation: the law is
//     real only where it separates from distance; scope it, demote
//     "universal" everywhere it appears.
//   DC1 reverses anywhere, or nulls on most -> deflation: E > R was
//     connectivity in costume. Report at full prominence, demote the
//     briefs' growth-engine language, and log it as the seventh
//     instrument-overrules-operator arc... in the operator's favor
//     this time would have been nicer.
//
// Writes deflation-control/results-control.json.

import { writeFileSync } from "node:fs";
import { BIN, CORPORA, firstSeenOf, makeGate, makeDistancer, CRATES_KERNELS } from "./lib.mjs";

const PERMS = 1000;
const SEED = 20260830223;
const SIDE_CAP = 500;
const MIN_CELLS = 30;

let rngState = SEED;
const rand = () => {
  rngState |= 0; rngState = (rngState + 0x6d2b79f5) | 0;
  let t = Math.imul(rngState ^ (rngState >>> 15), 1 | rngState);
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};
const capped = (arr) => {
  if (arr.length <= SIDE_CAP) return arr;
  for (let i = 0; i < SIDE_CAP; i++) {
    const j = i + Math.floor(rand() * (arr.length - i));
    const t = arr[i]; arr[i] = arr[j]; arr[j] = t;
  }
  return arr.slice(0, SIDE_CAP);
};

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
const scoreSet = (cells, label) => {
  if (cells.length < MIN_CELLS) {
    console.log(`  ${label}: UNINFORMATIVE (${cells.length} cells)`);
    return { cells: cells.length, uninformative: true };
  }
  const obs = statIdentity(cells);
  const nulls = [];
  for (let p = 0; p < PERMS; p++) nulls.push(statPermuted(cells));
  nulls.sort((a, b) => a - b);
  let below = 0;
  for (const v of nulls) if (v < obs) below++;
  const pct = (100 * below) / PERMS;
  const lo = nulls[Math.floor(0.025 * PERMS)], hi = nulls[Math.floor(0.975 * PERMS)];
  console.log(`  ${label}: cells=${cells.length} obs=${obs.toFixed(4)} null=[${lo.toFixed(4)},${hi.toFixed(4)}] pct=${pct.toFixed(1)}`);
  return { cells: cells.length, obs, lo, hi, pct };
};

const out = {};
for (const corpus of ["mathlib", "afp", "isabelle", "go", "crates"]) {
  const { subs, baselines, horizon } = CORPORA[corpus]();
  const cellsER = [], cellsED = [];
  let kernels = 0;
  for (const snaps of subs) {
    const fsMap = firstSeenOf(snaps);
    for (const ti of baselines) {
      const snap = snaps[ti];
      const fut = snaps[ti + horizon];
      const gate = makeGate(snap);
      const distancer = makeDistancer(snap);
      const { nComp, compMembers, names, inDeg } = snap;
      let order = Array.from({ length: nComp }, (_, i) => i);
      if (corpus === "crates") {
        for (let i = 0; i < nComp; i++) {
          const j = i + Math.floor(rand() * (nComp - i));
          const t = order[i]; order[i] = order[j]; order[j] = t;
        }
      }
      let used = 0;
      for (const a of order) {
        if (corpus === "crates" && used >= CRATES_KERNELS) break;
        const g = gate(a);
        if (!g) continue;
        used++; kernels++;
        const dOf = distancer(g.downMembers);
        const strata = new Map();
        for (let c = 0; c < nComp; c++) {
          const cell = g.cellOf(c);
          if (cell === "I") continue;
          const members = compMembers[c];
          if (members.length > 1) continue;
          const nm = names[members[0]];
          if (!fut.inDeg.has(nm)) continue;
          const d0 = inDeg.get(nm) ?? 0;
          const d = dOf(c);
          const key = `${BIN(d0)}|${fsMap.get(nm)}|${d === -1 ? "inf" : d}`;
          if (!strata.has(key)) strata.set(key, { E: [], D: [], R: [] });
          strata.get(key)[cell].push((fut.inDeg.get(nm) ?? 0) - d0);
        }
        for (const [, s] of strata) {
          if (s.E.length && s.R.length) {
            const E = capped(s.E), R = capped(s.R);
            cellsER.push({ gains: Float64Array.from([...E, ...R]), nA: E.length });
          }
          if (s.E.length && s.D.length) {
            const E = capped(s.E), D = capped(s.D);
            cellsED.push({ gains: Float64Array.from([...E, ...D]), nA: E.length });
          }
        }
      }
    }
  }
  console.log(`${corpus}: kernels=${kernels}`);
  const er = scoreSet(cellsER, "DC1 G_ER (distance-matched)");
  const ed = scoreSet(cellsED, "DC2 G_ED (distance-matched, descriptive)");
  const verdict = er.uninformative ? "UNINFORMATIVE"
    : er.obs > 0 && er.pct >= 97.5 ? "HOLDS"
    : er.obs < 0 && er.pct <= 2.5 ? "REVERSES" : "NULL";
  out[corpus] = { kernels, er, ed, "DC1": verdict };
  console.log(`  DC1: ${verdict}`);
}
writeFileSync("deflation-control/results-control.json", JSON.stringify(out, null, 1));
console.log(JSON.stringify(Object.fromEntries(Object.entries(out).map(([k, v]) => [k, v.DC1])), null, 1));
