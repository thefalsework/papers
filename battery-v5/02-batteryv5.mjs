// Battery v5 — THE REGISTERED RUN: does the Debian claim survive
// functional role? A pair must now agree on kernel, exact distance,
// AND archive Section — the archive's own role taxonomy — with the
// full v4 eight-feature caliper battery inside each stratum. A
// surviving effect is a claim about same-role twins: a libs package
// versus a libs package, at matched everything.
//
// PRE-REGISTRATION (header written before first run; committed after
// the blind pre-check 01, which touched structure only).
//
// WHAT THE BLIND PRE-CHECK FOUND (precheck.json) — AND IT CUTS THE
// OTHER WAY THIS TIME: inside v4-style pairs only 6.05% of E-R twins
// agree on section, and the E side is 2.4x more library-flavored
// (libs+libdevel+devel share 13.1% vs 5.4%). Unlike momentum and the
// oracle — both nearly balanced, both leaning against E — functional
// role is genuinely imbalanced WITH the story that would deflate the
// claim. This is the first battery generation since v2's Go kill
// where the pre-check says the knife has a real chance. Registered
// accordingly, with the operator's prior stated at even odds.
//
// Feasibility (blind): section-stratified ER 79,167 pairs, maxSMD
// 0.0090 — cleaner balance than any prior generation. Note on caps:
// SIDE_CAP applies per (distance x section) stratum, so the D side
// (huge cells, previously truncated at 300 per distance) contributes
// many more candidates than in v4; the ED descriptive is therefore
// not pair-for-pair comparable with v4's and is reported as its own
// object.
//
// REGISTERED PREDICTIONS:
//   BV5-1 (Debian E-vs-R, section-stratified, PRIMARY): Delta_ER > 0
//     at >= 97.5th percentile of its sign-flip null (conditional
//     statement per the program's reading discipline).
//   Registered-descriptive (scores nothing): section-stratified
//     Delta_ED; per-section Delta_ER for the five largest sections by
//     pair count (to see WHERE the effect lives if it survives).
//
// INTERPRETATION TABLE (fixed in advance):
//   BV5-1 holds -> the "it's just the library sections" explanation is
//     dead; the claim upgrades to same-role twins and battery v5
//     becomes the paper's result of record.
//   BV5-1 null/reverses -> the Debian effect was functional role in
//     costume; fourth in-house kill; the certified table empties and
//     the paper is rewritten around the graveyard, same day, full
//     volume.
//
// Constants identical to battery-v4/02 except stratification and seed.
// Seed 20260901777 (fresh). Writes battery-v5/results.json.

import { readFileSync, writeFileSync } from "node:fs";
import { buildSnap, firstSeenOf, makeGate, makeDistancer } from "../deflation-control/lib.mjs";
import { pagerank, coreNumbers, zStats, greedyMatch } from "../baseline-gauntlet/gauntlet-lib.mjs";
import { upsetSizes } from "../battery-v2/lib.mjs";
import { oracleMass } from "../battery-v3/lib.mjs";

const CALIPER = 0.5, SIDE_CAP = 300, PERMS = 1000, MIN_PAIRS = 50, SMD_GATE = 0.10, KERNEL_CAP = 300;
const HORIZON = 2, BASELINES = [1, 2, 3, 4, 5, 6, 7];
const FEATS = ["logIn", "logOut", "age", "logPR", "core", "logUpset", "logOracle", "momentum"];
const SEED = 20260901777;
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

const acc = { ER: { diffs: [], secs: [], sumE: FEATS.map(() => 0), sumB: FEATS.map(() => 0) },
              ED: { diffs: [], secs: [], sumE: FEATS.map(() => 0), sumB: FEATS.map(() => 0) } };
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
      const key = `${dOf(c)}|${secOf(c)}`;
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
        const sec = key.slice(key.indexOf("|") + 1);
        for (const [ei, bi] of pairs) {
          a2.diffs.push(gainOf(eCap[ei]) - gainOf(bCap[bi]));
          a2.secs.push(sec);
          for (let k = 0; k < FEATS.length; k++) {
            a2.sumE[k] += fE[ei][k];
            a2.sumB[k] += fB[bi][k];
          }
        }
      }
    }
  }
}

const score = (contrastOut, label) => {
  const { diffs, sumE, sumB } = contrastOut;
  const n = diffs.length;
  const smd = FEATS.map((f, k) => (n ? Math.abs(sumE[k] - sumB[k]) / n : null));
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
           smd: Object.fromEntries(FEATS.map((f, k) => [f, +smd[k].toFixed(4)])) };
};

console.log(`debian 8f section-stratified: kernels=${kernels}`);
const results = { kernels,
  ER: score(acc.ER, "BV5-1 PRIMARY Delta_ER (same-section twins)"),
  ED: score(acc.ED, "descriptive Delta_ED (same-section twins)") };

// registered-descriptive: per-section Delta_ER, five largest by pairs
const bySec = new Map();
acc.ER.diffs.forEach((d, i) => {
  const s = acc.ER.secs[i];
  if (!bySec.has(s)) bySec.set(s, []);
  bySec.get(s).push(d);
});
results.perSectionER = {};
const top = [...bySec.entries()].sort((a, b) => b[1].length - a[1].length).slice(0, 5);
for (const [s, ds] of top) {
  const m = ds.reduce((a, b) => a + b, 0) / ds.length;
  results.perSectionER[s] = { pairs: ds.length, obs: +m.toFixed(4) };
  console.log(`  per-section ER ${s}: pairs=${ds.length} obs=${m.toFixed(4)}`);
}
writeFileSync("battery-v5/results.json", JSON.stringify(results, null, 1));
console.log(JSON.stringify({ BV5_1: results.ER.verdict }));
