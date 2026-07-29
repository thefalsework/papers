/-
Copyright (c) 2026 Chris Brink.
Released under the same license as the rest of the FalseWork Papers.

Authors: Chris Brink (FalseWork)

# The bridge: partition non-degeneracy = ordinary kernel

This file welds the framework's two Lean stacks into one chain:

* the **topos stack** (`Positions/`): `DistinctionStructure` (the
  Spencer-Brown calling axiom, categorified), `kernelImage`, the four
  morphism-level cell predicates, and the partition theorem
  (`four_position_partition`);
* the **lattice stack** (`Lattice/`, `Examples/`): the four lattice
  cells (`IsLattice*`), `AllFourCellsInhabited`, `IsOrdinary` (Citkin's
  ordinary elements — neither regular nor dense), and the ordinary-
  elements structure theory of `preprints/ordinary-elements-z6/`
  (uniqueness of the ordinary element, six-element threshold, Z₆
  order-embedding, Rieger–Nishimura normal form).

## Main results

* `isInfrastructure_iff_lattice`, `isDistribution_iff_lattice`,
  `isExploitation_iff_lattice`, `isRefusal_iff_lattice` — each
  morphism-level cell predicate **is** the corresponding lattice cell
  at `img := image(D.map f)` relative to `a := kernelImage Δ Y`
  (definitionally for Infrastructure/Distribution/Exploitation; via
  `isRefusal_iff_image_le_compl` for Refusal).

* `partition_nondegenerate_iff_kernel_ordinary` — the four cells of
  the partition at `Y` admit subobject witnesses **iff** the kernel
  image is an ordinary element of `Sub(D Y)`.  This is the framework's
  non-degeneracy criterion transported to the topos register: the
  interpretive lens has all four positions available at `Y` exactly
  when the kernel is ordinary there.

* `kernel_ordinary_of_cells_occupied` — if all four cells are
  actually occupied by morphisms at `Y`, the kernel image is ordinary.

* `ordinary_kernel_div12_embedding` — an ordinary kernel forces the
  six-element lattice `Div12 ≅ Z₆` (the divisor lattice of 12, the
  pitch-class-set universe) to order-embed into `Sub(D Y)`, kernel to
  the tritone slot.

* `cells_occupied_div12_embedding` — the composite unification
  statement: four occupied positions at `Y` force the Z₆ figure inside
  the subobject lattice at `Y`.

## Why this matters for the framework

Before this file, the ordinary-elements paper's theorems (uniqueness,
threshold, embedding) were results about abstract Heyting algebras, and
the partition theorem was a result about distinction structures, and
the connection between them was prose.  After this file the chain

> distinction structure → four-position partition → non-degeneracy
> ↔ ordinary kernel → Z₆ order-embedded

is kernel-checked end to end.  Everything proved about ordinary
elements is now, formally, a statement about the kernels of the
interpretive lens.

## Cross-reference

* `Positions/Partition.lean` — the partition theorem (Theorem 0).
* `Positions/SpencerBrown.lean` — the Boolean collapse
  (`boolean_partition_three_cells`): when crossing holds, Exploitation
  is uninhabited, which via this file's bridge is the statement that a
  Boolean kernel is never ordinary.
* `Examples/NishimuraKernelLaw.lean` — `isOrdinary_iff_allFourCells`,
  the lattice-level non-degeneracy criterion.
* `Examples/LadderCore.lean` — `div12OrderEmbedding`.
* `preprints/ordinary-elements-z6/paper.md` — the ordinary-elements
  structure theory this bridge imports into the topos register.
-/

import FalseWorkPapers.Positions.Partition
import FalseWorkPapers.Examples.NishimuraKernelLaw
import FalseWorkPapers.Examples.LadderCore

namespace FalseWork.Positions

open CategoryTheory CategoryTheory.Limits FalseWork.Lattice

universe v u

