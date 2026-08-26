// AFP referendum, phase 0: blind structural census.
//
// Corpus: Archive of Formal Proofs, git mirror
// (github.com/isabelle-prover/mirror-afp-devel), HEAD pin
// 1e072b5cc6b4a19ed1f4f905feddb07b884c9f2c (2026-08-25), checked out at
// .scratch_afp (untracked).
//
// BLINDNESS DISCIPLINE (as mathlib-study 09/11/13/15): this script
// computes corpus sizes, import-parse and -resolution rates, graph
// dimensions at both candidate grains (theory-level and entry-level),
// per-entry topic label counts, and ordinariness/evaluability counts.
// It computes NO name/topic alignment of any cell and NO aperture. The
// registration (02) chooses its grain and criteria from these counts
// alone, before any measurement of the claims under test.
//
// Import syntax handled: the block between the first `imports` keyword
// after `theory <name>` and the following `begin`, names either bare
// (same-session theory), session-qualified (Session.Theory), or quoted
// (possibly relative paths). Comments (* ... *) inside the header are
// stripped. Resolution classes counted separately: within-entry,
// cross-entry (AFP session-qualified), distribution (HOL* and other
// Isabelle-bundled sessions — outside this corpus), unresolved-other.
//
// Writes afp-study/results-census.json.

import { readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { join, basename } from "node:path";

const ROOT = ".scratch_afp/thys";
const META = ".scratch_afp/metadata/entries";

// ---- collect theories per entry ----
const entries = readdirSync(ROOT).filter((d) => statSync(join(ROOT, d)).isDirectory()).sort();
const thyFiles = []; // { entry, name, path }
for (const e of entries) {
  const walk = (dir) => {
    for (const f of readdirSync(dir)) {
      const p = join(dir, f);
      if (statSync(p).isDirectory()) walk(p);
      else if (f.endsWith(".thy")) thyFiles.push({ entry: e, name: basename(f, ".thy"), path: p });
    }
  };
  walk(join(ROOT, e));
}

// index: theory name -> entries containing it; (entry, name) -> node id
const byName = new Map();
const nodeId = new Map();
thyFiles.forEach((t, i) => {
  nodeId.set(`${t.entry}/${t.name}`, i);
  if (!byName.has(t.name)) byName.set(t.name, []);
  byName.get(t.name).push(i);
});

// ---- parse imports ----
const stripComments = (s) => {
  let out = "", depth = 0;
  for (let i = 0; i < s.length; i++) {
    if (s[i] === "(" && s[i + 1] === "*") { depth++; i++; continue; }
    if (s[i] === "*" && s[i + 1] === ")" && depth > 0) { depth--; i++; continue; }
    if (depth === 0) out += s[i];
  }
  return out;
};

const stats = {
  theoriesWithHeader: 0, headerless: 0,
  tokens: 0, withinEntry: 0, crossEntry: 0, distribution: 0, unresolvedOther: 0,
};
const edgesThy = []; // [from, to] theory-level, AFP-internal only
const crossEntryPairs = new Set(); // "A>B" entry-level

const DIST_SESSIONS = /^(HOL|Pure|FOL|ZF|CCL|CTT|Cube|FOLP|LCF|Sequents|Tools|Doc)\b/;

for (const t of thyFiles) {
  const src = readFileSync(t.path, "utf8");
  const head = stripComments(src.slice(0, 20000));
  const m = head.match(/\btheory\b[\s\S]*?\bimports\b([\s\S]*?)\bbegin\b/);
  if (!m) { stats.headerless++; continue; }
  stats.theoriesWithHeader++;
  const toks = [];
  const re = /"([^"]+)"|([\w.\-/]+)/g;
  let g;
  while ((g = re.exec(m[1])) !== null) {
    const tok = (g[1] ?? g[2]).trim();
    if (tok === "keywords" || tok === "abbrevs") break; // header sections after imports
    if (tok) toks.push(tok);
  }
  const from = nodeId.get(`${t.entry}/${t.name}`);
  for (const tok of toks) {
    stats.tokens++;
    const clean = tok.replace(/\.thy$/, "");
    const last = clean.split("/").pop();
    // 1. session-qualified: Session.Theory
    const dot = last.lastIndexOf(".");
    if (dot > 0) {
      const sess = last.slice(0, dot), thy = last.slice(dot + 1);
      if (DIST_SESSIONS.test(sess)) { stats.distribution++; continue; }
      const to = nodeId.get(`${sess}/${thy}`);
      if (to !== undefined) {
        stats.crossEntry++;
        if (to !== from) { edgesThy.push([from, to]); crossEntryPairs.add(`${t.entry}>${sess}`); }
        continue;
      }
      stats.unresolvedOther++;
      continue;
    }
    // 2. bare / path-relative: same entry first, then unique global name
    const inEntry = nodeId.get(`${t.entry}/${last}`);
    if (inEntry !== undefined) {
      stats.withinEntry++;
      if (inEntry !== from) edgesThy.push([from, inEntry]);
      continue;
    }
    const global = byName.get(last);
    if (global && global.length === 1) {
      stats.crossEntry++;
      if (global[0] !== from) {
        edgesThy.push([from, global[0]]);
        crossEntryPairs.add(`${t.entry}>${thyFiles[global[0]].entry}`);
      }
      continue;
    }
    if (DIST_SESSIONS.test(last)) { stats.distribution++; continue; }
    stats.unresolvedOther++;
  }
}

