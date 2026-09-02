// Debian study, supplementary extraction: SECTION metadata (functional
// role) per package per release. The original extraction (01) kept only
// nodes and edges; battery v5 (battery-v5/) needs each package's archive
// Section — libs, devel, utils, admin, perl, python, ... — the archive's
// own functional-role taxonomy, to test the confound a Debian person
// raises immediately: "the Exploitation cell is just the library/devel
// sections, and those grow more dependents."
//
// PARSING CHOICES (fixed here, before any analysis):
//   - Section field verbatim, lowercased, with any "main/" (or other
//     "area/") prefix stripped — main-only Packages files mostly carry
//     bare sections, but older releases occasionally prefix;
//   - packages with no Section field recorded as "unknown";
//   - first record wins on rare dupes, matching 01's node rule.
//
// Output: debian-study/history/sections-{year}.json as { name: section }.

import { writeFileSync, existsSync } from "node:fs";
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

for (const [year, dist] of RELEASES) {
  const out = `debian-study/history/sections-${year}.json`;
  if (existsSync(out)) { console.log(`${year} ${dist}: exists, skipping`); continue; }
  console.log(`${year} ${dist}: fetching...`);
  const text = await fetchPackages(dist);
  const map = {};
  const counts = new Map();
  for (const record of text.split("\n\n")) {
    if (!record.trim()) continue;
    const lines = record.replace(/\n[ \t]/g, " ").split("\n");
    let pkg = null, section = "unknown";
    for (const line of lines) {
      if (line.startsWith("Package:")) pkg = line.slice(8).trim();
      else if (line.startsWith("Section:")) {
        section = line.slice(8).trim().toLowerCase();
        const slash = section.lastIndexOf("/");
        if (slash !== -1) section = section.slice(slash + 1);
      }
    }
    if (!pkg || pkg in map) continue;
    map[pkg] = section;
    counts.set(section, (counts.get(section) ?? 0) + 1);
  }
  writeFileSync(out, JSON.stringify(map));
  const top = [...counts.entries()].sort((a, b) => b[1] - a[1]).slice(0, 6)
    .map(([s, n]) => `${s}:${n}`).join(" ");
  console.log(`  ${Object.keys(map).length} packages, ${counts.size} sections; top: ${top}`);
}
console.log("done");