variable {C : Type u} [Category.{v} C]
  [HasImages C] [HasPullbacks C] [HasSubobjectClassifier C]
  [HasEqualizers C] [HasInitial C] [HasBinaryCoproducts C] [InitialMonoClass C]

/-! ## 1. Cell translation: morphism predicates = lattice predicates -/

/-- Morphism-level Infrastructure is lattice-level Infrastructure at the
image subobject, relative to the kernel image. -/
theorem isInfrastructure_iff_lattice (Δ : DistinctionStructure C)
    {X Y : C} (f : X ⟶ Y) :
    IsInfrastructure Δ f ↔
      IsLatticeInfrastructure (kernelImage Δ Y)
        (Subobject.mk (image.ι (Δ.D.map f))) :=
  Iff.rfl

/-- Morphism-level Distribution is lattice-level Distribution at the
image subobject, relative to the kernel image. -/
theorem isDistribution_iff_lattice (Δ : DistinctionStructure C)
    {X Y : C} (f : X ⟶ Y) :
    IsDistribution Δ f ↔
      IsLatticeDistribution (kernelImage Δ Y)
        (Subobject.mk (image.ι (Δ.D.map f))) :=
  Iff.rfl

/-- Morphism-level Exploitation is lattice-level Exploitation at the
image subobject, relative to the kernel image. -/
theorem isExploitation_iff_lattice (Δ : DistinctionStructure C)
    {X Y : C} (f : X ⟶ Y) :
    IsExploitation Δ f ↔
      IsLatticeExploitation (kernelImage Δ Y)
        (Subobject.mk (image.ι (Δ.D.map f))) :=
  Iff.rfl

/-- Morphism-level Refusal is lattice-level Refusal at the image
subobject, relative to the kernel image.  (The morphism-level predicate
is a factorization through the complement subobject; the equivalence
with the containment form is `isRefusal_iff_image_le_compl`.) -/
theorem isRefusal_iff_lattice (Δ : DistinctionStructure C)
    {X Y : C} (f : X ⟶ Y) :
    IsRefusal Δ f ↔
      IsLatticeRefusal (kernelImage Δ Y)
        (Subobject.mk (image.ι (Δ.D.map f))) :=
  isRefusal_iff_image_le_compl Δ f

/-! ## 2. The bridge theorem -/

/-- **Partition non-degeneracy = ordinary kernel.**  The four cells of
the four-position partition at `Y` all admit subobject witnesses iff
the kernel image at `Y` is an ordinary element (neither regular nor
dense) of the Heyting algebra `Sub(D Y)`.

This is `isOrdinary_iff_allFourCells` instantiated at
`H := Subobject (D Y)`, `a := kernelImage Δ Y` — the instantiation is
possible because `FalseWork.Heyting.heytingAlgebra` provides the
Heyting structure on subobject lattices of a topos.  The content:
the interpretive lens's four positions are simultaneously available
at `Y` exactly when the kernel is ordinary there, so the entire
ordinary-elements structure theory applies to the lens's kernels. -/
theorem partition_nondegenerate_iff_kernel_ordinary
    (Δ : DistinctionStructure C) (Y : C) :
    AllFourCellsInhabited (kernelImage Δ Y) ↔ IsOrdinary (kernelImage Δ Y) :=
  (isOrdinary_iff_allFourCells (kernelImage Δ Y)).symm

/-! ## 3. From occupied cells to the ordinary kernel -/

/-- **Occupied cells force an ordinary kernel.**  If at `Y` all four
positions are actually occupied by morphisms — with non-trivial images
in the Infrastructure and Refusal cases, where triviality would satisfy
the containments vacuously — then the kernel image at `Y` is an
ordinary element of `Sub(D Y)`.

