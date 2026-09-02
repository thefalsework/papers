#!/usr/bin/env node
// SPDX-License-Identifier: Apache-2.0
// oracle-rank — rank a dependency graph by concentration of reach.
//
//   ORACLE(x) = sum over packages u whose truncated dependency cone
//               contains x of 1/|cone(u)|
//
// "Count every toolchain you are part of, weighting each by the
// reciprocal of its size." High ORACLE + low direct-dependent count is
// the quiet load-bearing profile (liblzma, unicode-ident). Background
// and validation: preprints/quiet-criticality/paper.md in this repo.
//
// Self-contained: no dependencies, single file. Handles cycles via SCC
// condensation (members of a cycle share a score).
//
// Deterministic: cones are truncated at --cap, and traversal order is
// fixed by sorting adjacency by package name before the BFS, so the
// same graph produces byte-identical output regardless of how the
// input file happens to be ordered.
//
// USAGE
//   node oracle-rank.mjs <input> [--cap N] [--top N] [--out FILE]
//
//   <input>  dependency graph, one of:
//            - Cargo.lock: parsed directly ("node oracle-rank.mjs
//              Cargo.lock --top 50" works on any Rust project).
//              Both dependency entry forms resolve ("serde" and
//              "serde 1.0.188"). Versions are COLLAPSED to package
//              names: a crate present at two versions is one node
//              whose dependency set is the union — consistent with
//              the package-level Debian and crates.io rankings
//              published alongside this tool;
//            - .json: {"nodes":[names...],"edges":[[depIdx,depIdx]...]}
//              (edges as [dependent, dependency] index pairs), or a
//              plain JSON array of [dependent, dependency] name pairs;
//            - anything else: text edge list, one "dependent,dependency"
//              per line (comma, tab, or space separated; a first line
//              containing "depend" is treated as a header and skipped).
//   --cap N  cone truncation (default 200; rankings are insensitive
//            50..800 on tested corpora).
//   --top N  emit only the top N rows (default: all).
//   --out F  write CSV to file F (default: stdout).
//
// OUTPUT CSV columns:
//   oracle_rank, name, oracle, direct_dependents, dependents_rank
// Sorted by oracle_rank. The interesting rows for supply-chain triage
// are those where oracle_rank << dependents_rank.

import { readFileSync, writeFileSync } from "node:fs";

// ---- args ----
const args = process.argv.slice(2);
if (!args.length || args.includes("--help") || args.includes("-h")) {
  console.error("usage: node oracle-rank.mjs <input> [--cap N] [--top N] [--out FILE]");
  process.exit(args.length ? 0 : 1);
}
const input = args[0];
const flag = (name, dflt) => {
  const i = args.indexOf(name);
  return i === -1 ? dflt : args[i + 1];
};
const CAP = +flag("--cap", 200);
const TOP = +flag("--top", 0);
const OUT = flag("--out", null);

// ---- load edges as name pairs ----
let names = [], edges = []; // edges: [dependentIdx, dependencyIdx]
const idx = new Map();
const id = (nm) => {
  let i = idx.get(nm);
  if (i === undefined) { i = names.length; idx.set(nm, i); names.push(nm); }
  return i;
};
const text = readFileSync(input, "utf8");
const isCargoLock = /(^|[\\/])Cargo\.lock$/.test(input) ||
  (!input.endsWith(".json") && /^\[\[package\]\]/m.test(text));
if (isCargoLock) {
  // Cargo.lock: [[package]] blocks with name = "..." followed by an
  // optional dependencies = [ "name", "name version", ... ] array.
  let cur = null, inDeps = false;
  for (const rawLine of text.split("\n")) {
    const line = rawLine.trim();
    if (line === "[[package]]") { cur = null; inDeps = false; continue; }
    if (inDeps) {
      if (line.startsWith("]")) { inDeps = false; continue; }
      const dep = line.match(/^"([^" ]+)/);
      if (dep && cur !== null) edges.push([cur, id(dep[1])]);
      continue;
    }
    const nm = line.match(/^name = "([^"]+)"/);
    if (nm) { cur = id(nm[1]); continue; }
    if (line.startsWith("dependencies = [") && !line.includes("]")) inDeps = true;
  }
} else if (input.endsWith(".json")) {
  const raw = JSON.parse(text);
  if (Array.isArray(raw)) {
    for (const [a, b] of raw) edges.push([id(String(a)), id(String(b))]);
  } else {
    names = raw.nodes.map(String);
    names.forEach((nm, i) => idx.set(nm, i));
    edges = raw.edges;
  }
} else {
  const lines = text.split("\n");
  let start = 0;
  if (lines[0] && /depend/i.test(lines[0])) start = 1;
  for (let li = start; li < lines.length; li++) {
    const line = lines[li].trim();
    if (!line || line.startsWith("#")) continue;
    const parts = line.split(/[,\t ]+/);
    if (parts.length < 2) continue;
    edges.push([id(parts[0]), id(parts[1])]);
  }
}
const n = names.length;
if (!n) { console.error("no nodes parsed"); process.exit(1); }

// dedupe edges, drop self-loops
{
  const seen = new Set();
  const clean = [];
  for (const [a, b] of edges) {
    if (a === b) continue;
    // string key: numeric packing (a * 2^32 + b) silently collides past
    // ~2M nodes (2^53 limit), which npm-scale graphs would hit
    const k = a + ":" + b;
    if (seen.has(k)) continue;
    seen.add(k);
    clean.push([a, b]);
  }
  edges = clean;
}

// package-level direct dependents
const directDeps = new Int32Array(n);
for (const [, b] of edges) directDeps[b]++;

