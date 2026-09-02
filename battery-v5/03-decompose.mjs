// Battery v5 — POST-HOC DESCRIPTIVE DECOMPOSITION. NOT A SCORED RUN.
//
// Purpose (external review of the kill, 2026-09-02): the per-section
// estimates in the registered run were heterogeneous, not uniform —
// javascript -0.53, devel -0.27, doc +0.015 — and Debian's javascript
// packaging is notoriously atypical (thousands of tiny node-module
// packages with unusual dependency shapes). The question "is the
// reversal mostly a javascript artifact?" is checkable with data the
// registered run already produced, and the reader deserves the answer
// as part of the kill's anatomy. It does not resurrect the claim:
// the interpretation table bound BV5-1 regardless of composition.
//
// METHOD: reproduce the registered run's pair set EXACTLY (same seed
// 20260901777, same collection code path as 02-batteryv5.mjs; the RNG
// stream through collection is identical, so the pairs are identical)
// and report, with no verdicts and no percentiles:
//   - the FULL per-section table (pairs, mean diff), both contrasts;
//   - leave-one-out pooled means for the ten largest sections
//     ("what does Delta_ER read with section X's pairs removed?").
//
// Writes battery-v5/decompose.json.

import { readFileSync, writeFileSync } from "node:fs";
import { buildSnap, firstSeenOf, makeGate, makeDistancer } from "../deflation-control/lib.mjs";
import { pagerank, coreNumbers, zStats, greedyMatch } from "../baseline-gauntlet/gauntlet-lib.mjs";
import { upsetSizes } from "../battery-v2/lib.mjs";
import { oracleMass } from "../battery-v3/lib.mjs";

const CALIPER = 0.5, SIDE_CAP = 300, KERNEL_CAP = 300;
const HORIZON = 2, BASELINES = [1, 2, 3, 4, 5, 6, 7];
const SEED = 20260901777; // registered run's seed: identical pair stream
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

const acc = { ER: { diffs: [], secs: [] }, ED: { diffs: [], secs: [] } };
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
    used++;
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
        }
      }
    }
  }
}

const out = {};
for (const contrast of ["ER", "ED"]) {
  const { diffs, secs } = acc[contrast];
  const n = diffs.length;
  const total = diffs.reduce((a, b) => a + b, 0);
  const bySec = new Map();
  diffs.forEach((d, i) => {
    const s = secs[i];
    if (!bySec.has(s)) bySec.set(s, { n: 0, sum: 0 });
    const e = bySec.get(s);
    e.n++; e.sum += d;
  });
  const table = [...bySec.entries()]
    .sort((a, b) => b[1].n - a[1].n)
    .map(([s, e]) => ({ section: s, pairs: e.n, obs: +(e.sum / e.n).toFixed(4) }));
  const leaveOneOut = table.slice(0, 10).map(({ section }) => {
    const e = bySec.get(section);
    return { without: section,
             pairs: n - e.n,
             obs: +((total - e.sum) / (n - e.n)).toFixed(4) };
  });
  out[contrast] = { pairs: n, obs: +(total / n).toFixed(4), perSection: table, leaveOneOut };
  console.log(`${contrast}: pooled obs=${out[contrast].obs} over ${n} pairs`);
  console.log(`  per-section (>=1000 pairs): ${table.filter((r) => r.pairs >= 1000)
    .map((r) => `${r.section}:${r.obs}(${r.pairs})`).join(" ")}`);
  console.log(`  leave-one-out: ${leaveOneOut.map((r) => `-${r.without}:${r.obs}`).join(" ")}`);
}
writeFileSync("battery-v5/decompose.json", JSON.stringify(out, null, 1));
console.log("wrote battery-v5/decompose.json (descriptive, unscored)");
