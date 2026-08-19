// Git-history flow test: does the aperture profile of Mathlib consolidate
// over time?
//
// PRE-REGISTRATION (written before first run, 2026-08-19):
//
// Checkpoints: 2023-09, 2024-03, 2024-09, 2025-03, 2025-09 (git archive
// snapshots of Mathlib/{Order,Topology,Algebra}) plus HEAD (pin 1fb6b28816,
// 2026-05). Same modeling choices as all prior runs (namespace-internal
// imports; the import regex accepts both the old plain `import` and the new
// `public import` syntax).
//
// P1 (library flow): per namespace, the top-5-cone mean metrics (same pick
//    rule: largest foundations <= 18) computed at each checkpoint.
//    PREDICTION: latentFrac trends up and meanApFrac trends down over time
//    (consolidation at the frontier-cone scale). Statistic: Spearman of
//    checkpoint index vs metric, per namespace.
// P2 (cohort flow): the apex modules of the HEAD cones, traced backward:
//    the SAME module's foundation cone at each earlier checkpoint where it
//    exists (skip if cone > 18 or < 3). PREDICTION: meanApFrac
//    non-increasing with time per apex (cones narrow as they age).
//    LIMITATION, stated in advance: cone size grows with age and small
//    posets mechanically have coarser aperture fractions; sizes are
//    reported alongside so the reader can judge; no size-adjusted null here.
// P3 (youth of flat cones): the two flat Algebra cones
//    (Homology.SpectralObject.HasSpectralSequence, Order.Monoid.Canonical.Defs)
//    and the CWComplex island (Topology.CWComplex.Classical.Basic).
//    PREDICTION: flat/island material is YOUNG — absent from checkpoints
//    before 2025. If a flat cone is old, that is evidence AGAINST the
//    "flat = young, consolidation comes with age" developmental story and
//    will be reported as such.

import { readdirSync, readFileSync, statSync, existsSync } from "node:fs";
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
    size: cn,
    latentFrac: latent / cn,
    ordIdFrac: ordId / cn,
    meanApFrac: fracs.reduce((a, b) => a + b, 0) / cn,
  };
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

// cache graphs
const graphs = new Map();
const getGraph = (ck, base, ns) => {
  const key = ck + "/" + ns;
  if (!graphs.has(key)) graphs.set(key, loadGraph(base, ns));
  return graphs.get(key);
};

// ---- P1: library flow ----
console.log("=== P1: library-level flow (top-5-cone means per checkpoint) ===");
const p1 = {};
for (const ns of NAMESPACES) {
  p1[ns] = [];
  for (const [ck, base] of CHECKPOINTS) {
    const g = getGraph(ck, base, ns);
    if (!g) { p1[ns].push(null); continue; }
    const found = foundations(g.n, g.edges);
    const cands = [];
    for (let i = 0; i < g.n; i++) if (found[i].size <= MAXCONE) cands.push(i);
    cands.sort((a, b) => found[b].size - found[a].size || a - b);
    const res = cands.slice(0, CONES).map((x) => analyzeCone([...found[x]].sort((a, b) => a - b), found));
    const mean = (k) => res.reduce((s, r) => s + r[k], 0) / res.length;
    p1[ns].push({ ck, n: g.n, latentFrac: mean("latentFrac"), meanApFrac: mean("meanApFrac"), ordIdFrac: mean("ordIdFrac") });
  }
  console.log(`\n${ns}:`);
  for (const row of p1[ns]) {
    if (!row) continue;
    console.log(`  ${row.ck}  modules=${row.n}  latentFrac=${row.latentFrac.toFixed(3)}  ordIdFrac=${row.ordIdFrac.toFixed(3)}  meanApFrac=${row.meanApFrac.toFixed(4)}`);
  }
  const rows = p1[ns].filter(Boolean);
  const t = rows.map((_, i) => i);
  console.log(
    `  trend (Spearman vs time): latentFrac ${spearman(t, rows.map((r) => r.latentFrac)).toFixed(2)}` +
    `  meanApFrac ${spearman(t, rows.map((r) => r.meanApFrac)).toFixed(2)}` +
    `  (prediction: positive / negative)`
  );
}

// ---- P2: cohort flow (HEAD apexes traced backward) ----
console.log("\n=== P2: cohort flow — HEAD cone apexes traced backward ===");
const headBase = CHECKPOINTS[CHECKPOINTS.length - 1][1];
for (const ns of NAMESPACES) {
  const gHead = getGraph("2026-05", headBase, ns);
  const foundHead = foundations(gHead.n, gHead.edges);
  const cands = [];
  for (let i = 0; i < gHead.n; i++) if (foundHead[i].size <= MAXCONE) cands.push(i);
  cands.sort((a, b) => foundHead[b].size - foundHead[a].size || a - b);
  const apexes = [...new Set(cands.slice(0, CONES).map((x) => gHead.mods[x]))];
  console.log(`\n${ns} apexes:`);
  for (const apex of apexes) {
    const line = [];
    const series = [];
    for (const [ck, base] of CHECKPOINTS) {
      const g = getGraph(ck, base, ns);
      const xi = g ? g.midx.get(apex) : undefined;
      if (xi === undefined) { line.push(`${ck}: absent`); continue; }
      const found = foundations(g.n, g.edges);
      const sz = found[xi].size;
      if (sz > MAXCONE || sz < 3) { line.push(`${ck}: size=${sz} skipped`); continue; }
      const r = analyzeCone([...found[xi]].sort((a, b) => a - b), found);
      series.push(r.meanApFrac);
      line.push(`${ck}: size=${sz} ap=${r.meanApFrac.toFixed(3)} lat=${r.latentFrac.toFixed(2)}`);
    }
    const trend = series.length >= 3 ? spearman(series.map((_, i) => i), series).toFixed(2) : "n/a";
    console.log(`  ${apex.replace("Mathlib." + ns + ".", "")}\n    ${line.join("  |  ")}\n    meanApFrac trend vs time: ${trend} (prediction: negative)`);
  }
}

// ---- P3: youth of flat cones ----
console.log("\n=== P3: age of the flat/island modules ===");
const P3 = [
  ["Algebra", "Mathlib.Algebra.Homology.SpectralObject.HasSpectralSequence"],
  ["Algebra", "Mathlib.Algebra.Order.Monoid.Canonical.Defs"],
  ["Topology", "Mathlib.Topology.CWComplex.Classical.Basic"],
];
for (const [ns, mod] of P3) {
  const presence = CHECKPOINTS.map(([ck, base]) => {
    const g = getGraph(ck, base, ns);
    return g && g.midx.has(mod) ? ck : null;
  }).filter(Boolean);
  console.log(`  ${mod}: present at [${presence.join(", ")}]`);
}
