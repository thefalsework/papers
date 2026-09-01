// Battery v2 — BLIND PRE-CHECK (structure only; no gain is computed
// anywhere in this file).
//
// WHY THIS FOLDER EXISTS: the accretion study's flux law (THEORY.md,
// 2026-09-01) proved that under cone-local growth, expected gain tracks
// a node's truncated UP-SET SIZE (transitive dependents) — a quantity
// carried by NO feature in the standard battery (log-in/out-degree,
// age, exact distance, PageRank, k-core). PC(0) demonstrates a cell
// can beat that battery at |t| > 10 purely through up-set flux. So
// up-set size is the sharpest cheap knife not yet run at the program's
// surviving field claim (E > R at matched battery, Go + Debian). This
// study adds it to the battery and re-runs both corpora.
//
// THE NEW FEATURE, fixed here before anything runs:
//   f6 = log1p(|upset_200(x)|), where upset_200 is truncated BFS over
//   the dependents direction (cOut) from x, excluding x, capped at 200
//   nodes — the same truncation constant as the accretion cones.
//   z-scored per snapshot over the candidate rows, like f0-f2, f4-f5.
//
// WHAT THIS PRE-CHECK REPORTS (all structural, outcome-blind):
//   1. Up-set-size imbalance inside the OLD five-feature pairs: rebuild
//      the exact pairs the gauntlet/Debian-bet designs matched (same
//      seeds, same order of rand() consumption as a 5-feature match),
//      and measure the SMD of f6 across those pairs. If ~0, the old
//      results already had it balanced and v2 will change little; if
//      large, v2 is a real test.
//   2. Feasibility and balance of the SIX-feature match at caliper 0.5:
//      pair counts and post-match max |SMD| over all six features, per
//      corpus per contrast. Constants for the registered run are fixed
//      from this.
//
// Corpora and constants identical to the runs being audited:
//   go     — deflation-control CORPORA.go, all evaluable kernels,
//            gauntlet constants (SIDE_CAP 300, caliper 0.5).
//   debian — debian-study/history/{2007..2025}.json, baselines 0..7,
//            horizon +2, KERNEL_CAP 300, SIDE_CAP 300, caliper 0.5.
//
// Seed: 20260901101 (fresh; the registered run will use its own).

import { readFileSync, writeFileSync } from "node:fs";
import { CORPORA, buildSnap, firstSeenOf, makeGate, makeDistancer } from "../deflation-control/lib.mjs";
import { pagerank, coreNumbers, zStats, greedyMatch } from "../baseline-gauntlet/gauntlet-lib.mjs";

const CALIPER = 0.5, SIDE_CAP = 300, MIN_PAIRS = 50;
const SEED = 20260901101;
let rngState = SEED;
const rand = () => {
  rngState |= 0; rngState = (rngState + 0x6d2b79f5) | 0;
  let t = Math.imul(rngState ^ (rngState >>> 15), 1 | rngState);
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};

import { upsetSizes } from "./lib.mjs";

const loadDebian = () => {
  const YEARS = [2007, 2009, 2011, 2013, 2015, 2017, 2019, 2021, 2023, 2025];
  const snaps = YEARS.map((y) => {
    const raw = JSON.parse(readFileSync(`debian-study/history/${y}.json`, "utf8"));
    return buildSnap(raw.nodes, raw.edges);
  });
  return { snaps, baselines: [0, 1, 2, 3, 4, 5, 6, 7], horizon: 2, kernelCap: 300 };
};
const loadGo = () => {
  const { subs, baselines, horizon } = CORPORA.go();
  return { snaps: subs[0], baselines, horizon, kernelCap: Infinity };
};

