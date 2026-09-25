// Debian study, supplementary extraction: SOURCE PACKAGE mapping
// (binary package -> source project) for bookworm 2023, required by
// oracle-scanner/13-aggregation-blur.mjs (registered at e4f0b8d
// before this script existed). The archive's own project mapping —
// ground truth, same epoch as the dependency snapshot.
//
// PARSING CHOICES (per the registration):
//   - "Source:" field verbatim with any version suffix in
//     parentheses stripped ("Source: xz-utils (5.4.1)" -> xz-utils);
//   - packages with no Source field are their own source (Debian
//     Policy 5.6.1: the field is omitted when binary = source name);
//   - first record wins on rare dupes, matching 01/04's node rule.
//
// Output: debian-study/history/sources-2023.json as { binary: source }.

import { writeFileSync, existsSync } from "node:fs";
import { gunzipSync } from "node:zlib";

const MIRRORS = [
  "https://deb.debian.org/debian",
  "http://archive.debian.org/debian",
];

const out = "debian-study/history/sources-2023.json";
if (existsSync(out)) {
  console.log("sources-2023.json exists, skipping");
  process.exit(0);
}

let text = null;
for (const m of MIRRORS) {
  const url = `${m}/dists/bookworm/main/binary-amd64/Packages.gz`;
  try {
    const res = await fetch(url);
    if (!res.ok) { console.log(`${url} -> HTTP ${res.status}`); continue; }
    text = gunzipSync(Buffer.from(await res.arrayBuffer())).toString("latin1");
    console.log(`fetched ${url}`);
    break;
  } catch (e) {
    console.log(`${url} -> ${e.message}`);
  }
}
if (!text) throw new Error("no mirror served bookworm");

const map = {};
let withField = 0;
for (const record of text.split("\n\n")) {
  if (!record.trim()) continue;
  const lines = record.replace(/\n[ \t]/g, " ").split("\n");
  let pkg = null, source = null;
  for (const line of lines) {
    if (line.startsWith("Package:")) pkg = line.slice(8).trim();
    else if (line.startsWith("Source:")) {
      source = line.slice(7).trim();
      const paren = source.indexOf("(");
      if (paren !== -1) source = source.slice(0, paren).trim();
    }
  }
  if (!pkg || pkg in map) continue;
  if (source) withField++;
  map[pkg] = source ?? pkg;
}
writeFileSync(out, JSON.stringify(map));
const sources = new Set(Object.values(map));
console.log(`${Object.keys(map).length} binaries -> ${sources.size} source projects (${withField} carried an explicit Source field)`);
console.log(`sanity: liblzma5 -> ${map["liblzma5"]}`);
