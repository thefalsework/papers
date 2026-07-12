/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# Why 12: the arithmetic side of the music–logic weld

The weld (`Div12 ≅ Z_6`, `NishimuraTruncations.lean`) says *where* music
landed: on the 6-element truncation of the free Heyting algebra on one
generator.  This file answers the complementary question — *why 12-tone
equal temperament* is the system that lands there — by running the kernel
trichotomy (`allFourCellsInhabited_iff`, `NishimuraKernelLaw.lean`) on the
subgroup lattices of **all** cyclic groups `ℤ/n`.

The subgroup lattice of `ℤ/n` is the divisor lattice of `n`, which is the
product of chains `C_{e₁+1} × ⋯ × C_{eₖ+1}` for `n = p₁^{e₁} ⋯ pₖ^{eₖ}`
(one chain per prime, length = exponent + 1) — a standard identification
**[C]**, kernel-anchored at `n = 12` by `pcset_realizes_subgroup_lattice`
and `div12OrderIsoChains` below.  On these lattices the trichotomy gives:

* **Chains never carry a kernel** (`total_no_kernel`): in any
  totally-ordered Heyting algebra every non-`⊥` element has `⊥`
  complement, so Refusal is uninhabitable.  This covers **every prime
  power** `n = p^k`, all `k`, abstractly — no enumeration.
* **Products of two chains** (`prod_kernel_iff`): the kernels of
  `C × D` are exactly the pairs with one coordinate `⊥` and the other
  strictly internal.  Hence (`chainProd_kernel_exists_iff`,
  `chainProd_kernel_unique_iff`, abstract for all exponents `a, b ≥ 1`):
  - a kernel **exists** iff some exponent is `≥ 2` — squarefree `pq`
    temperaments are degenerate;
  - the kernel is **unique** iff the exponents are `{2, 1}` — i.e. iff
    `n = p²q`.
* **The least `n` of shape `p²q` is 12.**  Every `n < 12` is `1`, a prime
  power (2,3,4,5,7,8,9,11), or squarefree `pq` (6, 10) — elementary
  arithmetic, stated here, not formalized — so no `n < 12` carries a
  kernel, and at `n = 12` the kernel exists and is unique
  (`twelve_kernel_unique`, by `decide`: the unique kernel of `C₃ × C₂` is
  `(1, 0)`).
* **Beyond `p²q` uniqueness fails in every direction**, kernel-checked at
  the boundary shapes: `n = 24 = p³q` (two kernels), `n = 36 = p²q²`
  (two), `n = 60 = p²qr` (three).
* **The kernel at 12 is the tritone.**  `div12OrderIsoChains` is an
  explicit order isomorphism `Div12 ≃o C₃ × C₂` (preserving `⇨` and `ᶜ`,
  by `decide`) carrying the tritone `two` to `(1, 0)` — the unique kernel.

## What this buys

Together with the weld this closes the "you chose 12" objection from the
arithmetic side, the way the all-n law closed "you chose the truncation"
from the logic side:

* **logic**: `Z_6` is the *first* truncation of the free Heyting algebra
  where the partition switches on, unique kernel = free generator;
* **arithmetic**: `12` is the *first* equal temperament whose subgroup
  lattice carries a kernel, and (`12 = p²q` being the uniqueness shape)
  that kernel is unique;

and the two firsts are **the same six-element algebra with the same
kernel** (`Div12 ≅ Z_6 ≅ C₃ × C₂`; tritone = free generator = `(1,0)`).
Neither selection was available to choose.

## Scope honesty

* The two-prime laws are abstract **[K]** for all exponents; the general
  `k`-prime laws (characterization, existence, uniqueness, and the exact
  count `∏(eᵢ+1) − ∏eᵢ − 2^k + 1`) are now also abstract **[K]** in
  `WhyTwelveGeneral.lean` — the sample `p²qr` (`sixty_kernel_three`)
  remains as an instance check of the general law.
* "The divisor lattice models `n`-TET" inherits the framework's standing
  identification of `n`-tone temperament with `ℤ/n` (forced for 12 by the
  music anchor; conventional for other `n`).
* 18 and 20 are also `p²q`: they too have unique kernels (the same
  lattice).  12 is privileged as the **least**, not the only — exactly as
  `Z_6` is the least non-degenerate truncation, not the only one.
