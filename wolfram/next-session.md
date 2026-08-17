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
interior), and the latent aperture sizes previously reported as
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
  Bookkeeping, not mathematics.

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
iteration; pre-arXiv due diligence (2026-08-15 entry).

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
