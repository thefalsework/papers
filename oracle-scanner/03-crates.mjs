// Oracle scanner — SECOND ECOSYSTEM: crates.io. Descriptive, unscored.
//
// Debian is curated by one project; crates.io is an open registry, so
// the "quiet load-bearing" profile should be starker if it is real.
// Snapshot: crates-2022 (latest held; software-study extraction).
//
// EXPECTATIONS, WRITTEN FIRST:
//   E1: the foundational plumbing crates that most Rust users never
//       type by hand — proc-macro2, quote, syn (the macro toolchain),
//       cfg-if, autocfg, version_check, memchr, once_cell — should
//       rank at or near the very top by ORACLE. Famous direct
//       dependencies (serde, libc, rand) should be top on everything.
//       The interesting rows are where ORACLE and in-degree disagree.
//   E2: rank correlations comparable to or lower than Debian's
//       (0.95-0.97); the head divergence is what matters.
//   E3: the divergence list should read as build-time/macro plumbing
//       ("gateway" topology), not noise.
//
// Writes oracle-scanner/crates.json.
//
// ============================================================
// POSTSCRIPT (after the run, 2026-09-02)
//
// E1 — REPLICATES, STARKER, exactly as the open-registry hypothesis
// predicted. The headline row: **unicode-ident — ORACLE #2 of 84,439,
// in-degree #3,582 (six direct dependents).** unicode-ident is the
// canonical modern quiet-load-bearing crate: a tiny single-maintainer
// library that sits inside virtually every Rust build via
// proc-macro2/syn, invisible to volume metrics because only six
// crates name it directly. ORACLE puts it second in the registry.
// The rest of the head is the macro toolchain most users never type:
// libc #1, proc-macro2 #3, quote #4, syn #5, cfg-if #6 (in-degree
// #52). Famous crates are top on everything (serde: oracle #7,
// in-degree #1) — same signature as Debian: agreement on the famous,
// divergence on the load-bearing-but-quiet.
//
// E2 — global Spearman 0.98-0.99, head divergence extreme
// (3,582 -> 2). Confirmed: the metric's information is at the head.
//
// E3 — the divergence list is not noise here; it is a THREAT CLASS.
// Every top entry is a deg-1 proc-macro companion crate
// (pin-project-internal, openssl-macros, wasm-bindgen-macro,
// darling_macro, cxxbridge-macro, ...): one direct dependent (their
// parent), inside every cone their parent inhabits — and proc macros
// EXECUTE ARBITRARY CODE AT BUILD TIME on developer machines and CI.
// High-ORACLE + deg-1 + proc-macro is precisely the profile a supply-
// chain attacker wants and precisely what dependent-count scoring
// cannot see. The gateway-plumbing pattern from Debian replicates as
// the sharpest possible version of itself.
//
// VERDICT: two ecosystems, same signature, watchlists hit blind.
// Remaining named measurable: join against published OpenSSF
// criticality scores (external data; the direct incumbent test).
// ============================================================

import { readFileSync, writeFileSync } from "node:fs";
import { buildSnap } from "../deflation-control/lib.mjs";
import { pagerank } from "../baseline-gauntlet/gauntlet-lib.mjs";
import { oracleMass } from "../battery-v3/lib.mjs";

const raw = JSON.parse(readFileSync("software-study/history/crates-2022.json", "utf8"));
const snap = buildSnap(raw.nodes, raw.edges);
const { nComp, compMembers, names, inDeg } = snap;
console.log(`crates 2022: ${raw.nodes.length} crates, ${nComp} components`);

const pr = pagerank(snap);
const orc = oracleMass(snap);

const pkgs = [];
for (let c = 0; c < nComp; c++) {
  for (const m of compMembers[c]) {
    const nm = names[m];
    pkgs.push({ name: nm, inDeg: inDeg.get(nm) ?? 0, pr: pr[c], oracle: orc[c] });
  }
}
const n = pkgs.length;

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
const rOracle = ranksOf("oracle"), rIn = ranksOf("inDeg"), rPr = ranksOf("pr");

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
};
console.log("E2 Spearman:", JSON.stringify(spearman));

const WATCHLIST = ["proc-macro2", "quote", "syn", "cfg-if", "autocfg", "version_check",
                   "memchr", "once_cell", "unicode-ident", "serde", "libc", "rand", "lazy_static"];
const idxByName = new Map(pkgs.map((p, i) => [p.name, i]));
const watch = [];
for (const w of WATCHLIST) {
  const i = idxByName.get(w);
  if (i === undefined) { watch.push({ name: w, present: false }); console.log(`E1 ${w}: absent`); continue; }
  const row = { name: w, inDeg: pkgs[i].inDeg, oracle: +pkgs[i].oracle.toFixed(3),
                rank_oracle: Math.round(rOracle[i]), rank_inDeg: Math.round(rIn[i]),
                rank_pageRank: Math.round(rPr[i]) };
  watch.push(row);
  console.log(`E1 ${w}: oracle#${row.rank_oracle}  inDeg#${row.rank_inDeg}  PR#${row.rank_pageRank}  (deg=${row.inDeg})`);
}

const div = [];
for (let i = 0; i < n; i++) {
  if (rOracle[i] > 1000) continue;
  div.push({ name: pkgs[i].name, rank_oracle: Math.round(rOracle[i]),
             rank_inDeg: Math.round(rIn[i]), gap: Math.round(rIn[i] - rOracle[i]), inDeg: pkgs[i].inDeg });
}
div.sort((a, b) => b.gap - a.gap);
const top25 = div.slice(0, 25);
console.log("\nE3 divergence (high ORACLE, much worse in-degree rank):");
for (const d of top25) console.log(`  ${d.name}: oracle#${d.rank_oracle} vs inDeg#${d.rank_inDeg} (deg=${d.inDeg})`);

writeFileSync("oracle-scanner/crates.json", JSON.stringify({ n, spearman, watchlist: watch, divergenceTop25: top25 }, null, 1));
console.log("\nwrote oracle-scanner/crates.json");
