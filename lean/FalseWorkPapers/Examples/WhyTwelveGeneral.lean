/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# The k-prime kernel laws: products of arbitrarily many chains

`WhyTwelve.lean` proves the two-prime laws abstractly (kernel existence and
uniqueness on `C_{a+1} × C_{b+1}` for all exponents) and kernel-checks the
three-prime boundary only at the sample `n = 60`.  This file closes the gap
declared in its "Scope honesty" note: the **general `k`-prime laws**, for
the divisor lattice of `n = p₁^{e₁} ⋯ pₖ^{eₖ}` modelled as the product of
chains `∀ i : Fin k, Fin (eᵢ + 1)` with the pointwise Heyting structure
(`Pi.instHeytingAlgebra`).

Results, all abstract in `k` and the exponent vector `e`:

* **Kernel characterization** (`piChain_kernel_iff`): the four-position
  kernels of a product of non-trivial chains are exactly the points with
  some coordinate `⊥` and some coordinate strictly internal.
* **Existence** (`piChain_kernel_exists_iff`): a kernel exists iff `k ≥ 2`
  and some exponent is `≥ 2` — iff `n` has at least two prime factors and
  is not squarefree.
* **Uniqueness** (`piChain_kernel_unique_iff`): the kernel is unique iff
  `k = 2` with exponents `{2, 1}` — iff `n = p²q`.  In particular **three
  or more primes always break uniqueness**: the `sixty_kernel_three`
  sample generalizes to a law.
* **The count formula** (`piChain_kernel_card`): the number of kernels is
  exactly `∏(eᵢ+1) − ∏eᵢ − 2^k + 1` (stated additively over ℕ:
  `card + ∏eᵢ + 2^k = ∏(eᵢ+1) + 1`).  The two-prime instance is
  `(a−1) + (b−1)` and the uniqueness law is the corollary `count = 1 ↔
  {a,b} = {2,1}`; the formula also shows the count grows with every extra
  prime, quantifying the "kernels multiply" slogan.

The inclusion–exclusion behind the count: non-kernels are the points with
no `⊥` coordinate (`∏eᵢ` of them) or all coordinates in `{⊥,⊤}` (`2^k`),
overlapping exactly at `⊤` (1 point).

The proofs use decidable case splits (`Decidable.not_forall` / `by_cases`)
rather than classical negation pushing; the audit reports
`[propext, Classical.choice, Quot.sound]`, identical to the existing
two-prime sweep (`chainProd_kernel_unique_iff`, `twelve_kernel_unique`):
`Classical.choice` enters through Mathlib's `Fin`/`Fintype` instances, not
through any argument in this file.
-/
import Mathlib.Order.Heyting.Basic
import Mathlib.Order.Fin.Basic
import Mathlib.Data.Fintype.BigOperators
import Mathlib.Data.Fintype.Sum
import Mathlib.Data.Fin.VecNotation
import FalseWorkPapers.Examples.WhyTwelve

namespace FalseWork.Lattice

namespace Examples

section PiChains

variable {k : ℕ} {e : Fin k → ℕ}

/-- Decidability of the pointwise order on a finite product (Mathlib has the
`Pi` order but not this instance; it is the evident one). -/
instance piChainDecidableLE {ι : Type*} [Fintype ι] {π : ι → Type*}
    [∀ i, LE (π i)] [∀ i, DecidableLE (π i)] : DecidableLE (∀ i, π i) :=
  fun x y => decidable_of_iff (∀ i, x i ≤ y i) Pi.le_def.symm

/-- Complements in a product Heyting algebra are componentwise. -/
theorem pi_compl_apply (x : ∀ i, Fin (e i + 1)) (i : Fin k) :
    xᶜ i = (x i)ᶜ := by
  rw [← himp_bot, ← himp_bot]; rfl

private theorem mk_ne_bot {n v : ℕ} (hv : 0 < v) (h : v < n + 1) :
    (⟨v, h⟩ : Fin (n + 1)) ≠ ⊥ := by
  intro hb
  have h0 : v = 0 := by
    rw [show v = (⟨v, h⟩ : Fin (n + 1)).val from rfl, hb, fin_bot_val]
  omega

