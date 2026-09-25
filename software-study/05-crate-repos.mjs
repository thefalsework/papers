// 05-crate-repos.mjs — extract the crate -> project mapping for study 13
// (oracle-scanner/13-aggregation-blur.mjs, registration e4f0b8d).
//
// Source: crates.csv from the crates.io database dump
// (static.crates.io/db-dump.tar.gz), "repository" column.
// Normalization (as registered): lowercase; strip protocol, www.,
// trailing slash, .git; truncate path beyond host/org/repo. Crates
// sharing a normalized URL share a project. Missing/empty repository
// is omitted here (study script assigns singleton self:name).
//
// Only crates present in the 2022 snapshot node list are kept, to keep
// the committed mapping small. Output:
// software-study/history/crates-repos.json {dumpDate, coverage, repos}.
//
// Usage: node software-study/05-crate-repos.mjs <path-to-crates.csv> <dumpDate>

import { createReadStream, readFileSync, writeFileSync } from "node:fs";

const [csvPath, dumpDate] = process.argv.slice(2);
if (!csvPath || !dumpDate) {
  console.error("usage: node 05-crate-repos.mjs <crates.csv> <YYYY-MM-DD>");
  process.exit(1);
}

const snap = JSON.parse(readFileSync("software-study/history/crates-2022.json", "utf8"));
const wanted = new Set(snap.nodes);

function normalizeRepo(url) {
  let u = url.trim().toLowerCase();
  if (!u) return null;
  u = u.replace(/^[a-z+]+:\/\//, "");     // protocol
  u = u.replace(/^www\./, "");
  u = u.replace(/\/+$/, "");              // trailing slashes
  const parts = u.split("/");
  let key = parts.slice(0, 3).join("/");  // host/org/repo
  key = key.replace(/\.git$/, "");
  return key || null;
}

// Streaming RFC-4180 CSV parser: crates.csv has quoted multiline fields
// (readme, description), so line-splitting is not safe.
async function parseCsv(path, onRow) {
  const stream = createReadStream(path, { encoding: "utf8" });
  let field = "", row = [], inQuotes = false, prevQuote = false;
  for await (const chunk of stream) {
    for (let i = 0; i < chunk.length; i++) {
      const ch = chunk[i];
      if (inQuotes) {
        if (prevQuote) {
          prevQuote = false;
          if (ch === '"') { field += '"'; continue; }
          inQuotes = false;
          // fall through to unquoted handling of ch
        } else if (ch === '"') { prevQuote = true; continue; }
        else { field += ch; continue; }
      }
      if (ch === '"' && field === "") { inQuotes = true; }
      else if (ch === ",") { row.push(field); field = ""; }
      else if (ch === "\n") {
        row.push(field.endsWith("\r") ? field.slice(0, -1) : field);
        onRow(row); row = []; field = "";
      } else field += ch;
    }
  }
  if (field !== "" || row.length) { row.push(field); onRow(row); }
}

let header = null, nameIdx = -1, repoIdx = -1, rows = 0;
const repos = {};
await parseCsv(csvPath, (row) => {
  if (!header) {
    header = row;
    nameIdx = row.indexOf("name");
    repoIdx = row.indexOf("repository");
    if (nameIdx < 0 || repoIdx < 0) throw new Error("columns not found: " + row.join(","));
    return;
  }
  rows++;
  const name = row[nameIdx];
  if (!wanted.has(name)) return;
  const key = normalizeRepo(row[repoIdx] ?? "");
  if (key) repos[name] = key;
});

const coverage = Object.keys(repos).length / snap.nodes.length;
writeFileSync(
  "software-study/history/crates-repos.json",
  JSON.stringify({ dumpDate, coverage, repos }, null, 1),
);
console.log(`dump rows ${rows}; snapshot crates ${snap.nodes.length}; mapped ${Object.keys(repos).length} (${(coverage * 100).toFixed(1)}%)`);
const projects = new Set(Object.values(repos));
console.log(`distinct projects ${projects.size}`);
console.log(`sanity: serde -> ${repos["serde"]}, tokio -> ${repos["tokio"]}, rand -> ${repos["rand"]}`);
