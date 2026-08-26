// AFP referendum, part 2 prep: extract entry-level import graphs at
// biennial checkpoints, 2006-2026.
//
// BLIND: this script materializes edge lists and entry lists per
// checkpoint — no measures, no cones, no apertures. The registered study
// (05) computes everything from the committed edge lists.
//
// Checkpoint rule: for each year Y in {2006, 2008, ..., 2026}, the last
// commit on the mirror's default branch with author date < Y-01-01
// (UTC). Full 20-year history fetched 2026-08-26 (16,738 commits, root
// 2004-02-12).
//
// Extraction: read blobs directly from the object database (ls-tree +
// cat-file --batch in chunks) — no working tree is materialized, which
// both avoids Windows-reserved filenames in old snapshots (thys/Jinja/
// Common/Aux.thy, 2006: AUX is a reserved DOS device name) and skips
// gigabytes of disk churn. Parse theory headers with the same resolution
// rules as 01/02/03; write afp-study/history/<year>.json
// { rev, date, entries, edges }. Edge lists are committed (small).

import { execSync } from "node:child_process";
import { writeFileSync, mkdirSync, existsSync } from "node:fs";

const YEARS = [2006, 2008, 2010, 2012, 2014, 2016, 2018, 2020, 2022, 2024, 2026];
const REPO = ".scratch_afp";

mkdirSync("afp-study/history", { recursive: true });

const stripComments = (s) => {
  let out = "", d = 0;
  for (let i = 0; i < s.length; i++) {
    if (s[i] === "(" && s[i + 1] === "*") { d++; i++; continue; }
    if (s[i] === "*" && s[i + 1] === ")" && d > 0) { d--; i++; continue; }
    if (d === 0) out += s[i];
  }
  return out;
};
const DIST_SESSIONS = /^(HOL|Pure|FOL|ZF|CCL|CTT|Cube|FOLP|LCF|Sequents|Tools|Doc)\b/;

for (const year of YEARS) {
  const outPath = `afp-study/history/${year}.json`;
  if (existsSync(outPath)) { console.log(`${year}: exists, skipping`); continue; }
  const rev = execSync(
    `git -C ${REPO} rev-list -1 --before="${year}-01-01T00:00:00Z" HEAD`,
    { encoding: "utf8" }
  ).trim();
  if (!rev) { console.log(`${year}: no commit before cutoff`); continue; }
  const date = execSync(`git -C ${REPO} log -1 --format=%ci ${rev}`, { encoding: "utf8" }).trim();

  // list .thy blobs at the checkpoint
  const lsOut = execSync(`git -C ${REPO} ls-tree -r ${rev} thys`, {
    encoding: "utf8", maxBuffer: 256 * 1024 * 1024,
  });
  const thyFiles = []; // { entry, name, sha }
  const entrySet = new Set();
  for (const line of lsOut.split("\n")) {
    if (!line) continue;
    const tab = line.indexOf("\t");
    const path = line.slice(tab + 1);
    const parts = path.split("/");
    if (parts.length < 2) continue;
    entrySet.add(parts[1]);
    if (!path.endsWith(".thy")) continue;
    const sha = line.slice(0, tab).split(" ")[2];
    const file = parts[parts.length - 1];
    thyFiles.push({ entry: parts[1], name: file.slice(0, -4), sha });
  }
  const entries = [...entrySet].sort();

  // fetch blob contents in chunks via cat-file --batch
  const contentOf = new Map(); // sha -> header text (first 20000 chars)
  const CHUNK = 800;
  for (let c = 0; c < thyFiles.length; c += CHUNK) {
    const shas = thyFiles.slice(c, c + CHUNK).map((t) => t.sha);
    const raw = execSync(`git -C ${REPO} cat-file --batch`, {
      input: shas.join("\n") + "\n",
      maxBuffer: 1024 * 1024 * 1024,
    });
    let off = 0;
    for (const sha of shas) {
      const nl = raw.indexOf(10, off);
      const hdr = raw.toString("utf8", off, nl).split(" ");
      const size = parseInt(hdr[2], 10);
      const body = raw.toString("utf8", nl + 1, nl + 1 + Math.min(size, 20000));
      contentOf.set(sha, body);
      off = nl + 1 + size + 1; // skip content + trailing LF
    }
  }
  const byName = new Map();
  const nodeId = new Map();
  thyFiles.forEach((t, i) => {
    nodeId.set(`${t.entry}/${t.name}`, i);
    if (!byName.has(t.name)) byName.set(t.name, []);
    byName.get(t.name).push(i);
  });
  const pairs = new Set();
  for (const t of thyFiles) {
    const head = stripComments(contentOf.get(t.sha) ?? "");
    const m = head.match(/\btheory\b[\s\S]*?\bimports\b([\s\S]*?)\bbegin\b/);
    if (!m) continue;
    const re = /"([^"]+)"|([\w.\-/]+)/g;
    let g;
    while ((g = re.exec(m[1])) !== null) {
      const tok = (g[1] ?? g[2]).trim();
      if (tok === "keywords" || tok === "abbrevs") break;
      const clean = tok.replace(/\.thy$/, "");
      const last = clean.split("/").pop();
      const dot = last.lastIndexOf(".");
      if (dot > 0) {
        const sess = last.slice(0, dot), thy = last.slice(dot + 1);
        if (DIST_SESSIONS.test(sess)) continue;
        if (nodeId.has(`${sess}/${thy}`) && sess !== t.entry) pairs.add(`${t.entry}>${sess}`);
        continue;
      }
      if (nodeId.has(`${t.entry}/${last}`)) continue;
      const global = byName.get(last);
      if (global && global.length === 1 && thyFiles[global[0]].entry !== t.entry)
        pairs.add(`${t.entry}>${thyFiles[global[0]].entry}`);
    }
  }
  writeFileSync(outPath, JSON.stringify({
    year, rev, date, entries, edges: [...pairs].sort(),
  }));
  console.log(`${year}: rev=${rev.slice(0, 12)} entries=${entries.length} edges=${pairs.size}`);
}
console.log("done");
