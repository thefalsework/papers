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
// (postscript after the run)
// ============================================================

// Code to be written after this registration header is committed.
