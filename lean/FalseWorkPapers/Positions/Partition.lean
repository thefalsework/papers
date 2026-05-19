/-
Copyright (c) 2026 Chris Brink.
Released under the same license as the rest of the FalseWork Papers.

Authors: Chris Brink (FalseWork)

# The four-position partition theorem

This file states the framework's central structural claim: that the
four cell predicates `IsInfrastructure`, `IsDistribution`,
`IsExploitation`, `IsRefusal` partition the morphism space of `C`
(modulo the trivial-image edge case). The Commitment gate is a
*binary refinement* applied within each cell and is the subject of
`Commitment.lean`, not this file.

The partition reduces to a case-split over the Heyting algebra
`Sub(D Y)` of where `image(D.map f)` lies relative to `kernelImage Δ Y`
and its pseudo-complements. The disjointness reduces to Heyting-
algebra identities; the exhaustiveness reduces to a trichotomy that
itself refines into the four cells.

## The partition (informal)

For a morphism `f : X ⟶ Y` with `img := image(D.map f)` and
`k := kernelImage Δ Y`:

| Cell           | Condition                              | Heyting shape    |
|----------------|----------------------------------------|------------------|
| Infrastructure | `img ≤ k`                              | `≤ a`            |
| Refusal        | `img ≤ kᶜ`                             | `≤ aᶜ`           |
| Exploitation   | `img ≤ kᶜᶜ ∧ ¬(img ≤ k)`               | `≤ aᶜᶜ ∧ ¬(≤ a)` |
| Distribution   | `img ⊓ k ≠ ⊥ ∧ img ⊓ kᶜ ≠ ⊥`           | straddle         |

## The proof structure (informal)

**Disjointness** reduces to four Heyting identities:

* Infrastructure ⊥ Refusal: `img ≤ k ∧ img ≤ kᶜ ⇒ img ≤ k ⊓ kᶜ = ⊥`.
* Infrastructure ⊥ Distribution: `img ≤ k ⇒ img ⊓ kᶜ = ⊥`,
  contradicting Distribution's second clause.
* Infrastructure ⊥ Exploitation: by Exploitation's `¬(img ≤ k)` clause.
* Refusal ⊥ Distribution: `img ≤ kᶜ ⇒ img ⊓ k = ⊥`, contradicting
  Distribution's first clause.
* Refusal ⊥ Exploitation: `img ≤ kᶜ ∧ img ≤ kᶜᶜ ⇒ img ≤ kᶜ ⊓ kᶜᶜ = ⊥`.
* Distribution ⊥ Exploitation: `img ≤ kᶜᶜ ⇒ img ⊓ kᶜ = ⊥` (since
  `kᶜᶜ ⊓ kᶜ = ⊥`), contradicting Distribution's second clause.

**Exhaustiveness** reduces to the trichotomy on `img` relative to `k`:

  `(img ≤ k) ∨ (img ⊓ k = ⊥) ∨ (img ⊓ k ≠ ⊥ ∧ img ⊓ kᶜ ≠ ⊥)`

Case 1 is Infrastructure. Case 2 is equivalent to `img ≤ kᶜ` (Refusal).
Case 3 refines on `img ⊓ kᶜ`:
* `img ⊓ kᶜ ≠ ⊥`: Distribution.
* `img ⊓ kᶜ = ⊥` (i.e., `img ≤ kᶜᶜ`): Infrastructure if `img ≤ k`,
  Exploitation otherwise.

The trichotomy itself is a consequence of `img ⊓ k = ⊥ ↔ img ≤ kᶜ` in
a Heyting algebra, plus the law of excluded middle on the meta-level
proposition `img ≤ k`.

## The trivial-image edge case

When `image(D.map f) = ⊥`, all four cell conditions are satisfied
vacuously (`⊥ ≤ k`, `⊥ ≤ kᶜ`, `⊥ ⊓ k = ⊥`, `⊥ ⊓ kᶜ = ⊥`). The
partition theorem excludes this case (`image(D.map f) ≠ ⊥` hypothesis)
or alternatively interprets it as "the work makes no marking-claim at
`Y`," which is below the resolution of the cell dictionary.

## Cross-reference

