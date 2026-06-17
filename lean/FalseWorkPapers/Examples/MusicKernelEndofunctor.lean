/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# Music-kernel endofunctor on finite subsets of `ℝ/ℤ` — Points 2–3

Paper 3 §4 and claims `music-kernel-02`–`03` formalize the accumulation
endofunctor `D(X) = X ∪ (X + α)` on **C**, the poset of finite subsets of
the unit circle, for `α = log₂(3/2)` realized on `AddCircle 1`.

* **Point 2:** `Fix(D) = {∅}`.
* **Point 3:** no terminal object in **C** (hence no terminal `D`-coalgebra).

Point 4 (colimit escape / density) is in `MusicKernelEndofunctorColimit.lean`.
-/
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Set.Finite.Basic
import Mathlib.Topology.Instances.AddCircle.Defs
import FalseWorkPapers.Examples.MusicKernelIrrationality

namespace FalseWork.MusicKernel

open scoped AddCircle
open AddCircle Finset

noncomputable section

/-- The music-kernel step `α = log₂(3/2)` on the unit circle. -/
def αCircle : UnitAddCircle :=
  (α : UnitAddCircle)

/-- **Accumulation** `D(S) = S ∪ (S + α)` on finite subsets of `ℝ/ℤ`. -/
def D (S : Finset UnitAddCircle) : Finset UnitAddCircle :=
  S ∪ S.image (· + αCircle)

theorem D_empty : D (∅ : Finset UnitAddCircle) = ∅ := by
  simp [D]

theorem D_mono {S T : Finset UnitAddCircle} (h : S ⊆ T) : D S ⊆ D T := by
  intro x hx
  simp only [D, mem_union, mem_image] at hx ⊢
  rcases hx with hx | ⟨y, hy, rfl⟩
  · exact Or.inl (h hx)
  · exact Or.inr ⟨y, h hy, rfl⟩

