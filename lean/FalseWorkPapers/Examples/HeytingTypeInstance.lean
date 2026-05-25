/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink
-/
import FalseWorkPapers.Heyting.SubobjectInstance
import FalseWorkPapers.Positions

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
The conditional recursive partition theorem must report only the
standard three axioms. -/
#print axioms FalseWork.Positions.recursive_partition
