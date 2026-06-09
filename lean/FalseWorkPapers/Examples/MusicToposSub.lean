/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# `Sub_{Set^{Pᵒᵖ}}(1) ≅ Div12` as a Mathlib-level order isomorphism

This file closes item (i) of the "two residual fine-grained steps"
(`connecting-the-spine.md` §5.1a / `MusicTopos.lean` header): it exhibits an
explicit order isomorphism

```
  Subobject (⊤_ MusicTopos) ≃o Div12
```

between the subobject lattice of the terminal object of the concrete music
presheaf topos `Set^{Pᵒᵖ}` and the music algebra `Div12` (the divisor lattice
of 12 / subgroup lattice of `ℤ/12`), in Mathlib's `Subobject` API — not merely
at the down-set level of `birkhoff_representation`.

## The chain

The isomorphism is assembled from three pieces, all kernel-checked:

1. `Subobject (⊤_ MusicTopos) ≃o Subobject oneF` — transport along the
   canonical iso `⊤_ ≅ oneF` between the abstract terminal object and the
   explicit constant-`PUnit` presheaf `oneF` (both terminal), via
   `Subobject.mapIsoToOrderIso`.
2. `Subobject oneF ≃o Subfunctor oneF` — Mathlib's
   `Subfunctor.orderIsoSubobject` (subobjects of a type-valued functor are its
   subfunctors), inverted.
3. `Subfunctor oneF ≃o Div12` — the **down-set correspondence**, built here by
   hand: a subfunctor of the constant-`PUnit` presheaf on `Pᵒᵖ` is exactly a
   down-set of `P` (a `Set PUnit` at each object, compatible with restriction =
   down-closed), and down-sets of `P` are `Div12` via `birkhoff`.

Step 3 is the mathematical content; it is the `Subobject`-API upgrade of
`birkhoff_representation`, which had established the iso only at the level of
`Finset`-down-sets `O(P)`.
-/
import FalseWorkPapers.Examples.MusicTopos
import Mathlib.CategoryTheory.Subfunctor.Subobject

namespace FalseWork.Lattice.Examples

namespace Div12

open CategoryTheory CategoryTheory.Limits Opposite

/-- The explicit terminal presheaf `1` of the music topos: the constant
`PUnit`-valued presheaf on `Pᵒᵖ`. `Functor.isTerminalConst` witnesses that it
is terminal. -/
abbrev oneF : MusicTopos := (Functor.const Pᵒᵖ).obj PUnit

/-! ## `Set PUnit` helpers -/

private lemma mem_ite_top_bot (p : Prop) [Decidable p] (x : PUnit) :
    (x ∈ (if p then (⊤ : Set PUnit) else ⊥)) ↔ p := by
  by_cases h : p <;> simp [h]

private lemma setPUnit_le (s t : Set PUnit) :
    s ≤ t ↔ (PUnit.unit ∈ s → PUnit.unit ∈ t) := by
  constructor
  · intro h hs; exact h hs
  · intro h x hx; obtain rfl := Subsingleton.elim x PUnit.unit; exact h hx

private instance oneF_obj_subsingleton (U : Pᵒᵖ) : Subsingleton (oneF.obj U) :=
  inferInstanceAs (Subsingleton PUnit)

/-! ## `fromDownset ∘ birkhoff = id` (the missing round-trip) -/

/-- `fromDownset` is a left inverse of `birkhoff` (the complement of
`birkhoff_fromDownset`). -/
theorem fromDownset_birkhoff (a : Div12) : fromDownset (birkhoff a) = a := by
  revert a; decide

/-! ## The subfunctor attached to a lattice element -/

/-- The subfunctor of `1` attached to `a : Div12`: "true" at the
join-irreducible `p` iff `p ≤ a` (i.e. `p ∈ birkhoff a`). The down-set
condition on the restriction maps is exactly `birkhoff_isDownset`. -/
def divToSub (a : Div12) : Subfunctor oneF where
  obj U := if U.unop ∈ birkhoff a then (⊤ : Set PUnit) else ⊥
  map {U V} i x hx := by
    have hle : V.unop ≤ U.unop := leOfHom i.unop
    have hU : U.unop ∈ birkhoff a := (mem_ite_top_bot _ x).mp hx
    have hV : V.unop ∈ birkhoff a := birkhoff_isDownset a _ hU _ hle
    rw [Set.mem_preimage, Subsingleton.elim (oneF.map i x) (PUnit.unit : oneF.obj V)]
    exact (mem_ite_top_bot _ _).mpr hV

@[simp] lemma mem_divToSub (a : Div12) (U : Pᵒᵖ) :
    (PUnit.unit ∈ (divToSub a).obj U) ↔ U.unop ∈ birkhoff a :=
  mem_ite_top_bot _ _

/-! ## The support of a subfunctor -/

open scoped Classical in
/-- The `Finset` of join-irreducibles at which a subfunctor of `1` is
non-empty — its "support". -/
noncomputable def subSupp (S : Subfunctor oneF) : Finset JoinIrr :=
  Finset.univ.filter (fun j => (PUnit.unit : PUnit) ∈ S.obj (op j))

