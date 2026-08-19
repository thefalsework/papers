// Null model for the Mathlib latency finding.
//
// PRE-REGISTRATION (written before first run, 2026-08-19):
//
// Observed (from .scratch_subspace_nuclei.mjs, Mathlib.Order @ 1fb6b28816,
// cone of Antisymmetrization, |P| = 18): 11/18 principal kernels latent,
// 1/18 ordinary at identity, aperture fractions 0.1%-3% among latent.
//
// Question: are these values distinguishable from a degree-preserving null?
// Null model: double-edge-swap randomization of the REAL Mathlib.Order
// internal import DAG (edges kept forward with respect to a fixed topological
// order of the original graph, so acyclicity is preserved; in- and
// out-degree sequences preserved exactly). 10x|E| attempted swaps per
// replicate, REPLICATES independent replicates. For each replicate, the SAME
// pre-registered cone pick (largest foundation <= 18, ties alphabetical by
// node id) and the same analysis as the real run.
//
// Metrics per replicate: cone size, latent fraction of principal kernels,
// ordinary-at-identity fraction, mean and max aperture fraction.
//
// Pre-registered expectation (honest): the latent fraction will NOT differ
// much from the null — latency is suspected to be generic in rooted cones.
// If observed falls inside the null's central mass, the claim "latency
// exists in formalized mathematics" must be downgraded to "latency is
// generic in dependency-cone geometry, and Mathlib instantiates it."
// If observed is extreme (<= 5th or >= 95th percentile), Mathlib's import
// structure carries signal the degree sequence does not explain.

import { readdirSync, readFileSync, statSync } from "node:fs";
import { join } from "node:path";

const REPLICATES = 60;
const SEED = 20260819;

// deterministic PRNG (mulberry32)
let rngState = SEED;
const rand = () => {
  rngState |= 0; rngState = (rngState + 0x6d2b79f5) | 0;
  let t = Math.imul(rngState ^ (rngState >>> 15), 1 | rngState);
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};
const randInt = (n) => Math.floor(rand() * n);

// ---- load real graph ----
const ROOT = "lean/.lake/packages/mathlib/Mathlib/Order";
const files = [];
const walk = (dir) => {
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    if (statSync(p).isDirectory()) walk(p);
    else if (name.endsWith(".lean")) files.push(p);
  }
};
walk(ROOT);
const modOf = (p) =>
  "Mathlib." + p.replaceAll("\\", "/").split("Mathlib/")[1].replace(/\.lean$/, "").replaceAll("/", ".");
const mods = files.map(modOf);
const midx = new Map(mods.map((m, i) => [m, i]));
const n = mods.length;
const importRe = /^(?:(?:public|private|meta)\s+)*import\s+([\w.]+)/gm;
let edgeList = []; // [from(imported), to(importer)]
files.forEach((p, i) => {
  const src = readFileSync(p, "utf8");
  for (const m of src.matchAll(importRe)) {
    const j = midx.get(m[1]);
    if (j !== undefined && j !== i) edgeList.push([j, i]);
  }
});
console.log(`graph: ${n} nodes, ${edgeList.length} edges`);

// ---- fixed topological order of the real DAG ----
const topoPos = new Int32Array(n);
{
  const adj = Array.from({ length: n }, () => []);
  const indeg = new Int32Array(n);
  for (const [a, b] of edgeList) { adj[a].push(b); indeg[b]++; }
  const q = [];
  for (let i = 0; i < n; i++) if (indeg[i] === 0) q.push(i);
  let k = 0;
  while (q.length) {
    const v = q.shift();
    topoPos[v] = k++;
    for (const w of adj[v]) if (--indeg[w] === 0) q.push(w);
  }
  if (k !== n) throw new Error("cycle in real graph");
}

