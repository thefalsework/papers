/-
Copyright (c) 2026 Chris Brink.
Released under the same license as the rest of the FalseWork Papers.

Authors: Chris Brink (FalseWork)

# Commitment: total fidelity to one pole, asymptotic approach

A morphism `f` is in *Commitment position* when it is the (filtered)
colimit of an iterated `D`-application to a seed `g`. The work pursues
one pole of the comma to its asymptotic limit; the other pole persists
as the boundary the colimit approaches but never reaches.

## Empirical correspondences

* **Rothko, *Orange, Red, Yellow* (1961).** Many thin translucent
  layers, each adding luminous depth. `D` parameterized as
  "add a layer"; `f` is the colimit. The image-pole is pursued to its
  asymptote; the surface-pole persists as the canvas edge that is
  approached but does not vanish.

* **Newman, *Vir Heroicus Sublimis* (1950–1951).** The dividing zip
  carrying maximum compositional weight. `D` parameterized as "extend
  the dividing gesture"; `f` is again the colimit. The surface-pole is
  pursued; the image-pole asymptotes.

* **Sokurov, *Russian Ark* (2002).** A single 96-minute take. The
  cut's logic of spatial-temporal construction is pursued until the
  splice disappears into continuous camera movement. The continuity
  the cut produced becomes the asymptote.

* **Bach, complete tonal corpus.** "One composer, one position,
  lifetime fidelity" (per the Kurosawa-trajectory framing). The
  fifths geometry's logic is pursued exhaustively; the closed
  geometric space is the asymptotic limit.

The Rothko/Newman pairing is informative: both at the same position
(Commitment), with `D` parameterized differently (image-pole vs
surface-pole). The position-typing does not change with parameter
choice; only the pole pursued does.

## Formal characterisation

In the topos register, Commitment is the condition that `f` is
isomorphic to the filtered colimit of the iterated `D`-action on some
seed `g`. The colimit is *asymptotic* in the sense that it lives in
the `Ind`-completion of `C`: it represents a process approaching a
limit-object in `C` rather than reaching one.

The non-Boolean topos's `¬¬Im(η)` plays the role of the asymptotic
boundary — Commitment morphisms have image converging into
`¬¬Im(η)` without lying in `Im(η)`.

## Cross-reference

* Paper 1 v11.7 § 4 — Commitment as the fourth of five positions
* `Mathlib.CategoryTheory.Limits.Filtered` — filtered colimits
* `Mathlib.CategoryTheory.Limits.IndYoneda` (where it lands) —
  `Ind`-objects
-/

import FalseWorkPapers.Positions.Setup
import Mathlib.CategoryTheory.Limits.Filtered
import Mathlib.CategoryTheory.Limits.Shapes.Equalizers

namespace FalseWork.Positions

open CategoryTheory CategoryTheory.Limits

universe v u

variable {C : Type u} [Category.{v} C]

/-! ## Iterated distinction -/

/-- The `n`-fold iterated distinction endofunctor.

* `iterD Δ 0 = 𝟭 C`
* `iterD Δ (n+1) = iterD Δ n ⋙ Δ.D`

The Spencer-Brown idempotency `D ⋙ D ≅ D` (in `DistinctionStructure`)
implies `iterD Δ n ≅ Δ.D` for all `n ≥ 1`, which collapses the
iteration. To get a non-trivial Commitment colimit we therefore need
to *parameterize* `D` — typically by replacing `D` with a continuous
family `{D_t}_{t ∈ [0,1)}` whose limit at `t = 1` is the asymptotic
boundary. This file uses the discrete `iterD` for concreteness and
flags the parameterized version as the framework's actual target. -/
noncomputable def iterD (Δ : DistinctionStructure C) : ℕ → (C ⥤ C)
  | 0 => 𝟭 C
  | n + 1 => iterD Δ n ⋙ Δ.D

/-! ## The Commitment position -/

/-- A morphism `f : X ⟶ Y` is in *Commitment position* relative to `Δ`
when there exists a seed `g : X' ⟶ Y'` such that `f` is canonically
isomorphic to the colimit (in the arrow category of `C`) of the
sequential diagram `g, D-applied-to-g, D²-applied-to-g, …`.

The colimit is *filtered* (`ℕ` as a directed set) and is the framework's
formal home for "asymptotic approach to a limit pole."

