/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink
-/
import FalseWorkPapers.Heyting.SubobjectInstance
import FalseWorkPapers.Positions
import FalseWorkPapers.Lattice.FourPositionLattice
import FalseWorkPapers.Examples.CanonizationGeneratorInstance
import FalseWorkPapers.Examples.DivisorLattice12
import FalseWorkPapers.Examples.DivisorLattice12Distinction
import FalseWorkPapers.Examples.DivisorLattice12Birkhoff
import FalseWorkPapers.Examples.DivisorLattice12Nucleus
import FalseWorkPapers.Examples.DiophantineFloor
import FalseWorkPapers.Examples.MathFloorCantor
import FalseWorkPapers.Examples.NishimuraTruncations
import FalseWorkPapers.Examples.MusicKernelZMod12
import FalseWorkPapers.Examples.MusicTopos
import FalseWorkPapers.Examples.MusicToposSub
import FalseWorkPapers.Examples.MusicToposTrace

/-!
# Sanity-check examples for `FalseWork.Heyting.heytingAlgebra`

This file is a smoke test for the universal `HeytingAlgebra (Subobject X)`
instance constructed in `FalseWorkPapers.Heyting.SubobjectInstance`.  It
contains no theorems used elsewhere in the project; its sole purpose is to
exhibit that Lean's typeclass resolution finds the instance and that the
constructed implication behaves Heyting-correctly, giving a
reader/reviewer immediate confidence that the construction is wired right.

Phase 4 prep for the upstream Mathlib PR (`MATHLIB-PR-DRAFT.md`).  A
concrete-topos instantiation (`PUnitᵒᵖ ⥤ Type`) was attempted here but is
blocked by a universe / `InitialMonoClass` resolution gap in Mathlib's
presheaf-category instances (not a problem with our construction — the
universal instance resolves cleanly the moment the bundle is in scope).
That gap is the kind of plumbing issue the upstream PR review will surface
naturally; for now, the abstract examples below are sufficient to verify
that the instance exists and that its Galois behaviour is the expected one.
-/

namespace FalseWork.Heyting.Examples

open CategoryTheory CategoryTheory.Limits

/-- Smoke test 1.  Under the elementary-topos hypothesis bundle, the
Heyting-algebra instance on `Subobject X` resolves via typeclass search. -/
noncomputable example {C : Type*} [Category C]
    [HasSubobjectClassifier C] [HasPullbacks C] [HasEqualizers C]
    [HasInitial C] [HasImages C] [HasBinaryCoproducts C]
    [InitialMonoClass C] {X : C} :
    HeytingAlgebra (Subobject X) := inferInstance

/-- Smoke test 2.  The Galois connection holds (a direct consumer of the
typeclass: `le_himp_iff`). -/
example {C : Type*} [Category C]
    [HasSubobjectClassifier C] [HasPullbacks C] [HasEqualizers C]
    [HasInitial C] [HasImages C] [HasBinaryCoproducts C]
    [InitialMonoClass C] {X : C} (P Q : Subobject X) :
    (P ⇨ Q) ⊓ P ≤ Q := by
  rw [← le_himp_iff]

/-- Smoke test 3.  The pseudo-complement is the residual against `⊥`
(definitionally — `himp_bot := rfl` in the instance). -/
example {C : Type*} [Category C]
    [HasSubobjectClassifier C] [HasPullbacks C] [HasEqualizers C]
    [HasInitial C] [HasImages C] [HasBinaryCoproducts C]
    [InitialMonoClass C] {X : C} (P : Subobject X) :
    Pᶜ = P ⇨ ⊥ := rfl

/-- Smoke test 4.  De Morgan and `aᶜᶜ`-style consequences fall out from the
typeclass without further hypotheses. -/
example {C : Type*} [Category C]
    [HasSubobjectClassifier C] [HasPullbacks C] [HasEqualizers C]
    [HasInitial C] [HasImages C] [HasBinaryCoproducts C]
    [InitialMonoClass C] {X : C} (P : Subobject X) :
    P ≤ Pᶜᶜ := le_compl_compl

end FalseWork.Heyting.Examples

/-! ## Kernel-axiomatic-dependence audit

Empirical verification that `four_position_partition` does not
transitively depend on `sorry`.  `#print axioms` exposes the full
axiom set the Lean kernel needs to accept the theorem; if `sorryAx`
appears in the output, the theorem is not kernel-checked in the
strict sense (some link in its dependency chain is `sorry`).

The expected output is exactly the three standard Mathlib axioms
(`propext`, `Classical.choice`, `Quot.sound`).  If `sorryAx` appears,
this audit fails and the four-position-partition status claim must
be retracted.
-/

#print axioms FalseWork.Positions.four_position_partition
#print axioms FalseWork.Positions.isRefusal_iff_image_le_compl
#print axioms FalseWork.Heyting.heytingAlgebra
#print axioms FalseWork.Heyting.le_residual_iff_inf_le
#print axioms FalseWork.Positions.isDistribution_implies_neither_polar
#print axioms FalseWork.Positions.exploitation_refusal_disjoint
#print axioms FalseWork.Positions.trivialized_implies_isInfrastructure
#print axioms FalseWork.Positions.refusal_residue