private theorem αCircle_nsmul_injective :
    Function.Injective fun n : ℕ => n • αCircle := by
  intro m n hmn
  have hmn' : m • αCircle = n • αCircle := by simpa using hmn
  obtain hle | hle := le_total m n
  · rcases eq_or_lt_of_le hle with rfl | hk
    · rfl
    · have h0 : (n - m) • αCircle = 0 := by
        have hcombine : (n - m) • αCircle + m • αCircle = n • αCircle := by
          calc (n - m) • αCircle + m • αCircle
              = (n - m + m) • αCircle := (add_nsmul _ _ _).symm
            _ = n • αCircle := by rw [Nat.sub_add_cancel (Nat.le_of_lt hk)]
        have hsum : n • αCircle + (n - m) • αCircle = n • αCircle := by
          rw [add_comm]
          simpa [hmn'] using hcombine
        exact add_left_cancel (hsum.trans (Eq.symm (add_zero (n • αCircle))))
      have hfin : IsOfFinAddOrder αCircle :=
        (isOfFinAddOrder_iff_nsmul_eq_zero).2 ⟨n - m, Nat.sub_pos_of_lt hk, h0⟩
      obtain ⟨q, hq⟩ := (isOfFinAddOrder_iff_exists_rat_eq_div (p := (1 : ℝ))).1 hfin
      simp at hq
      have hmem : α ∈ Set.range Rat.cast := by
        rw [← hq]
        exact Set.mem_range_self q
      exact absurd hmem log_three_halves_irrational
  · rcases eq_or_lt_of_le hle with rfl | hk
    · rfl
    · have h0 : (m - n) • αCircle = 0 := by
        have hcombine : (m - n) • αCircle + n • αCircle = m • αCircle := by
          calc (m - n) • αCircle + n • αCircle
              = (m - n + n) • αCircle := (add_nsmul _ _ _).symm
            _ = m • αCircle := by rw [Nat.sub_add_cancel (Nat.le_of_lt hk)]
        have hsum : m • αCircle + (m - n) • αCircle = m • αCircle := by
          rw [add_comm]
          simpa [hmn'.symm] using hcombine
        exact add_left_cancel (hsum.trans (Eq.symm (add_zero (m • αCircle))))
      have hfin : IsOfFinAddOrder αCircle :=
        (isOfFinAddOrder_iff_nsmul_eq_zero).2 ⟨m - n, Nat.sub_pos_of_lt hk, h0⟩
      obtain ⟨q, hq⟩ := (isOfFinAddOrder_iff_exists_rat_eq_div (p := (1 : ℝ))).1 hfin
      simp at hq
      have hmem : α ∈ Set.range Rat.cast := by
        rw [← hq]
        exact Set.mem_range_self q
      exact absurd hmem log_three_halves_irrational

theorem D_fix_eq_empty :
    ∀ S : Finset UnitAddCircle, D S = S → S = ∅ := by
  intro S h
  by_contra hne
  obtain ⟨x, hx⟩ := S.nonempty_of_ne_empty hne
  have horbit : ∀ n : ℕ, x + n • αCircle ∈ S := by
    intro n
    induction n with
    | zero => simpa using hx
    | succ n ih =>
      have hstep : (x + n • αCircle) + αCircle ∈ S := by
        rw [← h, D, mem_union]
        exact Or.inr (mem_image_of_mem _ ih)
      simpa [add_assoc, add_nsmul, one_nsmul] using hstep
  have hinj : Function.Injective fun n : ℕ => x + n • αCircle := by
    intro m n hmn
    exact αCircle_nsmul_injective ((add_right_inj x).1 hmn)
  have hsub : (Finset.range (S.card + 1)).image (fun n => x + n • αCircle) ⊆ S := by
    intro z hz
    obtain ⟨n, _, rfl⟩ := Finset.mem_image.mp hz
    exact horbit n
  have hcard_image :
      ((Finset.range (S.card + 1)).image (fun n => x + n • αCircle)).card = S.card + 1 := by
    rw [Finset.card_image_of_injective, Finset.card_range]
    exact hinj
  have hcard : S.card + 1 ≤ S.card := by
    rw [← hcard_image]
    exact Finset.card_le_card hsub
  linarith

theorem D_fix_singleton_empty :
    {S : Finset UnitAddCircle | D S = S} = {∅} := by
  ext S
  simp only [Set.mem_setOf_eq, Set.mem_singleton_iff]
  constructor
  · exact D_fix_eq_empty S
  · intro h; subst h; ext x; simp [D]

private instance unitAddCircle_infinite : Infinite UnitAddCircle :=
  Infinite.of_injective (fun n : ℕ => n • αCircle) αCircle_nsmul_injective

private theorem exists_notMem_finset (A : Finset UnitAddCircle) :
    ∃ x : UnitAddCircle, x ∉ A := by
  by_contra hall
  push Not at hall
  have huniv : (A : Set UnitAddCircle) = Set.univ := by
    ext x
    simp [hall x, Set.mem_univ]
  have hfin : (A : Set UnitAddCircle).Finite := A.finite_toSet
  rw [huniv] at hfin
  exact Set.infinite_univ hfin

/-- **No terminal object** in **C** (poset of finite subsets under inclusion). -/
theorem no_largest_finite_subset :
    ¬ ∃ A : Finset UnitAddCircle, ∀ S : Finset UnitAddCircle, S ⊆ A := by
  intro ⟨A, hA⟩
  obtain ⟨x, hx⟩ := exists_notMem_finset A
  exact hx (hA {x} (by simp))

/-- **Lambek consequence:** a terminal `D`-coalgebra would lie in `Fix(D) = {∅}`; `∅` is not terminal. -/
theorem no_terminal_coalgebra :
    (∀ S, D S = S → S = ∅) ∧
    {S : Finset UnitAddCircle | D S = S} = {∅} ∧
    ¬ ∃ A : Finset UnitAddCircle, ∀ S : Finset UnitAddCircle, S ⊆ A := by
  refine ⟨D_fix_eq_empty, D_fix_singleton_empty, no_largest_finite_subset⟩

theorem music_kernel_endofunctor_points_two_three :
    (∀ S, D S = S → S = ∅) ∧
    {S : Finset UnitAddCircle | D S = S} = {∅} ∧
    ¬ ∃ A : Finset UnitAddCircle, ∀ S : Finset UnitAddCircle, S ⊆ A :=
  no_terminal_coalgebra

end

end FalseWork.MusicKernel
