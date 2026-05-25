/-
Copyright (c) 2026 Chris Brink.
Released under the same license as the rest of the FalseWork Papers.

Authors: Chris Brink (FalseWork)

# Concrete instantiation of the CanonizationGenerator structure

This file provides a first kernel-checked example of a
`CanonizationGenerator` witness, demonstrating that the closure-and-
generator framework's structure types are inhabited and that the
conditional separation theorem fires concretely.

The example here is deliberately minimal: it uses the identity monad
on a category `C` as both the underlying `Δ` and the canonization
closure, and instantiates the construction in the discrete category
over `PUnit` (one object, one morphism), where the separator
condition holds vacuously because every hom-set is a `Subsingleton`.

The point of this file is **not** to exhibit a structurally
interesting canonization figure — that is the substantive
empirical/historical work the framework defers to future iterations
(M-set construction, presheaf topos, or domain-specific
instantiation). The point is to **establish kernel-checked
existence**: the canonization-generator structure is inhabited, the
conditional separation theorem fires on a concrete instance, and the
framework's canonization apparatus escapes interpretive-only status
by exhibiting at least one example the Lean kernel verifies.

## What this file provides

* `idCanonizationGenerator` — a generic constructor producing a
  `CanonizationGenerator` from the identity monad on any category
  `C`, given any morphism `f : X ⟶ Y` and a proof that `Y` is a
  separator for `C`. Both the underlying distinction structure
  (via `DistinctionStructure.ofIdempotentMonad`) and the
  canonization closure use the identity monad.

* `Discrete.PUnit.canonizationGenerator` — a concrete instance of
  the above for `C = Discrete PUnit`, `Y = star`, `f = 𝟙 star`. The
  separator condition is discharged by `Subsingleton` (every hom-set
  in a discrete category is a subsingleton).

* `Discrete.PUnit.separation_example` — an example application of
  `canonization_separation` to the concrete instance, deriving a
  specific equality.

## What this file does NOT provide

* A canonization figure in a topos with structurally interesting
  content. The framework's empirical claims (Bach, Coltrane,
  Schoenberg) translate into specific constructions on specific
  topos models (presheaf categories, M-sets, or domain-specific
  models); these are deferred as substantive future work.

* An application of `recursive_partition` to the concrete instance.
  That theorem requires the full topos plumbing
  (`HasSubobjectClassifier`, `HasInitial`, `HasBinaryCoproducts`,
  etc.) which `Discrete PUnit` does not satisfy. The closure
  structure inhabits the type; the recursive partition theorem
  requires a richer setting to fire concretely. A richer example
  category satisfying the partition theorem's hypothesis bundle is
  the natural next step.

## Cross-reference

* `preprints/four-position-partition/closure-canonization.md` §10 —
  documents this instantiation level explicitly as the minimum
  kernel-checked existence demonstration.
* `Positions/CanonizationClosure.lean` — the `CanonizationGenerator`
  structure being instantiated.
* `Positions/SpencerBrown.lean` —
  `DistinctionStructure.ofIdempotentMonad`, used internally.
-/

import FalseWorkPapers.Positions.CanonizationClosure
import Mathlib.CategoryTheory.Discrete.Basic
import Mathlib.CategoryTheory.Monad.Basic

namespace FalseWork.Positions.Examples

open CategoryTheory CategoryTheory.Limits

universe v u

/-! ## Abstract construction -/

/-- The identity monad has an invertible multiplication: `μ = 𝟙 (𝟭 C)`,
which is trivially an iso. This instance is needed by
`DistinctionStructure.ofIdempotentMonad` and by the `CanonizationClosure`
field `μ_iso`. -/
instance idMonad_μ_isIso (C : Type u) [Category.{v} C] :
    IsIso (Monad.id C).μ := by
  show IsIso (𝟙 (𝟭 C))
  exact IsIso.id _

/-- The trivial distinction structure on any category `C`, induced by
the identity monad via `DistinctionStructure.ofIdempotentMonad`.

This `Δ` has `D = 𝟭 C`, `η = identity natural transformation`, and
`ι.hom = identity`. The four-position partition (when applied via
`recursive_partition` in a topos setting) becomes degenerate over
this `Δ`: every morphism with non-trivial image is `IsInfrastructure`
because `image(D.map f) = image(f) ≤ ⊤ = kernelImage Δ Y`. The
canonization-generator structure inhabits the type regardless. -/
noncomputable def trivialDistinction (C : Type u) [Category.{v} C] :
    DistinctionStructure C :=
  DistinctionStructure.ofIdempotentMonad (Monad.id C)

/-- A *generic identity-monad canonization-generator witness*: in any
category `C`, the identity monad gives a canonization-closure witness
for any morphism `f`. Adding a separator condition on `Y` lifts this
to a `CanonizationGenerator`.

The induced distinction structure is `trivialDistinction C`. The
canonization closure is the identity monad. The separator condition
is taken as a hypothesis.

