/-
Copyright (c) 2026 Chris Brink.
Released under the same license as the rest of the FalseWork Papers.

Authors: Chris Brink (FalseWork)

# Setup for the four-position partition + Commitment gate formalization

Shared definitions used by `Infrastructure.lean`, `Distribution.lean`,
`Exploitation.lean`, `Refusal.lean`, `CommitmentGate.lean`, and
`Partition.lean`.

The files together formalize the framework's structural dictionary in
the topos register described in `papers/comma-formal-structure-note.md`.
The architecture has two layers: a four-position partition over
morphisms (theorem-grade) plus a Commitment gate applied within each
cell (schema-grade). This index in `Positions.lean`; the partition
theorem in `Partition.lean`; the cell predicates in the four
position files.

The "five-position" framing of Paper 1 v11.7 §4 was superseded on
2026-05-10 when the two-parameter-unification exploration in
`MomentRelative.lean` showed that Commitment is best understood as a
binary gate inside each cell rather than a fifth cell of its own.

## What this file provides

* `DistinctionStructure C` — the topos endofunctor `D` with unit `η`
  and Spencer-Brown idempotency, parameterizing the framework's kernel.
* `DistinctionStructure.NonTrivial Δ` — the formal hypothesis that the
  kernel introduces a productive asymmetry. Without this, the four
  cells collapse (Infrastructure becomes the only inhabited cell).
* `kernelImage Δ Y` — the subobject of `D Y` reached by `η.app Y`.
  Operationally, the framework's `Im(η)`.

Each sibling file consumes this setup. The four cell files define a
predicate `IsXxx Δ f` plus a *signature theorem* characterising the
cell. `Partition.lean` states the four-position partition theorem.
`CommitmentGate.lean` documents the gate schema.
-/

import Mathlib.CategoryTheory.Subobject.Classifier.Defs
import Mathlib.CategoryTheory.Subobject.Lattice
import Mathlib.CategoryTheory.Limits.Shapes.Images
import Mathlib.Order.Heyting.Basic
-- The universal `HeytingAlgebra (Subobject Y)` instance is built here.
-- Importing it from `Setup.lean` puts it in scope for every cell file
-- (since every cell imports this module) and supersedes the abstract
-- `[∀ Y, HeytingAlgebra (Subobject Y)]` binder that the cells previously
-- carried as a stopgap for the Mathlib gap (now closed; see
-- `lean/PHASE-0-DECISIONS.md` § "Decision 2 superseded").
import FalseWorkPapers.Heyting.SubobjectInstance

namespace FalseWork.Positions

open CategoryTheory CategoryTheory.Limits

universe v u

variable (C : Type u) [Category.{v} C]

/-! ## Distinction structure -/

/-- A *distinction structure* on a category `C` is an endofunctor `D`
together with a marking unit `η : 𝟭 C ⟶ D` and a Spencer-Brown-style
idempotency witness `D ⋙ D ≅ D`.

Spencer-Brown's *Laws of Form* (1969) gives the calculus of
distinction-marking with two axioms:
* **Calling**: marking twice is the same as marking once (`D ∘ D = D`).
* **Crossing**: marking and unmarking cancel (handled by the unit `η`).

The `coherent` axiom expresses calling at the natural-transformation
level: `η` whiskered through `D` agrees with `D`-mapped `η`. -/
structure DistinctionStructure where
  D : C ⥤ C
  η : 𝟭 C ⟶ D
  idempotent : D ⋙ D ≅ D
  coherent : ∀ X : C,
    η.app (D.obj X) ≫ idempotent.hom.app X = 𝟙 (D.obj X)

namespace DistinctionStructure

variable {C}

/-- A distinction structure is *non-trivial* (`NonTrivial Δ`) when
its unit fails to be a natural iso — equivalently, there is some object
on which the marking morphism is not invertible.

The framework's hypothesis "the kernel introduces an irreducible
productive asymmetry" (Paper 1 v11.7 § 1) is exactly this condition.
Without it the five positions collapse to one (Infrastructure
becomes the only category). -/
def NonTrivial (Δ : DistinctionStructure C) : Prop :=
  ∃ X : C, ¬ IsIso (Δ.η.app X)

end DistinctionStructure

/-! ## Kernel image -/

variable {C} [HasImages C] [HasPullbacks C]

/-- The *kernel image* of `Δ` at `Y` is the subobject of `D Y` cut out
by the marking morphism `η.app Y`.

In the framework's vocabulary this is `Im(η)` at `Y` — the part of the
codomain that the kernel reaches. The five positions are characterised
by their relationship to this subobject (and to its various Heyting
operations: complement, double-complement, joins). -/
noncomputable def kernelImage (Δ : DistinctionStructure C) (Y : C) :
    Subobject (Δ.D.obj Y) :=
  Subobject.mk (image.ι (Δ.η.app Y))

/-! ## Mathlib gap — closed (Phase 2, 2026-05-19)

**Original gap (triaged 2026-05-17).**  Mathlib provides
`SemilatticeInf`, `SemilatticeSup`, and `OrderTop` instances on
`Subobject Y` under the standard limit hypotheses on `C`, but did
not provide a `HeytingAlgebra` instance for the case where `C` is a
topos.  The classical construction is in Mac Lane–Moerdijk Ch. IV.8.

**Closure.**  `lean/FalseWorkPapers/Heyting/SubobjectInstance.lean`
mechanizes the construction in ≈320 lines.  Implication is the
residual `Sub.mk (eq.ι (χ (P ⊓ Q).arrow) (χ P.arrow))`; the Heyting
adjunction `R ≤ (P ⇒ Q) ↔ R ⊓ P ≤ Q` decomposes into six bridging
lemmas (three elimination, three introduction).  The full
construction is committed at `2fed510`.

**Consumption.**  This `Setup.lean` file imports the new module,
so every cell file gets the universal instance in scope
automatically.  Cell files previously carried an abstract
`[∀ Y, HeytingAlgebra (Subobject Y)]` binder as a stopgap (Phase-0
Decision 2); that binder was retired in Phase 3 (2026-05-19) once
Phase 2 closed the underlying gap and the binder's abstractness
became actively counter-productive (it induced an instance diamond
between the binder's Heyting `PartialOrder` and the native
`instPartialOrderSubobject` — see `lean/HEYTING-DIAMOND.md`).
See `lean/PHASE-0-DECISIONS.md` § "Decision 2 superseded" for the
audit trail.

**Cell-file consumers (post-Phase-3).**  `Distribution.lean`,
`Exploitation.lean`, `Refusal.lean`, `Partition.lean` now consume
the universal instance with no Heyting binder.  Their section
variables include `[HasInitial C] [InitialMonoClass C]
[HasBinaryCoproducts C] [HasEqualizers C]` so the instance fires
via typeclass search.  `Infrastructure.lean` and `CommitmentGate.lean`
do not depend on Heyting structure and are unchanged.
-/

end FalseWork.Positions
