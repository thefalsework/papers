// Software pair, phase 3b: the GROWTH quadrants (registered).
//
// Protocol: software-study/PROTOCOL.md v1.0 §4, bottom row of the
// quadrant table. Gates passed (results-gates.json). Committed before
// first run per house rules.
//
// DESIGN inherited from mathlib-study/18 (which inherited afp-study/07):
// within-kernel, degree- AND age-matched E-vs-D contrast against a
// within-cell label-permutation null.
//   Checkpoints: 2016..2026 biennial. Baselines t in {2016, 2018, 2020,
//     2022}; horizon t+2 checkpoints = 4 years (the AFP horizon).
//   Kernels: evaluable principal kernels (ordinary; R, E, D nonempty) on
//     the SCC condensation at baseline.
//   Members: condensation components classified into cells relative to
//     the kernel (I = down(a); R = no path into down(a); E = inside
//     double-negation territory beyond down(a); D = straddling). Only
//     singleton components carry names and outcomes; non-singletons are
//     skipped and counted (largest SCC anywhere is 5 nodes).
//   Outcome: gain = dependents(name, t+2) - dependents(name, t), raw
//     in-degree by name; members absent at t+2 are excluded (death;
//     renames count as death+birth, as on Mathlib).
//   Strata: degree bin (0 / 1-2 / 3-7 / 8+) x EXACT first-seen
//     checkpoint index (age matched away, as mathlib-study/18).
//   Statistic: G_ED = weighted mean over (kernel x stratum) cells with
//     both sides present of [meanGain(E) - meanGain(D)], weight
//     min(nE, nD); G_ER identically. Pooled per corpus.
//   Null: within-cell label permutation, 1000 draws, one seeded stream.
//
// SCALE ADAPTATIONS for the museum (declared in advance; both are
// label-blind and seeded, so they cannot bias the contrast):
//   1. Kernel sampling: crates checkpoints have 5k-285k condensation
//      nodes; instead of all evaluable kernels (Go side: all), the crates
//      side samples uniformly until 300 evaluable kernels are found per
//      baseline (or the scan exhausts).
//   2. Cell-side subsampling: a crates kernel's cells can span most of
//      the registry; each (kernel, stratum, cell-side) list is capped at
//      500 members by seeded uniform subsample BEFORE the statistic or
//      any permutation is computed. The weighted mean-difference
//      estimator remains unbiased under uniform within-side subsampling,
//      and within-cell exchangeability under the null is preserved.
//
// REGISTERED PREDICTIONS (protocol §4, thresholds inherited):
//   Q1-GROWTH (garden): on Go, Exploitation grows — G_ED > 0 at or above
//     the 97.5th percentile of its null.
//   Q2-GROWTH (museum): on crates, Distribution grows — G_ED < 0 at or
//     below the 2.5th percentile of its null.
//   Secondary (descriptive, MG2 convention): E > R on both corpora
//     (G_ER > 0, >= 95th percentile). Color either way; scores nothing.
//
// FAILURE SEMANTICS (protocol §5): both growth quadrants as predicted ->
// the growth fingerprint of the axis counts. Diagonal outcomes (garden
// grows through D, or museum through E) are failure by reversal, full
// prominence. The operator's prior, per the protocol: 0 for 9.
//
// Writes software-study/results-growth.json.

import { readFileSync, writeFileSync } from "node:fs";

const YEARS = [2016, 2018, 2020, 2022, 2024, 2026];
const BASELINES = [0, 1, 2, 3];
const HORIZON = 2;
const BIN = (d) => (d === 0 ? 0 : d <= 2 ? 1 : d <= 7 ? 2 : 3);
const PERMS = 1000;
const SEED = 20260827472;
const CRATES_KERNELS = 300, SIDE_CAP = 500;

let rngState = SEED;
const rand = () => {
  rngState |= 0; rngState = (rngState + 0x6d2b79f5) | 0;
  let t = Math.imul(rngState ^ (rngState >>> 15), 1 | rngState);
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};

