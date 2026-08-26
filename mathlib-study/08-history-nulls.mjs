// Per-snapshot nulls for the consolidation arrow (the control gap named in
// 06 and in every outward document since).
//
// PRE-REGISTRATION (written before first run, 2026-08-26):
//
// MOTIVATION. Script 06 P1 found all six library-level trends in the
// predicted direction (latentFrac up, meanApFrac down; three namespaces,
// six checkpoints 2023-09..2026-05) but measured them against nothing: no
// per-snapshot null. 06's own P2 header named the gap ("no size-adjusted
// null here"). The CA study's v1.3 result (ca-study/RESULTS.md) has since
// demonstrated on this exact instrument that aperture statistics covary
// hard with the size and shape of the underlying object — a raw temporal
// trend on a growing library is exactly the artifact class the program
// caught itself producing yesterday. This script closes the gap.
//
// NULL MODEL. Per (checkpoint, namespace): degree-preserving double-edge-
// swap randomization of that snapshot's namespace-internal import DAG —
// the verbatim machinery of 03 (swaps kept forward with respect to a fixed
// topological order of the real snapshot graph, so acyclicity is
// preserved; in- and out-degree sequences preserved exactly; 10x|E|
// attempted swaps per replicate). REPLICATES = 30 per (checkpoint,
// namespace), mulberry32 seed 20260826, one stream in fixed iteration
// order (checkpoints outer, namespaces middle, replicates inner).
//
// PIPELINE IDENTITY. Each replicate runs the IDENTICAL pipeline as 06 P1,
// including the cone pick rule (top-5 foundations <= 18, ties by node id):
// the pick rule is part of the instrument, so the null must run through
// it. analyzeCone, loadGraph, spearman are verbatim from 06; rewire and
// percentile are verbatim from 03. Reuse is logged here (shared-bug risk
// on the record, as in ca-study).
//
// MEASURES. Per (checkpoint, namespace): observed top-5-cone mean
// latentFrac / meanApFrac / ordIdFrac / coneSize, the null distribution of
// each (30 replicates), and the observed percentile within the null.
// Null mean cone size is reported alongside as the size-confound
// diagnostic (rewired graphs may offer different-size cones to the same
// pick rule; sizes on the record either way).
//
// PREDICTIONS.
//
// NP1 (load-bearing). The consolidation arrow survives per-snapshot
//   normalization. Operationally: for the six (namespace, metric) pairs —
//   metric in {latentFrac (predicted +), meanApFrac (predicted -)} — the
//   Spearman correlation of the observed-percentile-within-null against
//   checkpoint index has the predicted sign in AT LEAST 5 OF 6.
//   The confound hypothesis this tests: the raw trends are produced by
//   composition (size/degree structure drifting over three years), in
//   which case each snapshot's null tracks its observed value and the
//   percentile series is flat or unsigned.
//   FAILURE SEMANTICS: <= 3 of 6 with predicted sign -> the arrow is
//   compositional; the consolidation claim is downgraded in README and
//   both briefs at the prominence it was reported. Exactly 4 -> attenuated;
//   reported as such, no survival claim. (Spearman of observed minus null
//   median vs time is reported alongside as a robustness view, not part
//   of the criterion.)
//
// NP2 (continuity anchor). At 2026-05, observed meanApFrac sits at or
//   below the 10th percentile of its null in Order AND in Topology —
//   03/04's cross-sectional narrowness, re-expressed under the top-5
//   pipeline. Algebra is explicitly NOT predicted (04: percentiles
//   93/5/7/3, misses the replication cutoffs). If NP2 fails, the
//   discrepancy with 03 must be diagnosed (first suspect: top-5-mean vs
//   03's single-largest-cone pick) BEFORE NP1 is interpreted.
//
// EXPLICITLY NOT PREDICTED: monotone percentile series; effect sizes; any
// cohort-level (06 P2) or youth (06 P3) claim; Algebra's cross-sectional
// position.
//
// Output: mathlib-study/results-history-nulls.json (raw, committed),
// incremental per-(checkpoint,namespace) so a crash preserves progress.

