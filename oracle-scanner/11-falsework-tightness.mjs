// Oracle scanner — FALSEWORK TIGHTNESS: measure the kernel-checked
// falsework inequality against reality on Debian bookworm.
// Registered before running.
//
// PROMPT. The falsework inequality (2026-09-23, kernel-checked in
// lean/FalseWorkPapers/Lattice/FalseworkInequality.lean) bounds an
// observer's L1 misperception of the conemass field by
// sum_u 2 p_u / (|C_u| + p_u), p_u the phantom mass on u's cone. The
// bound is an identity per cone; across cones it goes through a
// triangle inequality, where errors from different cones can cancel
// at a node. This study measures the slack on a real graph with two
// natural observers.
//
// OBSERVERS (both partition closures: J(S) = union of the partition
// classes S touches). Partition closures are inflationary and
// idempotent but NOT meet-preserving, so they are not nuclei; the
// falsework inequality applies to any inflationary blur by
// construction, and this is the first exercise of that generality.
// Partition closures are also DENSE (J(∅) = ∅), so by
// mass_conserved_iff_dense the blurred field must conserve total mass
// EXACTLY — asserted numerically below as a check of theory against
// implementation.
//   O1 (fine): name-stem partition — the study-08 succession stem
//      (strip digits/versions from package names). Blurs a package's
//      cone across version/ABI variants only.
//   O2 (coarse): section partition — debian-study sections-2023.json
//      (games, libs, python, ...). Blurs a cone to every package in
//      any section it touches.
//
// Cones: truncated (cap 200) dependency cones on the SCC
// condensation, exactly the cones conemass computes. Partition
// classes are assigned per component via its first member package
// (multi-member components are rare cycles; disclosed approximation).
//
// MEASUREMENTS, fixed in advance, per observer:
//   M1: actual L1 distortion ||cm_J - cm||_1 vs the theorem's bound;
//       report both and the ratio bound/actual.
//   M2: conservation check — |total(cm_J) - total(cm)| must be ~0
//       (float epsilon), because partition closures are dense.
//   M3: head survival — top-40 overlap between blurred and true
//       fields (blurred field is constant per class; ties broken by
//       name — descriptive only).
//
// REGISTERED GUESSES: the bound is loose in aggregate but same order
// of magnitude — ratio bound/actual between 2x and 20x on both
// observers (per-cone it is exact; cancellation across cones is the
// only slack). O1's absolute distortion is small (stems barely
// inflate cones), O2's is large (sections are huge classes). No kill
// conditions; this measures the theorem, not the metric.
//
// Writes oracle-scanner/falsework-tightness.json.
//
// ============================================================
// POSTSCRIPT (after the run, 2026-09-23)
//
// THE REGISTERED GUESS WAS WRONG IN THE FAVORABLE DIRECTION. Ratio
// bound/actual: O1 (stems) **1.05x**, O2 (sections) **1.16x** —
// against a guessed 2-20x. The falsework bound is nearly an identity
// in aggregate on a real 63,353-component graph, not just per cone:
// cross-cone cancellation, the only slack the triangle inequality
// admits, is almost absent in practice. (Mixed-sign nodes — true
// member of one cone, phantom of another — carry little total error.)
//
// M2 CONSERVATION: gap 1.5e-9 (O1) and 1.1e-9 (O2) — float epsilon.
// Partition closures are dense, and mass_conserved_iff_dense demands
// exact conservation; the implementation agrees with the kernel.
//
// M3 HEAD SURVIVAL, the operational reading: a stem-blind observer
// (60,304 classes) still sees 29/40 of the true conemass head; a
// section-level observer (58 classes) sees **0/40**. An observer
// that can only resolve sections cannot do criticality triage at
// all — and the falsework machinery says this BEFORE running any
// ranking: O2's per-cone relative phantom mass is visible in the
// bound (108,001 over total mass 54,189, i.e. distortion ~ the field
// itself), while O1's predicts survivable distortion.
//
// Absolute scale, honest note: even the fine observer distorts 45%
// of total mass in L1 (24,501 of 54,189) — cap-200 cones touch the
// few large stem classes (python/gcc/lib families) often enough that
// version-blindness is not free. Distortion concentrated in the bulk
// though: the head mostly survives (29/40).
//
// VERDICT: the theorem is usable as an instrument. Compute the bound
// (cheap, no blurred ranking needed) to predict whether a given
// coarse-graining destroys triage; the bound is within 5-16% of
// truth on both natural observers tested.
// ============================================================

