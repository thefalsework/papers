// Battery v4 — BLIND PRE-CHECK (structure only; no future gain computed).
//
// The seedbed paper (preprints/seedbed/paper.md §7) declared MOMENTUM —
// a node's own prior-interval in-degree gain, the most standard control
// in growth prediction — as the lead unmatched feature and committed
// [H] to running it. This folder resolves that commitment before the
// paper goes anywhere.
//
// THE FEATURE, fixed here before anything runs:
//   f8 = momentum = signed log: sign(g) * log1p(|g|), where
//        g = inDeg_baseline - inDeg_previous_snapshot
//   (previous in-degree is 0 for packages absent from the previous
//   snapshot — their momentum equals their whole baseline in-degree;
//   age is matched separately so this conflation is priced). z-scored
//   per snapshot over candidate rows like every other feature.
//   NOTE: momentum is a BASELINE-measurable quantity (it uses only
//   snapshots <= baseline); no future information enters.
//
// DECLARED DESIGN CHANGE: baselines shift from 0..7 to 1..7 (2009-2021)
// because 2007 has no predecessor. The v4 estimate is therefore not
// pair-for-pair comparable with v1-v3; the pre-check reports the
// 7-feature match on baselines 1..7 as the bridge column.
//
// WHAT THIS PRE-CHECK REPORTS (outcome-blind):
//   1. Momentum imbalance inside the v3 (seven-feature) pairs, on
//      baselines 1..7 — signed, per contrast. The Go-ER lesson: this
//      is where artifacts hide.
//   2. Feasibility/balance of the EIGHT-feature match at caliper 0.5.
//
// Corpus: Debian only (the only corpus with a certified claim).
// Constants otherwise identical to battery-v3. Seed: 20260901301.

import { readFileSync, writeFileSync } from "node:fs";
import { buildSnap, firstSeenOf, makeGate, makeDistancer } from "../deflation-control/lib.mjs";
import { pagerank, coreNumbers, zStats, greedyMatch } from "../baseline-gauntlet/gauntlet-lib.mjs";
import { upsetSizes } from "../battery-v2/lib.mjs";
import { oracleMass } from "../battery-v3/lib.mjs";

const CALIPER = 0.5, SIDE_CAP = 300, MIN_PAIRS = 50, KERNEL_CAP = 300;
const HORIZON = 2, BASELINES = [1, 2, 3, 4, 5, 6, 7];
const SEED = 20260901301;
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
const fsMap = firstSeenOf(snaps);

const runMatch = (nFeats) => {
  const acc = { ER: { n: 0, sumE: Array(8).fill(0), sumB: Array(8).fill(0) },
                ED: { n: 0, sumE: Array(8).fill(0), sumB: Array(8).fill(0) } };
  let kernels = 0;
  for (const ti of BASELINES) {
    const snap = snaps[ti];
    const prev = snaps[ti - 1];
    const fut = snaps[ti + HORIZON];
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
            for (let k = 0; k < 8; k++) { a2.sumE[k] += fE[ei][k]; a2.sumB[k] += fB[bi][k]; }
          }
        }
      }
    }
  }
  const report = { kernels };
  for (const contrast of ["ER", "ED"]) {
    const { n, sumE, sumB } = acc[contrast];
    const signed = Array.from({ length: 8 }, (_, k) => (n ? +((sumE[k] - sumB[k]) / n).toFixed(4) : null));
    report[contrast] = { pairs: n, signed,
                         maxSmdMatched: n ? Math.max(...signed.slice(0, nFeats).map(Math.abs)) : null,
                         smdMomentum: signed?.[7], feasible: n >= MIN_PAIRS };
  }
  return report;
};

const out = { featNames: ["logIn", "logOut", "age", "logPR", "core", "logUpset", "logOracle", "momentum"] };
for (const nFeats of [7, 8]) {
  const label = `debian-${nFeats}f-b1to7`;
  const r = runMatch(nFeats);
  out[label] = r;
  console.log(`${label}: kernels=${r.kernels}`);
  for (const c of ["ER", "ED"]) {
    console.log(`  ${c}: pairs=${r[c].pairs} maxSMD(matched)=${r[c].maxSmdMatched} signedSMD(momentum)=${r[c].smdMomentum}`);
  }
}
writeFileSync("battery-v4/precheck.json", JSON.stringify(out, null, 1));
console.log("wrote battery-v4/precheck.json");
