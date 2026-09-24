// Oracle scanner — OBSERVER COST SURVEY: the falsework inequality as
// an instrument, measured across an observer family on three corpora.
// REGISTRATION DRAFT — not yet committed; code to be written only
// after this header is committed. Nothing has been run.
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
// (postscript after the run)
// ============================================================

// Code to be written after this registration header is committed.
