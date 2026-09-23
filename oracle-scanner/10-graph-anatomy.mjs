// Oracle scanner — GRAPH ANATOMY: what shape statistic predicts, in
// advance, whether conemass separates from PageRank on a graph?
// Registered before running.
//
// PROMPT. The measured map so far: Debian bookworm 22/40 top-40
// overlap with PageRank (separates), crates-2022 35/40 (coincides),
// Prove2Me 33/40 (coincides), Mathlib 21/40-but-plumbing with
// Spearman 0.96 (coincides in substance). Study 06's postscript left
// the mechanism unmapped, with one hypothesis on the table: Debian's
// layered base-system topology — deep shared runtime chains under
// every leaf, the krb5 gateway class — versus the flatter
// macro-toolchain topology of crates. If a cheap statistic computed
// from the graph alone predicts the overlap, "where is conemass worth
// running?" gets an a-priori answer instead of a run-it-and-see.
//
// CORPORA (15 graphs, three families): Debian 2007..2025 (ten
// snapshots), crates 2016..2022 (four), Prove2Me union graph (one).
// Excluded with disclosure: Go history graphs (159-399 nodes — a
// top-40 statistic is meaningless); Mathlib (different pipeline, 8.4M
// edges; its measured point, 21/40 / Spearman 0.96, is cited in
// interpretation but not recomputed here). Disclosed: three of the
// fifteen outcomes are already known (Debian-2023 22, crates-2022 35,
// Prove2Me 33); the other twelve are new. Registration fixes the
// predictors and directions before those twelve are seen.
//
// OUTCOME per graph: top-40 overlap between conemass (cap 200) and
// PageRank ranks. Lower overlap = more separation.
//
// REGISTERED PREDICTORS, computed on the SCC condensation (the graph
// the metrics actually see), with directions fixed now:
//   S1 chain fraction — fraction of components with exactly one
//      dependency (|cIn| = 1). Chain links pass conemass credit
//      undamped, while PageRank decays by 0.85 per hop and splits
//      across out-links; chains are where the two functionals
//      mechanically diverge (the krb5 gateway chain is the archetype).
//      Direction: higher S1 -> lower overlap. PRIMARY.
//   S2 mean cone depth — mean BFS depth of the truncated (cap 200)
//      dependency cone, over components with nonempty cones. The 06
//      hypothesis: deep shared runtime chains under every leaf.
//      Direction: deeper -> lower overlap.
//   S3 cone-size heterogeneity — coefficient of variation of
//      truncated cone sizes. The harmonic weight 1/|cone| only
//      matters if cone sizes vary. Direction: higher CV -> lower
//      overlap.
//   S4 leaf share — fraction of components with no dependents
//      (pure consumers, the "voters" whose credits conemass sums).
//      Direction: higher -> lower overlap.
//
// SUCCESS CRITERION, registered: a predictor counts as predictive if
// Spearman(predictor, overlap) across the 15 graphs has the
// registered sign with |rho| >= 0.6, AND the family-level ordering
// agrees (Debian family median must sit on the separating side of
// crates and Prove2Me, since Debian is the known separator). Honest
// scope: within-family points are correlated (same ecosystem evolving
// biennially), so the effective n is closer to 3 families than 15
// graphs. This is anatomy — a mechanism sketch plus a candidate
// statistic to test on the NEXT new graph — not a confirmed law.
//
// Writes oracle-scanner/graph-anatomy.json.
//
// ============================================================
// POSTSCRIPT (after the run, 2026-09-23)
//
// THE PRIMARY IS DEAD. S1 (chain fraction): rho = -0.135. Worse than
// weak — Prove2Me has the HIGHEST chain fraction of all 15 graphs
// (0.290) and coincides with PageRank. The krb5-gateway-chain
// intuition, promoted here to primary predictor, does not generalize
// as a global statistic. (Chains explain WHICH rows diverge on
// Debian; they do not predict WHETHER a graph diverges.)
//
// S3 (cone-size CV): rho = +0.580 — WRONG SIGN, fails.
// S4 (leaf share): rho = +0.628 — WRONG SIGN, fails. More pure
// consumers went with MORE PageRank agreement, not less; Prove2Me
// (leaf share 0.102, lowest by 5x) coincides anyway.
//
// S2 (mean truncated-cone depth) PASSES the registered criterion:
// rho = -0.729, registered sign, and the family ordering is right —
// Debian median depth 5.19 / overlap 25 (separates), crates 3.82 /
// 33, Prove2Me 2.52 / 33 (coincide). Mechanism reading: conemass
// credit travels a dependency chain undamped, PageRank decays by
// 0.85 per hop and splits across links, so the functionals diverge
// where cones are deep and agree where the mass sits one or two hops
// away. Within-Debian, deeper years trend to lower overlap (2017:
// depth 5.49, overlap 21) and the family drifted more separating as
// the archive grew (28/40 in 2007 -> 22/40 by 2019).
//
// OUT-OF-FAMILY CHECK (conemass-mathlib/depth-stats.mjs, prediction
// stated before measuring): Mathlib's truncated depth came back 4.45
// — below the Debian median as predicted, direction right, BUT inside
// the Debian family range (4.41-5.54). debian-2025 (depth 4.41)
// separates at 23/40 while Mathlib (4.45) coincides at Spearman 0.96:
// a near-tie in S2 with opposite outcomes. Depth alone is therefore
// NOT sufficient; the partial pass is reported as partial.
//
// UNREGISTERED OBSERVATION (exploration, no claim): mean truncated
// cone size puts the coinciders at both extremes — Prove2Me 9.6 and
// crates-2016 9.6 (cones too small for the harmonic weight to matter)
// vs Mathlib 150.4/200 (cap-saturated fanout: everything's cone is
// everything) — with the separator Debian mid-range (37-54, thin-
// but-deep). A second, non-monotonic factor of this shape would
// reconcile the Mathlib near-tie, but it was found by looking and
// gets no status until registered on a new graph.
//
// VERDICT: one of four registered predictors survives. The
// falsifiable statement for the NEXT new graph: truncated-cone depth
// >= 5 predicts separation from PageRank, <= 4 predicts coincidence,
// and 4-5 is the disclosed unresolved band (Mathlib and late-Debian
// sit there with opposite outcomes). Effective n is ~3 families plus
// one external point; this is a candidate statistic with a
// registered track record, not a law.
// ============================================================

