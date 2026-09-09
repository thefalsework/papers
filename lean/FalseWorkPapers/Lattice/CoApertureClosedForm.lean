/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# The co-aperture closed form

Registered spec: `preprints/aperture/coaperture-spec.md` (committed
2026-09-09, before this file existed).  The aperture counts the
observers under which a kernel stays ordinary — what survives.  This
file adds the dual ledger: what each observer destroys.

A nucleus does not delete; it conflates.  The interval `[k, j k]` is
exactly the set of elements the observer `j` cannot distinguish from
`k` from above (E0, `IsNucleus.le_apply_iff`) — the phantom, not the
blind spot.  Its cardinality is the **phantom mass** of `k` under `j`,
and the **co-aperture** of `k` is the total phantom mass over all
observers:

  coaperture k = Σ over nuclei j of |Icc k (j k)|.

Results, matching the registered expectations:

* **E0 (`IsNucleus.le_apply_iff`).**  For `k ≤ x`:
  `x ≤ j k ↔ j x = j k`.  Two lines from inflationary + monotone +
  idempotent, on any `SemilatticeInf`.

* **E1 (`coaperture_chain_add`).**  On `Fin (m+1)`:
  `coaperture e + 2^e = 2^(m+1)` — the chain closed form, by double
  counting pairs (observer, conflated element).

* **E2 (`coaperture_pi`).**  On a finite product, the co-aperture is
  the product of the per-coordinate co-apertures: nuclei factor
  componentwise (`nucleusPiEquiv`) and `Pi.card_Icc` turns the
  phantom interval into a product.  Note the contrast with the
  aperture, which needs inclusion–exclusion to assemble; the
  co-aperture is exactly multiplicative.

* **E3 (`coaperture_closed_form_pi`).**  On the exponent lattice of
  `Div(p₁^{a₁} ⋯ p_r^{a_r})` with kernel `k`:
  `coaperture k = ∏ᵢ (2^{aᵢ+1} − 2^{kᵢ})`, over ℤ.

* **E4 (the independence witnesses, kernel-checked).**  Neither
  invariant determines the other.  Div24 = 2³·3: kernels 2 = (1,0)
  and 4 = (2,0) have the same aperture (3, nonzero) and different
  co-apertures (42, 36).  Div72 = 2³·3²: kernels 4 = (2,0) and
  6 = (1,1) have the same co-aperture (84) and different apertures
  (9, 6).  The survival count and the destruction ledger are
  independent coordinates on kernels.
-/
import FalseWorkPapers.Lattice.ApertureClosedFormPi
import Mathlib.Data.Pi.Interval

set_option linter.unusedSectionVars false

namespace FalseWork.Lattice

/-! ## E0: the confusion class -/

section ConfusionClass

variable {H : Type*} [SemilatticeInf H] {j : H → H}

/-- Everything in `[k, j k]` is sent to `j k`: the observer conflates
the whole interval with `k`. -/
theorem IsNucleus.apply_eq_of_le_of_le_apply (hj : IsNucleus j) {k x : H}
    (hkx : k ≤ x) (hxjk : x ≤ j k) : j x = j k :=
  le_antisymm (hj.le_of_fix (hj.2.1 k) hxjk) (hj.monotone hkx)

/-- **The confusion-class lemma (E0).**  For `k ≤ x`, membership in
`[k, j k]` is exactly indistinguishability from `k` under `j`.  The
interval is the phantom: confident false presence, not absence. -/
theorem IsNucleus.le_apply_iff (hj : IsNucleus j) {k x : H} (hkx : k ≤ x) :
    x ≤ j k ↔ j x = j k :=
  ⟨fun h => hj.apply_eq_of_le_of_le_apply hkx h,
   fun h => (hj.1 x).trans (le_of_eq h)⟩

end ConfusionClass

/-! ## The definitions -/

section Defs

variable {H : Type*} [SemilatticeInf H] [LocallyFiniteOrder H]

