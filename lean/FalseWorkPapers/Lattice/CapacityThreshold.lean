/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# The capacity threshold (the work theorem, kernel-checked)

Registered spec: `preprints/aperture/work-theorem-spec.md` (committed
2026-09-13, before this file; oracle `work-theorem/01-capacity-oracle.py`
passed on all 87 posets with ≤ 5 elements, 938 elements, no kill).

**The mathematics is Citkin's** (Logics 2024: Prop. 3 dense → Z₂/Z₃,
Props. 2 + Thm. 6 regular → ≤ Z₅, Prop. 4(c) ordinary → > 5), recorded
as such in the spec before this file was written.  This file is the
[C] → [K] discharge: the first kernel-checked, fully abstract form of
the classification, packaged as a single threshold iff.

* **W1 (`IsSubalgebraSet.dense_closed`).**  For dense `k`, the
  three-element set `{⊥, k, ⊤}` is operation-closed.
* **W2 (`IsSubalgebraSet.regular_closed`).**  For regular `k`, the
  five-element set `{⊥, k, kᶜ, k ⊔ kᶜ, ⊤}` is operation-closed.
* **W3 (`IsOrdinary.six_distinct`).**  For ordinary `k`, the six
  elements `⊥, k, kᶜ, kᶜᶜ, k ⊔ kᶜ, ⊤` are pairwise distinct — a
  direct argument, not Citkin's quotient-by-dense-filter proof.
* **W4 (`isOrdinary_iff_six_le_capacity`).**  `k` is ordinary **iff**
  every operation-closed set containing `k` contains at least six
  elements.  What ordinariness buys: strictly more generated structure
  than any regular or dense element can produce, threshold at six.
-/
import Mathlib.Data.Finset.Card
import FalseWorkPapers.Examples.NishimuraKernelLaw

set_option linter.unusedSectionVars false
set_option linter.unusedSimpArgs false

namespace FalseWork.Lattice

variable {H : Type*} [HeytingAlgebra H]

/-! ## Operation-closed sets (subalgebra carriers) -/

/-- A set closed under the Heyting operations and containing the
bounds: the carrier of a subalgebra.  The capacity of `k` is the size
of the least such set containing `k`. -/
structure IsSubalgebraSet (S : Set H) : Prop where
  bot_mem : (⊥ : H) ∈ S
  top_mem : (⊤ : H) ∈ S
  inf_mem : ∀ ⦃a b : H⦄, a ∈ S → b ∈ S → a ⊓ b ∈ S
  sup_mem : ∀ ⦃a b : H⦄, a ∈ S → b ∈ S → a ⊔ b ∈ S
  himp_mem : ∀ ⦃a b : H⦄, a ∈ S → b ∈ S → a ⇨ b ∈ S

theorem IsSubalgebraSet.compl_mem {S : Set H} (hS : IsSubalgebraSet S)
    {a : H} (ha : a ∈ S) : aᶜ ∈ S := by
  rw [← himp_bot]
  exact hS.himp_mem ha hS.bot_mem

/-! ### Implication endpoint identities (kept local to avoid name
dependence on the ambient Mathlib simp set) -/

private theorem himp_top_eq (x : H) : x ⇨ ⊤ = ⊤ :=
  eq_top_iff.mpr (le_himp_iff.mpr (by simp))

private theorem top_himp_eq (x : H) : ⊤ ⇨ x = x := by
  refine le_antisymm ?_ le_himp
  have h : ((⊤ : H) ⇨ x) ⊓ ⊤ ≤ x := himp_inf_le
  rwa [inf_top_eq] at h

private theorem bot_himp_eq (x : H) : ⊥ ⇨ x = ⊤ :=
  eq_top_iff.mpr (le_himp_iff.mpr (by simp))

/-! ## W1: the dense closure -/

/-- **W1.**  A dense element generates at most `{⊥, k, ⊤}`: the
three-element set is operation-closed (Citkin 2024 Prop. 3, the
`{0, g, 1}` observation, kernel-checked). -/
theorem IsSubalgebraSet.dense_closed {k : H} (hk : kᶜ = ⊥) :
    IsSubalgebraSet ({⊥, k, ⊤} : Set H) := by
  have d1 : k ⇨ ⊥ = ⊥ := by rw [himp_bot, hk]
  refine ⟨by simp, by simp, ?_, ?_, ?_⟩ <;>
  · intro a b ha hb
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at ha hb ⊢
    rcases ha with rfl | rfl | rfl <;> rcases hb with rfl | rfl | rfl <;>
      simp [d1, himp_top_eq, top_himp_eq, bot_himp_eq, himp_self]

