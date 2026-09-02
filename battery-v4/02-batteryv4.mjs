// Battery v4 — THE REGISTERED RUN: does the Debian claim survive
// momentum, the most standard control in growth prediction?
//
// PRE-REGISTRATION (header written before first run; committed after
// the blind pre-check 01, which touched balance/feasibility only).
// This run resolves the [H] commitment of preprints/seedbed/paper.md
// §7 before that paper goes anywhere — the reviewer's first question,
// answered in advance, whichever way it falls.
//
// THE FEATURE: f8 = signed-log prior-interval in-degree gain (momentum),
// baseline-measurable only (snapshots <= baseline). Baselines shift to
// 1..7 (2009-2021) because 2007 has no predecessor; the pre-check's
// 7-feature bridge column on the same baselines is the comparison
// basis (ER: 215,861 pairs at the v3 battery, baselines 1..7).
//
// WHAT THE BLIND PRE-CHECK FOUND (precheck.json, structure only):
//   - Momentum imbalance inside v3-battery pairs (baselines 1..7):
//     signed SMD -0.024 — small, and AGAINST the E side (E-members
//     carry slightly LESS recent growth than their R twins). Same
//     shape as the oracle pre-check: if anything, prior estimates
//     were conservative on this axis.
//   - Eight-feature match fully feasible: ER 201,031 pairs, maxSMD
//     0.0113; ED 703,078 pairs, maxSMD 0.0214.
//
// DESIGN: identical to battery-v3/02 for Debian in every constant
// except baselines 1..7 and the eighth feature in caliper and gate.
// Seed 20260901999 (fresh).
//
// REGISTERED PREDICTIONS:
//   BV4-1 (Debian E-vs-R, PRIMARY): Delta_ER > 0 at >= 97.5th
//     percentile of its sign-flip null (conditional statement per the
//     program's post-audit reading discipline).
//   Registered-descriptive (scores nothing): Delta_ED; and the
//     7-feature Delta_ER on baselines 1..7 (the bridge estimate, to
//     separate "momentum moved it" from "dropping 2007 moved it").
//
// OPERATOR PRIOR, ON THE RECORD: survival likely (pre-check imbalance
// small and negative), stated with the humility the last three
// batteries earned. Record going in: 9 for 26.
//
// INTERPRETATION TABLE (fixed in advance):
//   BV4-1 holds -> the paper's §7 [H] resolves to survival; battery
//     v4 becomes the paper's result of record; the reviewer's first
//     question has a sealed answer.
//   BV4-1 null/reverses -> the Debian effect was momentum in costume;
//     the fourth in-house kill, the claim table empties entirely, and
//     the paper is rewritten around the graveyard as the sole finding
//     (per the program's rules, at full volume, same day).
//
// Writes battery-v4/results.json.

import { readFileSync, writeFileSync } from "node:fs";
import { buildSnap, firstSeenOf, makeGate, makeDistancer } from "../deflation-control/lib.mjs";
import { pagerank, coreNumbers, zStats, greedyMatch } from "../baseline-gauntlet/gauntlet-lib.mjs";
import { upsetSizes } from "../battery-v2/lib.mjs";
import { oracleMass } from "../battery-v3/lib.mjs";

const CALIPER = 0.5, SIDE_CAP = 300, PERMS = 1000, MIN_PAIRS = 50, SMD_GATE = 0.10, KERNEL_CAP = 300;
const HORIZON = 2, BASELINES = [1, 2, 3, 4, 5, 6, 7];
const FEATS = ["logIn", "logOut", "age", "logPR", "core", "logUpset", "logOracle", "momentum"];
const SEED = 20260901999;
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

// nFeats 8 = the registered battery; nFeats 7 = the bridge (descriptive)
const collect = (nFeats) => {
  const out = { ER: { diffs: [], sumE: FEATS.map(() => 0), sumB: FEATS.map(() => 0) },
                ED: { diffs: [], sumE: FEATS.map(() => 0), sumB: FEATS.map(() => 0) } };
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
    const gainOf = (c) => {
      const nm = names[compMembers[c][0]];
      return (fut.inDeg.get(nm) ?? 0) - (inDeg.get(nm) ?? 0);
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

const score = (contrastOut, label, nFeats) => {
  const { diffs, sumE, sumB } = contrastOut;
  const n = diffs.length;
  const smd = FEATS.slice(0, nFeats).map((f, k) => (n ? Math.abs(sumE[k] - sumB[k]) / n : null));
  const maxSmd = n ? Math.max(...smd) : null;
  if (!n || n < MIN_PAIRS) { console.log(`  ${label}: UNINFORMATIVE (${n} pairs)`); return { pairs: n, verdict: "UNINFORMATIVE" }; }
  let obs = 0;
  for (const d of diffs) obs += d;
  obs /= n;
  const gateFailed = maxSmd > SMD_GATE;
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
  const verdict = gateFailed ? "GATE-FAILED (descriptive only)"
    : obs > 0 && pct >= 97.5 ? "HOLDS" : obs < 0 && pct <= 2.5 ? "REVERSES" : "NULL";
  console.log(`  ${label}: pairs=${n} maxSMD=${maxSmd.toFixed(4)} obs=${obs.toFixed(4)} null=[${lo.toFixed(4)},${hi.toFixed(4)}] pct=${pct.toFixed(1)} -> ${verdict}`);
  return { pairs: n, maxSmd: +maxSmd.toFixed(4), obs: +obs.toFixed(4), lo: +lo.toFixed(4), hi: +hi.toFixed(4), pct, verdict,
           smd: Object.fromEntries(FEATS.slice(0, nFeats).map((f, k) => [f, +smd[k].toFixed(4)])) };
};

const results = {};
{
  const { kernels, out } = collect(8);
  console.log(`debian 8f (registered): kernels=${kernels}`);
  results.v4 = { kernels,
    ER: score(out.ER, "BV4-1 PRIMARY Delta_ER", 8),
    ED: score(out.ED, "descriptive Delta_ED", 8) };
}
{
  const { kernels, out } = collect(7);
  console.log(`debian 7f bridge on baselines 1..7 (descriptive):`);
  results.bridge7f = { kernels,
    ER: score(out.ER, "bridge Delta_ER (7f, b1..7)", 7),
    ED: score(out.ED, "bridge Delta_ED (7f, b1..7)", 7) };
}
writeFileSync("battery-v4/results.json", JSON.stringify(results, null, 1));
console.log(JSON.stringify({ BV4_1: results.v4.ER.verdict }));
