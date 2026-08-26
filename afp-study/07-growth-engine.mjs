// Growth-engine study: is the Exploitation cell where future foundations
// come from?
//
// PRE-REGISTRATION (written before first run, 2026-08-26; committed with
// the blind pre-check 06, which computed marginals and feasibility only —
// the cell-x-outcome join scored below was never touched).
//
// THE HYPOTHESIS, and where it comes from. The one dictionary gloss that
// survived every registered test ("Exploitation is on-territory",
// Mathlib 16/16 + AFP at the 100th percentile) is static: it says where
// residue-miners SIT. The speculative extension proposed 2026-08-26: if
// a commitment's undigested residue accumulates near it and is worked by
// neighbors, the E cell should be where the next kernels come from —
// today's residue-miners become tomorrow's foundations. This is the
// program's first DYNAMICAL prediction.
//
// THE CONFOUND THIS DESIGN EXISTS TO KILL. Unlike the topic study,
// predictor (cell at t) and outcome (dependents gained by t+k) live in
// the same graph, and preferential attachment is a live alternative:
// E-membership requires dense entanglement, entangled entries are
// central, central entries accumulate dependents regardless of any cell
// story. Therefore: WITHIN-KERNEL, DEGREE-MATCHED contrasts only. For
// each (baseline t, evaluable kernel, in-degree stratum) cell containing
// both E and D members, the unit is the difference of mean dependent
// gains. The within-kernel contrast holds the neighborhood fixed; the
// stratum holds centrality fixed; what remains is the algebraic position.
//
// DESIGN (all constants fixed by pre-check 06):
//   Baselines t in {2012..2022}, horizon +2 checkpoints (4 years).
//   Survivors only (pre-check: survival = 1.000 everywhere).
//   Degree bins at t: 0, 1-2, 3-7, 8+ (in-dependents).
//   Statistic: G_ED = sum over matched cells of
//     min(nE, nD) * [meanGain(E) - meanGain(D)] / sum of min(nE, nD),
//     pooled over all six baselines (per-baseline values reported).
//   Null: within each matched cell, permute the E/D labels among that
//     cell's E-and-D members (counts preserved); recompute G_ED; 1000
//     permutations, mulberry32 seed 20260826951, one stream. Under H0
//     (position carries no growth information beyond neighborhood and
//     degree) the labels are exchangeable within cells.
//
// PREDICTIONS:
//   GP1 (growth engine, primary): G_ED > 0 AND above the 95th percentile
//       of its permutation null.
//   GP2 (secondary, scored separately): same construction for E vs R
//       (G_ER, own permutation stream over E/R matched cells).
//   COVARIATE GUARD, fixed in advance: mean entry age (first-seen year)
//       of E vs D members within matched cells is reported; if GP1 holds
//       AND the pooled age gap exceeds 2 years, an age-stratified
//       robustness pass is REQUIRED before the finding ships anywhere
//       outward (it does not retroactively unscore GP1; it gates the
//       graduation, as the CA size control gated the still-life lead).
//
// INTERPRETATION, FIXED IN ADVANCE:
//   GP1 holds (and guard passes) -> the four-position partition acquires
//     a dynamics: the non-classical cell predicts becoming load-bearing.
//     Outward documents may state it with the design named.
//   GP1 fails -> the growth-engine reading dies at the price of an
//     afternoon, before reaching any outward document. The static
//     on-territory finding is untouched either way.
//   GP2 is color: E vs R compares against fully-independent lineages
//     (expected weaker/noisier; no primary claim rests on it).
//
// Output: afp-study/results-growth-engine.json (raw, committed).

import { readFileSync, writeFileSync } from "node:fs";

const BASELINES = [2012, 2014, 2016, 2018, 2020, 2022];
const HORIZON = 2;
const YEARS = [2006, 2008, 2010, 2012, 2014, 2016, 2018, 2020, 2022, 2024, 2026];
const BIN = (d) => (d === 0 ? 0 : d <= 2 ? 1 : d <= 7 ? 2 : 3);
const PERMS = 1000;
const SEED = 20260826951;

let rngState = SEED;
const rand = () => {
  rngState |= 0; rngState = (rngState + 0x6d2b79f5) | 0;
  let t = Math.imul(rngState ^ (rngState >>> 15), 1 | rngState);
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};