// ---- entry-level graph + topics ----
const topicOf = {};
let entriesWithTopics = 0;
const topLevelTopicCounts = {};
for (const e of entries) {
  try {
    const toml = readFileSync(join(META, `${e}.toml`), "utf8");
    const tm = toml.match(/topics\s*=\s*\[([\s\S]*?)\]/);
    if (tm) {
      const topics = [...tm[1].matchAll(/"([^"]+)"/g)].map((x) => x[1]);
      if (topics.length) {
        topicOf[e] = topics;
        entriesWithTopics++;
        const top = topics[0].split("/")[0];
        topLevelTopicCounts[top] = (topLevelTopicCounts[top] ?? 0) + 1;
      }
    }
  } catch { /* no metadata file */ }
}

// ---- ordinariness/evaluability at the ENTRY grain (counts only) ----
const eIdx = new Map(entries.map((e, i) => [e, i]));
const nE = entries.length, wE = (nE + 31) >> 5;
const adjInE = Array.from({ length: nE }, () => new Set());
for (const pair of crossEntryPairs) {
  const [a, b] = pair.split(">");
  adjInE[eIdx.get(a)].add(eIdx.get(b));
}
const bsNew = (w) => new Uint32Array(w);
const bsSet = (b, i) => { b[i >> 5] |= 1 << (i & 31); };
const bsOrInto = (d, s) => { for (let k = 0; k < d.length; k++) d[k] |= s[k]; };
const bsIntersects = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] & b[k]) return true; return false; };
const bsSubset = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] & ~b[k]) return false; return true; };
const bsEq = (a, b) => { for (let k = 0; k < a.length; k++) if (a[k] !== b[k]) return false; return true; };
const bsAny = (a) => { for (let k = 0; k < a.length; k++) if (a[k]) return true; return false; };

const downOf = (n, w, adjIn) => {
  const down = new Array(n), state = new Uint8Array(n), stack = [];
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
  return down;
};

const gateCounts = (n, w, down) => {
  let ordinary = 0, evaluable = 0;
  for (let x = 0; x < n; x++) {
    const a = down[x];
    const notA = bsNew(w);
    for (let y = 0; y < n; y++) if (!bsIntersects(down[y], a)) bsSet(notA, y);
    if (!bsAny(notA)) continue;
    const nnA = bsNew(w);
    for (let y = 0; y < n; y++) if (!bsIntersects(down[y], notA)) bsSet(nnA, y);
    if (bsEq(nnA, a)) continue;
    ordinary++;
    let hasR = false, hasE = false, hasD = false;
    for (let y = 0; y < n; y++) {
      if (bsSubset(down[y], a)) continue;
      else if (bsSubset(down[y], notA)) hasR = true;
      else if (bsSubset(down[y], nnA)) hasE = true;
      else hasD = true;
    }
    if (hasR && hasE && hasD) evaluable++;
  }
  return { ordinary, evaluable };
};

