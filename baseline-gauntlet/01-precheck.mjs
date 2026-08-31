// Baseline gauntlet, blind pre-check.
//
// BLINDNESS DISCIPLINE: computes matching FEASIBILITY and covariate
// BALANCE only — how many E-R (and E-D) nearest-neighbor pairs form per
// corpus at candidate calipers {0.5, 1.0, 2.0}, and the post-matching
// standardized mean difference (SMD) of every battery feature. Horizon
// snapshots are touched only for the survival filter (does the member
// still exist), exactly as every prior pre-check. No gain is computed.
// The caliper for the registered run will be chosen from THIS output
// (structural information only) and fixed in 02's header.
//
// REVISION (same session, still blind): the first pass matched all six
// features in one z-space and the balance report showed the residual
// imbalance is entirely the DISTANCE dimension (crates ER at caliper
// 0.5: dist SMD 0.286, every other feature <= 0.01). Distance is the
// confound the deflation control already handles by exact matching, so
// this pass adopts the same discipline: candidates are grouped by EXACT
// distance within kernel (unreachable its own group), and the caliper
// governs the five continuous features. Calipers tested: 0.25/0.5/1.0.
//
// Corpora: Go and crates.io — the two where the cell effect survived
// the deflation control; they are the claim under defense.
//
// Writes baseline-gauntlet/results-precheck.json.

import { writeFileSync } from "node:fs";
import { CORPORA, firstSeenOf, makeGate, makeDistancer, CRATES_KERNELS } from "../deflation-control/lib.mjs";
import { pagerank, coreNumbers, zStats, greedyMatch } from "./gauntlet-lib.mjs";

const SEED = 20260831011;
let rngState = SEED;
const rand = () => {
  rngState |= 0; rngState = (rngState + 0x6d2b79f5) | 0;
  let t = Math.imul(rngState ^ (rngState >>> 15), 1 | rngState);
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};

const CALIPERS = [0.25, 0.5, 1.0];
const SIDE_CAP = 300; // per (kernel, cell, distance-group) before matching, seeded

const FEATS = ["logIn", "logOut", "age", "logPR", "core"];

const run = (corpus) => {
  const { subs, baselines, horizon } = CORPORA[corpus]();
  const snaps = subs[0];
  const fsMap = firstSeenOf(snaps);
  // accumulators per caliper per contrast
  const acc = {};
  for (const cal of CALIPERS) {
    acc[cal] = {
      ER: { pairs: 0, kernels: 0, sumE: FEATS.map(() => 0), sumR: FEATS.map(() => 0) },
      ED: { pairs: 0, kernels: 0, sumE: FEATS.map(() => 0), sumR: FEATS.map(() => 0) },
    };
  }
  let kernels = 0, candE = 0, candR = 0, candD = 0;
  for (const ti of baselines) {
    const snap = snaps[ti];
    const fut = snaps[ti + horizon];
    const gate = makeGate(snap);
    const distancer = makeDistancer(snap);
    const { nComp, compMembers, names, inDeg } = snap;
    const pr = pagerank(snap);
    const core = coreNumbers(snap);
    // snapshot-level z stats over all surviving singleton comps
    const globalRows = [];
    for (let c = 0; c < nComp; c++) {
      const members = compMembers[c];
      if (members.length > 1) continue;
      const nm = names[members[0]];
      if (!fut.inDeg.has(nm)) continue;
      globalRows.push(c);
    }
    const gIn = zStats(globalRows.map((c) => Math.log1p(inDeg.get(names[compMembers[c][0]]) ?? 0)));
    const gOut = zStats(globalRows.map((c) => Math.log1p(snap.cIn[c].length)));
    const gAge = zStats(globalRows.map((c) => fsMap.get(names[compMembers[c][0]])));
    const gPR = zStats(globalRows.map((c) => Math.log(pr[c])));
    const gCore = zStats(globalRows.map((c) => core[c]));
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
      // group candidates by (cell, exact distance)
      const groups = { E: new Map(), D: new Map(), R: new Map() };
      let nE = 0, nR = 0, nD = 0;
      for (const c of globalRows) {
        const cell = g.cellOf(c);
        if (cell === "I") continue;
        const d = dOf(c); // -1 = unreachable, its own group
        if (!groups[cell].has(d)) groups[cell].set(d, []);
        groups[cell].get(d).push(c);
        if (cell === "E") nE++; else if (cell === "R") nR++; else nD++;
      }
      candE += nE; candR += nR; candD += nD;
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
        const counted = new Set();
        for (const [d, eMembers] of groups.E) {
          const bMembers = groups[bSide].get(d);
          if (!bMembers) continue;
          const fE = cap([...eMembers]).map(featOf);
          const fB = cap([...bMembers]).map(featOf);
          for (const cal of CALIPERS) {
            const pairs = greedyMatch(fE, fB, cal, rand);
            if (!pairs.length) continue;
            const a2 = acc[cal][contrast];
            a2.pairs += pairs.length;
            if (!counted.has(cal)) { a2.kernels++; counted.add(cal); }
            for (const [ei, bi] of pairs) {
              for (let k = 0; k < FEATS.length; k++) {
                a2.sumE[k] += fE[ei][k];
                a2.sumR[k] += fB[bi][k];
              }
            }
          }
        }
      }
    }
  }
  const report = { kernels, candE, candR, candD, calipers: {} };
  for (const cal of CALIPERS) {
    report.calipers[cal] = {};
    for (const contrast of ["ER", "ED"]) {
      const a2 = acc[cal][contrast];
      const smd = FEATS.map((f, k) =>
        a2.pairs ? +(Math.abs(a2.sumE[k] - a2.sumR[k]) / a2.pairs).toFixed(4) : null);
      report.calipers[cal][contrast] = {
        pairs: a2.pairs, kernels: a2.kernels,
        smd: Object.fromEntries(FEATS.map((f, k) => [f, smd[k]])),
        maxSmd: a2.pairs ? Math.max(...smd) : null,
      };
    }
  }
  return report;
};

const out = {};
for (const corpus of ["go", "crates"]) {
  out[corpus] = run(corpus);
  console.log(`${corpus}: kernels=${out[corpus].kernels} candidates E=${out[corpus].candE} R=${out[corpus].candR} D=${out[corpus].candD}`);
  for (const cal of CALIPERS) {
    const r = out[corpus].calipers[cal];
    console.log(`  caliper ${cal}: ER pairs=${r.ER.pairs} (maxSMD ${r.ER.maxSmd}) | ED pairs=${r.ED.pairs} (maxSMD ${r.ED.maxSmd})`);
  }
}
writeFileSync("baseline-gauntlet/results-precheck.json", JSON.stringify(out, null, 1));
console.log("wrote baseline-gauntlet/results-precheck.json");