const load = (y) => JSON.parse(readFileSync(`afp-study/history/${y}.json`, "utf8"));

const bsNew = (w) => new Uint32Array(w);
const bsSet = (b, i) => { b[i >> 5] |= 1 << (i & 31); };
const bsIntersects = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] & b[k]) return true; return false; };
const bsSubset = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] & ~b[k]) return false; return true; };
const bsEq = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] !== b[k]) return false; return true; };
const bsAny = (a) => { for (let k = 0; k < a.length; k++) if (a[k]) return true; return false; };

const downOf = (n, adjIn) => {
  const w = (n + 31) >> 5;
  const down = Array.from({ length: n }, (_, i) => { const b = bsNew(w); bsSet(b, i); return b; });
  let changed = true;
  while (changed) {
    changed = false;
    for (let i = 0; i < n; i++)
      for (const j of adjIn[i])
        for (let k = 0; k < w; k++) {
          const nv = (down[i][k] | down[j][k]) >>> 0;
          if (nv !== down[i][k]) { down[i][k] = nv; changed = true; }
        }
  }
  return down;
};

const graphs = new Map();
const graphOf = (y) => {
  if (graphs.has(y)) return graphs.get(y);
  const { entries, edges } = load(y);
  const idx = new Map(entries.map((e, i) => [e, i]));
  const n = entries.length;
  const adjIn = Array.from({ length: n }, () => new Set());
  const dependents = new Map(entries.map((e) => [e, 0]));
  for (const pair of edges) {
    const [a, b] = pair.split(">");
    adjIn[idx.get(a)].add(idx.get(b));
    dependents.set(b, (dependents.get(b) ?? 0) + 1);
  }
  const down = downOf(n, adjIn);
  const g = { entries, idx, n, w: (n + 31) >> 5, down, dependents };
  graphs.set(y, g);
  return g;
};

const firstSeen = new Map();
for (const y of YEARS) {
  const { entries } = load(y);
  for (const e of entries) if (!firstSeen.has(e)) firstSeen.set(e, y);
}

// ---- collect matched cells ----
// cellsED / cellsER: arrays of { gains: number[], nA, nB } where members
// [0..nA) are the A-side (E) and [nA..nA+nB) the B-side (D or R).
const cellsED = [], cellsER = [];
const perBaseline = {};
let ageSumE_ED = 0, ageSumD_ED = 0, ageCntE_ED = 0, ageCntD_ED = 0;

for (const t of BASELINES) {
  const tk = YEARS[YEARS.indexOf(t) + HORIZON];
  const g = graphOf(t), gk = graphOf(tk);
  const { n, w, down } = g;
  const gain = (y) => (gk.dependents.get(g.entries[y]) ?? 0) - (g.dependents.get(g.entries[y]) ?? 0);
  let cellsHereED = 0, cellsHereER = 0;

  for (let x = 0; x < n; x++) {
    const a = down[x];
    const notA = bsNew(w);
    for (let y = 0; y < n; y++) if (!bsIntersects(down[y], a)) bsSet(notA, y);
    if (!bsAny(notA)) continue;
    const nnA = bsNew(w);
    for (let y = 0; y < n; y++) if (!bsIntersects(down[y], notA)) bsSet(nnA, y);
    if (bsEq(nnA, a)) continue;
    const strata = new Map();
    let hasR = false, hasE = false, hasD = false;
    for (let y = 0; y < n; y++) {
      if (bsSubset(down[y], a)) continue;
      let cell;
      if (bsSubset(down[y], notA)) { cell = "R"; hasR = true; }
      else if (bsSubset(down[y], nnA)) { cell = "E"; hasE = true; }
      else { cell = "D"; hasD = true; }
      const name = g.entries[y];
      if (!gk.idx.has(name)) continue;
      const bin = BIN(g.dependents.get(name) ?? 0);
      if (!strata.has(bin)) strata.set(bin, { E: [], D: [], R: [] });
      strata.get(bin)[cell].push(y);
    }
    if (!(hasR && hasE && hasD)) continue;
    for (const [, s] of strata) {
      if (s.E.length && s.D.length) {
        cellsED.push({
          gains: [...s.E.map(gain), ...s.D.map(gain)],
          nA: s.E.length, nB: s.D.length,
        });
        cellsHereED++;
        for (const y of s.E) { ageSumE_ED += firstSeen.get(g.entries[y]); ageCntE_ED++; }
        for (const y of s.D) { ageSumD_ED += firstSeen.get(g.entries[y]); ageCntD_ED++; }
      }
      if (s.E.length && s.R.length) {
        cellsER.push({
          gains: [...s.E.map(gain), ...s.R.map(gain)],
          nA: s.E.length, nB: s.R.length,
        });
        cellsHereER++;
      }
    }
  }
  perBaseline[t] = { horizonYear: tk, matchedED: cellsHereED, matchedER: cellsHereER };
  console.log(`${t}->${tk}: matched cells ED=${cellsHereED} ER=${cellsHereER}`);
}

