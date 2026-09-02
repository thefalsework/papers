// Battery v5 — BLIND PRE-CHECK (structure only; no future gain computed).
//
// THE CONFOUND (the one a Debian person raises immediately): the
// Exploitation cell might simply be the library/devel sections of the
// archive in costume — functional role, not cell membership, and
// libraries grow dependents because that is what libraries are FOR.
// No battery generation has ever seen functional role: it is
// institutional metadata, not graph structure.
//
// THE CONTROL, fixed here before anything runs: EXACT STRATIFICATION.
// Rather than a ninth z-feature, a pair must now agree on kernel,
// exact undirected distance, AND archive Section (the archive's own
// role taxonomy: libs, libdevel, devel, python, perl, utils, admin,
// ...; "main/"-style prefixes stripped; missing -> "unknown"; see
// debian-study/04-sections.mjs for the fixed parsing choices). Caliper
// matching on the full v4 eight-feature battery proceeds inside each
// (distance, section) stratum. A surviving effect is then a claim
// about same-role twins: a libs package vs a libs package, at matched
// everything.
//
// WHAT THIS PRE-CHECK REPORTS (outcome-blind):
//   1. Inside the v4 pairs (recreated, structure only): how often a
//      pair already agrees on section, and the E-vs-R section
//      composition gap (share of libs+libdevel+devel, the "library
//      story" mass) — the imbalance the old battery never saw.
//   2. Feasibility/balance of the section-stratified 8-feature match:
//      pair count and max |SMD| at caliper 0.5.
//
// Corpus: Debian, baselines 1..7 (v4 design). Seed: 20260901501.

import { readFileSync, writeFileSync } from "node:fs";
import { buildSnap, firstSeenOf, makeGate, makeDistancer } from "../deflation-control/lib.mjs";
import { pagerank, coreNumbers, zStats, greedyMatch } from "../baseline-gauntlet/gauntlet-lib.mjs";
import { upsetSizes } from "../battery-v2/lib.mjs";
import { oracleMass } from "../battery-v3/lib.mjs";

const CALIPER = 0.5, SIDE_CAP = 300, MIN_PAIRS = 50, KERNEL_CAP = 300;
const HORIZON = 2, BASELINES = [1, 2, 3, 4, 5, 6, 7];
const SEED = 20260901501;
let rngState = SEED;
const rand = () => {
  rngState |= 0; rngState = (rngState + 0x6d2b79f5) | 0;
  let t = Math.imul(rngState ^ (rngState >>> 15), 1 | rngState);
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};

const YEARS = [2007, 2009, 2011, 2013, 2015, 2017, 2019, 2021, 2023, 2025];
const snaps = YEARS.map((y) => {
  const raw = JSON.parse(readFileSync(`debian-study/history/${y}.json`, "utf8"));
  return buildSnap(raw.nodes, raw.edges);
});
const sections = YEARS.map((y) =>
  JSON.parse(readFileSync(`debian-study/history/sections-${y}.json`, "utf8")));
const fsMap = firstSeenOf(snaps);
const LIB_SECTIONS = new Set(["libs", "libdevel", "devel"]);

