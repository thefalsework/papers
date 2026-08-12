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

## Tomorrow, in order

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