/-! ## W2: the regular closure -/

/-- **W2.**  A regular element generates at most
`{⊥, k, kᶜ, k ⊔ kᶜ, ⊤}`: the five-element set is operation-closed
(Citkin 2024 Props. 2/Thm. 6 give the ≤ 5 cap; kernel-checked).  The
two entries that use regularity: `kᶜ ⇨ ⊥ = k` and `kᶜ ⇨ k = k`. -/
theorem IsSubalgebraSet.regular_closed {k : H} (hk : kᶜᶜ = k) :
    IsSubalgebraSet ({⊥, k, kᶜ, k ⊔ kᶜ, ⊤} : Set H) := by
  -- meet identities
  have i1 : k ⊓ kᶜ = ⊥ := disjoint_iff.mp disjoint_compl_right
  have i1' : kᶜ ⊓ k = ⊥ := by rw [inf_comm]; exact i1
  have m1 : k ⊓ (k ⊔ kᶜ) = k := inf_sup_self
  have m2 : (k ⊔ kᶜ) ⊓ k = k := by rw [inf_comm]; exact m1
  have m3 : kᶜ ⊓ (k ⊔ kᶜ) = kᶜ := by
    rw [inf_sup_left, i1', bot_sup_eq, inf_idem]
  have m4 : (k ⊔ kᶜ) ⊓ kᶜ = kᶜ := by rw [inf_comm]; exact m3
  -- join identities
  have j1 : kᶜ ⊔ k = k ⊔ kᶜ := sup_comm _ _
  have j2 : k ⊔ (k ⊔ kᶜ) = k ⊔ kᶜ := by rw [← sup_assoc, sup_idem]
  have j3 : kᶜ ⊔ (k ⊔ kᶜ) = k ⊔ kᶜ := by rw [sup_left_comm, sup_idem]
  have j4 : (k ⊔ kᶜ) ⊔ k = k ⊔ kᶜ := by rw [sup_comm]; exact j2
  have j5 : (k ⊔ kᶜ) ⊔ kᶜ = k ⊔ kᶜ := by rw [sup_assoc, sup_idem]
  -- implication identities
  have i2 : k ⇨ ⊥ = kᶜ := himp_bot k
  have i3 : kᶜ ⇨ ⊥ = k := by rw [himp_bot, hk]
  have i4 : (k ⊔ kᶜ) ⇨ ⊥ = ⊥ := by
    rw [himp_bot, compl_sup, hk, i1']
  have i5 : k ⇨ kᶜ = kᶜ := by
    rw [← himp_bot, himp_himp, inf_idem, himp_bot]
  have i6 : kᶜ ⇨ k = k := by
    refine le_antisymm ?_ le_himp
    have h1 : (kᶜ ⇨ k) ⊓ kᶜ ≤ ⊥ :=
      le_trans (le_inf himp_inf_le inf_le_right) i1.le
    have h2 : kᶜ ⇨ k ≤ kᶜ ⇨ ⊥ := le_himp_iff.mpr h1
    rw [himp_bot, hk] at h2
    exact h2
  have i7 : (k ⊔ kᶜ) ⇨ k = k := by
    rw [sup_himp_distrib, himp_self, i6, top_inf_eq]
  have i8 : (k ⊔ kᶜ) ⇨ kᶜ = kᶜ := by
    rw [sup_himp_distrib, i5, himp_self, inf_top_eq]
  have i9 : k ⇨ (k ⊔ kᶜ) = ⊤ :=
    eq_top_iff.mpr (le_himp_iff.mpr (by simp))
  have i10 : kᶜ ⇨ (k ⊔ kᶜ) = ⊤ :=
    eq_top_iff.mpr (le_himp_iff.mpr (by simp))
  refine ⟨by simp, by simp, ?_, ?_, ?_⟩ <;>
  · intro a b ha hb
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at ha hb ⊢
    rcases ha with rfl | rfl | rfl | rfl | rfl <;>
      rcases hb with rfl | rfl | rfl | rfl | rfl <;>
      simp [i1, i1', m1, m2, m3, m4, j1, j2, j3, j4, j5,
        i2, i3, i4, i5, i6, i7, i8, i9, i10,
        himp_top_eq, top_himp_eq, bot_himp_eq, himp_self]

/-! ## W3: the ordinary floor -/

/-- **W3.**  An ordinary element manufactures six pairwise-distinct
elements: `⊥, k, kᶜ, kᶜᶜ, k ⊔ kᶜ, ⊤`.  A direct argument (Citkin 2024
Prop. 4(c) proves `> 5` by a quotient through the dense filter; here
the six witnesses are explicit).  Distinctness of `k ⊔ kᶜ` from `⊤`
uses distributivity. -/
theorem IsOrdinary.six_distinct {k : H} (hk : IsOrdinary k) :
    (⊥ : H) ≠ k ∧ (⊥ : H) ≠ kᶜ ∧ (⊥ : H) ≠ kᶜᶜ ∧ (⊥ : H) ≠ k ⊔ kᶜ ∧
      (⊥ : H) ≠ ⊤ ∧
    k ≠ kᶜ ∧ k ≠ kᶜᶜ ∧ k ≠ k ⊔ kᶜ ∧ k ≠ ⊤ ∧
    kᶜ ≠ kᶜᶜ ∧ kᶜ ≠ k ⊔ kᶜ ∧ kᶜ ≠ ⊤ ∧
    kᶜᶜ ≠ k ⊔ kᶜ ∧ kᶜᶜ ≠ ⊤ ∧
    k ⊔ kᶜ ≠ ⊤ := by
  obtain ⟨hreg, hden⟩ := hk
  have i1 : k ⊓ kᶜ = ⊥ := disjoint_iff.mp disjoint_compl_right
  have i1' : kᶜ ⊓ k = ⊥ := by rw [inf_comm]; exact i1
  have ic : kᶜ ⊓ kᶜᶜ = ⊥ := disjoint_iff.mp disjoint_compl_right
  have hkbot : k ≠ ⊥ := by
    rintro rfl
    exact hreg (by simp)
  have hktop : k ≠ ⊤ := by
    rintro rfl
    exact hden (by simp)
  refine ⟨Ne.symm hkbot, Ne.symm hden, ?_, ?_, ?_, ?_, Ne.symm hreg,
    ?_, hktop, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · -- ⊥ ≠ kᶜᶜ
    intro h
    exact hkbot (le_bot_iff.mp (by rw [h]; exact le_compl_compl))
  · -- ⊥ ≠ k ⊔ kᶜ
    intro h
    exact hkbot (le_bot_iff.mp (by rw [h]; exact le_sup_left))
  · -- ⊥ ≠ ⊤
    intro h
    exact hden (le_bot_iff.mp (by rw [h]; exact le_top))
  · -- k ≠ kᶜ
    intro h
    refine hkbot (le_bot_iff.mp ?_)
    calc k = k ⊓ k := by rw [inf_idem]
    _ ≤ k ⊓ kᶜ := inf_le_inf_left k h.le
    _ = ⊥ := i1
  · -- k ≠ k ⊔ kᶜ
    intro h
    have hck : kᶜ ≤ k := le_sup_right.trans h.ge
    exact hden (by rw [← inf_eq_left.mpr hck]; exact i1')
  · -- kᶜ ≠ kᶜᶜ
    intro h
    exact hden (by rw [← inf_eq_left.mpr h.le]; exact ic)
  · -- kᶜ ≠ k ⊔ kᶜ
    intro h
    have hkc : k ≤ kᶜ := le_sup_left.trans h.ge
    exact hkbot (by rw [← inf_eq_left.mpr hkc]; exact i1)
  · -- kᶜ ≠ ⊤
    intro h
    have hke : k = k ⊓ kᶜ := by rw [h, inf_top_eq]
    exact hkbot (hke.trans i1)
  · -- kᶜᶜ ≠ k ⊔ kᶜ
    intro h
    have hcc : kᶜ ≤ kᶜᶜ := le_sup_right.trans h.ge
    exact hden (by rw [← inf_eq_left.mpr hcc]; exact ic)
  · -- kᶜᶜ ≠ ⊤
    intro h
    have hce : kᶜ = kᶜ ⊓ kᶜᶜ := by rw [h, inf_top_eq]
    exact hden (hce.trans ic)
  · -- k ⊔ kᶜ ≠ ⊤
    intro h
    refine hreg ?_
    calc kᶜᶜ = kᶜᶜ ⊓ (k ⊔ kᶜ) := by rw [h, inf_top_eq]
    _ = kᶜᶜ ⊓ k ⊔ kᶜᶜ ⊓ kᶜ := by rw [inf_sup_left]
    _ = k ⊔ ⊥ := by
        rw [inf_eq_right.mpr le_compl_compl, inf_comm, ic]
    _ = k := by simp

/-! ## W4: the threshold -/

/-- **W4 (the work theorem).**  An element is ordinary **iff** every
operation-closed set containing it holds at least six elements.
Forward: the six W3 witnesses live in every such set.  Backward: a
regular or dense element sits inside the explicit five- or
three-element closed set of W2/W1, which cannot host six distinct
elements.  What ordinariness buys is generated structure, and the
threshold is six (mathematics: Citkin 2024 + Nishimura; this
packaging and kernel-check are the contribution here). -/
theorem isOrdinary_iff_six_le_capacity (k : H) :
    IsOrdinary k ↔
      ∀ S : Set H, IsSubalgebraSet S → k ∈ S →
        ∃ T : Finset H, ↑T ⊆ S ∧ 6 ≤ T.card := by
  classical
  constructor
  · intro hk S hS hkS
    obtain ⟨n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13,
      n14, n15⟩ := hk.six_distinct
    refine ⟨{⊥, k, kᶜ, kᶜᶜ, k ⊔ kᶜ, ⊤}, ?_, ?_⟩
    · intro x hx
      simp only [Finset.coe_insert, Set.mem_insert_iff,
        Finset.coe_singleton, Set.mem_singleton_iff] at hx
      rcases hx with rfl | rfl | rfl | rfl | rfl | rfl
      · exact hS.bot_mem
      · exact hkS
      · exact hS.compl_mem hkS
      · exact hS.compl_mem (hS.compl_mem hkS)
      · exact hS.sup_mem hkS (hS.compl_mem hkS)
      · exact hS.top_mem
    · have hcard : ({⊥, k, kᶜ, kᶜᶜ, k ⊔ kᶜ, ⊤} : Finset H).card = 6 := by
        rw [Finset.card_insert_of_notMem (by simp [n1, n2, n3, n4, n5]),
          Finset.card_insert_of_notMem (by simp [n6, n7, n8, n9]),
          Finset.card_insert_of_notMem (by simp [n10, n11, n12]),
          Finset.card_insert_of_notMem (by simp [n13, n14]),
          Finset.card_insert_of_notMem (by simp [n15])]
        simp
      omega
  · intro hcap
    by_contra hord
    rw [IsOrdinary, not_and_or, not_ne_iff, not_ne_iff] at hord
    rcases hord with hreg | hden
    · -- regular: the five-element closed set pigeonholes
      obtain ⟨T, hTsub, hTcard⟩ :=
        hcap {⊥, k, kᶜ, k ⊔ kᶜ, ⊤} (IsSubalgebraSet.regular_closed hreg)
          (by simp)
      have hsub : T ⊆ ({⊥, k, kᶜ, k ⊔ kᶜ, ⊤} : Finset H) := by
        intro x hx
        have := hTsub hx
        simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at this
        simp only [Finset.mem_insert, Finset.mem_singleton]
        exact this
      have h5 : ({⊥, k, kᶜ, k ⊔ kᶜ, ⊤} : Finset H).card ≤ 5 := by
        refine le_trans (Finset.card_insert_le _ _) ?_
        refine Nat.succ_le_succ ?_
        refine le_trans (Finset.card_insert_le _ _) ?_
        refine Nat.succ_le_succ ?_
        refine le_trans (Finset.card_insert_le _ _) ?_
        refine Nat.succ_le_succ ?_
        refine le_trans (Finset.card_insert_le _ _) ?_
        simp
      have := (Finset.card_le_card hsub).trans h5
      omega
    · -- dense: the three-element closed set pigeonholes
      obtain ⟨T, hTsub, hTcard⟩ :=
        hcap {⊥, k, ⊤} (IsSubalgebraSet.dense_closed hden) (by simp)
      have hsub : T ⊆ ({⊥, k, ⊤} : Finset H) := by
        intro x hx
        have := hTsub hx
        simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at this
        simp only [Finset.mem_insert, Finset.mem_singleton]
        exact this
      have h3 : ({⊥, k, ⊤} : Finset H).card ≤ 3 := by
        refine le_trans (Finset.card_insert_le _ _) ?_
        refine Nat.succ_le_succ ?_
        refine le_trans (Finset.card_insert_le _ _) ?_
        simp
      have := (Finset.card_le_card hsub).trans h3
      omega

end FalseWork.Lattice
