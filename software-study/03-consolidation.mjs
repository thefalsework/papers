// Software pair, phase 3a: the CONSOLIDATION quadrants (registered).
//
// Protocol: software-study/PROTOCOL.md v1.0 §4, top row of the quadrant
// table. Gates passed (results-gates.json, 2026-08-27: MC1 ratio 3.13,
// MC2 6/6 both corpora), so this scoring is licensed.
//
// PRE-REGISTRATION (this header is written before the script's first run;
// committed before execution per house rules).
//
// Design inherited from mathlib-study/06 (arrows) and 08 (per-snapshot
// nulls), as the protocol requires:
//   - Per corpus, per checkpoint (2016..2026 biennial): build the SCC
//     condensation of the import graph; CONE PICK RULE as in the prior
//     studies — principal down-sets with foundation size <= 18, top 5 by
//     foundation size, ties broken by node name (deterministic).
//   - Per cone: for every principal kernel, enumerate ALL 2^n subspace
//     nuclei (the complete observer census of the down-set algebra
//     [C: Simmons 1980]); record ambient ordinariness, latency (not
//     ordinary at identity, aperture nonempty), and aperture fraction.
//   - Per checkpoint: mean over the five cones of latentFrac and
//     meanApFrac (the two registered metrics; ordIdFrac and maxApFrac
//     reported descriptively).
//   - Arrows: Spearman rank correlation of each metric against checkpoint
//     index, over the six checkpoints.
//   - Nulls: 30 degree-preserving rewires per checkpoint (double-edge
//     swaps respecting a fixed topological order of the condensation, as
//     mathlib-study/03 — in/out-degree sequences exact, acyclicity
//     preserved), identical pipeline including the pick rule; observed
//     metrics scored as percentiles within the 30 nulls, per checkpoint.
//
// REGISTERED PREDICTIONS (thresholds inherited unchanged from the
// protocol and the mathlib originals):
//   Q1-CONS (garden): on Go, apertures NARROW — Spearman(meanApFrac) <=
//     -0.6 AND the final checkpoint's observed meanApFrac sits at or
//     below the 5th percentile of its own 30 nulls ("outside null").
//   Q2-CONS (museum): on crates, apertures DO NOT narrow —
//     Spearman(meanApFrac) > -0.6 OR the final checkpoint sits inside
//     its null band (percentile > 5).
//   SP1 (both corpora, secondary): latency rises — Spearman(latentFrac)
//     >= +0.6. A failure scopes the latency arrow, not the axis.
//
// FAILURE SEMANTICS (protocol §5): both consolidation quadrants must
// come out as predicted for the axis's consolidation fingerprint to
// count. A diagonal outcome (museum consolidates, or garden loosens) is
// failure by reversal and is reported at full prominence.
//
// Determinism: PRNG mulberry32, seed 20260827 + checkpoint index;
// rewire seeds recorded in output. Crates 2024/2026 history files are
// untracked (large); regenerate via 01 against the pinned SHAs.
//
// Writes software-study/results-consolidation.json.
//
// ---------------------------------------------------------------------
// POSTSCRIPT (2026-08-27, after the single registered run).
//
//   go:     Spearman latent=-0.657  meanAp=-0.714  finalPct=43.3
//   crates: Spearman latent=+0.314  meanAp=-0.200  finalPct=96.7
//
// Q1-CONS FAILS. Go's apertures do trend downward (Spearman -0.714,
// clearing the -0.6 threshold), but the 2026 checkpoint sits at the
// 43.3rd percentile of its own nulls — squarely inside the band. Mature
// Go is not distinguishable from its degree-random twin on this metric.
// The drop is also non-monotone (2024 dipped to pct 3.3, 2026 rebounded),
// which a consolidation arrow should not do.
//
// Q2-CONS HOLDS. Crates does not narrow (Spearman -0.200, final pct
// 96.7). As registered, this is the weak half: it predicted an absence.
//
// SP1 FAILS on both corpora: latency FALLS on Go (-0.657) and is flat
// on crates (+0.314). The latency arrow — which held on Mathlib AND on
// AFP — does not appear on either software corpus.
//
// consolidationFingerprint: NOT AS PREDICTED. Per protocol §5 the axis's
// consolidation fingerprint does not count: the garden did not
// consolidate. Note this is failure-by-absence in the garden quadrant,
// not failure-by-reversal (crates did not consolidate either; no
// diagonal). Reading: Mathlib's consolidation arrow now looks like a
// fact about Mathlib specifically — one continuously-refactored corpus —
// not about maintained corpora as a class. The garden/museum axis loses
// its consolidation row regardless of what the growth quadrants say.
// ---------------------------------------------------------------------