private theorem mk_ne_top {n v : ℕ} (hv : v < n) (h : v < n + 1) :
    (⟨v, h⟩ : Fin (n + 1)) ≠ ⊤ := by
  intro ht
  have h0 : v = n := by
    rw [show v = (⟨v, h⟩ : Fin (n + 1)).val from rfl, ht, fin_top_val]
  omega

/-- A strictly internal coordinate value has `0 < v < eᵢ`, so the chain at
that coordinate has length `≥ 3`, i.e. exponent `≥ 2`. -/
private theorem internal_exponent {i : Fin k} {v : Fin (e i + 1)}
    (h0 : v ≠ ⊥) (h1 : v ≠ ⊤) : 2 ≤ e i := by
  have hv0 : (v : ℕ) ≠ 0 := fun h => h0 (Fin.ext (h.trans fin_bot_val.symm))
  have hv1 : (v : ℕ) ≠ e i := fun h => h1 (Fin.ext (h.trans fin_top_val.symm))
  have := v.isLt
  omega

/-! ## 1. The kernel characterization -/

/-- **Kernels of a product of non-trivial chains.**  A point of
`∀ i, Fin (eᵢ + 1)` (all `eᵢ ≥ 1`) makes all four cells inhabited iff some
coordinate is `⊥` (supplying Refusal mass) and some coordinate is strictly
internal (supplying the regularity failure that opens Exploitation).  The
`k = 2` case is `prod_kernel_iff` in curried form. -/
theorem piChain_kernel_iff (he : ∀ i, 1 ≤ e i) (x : ∀ i, Fin (e i + 1)) :
    AllFourCellsInhabited x ↔
      (∃ i, x i = ⊥) ∧ (∃ j, x j ≠ ⊥ ∧ x j ≠ ⊤) := by
  rw [allFourCellsInhabited_iff]
  constructor
  · rintro ⟨-, hc, hr⟩
    constructor
    · obtain ⟨i, hi⟩ : ∃ i, ¬ xᶜ i = ⊥ := by
        by_cases hall : ∀ i, xᶜ i = ⊥
        · exact absurd (funext hall) hc
        · exact Decidable.not_forall.mp hall
      rw [pi_compl_apply] at hi
      exact ⟨i, (compl_ne_bot_iff_of_total le_total
        (fin_bot_ne_top (he i)) (x i)).mp hi⟩
    · obtain ⟨j, hj⟩ : ∃ j, ¬ xᶜᶜ j = x j := by
        by_cases hall : ∀ j, xᶜᶜ j = x j
        · exact absurd (funext hall) hr
        · exact Decidable.not_forall.mp hall
      rw [pi_compl_apply, pi_compl_apply] at hj
      have := (compl_compl_eq_iff_of_total (le_total (α := Fin (e j + 1)))
        (x j)).not.mp hj
      exact ⟨j, fun h => this (Or.inl h), fun h => this (Or.inr h)⟩
  · rintro ⟨⟨i, hi⟩, ⟨j, hj0, hj1⟩⟩
    refine ⟨fun h => hj0 (congrFun h j), fun h => ?_, fun h => ?_⟩
    · have := congrFun h i
      rw [pi_compl_apply, hi, compl_bot] at this
      exact fin_bot_ne_top (he i) this.symm
    · have := congrFun h j
      rw [pi_compl_apply, pi_compl_apply] at this
      exact ((compl_compl_eq_iff_of_total le_total (x j)).mp this).elim hj0 hj1

/-! ## 2. Spike witnesses -/

/-- The single-spike point: value `v` at coordinate `i`, `⊥` elsewhere. -/
def spike (e : Fin k → ℕ) (i : Fin k) (v : ℕ) (hv : v < e i + 1) :
    ∀ l, Fin (e l + 1) :=
  fun l => if h : l = i then ⟨v, by rw [h]; exact hv⟩ else ⊥

theorem spike_at (e : Fin k → ℕ) (i : Fin k) (v : ℕ) (hv : v < e i + 1) :
    spike e i v hv i = ⟨v, hv⟩ := by
  simp only [spike]
  exact dif_pos trivial

