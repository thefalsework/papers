// Forward registration, baseline freeze (see REGISTER.md).
//
// Computes, at each corpus's 2026 baseline, the evaluable principal kernels
// and their E-/D-cell members, per the frozen designs (mathlib-study/18;
// software-study/04), and writes predictions/frozen-2026.json.
//
// This script reads NO horizon data (none exists: the horizon is 2028-07-01).
// Subsampling constants below are size-control only — label-blind and
// seeded; they can reduce power, never bias (REGISTER.md §2).
//
// Frozen structure, per corpus:
//   { meta: {...pins}, deg: { name: d0 }, fs: { name: firstSeenIdx },
//     cells: [ { E: [names], D: [names] } ] }   // one entry per
//                                               // (kernel x stratum)
//
// Determinism: PRNG mulberry32, seed 20260827881.

import { readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { gzipSync } from "node:zlib";

const SEED = 20260827881;
const BIN = (d) => (d === 0 ? 0 : d <= 2 ? 1 : d <= 7 ? 2 : 3);

// size-control constants (REGISTER.md §2)
const ML_KERNELS_PER_NS = 150, ML_SIDE_CAP = 60;
const CRATES_KERNELS = 100, CRATES_SIDE_CAP = 100;
const AFP_SIDE_CAP = 200; // afp + go kernels: all evaluable (small corpora)

let rngState = SEED;
const rand = () => {
  rngState |= 0; rngState = (rngState + 0x6d2b79f5) | 0;
  let t = Math.imul(rngState ^ (rngState >>> 15), 1 | rngState);
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};
const shuffled = (n) => {
  const perm = Uint32Array.from({ length: n }, (_, i) => i);
  for (let i = 0; i < n; i++) {
    const j = i + Math.floor(rand() * (n - i));
    const t = perm[i]; perm[i] = perm[j]; perm[j] = t;
  }
  return perm;
};
const capped = (arr, cap) => {
  if (arr.length <= cap) return arr;
  const perm = shuffled(arr.length);
  const out = [];
  for (let i = 0; i < cap; i++) out.push(arr[perm[i]]);
  return out;
};

const out = {};

// =====================================================================
// Mathlib (design of mathlib-study/18): per-namespace module graphs,
// bitset down-sets, evaluable principal kernels, strata bin x firstSeen.
// =====================================================================
{
  const CHECKPOINTS = [
    ["2023-09", ".scratch_mathlib_hist/2023-09/Mathlib"],
    ["2024-03", ".scratch_mathlib_hist/2024-03/Mathlib"],
    ["2024-09", ".scratch_mathlib_hist/2024-09/Mathlib"],
    ["2025-03", ".scratch_mathlib_hist/2025-03/Mathlib"],
    ["2025-09", ".scratch_mathlib_hist/2025-09/Mathlib"],
    ["2026-05", "lean/.lake/packages/mathlib/Mathlib"],
  ];
  const NAMESPACES = ["Order", "Topology", "Algebra"];
  const importRe = /^(?:(?:public|private|meta)\s+)*import\s+([\w.]+)/gm;
  const loadGraph = (base, ns) => {
    const root = join(base, ns);
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
    const adjIn = Array.from({ length: n }, () => []);
    const dependents = new Map(mods.map((m) => [m, 0]));
    files.forEach((p, i) => {
      const src = readFileSync(p, "utf8");
      for (const m of src.matchAll(importRe)) {
        const j = midx.get(m[1]);
        if (j !== undefined && j !== i) {
          adjIn[i].push(j);
          dependents.set(mods[j], (dependents.get(mods[j]) ?? 0) + 1);
        }
      }
    });
    return { n, mods, midx, adjIn, dependents };
  };
  const bsNew = (w) => new Uint32Array(w);
  const bsSet = (b, i) => { b[i >> 5] |= 1 << (i & 31); };
  const bsOrInto = (d, s) => { for (let k = 0; k < d.length; k++) d[k] |= s[k]; };
  const bsIntersects = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] & b[k]) return true; return false; };
  const bsSubset = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] & ~b[k]) return false; return true; };
  const bsEq = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] !== b[k]) return false; return true; };
  const bsAny = (a) => { for (let k = 0; k < a.length; k++) if (a[k]) return true; return false; };
  const downOf = (g) => {
    const { n, adjIn } = g;
    const w = (n + 31) >> 5;
    const down = new Array(n);
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
        const b = bsNew(w);
        bsSet(b, i);
        for (const j of adjIn[i]) bsOrInto(b, down[j]);
        down[i] = b; state[i] = 2; stack.pop();
      }
    }
    return { down, w };
  };

  // first-seen across the six checkpoints (Mathlib names are namespaced
  // with "ns/" as in 18, since the graphs are per-namespace)
  const fsMap = new Map();
  for (let ci = 0; ci < CHECKPOINTS.length; ci++)
    for (const ns of NAMESPACES) {
      const g = loadGraph(CHECKPOINTS[ci][1], ns);
      for (const m of g.mods) {
        const key = ns + "/" + m;
        if (!fsMap.has(key)) fsMap.set(key, ci);
      }
    }

  const deg = {}, fs = {}, cells = [];
  let kernelsUsed = 0;
  for (const ns of NAMESPACES) {
    const g = loadGraph(CHECKPOINTS[5][1], ns);
    const { down, w } = downOf(g);
    const { n, mods, dependents } = g;
    const perm = shuffled(n);
    let used = 0;
    for (const pi of perm) {
      if (used >= ML_KERNELS_PER_NS) break;
      const x = pi;
      const a = down[x];
      const notA = bsNew(w);
      for (let y = 0; y < n; y++) if (!bsIntersects(down[y], a)) bsSet(notA, y);
      if (!bsAny(notA)) continue;
      const nnA = bsNew(w);
      for (let y = 0; y < n; y++) if (!bsIntersects(down[y], notA)) bsSet(nnA, y);
      if (bsEq(nnA, a)) continue;
      let hasR = false, hasE = false, hasD = false;
      const strata = new Map();
      for (let y = 0; y < n; y++) {
        if (bsSubset(down[y], a)) continue;
        let cell;
        if (bsSubset(down[y], notA)) { cell = "R"; hasR = true; continue; }
        else if (bsSubset(down[y], nnA)) { cell = "E"; hasE = true; }
        else { cell = "D"; hasD = true; }
        const m = ns + "/" + mods[y];
        const d0 = dependents.get(mods[y]) ?? 0;
        const key = `${BIN(d0)}|${fsMap.get(m)}`;
        if (!strata.has(key)) strata.set(key, { E: [], D: [] });
        strata.get(key)[cell].push(m);
        deg[m] = d0; fs[m] = fsMap.get(m);
      }
      if (!(hasR && hasE && hasD)) continue;
      used++; kernelsUsed++;
      for (const [, s] of strata) {
        if (s.E.length && s.D.length)
          cells.push({ E: capped(s.E, ML_SIDE_CAP), D: capped(s.D, ML_SIDE_CAP) });
      }
    }
  }
  out.mathlib = {
    meta: {
      baseline: "2026-05 pin (lean/.lake/packages/mathlib)",
      namespaces: NAMESPACES, kernels: kernelsUsed,
      note: "dependents counted within the namespace subgraph, as mathlib-study/18",
    },
    deg, fs, cells,
  };
  console.log(`mathlib: kernels=${kernelsUsed} cells=${cells.length}`);
}