This constructor is honestly trivial — every category admits this
witness for every morphism with a separator codomain. Its purpose is
establishing inhabitation of the structure type, not exhibiting
substantive framework content. -/
noncomputable def idCanonizationGenerator
    (C : Type u) [Category.{v} C]
    {X Y : C} (f : X ⟶ Y)
    (h_sep : ∀ {A B : C} (g₁ g₂ : A ⟶ B),
      (∀ h : Y ⟶ A, h ≫ g₁ = h ≫ g₂) → g₁ = g₂) :
    CanonizationGenerator (trivialDistinction C) f where
  T := Monad.id C
  μ_iso := idMonad_μ_isIso C
  isSeparator := h_sep

/-! ## Concrete instance: Discrete PUnit -/

namespace DiscretePUnit

/-- The unique object of `Discrete PUnit`, our test canonization
codomain. In a discrete category over a singleton, this is the
*only* object. -/
abbrev star : Discrete PUnit := ⟨PUnit.unit⟩

/-- The identity morphism on `star`, our test canonization figure. -/
abbrev starId : star ⟶ star := 𝟙 star

/-- In a discrete category every hom-set is a `Subsingleton`, so any
parallel morphisms are equal. The separator condition therefore holds
vacuously for any chosen object `Y` (and in particular for `star`).

This is the key step that makes the concrete instantiation
kernel-checkable without further plumbing: the separator hypothesis,
which is the non-trivial input of `idCanonizationGenerator`, is
discharged by `Subsingleton` of `Discrete` hom-sets. -/
theorem star_isSeparator :
    ∀ {A B : Discrete PUnit} (g₁ g₂ : A ⟶ B),
      (∀ _h : star ⟶ A, _h ≫ g₁ = _h ≫ g₂) → g₁ = g₂ := by
  intro A B g₁ g₂ _
  exact Subsingleton.elim _ _

/-- The concrete `CanonizationGenerator` witness in `Discrete PUnit`.
Uses the identity monad as both the underlying distinction structure
and the canonization closure; the separator condition is discharged
by `star_isSeparator`.

This is the framework's first kernel-checked canonization-generator
witness. It demonstrates that the structure type is inhabited and
that `canonization_separation` fires concretely. It is structurally
trivial (every category satisfies it) but it establishes existence
unambiguously. -/
noncomputable def canonizationGenerator :
    CanonizationGenerator (trivialDistinction (Discrete PUnit)) starId :=
  idCanonizationGenerator (Discrete PUnit) starId star_isSeparator

/-- Example application of `canonization_separation` to the concrete
witness. The conclusion is a specific equality of parallel morphisms
in `Discrete PUnit` derived from the agreement-under-star-composition
hypothesis.

The kernel verifies this as a concrete derivation rather than a
conditional theorem. Together with `canonizationGenerator`, this
example demonstrates that the framework's closure-and-generator
layer is non-vacuously formalized: the structure type has at least
one inhabitant, and the conditional theorem fires on that
inhabitant. -/
theorem separation_example
    {A B : Discrete PUnit} (g₁ g₂ : A ⟶ B)
    (h : ∀ k : star ⟶ A, k ≫ g₁ = k ≫ g₂) :
    g₁ = g₂ :=
  canonization_separation canonizationGenerator g₁ g₂ h

end DiscretePUnit

/-! ## Status

DONE (kernel-checkable in this file):
* `idMonad_μ_isIso` — the identity monad has an invertible
  multiplication.
* `trivialDistinction` — the distinction structure from the identity
  monad on any category.
* `idCanonizationGenerator` — the generic constructor: identity
  monad + separator hypothesis → `CanonizationGenerator`.
* `DiscretePUnit.star_isSeparator` — separator condition in
  `Discrete PUnit` discharged via `Subsingleton`.
* `DiscretePUnit.canonizationGenerator` — the concrete witness.
* `DiscretePUnit.separation_example` — `canonization_separation`
  fires concretely on the witness.

NOT IN THIS FILE (structurally interesting examples):
* M-set instantiation: build a non-trivial idempotent monad on
  `M-Set` for a chosen monoid `M` and exhibit a `CanonizationGenerator`
  for a chosen morphism. This would be a more substantive example,
  closer in spirit to Phase 1.2 of the non-vacuity work
  (`preprints/four-position-partition/examples/phase-1-2-progress.md`).
* Presheaf instantiation: build a `CanonizationGenerator` in a
  presheaf topos over a small base. Has the advantage of supporting
  the full topos plumbing for `recursive_partition` as well.
* Domain-specific instantiation: any of the framework's empirical
  canonization figures (Bach, Coltrane, Schoenberg) lifted to a
  formal topos model with a verified separator condition. This is
  substantial historical-cum-mathematical work and is the natural
  conclusion of the canonization formalization track.

WHY THE TRIVIAL EXAMPLE IS HONEST:
The example is structurally trivial — `Discrete PUnit` has one
object and one morphism, and the identity monad on it carries no
structural content. The example does *not* show the framework is
non-vacuous in any deep sense; it shows the *structure type* is
inhabited, which is what kernel-checked existence requires. The
deeper non-vacuity (four cells inhabited by a single distinction
structure) is the subject of Phase 1.2 work and remains open under
the structural obstruction documented in
`preprints/four-position-partition/examples/phase-1-2-progress.md`.

This file therefore closes one open item from the framework's
status ledger (concrete instantiation of `CanonizationGenerator`)
without closing the deeper non-vacuity question (which is open in a
different sense — the *partition theorem's* four-cell non-vacuity).
The two are independent.
-/

end FalseWork.Positions.Examples
