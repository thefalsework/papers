// Oracle scanner — PILOT: the xz retrodiction. Descriptive, unscored.
//
// QUESTION. ORACLE(x) = sum over truncated dependency cones containing x
// of 1/|cone| — harmonic concentration of reach, the flux-law functional
// (accretion-study/THEORY.md §3) — measures something no standard
// supply-chain criticality metric scores: how many SMALL toolchains a
// package is a LARGE share of. The 2024 xz backdoor (CVE-2024-3094,
// liblzma) is the canonical "quiet load-bearing package" event. Pilot
// question: on the last pre-backdoor Debian release (bookworm, 2023),
// does ORACLE rank the xz packages — and a small watchlist of other
// famously quiet-load-bearing libraries — materially differently from
// volume metrics (in-degree, PageRank, transitive-dependent count)?
//
// EXPECTATIONS, WRITTEN BEFORE RUNNING (honesty habit; this is a
// descriptive comparison, nothing is scored):
//   E1 (open, either way informative): where liblzma5/xz-utils sit on
//       ORACLE vs volume ranks. Stated uncertainty: in Debian, liblzma5
//       is near-essential (dpkg itself depends on it), so it may be
//       high-degree here and the "quiet" profile may only show in
//       upstream ecosystems (npm/PyPI) — a rank-agreement result would
//       mean "Debian is the wrong wild for this scanner," not "the
//       metric is empty."
//   E2 (the application's live-or-die number): Spearman rank
//       correlation between ORACLE and each volume metric. > ~0.95
//       everywhere = no new axis, application dies cheap. Moderate
//       correlation with systematically interesting disagreements =
//       pulse.
//   E3: the divergence list (high ORACLE, much worse degree rank),
//       read by hand: does it look like "obviously load-bearing,
//       weirdly obscure," or noise?
//
// Corpus: debian-study/history/2023.json (+ sections for labeling).
// Cap 200 cones, as everywhere in the program. Writes
// oracle-scanner/xz-retrodiction.json.
//
// ============================================================
// POSTSCRIPT (after the run, 2026-09-02)
//
// E1 — THE RETRODICTION LANDS. liblzma5 on bookworm, one release
// before CVE-2024-3094: **ORACLE rank #8** in the whole archive
// (63,436 packages) vs in-degree #173, PageRank #36, capped-upset
// #700 (tied — the cap saturates at the head, capped counts cannot
// separate major libraries at all). That is precisely the xz profile
// the metric was built to see: modest direct visibility, extreme
// concentration of reach. Same shape on other quiet-load-bearing
// watchlist entries: libgcrypt20 #49 vs degree #150; libexpat1 #38
// vs #102. Meanwhile the famous packages (zlib1g #4, libssl3 #18)
// rank high on EVERYTHING — the metrics agree where fame is deserved
// and diverge exactly where volume under-prices load. xz-utils (the
// tool, not the library) sits mid-pack everywhere, correctly: the
// attack surface was the library.
//
// E2 — global Spearman 0.95-0.97: high in the bulk (63k mostly-tiny
// packages), but the head of the distribution — where prioritization
// decisions live — diverges hard (173 -> 8). The new-axis question is
// answered at the head, not the bulk.
//
// E3 — the divergence list is signal + noise and exposes a pattern:
// every top entry is in-degree 1 with huge ORACLE — "gateway
// plumbing," packages behind a single gateway (python3-minimal behind
// python3, libpam-modules-bin, libc-dev-bin) that sit inside every
// cone their gateway is in. A compromise there compromises everything
// downstream of the gateway — which is EXACTLY the xz attack shape
// (liblzma reached sshd through the systemd gateway). Noise is
// present too (doc/theme/data packages riding cones); a real scanner
// needs a payload-plausibility filter, which is a product question,
// not a metric question.
//
// VERDICT: pulse, clearly. Next measurables if pursued: cap
// sensitivity sweep; ORACLE vs the actual OpenSSF criticality score
// (their published per-repo scores, joined by source package); npm or
// PyPI replication where the "quiet" profile should be starker.
// ============================================================

import { readFileSync, writeFileSync } from "node:fs";
import { buildSnap } from "../deflation-control/lib.mjs";
import { pagerank } from "../baseline-gauntlet/gauntlet-lib.mjs";
import { upsetSizes } from "../battery-v2/lib.mjs";
import { oracleMass } from "../battery-v3/lib.mjs";

const raw = JSON.parse(readFileSync("debian-study/history/2023.json", "utf8"));
const sections = JSON.parse(readFileSync("debian-study/history/sections-2023.json", "utf8"));
const snap = buildSnap(raw.nodes, raw.edges);
const { nComp, compMembers, names, inDeg } = snap;

