/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# The bridge: dependency cones as Heyting-algebra elements

Registered spec: `bridge-study/SPEC.md` (committed 2026-09-12 before
the pilot ran; postscript same day).  A dependency graph induces a
poset — dependencies below, base libraries minimal — and its down-sets
form a canonical Heyting algebra (Mathlib's `LowerSet`, Heyting
structure via `CompletelyDistribLattice`).  A package's dependency
cone is the principal down-set, so the program's invariants apply to
it verbatim.  This file kernel-checks the two structural facts the
brute-force pilot confirmed:

* **H1 (`LowerSet.regular_or_dense_of_min`).**  If the poset has a
  global lower bound — a package everything depends on, the libc
  case — then *every* lower set is regular or dense, so no dependency
  cone is ever ordinary.  The abstract half
  (`compl_eq_bot_of_meets_all`: an element meeting every nonzero
  element is dense) holds in any Heyting algebra.

* **H3 (the minimal-motif witnesses).**  The smallest motif with an
  ordinary cone: `b` depends on `p`, `q` isolated.  Down-sets of a
  disjoint union are the product of the down-set lattices, and
  down-sets of an n-chain form an (n+1)-chain, so D(P) is the
  3-chain × 2-chain — Div12's exponent lattice, presented as
  `Π i : Fin 2, Fin (![2, 1] i + 1)` — with ↓p = (1,0), ↓b = (2,0),
  ↓q = (0,1).  Kernel-checked: ↓p is **ordinary** (the quiet
  depended-upon node) while ↓b (the app) and ↓q (the bystander) are
  regular; aperture(↓p) = 1 with aperture(↓b) = aperture(↓q) = 0;
  co-apertures 18, 12, 14.  All seven numbers match the pilot's
  brute-force enumeration digit for digit through an independent
  presentation of the algebra.
-/
import FalseWorkPapers.Lattice.CoApertureClosedForm
import Mathlib.Order.UpperLower.CompleteLattice

set_option linter.unusedSectionVars false

namespace FalseWork.Lattice

/-! ## H1, abstract half: meeting everything forces density -/

section H1Abstract

variable {H : Type*} [HeytingAlgebra H]

/-- In any Heyting algebra, an element that meets every nonzero
element is dense: `u ⊓ uᶜ = ⊥`, so `uᶜ` would be a nonzero element
missed by `u`. -/
theorem compl_eq_bot_of_meets_all {u : H}
    (h : ∀ v : H, v ≠ ⊥ → u ⊓ v ≠ ⊥) : uᶜ = ⊥ := by
  by_contra hne
  exact h uᶜ hne (disjoint_iff.mp disjoint_compl_right)

end H1Abstract

/-! ## H1 on down-set algebras -/

section H1LowerSet

variable {P : Type*} [Preorder P]

/-- A nonempty lower set contains every global lower bound. -/
theorem LowerSet.mem_of_forall_le {m : P} (hm : ∀ x, m ≤ x)
    {U : LowerSet P} (hU : U ≠ ⊥) : m ∈ U := by
  obtain ⟨x, hx⟩ : ∃ x, x ∈ U := by
    by_contra h
    push Not at h
    exact hU (SetLike.ext fun y => by simp [h y])
  exact U.lower (hm x) hx

/-- **H1.**  If the poset has a global lower bound (a package that
everything transitively depends on), every lower set is regular or
dense — `OrdinaryElement` is uninhabited on the dependency-side
algebra.  This is why the pilot's xz motif shows every dependency
cone dense; the surviving structure there is carried by the aperture,
i.e. by ordinariness inside observers' worlds, not in the ambient
algebra. -/
theorem LowerSet.regular_or_dense_of_min (m : P) (hm : ∀ x, m ≤ x)
    (U : LowerSet P) : Uᶜᶜ = U ∨ Uᶜ = ⊥ := by
  by_cases hU : U = ⊥
  · left
    simp [hU]
  · right
    refine compl_eq_bot_of_meets_all fun V hV hUV => ?_
    have hmUV : m ∈ U ⊓ V :=
      ⟨LowerSet.mem_of_forall_le hm hU, LowerSet.mem_of_forall_le hm hV⟩
    rw [hUV] at hmUV
    simp at hmUV

end H1LowerSet

/-! ## H3: the minimal-motif witnesses, kernel-checked

The motif poset is `{p < b} ⊔ {q}`; its down-set algebra is the
3-chain × 2-chain, presented as the exponent lattice
`Π i : Fin 2, Fin (![2, 1] i + 1)` with

  ↓p = (1,0),  ↓b = (2,0),  ↓q = (0,1).

