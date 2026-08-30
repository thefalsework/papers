// Referee study (Phase 2, RF2 prep): extract theory-level import graphs
// of the ISABELLE DISTRIBUTION at biennial checkpoints, 2006-2026.
//
// BLIND: this script materializes node/edge lists per checkpoint — no
// measures, no cones, no cells, no gains. The registered study (03)
// computes everything from the committed lists. Same discipline as
// afp-study/04.
//
// Corpus: git mirror github.com/isabelle-prover/mirror-isabelle, bare
// blobless clone at .scratch_isabelle.git (untracked). Checkpoint rule
// as afp-study/04 — for each year Y in {2006, 2008, .., 2026}, the last
// commit before Y-01-01 (UTC) — WITH ONE TIGHTENING, logged as a
// plumbing repair (2026-08-30, before any measurement): the walk is
// restricted to the FIRST-PARENT line of the default branch. Without
// it, the Mercurial-converted history hands 2010 a grafted side-line
// commit whose tree is just the jEdit subtree (38 files, 0 theories).
// With it, theory counts are monotone (834 -> 1,843) across all eleven
// checkpoints. Resolved 2026-08-30 (first-parent):
//   2006 be8f786c  2008 e7fa1932  2010 559be60d  2012 a1032ffb
//   2014 2d5ac697  2016 9b94815f  2018 ddb9b3d1  2020 08fd3521
//   2022 b318c401  2024 eba47215  2026 e6827a68
//
// Grain: THEORY FILES under src/ (module grain, as Mathlib), identified
// by path without extension, e.g. "HOL/Library/Multiset". This is the
// distribution the same community maintains continuously — the garden
// half of the within-community contrast; AFP (entry grain) is the
// museum half. Grain difference is declared: AFP entries are paper-
// sized, distribution theories are file-sized; the growth design is
// grain-agnostic (it needs only nodes, edges, and identity over time).
//
// Import resolution (theory headers, comments stripped, same tokenizer
// as afp-study/04):
//   1. "Session.Theory" qualified tokens: resolved by BASENAME
//      (the trailing component after the last dot) — session-to-
//      directory mapping is not stable across two decades, so
//      basename-unique resolution is used and the ambiguity rate
//      is reported by the census (02).
//   2. plain "Theory" tokens: resolved to a same-directory sibling if
//      present, else by unique global basename.
//   3. quoted relative paths ("../X/Y"): resolved against the
//      importing file's directory.
//   Unresolved and ambiguous tokens are counted and reported — the
//   same stated-approximation discipline as AFP's 8%.
//
// Partial-clone plumbing: tree objects are local; blobs are fetched
// per checkpoint in bulk (batch-check to find missing, then git fetch
// with explicit OIDs in chunks) before cat-file --batch reads them.
//
// Writes isabelle-study/history/<year>.json { year, rev, date, nodes,
// edges: [[i,j], ...] } (i imports j; j gains a dependent).

import { execFileSync } from "node:child_process";
import { writeFileSync, mkdirSync, existsSync } from "node:fs";

const REPO = ".scratch_isabelle.git";
const CHECKPOINTS = [
  [2006, "be8f786cc83c99a5ecf1ae513e083803aceff3c6"],
  [2008, "e7fa1932ee27170f6900ac58819bfc173a7fd8a9"],
  [2010, "559be60d2aaab4ffcbbe5e2471fdcc0bbd04c284"],
  [2012, "a1032ffb4a5062e3d0e82f6f0e8674698c6d9a59"],
  [2014, "2d5ac697f421b9f5b2b6ef83cf137b33ef467041"],
  [2016, "9b94815fc87591379fa881bd930861dc5fcf92be"],
  [2018, "ddb9b3d176b025223cc9bf575346f3b837c3cc9f"],
  [2020, "08fd352199c2ee44c100befd2dda488c0d9e891a"],
  [2022, "b318c4010e4a515298b7619580f0a179d73e5aff"],
  [2024, "eba472154d6d800ae2cfc8534f07dc0551123774"],
  [2026, "e6827a688d9a3f8e2cefb755ca5c0eaf4348852f"],
];

mkdirSync("isabelle-study/history", { recursive: true });

const git = (args, input, noLazy = false) =>
  execFileSync("git", ["-C", REPO, ...args], {
    input, maxBuffer: 1024 * 1024 * 1024,
    env: noLazy ? { ...process.env, GIT_NO_LAZY_FETCH: "1" } : process.env,
  });

const stripComments = (s) => {
  let out = "", d = 0;
  for (let i = 0; i < s.length; i++) {
    if (s[i] === "(" && s[i + 1] === "*") { d++; i++; continue; }
    if (s[i] === "*" && s[i + 1] === ")" && d > 0) { d--; i++; continue; }
    if (d === 0) out += s[i];
  }
  return out;
};