-/
import Mathlib.Order.Heyting.Basic
import Mathlib.Order.Fin.Basic
import Mathlib.Data.Fintype.Prod
import FalseWorkPapers.Examples.NishimuraKernelLaw

namespace FalseWork.Lattice

/-! ## 1. Chains never carry a kernel (prime powers, abstractly) -/

section TotalOrders

variable {α : Type*} [HeytingAlgebra α]

/-- In a Heyting algebra whose order is total, every non-`⊥` element has `⊥`
complement: the complement is disjoint from `a`, and in a chain one of two
disjoint elements is `⊥`. -/
theorem compl_eq_bot_of_total (htot : ∀ x y : α, x ≤ y ∨ y ≤ x) {a : α}
    (ha : a ≠ ⊥) : aᶜ = ⊥ := by
  rcases htot a aᶜ with h | h
  · exact absurd (le_bot_iff.mp ((le_inf le_rfl h).trans (inf_compl_self a).le)) ha
  · exact le_bot_iff.mp ((le_inf h le_rfl).trans (inf_compl_self a).le)

/-- **Chains never carry a non-degenerate kernel.**  In a totally-ordered
Heyting algebra — e.g. the divisor lattice of any prime power `p^k` — no
element makes all four cells inhabited: Refusal needs `aᶜ ≠ ⊥`, which in a
chain forces `a = ⊥`, killing Infrastructure.  Covers every prime-power
equal temperament at once, with no enumeration. -/
theorem total_no_kernel (htot : ∀ x y : α, x ≤ y ∨ y ≤ x) (a : α) :
    ¬ AllFourCellsInhabited a := by
  rw [allFourCellsInhabited_iff]
  rintro ⟨h0, hc, -⟩
  exact hc (compl_eq_bot_of_total htot h0)

/-- In a non-trivial chain, `aᶜ ≠ ⊥` happens exactly at `a = ⊥`. -/
theorem compl_ne_bot_iff_of_total (htot : ∀ x y : α, x ≤ y ∨ y ≤ x)
    (hbt : (⊥ : α) ≠ ⊤) (a : α) : aᶜ ≠ ⊥ ↔ a = ⊥ := by
  constructor
  · intro h
    by_contra h0
    exact h (compl_eq_bot_of_total htot h0)
  · rintro rfl
    rw [compl_bot]
    exact fun h => hbt h.symm

/-- In a chain, the regular elements are exactly `⊥` and `⊤`: everything
strictly internal has `⊥` complement, hence `⊤` double complement. -/
theorem compl_compl_eq_iff_of_total (htot : ∀ x y : α, x ≤ y ∨ y ≤ x)
    (a : α) : aᶜᶜ = a ↔ a = ⊥ ∨ a = ⊤ := by
  constructor
  · intro h
    by_contra hcon
    rcases not_or.mp hcon with ⟨h1, h2⟩
    rw [compl_eq_bot_of_total htot h1, compl_bot] at h
    exact h2 h.symm
  · rintro (rfl | rfl) <;> simp

end TotalOrders

/-! ## 2. Kernel characterization on a product of two chains -/

section ProdChains

variable {α β : Type*} [HeytingAlgebra α] [HeytingAlgebra β]

/-- Complements in a product Heyting algebra are componentwise. -/
theorem prod_compl (a : α) (b : β) : ((a, b) : α × β)ᶜ = (aᶜ, bᶜ) := rfl