/-! Spencer-Brown anchor (companion to
`preprints/four-position-partition/spencer-brown-anchor.md`).
Both audit lines must report only the standard three axioms. -/
#print axioms FalseWork.Positions.boolean_partition_three_cells
#print axioms FalseWork.Positions.DistinctionStructure.ofIdempotentMonad

/-! Canonization closure (companion to
`preprints/four-position-partition/closure-canonization.md`).
The conditional recursive partition theorem and the conditional
separation theorem must report only the standard three axioms. -/
#print axioms FalseWork.Positions.recursive_partition
#print axioms FalseWork.Positions.canonization_separation

/-! Concrete instantiation of `CanonizationGenerator`
(companion to `Examples/CanonizationGeneratorInstance.lean`).  The
worked-example witness and its application of `canonization_separation`
must report only the standard three axioms.  These audit lines close
the "concrete instantiation" item from the framework's status ledger;
the structure type is now demonstrably inhabited and the conditional
separation theorem fires on a kernel-checked concrete witness. -/
#print axioms FalseWork.Positions.Examples.DiscretePUnit.canonizationGenerator
#print axioms FalseWork.Positions.Examples.DiscretePUnit.separation_example

/-! Cross-layer alignment (Commitment-yes ⇒ canonization-generator
witness; companion to `preprints/four-position-partition/closure-
canonization.md` §8b).  The conditional cross-layer definition and
its propositional companion must report only the standard three
axioms.  These audit lines close the cross-layer architectural item
from the framework's status ledger: the connection between the
Commitment gate and the canonization closure-and-generator layer is
now formally recorded at the type level. -/
#print axioms FalseWork.Positions.CanonizationGenerator.ofCommitmentYes
#print axioms FalseWork.Positions.commitment_yes_admits_canonization_generator

/-! Layer-L lattice-level four-position partition (companion to
`FalseWorkPapers.Lattice.FourPositionLattice` and
`preprints/four-position-partition/music-anchor/feasibility.md` §12).
The abstract Heyting-algebra theorem and the concrete divisor-lattice-
of-12 music-anchor witness must report only the standard three axioms.
These audit lines close the Layer-L item of the music anchor: the
four-position partition is now kernel-checked at the lattice level
on a Heyting algebra isomorphic to the subgroup lattice of `Z/12`. -/
#print axioms FalseWork.Lattice.lattice_four_position_partition
#print axioms FalseWork.Lattice.Examples.Div12.heytingAlgebra
#print axioms FalseWork.Lattice.Examples.Div12.tritone_non_regular
#print axioms FalseWork.Lattice.Examples.Div12.music_anchor_witness

/-! Layer-D distinction operator and the literal `Z/12` realization
(companion to `Examples/DivisorLattice12Distinction.lean` and
`preprints/four-position-partition/music-anchor/feasibility.md` §12.6).
The closure-operator "distinction slice" — whose kernel image
`tritoneClosure ⊥` is the tritone, de-arbitrarizing the kernel used by
`music_anchor_witness` — and the kernel-checked correspondence between
the six divisor-lattice elements and the six transposition-symmetric
pitch-class subgroups of `Z/12` must report only the standard three
axioms. -/
#print axioms FalseWork.Lattice.Examples.Div12.tritoneClosure_is_distinction_slice
#print axioms FalseWork.Lattice.Examples.Div12.tritoneClosure_bot
#print axioms FalseWork.Lattice.Examples.Div12.tritoneClosure_bot_non_regular
#print axioms FalseWork.Lattice.Examples.Div12.pcset_realizes_subgroup_lattice
#print axioms FalseWork.Lattice.Examples.Div12.pcset_tritoneClosure_bot

/-! Birkhoff representation of the music lattice (companion to
`Examples/DivisorLattice12Birkhoff.lean` and the T2 construction of
`music-anchor/mazzola-bridge-note.md` §5).  The divisor lattice of 12 is
realized as the lattice of down-sets of its poset of join-irreducibles,
i.e. `Sub_{Set^{Pᵒᵖ}}(1)` of a concrete presheaf topos built from the
symmetric pitch-class generators of `Z/12`. -/
#print axioms FalseWork.Lattice.Examples.Div12.birkhoff_representation
#print axioms FalseWork.Lattice.Examples.Div12.birkhoff_tritoneKernel

/-! The tritone kernel as a Lawvere–Tierney topology (companion to
`Examples/DivisorLattice12Nucleus.lean`).  A nucleus on the T2 topos with
the tritone as its non-regular kernel exists; the minimal tritone-closing
closure operator is *not* a nucleus — the reflective vs. geometric lifts
of the same kernel. -/
#print axioms FalseWork.Lattice.Examples.Div12.tritone_kernel_has_lawvere_tierney_realization
#print axioms FalseWork.Lattice.Examples.Div12.tritoneClosure_not_nucleus

