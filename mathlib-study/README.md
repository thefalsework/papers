# The aperture instrument on Mathlib: an empirical study of formalized mathematics

**Date.** 2026-08-19, one session. **Corpus.** The Mathlib4 checkout pinned by this
repository's Lean toolchain (`lean/.lake/packages/mathlib`, rev `1fb6b28816`,
2026-05-19), namespaces `Order` (306 modules), `Topology` (658), `Algebra` (1317);
historical snapshots at five checkpoints back to 2023-09 via `git archive` from the
same clone.

**Status.** Working study, [computed] throughout. Every script carries its
pre-registration in the header, written before its first run, including the two
predictions that the data overruled (see 03 and 07). Results are logged in detail in
`wolfram/next-session.md` (status updates of 2026-08-19).

## The question

The program's aperture theorems (see `preprints/aperture/paper.md`) are proved on
finite Heyting algebras. A dependency graph of formalized mathematics supplies such
algebras with an uncontestable dictionary: modules ordered by (transitive,
namespace-internal) import, down-sets as elements, coarse-grainings as nuclei. The
study asks whether the four-position / aperture machinery, used as a measuring
instrument on this data, detects anything a simpler statistic does not.

## Setup (one step; no Lean install required)

The scripts read Mathlib *source text* from `lean/.lake/packages/mathlib`, which is
not tracked by this repository. Requirements: Node ≥ 18 (no npm packages) and git.
Fetch the pinned corpus with:

```bash
git clone https://github.com/leanprover-community/mathlib4 lean/.lake/packages/mathlib
git -C lean/.lake/packages/mathlib checkout 1fb6b28816d41e7b81bc0109124888c77ece34f9
```

This is the same revision the repository's `lean/lake-manifest.json` pins, so a
Lean user who has already run `lake build` in `lean/` needs nothing extra. The
clone also provides the git history that script 06 extracts snapshots from.

## The scripts, in narrative order

Run each from the repository root: `node mathlib-study/NN-name.mjs`.

1. **`01-ordinariness-gate.mjs`** — does any principal down-set pass the
   ordinariness gate? Result: yes, generically (0 dense / 20 regular / 286 ordinary
   in Order; 0/11/647 in Topology) — inverting the divisor-lattice picture, where
   ordinariness is rare. The discriminating layer in wide sparse posets is cell
   occupancy, not the gate: the node-empty-cell filter cuts 647 ordinary kernels to
   exactly 4, all in the `Topology.CWComplex.Classical` cluster (empty Distribution
   cell = a genuine import island, verified by hand).
2. **`02-subspace-nuclei.mjs`** — the structural key. Verifies from the axioms, two
   independent ways on 12 posets, that nuclei on Down(P) are exactly the 2^|P|
   subspace nuclei j_S (Fix(j_S) ≅ Down(S)); anchors the representation against the
   kernel-checked Div12/Div36 theorems (closed form reproduced on all 15 elements;
   the Div36 latent pair comes out as exactly the two proved keys); then hunts
   latency in the wild: on the 18-module cone of `Order.Antisymmetrization`,
   11/18 principal kernels are latent (all 262,144 worlds enumerated per kernel).
   Consequence for the mathematics: **Ap(a) = { S ⊆ P : a∩S ordinary in Down(S) }**
   on any finite distributive lattice — the paper's open generalization problem
   reduced to sub-poset combinatorics. (The classification behind this is
   classical, located 2026-08-19: Simmons, "Spaces with Boolean assemblies",
   Colloq. Math. 43 (1980), Thm 4.5 — N(ΩS) is Boolean iff S is scattered;
   poset form in Bezhanishvili–Bezhanishvili–Carai–Morandi et al., "The Frame
   of Nuclei of an Alexandroff Space", Order 37 (2020), arXiv:1906.03640 —
   N(O S) Boolean iff S noetherian, hence for finite P the assembly is the
   Boolean algebra 2^|P| and nuclei are exactly the subspace nuclei. Algebraic
   condition: Beazer–Macnab, Colloq. Math. 41 (1979). Grade of script 02's
   Part A is therefore [C]-verified-[computed]; the aperture reduction built
   on it appears to be new.)