import { readFileSync, writeFileSync } from "node:fs";
import { buildSnap } from "../deflation-control/lib.mjs";
import { pagerank } from "../baseline-gauntlet/gauntlet-lib.mjs";
import { oracleMass } from "../battery-v3/lib.mjs";

const CAP = 200;

// truncated-cone stats: size and BFS depth per component, same
// traversal as oracleMass (cIn, cap, insertion-order queue)
function coneStats(snap, cap = CAP) {
  const { nComp, cIn } = snap;
  const sizes = new Int32Array(nComp);
  const depths = new Int32Array(nComp);
  const seen = new Int32Array(nComp).fill(-1);
  const depth = new Int32Array(nComp);
  for (let u = 0; u < nComp; u++) {
    seen[u] = u; depth[u] = 0;
    let size = 0, maxD = 0;
    const q = [u];
    let head = 0;
    while (head < q.length && size < cap) {
      const v = q[head++];
      for (const w of cIn[v]) {
        if (seen[w] === u) continue;
        seen[w] = u;
        depth[w] = depth[v] + 1;
        if (depth[w] > maxD) maxD = depth[w];
        size++;
        if (size >= cap) break;
        q.push(w);
      }
    }
    sizes[u] = size; depths[u] = maxD;
  }
  return { sizes, depths };
}

function spearman(xs, ys) {
  const n = xs.length;
  const rank = (arr) => {
    const idx = Array.from({ length: n }, (_, i) => i).sort((a, b) => arr[a] - arr[b]);
    const r = new Array(n);
    let i = 0;
    while (i < n) {
      let j = i;
      while (j + 1 < n && arr[idx[j + 1]] === arr[idx[i]]) j++;
      const avg = (i + j) / 2 + 1;
      for (let k = i; k <= j; k++) r[idx[k]] = avg;
      i = j + 1;
    }
    return r;
  };
  const rx = rank(xs), ry = rank(ys);
  const mx = rx.reduce((a, b) => a + b) / n, my = ry.reduce((a, b) => a + b) / n;
  let num = 0, dx = 0, dy = 0;
  for (let i = 0; i < n; i++) {
    num += (rx[i] - mx) * (ry[i] - my);
    dx += (rx[i] - mx) ** 2; dy += (ry[i] - my) ** 2;
  }
  return num / Math.sqrt(dx * dy);
}

