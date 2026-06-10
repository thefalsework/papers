/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# The Glivenko collapse: classical logic cannot carry the partition
(deeper-theorem item 2 of 2026-06-10; pre-registered in
`validation/claims/unique-ordinary-structure.md` §3 check 3)

The kernel trichotomy (`allFourCellsInhabited_iff`) already showed that a
non-degenerate four-position kernel must be *ordinary* — neither regular
nor dense — which is impossible in a Boolean algebra, where `¬¬a = a`
everywhere.  This file sharpens that observation into a statement about
the **double-negation reflection** (Glivenko):

1. **`boolean_no_ordinary` / `boolean_no_kernel`.**  No Boolean algebra
   has an ordinary element; equivalently, no kernel in a Boolean algebra
   makes all four cells inhabited.  The partition is degenerate at *every*
   kernel of *every* Boolean algebra.

2. **`not_isOrdinary_compl_compl`.**  In any Heyting algebra, the image of
   the double-negation map `a ↦ ¬¬a` is never ordinary: `¬¬a` is regular
   by the triple-negation law.  So the reflection annihilates ordinariness
   pointwise, before one even passes to the regular subalgebra.

3. **`glivenko_no_kernel`.**  The regular elements of any Heyting algebra
   form a Boolean algebra (Glivenko; Mathlib `Heyting.Regular`), and the
   reflection `Heyting.Regular.toRegular : H →o Regular H` (with
   `toRegular a = ¬¬a` on underlying elements) lands every element there.
   No element of that Boolean shadow is a non-degenerate kernel.

**Reading**: the four positions are structure that classical logic
provably cannot represent.  Whatever survives the passage to the Boolean
shadow of a Heyting algebra, the four-cell partition does not: every
ordinary element is sent to a regular one, and the cells Exploitation and
Refusal lose their simultaneous witnesses.  This is the contrapositive
face of the trichotomy's "non-Boolean" clause, stated as a reflection
theorem rather than as a non-existence observation.
-/
import Mathlib.Order.Heyting.Regular
import FalseWorkPapers.Examples.NishimuraKernelLaw

namespace FalseWork.Lattice

/-! ## 1. Boolean algebras carry no ordinary element, hence no kernel -/

section Boolean

variable {B : Type*} [BooleanAlgebra B]

/-- **No Boolean algebra has an ordinary element**: `¬¬a = a` everywhere,
so the first conjunct of `IsOrdinary` fails for every `a`. -/
theorem boolean_no_ordinary (a : B) : ¬ IsOrdinary a := fun h =>
  h.1 (compl_compl a)

/-- **No Boolean kernel is non-degenerate**: in a Boolean algebra no
element makes all four cells of the four-position partition inhabited.
Via the trichotomy this is exactly `boolean_no_ordinary`. -/
theorem boolean_no_kernel (a : B) : ¬ AllFourCellsInhabited a := fun h =>
  boolean_no_ordinary a ((isOrdinary_iff_allFourCells a).mpr h)

end Boolean

/-! ## 2. The double-negation reflection annihilates ordinariness -/

section Reflection

variable {H : Type*} [HeytingAlgebra H]

/-- **The image of the double-negation map is never ordinary.**  For any
`a` in any Heyting algebra, `¬¬a` is regular (`¬¬¬¬a = ¬¬a`, by the
triple-negation law), so the Glivenko reflection `a ↦ ¬¬a` sends every
element — ordinary or not — to a non-ordinary one. -/
theorem not_isOrdinary_compl_compl (a : H) : ¬ IsOrdinary (aᶜᶜ) := fun h =>
  h.1 (congrArg (·ᶜ) (compl_compl_compl a))

/-- **No ordinary element in the Boolean shadow.**  The regular elements
`Heyting.Regular H` form a Boolean algebra (Glivenko), so none of them is
ordinary *as an element of that algebra*. -/
theorem glivenko_no_ordinary (a : Heyting.Regular H) : ¬ IsOrdinary a :=
  boolean_no_ordinary a

/-- **The Glivenko collapse of the partition.**  In the Boolean algebra of
regular elements of any Heyting algebra — the codomain of the
double-negation reflection `Heyting.Regular.toRegular`, which sends `a`
to `¬¬a` — no kernel makes all four cells inhabited.  The four-position
partition does not survive passage to the classical shadow. -/
theorem glivenko_no_kernel (a : Heyting.Regular H) :
    ¬ AllFourCellsInhabited a :=
  boolean_no_kernel a

/-- **Bundle.**  The reflection annihilates the partition twice over:
pointwise (`¬¬a` is never ordinary in `H`) and globally (the regular
subalgebra, where the reflection lands, has no non-degenerate kernel at
all). -/
theorem glivenko_collapse :
    (∀ a : H, ¬ IsOrdinary (aᶜᶜ)) ∧
    (∀ a : Heyting.Regular H, ¬ AllFourCellsInhabited a) :=
  ⟨not_isOrdinary_compl_compl, glivenko_no_kernel⟩

end Reflection

end FalseWork.Lattice
