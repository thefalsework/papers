/-
Copyright (c) 2026 Chris Brink.
Released under the same license as the rest of the FalseWork Papers.

Authors: Chris Brink (FalseWork)

# Infrastructure: the kernel acts trivially

A morphism `f` is in *Infrastructure position* relative to a kernel `D`
when the marking unit `η` is invertible at both endpoints of `f`. The
distinction makes no difference to `f`; applying `D` to `f` returns `f`
back, up to canonical iso.

## Empirical correspondences

* **Raphael, *The School of Athens* (1509–1511).** The marking operation
  is fully active — every brushstroke deposits pigment AND constructs
  illusionistic space — but Renaissance convention conceals the comma
  so completely that the viewer sees only philosophical space, never
  paint on plaster. `η` acts but is locally invertible at every passage.

* **Coltrane, *A Love Supreme* (1965).** The fifths geometry is present
  everywhere but foregrounded nowhere; modal harmony absorbs the kernel.
  `η` is iso at the harmonic-vocabulary level.

* **Kurosawa, *Stray Dog* (1949) / *Seven Samurai* (1954) / *Ran* (1985).**
  Continuity editing makes the cut transparent; `η` is iso at the
  cut level. *But* Kurosawa is doing sophisticated structural work
  *above* the cut level (serial economic descent, durational debt,
  multi-register constriction). This is **Deep Infrastructure** — the
  kernel is transparent at level `k`, but additional structure exists
  at level `k+1` that the practitioner builds on top of the inherited
  kernel. The position-typing happens at the level where `η` acts; the
  structural depth above is orthogonal and not part of position
  classification.

The Deep Infrastructure refinement requires a fibration of `C` over a
level-poset, which is sketched but not implemented here.

## Cross-reference

* Paper 1 v11.7 § 4 — Infrastructure as the first of five positions
* `validation/claims/five-position-derivation-formalization.md` —
  open theorem this file targets
-/

import FalseWorkPapers.Positions.Setup

namespace FalseWork.Positions

open CategoryTheory CategoryTheory.Limits

universe v u

variable {C : Type u} [Category.{v} C]

/-! ## The Infrastructure position -/

/-- A morphism `f : X ⟶ Y` is in *Infrastructure position* relative to
the distinction `Δ` when both `η.app X` and `η.app Y` are isomorphisms.

The marking morphism is invertible at `f`'s endpoints, so applying `D`
to `f` produces a morphism canonically conjugate to `f`. The kernel is
operating but transparent. -/
def IsInfrastructure (Δ : DistinctionStructure C) {X Y : C} (f : X ⟶ Y) :
    Prop :=
  IsIso (Δ.η.app X) ∧ IsIso (Δ.η.app Y)

/-! ## Signature theorem: D acts trivially -/

/-- **Infrastructure signature.** When `f` is in Infrastructure
position, `D.map f` is determined by `f` via the unit's iso components:
the obvious square commutes by naturality of `η`, and both vertical
arrows are isos.

Concretely: `D.map f = (η.app X)⁻¹ ≫ f ≫ η.app Y` modulo the canonical
iso, so no information beyond `f` is created or destroyed by `D`. -/
theorem isInfrastructure_iff_D_trivial
    (Δ : DistinctionStructure C) {X Y : C} (f : X ⟶ Y) :
    IsInfrastructure Δ f ↔
      IsIso (Δ.η.app X) ∧ IsIso (Δ.η.app Y) ∧
      Δ.D.map f = inv (Δ.η.app X) ≫ f ≫ Δ.η.app Y := by
  constructor
  · rintro ⟨hX, hY⟩
    refine ⟨hX, hY, ?_⟩
    -- Use naturality of η: η.app Y ∘ f = D.map f ∘ η.app X.
    -- Then: D.map f = D.map f ∘ η.app X ∘ inv (η.app X)
    --              = η.app Y ∘ f ∘ inv (η.app X)
    -- which is what we want, modulo commutativity of the iso
    -- diagram.
    sorry  -- 5–10 lines using `NatTrans.naturality_app` and `IsIso.inv_hom_id`
  · rintro ⟨hX, hY, _⟩
    exact ⟨hX, hY⟩

/-! ## Deep Infrastructure (sketched, level-stratified) -/

/-- A *level structure* on `C` is a fibration `C → Lvl` for some poset
`Lvl`, decomposing `C` into level-strata `C_k`. The framework's claim
is that real fields of practice are stratified — Kurosawa's cinema
operates at the cut level (`k = 0`) and at the higher organizational
level (`k = 1`) of serial spatial logic, durational debt, etc.

This file does *not* construct the level structure; that is a
separate piece of upstream work. The definition below is a *signature*
for what Deep Infrastructure would say once the level structure is in
hand. -/
class LevelStructure (C : Type u) [Category.{v} C] where
  Lvl : Type
  level : C → Lvl
  -- Plus axioms relating `level` to `C`'s structure, which a real
  -- implementation would specify (functoriality, fiber categories,
  -- etc.). Omitted here.

/-- **Deep Infrastructure (sketch).** `f` is in Deep Infrastructure
position at level `k` if `η` is locally trivial at level `k` —
restricting `Δ.η` to the level-`k` stratum gives an iso — *regardless*
of how `Δ.η` behaves at higher levels.

The framework reading: Kurosawa's cut-level continuity is transparent
(`η` iso at level 0), so *Stray Dog* is Infrastructure at level 0; the
serial economic descent at level 1 may be `η`-non-trivial (it
generates real cascading constraints) but does not change the
level-0 classification. -/
def IsDeepInfrastructure (Δ : DistinctionStructure C) [LevelStructure C]
    (k : LevelStructure.Lvl C) {X Y : C} (f : X ⟶ Y) : Prop :=
  LevelStructure.level X = k ∧ LevelStructure.level Y = k ∧
  IsInfrastructure Δ f

/-! ## Status

DONE:
* `IsInfrastructure` definition. Type-checks against current Mathlib.
* Signature theorem statement. The forward direction needs ~10 lines of
  naturality manipulation; the reverse is immediate.

REMAINING `sorry`:
* The `D.map f = inv (η.app X) ≫ f ≫ η.app Y` step in
  `isInfrastructure_iff_D_trivial` is straightforward — naturality of
  `η` plus iso cancellation.

OPEN FRAMEWORK QUESTION:
* The level structure for Deep Infrastructure is sketched as a class
  `LevelStructure C` but not actually constructed. Two paths forward:
  (a) require `C` to be fibered over `ℕ` with a specific structure
      that the framework specifies per-domain, or
  (b) work in a 2-categorical setting where levels are intrinsic.
  Path (a) is more concrete; path (b) is more general. Decision is
  framework-level, not Lean-level.

* Whether Infrastructure should require *both* endpoints to have iso
  `η` (current definition) or just *one* is also open. Both endpoints
  is the strongest condition; one endpoint admits a one-sided
  Infrastructure that the framework may or may not want.
-/

end FalseWork.Positions