/-! The shared Diophantine floor (companion to `Examples/DiophantineFloor.lean`
and Paper 5).  Rank-1 (`√2` irrational) and rank-2 (`2`–`3` multiplicative
independence / the Pythagorean comma) as the two faces of unique
factorization. -/
#print axioms FalseWork.Diophantine.shared_diophantine_floor

/-! The mathematics floor: the diagonal as Level-0 comma (companion to
`Examples/MathFloorCantor.lean`, math anchor Phase 1).  The diagonal residue
(`diagonal_escapes`), Cantor non-surjection (handed over by Mathlib), and the
Lawvere fixed-point unification (Cantor as a fixed-point obstruction) must
report only the standard three axioms.  Structural identification with the
FalseWork comma is prose, not theorem. -/
#print axioms FalseWork.MathFloor.mathematics_floor
#print axioms FalseWork.MathFloor.lawvere_fixedPoint
#print axioms FalseWork.MathFloor.diagonal_escapes

/-! Rieger–Nishimura truncations (companion to
`Examples/NishimuraTruncations.lean`, math anchor Phases 2–4).  The forced-
kernel experiment on the canonical finite truncations `Z_n` of the free
Heyting algebra on one generator, pre-registered in
`validation/claims/math-anchor-cantor-floor.md`.  Result: outcome (A) —
unique truncation-stable kernel = the free generator at `n = 6, 7, 8`, no
kernel at `n = 5`; and `Div12 ≅ Z_6` (the music lattice is one-generated by
the tritone).  All lines must report only the standard axioms. -/
#print axioms FalseWork.Lattice.Examples.rn_truncation_outcome_A
#print axioms FalseWork.Lattice.Examples.Div12.one_generated_by_tritone
#print axioms FalseWork.Lattice.Examples.Div12.kernel_unique
#print axioms FalseWork.Lattice.Examples.Z7.kernel_unique
#print axioms FalseWork.Lattice.Examples.Z7.witness
#print axioms FalseWork.Lattice.Examples.Z8.kernel_unique
#print axioms FalseWork.Lattice.Examples.Z8.witness
#print axioms FalseWork.Lattice.Examples.Z5.no_kernel

/-! The music kernel "The Fifth" on `ℤ/12` (companion to
`Examples/MusicKernelZMod12.lean` and `music-kernel-05-z12z-cycle.md`).
The circle of fifths closes in the tempered quotient — the complement of
the rank-2 Diophantine non-closure. -/
#print axioms FalseWork.MusicKernel.fifth_closes_in_quotient

/-! The music presheaf topos `Set^{Pᵒᵖ}` as a concrete Lean elementary-topos
object (companion to `Examples/MusicTopos.lean` and the T2 construction of
`music-anchor/mazzola-bridge-note.md` §5 / `connecting-the-spine.md` §5.1).
The previously-deferred "topos-object plumbing": the full elementary-topos
hypothesis bundle resolves for the concrete music-derived presheaf topos, so
`Sub_{Set^{Pᵒᵖ}}(1)` is a Heyting algebra and the central theorem
`four_position_partition` fires against the concrete topos object (over the
trivial distinction — the non-degenerate musical partition is the
lattice-level theorem). -/
#print axioms FalseWork.Lattice.Examples.Div12.musicTopos_isElementaryTopos
#print axioms FalseWork.Lattice.Examples.Div12.subTerminalHeytingAlgebra
#print axioms FalseWork.Lattice.Examples.Div12.four_position_partition_musicTopos

/-! `Sub_{Set^{Pᵒᵖ}}(1) ≅ Div12` as a Mathlib-level order isomorphism
(companion to `Examples/MusicToposSub.lean`).  This upgrades
`birkhoff_representation` from the down-set level `O(P)` to an isomorphism of
the actual `Subobject` lattice of the terminal object of the concrete music
topos, mapping the subobject lattice cells onto the named pitch-class objects of
`Div12`.  Item (i) of `connecting-the-spine.md` §5.1a. -/
#print axioms FalseWork.Lattice.Examples.Div12.subobjectTerminalEquivDiv12
#print axioms FalseWork.Lattice.Examples.Div12.fromDownset_birkhoff

/-! The topos-level **trace-collapse** result (companion to
`Examples/MusicToposTrace.lean`).  The four-position kernel `kernelImage Δ Y` is
`Im(η.app Y)`; an iso unit forces it to `⊤`.  Since the terminal presheaf is a
sheaf for every topology, every sheafification monad has iso unit at `1`, so the
tritone nucleus (`⟨6⟩ ≠ ⊤`) does *not* lift to `kernelImage Δ 1` — the
lattice-level nucleus and the topos-level `Im(η)` kernel come apart at `1`.
Item (ii) of `connecting-the-spine.md` §5.1a, resolved as a category error in
the naïve form (the non-degenerate tritone partition stays lattice-level). -/
#print axioms FalseWork.Positions.kernelImage_eq_top_of_isIso_unit
#print axioms FalseWork.Positions.isInfrastructure_of_isIso_unit