import { readFileSync, writeFileSync } from "node:fs";

const YEARS = [2016, 2018, 2020, 2022, 2024, 2026];
const CONE_MAX = 18, TOP_CONES = 5, N_REWIRES = 30, SEED = 20260827;

const mulberry32 = (a) => () => {
  a |= 0; a = (a + 0x6D2B79F5) | 0;
  let t = Math.imul(a ^ (a >>> 15), 1 | a);
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};

// ---- Tarjan SCC ----
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

// condensation edge lists (cIn[c] = comps c depends on)
const condense = (n, edges) => {
  const adjOut = Array.from({ length: n }, () => []);
  for (const [a, b] of edges) adjOut[a].push(b);
  const { comp, nComp } = sccOf(n, adjOut);
  const set = new Set();
  for (const [a, b] of edges) if (comp[a] !== comp[b]) set.add(comp[a] * 2000000 + comp[b]);
  const cIn = Array.from({ length: nComp }, () => []);
  const cOut = Array.from({ length: nComp }, () => []);
  for (const x of set) {
    const a = Math.floor(x / 2000000), b = x % 2000000;
    cIn[a].push(b); cOut[b].push(a);
  }
  return { nComp, cIn, cOut, edgeList: [...set].map((x) => [Math.floor(x / 2000000), x % 2000000]) };
};

// ---- cone pick: top-5 principal down-sets with |down| <= CONE_MAX ----
// early-abort BFS per node; deterministic tie-break by node index.
const pickCones = (n, cIn) => {
  const sizes = new Int32Array(n).fill(-1);
  const seen = new Int32Array(n).fill(-1);
  const q = new Int32Array(CONE_MAX + 2);
  for (let v = 0; v < n; v++) {
    let head = 0, tail = 0, count = 0, ok = true;
    seen[v] = v; q[tail++] = v; count = 1;
    while (head < tail) {
      const x = q[head++];
      for (const u of cIn[x]) {
        if (seen[u] === v) continue;
        seen[u] = v;
        if (++count > CONE_MAX) { ok = false; break; }
        q[tail++] = u;
      }
      if (!ok) break;
    }
    if (ok) sizes[v] = count;
  }
  const cand = [];
  for (let v = 0; v < n; v++) if (sizes[v] >= 2) cand.push(v);
  cand.sort((a, b) => sizes[b] - sizes[a] || a - b);
  return cand.slice(0, TOP_CONES).map((v) => ({ apex: v, size: sizes[v] }));
};

// ---- cone analysis: full 2^n observer census ----
// members: array of condensation node ids in the cone; down-closure within
// the cone as bitmasks; per-kernel latency + aperture fraction.
const analyzeCone = (apex, cIn) => {
  // collect members by BFS (size <= CONE_MAX guaranteed by pick)
  const members = [apex];
  const inCone = new Set([apex]);
  for (let h = 0; h < members.length; h++)
    for (const u of cIn[members[h]])
      if (!inCone.has(u)) { inCone.add(u); members.push(u); }
  const n = members.length;
  const midx = new Map(members.map((m, i) => [m, i]));
  // down[i] = bitmask of cone-internal down-set (reflexive)
  const down = new Int32Array(n);
  // topological process: repeat until fixpoint (n small)
  for (let i = 0; i < n; i++) down[i] = 1 << i;
  let changed = true;
  while (changed) {
    changed = false;
    for (let i = 0; i < n; i++) {
      let d = down[i];
      for (const u of cIn[members[i]]) {
        const j = midx.get(u);
        if (j !== undefined) d |= down[j];
      }
      if (d !== down[i]) { down[i] = d; changed = true; }
    }
  }
  const full = n === 31 ? 0x7fffffff : (1 << n) - 1;
  const nWorlds = 1 << n;
  // ordinariness of kernel bitmask B in world S: N = { y in S : down[y]&S&B == 0 };
  // dense iff N empty; NN = { y in S : down[y]&S&N == 0 }; regular iff NN == B∩S... 
  // (B is already a subset of S when called: we pass B = down[k] & S)
  const ordinaryIn = (B, S) => {
    if (B === 0) return false;
    let N = 0;
    for (let y = 0; y < n; y++) {
      if (!(S & (1 << y))) continue;
      if ((down[y] & S & B) === 0) N |= 1 << y;
    }
    if (N === 0) return false;
    let NN = 0;
    for (let y = 0; y < n; y++) {
      if (!(S & (1 << y))) continue;
      if ((down[y] & S & N) === 0) NN |= 1 << y;
    }
    return NN !== B;
  };
  let latent = 0, ordId = 0, apSum = 0, apMax = 0;
  for (let k = 0; k < n; k++) {
    const K = down[k];
    const ambient = ordinaryIn(K, full);
    if (ambient) ordId++;
    let ap = 0;
    for (let S = 0; S < nWorlds; S++) {
      const B = K & S;
      if (ordinaryIn(B, S)) ap++;
    }
    const apFrac = ap / nWorlds;
    apSum += apFrac;
    if (apFrac > apMax) apMax = apFrac;
    if (!ambient && ap > 0) latent++;
  }
  return { n, latentFrac: latent / n, ordIdFrac: ordId / n, meanApFrac: apSum / n, maxApFrac: apMax };
};

