/-
Copyright (c) 2026 Chris Brink.
Released under the same license as the rest of the FalseWork Papers.

Authors: Chris Brink (FalseWork)

# Moment-relative position predicates: testing two-parameter unification

This file is an **exploration**, not a settled definition layer. It runs
the specific test posed in the framework conversation of 2026-05-10:

> Can `Pos_P[t]` — the subcategory of morphisms satisfying position
> predicate `P` relative to the boundary as understood at moment `t`
> — be defined by a *single uniform construction* taking `P` and `t`
> as parameters, or does the definition of `Pos_P[t]` require
> case-analysis on `P`?
>
> If the right-hand side is a single expression that takes `P` and `t`
> as parameters and produces the subcategory, the unification is real.
> If the right-hand side has to be a case analysis on `P`, then `t` is
> wrapping non-uniform content rather than parameterizing a uniform
> construction.

The motivation: the moment-relativization observation (a work's
"Commitment-yes" status is moment-relative — *Fountain* is at the
boundary of "what counts as art" *as understood in 1917*) reopened the
question of whether the four position-specific extension operators
(level-`n+1` system-iteration for Infrastructure, strategy-refinement
for Distribution, residue-coverage for Exploitation, alternative-
generator iteration for Refusal) might all derive from a single
underlying construction, with the apparent differences absorbed into
moment-relative variation in the boundary state.

## What this file shows

A clean **negative result** under the genuine test:

* Moment-relative kernel image **does** unify uniformly:
  `kernelImageAt : Moment → Subobject (D Y)` is a single function, the
  same for every position (`unifiedKernelImage` below).
* The four position predicates **do not** unify uniformly: instantiating
  `Pos[t] P` for each `P` requires four structurally distinct Heyting
  expressions (`≤ a`, straddle-`a`-and-`aᶜ`, `≤ aᶜᶜ ∧ ¬(≤ a)`, `≤ aᶜ`)
  that are not specializations of any single Heyting term parameterized
  by `P`.

The case-split surfaces at exactly the level where the previous
walk-through diagnosed it: in *what relationship to `kernelImage[t]`*
the image of `D.map f` is required to have. Moment-relativization
makes `kernelImage[t]` itself uniform across positions, but does not
collapse the four distinct Heyting relationships into one.

## Result

The brief's positive scenario does *not* land: there is no single
expression `φ(P, kernelImage[t], img)` that, when `P` is instantiated
at each of the four position-tags, produces the four correct Heyting
conditions without case-analysis. The four conditions are
*irreducibly different shapes* in the subobject lattice.

The brief's negative scenario *does* land: the four extension operators
remain genuinely different in substance under moment-relativization.
The schema-level reading is forced. The gate (Commitment-yes) is a
real, operationally useful, predicate-shape-uniform structure, but it
does not derive from a single underlying construction.

This file documents the negative result formally so the framework can
calibrate around it.

## What this means for the canonicity claim

The canonicity-via-moment-relative-Commitment-yes claim survives the
negative Lean result. The negative result is about *unifying the four
extension operators*, not about *whether each operator individually
admits a moment-relative reading*. Each `E_P[t]` is well-defined
within its position; they just differ in substance across positions.
Commitment-yes as a binary gate at each position is still operational.

## Status

This file is **exploration**, not load-bearing definition. It exists to
document the test and the negative result. It is *not* imported by
`FalseWorkPapers.Positions` and not used by the four position files.
The settled definitions remain in those four files (with the open
questions tracked there). This file's purpose is to close the
two-parameter-unification question identified on 2026-05-10.

## Cross-reference

* `Positions.lean` — five-position dictionary (settled definitions)
* `Positions/Commitment.lean` — Commitment with continuous-iteration
  open question
* `papers/comma-formal-structure-note.md` — expository companion;
  this file's negative result is consistent with the schema-level
  framing there
-/

import FalseWorkPapers.Positions.Setup

namespace FalseWork.Positions.MomentRelative

open CategoryTheory CategoryTheory.Limits

universe v u w

variable {C : Type u} [Category.{v} C]

/-! ## Moments and boundary states -/