/-- **Kernels of a product of two chains.**  In `α × β` with both factors
non-trivial totally-ordered Heyting algebras, the four-position kernels are
exactly the pairs with one coordinate `⊥` and the other strictly internal
(`≠ ⊥`, `≠ ⊤`).  The `⊥` coordinate supplies Refusal mass; the internal
coordinate supplies the regularity failure that opens Exploitation. -/
theorem prod_kernel_iff
    (htα : ∀ x y : α, x ≤ y ∨ y ≤ x) (htβ : ∀ x y : β, x ≤ y ∨ y ≤ x)
    (hbtα : (⊥ : α) ≠ ⊤) (hbtβ : (⊥ : β) ≠ ⊤) (a : α) (b : β) :
    AllFourCellsInhabited ((a, b) : α × β) ↔
      (a = ⊥ ∧ b ≠ ⊥ ∧ b ≠ ⊤) ∨ (b = ⊥ ∧ a ≠ ⊥ ∧ a ≠ ⊤) := by
  have hca := compl_ne_bot_iff_of_total htα hbtα a
  have hcb := compl_ne_bot_iff_of_total htβ hbtβ b
  have hra := compl_compl_eq_iff_of_total htα a
  have hrb := compl_compl_eq_iff_of_total htβ b
  rw [allFourCellsInhabited_iff]
  constructor
  · rintro ⟨h0, hc, hr⟩
    replace h0 : ¬ (a = ⊥ ∧ b = ⊥) := by
      rintro ⟨rfl, rfl⟩; exact h0 rfl
    replace hc : a = ⊥ ∨ b = ⊥ := by
      rcases not_and_or.mp
          (fun hand : aᶜ = ⊥ ∧ bᶜ = ⊥ => hc (by rw [prod_compl, hand.1, hand.2]; rfl))
        with h | h
      · exact Or.inl (hca.mp h)
      · exact Or.inr (hcb.mp h)
    replace hr : ¬ ((a = ⊥ ∨ a = ⊤) ∧ (b = ⊥ ∨ b = ⊤)) := by
      rintro ⟨h1, h2⟩
      exact hr (by rw [prod_compl, prod_compl, hra.mpr h1, hrb.mpr h2])
    tauto
  · rintro (⟨rfl, hb0, hb1⟩ | ⟨rfl, ha0, ha1⟩)
    · refine ⟨fun h => hb0 (congrArg Prod.snd h), ?_, ?_⟩
      · rw [prod_compl, compl_bot]
        intro h
        exact hbtα (congrArg Prod.fst h).symm
      · rw [prod_compl, prod_compl]
        intro h
        exact ((hrb.mp (congrArg Prod.snd h)).elim hb0 hb1)
    · refine ⟨fun h => ha0 (congrArg Prod.fst h), ?_, ?_⟩
      · rw [prod_compl, compl_bot]
        intro h
        exact hbtβ (congrArg Prod.snd h).symm
      · rw [prod_compl, prod_compl]
        intro h
        exact ((hra.mp (congrArg Prod.fst h)).elim ha0 ha1)

end ProdChains

/-- Decidability of the product order from decidability of the factors.
(Mathlib has the product `LE` but not this instance; it is the evident one
and is what lets the sweep below run by `decide` rather than by hand.) -/
instance prodDecidableLE {α β : Type*} [LE α] [LE β]
    [DecidableLE α] [DecidableLE β] : DecidableLE (α × β) := fun p q =>
  decidable_of_iff (p.1 ≤ q.1 ∧ p.2 ≤ q.2) Prod.le_def.symm

namespace Examples

/-! ## 3. The equal-temperament sweep

The divisor lattice of `n = p^a q^b` is `Fin (a+1) × Fin (b+1)` (chains of
length exponent + 1).  Mathlib supplies the Heyting structure on both `Fin`
chains (`Fin.instBiheytingAlgebra`) and products (`Prod.instHeytingAlgebra`),
so all of these are honest decidable instances. -/

section Fin

/-- `⊥` of a `Fin` chain is `0`. -/
theorem fin_bot_val {n : ℕ} : ((⊥ : Fin (n + 1)) : ℕ) = 0 := rfl

/-- `⊤` of a `Fin` chain is `n`. -/
theorem fin_top_val {n : ℕ} : ((⊤ : Fin (n + 1)) : ℕ) = n := rfl

theorem fin_bot_ne_top {n : ℕ} (hn : 1 ≤ n) : (⊥ : Fin (n + 1)) ≠ ⊤ := by
  intro h
  have h' := congrArg Fin.val h
  rw [fin_bot_val, fin_top_val] at h'
  omega

/-- **Prime powers `p^k`: no kernel, for every `k`.**  The divisor lattice
is the chain `C_{k+1}`; chains never carry a kernel. -/
theorem primePower_no_kernel (k : ℕ) (a : Fin (k + 1)) :
    ¬ AllFourCellsInhabited a :=
  total_no_kernel le_total a

/-- **Squarefree `pq` (e.g. 6, 10): no kernel** — `C₂ × C₂` has no strictly
internal coordinate.  Kernel-checked exhaustively. -/
theorem squarefree_pq_no_kernel : ∀ a : Fin 2 × Fin 2, ¬ AllFourCellsInhabited a := by
  decide