* `papers/comma-formal-structure-note.md` §5 — the cell predicates
* `papers/comma-formal-structure-note.md` §6 Theorem 0 — the statement
  of this partition
* `Setup.lean` — `DistinctionStructure`, `kernelImage`, Mathlib gap note
* `Infrastructure.lean`, `Distribution.lean`, `Exploitation.lean`,
  `Refusal.lean` — the four cell predicates
* `Commitment.lean` — the binary gate applied within each cell

The four cell predicates are formal commitments; their disjointness
and exhaustiveness here are theorem-grade claims. The Commitment gate
is schema-grade (uniform shape across cells, content cell-specific);
its theorem-grade unification was tested in `MomentRelative.lean` on
2026-05-10 and closed negative.
-/

import FalseWorkPapers.Positions.Setup
import FalseWorkPapers.Positions.Infrastructure
import FalseWorkPapers.Positions.Distribution
import FalseWorkPapers.Positions.Exploitation
import FalseWorkPapers.Positions.Refusal

namespace FalseWork.Positions

open CategoryTheory CategoryTheory.Limits

universe v u

variable {C : Type u} [Category.{v} C]
  [HasImages C] [HasPullbacks C] [HasSubobjectClassifier C]

/-! ## The partition theorem -/

/-- **Theorem 0 (Four-position partition).** Let `Δ` be a non-trivial
distinction structure on a category `C` with the requisite Heyting
structure on its subobject lattices. For every morphism `f : X ⟶ Y`
in `C` whose `D`-image is non-trivial, exactly one of the four cell
predicates holds: `IsInfrastructure Δ f`, `IsDistribution Δ f`,
`IsExploitation Δ f`, `IsRefusal Δ f`.

The four cells are pairwise disjoint Heyting conditions on
`(image(D.map f), kernelImage Δ Y)` and exhaustive over the morphism
space of `C` (modulo the trivial-image edge case). -/
theorem four_position_partition
    (Δ : DistinctionStructure C)
    [∀ Y : C, HeytingAlgebra (Subobject Y)]
    {X Y : C} (f : X ⟶ Y)
    (_h_nontriv : Subobject.mk (image.ι (Δ.D.map f)) ≠ ⊥) :
    (IsInfrastructure Δ f ∨ IsDistribution Δ f ∨
      IsExploitation Δ f ∨ IsRefusal Δ f) ∧
    (IsInfrastructure Δ f → ¬ IsDistribution Δ f) ∧
    (IsInfrastructure Δ f → ¬ IsExploitation Δ f) ∧
    (IsInfrastructure Δ f → ¬ IsRefusal Δ f) ∧
    (IsDistribution Δ f → ¬ IsExploitation Δ f) ∧
    (IsDistribution Δ f → ¬ IsRefusal Δ f) ∧
    (IsExploitation Δ f → ¬ IsRefusal Δ f) := by
  /- Proof structure:

     Let `img := Subobject.mk (image.ι (Δ.D.map f))` and
     `k := kernelImage Δ Y`.

     EXHAUSTIVENESS. Case-split on `img ≤ k`:
     * If `img ≤ k`: Infrastructure. Done.
     * If `¬(img ≤ k)`: case-split on `img ⊓ k = ⊥`:
       - If `img ⊓ k = ⊥`: this is equivalent to `img ≤ kᶜ` in a
         Heyting algebra. Refusal. (Note: `IsRefusal` is currently
         stated as a factorization condition; the equivalence with
         `img ≤ kᶜ` is a separate lemma — see `Refusal.lean`.)
       - If `img ⊓ k ≠ ⊥`: case-split on `img ⊓ kᶜ = ⊥`:
         * If `img ⊓ kᶜ ≠ ⊥`: Distribution.
         * If `img ⊓ kᶜ = ⊥`: equivalent to `img ≤ kᶜᶜ`. Combined
           with `¬(img ≤ k)`: Exploitation.

     DISJOINTNESS. Each pair-wise disjointness reduces to a Heyting
     identity, listed in the file's docstring.

     The proof depends on:
     * Heyting structure on `Subobject (D Y)` — currently assumed via
       the `[HeytingAlgebra (Subobject _)]` instance hypothesis (the
       Mathlib gap, see `Setup.lean`).
     * The equivalence `IsRefusal Δ f ↔ img ≤ kᶜ` — currently
       `IsRefusal` is stated as a factorization through `kᶜ`; the
       image-subobject characterisation is a separate lemma to add.
     * Trichotomy in a Heyting algebra: for any `a, b`,
       `(a ≤ b) ∨ (a ⊓ b = ⊥) ∨ (a ⊓ b ≠ ⊥ ∧ a ⊓ bᶜ ≠ ⊥)` — this
       requires classical reasoning on the meta-propositions, which
       is available since we are working in `Prop`. -/
  sorry

