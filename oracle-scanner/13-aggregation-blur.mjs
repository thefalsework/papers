// Oracle scanner — AGGREGATION BLUR: does project/repository-level
// aggregation bury quiet criticality? Study 12's G2 inversion made
// real-world, against ground-truth project mappings instead of name
// heuristics. REGISTRATION — this header is frozen before any mapping
// is extracted and before any code below it is written; coverage
// gates and thresholds are therefore set blind.
//
// PROMPT. Study 12 (observer-cost.json) found that semantic
// partitions damage the head of the conemass ranking MORE than
// size-matched random partitions at identical granularity, because
// semantic classes are exactly the sets dependency cones
// systematically touch. If that mechanism survives contact with the
// aggregation real tools actually perform, then criticality
// assessment done at project granularity systematically blurs the
// quiet-critical class (the liblzma5 profile: #8 of 63,436 as a
// package; invisible inside "xz-utils, moderately popular" as a
// project). Study 12 used name-derived partitions (stems, sections);
// this study uses the aggregations tools actually use.
//
// SCOPE, stated before anything runs: the registered claims are
// about THESE corpora, THESE mappings, THIS granularity. The
// correspondence to real tools is a modeling assumption, disclosed
// here and not itself tested: arm A approximates repository-level
// SBOM dependency resolution; arm B approximates OpenSSF-style
// project scoring. Any sentence of the form "project-level tools
// are blind to quiet criticality" is an EXTRAPOLATION from this
// study, not its finding.
//
// TWO ARMS — real tools do two different things, with potentially
// opposite effects, so they are registered separately:
//
//   ARM A, cone inflation (the study-12 observer on a real
//   partition): the blur believes you depend on every package in
//   the same project as your real dependencies. A falsework
//   observer in the strict sense (C_u ⊆ JC_u); the inequality
//   applies; bound and ratio reported alongside. Mechanism at risk:
//   credit spread onto phantom siblings.
//
//   ARM B, target pooling: compute the TRUE per-package conemass
//   field, then sum it within each project and rank projects. NOT
//   an observer in the theorem's formalism — a pushforward of the
//   output field; no cones inflate, no phantoms exist, and total
//   mass is conserved by construction, so the entire question is
//   positional. This arm borrows no authority from the falsework
//   inequality. Mechanism at risk: fame-by-aggregation — bulk
//   projects accumulating credit that outranks a quiet package's
//   small project.
//
// CORPORA AND MAPPINGS (fixed):
//   PRIMARY: Debian bookworm 2023 (debian-study/history/2023.json,
//   cap 200, SCC condensation, the study-11/12 traversal verbatim;
//   partition class of a multi-member component via first member,
//   the disclosed study-11 approximation). Mapping: the archive's
//   own binary-to-source mapping, extracted from the bookworm
//   Packages.gz "Source:" field (version suffix in parentheses
//   stripped; packages with no Source field are their own source —
//   the field is omitted exactly when binary name = source name,
//   Debian Policy 5.6.1). This mapping is ground truth, same epoch
//   as the snapshot; extraction script debian-study/05-sources.mjs,
//   written and run only after this header is committed.
//   REPLICATION: crates.io 2022 (software-study/history/
//   crates-2022.json, same configuration). Mapping: the
//   "repository" field of the crates.io database dump current at
//   run time (static.crates.io/db-dump.tar.gz; dump date recorded
//   in the postscript; its ~4-year distance from the 2022 snapshot
//   disclosed as a limitation). Normalization: lowercase, strip
//   protocol, "www.", trailing "/", trailing ".git", and any path
//   segments beyond host/org/repo. Shared repository URL = same
//   project (faithful to the tool model: monorepos are scored as
//   one project). Missing, empty, or unparseable repository =
//   singleton project of itself, disclosed. COVERAGE GATE: if
//   fewer than 60% of the snapshot's crates resolve to a
//   non-singleton-by-default mapping row (i.e., appear in the dump
//   with a nonempty repository field), the crates cells ship as
//   DESCRIPTIVE ONLY and all registered claims are evaluated on
//   Debian alone. If the dump cannot be obtained at run time, the
//   crates arm ships as not-run with disclosure.
//   EXCLUDED with disclosure: Prove2Me (missions ARE the project
//   granularity — the tool-model question does not arise); Mathlib
//   and Go (same exclusions and reasons as studies 10 and 12).
//
// NULLS: for arm A, one seeded uniform random partition per corpus
// with the identical multiset of class sizes as the real project
// partition (seed 13, fixed now; same construction as study 12).
// Arm B pooling is also run over the same random partition, so both
// arms carry their own granularity-matched null.
//
// MEASUREMENTS, fixed in advance:
//   ARM A (per corpus): head survival = top-40 overlap of blurred
//   vs true field (study-11 tie convention, by name); L1 distortion,
//   falsework bound, ratio; conservation gap (prediction: 0, dense).
//   Same for the random-null partition.
//   ARM B (per corpus): project ranking by pooled true mass (ties
//   by project name). For each true top-40 package: its project's
//   rank — reported in full, with median and worst. Registered
//   summary: BURIED COUNT = number of true-top-40 packages whose
//   project ranks outside the project top-40. Total pooled mass
//   must equal total true mass to float epsilon (gate, not
//   finding). Same for the random-null grouping. Named row,
//   recorded either way: liblzma5 and the rank of its source
//   project (src:xz-utils) under pooling.
//
// VALIDATION GATES (halt before reading results if violated):
//   V1 arm-A partitions are dense: conservation gap < 1e-6.
//   V2 arm-B pooling conserves: |pooled total - true total| < 1e-6.
//   V3 the inequality on arm A: bound >= actual in every cell (the
//      kernel-checked theorem; a violation is a harness bug, never
//      a finding).
//   V4 mapping sanity, Debian: liblzma5 maps to source xz-utils (a
//      known ground-truth row; failure means the Source-field
//      parser is wrong).
//
// REGISTERED CLAIMS AND KILLS (evaluated on Debian; crates is
// replication color subject to its coverage gate):
//   CLAIM A ("dependency-resolution-style aggregation buries quiet
//   criticality"): fires if source-project head survival <= 20/40
//   AND strictly below its random null's survival. DEAD (K13a) if
//   survival >= 30/40 OR >= the null. Between: attenuated, no claim.
//   CLAIM B ("score pooling hides quiet criticality"): fires if
//   buried count >= 10 of 40. DEAD (K13b) if buried count <= 4.
//   Between: attenuated, no claim.
//   The two claims are independent; either can die alone. If both
//   die, the G2 inversion is a name-heuristic artifact with no
//   tool-relevant content, and that verdict ships permanently.
//
// REGISTERED GUESSES (reported right or wrong, no kill attached):
//   G1 arm-A Debian survival strictly below its random null — the
//      study-12 inversion replicates on a ground-truth mapping.
//   G2 pooling is the gentler operation: Debian buried count <
//      (40 - arm-A survival), i.e. arm B hides less of the head
//      than arm A destroys.
//   G3 pooling lifts the archetype: src:xz-utils ranks INSIDE the
//      project top-40 on Debian — the quiet package's credit,
//      summed with its siblings', surfaces the project even though
//      per-package identity is lost. (If G3 holds while claim B
//      fires, the finding is that pooling preserves projects with
//      concentrated quiet load while burying others — recorded as
//      mechanism color, not a registered claim.)
//
// DESCRIPTIVE ONLY, no status: attribution resolution (a project's
// pooled score does not say which package carries it — for each
// top-10 project, the share of its pooled mass carried by its
// top package); per-project package counts; anything found in
// the crates cells if the coverage gate fails.
//
// Writes oracle-scanner/aggregation-blur.json.
//
// ============================================================
// POSTSCRIPT (2026-09-25, after the run; header above unchanged
// from registration commit e4f0b8d). ranAt 2026-09-25T20:43:07.226Z.
// ============================================================
//
// Gates V1-V4 all passed. cratesMeta: dumpDate 2026-09-25, coverage
// 0.8019, status "replication (coverage gate passed)".
//
// CLAIM A ("dependency-resolution-style aggregation buries quiet
// criticality"): FIRES. Debian source-project head survival 1/40
// (34149 classes), strictly below the random null 2/40. Both
// registered fire conditions hold (≤20/40 and < null). K13a does
// not apply.
// CLAIM B ("score pooling hides quiet criticality"): DEAD (K13b).
// Debian buried count 2/40 (median project rank 13, worst 42).
// Registered kill is buried count ≤ 4.
//
// GUESSES (Debian, no kill attached): G1 RIGHT (1 vs 2). G2 RIGHT
// (arm B buries 2; arm A loses 39). G3 RIGHT (src:xz-utils
// project rank 7).
//
// REPLICATION COLOR (crates, not a registered claim): arm A
// survival 16/40 vs null 14/40 (65573 classes); arm B buried 3/40
// (median 20, worst 44). crates buried count 3/40 would also meet
// the K13b threshold. Coverage gate passed; dump ~4 years after
// the 2022 snapshot, as registered.
//
// MECHANISM, not a registered claim: the Debian null also collapsed
// (2/40). G1's margin is one row. Crates arm A is above its null
// (16 vs 14), so the study-12 inversion direction does not appear
// in the replication cell. The Claim A fire should not be cited as
// evidence that semantic grouping buries quiet criticality; the
// size-matched null collapsed nearly as far. Descriptive
// attribution (no status): gcc-12 is pooled rank 1, 98 packages,
// top-package share 0.430; xz-utils is pooled rank 7, 5 packages,
// liblzma5 share 0.984.
// ============================================================