// nFeats = 5 reproduces the old battery match; 6 adds f6 to the caliper.
// Returns per-contrast: pairs, SMDs over all SIX features (for the
// 5-feature run, f6's SMD is measured but did not constrain the match).
const runMatch = (loader, nFeats) => {
  const { snaps, baselines, horizon, kernelCap } = loader();
  const fsMap = firstSeenOf(snaps);
  const acc = { ER: { n: 0, sumE: Array(6).fill(0), sumB: Array(6).fill(0) },
                ED: { n: 0, sumE: Array(6).fill(0), sumB: Array(6).fill(0) } };
  let kernels = 0;
  for (const ti of baselines) {
    const snap = snaps[ti];
    const fut = snaps[ti + horizon];
    const gate = makeGate(snap);
    const distancer = makeDistancer(snap);
    const { nComp, compMembers, names, inDeg } = snap;
    const pr = pagerank(snap);
    const core = coreNumbers(snap);
    const upset = upsetSizes(snap);
    const globalRows = [];
    for (let c = 0; c < nComp; c++) {
      if (compMembers[c].length > 1) continue;
      if (!fut.inDeg.has(names[compMembers[c][0]])) continue;
      globalRows.push(c);
    }
    const gIn = zStats(globalRows.map((c) => Math.log1p(inDeg.get(names[compMembers[c][0]]) ?? 0)));
    const gOut = zStats(globalRows.map((c) => Math.log1p(snap.cIn[c].length)));
    const gAge = zStats(globalRows.map((c) => fsMap.get(names[compMembers[c][0]])));
    const gPR = zStats(globalRows.map((c) => Math.log(pr[c])));
    const gCore = zStats(globalRows.map((c) => core[c]));
    const gUp = zStats(globalRows.map((c) => Math.log1p(upset[c])));
    const featOf = (c) => {
      const nm = names[compMembers[c][0]];
      return [
        (Math.log1p(inDeg.get(nm) ?? 0) - gIn.mu) / gIn.sd,
        (Math.log1p(snap.cIn[c].length) - gOut.mu) / gOut.sd,
        (fsMap.get(nm) - gAge.mu) / gAge.sd,
        (Math.log(pr[c]) - gPR.mu) / gPR.sd,
        (core[c] - gCore.mu) / gCore.sd,
        (Math.log1p(upset[c]) - gUp.mu) / gUp.sd,
      ];
    };
    const order = Array.from({ length: nComp }, (_, i) => i);
    for (let i = 0; i < nComp; i++) {
      const j = i + Math.floor(rand() * (nComp - i));
      const t = order[i]; order[i] = order[j]; order[j] = t;
    }
    let used = 0;
    for (const a of order) {
      if (used >= kernelCap) break;
      const g = gate(a);
      if (!g) continue;
      used++; kernels++;
      const dOf = distancer(g.downMembers);
      const groups = { E: new Map(), D: new Map(), R: new Map() };
      for (const c of globalRows) {
        const cell = g.cellOf(c);
        if (cell === "I") continue;
        const d = dOf(c);
        if (!groups[cell].has(d)) groups[cell].set(d, []);
        groups[cell].get(d).push(c);
      }
      const cap = (arr) => {
        if (arr.length <= SIDE_CAP) return arr;
        for (let i = 0; i < SIDE_CAP; i++) {
          const j = i + Math.floor(rand() * (arr.length - i));
          const t = arr[i]; arr[i] = arr[j]; arr[j] = t;
        }
        return arr.slice(0, SIDE_CAP);
      };
      for (const [contrast, bSide] of [["ER", "R"], ["ED", "D"]]) {
        for (const [d, eMembers] of groups.E) {
          const bMembers = groups[bSide].get(d);
          if (!bMembers) continue;
          const eCap = cap([...eMembers]), bCap = cap([...bMembers]);
          const fE = eCap.map(featOf), fB = bCap.map(featOf);
          const pairs = greedyMatch(fE.map((f) => f.slice(0, nFeats)), fB.map((f) => f.slice(0, nFeats)), CALIPER, rand);
          const a2 = acc[contrast];
          for (const [ei, bi] of pairs) {
            a2.n++;
            for (let k = 0; k < 6; k++) { a2.sumE[k] += fE[ei][k]; a2.sumB[k] += fB[bi][k]; }
          }
        }
      }
    }
  }
  const report = { kernels };
  for (const contrast of ["ER", "ED"]) {
    const { n, sumE, sumB } = acc[contrast];
    const smd = Array.from({ length: 6 }, (_, k) => (n ? +(Math.abs(sumE[k] - sumB[k]) / n).toFixed(4) : null));
    report[contrast] = { pairs: n, smd, maxSmd5: n ? Math.max(...smd.slice(0, 5)) : null, smdUpset: smd[5], feasible: n >= MIN_PAIRS };
  }
  return report;
};

const FEAT_NAMES = ["logIn", "logOut", "age", "logPR", "core", "logUpset"];
const out = { featNames: FEAT_NAMES };
for (const [corpus, loader] of [["go", loadGo], ["debian", loadDebian]]) {
  for (const nFeats of [5, 6]) {
    const label = `${corpus}-${nFeats}f`;
    const r = runMatch(loader, nFeats);
    out[label] = r;
    console.log(`${label}: kernels=${r.kernels}`);
    for (const c of ["ER", "ED"]) {
      console.log(`  ${c}: pairs=${r[c].pairs} maxSMD(f0-f4)=${r[c].maxSmd5} SMD(upset)=${r[c].smdUpset}`);
    }
  }
}
writeFileSync("battery-v2/precheck.json", JSON.stringify(out, null, 1));
console.log("wrote battery-v2/precheck.json");