/-! ## Refusal characterization (helper lemma needed for the partition) -/

/-- **Refusal as image-subobject condition.** `IsRefusal Δ f` is
equivalent to `image(D.map f) ≤ (kernelImage Δ Y)ᶜ`.

The current `IsRefusal` definition factors through the complement
subobject; this lemma rewrites that factorization as the image-
subobject containment used in the partition proof.

This is a standard image-factorization-through-mono equivalence:

* (⇒) A factorization `D.map f = g ≫ m.arrow` (where `m` is a
  subobject of `D Y`) implies `image(D.map f) ≤ m` because the image
  of `D.map f` is the smallest subobject through which `D.map f`
  factors, and `m` is one such subobject.

* (⇐) A containment `image(D.map f) ≤ m` produces a factorization
  via the composition of `factorThruImage (D.map f)` with the
  subobject inclusion `image(D.map f) ⟶ m` (which exists by the
  containment) and `m.arrow`.

Both directions are routine but require the Mathlib image-and-
subobject API (`Subobject.factorThru`, `Subobject.ofLE`,
`image.factorThruImage`). Lemma names tentative pending verification. -/
theorem isRefusal_iff_image_le_compl
    (Δ : DistinctionStructure C)
    [∀ Y : C, HeytingAlgebra (Subobject Y)]
    {X Y : C} (f : X ⟶ Y) :
    IsRefusal Δ f ↔
      Subobject.mk (image.ι (Δ.D.map f)) ≤ (kernelImage Δ Y)ᶜ := by
  constructor
  · rintro ⟨g, hg⟩
    -- `D.map f = g ≫ ((kᶜ).arrow)`, so `D.map f` factors through `kᶜ`.
    -- Therefore the image of `D.map f` is bounded above by `kᶜ` in
    -- the subobject lattice. The relevant lemma is
    -- `Subobject.image_le_iff_factors_through` (or its analogue
    -- via `image.lift` factoring through the mono `kᶜ.arrow`).
    sorry
  · intro h
    -- From `image(D.map f) ≤ kᶜ`, get a morphism
    -- `image(D.map f) ⟶ underlying(kᶜ)` realizing the inclusion (via
    -- `Subobject.ofLE`), then compose with `factorThruImage (D.map f)`
    -- to get `g : D X ⟶ underlying(kᶜ)` with
    -- `D.map f = g ≫ (kᶜ).arrow`.
    sorry

/-! ## Status

DONE:
* `four_position_partition` — full statement of Theorem 0. The proof
  structure is documented; the proof itself is `sorry` pending:
  - The Mathlib `HeytingAlgebra (Subobject Y)` instance for topoi.
  - The `isRefusal_iff_image_le_compl` characterisation lemma below.
  - The Heyting-algebra trichotomy lemma (provable in Mathlib once
    the instance is available).
* `isRefusal_iff_image_le_compl` — helper lemma re-characterising
  Refusal in image-subobject form. `sorry` pending standard image-
  factorization lemmas.

UPSTREAM MATHLIB GAP:
* `HeytingAlgebra (Subobject _)` for topoi (see `Setup.lean` note).
  This is the load-bearing gap for the partition theorem.

FRAMEWORK STATUS:
* Theorem 0 is the framework's central structural claim. The cell
  predicates are stable; the partition is a Heyting-algebra theorem
  modulo the Mathlib gap. The Commitment gate (`Commitment.lean`)
  is orthogonal and lives at schema level, not at theorem-grade
  partition level.
-/

end FalseWork.Positions
