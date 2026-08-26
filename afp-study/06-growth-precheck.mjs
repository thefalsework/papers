// Growth-engine study, blind pre-check.
//
// HYPOTHESIS UNDER DESIGN (registered in 07, not here): entries occupying
// a kernel's Exploitation cell at checkpoint t disproportionately become
// load-bearing by t+k — the residue is where the next foundations come
// from.
//
// BLINDNESS DISCIPLINE: the predictor (cell membership at t) and the
// outcome (dependents gained by t+k) both live in the graph, so this
// study's null carries more weight than the topic study's did. This
// pre-check computes ONLY marginals and feasibility counts:
//   - entry survival t -> t+k (name churn would poison tracking),
//   - evaluable kernel populations per checkpoint,
//   - (kernel, member) pair counts per cell (predictor marginal),
//   - cell x in-degree-bin joint counts (covariate balance, no outcome),
//   - cell x age joint counts (covariate balance, no outcome),
//   - outcome marginal: distribution of dependents gained, NOT joined
//     to any cell,
//   - matched-cell feasibility: # of (t, kernel, degree-stratum) cells
//     containing BOTH E and D members (and E and R), and their weights.
// The cell-x-outcome join — the thing 07 predicts — is never computed.
//
// Checkpoints: t in {2012..2022}, horizon k = 2 checkpoints (4 years),
// outcomes read at {2016..2026}. Degree bins (in-dependents at t):
// 0, 1-2, 3-7, 8+.
//
// Writes afp-study/results-growth-precheck.json.

import { readFileSync, writeFileSync } from "node:fs";

const BASELINES = [2012, 2014, 2016, 2018, 2020, 2022];
const HORIZON = 2; // checkpoints = 4 years
const YEARS = [2006, 2008, 2010, 2012, 2014, 2016, 2018, 2020, 2022, 2024, 2026];
const BIN = (d) => (d === 0 ? 0 : d <= 2 ? 1 : d <= 7 ? 2 : 3);

const load = (y) => JSON.parse(readFileSync(`afp-study/history/${y}.json`, "utf8"));

const bsNew = (w) => new Uint32Array(w);
const bsSet = (b, i) => { b[i >> 5] |= 1 << (i & 31); };
const bsIntersects = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] & b[k]) return true; return false; };
const bsSubset = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] & ~b[k]) return false; return true; };
const bsEq = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] !== b[k]) return false; return true; };
const bsAny = (a) => { for (let k = 0; k < a.length; k++) if (a[k]) return true; return false; };

// cycle-tolerant foundations (unsigned coercion; lesson of 02)
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

// build graph objects per year once
const graphs = new Map();
const graphOf = (y) => {
  if (graphs.has(y)) return graphs.get(y);
  const { entries, edges } = load(y);
  const idx = new Map(entries.map((e, i) => [e, i]));
  const n = entries.length;
  const adjIn = Array.from({ length: n }, () => new Set());
  const dependents = new Map(entries.map((e) => [e, 0])); // direct in-flow per entry name
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

// first checkpoint at which each entry appears (age covariate)
const firstSeen = new Map();
for (const y of YEARS) {
  const { entries } = load(y);
  for (const e of entries) if (!firstSeen.has(e)) firstSeen.set(e, y);
}

const out = { baselines: {}, notes: "marginals and feasibility only; cell-x-outcome never joined" };
for (const t of BASELINES) {
  const tk = YEARS[YEARS.indexOf(t) + HORIZON];
  const g = graphOf(t), gk = graphOf(tk);

  // survival
  const survived = g.entries.filter((e) => gk.idx.has(e)).length;

  // cells per evaluable kernel
  const { n, w, down } = g;
  let evaluable = 0;
  const pairCount = { R: 0, E: 0, D: 0 };
  const cellDegree = { R: [0, 0, 0, 0], E: [0, 0, 0, 0], D: [0, 0, 0, 0] };
  const cellAge = { R: {}, E: {}, D: {} };
  let matchedED = 0, matchedER = 0, weightED = 0, weightER = 0;

  for (let x = 0; x < n; x++) {
    const a = down[x];
    const notA = bsNew(w);
    for (let y = 0; y < n; y++) if (!bsIntersects(down[y], a)) bsSet(notA, y);
    if (!bsAny(notA)) continue;
    const nnA = bsNew(w);
    for (let y = 0; y < n; y++) if (!bsIntersects(down[y], notA)) bsSet(nnA, y);
    if (bsEq(nnA, a)) continue;
    // classify members; only survivors are usable
    const strata = new Map(); // bin -> {E:[], D:[], R:[]}
    let hasR = false, hasE = false, hasD = false;
    for (let y = 0; y < n; y++) {
      if (bsSubset(down[y], a)) continue; // I or apex
      let cell;
      if (bsSubset(down[y], notA)) { cell = "R"; hasR = true; }
      else if (bsSubset(down[y], nnA)) { cell = "E"; hasE = true; }
      else { cell = "D"; hasD = true; }
      const name = g.entries[y];
      if (!gk.idx.has(name)) continue;
      const bin = BIN(g.dependents.get(name) ?? 0);
      pairCount[cell]++;
      cellDegree[cell][bin]++;
      const age = firstSeen.get(name);
      cellAge[cell][age] = (cellAge[cell][age] ?? 0) + 1;
      if (!strata.has(bin)) strata.set(bin, { E: [], D: [], R: [] });
      strata.get(bin)[cell].push(y);
    }
    if (!(hasR && hasE && hasD)) continue;
    evaluable++;
    for (const [, s] of strata) {
      if (s.E.length && s.D.length) { matchedED++; weightED += Math.min(s.E.length, s.D.length); }
      if (s.E.length && s.R.length) { matchedER++; weightER += Math.min(s.E.length, s.R.length); }
    }
  }

  // outcome marginal (never joined to cells): dependents gained by survivors
  const gains = g.entries.filter((e) => gk.idx.has(e))
    .map((e) => (gk.dependents.get(e) ?? 0) - (g.dependents.get(e) ?? 0));
  gains.sort((a, b) => a - b);
  const q = (p) => gains[Math.min(gains.length - 1, Math.floor(p * gains.length))];

  out.baselines[t] = {
    horizonYear: tk, entries: g.n, survived, survivalFrac: +(survived / g.n).toFixed(3),
    evaluableKernels: evaluable,
    survivorPairsPerCell: pairCount,
    cellDegreeBins: cellDegree,
    cellAge,
    matchedCells: { ED: matchedED, ER: matchedER, weightED, weightER },
    gainMarginal: { median: q(0.5), p75: q(0.75), p90: q(0.9), max: gains[gains.length - 1], fracPositive: +(gains.filter((x) => x > 0).length / gains.length).toFixed(3) },
  };
  const b = out.baselines[t];
  console.log(
    `${t}->${tk}: entries=${b.entries} surv=${b.survivalFrac} evalKernels=${b.evaluableKernels}  ` +
    `pairs E/D/R=${pairCount.E}/${pairCount.D}/${pairCount.R}  ` +
    `matched ED=${matchedED}(w${weightED}) ER=${matchedER}(w${weightER})  ` +
    `gain median=${b.gainMarginal.median} p90=${b.gainMarginal.p90} frac+=${b.gainMarginal.fracPositive}`
  );
}

writeFileSync("afp-study/results-growth-precheck.json", JSON.stringify(out, null, 1));
console.log("\nwritten: afp-study/results-growth-precheck.json (marginals and feasibility only)");
