// Deflation test 1: is the aperture profile predicted by simple graph invariants?
//
// PRE-REGISTRATION (written before first run, 2026-08-19):
//
// Threat: the narrow-aperture finding (real Mathlib cones vs degree-preserving
// null) might be a repackaging of an ordinary graph statistic. If a simple
// invariant explains the gap, the aperture adds no empirical signal beyond it.
//
// Candidate simple invariants, per cone (fixed in advance):
//   J  = mean pairwise Jaccard overlap of principal foundations
//        |down(x) /\ down(y)| / |down(x) \/ down(y)| over unordered pairs
//   D  = normalized depth = (longest chain length in cone) / |cone|
//   M  = number of minimal elements / |cone|
//   F  = mean |down(x)| / |cone|  (mean foundation fraction)
//
// Aperture metrics, per cone: latentFrac, meanApFrac.
//
// Data: for each namespace (Order, Topology, Algebra), the 5 observed cones
// plus 5 cones from each of 20 degree-preserving rewires (same rules as the
// replication study; seeded PRNG 20260820 — new seed, new draws).
//
// Analyses (fixed in advance):
//   A. Spearman rank correlation of each invariant with each aperture metric,
//      pooled over all cones (real + null).
//   B. Matched comparison: for each real cone, find the 5 null cones nearest
//      in the single best-correlated invariant; compare the real cone's
//      meanApFrac to the matched null cones' values.
//
// Pre-registered deflation criterion: the finding is DEFLATED if, in the
// matched comparison, real cones are no longer systematically below their
// invariant-matched null cones (fewer than 2/3 of real cones below their
// matched-null median). If real cones remain below even after matching on
// the best invariant, the aperture carries signal beyond that invariant.
// Honest expectation: J (foundation overlap) will correlate strongly —
// density at identity is literally about shared foundations — so the live
// question is whether the gap survives matching on J.

import { readdirSync, readFileSync, statSync, existsSync } from "node:fs";
import { join } from "node:path";

const NAMESPACES = ["Order", "Topology", "Algebra"];
const REPLICATES = 20;
const CONES = 5;
const MAXCONE = 18;

let rngState = 20260820;
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
  files.sort();
  const midx = new Map(files.map((p, i) => [
    "Mathlib." + p.replaceAll("\\", "/").split("Mathlib/")[1].replace(/\.lean$/, "").replaceAll("/", "."), i]));
  const n = files.length;
  const importRe = /^(?:(?:public|private|meta)\s+)*import\s+([\w.]+)/gm;
  const edges = [];
  files.forEach((p, i) => {
    const src = readFileSync(p, "utf8");
    for (const m of src.matchAll(importRe)) {
      const j = midx.get(m[1]);
      if (j !== undefined && j !== i) edges.push([j, i]);
    }
  });
  return { n, edges };
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

const popcount32 = (v) => { v = v - ((v >>> 1) & 0x55555555); v = (v & 0x33333333) + ((v >>> 2) & 0x33333333); return (((v + (v >>> 4)) & 0x0f0f0f0f) * 0x01010101) >>> 24; };

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
  // ---- invariants ----
  let jSum = 0, jCnt = 0;
  for (let x = 0; x < cn; x++) for (let y = x + 1; y < cn; y++) {
    jSum += popcount32(down[x] & down[y]) / popcount32(down[x] | down[y]);
    jCnt++;
  }
  // longest chain via DP over |down| order
  const order = [...Array(cn).keys()].sort((a, b) => popcount32(down[a]) - popcount32(down[b]));
  const h = new Int32Array(cn).fill(1);
  for (const x of order) for (const y of order) {
    if (x !== y && (down[y] & ~down[x]) === 0 && (down[x] & (1 << y))) h[x] = Math.max(h[x], h[y] + 1);
  }
  let minimals = 0;
  for (let x = 0; x < cn; x++) if (popcount32(down[x]) === 1) minimals++;
  const meanFound = down.reduce((s, d) => s + popcount32(d), 0) / cn / cn;
  return {
    latentFrac: latent / cn,
    meanApFrac: fracs.reduce((a, b) => a + b, 0) / cn,
    J: jSum / jCnt,
    D: Math.max(...h) / cn,
    M: minimals / cn,
    F: meanFound,
  };
};

