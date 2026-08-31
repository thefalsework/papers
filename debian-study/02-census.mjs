// Debian study, blind structural census.
//
// BLINDNESS DISCIPLINE: reports graph dimensions, cycle structure,
// evaluable-kernel rates, member survival at the +2 horizon, and the
// gauntlet-design pair feasibility + covariate balance (calipers
// 0.25/0.5/1.0). Horizon snapshots are touched only for existence
// (survival filter). No gain is computed anywhere. The caliper for the
// registered bet (03) will be fixed from this output.
//
// Design constants mirrored from baseline-gauntlet: 300 seeded kernels
// per baseline (Debian condensations are 17k-69k components — the
// crates regime), side cap 300 per (kernel, cell, distance group).
//
// Writes debian-study/results-census.json.

import { readFileSync, writeFileSync } from "node:fs";
import { buildSnap, makeGate, makeDistancer, firstSeenOf } from "../deflation-control/lib.mjs";
import { pagerank, coreNumbers, zStats, greedyMatch } from "../baseline-gauntlet/gauntlet-lib.mjs";

const YEARS = [2007, 2009, 2011, 2013, 2015, 2017, 2019, 2021, 2023, 2025];
const BASELINES = [0, 1, 2, 3, 4, 5, 6, 7];
const HORIZON = 2;
const KERNEL_CAP = 300;
const SIDE_CAP = 300;
const CALIPERS = [0.25, 0.5, 1.0];
const FEATS = ["logIn", "logOut", "age", "logPR", "core"];

const SEED = 20260831031;
let rngState = SEED;
const rand = () => {
  rngState |= 0; rngState = (rngState + 0x6d2b79f5) | 0;
  let t = Math.imul(rngState ^ (rngState >>> 15), 1 | rngState);
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};

const snaps = YEARS.map((y) => {
  const raw = JSON.parse(readFileSync(`debian-study/history/${y}.json`, "utf8"));
  return buildSnap(raw.nodes, raw.edges);
});
const fsMap = firstSeenOf(snaps);

// per-snapshot structure
const structure = snaps.map((s, i) => {
  let nontrivial = 0, largest = 0;
  for (const m of s.compMembers) {
    if (m.length > 1) { nontrivial++; if (m.length > largest) largest = m.length; }
  }
  const surv = i + HORIZON < snaps.length
    ? s.names.filter((nm) => snaps[i + HORIZON].inDeg.has(nm)).length / s.names.length
    : null;
  return {
    year: YEARS[i], nodes: s.n, comps: s.nComp,
    nontrivialSccs: nontrivial, largestScc: largest,
    survivalAtHorizon: surv === null ? null : +surv.toFixed(4),
  };
});
console.log(JSON.stringify(structure, null, 1));

// gauntlet feasibility + balance, blind
const acc = {};
for (const cal of CALIPERS) {
  acc[cal] = {
    ER: { pairs: 0, sumE: FEATS.map(() => 0), sumB: FEATS.map(() => 0) },
    ED: { pairs: 0, sumE: FEATS.map(() => 0), sumB: FEATS.map(() => 0) },
  };
}
let kernelsEval = 0, kernelsTried = 0, candE = 0, candR = 0, candD = 0;
for (const ti of BASELINES) {
  const snap = snaps[ti];
  const fut = snaps[ti + HORIZON];
  const gate = makeGate(snap);
  const distancer = makeDistancer(snap);
  const { nComp, compMembers, names, inDeg } = snap;
  const pr = pagerank(snap);
  const core = coreNumbers(snap);
  const globalRows = [];
  for (let c = 0; c < nComp; c++) {
    const members = compMembers[c];
    if (members.length > 1) continue;
    if (!fut.inDeg.has(names[members[0]])) continue;
    globalRows.push(c);
  }
  const gIn = zStats(globalRows.map((c) => Math.log1p(inDeg.get(names[compMembers[c][0]]) ?? 0)));
  const gOut = zStats(globalRows.map((c) => Math.log1p(snap.cIn[c].length)));
  const gAge = zStats(globalRows.map((c) => fsMap.get(names[compMembers[c][0]])));
  const gPR = zStats(globalRows.map((c) => Math.log(pr[c])));
  const gCore = zStats(globalRows.map((c) => core[c]));
  const order = Array.from({ length: nComp }, (_, i) => i);
  for (let i = 0; i < nComp; i++) {
    const j = i + Math.floor(rand() * (nComp - i));
    const t = order[i]; order[i] = order[j]; order[j] = t;
  }
  let used = 0;
  for (const a of order) {
    if (used >= KERNEL_CAP) break;
    kernelsTried++;
    const g = gate(a);
    if (!g) continue;
    used++; kernelsEval++;
    const dOf = distancer(g.downMembers);
    const groups = { E: new Map(), D: new Map(), R: new Map() };
    for (const c of globalRows) {
      const cell = g.cellOf(c);
      if (cell === "I") continue;
      const d = dOf(c);
      if (!groups[cell].has(d)) groups[cell].set(d, []);
      groups[cell].get(d).push(c);
    }
    candE += [...groups.E.values()].reduce((s, v) => s + v.length, 0);
    candR += [...groups.R.values()].reduce((s, v) => s + v.length, 0);
    candD += [...groups.D.values()].reduce((s, v) => s + v.length, 0);
    const featOf = (c) => {
      const nm = names[compMembers[c][0]];
      return [
        (Math.log1p(inDeg.get(nm) ?? 0) - gIn.mu) / gIn.sd,
        (Math.log1p(snap.cIn[c].length) - gOut.mu) / gOut.sd,
        (fsMap.get(nm) - gAge.mu) / gAge.sd,
        (Math.log(pr[c]) - gPR.mu) / gPR.sd,
        (core[c] - gCore.mu) / gCore.sd,
      ];
    };
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
        const fE = cap([...eMembers]).map(featOf);
        const fB = cap([...bMembers]).map(featOf);
        for (const cal of CALIPERS) {
          const pairs = greedyMatch(fE, fB, cal, rand);
          const a2 = acc[cal][contrast];
          a2.pairs += pairs.length;
          for (const [ei, bi] of pairs) {
            for (let k = 0; k < FEATS.length; k++) {
              a2.sumE[k] += fE[ei][k];
              a2.sumB[k] += fB[bi][k];
            }
          }
        }
      }
    }
  }
}
const feasibility = { kernelsEval, kernelsTried, candE, candR, candD, calipers: {} };
for (const cal of CALIPERS) {
  feasibility.calipers[cal] = {};
  for (const contrast of ["ER", "ED"]) {
    const a2 = acc[cal][contrast];
    const smd = FEATS.map((f, k) => (a2.pairs ? +(Math.abs(a2.sumE[k] - a2.sumB[k]) / a2.pairs).toFixed(4) : null));
    feasibility.calipers[cal][contrast] = {
      pairs: a2.pairs,
      smd: Object.fromEntries(FEATS.map((f, k) => [f, smd[k]])),
      maxSmd: a2.pairs ? Math.max(...smd) : null,
    };
    console.log(`caliper ${cal} ${contrast}: pairs=${a2.pairs} maxSMD=${feasibility.calipers[cal][contrast].maxSmd}`);
  }
}
console.log(`kernels evaluable: ${kernelsEval} (tried ${kernelsTried}); candidates E=${candE} R=${candR} D=${candD}`);
writeFileSync("debian-study/results-census.json", JSON.stringify({ structure, feasibility }, null, 1));
console.log("wrote debian-study/results-census.json");
