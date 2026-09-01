// Battery v2 — blind caliper sweep for the one tight spot (Go, E-vs-R).
// Still outcome-blind: no gain computed. The 01 pre-check found the
// six-feature match at caliper 0.5 leaves 51 pairs with SMD(upset)
// 0.113 — marginally over the 0.10 gate and one pair above the floor.
// This sweep fixes the registered caliper for Go ER (or establishes
// that Go ER is INFEASIBLE at every caliper, which the registration
// must then say in advance). Also reports the SIGN of the up-set
// imbalance in the old five-feature pairs, which |SMD| hides.

import { CORPORA, firstSeenOf, makeGate, makeDistancer } from "../deflation-control/lib.mjs";
import { pagerank, coreNumbers, zStats, greedyMatch } from "../baseline-gauntlet/gauntlet-lib.mjs";
import { upsetSizes } from "./lib.mjs";

const SIDE_CAP = 300;
const SEED = 20260901102;
let rngState = SEED;
const rand = () => {
  rngState |= 0; rngState = (rngState + 0x6d2b79f5) | 0;
  let t = Math.imul(rngState ^ (rngState >>> 15), 1 | rngState);
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};

const { subs, baselines, horizon } = CORPORA.go();
const snaps = subs[0];
const fsMap = firstSeenOf(snaps);

// collect candidate groups once per baseline, then sweep calipers
const perBaseline = [];
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
  const kernelGroups = [];
  for (let a = 0; a < nComp; a++) {
    const g = gate(a);
    if (!g) continue;
    const dOf = distancer(g.downMembers);
    const groups = { E: new Map(), R: new Map() };
    for (const c of globalRows) {
      const cell = g.cellOf(c);
      if (cell !== "E" && cell !== "R") continue;
      const d = dOf(c);
      if (!groups[cell].has(d)) groups[cell].set(d, []);
      groups[cell].get(d).push(c);
    }
    kernelGroups.push(groups);
  }
  perBaseline.push({ featOf, kernelGroups });
}

const cap = (arr) => {
  if (arr.length <= SIDE_CAP) return arr;
  for (let i = 0; i < SIDE_CAP; i++) {
    const j = i + Math.floor(rand() * (arr.length - i));
    const t = arr[i]; arr[i] = arr[j]; arr[j] = t;
  }
  return arr.slice(0, SIDE_CAP);
};

for (const [nFeats, caliper] of [[5, 0.5], [6, 0.5], [6, 0.4], [6, 0.35], [6, 0.3], [6, 0.25], [6, 0.6], [6, 0.75]]) {
  let n = 0;
  const sumE = Array(6).fill(0), sumB = Array(6).fill(0);
  for (const { featOf, kernelGroups } of perBaseline) {
    for (const groups of kernelGroups) {
      for (const [d, eMembers] of groups.E) {
        const rMembers = groups.R.get(d);
        if (!rMembers) continue;
        const eCap = cap([...eMembers]), rCap = cap([...rMembers]);
        const fE = eCap.map(featOf), fR = rCap.map(featOf);
        const pairs = greedyMatch(fE.map((f) => f.slice(0, nFeats)), fR.map((f) => f.slice(0, nFeats)), caliper, rand);
        for (const [ei, ri] of pairs) {
          n++;
          for (let k = 0; k < 6; k++) { sumE[k] += fE[ei][k]; sumB[k] += fR[ri][k]; }
        }
      }
    }
  }
  const signed = Array.from({ length: 6 }, (_, k) => (n ? +((sumE[k] - sumB[k]) / n).toFixed(4) : null));
  const max5 = n ? Math.max(...signed.slice(0, 5).map(Math.abs)) : null;
  console.log(`go ER ${nFeats}f caliper=${caliper}: pairs=${n} maxSMD(f0-f4)=${max5} signedSMD(upset)=${signed[5]} signed=[${signed}]`);
}
