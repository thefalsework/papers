// Replication study for the narrow-aperture finding.
//
// PRE-REGISTRATION (written before first run, 2026-08-19):
//
// Prior result (.scratch_latency_null.mjs): on the single pre-registered cone
// of Mathlib.Order, the real graph was extreme vs a degree-preserving null on
// all four metrics (latentFrac above all 60 rewires; ordIdFrac, meanApFrac,
// maxApFrac below all 60). One cone, one namespace. This study replicates
// across namespaces and cones. Design fixed in advance:
//
//   Namespaces: Order, Topology, Algebra (skipped if directory absent).
//   Cones per graph: the 5 distinct modules with the largest foundation of
//     size <= 18 (ties: smaller node id = alphabetical file order). Same rule
//     for observed and for every rewired replicate.
//   Null: 30 degree-preserving double-edge-swap rewires per namespace
//     (forward edges wrt a fixed topological order of the real graph;
//     10x|E| attempted swaps; seeded PRNG 20260819).
//   Statistic per graph: MEAN over its 5 cones of each metric
//     (latentFrac, ordIdFrac, meanApFrac, maxApFrac).
//   Success criterion (pre-registered): the prior result replicates in a
//     namespace if observed latentFrac is >= the null's 95th percentile AND
//     meanApFrac is <= the null's 5th percentile. Anything else is reported
//     as a non-replication for that namespace, without reinterpretation.

import { readdirSync, readFileSync, statSync, existsSync } from "node:fs";
import { join } from "node:path";

const NAMESPACES = ["Order", "Topology", "Algebra"];
const REPLICATES = 30;
const CONES = 5;
const MAXCONE = 18;

let rngState = 20260819;
const rand = () => {
  rngState |= 0; rngState = (rngState + 0x6d2b79f5) | 0;
  let t = Math.imul(rngState ^ (rngState >>> 15), 1 | rngState);
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};
const randInt = (n) => Math.floor(rand() * n);

const loadGraph = (ns) => {
  const root = `lean/.lake/packages/mathlib/Mathlib/${ns}`;
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
  files.sort(); // deterministic node ids = alphabetical
  const modOf = (p) =>
    "Mathlib." + p.replaceAll("\\", "/").split("Mathlib/")[1].replace(/\.lean$/, "").replaceAll("/", ".");
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
  return { n, mods, edges };
};

const topoOrder = (n, edges) => {
  const adj = Array.from({ length: n }, () => []);
  const indeg = new Int32Array(n);
  for (const [a, b] of edges) { adj[a].push(b); indeg[b]++; }
  const pos = new Int32Array(n);
  const q = [];
  for (let i = 0; i < n; i++) if (indeg[i] === 0) q.push(i);
  let k = 0;
  while (q.length) {
    const v = q.shift();
    pos[v] = k++;
    for (const w of adj[v]) if (--indeg[w] === 0) q.push(w);
  }
  if (k !== n) throw new Error("cycle");
  return pos;
};

// foundations as arrays of sorted node ids, iterative, memoized
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
    latentFrac: latent / cn,
    ordIdFrac: ordId / cn,
    meanApFrac: fracs.reduce((a, b) => a + b, 0) / cn,
    maxApFrac: Math.max(...fracs),
  };
};

const graphStat = (n, edges) => {
  const found = foundations(n, edges);
  // top CONES modules by (foundation size <= MAXCONE desc, node id asc)
  const cands = [];
  for (let i = 0; i < n; i++) if (found[i].size <= MAXCONE) cands.push(i);
  cands.sort((a, b) => found[b].size - found[a].size || a - b);
  const picks = cands.slice(0, CONES);
  const res = picks.map((x) => analyzeCone([...found[x]].sort((a, b) => a - b), found));
  const mean = (k) => res.reduce((s, r) => s + r[k], 0) / res.length;
  return {
    picks,
    perCone: res,
    coneSizes: picks.map((x) => found[x].size),
    latentFrac: mean("latentFrac"),
    ordIdFrac: mean("ordIdFrac"),
    meanApFrac: mean("meanApFrac"),
    maxApFrac: mean("maxApFrac"),
  };
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

const pct = (arr, v) => {
  const s = [...arr].sort((a, b) => a - b);
  const below = s.filter((x) => x < v).length;
  const eq = s.filter((x) => x === v).length;
  return ((below + eq / 2) / s.length) * 100;
};
const q = (arr, p) => {
  const s = [...arr].sort((a, b) => a - b);
  return s[Math.min(s.length - 1, Math.floor((p / 100) * s.length))];
};

for (const ns of NAMESPACES) {
  const g = loadGraph(ns);
  if (!g) { console.log(`\n### Mathlib.${ns}: directory absent, skipped`); continue; }
  console.log(`\n### Mathlib.${ns}: ${g.n} modules, ${g.edges.length} internal edges`);
  const topoPos = topoOrder(g.n, g.edges);
  const obs = graphStat(g.n, g.edges);
  console.log(`observed cones (sizes ${obs.coneSizes.join(",")}):`);
  obs.picks.forEach((x, i) => {
    const r = obs.perCone[i];
    console.log(
      `  ${g.mods[x]}  latent=${r.latentFrac.toFixed(3)} ordId=${r.ordIdFrac.toFixed(3)} meanAp=${r.meanApFrac.toFixed(4)} maxAp=${r.maxApFrac.toFixed(4)}`
    );
  });
  const stats = { latentFrac: [], ordIdFrac: [], meanApFrac: [], maxApFrac: [] };
  for (let r = 0; r < REPLICATES; r++) {
    const res = graphStat(g.n, rewire(g.n, g.edges, topoPos));
    for (const k of Object.keys(stats)) stats[k].push(res[k]);
    if ((r + 1) % 10 === 0) console.log(`  replicate ${r + 1}/${REPLICATES}`);
  }
  console.log(`null (${REPLICATES} rewires, mean over top-${CONES} cones) vs observed:`);
  for (const k of Object.keys(stats)) {
    console.log(
      `  ${k}: null 5/50/95% = ${q(stats[k], 5).toFixed(3)}/${q(stats[k], 50).toFixed(3)}/${q(stats[k], 95).toFixed(3)}` +
      `  observed=${obs[k].toFixed(3)}  pct=${pct(stats[k], obs[k]).toFixed(1)}`
    );
  }
  const replicates =
    obs.latentFrac >= q(stats.latentFrac, 95) && obs.meanApFrac <= q(stats.meanApFrac, 5);
  console.log(`pre-registered criterion (latentFrac >= null95 AND meanApFrac <= null5): ${replicates ? "REPLICATES" : "does NOT replicate"}`);
}