(The Distribution and Exploitation predicates force non-triviality by
themselves: a `⊥` image cannot meet the kernel non-trivially, nor fail
a containment.) -/
theorem kernel_ordinary_of_cells_occupied (Δ : DistinctionStructure C)
    {Y : C}
    (hI : ∃ (X : C) (f : X ⟶ Y),
      Subobject.mk (image.ι (Δ.D.map f)) ≠ ⊥ ∧ IsInfrastructure Δ f)
    (hD : ∃ (X : C) (f : X ⟶ Y), IsDistribution Δ f)
    (hE : ∃ (X : C) (f : X ⟶ Y), IsExploitation Δ f)
    (hR : ∃ (X : C) (f : X ⟶ Y),
      Subobject.mk (image.ι (Δ.D.map f)) ≠ ⊥ ∧ IsRefusal Δ f) :
    IsOrdinary (kernelImage Δ Y) := by
  rw [isOrdinary_iff_allFourCells]
  obtain ⟨XI, fI, hI0, hIc⟩ := hI
  obtain ⟨XD, fD, hDc⟩ := hD
  obtain ⟨XE, fE, hEc⟩ := hE
  obtain ⟨XR, fR, hR0, hRc⟩ := hR
  exact ⟨⟨_, hI0, (isInfrastructure_iff_lattice Δ fI).mp hIc⟩,
    ⟨_, (isDistribution_iff_lattice Δ fD).mp hDc⟩,
    ⟨_, (isExploitation_iff_lattice Δ fE).mp hEc⟩,
    ⟨_, hR0, (isRefusal_iff_lattice Δ fR).mp hRc⟩⟩

/-! ## 4. The Z₆ import: ordinary kernels carry the six-element figure -/

/-- **An ordinary kernel forces Z₆ into the subobject lattice.**  If the
kernel image at `Y` is ordinary, the six-element lattice `Div12 ≅ Z₆`
(the divisor lattice of 12; equivalently the subgroup lattice of
`ℤ/12ℤ`, the transposition-symmetric pitch-class sets) order-embeds
into `Sub(D Y)`, with the kernel image in the tritone slot.

This transports Theorem 4.2 of the ordinary-elements paper
(`div12OrderEmbedding`) to the topos register. -/
theorem ordinary_kernel_div12_embedding (Δ : DistinctionStructure C)
    {Y : C} (h : IsOrdinary (kernelImage Δ Y)) :
    Nonempty (Examples.Div12 ↪o Subobject (Δ.D.obj Y)) :=
  ⟨div12OrderEmbedding h⟩

/-- **Unification.**  If all four positions are occupied by morphisms at
`Y`, then the six-element figure Z₆ order-embeds into the subobject
lattice at `Y`.  Composite of `kernel_ordinary_of_cells_occupied` and
`ordinary_kernel_div12_embedding`: the chain

> occupied positions → ordinary kernel → Z₆ inside the lens

is kernel-checked end to end. -/
theorem cells_occupied_div12_embedding (Δ : DistinctionStructure C)
    {Y : C}
    (hI : ∃ (X : C) (f : X ⟶ Y),
      Subobject.mk (image.ι (Δ.D.map f)) ≠ ⊥ ∧ IsInfrastructure Δ f)
    (hD : ∃ (X : C) (f : X ⟶ Y), IsDistribution Δ f)
    (hE : ∃ (X : C) (f : X ⟶ Y), IsExploitation Δ f)
    (hR : ∃ (X : C) (f : X ⟶ Y),
      Subobject.mk (image.ι (Δ.D.map f)) ≠ ⊥ ∧ IsRefusal Δ f) :
    Nonempty (Examples.Div12 ↪o Subobject (Δ.D.obj Y)) :=
  ordinary_kernel_div12_embedding Δ
    (kernel_ordinary_of_cells_occupied Δ hI hD hE hR)

/-! ## Status

All theorems in this file are total (no `sorry`); the mathematical
content is inherited from the two stacks being bridged — the file's
contribution is the *identification* of the two vocabularies, which
is exactly what makes the ordinary-elements structure theory a formal
foundation for the interpretive lens rather than an analogy to it.
-/

end FalseWork.Positions