theorem spike_ne (e : Fin k → ℕ) (i : Fin k) (v : ℕ) (hv : v < e i + 1)
    {l : Fin k} (hl : l ≠ i) : spike e i v hv l = ⊥ := by
  simp only [spike]
  rw [dif_neg hl]

/-- A spike with a strictly internal value is a kernel, provided a second
coordinate exists to carry the `⊥`. -/
theorem spike_kernel (he : ∀ i, 1 ≤ e i) {i j : Fin k} (hji : j ≠ i)
    {v : ℕ} (hv0 : 0 < v) (hvi : v < e i) :
    AllFourCellsInhabited (spike e i v (by omega)) := by
  rw [piChain_kernel_iff he]
  refine ⟨⟨j, spike_ne e i v _ hji⟩, ⟨i, ?_, ?_⟩⟩
  · rw [spike_at]; exact mk_ne_bot hv0 _
  · rw [spike_at]; exact mk_ne_top hvi _

/-- Two spikes at the same coordinate with different values differ. -/
theorem spike_ne_spike_of_val_ne {i : Fin k} {v w : ℕ}
    {hv : v < e i + 1} {hw : w < e i + 1} (hvw : v ≠ w) :
    spike e i v hv ≠ spike e i w hw := by
  intro h
  have := congrFun h i
  rw [spike_at, spike_at] at this
  exact hvw (congrArg Fin.val this)

/-- Two spikes at different coordinates with nonzero values differ. -/
theorem spike_ne_spike_of_ne {i j : Fin k} (hij : i ≠ j) {v w : ℕ}
    {hv : v < e i + 1} {hw : w < e j + 1} (hv0 : 0 < v) :
    spike e i v hv ≠ spike e j w hw := by
  intro h
  have := congrFun h i
  rw [spike_at, spike_ne e j w _ hij] at this
  exact mk_ne_bot hv0 hv this

/-- The double-spike point: value `v` at `i`, `⊤` at `j`, `⊥` elsewhere. -/
def spikeTop (e : Fin k → ℕ) (i j : Fin k) (v : ℕ) (hv : v < e i + 1) :
    ∀ l, Fin (e l + 1) :=
  fun l => if h : l = i then ⟨v, by rw [h]; exact hv⟩
           else if l = j then ⊤ else ⊥

theorem spikeTop_at (e : Fin k → ℕ) (i j : Fin k) (v : ℕ) (hv : v < e i + 1) :
    spikeTop e i j v hv i = ⟨v, hv⟩ := by
  simp only [spikeTop]
  exact dif_pos trivial

theorem spikeTop_at_top (e : Fin k → ℕ) {i j : Fin k} (hji : j ≠ i)
    (v : ℕ) (hv : v < e i + 1) : spikeTop e i j v hv j = ⊤ := by
  simp only [spikeTop]
  rw [dif_neg hji]
  exact if_pos trivial

theorem spikeTop_ne (e : Fin k → ℕ) {i j l : Fin k} (hli : l ≠ i)
    (hlj : l ≠ j) (v : ℕ) (hv : v < e i + 1) : spikeTop e i j v hv l = ⊥ := by
  simp only [spikeTop]
  rw [dif_neg hli, if_neg hlj]

/-- The double spike is a kernel provided a *third* coordinate carries `⊥`. -/
theorem spikeTop_kernel (he : ∀ i, 1 ≤ e i) {i j l : Fin k}
    (hli : l ≠ i) (hlj : l ≠ j) {v : ℕ}
    (hv0 : 0 < v) (hvi : v < e i) :
    AllFourCellsInhabited (spikeTop e i j v (by omega)) := by
  rw [piChain_kernel_iff he]
  refine ⟨⟨l, spikeTop_ne e hli hlj v _⟩, ⟨i, ?_, ?_⟩⟩
  · rw [spikeTop_at]; exact mk_ne_bot hv0 _
  · rw [spikeTop_at]; exact mk_ne_top hvi _

/-! ## 3. Existence: `k ≥ 2` and some exponent `≥ 2` -/

