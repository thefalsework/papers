// Debian study, extraction. Builds biennial dependency snapshots of the
// Debian archive (main, binary-amd64) across ten stable releases:
//
//   2007 etch    2009 lenny    2011 squeeze  2013 wheezy   2015 jessie
//   2017 stretch 2019 buster   2021 bullseye 2023 bookworm 2025 trixie
//
// WHY DEBIAN: the registered tiebreaker corpus for the growth claim
// (see baseline-gauntlet/ and wolfram/next-session.md 2026-08-31).
// Debian sits at the maximum of the reuse-selection scale — a binary
// dependency is code that is installed and executed, and the archive is
// curated by a single project across twenty years — and none of the
// program's machinery has ever touched it.
//
// EXTRACTION CHOICES (fixed here, before any analysis):
//   - main/binary-amd64 Packages file per release (amd64 exists from
//     etch onward, keeping the architecture constant across snapshots);
//   - nodes = binary package names (first record wins on rare dupes);
//   - edges = Depends + Pre-Depends of each package (runtime, not
//     build); for each comma-separated clause the FIRST alternative is
//     taken (the default the resolver installs); version constraints,
//     multiarch suffixes (":any"), and arch qualifiers stripped;
//   - edges whose target is not a real package in the same snapshot
//     (unresolved virtual packages) are dropped; the drop rate is
//     logged per snapshot as structural metadata.
//
// Output: debian-study/history/{year}.json as { nodes, edges } with
// edges as [dependent, dependency] index pairs — the exact schema of
// software-study/history/go-*.json.

import { mkdirSync, writeFileSync, existsSync } from "node:fs";
import { gunzipSync } from "node:zlib";

const RELEASES = [
  [2007, "etch"], [2009, "lenny"], [2011, "squeeze"], [2013, "wheezy"],
  [2015, "jessie"], [2017, "stretch"], [2019, "buster"],
  [2021, "bullseye"], [2023, "bookworm"], [2025, "trixie"],
];
const MIRRORS = [
  "http://archive.debian.org/debian",
  "https://deb.debian.org/debian",
];

const fetchPackages = async (dist) => {
  for (const m of MIRRORS) {
    const url = `${m}/dists/${dist}/main/binary-amd64/Packages.gz`;
    try {
      const res = await fetch(url);
      if (!res.ok) { console.log(`  ${url} -> HTTP ${res.status}`); continue; }
      const buf = Buffer.from(await res.arrayBuffer());
      return gunzipSync(buf).toString("latin1");
    } catch (e) {
      console.log(`  ${url} -> ${e.message}`);
    }
  }
  throw new Error(`no mirror served ${dist}`);
};

const depName = (raw) => {
  // first alternative, strip version/arch/multiarch decorations
  let s = raw.split("|")[0].trim();
  const paren = s.indexOf("(");
  if (paren !== -1) s = s.slice(0, paren);
  const bracket = s.indexOf("[");
  if (bracket !== -1) s = s.slice(0, bracket);
  const angle = s.indexOf("<");
  if (angle !== -1) s = s.slice(0, angle);
  const colon = s.indexOf(":");
  if (colon !== -1) s = s.slice(0, colon);
  return s.trim();
};

const parse = (text) => {
  const nodes = [];
  const idx = new Map();
  const rawDeps = []; // per node: array of dep name strings
  for (const record of text.split("\n\n")) {
    if (!record.trim()) continue;
    // unfold continuation lines
    const lines = record.replace(/\n[ \t]/g, " ").split("\n");
    let pkg = null, deps = "";
    for (const line of lines) {
      if (line.startsWith("Package:")) pkg = line.slice(8).trim();
      else if (line.startsWith("Depends:")) deps += (deps ? "," : "") + line.slice(8);
      else if (line.startsWith("Pre-Depends:")) deps += (deps ? "," : "") + line.slice(12);
    }
    if (!pkg || idx.has(pkg)) continue;
    idx.set(pkg, nodes.length);
    nodes.push(pkg);
    rawDeps.push(deps ? deps.split(",").map(depName).filter(Boolean) : []);
  }
  const edges = [];
  let dropped = 0;
  const seen = new Set();
  rawDeps.forEach((deps, i) => {
    for (const d of deps) {
      const j = idx.get(d);
      if (j === undefined) { dropped++; continue; }
      if (j === i) continue;
      const key = i * 200000 + j;
      if (seen.has(key)) continue;
      seen.add(key);
      edges.push([i, j]);
    }
  });
  return { nodes, edges, dropped };
};

mkdirSync("debian-study/history", { recursive: true });
for (const [year, dist] of RELEASES) {
  const out = `debian-study/history/${year}.json`;
  if (existsSync(out)) { console.log(`${year} ${dist}: exists, skipping`); continue; }
  console.log(`${year} ${dist}: fetching...`);
  const text = await fetchPackages(dist);
  const { nodes, edges, dropped } = parse(text);
  writeFileSync(out, JSON.stringify({ nodes, edges }));
  console.log(`  ${nodes.length} packages, ${edges.length} edges (${dropped} unresolved dep clauses dropped)`);
}
console.log("done");