const conesOf = (n, edges) => {
  const found = foundations(n, edges);
  const cands = [];
  for (let i = 0; i < n; i++) if (found[i].size <= MAXCONE) cands.push(i);
  cands.sort((a, b) => found[b].size - found[a].size || a - b);
  return cands.slice(0, CONES).map((x) => analyzeCone([...found[x]].sort((a, b) => a - b), found));
};

const rewire = (n, edges, topoPos) => {
  const es = edges.map((e) => [...e]);
  const have = new Set(es.map(([a, b]) => a * n + b));
  for (let t = 0; t < es.length * 10; t++) {
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

// ---- collect data ----
const realCones = [], nullCones = [];
for (const ns of NAMESPACES) {
  const g = loadGraph(ns);
  if (!g) continue;
  const topoPos = topoOrder(g.n, g.edges);
  for (const c of conesOf(g.n, g.edges)) realCones.push({ ns, ...c });
  for (let r = 0; r < REPLICATES; r++) {
    for (const c of conesOf(g.n, rewire(g.n, g.edges, topoPos))) nullCones.push({ ns, ...c });
  }
  console.log(`${ns}: collected (real 5, null ${REPLICATES * CONES})`);
}

// ---- Analysis A: Spearman correlations, pooled ----
const spearman = (xs, ys) => {
  const rank = (a) => {
    const idx = [...a.keys()].sort((i, j) => a[i] - a[j]);
    const r = new Array(a.length);
    idx.forEach((i, k) => (r[i] = k));
    return r;
  };
  const rx = rank(xs), ry = rank(ys);
  const mx = rx.reduce((s, v) => s + v, 0) / rx.length;
  let num = 0, dx = 0, dy = 0;
  for (let i = 0; i < rx.length; i++) {
    num += (rx[i] - mx) * (ry[i] - mx);
    dx += (rx[i] - mx) ** 2; dy += (ry[i] - mx) ** 2;
  }
  return num / Math.sqrt(dx * dy);
};
const pool = [...realCones, ...nullCones];
console.log(`\nAnalysis A: Spearman correlations over ${pool.length} cones (real+null pooled)`);
for (const inv of ["J", "D", "M", "F"]) {
  for (const met of ["latentFrac", "meanApFrac"]) {
    console.log(`  ${inv} vs ${met}: ${spearman(pool.map((c) => c[inv]), pool.map((c) => c[met])).toFixed(3)}`);
  }
}

// ---- Analysis B: matched comparison on the best invariant ----
// best = invariant with largest |spearman| vs meanApFrac
let best = "J", bestR = 0;
for (const inv of ["J", "D", "M", "F"]) {
  const r = Math.abs(spearman(pool.map((c) => c[inv]), pool.map((c) => c.meanApFrac)));
  if (r > bestR) { bestR = r; best = inv; }
}
console.log(`\nAnalysis B: matching on best invariant '${best}' (|rho|=${bestR.toFixed(3)})`);
let below = 0;
for (const rc of realCones) {
  const matched = [...nullCones]
    .sort((a, b) => Math.abs(a[best] - rc[best]) - Math.abs(b[best] - rc[best]))
    .slice(0, 5);
  const med = matched.map((c) => c.meanApFrac).sort((a, b) => a - b)[2];
  const isBelow = rc.meanApFrac < med;
  if (isBelow) below++;
  console.log(
    `  real ${rc.ns} cone: ${best}=${rc[best].toFixed(3)} meanApFrac=${rc.meanApFrac.toFixed(4)}` +
    `  matched-null ${best}=[${matched.map((c) => c[best].toFixed(3)).join(",")}] median meanApFrac=${med.toFixed(4)}` +
    `  ${isBelow ? "BELOW" : "not below"}`
  );
}
console.log(`\nreal cones below invariant-matched null median: ${below}/${realCones.length}`);
console.log(below >= Math.ceil((2 / 3) * realCones.length)
  ? "VERDICT: NOT deflated — aperture carries signal beyond the best simple invariant"
  : "VERDICT: DEFLATED — the aperture profile is explained by a simple invariant");
