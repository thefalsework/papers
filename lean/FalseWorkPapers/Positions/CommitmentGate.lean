/-
Copyright (c) 2026 Chris Brink.
Released under the same license as the rest of the FalseWork Papers.

Authors: Chris Brink (FalseWork)

# The Commitment gate (schema)

This file replaces the earlier `Commitment.lean` (which treated
Commitment as a fifth cell parallel to Infrastructure, Distribution,
Exploitation, Refusal). Under the 2026-05-10 architectural refinement,
Commitment is a *binary gate* applied within each of the four cells,
not a separate cell.

A morphism `f` classified in cell `P ∈ {Infrastructure, Distribution,
Exploitation, Refusal}` is additionally either **Commitment-yes at
`P`** (a fixed point of the `P`-restricted iteration of `D` — at the
structural limit of the cell, with no further `P`-internal iteration
producing new content) or **Commitment-no at `P`**.

## Schema-level uniformity (what the gate gets right)

Three uniformities hold across the four cells:

1. The moment-relative kernel image
   `kernelImageAt : Moment → Subobject (D Y)`
   is a single construction shared by every cell.
2. Every cell predicate lives in the same Heyting register:
   a condition on `(image(D.map f), kernelImageAt t Y)`.
3. The gate has uniform shape: binary fixedness under cell-restricted
   iteration.

## Theorem-grade unity (what the gate does not have)

The four cell predicates are propositional-shape-distinct as Heyting
conditions: `≤ a`, straddle-`a`-and-`aᶜ`, `≤ aᶜᶜ ∧ ¬(≤ a)`, `≤ aᶜ`.
They are not specializations of a single Heyting expression
parameterized by cell. Any uniform formula must internally case-split
on cell. The case-split is structural, not bookkeeping. The four
cell-restricted iterations therefore differ in substance across cells;
the gate's uniformity is schema-level, not theorem-grade. The
2026-05-10 exploration in `MomentRelative.lean` is the formal record
of this.

## Iteration content (open per cell)

For each cell `P`, there is a `P`-restricted iteration `iterP : ℕ →
(C ⥤ C)` whose fixed points characterise Commitment-yes at `P`. The
shape is uniform; the content is cell-specific:

| Cell           | Iteration content (informal)                          |
|----------------|-------------------------------------------------------|
| Infrastructure | Level-`n+1` system iteration over a level fibration   |
| Distribution   | Strategy-refinement iteration                         |
| Exploitation   | Residue-coverage iteration                            |
| Refusal        | Alternative-generator `D'` iteration                  |

Each iteration's categorical specification is open framework work.
The schema below states the uniform shape; the content slots are
parameterized in by `iterP` and remain `sorry`-grade until each
cell-specific operator is specified.

## The idempotency collapse and continuous iteration

Spencer-Brown idempotency `D ⋙ D ≅ D` (in `DistinctionStructure`)
collapses the discrete iterated diagram, which means the *unrestricted*
`iterD Δ n` is degenerate. The cell-restricted iterations escape the
collapse by working in a subcategory cut out by the cell predicate
(where `D` no longer satisfies `D ⋙ D ≅ D` in the same way) or by
adding a continuous parameter. The continuous-parameterization
question is the framework's open work; the discrete `iterD` is
retained below as a placeholder shape, with the understanding that
the actual operator is cell-specific.

## Canonicity claim (open empirical)

The framework's strong canonicity claim is: *moment-relative
Commitment-yes at the work's cell is necessary for canonicity*.
Canonical works are at their cell's structural limit as of their
moment. Commitment-yes-but-not-canonical works exist (sociological
filtering, reception timing, accessibility), so the condition is
necessary but not sufficient. The strong claim is falsifiable; a
canonical-but-not-Commitment-yes work would falsify it.

## Empirical reclassifications

Works previously classified as "Commitment" under the five-cell
framing are candidates for reclassification as (cell, Commitment-yes):

* Rothko (image-pole) → likely (Exploitation, yes)
* Newman (surface-pole) → likely (Exploitation, yes)
* Sokurov, *Russian Ark* → likely (Refusal, yes) or (Exploitation, yes)
* Bach, complete tonal corpus → likely (Infrastructure, yes)