/-- **Kernel existence for `n = p₁^{e₁} ⋯ pₖ^{eₖ}` (all `k`, all exponents
`≥ 1`).**  The divisor lattice carries a four-position kernel iff `n` has at
least two prime factors and is not squarefree.  Generalizes
`chainProd_kernel_exists_iff` (the `k = 2` case) and `total_no_kernel`
(the `k = 1` case, where `2 ≤ k` fails). -/
theorem piChain_kernel_exists_iff (he : ∀ i, 1 ≤ e i) :
    (∃ x : ∀ i, Fin (e i + 1), AllFourCellsInhabited x) ↔
      2 ≤ k ∧ ∃ i, 2 ≤ e i := by
  constructor
  · rintro ⟨x, hx⟩
    rw [piChain_kernel_iff he] at hx
    obtain ⟨⟨i, hi⟩, ⟨j, hj0, hj1⟩⟩ := hx
    have hij : i ≠ j := fun h => hj0 (h ▸ hi)
    refine ⟨?_, j, internal_exponent hj0 hj1⟩
    have h2 : 1 < Fintype.card (Fin k) := Fintype.one_lt_card_iff.mpr ⟨i, j, hij⟩
    rw [Fintype.card_fin] at h2
    omega
  · rintro ⟨hk, i, hi⟩
    have : Nontrivial (Fin k) := Fin.nontrivial_iff_two_le.mpr hk
    obtain ⟨j, hj⟩ := exists_ne i
    exact ⟨spike e i 1 (by have := he i; omega),
      spike_kernel he hj (by omega) (by omega)⟩

/-! ## 4. Uniqueness: exactly the shape `p²q`, for every `k` -/

/-- With `k ≥ 3` primes, a kernel is never alone: spike and double-spike
witnesses at the same internal coordinate differ at the `⊤` coordinate. -/
theorem piChain_two_kernels (he : ∀ i, 1 ≤ e i) (hk : 3 ≤ k)
    {i : Fin k} (hi : 2 ≤ e i) :
    ∃ x y : ∀ l, Fin (e l + 1),
      AllFourCellsInhabited x ∧ AllFourCellsInhabited y ∧ x ≠ y := by
  obtain ⟨j₁, hj₁, j₂, hj₂, hj₁₂⟩ :
      ∃ j₁ ∈ Finset.univ.erase i, ∃ j₂ ∈ Finset.univ.erase i, j₁ ≠ j₂ := by
    apply Finset.one_lt_card.mp
    rw [Finset.card_erase_of_mem (Finset.mem_univ i), Finset.card_univ,
      Fintype.card_fin]
    omega
  have hj₁i : j₁ ≠ i := Finset.ne_of_mem_erase hj₁
  have hj₂i : j₂ ≠ i := Finset.ne_of_mem_erase hj₂
  refine ⟨spike e i 1 (by omega), spikeTop e i j₁ 1 (by omega),
    spike_kernel he hj₁i (by omega) (by omega),
    spikeTop_kernel he hj₂i hj₁₂.symm (by omega) (by omega), ?_⟩
  · intro h
    have := congrFun h j₁
    rw [spike_ne e i 1 _ hj₁i, spikeTop_at_top e hj₁i 1 _] at this
    exact fin_bot_ne_top (he j₁) this

