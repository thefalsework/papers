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
  [HasEqualizers C] [HasInitial C] [HasBinaryCoproducts C] [InitialMonoClass C]

/-! ## The Refusal position -/

/-- A morphism `f : X ⟶ Y` *refuses* the distinction `Δ` when
`D.map f` factors through the Heyting pseudo-complement of the kernel
image — the Refusal-act lives in the part of `D Y` that the marking
morphism does not reach. -/
def IsRefusal (Δ : DistinctionStructure C)
    {X Y : C} (f : X ⟶ Y) : Prop :=
  ∃ (g : Δ.D.obj X ⟶ ((kernelImage Δ Y)ᶜ : Subobject (Δ.D.obj Y))),
    Δ.D.map f = g ≫ ((kernelImage Δ Y)ᶜ).arrow

/-! ## The asymptotic-residue theorem

The framework's claim: even a Refusal-act cannot fully eliminate the
kernel; the kernel persists as residue. The empirical phenomenology —
Reinhardt's cruciform, Coltrane's "the geometry pulls back," Malevich's
craquelure — maps onto a categorical statement: when the kernel image
is *irregular* (fails the law of double negation), `Im(η)` is *strictly*
contained in `¬¬Im(η)`. The strict gap is the formal residue.

### Regulars vs. irregulars

In any Heyting algebra `H`, the elements `x` with `x = xᶜᶜ` are the
*regular* elements; they form a Boolean sub-algebra `H_reg ⊆ H` (meet
inherited, join given by `¬¬(x ∨ y)`). The regular sub-algebra is the
part of the logic where classical reasoning remains valid — `¬¬p ↔ p`
holds there by definition. The non-regular elements are precisely
those that exhibit the intuitionistic strictness `x < xᶜᶜ`.

A distinction structure whose kernel image always lands in the regular
sub-algebra — call such a `Δ` *regularly-confined* — has a Boolean
kernel even when the ambient topos is non-Boolean. The asymptotic
residue cannot exist there, because the residue *is* the gap between
an element and its double-negation closure, and that gap is zero on
regulars by definition.

The framework's commitment, made explicit by the `HasIrregularKernel`
predicate below, is to study distinction structures that escape the
regular sub-algebra — those whose operation reaches into the
intuitionistic part of the ambient logic. Refusal-as-asymptotic-limit
is a non-degenerate position exactly there. -/

/-- A category with classifier is *non-Boolean* if some subobject
fails the law of double negation. Equivalently, the internal logic of
`C` is intuitionistic but not classical.

`NonBoolean C` is a property of the ambient topos. It says the
*topos* has intuitionistic content, but says nothing about whether
that content is visible at the kernel image of any particular `Δ`. -/
def NonBoolean (C : Type u) [Category.{v} C] [HasSubobjectClassifier C]
    [HasImages C] [HasPullbacks C]
    [HasEqualizers C] [HasInitial C] [HasBinaryCoproducts C]
    [InitialMonoClass C] : Prop :=
  ∃ (Y : C) (S : Subobject Y), Sᶜᶜ ≠ S

/-- A distinction structure `Δ` has an *irregular kernel* when its
kernel image fails the law of double negation at some object.
Equivalently: `Δ` does not factor through the regular sub-algebra of
the subobject lattices.

This is a strictly stronger property than `NonBoolean C`. The latter
says the topos has intuitionistic content *somewhere*; the former says
the kernel image *is* that intuitionistic content at some object. The
bridge between them — when does `Δ.NonTrivial + NonBoolean C` force
`Δ.HasIrregularKernel`? — is the framework-level open question tracked
at `validation/claims/refusal-bridge.md`. -/
def DistinctionStructure.HasIrregularKernel (Δ : DistinctionStructure C) : Prop :=
  ∃ Y : C, (kernelImage Δ Y)ᶜᶜ ≠ kernelImage Δ Y

/-- **Asymptotic-residue theorem.**

For a distinction structure `Δ` with an irregular kernel, there exists
`Y : C` such that the kernel image at `Y` is strictly contained in its
double pseudo-complement.

The strict inequality `kernelImage Δ Y < (kernelImage Δ Y)ᶜᶜ` is the
formal expression of "the kernel persists as residue even where it is
refused." The strict-inequality form is essential: a proper subobject
`S < ⊤` with `S = Sᶜᶜ` (a *regular* proper subobject) is a complete
capture with zero residue inside its closure — that is *not* the
asymptotic-residue phenomenology Reinhardt, Coltrane, and Malevich
exhibit. The residue is the gap *after* closure, which is what
`S < Sᶜᶜ` names. -/
theorem refusal_residue (Δ : DistinctionStructure C)
    (hIrregular : Δ.HasIrregularKernel) :
    ∃ Y : C, kernelImage Δ Y < (kernelImage Δ Y)ᶜᶜ := by
  obtain ⟨Y, hY⟩ := hIrregular
  exact ⟨Y, lt_of_le_of_ne le_compl_compl (Ne.symm hY)⟩

/-! ## Status

DONE:
* `IsRefusal` definition. The cleanest of the five.
* `NonBoolean` predicate (ambient-topos non-classicality).
* `DistinctionStructure.HasIrregularKernel` predicate (kernel-level
  non-classicality, i.e., the kernel image escapes the regular
  sub-algebra at some object).
* `refusal_residue` — asymptotic residue as a strict inequality in
  `Subobject (D Y)`.  Proof body closed (2026-05-20) using the
  Heyting identity `S ≤ Sᶜᶜ` combined with the irregular-kernel
  hypothesis.

UPSTREAM MATHLIB GAP:
* Closed (Phase 2, 2026-05-19) by the in-repo
  `FalseWork.Heyting.heytingAlgebra` instance.  PR #39618 opened
  upstream (2026-05-20).

OPEN AT THE FRAMEWORK LEVEL:
* The *refusal bridge*: when does `Δ.NonTrivial + NonBoolean C` force
  `Δ.HasIrregularKernel`?  Equivalently: which structural properties
  of a distinction operation force it off the regular sub-algebra of
  the subobject lattices?  The bridge is non-trivial because the
  regular elements of a Heyting algebra form a Boolean sub-algebra,
  and a non-trivial `Δ` whose image lands entirely in regulars at
  every object would produce a Boolean kernel inside a non-Boolean
  topos — a generically available class, not a constructed
  counterexample.  Tracked at
  `validation/claims/refusal-bridge.md` as a named open conjecture.

WHY THIS POSITION IS THE CLEANEST:
Topos-theoretic negation does the structural work. The asymptotic
residue is not assumed — it is derived from the failure of `¬¬a = a`
on the irregular part of the subobject lattice, which is a theorem of
intuitionistic Heyting algebra. The four empirical cases (Reinhardt,
Om, Black Square, Throne of Blood) all exhibit the same residue
phenomenology and all map onto the same categorical statement.  The
framework commits, via `HasIrregularKernel`, to studying distinction
structures whose operations reach into the intuitionistic part of the
ambient logic; whether that commitment is automatic in non-Boolean
topoi is the bridge conjecture.
-/

end FalseWork.Positions