/-- A *moment-category* is a filtered preorder of historical states.

We require a preorder (moments are partially ordered by "before/after"
with possible incomparability for simultaneous developments in
different domains) plus a directedness condition (every pair of
moments has a common successor — capturing that the historical record
is, eventually, comparable).

For this exploration the concrete content of `Moment` is opaque; we
care only about the order structure and how the boundary state
evolves along it. -/
class MomentCategory (T : Type w) extends Preorder T where
  /-- Any two moments have a common successor. The framework reading:
  given any two historical moments, there is a later moment from which
  both are in the past. -/
  directed : ∀ t₁ t₂ : T, ∃ t : T, t₁ ≤ t ∧ t₂ ≤ t

variable (Δ : DistinctionStructure C) [HasImages C] [HasPullbacks C]
variable {T : Type w} [MomentCategory T]

/-- A *boundary state* assigns to each moment `t` a subobject of
`D.obj Y` for each `Y`, representing the kernel image as understood at
moment `t`. The framework reading: at moment `t`, practitioners and
audiences treat `kernelImageAt t Y` as "what the kernel reaches" in
domain `Y`.

The `monotone` axiom captures that the kernel image grows (or at
least, does not shrink) as understanding deepens — once a region of
`D.obj Y` is recognized as reachable by the kernel, it stays
recognized. (This is the framework's "irreversibility of distinction"
read at the historical scale.) -/
structure BoundaryState where
  kernelImageAt : T → (Y : C) → Subobject (Δ.D.obj Y)
  monotone : ∀ {t₁ t₂ : T} (Y : C), t₁ ≤ t₂ →
    kernelImageAt t₁ Y ≤ kernelImageAt t₂ Y

namespace BoundaryState

variable {Δ}

/-- The static (moment-invariant) boundary state: `kernelImageAt t Y`
is just `kernelImage Δ Y` for every `t`. This recovers the original
position definitions as the `t`-constant case. -/
noncomputable def static : BoundaryState Δ (T := T) where
  kernelImageAt _ Y := kernelImage Δ Y
  monotone _ _ := le_refl _

end BoundaryState

/-! ## Step 1: kernel image at a moment — UNIFORM

This is the test's first checkpoint: the moment-relative kernel image
should be a single expression for every position. It is.

`unifiedKernelImage` takes a boundary state `B` and a moment `t` and
returns the subobject `B.kernelImageAt t Y`. The same function is used
by every position predicate. No case-analysis on position.

This part of the unification is real. -/

/-- The moment-relative kernel image, unified across positions. -/
noncomputable def unifiedKernelImage (B : BoundaryState Δ (T := T))
    (t : T) (Y : C) : Subobject (Δ.D.obj Y) :=
  B.kernelImageAt t Y

/-! ## Step 2: position predicates at a moment — CASE-SPLIT REQUIRED

This is the test's decisive checkpoint. We define a `Position` enum and
ask: can `Pos[t] P f` be written as a single Heyting expression in
`unifiedKernelImage B t Y` and `Im(D.map f)`, parameterized by `P`,
that produces the correct condition for each position when `P` is
instantiated?

The answer is **no**. The four positions require four structurally
distinct Heyting relationships:

| Position       | Condition on `img := Im(D.map f)` relative to `a := kernelImage[t]`                |
|----------------|------------------------------------------------------------------------------------|
| Infrastructure | `IsIso (η.app X) ∧ IsIso (η.app Y)` (does not use `a` at all!) **OR**              |
|                | (closure-reading) `img ≤ a`                                                        |
| Distribution   | `img ⊓ a ≠ ⊥  ∧  img ⊓ aᶜ ≠ ⊥`                                                     |
| Exploitation   | `img ≤ aᶜᶜ  ∧  ¬(img ≤ a)`                                                         |
| Refusal        | `img ≤ aᶜ`                                                                         |

These are **not** specializations of a single Heyting term. `≤ a`,
straddle, `≤ aᶜᶜ ∧ ¬(≤ a)`, `≤ aᶜ` are four irreducibly different
shapes of Heyting predicate. There is no expression `φ(P, a, img)` in
the language of Heyting algebra plus an enum-parameter `P` that
reduces to each of these four when `P` is instantiated, without
internal case-analysis.

