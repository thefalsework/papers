/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# The Booleanization of an Alexandrov algebra is the power set of its
# minimal elements

The theorem behind the arrangement-check retraction
(`arrangement-check/SPEC.md`, Amendment 2, 2026-09-15): in any finite
poset the double negation of an open depends only on its extremal
layer, so the regular elements are in bijection with subsets of that
layer, at every size, with no geometric content.  The external
reviewer's two-line argument, kernel-checked, in the down-set
convention used throughout this repository (minimal elements play the
role cells played in the up-set presentation of the arrangement
algebra; the two are order-duals).

Proved for any `WellFoundedLT` order — strictly stronger than the
finite case the retraction rests on.

* `LowerSet.mem_compl_iff_min` — negation sees only the minimal layer:
  `x ∈ ¬U` iff no minimal element below `x` lies in `U`.
* `LowerSet.mem_compl_compl_iff` — the forced formula:
  `x ∈ ¬¬U` iff **every** minimal element below `x` lies in `U`.
* `LowerSet.compl_eq_bot_iff_min` — density is exactly containing the
  whole minimal layer (so the dense count is the up-set count of the
  boundary `P ∖ Min`, and the entire four-class census of any such
  algebra reduces to two up-set numbers).
* `minReg_regular`, `regularEquivMinSets` — the Booleanization:
  regular elements correspond bijectively to subsets of the minimal
  layer, `T ↦ {x | every minimal below x lies in T}`.
* `card_regular_eq_two_pow` — the count: `2 ^ #minimals` regulars,
  the "128 = 2⁷, 2048 = 2¹¹" of the scaling census, as a theorem
  about every finite poset at once.
-/
import FalseWorkPapers.Lattice.ObserverClassification

set_option linter.unusedSectionVars false

namespace FalseWork.Lattice

variable {α : Type*} [PartialOrder α]

/-! ## Minimal elements exist below everything (well-founded orders) -/

theorem exists_isMin_le [WellFoundedLT α] (x : α) :
    ∃ m, IsMin m ∧ m ≤ x := by
  induction x using WellFoundedLT.induction with
  | ind x ih =>
    by_cases hx : IsMin x
    · exact ⟨x, hx, le_rfl⟩
    · obtain ⟨y, hy⟩ := not_isMin_iff.mp hx
      obtain ⟨m, hm, hmy⟩ := ih y hy
      exact ⟨m, hm, hmy.trans hy.le⟩

/-! ## Negation and double negation see only the minimal layer -/

/-- Membership in the Heyting complement of a lower set: nothing below
`x` lies in `U`. -/
theorem LowerSet.mem_compl_iff {U : LowerSet α} {x : α} :
    x ∈ (Uᶜ : LowerSet α) ↔ ∀ y, y ≤ x → y ∉ U := by
  rw [← himp_bot, LowerSet.mem_himp_iff]
  constructor
  · intro h y hyx hyU
    simpa using h y hyx hyU
  · intro h y hyx hyU
    exact absurd hyU (h y hyx)

/-- Negation depends only on the minimal layer: `x ∈ ¬U` iff no
minimal element below `x` lies in `U`. -/
theorem LowerSet.mem_compl_iff_min [WellFoundedLT α] {U : LowerSet α}
    {x : α} :
    x ∈ (Uᶜ : LowerSet α) ↔ ∀ m, IsMin m → m ≤ x → m ∉ U := by
  rw [LowerSet.mem_compl_iff]
  constructor
  · intro h m _ hmx
    exact h m hmx
  · intro h y hyx hyU
    obtain ⟨m, hm, hmy⟩ := exists_isMin_le y
    exact h m hm (hmy.trans hyx) (U.lower hmy hyU)

/-- **The forced formula.**  `x ∈ ¬¬U` iff every minimal element below
`x` lies in `U`.  Everything the arrangement scaling census surveyed
is a corollary of this membership equation. -/
theorem LowerSet.mem_compl_compl_iff [WellFoundedLT α] {U : LowerSet α}
    {x : α} :
    x ∈ (Uᶜᶜ : LowerSet α) ↔ ∀ m, IsMin m → m ≤ x → m ∈ U := by
  rw [LowerSet.mem_compl_iff]
  constructor
  · intro h m hm hmx
    have h2 := h m hmx
    rw [LowerSet.mem_compl_iff] at h2
    push Not at h2
    obtain ⟨y, hym, hyU⟩ := h2
    exact le_antisymm hym (hm hym) ▸ hyU
  · intro h y hyx
    rw [LowerSet.mem_compl_iff]
    push Not
    obtain ⟨m, hm, hmy⟩ := exists_isMin_le y
    exact ⟨m, hmy, h m hm (hmy.trans hyx)⟩