// ---- load snapshot: names, raw in-degree by name, condensation ----
const sccOf = (n, adjOut) => {
  const idx = new Int32Array(n).fill(-1), low = new Int32Array(n),
    onStk = new Uint8Array(n), comp = new Int32Array(n).fill(-1);
  let counter = 0, nComp = 0;
  const stk = [];
  for (let s = 0; s < n; s++) {
    if (idx[s] !== -1) continue;
    const call = [[s, 0]];
    while (call.length) {
      const fr = call[call.length - 1], v = fr[0];
      if (fr[1] === 0) { idx[v] = low[v] = counter++; stk.push(v); onStk[v] = 1; }
      let advanced = false;
      const nbrs = adjOut[v];
      while (fr[1] < nbrs.length) {
        const u = nbrs[fr[1]++];
        if (idx[u] === -1) { call.push([u, 0]); advanced = true; break; }
        if (onStk[u]) low[v] = Math.min(low[v], idx[u]);
      }
      if (advanced) continue;
      if (low[v] === idx[v]) {
        for (;;) { const u = stk.pop(); onStk[u] = 0; comp[u] = nComp; if (u === v) break; }
        nComp++;
      }
      call.pop();
      if (call.length) { const p = call[call.length - 1][0]; low[p] = Math.min(low[p], low[v]); }
    }
  }
  return { comp, nComp };
};

const snapshots = new Map();
const loadSnap = (corpus, yi) => {
  const key = corpus + yi;
  if (snapshots.has(key)) return snapshots.get(key);
  const raw = JSON.parse(readFileSync(`software-study/history/${corpus}-${YEARS[yi]}.json`, "utf8"));
  const n = raw.nodes.length;
  const adjOut = Array.from({ length: n }, () => []);
  const inDeg = new Map(raw.nodes.map((nm) => [nm, 0]));
  for (const [a, b] of raw.edges) {
    adjOut[a].push(b);
    inDeg.set(raw.nodes[b], inDeg.get(raw.nodes[b]) + 1);
  }
  const { comp, nComp } = sccOf(n, adjOut);
  const compMembers = Array.from({ length: nComp }, () => []);
  for (let i = 0; i < n; i++) compMembers[comp[i]].push(i);
  const eSet = new Set();
  for (const [a, b] of raw.edges) if (comp[a] !== comp[b]) eSet.add(comp[a] * 2000000 + comp[b]);
  const cIn = Array.from({ length: nComp }, () => []);
  const cOut = Array.from({ length: nComp }, () => []);
  for (const x of eSet) {
    const a = Math.floor(x / 2000000), b = x % 2000000;
    cIn[a].push(b); cOut[b].push(a);
  }
  const snap = { names: raw.nodes, n, inDeg, nComp, cIn, cOut, compMembers };
  snapshots.set(key, snap);
  return snap;
};

// first-seen checkpoint index by name
const firstSeen = { go: new Map(), crates: new Map() };
for (const corpus of ["go", "crates"])
  for (let yi = 0; yi < YEARS.length; yi++) {
    const raw = JSON.parse(readFileSync(`software-study/history/${corpus}-${YEARS[yi]}.json`, "utf8"));
    for (const nm of raw.nodes) if (!firstSeen[corpus].has(nm)) firstSeen[corpus].set(nm, yi);
  }

