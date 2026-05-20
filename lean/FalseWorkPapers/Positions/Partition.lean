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
  [HasEqualizers C] [HasInitial C] [HasBinaryCoproducts C] [InitialMonoClass C]

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

Both directions discharge directly from
`CategoryTheory.Limits.imageSubobject_le` (forward) and the composition
`factorThruImageSubobject ≫ Subobject.ofLE` (backward), the latter
collapsed by `ofLE_arrow` and `imageSubobject_arrow_comp`.  Closed in
Path 5 (2026-05-19). -/
theorem isRefusal_iff_image_le_compl
    (Δ : DistinctionStructure C)
    {X Y : C} (f : X ⟶ Y) :
    IsRefusal Δ f ↔
      Subobject.mk (image.ι (Δ.D.map f)) ≤ (kernelImage Δ Y)ᶜ := by
  constructor
  · rintro ⟨g, hg⟩
    -- `hg : Δ.D.map f = g ≫ ((kernelImage Δ Y)ᶜ).arrow` is the factorisation
    -- witness; `Subobject.imageSubobject_le` reads exactly this off:
    -- `imageSubobject f ≤ X` when `h ≫ X.arrow = f`.  `imageSubobject _`
    -- is `Subobject.mk (image.ι _)` (abbrev), so the goal unifies.
    exact imageSubobject_le (Δ.D.map f) g hg.symm
  · intro h
    -- Build `g` as `factorThruImageSubobject (Δ.D.map f) ≫ ofLE _ _ h`;
    -- the equation `g ≫ kᶜ.arrow = Δ.D.map f` then follows from
    -- `ofLE_arrow` (collapses the second factor to `(imageSubobject _).arrow`)
    -- and `imageSubobject_arrow_comp` (collapses the rest to `Δ.D.map f`).
    refine ⟨factorThruImageSubobject (Δ.D.map f) ≫
              Subobject.ofLE _ _ h, ?_⟩
    rw [Category.assoc, Subobject.ofLE_arrow, imageSubobject_arrow_comp]

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
    {X Y : C} (f : X ⟶ Y)
    (h_nontriv : Subobject.mk (image.ι (Δ.D.map f)) ≠ ⊥) :
    (IsInfrastructure Δ f ∨ IsDistribution Δ f ∨
      IsExploitation Δ f ∨ IsRefusal Δ f) ∧
    (IsInfrastructure Δ f → ¬ IsDistribution Δ f) ∧
    (IsInfrastructure Δ f → ¬ IsExploitation Δ f) ∧
    (IsInfrastructure Δ f → ¬ IsRefusal Δ f) ∧
    (IsDistribution Δ f → ¬ IsExploitation Δ f) ∧
    (IsDistribution Δ f → ¬ IsRefusal Δ f) ∧
    (IsExploitation Δ f → ¬ IsRefusal Δ f) := by
  -- Abbreviations for readability.
  set img := Subobject.mk (image.ι (Δ.D.map f)) with himg_def
  set K := kernelImage Δ Y with hK_def
  -- The `IsRefusal ↔ img ≤ Kᶜ` equivalence (image-API helper).
  have hRefuse : IsRefusal Δ f ↔ img ≤ Kᶜ :=
    isRefusal_iff_image_le_compl Δ f
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · -- EXHAUSTIVENESS.  Classical case-split on `img ≤ K`, then on the
    -- two Heyting non-triviality flags `img ⊓ K = ⊥` and `img ⊓ Kᶜ = ⊥`.
    by_cases h1 : img ≤ K
    · exact Or.inl h1
    · by_cases h2 : img ⊓ K = ⊥
      · -- `img ⊓ K = ⊥` ⇒ `img ≤ Kᶜ` via the Heyting Galois connection
        -- (`le_compl_iff_disjoint_right` ↔ `disjoint_iff`).
        refine Or.inr (Or.inr (Or.inr ?_))
        apply hRefuse.mpr
        rw [le_compl_iff_disjoint_right, disjoint_iff]
        exact h2
      · by_cases h3 : img ⊓ Kᶜ = ⊥
        · -- `img ⊓ Kᶜ = ⊥` ⇒ `img ≤ Kᶜᶜ` (same Galois move).  Combined
          -- with `h1 : ¬(img ≤ K)` gives `IsExploitation`.
          refine Or.inr (Or.inr (Or.inl ⟨?_, h1⟩))
          rw [le_compl_iff_disjoint_right, disjoint_iff]
          exact h3
        · -- Both meets non-trivial ⇒ `IsDistribution`.
          exact Or.inr (Or.inl ⟨h2, h3⟩)
  · -- Infra → ¬Distribution.  `img ≤ K` forces `img ⊓ Kᶜ ≤ K ⊓ Kᶜ = ⊥`,
    -- contradicting `IsDistribution.2`.
    intro hInfra ⟨_, h_dist_hi⟩
    exact h_dist_hi (hInfra.disjoint_compl_right.eq_bot)
  · -- Infra → ¬Exploitation.  `IsExploitation.2 = ¬(img ≤ K)`.
    intro hInfra ⟨_, h_neg⟩
    exact h_neg hInfra
  · -- Infra → ¬Refusal.  Via `hRefuse`: refusal ⇒ `img ≤ Kᶜ`.  Combined
    -- with `img ≤ K` gives `img ≤ K ⊓ Kᶜ = ⊥`, contradicting `h_nontriv`.
    intro hInfra hRef
    have hKc : img ≤ Kᶜ := hRefuse.mp hRef
    apply h_nontriv
    exact le_bot_iff.mp ((le_inf hInfra hKc).trans (inf_compl_self K).le)
  · -- Distribution → ¬Exploitation.  `IsExploitation.1 = img ≤ Kᶜᶜ` forces
    -- `img ⊓ Kᶜ ≤ Kᶜᶜ ⊓ Kᶜ = ⊥` (via `compl_inf_self Kᶜ`), contradicting
    -- `IsDistribution.2`.
    intro ⟨_, h_dist_hi⟩ ⟨hClos, _⟩
    apply h_dist_hi
    exact le_bot_iff.mp ((inf_le_inf_right _ hClos).trans (compl_inf_self Kᶜ).le)
  · -- Distribution → ¬Refusal.  Refusal ⇒ `img ≤ Kᶜ` ⇒ `img ⊓ K ≤ Kᶜ ⊓ K = ⊥`,
    -- contradicting `IsDistribution.1`.
    intro ⟨h_dist_lo, _⟩ hRef
    have hKc : img ≤ Kᶜ := hRefuse.mp hRef
    apply h_dist_lo
    exact le_bot_iff.mp ((inf_le_inf_right _ hKc).trans (compl_inf_self K).le)
  · -- Exploitation → ¬Refusal.  Refusal ⇒ `img ≤ Kᶜ`; combined with
    -- `img ≤ Kᶜᶜ` gives `img ≤ Kᶜ ⊓ Kᶜᶜ = ⊥`, contradicting `h_nontriv`.
    intro ⟨hClos, _⟩ hRef
    have hKc : img ≤ Kᶜ := hRefuse.mp hRef
    apply h_nontriv
    exact le_bot_iff.mp ((le_inf hKc hClos).trans (inf_compl_self Kᶜ).le)