// adjacency (dependency direction: node -> its dependencies)
const depHead = new Int32Array(n).fill(-1);
const depNext = new Int32Array(edges.length);
const depTo = new Int32Array(edges.length);
edges.forEach(([a, b], e) => { depTo[e] = b; depNext[e] = depHead[a]; depHead[a] = e; });

// ---- iterative Tarjan SCC ----
const comp = new Int32Array(n).fill(-1);
{
  const index = new Int32Array(n).fill(-1);
  const low = new Int32Array(n);
  const onStack = new Uint8Array(n);
  const stack = [];
  let counter = 0, nComp = 0;
  const frameNode = [], frameEdge = [];
  for (let s = 0; s < n; s++) {
    if (index[s] !== -1) continue;
    frameNode.push(s); frameEdge.push(depHead[s]);
    index[s] = low[s] = counter++; stack.push(s); onStack[s] = 1;
    while (frameNode.length) {
      const v = frameNode[frameNode.length - 1];
      let e = frameEdge[frameNode.length - 1];
      let advanced = false;
      while (e !== -1) {
        const w = depTo[e];
        e = depNext[e];
        if (index[w] === -1) {
          frameEdge[frameNode.length - 1] = e;
          frameNode.push(w); frameEdge.push(depHead[w]);
          index[w] = low[w] = counter++; stack.push(w); onStack[w] = 1;
          advanced = true;
          break;
        } else if (onStack[w]) {
          if (index[w] < low[v]) low[v] = index[w];
        }
      }
      if (advanced) continue;
      frameNode.pop(); frameEdge.pop();
      if (low[v] === index[v]) {
        for (;;) {
          const w = stack.pop(); onStack[w] = 0; comp[w] = nComp;
          if (w === v) break;
        }
        nComp++;
      }
      if (frameNode.length) {
        const p = frameNode[frameNode.length - 1];
        if (low[v] < low[p]) low[p] = low[v];
      }
    }
  }
  var NC = nComp;
}

// canonicalize component ids (sorted by lexicographically minimal
// member name): Tarjan's numbering depends on edge order in the input,
// and it sets the float accumulation order below — without this,
// last-ulp summation noise makes tie groups split differently across
// reorderings of the same graph
{
  const repName = new Array(NC);
  for (let i = 0; i < n; i++) {
    const c = comp[i];
    if (repName[c] === undefined || names[i] < repName[c]) repName[c] = names[i];
  }
  const perm = Array.from({ length: NC }, (_, c) => c)
    .sort((x, y) => (repName[x] < repName[y] ? -1 : 1));
  const newId = new Int32Array(NC);
  perm.forEach((old, ni) => { newId[old] = ni; });
  for (let i = 0; i < n; i++) comp[i] = newId[comp[i]];
}

// condensation adjacency (component -> component dependencies, unique)
const cDeps = Array.from({ length: NC }, () => []);
{
  const seen = new Set();
  for (const [a, b] of edges) {
    const ca = comp[a], cb = comp[b];
    if (ca === cb) continue;
    const k = ca + ":" + cb;
    if (seen.has(k)) continue;
    seen.add(k);
    cDeps[ca].push(cb);
  }
}

// sort adjacency (ids are canonical, so this is by representative
// name) so that cone truncation at the cap boundary does not depend on
// the order edges appeared in the input file
for (const list of cDeps) list.sort((x, y) => x - y);

// ---- ORACLE over the condensation ----
const orc = new Float64Array(NC);
{
  const seen = new Int32Array(NC).fill(-1);
  for (let u = 0; u < NC; u++) {
    const cone = [];
    seen[u] = u;
    const q = [u];
    let qi = 0;
    while (qi < q.length && cone.length < CAP) {
      const v = q[qi++];
      for (const w of cDeps[v]) {
        if (seen[w] === u) continue;
        seen[w] = u;
        cone.push(w);
        // intentional: cone is full, remaining neighbors of v are
        // dropped (this is the truncation; adjacency is pre-sorted
        // above so the drop is deterministic)
        if (cone.length >= CAP) break;
        q.push(w);
      }
    }
    if (!cone.length) continue;
    const credit = 1 / cone.length;
    for (const x of cone) orc[x] += credit;
  }
}

// ---- ranks and output ----
const oracleOf = (i) => orc[comp[i]];
const rankOf = (valOf) => {
  const order = Array.from({ length: n }, (_, i) => i)
    .sort((a, b) => valOf(b) - valOf(a) || (names[a] < names[b] ? -1 : 1));
  const ranks = new Int32Array(n);
  let i = 0;
  while (i < n) {
    let j = i;
    while (j + 1 < n && valOf(order[j + 1]) === valOf(order[i])) j++;
    for (let k = i; k <= j; k++) ranks[order[k]] = i + 1; // min rank for ties
    i = j + 1;
  }
  return { order, ranks };
};
const { order, ranks: rOr } = rankOf(oracleOf);
const { ranks: rDeg } = rankOf((i) => directDeps[i]);

const limit = TOP > 0 ? Math.min(TOP, n) : n;
const rows = ["oracle_rank,name,oracle,direct_dependents,dependents_rank"];
for (let k = 0; k < limit; k++) {
  const i = order[k];
  rows.push(`${rOr[i]},${names[i]},${oracleOf(i).toFixed(4)},${directDeps[i]},${rDeg[i]}`);
}
const csv = rows.join("\n") + "\n";
if (OUT) { writeFileSync(OUT, csv); console.error(`wrote ${OUT} (${limit} rows of ${n} nodes, cap ${CAP})`); }
else process.stdout.write(csv);