// ---- analysis pipeline (same as the real run) ----
const analyzeGraph = (edges) => {
  // foundations
  const adjIn = Array.from({ length: n }, () => []); // imports of each node
  for (const [a, b] of edges) adjIn[b].push(a);
  const found = new Array(n);
  const state = new Uint8Array(n);
  const stack = [];
  const dfs = (i0) => {
    stack.push(i0);
    while (stack.length) {
      const i = stack[stack.length - 1];
      if (state[i] === 2) { stack.pop(); continue; }
      if (state[i] === 0) { state[i] = 1; for (const j of adjIn[i]) if (state[j] !== 2) stack.push(j); continue; }
      // state 1: children done
      const s = new Set([i]);
      for (const j of adjIn[i]) for (const k of found[j]) s.add(k);
      found[i] = s; state[i] = 2; stack.pop();
    }
  };
  for (let i = 0; i < n; i++) dfs(i);

  // pre-registered pick: largest foundation <= 18, ties smallest node id
  let pick = -1;
  for (let i = 0; i < n; i++) {
    if (found[i].size <= 18) {
      if (pick === -1 || found[i].size > found[pick].size) pick = i;
    }
  }
  const cone = [...found[pick]].sort((a, b) => a - b);
  const cn = cone.length;
  const localIdx = new Map(cone.map((g, i) => [g, i]));
  const down = cone.map((g) => {
    let m = 0;
    for (const k of found[g]) if (localIdx.has(k)) m |= 1 << localIdx.get(k);
    return m;
  });

  // per-kernel: latent? ordinary@identity? aperture fraction
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
      if (notB === 0) continue; // dense
      let nnB = 0;
      for (let p = 0; p < cn; p++) if ((S & (1 << p)) && (down[p] & notB) === 0) nnB |= 1 << p;
      if (nnB !== Bs) ap++; // not regular either -> ordinary
    }
    // identity verdict
    const Bs = B;
    let notB = 0;
    for (let p = 0; p < cn; p++) if ((down[p] & Bs) === 0) notB |= 1 << p;
    let idOrd = false;
    if (notB !== 0) {
      let nnB = 0;
      for (let p = 0; p < cn; p++) if ((down[p] & notB) === 0) nnB |= 1 << p;
      idOrd = nnB !== Bs;
    }
    if (idOrd) ordId++;
    else if (ap > 0) latent++;
    fracs.push(ap / (full + 1));
  }
  return {
    coneSize: cn,
    latentFrac: latent / cn,
    ordIdFrac: ordId / cn,
    meanApFrac: fracs.reduce((a, b) => a + b, 0) / cn,
    maxApFrac: Math.max(...fracs),
  };
};

// ---- observed ----
const obs = analyzeGraph(edgeList);
console.log(`observed: cone=${obs.coneSize} latentFrac=${obs.latentFrac.toFixed(3)} ordIdFrac=${obs.ordIdFrac.toFixed(3)} meanApFrac=${obs.meanApFrac.toFixed(4)} maxApFrac=${obs.maxApFrac.toFixed(4)}`);

// ---- degree-preserving rewire (double edge swaps, forward wrt topoPos) ----
const rewire = (edges) => {
  const es = edges.map((e) => [...e]);
  const have = new Set(es.map(([a, b]) => a * n + b));
  const attempts = es.length * 10;
  for (let t = 0; t < attempts; t++) {
    const i = randInt(es.length), j = randInt(es.length);
    if (i === j) continue;
    const [a, b] = es[i], [c, d] = es[j];
    if (a === d || c === b) continue;
    // forward constraint keeps acyclicity
    if (!(topoPos[a] < topoPos[d] && topoPos[c] < topoPos[b])) continue;
    if (have.has(a * n + d) || have.has(c * n + b)) continue;
    have.delete(a * n + b); have.delete(c * n + d);
    es[i] = [a, d]; es[j] = [c, b];
    have.add(a * n + d); have.add(c * n + b);
  }
  return es;
};

// ---- run null ----
const stats = { coneSize: [], latentFrac: [], ordIdFrac: [], meanApFrac: [], maxApFrac: [] };
for (let r = 0; r < REPLICATES; r++) {
  const res = analyzeGraph(rewire(edgeList));
  for (const k of Object.keys(stats)) stats[k].push(res[k]);
  if ((r + 1) % 10 === 0) console.log(`  replicate ${r + 1}/${REPLICATES} done`);
}

const pct = (arr, v) => {
  const s = [...arr].sort((a, b) => a - b);
  let below = s.filter((x) => x < v).length;
  let eq = s.filter((x) => x === v).length;
  return ((below + eq / 2) / s.length) * 100;
};
const q = (arr, p) => {
  const s = [...arr].sort((a, b) => a - b);
  return s[Math.min(s.length - 1, Math.floor((p / 100) * s.length))];
};

console.log(`\nNULL DISTRIBUTION (${REPLICATES} degree-preserving rewires) vs OBSERVED`);
for (const k of Object.keys(stats)) {
  const a = stats[k];
  console.log(
    `  ${k}: null 5%=${q(a, 5).toFixed(3)} 50%=${q(a, 50).toFixed(3)} 95%=${q(a, 95).toFixed(3)}` +
    `  observed=${obs[k].toFixed(3)}  percentile=${pct(a, obs[k]).toFixed(1)}`
  );
}
