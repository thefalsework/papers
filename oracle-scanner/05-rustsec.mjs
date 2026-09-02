// Oracle scanner — THE RUSTSEC RETRODICTION (registered). The killer
// test two independent reviewers converged on: does concentration of
// reach place future advisory-affected crates unusually high, BEFORE
// the advisories exist, and does it beat the standard rankings?
//
// TIME SLICE. Metrics are computed on the crates.io 2022 snapshot
// (index at 2022-07-01, pinned by SHA in software-study/01-census.mjs;
// the exact graph behind the published ranking). Labels are RustSec
// advisories dated 2022-07-02 OR LATER — strictly after every byte of
// the input. Advisory DB: github.com/rustsec/advisory-db, cloned at a
// commit recorded in the output JSON.
//
// LABEL RULES, fixed before parsing:
//   - An advisory labels its `package` if that crate exists in the
//     2022 snapshot. Crate-level dedupe (>=1 qualifying advisory).
//   - Advisories with a `withdrawn` key are excluded.
//   - PRIMARY set: advisories with NO `informational` key (true
//     vulnerabilities: memory safety, RCE, crypto, etc.).
//   - SECONDARY set: PRIMARY plus informational = "unsound"
//     (soundness holes are security-relevant in Rust; reported
//     separately, never pooled). "unmaintained"/"notice" advisories
//     are in neither set — they are not incidents.
//
// METRICS, all computed on the identical condensation (03-crates path):
//   ORACLE (cap 200) | dependent count (in-degree) | PageRank |
//   betweenness (sampled Brandes, 200 seeded sources; approximation
//   stated, standard) | analytic random null (top-q% captures q%).
//   Ranks: average-rank over ties (the 03-crates/paper convention).
//
// STATISTIC. For each metric and label set: share of labeled crates
// ranked in the top 1% / 5% / 10% of all crates, plus median rank
// quantile. HEADLINE CELL, fixed now: PRIMARY set, top 10%.
//
// REGISTERED PREDICTIONS:
//   R1 (headline): ORACLE's PRIMARY top-10% share strictly exceeds
//      dependent count's.
//   R2: ORACLE's PRIMARY top-10% share strictly exceeds PageRank's.
//   R3 (sanity gate): dependent count's PRIMARY top-10% share >= 0.20
//      (2x the analytic null). If even the scrutiny-favored metric
//      cannot double random, the labels are too sparse to rank
//      metrics: verdict UNINFORMATIVE, no R1/R2 scoring.
//
// BIAS STATEMENT, fixed in advance (asymmetric reading): advisory
// discovery correlates with scrutiny, and scrutiny correlates with
// popularity — the label process favors high-dependent-count crates.
// A win for ORACLE on R1 is therefore a win DESPITE adverse label
// bias. A loss on R1 is confounded (quiet crates may be vulnerable
// but unaudited) and is reported as a loss anyway, per registration.
//
// INTERPRETATION TABLE:
//   R1+R2 land -> first registered support for the security-relevance
//     upgrade (claim B/C); goes to the paper and the OpenSSF thread.
//   R1 fails -> ORACLE does not beat dependent count on advisory
//     retrodiction; the structural-embeddedness claim (A) is
//     untouched; the loss goes in the paper's limitations verbatim.
//   R3 fails -> UNINFORMATIVE; report and stop. No threshold tuning
//     in any branch.

import { readFileSync, writeFileSync, readdirSync } from "node:fs";
import { execSync } from "node:child_process";
import { buildSnap } from "../deflation-control/lib.mjs";
import { pagerank } from "../baseline-gauntlet/gauntlet-lib.mjs";
import { oracleMass } from "../battery-v3/lib.mjs";

const ADVISORY_DB = "C:/dev/advisory-db";
const CUTOFF = "2022-07-02";

// ---- labels ----
const dbCommit = execSync(`git -C ${ADVISORY_DB} rev-parse HEAD`, { encoding: "utf8" }).trim();
const primary = new Set(), secondary = new Set();
let advTotal = 0, advAfter = 0;
for (const dir of readdirSync(`${ADVISORY_DB}/crates`)) {
  for (const f of readdirSync(`${ADVISORY_DB}/crates/${dir}`)) {
    if (!f.endsWith(".md")) continue;
    const text = readFileSync(`${ADVISORY_DB}/crates/${dir}/${f}`, "utf8");
    const fm = text.split("```")[1] ?? "";
    const get = (k) => (fm.match(new RegExp(`^${k} = "([^"]*)"`, "m")) ?? [])[1];
    advTotal++;
    if (fm.match(/^withdrawn = /m)) continue;
    const pkg = get("package"), date = get("date");
    if (!pkg || !date || date < CUTOFF) continue;
    advAfter++;
    const info = get("informational");
    if (info === undefined) { primary.add(pkg); secondary.add(pkg); }
    else if (info === "unsound") secondary.add(pkg);
  }
}
console.log(`advisories: ${advTotal} total, ${advAfter} dated >= ${CUTOFF}`);
console.log(`labeled crates (pre-membership): primary ${primary.size}, secondary ${secondary.size}`);

// ---- metrics on the 2022 snapshot (identical path to 03-crates.mjs) ----
const raw = JSON.parse(readFileSync("software-study/history/crates-2022.json", "utf8"));
const snap = buildSnap(raw.nodes, raw.edges);
const { nComp, compMembers, names, inDeg } = snap;
const pr = pagerank(snap);
const orc = oracleMass(snap);