/-- **Density is containing the minimal layer.**  With the formula
above, the whole four-class census of a down-set algebra reduces to
two up-set counts: total opens, and opens of the boundary `P ∖ Min`
(the dense ones); regulars are pinned at `2 ^ #Min` by the equivalence
below, and ordinary is the remainder. -/
theorem LowerSet.compl_eq_bot_iff_min [WellFoundedLT α] {U : LowerSet α} :
    (Uᶜ : LowerSet α) = ⊥ ↔ ∀ m, IsMin m → m ∈ U := by
  constructor
  · intro h m hm
    by_contra hmU
    have hmem : m ∈ (Uᶜ : LowerSet α) := by
      rw [LowerSet.mem_compl_iff]
      intro y hym hyU
      exact hmU (le_antisymm hym (hm hym) ▸ hyU)
    rw [h] at hmem
    simp at hmem
  · intro h
    refine SetLike.ext fun x => ?_
    constructor
    · intro hx
      rw [LowerSet.mem_compl_iff] at hx
      obtain ⟨m, hm, hmx⟩ := exists_isMin_le x
      exact absurd (h m hm) (hx m hmx)
    · intro hx
      simp at hx

/-! ## The Booleanization -/

/-- The canonical regular element with prescribed minimal trace `T`:
all points whose every minimal predecessor lies in `T`. -/
def minReg (T : Set {m : α // IsMin m}) : LowerSet α :=
  ⟨{x | ∀ m : {m : α // IsMin m}, (m : α) ≤ x → m ∈ T},
   fun _a _b hba ha m hmb => ha m (hmb.trans hba)⟩

@[simp]
theorem mem_minReg {T : Set {m : α // IsMin m}} {x : α} :
    x ∈ minReg T ↔ ∀ m : {m : α // IsMin m}, (m : α) ≤ x → m ∈ T :=
  Iff.rfl

/-- `minReg T` is regular. -/
theorem minReg_regular [WellFoundedLT α] (T : Set {m : α // IsMin m}) :
    ((minReg T)ᶜᶜ : LowerSet α) = minReg T := by
  refine SetLike.ext fun x => ?_
  rw [LowerSet.mem_compl_compl_iff]
  constructor
  · intro h m hmx
    exact h (m : α) m.2 hmx m le_rfl
  · intro h m hm hmx m' hm'm
    have h2 : (m' : α) = m := le_antisymm hm'm (hm hm'm)
    exact h m' ((le_of_eq h2).trans hmx)

/-- **The Booleanization is the power set of the minimal layer.**
Regular elements of the down-set algebra correspond bijectively to
subsets of the minimal elements.  In the arrangement algebra's up-set
presentation the minimal layer is the set of cells, so this is "Cover's
regions are the Boolean skeleton" — revealed as a fact about Alexandrov
algebras with no arrangement content, which is what forced the
retraction. -/
def regularEquivMinSets [WellFoundedLT α] :
    {U : LowerSet α // (Uᶜᶜ : LowerSet α) = U} ≃ Set {m : α // IsMin m} where
  toFun U := {m | (m : α) ∈ U.1}
  invFun T := ⟨minReg T, minReg_regular T⟩
  left_inv U := by
    refine Subtype.ext (SetLike.ext fun x => ?_)
    constructor
    · intro h
      rw [← U.2, LowerSet.mem_compl_compl_iff]
      intro m hm hmx
      exact h ⟨m, hm⟩ hmx
    · intro h m hmx
      exact U.1.lower hmx h
  right_inv T := by
    ext m
    constructor
    · intro h
      exact h m le_rfl
    · intro h m' hm'm
      have h2 : m' = m := Subtype.ext (le_antisymm hm'm (m.2 hm'm))
      exact h2.symm ▸ h

/-- The count, for the finite case the censuses ran: the regular
elements number exactly `2 ^ #minimals` — the `128 = 2⁷` and
`2048 = 2¹¹` of the scaling run, at every size of every finite poset
at once. -/
theorem card_regular_eq_two_pow [Finite α] :
    Nat.card {U : LowerSet α // (Uᶜᶜ : LowerSet α) = U}
      = 2 ^ Nat.card {m : α // IsMin m} := by
  rw [Nat.card_congr (regularEquivMinSets (α := α))]
  rw [show (Set {m : α // IsMin m}) = ({m : α // IsMin m} → Prop) from rfl]
  rw [Nat.card_fun]
  congr 1
  rw [Nat.card_eq_fintype_card, Fintype.card_prop]

end FalseWork.Lattice