/-- **Kernel uniqueness is exactly the shape `p²q`, for every number of
primes.**  For `n = p₁^{e₁} ⋯ pₖ^{eₖ}` (all exponents `≥ 1`), the divisor
lattice has a *unique* four-position kernel iff `k = 2` and the exponents
are `{2, 1}` — iff `n = p²q`.  This upgrades `chainProd_kernel_unique_iff`
from a two-prime law to the global law: **three or more primes always break
uniqueness**, so `p²q` is forced without any restriction on the factor
count.  The least such `n` remains **12**. -/
theorem piChain_kernel_unique_iff (he : ∀ i, 1 ≤ e i) :
    (∃! x : ∀ i, Fin (e i + 1), AllFourCellsInhabited x) ↔
      k = 2 ∧ ∃ i j : Fin k, i ≠ j ∧ e i = 2 ∧ e j = 1 := by
  constructor
  · rintro ⟨x, hx, huniq⟩
    have hpair : ∀ w₁ w₂ : ∀ l, Fin (e l + 1),
        AllFourCellsInhabited w₁ → AllFourCellsInhabited w₂ → w₁ ≠ w₂ → False :=
      fun w₁ w₂ h₁ h₂ hne => hne ((huniq w₁ h₁).trans (huniq w₂ h₂).symm)
    obtain ⟨hk2, i, hi⟩ := (piChain_kernel_exists_iff he).mp ⟨x, hx⟩
    have hk3 : ¬ 3 ≤ k := by
      intro hk3
      obtain ⟨w₁, w₂, h₁, h₂, hne⟩ := piChain_two_kernels he hk3 hi
      exact hpair w₁ w₂ h₁ h₂ hne
    have hk : k = 2 := by omega
    have : Nontrivial (Fin k) := Fin.nontrivial_iff_two_le.mpr hk2
    obtain ⟨j, hji⟩ := exists_ne i
    refine ⟨hk, i, j, fun h => hji h.symm, ?_, ?_⟩
    · -- e i = 2: a third rung at i would give a second spike kernel
      by_cases h3 : 3 ≤ e i
      · exact (hpair _ _ (spike_kernel he hji (v := 1) (by omega) (by omega))
          (spike_kernel he hji (v := 2) (by omega) (by omega))
          (spike_ne_spike_of_val_ne (by omega))).elim
      · omega
    · -- e j = 1: an internal rung at j would give a kernel spiked at j
      by_cases h2 : 2 ≤ e j
      · exact (hpair _ _ (spike_kernel he hji (v := 1) (by omega) (by omega))
          (spike_kernel he (i := j) (j := i) (fun h => hji h.symm)
            (v := 1) (by omega) (by omega))
          (spike_ne_spike_of_ne (fun h => hji h.symm) (by omega))).elim
      · have := he j; omega
  · rintro ⟨hk, i, j, hij, hei, hej⟩
    subst hk
    have hcover : ∀ l : Fin 2, l = i ∨ l = j := by
      intro l
      have hne : (i : ℕ) ≠ (j : ℕ) := fun h => hij (Fin.ext h)
      have h1 := i.isLt
      have h2 := j.isLt
      have h3 := l.isLt
      have : (l : ℕ) = (i : ℕ) ∨ (l : ℕ) = (j : ℕ) := by omega
      exact this.elim (fun h => Or.inl (Fin.ext h)) (fun h => Or.inr (Fin.ext h))
    refine ⟨spike e i 1 (by omega),
      spike_kernel he (fun h => hij h.symm) (by omega) (by omega), ?_⟩
    intro y hy
    rw [piChain_kernel_iff he] at hy
    obtain ⟨⟨l₀, hl₀⟩, ⟨m, hm0, hm1⟩⟩ := hy
    -- the internal coordinate must be i (the chain at j is C₂)
    have hmi : m = i := by
      rcases hcover m with h | h
      · exact h
      · exfalso
        have h2 := internal_exponent hm0 hm1
        rw [h] at h2
        omega
    rw [hmi] at hm0 hm1
    -- and its value must be 1 (the chain at i is C₃)
    have hyi : y i = ⟨1, by omega⟩ := by
      have hv0 : (y i : ℕ) ≠ 0 := fun h => hm0 (Fin.ext (h.trans fin_bot_val.symm))
      have hv1 : (y i : ℕ) ≠ e i := fun h => hm1 (Fin.ext (h.trans fin_top_val.symm))
      have hlt := (y i).isLt
      apply Fin.ext
      show (y i : ℕ) = 1
      omega
    -- the ⊥ coordinate must then be j
    have hyj : y j = ⊥ := by
      rcases hcover l₀ with h | h
      · exfalso
        rw [h, hyi] at hl₀
        exact mk_ne_bot (by omega) _ hl₀
      · rwa [h] at hl₀
    funext l
    rcases hcover l with h | h <;> subst h
    · rw [hyi, spike_at]
    · rw [hyj, spike_ne e i 1 _ hij.symm]

/-! ## 5. The count formula -/

private theorem not_internal_iff {n : ℕ} (v : Fin (n + 1)) :
    ¬ (v ≠ ⊥ ∧ v ≠ ⊤) ↔ v = ⊥ ∨ v = ⊤ := by
  by_cases h0 : v = ⊥
  · simp [h0]
  · by_cases h1 : v = ⊤ <;> simp [h0, h1]