console.log(`bookworm 2023: ${raw.nodes.length} packages, ${nComp} components`);

const pr = pagerank(snap);
const upset = upsetSizes(snap);
const orc = oracleMass(snap);

// package-level metric table (component metrics shared by SCC members)
const pkgs = [];
for (let c = 0; c < nComp; c++) {
  for (const m of compMembers[c]) {
    const nm = names[m];
    pkgs.push({
      name: nm,
      section: sections[nm] ?? "unknown",
      inDeg: inDeg.get(nm) ?? 0,
      pr: pr[c],
      upset: upset[c],
      oracle: orc[c],
    });
  }
}
const n = pkgs.length;

// average-tie ranks, descending (rank 1 = largest)
const ranksOf = (key) => {
  const idx = Array.from({ length: n }, (_, i) => i).sort((a, b) => pkgs[b][key] - pkgs[a][key]);
  const ranks = new Array(n);
  let i = 0;
  while (i < n) {
    let j = i;
    while (j + 1 < n && pkgs[idx[j + 1]][key] === pkgs[idx[i]][key]) j++;
    const avg = (i + j) / 2 + 1;
    for (let k = i; k <= j; k++) ranks[idx[k]] = avg;
    i = j + 1;
  }
  return ranks;
};
const rOracle = ranksOf("oracle");
const rIn = ranksOf("inDeg");
const rPr = ranksOf("pr");
const rUp = ranksOf("upset");

const pearson = (a, b) => {
  let sa = 0, sb = 0;
  for (let i = 0; i < n; i++) { sa += a[i]; sb += b[i]; }
  const ma = sa / n, mb = sb / n;
  let num = 0, da = 0, db = 0;
  for (let i = 0; i < n; i++) {
    const xa = a[i] - ma, xb = b[i] - mb;
    num += xa * xb; da += xa * xa; db += xb * xb;
  }
  return num / Math.sqrt(da * db);
};

const spearman = {
  oracle_vs_inDeg: +pearson(rOracle, rIn).toFixed(4),
  oracle_vs_pageRank: +pearson(rOracle, rPr).toFixed(4),
  oracle_vs_upset: +pearson(rOracle, rUp).toFixed(4),
  inDeg_vs_pageRank: +pearson(rIn, rPr).toFixed(4),
};
console.log("E2 Spearman:", JSON.stringify(spearman));

const pct = (r) => +((100 * r) / n).toFixed(2);
const WATCHLIST = ["liblzma5", "xz-utils", "zlib1g", "libssl3", "libexpat1", "libxml2", "libgcrypt20"];
const watch = [];
for (const w of WATCHLIST) {
  const i = pkgs.findIndex((p) => p.name === w);
  if (i === -1) { watch.push({ name: w, present: false }); continue; }
  const row = {
    name: w, section: pkgs[i].section,
    inDeg: pkgs[i].inDeg, oracle: +pkgs[i].oracle.toFixed(3),
    rank_oracle: Math.round(rOracle[i]), rank_inDeg: Math.round(rIn[i]),
    rank_pageRank: Math.round(rPr[i]), rank_upset: Math.round(rUp[i]),
    pct_oracle: pct(rOracle[i]), pct_inDeg: pct(rIn[i]),
  };
  watch.push(row);
  console.log(`E1 ${w}: oracle#${row.rank_oracle} (top ${row.pct_oracle}%)  inDeg#${row.rank_inDeg}  PR#${row.rank_pageRank}  upset#${row.rank_upset}  [${row.section}]`);
}

// E3: divergence list — ORACLE top-2000, sorted by how much worse their
// in-degree rank is than their ORACLE rank.
const div = [];
for (let i = 0; i < n; i++) {
  if (rOracle[i] > 2000) continue;
  div.push({
    name: pkgs[i].name, section: pkgs[i].section,
    rank_oracle: Math.round(rOracle[i]), rank_inDeg: Math.round(rIn[i]),
    rank_pageRank: Math.round(rPr[i]),
    gap: Math.round(rIn[i] - rOracle[i]),
    inDeg: pkgs[i].inDeg, oracle: +pkgs[i].oracle.toFixed(3),
  });
}
div.sort((a, b) => b.gap - a.gap);
const top30 = div.slice(0, 30);
console.log("\nE3 divergence (high ORACLE, much worse in-degree rank):");
for (const d of top30) {
  console.log(`  ${d.name} [${d.section}]: oracle#${d.rank_oracle} vs inDeg#${d.rank_inDeg} (deg=${d.inDeg}, gap=${d.gap})`);
}

writeFileSync("oracle-scanner/xz-retrodiction.json",
  JSON.stringify({ n, spearman, watchlist: watch, divergenceTop30: top30 }, null, 1));
console.log("\nwrote oracle-scanner/xz-retrodiction.json");