// stratify: false = v4 replica (distance only), true = distance x section
const runMatch = (stratifySection) => {
  const acc = { ER: { n: 0, agree: 0, libE: 0, libB: 0, sumE: Array(8).fill(0), sumB: Array(8).fill(0) },
                ED: { n: 0, agree: 0, libE: 0, libB: 0, sumE: Array(8).fill(0), sumB: Array(8).fill(0) } };
  let kernels = 0;
  for (const ti of BASELINES) {
    const snap = snaps[ti];
    const prev = snaps[ti - 1];
    const fut = snaps[ti + HORIZON];
    const secMap = sections[ti];
    const gate = makeGate(snap);
    const distancer = makeDistancer(snap);
    const { nComp, compMembers, names, inDeg } = snap;
    const pr = pagerank(snap);
    const core = coreNumbers(snap);
    const upset = upsetSizes(snap);
    const orc = oracleMass(snap);
    const globalRows = [];
    for (let c = 0; c < nComp; c++) {
      if (compMembers[c].length > 1) continue;
      if (!fut.inDeg.has(names[compMembers[c][0]])) continue;
      globalRows.push(c);
    }
    const secOf = (c) => secMap[names[compMembers[c][0]]] ?? "unknown";
    const momOf = (c) => {
      const nm = names[compMembers[c][0]];
      const g = (inDeg.get(nm) ?? 0) - (prev.inDeg.get(nm) ?? 0);
      return Math.sign(g) * Math.log1p(Math.abs(g));
    };
    const gIn = zStats(globalRows.map((c) => Math.log1p(inDeg.get(names[compMembers[c][0]]) ?? 0)));
    const gOut = zStats(globalRows.map((c) => Math.log1p(snap.cIn[c].length)));
    const gAge = zStats(globalRows.map((c) => fsMap.get(names[compMembers[c][0]])));
    const gPR = zStats(globalRows.map((c) => Math.log(pr[c])));
    const gCore = zStats(globalRows.map((c) => core[c]));
    const gUp = zStats(globalRows.map((c) => Math.log1p(upset[c])));
    const gOr = zStats(globalRows.map((c) => Math.log1p(orc[c])));
    const gMo = zStats(globalRows.map(momOf));
    const featOf = (c) => {
      const nm = names[compMembers[c][0]];
      return [
        (Math.log1p(inDeg.get(nm) ?? 0) - gIn.mu) / gIn.sd,
        (Math.log1p(snap.cIn[c].length) - gOut.mu) / gOut.sd,
        (fsMap.get(nm) - gAge.mu) / gAge.sd,
        (Math.log(pr[c]) - gPR.mu) / gPR.sd,
        (core[c] - gCore.mu) / gCore.sd,
        (Math.log1p(upset[c]) - gUp.mu) / gUp.sd,
        (Math.log1p(orc[c]) - gOr.mu) / gOr.sd,
        (momOf(c) - gMo.mu) / gMo.sd,
      ];
    };
    const order = Array.from({ length: nComp }, (_, i) => i);
    for (let i = 0; i < nComp; i++) {
      const j = i + Math.floor(rand() * (nComp - i));
      const t = order[i]; order[i] = order[j]; order[j] = t;
    }
    let used = 0;
    for (const a of order) {
      if (used >= KERNEL_CAP) break;
      const g = gate(a);
      if (!g) continue;
      used++; kernels++;
      const dOf = distancer(g.downMembers);
      const groups = { E: new Map(), D: new Map(), R: new Map() };
      for (const c of globalRows) {
        const cell = g.cellOf(c);
        if (cell === "I") continue;
        const key = stratifySection ? `${dOf(c)}|${secOf(c)}` : `${dOf(c)}`;
        if (!groups[cell].has(key)) groups[cell].set(key, []);
        groups[cell].get(key).push(c);
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
        for (const [key, eMembers] of groups.E) {
          const bMembers = groups[bSide].get(key);
          if (!bMembers) continue;
          const eCap = cap([...eMembers]), bCap = cap([...bMembers]);
          const fE = eCap.map(featOf), fB = bCap.map(featOf);
          const pairs = greedyMatch(fE, fB, CALIPER, rand);
          const a2 = acc[contrast];
          for (const [ei, bi] of pairs) {
            a2.n++;
            if (secOf(eCap[ei]) === secOf(bCap[bi])) a2.agree++;
            if (LIB_SECTIONS.has(secOf(eCap[ei]))) a2.libE++;
            if (LIB_SECTIONS.has(secOf(bCap[bi]))) a2.libB++;
            for (let k = 0; k < 8; k++) { a2.sumE[k] += fE[ei][k]; a2.sumB[k] += fB[bi][k]; }
          }
        }
      }
    }
  }
  const report = { kernels };
  for (const contrast of ["ER", "ED"]) {
    const { n, agree, libE, libB, sumE, sumB } = acc[contrast];
    const signed = Array.from({ length: 8 }, (_, k) => (n ? +((sumE[k] - sumB[k]) / n).toFixed(4) : null));
    report[contrast] = { pairs: n,
                         sectionAgreeRate: n ? +(agree / n).toFixed(4) : null,
                         libShareE: n ? +(libE / n).toFixed(4) : null,
                         libShareB: n ? +(libB / n).toFixed(4) : null,
                         maxSmdMatched: n ? Math.max(...signed.map(Math.abs)) : null,
                         feasible: n >= MIN_PAIRS };
  }
  return report;
};

const out = {};
for (const stratify of [false, true]) {
  const label = stratify ? "debian-8f-sectionStratified" : "debian-8f-v4replica";
  const r = runMatch(stratify);
  out[label] = r;
  console.log(`${label}: kernels=${r.kernels}`);
  for (const c of ["ER", "ED"]) {
    console.log(`  ${c}: pairs=${r[c].pairs} agree=${r[c].sectionAgreeRate} libShare E=${r[c].libShareE} vs B=${r[c].libShareB} maxSMD=${r[c].maxSmdMatched}`);
  }
}
writeFileSync("battery-v5/precheck.json", JSON.stringify(out, null, 1));
console.log("wrote battery-v5/precheck.json");