/-- **The kernel count formula** (stated additively over ℕ, hence exactly):
on the product of `k` non-trivial chains with exponents `e₁, …, eₖ`,

  `#kernels = ∏(eᵢ+1) − ∏eᵢ − 2^k + 1`.

Inclusion–exclusion on the complement of the characterization
`piChain_kernel_iff`: the non-kernels are the points with **no `⊥`
coordinate** (`∏eᵢ`) or **all coordinates in `{⊥,⊤}`** (`2^k`), overlapping
exactly at `⊤`.  Two-prime instance: `(a+1)(b+1) − ab − 4 + 1 = a + b − 2`,
which is `1` iff `{a,b} = {2,1}` — recovering the `p²q` law.  Each extra
prime multiplies `∏(eᵢ+1) − ∏eᵢ` faster than it doubles `2^k`, so the count
strictly grows: the quantitative form of "kernels multiply". -/
theorem piChain_kernel_card (he : ∀ i, 1 ≤ e i) :
    Fintype.card {x : ∀ i, Fin (e i + 1) // AllFourCellsInhabited x}
        + (∏ i, e i) + 2 ^ k
      = (∏ i, (e i + 1)) + 1 := by
  set A : Finset (∀ i, Fin (e i + 1)) :=
    Finset.univ.filter (fun x => ∀ i, ¬ x i = ⊥) with hAdef
  set B : Finset (∀ i, Fin (e i + 1)) :=
    Finset.univ.filter (fun x => ∀ i, x i = ⊥ ∨ x i = ⊤) with hBdef
  -- (i) the non-kernels are exactly A ∪ B
  have hunion : A ∪ B = Finset.univ.filter (fun x => ¬ AllFourCellsInhabited x) := by
    ext x
    simp only [hAdef, hBdef, Finset.mem_union, Finset.mem_filter,
      Finset.mem_univ, true_and]
    rw [piChain_kernel_iff he]
    constructor
    · rintro (hA | hB)
      · rintro ⟨⟨i, hi⟩, -⟩; exact hA i hi
      · rintro ⟨-, ⟨j, hj⟩⟩; exact (not_internal_iff (x j)).mpr (hB j) hj
    · intro h
      by_cases hall : ∀ i, ¬ x i = ⊥
      · exact Or.inl hall
      · right
        obtain ⟨i, hi⟩ := Decidable.not_forall.mp hall
        rw [Decidable.not_not] at hi
        intro j
        by_cases hj0 : x j = ⊥
        · exact Or.inl hj0
        · by_cases hj1 : x j = ⊤
          · exact Or.inr hj1
          · exact absurd ⟨⟨i, hi⟩, ⟨j, hj0, hj1⟩⟩ h
  -- (ii) kernels + non-kernels = everything
  have hsplit :
      (Finset.univ.filter (fun x : ∀ i, Fin (e i + 1) =>
          AllFourCellsInhabited x)).card
        + (A ∪ B).card
      = Fintype.card (∀ i, Fin (e i + 1)) := by
    rw [hunion, ← Finset.card_univ]
    exact Finset.card_filter_add_card_filter_not _
  -- (iii) inclusion–exclusion
  have hui : (A ∪ B).card + (A ∩ B).card = A.card + B.card :=
    Finset.card_union_add_card_inter A B
  -- (iv) the overlap is exactly {⊤}
  have hAB : A ∩ B = {⊤} := by
    ext x
    simp only [hAdef, hBdef, Finset.mem_inter, Finset.mem_filter,
      Finset.mem_univ, true_and, Finset.mem_singleton]
    constructor
    · rintro ⟨h1, h2⟩
      funext i
      exact (h2 i).resolve_left (h1 i)
    · rintro rfl
      exact ⟨fun i h => fin_bot_ne_top (he i) h.symm, fun i => Or.inr rfl⟩
  -- (v) |A| = ∏ eᵢ
  have hAcard : A.card = ∏ i, e i := by
    rw [hAdef, ← Fintype.card_subtype]
    rw [Fintype.card_congr
      (Equiv.subtypePiEquivPi (p := fun i (v : Fin (e i + 1)) => ¬ v = ⊥))]
    rw [Fintype.card_pi]
    refine Finset.prod_congr rfl fun i _ => ?_
    rw [Fintype.card_subtype_compl, Fintype.card_subtype_eq, Fintype.card_fin]
    omega
  -- (vi) |B| = 2^k
  have hBcard : B.card = 2 ^ k := by
    rw [hBdef, ← Fintype.card_subtype]
    rw [Fintype.card_congr
      (Equiv.subtypePiEquivPi (p := fun i (v : Fin (e i + 1)) => v = ⊥ ∨ v = ⊤))]
    rw [Fintype.card_pi]
    rw [Finset.prod_congr rfl fun i (_ : i ∈ Finset.univ) =>
      Fintype.card_subtype_eq_or_eq_of_ne (fin_bot_ne_top (he i))]
    rw [Finset.prod_const, Finset.card_univ, Fintype.card_fin]
  -- (vii) total = ∏ (eᵢ + 1)
  have htot : Fintype.card (∀ i, Fin (e i + 1)) = ∏ i, (e i + 1) := by
    rw [Fintype.card_pi]
    exact Finset.prod_congr rfl fun i _ => Fintype.card_fin _
  -- assemble
  have hK : Fintype.card {x : ∀ i, Fin (e i + 1) // AllFourCellsInhabited x}
      = (Finset.univ.filter (fun x : ∀ i, Fin (e i + 1) =>
          AllFourCellsInhabited x)).card :=
    Fintype.card_subtype _
  have hABcard : (A ∩ B).card = 1 := by rw [hAB]; exact Finset.card_singleton _
  omega

/-- The count formula in subtraction form (ℕ-subtraction is exact here since
the additive identity bounds the subtrahends). -/
theorem piChain_kernel_card_eq (he : ∀ i, 1 ≤ e i) :
    Fintype.card {x : ∀ i, Fin (e i + 1) // AllFourCellsInhabited x}
      = (∏ i, (e i + 1)) + 1 - (∏ i, e i) - 2 ^ k := by
  have := piChain_kernel_card he
  omega

end PiChains

/-! ## 6. Kernel-checked instances of the count formula

The formula against the exhaustively checked temperaments of
`WhyTwelve.lean`: `12 = 2²·3` (1 kernel), `24 = 2³·3` (2), `36 = 2²·3²`
(2), `60 = 2²·3·5` (3), and `210 = 2·3·5·7` — squarefree with four primes,
where the formula gives `16 − 1 − 16 + 1 = 0`. -/

example :  -- n = 12 : (2+1)(1+1) − 2·1 − 2² + 1 = 1
    Fintype.card {x : ∀ i, Fin (![2, 1] i + 1) // AllFourCellsInhabited x}
      = 1 := by decide

example :  -- n = 24 : (3+1)(1+1) − 3·1 − 2² + 1 = 2
    Fintype.card {x : ∀ i, Fin (![3, 1] i + 1) // AllFourCellsInhabited x}
      = 2 := by decide

example :  -- n = 36 : (2+1)(2+1) − 2·2 − 2² + 1 = 2
    Fintype.card {x : ∀ i, Fin (![2, 2] i + 1) // AllFourCellsInhabited x}
      = 2 := by decide

example :  -- n = 60 : (2+1)(1+1)(1+1) − 2·1·1 − 2³ + 1 = 3
    Fintype.card {x : ∀ i, Fin (![2, 1, 1] i + 1) // AllFourCellsInhabited x}
      = 3 := by decide

example :  -- n = 210 = 2·3·5·7 : squarefree, 2⁴ − 1 − 2⁴ + 1 = 0
    Fintype.card {x : ∀ i, Fin (![1, 1, 1, 1] i + 1) // AllFourCellsInhabited x}
      = 0 := by decide

/-- **The unique-kernel law at `12`, through the general machinery.**
`12 = 2²·3` has exponent vector `(2, 1)` on two primes, which satisfies the
`p²q` shape, so the kernel is unique — now derived from the all-`k` law
rather than the two-prime law. -/
theorem twelve_unique_via_general :
    ∃! x : ∀ i, Fin (![2, 1] i + 1), AllFourCellsInhabited x :=
  (piChain_kernel_unique_iff (by decide)).mpr
    ⟨rfl, 0, 1, by decide, by decide, by decide⟩

end Examples

end FalseWork.Lattice
