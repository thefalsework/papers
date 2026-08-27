// Software pair (garden/museum), phase 1: blind structural census.
//
// Protocol: software-study/PROTOCOL.md v1.0 (committed 2026-08-26, before
// any acquisition). This script is phase 1 of its fixed execution order.
//
// BLINDNESS DISCIPLINE (as afp-study/01, mathlib-study/09/11/13/15): this
// script computes corpus sizes, parse and resolution rates, graph
// dimensions, cycle structure (SCC condensation), and evaluable-kernel
// COUNTS per checkpoint. It computes NO name/category alignment of any
// cell, NO aperture, and NO cross-checkpoint comparison (rewiring rates
// are script 02's job, where the MC1 gate is scored). Nothing here can
// leak any of the four registered quadrant predictions.
//
// CORPORA (acquisition log, 2026-08-27):
//   Garden: golang/go, bare clone .scratch_go.git (full history; HEAD
//     fba9e4b2d093b59898003208f5b8c08c2b4fc01f, 2026-08-27). Standard
//     library = packages under src/, excluding src/cmd/** (toolchain, not
//     library), vendor/ and testdata/ subtrees, and _test.go files.
//   Museum: the crates.io index. ACQUISITION FACT, logged per protocol
//     §7: the index repo squashes master periodically — the live repo's
//     history root is 2026-08-19, so it cannot supply any registered
//     checkpoint. Pre-squash history is preserved by the same owner in
//     rust-lang/crates.io-index-archive as snapshot-* branches; this is
//     the same object (the index) on its official archival mirror, so the
//     registered acquisition source is unchanged in substance. Shallow
//     fetches (--shallow-since = June 25 of the checkpoint year) into
//     .scratch_crates_hist.git of:
//       snapshot-2018-09-26  (covers checkpoints 2016, 2018)
//       snapshot-2020-08-04  (2020)
//       snapshot-2022-07-06  (2022)
//       snapshot-2024-09-08  (2024)
//       snapshot-2026-08-19  (2026)
//
// CHECKPOINT RULE (protocol §2): last commit on or before July 1 of each
// year in {2016, 2018, 2020, 2022, 2024, 2026}, i.e. rev-list -1
// --before="YYYY-07-02T00:00:00Z" on the stated branch. Resolved SHAs are
// recorded in the output.
//
// EDGE RULES (protocol §2, operationalized here, fixed before first run):
//   Go: package A -> package B when any non-test .go file of A imports B
//     and B is a stdlib package present at the checkpoint. Imports parsed
//     from comment-stripped source (single and block forms). Imports of
//     cmd/*, vendored, and external paths are counted, not edges.
//     PLUMBING REPAIR (2026-08-27, census phase, before any gate was
//     scored): the first census run produced a 188-package SCC —
//     impossible, the Go compiler enforces acyclic imports — traced to
//     build-ignored GENERATOR files (e.g. strconv/makeisprint.go,
//     math/bits/make_tables.go, tagged //go:build ignore) whose imports
//     of fmt/log/os/go-format are not part of the package. Files carrying
//     an "ignore" build constraint are now skipped and counted. Same
//     class of fix as afp-study/02's signed-int32 repair: instrument
//     plumbing, corrected before measurement.
//   crates: crate A -> crate B when the LAST non-yanked published version
//     of A at the checkpoint declares a dependency on B with
//     kind == "normal" (or absent) and optional == false. Renames resolve
//     via the "package" field. Target-conditional normal deps are
//     included (counted separately). Deps naming crates absent from the
//     checkpoint index are counted unresolved, not edges.
//
// EVALUABLE-KERNEL GATE (counts only, for MC2 which is scored in 02):
// on the SCC condensation (as afp-study/01), a kernel a is evaluable iff
// ordinary (neither dense nor regular) with R, E, D cells all nonempty.
// On a down-set algebra the cells are decidable by node membership:
//   down(a) = backward closure of a;  N = complement of up(down(a));
//   NN = complement of up(N);  I = down(a); R = N; E = NN \ down(a);
//   D = the rest. Dense iff N empty; regular iff NN == down(a).
// Each kernel costs O(V+E) by BFS — no bitsets. Where the condensation
// exceeds SAMPLE_LIMIT nodes, the census counts over a seeded uniform
// sample of SAMPLE_N kernels and reports the method; MC2's threshold
// (>= 3 evaluable) is decidable either way.
//
// PRNG seed 20260827 (mulberry32). Writes:
//   software-study/results-census.json           (summary, committed)
//   software-study/history/go-YYYY.json          (node/edge lists)
//   software-study/history/crates-YYYY.json      (node/edge lists)
// Large history files may stay untracked; regeneration = rerun this
// script against the pinned SHAs.