open scoped Classical in
lemma mem_subSupp (S : Subfunctor oneF) (j : JoinIrr) :
    j ∈ subSupp S ↔ (PUnit.unit : PUnit) ∈ S.obj (op j) := by
  simp [subSupp]

/-- The support of a subfunctor of `1` is a down-set of `P`: this is the
down-closure forced by the restriction maps of the subfunctor. -/
lemma subSupp_isDownset (S : Subfunctor oneF) : IsDownset (subSupp S) := by
  intro x hx y hyx
  rw [mem_subSupp] at hx ⊢
  have hsub := S.map (homOfLE hyx).op hx
  rw [Set.mem_preimage,
    Subsingleton.elim (oneF.map (homOfLE hyx).op PUnit.unit) (PUnit.unit : oneF.obj (op y))]
    at hsub
  exact hsub

/-- The lattice element attached to a subfunctor of `1`: the join of its
support. -/
noncomputable def subToDiv (S : Subfunctor oneF) : Div12 := fromDownset (subSupp S)

/-! ## The order isomorphism `Div12 ≃o Subfunctor 1` -/

/-- **`Div12 ≅ Subfunctor (1)` as bounded lattices.**  The music algebra is
order-isomorphic to the lattice of subfunctors of the terminal presheaf of
`Set^{Pᵒᵖ}` (equivalently, the down-sets of `P`). -/
noncomputable def divEquivSub : Div12 ≃o Subfunctor oneF where
  toFun := divToSub
  invFun := subToDiv
  left_inv a := by
    have hsupp : subSupp (divToSub a) = birkhoff a := by
      ext j
      rw [mem_subSupp, mem_divToSub, unop_op]
    show fromDownset (subSupp (divToSub a)) = a
    rw [hsupp, fromDownset_birkhoff]
  right_inv S := by
    have hb : birkhoff (subToDiv S) = subSupp S :=
      birkhoff_fromDownset _ (subSupp_isDownset S)
    refine Subfunctor.ext (funext fun U => ?_)
    apply Set.ext
    intro x
    obtain rfl := Subsingleton.elim x (PUnit.unit : oneF.obj U)
    show (PUnit.unit ∈ (if U.unop ∈ birkhoff (subToDiv S) then (⊤ : Set PUnit) else ⊥)) ↔
        PUnit.unit ∈ S.obj U
    rw [mem_ite_top_bot, hb, mem_subSupp, op_unop]
  map_rel_iff' {a b} := by
    show divToSub a ≤ divToSub b ↔ a ≤ b
    rw [birkhoff_mono]
    constructor
    · intro h p hp
      have hle := (Subfunctor.le_def _ _).mp h (op p)
      have himp := (setPUnit_le _ _).mp hle
      have h1 : PUnit.unit ∈ (divToSub a).obj (op p) :=
        (mem_divToSub a (op p)).mpr (by rw [unop_op]; exact hp)
      have h3 := (mem_divToSub b (op p)).mp (himp h1)
      rwa [unop_op] at h3
    · intro h
      rw [Subfunctor.le_def]
      intro U
      refine (setPUnit_le _ _).mpr ?_
      intro hU
      exact (mem_divToSub b U).mpr (h ((mem_divToSub a U).mp hU))

/-- `Subfunctor (1) ≃o Div12` (the inverse of `divEquivSub`). -/
noncomputable def subEquivDiv12 : Subfunctor oneF ≃o Div12 := divEquivSub.symm

/-! ## The headline isomorphism on `Subobject (⊤_ MusicTopos)` -/

/-- The canonical iso between the abstract terminal object of the music topos
and the explicit constant-`PUnit` terminal presheaf `oneF`. -/
noncomputable def terminalIsoOne : (⊤_ MusicTopos) ≅ oneF :=
  terminalIsTerminal.uniqueUpToIso (Functor.isTerminalConst _ Types.isTerminalPUnit)

/-- **`Sub_{Set^{Pᵒᵖ}}(1) ≅ Div12` in Mathlib's `Subobject` API.**

The subobject lattice of the terminal object of the concrete music presheaf
topos `Set^{Pᵒᵖ}` is order-isomorphic to the music algebra `Div12` (the divisor
lattice of 12 / subgroup lattice of `ℤ/12`).  This upgrades
`birkhoff_representation` — which gave the iso at the down-set level `O(P)` — to
an isomorphism of the actual `Subobject` lattice of a Lean topos object, closing
item (i) of `connecting-the-spine.md` §5.1a. -/
noncomputable def subobjectTerminalEquivDiv12 :
    Subobject (⊤_ MusicTopos) ≃o Div12 :=
  (Subobject.mapIsoToOrderIso terminalIsoOne).trans
    ((Subfunctor.orderIsoSubobject oneF).symm.trans subEquivDiv12)

end Div12

end FalseWork.Lattice.Examples
