# Next session: write the aperture closed form into the paper (2026-08-12)

## State at end of 2026-08-11

The evening ended one step past where the draft currently sits. The paper
(`preprints/aperture/paper.md`) still presents the two-prime product law as
its §5 conjecture. That is now superseded: we have a **closed form for the
aperture of every element of every divisor lattice**, verified with zero
mismatches on all 164 elements of 15 lattices (`aperture-closed-form.mjs`),
including all 109 zero-aperture elements and every mixed kernel — and every
step of its derivation is elementary and provable.

**The formula.** For k in Div(n), n = ∏ p_c^{a_c}, with e_c the exponent
of p_c in k:

    |Ap(k)| = ∏ 2^{a_c}  −  ∏ D_c  −  ∏ R_c  +  ∏ DR_c

    D_c  = (2^{e_c} − 1)·2^{a_c − e_c} + 1    (chain worlds where j(e) is dense)
    R_c  = 2^{a_c − e_c} + 2^{e_c} − 1        (… regular)
    DR_c = 2^{e_c}                            (… both)

**The derivation (all three steps elementary — do not lose this):**

1. *Factorization lemma.* Nuclei on a finite product H = A × B factor
   componentwise. Proof: for any nucleus j, (a,b) = (a,⊤) ∧ (⊤,b); by
   meet-preservation j(a,b) = j(a,⊤) ∧ j(⊤,b); inflation forces
   j(a,⊤) = (j_A a, ⊤) and j(⊤,b) = (⊤, j_B b); so j = j_A × j_B, and
   j_A(a) := π_A j(a,⊤) inherits all three nucleus laws. (Conversely every
   product of nuclei is a nucleus.) This was believed an open lemma until
   the four-line proof surfaced; it is NOT open.
2. *Coordinate-locality.* Negation in a product (and in Fix(j) = ∏ Fix(j_c))
   is componentwise, so j(k) is dense in Fix(j) iff dense in every
   coordinate world, regular iff regular in every coordinate.
3. *Chain counts.* On the chain C_{a+1}, nuclei = subsets F ∋ ⊤ of the a
   non-top elements (2^a of them), j(e) = least member ≥ e. Dense ⟺
   min F < e or F = {⊤}; regular ⟺ j(e) ∈ {min F, ⊤}; both ⟺ j(e) = ⊤.
   Counting gives D, R, DR above. Ordinary = not dense and not regular,
   so inclusion-exclusion yields the formula.

**Corollaries (verified numerically, worth stating in the paper):** the
two-prime law (2^i−1)(2^{a−i}−1)(2^b−1) [algebra checks], the original
Div(2^a·3) product law, the latency characterization (all exponents
interior — CORRECTED 2026-08-24: valid only at exactly two primes; see
paper Result 6.3 and `latency-characterization-correction.mjs`), and the
latent aperture sizes previously reported as
"unfitted data" — the refusal to curve-fit was correct, and the derived
form then explained them.