import { readdirSync, readFileSync, statSync, existsSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const CHECKPOINTS = [
  ["2023-09", ".scratch_mathlib_hist/2023-09/Mathlib"],
  ["2024-03", ".scratch_mathlib_hist/2024-03/Mathlib"],
  ["2024-09", ".scratch_mathlib_hist/2024-09/Mathlib"],
  ["2025-03", ".scratch_mathlib_hist/2025-03/Mathlib"],
  ["2025-09", ".scratch_mathlib_hist/2025-09/Mathlib"],
  ["2026-05", "lean/.lake/packages/mathlib/Mathlib"],
];
const NAMESPACES = ["Order", "Topology", "Algebra"];
const CONES = 5;
const MAXCONE = 18;
const REPLICATES = 30;
const SEED = 20260826;
const OUT = "mathlib-study/results-history-nulls.json";

// deterministic PRNG (mulberry32), one stream for the whole run
let rngState = SEED;
const rand = () => {
  rngState |= 0; rngState = (rngState + 0x6d2b79f5) | 0;
  let t = Math.imul(rngState ^ (rngState >>> 15), 1 | rngState);
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};
const randInt = (n) => Math.floor(rand() * n);

// ---- loadGraph, verbatim from 06 ----
const loadGraph = (base, ns) => {
  const root = join(base, ns);
  if (!existsSync(root)) return null;
  const files = [];
  const walk = (dir) => {
    for (const name of readdirSync(dir)) {
      const p = join(dir, name);
      if (statSync(p).isDirectory()) walk(p);
      else if (name.endsWith(".lean")) files.push(p);
    }
  };
  walk(root);
  files.sort();
  const modOf = (p) =>
    "Mathlib." + p.replaceAll("\\", "/").split("Mathlib/").pop().replace(/\.lean$/, "").replaceAll("/", ".");
  const mods = files.map(modOf);
  const midx = new Map(mods.map((m, i) => [m, i]));
  const n = mods.length;
  const importRe = /^(?:(?:public|private|meta)\s+)*import\s+([\w.]+)/gm;
  const edges = [];
  files.forEach((p, i) => {
    const src = readFileSync(p, "utf8");
    for (const m of src.matchAll(importRe)) {
      const j = midx.get(m[1]);
      if (j !== undefined && j !== i) edges.push([j, i]);
    }
  });
  return { n, mods, midx, edges };
};

// ---- foundations, verbatim from 06 ----
const foundations = (n, edges) => {
  const adjIn = Array.from({ length: n }, () => []);
  for (const [a, b] of edges) adjIn[b].push(a);
  const found = new Array(n);
  const state = new Uint8Array(n);
  const stack = [];
  for (let s = 0; s < n; s++) {
    if (state[s] === 2) continue;
    stack.push(s);
    while (stack.length) {
      const i = stack[stack.length - 1];
      if (state[i] === 2) { stack.pop(); continue; }
      if (state[i] === 0) {
        state[i] = 1;
        for (const j of adjIn[i]) if (state[j] !== 2) stack.push(j);
        continue;
      }
      const set = new Set([i]);
      for (const j of adjIn[i]) for (const k of found[j]) set.add(k);
      found[i] = set;
      state[i] = 2;
      stack.pop();
    }
  }
  return found;
};

// ---- analyzeCone, verbatim from 06 ----
const analyzeCone = (cone, found) => {
  const cn = cone.length;
  const localIdx = new Map(cone.map((g, i) => [g, i]));
  const down = cone.map((g) => {
    let m = 0;
    for (const k of found[g]) if (localIdx.has(k)) m |= 1 << localIdx.get(k);
    return m;
  });
  const full = (1 << cn) - 1;
  let latent = 0, ordId = 0;
  const fracs = [];
  for (let x = 0; x < cn; x++) {
    const B = down[x];
    let ap = 0;
    for (let S = 0; S <= full; S++) {
      const Bs = B & S;
      let notB = 0;
      for (let p = 0; p < cn; p++) if ((S & (1 << p)) && (down[p] & Bs) === 0) notB |= 1 << p;
      if (notB === 0) continue;
      let nnB = 0;
      for (let p = 0; p < cn; p++) if ((S & (1 << p)) && (down[p] & notB) === 0) nnB |= 1 << p;
      if (nnB !== Bs) ap++;
    }
    let notB = 0;
    for (let p = 0; p < cn; p++) if ((down[p] & B) === 0) notB |= 1 << p;
    let idOrd = false;
    if (notB !== 0) {
      let nnB = 0;
      for (let p = 0; p < cn; p++) if ((down[p] & notB) === 0) nnB |= 1 << p;
      idOrd = nnB !== B;
    }
    if (idOrd) ordId++;
    else if (ap > 0) latent++;
    fracs.push(ap / (full + 1));
  }
  return {
    size: cn,
    latentFrac: latent / cn,
    ordIdFrac: ordId / cn,
    meanApFrac: fracs.reduce((a, b) => a + b, 0) / cn,
  };
};

// ---- top-5 pipeline (identical pick rule to 06 P1) ----
const topFiveMeans = (n, edges) => {
  const found = foundations(n, edges);
  const cands = [];
  for (let i = 0; i < n; i++) if (found[i].size <= MAXCONE) cands.push(i);
  cands.sort((a, b) => found[b].size - found[a].size || a - b);
  const res = cands.slice(0, CONES).map((x) => analyzeCone([...found[x]].sort((a, b) => a - b), found));
  const mean = (k) => res.reduce((s, r) => s + r[k], 0) / res.length;
  return {
    latentFrac: mean("latentFrac"),
    meanApFrac: mean("meanApFrac"),
    ordIdFrac: mean("ordIdFrac"),
    coneSize: mean("size"),
  };
};

// ---- rewire, verbatim from 03 (topoPos computed per snapshot graph) ----
const topoOrder = (n, edges) => {
  const topoPos = new Int32Array(n);
  const adj = Array.from({ length: n }, () => []);
  const indeg = new Int32Array(n);
  for (const [a, b] of edges) { adj[a].push(b); indeg[b]++; }
  const q = [];
  for (let i = 0; i < n; i++) if (indeg[i] === 0) q.push(i);
  let k = 0;
  while (q.length) {
    const v = q.shift();
    topoPos[v] = k++;
    for (const w of adj[v]) if (--indeg[w] === 0) q.push(w);
  }
  if (k !== n) throw new Error("cycle in snapshot graph");
  return topoPos;
};

const rewire = (n, edges, topoPos) => {
  const es = edges.map((e) => [...e]);
  const have = new Set(es.map(([a, b]) => a * n + b));
  const attempts = es.length * 10;
  for (let t = 0; t < attempts; t++) {
    const i = randInt(es.length), j = randInt(es.length);
    if (i === j) continue;
    const [a, b] = es[i], [c, d] = es[j];
    if (a === d || c === b) continue;
    if (!(topoPos[a] < topoPos[d] && topoPos[c] < topoPos[b])) continue;
    if (have.has(a * n + d) || have.has(c * n + b)) continue;
    have.delete(a * n + b); have.delete(c * n + d);
    es[i] = [a, d]; es[j] = [c, b];
    have.add(a * n + d); have.add(c * n + b);
  }
  return es;
};

// ---- percentile, verbatim from 03; spearman, verbatim from 06 ----
const pct = (arr, v) => {
  const s = [...arr].sort((a, b) => a - b);
  const below = s.filter((x) => x < v).length;
  const eq = s.filter((x) => x === v).length;
  return ((below + eq / 2) / s.length) * 100;
};
const spearman = (xs, ys) => {
  const rank = (a) => {
    const idx = [...a.keys()].sort((i, j) => a[i] - a[j]);
    const r = new Array(a.length);
    idx.forEach((i, k) => (r[i] = k));
    return r;
  };
  const rx = rank(xs), ry = rank(ys);
  const m = (rx.length - 1) / 2;
  let num = 0, dx = 0, dy = 0;
  for (let i = 0; i < rx.length; i++) {
    num += (rx[i] - m) * (ry[i] - m);
    dx += (rx[i] - m) ** 2; dy += (ry[i] - m) ** 2;
  }
  return num / Math.sqrt(dx * dy);
};

// ---- run ----
const results = [];
const t0 = Date.now();
for (const [ck, base] of CHECKPOINTS) {
  for (const ns of NAMESPACES) {
    const g = loadGraph(base, ns);
    if (!g) { results.push({ ck, ns, defined: false }); continue; }
    const topoPos = topoOrder(g.n, g.edges);
    const obs = topFiveMeans(g.n, g.edges);
    const nulls = { latentFrac: [], meanApFrac: [], ordIdFrac: [], coneSize: [] };
    for (let r = 0; r < REPLICATES; r++) {
      const nr = topFiveMeans(g.n, rewire(g.n, g.edges, topoPos));
      for (const k of Object.keys(nulls)) nulls[k].push(nr[k]);
    }
    const row = {
      ck, ns, defined: true, modules: g.n, edges: g.edges.length,
      observed: obs, nulls,
      percentile: {
        latentFrac: pct(nulls.latentFrac, obs.latentFrac),
        meanApFrac: pct(nulls.meanApFrac, obs.meanApFrac),
      },
      nullMedian: {
        latentFrac: [...nulls.latentFrac].sort((a, b) => a - b)[Math.floor(REPLICATES / 2)],
        meanApFrac: [...nulls.meanApFrac].sort((a, b) => a - b)[Math.floor(REPLICATES / 2)],
        coneSize: [...nulls.coneSize].sort((a, b) => a - b)[Math.floor(REPLICATES / 2)],
      },
    };
    results.push(row);
    writeFileSync(OUT, JSON.stringify({ seed: SEED, replicates: REPLICATES, results }, null, 1));
    console.log(
      `${ck} ${ns.padEnd(8)} mods=${g.n} obs latent=${obs.latentFrac.toFixed(3)} ` +
      `(null med ${row.nullMedian.latentFrac.toFixed(3)}, pctl ${row.percentile.latentFrac.toFixed(1)})  ` +
      `obs ap=${obs.meanApFrac.toFixed(4)} (null med ${row.nullMedian.meanApFrac.toFixed(4)}, pctl ${row.percentile.meanApFrac.toFixed(1)})  ` +
      `coneSize obs=${obs.coneSize.toFixed(1)} null=${row.nullMedian.coneSize.toFixed(1)}  ` +
      `[${((Date.now() - t0) / 60000).toFixed(1)} min]`
    );
  }
}

// ---- NP1 evaluation ----
console.log("\n=== NP1: does the consolidation arrow survive per-snapshot nulls? ===");
let signOK = 0;
const trendRows = [];
for (const ns of NAMESPACES) {
  const rows = results.filter((r) => r.defined && r.ns === ns);
  const t = rows.map((_, i) => i);
  for (const [metric, predictedSign] of [["latentFrac", +1], ["meanApFrac", -1]]) {
    const pctlSeries = rows.map((r) => r.percentile[metric]);
    const diffSeries = rows.map((r) => r.observed[metric] - r.nullMedian[metric]);
    const rawSeries = rows.map((r) => r.observed[metric]);
    const sPctl = spearman(t, pctlSeries);
    const sDiff = spearman(t, diffSeries);
    const sRaw = spearman(t, rawSeries);
    const ok = Math.sign(sPctl) === predictedSign;
    if (ok) signOK++;
    trendRows.push({ ns, metric, sPctl, sDiff, sRaw, predictedSign, ok });
    console.log(
      `${ns.padEnd(8)} ${metric.padEnd(11)} raw ρ=${sRaw.toFixed(2)}  ` +
      `pctl-in-null ρ=${sPctl.toFixed(2)} (predict ${predictedSign > 0 ? "+" : "-"})  ` +
      `obs-minus-nullmed ρ=${sDiff.toFixed(2)}  -> ${ok ? "sign OK" : "SIGN FLIPPED/ABSENT"}`
    );
    console.log(`         percentile series: [${pctlSeries.map((v) => v.toFixed(0)).join(", ")}]`);
  }
}
const np1 = signOK >= 5 ? "SURVIVES" : signOK === 4 ? "ATTENUATED (no survival claim)" : "COMPOSITIONAL (arrow does not survive)";
console.log(`NP1: ${signOK}/6 predicted signs -> ${np1}`);

// ---- NP2 evaluation ----
console.log("\n=== NP2: continuity anchor at 2026-05 ===");
let np2 = true;
for (const ns of ["Order", "Topology"]) {
  const row = results.find((r) => r.defined && r.ck === "2026-05" && r.ns === ns);
  const ok = row.percentile.meanApFrac <= 10;
  if (!ok) np2 = false;
  console.log(`${ns}: observed meanApFrac percentile ${row.percentile.meanApFrac.toFixed(1)} (require <= 10)  -> ${ok ? "OK" : "FAIL"}`);
}
console.log(`NP2: ${np2 ? "HOLDS" : "FAILS — diagnose vs 03 before interpreting NP1"}`);

writeFileSync(OUT, JSON.stringify({ seed: SEED, replicates: REPLICATES, results, trends: trendRows, NP1: { signOK, verdict: np1 }, NP2: np2 }, null, 1));
console.log(`\nwritten: ${OUT}  [total ${((Date.now() - t0) / 60000).toFixed(1)} min]`);