function study(label, family, names, edges) {
  const snap = buildSnap(names, edges);
  const { nComp, compMembers, cIn, cOut } = snap;
  const pr = pagerank(snap);
  const orc = oracleMass(snap);
  const { sizes, depths } = coneStats(snap);

  // outcome: top-40 overlap on package names (min-tie irrelevant at set level)
  const rows = [];
  for (let c = 0; c < nComp; c++) {
    for (const m of compMembers[c]) rows.push({ name: names[m], orc: orc[c], pr: pr[c] });
  }
  const topSet = (key) => new Set(
    rows.slice().sort((a, b) => b[key] - a[key] || (a.name < b.name ? -1 : 1))
      .slice(0, 40).map((r) => r.name));
  const tOr = topSet("orc"), tPr = topSet("pr");
  const overlap = [...tOr].filter((x) => tPr.has(x)).length;

  // predictors on the condensation
  let chain = 0, leaf = 0, nzCones = 0, sumSize = 0, sumSize2 = 0, sumDepth = 0;
  for (let c = 0; c < nComp; c++) {
    if (cIn[c].length === 1) chain++;
    if (cOut[c].length === 0) leaf++;
    if (sizes[c] > 0) {
      nzCones++;
      sumSize += sizes[c]; sumSize2 += sizes[c] * sizes[c];
      sumDepth += depths[c];
    }
  }
  const meanSize = sumSize / nzCones;
  const sd = Math.sqrt(sumSize2 / nzCones - meanSize * meanSize);
  const res = {
    label, family, nComp, overlap,
    S1_chainFrac: chain / nComp,
    S2_meanConeDepth: sumDepth / nzCones,
    S3_coneSizeCV: sd / meanSize,
    S4_leafShare: leaf / nComp,
  };
  console.log(`${label}: nComp ${nComp}  overlap ${overlap}/40  S1 ${res.S1_chainFrac.toFixed(3)}  S2 ${res.S2_meanConeDepth.toFixed(2)}  S3 ${res.S3_coneSizeCV.toFixed(2)}  S4 ${res.S4_leafShare.toFixed(3)}`);
  return res;
}

const results = [];
for (const y of [2007, 2009, 2011, 2013, 2015, 2017, 2019, 2021, 2023, 2025]) {
  const raw = JSON.parse(readFileSync(`debian-study/history/${y}.json`, "utf8"));
  results.push(study(`debian-${y}`, "debian", raw.nodes, raw.edges));
}
for (const y of [2016, 2018, 2020, 2022]) {
  const raw = JSON.parse(readFileSync(`software-study/history/crates-${y}.json`, "utf8"));
  results.push(study(`crates-${y}`, "crates", raw.nodes, raw.edges));
}
{
  const lines = readFileSync("C:/dev/conemass/examples/prove2me/out/edges-union.csv", "utf8").trim().split("\n").slice(1);
  const idx = new Map(); const names = []; const edges = [];
  const id = (nm) => {
    let i = idx.get(nm);
    if (i === undefined) { i = names.length; idx.set(nm, i); names.push(nm); }
    return i;
  };
  for (const l of lines) {
    const c = l.indexOf(",");
    edges.push([id(l.slice(0, c)), id(l.slice(c + 1))]);
  }
  results.push(study("prove2me", "prove2me", names, edges));
}

// correlations across all 15 graphs
console.log("\n=== Spearman(predictor, top-40 overlap) across 15 graphs ===");
const ov = results.map((r) => r.overlap);
const corr = {};
for (const k of ["S1_chainFrac", "S2_meanConeDepth", "S3_coneSizeCV", "S4_leafShare"]) {
  corr[k] = spearman(results.map((r) => r[k]), ov);
  console.log(`${k}: rho = ${corr[k].toFixed(3)} (registered direction: negative)`);
}

// family medians
console.log("\n=== family medians ===");
const fams = {};
for (const fam of ["debian", "crates", "prove2me"]) {
  const rs = results.filter((r) => r.family === fam);
  const med = (key) => {
    const v = rs.map((r) => r[key]).sort((a, b) => a - b);
    return v[Math.floor(v.length / 2)];
  };
  fams[fam] = {
    overlap: med("overlap"), S1: med("S1_chainFrac"), S2: med("S2_meanConeDepth"),
    S3: med("S3_coneSizeCV"), S4: med("S4_leafShare"),
  };
  console.log(`${fam}: overlap ${fams[fam].overlap}  S1 ${fams[fam].S1.toFixed(3)}  S2 ${fams[fam].S2.toFixed(2)}  S3 ${fams[fam].S3.toFixed(2)}  S4 ${fams[fam].S4.toFixed(3)}`);
}

writeFileSync("oracle-scanner/graph-anatomy.json",
  JSON.stringify({ results, correlations: corr, familyMedians: fams }, null, 1));
console.log("\nwrote oracle-scanner/graph-anatomy.json");