import { readFileSync, writeFileSync } from "node:fs";
import { buildSnap } from "../deflation-control/lib.mjs";
import { oracleMass } from "../battery-v3/lib.mjs";

const CAP = 200;

const raw = JSON.parse(readFileSync("debian-study/history/2023.json", "utf8"));
const sections = JSON.parse(readFileSync("debian-study/history/sections-2023.json", "utf8"));
const snap = buildSnap(raw.nodes, raw.edges);
const { nComp, compMembers, cIn, names } = snap;

const stem = (nm) =>
  nm.toLowerCase().replace(/t64$/, "").replace(/[0-9.]+/g, "").replace(/-+/g, "-").replace(/-$/, "");

// class of a component under each partition (first member's class)
const classOf = {
  stem: (c) => stem(names[compMembers[c][0]]),
  section: (c) => sections[names[compMembers[c][0]]] ?? `~solo:${names[compMembers[c][0]]}`,
};

// true field per component
const cm = oracleMass(snap, CAP);

function study(label, cls) {
  // partition: class -> component count
  const classSize = new Map();
  const compClass = new Array(nComp);
  for (let c = 0; c < nComp; c++) {
    const k = cls(c);
    compClass[c] = k;
    classSize.set(k, (classSize.get(k) ?? 0) + 1);
  }

  // per cone: classes touched, |C|, |JC|; accumulate class credits and bound
  const W = new Map(); // class -> blurred credit
  let bound = 0;
  const seen = new Int32Array(nComp).fill(-1);
  for (let u = 0; u < nComp; u++) {
    // truncated cone BFS, same traversal as oracleMass
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
  }

  // blurred field, distortion, conservation
  let l1 = 0, totTrue = 0, totBlur = 0;
  const rows = [];
  for (let c = 0; c < nComp; c++) {
    const blurred = W.get(compClass[c]) ?? 0;
    l1 += Math.abs(blurred - cm[c]);
    totTrue += cm[c];
    totBlur += blurred;
    rows.push({ c, true: cm[c], blurred });
  }

  // head survival (descriptive; blurred ties broken by name)
  const nameOf = (c) => names[compMembers[c][0]];
  const top = (key) => new Set(
    rows.slice().sort((a, b) => b[key] - a[key] ||
      (nameOf(a.c) < nameOf(b.c) ? -1 : 1)).slice(0, 40).map((r) => r.c));
  const tTrue = top("true"), tBlur = top("blurred");
  const headOverlap = [...tTrue].filter((x) => tBlur.has(x)).length;

  const res = {
    observer: label, classes: classSize.size,
    l1Actual: l1, l1Bound: bound, ratio: bound / l1,
    totalTrue: totTrue, totalBlurred: totBlur,
    conservationGap: Math.abs(totBlur - totTrue),
    headOverlap40: headOverlap,
  };
  console.log(`\n=== ${label} ===`);
  console.log(`classes: ${res.classes} over ${nComp} components`);
  console.log(`L1 distortion: actual ${l1.toFixed(2)}, bound ${bound.toFixed(2)}, ratio ${res.ratio.toFixed(2)}x`);
  console.log(`conservation: true ${totTrue.toFixed(6)}, blurred ${totBlur.toFixed(6)}, gap ${res.conservationGap.toExponential(2)}`);
  console.log(`top-40 head overlap blurred vs true: ${headOverlap}/40`);
  return res;
}

const out = {
  corpus: "debian bookworm 2023", nComp, cap: CAP,
  o1: study("O1 name-stem partition closure", classOf.stem),
  o2: study("O2 section partition closure", classOf.section),
};
writeFileSync("oracle-scanner/falsework-tightness.json", JSON.stringify(out, null, 1));
console.log("\nwrote oracle-scanner/falsework-tightness.json");