// =====================================================================
// Go / crates / AFP: SCC condensation gate (design of software-study/04).
// =====================================================================
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
  return { names, n, inDeg, nComp, cIn, cOut, compMembers };
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

const freezeCondensation = (label, snap, fsMap, kernelQuota, sideCap) => {
  const gate = makeGate(snap);
  const { nComp, compMembers, names, inDeg } = snap;
  const deg = {}, fs = {}, cells = [];
  const order = kernelQuota == null
    ? Array.from({ length: nComp }, (_, i) => i)
    : [...shuffled(nComp)];
  let used = 0;
  for (const a of order) {
    if (kernelQuota != null && used >= kernelQuota) break;
    const g = gate(a);
    if (!g) continue;
    used++;
    const strata = new Map();
    for (let c = 0; c < nComp; c++) {
      const cell = g.cellOf(c);
      if (cell === "I" || cell === "R") continue;
      const members = compMembers[c];
      if (members.length > 1) continue; // non-singleton: no unambiguous name
      const nm = names[members[0]];
      const d0 = inDeg.get(nm) ?? 0;
      const key = `${BIN(d0)}|${fsMap.get(nm)}`;
      if (!strata.has(key)) strata.set(key, { E: [], D: [] });
      strata.get(key)[cell].push(nm);
      deg[nm] = d0; fs[nm] = fsMap.get(nm);
    }
    for (const [, s] of strata) {
      if (s.E.length && s.D.length)
        cells.push({ E: capped(s.E, sideCap), D: capped(s.D, sideCap) });
    }
  }
  console.log(`${label}: kernels=${used} cells=${cells.length}`);
  return { kernels: used, deg, fs, cells };
};