/-- **`n = 12 = 2²·3`: the unique kernel of `C₃ × C₂` is `(1, 0)`** — the
image of the tritone under `div12OrderIsoChains`.  Kernel-checked
exhaustively. -/
theorem twelve_kernel_unique :
    ∀ a : Fin 3 × Fin 2, AllFourCellsInhabited a ↔ a = (1, 0) := by decide

/-- The mirror shape `q·p²` (same lattice, factors swapped). -/
theorem twelve_mirror_kernel_unique :
    ∀ a : Fin 2 × Fin 3, AllFourCellsInhabited a ↔ a = (0, 1) := by decide

/-- **`n = 24 = 2³·3`: uniqueness fails** — two kernels. -/
theorem twentyfour_kernel_two :
    ∀ a : Fin 4 × Fin 2, AllFourCellsInhabited a ↔ (a = (1, 0) ∨ a = (2, 0)) := by
  decide

/-- **`n = 36 = 2²·3²`: uniqueness fails** — two kernels. -/
theorem thirtysix_kernel_two :
    ∀ a : Fin 3 × Fin 3, AllFourCellsInhabited a ↔ (a = (1, 0) ∨ a = (0, 1)) := by
  decide

/-- **`n = 60 = 2²·3·5`: a third prime multiplies kernels** — three. -/
theorem sixty_kernel_three :
    ∀ a : Fin 3 × Fin 2 × Fin 2, AllFourCellsInhabited a ↔
      (a = (1, 0, 0) ∨ a = (1, 0, 1) ∨ a = (1, 1, 0)) := by
  decide

end Fin

/-! ## 4. The abstract two-prime laws (all exponents at once) -/

section TwoPrimeLaws

/-- **Kernel existence for `n = p^a q^b` (all exponents `a, b ≥ 1`).**  The
divisor lattice `C_{a+1} × C_{b+1}` carries a four-position kernel iff some
exponent is at least 2 — iff `n` is not squarefree. -/
theorem chainProd_kernel_exists_iff {a b : ℕ} (ha : 1 ≤ a) (hb : 1 ≤ b) :
    (∃ z : Fin (a + 1) × Fin (b + 1), AllFourCellsInhabited z) ↔
      2 ≤ a ∨ 2 ≤ b := by
  constructor
  · rintro ⟨⟨x, y⟩, hz⟩
    rw [prod_kernel_iff le_total le_total (fin_bot_ne_top ha) (fin_bot_ne_top hb)] at hz
    rcases hz with ⟨-, hy0, hy1⟩ | ⟨-, hx0, hx1⟩
    · right
      have h0 : (y : ℕ) ≠ 0 := fun h => hy0 (Fin.ext (h.trans fin_bot_val.symm))
      have h1 : (y : ℕ) ≠ b := fun h => hy1 (Fin.ext (h.trans fin_top_val.symm))
      have := y.isLt
      omega
    · left
      have h0 : (x : ℕ) ≠ 0 := fun h => hx0 (Fin.ext (h.trans fin_bot_val.symm))
      have h1 : (x : ℕ) ≠ a := fun h => hx1 (Fin.ext (h.trans fin_top_val.symm))
      have := x.isLt
      omega
  · intro h
    rcases h with h2 | h2
    · refine ⟨((⟨1, by omega⟩ : Fin (a + 1)), ⊥), ?_⟩
      rw [prod_kernel_iff le_total le_total (fin_bot_ne_top ha) (fin_bot_ne_top hb)]
      right
      refine ⟨rfl, fun h => ?_, fun h => ?_⟩
      · have := congrArg Fin.val h
        rw [fin_bot_val] at this
        simp at this
      · have := congrArg Fin.val h
        rw [fin_top_val] at this
        simp at this
        omega
    · refine ⟨((⊥ : Fin (a + 1)), (⟨1, by omega⟩ : Fin (b + 1))), ?_⟩
      rw [prod_kernel_iff le_total le_total (fin_bot_ne_top ha) (fin_bot_ne_top hb)]
      left
      refine ⟨rfl, fun h => ?_, fun h => ?_⟩
      · have := congrArg Fin.val h
        rw [fin_bot_val] at this
        simp at this
      · have := congrArg Fin.val h
        rw [fin_top_val] at this
        simp at this
        omega

