/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# Is the tritone distinction operator a Lawvere–Tierney topology?

The music-anchor bridge note (`music-anchor/mazzola-bridge-note.md` §5)
speculated that the distinction operator `tritoneClosure` might be "the
subobject-level trace of a sheafification for a specific Grothendieck
topology on `P`."  A sheafification's action on the subobject lattice is a
**nucleus** — a closure operator `j` that additionally *preserves binary
meets*, `j(a ⊓ b) = j a ⊓ j b` — equivalently (in a presheaf topos) the
subobject trace of a Lawvere–Tierney topology.

This file settles the question, kernel-checked:

* **Negative.** The *minimal* tritone-closing closure operator
  `tritoneClosure` (Moore family `{⟨6⟩, Z/12} = {two, twelve}`) is **not**
  a nucleus: it fails meet-preservation (`tritoneClosure_not_nucleus`).
  So the bridge note's sheafification reading of that specific operator is
  incorrect; its topos lift is a general idempotent monad
  (`DistinctionStructure.ofIdempotentMonad`), **not** a Lawvere–Tierney
  topology.

* **Positive.** The *maximal* tritone-closing closure operator
  `tritoneNucleus` (Moore family `{⟨6⟩, ⟨3⟩, ⟨2⟩, Z/12} = {two, four,
  six, twelve}`) **is** a nucleus, and its kernel image
  `tritoneNucleus ⊥` is still the tritone — a non-regular element.  So
  there *is* a Lawvere–Tierney topology on the T2 topos `Set^{Pᵒᵖ}` whose
  induced distinction structure has the tritone as its (non-regular)
  kernel, hence all four cells of the partition inhabited.  This gives the
  music kernel a genuine *geometric* (sheaf-theoretic) realization, not
  merely a reflective one.

Both operators share the same kernel image (the tritone), so the
four-position witness `music_anchor_witness` is realized by *either* lift.
The distinction between them is exactly the distinction between a generic
reflective subcategory and a sheaf subtopos.
-/
import FalseWorkPapers.Examples.DivisorLattice12Distinction

namespace FalseWork.Lattice.Examples

namespace Div12

/-- A **nucleus** on the Heyting algebra: an inflationary, idempotent,
binary-meet-preserving operator.  (Monotonicity follows from
meet-preservation.)  Nuclei are exactly the subobject-level traces of
Lawvere–Tierney topologies / sheafifications. -/
def IsNucleus (j : Div12 → Div12) : Prop :=
  (∀ a, a ≤ j a) ∧
  (∀ a, j (j a) = j a) ∧
  (∀ a b, j (a ⊓ b) = j a ⊓ j b)

/-! ## Negative: the minimal tritone-closing operator is not a nucleus -/

/-- `tritoneClosure` fails meet-preservation, exhibited concretely:
with `a = three` (augmented triad) and `b = four` (diminished 7th),
`a ⊓ b = ⊥` closes up to the tritone, but `j a ⊓ j b = ⊤`. -/
theorem tritoneClosure_not_meet_preserving :
    ∃ a b : Div12,
      tritoneClosure (a ⊓ b) ≠ tritoneClosure a ⊓ tritoneClosure b := by decide

/-- **The minimal tritone-closing closure operator is not a nucleus.**
Hence it is not the subobject trace of a Lawvere–Tierney topology; its
topos lift is a general (non-left-exact) idempotent monad. -/
theorem tritoneClosure_not_nucleus : ¬ IsNucleus tritoneClosure := by
  intro h
  obtain ⟨a, b, hab⟩ := tritoneClosure_not_meet_preserving
  exact hab (h.2.2 a b)

/-! ## Positive: the maximal tritone-closing operator is a nucleus -/

/-- The maximal tritone-closing closure operator, with Moore family
`{two, four, six, twelve}` — every element except `⊥` (`one`) and the
augmented triad (`three`) is closed.  Pointwise:

```
  one ↦ two     three ↦ six
  two ↦ two     four  ↦ four
  six ↦ six     twelve ↦ twelve
```

This is candidate `{2,4,6,12}` from §12.6 of the music-anchor memo. -/
def tritoneNucleus : Div12 → Div12
  | one    => two
  | two    => two
  | three  => six
  | four   => four
  | six    => six
  | twelve => twelve

theorem tritoneNucleus_le_self : ∀ a : Div12, a ≤ tritoneNucleus a := by decide

theorem tritoneNucleus_idem :
    ∀ a : Div12, tritoneNucleus (tritoneNucleus a) = tritoneNucleus a := by decide

theorem tritoneNucleus_meet :
    ∀ a b : Div12,
      tritoneNucleus (a ⊓ b) = tritoneNucleus a ⊓ tritoneNucleus b := by decide

/-- **`tritoneNucleus` is a nucleus** — the subobject-level trace of a
Lawvere–Tierney topology on the presheaf topos `Set^{Pᵒᵖ}`. -/
theorem tritoneNucleus_isNucleus : IsNucleus tritoneNucleus :=
  ⟨tritoneNucleus_le_self, tritoneNucleus_idem, tritoneNucleus_meet⟩

/-- The nucleus' kernel image is still the tritone: `tritoneNucleus ⊥ =
tritoneKernel`.  The geometric lift lands on the same kernel as the
reflective one. -/
theorem tritoneNucleus_bot : tritoneNucleus ⊥ = tritoneKernel := by decide

/-- The nucleus' kernel image is non-regular — so the Exploitation cell of
the partition around it is non-empty. -/
theorem tritoneNucleus_bot_non_regular :
    (tritoneNucleus ⊥)ᶜᶜ ≠ tritoneNucleus ⊥ := by decide

/-- Both tritone-closing operators agree on `⊥`: the reflective slice
(`tritoneClosure`) and the geometric slice (`tritoneNucleus`) cut out the
same kernel image, the tritone. -/
theorem tritoneClosure_tritoneNucleus_bot_agree :
    tritoneClosure ⊥ = tritoneNucleus ⊥ := by decide

/-- **The tritone kernel is realized by a Lawvere–Tierney topology
(bundled).**

There is a nucleus `tritoneNucleus` on the divisor lattice of 12 — the
subobject-level trace of a Lawvere–Tierney topology on the T2 presheaf
topos `Set^{Pᵒᵖ}` — whose kernel image is the tritone, a non-regular
element.  Consequently the four-position partition around the music kernel
(`music_anchor_witness`) is realized not merely by a reflective
subcategory but by a *sheaf subtopos*, the genuinely geometric form of the
distinction operation.  The minimal operator `tritoneClosure`, by
contrast, is *not* a nucleus (`tritoneClosure_not_nucleus`): the two lifts
are the reflective and the geometric realizations of the same kernel. -/
theorem tritone_kernel_has_lawvere_tierney_realization :
    IsNucleus tritoneNucleus ∧
    tritoneNucleus ⊥ = tritoneKernel ∧
    (tritoneNucleus ⊥)ᶜᶜ ≠ tritoneNucleus ⊥ ∧
    ¬ IsNucleus tritoneClosure :=
  ⟨tritoneNucleus_isNucleus, tritoneNucleus_bot,
   tritoneNucleus_bot_non_regular, tritoneClosure_not_nucleus⟩

end Div12

end FalseWork.Lattice.Examples