// ---- degree-preserving rewire on the condensation edge list ----
// double-edge swaps respecting a fixed topological order (edges point
// from later to earlier: a depends-on b means b topologically before a).
const topoOrder = (n, cIn) => {
  const indeg = new Int32Array(n); // count of deps not yet placed
  for (let i = 0; i < n; i++) indeg[i] = cIn[i].length;
  const cOut = Array.from({ length: n }, () => []);
  for (let i = 0; i < n; i++) for (const j of cIn[i]) cOut[j].push(i);
  const order = new Int32Array(n), pos = new Int32Array(n);
  let head = 0, tail = 0;
  const q = new Int32Array(n);
  for (let i = 0; i < n; i++) if (indeg[i] === 0) q[tail++] = i;
  let c = 0;
  while (head < tail) {
    const v = q[head++];
    order[c] = v; pos[v] = c; c++;
    for (const u of cOut[v]) if (--indeg[u] === 0) q[tail++] = u;
  }
  return pos; // pos[v] = topological position (deps have smaller pos)
};

const rewire = (n, edgeList, pos, rng) => {
  const edges = edgeList.map((e) => [e[0], e[1]]);
  const have = new Set(edges.map(([a, b]) => a * 2000000 + b));
  const m = edges.length;
  let swaps = 0;
  const target = 2 * m;
  let attempts = 0;
  while (swaps < target && attempts < 20 * target) {
    attempts++;
    const i = Math.floor(rng() * m), j = Math.floor(rng() * m);
    if (i === j) continue;
    const [a, b] = edges[i], [c, d] = edges[j];
    // proposed: a->d, c->b ; must respect topo (dep pos < dependent pos:
    // edge x->y means x depends on y, so pos[y] < pos[x])
    if (a === d || c === b) continue;
    if (pos[d] >= pos[a] || pos[b] >= pos[c]) continue;
    const k1 = a * 2000000 + d, k2 = c * 2000000 + b;
    if (have.has(k1) || have.has(k2)) continue;
    have.delete(a * 2000000 + b); have.delete(c * 2000000 + d);
    have.add(k1); have.add(k2);
    edges[i] = [a, d]; edges[j] = [c, b];
    swaps++;
  }
  const cIn = Array.from({ length: n }, () => []);
  for (const [a, b] of edges) cIn[a].push(b);
  return { cIn, swaps, attempts };
};

// ---- pipeline for one graph: pick + analyze ----
const metricsOf = (n, cIn) => {
  const cones = pickCones(n, cIn);
  if (cones.length === 0) return null;
  const per = cones.map((c) => analyzeCone(c.apex, cIn));
  const mean = (f) => per.reduce((s, x) => s + f(x), 0) / per.length;
  return {
    cones: cones.map((c, i) => ({ apex: c.apex, n: per[i].n })),
    latentFrac: mean((x) => x.latentFrac),
    ordIdFrac: mean((x) => x.ordIdFrac),
    meanApFrac: mean((x) => x.meanApFrac),
    maxApFrac: mean((x) => x.maxApFrac),
  };
};

