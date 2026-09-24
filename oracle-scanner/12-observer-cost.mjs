// Oracle scanner — OBSERVER COST SURVEY: the falsework inequality as
// an instrument, measured across an observer family on three corpora.
// REGISTERED 2026-09-24, commit ca23907 (header frozen there; this
// status line is the only header text changed when the implementation
// was added below, after the freeze).
//
// PROMPT. Study 11 measured the falsework inequality (kernel-checked,
// lean/FalseWorkPapers/Lattice/FalseworkInequality.lean; note at
// falsework-note/falsework-inequality.md, v0.2) on one graph with two
// observers: bound within 1.05x/1.16x of actual L1 distortion, head
// survival 29/40 vs 0/40. The note's v0.2 correction softened "prices
// the blur before any ranking is run" to: the bound's value is
// analytic (computing the phantom count p_u = |JC_u| - |C_u| requires
// the true cones, at which point both fields are cheap), and head
// survival — the triage-relevant quantity — must still be measured.
// This study asks the question that softening left open, as a
// registered claim with a kill: across a family of natural and
// synthetic observers on three corpora, does the RELATIVE BOUND
// (bound / total true mass) RANK-ORDER head survival? If yes, the
// inequality is a usable comparative instrument (given two candidate
// coarse-grainings, the bound says which one destroys triage). If
// no, its value is analytic only, permanently. Secondary: does the
// bound stay near-exact in aggregate (study 11's 1.05-1.16x) across
// corpora and across observer TYPES — including non-idempotent and
// non-dense blurs the theorem covers but study 11 never exercised?
//
// TERMINOLOGY (v0.2): p_u is the phantom COUNT on cone u. The
// aperture papers' phantom mass is the interval cardinality 2^p_u;
// related by a logarithm, not identical.
//
// CORPORA (3, fixed):
//   C1 Debian bookworm 2023 (debian-study/history/2023.json) — the
//      published conemass configuration and study-11 anchor.
//   C2 crates.io 2022 (software-study/history/crates-2022.json) —
//      the published crates snapshot.
//   C3 Prove2Me union graph
//      (C:/dev/conemass/examples/prove2me/out/edges-union.csv) —
//      proof corpus, out-of-family.
//   Excluded with disclosure: Mathlib (different pipeline, 8.4M
//   edges — same exclusion and reason as study 10); Go graphs (too
//   small for a top-40 statistic).
// Cones: truncated (cap 200) dependency cones on the SCC
// condensation, the exact study-11 traversal (insertion-order BFS,
// cap break mid-neighbor-loop). Cone of u excludes u. Partition
// class of a multi-member component assigned via first member
// (study-11 disclosed approximation).
//
// OBSERVER FAMILY (fixed now; every J satisfies C_u ⊆ JC_u — the
// only hypothesis the theorem uses):
//
// Natural partition closures (inflationary, idempotent, dense, NOT
// meet-preserving — non-nuclei):
//   P1 stem partition — Debian: the study-11 stem function verbatim.
//      Crates: lowercase, strip [0-9.]+, collapse [-_]+ runs, trim
//      trailing separators (crude; disclosed). Not defined on C3
//      (theorem names are not versioned; disclosed).
//   P2 coarse semantic partition — Debian: section
//      (sections-2023.json, study-11 O2 verbatim). Crates: project
//      prefix (name up to first '-' or '_', else whole name).
//      Prove2Me: namespace (name up to first '.', else whole name).
//
// Calibration nulls:
//   R(P) — for each natural partition above, one seeded uniform
//      random partition over components with the IDENTICAL multiset
//      of class sizes (seed 12, fixed now). Same granularity, zero
//      semantics.
//
// Non-partition inflationary blurs (the generality stress; neither
// is a partition closure, and N2 is not dense):
//   N1 truncation observer — JC_u = the cap-800 cone of u. Contains
//      the cap-200 cone by the traversal's prefix property
//      (identical insertion order up to the cap; disclosed). Not
//      induced by any operator on sets; the theorem needs only the
//      per-cone inclusion. Reading: the cost of cap 200 itself,
//      connecting to the study-02 cap sweep.
//   N2 base-set adjunction — JC_u = C_u ∪ H, H = the top 16
//      components by in-degree on the condensation (h = 16
//      arbitrary, fixed now; ties by name). Applied to EMPTY cones
//      too: J(∅) = H, so N2 is NOT dense. On the powerset this is
//      the closed nucleus S ↦ S ∪ H — the one true nucleus in the
//      family. Reading: an observer that assumes everything sits on
//      the base system.
//
// Cells: C1 × {P1, P2, R(P1), R(P2), N1, N2} = 6; C2 × same = 6;
// C3 × {P2, R(P2), N1, N2} = 4. Total 16 cells.
//
// MEASUREMENTS, fixed in advance, per cell:
//   M1 L1 distortion: actual ||cm_J - cm||_1, the theorem's bound
//      Σ_u 2 p_u / (|C_u| + p_u), and ratio bound/actual.
//   M2 conservation gap |total(cm_J) - total(cm)| against the exact
//      theory prediction: 0 (float epsilon) for all dense observers
//      (P, R, N1); EXACTLY the number of empty-cone components for
//      N2 (corollary mass_conserved_iff_dense: one unit minted per
//      inflated empty cone).
//   M3 head survival: top-40 overlap, blurred vs true field, ties
//      by name (study-11 convention).
//   M4 the instrument question: Spearman(relative bound, head
//      survival) pooled over all 16 cells, where relative bound =
//      bound / total true mass. Registered direction: NEGATIVE.
//      Ties (head survival is an integer 0-40 and will tie across
//      cells) handled by average ranks, the standard convention and
//      the one every prior study's spearman() implements.
//      Honest scope disclosed now: cells within a corpus share a
//      graph, so effective n is nearer 3 corpora than 16 cells;
//      per-corpus Spearmans reported alongside the pooled value.
//
// VALIDATION GATES (halt before reading results if violated):
//   V1 continuity, exact: C1 × P1 and C1 × P2 must reproduce
//      falsework-tightness.json bit-for-bit (same code path, same
//      data — equality, not a statistical gate; per the
//      phantom-predictor Phase 2 lesson that near-threshold
//      statistical gates on fresh corpora mistake sampling variation
//      for harness error, while exact reruns admit an equality
//      check).
//   V2 theory transcription: M2 must match its prediction in every
//      cell (dense gap < 1e-6; N2 gap = #empty-cone components to
//      float epsilon). A violation is an implementation bug or a
//      mis-transcribed corollary, not a finding.
//   V3 the inequality itself: bound >= actual (ratio >= 1.0) in
//      every cell. This is the kernel-checked theorem, so a
//      violation is a bug in the harness, never a finding; it is a
//      gate, not a guess.
//
// REGISTERED GUESSES (reported right or wrong, no kill attached):
//   G1 ratio bound/actual <= 1.5 in all 16 cells — cross-cone
//      cancellation stays near-absent beyond Debian and beyond
//      partition closures (study 11 measured 1.05x and 1.16x; the
//      registered 2-20x guess there was wrong favorably). The
//      >= 1.0 side is the theorem and lives in gate V3, not here.
//   G2 semantics beats chance at equal granularity: each natural
//      partition strictly beats its size-matched random null on head
//      survival in its corpus, all 5 pairs.
//   G3 N1 (truncation) is the cheapest observer per corpus — lowest
//      relative bound and highest head survival: cap-200 was chosen
//      because the ranking is insensitive to it (study 02), so the
//      cap-as-blur should cost near nothing.
//
// KILL CONDITION:
//   K12 — if the pooled M4 Spearman is positive, or |rho| < 0.3,
//      the comparative-instrument reading is DEAD: the bound does
//      not rank-order triage damage even across observers on the
//      same graph, and the v0.2 softening ("value is analytic, head
//      survival must be measured") is upgraded from caution to
//      measured fact, permanently. Threshold for the positive
//      claim: pooled rho <= -0.6 AND every per-corpus rho negative.
//      Between -0.6 and -0.3: reported as attenuated, no instrument
//      claim shipped.
//
// CONVERSE-PROBE LAYER (descriptive only, no claims, no thresholds):
//   per cell, record total blurred mass, the blurred field's top-40
//   values, and per-cone relative phantom count distribution
//   (median, p90, max) — raw material for the note's open converse
//   question (which load fields are achievable as cm_J), collected
//   while the machinery is warm. Anything found here gets no status
//   until registered on its own.
//
// Writes oracle-scanner/observer-cost.json.
//
// ============================================================
// POSTSCRIPT (after the run, 2026-09-24 — registration and run same
// day; header frozen at ca23907 strictly before the code below was
// written; runtime ~15s; raw output oracle-scanner/observer-cost.json)
//
// GATES: all three pass. V1 — the two study-11 anchor cells
// reproduce bit-for-bit (all eight compared values identical,
// including floats). V2 — conservation matched theory in all 16
// cells: every dense observer conserves to 1e-9 or better, and N2
// minted EXACTLY its predicted mass — 9,164 (debian), 22,960
// (crates), 1,106 (prove2me) units, one per inflated empty cone, to
// float epsilon. mass_conserved_iff_dense is now measured at scale
// on BOTH branches of the iff. V3 — bound >= actual everywhere.
//
// VERDICT (M4/K12): K12 DID NOT FIRE — THE INSTRUMENT CLAIM IS
// LICENSED at the registered threshold. Pooled Spearman(relative
// bound, head survival) = -0.908 over 16 cells; per-corpus -0.928
// (debian), -0.928 (crates), -0.800 (prove2me) — all negative,
// pooled well past -0.6. Given candidate coarse-grainings of the
// same graph, the falsework bound rank-orders which one destroys
// triage. Scope exactly as disclosed at registration: cells within
// a corpus share a graph, so effective n is nearer 3 corpora than
// 16 cells; this licenses comparative use, not a universal law.
//
// G1 WRONG (three cells above 1.5; worst 1.797): study 11's
// "nearly an identity in aggregate" does NOT generalize across
// observer types. Partition cells on debian/crates replicate the
// study-11 tightness (1.015-1.163); prove2me partitions run
// 1.46-1.47; the truncation observer runs 1.665 (crates) and 1.797
// (debian) — its phantom credit lands on deep base nodes that are
// simultaneously true members of many other cones, so the
// mixed-sign cancellation the triangle inequality permits is heavy
// exactly there; and N2 runs 1.297-1.558 partly for a structural
// reason: the per-cone equality is a NONEMPTY-cone statement (note
// v0.2, proof section), and an inflated empty cone costs 1 unit of
// L1 against a bound contribution of 2.
//
// G2 WRONG IN 4 OF 5 PAIRS — the study's most informative miss.
// Random size-matched partitions preserve the head BETTER than the
// natural partitions they were matched to: debian stems 29/40 vs
// random 38/40; crates stems 32/40 vs 40/40; crates prefixes 5/40
// vs 17/40; debian sections 0/40 vs 0/40 (a tie fails the strict
// guess); only the prove2me namespace partition beats its null
// (31/40 vs 11/40). Mechanism reading: natural semantic classes are
// exactly the sets dependency cones systematically touch (the
// python/gcc/lib families sit inside tens of thousands of cones),
// so at equal granularity a semantic blur buys MORE phantom count
// than a random one — debian stem bound 25,820 vs its null's 8,854,
// crates 21,084 vs 2,810. Prove2me inverts because namespaces are
// missions and its cones mostly stay inside one mission: there the
// natural blur aligns WITH cone boundaries (bound 2,139 vs the
// null's 5,124). In all five pairs the higher bound went with the
// lower head survival (the debian-section pair a near-tie in both)
// — the registered guess was wrong precisely where the instrument
// was right, which is the cleanest single piece of evidence the
// study produced.
//
// G3 RIGHT: N1 — the published cap itself, read as a blur — is the
// cheapest observer and preserves the head best in every corpus:
// debian 39/40 at 2.1% relative L1 distortion, crates 40/40,
// prove2me 40/40 with ratio exactly 1.000 (almost no cone on the
// proof graph exceeds cap 200). Study 02's cap-insensitivity
// finding now has a falsework-inequality reading: cap-200 is a
// near-perfect observer of the cap-800 field.
//
// CONVERSE-PROBE LAYER: recorded per cell in observer-cost.json
// (relative phantom count quantiles, blurred top-40 values, total
// blurred mass). Descriptive only, no claims, per registration.
// ============================================================