/-! ## Status

DONE:
* `four_position_partition` — fully proven (Phase 3, 2026-05-19)
  via the helper `isRefusal_iff_image_le_compl`.  The Heyting
  case-split (`by_cases` on `img ≤ K`, `img ⊓ K = ⊥`, `img ⊓ Kᶜ = ⊥`)
  and the six pair-wise disjointness arguments are all discharged
  using the universal `FalseWork.Heyting.heytingAlgebra` instance.
* `isRefusal_iff_image_le_compl` — both directions discharged in
  Path 5 (2026-05-19): forward via `imageSubobject_le`, backward
  via `factorThruImageSubobject ≫ Subobject.ofLE` collapsed by
  `ofLE_arrow` + `imageSubobject_arrow_comp`.

REMAINING `sorry`s in this file: none.

UPSTREAM MATHLIB GAP:
* `HeytingAlgebra (Subobject _)` — closed Phase 2 (2026-05-19) by
  `FalseWork.Heyting.heytingAlgebra`; cell files now consume the
  instance via `Setup.lean`.

FRAMEWORK STATUS:
* Theorem 0 is the framework's central structural claim, now
  formally established in Lean.  The cell predicates are stable;
  the partition is a Heyting-algebra theorem *and* an image-algebra
  theorem.  Phase 2 + Phase 3 closed the Heyting side; Path 5
  (2026-05-19) closed the image side.  The Commitment gate
  (`Commitment.lean`) is orthogonal and lives at schema level, not
  at theorem-grade partition level.
-/

end FalseWork.Positions