// ---- Go ----
{
  const YEARS = [2016, 2018, 2020, 2022, 2024, 2026];
  const fsMap = new Map();
  for (let yi = 0; yi < YEARS.length; yi++) {
    const raw = JSON.parse(readFileSync(`software-study/history/go-${YEARS[yi]}.json`, "utf8"));
    for (const nm of raw.nodes) if (!fsMap.has(nm)) fsMap.set(nm, yi);
  }
  const raw = JSON.parse(readFileSync("software-study/history/go-2026.json", "utf8"));
  const snap = buildSnap(raw.nodes, raw.edges);
  const f = freezeCondensation("go", snap, fsMap, null, AFP_SIDE_CAP);
  out.go = { meta: { baseline: `go-2026 rev ${raw.rev}`, kernels: f.kernels }, deg: f.deg, fs: f.fs, cells: f.cells };
}

// ---- crates ----
{
  const YEARS = [2016, 2018, 2020, 2022, 2024, 2026];
  const fsMap = new Map();
  for (let yi = 0; yi < YEARS.length; yi++) {
    const raw = JSON.parse(readFileSync(`software-study/history/crates-${YEARS[yi]}.json`, "utf8"));
    for (const nm of raw.nodes) if (!fsMap.has(nm)) fsMap.set(nm, yi);
  }
  const raw = JSON.parse(readFileSync("software-study/history/crates-2026.json", "utf8"));
  const snap = buildSnap(raw.nodes, raw.edges);
  const f = freezeCondensation("crates", snap, fsMap, CRATES_KERNELS, CRATES_SIDE_CAP);
  out.crates = { meta: { baseline: `crates-2026 rev ${raw.rev}`, kernels: f.kernels }, deg: f.deg, fs: f.fs, cells: f.cells };
}

// ---- AFP ----
{
  const YEARS = [2006, 2008, 2010, 2012, 2014, 2016, 2018, 2020, 2022, 2024, 2026];
  const fsMap = new Map();
  for (let yi = 0; yi < YEARS.length; yi++) {
    const raw = JSON.parse(readFileSync(`afp-study/history/${YEARS[yi]}.json`, "utf8"));
    for (const nm of raw.entries) if (!fsMap.has(nm)) fsMap.set(nm, yi);
  }
  const raw = JSON.parse(readFileSync("afp-study/history/2026.json", "utf8"));
  const eidx = new Map(raw.entries.map((e, i) => [e, i]));
  const edges = raw.edges.map((s) => {
    const [a, b] = s.split(">");
    return [eidx.get(a), eidx.get(b)];
  });
  const snap = buildSnap(raw.entries, edges);
  const f = freezeCondensation("afp", snap, fsMap, null, AFP_SIDE_CAP);
  out.afp = { meta: { baseline: `afp 2026 rev ${raw.rev} (${raw.date})`, kernels: f.kernels }, deg: f.deg, fs: f.fs, cells: f.cells };
}

writeFileSync("predictions/frozen-2026.json.gz", gzipSync(JSON.stringify(out), { level: 9 }));
console.log("wrote predictions/frozen-2026.json.gz");