The registered graph reading: ordinariness of `↓p` requires someone
dependency-disjoint from `p` (non-dense — the bystander `q`) *and*
someone outside `p`'s cone entangled with it (non-regular — the
dependent `b`).  Fame (`b`) and isolation (`q`) are both classical. -/

section H3Witnesses

attribute [local instance] piDecidableLE

local instance (n : ℕ) : BiheytingAlgebra (Fin (n + 1)) :=
  LinearOrder.toBiheytingAlgebra (Fin (n + 1))

/-- ↓p = (1,0) is **ordinary**: neither regular nor dense
(`OrdinaryElement` verbatim).  The unique ordinary principal cone in
the motif — the quiet depended-upon node. -/
example :
    (let k := fun i => (⟨![1, 0] i, by fin_cases i <;> norm_num⟩ :
        Fin (![2, 1] i + 1))
     kᶜᶜ ≠ k ∧ kᶜ ≠ ⊥) := by
  decide

/-- ↓b = (2,0) is regular: the dependent (the "app") is classical. -/
example :
    (let k := fun i => (⟨![2, 0] i, by fin_cases i <;> norm_num⟩ :
        Fin (![2, 1] i + 1))
     kᶜᶜ = k) := by
  decide

/-- ↓q = (0,1) is regular: the bystander is classical. -/
example :
    (let k := fun i => (⟨![0, 1] i, by fin_cases i <;> norm_num⟩ :
        Fin (![2, 1] i + 1))
     kᶜᶜ = k) := by
  decide

/-- aperture(↓p) = **1**: exactly one observer keeps the
infrastructure node's ordinariness visible.  (Pilot: 1.) -/
example :
    (Fintype.card {j : (∀ i : Fin 2, Fin (![2, 1] i + 1)) →
        ∀ i : Fin 2, Fin (![2, 1] i + 1) //
        IsNucleus j ∧ Opens j
          (fun i => (⟨![1, 0] i, by fin_cases i <;> norm_num⟩ :
            Fin (![2, 1] i + 1)))} : ℤ) = 1 := by
  rw [aperture_closed_form_pi]
  decide

/-- aperture(↓b) = **0**: no observer's world renders the app
ordinary.  (Pilot: 0.) -/
example :
    (Fintype.card {j : (∀ i : Fin 2, Fin (![2, 1] i + 1)) →
        ∀ i : Fin 2, Fin (![2, 1] i + 1) //
        IsNucleus j ∧ Opens j
          (fun i => (⟨![2, 0] i, by fin_cases i <;> norm_num⟩ :
            Fin (![2, 1] i + 1)))} : ℤ) = 0 := by
  rw [aperture_closed_form_pi]
  decide

/-- aperture(↓q) = **0**: nor the bystander.  (Pilot: 0.) -/
example :
    (Fintype.card {j : (∀ i : Fin 2, Fin (![2, 1] i + 1)) →
        ∀ i : Fin 2, Fin (![2, 1] i + 1) //
        IsNucleus j ∧ Opens j
          (fun i => (⟨![0, 1] i, by fin_cases i <;> norm_num⟩ :
            Fin (![2, 1] i + 1)))} : ℤ) = 0 := by
  rw [aperture_closed_form_pi]
  decide

/-- coaperture(↓p) = **18** = (2³−2)(2²−1).  (Pilot: 18.) -/
example :
    (coaperture (fun i => (⟨![1, 0] i, by fin_cases i <;> norm_num⟩ :
        Fin (![2, 1] i + 1))) : ℤ) = 18 := by
  rw [coaperture_closed_form_pi]
  decide

/-- coaperture(↓b) = **12** = (2³−4)(2²−1).  (Pilot: 12.) -/
example :
    (coaperture (fun i => (⟨![2, 0] i, by fin_cases i <;> norm_num⟩ :
        Fin (![2, 1] i + 1))) : ℤ) = 12 := by
  rw [coaperture_closed_form_pi]
  decide

/-- coaperture(↓q) = **14** = (2³−1)(2²−2).  (Pilot: 14.)  Note ↓p
and ↓q have equal cone size (1) and are separated by every invariant:
ordinary vs regular, aperture 1 vs 0, coaperture 18 vs 14 — the E2
separation phenomenon at minimal scale, kernel-checked. -/
example :
    (coaperture (fun i => (⟨![0, 1] i, by fin_cases i <;> norm_num⟩ :
        Fin (![2, 1] i + 1))) : ℤ) = 14 := by
  rw [coaperture_closed_form_pi]
  decide

end H3Witnesses

end FalseWork.Lattice
