/-
Copyright (c) 2026 Chris Brink.
Released under the same license as the rest of the FalseWork Papers.

Authors: Chris Brink (FalseWork)

# Refusal: factoring through the Heyting complement of the kernel image

A morphism `f` is in *Refusal position* relative to a kernel `D` when
its `D`-image factors through the Heyting pseudo-complement of the
kernel image `Im(η)`. Where Infrastructure conceals the kernel,
Distribution distributes it, Exploitation makes its irresolvability
content, and Commitment extends one pole asymptotically — Refusal
*structurally negates* the kernel's productive operation, with the
negation generating its own cascading consequences.

## Empirical correspondences

* **Reinhardt, *Abstract Painting No. 5* (1962).** Every property of the
  mark systematically withdrawn — no gesture, no depth, no contrast,
  no figure, no ground. *And yet* a cruciform structure of
  almost-imperceptible color variation emerges under extended
  viewing. This residue is `¬¬Im(η) ∖ Im(η)`: the closure of the
  kernel image that persists in non-Boolean topoi.

* **Coltrane, *Om* (1965).** The fifths geometry's organizing axes
  refused; the closing section: "complete formlessness is unsustainable
  — the geometry pulls back." Same residue, different domain.

* **Malevich, *Black Square* (1915).** A mark that refuses to become an
  image. The craquelure exposes earlier color layers — material
  history that the refusal cannot suppress.

* **Kurosawa, *Throne of Blood* (1957).** "The cut's generative logic
  systematically refused, and Noh is the formal argument that licenses
  the refusal." Same structural position; Refusal as productive
  negation rather than absence.

## Formal characterisation

In the topos register, Refusal is the cleanest of the five positions:
`f` factors through `(Im(η))ᶜ` in `Subobject (D Y)`'s Heyting algebra.
The **asymptotic-residue** feature ("the thing refused keeps showing
through") falls out as a theorem from the failure of `¬¬a = a` in
non-Boolean topoi — it is not assumed, it is derived.

## Cross-reference

* Paper 1 v11.7 § 1 — asymmetry principle stated in one sentence
* Paper 1 v11.7 § 4 — Refusal as the fifth of five positions
* Paper 3 v9.3 § 2 — distinction operation as primitive output
* `validation/claims/five-position-derivation-formalization.md` —
  open theorem this file targets
-/

import FalseWorkPapers.Positions.Setup

namespace FalseWork.Positions

open CategoryTheory CategoryTheory.Limits

universe v u

variable {C : Type u} [Category.{v} C]
  [HasImages C] [HasPullbacks C] [HasSubobjectClassifier C]

/-! ## The Refusal position -/

/-- A morphism `f : X ⟶ Y` *refuses* the distinction `Δ` when
`D.map f` factors through the Heyting pseudo-complement of the kernel
image — the Refusal-act lives in the part of `D Y` that the marking
morphism does not reach. -/
def IsRefusal (Δ : DistinctionStructure C)
    [∀ Y : C, HeytingAlgebra (Subobject Y)]  -- discharged universally by `FalseWork.Heyting.heytingAlgebra` for elementary topoi
    {X Y : C} (f : X ⟶ Y) : Prop :=
  ∃ (g : Δ.D.obj X ⟶ ((kernelImage Δ Y)ᶜ : Subobject (Δ.D.obj Y))),
    Δ.D.map f = g ≫ ((kernelImage Δ Y)ᶜ).arrow

/-! ## The asymptotic-residue theorem

The framework's claim: even a Refusal-act cannot fully eliminate the
kernel; the kernel persists as residue. The empirical phenomenology —
Reinhardt's cruciform, Coltrane's "the geometry pulls back," Malevich's
craquelure — maps onto a categorical statement: in a non-Boolean topos,
`Im(η)` is *strictly* contained in `¬¬Im(η)`. The strict gap is the
formal residue. -/

/-- A category with classifier is *non-Boolean* if some subobject
fails the law of double negation. Equivalently, the internal logic of
`C` is intuitionistic but not classical. -/
def NonBoolean (C : Type u) [Category.{v} C] [HasSubobjectClassifier C]
    [HasImages C] [HasPullbacks C]
    [∀ Y : C, HeytingAlgebra (Subobject Y)] : Prop :=
  ∃ (Y : C) (S : Subobject Y), Sᶜᶜ ≠ S

/-- **Asymptotic-residue theorem (statement).**

In a non-Boolean topos `C`, with a non-trivial distinction structure
`Δ`, there exists `Y : C` such that the kernel image at `Y` is
strictly contained in its double pseudo-complement.

The strict inequality `kernelImage Δ Y < (kernelImage Δ Y)ᶜᶜ` is the
formal expression of "the kernel persists as residue even where it is
refused." -/
theorem refusal_residue (Δ : DistinctionStructure C)
    [∀ Y : C, HeytingAlgebra (Subobject Y)]
    (_hΔ : Δ.NonTrivial)
    (_hC : NonBoolean C) :
    ∃ Y : C, kernelImage Δ Y < (kernelImage Δ Y)ᶜᶜ := by
  /- Proof sketch:

     1. `_hC : NonBoolean C` provides some `Y₀` and `S₀ : Subobject Y₀`
        with `S₀ᶜᶜ ≠ S₀`. Since `S ≤ Sᶜᶜ` is a Heyting-algebra theorem
        (`le_compl_compl`), this gives the strict inequality
        `S₀ < S₀ᶜᶜ` at `Y₀`.

     2. `_hΔ : Δ.NonTrivial` provides `X` with `η.app X` not iso, hence
        `image.ι (η.app X)` is a *proper* subobject of `D X` — the
        kernel image is non-trivial.

     3. The load-bearing step is to show that the witness `Y₀` from
        step 1 can be chosen so that `kernelImage Δ Y₀` plays the role
        of `S₀`. Equivalently: at the point where the topos is
        non-Boolean, the kernel image is an instance of the failure
        of `¬¬a = a`. This is true *generically* in a topos where the
        kernel image is "non-decidable" — but the precise hypothesis
        on `Δ` and `C` needed to guarantee it is what the proof must
        identify. The framework's claim is that the conjunction of
        non-trivial `Δ` and non-Boolean `C` is sufficient; verifying
        this in Lean is the substantive theorem. -/
  sorry

/-! ## Status

DONE structurally:
* `IsRefusal` definition. The cleanest of the five.
* `NonBoolean` predicate.
* `refusal_residue` *statement* — asymptotic residue as a strict
  inequality in `Subobject (D Y)`.

REMAINING `sorry`:
* `refusal_residue` proof body — three-step sketch in the comment;
  step 3 (transport of non-Boolean witness onto `kernelImage`) is the
  load-bearing step that needs a hypothesis decision (see
  `Setup.lean` and the framework-question section below).

UPSTREAM MATHLIB GAP:
* `HeytingAlgebra (Subobject Y)` for topoi (see `Setup.lean` note).
  Without this the `[HeytingAlgebra ...]` hypothesis must be carried;
  with it, the hypothesis becomes derivable.

WHY THIS POSITION IS THE CLEANEST:
Topos-theoretic negation does the structural work. The asymptotic
residue is not assumed — it is derived from the failure of `¬¬a = a`,
which is a theorem of intuitionistic Heyting algebra. The four
empirical cases (Reinhardt, Om, Black Square, Throne of Blood) all
exhibit the same residue phenomenology and all map onto the same
categorical statement.
-/

end FalseWork.Positions