Note: as written, the discrete iterated structure collapses under
Spencer-Brown idempotency (`D ⋙ D ≅ D`). The intended formalization
parameterizes `D` continuously — see the `iterD` doc-comment and the
status section. -/
def IsCommitment (Δ : DistinctionStructure C) {X Y : C} (f : X ⟶ Y) :
    Prop :=
  ∃ (X' Y' : C) (g : X' ⟶ Y') (_seq_iso :
      ∀ n : ℕ, ((iterD Δ n).map g : (iterD Δ n).obj X' ⟶ (iterD Δ n).obj Y')
              ≅ ((iterD Δ (n+1)).map g)),
    -- f is isomorphic, in the arrow category, to the sequential
    -- colimit of (iterD Δ n).map g over n
    True  -- placeholder: actual condition wants HasFilteredColimits +
          -- arrow-category colimit definition

/-! ## Signature theorem: pole symmetry -/

/-- **Commitment pole symmetry (signature).** The framework's empirical
observation that Commitment admits *two* poles (Rothko's image-pole vs
Newman's surface-pole) corresponds formally to the existence of two
distinct seeds `g_1, g_2` whose iterated colimits both yield Commitment
morphisms — *with the same target position* but different asymptotic
boundaries.

This is the formal home for the Rothko/Newman pairing: same position,
opposite poles. The two seeds parameterize `D`'s action toward two
distinct asymptotic limits within `¬¬Im(η)`. -/
theorem commitment_two_poles (Δ : DistinctionStructure C) :
    Δ.NonTrivial →
    ∃ (X₁ Y₁ X₂ Y₂ : C) (g₁ : X₁ ⟶ Y₁) (g₂ : X₂ ⟶ Y₂),
      -- Both seeds yield Commitment morphisms
      -- but with structurally distinct asymptotic boundaries.
      True := by
  sorry  -- The proof depends on what "asymptotic boundary" is formally
         -- (open: `¬¬Im(η)` in subobject lattice? Limit object in
         --  Ind(C)? Both?). With `IsCommitment` properly defined and
         -- the asymptotic-boundary structure pinned down, this is
         -- a constructive existence result.

/-! ## Status

DONE:
* `iterD` — discrete iterated functor.
* `IsCommitment` — structural shape of the definition (sequential
  colimit of iterated D-action on a seed).
* `commitment_two_poles` — signature for Rothko/Newman symmetry.

REMAINING — substantial work:
* The `True` placeholder in `IsCommitment` is the actual condition:
  "f is iso (in `Arrow C`) to the sequential colimit of
  `(iterD Δ n).map g`." This requires either explicit `colim` in the
  arrow category (Mathlib has `Arrow C` and limits in functor
  categories, so the structure is there) or `Ind`-object machinery
  for asymptotic colimits.

* The proof body of `commitment_two_poles` depends on what
  "asymptotic boundary" formally means — see the open question below.

OPEN FRAMEWORK QUESTIONS:
* **The idempotency collapse.** `D ⋙ D ≅ D` collapses iterated `D`
  to `D`, which means the discrete `iterD` is not the right object
  for asymptotic Commitment. The framework's intended mathematical
  structure is *continuous* iteration — a family `{D_t}_{t ∈ [0,1)}`
  with `D_0 = id` and `D_t → D` as `t → 1`. This needs either:
  - relaxing Spencer-Brown idempotency to a *strict-iteration*
    distinction structure where `D ⋙ D ≇ D`, or
  - adding a continuous parameter via internal-hom (`C(I, D)` for
    some interval object `I`), or
  - working in an enriched category over a topological category.
  This is **the central open question for Commitment** and parallels
  the open construction for Exploitation.

* **Asymptotic boundary as `¬¬Im(η)`.** The file claims (in the doc
  comment) that the asymptotic boundary is `¬¬Im(η)`. Justifying this
  formally — showing that Commitment colimits land in the closure
  but not in the strict image — is open. Could become a theorem once
  the continuous-parameter version of `D` is in place.

WHY THIS POSITION IS HARD (BUT NOT AS HARD AS EXPLOITATION):
Commitment needs the *continuous-iteration* refinement of `D` plus
the `Ind`-object machinery for asymptotic colimits. Both of these are
existing mathematical machinery — they don't require new
constructions, just careful application. This contrasts with
Exploitation, which needs the comma-object `L_d` that has no clear
direct analogue in current Mathlib.
-/

end FalseWork.Positions
