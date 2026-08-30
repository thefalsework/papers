// Referee study, blind structural census (pre-check for the registered
// RF2 run in 03).
//
// BLINDNESS DISCIPLINE (as mathlib-study/17): this script computes, per
// checkpoint, graph dimensions, cycle structure, and the evaluable-kernel
// population (ordinary kernels with E, D, R all nonempty — occupancy
// COUNTS only), and, per baseline, member survival to horizon and
// stratum feasibility. NO growth contrast is computed anywhere: nothing
// here can leak the E-vs-D alignment that 03 predicts.
//
// Corpus: the Isabelle distribution's theory-import graphs extracted by
// 01 (isabelle-study/history/<year>.json).
//
// Writes isabelle-study/results-census.json.

import { readFileSync, writeFileSync } from "node:fs";

const YEARS = [2006, 2008, 2010, 2012, 2014, 2016, 2018, 2020, 2022, 2024, 2026];
const BASELINES = [0, 1, 2, 3, 4, 5, 6, 7, 8]; // 2006..2022, horizon +2
const HORIZON = 2;
const BIN = (d) => (d === 0 ? 0 : d <= 2 ? 1 : d <= 7 ? 2 : 3);

// ---- Tarjan SCC (as software-study/04) ----
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

const buildSnap = (names, edges) => {
  const n = names.length;
  const adjOut = Array.from({ length: n }, () => []);
  const inDeg = new Map(names.map((nm) => [nm, 0]));
  for (const [a, b] of edges) {
    adjOut[a].push(b);
    inDeg.set(names[b], inDeg.get(names[b]) + 1);
  }
  const { comp, nComp } = sccOf(n, adjOut);
  const compMembers = Array.from({ length: nComp }, () => []);
  for (let i = 0; i < n; i++) compMembers[comp[i]].push(i);
  const eSet = new Set();
  for (const [a, b] of edges) if (comp[a] !== comp[b]) eSet.add(comp[a] * 2000000 + comp[b]);
  const cIn = Array.from({ length: nComp }, () => []);
  const cOut = Array.from({ length: nComp }, () => []);
  for (const x of eSet) {
    const a = Math.floor(x / 2000000), b = x % 2000000;
    cIn[a].push(b); cOut[b].push(a);
  }
  return { names, n, nEdges: edges.length, inDeg, comp, nComp, cIn, cOut, compMembers };
};

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
  return (a) => {
    const st = stamp++;
    closure([a], cIn, mDown, st);
    const downMembers = [];
    for (let i = 0; i < nComp; i++) if (mDown[i] === st) downMembers.push(i);
    closure(downMembers, cOut, mUp1, st);
    const Nmembers = [];
    for (let i = 0; i < nComp; i++) if (mUp1[i] !== st) Nmembers.push(i);
    if (Nmembers.length === 0) return null;
    closure(Nmembers, cOut, mUp2, st);
    let hasE = false, hasD = false;
    for (let i = 0; i < nComp && !(hasE && hasD); i++) {
      if (mDown[i] === st || mUp1[i] !== st) continue;
      if (mUp2[i] !== st) hasE = true; else hasD = true;
    }
    if (!hasE || !hasD) return null;
    return {
      cellOf: (i) => {
        if (mDown[i] === st) return "I";
        if (mUp1[i] !== st) return "R";
        return mUp2[i] !== st ? "E" : "D";
      },
    };
  };
};

const snaps = YEARS.map((y) => {
  const raw = JSON.parse(readFileSync(`isabelle-study/history/${y}.json`, "utf8"));
  return { year: y, parse: raw.parse, snap: buildSnap(raw.nodes, raw.edges) };
});

const firstSeen = new Map();
snaps.forEach(({ snap }, yi) => {
  for (const nm of snap.names) if (!firstSeen.has(nm)) firstSeen.set(nm, yi);
});

const out = { perYear: [], perBaseline: [] };
for (const { year, parse, snap } of snaps) {
  const gate = makeGate(snap);
  let evaluable = 0;
  for (let a = 0; a < snap.nComp; a++) if (gate(a)) evaluable++;
  let maxScc = 0, nontrivial = 0;
  for (const m of snap.compMembers) {
    if (m.length > maxScc) maxScc = m.length;
    if (m.length > 1) nontrivial++;
  }
  out.perYear.push({
    year, nodes: snap.n, edges: snap.nEdges, comps: snap.nComp,
    nontrivialSccs: nontrivial, maxScc, evaluableKernels: evaluable,
    ambiguousRate: +(parse.ambiguous / Math.max(1, parse.tokens)).toFixed(3),
  });
  console.log(
    `${year}: n=${snap.n} e=${snap.nEdges} sccMax=${maxScc} evaluable=${evaluable} ` +
    `ambig=${(100 * parse.ambiguous / Math.max(1, parse.tokens)).toFixed(1)}%`,
  );
}

for (const ti of BASELINES) {
  const { snap } = snaps[ti];
  const fut = snaps[ti + HORIZON].snap;
  let alive = 0;
  for (const nm of snap.names) if (fut.inDeg.has(nm)) alive++;
  // stratum feasibility: distinct (bin x firstSeen) keys with >= 2 members
  const strat = new Map();
  for (const nm of snap.names) {
    const key = `${BIN(snap.inDeg.get(nm) ?? 0)}|${firstSeen.get(nm)}`;
    strat.set(key, (strat.get(key) ?? 0) + 1);
  }
  let feasible = 0;
  for (const [, c] of strat) if (c >= 2) feasible++;
  out.perBaseline.push({
    baseline: YEARS[ti], horizon: YEARS[ti + HORIZON],
    nodes: snap.n, aliveAtHorizon: alive,
    survival: +(alive / snap.n).toFixed(3),
    strataTotal: strat.size, strataFeasible: feasible,
  });
  console.log(
    `baseline ${YEARS[ti]} -> ${YEARS[ti + HORIZON]}: survival=${(100 * alive / snap.n).toFixed(1)}% ` +
    `strata=${strat.size} (feasible ${feasible})`,
  );
}

writeFileSync("isabelle-study/results-census.json", JSON.stringify(out, null, 1));
console.log("wrote isabelle-study/results-census.json");
