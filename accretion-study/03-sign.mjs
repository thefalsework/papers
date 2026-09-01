// Accretion study, Phase D opener — THE SIGN PROBLEM MEASURED
// (registered before first run; the "registered next measurable" of
// THEORY.md section 3 and SPEC.md postscript 2).
//
// THE QUESTION: why does PC(0) put R above E at matched battery?
// THEORY.md's flux law says expected gain tracks truncated up-set size
// (cone-membership frequency), and its conjecture says the cells
// differ in up-set size *at matched battery*: E-members sit interior
// to the kernel's sector, while battery- and distance-matched
// R-members are relatively more root-like within foreign sectors and
// so appear in more future cones.
//
// DESIGN: 10 fresh PC(0) universes (seeds 920000+r; estimator seeds
// 925000+r; disjoint from Phase A/B'), N = 30k, schedule and pairing
// machinery identical to the confirmatory runs (5-feature battery,
// the battery the R > E > D discovery was made on). For each matched
// E-R and E-D pair, record THREE numbers: the gain difference (as
// always), the baseline log1p(up-set) difference, and their product
// sign. Per universe: mean pair up-set difference; pooled Pearson
// correlation of log1p(upset) with gain over all candidate members.
//
// REGISTERED PREDICTIONS (thresholds fixed now):
//   S1 (flux law, direct): pooled corr(log1p(upset), gain) > 0 in
//      EVERY universe (10/10). This is the law itself; if it fails,
//      THEORY.md section 3 is wrong at its root.
//   S2 (the sign conjecture): across-universe mean of (mean pair
//      upsetE - upsetR) < 0 at |t| >= 3 — matched E-members carry
//      SMALLER up-sets than their R twins. If S2 holds together with
//      S1, the R > E > D inversion is explained: the cell's battery-
//      transcending signal in PC(0) IS up-set flux, flowing along the
//      up-set gap the battery cannot see. (This is the synthetic
//      mirror of what battery-v2 found on Go, +0.69 the other way.)
//   S3 (closure): with log1p(upset) ADDED to the battery (six
//      features, the battery-v2 move run in the synthetic world), the
//      across-universe mean Delta_ER comes back |t| < 2 — matching
//      away the up-set gap kills the PC(0) effect entirely. CONFIRMS
//      = the mechanism is fully identified; a surviving effect at
//      |t| >= 3 = something beyond up-set flux is live and THEORY.md
//      is incomplete.
//
// Writes accretion-study/results-sign.json.

import { writeFileSync } from "node:fs";
import { grow, toSnaps, mulberry } from "./sim-lib.mjs";
import { firstSeenOf, makeGate, makeDistancer } from "../deflation-control/lib.mjs";
import { pagerank, coreNumbers, zStats, greedyMatch } from "../baseline-gauntlet/gauntlet-lib.mjs";
import { upsetSizes } from "../battery-v2/lib.mjs";

const N = 30000;
const SCHEDULE = [5000, 10000, 15000, 20000, 25000, 30000];
const BASELINES = [0, 1, 2, 3], HORIZON = 2, KERNEL_CAP = 300;
const CALIPER = 0.5, SIDE_CAP = 300;
const R = 10;

