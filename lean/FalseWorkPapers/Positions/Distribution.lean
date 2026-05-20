/-
Copyright (c) 2026 Chris Brink.
Released under the same license as the rest of the FalseWork Papers.

Authors: Chris Brink (FalseWork)

# Distribution: the comma straddles both poles

A morphism `f` is in *Distribution position* when its `D`-image
straddles `Im(η)` and `¬Im(η)` in the subobject lattice — neither
contained in nor disjoint from the kernel image. Both poles of the
comma are present in `f`'s structure; neither is suppressed.

## Empirical correspondences

* **Vermeer, *Girl with a Pearl Earring* (c. 1665).** Every passage
  carries both terms: the pearl highlight IS pigment AND IS reflection,
  the turban IS fabric AND IS applied color. The comma is distributed
  across parallel registers; no register suppresses the other.

* **Coppola, *The Godfather* (1972), baptism scene.** The cut's tension
  is distributed across audio and image channels — the priest's
  liturgy on one channel, escalating murders on another. Each channel
  carries part of the comma; the parallel-channel structure is the
  distribution.

## Formal characterisation

In the topos register, Distribution is the condition that the image of
`D.map f` (as a subobject of `D Y`) intersects both `Im(η)` and
`¬Im(η)` non-trivially. Operationally:

* `img(D.map f) ⊓ Im(η)` is non-zero — `f` reaches into the kernel image.
* `img(D.map f) ⊓ ¬Im(η)` is non-zero — `f` reaches into the complement.

Neither term is suppressed; both registers carry weight. The "balance"
condition the framework wants — that no register dominates — is
captured here at its weakest form: both intersections are non-trivial.
A stronger balance condition (e.g., parity of measure, or symmetry
under some structure on `C`) is open framework work.

## Cross-reference

* Paper 1 v11.7 § 4 — Distribution as the second of five positions
-/

import FalseWorkPapers.Positions.Setup

namespace FalseWork.Positions

open CategoryTheory CategoryTheory.Limits

universe v u

variable {C : Type u} [Category.{v} C]
  [HasImages C] [HasPullbacks C] [HasSubobjectClassifier C]

/-! ## The Distribution position -/

/-- A morphism `f : X ⟶ Y` is in *Distribution position* relative to
`Δ` when its `D`-image (as a subobject of `D Y`) intersects both the
kernel image `Im(η)` and its Heyting complement `¬Im(η)` non-trivially.

The framework's "comma distributed across parallel registers" becomes
the formal condition that neither pole is suppressed in `D.map f`'s
codomain. -/
noncomputable def IsDistribution (Δ : DistinctionStructure C)
    [∀ Y : C, HeytingAlgebra (Subobject Y)]  -- discharged universally by `FalseWork.Heyting.heytingAlgebra` for elementary topoi
    {X Y : C} (f : X ⟶ Y) : Prop :=
  let img := Subobject.mk (image.ι (Δ.D.map f))
  img ⊓ kernelImage Δ Y ≠ ⊥ ∧ img ⊓ (kernelImage Δ Y)ᶜ ≠ ⊥

/-! ## Signature theorem: both poles non-trivial -/

/-- **Distribution signature.** A morphism in Distribution position
witnesses the kernel image and its complement *jointly* — neither pole
of the comma is contained in the other relative to `f`.

Equivalently: `f` is *not* in Infrastructure position (which would
mean `img ⊆ Im(η)`) and *not* in Refusal position (which would mean
`img ⊆ ¬Im(η)`). Distribution sits in between. -/
theorem isDistribution_implies_neither_polar (Δ : DistinctionStructure C)
    [∀ Y : C, HeytingAlgebra (Subobject Y)]
    {X Y : C} (f : X ⟶ Y) (h : IsDistribution Δ f) :
    let img := Subobject.mk (image.ι (Δ.D.map f))
    ¬(img ≤ kernelImage Δ Y) ∧ ¬(img ≤ (kernelImage Δ Y)ᶜ) := by
  sorry  -- Proof: the meet conditions in `IsDistribution` directly
         -- contradict the containment claims; standard lattice
         -- manipulation, ~10 lines.

/-! ## Status

DONE:
* `IsDistribution` definition. Captures "both poles non-trivial" in
  the subobject lattice.
* Signature theorem statement. Distribution is between Infrastructure
  and Refusal: neither pole contains the image.

REMAINING `sorry`:
* `isDistribution_implies_neither_polar` proof — straightforward
  lattice manipulation, ~10 lines.

OPEN FRAMEWORK QUESTIONS:
* The "balance" condition. Current definition asks both intersections
  be non-trivial; the framework's operational notion ("parallel
  registers, no register dominates") is stronger. Three candidate
  refinements:
  1. **Anti-chain**: `img ⊓ Im(η)` and `img ⊓ ¬Im(η)` are pairwise
     incomparable in the subobject ordering. Captures "neither
     dominates" at the lattice level.
  2. **Equimeasure** (requires additional structure): if `Sub(D Y)`
     comes equipped with a measure, the two intersections have the
     same measure. Captures "balance" at the quantitative level.
  3. **Categorical decomposition**: `img` is a colimit of pieces, some
     in `Im(η)`, some in `¬Im(η)`, with the pieces forming a discrete
     diagram (so the colimit is a coproduct). Captures "parallel
     registers" structurally.
  Decision is framework-level.

UPSTREAM MATHLIB GAP:
* `HeytingAlgebra (Subobject _)` for topoi (see `Setup.lean` note).
-/

end FalseWork.Positions
