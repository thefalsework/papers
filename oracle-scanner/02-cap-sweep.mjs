// Oracle scanner — CAP SENSITIVITY SWEEP. Descriptive, unscored.
//
// The pilot's headline (liblzma5 ORACLE rank #8 vs in-degree #173 on
// pre-backdoor bookworm) was computed at cone cap 200, inherited from
// the accretion study. Named robustness question: is the head of the
// ORACLE ranking an artifact of that truncation?
//
// EXPECTATIONS, WRITTEN FIRST: if the metric measures real
// concentration structure, watchlist ranks should be stable within a
// small factor across caps 50..800, and adjacent-cap rankings should
// agree strongly at the head. A liblzma5 rank that swings wildly with
// cap kills the pilot's headline.
//
// Corpus: Debian bookworm 2023. Writes oracle-scanner/cap-sweep.json.

import { readFileSync, writeFileSync } from "node:fs";
import { buildSnap } from "../deflation-control/lib.mjs";
import { oracleMass } from "../battery-v3/lib.mjs";

const CAPS = [50, 100, 200, 400, 800];
const WATCHLIST = ["liblzma5", "xz-utils", "zlib1g", "libssl3", "libexpat1", "libxml2", "libgcrypt20"];

const raw = JSON.parse(readFileSync("debian-study/history/2023.json", "utf8"));
const snap = buildSnap(raw.nodes, raw.edges);
const { nComp, compMembers, names } = snap;

// package index -> component, package order fixed
const pkgNames = [];
const pkgComp = [];
for (let c = 0; c < nComp; c++) {
  for (const m of compMembers[c]) { pkgNames.push(names[m]); pkgComp.push(c); }
}
const n = pkgNames.length;
const idxOf = new Map(pkgNames.map((nm, i) => [nm, i]));

const rankAll = (vals) => {
  const idx = Array.from({ length: n }, (_, i) => i).sort((a, b) => vals[b] - vals[a]);
  const ranks = new Array(n);
  let i = 0;
  while (i < n) {
    let j = i;
    while (j + 1 < n && vals[idx[j + 1]] === vals[idx[i]]) j++;
    const avg = (i + j) / 2 + 1;
    for (let k = i; k <= j; k++) ranks[idx[k]] = avg;
    i = j + 1;
  }
  return ranks;
};

const out = { watch: {}, headOverlap: {} };
let prevRanks = null, prevTop100 = null;
for (const cap of CAPS) {
  const orc = oracleMass(snap, cap);
  const vals = pkgComp.map((c) => orc[c]);
  const ranks = rankAll(vals);
  for (const w of WATCHLIST) {
    const i = idxOf.get(w);
    if (i === undefined) continue;
    (out.watch[w] ??= {})[`cap${cap}`] = Math.round(ranks[i]);
  }
  const top100 = new Set(
    Array.from({ length: n }, (_, i) => i).sort((a, b) => ranks[a] - ranks[b]).slice(0, 100));
  if (prevTop100) {
    let inter = 0;
    for (const i of top100) if (prevTop100.has(i)) inter++;
    out.headOverlap[`cap${CAPS[CAPS.indexOf(cap) - 1]}_vs_cap${cap}`] = inter / 100;
  }
  prevTop100 = top100;
  prevRanks = ranks;
  console.log(`cap ${cap}: ${WATCHLIST.map((w) => `${w}#${out.watch[w]?.[`cap${cap}`] ?? "-"}`).join(" ")}`);
}
console.log("top-100 overlap between adjacent caps:", JSON.stringify(out.headOverlap));
writeFileSync("oracle-scanner/cap-sweep.json", JSON.stringify(out, null, 1));
console.log("wrote oracle-scanner/cap-sweep.json");