// Cycles: Isabelle enforces acyclic theory imports, so theory-level cycles
// indicate resolution artifacts; entry-level cycles can also be genuine
// (two entries importing different theories of each other). Census reports
// SCC structure; the gate is computed on the entry condensation and
// labelled as such.
const sccOf = (n, adjOut) => {
  const idx = new Int32Array(n).fill(-1), low = new Int32Array(n),
    onStk = new Uint8Array(n), comp = new Int32Array(n).fill(-1);
  let counter = 0, nComp = 0;
  const stk = [];
  for (let s = 0; s < n; s++) {
    if (idx[s] !== -1) continue;
    const call = [[s, 0]];
    while (call.length) {
      const fr = call[call.length - 1];
      const v = fr[0];
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
        for (;;) {
          const u = stk.pop(); onStk[u] = 0; comp[u] = nComp;
          low[v] = low[v];
          if (u === v) break;
        }
        nComp++;
      }
      call.pop();
      if (call.length) {
        const p = call[call.length - 1][0];
        low[p] = Math.min(low[p], low[v]);
      }
    }
  }
  return { comp, nComp };
};

const adjOutE = Array.from({ length: nE }, () => []);
for (let i = 0; i < nE; i++) for (const j of adjInE[i]) adjOutE[j].push(i);
// SCC over the union direction (cycles are direction-independent for counting)
const adjBothE = Array.from({ length: nE }, (_, i) => [...adjInE[i]]);
const { comp: compE, nComp: nCompE } = sccOf(nE, adjBothE);
const sccSizes = new Array(nCompE).fill(0);
for (let i = 0; i < nE; i++) sccSizes[compE[i]]++;
const nontrivialSccs = sccSizes.filter((s) => s > 1).sort((a, b) => b - a);

// condensation
const cAdjIn = Array.from({ length: nCompE }, () => new Set());
for (let i = 0; i < nE; i++)
  for (const j of adjInE[i])
    if (compE[i] !== compE[j]) cAdjIn[compE[i]].add(compE[j]);
const wC = (nCompE + 31) >> 5;
const downC = downOf(nCompE, wC, cAdjIn);
const entryGate = gateCounts(nCompE, wC, downC);

// theory-level DAG check
const adjInT = Array.from({ length: thyFiles.length }, () => []);
for (const [a, b] of edgesThy) adjInT[a].push(b);
const { nComp: nCompT } = sccOf(thyFiles.length, adjInT);
const theoryHasCycles = nCompT < thyFiles.length;

// ---- theory-level graph dimensions (no gate counts here — cost noted for registration) ----
const nT = thyFiles.length;
const edgeSetT = new Set(edgesThy.map(([a, b]) => a * 100000 + b));

// per-entry theory counts (top 10 + quartiles)
const perEntry = entries.map((e) => thyFiles.filter((t) => t.entry === e).length).sort((a, b) => b - a);

const out = {
  pin: "1e072b5cc6b4a19ed1f4f905feddb07b884c9f2c",
  entries: nE,
  theories: nT,
  parse: stats,
  theoryGraph: { nodes: nT, afpInternalEdges: edgeSetT.size, hasCycles: theoryHasCycles, sccCount: nCompT },
  entryGraph: {
    nodes: nE, edges: crossEntryPairs.size,
    nontrivialSccs: nontrivialSccs.length, largestScc: nontrivialSccs[0] ?? 1,
    condensationNodes: nCompE, gateOnCondensation: entryGate,
  },
  topics: { entriesWithTopics, topLevel: topLevelTopicCounts },
  perEntryTheoryCounts: {
    top10: perEntry.slice(0, 10),
    median: perEntry[Math.floor(perEntry.length / 2)],
    p90: perEntry[Math.floor(perEntry.length * 0.1)],
  },
};
writeFileSync("afp-study/results-census.json", JSON.stringify(out, null, 1));
console.log(JSON.stringify(out, null, 1));