const spearman = (xs, ys) => {
  const rank = (v) => {
    const idx = v.map((x, i) => [x, i]).sort((a, b) => a[0] - b[0]);
    const r = new Array(v.length);
    for (let i = 0; i < idx.length;) {
      let j = i;
      while (j + 1 < idx.length && idx[j + 1][0] === idx[i][0]) j++;
      const avg = (i + j) / 2 + 1;
      for (let k = i; k <= j; k++) r[idx[k][1]] = avg;
      i = j + 1;
    }
    return r;
  };
  const rx = rank(xs), ry = rank(ys);
  const mx = rx.reduce((a, b) => a + b) / rx.length, my = ry.reduce((a, b) => a + b) / ry.length;
  let num = 0, dx = 0, dy = 0;
  for (let i = 0; i < rx.length; i++) {
    num += (rx[i] - mx) * (ry[i] - my);
    dx += (rx[i] - mx) ** 2; dy += (ry[i] - my) ** 2;
  }
  return num / Math.sqrt(dx * dy);
};

// ---- run ----
const out = { protocol: "software-study/PROTOCOL.md v1.0 §4 (consolidation row)", ranAt: new Date().toISOString() };
for (const corpus of ["go", "crates"]) {
  const perYear = [];
  for (let yi = 0; yi < YEARS.length; yi++) {
    const year = YEARS[yi];
    const snap = JSON.parse(readFileSync(`software-study/history/${corpus}-${year}.json`, "utf8"));
    const { nComp, cIn, edgeList } = condense(snap.nodes.length, snap.edges);
    const obs = metricsOf(nComp, cIn);
    const pos = topoOrder(nComp, cIn);
    const nulls = [];
    for (let r = 0; r < N_REWIRES; r++) {
      const rng = mulberry32(SEED + yi * 1000 + r + (corpus === "go" ? 0 : 500000));
      const rw = rewire(nComp, edgeList, pos, rng);
      const m = metricsOf(nComp, rw.cIn);
      nulls.push({ latentFrac: m.latentFrac, meanApFrac: m.meanApFrac, swaps: rw.swaps });
    }
    const pct = (v, arr) => (100 * arr.filter((x) => x < v).length + 50 * arr.filter((x) => x === v).length) / arr.length;
    perYear.push({
      year, obs,
      pctLatent: +pct(obs.latentFrac, nulls.map((x) => x.latentFrac)).toFixed(1),
      pctMeanAp: +pct(obs.meanApFrac, nulls.map((x) => x.meanApFrac)).toFixed(1),
      nullMeanApMed: +nulls.map((x) => x.meanApFrac).sort((a, b) => a - b)[15].toFixed(4),
      meanSwaps: Math.round(nulls.reduce((s, x) => s + x.swaps, 0) / nulls.length),
    });
    console.log(`${corpus} ${year}: latent=${obs.latentFrac.toFixed(3)} (pct ${perYear[yi].pctLatent}) meanAp=${obs.meanApFrac.toFixed(4)} (pct ${perYear[yi].pctMeanAp})`);
  }
  const idx = YEARS.map((_, i) => i);
  const sLat = spearman(idx, perYear.map((p) => p.obs.latentFrac));
  const sAp = spearman(idx, perYear.map((p) => p.obs.meanApFrac));
  const finalPct = perYear[perYear.length - 1].pctMeanAp;
  out[corpus] = {
    perYear, spearmanLatent: +sLat.toFixed(3), spearmanMeanAp: +sAp.toFixed(3), finalPctMeanAp: finalPct,
  };
  console.log(`${corpus}: Spearman latent=${sLat.toFixed(3)} meanAp=${sAp.toFixed(3)} finalPct=${finalPct}`);
}

// ---- registered verdicts ----
const q1 = out.go.spearmanMeanAp <= -0.6 && out.go.finalPctMeanAp <= 5;
const q2 = !(out.crates.spearmanMeanAp <= -0.6 && out.crates.finalPctMeanAp <= 5);
out.verdicts = {
  "Q1-CONS (Go narrows, outside null)": q1 ? "HOLDS" : "FAILS",
  "Q2-CONS (crates does not narrow)": q2 ? "HOLDS" : "FAILS",
  "SP1-go (latency rises)": out.go.spearmanLatent >= 0.6 ? "HOLDS" : "FAILS",
  "SP1-crates (latency rises)": out.crates.spearmanLatent >= 0.6 ? "HOLDS" : "FAILS",
  consolidationFingerprint: q1 && q2 ? "AS PREDICTED" : "NOT AS PREDICTED",
};
writeFileSync("software-study/results-consolidation.json", JSON.stringify(out, null, 1));
console.log(JSON.stringify(out.verdicts, null, 1));