The empirical reclassification of the trajectory artifacts (Coltrane,
Painting, Kurosawa, Cinema) under the gate framework is pending
work; the four-position partition's empirical adequacy is
independently testable.

## Cross-reference

* `papers/comma-formal-structure-note.md` §5.5 — the gate's
  expository statement
* `Positions/MomentRelative.lean` — 2026-05-10 exploration that
  established schema-level uniformity and closed theorem-grade
  unification negatively
* `Positions/Partition.lean` — the four-position partition theorem
  (Theorem 0); the gate is orthogonal to this
-/

import FalseWorkPapers.Positions.Setup
import Mathlib.CategoryTheory.Limits.Filtered
import Mathlib.CategoryTheory.Limits.Shapes.Equalizers

namespace FalseWork.Positions

open CategoryTheory CategoryTheory.Limits

universe v u

variable {C : Type u} [Category.{v} C]

/-! ## The four cells as a discrete tag -/

/-- The four cells of the partition. Used as a parameter for the
cell-restricted iteration and gate predicates below. -/
inductive Cell : Type
  | infrastructure
  | distribution
  | exploitation
  | refusal
  deriving DecidableEq, Inhabited

/-! ## Iterated distinction (placeholder for cell-restricted iteration) -/

/-- The `n`-fold iterated distinction endofunctor.

* `iterD Δ 0 = 𝟭 C`
* `iterD Δ (n+1) = iterD Δ n ⋙ Δ.D`

The Spencer-Brown idempotency `D ⋙ D ≅ D` (in `DistinctionStructure`)
implies `iterD Δ n ≅ Δ.D` for all `n ≥ 1`, which collapses the
unrestricted iteration. The cell-restricted iterations `iterP` below
escape this collapse by working in a subcategory cut out by the cell
predicate. Specifying `iterP` for each cell is open framework work;
this `iterD` is retained as the *uniform shape* the four cell-specific
iterations specialize. -/
noncomputable def iterD (Δ : DistinctionStructure C) : ℕ → (C ⥤ C)
  | 0 => 𝟭 C
  | n + 1 => iterD Δ n ⋙ Δ.D

/-! ## The gate schema -/

/-- The cell-restricted iteration's signature. For each cell `P` and
each distinction structure `Δ`, there should be an iteration operator
`iterCell P Δ : ℕ → (C ⥤ C)` whose fixed points (under colimit)
characterise Commitment-yes at cell `P`.

This file does *not* construct the four cell-specific iterations. It
declares the signature uniformly. Each cell-specific operator is open
framework work; candidates are flagged in the per-cell files
(`Infrastructure.lean`, `Distribution.lean`, `Exploitation.lean`,
`Refusal.lean`).

The default value `iterD Δ` is a placeholder; downstream code that
needs the actual cell-specific operator should override it. -/
noncomputable def iterCell (P : Cell) (Δ : DistinctionStructure C) :
    ℕ → (C ⥤ C) :=
  -- Placeholder: each cell's actual iteration operator should be
  -- specified here once the framework decides the categorical content.
  -- See file docstring for the per-cell open questions.
  match P with
  | .infrastructure => iterD Δ
  | .distribution => iterD Δ
  | .exploitation => iterD Δ
  | .refusal => iterD Δ

/-- **Commitment-yes at cell `P` (schema).** A morphism `f : X ⟶ Y` is
*Commitment-yes at cell `P`* relative to `Δ` when it is a fixed point
of the cell-restricted iteration `iterCell P Δ` — equivalently, when
there exists a seed `g` such that `f` is canonically isomorphic to the
sequential colimit of `(iterCell P Δ n).map g`, and the colimit is
itself reached at `f` (no further iteration produces new content).

This is the *uniform schema*. Its content depends on `iterCell P`,
which is currently a placeholder. The schema's shape (binary
fixedness under sequential iteration) is the same across cells; what
varies is which iteration operator the cell uses.

