// Baseline gauntlet — THE REGISTERED RUN: does E > R survive the
// standard-predictor battery?
//
// PRE-REGISTRATION (header written before first run; committed after the
// blind pre-check 01, which touched only matching feasibility and
// covariate balance — no gain was computed anywhere).
//
// WHAT IS AT STAKE: the program's surviving positive claim — in package
// ecosystems, Exploitation-cell membership predicts future load-bearing
// growth beyond degree, age, and connectivity (deflation-control/) — is
// not yet safe from the reviewer's arsenal. The remaining cheap
// explanations are the standard graph predictors: preferential
// attachment (in-degree), breadth (out-degree), prestige (PageRank),
// embeddedness (k-core). If the cell is a proxy for any combination of
// them, the compelling one-sentence result does not exist and the
// program needs to know today.
//
// DESIGN (constants fixed from the blind pre-check, structural info
// only): corpora Go and crates.io, same snapshots/baselines/horizons as
// software-study/04 and deflation-control (crates: 300 seeded kernels
// per baseline). Per evaluable kernel, candidates (singleton components,
// alive at horizon, non-I) are grouped by cell x EXACT undirected
// distance to the kernel's down-set (unreachable = own group). Within
// each distance group, sides capped at 300 (seeded), then greedy
// nearest-neighbor matching WITHOUT replacement in the z-space of five
// features — log1p(in-degree), log1p(out-degree), first-seen index,
// log(PageRank alpha=0.85 on the depended-upon direction), k-core
// number — with CALIPER 0.5 (chosen from the pre-check as the loosest
// caliper keeping every post-match standardized mean difference under
// 0.10 on both corpora and both contrasts). Declared exclusions from
// the battery: betweenness (O(VE), infeasible at crates scale) and
// clustering coefficient (heavy-tailed triangle counting; not a
// standard growth predictor).
//
// GATE (manipulation check, evaluated before any scoring): post-match
// max |SMD| over the five features must be <= 0.10 per corpus per
// contrast; a contrast failing balance is reported INFEASIBLE, not
// scored. Uninformative floor: < 50 pairs.
//
// SCORING: gains = horizon in-degree minus baseline in-degree. Paired
// statistic Delta = mean over pairs of (gain_E - gain_partner). Null:
// within-pair label swap (independent fair sign flips), 1000 draws,
// mulberry32 seed 20260831223.
//
// REGISTERED PREDICTIONS:
//   BG1 (Go):     Delta_ER > 0 at >= 97.5th percentile of its null.
//   BG2 (crates): Delta_ER > 0 at >= 97.5th percentile of its null.
//   Secondary, registered-descriptive (scores nothing): Delta_ED under
//   the same machinery — does E > D also survive the battery?
//
// OPERATOR PRIOR, ON THE RECORD: leaning survival, stated 2026-08-31 —
// the deflation control already killed the strongest single confound
// and the battery's heavy hitters (PageRank, k-core) are strongly
// degree-correlated. But the pre-check showed Go's matchable E-R
// overlap is thin (182 pairs), so a Go null by low power is a live
// possibility; that is what the uninformative floor and the explicit
// pair count are for. Registered-directional record going in: 3 for 18.
//
// INTERPRETATION TABLE (fixed in advance):
//   BG1 and BG2 hold -> the cell beats the battery on both surviving
//     corpora; the gatekeeper sentence exists; proceed to the Debian
//     rank bet and write the empirical paper.
//   One holds, one null -> partial: the claim is scoped to the corpus
//     that held; the paper weakens to that scope; Debian becomes the
//     tiebreaker and its registration must say so.
//   Both null or any reversal -> the cell is a proxy for standard
//     structure in package ecosystems too; the E-growth positive dies
//     the same death as the proof-corpus version, at full prominence;
//     what remains of the program's field claims is E-on-territory,
//     latency, and the E-vs-D orderings.
//
// Writes baseline-gauntlet/results-gauntlet.json.

import { writeFileSync } from "node:fs";
import { CORPORA, firstSeenOf, makeGate, makeDistancer, CRATES_KERNELS } from "../deflation-control/lib.mjs";
import { pagerank, coreNumbers, zStats, greedyMatch } from "./gauntlet-lib.mjs";

const SEED = 20260831223;
const CALIPER = 0.5;
const SIDE_CAP = 300;
const PERMS = 1000;
const MIN_PAIRS = 50;
const SMD_GATE = 0.10;
const FEATS = ["logIn", "logOut", "age", "logPR", "core"];