import { execSync } from "node:child_process";
import { writeFileSync, mkdirSync } from "node:fs";

const YEARS = [2016, 2018, 2020, 2022, 2024, 2026];
const GO_REPO = ".scratch_go.git";
const CR_REPO = ".scratch_crates_hist.git";
const CR_BRANCH = {
  2016: "snapshot-2018-09-26", 2018: "snapshot-2018-09-26",
  2020: "snapshot-2020-08-04", 2022: "snapshot-2022-07-06",
  2024: "snapshot-2024-09-08", 2026: "snapshot-2026-08-19",
};
const SAMPLE_LIMIT = 8000, SAMPLE_N = 2000, SEED = 20260827;

mkdirSync("software-study/history", { recursive: true });

const git = (repo, cmd, opts = {}) =>
  execSync(`git -C ${repo} ${cmd}`, { encoding: "utf8", maxBuffer: 1024 * 1024 * 1024, ...opts });

const revAt = (repo, branch, year) => {
  const rev = git(repo, `rev-list -1 --before="${year}-07-02T00:00:00Z" ${branch}`).trim();
  if (!rev) throw new Error(`no commit before cutoff ${year} on ${branch}`);
  const date = git(repo, `log -1 --format=%ci ${rev}`).trim();
  return { rev, date };
};

// ---- blob streaming: sha list -> callback(sha, contentBuffer) ----
const catBlobs = (repo, shas, onBlob, chunk = 300) => {
  for (let c = 0; c < shas.length; c += chunk) {
    const part = shas.slice(c, c + chunk);
    const raw = execSync(`git -C ${repo} cat-file --batch`, {
      input: part.join("\n") + "\n", maxBuffer: 2 * 1024 * 1024 * 1024,
    });
    let off = 0;
    for (const sha of part) {
      const nl = raw.indexOf(10, off);
      const hdr = raw.toString("utf8", off, nl).split(" ");
      const size = parseInt(hdr[2], 10);
      onBlob(sha, raw.subarray(nl + 1, nl + 1 + size));
      off = nl + 1 + size + 1;
    }
  }
};

// ---- mulberry32 ----
const mulberry32 = (a) => () => {
  a |= 0; a = (a + 0x6D2B79F5) | 0;
  let t = Math.imul(a ^ (a >>> 15), 1 | a);
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};

// ---- Tarjan SCC (iterative; adjOut as arrays) ----
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

// ---- evaluability gate on a DAG via per-kernel BFS ----
// adjIn[i] = nodes i depends on (imports); adjOut[i] = dependents of i.
const gateCensus = (n, adjIn, adjOut, sampleRng) => {
  const kernels = [];
  if (n <= SAMPLE_LIMIT) for (let i = 0; i < n; i++) kernels.push(i);
  else {
    const seen = new Set();
    while (kernels.length < SAMPLE_N) {
      const k = Math.floor(sampleRng() * n);
      if (!seen.has(k)) { seen.add(k); kernels.push(k); }
    }
  }
  // three stamp arrays: down(a), up(down(a)), up(N); stamped per kernel
  const mDown = new Int32Array(n).fill(-1);
  const mUp1 = new Int32Array(n).fill(-1);
  const mUp2 = new Int32Array(n).fill(-1);
  const q = new Int32Array(n);
  const closure = (seeds, adj, mark, st) => {
    let head = 0, tail = 0;
    for (const s of seeds) if (mark[s] !== st) { mark[s] = st; q[tail++] = s; }
    while (head < tail) {
      const v = q[head++];
      for (const u of adj[v]) if (mark[u] !== st) { mark[u] = st; q[tail++] = u; }
    }
    return tail;
  };
  let ordinary = 0, evaluable = 0, dense = 0, regular = 0;
  for (let ki = 0; ki < kernels.length; ki++) {
    const a = kernels[ki], st = ki;
    closure([a], adjIn, mDown, st);
    const downMembers = [];
    for (let i = 0; i < n; i++) if (mDown[i] === st) downMembers.push(i);
    closure(downMembers, adjOut, mUp1, st);
    const Nmembers = [];
    for (let i = 0; i < n; i++) if (mUp1[i] !== st) Nmembers.push(i);
    if (Nmembers.length === 0) { dense++; continue; }
    closure(Nmembers, adjOut, mUp2, st);
    // cells: I = down(a); R = N; E = (outside up(N)) \ down(a); D = rest
    let hasE = false, hasD = false;
    for (let i = 0; i < n; i++) {
      if (mDown[i] === st) continue;              // I
      if (mUp1[i] !== st) continue;               // R (member of N)
      if (mUp2[i] !== st) hasE = true;            // in NN beyond down(a)
      else hasD = true;                           // straddles
      if (hasE && hasD) break;
    }
    if (!hasE) {
      // NN == down(a): regular (no double-negation residue)
      regular++; continue;
    }
    ordinary++;
    if (hasD) evaluable++;
  }
  return {
    method: n <= SAMPLE_LIMIT ? "exact" : `sample-${SAMPLE_N}-seed-${SEED}`,
    kernelsTested: kernels.length, dense, regular, ordinary, evaluable,
  };
};

