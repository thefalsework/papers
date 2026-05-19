/-
Copyright (c) 2026 Chris Brink.
Released under the same license as the rest of the FalseWork Papers.

Authors: Chris Brink (FalseWork)

# Infrastructure: the kernel's marking activity does not exceed its native ground

A morphism `f : X ⟶ Y` is in *Infrastructure position* relative to a
kernel `D` when the image of `D.map f` lies entirely within the kernel
image at `Y`. The work's marking activity does not exceed what `η`
already produces — the practitioner operates inside the kernel's
native ground.

The earlier predicate `IsIso (η.app X) ∧ IsIso (η.app Y)` (endpoint
trivialization) was retired on 2026-05-17 because it would have left
an exhaustiveness hole in the four-position partition theorem: any
work whose image stays in `Im(η)` *without* the endpoints being
trivialized would have failed to land in Infrastructure under the
old predicate, breaking the partition's "exactly one cell" claim.
Endpoint trivialization survives here as a *sufficient sub-condition*
(`Trivialized` below); it is a special case where the kernel is
transparent at the work's endpoints.

## Empirical correspondences

* **Bach, *Well-Tempered Clavier* within a single key.** The
  temperament system has already absorbed the Pythagorean comma into
  the operating apparatus. Within one key (no modulation), the work's
  harmonic content stays in the kernel's native ground.

* **Raphael, *The School of Athens* (1509–1511).** The marking
  operation is fully active — every brushstroke deposits pigment AND
  constructs illusionistic space — but Renaissance convention
  conceals the comma so completely that the viewer sees only
  philosophical space, never paint on plaster. The work's image
  under `D` stays in the kernel's native ground.

* **Classical Hollywood continuity editing inside an established
  genre.** The cut's discontinuity has been managed by inherited
  Hollywood grammar; the work's image under `D` stays in the kernel
  image.

* **Kurosawa, *Stray Dog* / *Seven Samurai* / *Ran* — Deep
  Infrastructure.** Sophisticated structural work *above* a
  transparent kernel (serial economic descent, durational debt,
  multi-register constriction operating on top of continuity
  editing). The cell-level classification is Infrastructure; the
  level-stratified refinement *Deep Infrastructure* is sketched
  below but requires a level fibration of `C` that is not yet
  implemented.

## Cross-reference

* Paper 1 §3.4 — Infrastructure as the first of four cells
* `papers/comma-formal-structure-note.md` §5 — image-subobject
  predicate (current) and endpoint-iso predicate (retired sufficient
  condition)
* `papers/comma-formal-structure-note.md` §6 Theorem 0 — the
  four-position partition theorem this predicate participates in
* `validation/claims/five-position-derivation-formalization.md` —
  open theorem this file targets
-/

import FalseWorkPapers.Positions.Setup

namespace FalseWork.Positions

open CategoryTheory CategoryTheory.Limits

universe v u

variable {C : Type u} [Category.{v} C]
  [HasImages C] [HasPullbacks C]

/-! ## The Infrastructure position -/

/-- A morphism `f : X ⟶ Y` is in *Infrastructure position* relative to
the distinction `Δ` when the image of `D.map f` (as a subobject of
`D Y`) lies within the kernel image at `Y`. The work's marking
activity does not exceed the kernel's native ground.

This is the cell predicate that participates in the four-position
partition (`Partition.lean`, Theorem 0). It is propositional-shape
`img ≤ k`, dual to Refusal's `img ≤ kᶜ`. -/
noncomputable def IsInfrastructure (Δ : DistinctionStructure C)
    {X Y : C} (f : X ⟶ Y) : Prop :=
  Subobject.mk (image.ι (Δ.D.map f)) ≤ kernelImage Δ Y

/-! ## Endpoint trivialization as a sufficient sub-condition -/

/-- A morphism `f` is *endpoint-trivialized* by `Δ` when `η` is an
isomorphism at both endpoints. This is the original (retired)
candidate Infrastructure predicate. It survives here as a sufficient
sub-condition: endpoint trivialization implies `IsInfrastructure`,
but the converse fails — works can stay in the kernel image without
the kernel being transparent at the endpoints. -/
def Trivialized (Δ : DistinctionStructure C) {X Y : C} (f : X ⟶ Y) :
    Prop :=
  IsIso (Δ.η.app X) ∧ IsIso (Δ.η.app Y)

/-- **Endpoint trivialization implies Infrastructure.**

When `η.app Y` is an isomorphism, the image of `η.app Y` is the
maximal subobject of `D Y`, so `kernelImage Δ Y = ⊤`. The image-
subobject condition `img ≤ ⊤` then holds by `le_top` for any `f`.
(Endpoint trivialization at `X` is unused for this direction; it
carries content for the stronger pointwise-`D` claim recorded in
`trivialized_iff_D_pointwise` below.) -/
theorem trivialized_implies_isInfrastructure
    (Δ : DistinctionStructure C) {X Y : C} (f : X ⟶ Y)
    (hf : Trivialized Δ f) :
    IsInfrastructure Δ f := by
  unfold IsInfrastructure
  have hY : IsIso (Δ.η.app Y) := hf.2
  -- Strategy: show `kernelImage Δ Y = ⊤`, then conclude by `le_top`.
  -- `kernelImage Δ Y = Subobject.mk (image.ι (Δ.η.app Y))`.
  -- When `Δ.η.app Y` is iso, `image.ι (Δ.η.app Y)` is iso (image of
  -- an iso is its source, up to iso), so `Subobject.mk` of it is `⊤`.
  suffices h : kernelImage Δ Y = ⊤ by
    rw [h]; exact le_top
  unfold kernelImage
  -- The remaining step needs the Mathlib lemma chain
  --   IsIso (η.app Y) → IsIso (image.ι (η.app Y)) → Subobject.mk _ = ⊤
  -- The first arrow is `image.isIso_of_isIso` (or similar); the second
  -- is `Subobject.mk_eq_top_iff_isIso`. Lemma names tentative; see
  -- the open question in the status section.
  sorry

