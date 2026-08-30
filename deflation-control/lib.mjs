// Deflation control: shared loaders and cell/distance machinery.
//
// Uniform snapshot interface over the five corpora with history, matching
// the graphs used by the original growth studies exactly:
//   mathlib  — per-namespace module graphs, six checkpoints 2023-09..2026-05
//              (mathlib-study/18 loader);
//   afp      — entry graphs, eleven biennial checkpoints (afp-study/04/07);
//   isabelle — theory graphs, eleven biennial checkpoints (isabelle-study);
//   go, crates — package/crate graphs, six biennial checkpoints
//              (software-study/01/04).
// All are reduced to SCC condensations (mathlib/isabelle/go are acyclic;
// afp has one small knot; crates has small knots) with the same gate and
// cell classifier as mathlib-study/18 -> software-study/04 ->
// isabelle-study/03.
//
// New machinery for this study: per-kernel UNDIRECTED multi-source BFS
// distance from the kernel's down-set over the condensation. Distance is
// the skeptic's variable: "connected periphery grows, disconnected
// doesn't." Cells are matched on it exactly (unreachable = "inf").

import { readdirSync, readFileSync, statSync } from "node:fs";
import { join } from "node:path";

export const BIN = (d) => (d === 0 ? 0 : d <= 2 ? 1 : d <= 7 ? 2 : 3);

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

export const buildSnap = (names, edges) => {
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
  const cIn = Array.from({ length: nComp }, () => []);   // deps of x
  const cOut = Array.from({ length: nComp }, () => []);  // dependents of x
  const und = Array.from({ length: nComp }, () => []);   // undirected
  for (const x of eSet) {
    const a = Math.floor(x / 2000000), b = x % 2000000;
    cIn[a].push(b); cOut[b].push(a);
    und[a].push(b); und[b].push(a);
  }
  return { names, n, inDeg, nComp, cIn, cOut, und, compMembers };
};

// ---- evaluable-kernel gate + cell classifier (as the growth studies) ----
export const makeGate = (snap) => {
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
      downMembers,
      cellOf: (i) => {
        if (mDown[i] === st) return "I";
        if (mUp1[i] !== st) return "R";
        return mUp2[i] !== st ? "E" : "D";
      },
    };
  };
};

// undirected multi-source BFS from the kernel's down-set; -1 = unreachable
export const makeDistancer = (snap) => {
  const { nComp, und } = snap;
  const dist = new Int32Array(nComp);
  const mark = new Int32Array(nComp).fill(-1);
  const q = new Int32Array(nComp);
  let stamp = 0;
  return (seeds) => {
    const st = stamp++;
    let head = 0, tail = 0;
    for (const s of seeds) { mark[s] = st; dist[s] = 0; q[tail++] = s; }
    while (head < tail) {
      const v = q[head++];
      for (const u of und[v]) if (mark[u] !== st) { mark[u] = st; dist[u] = dist[v] + 1; q[tail++] = u; }
    }
    return (i) => (mark[i] === st ? dist[i] : -1);
  };
};

// ---- corpus loaders: () => { labels: string[], snaps: snap[], baselines: number[], horizon: number } ----

const importRe = /^(?:(?:public|private|meta)\s+)*import\s+([\w.]+)/gm;
const loadMathlibNs = (base, ns) => {
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
  const edges = [];
  files.forEach((p, i) => {
    const src = readFileSync(p, "utf8");
    for (const m of src.matchAll(importRe)) {
      const j = midx.get(m[1]);
      if (j !== undefined && j !== i) edges.push([i, j]);
    }
  });
  return { names: mods.map((m) => ns + "/" + m), edges };
};

const ML_CHECKPOINTS = [
  ".scratch_mathlib_hist/2023-09/Mathlib",
  ".scratch_mathlib_hist/2024-03/Mathlib",
  ".scratch_mathlib_hist/2024-09/Mathlib",
  ".scratch_mathlib_hist/2025-03/Mathlib",
  ".scratch_mathlib_hist/2025-09/Mathlib",
  "lean/.lake/packages/mathlib/Mathlib",
];

export const CORPORA = {
  // mathlib is handled per namespace: three sub-corpora pooled at scoring
  mathlib: () => {
    const subs = [];
    for (const ns of ["Order", "Topology", "Algebra"]) {
      const snaps = ML_CHECKPOINTS.map((base) => {
        const { names, edges } = loadMathlibNs(base, ns);
        return buildSnap(names, edges);
      });
      subs.push(snaps);
    }
    return { subs, baselines: [0, 1, 2, 3], horizon: 2 };
  },
  afp: () => {
    const YEARS = [2006, 2008, 2010, 2012, 2014, 2016, 2018, 2020, 2022, 2024, 2026];
    const snaps = YEARS.map((y) => {
      const raw = JSON.parse(readFileSync(`afp-study/history/${y}.json`, "utf8"));
      const eidx = new Map(raw.entries.map((e, i) => [e, i]));
      const edges = raw.edges.map((s) => {
        const [a, b] = s.split(">");
        return [eidx.get(a), eidx.get(b)];
      });
      return buildSnap(raw.entries, edges);
    });
    return { subs: [snaps], baselines: [0, 1, 2, 3, 4, 5, 6, 7, 8], horizon: 2 };
  },
  isabelle: () => {
    const YEARS = [2006, 2008, 2010, 2012, 2014, 2016, 2018, 2020, 2022, 2024, 2026];
    const snaps = YEARS.map((y) => {
      const raw = JSON.parse(readFileSync(`isabelle-study/history/${y}.json`, "utf8"));
      return buildSnap(raw.nodes, raw.edges);
    });
    return { subs: [snaps], baselines: [0, 1, 2, 3, 4, 5, 6, 7, 8], horizon: 2 };
  },
  go: () => {
    const YEARS = [2016, 2018, 2020, 2022, 2024, 2026];
    const snaps = YEARS.map((y) => {
      const raw = JSON.parse(readFileSync(`software-study/history/go-${y}.json`, "utf8"));
      return buildSnap(raw.nodes, raw.edges);
    });
    return { subs: [snaps], baselines: [0, 1, 2, 3], horizon: 2 };
  },
  crates: () => {
    const YEARS = [2016, 2018, 2020, 2022, 2024, 2026];
    const snaps = YEARS.map((y) => {
      const raw = JSON.parse(readFileSync(`software-study/history/crates-${y}.json`, "utf8"));
      return buildSnap(raw.nodes, raw.edges);
    });
    return { subs: [snaps], baselines: [0, 1, 2, 3], horizon: 2 };
  },
};

export const firstSeenOf = (snaps) => {
  const fs = new Map();
  snaps.forEach((snap, yi) => {
    for (const nm of snap.names) if (!fs.has(nm)) fs.set(nm, yi);
  });
  return fs;
};

// scale adaptations for crates, inherited from software-study/04
export const CRATES_KERNELS = 300, SIDE_CAP = 500;