// ---- statistic and permutation ----
const statOf = (cells, labelOf) => {
  // labelOf(cell, memberIndex) -> true if counted on the A side
  let num = 0, den = 0;
  for (const c of cells) {
    const wgt = Math.min(c.nA, c.nB);
    let sA = 0, cA = 0, sB = 0, cB = 0;
    for (let i = 0; i < c.gains.length; i++) {
      if (labelOf(c, i)) { sA += c.gains[i]; cA++; }
      else { sB += c.gains[i]; cB++; }
    }
    if (cA === 0 || cB === 0) continue; // cannot happen for identity labels
    num += wgt * (sA / cA - sB / cB);
    den += wgt;
  }
  return num / den;
};
const identity = (c, i) => i < c.nA;

const permute = (cells) => {
  // per cell: choose nA members uniformly to be the A side
  return (c, i, permSets) => permSets.get(c).has(i);
};

const runTest = (cells) => {
  const obs = statOf(cells, identity);
  const nulls = [];
  for (let p = 0; p < PERMS; p++) {
    const permSets = new Map();
    for (const c of cells) {
      const m = c.gains.length;
      const pick = new Set();
      // partial Fisher-Yates: choose nA of m
      const arr = [...Array(m).keys()];
      for (let i = 0; i < c.nA; i++) {
        const j = i + Math.floor(rand() * (m - i));
        [arr[i], arr[j]] = [arr[j], arr[i]];
        pick.add(arr[i]);
      }
      permSets.set(c, pick);
    }
    nulls.push(statOf(cells, (c, i) => permSets.get(c).has(i)));
  }
  const sorted = [...nulls].sort((a, b) => a - b);
  const below = sorted.filter((x) => x < obs).length;
  const eq = sorted.filter((x) => x === obs).length;
  return {
    obs,
    p5: sorted[Math.floor(PERMS * 0.05)],
    p95: sorted[Math.floor(PERMS * 0.95)],
    obsPctile: ((below + eq / 2) / PERMS) * 100,
  };
};

const ed = runTest(cellsED);
const er = runTest(cellsER);
const ageGapED = ageSumE_ED / ageCntE_ED - ageSumD_ED / ageCntD_ED;

const gp1 = { ...ed, holds: ed.obs > 0 && ed.obsPctile > 95 };
const gp2 = { ...er, holds: er.obs > 0 && er.obsPctile > 95 };

console.log(
  `\nGP1 (E vs D, growth): G_ED=${ed.obs.toFixed(4)}  null[5,95]=[${ed.p5.toFixed(4)}, ${ed.p95.toFixed(4)}]  pctile=${ed.obsPctile.toFixed(1)}  -> ${gp1.holds ? "HOLDS" : "FAILS"}` +
  `\nGP2 (E vs R, growth): G_ER=${er.obs.toFixed(4)}  null[5,95]=[${er.p5.toFixed(4)}, ${er.p95.toFixed(4)}]  pctile=${er.obsPctile.toFixed(1)}  -> ${gp2.holds ? "holds" : "fails"} (secondary)` +
  `\nCovariate guard: mean first-seen year, E minus D in matched cells = ${ageGapED.toFixed(2)} years ` +
  `(robustness pass required before shipping iff GP1 holds and |gap| > 2)`
);

writeFileSync("afp-study/results-growth-engine.json", JSON.stringify({
  seed: SEED, perms: PERMS, perBaseline,
  matchedCells: { ED: cellsED.length, ER: cellsER.length },
  GP1: gp1, GP2: gp2, ageGapED,
}, null, 1));
console.log("\nwritten: afp-study/results-growth-engine.json");