// one universe -> per-contrast mean pair diffs (gain, upset) for both
// batteries, plus pooled upset-gain correlation
const measure = (r) => {
  const grown = grow(0, N, SCHEDULE, 920000 + r);
  const snaps = toSnaps(grown, SCHEDULE);
  const fsMap = firstSeenOf(snaps);
  const rand = mulberry(925000 + r);
  const acc = {};
  for (const key of ["ER5", "ED5", "ER6", "ED6"]) acc[key] = { gain: [], up: [] };
  let cN = 0, cSumX = 0, cSumY = 0, cSumXX = 0, cSumYY = 0, cSumXY = 0;
  for (const ti of BASELINES) {
    const snap = snaps[ti];
    const fut = snaps[ti + HORIZON];
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
    const gainOf = (c) => {
      const nm = names[compMembers[c][0]];
      return (fut.inDeg.get(nm) ?? 0) - (inDeg.get(nm) ?? 0);
    };
    // pooled flux-law correlation over all candidates at this baseline
    for (const c of globalRows) {
      const x = Math.log1p(upset[c]), y = gainOf(c);
      cN++; cSumX += x; cSumY += y; cSumXX += x * x; cSumYY += y * y; cSumXY += x * y;
    }
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
      for (const [side, bSide] of [["ER", "R"], ["ED", "D"]]) {
        for (const [d, eMembers] of groups.E) {
          const bMembers = groups[bSide].get(d);
          if (!bMembers) continue;
          const eCap = cap([...eMembers]), bCap = cap([...bMembers]);
          const fE = eCap.map(featOf), fB = bCap.map(featOf);
          for (const nFeats of [5, 6]) {
            const pairs = greedyMatch(fE.map((f) => f.slice(0, nFeats)), fB.map((f) => f.slice(0, nFeats)), CALIPER, rand);
            const a2 = acc[side + nFeats];
            for (const [ei, bi] of pairs) {
              a2.gain.push(gainOf(eCap[ei]) - gainOf(bCap[bi]));
              a2.up.push(fE[ei][5] - fB[bi][5]); // z-scored log-upset gap
            }
          }
        }
      }
    }
  }
  const mean = (xs) => xs.reduce((s, v) => s + v, 0) / xs.length;
  const corr = (cSumXY / cN - (cSumX / cN) * (cSumY / cN)) /
    (Math.sqrt(cSumXX / cN - (cSumX / cN) ** 2) * Math.sqrt(cSumYY / cN - (cSumY / cN) ** 2));
  const res = { corr: +corr.toFixed(4) };
  for (const key of ["ER5", "ED5", "ER6", "ED6"]) {
    res[key] = { pairs: acc[key].gain.length,
                 gain: +mean(acc[key].gain).toFixed(4),
                 upGap: +mean(acc[key].up).toFixed(4) };
  }
  return res;
};

const summarize = (xs) => {
  const n = xs.length;
  const mu = xs.reduce((s, v) => s + v, 0) / n;
  const sd = Math.sqrt(xs.reduce((s, v) => s + (v - mu) * (v - mu), 0) / (n - 1));
  return { mu: +mu.toFixed(4), sd: +sd.toFixed(4), t: +(mu / (sd / Math.sqrt(n))).toFixed(2) };
};

const universes = [];
for (let r = 0; r < R; r++) {
  const res = measure(r);
  universes.push(res);
  console.log(`u${r}: corr=${res.corr} | ER5 gain=${res.ER5.gain} upGap=${res.ER5.upGap} | ER6 gain=${res.ER6.gain} upGap=${res.ER6.upGap} | ED5 gain=${res.ED5.gain}`);
}

const out = { universes };
out.S1 = { posCount: universes.filter((u) => u.corr > 0).length,
           verdict: universes.every((u) => u.corr > 0) ? "CONFIRMS" : "FAILS" };
const s2 = summarize(universes.map((u) => u.ER5.upGap));
out.S2 = { ...s2, verdict: s2.mu < 0 && Math.abs(s2.t) >= 3 ? "CONFIRMS" : Math.abs(s2.t) < 2 ? "NULL" : "INDETERMINATE" };
const s3 = summarize(universes.map((u) => u.ER6.gain));
out.S3 = { ...s3, verdict: Math.abs(s3.t) < 2 ? "CONFIRMS (effect fully explained)" : Math.abs(s3.t) >= 3 ? "RESIDUAL EFFECT (theory incomplete)" : "INDETERMINATE" };
out.ED5gain = summarize(universes.map((u) => u.ED5.gain));
out.ED6gain = summarize(universes.map((u) => u.ED6.gain));
console.log(JSON.stringify({ S1: out.S1, S2: out.S2, S3: out.S3 }, null, 1));
writeFileSync("accretion-study/results-sign.json", JSON.stringify(out, null, 1));
console.log("wrote accretion-study/results-sign.json");