/-- A strictly internal first coordinate paired with `⊥` is a kernel. -/
private theorem kernel_left {a b : ℕ} (ha : 1 ≤ a) (hb : 1 ≤ b)
    (v : ℕ) (hv0 : 0 < v) (hva : v < a) :
    AllFourCellsInhabited
      (((⟨v, by omega⟩ : Fin (a + 1)), (⊥ : Fin (b + 1))) : Fin (a + 1) × Fin (b + 1)) := by
  rw [prod_kernel_iff le_total le_total (fin_bot_ne_top ha) (fin_bot_ne_top hb)]
  right
  refine ⟨rfl, fun h => ?_, fun h => ?_⟩
  · have := congrArg Fin.val h
    rw [fin_bot_val] at this
    simp at this
    omega
  · have := congrArg Fin.val h
    rw [fin_top_val] at this
    simp at this
    omega

/-- A strictly internal second coordinate paired with `⊥` is a kernel. -/
private theorem kernel_right {a b : ℕ} (ha : 1 ≤ a) (hb : 1 ≤ b)
    (v : ℕ) (hv0 : 0 < v) (hvb : v < b) :
    AllFourCellsInhabited
      (((⊥ : Fin (a + 1)), (⟨v, by omega⟩ : Fin (b + 1))) : Fin (a + 1) × Fin (b + 1)) := by
  rw [prod_kernel_iff le_total le_total (fin_bot_ne_top ha) (fin_bot_ne_top hb)]
  left
  refine ⟨rfl, fun h => ?_, fun h => ?_⟩
  · have := congrArg Fin.val h
    rw [fin_bot_val] at this
    simp at this
    omega
  · have := congrArg Fin.val h
    rw [fin_top_val] at this
    simp at this
    omega

/-- **Kernel uniqueness for `n = p^a q^b` is exactly the shape `p²q`.**
For all exponents `a, b ≥ 1`: the divisor lattice `C_{a+1} × C_{b+1}` has a
*unique* four-position kernel iff `{a, b} = {2, 1}` — iff `n = p²q`.  The
least such `n` is **12**. -/
theorem chainProd_kernel_unique_iff {a b : ℕ} (ha : 1 ≤ a) (hb : 1 ≤ b) :
    (∃! z : Fin (a + 1) × Fin (b + 1), AllFourCellsInhabited z) ↔
      (a = 2 ∧ b = 1) ∨ (a = 1 ∧ b = 2) := by
  constructor
  · rintro ⟨z, hz, huniq⟩
    by_contra hcon
    have hex : 2 ≤ a ∨ 2 ≤ b :=
      (chainProd_kernel_exists_iff ha hb).mp ⟨z, hz⟩
    have hcase : 3 ≤ a ∨ 3 ≤ b ∨ (a = 2 ∧ b = 2) := by omega
    have hpair : ∀ w₁ w₂ : Fin (a + 1) × Fin (b + 1),
        AllFourCellsInhabited w₁ → AllFourCellsInhabited w₂ → w₁ ≠ w₂ → False :=
      fun w₁ w₂ h₁ h₂ hne => hne ((huniq w₁ h₁).trans (huniq w₂ h₂).symm)
    rcases hcase with h3 | h3 | ⟨rfl, rfl⟩
    · refine hpair _ _ (kernel_left ha hb 1 (by omega) (by omega))
        (kernel_left ha hb 2 (by omega) (by omega)) (fun h => ?_)
      have hv : (1 : ℕ) = 2 :=
        congrArg (fun p : Fin (a + 1) × Fin (b + 1) => (p.1 : ℕ)) h
      omega
    · refine hpair _ _ (kernel_right ha hb 1 (by omega) (by omega))
        (kernel_right ha hb 2 (by omega) (by omega)) (fun h => ?_)
      have hv : (1 : ℕ) = 2 :=
        congrArg (fun p : Fin (a + 1) × Fin (b + 1) => (p.2 : ℕ)) h
      omega
    · refine hpair _ _ (kernel_left ha hb 1 (by omega) (by omega))
        (kernel_right ha hb 1 (by omega) (by omega)) (fun h => ?_)
      have hv : (1 : ℕ) = 0 :=
        congrArg (fun p : Fin (2 + 1) × Fin (2 + 1) => (p.1 : ℕ)) h
      omega
  · rintro (⟨rfl, rfl⟩ | ⟨rfl, rfl⟩)
    · exact ⟨(1, 0), (twelve_kernel_unique _).mpr rfl,
        fun z hz => (twelve_kernel_unique z).mp hz⟩
    · exact ⟨(0, 1), (twelve_mirror_kernel_unique _).mpr rfl,
        fun z hz => (twelve_mirror_kernel_unique z).mp hz⟩

