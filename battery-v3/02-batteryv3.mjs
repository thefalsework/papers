// Battery v3 — THE REGISTERED RUN: does the field claim survive the
// functional that fully explains the strongest synthetic counterexample?
//
// PRE-REGISTRATION (header written before first run; committed after
// the blind pre-check 01, which touched balance/feasibility only).
//
// PROVENANCE: battery v2's sixth feature was derived from the flux
// law's first-order form (up-set size) and killed Go's E-vs-R. The
// oracle test (accretion-study/05-oracle.mjs, same day) then found the
// COMPLETE mechanism of the synthetic inversion: harmonic
// cone-membership mass, ORACLE(x) = sum_{u: x in cone_200(u)}
// 1/|cone_200(u)| — with ORACLE matched, the synthetic cell effect is
// exactly zero (t = -0.25), while exact descendant counts leave t = -7.
// ORACLE is a pure graph feature, so it is admissible in a field
// battery. This is the sharpest knife the program knows how to make.
//
// WHAT THE BLIND PRE-CHECK FOUND (precheck.json, structure only):
//   - Debian, v2 (six-feature) pairs: ORACLE imbalance is small and
//     NEGATIVE (signed SMD -0.025) — the certified v2 pairs slightly
//     under-served E on cone mass; the v2 estimate was, if anything,
//     conservative w.r.t. this feature.
//   - Debian, seven-feature match: fully feasible (ER 229,646 pairs,
//     maxSMD 0.0114; ED 884,598 pairs, maxSMD 0.0222).
//   - Go E-vs-D: feasible (10,074 pairs, maxSMD 0.074, oracle SMD
//     0.013). Go E-vs-R: unchanged from v2 (51 pairs, gate failed at
//     0.113) — remains pre-declared uncertifiable; reported
//     descriptively only.
//
// DESIGN: identical to battery-v2/02 in every constant; the match
// z-space gains f7 = log1p(ORACLE) (battery-v3/lib.mjs) and the
// balance gate covers all seven features. Seed 20260901888 (fresh).
//
// REGISTERED PREDICTIONS:
//   BV3-1 (Debian E-vs-R, PRIMARY): Delta_ER > 0 at >= 97.5th
//     percentile of its sign-flip null (conditional statement, per
//     the audit's reading discipline; the registered content is sign
//     + conditional band).
//   BV3-2 (Go E-vs-D): Delta_ED > 0 at >= 97.5th percentile.
//   Registered-descriptive (scores nothing): Debian E-vs-D; Go E-vs-R.
//
// OPERATOR PRIOR, ON THE RECORD: survival likely for both — the
// pre-check shows the oracle nearly balanced already in the pairs
// that carried v2. But this is exactly what the Go-ER pairs looked
// safe on before up-set was measured, and the whole point of a sealed
// bet is that the prior doesn't score. Record going in: 8 for 24.
//
// INTERPRETATION TABLE (fixed in advance):
//   Both hold -> the claim reaches its strongest attainable form:
//     the cell predicts growth beyond every standard predictor, the
//     first-order flux feature, AND the complete synthetic mechanism.
//     The growth chapter closes certified; remaining work is theory
//     (why E, not R, in the field) and the 2028 register.
//   BV3-1 dissolves -> the deepest possible deflation, and the best
//     mechanistic result the program could ask for: field growth IS
//     harmonic cone-mass flux; the cells were reading it; the
//     empirical paper becomes "a derived functional explains package
//     ecosystem growth and its cell partition" — written around the
//     deflation at full volume.
//   BV3-2 dissolves alone -> Go exits the certified table entirely;
//     Debian stands alone, maximally certified.
//
// Writes battery-v3/results.json.

import { readFileSync, writeFileSync } from "node:fs";
import { CORPORA, buildSnap, firstSeenOf, makeGate, makeDistancer } from "../deflation-control/lib.mjs";
import { pagerank, coreNumbers, zStats, greedyMatch } from "../baseline-gauntlet/gauntlet-lib.mjs";
import { upsetSizes } from "../battery-v2/lib.mjs";
import { oracleMass } from "./lib.mjs";

const CALIPER = 0.5, SIDE_CAP = 300, PERMS = 1000, MIN_PAIRS = 50, SMD_GATE = 0.10;
const FEATS = ["logIn", "logOut", "age", "logPR", "core", "logUpset", "logOracle"];
const SEED = 20260901888;
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

const collect = (loader) => {
  const { snaps, baselines, horizon, kernelCap } = loader();
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

const results = {};
for (const [corpus, loader] of [["go", loadGo], ["debian", loadDebian]]) {
  const { kernels, out } = collect(loader);
  console.log(`${corpus}: kernels=${kernels}`);
  results[corpus] = {
    kernels,
    ER: score(out.ER, corpus === "debian" ? "BV3-1 PRIMARY Delta_ER" : "descriptive (pre-declared gate-failed) Delta_ER"),
    ED: score(out.ED, corpus === "go" ? "BV3-2 Delta_ED" : "descriptive Delta_ED"),
  };
}
writeFileSync("battery-v3/results.json", JSON.stringify(results, null, 1));
console.log(JSON.stringify({ BV3_1: results.debian.ER.verdict, BV3_2: results.go.ED.verdict }));