3. **`03-null-degree-preserving.mjs`** — is the latency profile explained by cone
   geometry? Null: 60 degree-preserving double-edge-swap rewires of the real graph,
   identical pipeline. Pre-registered expectation was that the finding would
   dissolve. It did not: observed latent fraction above all 60 rewires; ordinary-at-
   identity, mean and max aperture fraction below all 60 (real apertures ≈ 18×
   narrower than degree-matched random).
4. **`04-replication.mjs`** — across namespaces: Order and Topology replicate the
   pre-registered criterion; Algebra does not (percentiles 93/5/7/3 — directionally
   consistent, misses the cutoffs). Post-hoc observation flagged as such: Algebra's
   cones are bimodal (consolidated narrow vs flat wide), and the namespace mean
   averaged two populations.
5. **`05-deflation-invariants.mjs`** — is the aperture a repackaged simple graph
   statistic? Four pre-registered invariants (foundation Jaccard, depth, minimal
   fraction, mean foundation fraction) across 315 real+null cones: best correlation
   |ρ| = 0.39; matched on the best invariant, 13/15 real cones remain below their
   matched-null median. Not deflated by these invariants.
6. **`06-history-flow.mjs`** — six checkpoints, 2023-09 → 2026-05. Library-level
   consolidation arrow: all six pre-registered trends in the predicted direction
   (latency up, apertures down; Order strongest at ρ = +0.94/−0.89). Cohort level:
   the strict monotone-narrowing prediction is falsified for young cones — the life
   cycle is born-thin → widen-under-construction → consolidate-narrow. Requires the
   snapshot extracts (regeneration commands below).
7. **`07-role-study.mjs`** — tests the post-hoc reading from 06 that flat cones are
   definitional *interfaces* rather than *young*. The role hypothesis fails its own
   pre-registered test (primary classifier has zero dynamic range; continuous
   correlation ρ ≈ 0.1; name-based `Defs` cones span both extremes), while the age
   effect is present in the same sample (old cones median aperture 0.081 vs young
   0.131). The role story is withdrawn; `Order.Monoid.Canonical.Defs` stays on the
   books as an individual anomaly.