// sampled Brandes betweenness on the condensation (directed dep edges)
const betweenness = (K, seed) => {
  let s = seed;
  const rand = () => {
    s |= 0; s = (s + 0x6d2b79f5) | 0;
    let t = Math.imul(s ^ (s >>> 15), 1 | s);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
  const cDeps = Array.from({ length: nComp }, () => []);
  {
    const seen = new Set();
    for (let c = 0; c < nComp; c++) {
      for (const e of snap.cIn[c]) { // cIn = c's dependencies (lib naming)
        const k = c + ":" + e;
        if (c === e || seen.has(k)) continue;
        seen.add(k); cDeps[c].push(e);
      }
    }
  }
  const bc = new Float64Array(nComp);
  const sigma = new Float64Array(nComp), dist = new Int32Array(nComp), delta = new Float64Array(nComp);
  for (let k = 0; k < K; k++) {
    const src = Math.floor(rand() * nComp);
    sigma.fill(0); dist.fill(-1); delta.fill(0);
    sigma[src] = 1; dist[src] = 0;
    const order = [src];
    for (let qi = 0; qi < order.length; qi++) {
      const v = order[qi];
      for (const w of cDeps[v]) {
        if (dist[w] === -1) { dist[w] = dist[v] + 1; order.push(w); }
        if (dist[w] === dist[v] + 1) sigma[w] += sigma[v];
      }
    }
    for (let qi = order.length - 1; qi > 0; qi--) {
      const v = order[qi];
      // standard Brandes accumulation: v's shortest-path successors w
      // (dist[w] = dist[v]+1) were processed already in this reverse
      // BFS-order sweep
      for (const w of cDeps[v]) {
        if (dist[w] === dist[v] + 1) delta[v] += (sigma[v] / sigma[w]) * (1 + delta[w]);
      }
      if (v !== src) bc[v] += delta[v];
    }
  }
  return bc;
};
console.log("computing sampled betweenness (200 sources)...");
const bt = betweenness(200, 20260902);

const pkgs = [];
for (let c = 0; c < nComp; c++) {
  for (const m of compMembers[c]) {
    const nm = names[m];
    pkgs.push({ name: nm, inDeg: inDeg.get(nm) ?? 0, pr: pr[c], oracle: orc[c], bt: bt[c] });
  }
}
const n = pkgs.length;
const idxByName = new Map(pkgs.map((p, i) => [p.name, i]));
console.log(`snapshot: ${n} crates, ${nComp} components`);

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
const METRICS = { oracle: ranksOf("oracle"), inDeg: ranksOf("inDeg"), pageRank: ranksOf("pr"), betweenness: ranksOf("bt") };

// membership filter
const inSnap = (set) => [...set].filter((nm) => idxByName.has(nm));
const labPrimary = inSnap(primary), labSecondary = inSnap(secondary);
console.log(`labeled crates in snapshot: primary ${labPrimary.length}, secondary ${labSecondary.length}`);

const table = {};
for (const [metric, ranks] of Object.entries(METRICS)) {
  table[metric] = {};
  for (const [setName, lab] of [["primary", labPrimary], ["secondary", labSecondary]]) {
    const qs = lab.map((nm) => ranks[idxByName.get(nm)] / n).sort((a, b) => a - b);
    const share = (q) => +(qs.filter((x) => x <= q).length / qs.length).toFixed(4);
    table[metric][setName] = {
      top1: share(0.01), top5: share(0.05), top10: share(0.10),
      medianQuantile: +qs[Math.floor(qs.length / 2)].toFixed(4),
    };
  }
}
table.randomNull = { primary: { top1: 0.01, top5: 0.05, top10: 0.10, medianQuantile: 0.5 },
                     secondary: { top1: 0.01, top5: 0.05, top10: 0.10, medianQuantile: 0.5 } };

console.log("\nPRIMARY (true vulnerabilities), share of labeled crates in metric's top q%:");
console.log("metric        top1%   top5%   top10%  medianQ");
for (const m of ["oracle", "inDeg", "pageRank", "betweenness", "randomNull"]) {
  const r = table[m].primary;
  console.log(`${m.padEnd(13)} ${String(r.top1).padEnd(7)} ${String(r.top5).padEnd(7)} ${String(r.top10).padEnd(7)} ${r.medianQuantile}`);
}
console.log("\nSECONDARY (+unsound):");
for (const m of ["oracle", "inDeg", "pageRank", "betweenness"]) {
  const r = table[m].secondary;
  console.log(`${m.padEnd(13)} ${String(r.top1).padEnd(7)} ${String(r.top5).padEnd(7)} ${String(r.top10).padEnd(7)} ${r.medianQuantile}`);
}

// verdicts
const r3 = table.inDeg.primary.top10 >= 0.20;
const r1 = table.oracle.primary.top10 > table.inDeg.primary.top10;
const r2 = table.oracle.primary.top10 > table.pageRank.primary.top10;
const verdicts = !r3
  ? { R3: "FAILS — UNINFORMATIVE; R1/R2 unscored per registration" }
  : { R3: "GATE PASSES", R1: r1 ? "LANDS" : "FAILS", R2: r2 ? "LANDS" : "FAILS" };
console.log("\nVERDICTS:", JSON.stringify(verdicts));

writeFileSync("oracle-scanner/rustsec.json", JSON.stringify({
  advisoryDbCommit: dbCommit, cutoff: CUTOFF,
  advisoriesTotal: advTotal, advisoriesAfterCutoff: advAfter,
  labeledInSnapshot: { primary: labPrimary.length, secondary: labSecondary.length },
  n, table, verdicts,
  labeledPrimary: labPrimary.sort(),
}, null, 1));
console.log("wrote oracle-scanner/rustsec.json");