// ---- per-kernel cell classification on the condensation (stamp BFS) ----
const makeGate = (snap) => {
  const { nComp, cIn, cOut } = snap;
  const mDown = new Int32Array(nComp).fill(-1);
  const mUp1 = new Int32Array(nComp).fill(-1);
  const mUp2 = new Int32Array(nComp).fill(-1);
  const q = new Int32Array(nComp);
  const closure = (seeds, adj, mark, st) => {
    let head = 0, tail = 0;
    for (const s of seeds) if (mark[s] !== st) { mark[s] = st; q[tail++] = s; }
    while (head < tail) {
      const v = q[head++];
      for (const u of adj[v]) if (mark[u] !== st) { mark[u] = st; q[tail++] = u; }
    }
  };
  let stamp = 0;
  // returns null if not evaluable; else { cellOf: (comp)-> 'I'|'R'|'E'|'D' via marks }
  return (a) => {
    const st = stamp++;
    closure([a], cIn, mDown, st);
    const downMembers = [];
    for (let i = 0; i < nComp; i++) if (mDown[i] === st) downMembers.push(i);
    closure(downMembers, cOut, mUp1, st);
    const Nmembers = [];
    for (let i = 0; i < nComp; i++) if (mUp1[i] !== st) Nmembers.push(i);
    if (Nmembers.length === 0) return null; // dense
    closure(Nmembers, cOut, mUp2, st);
    let hasE = false, hasD = false;
    for (let i = 0; i < nComp && !(hasE && hasD); i++) {
      if (mDown[i] === st || mUp1[i] !== st) continue;
      if (mUp2[i] !== st) hasE = true; else hasD = true;
    }
    if (!hasE) return null; // regular
    if (!hasD) return null; // not evaluable (D empty)
    return {
      cellOf: (i) => {
        if (mDown[i] === st) return "I";
        if (mUp1[i] !== st) return "R";
        return mUp2[i] !== st ? "E" : "D";
      },
    };
  };
};

// ---- collect matched cells per corpus ----
const collect = (corpus) => {
  const cellsED = [], cellsER = [];
  let kernelsUsed = 0, nonSingletonSkipped = 0;
  for (const ti of BASELINES) {
    const snap = loadSnap(corpus, ti);
    const fut = loadSnap(corpus, ti + HORIZON);
    const gate = makeGate(snap);
    const { nComp, compMembers, names, inDeg } = snap;
    // kernel list: Go = all comps; crates = seeded uniform scan until quota
    let kernelIds;
    if (corpus === "go") kernelIds = Array.from({ length: nComp }, (_, i) => i);
    else {
      kernelIds = [];
      const perm = Uint32Array.from({ length: nComp }, (_, i) => i);
      for (let i = 0; i < nComp; i++) {
        const j = i + Math.floor(rand() * (nComp - i));
        const t = perm[i]; perm[i] = perm[j]; perm[j] = t;
      }
      kernelIds = [...perm];
    }
    let used = 0;
    for (const a of kernelIds) {
      if (corpus === "crates" && used >= CRATES_KERNELS) break;
      const g = gate(a);
      if (!g) continue;
      used++; kernelsUsed++;
      // strata: "bin|firstSeen" -> { E: [gains], D: [...], R: [...] }
      const strata = new Map();
      for (let c = 0; c < nComp; c++) {
        const cell = g.cellOf(c);
        if (cell === "I") continue;
        const members = compMembers[c];
        if (members.length > 1) { nonSingletonSkipped++; continue; }
        const nm = names[members[0]];
        if (!fut.inDeg.has(nm)) continue; // dead by horizon
        const d0 = inDeg.get(nm) ?? 0;
        const key = `${BIN(d0)}|${firstSeen[corpus].get(nm)}`;
        if (!strata.has(key)) strata.set(key, { E: [], D: [], R: [] });
        strata.get(key)[cell].push((fut.inDeg.get(nm) ?? 0) - d0);
      }
      for (const [, s] of strata) {
        const cap = (arr) => {
          if (arr.length <= SIDE_CAP) return arr;
          // seeded uniform subsample (partial Fisher-Yates)
          for (let i = 0; i < SIDE_CAP; i++) {
            const j = i + Math.floor(rand() * (arr.length - i));
            const t = arr[i]; arr[i] = arr[j]; arr[j] = t;
          }
          return arr.slice(0, SIDE_CAP);
        };
        const E = cap(s.E), D = cap(s.D), R = cap(s.R);
        if (E.length && D.length)
          cellsED.push({ gains: Float64Array.from([...E, ...D]), nA: E.length });
        if (E.length && R.length)
          cellsER.push({ gains: Float64Array.from([...E, ...R]), nA: E.length });
      }
    }
  }
  return { cellsED, cellsER, kernelsUsed, nonSingletonSkipped };
};