import { readFileSync, writeFileSync } from "node:fs";
import { buildSnap } from "../deflation-control/lib.mjs";
import { oracleMass } from "../battery-v3/lib.mjs";

const CAP = 200;      // published conemass configuration (true cones)
const CAP_N1 = 800;   // N1 truncation observer
const SEED = 12;      // R(P) partitions (frozen in header)
const H_SIZE = 16;    // N2 hub set (frozen in header)

// ---------- deterministic PRNG for R(P) ----------
function mulberry32(a) {
  return function () {
    a |= 0; a = (a + 0x6D2B79F5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

// average-rank Spearman (study-10 implementation, unchanged)
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

const quantiles = (arr) => {
  if (!arr.length) return { median: 0, p90: 0, max: 0 };
  const s = arr.slice().sort((a, b) => a - b);
  const at = (q) => s[Math.min(s.length - 1, Math.floor(q * s.length))];
  return { median: at(0.5), p90: at(0.9), max: s[s.length - 1] };
};

// head survival on {c, true, blurred} rows — study-11 convention verbatim
function headStats(rows, nameOf) {
  const sorted = (key) => rows.slice().sort((a, b) =>
    b[key] - a[key] || (nameOf(a.c) < nameOf(b.c) ? -1 : 1)).slice(0, 40);
  const tTrue = new Set(sorted("true").map((r) => r.c));
  const blurTop = sorted("blurred");
  const overlap = blurTop.filter((r) => tTrue.has(r.c)).length;
  return { overlap, blurredTop40Values: blurTop.map((r) => r.blurred) };
}

// ---------- partition cells: the study-11 code path, cloned verbatim
// (V1 demands bit-exact reproduction; converse-layer collection is
// kept out of the float accumulation order) ----------
function partitionStudy(snap, cm, label, cls) {
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
  const rels = [];
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
    if (!cone.length) continue; // dense: J(empty) = empty
    const touched = new Set();
    for (const x of cone) touched.add(compClass[x]);
    let jSize = 0;
    for (const k of touched) jSize += classSize.get(k);
    const credit = 1 / jSize;
    for (const k of touched) W.set(k, (W.get(k) ?? 0) + credit);
    bound += (2 * (jSize - cone.length)) / jSize;
    rels.push((jSize - cone.length) / jSize);
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
  const { overlap, blurredTop40Values } = headStats(rows, nameOf);
  return {
    observer: label, classes: classSize.size,
    l1Actual: l1, l1Bound: bound, ratio: bound / l1,
    totalTrue: totTrue, totalBlurred: totBlur,
    conservationGap: Math.abs(totBlur - totTrue),
    headOverlap40: overlap,
    conservationPrediction: 0,
    relPhantom: quantiles(rels), blurredTop40Values,
  };
}

// ---------- N1 truncation observer: JC_u = cap-800 cone ----------
function n1Study(snap, cm, label) {
  const { nComp, compMembers, cIn, names } = snap;
  const blur = new Float64Array(nComp);
  let bound = 0;
  const rels = [];
  const seen = new Int32Array(nComp).fill(-1);
  for (let u = 0; u < nComp; u++) {
    const cone = [];
    seen[u] = u;
    const q = [u];
    let head = 0;
    while (head < q.length && cone.length < CAP_N1) {
      const v = q[head++];
      for (const w of cIn[v]) {
        if (seen[w] === u) continue;
        seen[w] = u;
        cone.push(w);
        if (cone.length >= CAP_N1) break;
        q.push(w);
      }
    }
    if (!cone.length) continue; // empty at 800 iff empty at 200: dense
    // prefix property: the cap-200 cone is the first min(len, 200) entries
    const len200 = Math.min(cone.length, CAP);
    const p = cone.length - len200;
    bound += (2 * p) / cone.length;
    rels.push(p / cone.length);
    const credit = 1 / cone.length;
    for (const x of cone) blur[x] += credit;
  }

  let l1 = 0, totTrue = 0, totBlur = 0;
  const rows = [];
  for (let c = 0; c < nComp; c++) {
    l1 += Math.abs(blur[c] - cm[c]);
    totTrue += cm[c];
    totBlur += blur[c];
    rows.push({ c, true: cm[c], blurred: blur[c] });
  }
  const nameOf = (c) => names[compMembers[c][0]];
  const { overlap, blurredTop40Values } = headStats(rows, nameOf);
  return {
    observer: label, classes: null,
    l1Actual: l1, l1Bound: bound, ratio: bound / l1,
    totalTrue: totTrue, totalBlurred: totBlur,
    conservationGap: Math.abs(totBlur - totTrue),
    headOverlap40: overlap,
    conservationPrediction: 0,
    relPhantom: quantiles(rels), blurredTop40Values,
  };
}

// ---------- N2 base-set adjunction: JC_u = C_u ∪ H (non-dense) ----------
function n2Study(snap, cm, label, H) {
  const { nComp, compMembers, cIn, names } = snap;
  const blur = new Float64Array(nComp);
  let bound = 0, emptyCount = 0;
  const rels = [];
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
    if (!cone.length) emptyCount++;
    // h ∈ cone iff seen[h] === u && h !== u (BFS stamps u itself, cone excludes it)
    let extra = 0;
    for (const h of H) if (!(seen[h] === u && h !== u)) extra++;
    const jSize = cone.length + extra;
    const p = extra;
    bound += (2 * p) / jSize;
    rels.push(p / jSize);
    const credit = 1 / jSize;
    for (const x of cone) blur[x] += credit;
    for (const h of H) if (!(seen[h] === u && h !== u)) blur[h] += credit;
  }

  let l1 = 0, totTrue = 0, totBlur = 0;
  const rows = [];
  for (let c = 0; c < nComp; c++) {
    l1 += Math.abs(blur[c] - cm[c]);
    totTrue += cm[c];
    totBlur += blur[c];
    rows.push({ c, true: cm[c], blurred: blur[c] });
  }
  const nameOf = (c) => names[compMembers[c][0]];
  const { overlap, blurredTop40Values } = headStats(rows, nameOf);
  return {
    observer: label, classes: null,
    l1Actual: l1, l1Bound: bound, ratio: bound / l1,
    totalTrue: totTrue, totalBlurred: totBlur,
    conservationGap: Math.abs(totBlur - totTrue),
    headOverlap40: overlap,
    conservationPrediction: emptyCount, // corollary: one unit minted per inflated empty cone
    relPhantom: quantiles(rels), blurredTop40Values,
  };
}

// ---------- observers: shared constructions ----------
function randomPartitionCls(snap, natCls, seed) {
  const { nComp } = snap;
  const sizeMap = new Map();
  for (let c = 0; c < nComp; c++) {
    const k = natCls(c);
    sizeMap.set(k, (sizeMap.get(k) ?? 0) + 1);
  }
  // deterministic class order: size desc, then class label asc
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

function topHubs(snap) {
  const nameOf = (c) => snap.names[snap.compMembers[c][0]];
  return Array.from({ length: snap.nComp }, (_, c) => c)
    .sort((a, b) => snap.cOut[b].length - snap.cOut[a].length || (nameOf(a) < nameOf(b) ? -1 : 1))
    .slice(0, H_SIZE);
}

// ---------- corpora ----------
const debianRaw = JSON.parse(readFileSync("debian-study/history/2023.json", "utf8"));
const debianSections = JSON.parse(readFileSync("debian-study/history/sections-2023.json", "utf8"));
const cratesRaw = JSON.parse(readFileSync("software-study/history/crates-2022.json", "utf8"));
const p2mNames = [], p2mEdges = [];
{
  const lines = readFileSync("C:/dev/conemass/examples/prove2me/out/edges-union.csv", "utf8").trim().split("\n").slice(1);
  const idx = new Map();
  const id = (nm) => {
    let i = idx.get(nm);
    if (i === undefined) { i = p2mNames.length; idx.set(nm, i); p2mNames.push(nm); }
    return i;
  };
  for (const l of lines) {
    const c = l.indexOf(",");
    p2mEdges.push([id(l.slice(0, c)), id(l.slice(c + 1))]);
  }
}

// stems and partitions (frozen definitions)
const debianStem = (nm) =>
  nm.toLowerCase().replace(/t64$/, "").replace(/[0-9.]+/g, "").replace(/-+/g, "-").replace(/-$/, "");
const cratesStem = (nm) =>
  nm.toLowerCase().replace(/[0-9.]+/g, "").replace(/[-_]+/g, "-").replace(/-+$/, "");
const cratesPrefix = (nm) => {
  const m = nm.search(/[-_]/);
  return m === -1 ? nm : nm.slice(0, m);
};
const p2mNamespace = (nm) => {
  const d = nm.indexOf(".");
  return d === -1 ? nm : nm.slice(0, d);
};

function corpusPlan() {
  const dSnap = buildSnap(debianRaw.nodes, debianRaw.edges);
  const dName = (c) => dSnap.names[dSnap.compMembers[c][0]];
  const dP1 = (c) => debianStem(dName(c));
  const dP2 = (c) => debianSections[dName(c)] ?? `~solo:${dName(c)}`;

  const cSnap = buildSnap(cratesRaw.nodes, cratesRaw.edges);
  const cName = (c) => cSnap.names[cSnap.compMembers[c][0]];
  const cP1 = (c) => cratesStem(cName(c));
  const cP2 = (c) => cratesPrefix(cName(c));

  const pSnap = buildSnap(p2mNames, p2mEdges);
  const pName = (c) => pSnap.names[pSnap.compMembers[c][0]];
  const pP2 = (c) => p2mNamespace(pName(c));

  return [
    {
      corpus: "debian-2023", snap: dSnap,
      observers: [
        { key: "P1", kind: "partition", label: "P1 name-stem partition", cls: dP1 },
        { key: "P2", kind: "partition", label: "P2 section partition", cls: dP2 },
        { key: "R(P1)", kind: "partition", label: "R(P1) random size-matched to stem", cls: randomPartitionCls(dSnap, dP1, SEED) },
        { key: "R(P2)", kind: "partition", label: "R(P2) random size-matched to section", cls: randomPartitionCls(dSnap, dP2, SEED) },
        { key: "N1", kind: "n1", label: "N1 truncation observer (cap 800)" },
        { key: "N2", kind: "n2", label: "N2 base-set adjunction (top-16 hubs)" },
      ],
    },
    {
      corpus: "crates-2022", snap: cSnap,
      observers: [
        { key: "P1", kind: "partition", label: "P1 name-stem partition", cls: cP1 },
        { key: "P2", kind: "partition", label: "P2 project-prefix partition", cls: cP2 },
        { key: "R(P1)", kind: "partition", label: "R(P1) random size-matched to stem", cls: randomPartitionCls(cSnap, cP1, SEED) },
        { key: "R(P2)", kind: "partition", label: "R(P2) random size-matched to prefix", cls: randomPartitionCls(cSnap, cP2, SEED) },
        { key: "N1", kind: "n1", label: "N1 truncation observer (cap 800)" },
        { key: "N2", kind: "n2", label: "N2 base-set adjunction (top-16 hubs)" },
      ],
    },
    {
      corpus: "prove2me", snap: pSnap,
      observers: [
        { key: "P2", kind: "partition", label: "P2 namespace partition", cls: pP2 },
        { key: "R(P2)", kind: "partition", label: "R(P2) random size-matched to namespace", cls: randomPartitionCls(pSnap, pP2, SEED) },
        { key: "N1", kind: "n1", label: "N1 truncation observer (cap 800)" },
        { key: "N2", kind: "n2", label: "N2 base-set adjunction (top-16 hubs)" },
      ],
    },
  ];
}

// ---------- run ----------
const cells = [];
for (const { corpus, snap, observers } of corpusPlan()) {
  const cm = oracleMass(snap, CAP);
  const hubs = observers.some((o) => o.kind === "n2") ? topHubs(snap) : null;
  for (const ob of observers) {
    const res =
      ob.kind === "partition" ? partitionStudy(snap, cm, ob.label, ob.cls) :
      ob.kind === "n1" ? n1Study(snap, cm, ob.label) :
      n2Study(snap, cm, ob.label, hubs);
    const cell = { corpus, key: ob.key, nComp: snap.nComp, ...res };
    cells.push(cell);
    console.log(
      `${corpus} ${ob.key.padEnd(6)} L1 ${res.l1Actual.toFixed(2)}  bound ${res.l1Bound.toFixed(2)}  ` +
      `ratio ${res.ratio.toFixed(3)}  head ${res.headOverlap40}/40  gap ${res.conservationGap.toExponential(2)}` +
      (res.conservationPrediction ? ` (predicted ${res.conservationPrediction})` : ""));
  }
}

// ---------- gates (halt before reading results if violated) ----------
const gateFailures = [];

// V1: bit-exact reproduction of study 11
{
  const fix = JSON.parse(readFileSync("oracle-scanner/falsework-tightness.json", "utf8"));
  const pairs = [["P1", fix.o1], ["P2", fix.o2]];
  for (const [key, ref] of pairs) {
    const cell = cells.find((c) => c.corpus === "debian-2023" && c.key === key);
    const checks = [
      ["classes", cell.classes, ref.classes],
      ["l1Actual", cell.l1Actual, ref.l1Actual],
      ["l1Bound", cell.l1Bound, ref.l1Bound],
      ["ratio", cell.ratio, ref.ratio],
      ["totalTrue", cell.totalTrue, ref.totalTrue],
      ["totalBlurred", cell.totalBlurred, ref.totalBlurred],
      ["conservationGap", cell.conservationGap, ref.conservationGap],
      ["headOverlap40", cell.headOverlap40, ref.headOverlap40],
    ];
    for (const [f, got, want] of checks)
      if (got !== want) gateFailures.push(`V1 ${key}.${f}: got ${got}, study 11 has ${want}`);
  }
}

// V2: conservation against exact theory prediction
for (const c of cells) {
  const dev = Math.abs(c.conservationGap - c.conservationPrediction);
  if (dev >= 1e-6) gateFailures.push(
    `V2 ${c.corpus}/${c.key}: gap ${c.conservationGap} vs predicted ${c.conservationPrediction} (dev ${dev})`);
}

// V3: the kernel-checked inequality itself
for (const c of cells)
  if (!(c.ratio >= 1.0)) gateFailures.push(`V3 ${c.corpus}/${c.key}: ratio ${c.ratio} < 1`);

if (gateFailures.length) {
  console.error("\nVALIDATION GATE FAILURE — results not read, nothing written:");
  for (const f of gateFailures) console.error("  " + f);
  process.exit(1);
}
console.log("\ngates V1 (bit-exact continuity), V2 (conservation = theory), V3 (bound >= actual): all pass");

// ---------- M4 + guesses + kill ----------
const relBound = (c) => c.l1Bound / c.totalTrue;
const pooledRho = spearman(cells.map(relBound), cells.map((c) => c.headOverlap40));
const perCorpus = {};
for (const corpus of ["debian-2023", "crates-2022", "prove2me"]) {
  const cs = cells.filter((c) => c.corpus === corpus);
  perCorpus[corpus] = spearman(cs.map(relBound), cs.map((c) => c.headOverlap40));
}

const g1 = { pass: cells.every((c) => c.ratio <= 1.5), worst: Math.max(...cells.map((c) => c.ratio)) };
const g2Pairs = [
  ["debian-2023", "P1"], ["debian-2023", "P2"],
  ["crates-2022", "P1"], ["crates-2022", "P2"],
  ["prove2me", "P2"],
].map(([corpus, key]) => {
  const nat = cells.find((c) => c.corpus === corpus && c.key === key);
  const ran = cells.find((c) => c.corpus === corpus && c.key === `R(${key})`);
  return { corpus, key, natural: nat.headOverlap40, random: ran.headOverlap40, pass: nat.headOverlap40 > ran.headOverlap40 };
});
const g2 = { pass: g2Pairs.every((p) => p.pass), pairs: g2Pairs };
const g3ByCorpus = {};
for (const corpus of ["debian-2023", "crates-2022", "prove2me"]) {
  const cs = cells.filter((c) => c.corpus === corpus);
  const n1 = cs.find((c) => c.key === "N1");
  g3ByCorpus[corpus] = {
    cheapestBound: cs.every((c) => c.key === "N1" || relBound(n1) <= relBound(c)),
    highestHead: cs.every((c) => c.key === "N1" || n1.headOverlap40 >= c.headOverlap40),
  };
}
const g3 = { pass: Object.values(g3ByCorpus).every((v) => v.cheapestBound && v.highestHead), byCorpus: g3ByCorpus };

const allCorpusNegative = Object.values(perCorpus).every((r) => r < 0);
const verdict =
  pooledRho > 0 || Math.abs(pooledRho) < 0.3 ? "K12 FIRED — comparative-instrument reading dead; v0.2 softening is the permanent statement"
  : pooledRho <= -0.6 && allCorpusNegative ? "instrument claim licensed (pooled <= -0.6, all per-corpus negative)"
  : "attenuated — no instrument claim shipped";

console.log(`\nM4 pooled Spearman(relative bound, head survival) over ${cells.length} cells: ${pooledRho.toFixed(3)}`);
for (const [k, v] of Object.entries(perCorpus)) console.log(`  ${k}: ${v.toFixed(3)}`);
console.log(`G1 (ratio <= 1.5 everywhere): ${g1.pass ? "RIGHT" : "WRONG"} (worst ${g1.worst.toFixed(3)})`);
console.log(`G2 (natural beats random, all 5 pairs): ${g2.pass ? "RIGHT" : "WRONG"}`);
for (const p of g2Pairs) console.log(`  ${p.corpus} ${p.key}: natural ${p.natural}/40 vs random ${p.random}/40 ${p.pass ? "ok" : "FAIL"}`);
console.log(`G3 (N1 cheapest + highest head per corpus): ${g3.pass ? "RIGHT" : "WRONG"}`);
console.log(`\nVERDICT: ${verdict}`);

writeFileSync("oracle-scanner/observer-cost.json", JSON.stringify({
  registered: "ca23907", ranAt: new Date().toISOString(),
  cap: CAP, capN1: CAP_N1, seed: SEED, hSize: H_SIZE,
  cells: cells.map((c) => ({ ...c, blurredTop40Values: c.blurredTop40Values.map((v) => +v.toPrecision(10)) })),
  m4: { pooledRho, perCorpus },
  guesses: { g1, g2, g3 },
  verdict,
}, null, 1));
console.log("wrote oracle-scanner/observer-cost.json");
