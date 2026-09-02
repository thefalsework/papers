// Battery v3 — BLIND PRE-CHECK (structure only; no gain computed).
//
// Question on deck: does the field's surviving claim survive the
// harmonic cone-mass feature (battery-v3/lib.mjs) — the functional
// that COMPLETELY explains the strongest synthetic counterexample?
//
// This pre-check reports, outcome-blind:
//   1. ORACLE imbalance inside the v2 pairs (seven-feature SMD audit
//      of six-feature matches): was the feature battery-v2 just
//      certified on secretly unbalanced on cone mass? (The Go-ER
//      lesson: this is where artifacts hide.)
//   2. Feasibility/balance of the SEVEN-feature match at caliper 0.5:
//      pair counts and post-match max |SMD| per corpus per contrast.
//
// Corpora and constants identical to battery-v2: Go (all evaluable
// kernels) and Debian (300 seeded kernels/baseline), horizon +2,
// SIDE_CAP 300, caliper 0.5. Contrasts: ER and ED both, both corpora
// (Go-ER expected infeasible as in v2; measured anyway, blind).
// Seed: 20260901201.

import { readFileSync, writeFileSync } from "node:fs";
import { CORPORA, buildSnap, firstSeenOf, makeGate, makeDistancer } from "../deflation-control/lib.mjs";
import { pagerank, coreNumbers, zStats, greedyMatch } from "../baseline-gauntlet/gauntlet-lib.mjs";
import { upsetSizes } from "../battery-v2/lib.mjs";
import { oracleMass } from "./lib.mjs";

const CALIPER = 0.5, SIDE_CAP = 300, MIN_PAIRS = 50;
const SEED = 20260901201;
let rngState = SEED;
const rand = () => {
  rngState |= 0; rngState = (rngState + 0x6d2b79f5) | 0;
  let t = Math.imul(rngState ^ (rngState >>> 15), 1 | rngState);
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};

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

// nFeats = 6 reproduces the v2 match (oracle SMD measured, unmatched);
// nFeats = 7 adds the oracle to the caliper.
const runMatch = (loader, nFeats) => {
  const { snaps, baselines, horizon, kernelCap } = loader();
  const fsMap = firstSeenOf(snaps);
  const acc = { ER: { n: 0, sumE: Array(7).fill(0), sumB: Array(7).fill(0) },
                ED: { n: 0, sumE: Array(7).fill(0), sumB: Array(7).fill(0) } };
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
    const orc = oracleMass(snap);
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
    const gOr = zStats(globalRows.map((c) => Math.log1p(orc[c])));
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
            for (let k = 0; k < 7; k++) { a2.sumE[k] += fE[ei][k]; a2.sumB[k] += fB[bi][k]; }
          }
        }
      }
    }
  }
  const report = { kernels };
  for (const contrast of ["ER", "ED"]) {
    const { n, sumE, sumB } = acc[contrast];
    const signed = Array.from({ length: 7 }, (_, k) => (n ? +((sumE[k] - sumB[k]) / n).toFixed(4) : null));
    report[contrast] = { pairs: n, signed,
                         maxSmdMatched: n ? Math.max(...signed.slice(0, 6).map(Math.abs)) : null,
                         smdOracle: signed?.[6], feasible: n >= MIN_PAIRS };
  }
  return report;
};

const out = { featNames: ["logIn", "logOut", "age", "logPR", "core", "logUpset", "logOracle"] };
for (const [corpus, loader] of [["go", loadGo], ["debian", loadDebian]]) {
  for (const nFeats of [6, 7]) {
    const label = `${corpus}-${nFeats}f`;
    const r = runMatch(loader, nFeats);
    out[label] = r;
    console.log(`${label}: kernels=${r.kernels}`);
    for (const c of ["ER", "ED"]) {
      console.log(`  ${c}: pairs=${r[c].pairs} maxSMD(matched)=${r[c].maxSmdMatched} signedSMD(oracle)=${r[c].smdOracle}`);
    }
  }
}
writeFileSync("battery-v3/precheck.json", JSON.stringify(out, null, 1));
console.log("wrote battery-v3/precheck.json");