/-! ## Signature lemma: under endpoint trivialization, D acts pointwise -/

/-- **Pointwise-`D` signature under endpoint trivialization.** When
`f` is endpoint-trivialized, `D.map f` is determined by `f` via the
unit's iso components: `D.map f = (η.app X)⁻¹ ≫ f ≫ η.app Y` modulo
the canonical iso, so no information beyond `f` is created or
destroyed by `D` at this `f`. This is the categorical content of
"the kernel is transparent at the work's endpoints." -/
theorem trivialized_iff_D_pointwise
    (Δ : DistinctionStructure C) {X Y : C} (f : X ⟶ Y) :
    Trivialized Δ f ↔
      IsIso (Δ.η.app X) ∧ IsIso (Δ.η.app Y) ∧
      Δ.η.app X ≫ Δ.D.map f = f ≫ Δ.η.app Y := by
  -- The third conjunct is the naturality square at `f`. Combined with
  -- the IsIso witnesses, this is equivalent to the inv-form
  -- `Δ.D.map f = inv (Δ.η.app X) ≫ f ≫ Δ.η.app Y`, but stating it in
  -- naturality form avoids needing `IsIso` in the type signature
  -- itself (which would be circular — the IsIso is asserted alongside).
  -- `Δ.η.naturality f` gives `f ≫ η.app Y = η.app X ≫ D.map f`;
  -- the third conjunct is its `.symm`. Both directions reduce to
  -- pairing the IsIso witnesses with this naturality equation.
  refine ⟨?_, ?_⟩
  · rintro ⟨hX, hY⟩
    exact ⟨hX, hY, (Δ.η.naturality f).symm⟩
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
position at level `k` if it sits at level `k` and is in Infrastructure
position there. The framework reading: Kurosawa's cut-level
continuity is transparent and the work is in Infrastructure at level
0; the serial economic descent at level 1 may engage the kernel
non-trivially (it generates cascading constraints) but does not
change the level-0 classification.

Whether the level-stratified refinement should require *endpoint
trivialization* at level `k` (the strong reading: `D` is genuinely
transparent at the work's level) or just *Infrastructure* at level
`k` (the weak reading: the work's image stays in the kernel ground at
its level) is open framework work. The strong reading is taken below
because it captures the empirical "transparent substrate" intuition;
the weak reading is also defensible. -/
def IsDeepInfrastructure (Δ : DistinctionStructure C) [LevelStructure C]
    (k : LevelStructure.Lvl C) {X Y : C} (f : X ⟶ Y) : Prop :=
  LevelStructure.level X = k ∧ LevelStructure.level Y = k ∧
  Trivialized Δ f

/-! ## Status

DONE:
* `IsInfrastructure` definition reframed as image-subobject condition
  (2026-05-17). Participates in the four-position partition without
  exhaustiveness gap.
* `Trivialized` predicate retained as sufficient sub-condition.
* `trivialized_iff_D_pointwise` forward direction proven
  (2026-05-17) via `NatTrans.naturality` and `IsIso.inv_hom_id`.
  Proof is a four-step `calc`; lemma names verified against Mathlib
  conventions but not yet `lake build`-checked.
* `trivialized_implies_isInfrastructure` — structural proof
  reduced (2026-05-17) to a single `sorry` covering the chain
  `IsIso (η.app Y) → IsIso (image.ι (η.app Y)) → Subobject.mk _ = ⊤`.
  Mathlib lemma names tentative.

REMAINING `sorry`:
* `trivialized_implies_isInfrastructure` — final step: identify
  `Subobject.mk (image.ι (η.app Y))` with `⊤` given that `η.app Y`
  is iso. Mathlib lemmas in play:
  - `image.isIso_of_isIso` (or analogue) — image of an iso has iso `ι`
  - `Subobject.mk_eq_top_iff_isIso` — `Subobject.mk m = ⊤ ↔ IsIso m`
  Both names tentative; verification needed.

OPEN FRAMEWORK QUESTIONS:
* The level structure for Deep Infrastructure is sketched as a class
  `LevelStructure C` but not actually constructed. Two paths forward:
  (a) require `C` to be fibered over `ℕ` with a specific structure
      that the framework specifies per-domain, or
  (b) work in a 2-categorical setting where levels are intrinsic.
  Path (a) is more concrete; path (b) is more general. Decision is
  framework-level, not Lean-level.

* Whether Deep Infrastructure should require `Trivialized` (current
  definition; strong reading) or `IsInfrastructure` (weak reading) at
  level `k` is open.
-/

end FalseWork.Positions