// ---- GO: packages + edges at a checkpoint ----
const goCheckpoint = (year) => {
  const { rev, date } = revAt(GO_REPO, "master", year);
  const ls = git(GO_REPO, `ls-tree -r ${rev} src`);
  const files = []; // { pkg, sha }
  for (const line of ls.split("\n")) {
    if (!line) continue;
    const tab = line.indexOf("\t");
    const path = line.slice(tab + 1);
    if (!path.endsWith(".go") || path.endsWith("_test.go")) continue;
    if (path.startsWith("src/cmd/")) continue;
    if (path.includes("/vendor/") || path.startsWith("src/vendor/")) continue;
    if (path.includes("/testdata/")) continue;
    const sha = line.slice(0, tab).split(" ")[2];
    const dir = path.slice(4, path.lastIndexOf("/")); // strip "src/"
    if (!dir) continue; // files directly under src/
    files.push({ pkg: dir, sha });
  }
  const stats = { files: files.length, buildIgnored: 0, packages: 0, importTokens: 0, resolved: 0, cmd: 0, externalOrVendored: 0, unresolved: 0 };
  const stripGo = (s) =>
    s.replace(/\/\*[\s\S]*?\*\//g, "").replace(/^\s*\/\/.*$/gm, "");
  const isBuildIgnored = (raw) =>
    /^\/\/go:build .*\bignore\b/m.test(raw.slice(0, 2000)) ||
    /^\/\/ \+build .*\bignore\b/m.test(raw.slice(0, 2000));
  // pass 1: stream blobs, collect per-file import tokens (skip generators)
  const parsed = []; // { pkg, toks }
  let fi = 0;
  catBlobs(GO_REPO, files.map((f) => f.sha), (sha, buf) => {
    const f = files[fi++];
    const raw = buf.toString("utf8");
    if (isBuildIgnored(raw)) { stats.buildIgnored++; return; }
    const src = stripGo(raw);
    const toks = [];
    for (const m of src.matchAll(/\bimport\s*\(([\s\S]*?)\)/g))
      for (const q of m[1].matchAll(/"([^"]+)"/g)) toks.push(q[1]);
    for (const m of src.matchAll(/\bimport\s+(?:[\w.]+\s+)?"([^"]+)"/g)) toks.push(m[1]);
    parsed.push({ pkg: f.pkg, toks });
  });
  // pass 2: package set from non-ignored files; resolve edges
  const pkgs = [...new Set(parsed.map((p) => p.pkg))].sort();
  stats.packages = pkgs.length;
  const pid = new Map(pkgs.map((p, i) => [p, i]));
  const pairs = new Set();
  for (const p of parsed) {
    for (const t of p.toks) {
      stats.importTokens++;
      if (pid.has(t)) {
        stats.resolved++;
        if (t !== p.pkg) pairs.add(pid.get(p.pkg) * 1000000 + pid.get(t));
      } else if (t.startsWith("cmd/")) stats.cmd++;
      else if (t.includes(".")) stats.externalOrVendored++;
      else stats.unresolved++;
    }
  }
  const edges = [...pairs].map((x) => [Math.floor(x / 1000000), x % 1000000]);
  return { rev, date, nodes: pkgs, edges, stats };
};

// ---- CRATES: crates + edges at a checkpoint ----
const cratesCheckpoint = (year) => {
  const { rev, date } = revAt(CR_REPO, CR_BRANCH[year], year);
  const ls = git(CR_REPO, `ls-tree -r ${rev}`);
  const files = []; // { name, sha }
  for (const line of ls.split("\n")) {
    if (!line) continue;
    const tab = line.indexOf("\t");
    const path = line.slice(tab + 1);
    const base = path.slice(path.lastIndexOf("/") + 1);
    if (base === "config.json" || path.startsWith(".github/") || base === "README.md") continue;
    const sha = line.slice(0, tab).split(" ")[2];
    files.push({ name: base.toLowerCase(), sha });
  }
  const stats = {
    crateFiles: files.length, parsedCrates: 0, allYanked: 0, badJson: 0,
    depTokens: 0, resolved: 0, unresolved: 0, targetConditional: 0,
  };
  const depOf = new Map(); // name -> Set of dep names
  let fi = 0;
  catBlobs(CR_REPO, files.map((f) => f.sha), (sha, buf) => {
    const f = files[fi++];
    const txt = buf.toString("utf8");
    let chosen = null;
    // last non-yanked published version
    const lines = txt.split("\n");
    for (let i = lines.length - 1; i >= 0; i--) {
      const ln = lines[i].trim();
      if (!ln) continue;
      try {
        const v = JSON.parse(ln);
        if (v.yanked === true) continue;
        chosen = v; break;
      } catch { stats.badJson++; continue; }
    }
    if (!chosen) { stats.allYanked++; return; }
    stats.parsedCrates++;
    const deps = new Set();
    for (const d of chosen.deps ?? []) {
      const kind = d.kind ?? "normal";
      if (kind !== "normal" || d.optional === true) continue;
      stats.depTokens++;
      if (d.target != null) stats.targetConditional++;
      deps.add((d.package ?? d.name).toLowerCase());
    }
    depOf.set(f.name, deps);
  });
  const names = [...depOf.keys()].sort();
  const nid = new Map(names.map((nm, i) => [nm, i]));
  const pairs = new Set();
  for (const [nm, deps] of depOf) {
    const from = nid.get(nm);
    for (const d of deps) {
      const to = nid.get(d);
      if (to === undefined) { stats.unresolved++; continue; }
      stats.resolved++;
      if (to !== from) pairs.add(from * 1000000 + to);
    }
  }
  const edges = [...pairs].map((x) => [Math.floor(x / 1000000), x % 1000000]);
  return { rev, date, nodes: names, edges, stats };
};

// ---- per-checkpoint graph analysis (SCC, condensation, gate) ----
const analyze = (nodes, edges, rng) => {
  const n = nodes.length;
  const adjOut = Array.from({ length: n }, () => []);
  for (const [a, b] of edges) adjOut[a].push(b); // direction: a depends-on b; SCC over directed graph
  const { comp, nComp } = sccOf(n, adjOut);
  const sizes = new Array(nComp).fill(0);
  for (let i = 0; i < n; i++) sizes[comp[i]]++;
  const nontrivial = sizes.filter((s) => s > 1).sort((x, y) => y - x);
  // condensation: cIn[c] = comps c depends on; cOut = dependents
  const cInS = Array.from({ length: nComp }, () => new Set());
  for (const [a, b] of edges) if (comp[a] !== comp[b]) cInS[comp[a]].add(comp[b]);
  const cIn = cInS.map((s) => [...s]);
  const cOut = Array.from({ length: nComp }, () => []);
  for (let c = 0; c < nComp; c++) for (const d of cIn[c]) cOut[d].push(c);
  const gate = gateCensus(nComp, cIn, cOut, rng);
  return {
    nodes: n, edges: edges.length,
    nontrivialSccs: nontrivial.length, largestScc: nontrivial[0] ?? 1,
    condensationNodes: nComp, gate,
  };
};

// ---- run ----
const out = { protocol: "software-study/PROTOCOL.md v1.0", ranAt: new Date().toISOString(), go: {}, crates: {} };
const rng = mulberry32(SEED);
for (const year of YEARS) {
  console.log(`== go ${year} ==`);
  const g = goCheckpoint(year);
  writeFileSync(`software-study/history/go-${year}.json`,
    JSON.stringify({ year, rev: g.rev, date: g.date, nodes: g.nodes, edges: g.edges }));
  out.go[year] = { rev: g.rev, date: g.date, stats: g.stats, graph: analyze(g.nodes, g.edges, rng) };
  console.log(JSON.stringify(out.go[year].graph));
}
for (const year of YEARS) {
  console.log(`== crates ${year} ==`);
  const c = cratesCheckpoint(year);
  writeFileSync(`software-study/history/crates-${year}.json`,
    JSON.stringify({ year, rev: c.rev, date: c.date, nodes: c.nodes, edges: c.edges }));
  out.crates[year] = { rev: c.rev, date: c.date, stats: c.stats, graph: analyze(c.nodes, c.edges, rng) };
  console.log(JSON.stringify(out.crates[year].graph));
}
writeFileSync("software-study/results-census.json", JSON.stringify(out, null, 1));
console.log("census written");