**How we got here (for design-notes):** the cloud run's unregistered Div72
ambient apertures (9, 7, 9) suggested a third factor (2^b − 1); reviewer
pushback (correct) said the Div60 fit of the rival N(complement)−1 form
was a degenerate-point coincidence and demanded Div120/Div180 as the
discriminating test; the test favored N(complement)−1 on 4/4 points
(9,9,7,7 vs chain-form's 3,3,3,3); asking WHY the −1 (reviewer: "if
there's no story it's a fudge") produced the derivation, which subsumed
both candidate forms.

## Status update, 2026-08-12 (end of session)

Items 1, 3, 4, 5 below are done; item 2's cloud rerun is the one
remaining manual step.

- **Paper** rewritten: §5 closed form as theorem with derivation,
  Result 4.1 and Result 6.1 upgraded to [K], §8 table and §9 updated.
- **Lean** (`Lattice/NucleusFactorization.lean`,
  `Examples/ApertureAnchors.lean`): the factorization lemma is [K] in
  full generality (`nucleus_prod_iff`); Ap(2) = {identity} on Div12
  over all nuclei (`aperture_two_complete`) and Ap(6) = exactly
  {jLeft, jRight} on Div36 (`latent_ordinariness_witness`,
  `aperture_six_complete`) are [K]. Method: the brute-force decide
  over 6⁶ self-maps crashed the kernel; the factorization lemma
  collapses the search to componentwise pairs (108 for Div12 via the
  exponent iso C₃ × C₂ + transport lemmas, 729 for Div36), after
  which decide is instant. Axiom audit clean — no native_decide, no
  sorry. Full `lake build` green. Episode recorded in design-notes
  part 5.
- **Still open on the Lean track:** Steps 2–3 of Theorem 5.1
  (coordinate-locality of density/regularity in product worlds;
  the chain counts) — that is what makes the closed form itself [K].

## Status update, 2026-08-14

- **Lean track closed for the two-prime case.** Steps 2–3 of
  Theorem 5.1 are [K] in `Lattice/ApertureClosedForm.lean`:
  WorldDense/WorldRegular defined (Opens = neither, definitionally);
  coordinate-locality on products; nucleus factorization upgraded to
  a type equivalence; chain nuclei classified as top-sets
  (`nucleusEquivTopSets`); the four chain counts proved as powerset
  cardinalities on arbitrary finite bounded chains (D and R stated
  additively to avoid ℕ-subtraction); inclusion-exclusion assembly
  (`aperture_card_add_eq`) proved for any product of two finite
  Heyting algebras; `aperture_closed_form_two_chains` (abstract, over
  ℤ) and `aperture_closed_form_exponents` (Fin exponent lattices —
  Theorem 5.1 verbatim, two-prime case) proved; Div12 cross-check
  example `decide`s to 1, agreeing with `aperture_two_complete`.
  Axiom audit: propext, Classical.choice, Quot.sound only — no
  sorry, no native_decide. Paper §5/§6/§8/§9 and abstract updated:
  closed form now [K] on two-prime lattices, [computed] for r > 2.
- **Remaining Lean gap:** the r > 2 iteration of the binary
  assembly (fold `aperture_card_add_eq` across an r-fold product).
  Bookkeeping, not mathematics. (CLOSED 2026-08-24 — and not by
  folding: see the 2026-08-24 status update.)

## Status update, 2026-08-15

- **Literature placement added to paper §5 + §8.** The chain-nucleus
  classification (Step 3, structural half) is folklore in print:
  Erné, "Nuclear ranges in implicative semilattices" (Algebra
  Universalis 2022) states it for bounded chains; Bezhanishvili ×2,
  Carai, Gabelaia, Ghilardi, Jibladze (arXiv:2001.11060) classify
  nuclei on finite implicative semilattices via meet-prime subsets.
  Ordinary elements remain active vocabulary in intermediate logics
  (Citkin, "An Algebraic Proof of the Nishimura Theorem," Logics
  2024). No trace found of: ordinariness relativized to nucleus
  worlds, the aperture, latency, or the count. Novelty claims now
  explicitly located there; search-not-review caveat marked [O].
- **Due diligence before arXiv:** follow citation trails of the two
  papers above; search "nucleus" + dense/regular element variants;
  consider writing to Citkin directly.
- **Wolfram track: closed.** `aperture-scaling.wl` rerun in Wolfram
  Cloud 2026-08-12: enumerations match the pre-registered table,
  product law 15/15, latency 8/8 CONFIRMED, closed form EXACT on
  all 79 elements (56 zero-aperture cancellations included).
  Recorded in the README scaling section and closed-form bullet.

## Status update, 2026-08-16

- **New preprint drafted: `preprints/hearing/paper.md`** ("Hearing at
  a Blur") — the cognitive hypothesis paper. States Hypothesis H:
  settled auditory attention (metrical entrainment) acts on Div(n) as
  a nucleus, decomposed into three independently falsifiable axioms
  (H1 inflation / H2 idempotence / H3 meet-preservation as perceptual
  laws). Introduces grade **[H]** (falsifiable empirical hypothesis,
  untested) alongside the existing five. Transfers, conditional on H:
  finite hearing spaces (8 for Div12, 16 for Div36), fragility
  (Result 4.1), and latency as the strong prediction — organization
  in-principle closed to full attention, open to exactly two
  computable hearings. Locates H against Lerdahl–Jackendoff (1983),
  Jones–Large (1999), London (2004), Bregman (1990): components all
  known, the algebraic package unasked. §6 gives a pre-registrable
  latency-detection design (36-pulse material, entrainment-primed
  conditions, square-free 30-pulse structural control, predictions
  P1–P5) with failure semantics mapped to axioms. Stimulus
  construction (realizing the level-6 four-fold acoustically) flagged
  [O] as the hard step. Bach (hemiola, BWV 645, augmentation) used as
  illustration, graded [A], explicitly not evidence.
- **Companion tooling:** interactive worksheet canvas (Div12/Div36
  hearings, verdicts, closed-form panel) with click-layer
  sonification — one layer per registered grid, coarse low/loud,
  fine high/soft; doubles as the stimulus-generation spec for §6.
  Verified against the Lean anchors before embedding
  (`.scratch_worksheet_check.mjs`, brute-force nuclei from axioms +
  per-chain verdict cross-check, zero mismatches).

## Status update, 2026-08-18: arXiv declines Paper 2 v2; routing changed

arXiv moderation declined Paper 2's v2 submission (submit/7711078)
and gated the account (journal DOI required for future submissions;
reconsidered once a publication record exists). Full event note and
routing decision logged in `papers/INDEX.md` (Paper 2 entry +
next-revisions list). Consequences for this track: the **Algebra
Universalis extraction of the aperture paper** is promoted from
due-diligence item to the priority artifact — it is both the
strongest material and the account-rehabilitation path (theorem-proof
register, no framework vocabulary, Lean as supplementary material;
Erné's venue = right referees). The Citkin letter (already queued
2026-08-15) now also serves the submission. Zenodo deposit of the
current aperture preprint for a DOI'd timestamp is cheap and should
happen before the journal cycle starts.

## Status update, 2026-08-19: the ordinariness gate runs on Mathlib itself

First run of the four-position instrument on formalized mathematics
(`.scratch_mathlib_gate.mjs`, untracked scratch; Mathlib pinned at
1fb6b28816). Modeling choices pre-registered in the script header:
namespace-internal import graph, down(x) = x's transitive imports,
kernels = principal down-sets, pseudocomplement/double-negation in the
down-set algebra.

- **The geometry exists, and it is generic, not exceptional.**
  Mathlib.Order: 306 modules, 0 dense / 20 regular / 286 ordinary
  kernels. Mathlib.Topology: 658 modules, 0 dense / 11 regular / 647
  ordinary. This *inverts* the divisor-lattice picture (109/164 empty
  apertures): in wide sparse import posets ordinariness is the rule.
  Honest reading: the gate alone is not the discriminating instrument
  here; the cell-occupancy profile is.
- **The node-empty-cell filter is sharp: 647 → 4.** In Topology,
  exactly four ordinary kernels have a node-empty cell, and they are
  one cluster: `Mathlib.Topology.CWComplex.Classical.*`, each with
  Distribution = 0. Verified by hand: `CWComplex/Classical/Basic.lean`
  imports *nothing* from Mathlib.Topology (enters via Analysis) — a
  genuine island the instrument found mechanically. Nothing in the
  namespace both builds on CW complexes and touches the rest of
  Topology.
- **Pre-registrable prediction (first forward prediction from the
  instrument):** as Mathlib grows, the CWComplex cluster's
  Distribution cell fills (bridging modules to Homotopy etc.) or the
  cluster is re-founded on Topology-internal imports. Testable
  against any future Mathlib revision by rerunning the script.
- **Regular kernels = the classical shadow, as predicted:** the 20/11
  gate-failures are leaf or near-isolated modules (|foundation| ≤ 3)
  whose cone closure adds nothing — the Boolean-pocket picture
  holding in the wild.
- Caveats logged: namespace-internal restriction (paths leaving and
  re-entering via other namespaces are invisible; the island reading
  is relative to that choice); principal-kernel scope; single
  revision, no baseline yet. Next steps if pursued: full-Mathlib
  graph (declaration-level or module-level), aperture computation
  (needs nuclei on general down-set algebras — the r > 2 / general
  distributive lattice open problem, so this doubles as
  reconnaissance for it), and a historical-revision backtest of the
  gap prediction.

## Status update, 2026-08-19 (later): subspace nuclei crack the general case; latency found in the wild

Follow-up to the morning's gate run (`.scratch_subspace_nuclei.mjs`,
untracked scratch; pre-registered header). Three results, in
ascending order of importance:

- **The subspace-nucleus correspondence [computed, likely (C)].** For
  finite P, nuclei on Down(P) are exactly the subspace nuclei
  j_S(A) = {p : ↓p ∩ S ⊆ A}, one per S ⊆ P, so #nuclei = 2^|P| and
  Fix(j_S) ≅ Down(S). Verified from the axioms two independent ways
  (fix-set enumeration on 12 posets: chains, antichains, V, Λ,
  diamond, fence, unions, 5-pt mixed; raw enumeration of all
  inflationary maps on the small ones). This should be classical —
  finite frames have only spatial sublocales — so the grade target is
  [C] with citation (Johnstone / Picado–Pultr; find the exact
  statement before using it in print). Consequence, and it is large:
  **the aperture problem on ANY finite distributive lattice reduces
  to combinatorics on sub-posets**:
      Ap(a) = { S ⊆ P : a ∩ S ordinary in Down(S) }.
  The general closed form (the paper's named open problem) is now
  "count the S with a∩S ordinary" — Theorem 5.1's chain counts are
  the disjoint-union-of-chains special case.
- **Third-way anchor check.** Down(chain2⊔chain1) ≅ Div12,
  Down(chain2⊔chain2) ≅ Div36; aperture sizes computed by subset
  enumeration match the closed form on all 15 elements, Ap(2) =
  {identity} on Div12, and the Div36 latent pair comes out as
  S = {p1,p2,q2} and {p2,q1,q2} — exactly the even-grid and
  threes-grid hearings of the kernel-checked anchors. The closed form
  has now survived a representation it was not derived in.
- **Latency exists in formalized mathematics [computed].** Sub-poset:
  the 18-module foundation cone of Mathlib.Order.Antisymmetrization
  (pre-registered pick: largest foundation ≤ 18; Mathlib pinned
  1fb6b28816). All 2^18 = 262,144 worlds enumerated per kernel.
  11/18 principal kernels are LATENT: dense at identity (inside one
  cone every foundation shares the base, so ¬a = ∅ at full
  resolution) but ordinary in thousands of proper worlds (aperture
  fractions 0.1%–3%). Reading: within a dependency cone, four-position
  structure around a module exists only for observers who do NOT
  register the common foundations. One kernel is ordinary at identity:
  Defs.PartialOrder, with |Ap| = 32768 = 2^15 exactly — a suspiciously
  clean count (2^(|P|−3)) that smells like the first data point of the
  general counting theorem.

**Null model result (same day, `.scratch_latency_null.mjs`): the
latency finding SURVIVES, against the pre-registered expectation.**
Null = 60 degree-preserving double-edge-swap rewires of the real
Mathlib.Order DAG (forward edges wrt a fixed topological order, so
in/out-degree sequences exact), same pre-registered cone pick, same
analysis, seeded PRNG (20260819). The pre-registered expectation was
that latency is generic cone geometry and Mathlib would sit in the
null's central mass. Wrong, on every metric:

    latentFrac   null 5/50/95% = .167/.278/.556   observed .611  (above all 60)
    ordIdFrac    null 5/50/95% = .389/.556/.722   observed .056  (below all 60)
    meanApFrac   null 5/50/95% = .186/.292/.449   observed .016  (below all 60)
    maxApFrac    null 5/50/95% = .508/.702/.842   observed .125  (below all 60)

Reading: degree-matched random cones have COMMON full-resolution
ordinariness and WIDE apertures (structure robust, visible to many
observers). The real Mathlib cone is the opposite: full-resolution
structure is rare (foundations heavily shared, density generic),
latency is elevated, and apertures are ~18x narrower than random —
structure exists, but only for few, specific coarse-grainings. The
degree sequence does not explain this; real formalization practice
is doing something (consolidation through shared foundational
modules) that the aperture instrument detects. Caveats: one cone,
one namespace, 60 replicates (one-sided p ≈ 1/61 per metric,
metrics correlated); replicate across namespaces and cones before
this becomes a claim with a grade. The wrong pre-registered
expectation is part of the record — the instrument outran the
operator, which is what instruments are for.

**Replication study (same day, `.scratch_latency_replication.mjs`):
2 of 3 namespaces replicate; Algebra does not.** Pre-registered
design: namespaces Order/Topology/Algebra, top-5 cones (foundation
≤ 18) per graph, 30 degree-preserving rewires per namespace,
criterion = latentFrac ≥ null-95 AND meanApFrac ≤ null-5 on the
5-cone mean. Results, reported without reinterpretation:
  - Order: REPLICATES (latentFrac .611 above all rewires; other
    three metrics at 0th percentile). Caveat found in passing: the
    top-5 Order cones share nearly all content (overlapping
    foundations), so this is closer to one confirmation than five.
  - Topology: REPLICATES (latentFrac .756 at 100th pct, ordIdFrac
    .000 at 0th, meanApFrac at 3.3rd).
  - Algebra: does NOT replicate. Directionally consistent
    (percentiles 93.3 / 5.0 / 6.7 / 3.3 — all near the tails) but
    misses both cutoffs. Post-hoc observation (flagged as such): the
    five Algebra cones split into two regimes — three
    narrow-aperture consolidated cones like Order/Topology, and two
    cones (Homology.SpectralObject.HasSpectralSequence,
    Order.Monoid.Canonical.Defs) with latent = 0, ordId ≈ .85, wide
    apertures — i.e. cones that look like the RANDOM regime. The
    within-namespace heterogeneity is real signal for a follow-up
    with cone-level (not namespace-mean) statistics and
    non-overlapping cone selection.
Status of the claim: "real Mathlib dependency cones are
narrow-aperture vs degree-matched null" holds in Order and Topology,
is directionally supported but not established in Algebra, and the
next design must fix the two flaws this run exposed (overlapping
cones; namespace-mean masking a bimodal cone population).

**Deflation test 1 (same day, `.scratch_deflation_invariants.mjs`):
NOT deflated.** Threat tested: the narrow-aperture finding might be a
repackaged simple graph statistic. Four pre-registered invariants per
cone (mean pairwise foundation Jaccard J, normalized depth D, minimal
fraction M, mean foundation fraction F), 315 cones pooled (15 real +
300 from 20 rewires × 3 namespaces, seed 20260820). Results: all
Spearman correlations with aperture metrics weak (best |rho| = 0.389,
F vs meanApFrac; J — the honest-expectation favorite — essentially
zero). Matched comparison on F: 13/15 real cones below their
invariant-matched null median (criterion was ≥ 2/3). The two
exceptions are exactly the two flat Algebra cones already identified
(SpectralObject, Monoid.Canonical) — consistent with the two-regime
picture, not a new anomaly. Deduped for overlapping cones (Order and
Topology top-5s largely coincide): ~7/9 distinct cones below, still
passing. Caveat: this rules out these four invariants, not all
conceivable ones; a smarter statistic could still deflate, and we
should keep inviting candidates. Bridge status: correspondence 4
(aperture as static irreducibility signature, not reducible to depth
or overlap) survives its first serious challenge. Remaining deflation
tests, in order of danger: git-history flow (does flat material
consolidate? kills the developmental story if not), and the
generalized bimodality check (cone-level stats, non-overlapping
cones, more namespaces).

**Git-history flow test (same day, `.scratch_history_flow.mjs`;
snapshots in `.scratch_mathlib_hist/`, git-archive extracts at
2023-09/2024-03/2024-09/2025-03/2025-09 + HEAD pin):** verdict mixed
in an informative way — P1 pass, P2 split, P3 2/3 with a named
counterexample.

- **P1 (library flow): PASS.** All six pre-registered trends point
  the predicted way: latentFrac rises / meanApFrac falls over the
  six checkpoints in every namespace (Order +0.94/−0.89 Spearman,
  Topology +0.60/−0.43, Algebra +0.43/−0.31). The frontier-cone
  aperture profile of the library consolidates over three years.
  Caveat: n = 6 checkpoints, no significance claim; Order's sharp
  2025 narrowing may ride a specific refactor event.
- **P2 (cohort flow): SPLIT — the monotone-narrowing prediction is
  falsified for young cones and confirmed for old ones.** All five
  Order apexes (old modules) narrow with age (trends −0.43..−0.60).
  All three traceable young Topology apexes WIDEN (+1.00): born as
  thin chains (cone size 4–9, meanApFrac ≈ 0), they broaden while
  under construction. The life cycle is non-monotone: born
  thin-narrow → widen during construction → consolidate narrow.
  The pre-registered strict prediction dies; the refined life-cycle
  description is post-hoc and needs its own pre-registered test.
- **P3 (youth of flat cones): 2/3.** SpectralObject (HEAD only) and
  CWComplex (born 2025-03) are young as predicted.
  **Order.Monoid.Canonical.Defs is the counterexample:** present
  since 2023-09, and its cone has consistently WIDENED (ap 0.12 →
  0.44, latency 0 throughout). Post-hoc reading, flagged as such:
  the flat regime may track ROLE, not age — `Defs`-style
  definitional interface files stay wide-shallow by design while
  theorem-mass consolidates into narrow towers. If that holds under
  a pre-registered test (classify cones by apex role, compare
  profiles), the two regimes become: maintained reducible interfaces
  vs consolidating irreducible towers — which is a sharper bridge
  statement than the age story, not a weaker one.

Bridge status after three deflation-adjacent tests: the static
signature survived degree-matched and invariant-matched nulls; the
dynamics exists at library level (P1) with a non-monotone cohort
life cycle (P2) and a role-dependent persistent-flat class (P3).
Next pre-registerable design: role-classified cohort study (Defs vs
theorem apexes), plus more checkpoints to firm up P1.

**Role-classified cone study (same day, `.scratch_role_study.mjs`):
the role hypothesis FAILS; the age/life-cycle story stands.**
Pre-registered design: 126 deduped cones (size 10–18) across the
three namespaces at HEAD; role = cone-aggregate declaration mix
(defFrac ≥ 0.5 = interface), secondary name-based classifier
({Defs, Notation, Init} path component); age from the 2023-09 /
2024-03 snapshots. Results, reported without re-thresholding:
  - Primary classifier had zero dynamic range: NO cone reaches
    defFrac 0.5 (theorem-like declarations dominate every cone's
    aggregate). R1/R3 untestable as registered — a design failure,
    logged as such.
  - Continuous check (R2): Spearman(defFrac, meanApFrac) = +0.106,
    (defFrac, latentFrac) = −0.079 — negligible. Declaration mix
    carries no aperture signal.
  - Name-based secondary: name-interface cones are NOT wider
    (medAp 0.098 vs 0.122 — slightly narrower). Defs-named cones
    span both extremes (UniformSpace.Defs among the narrowest,
    Prime.Defs among the widest).
  - Age effect present in the same sample: old cones medAp 0.081 vs
    young 0.131 — young wider, consistent with the life-cycle
    account (born thin → widen under construction → consolidate).
Verdict: the post-hoc "maintained reducible interfaces" reading from
the history test is withdrawn. Canonical.Defs stays on the books as
an individual unexplained anomaly (old, flat, widening), not the tip
of a class. The bridge keeps: static narrow-aperture signature
(survived two nulls) + library-level consolidation arrow + a
non-monotone cohort life cycle. It does NOT get the designed-pockets
architecture — that reading lasted three hours, which is what
pre-registration is for.

**Citation hunt + novelty scan (same day): all three questions
resolved.**

1. *The subspace-nucleus correspondence is classical, precisely
   located.* Simmons, "Spaces with Boolean assemblies", Colloq.
   Math. 43 (1980), Thm 4.5: for a T0 space, the assembly N(ΩS) is
   Boolean iff S is scattered. Poset/Alexandroff form: Bezhanishvili
   et al., "The Frame of Nuclei of an Alexandroff Space", Order 37
   (2020), arXiv:1906.03640 — N(O S) Boolean iff S is noetherian.
   Finite posets are noetherian, so the assembly is Boolean on 2^|P|
   atoms = our subsets-of-P census; Beazer–Macnab (Colloq. Math. 41,
   1979) has the algebraic condition. Part A of script 02 regrades
   [C]; the aperture reduction Ap(a) = {S : a∩S ordinary in Down(S)}
   built on top appears unclaimed — the intersection (ordinariness
   relativized to worlds + counting) remains ours, consistent with
   the paper's earlier novelty scan.
2. *Nearest empirical neighbor exists and is brand-new:* "The
   Network Structure of Mathlib" (arXiv:2604.24797, 2026; Toronto/
   UCLA/UCL/Google/Rutgers; dataset MathNetwork/MathlibGraph on
   HuggingFace — 308k declarations, 8.4M edges, module + declaration
   + namespace layers, historical commit pinned). Pure network
   science: PageRank, betweenness, Louvain, DAG layers. Zero
   Heyting/locale/nucleus content (grepped). Our instrument is
   orthogonal (their toolkit cannot express "verdict inside a
   coarse-grained world"), their dataset is directly usable for a
   declaration-level rerun, and the authors are candidate empirical
   collaborators.
3. *Wolfram alignment is exact and the gap is real:* the Wolfram
   Institute's own 2026 survey (Wiles, "Computational Metaphysics")
   names "identifying reducible pockets in the ruliad" as a key open
   problem; observer theory (Wolfram 2023 essay, 2026 metaphysics
   essay) remains informal — no observer census, no computable
   pocket criterion anywhere in that ecosystem. Our offering maps
   1:1: complete finite observer census (Boolean assembly, [C]),
   computable pocket criterion (ordinariness inside the world, [K]
   bridge), closed form on chains ([K]), null-tested empirics on
   real computation records ([computed], mathlib-study/). No prior
   art found applying nuclei to dependency graphs (word-collisions
   only: a localic-measure-theory blueprint graph, a Varela/ECI
   self-reference project).

Collaboration artifact decision pending: a working paper pitched at
the Wolfram Institute framing mathlib-study as "a computable
observer census and pocket-of-reducibility criterion for static
computation records, demonstrated on Mathlib with pre-registered
nulls" — their named open problem, our instrument, no publication
gate required.

Next when this thread resumes: (1) restate the reduction as a lemma
with the Simmons/Bezhanishvili citations (done in mathlib-study
README; propagate to the aperture paper when it next opens);
(2) mine the Part C aperture counts (284, 1020×2, 3892, 4356, 5344,
5888, 5916, 6780, 7728, 2^15) for the shape of the general formula —
these are exact values on a real 18-point poset, ideal test data;
(3) consider whether the Algebra Universalis extraction should state
the subspace reduction (it strengthens the paper from "two-prime
closed form + open problem" toward "general reduction + solved
chain case"); (4) Lean-check the correspondence on small P via
`decide` if cheap.

## Status update, 2026-08-24: latency rule corrected; closed form [K] at every arity

Two events, same day, causally linked:

- **The latency characterization was wrong, and the instrument
  caught it.** Div180 element 30 (exponents (1,1,1), 5-exponent at
  its chain top) has aperture 4 by the paper's own closed form —
  refuting the "every exponent strictly interior" rule in the
  false-negative direction. The violation hunt then found the
  false-positive direction too: Div8 elements 2 and 4 are
  all-interior with aperture 0 (single chain, no second coordinate).
  All three witnesses were sitting, unread, in the published
  164-element verification set; the ten-algebra sweep confirmed the
  wrong rule 10/10 only because every sweep lattice was two-prime or
  square-free — exactly where wrong and right rules coincide.
  Corrected rule (paper Result 6.3): **Ap(d) ≠ ∅ iff some exponent
  strictly interior and some other chain below its top; latent iff
  additionally no exponent is zero.** Verified 164/164 vs
  enumeration + 252 formula-only points
  (`latency-characterization-correction.mjs`). Square-free and
  Div(2^a·3) impossibility results survive. Paper bumped to v0.3
  with the correction dated; original pre-registered headers kept
  with postscripts. Fourth time the instrument has overruled the
  operator.
- **The r > 2 Lean iteration closed the same day**
  (`Lattice/ApertureClosedFormPi.lean`) — pulled forward because the
  correction produced witnesses only a general-arity theorem could
  kernel-check. Not by folding the binary assembly: the Pi statement
  is proved directly (`nucleusPiEquiv` via `x = ⨅ i, update ⊤ i (x i)`;
  coordinatewise world predicates; `aperture_card_add_eq_pi`, whose
  two inclusion-exclusion events do not multiply with arity).
  `aperture_closed_form_pi` is Theorem 5.1 verbatim on
  `Π i : Fin r, Fin (aᵢ + 1)`, any r. `decide`d cross-checks:
  Div180/30 = 4, Div8/2 = Div8/4 = 0 (the correction witnesses,
  kernel-certified), Div12 = 1 (re-meeting `aperture_two_complete`).
  Axiom audit clean; full `lake build` green. **Theorem 5.1 is [K]
  on all divisor lattices.** What stays [computed]: the exhaustive
  sweeps and Result 6.3's general "iff" (its formula and witnesses
  are [K]). Design notes part 7 has the Lean decisions.

## Status update, 2026-08-25: Study 10 (Life causal cones) — protocol died twice, honestly

The Game of Life pilot (`ca-study/`) ran its full arc in one day:

- **v1.0 died by inspection, before any run.** The registered syntactic
  edge rule (every Moore pair, values never consulted) makes the causal
  DAG state-independent: conditions A–E produce isomorphic depth-d
  pyramids, N2 (rule randomization) is provably a no-op, and the budget
  forces depth 1 = the 9-antichain-under-a-top, whose kernels are all
  dense or regular. P1–P4 would have failed as theorems about the
  construction. v1.0 is committed unexecuted with the proof as its
  postscript. General diagnostic kept: *if a randomization cannot change
  your object, your object does not depend on what you randomized.*
- **v1.1 (counterfactual single-flip edges, all parameters pinned) was
  registered, committed at `0b1c40a`, and executed.** Anchors 8/8
  (Div12/Div36 kernel-checked values reproduced). Census: counterfactual
  cones around live structure grow fast (glider 9 → 27 → 57), so 21 of 29
  cones landed at depth 1. **P1 FAILED** (Mann–Whitney p = 0.738; stop
  rule applied, nulls not run). Postmortem: every depth-1 cone is a fan,
  and Down(fan) is a powerset with a dense top glued on — aperture
  identically 0 in every world, provable in two lines. The budget policy,
  not the invariant, decided the outcome; both pools were structural
  zeros. The v1.0 postscript had already named the pyramid as blind; the
  amendment changed which two-layer poset the budget buys, not the
  blindness of two-layer posets.
- **What the deep cones showed (descriptive only, cross-depth, not
  licensed as claims):** still lifes have the thinnest counterfactual
  margins and hence the deepest in-budget cones — beehive (n=15, d=3)
  14/15 latent, medAp 0.153; loaf (n=16, d=3) 15/16, 0.171 — an order of
  magnitude wider than depth-2 soups (0.004–0.016). Soup-20260825005 has
  the substrate's first ambient-ordinary kernels. Figure-against-quiet-
  ground is where the instrument's budget goes deepest, which is where
  the interpretive hypothesis lives — suggestive, unproved, unclaimed.
- **Named follow-up, not run:** v1.2 depth-matched design (fixed d = 2
  all conditions, all-kernel enumeration under a wide-mask engine or a
  budget raise to n ≤ 24). Requires a new pre-registration. Pending
  manual step: the WL twin (`ca-study/wl/ca-aperture.wl`) in Wolfram
  Cloud to confirm the Node-side P1 negative.
- Fifth instrument-overrules-operator event, second within this study.
  Lesson recorded: *a budget policy is part of the instrument, and it can
  be the part that goes blind.*

## Status update, 2026-08-25 (later): Study 10 v1.2 — the real answer, and it splits

Depth-matched redesign registered cold (`PREREGISTRATION-v1.2.md`,
calibration 106/108 committed with it at `c64ce3c`) and executed same day:

- **P1′ (structured-vs-soup) FAILS as a genuine measurement** (p = 0.263).
  With the fan artifact removed, every cone carries real apertures, and
  gliders/oscillators/spaceships are statistically indistinguishable from
  soup. The v1.1 negative is confirmed by clean design. Post-hoc reading,
  flagged: soup at T = 8 is ash — still lifes and blinkers — so the
  registered contrast compared zoo objects to a population of the same
  kinds of objects; the question, not the instrument, may be ill-posed at
  this horizon.
- **P6′ (figure-vs-ground) HOLDS**: still-life cones ~17× wider than soup
  at matched depth (0.0977 vs 0.0057, MW p = 0.044). Caveat recorded: the
  signal rides on beehive/loaf's n = 9 cones and aperture fractions covary
  with cone size — but thin counterfactual margins ARE the still-life
  phenomenon, so signal and confound are entangled. Size-controlled
  follow-up named, not run.
- **Narrowness does NOT transfer**: real cones sit at percentiles 6-88 of
  their own 100 degree-preserving rewirings. The Mathlib ≈18× is a fact
  about curated dependency structures — the anticipated §8 reading of the
  aperture paper's empirical scope, now measured.
- **Latency is generic on the CA substrate** (67-94% of kernels in every
  non-trivial cone; first ambient-ordinary kernels found in oscillator and
  soup cones). Cross-substrate picture: latency rare on divisor lattices,
  generic on Mathlib, generic on Life — full-resolution ordinariness is
  the exception in the wild.
- **N2**: random matched-density rules kill the pattern before T = 8 in
  45-60% of runs; where defined, apertures run 0-0.0018 vs Life's
  0.0037-0.0147 on the same seeds. Life makes wider-aperture causal
  structure than a random rule of equal table density [descriptive].
- Pending: WL cloud run (`ca-study/wl/ca-aperture.wl`) to confirm the
  Node-side primary cones; size-controlled P6′ follow-up as a fresh
  registration.

## Tomorrow (2026-08-17): write the study — the positions casework

The third companion is drafted next: **the four positions of the
temperament commitment, one work per cell, fully worked** — the
cultural wager alongside the mathematical (aperture) and perceptual
(hearing) papers. Suggested location: `preprints/positions-casework/`
(or `papers/` if it stays essay-register). It can now stand on
Bach-at-the-Kernel v0.3 §4 instead of rebuilding the aperture layer.

Structure agreed in session 2026-08-16:

1. **Kernel and dictionary, committed once.** Kernel = the 12-EDO
   temperament commitment; the work→element dictionary stated up
   front, [A], defended per case. The 4-cell theorem's exclusivity is
   the discipline: one cell per work *per committed reading*; arguing
   a different cell requires changing the reading and defending the
   change.
2. **Four case studies, one per cell, each with its falsification
   condition stated** (what would force a different cell under the
   same reading):
   - Infrastructure — *Well-Tempered Clavier* (load-bearing
     demonstration from inside the commitment);
   - Distribution — the common-practice modulation system /
     enharmonic pivot practice (the shakiest chair; say so);
   - Exploitation — *Giant Steps* (the major-third cycle as
     equal-temperament surplus; the symmetry exists only in 12-EDO —
     mining the residue), with blues intonation as the other corner;
   - Refusal — Partch (43-tone just intonation; nearly self-evident,
     say so), Johnston / La Monte Young as secondary witnesses.
3. **Fragility profiles — the new instrument.** For each work, not
   just "which cell" but "under which of the eight hearings does its
   cell survive": Refusal needs the dense half alive, Exploitation
   the regularity gap, so the four works have *different computable
   collapse profiles*. Wire to the actual Div12 aperture data
   (Ap(kernel) = {identity} [K] bounds everything: at full blur-depth
   all placements die together; the profiles differ in *how* they
   die — dense-side vs regular-side, per the worksheet verdicts).
4. **Honesty apparatus:** Tymoczko's standing skepticism (does the
   comma still actively matter on fixed-tuning instruments) logged in
   the paper, not smoothed; the resolution-dependence finding (Paper
   2 §3.7, 21% alignment) cited as measured cost; grades throughout
   ([K] the partition/aperture facts, [A] every placement, no
   quiet upgrades).
5. **Feed-forward:** the fragility profiles double as the epistemic
   paper's T2/T3 theses running on real cultural material — this
   study is evidence infrastructure for the epistemology, not a
   detour from it.

Also pending from this weekend, lower priority: the epistemic reading
paper (`preprints/epistemic/` — grain-of-description dictionary,
T1–T4, statistical-mechanics latency case study); the r > 2 Lean
iteration (DONE 2026-08-24); pre-arXiv due diligence (2026-08-15
entry).

## Tomorrow, in order (original plan, 2026-08-11)

1. **Paper §5 rewrite** — replace the product-law conjecture with the
   closed form as a theorem-with-proof-sketch (the two paragraphs above).
   Grade honestly: derivation given in text, 164/164 [computed], Lean
   pending. State corollaries. Update §6 (latent sizes now *explained* —
   keep the narrative that we refused to fit them first), abstract and §1
   (fifteen lattices, closed form as companion headline to latency), §8
   grade table, §9 reproducibility (cite `aperture-closed-form.mjs`).
2. **Second implementation** — add the closed-form check to
   `aperture-scaling.wl` (formula vs measured apertures over its eight
   lattices) and rerun in Wolfram Cloud; record confirmation in README.
3. **README + design-notes** — update the scaling section (the "sizes fit
   no obvious product form" line is superseded), add the closed-form story
   to the part-4 addendum (predict → discriminate → derive sequence).
4. **Lean** — formalize the closed form per reviewer: the general
   statement, not the two-prime corollary. The factorization lemma proof
   above is the skeleton. This upgrades the paper's central result from
   [computed] to [K].
5. Housekeeping: `wolfram/product-law-two-prime.mjs` documents the
   intermediate discrimination step; fold its story into design-notes and
   decide whether to keep or delete it.

Uncommitted leftover scratch in repo root (`.scratch_aperture_check.mjs`
etc.) is intentionally untracked; ignore.