let rngState = SEED;
const rand = () => {
  rngState |= 0; rngState = (rngState + 0x6d2b79f5) | 0;
  let t = Math.imul(rngState ^ (rngState >>> 15), 1 | rngState);
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};

const collect = (corpus) => {
  const { subs, baselines, horizon } = CORPORA[corpus]();
  const snaps = subs[0];
  const fsMap = firstSeenOf(snaps);
  const out = { ER: { diffs: [], sumE: FEATS.map(() => 0), sumB: FEATS.map(() => 0) },
                ED: { diffs: [], sumE: FEATS.map(() => 0), sumB: FEATS.map(() => 0) } };
  let kernels = 0;
  for (const ti of baselines) {
    const snap = snaps[ti];
    const fut = snaps[ti + horizon];
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
      const groups = { E: new Map(), D: new Map(), R: new Map() };
      for (const c of globalRows) {
        const cell = g.cellOf(c);
        if (cell === "I") continue;
        const d = dOf(c);
        if (!groups[cell].has(d)) groups[cell].set(d, []);
        groups[cell].get(d).push(c);
      }
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
      const gainOf = (c) => {
        const nm = names[compMembers[c][0]];
        return (fut.inDeg.get(nm) ?? 0) - (inDeg.get(nm) ?? 0);
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
          const eCap = cap([...eMembers]), bCap = cap([...bMembers]);
          const fE = eCap.map(featOf), fB = bCap.map(featOf);
          const pairs = greedyMatch(fE, fB, CALIPER, rand);
          const acc = out[contrast];
          for (const [ei, bi] of pairs) {
            acc.diffs.push(gainOf(eCap[ei]) - gainOf(bCap[bi]));
            for (let k = 0; k < FEATS.length; k++) {
              acc.sumE[k] += fE[ei][k];
              acc.sumB[k] += fB[bi][k];
            }
          }
        }
      }
    }
  }
  return { kernels, out };
};

const results = {};
for (const corpus of ["go", "crates"]) {
  const { kernels, out } = collect(corpus);
  results[corpus] = { kernels };
  console.log(`${corpus}: kernels=${kernels}`);
  for (const contrast of ["ER", "ED"]) {
    const { diffs, sumE, sumB } = out[contrast];
    const n = diffs.length;
    const smd = FEATS.map((f, k) => (n ? Math.abs(sumE[k] - sumB[k]) / n : null));
    const maxSmd = n ? Math.max(...smd) : null;
    const label = contrast === "ER" ? "PRIMARY Delta_ER" : "descriptive Delta_ED";
    if (!n || n < MIN_PAIRS) {
      console.log(`  ${label}: UNINFORMATIVE (${n} pairs)`);
      results[corpus][contrast] = { pairs: n, verdict: "UNINFORMATIVE" };
      continue;
    }
    if (maxSmd > SMD_GATE) {
      console.log(`  ${label}: INFEASIBLE — balance gate failed (maxSMD ${maxSmd.toFixed(4)})`);
      results[corpus][contrast] = { pairs: n, maxSmd, verdict: "INFEASIBLE" };
      continue;
    }
    let obs = 0;
    for (const d of diffs) obs += d;
    obs /= n;
    const nulls = [];
    for (let p = 0; p < PERMS; p++) {
      let s = 0;
      for (const d of diffs) s += rand() < 0.5 ? d : -d;
      nulls.push(s / n);
    }
    nulls.sort((a, b) => a - b);
    let below = 0;
    for (const v of nulls) if (v < obs) below++;
    const pct = (100 * below) / PERMS;
    const lo = nulls[Math.floor(0.025 * PERMS)], hi = nulls[Math.floor(0.975 * PERMS)];
    const verdict = obs > 0 && pct >= 97.5 ? "HOLDS" : obs < 0 && pct <= 2.5 ? "REVERSES" : "NULL";
    console.log(`  ${label}: pairs=${n} maxSMD=${maxSmd.toFixed(4)} obs=${obs.toFixed(4)} null=[${lo.toFixed(4)},${hi.toFixed(4)}] pct=${pct.toFixed(1)} -> ${verdict}`);
    results[corpus][contrast] = {
      pairs: n, maxSmd, obs, lo, hi, pct, verdict,
      smd: Object.fromEntries(FEATS.map((f, k) => [f, +smd[k].toFixed(4)])),
    };
  }
}
writeFileSync("baseline-gauntlet/results-gauntlet.json", JSON.stringify(results, null, 1));
console.log(JSON.stringify({ BG1: results.go.ER.verdict, BG2: results.crates.ER.verdict }));