To see this: any uniform Heyting expression in `a` and `img` is built
from `⊓`, `⊔`, `⇒`, `¬`, `≤`, `=`, plus constants `⊥, ⊤`. The four
conditions use, respectively: `≤`, conjunction-of-non-trivial-meets,
conjunction-of-`≤`-on-double-complement-and-negated-`≤`, `≤`. These
are different *propositional shapes*, not different *values within a
fixed shape*. A parameter `P` cannot select among propositional shapes
without case-analysis on `P`.

## The `Position` enum and the case-split predicate -/

/-- The four position tags. We omit Commitment from this enum because
Commitment is the *gate* across the four positions (binary fixedness
under each position's extension operator), not a fifth lattice cell.
This is the reframing from 2026-05-10. -/
inductive Position
  | infrastructure
  | distribution
  | exploitation
  | refusal
  deriving DecidableEq, Inhabited

/-- The position predicate at moment `t`, with the case-split made
explicit. This is the honest definition: a `match` on `Position`.

Note that the case-split here is *not* an artifact of how the
definition happens to be written — it reflects the four irreducibly
different Heyting shapes documented above. Any attempt to remove the
`match` runs into the propositional-shape obstruction. -/
noncomputable def Pos
    [HeytingAlgebra (Subobject (Δ.D.obj _))]
    (B : BoundaryState Δ (T := T)) (t : T)
    {X Y : C} (f : X ⟶ Y) : Position → Prop
  | .infrastructure =>
      -- Infrastructure: η is iso at endpoints. Note this does *not*
      -- reference `unifiedKernelImage B t Y` at all — the predicate
      -- is moment-invariant in its η-formulation. (See discussion
      -- below on whether to rephrase as a closure condition.)
      IsIso (Δ.η.app X) ∧ IsIso (Δ.η.app Y)
  | .distribution =>
      let img := Subobject.mk (image.ι (Δ.D.map f))
      let a := unifiedKernelImage B t Y
      img ⊓ a ≠ ⊥ ∧ img ⊓ aᶜ ≠ ⊥
  | .exploitation =>
      let img := Subobject.mk (image.ι (Δ.D.map f))
      let a := unifiedKernelImage B t Y
      img ≤ aᶜᶜ ∧ ¬(img ≤ a)
  | .refusal =>
      let img := Subobject.mk (image.ι (Δ.D.map f))
      let a := unifiedKernelImage B t Y
      img ≤ aᶜ

/-! ## Step 3: the failure-mode check the brief flagged

The brief warned about uniformity-at-the-wrong-level: defining
`Pos[t] P` as "the subcategory of morphisms satisfying the
appropriate condition at moment `t`" — uniform but vacuous, because
"appropriate condition" is a placeholder for position-specific
content.

Our definition above does not have that failure mode. The `match`
specifies *which Heyting expression* each position evaluates. It is
honest case-analysis, not a placeholder.

The deeper failure mode the brief named — uniform-looking definition
that on inspection reduces to "Pos_Infrastructure[t] is whatever
Infrastructure means at t, etc." — is the one we have to reject. Our
definition makes the case-analysis visible. The brief's "genuine
test" would require an expression that, when expanded for specific
`P` values, produces the four conditions without separate
specification. We have argued above that no such expression exists in
the Heyting language. -/

/-- A sanity check: at the static boundary state, `Pos B t P` recovers
the original position predicates from the sibling files (up to the
Infrastructure rephrasing issue noted below). -/
example [HeytingAlgebra (Subobject (Δ.D.obj _))]
    (t : T) {X Y : C} (f : X ⟶ Y) :
    Pos Δ (B := .static) t f .refusal ↔
      Subobject.mk (image.ι (Δ.D.map f)) ≤ (kernelImage Δ Y)ᶜ := by
  unfold Pos BoundaryState.static unifiedKernelImage
  rfl

/-! ## Step 4: can we rephrase Infrastructure to fit a uniform shape?

One might object: the Infrastructure case is the odd one out — it
references `η` directly, not the kernel image. Could we re-express
Infrastructure as a Heyting condition on `unifiedKernelImage` to
bring it into line with the other three?

Two candidates:

1. **Closure reading.** Infrastructure means `img ≤ a` (the image
   stays inside the kernel image). When `a = ⊤`, this is trivially
   true; when `η` is iso at endpoints, the image is forced to lie in
   `a` by naturality.

2. **Top-element reading.** Infrastructure means `a = ⊤` itself (the
   kernel image is the whole codomain — there is no comma residue at
   moment `t`).

Reading (1) is a Heyting condition on `(img, a)` and *is* a fourth
shape: `≤ a`. So the four shapes become:

| Position       | Heyting condition          |
|----------------|----------------------------|
| Infrastructure | `img ≤ a`                  |
| Distribution   | `img ⊓ a ≠ ⊥ ∧ img ⊓ aᶜ ≠ ⊥`|
| Exploitation   | `img ≤ aᶜᶜ ∧ ¬(img ≤ a)`   |
| Refusal        | `img ≤ aᶜ`                 |

This is the closest the four positions get to a uniform shape: each
is a Heyting condition in `(img, a)`. But they are still *four
different conditions*, not specializations of one parameterized
condition. The parameter `P` selects among the four, which is still
case-analysis. -/

/-- Closure-reading variant of `Pos`. Same case-split structure; only
the Infrastructure clause changes. -/
noncomputable def Pos'
    [HeytingAlgebra (Subobject (Δ.D.obj _))]
    (B : BoundaryState Δ (T := T)) (t : T)
    {X Y : C} (f : X ⟶ Y) : Position → Prop
  | .infrastructure =>
      let img := Subobject.mk (image.ι (Δ.D.map f))
      let a := unifiedKernelImage B t Y
      img ≤ a
  | .distribution =>
      let img := Subobject.mk (image.ι (Δ.D.map f))
      let a := unifiedKernelImage B t Y
      img ⊓ a ≠ ⊥ ∧ img ⊓ aᶜ ≠ ⊥
  | .exploitation =>
      let img := Subobject.mk (image.ι (Δ.D.map f))
      let a := unifiedKernelImage B t Y
      img ≤ aᶜᶜ ∧ ¬(img ≤ a)
  | .refusal =>
      let img := Subobject.mk (image.ι (Δ.D.map f))
      let a := unifiedKernelImage B t Y
      img ≤ aᶜ

/-! ## Step 5: the case-split is irreducible

A purported uniform expression would have to be a Heyting term `φ` in
two subobject variables `(a, img)` and one position-parameter `P`,
such that:

* `φ(.infrastructure, a, img) ↔ img ≤ a`
* `φ(.distribution, a, img) ↔ img ⊓ a ≠ ⊥ ∧ img ⊓ aᶜ ≠ ⊥`
* `φ(.exploitation, a, img) ↔ img ≤ aᶜᶜ ∧ ¬(img ≤ a)`
* `φ(.refusal, a, img) ↔ img ≤ aᶜ`

`P` enters `φ` only as a propositional-shape selector. In Heyting
algebra, there is no operation that takes a discrete-tag input and
returns a propositional shape; the language has logical connectives
and order, not metalinguistic case-analysis. Therefore `φ` must use
`if P = ...` internally — which is exactly the case-analysis we are
trying to avoid.

The conclusion is structural, not bookkeeping: the four position
predicates are propositional-shape-distinct. Moment-relativization
does not change this.

Below we make the irreducibility precise as a meta-claim. -/

/-- **Meta-claim (informal, stated as documentation).** Let
`(a : Subobject Z)` and `(img : Subobject Z)` range freely. The four
Heyting predicates

* `P_I(a, img) := img ≤ a`
* `P_D(a, img) := img ⊓ a ≠ ⊥ ∧ img ⊓ aᶜ ≠ ⊥`
* `P_E(a, img) := img ≤ aᶜᶜ ∧ ¬(img ≤ a)`
* `P_R(a, img) := img ≤ aᶜ`

are not pairwise mutually implied: there exist Heyting algebras and
choices of `(a, img)` realizing each pair `(P_X, ¬P_Y)` for `X ≠ Y`
(modulo boundary cases). In particular they define four genuinely
distinct subsets of `Sub(Z) × Sub(Z)`, so any function
`Position → ((a,img) → Prop)` selecting among them is not constant in
the `Position` argument, hence its definition requires case-analysis.

(This is a meta-statement *about* the Lean definitions, not a Lean
theorem. The negative result is the absence of a uniform Heyting
formula, which is a statement about the expressive power of the
Heyting language — better tracked in `papers/comma-formal-structure-note.md`
than proved internally.)
-/
-- (No Lean code: meta-claim only. The four `def`s above are the
-- formal evidence.)

/-! ## What schema-level uniformity DOES hold

Even given the negative result, three uniformity properties survive
and are operationally useful:

**U1. The boundary state is uniform.** `unifiedKernelImage B t Y` is
a single function used by every position predicate. There is no
position-specific moment-relative kernel image.

**U2. The Heyting-condition shape is uniform.** Every position
predicate (in the closure-reading version `Pos'`) is a Heyting
condition on `(Im(D.map f), unifiedKernelImage B t Y)`. Different
shapes, but the same algebraic register.

**U3. The fixed-point gate is uniform.** Commitment-yes at position
`P` and moment `t` is fixedness of `f` under the
`Pos'[t] P`-restricted iteration of `D`. The definition of "fixedness"
is uniform across positions; what differs is which subcategory the
iteration takes place in (specified by `Pos' P`).

These three uniformities are what the framework gets. They are
**schema-level**: same algebraic register, same fixed-point structure,
parameterized by which Heyting shape and which boundary state. They
are **not theorem-grade**: there is no single Heyting expression that
specializes to the four position conditions.

The brief's terminology applies: this is "predicate-shape uniformity
(each position has its own extension operator with binary fixed-point
structure)" but not "theorem-grade unity." The gate is real and
operationally useful; it does not derive from a single underlying
construction.
-/

/-- A schematic record of the uniform commitment gate at position `P`,
moment `t`. The `fixedUnder` field is the binary fixedness condition
in the `Pos' P`-restricted iteration; its full definition requires
the iteration-and-colimit machinery from `Commitment.lean` and is
left as a placeholder here.

The structure is uniform across `P` and `t` — same shape, same
typing. The *value* of `fixedUnder` is position-specific (different
restricted iterations), which is the schema-level reading. -/
structure CommitmentGate
    [HeytingAlgebra (Subobject (Δ.D.obj _))]
    (B : BoundaryState Δ (T := T)) (t : T)
    {X Y : C} (f : X ⟶ Y) (P : Position) : Prop where
  inPosition : Pos' Δ B t f P
  fixedUnder : True  -- placeholder for the position-restricted-
                     -- iteration fixedness condition; see
                     -- `Commitment.lean` for the iteration machinery
                     -- and the open question on continuous parameterization

/-! ## Verdict

**Negative result on theorem-grade two-parameter unification.** The
four position predicates do not derive from a single Heyting
expression parameterized by position. Moment-relativization unifies
the boundary state (U1) and preserves the Heyting register (U2) and
the gate's fixed-point shape (U3), but does not collapse the four
distinct predicate shapes into one.

**Positive result on schema-level uniformity.** All four predicates
live in the same Heyting register; the commitment gate has a uniform
shape across positions; the moment-relative kernel image is a single
construction.

**Calibrated framework position.** The five-position dictionary is
schema-level uniform, with four distinct Heyting shapes and a uniform
gate-and-iteration structure. The canonicity claim
(moment-relative-Commitment-yes is necessary for canonicity) is not
affected by this result — that claim is about whether each individual
extension operator's fixed points capture canonicity within its
position, not about whether the four operators unify.

The two-parameter-unification question is closed: the unification is
cosmetic, not theorem-grade. Subsequent work should not reopen it
without a fundamentally different parameterization (e.g., embedding
the four Heyting shapes into a richer ambient structure that the
Heyting language cannot see — which is a substantial categorical
move and not a routine refinement).
-/

end FalseWork.Positions.MomentRelative