Note: as written with `iterD` as the iteration content for every
cell, the predicate collapses under Spencer-Brown idempotency
(`D ⋙ D ≅ D`), so every `f` with image in `Im(η)` is trivially
"Commitment-yes." The non-trivial gate requires `iterCell P` to be
genuinely cell-restricted, which is the per-cell open work. -/
def IsCommitmentYes (_Δ : DistinctionStructure C) (_P : Cell) {X Y : C}
    (_f : X ⟶ Y) : Prop :=
  -- PLACEHOLDER. The real predicate quantifies over a seed `g : X' ⟶ Y'`
  -- and a sequential iso-family relating `(iterCell P Δ n).map g` at
  -- successive `n`, then asserts that `f` is canonically isomorphic in
  -- the arrow category to the colimit of that sequence. Encoding this
  -- requires `HasFilteredColimits`, the arrow-category colimit
  -- construction, and a per-cell `iterCell` whose hom-types are
  -- coherent across `n` (currently `iterCell P Δ n`'s codomain category
  -- changes with `n`, which makes an iso family between successive
  -- iterations ill-typed). The per-cell iteration content is four
  -- independent open problems documented in the Status section below.
  -- This stub keeps the schema visible and the module compiling while
  -- the content work happens.
  True

/-- Commitment-no at cell `P` is the negation of Commitment-yes at
`P`. The binary gate. -/
def IsCommitmentNo (Δ : DistinctionStructure C) (P : Cell) {X Y : C}
    (f : X ⟶ Y) : Prop :=
  ¬ IsCommitmentYes Δ P f

/-! ## Schema-level uniformity claim

**Schema uniformity (informal).** The shape of `IsCommitmentYes`
is identical across the four values of `Cell` — the same colimit
condition, the same binary structure. What differs is the iteration
operator `iterCell P` used to evaluate the condition.

This is a meta-statement about the definition's *form*, not a
provable Lean theorem. The Lean evidence is the single `def
IsCommitmentYes` parameterized by `Cell`, with no per-cell
specialization in its body. -/

/-! ## Status

DONE:
* `Cell` enumeration — the four cells of the partition.
* `iterD` — uniform shape of the iteration (Spencer-Brown-collapsing
  placeholder).
* `iterCell` — per-cell signature (currently a stub that returns
  `iterD` for every cell; each cell's actual operator is open work).
* `IsCommitmentYes` — schema definition. Uniform shape across cells.
* `IsCommitmentNo` — binary complement.

REMAINING — substantial work, per cell:
* The `True` placeholder in `IsCommitmentYes` is the actual colimit
  condition: "f is iso (in `Arrow C`) to the sequential colimit of
  `(iterCell P Δ n).map g`." Same shape as the pre-reframe sketch;
  same need for explicit arrow-category colimit or `Ind`-object
  machinery.
* The four `iterCell P` operators need cell-specific categorical
  specification. Currently all four are the placeholder `iterD`,
  which collapses under Spencer-Brown idempotency. Each cell-specific
  iteration is a separate framework decision; candidates are flagged
  in the per-cell position files.

OPEN FRAMEWORK QUESTIONS:
* **Per-cell iteration content.** Replaces the dissolved
  Commitment/Exploitation cross-cell disjointness problem. For each
  of the four cells, specify the cell-restricted iteration
  categorically. Independent problems, four in total.
* **Continuous iteration of `D`.** Spencer-Brown idempotency
  `D ⋙ D ≅ D` collapses the discrete iterated diagram. The framework
  needs to decide whether to relax idempotency, parameterize over an
  interval object, or move to an enriched setting. Affects the gate's
  content across all four cells.
* **Canonicity claim (empirical).** Moment-relative Commitment-yes at
  the work's cell is necessary for canonicity. Falsifiable by a
  canonical-but-not-Commitment-yes work. Empirical test (counterexample
  search) is open.

WHY THIS FILE REPLACED `Commitment.lean`:
The pre-reframe `Commitment.lean` (retired 2026-05-17) treated
Commitment as a fifth cell with its own structural region in `¬¬Im(η)`.
That framing created a cross-cell disjointness problem with
Exploitation that could not be resolved categorically. The 2026-05-10
reframe recognized Commitment as a binary gate within each cell, and
the disjointness problem *dissolved* — Commitment is not a separate
cell, so there is no cross-cell disjointness question. The residual
question is the per-cell iteration content, which is four independent
local problems rather than one global one.
-/

end FalseWork.Positions