import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { buildSnap } from "../deflation-control/lib.mjs";
import { oracleMass } from "../battery-v3/lib.mjs";

const CAP = 200;
const SEED = 13; // frozen in header

function mulberry32(a) {
  return function () {
    a |= 0; a = (a + 0x6D2B79F5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

// study-11/12 head convention: rank by field desc, ties by name
function top40(rows, nameOf, key) {
  return rows.slice().sort((a, b) =>
    b[key] - a[key] || (nameOf(a.c) < nameOf(b.c) ? -1 : 1)).slice(0, 40);
}

// ---------- ARM A: cone inflation (study-12 partitionStudy, cloned) ----------
function armA(snap, cm, label, cls) {
  const { nComp, compMembers, cIn, names } = snap;
  const classSize = new Map();
  const compClass = new Array(nComp);
  for (let c = 0; c < nComp; c++) {
    const k = cls(c);
    compClass[c] = k;
    classSize.set(k, (classSize.get(k) ?? 0) + 1);
  }
  const W = new Map();
  let bound = 0;
  const seen = new Int32Array(nComp).fill(-1);
  for (let u = 0; u < nComp; u++) {
    const cone = [];
    seen[u] = u;
    const q = [u];
    let head = 0;
    while (head < q.length && cone.length < CAP) {
      const v = q[head++];
      for (const w of cIn[v]) {
        if (seen[w] === u) continue;
        seen[w] = u;
        cone.push(w);
        if (cone.length >= CAP) break;
        q.push(w);
      }
    }
    if (!cone.length) continue; // dense
    const touched = new Set();
    for (const x of cone) touched.add(compClass[x]);
    let jSize = 0;
    for (const k of touched) jSize += classSize.get(k);
    const credit = 1 / jSize;
    for (const k of touched) W.set(k, (W.get(k) ?? 0) + credit);
    bound += (2 * (jSize - cone.length)) / jSize;
  }
  let l1 = 0, totTrue = 0, totBlur = 0;
  const rows = [];
  for (let c = 0; c < nComp; c++) {
    const blurred = W.get(compClass[c]) ?? 0;
    l1 += Math.abs(blurred - cm[c]);
    totTrue += cm[c];
    totBlur += blurred;
    rows.push({ c, true: cm[c], blurred });
  }
  const nameOf = (c) => names[compMembers[c][0]];
  const tTrue = new Set(top40(rows, nameOf, "true").map((r) => r.c));
  const survival = top40(rows, nameOf, "blurred").filter((r) => tTrue.has(r.c)).length;
  return {
    observer: label, classes: classSize.size,
    l1Actual: l1, l1Bound: bound, ratio: bound / l1,
    conservationGap: Math.abs(totBlur - totTrue),
    headSurvival40: survival,
  };
}

// ---------- ARM B: target pooling (pushforward of the true field) ----------
function armB(snap, cm, label, cls) {
  const { nComp, compMembers, names } = snap;
  const nameOf = (c) => names[compMembers[c][0]];
  const pool = new Map();
  const members = new Map();
  let totTrue = 0;
  for (let c = 0; c < nComp; c++) {
    const k = cls(c);
    pool.set(k, (pool.get(k) ?? 0) + cm[c]);
    totTrue += cm[c];
    if (!members.has(k)) members.set(k, []);
    members.get(k).push(c);
  }
  let totPool = 0;
  for (const v of pool.values()) totPool += v;
  const ranked = [...pool.entries()].sort((a, b) => b[1] - a[1] || (a[0] < b[0] ? -1 : 1));
  const rankOf = new Map(ranked.map(([k], i) => [k, i + 1]));

  const rows = Array.from({ length: nComp }, (_, c) => ({ c, true: cm[c] }));
  const head = top40(rows, nameOf, "true").map((r) => ({
    package: nameOf(r.c), mass: r.true,
    project: cls(r.c), projectRank: rankOf.get(cls(r.c)),
  }));
  const ranks = head.map((h) => h.projectRank).sort((a, b) => a - b);
  const buried = head.filter((h) => h.projectRank > 40).length;

  // descriptive: attribution resolution for the top-10 projects
  const attribution = ranked.slice(0, 10).map(([k, mass], i) => {
    const top = members.get(k).reduce((best, c) => (cm[c] > cm[best] ? c : best));
    return {
      rank: i + 1, project: k, pooledMass: mass,
      packages: members.get(k).length,
      topPackage: nameOf(top), topPackageShare: cm[top] / mass,
    };
  });
  return {
    grouping: label, projects: pool.size,
    conservationGap: Math.abs(totPool - totTrue),
    buriedCount: buried,
    projectRankMedian: ranks[Math.floor(ranks.length / 2)],
    projectRankWorst: ranks[ranks.length - 1],
    head, attribution,
  };
}

function randomPartitionCls(snap, natCls, seed) {
  const { nComp } = snap;
  const sizeMap = new Map();
  for (let c = 0; c < nComp; c++) {
    const k = natCls(c);
    sizeMap.set(k, (sizeMap.get(k) ?? 0) + 1);
  }
  const classes = [...sizeMap.entries()].sort((a, b) => b[1] - a[1] || (a[0] < b[0] ? -1 : 1));
  const idx = Array.from({ length: nComp }, (_, i) => i);
  const rnd = mulberry32(seed);
  for (let i = nComp - 1; i > 0; i--) {
    const j = Math.floor(rnd() * (i + 1));
    [idx[i], idx[j]] = [idx[j], idx[i]];
  }
  const lab = new Array(nComp);
  let pos = 0, ci = 0;
  for (const [, size] of classes) {
    const name = `r${ci++}`;
    for (let k = 0; k < size; k++) lab[idx[pos++]] = name;
  }
  return (c) => lab[c];
}

function runCorpus(corpus, snap, projectCls) {
  const cm = oracleMass(snap, CAP);
  const nullCls = randomPartitionCls(snap, projectCls, SEED);
  return {
    corpus,
    armA: {
      project: armA(snap, cm, "project partition", projectCls),
      randomNull: armA(snap, cm, "random size-matched", nullCls),
    },
    armB: {
      project: armB(snap, cm, "project pooling", projectCls),
      randomNull: armB(snap, cm, "random size-matched pooling", nullCls),
    },
  };
}

// ---------- Debian (primary) ----------
const debianRaw = JSON.parse(readFileSync("debian-study/history/2023.json", "utf8"));
const sources = JSON.parse(readFileSync("debian-study/history/sources-2023.json", "utf8"));
const dSnap = buildSnap(debianRaw.nodes, debianRaw.edges);
const dName = (c) => dSnap.names[dSnap.compMembers[c][0]];
const dCls = (c) => sources[dName(c)] ?? dName(c);
const debian = runCorpus("debian-2023", dSnap, dCls);

// ---------- crates (replication, coverage-gated) ----------
let crates = null;
let cratesMeta = { status: "not run: mapping unavailable at run time" };
const REPO_MAP = "software-study/history/crates-repos.json";
if (existsSync(REPO_MAP)) {
  const meta = JSON.parse(readFileSync(REPO_MAP, "utf8"));
  const cratesRaw = JSON.parse(readFileSync("software-study/history/crates-2022.json", "utf8"));
  const cSnap = buildSnap(cratesRaw.nodes, cratesRaw.edges);
  const cName = (c) => cSnap.names[cSnap.compMembers[c][0]];
  let mapped = 0;
  for (const nm of cratesRaw.nodes) if (meta.repos[nm]) mapped++;
  const coverage = mapped / cratesRaw.nodes.length;
  const cCls = (c) => meta.repos[cName(c)] ?? `self:${cName(c)}`;
  crates = runCorpus("crates-2022", cSnap, cCls);
  cratesMeta = {
    status: coverage >= 0.6 ? "replication (coverage gate passed)" : "DESCRIPTIVE ONLY (coverage below registered 60% gate)",
    dumpDate: meta.dumpDate, coverage,
  };
}

// ---------- gates ----------
const fails = [];
for (const co of [debian, crates].filter(Boolean)) {
  for (const arm of [co.armA.project, co.armA.randomNull])
    if (arm.conservationGap >= 1e-6) fails.push(`V1 ${co.corpus}/${arm.observer}: gap ${arm.conservationGap}`);
  for (const arm of [co.armB.project, co.armB.randomNull])
    if (arm.conservationGap >= 1e-6) fails.push(`V2 ${co.corpus}/${arm.grouping}: gap ${arm.conservationGap}`);
  for (const arm of [co.armA.project, co.armA.randomNull])
    if (!(arm.ratio >= 1.0)) fails.push(`V3 ${co.corpus}/${arm.observer}: ratio ${arm.ratio} < 1`);
}
if (sources["liblzma5"] !== "xz-utils") fails.push(`V4: liblzma5 maps to ${sources["liblzma5"]}`);
if (fails.length) {
  console.error("VALIDATION GATE FAILURE — results not read, nothing written:");
  for (const f of fails) console.error("  " + f);
  process.exit(1);
}
console.log("gates V1-V4: all pass\n");

// ---------- claims, kills, guesses (Debian primary, per header) ----------
const A = debian.armA, B = debian.armB;
const claimA =
  A.project.headSurvival40 >= 30 || A.project.headSurvival40 >= A.randomNull.headSurvival40
    ? "DEAD (K13a)"
    : A.project.headSurvival40 <= 20 && A.project.headSurvival40 < A.randomNull.headSurvival40
      ? "FIRES" : "attenuated, no claim";
const claimB =
  B.project.buriedCount <= 4 ? "DEAD (K13b)"
  : B.project.buriedCount >= 10 ? "FIRES" : "attenuated, no claim";
const xzRow = B.project.head.find((h) => h.package === "liblzma5") ??
  { note: "liblzma5 not in true top-40", projectRank: null };
const xzProjectRank = (() => {
  const r = B.project.head.find((h) => h.project === "xz-utils");
  return r ? r.projectRank : xzRow.projectRank;
})();
const guesses = {
  g1: { statement: "arm-A project survival strictly below random null", value: `${A.project.headSurvival40} vs ${A.randomNull.headSurvival40}`, right: A.project.headSurvival40 < A.randomNull.headSurvival40 },
  g2: { statement: "buried count < 40 - armA survival", value: `${B.project.buriedCount} vs ${40 - A.project.headSurvival40}`, right: B.project.buriedCount < 40 - A.project.headSurvival40 },
  g3: { statement: "src:xz-utils inside project top-40 under pooling", value: xzProjectRank, right: xzProjectRank !== null && xzProjectRank <= 40 },
};

console.log(`ARM A (debian): project survival ${A.project.headSurvival40}/40 (ratio ${A.project.ratio.toFixed(3)}, ${A.project.classes} projects), null ${A.randomNull.headSurvival40}/40 (ratio ${A.randomNull.ratio.toFixed(3)}) -> CLAIM A: ${claimA}`);
console.log(`ARM B (debian): buried ${B.project.buriedCount}/40 (median project rank ${B.project.projectRankMedian}, worst ${B.project.projectRankWorst}), null buried ${B.randomNull.buriedCount}/40 -> CLAIM B: ${claimB}`);
console.log(`xz row: liblzma5 project rank under pooling = ${xzProjectRank}`);
for (const [k, g] of Object.entries(guesses)) console.log(`${k.toUpperCase()} ${g.right ? "RIGHT" : "WRONG"}: ${g.statement} (${g.value})`);
if (crates) {
  console.log(`\ncrates (${cratesMeta.status}, coverage ${(cratesMeta.coverage * 100).toFixed(1)}%):`);
  console.log(`  armA project ${crates.armA.project.headSurvival40}/40 vs null ${crates.armA.randomNull.headSurvival40}/40; armB buried ${crates.armB.project.buriedCount}/40 vs null ${crates.armB.randomNull.buriedCount}/40`);
}

writeFileSync("oracle-scanner/aggregation-blur.json", JSON.stringify({
  registered: "e4f0b8d", ranAt: new Date().toISOString(),
  cap: CAP, seed: SEED,
  debian, crates, cratesMeta,
  verdicts: { claimA, claimB }, guesses,
}, null, 1));
console.log("\nwrote oracle-scanner/aggregation-blur.json");