end TwoPrimeLaws

/-! ## 5. The kernel at 12 IS the tritone: `Div12 ≃o C₃ × C₂` -/

namespace Div12

/-- The chain-product coordinates of the music lattice: `(v₂, v₃)` —
2-adic and 3-adic valuations of the subgroup order. -/
def toChains : Div12 → Fin 3 × Fin 2
  | one    => (0, 0)
  | two    => (1, 0)
  | three  => (0, 1)
  | four   => (2, 0)
  | six    => (1, 1)
  | twelve => (2, 1)

/-- Inverse of `toChains`. -/
def ofChains : Fin 3 × Fin 2 → Div12 := fun p =>
  match p with
  | (⟨0, _⟩, ⟨0, _⟩) => one
  | (⟨1, _⟩, ⟨0, _⟩) => two
  | (⟨0, _⟩, ⟨1, _⟩) => three
  | (⟨2, _⟩, ⟨0, _⟩) => four
  | (⟨1, _⟩, ⟨1, _⟩) => six
  | (⟨2, _⟩, ⟨1, _⟩) => twelve

theorem toChains_le_iff : ∀ x y : Div12, toChains x ≤ toChains y ↔ x ≤ y := by
  decide

/-- `toChains` preserves Heyting implication — the iso is a Heyting iso,
not merely an order iso. -/
theorem toChains_himp :
    ∀ x y : Div12, toChains (x ⇨ y) = toChains x ⇨ toChains y := by decide

/-- `toChains` preserves complements. -/
theorem toChains_compl : ∀ x : Div12, toChains xᶜ = (toChains x)ᶜ := by decide

/-- The tritone lands on the unique kernel of `C₃ × C₂`. -/
theorem toChains_tritone : toChains Div12.two = (1, 0) := rfl

/-- **The music lattice is the chain product `C₃ × C₂`** — the divisor
lattice of `12 = 2²·3` in valuation coordinates, as an explicit order
isomorphism (Heyting by `toChains_himp`/`toChains_compl`).  Composed with
the weld this gives `Z_6 ≅ Div12 ≅ C₃ × C₂`: logic's first non-degenerate
truncation and arithmetic's first non-degenerate temperament are the same
object, and `toChains_tritone` + `twelve_kernel_unique` match the unique
kernels. -/
def div12OrderIsoChains : Div12 ≃o Fin 3 × Fin 2 where
  toFun := toChains
  invFun := ofChains
  left_inv := fun x =>
    (by decide : ∀ y : Div12, ofChains (toChains y) = y) x
  right_inv := fun p =>
    (by decide : ∀ q : Fin 3 × Fin 2, toChains (ofChains q) = q) p
  map_rel_iff' := @fun x y => toChains_le_iff x y

end Div12

/-! ## 6. The headline bundle -/

/-- **Why 12 (kernel-checked package).**  Among the equal temperaments
`ℤ/n`, modelled by their divisor lattices:

1. prime powers `p^k` never carry a four-position kernel (all `k`,
   abstract);
2. squarefree `pq` never does (exhaustive);
3. `12 = 2²·3` carries a **unique** kernel — and `12` is the least `n`
   not covered by 1–2 (every `n < 12` is `1`, `p^k`, or `pq`);
4. under `div12OrderIsoChains` that unique kernel **is the tritone**, the
   element `Div12.kernel_unique` already forced from the music side.

With the all-n law (`nishimura_kernel_unique`) this is the two-sided
forcing: logic's least non-degenerate one-generated algebra and
arithmetic's least non-degenerate temperament are the same six-element
object with the same unique kernel. -/
theorem why_twelve :
    (∀ k : ℕ, ∀ a : Fin (k + 1), ¬ AllFourCellsInhabited a) ∧
    (∀ a : Fin 2 × Fin 2, ¬ AllFourCellsInhabited a) ∧
    (∀ a : Fin 3 × Fin 2, AllFourCellsInhabited a ↔ a = (1, 0)) ∧
    Div12.toChains Div12.two = (1, 0) ∧
    (∀ a : Div12, AllFourCellsInhabited a ↔ a = Div12.two) :=
  ⟨primePower_no_kernel, squarefree_pq_no_kernel, twelve_kernel_unique,
    Div12.toChains_tritone, Div12.kernel_unique⟩

end Examples

end FalseWork.Lattice