/-- The **phantom mass** of `k` under the observer `j`: the size of
the interval `[k, j k]`, i.e. (by E0) the number of elements at or
above `k` that `j` cannot distinguish from `k`.  Always ≥ 1; equals 1
iff `j` fixes `k`. -/
def phantomMass (j : H → H) (k : H) : ℕ := (Finset.Icc k (j k)).card

variable [Fintype H] [DecidableEq H] [DecidableLE H]

/-- The **co-aperture** of `k`: total phantom mass over all
observers.  The dual ledger to the aperture — not which observers keep
`k` ordinary, but how much confusion each observer manufactures at
`k`, summed. -/
def coaperture (k : H) : ℕ :=
  ∑ j : {j : H → H // IsNucleus j}, phantomMass j.1 k

end Defs

/-! ## Counting helpers -/

section Helpers

private theorem card_filter_subtype' {γ : Type*} [Fintype γ]
    (P Q : γ → Prop) [DecidablePred P] [DecidablePred Q] :
    (Finset.univ.filter fun x : {x // P x} => Q x.1).card
      = Fintype.card {x : γ // P x ∧ Q x} := by
  rw [← Fintype.card_subtype]
  exact Fintype.card_congr (Equiv.subtypeSubtypeEquivSubtypeInter P Q)

private theorem sum_range_two_pow (N : ℕ) :
    (∑ t ∈ Finset.range N, 2 ^ t) + 1 = 2 ^ N := by
  induction N with
  | zero => rfl
  | succ n ih =>
    rw [Finset.sum_range_succ, pow_succ]
    omega

end Helpers

/-! ## E1: the chain closed form -/

section Chain

variable {α : Type*} [LinearOrder α] [Fintype α] [BoundedOrder α]

local instance : BiheytingAlgebra α := LinearOrder.toBiheytingAlgebra α

/-- `x` lies at or below the image of `e` under the observer `F` iff
no member of `F` separates them: every fixed point at or above `e` is
already at or above `x`. -/
theorem le_chainNucleus_iff {F : Finset α} (htop : ⊤ ∈ F) {e x : α} :
    x ≤ chainNucleus F htop e ↔ ∀ f ∈ F, e ≤ f → x ≤ f := by
  constructor
  · intro h f hf hef
    exact h.trans (chainNucleus_le htop hf hef)
  · intro h
    exact h _ (chainNucleus_mem htop e) (le_chainNucleus htop e)

end Chain

section ChainFin

local instance (n : ℕ) : BiheytingAlgebra (Fin (n + 1)) :=
  LinearOrder.toBiheytingAlgebra (Fin (n + 1))

/-- The per-element count: for `e ≤ x`, the observers that conflate
`x` with `e` (i.e. `x ≤ j e`) are exactly the top-sets avoiding
`Ico e x`, and they number `2^(m − (x − e))`. -/
private theorem count_conflating_topsets (m : ℕ) (e x : Fin (m + 1))
    (hex : e ≤ x) :
    (∑ F : {F : Finset (Fin (m + 1)) // ⊤ ∈ F},
        if x ≤ chainNucleus F.1 F.2 e then 1 else 0)
      = 2 ^ (m - ((x : ℕ) - (e : ℕ))) := by
  -- rewrite the condition into a form independent of the `⊤ ∈ F` proof
  have hcong : (∑ F : {F : Finset (Fin (m + 1)) // ⊤ ∈ F},
        if x ≤ chainNucleus F.1 F.2 e then 1 else 0)
      = ∑ F : {F : Finset (Fin (m + 1)) // ⊤ ∈ F},
          if (∀ f ∈ F.1, e ≤ f → x ≤ f) then 1 else 0 :=
    Finset.sum_congr rfl fun F _ => by
      rw [if_congr (le_chainNucleus_iff F.2) rfl rfl]
  rw [hcong]
  -- sum of indicators = subtype count
  have hcard : (∑ F : {F : Finset (Fin (m + 1)) // ⊤ ∈ F},
        if (∀ f ∈ F.1, e ≤ f → x ≤ f) then 1 else 0)
      = Fintype.card {F : Finset (Fin (m + 1)) //
          ⊤ ∈ F ∧ ∀ f ∈ F, e ≤ f → x ≤ f} := by
    rw [← card_filter_subtype' (fun F : Finset (Fin (m + 1)) => ⊤ ∈ F)
      (fun F => ∀ f ∈ F, e ≤ f → x ≤ f), Finset.card_filter]
  rw [hcard, card_topSets_filter]
  -- the `insert ⊤` is harmless (`⊤` satisfies the condition), and the
  -- surviving predicate turns the filter into a powerset
  have hset : ((Finset.univ.erase (⊤ : Fin (m + 1))).powerset).filter
        (fun G => ∀ f ∈ insert (⊤ : Fin (m + 1)) G, e ≤ f → x ≤ f)
      = ((Finset.univ.erase (⊤ : Fin (m + 1))).filter
          fun f => e ≤ f → x ≤ f).powerset := by
    ext G
    simp only [Finset.mem_filter, Finset.mem_powerset]
    constructor
    · rintro ⟨hGS, h⟩ y hyG
      exact Finset.mem_filter.mpr
        ⟨hGS hyG, h y (Finset.mem_insert_of_mem hyG)⟩
    · intro hGT
      refine ⟨fun y hyG => (Finset.mem_filter.mp (hGT hyG)).1, ?_⟩
      intro f hf hef
      rcases Finset.mem_insert.mp hf with rfl | hfG
      · exact le_top
      · exact (Finset.mem_filter.mp (hGT hfG)).2 hef
  rw [hset, Finset.card_powerset]
  congr 1
  -- the complement of the allowed set inside the non-top elements is `Ico e x`
  have hnot : ((Finset.univ.erase (⊤ : Fin (m + 1))).filter
        fun f => ¬(e ≤ f → x ≤ f))
      = Finset.Ico e x := by
    ext f
    simp only [Finset.mem_filter, Finset.mem_erase, Finset.mem_univ,
      and_true, Finset.mem_Ico, Classical.not_imp, not_le]
    constructor
    · rintro ⟨-, hef, hfx⟩
      exact ⟨hef, hfx⟩
    · rintro ⟨hef, hfx⟩
      exact ⟨ne_top_of_lt hfx, hef, hfx⟩
  have hsplit : ((Finset.univ.erase (⊤ : Fin (m + 1))).filter
        fun f => e ≤ f → x ≤ f).card
      + ((Finset.univ.erase (⊤ : Fin (m + 1))).filter
          fun f => ¬(e ≤ f → x ≤ f)).card
      = (Finset.univ.erase (⊤ : Fin (m + 1))).card :=
    Finset.card_filter_add_card_filter_not ..
  rw [hnot, fin_card_nontop, Fin.card_Ico] at hsplit
  have hxm : (x : ℕ) ≤ m := Nat.lt_succ_iff.mp x.isLt
  have hexn : (e : ℕ) ≤ (x : ℕ) := hex
  omega

/-- **E1: the chain closed form (additive).**  On `Fin (m+1)` with
kernel exponent `e`: `coaperture e + 2^e = 2^(m+1)`. -/
theorem coaperture_chain_add (m : ℕ) (e : Fin (m + 1)) :
    coaperture e + 2 ^ (e : ℕ) = 2 ^ (m + 1) := by
  -- transfer the sum from nuclei to top-sets (along the *inverse*
  -- classification, so the transported summand is definitionally the
  -- phantom mass of the induced nucleus)
  have h1 : coaperture e
      = ∑ F : {F : Finset (Fin (m + 1)) // ⊤ ∈ F},
          (Finset.Icc e (chainNucleus F.1 F.2 e)).card := by
    unfold coaperture
    exact (Fintype.sum_equiv nucleusEquivTopSets.symm
      (fun F : {F : Finset (Fin (m + 1)) // ⊤ ∈ F} =>
        (Finset.Icc e (chainNucleus F.1 F.2 e)).card)
      (fun j => phantomMass j.1 e) (fun F => rfl)).symm
  -- interval cardinality as an indicator sum over the whole chain
  have h2 : ∀ F : {F : Finset (Fin (m + 1)) // ⊤ ∈ F},
      (Finset.Icc e (chainNucleus F.1 F.2 e)).card
        = ∑ x : Fin (m + 1),
            if e ≤ x ∧ x ≤ chainNucleus F.1 F.2 e then 1 else 0 := by
    intro F
    rw [← Finset.card_filter]
    congr 1
    ext x
    simp [Finset.mem_Icc]
  -- swap the two sums and evaluate the inner count
  have h3 : coaperture e
      = ∑ x : Fin (m + 1),
          if e ≤ x then 2 ^ (m - ((x : ℕ) - (e : ℕ))) else 0 := by
    rw [h1, Finset.sum_congr rfl fun F _ => h2 F, Finset.sum_comm]
    refine Finset.sum_congr rfl fun x _ => ?_
    by_cases hex : e ≤ x
    · rw [if_pos hex, ← count_conflating_topsets m e x hex]
      refine Finset.sum_congr rfl fun F _ => ?_
      rw [if_congr (and_iff_right hex) rfl rfl]
    · rw [if_neg hex]
      refine Finset.sum_eq_zero fun F _ => ?_
      rw [if_neg (fun h => hex h.1)]
  -- convert the Fin sum to a ℕ range sum
  have h4 : (∑ x : Fin (m + 1),
        if e ≤ x then 2 ^ (m - ((x : ℕ) - (e : ℕ))) else 0)
      = ∑ n ∈ Finset.range (m + 1),
          if (e : ℕ) ≤ n then 2 ^ (m - (n - (e : ℕ))) else 0 := by
    rw [← Fin.sum_univ_eq_sum_range
      (fun n => if (e : ℕ) ≤ n then 2 ^ (m - (n - (e : ℕ))) else 0) (m + 1)]
    exact Finset.sum_congr rfl fun x _ => if_congr Fin.le_def rfl rfl
  have hico : (Finset.range (m + 1)).filter (fun n => (e : ℕ) ≤ n)
      = Finset.Ico (e : ℕ) (m + 1) := by
    ext n
    simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_Ico]
    omega
  have hem : (e : ℕ) ≤ m := Nat.lt_succ_iff.mp e.isLt
  rw [h3, h4, ← Finset.sum_filter, hico, Finset.sum_Ico_eq_sum_range]
  -- simplify the exponent, reflect the decreasing powers, factor 2^e
  have hsimp : (∑ t ∈ Finset.range (m + 1 - (e : ℕ)),
        2 ^ (m - ((e : ℕ) + t - (e : ℕ))))
      = ∑ t ∈ Finset.range (m + 1 - (e : ℕ)), 2 ^ (m - t) :=
    Finset.sum_congr rfl fun t _ => by congr 1; omega
  have hreflect : (∑ t ∈ Finset.range (m + 1 - (e : ℕ)), 2 ^ (m - t))
      = ∑ t ∈ Finset.range (m + 1 - (e : ℕ)), 2 ^ ((e : ℕ) + t) := by
    rw [← Finset.sum_range_reflect]
    refine Finset.sum_congr rfl fun t ht => ?_
    have htlt := Finset.mem_range.mp ht
    congr 1
    omega
  have hgeom : (∑ t ∈ Finset.range (m + 1 - (e : ℕ)), 2 ^ ((e : ℕ) + t))
      = 2 ^ (e : ℕ) * ∑ t ∈ Finset.range (m + 1 - (e : ℕ)), 2 ^ t := by
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun t _ => pow_add 2 (e : ℕ) t
  rw [hsimp, hreflect, hgeom]
  have h2p := sum_range_two_pow (m + 1 - (e : ℕ))
  have hsplit : 2 ^ (e : ℕ) * 2 ^ (m + 1 - (e : ℕ)) = 2 ^ (m + 1) := by
    rw [← pow_add]
    congr 1
    omega
  -- coaperture + 2^e = 2^e * (geom + 1) = 2^e * 2^(m+1−e) = 2^(m+1)
  calc 2 ^ (e : ℕ) * (∑ t ∈ Finset.range (m + 1 - (e : ℕ)), 2 ^ t)
        + 2 ^ (e : ℕ)
      = 2 ^ (e : ℕ)
          * ((∑ t ∈ Finset.range (m + 1 - (e : ℕ)), 2 ^ t) + 1) := by ring
    _ = 2 ^ (e : ℕ) * 2 ^ (m + 1 - (e : ℕ)) := by rw [h2p]
    _ = 2 ^ (m + 1) := hsplit

end ChainFin

/-! ## E2: multiplicativity on finite products

The contrast with the aperture is structural: the aperture needs
inclusion–exclusion to assemble across coordinates, the co-aperture
is exactly multiplicative — nuclei factor componentwise and the
phantom interval of a product is the product of the phantom
intervals. -/

section CoaperturePi

attribute [local instance] piDecidableLE

variable {ι : Type*} [Fintype ι] [DecidableEq ι]
  {α : ι → Type*} [∀ i, SemilatticeInf (α i)] [∀ i, OrderTop (α i)]
  [∀ i, Fintype (α i)] [∀ i, DecidableEq (α i)] [∀ i, DecidableLE (α i)]
  [∀ i, LocallyFiniteOrder (α i)]

/-- **E2: the co-aperture is multiplicative on finite products.** -/
theorem coaperture_pi (k : ∀ i, α i) :
    coaperture k = ∏ i, coaperture (k i) := by
  classical
  unfold coaperture
  -- transfer the sum along the componentwise classification of nuclei
  rw [← Equiv.sum_comp nucleusPiEquiv.symm
    (fun j : {j : (∀ i, α i) → ∀ i, α i // IsNucleus j} => phantomMass j.1 k)]
  -- each summand is a product of per-coordinate phantom masses
  have hfact : ∀ p : ∀ i, {jc : α i → α i // IsNucleus jc},
      phantomMass (nucleusPiEquiv.symm p).1 k
        = ∏ i, phantomMass (p i).1 (k i) := by
    intro p
    unfold phantomMass
    have : (nucleusPiEquiv.symm p).1 k = fun i => (p i).1 (k i) := rfl
    rw [this, Pi.card_Icc]
  rw [Finset.sum_congr rfl fun p _ => hfact p]
  -- sum of products = product of sums
  rw [Finset.prod_univ_sum]
  rw [Fintype.piFinset_univ]

end CoaperturePi

/-! ## E3: the closed form on divisor lattices -/

section ClosedForm

attribute [local instance] piDecidableLE

local instance (n : ℕ) : BiheytingAlgebra (Fin (n + 1)) :=
  LinearOrder.toBiheytingAlgebra (Fin (n + 1))

/-- **E3: the co-aperture closed form on divisor lattices.**  On the
exponent lattice `Π i : Fin r, Fin (a i + 1)` of
`Div(p₁^{a₁} ⋯ p_r^{a_r})`, the kernel `k = (k₁, …, k_r)` has

  coaperture k = ∏ᵢ (2^{aᵢ+1} − 2^{kᵢ}).

Compare the aperture closed form (`aperture_closed_form_pi`): four
terms with inclusion–exclusion there, one product here. -/
theorem coaperture_closed_form_pi {r : ℕ} (a : Fin r → ℕ)
    (k : ∀ i, Fin (a i + 1)) :
    (coaperture k : ℤ) = ∏ i, (2 ^ (a i + 1) - 2 ^ ((k i : ℕ))) := by
  rw [coaperture_pi]
  push_cast
  refine Finset.prod_congr rfl fun i _ => ?_
  have h := coaperture_chain_add (a i) (k i)
  have hz : (coaperture (k i) : ℤ) + 2 ^ ((k i : ℕ)) = 2 ^ (a i + 1) := by
    exact_mod_cast h
  linarith

end ClosedForm

/-! ## E4: the independence witnesses, kernel-checked

Neither invariant determines the other.  Both witnesses were
hand-computed in the registered spec before this file existed. -/

section Witnesses

attribute [local instance] piDecidableLE

local instance (n : ℕ) : BiheytingAlgebra (Fin (n + 1)) :=
  LinearOrder.toBiheytingAlgebra (Fin (n + 1))

/-- Div24 = 2³·3, kernel 2 = (1,0): aperture **3**. -/
example :
    (Fintype.card {j : (∀ i : Fin 2, Fin (![3, 1] i + 1)) →
        ∀ i : Fin 2, Fin (![3, 1] i + 1) //
        IsNucleus j ∧ Opens j
          (fun i => (⟨![1, 0] i, by fin_cases i <;> norm_num⟩ :
            Fin (![3, 1] i + 1)))} : ℤ) = 3 := by
  rw [aperture_closed_form_pi]
  decide

/-- Div24 = 2³·3, kernel 4 = (2,0): aperture **3** — the same. -/
example :
    (Fintype.card {j : (∀ i : Fin 2, Fin (![3, 1] i + 1)) →
        ∀ i : Fin 2, Fin (![3, 1] i + 1) //
        IsNucleus j ∧ Opens j
          (fun i => (⟨![2, 0] i, by fin_cases i <;> norm_num⟩ :
            Fin (![3, 1] i + 1)))} : ℤ) = 3 := by
  rw [aperture_closed_form_pi]
  decide

/-- Div24, kernel 2 = (1,0): co-aperture **42**. -/
example :
    (coaperture (fun i => (⟨![1, 0] i, by fin_cases i <;> norm_num⟩ :
        Fin (![3, 1] i + 1))) : ℤ) = 42 := by
  rw [coaperture_closed_form_pi]
  decide

/-- Div24, kernel 4 = (2,0): co-aperture **36** — different.
**Same aperture, different co-apertures**: the aperture does not
determine the co-aperture, at nonzero aperture. -/
example :
    (coaperture (fun i => (⟨![2, 0] i, by fin_cases i <;> norm_num⟩ :
        Fin (![3, 1] i + 1))) : ℤ) = 36 := by
  rw [coaperture_closed_form_pi]
  decide

/-- Div72 = 2³·3², kernel 4 = (2,0): co-aperture **84**. -/
example :
    (coaperture (fun i => (⟨![2, 0] i, by fin_cases i <;> norm_num⟩ :
        Fin (![3, 2] i + 1))) : ℤ) = 84 := by
  rw [coaperture_closed_form_pi]
  decide

/-- Div72, kernel 6 = (1,1): co-aperture **84** — the same. -/
example :
    (coaperture (fun i => (⟨![1, 1] i, by fin_cases i <;> norm_num⟩ :
        Fin (![3, 2] i + 1))) : ℤ) = 84 := by
  rw [coaperture_closed_form_pi]
  decide

/-- Div72, kernel 4 = (2,0): aperture **9**. -/
example :
    (Fintype.card {j : (∀ i : Fin 2, Fin (![3, 2] i + 1)) →
        ∀ i : Fin 2, Fin (![3, 2] i + 1) //
        IsNucleus j ∧ Opens j
          (fun i => (⟨![2, 0] i, by fin_cases i <;> norm_num⟩ :
            Fin (![3, 2] i + 1)))} : ℤ) = 9 := by
  rw [aperture_closed_form_pi]
  decide

/-- Div72, kernel 6 = (1,1): aperture **6** — different.
**Same co-aperture, different apertures**: the co-aperture does not
determine the aperture.  Together with the Div24 pair: the survival
count and the destruction ledger are independent coordinates. -/
example :
    (Fintype.card {j : (∀ i : Fin 2, Fin (![3, 2] i + 1)) →
        ∀ i : Fin 2, Fin (![3, 2] i + 1) //
        IsNucleus j ∧ Opens j
          (fun i => (⟨![1, 1] i, by fin_cases i <;> norm_num⟩ :
            Fin (![3, 2] i + 1)))} : ℤ) = 6 := by
  rw [aperture_closed_form_pi]
  decide

end Witnesses

end FalseWork.Lattice