8. **`08-history-nulls.mjs`** (2026-08-26) — closes the control gap 06 named: per-
   snapshot degree-preserving nulls (30 rewires per checkpoint × namespace, identical
   pipeline including the pick rule). **NP1: 6/6 — the consolidation arrow survives.**
   The sharper fact: 2023-09 observed values sit *inside* their null envelopes
   (percentiles 10–47 on latency), 2025-09/2026-05 sit at the extremes (100 on
   latency, 0–3 on aperture) in all three namespaces — early Mathlib was
   statistically indistinguishable from its degree-random twin; mature Mathlib is
   not. NP2 (continuity with 03/04's cross-sectional narrowness) holds.
9. **`09-cell-precheck.mjs` / `10-cell-composition.mjs`** (2026-08-26) — first test
   of the cell *dictionary* (do the four positions' names describe what falls in
   them?). v1 died by instrument saturation: the shared-prefix median has no dynamic
   range on this corpus (every cell median pinned at 2.00; permutation null
   degenerate). Uninformative, lesson recorded in the postscript: blindness
   discipline does not excuse skipping a resolution check.
10. **`11-cell-precheck2.mjs` / `12-cell-composition2.mjs`** (2026-08-26) — v2 with
    a resolution-checked measure (same-subarea fraction at k\* = 3, pooled).
    **C1′ HOLDS decisively: Exploitation-cell modules occupy the kernel's named
    territory** (99th–100th percentile vs 100 name-permutation nulls, all three
    namespaces) — the first corpus-level empirical support for a contentful cell
    reading. C2′ fails (Distribution is not at intermediate proximity; in
    Order/Topology the Refusal cell is name-closer, a flagged post-hoc observation:
    refusal happens on-territory). C0′ calibration violated in Topology and
    explained: transitive foundations dilute I's proximity with deep roots.
11. **`13-gloss-precheck.mjs` / `14-gloss-confirmation.mjs`** (2026-08-26) — 12's
    two loose ends taken to *thirteen held-out namespaces* (every remaining top-level
    dir ≥ 100 files). **G1 HOLDS: Exploitation-on-territory replicates out-of-sample
    13/13** (above the null's 95th percentile in 11, zero reversals) — with the
    original three, 16/16. **G2 (the post-hoc "refusal is proximate" reading) is
    REFUTED by significant reversal in 8/13**: Order/Topology were the outliers,
    not the rule. The reversal direction is the original dictionary ordering, which
    (being unpredicted) got its own registration:
12. **`15-smallns-precheck.mjs` / `16-rd-ordering.mjs`** (2026-08-26) — the original
    "Distribution nearer than Refusal" ordering, scored on the *last* five fresh
    namespaces (sub-100-file, ≥ 30 evaluable kernels). **G3 FAILS**: positive 2/5,
    significantly reversed in Logic and SetTheory — which pattern with Order and
    Topology. Verdict, final for this corpus (all 21 namespaces now used): the R/D
    geography is namespace-contingent; no spatial gloss of Refusal or Distribution
    survives in either direction. Post-hoc pattern, untestable here: the four
    R-proximate namespaces are Mathlib's foundational strata. Descriptive: sED
    positive at the 99th–100th percentile in 4/5, so Exploitation stands at 20/21
    overall with zero significant reversals.

## Headline findings

- **The four-position geometry exists in formalized mathematics and is generic;
  the informative layers are cell occupancy and the aperture.**
- **Real dependency cones are narrow-aperture**: structure around a module, where
  it exists at all, is visible only under few specific coarse-grainings — an effect
  not reproduced by degree-matched randomization nor explained by four simple graph
  invariants.
- **Latency exists in the wild**: most principal kernels in a real cone have no
  four-position structure at full resolution and acquire it only in proper
  sub-poset worlds.
- **Consolidation is measurable, directional, and now null-controlled** at the
  library level over three years (08: survives per-snapshot degree-preserving
  nulls 6/6; the young library sat inside its null envelope, the mature library
  sits at the extremes), with a non-monotone cohort life cycle.
- **The cell dictionary splits cleanly under out-of-sample confirmation**
  (12/14/16, all 21 namespaces used): "Exploitation is on-territory" is a corpus
  regularity — 16/16 registered, 20/21 including descriptive runs, zero
  significant reversals. The Refusal/Distribution *spatial* glosses are dead in
  both directions: the original ordering failed on Order/Topology/Algebra, its
  post-hoc correction was refuted 8/13 out-of-sample, and the original scored on
  the final five fresh namespaces failed 2/5. The R/D geography is
  namespace-contingent; outward documents drop spatial language for R and D.
- **One forward prediction stands**: the `Topology.CWComplex.Classical` cluster's
  empty Distribution cell fills (bridging modules appear) or the cluster is
  re-founded — testable against any future Mathlib revision by rerunning 01.

## Regenerating the historical snapshots (needed by 06 only)

```powershell
# from the repository root; does not touch the pinned working tree
$revs = @{"2023-09"="0469f845e132ccd0e56c40aafd34bd9084c104bb";
          "2024-03"="2a0739561acdae879ca34df7b2d67e9db18a5bab";
          "2024-09"="63cced2a6b7c4ed2afb8e6cdf7443d6dbcc975e0";
          "2025-03"="fb85dc4d9b1b2228454595ca243ef3314098035a";
          "2025-09"="7d990dccdd53e3a9c87661bef8be58be62409624"}
foreach ($k in $revs.Keys) {
  $dir = ".scratch_mathlib_hist/$k"
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  git -C lean\.lake\packages\mathlib archive $revs[$k] Mathlib/Order Mathlib/Topology Mathlib/Algebra -o "$env:TEMP\mlhist.tar"
  tar -xf "$env:TEMP\mlhist.tar" -C $dir
}
```

## Modeling choices (shared by all scripts, fixed 2026-08-19)

Namespace-internal import graphs only (paths leaving and re-entering through other
namespaces are invisible — a stated approximation); down(x) = x plus its transitive
imports; kernel candidates = principal down-sets; the import parser accepts both the
old `import X` and the module-system `public import X` syntax. Seeded PRNGs
throughout; seeds recorded in each script header.