for (const [year, rev] of CHECKPOINTS) {
  const outPath = `isabelle-study/history/${year}.json`;
  if (existsSync(outPath)) { console.log(`${year}: exists, skipping`); continue; }
  const date = git(["log", "-1", "--format=%ci", rev]).toString("utf8").trim();

  // ---- list .thy blobs under src/ ----
  const lsOut = git(["ls-tree", "-r", rev, "src"]).toString("utf8");
  const files = []; // { path (no ext, no leading src/), dir, base, sha }
  for (const line of lsOut.split("\n")) {
    if (!line.endsWith(".thy")) continue;
    const tab = line.indexOf("\t");
    const sha = line.slice(0, tab).split(" ")[2];
    const full = line.slice(tab + 1); // src/.../X.thy
    const noExt = full.slice(4, -4); // strip "src/" and ".thy"
    const slash = noExt.lastIndexOf("/");
    files.push({
      path: noExt,
      dir: slash === -1 ? "" : noExt.slice(0, slash),
      base: slash === -1 ? noExt : noExt.slice(slash + 1),
      sha,
    });
  }
  files.sort((a, b) => (a.path < b.path ? -1 : 1));

  // ---- prefetch missing blobs in bulk (partial clone) ----
  const uniq = [...new Set(files.map((f) => f.sha))];
  const check = git(
    ["cat-file", "--batch-check=%(objectname) %(objecttype)"],
    uniq.join("\n") + "\n",
    true, // GIT_NO_LAZY_FETCH: report missing instead of fetching one-by-one
  ).toString("utf8");
  const missing = [];
  for (const line of check.split("\n")) {
    if (line.includes(" missing")) missing.push(line.split(" ")[0]);
  }
  console.log(`${year}: ${files.length} theories, ${missing.length} blobs to fetch`);
  const FCHUNK = 500;
  for (let c = 0; c < missing.length; c += FCHUNK)
    git(["fetch", "--no-tags", "origin", ...missing.slice(c, c + FCHUNK)]);

  // ---- read headers ----
  const contentOf = new Map();
  const CHUNK = 800;
  for (let c = 0; c < uniq.length; c += CHUNK) {
    const shas = uniq.slice(c, c + CHUNK);
    const raw = git(["cat-file", "--batch"], shas.join("\n") + "\n");
    let off = 0;
    for (const sha of shas) {
      const nl = raw.indexOf(10, off);
      const hdr = raw.toString("utf8", off, nl).split(" ");
      const size = parseInt(hdr[2], 10);
      contentOf.set(sha, raw.toString("utf8", nl + 1, nl + 1 + Math.min(size, 20000)));
      off = nl + 1 + size + 1;
    }
  }

  // ---- resolution maps ----
  const idOf = new Map(files.map((f, i) => [f.path, i]));
  const byBase = new Map();
  for (let i = 0; i < files.length; i++) {
    const b = files[i].base;
    if (!byBase.has(b)) byBase.set(b, []);
    byBase.get(b).push(i);
  }

  // ---- parse and resolve ----
  const pairs = new Set();
  let tokens = 0, resolved = 0, ambiguous = 0, headerless = 0;
  for (let i = 0; i < files.length; i++) {
    const f = files[i];
    const head = stripComments(contentOf.get(f.sha) ?? "");
    const m = head.match(/\btheory\b[\s\S]*?\bimports\b([\s\S]*?)\bbegin\b/);
    if (!m) { headerless++; continue; }
    const re = /"([^"]+)"|([\w.\-/]+)/g;
    let g;
    while ((g = re.exec(m[1])) !== null) {
      const tok = (g[1] ?? g[2]).trim();
      if (tok === "keywords" || tok === "abbrevs" || tok === "fixes") break;
      tokens++;
      let target = -1;
      const clean = tok.replace(/\.thy$/, "");
      if (clean.includes("/")) {
        // relative path against the importer's directory
        const parts = (f.dir ? f.dir.split("/") : []);
        for (const seg of clean.split("/")) {
          if (seg === "..") parts.pop();
          else if (seg !== ".") parts.push(seg);
        }
        target = idOf.get(parts.join("/")) ?? -1;
      } else {
        const dot = clean.lastIndexOf(".");
        const base = dot === -1 ? clean : clean.slice(dot + 1);
        if (dot === -1 && idOf.has(f.dir ? f.dir + "/" + base : base)) {
          target = idOf.get(f.dir ? f.dir + "/" + base : base);
        } else {
          const cands = byBase.get(base);
          if (cands && cands.length === 1) target = cands[0];
          else if (cands && cands.length > 1) { ambiguous++; continue; }
        }
      }
      if (target !== -1 && target !== i) { resolved++; pairs.add(i * 1000000 + target); }
    }
  }

  const edges = [...pairs].sort((a, b) => a - b).map((x) => [Math.floor(x / 1000000), x % 1000000]);
  writeFileSync(outPath, JSON.stringify({
    year, rev, date,
    parse: { theories: files.length, headerless, tokens, resolved, ambiguous },
    nodes: files.map((f) => f.path),
    edges,
  }));
  console.log(
    `${year}: nodes=${files.length} edges=${edges.length} ` +
    `(tokens=${tokens} resolved=${resolved} ambiguous=${ambiguous} headerless=${headerless})`,
  );
}
console.log("done");