// ---- statistic + permutation (verbatim shape from mathlib-study/18) ----
const statIdentity = (cells) => {
  let num = 0, den = 0;
  for (const c of cells) {
    const m = c.gains.length, nA = c.nA, nB = m - nA;
    const wgt = Math.min(nA, nB);
    let sA = 0;
    for (let i = 0; i < nA; i++) sA += c.gains[i];
    let sT = sA;
    for (let i = nA; i < m; i++) sT += c.gains[i];
    num += wgt * (sA / nA - (sT - sA) / nB);
    den += wgt;
  }
  return num / den;
};
const statPermuted = (cells) => {
  let num = 0, den = 0;
  for (const c of cells) {
    const m = c.gains.length, nA = c.nA, nB = m - nA;
    const wgt = Math.min(nA, nB);
    const idx = c.scratch ?? (c.scratch = Uint32Array.from({ length: m }, (_, i) => i));
    for (let i = 0; i < nA; i++) {
      const j = i + Math.floor(rand() * (m - i));
      const t = idx[i]; idx[i] = idx[j]; idx[j] = t;
    }
    let sA = 0;
    for (let i = 0; i < nA; i++) sA += c.gains[idx[i]];
    let sT = 0;
    for (let i = 0; i < m; i++) sT += c.gains[i];
    num += wgt * (sA / nA - (sT - sA) / nB);
    den += wgt;
  }
  return num / den;
};
const runTest = (cells) => {
  const obs = statIdentity(cells);
  const nulls = [];
  for (let p = 0; p < PERMS; p++) nulls.push(statPermuted(cells));
  const sorted = [...nulls].sort((a, b) => a - b);
  const below = sorted.filter((x) => x < obs).length;
  const eq = sorted.filter((x) => x === obs).length;
  return {
    obs: +obs.toFixed(4),
    null25: +sorted[Math.floor(PERMS * 0.025)].toFixed(4),
    null975: +sorted[Math.floor(PERMS * 0.975)].toFixed(4),
    obsPctile: +(((below + eq / 2) / PERMS) * 100).toFixed(1),
  };
};

// ---- run ----
const out = { protocol: "software-study/PROTOCOL.md v1.0 §4 (growth row)", seed: SEED, ranAt: new Date().toISOString() };
for (const corpus of ["go", "crates"]) {
  console.log(`== ${corpus} ==`);
  const { cellsED, cellsER, kernelsUsed, nonSingletonSkipped } = collect(corpus);
  console.log(`kernels=${kernelsUsed} cellsED=${cellsED.length} cellsER=${cellsER.length}`);
  const ed = runTest(cellsED), er = runTest(cellsER);
  out[corpus] = {
    kernelsUsed, matchedCells: { ED: cellsED.length, ER: cellsER.length }, nonSingletonSkipped,
    G_ED: ed, G_ER: er,
  };
  console.log(`G_ED=${ed.obs} null[2.5,97.5]=[${ed.null25},${ed.null975}] pctile=${ed.obsPctile}`);
  console.log(`G_ER=${er.obs} pctile=${er.obsPctile}`);
}
const q1g = out.go.G_ED.obs > 0 && out.go.G_ED.obsPctile >= 97.5;
const q2g = out.crates.G_ED.obs < 0 && out.crates.G_ED.obsPctile <= 2.5;
out.verdicts = {
  "Q1-GROWTH (Go: E grows)": q1g ? "HOLDS" : "FAILS",
  "Q2-GROWTH (crates: D grows)": q2g ? "HOLDS" : "FAILS",
  "secondary E>R go": out.go.G_ER.obs > 0 && out.go.G_ER.obsPctile >= 95 ? "holds" : "fails",
  "secondary E>R crates": out.crates.G_ER.obs > 0 && out.crates.G_ER.obsPctile >= 95 ? "holds" : "fails",
  growthFingerprint: q1g && q2g ? "AS PREDICTED" : "NOT AS PREDICTED",
};
writeFileSync("software-study/results-growth.json", JSON.stringify(out, null, 1));
console.log(JSON.stringify(out.verdicts, null, 1));
