/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# Best approximations of the second kind for continued-fraction convergents

Classical Diophantine approximation: convergents of an irrational `ξ` are best
rational approximations of the **second kind** — they strictly minimize
`|q·ξ − p|` among integer pairs `(p, q)` with `0 < q < q_{n+1}`.

This file proves **(C1)** from `validation/claims/optimal-ntet-continued-fraction.md`
for general irrational `ξ`, then specializes in `PythagoreanCommaOptimal.lean`.
-/
import Mathlib.NumberTheory.DiophantineApproximation.ContinuedFractions
import Mathlib.Algebra.ContinuedFractions.Computation.Approximations
import Mathlib.Algebra.ContinuedFractions.Computation.TerminatesIffRat
import Mathlib.Algebra.ContinuedFractions.Determinant
import Mathlib.Algebra.Order.Round

import Mathlib.Data.Rat.Lemmas

namespace Real

open Int GenContFract

variable {ξ : ℝ}

noncomputable section

/-! ## Irrationality ⇒ non-terminating continued fraction -/

theorem not_terminates_of_irrational (hξ : Irrational ξ) : ¬(GenContFract.of ξ).Terminates := by
  intro hT
  obtain ⟨q, hq⟩ := (terminates_iff_rat ξ).1 hT
  exact hξ.ne_rat q hq

theorem not_terminatedAt_of_irrational (hξ : Irrational ξ) (n : ℕ) :
    ¬(GenContFract.of ξ).TerminatedAt n := by
  intro hterm
  exact not_terminates_of_irrational hξ ⟨n, hterm⟩

/-! ## Bridge between `Real.convergent` and `GenContFract.of` -/

theorem convergent_coe_eq_convs (n : ℕ) : (ξ.convergent n : ℝ) = (GenContFract.of ξ).convs n :=
  (convs_eq_convergent ξ n).symm

theorem convergent_rat_eq_num_div_den (n : ℕ) :
    (ξ.convergent n : ℝ) = (GenContFract.of ξ).nums n / (GenContFract.of ξ).dens n := by
  rw [convergent_coe_eq_convs n, conv_eq_num_div_den]

private theorem cf_den_pos (hξ : Irrational ξ) (n : ℕ) : 0 < (GenContFract.of ξ).dens n := by
  have hfib : (0 : ℝ) < Nat.fib (n + 1) := mod_cast Nat.fib_pos.2 n.succ_pos
  rcases n with - | m
  · simp [zeroth_den_eq_one]
  · have hterm := not_terminatedAt_of_irrational hξ (m + 1)
    have hprev := mt (terminated_stable (Nat.le_succ m)) hterm
    have hyp : m.succ = 0 ∨ ¬(GenContFract.of ξ).TerminatedAt (m.succ - 1) := Or.inr hprev
    exact lt_of_lt_of_le hfib (succ_nth_fib_le_of_nth_den (K := ℝ) (v := ξ) hyp)

/-- The continuants `Aₙ, Bₙ` of `GenContFract.of ξ` are integer-valued. -/
private theorem contsAux_isInt (hξ : Irrational ξ) :
    ∀ n, ∃ a b : ℤ, (GenContFract.of ξ).contsAux n = ⟨(a : ℝ), (b : ℝ)⟩ := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n IH =>
    match n, IH with
    | 0, _ => exact ⟨1, 0, by rw [zeroth_contAux_eq_one_zero]; norm_num⟩
    | 1, _ => exact ⟨⌊ξ⌋, 1, by rw [first_contAux_eq_h_one, of_h_eq_floor]; norm_num⟩
    | (m + 2), IH =>
      obtain ⟨gp, hgp⟩ : ∃ gp, (GenContFract.of ξ).s.get? m = some gp :=
        Option.ne_none_iff_exists'.1 (not_terminatedAt_of_irrational hξ m)
      obtain ⟨ha1, z, hz⟩ := of_partNum_eq_one_and_exists_int_partDen_eq hgp
      obtain ⟨a₀, b₀, h0⟩ := IH m (by omega)
      obtain ⟨a₁, b₁, h1⟩ := IH (m + 1) (by omega)
      refine ⟨z * a₁ + a₀, z * b₁ + b₀, ?_⟩
      rw [contsAux_recurrence hgp h0 h1, ha1, hz]
      simp only [Pair.mk.injEq]
      constructor <;> push_cast <;> ring

private theorem cf_nums_dens_isInt (hξ : Irrational ξ) (n : ℕ) :
    ∃ a b : ℤ, (GenContFract.of ξ).nums n = (a : ℝ) ∧ (GenContFract.of ξ).dens n = (b : ℝ) := by
  obtain ⟨a, b, h⟩ := contsAux_isInt hξ (n + 1)
  exact ⟨a, b, by rw [num_eq_conts_a, nth_cont_eq_succ_nth_contAux, h],
    by rw [den_eq_conts_b, nth_cont_eq_succ_nth_contAux, h]⟩

/-- The `n`-th continuant numerator and denominator are coprime (determinant identity). -/
private theorem cf_coprime (hξ : Irrational ξ) (n : ℕ) :
    ∃ a b : ℤ, (GenContFract.of ξ).nums n = (a : ℝ) ∧ (GenContFract.of ξ).dens n = (b : ℝ) ∧
      Nat.Coprime a.natAbs b.natAbs := by
  obtain ⟨a, b, hA, hB⟩ := cf_nums_dens_isInt hξ n
  obtain ⟨a', b', hA', hB'⟩ := cf_nums_dens_isInt hξ (n + 1)
  have hterm := not_terminatedAt_of_irrational hξ n
  have hdet : (GenContFract.of ξ).nums n * (GenContFract.of ξ).dens (n + 1)
      - (GenContFract.of ξ).dens n * (GenContFract.of ξ).nums (n + 1) = (-1 : ℝ) ^ (n + 1) :=
    (SimpContFract.of ξ).determinant hterm
  rw [hA, hB, hA', hB'] at hdet
  have hdetZ : a * b' - b * a' = (-1 : ℤ) ^ (n + 1) := by exact_mod_cast hdet
  have he2 : ((-1 : ℤ) ^ (n + 1)) * ((-1 : ℤ) ^ (n + 1)) = 1 := by
    rw [← pow_add]
    exact Even.neg_one_pow ⟨n + 1, by ring⟩
  have hcop : IsCoprime a b := by
    refine ⟨(-1 : ℤ) ^ (n + 1) * b', -((-1 : ℤ) ^ (n + 1) * a'), ?_⟩
    have hexp : (-1 : ℤ) ^ (n + 1) * b' * a + -((-1 : ℤ) ^ (n + 1) * a') * b
        = (-1 : ℤ) ^ (n + 1) * (a * b' - b * a') := by ring
    rw [hexp, hdetZ]
    exact he2
  exact ⟨a, b, hA, hB, Int.isCoprime_iff_gcd_eq_one.mp hcop⟩

theorem convergent_den_cast (hξ : Irrational ξ) (n : ℕ) :
    ((ξ.convergent n).den : ℝ) = (GenContFract.of ξ).dens n := by
  obtain ⟨a, b, hA, hB, hcop⟩ := cf_coprime hξ n
  have hbpos : 0 < b := by
    have : (0 : ℝ) < (b : ℝ) := hB ▸ cf_den_pos hξ n
    exact_mod_cast this
  have hq : ξ.convergent n = (a : ℚ) / (b : ℚ) := by
    have hr : ((ξ.convergent n : ℚ) : ℝ) = (((a : ℚ) / (b : ℚ)) : ℝ) := by
      push_cast
      rw [convergent_rat_eq_num_div_den, hA, hB]
    exact_mod_cast hr
  have hden : ((ξ.convergent n).den : ℤ) = b := by
    rw [hq]; exact Rat.den_div_eq_of_coprime hbpos hcop
  rw [hB]
  exact_mod_cast hden

theorem convergent_num_cast (hξ : Irrational ξ) (n : ℕ) :
    ((ξ.convergent n).num : ℝ) = (GenContFract.of ξ).nums n := by
  have hden := convergent_den_cast hξ n
  have hpos := cf_den_pos hξ n
  have h := convergent_rat_eq_num_div_den (ξ := ξ) n
  have hcast : ((ξ.convergent n : ℝ)) =
      ((ξ.convergent n).num : ℝ) / ((ξ.convergent n).den : ℝ) := by
    exact_mod_cast (Rat.num_div_den (ξ.convergent n)).symm
  rw [hcast, hden] at h
  rw [div_eq_div_iff hpos.ne' hpos.ne'] at h
  exact mul_right_cancel₀ hpos.ne' h

theorem convergent_den_pos (_hξ : Irrational ξ) (n : ℕ) : 0 < (ξ.convergent n).den :=
  (ξ.convergent n).pos

theorem convergent_den_le_succ (hξ : Irrational ξ) (n : ℕ) :
    (ξ.convergent n).den ≤ (ξ.convergent (n + 1)).den := by
  have hmono : (GenContFract.of ξ).dens n ≤ (GenContFract.of ξ).dens (n + 1) :=
    GenContFract.of_den_mono (v := ξ) (n := n)
  rw [← convergent_den_cast hξ n, ← convergent_den_cast hξ (n + 1)] at hmono
  exact mod_cast hmono

private def cfNum (ξ : ℝ) (n : ℕ) : ℝ := (GenContFract.of ξ).nums n
private def cfDen (ξ : ℝ) (n : ℕ) : ℝ := (GenContFract.of ξ).dens n

/-! ## Error bounds for convergents -/

private theorem abs_mul_sub_cf (hξ : Irrational ξ) (n : ℕ) :
    |cfDen ξ n * ξ - cfNum ξ n| = cfDen ξ n * |ξ - cfNum ξ n / cfDen ξ n| := by
  have hden : 0 < cfDen ξ n := cf_den_pos hξ n
  have hdne : cfDen ξ n ≠ 0 := hden.ne'
  calc
    |cfDen ξ n * ξ - cfNum ξ n|
        = |cfDen ξ n * ξ - cfDen ξ n * (cfNum ξ n / cfDen ξ n)| := by rw [mul_div_cancel₀ _ hdne]
    _ = |cfDen ξ n * (ξ - cfNum ξ n / cfDen ξ n)| := by ring_nf
    _ = cfDen ξ n * |ξ - cfNum ξ n / cfDen ξ n| := by rw [abs_mul, abs_of_pos hden]

theorem convergent_sub_le (hξ : Irrational ξ) (n : ℕ) :
    |ξ - cfNum ξ n / cfDen ξ n| ≤ (1 : ℝ) / (cfDen ξ n * cfDen ξ (n + 1)) := by
  have hterm := not_terminatedAt_of_irrational hξ n
  have hbound := abs_sub_convs_le (K := ℝ) (v := ξ) hterm
  rw [← convergent_coe_eq_convs n, convergent_rat_eq_num_div_den (ξ := ξ) n] at hbound
  simpa [cfNum, cfDen] using hbound

theorem convergent_mul_sub_le (hξ : Irrational ξ) (n : ℕ) :
    |cfDen ξ n * ξ - cfNum ξ n| ≤ (1 : ℝ) / cfDen ξ (n + 1) := by
  rw [abs_mul_sub_cf hξ]
  have hden_pos : 0 < cfDen ξ n := cf_den_pos hξ n
  have hnext_pos : 0 < cfDen ξ (n + 1) := cf_den_pos hξ (n + 1)
  have hsub := convergent_sub_le hξ n
  calc
    cfDen ξ n * |ξ - cfNum ξ n / cfDen ξ n|
        ≤ cfDen ξ n * (1 / (cfDen ξ n * cfDen ξ (n + 1))) :=
      mul_le_mul_of_nonneg_left hsub hden_pos.le
    _ = 1 / cfDen ξ (n + 1) := by field_simp [hden_pos.ne', hnext_pos.ne']

/-! ## Irrationality of the error term and sign alternation -/

/-- The error term `Bₙ·ξ − Aₙ` is irrational (a nonzero integer multiple of `ξ`, minus an
integer). -/
private theorem cf_err_irrational (hξ : Irrational ξ) (n : ℕ) :
    Irrational (cfDen ξ n * ξ - cfNum ξ n) := by
  obtain ⟨a, b, hA, hB⟩ := cf_nums_dens_isInt hξ n
  have hb0 : b ≠ 0 := by
    have hpos : (0 : ℝ) < (b : ℝ) := by rw [← hB]; exact cf_den_pos hξ n
    exact_mod_cast hpos.ne'
  simp only [cfNum, cfDen]
  rw [hA, hB, irrational_sub_intCast_iff, irrational_intCast_mul_iff]
  exact ⟨hb0, hξ⟩

/-- The absolute value of an irrational number is irrational. -/
private theorem abs_irrational {y : ℝ} (h : Irrational y) : Irrational |y| := by
  rcases abs_cases y with ⟨h1, _⟩ | ⟨h1, _⟩
  · rwa [h1]
  · rw [h1]; exact h.neg

/-- Exact sign of `ξ − pₙ/qₙ`: it equals the sign of `(−1)ⁿ`. -/
private theorem sub_convs_sign (hξ : Irrational ξ) (n : ℕ) :
    0 < (-1 : ℝ) ^ n * (ξ - (GenContFract.of ξ).convs n) := by
  have hne : IntFractPair.stream ξ n ≠ none := by
    intro hnone
    have hc := of_correctness_of_nth_stream_eq_none hnone
    rw [convs_eq_convergent] at hc
    exact hξ.ne_rat _ hc
  obtain ⟨ifp, hstream⟩ := Option.ne_none_iff_exists'.1 hne
  have hfr : ifp.fr ≠ 0 := by
    intro hfr0
    have h := sub_convs_eq (v := ξ) hstream
    simp only [if_pos hfr0] at h
    have hxi : ξ = (GenContFract.of ξ).convs n := sub_eq_zero.1 h
    rw [convs_eq_convergent] at hxi
    exact hξ.ne_rat _ hxi
  have h := sub_convs_eq (v := ξ) hstream
  simp only [if_neg hfr] at h
  have hBpos : 0 < ((GenContFract.of ξ).contsAux (n + 1)).b := by
    have := cf_den_pos hξ n
    rwa [den_eq_conts_b, nth_cont_eq_succ_nth_contAux] at this
  have hpB : 0 ≤ ((GenContFract.of ξ).contsAux n).b := zero_le_of_contsAux_b
  have hfrpos : 0 < ifp.fr := (IntFractPair.nth_stream_fr_nonneg hstream).lt_of_ne (Ne.symm hfr)
  have hinner : 0 < ifp.fr⁻¹ * ((GenContFract.of ξ).contsAux (n + 1)).b
      + ((GenContFract.of ξ).contsAux n).b :=
    add_pos_of_pos_of_nonneg (mul_pos (inv_pos.mpr hfrpos) hBpos) hpB
  have hD : 0 < ((GenContFract.of ξ).contsAux (n + 1)).b
      * (ifp.fr⁻¹ * ((GenContFract.of ξ).contsAux (n + 1)).b + ((GenContFract.of ξ).contsAux n).b) :=
    mul_pos hBpos hinner
  have hpow : (-1 : ℝ) ^ n * (-1) ^ n = 1 := by
    rw [← pow_add]; exact Even.neg_one_pow ⟨n, rfl⟩
  rw [h, mul_div_assoc', hpow]
  exact one_div_pos.mpr hD

/-- The signed error term `(−1)ⁿ·(qₙ·ξ − pₙ)` is strictly positive. -/
private theorem cf_err_sign (hξ : Irrational ξ) (n : ℕ) :
    0 < (-1 : ℝ) ^ n * (cfDen ξ n * ξ - cfNum ξ n) := by
  have h := sub_convs_sign hξ n
  have hd : 0 < cfDen ξ n := cf_den_pos hξ n
  have hdne : (GenContFract.of ξ).dens n ≠ 0 := (cf_den_pos hξ n).ne'
  have hc : cfDen ξ n * (GenContFract.of ξ).convs n = cfNum ξ n := by
    rw [conv_eq_num_div_den]; simp only [cfNum, cfDen]
    rw [← mul_div_assoc]; exact mul_div_cancel_left₀ _ hdne
  have heq : cfDen ξ n * ξ - cfNum ξ n = cfDen ξ n * (ξ - (GenContFract.of ξ).convs n) := by
    rw [mul_sub, hc]
  rw [heq, show (-1 : ℝ) ^ n * (cfDen ξ n * (ξ - (GenContFract.of ξ).convs n))
      = cfDen ξ n * ((-1) ^ n * (ξ - (GenContFract.of ξ).convs n)) from by ring]
  exact mul_pos hd h

theorem convergent_mul_sub_lt (hξ : Irrational ξ) (n : ℕ) :
    |cfDen ξ n * ξ - cfNum ξ n| < (1 : ℝ) / cfDen ξ (n + 1) := by
  have hle := convergent_mul_sub_le hξ n
  have hLirr : Irrational |cfDen ξ n * ξ - cfNum ξ n| := abs_irrational (cf_err_irrational hξ n)
  have hRrat : ¬Irrational ((1 : ℝ) / cfDen ξ (n + 1)) := by
    obtain ⟨a', b', hA', hB'⟩ := cf_nums_dens_isInt hξ (n + 1)
    have hcf : cfDen ξ (n + 1) = (b' : ℝ) := by simp only [cfDen]; exact hB'
    rw [hcf]
    exact fun hirr => hirr ⟨(b' : ℚ)⁻¹, by push_cast; rw [one_div]⟩
  exact lt_of_le_of_ne hle (fun heq => hRrat (heq ▸ hLirr))

theorem convergent_determinant_int (hξ : Irrational ξ) (n : ℕ) :
    (ξ.convergent n).num * (ξ.convergent (n + 1)).den -
      (ξ.convergent n).den * (ξ.convergent (n + 1)).num = (-1 : ℤ) ^ (n + 1) := by
  have hdet : (GenContFract.of ξ).nums n * (GenContFract.of ξ).dens (n + 1)
      - (GenContFract.of ξ).dens n * (GenContFract.of ξ).nums (n + 1) = (-1 : ℝ) ^ (n + 1) :=
    (SimpContFract.of ξ).determinant (not_terminatedAt_of_irrational hξ n)
  rw [← convergent_num_cast hξ n, ← convergent_num_cast hξ (n + 1),
    ← convergent_den_cast hξ n, ← convergent_den_cast hξ (n + 1)] at hdet
  exact_mod_cast hdet

/-! ## Distance to nearest integer -/

theorem abs_mul_sub_minimized_by_round (b : ℤ) (a : ℤ) :
    |((b : ℝ) * ξ - (round ((b : ℝ) * ξ) : ℝ))| ≤ |(b : ℝ) * ξ - (a : ℝ)| :=
  round_le ((b : ℝ) * ξ) a

/-! ## A sign lemma for absolute values -/

/-- If `u` and `v` have the same sign, `|u + v| = |u| + |v|`. -/
private theorem abs_add_of_mul_nonneg {u v : ℝ} (h : 0 ≤ u * v) : |u + v| = |u| + |v| := by
  rcases le_total 0 u with hu | hu <;> rcases le_total 0 v with hv | hv
  · rw [abs_of_nonneg hu, abs_of_nonneg hv, abs_of_nonneg (by linarith)]
  · have huv : u * v = 0 := le_antisymm (by nlinarith [mul_nonneg hu (neg_nonneg.mpr hv)]) h
    rcases mul_eq_zero.1 huv with h0 | h0 <;> simp [h0]
  · have huv : u * v = 0 := le_antisymm (by nlinarith [mul_nonneg (neg_nonneg.mpr hu) hv]) h
    rcases mul_eq_zero.1 huv with h0 | h0 <;> simp [h0]
  · rw [abs_of_nonpos hu, abs_of_nonpos hv, abs_of_nonpos (by linarith)]; ring

/-! ## (C1) Best approximation of the second kind

The convergent `pₙ/qₙ` strictly minimizes `|q·ξ − p|` among all integer pairs `(p, q)` with
`0 < q < q_{n+1}` other than `(pₙ, qₙ)`. The proof is the classical linear-algebra argument:
writing `(a, b)` in the basis `{(pₙ, qₙ), (p_{n+1}, q_{n+1})}` (an integer basis by the determinant
identity) and using the sign alternation of the error terms. -/

theorem convergent_best_approx_second_kind (hξ : Irrational ξ) {n : ℕ}
    {a b : ℤ} (hb_pos : 0 < b) (hb_lt : (b : ℝ) < cfDen ξ (n + 1))
    (hne : (a, b) ≠ ((ξ.convergent n).num, (Nat.cast (ξ.convergent n).den : ℤ))) :
    |cfDen ξ n * ξ - cfNum ξ n| < |(b : ℝ) * ξ - (a : ℝ)| := by
  -- integer continuants for indices `n` and `n + 1`
  obtain ⟨a₀, b₀, hA₀, hB₀⟩ := cf_nums_dens_isInt hξ n
  obtain ⟨a₁, b₁, hA₁, hB₁⟩ := cf_nums_dens_isInt hξ (n + 1)
  have hcfD : cfDen ξ n = (b₀ : ℝ) := by simp only [cfDen]; exact hB₀
  have hcfN : cfNum ξ n = (a₀ : ℝ) := by simp only [cfNum]; exact hA₀
  have hcfD₁ : cfDen ξ (n + 1) = (b₁ : ℝ) := by simp only [cfDen]; exact hB₁
  have hcfN₁ : cfNum ξ (n + 1) = (a₁ : ℝ) := by simp only [cfNum]; exact hA₁
  have hb₀pos : 0 < b₀ := by
    have : (0 : ℝ) < (b₀ : ℝ) := hB₀ ▸ cf_den_pos hξ n; exact_mod_cast this
  have hb₁pos : 0 < b₁ := by
    have : (0 : ℝ) < (b₁ : ℝ) := hB₁ ▸ cf_den_pos hξ (n + 1); exact_mod_cast this
  have hbb : b < b₁ := by
    have hlt : (b : ℝ) < (b₁ : ℝ) := by rw [← hcfD₁]; exact hb_lt
    exact_mod_cast hlt
  -- translate the `(a, b) ≠ (pₙ, qₙ)` hypothesis to the continuant integers
  have hconvN : a₀ = (ξ.convergent n).num := by
    have := (convergent_num_cast hξ n).trans hA₀; exact_mod_cast this.symm
  have hconvD : b₀ = (Nat.cast (ξ.convergent n).den : ℤ) := by
    have := (convergent_den_cast hξ n).trans hB₀; exact_mod_cast this.symm
  -- determinant identity over `ℤ`
  have hdet : (GenContFract.of ξ).nums n * (GenContFract.of ξ).dens (n + 1)
      - (GenContFract.of ξ).dens n * (GenContFract.of ξ).nums (n + 1) = (-1 : ℝ) ^ (n + 1) :=
    (SimpContFract.of ξ).determinant (not_terminatedAt_of_irrational hξ n)
  rw [hA₀, hB₀, hA₁, hB₁] at hdet
  set ε : ℤ := (-1 : ℤ) ^ (n + 1) with hε
  have hdetZ : a₀ * b₁ - b₀ * a₁ = ε := by rw [hε]; exact_mod_cast hdet
  have hεsq : ε * ε = 1 := by rw [hε, ← pow_add]; exact Even.neg_one_pow ⟨n + 1, by ring⟩
  -- Cramer solution: write `(a, b)` in the continuant basis
  set x : ℤ := ε * (a * b₁ - a₁ * b) with hx
  set y : ℤ := ε * (a₀ * b - a * b₀) with hy
  have hsysA : a₀ * x + a₁ * y = a := by
    rw [hx, hy, show a₀ * (ε * (a * b₁ - a₁ * b)) + a₁ * (ε * (a₀ * b - a * b₀))
      = ε * (a₀ * b₁ - b₀ * a₁) * a from by ring, hdetZ,
      show ε * ε * a = (ε * ε) * a from by ring, hεsq, one_mul]
  have hsysB : b₀ * x + b₁ * y = b := by
    rw [hx, hy, show b₀ * (ε * (a * b₁ - a₁ * b)) + b₁ * (ε * (a₀ * b - a * b₀))
      = ε * (a₀ * b₁ - b₀ * a₁) * b from by ring, hdetZ,
      show ε * ε * b = (ε * ε) * b from by ring, hεsq, one_mul]
  -- real error terms and their signs
  rw [hcfD, hcfN]
  set δ₀ : ℝ := (b₀ : ℝ) * ξ - (a₀ : ℝ) with hδ₀def
  set δ₁ : ℝ := (b₁ : ℝ) * ξ - (a₁ : ℝ) with hδ₁def
  set s : ℝ := (-1 : ℝ) ^ n with hsdef
  have hs0 : 0 < s * δ₀ := by
    rw [hsdef, hδ₀def]; have := cf_err_sign hξ n; rwa [hcfD, hcfN] at this
  have hs1 : 0 < (-1 : ℝ) ^ (n + 1) * δ₁ := by
    rw [hδ₁def]; have := cf_err_sign hξ (n + 1); rwa [hcfD₁, hcfN₁] at this
  have hsabs : |s| = 1 := by rw [hsdef, abs_pow]; norm_num
  have habs0 : |δ₀| = s * δ₀ := by rw [← abs_of_pos hs0, abs_mul, hsabs, one_mul]
  have hsδ₁neg : s * δ₁ < 0 := by
    have hflip : (-1 : ℝ) ^ (n + 1) = -s := by rw [hsdef, pow_succ]; ring
    rw [hflip] at hs1; linarith
  have hpos1 : 0 < -(s * δ₁) := by linarith
  have habs1 : |δ₁| = -(s * δ₁) := by rw [← abs_of_pos hpos1, abs_neg, abs_mul, hsabs, one_mul]
  have hδ₀ne : δ₀ ≠ 0 := by intro h; rw [h, mul_zero] at hs0; exact lt_irrefl 0 hs0
  have hδ₁ne : δ₁ ≠ 0 := by intro h; rw [h, mul_zero] at hsδ₁neg; exact lt_irrefl 0 hsδ₁neg
  have habs0pos : 0 < |δ₀| := abs_pos.mpr hδ₀ne
  have habs1pos : 0 < |δ₁| := abs_pos.mpr hδ₁ne
  -- the key real identity `b·ξ − a = x·δ₀ + y·δ₁`
  have hid : (b : ℝ) * ξ - (a : ℝ) = (x : ℝ) * δ₀ + (y : ℝ) * δ₁ := by
    have hbR : (b : ℝ) = (b₀ : ℝ) * x + (b₁ : ℝ) * y := by exact_mod_cast hsysB.symm
    have haR : (a : ℝ) = (a₀ : ℝ) * x + (a₁ : ℝ) * y := by exact_mod_cast hsysA.symm
    rw [hbR, haR, hδ₀def, hδ₁def]; ring
  have hsid : s * ((b : ℝ) * ξ - (a : ℝ)) = (x : ℝ) * |δ₀| + (-(y : ℝ)) * |δ₁| := by
    rw [hid, habs0, habs1]; ring
  have hgoalRHS : |(b : ℝ) * ξ - (a : ℝ)| = abs ((x : ℝ) * |δ₀| + (-(y : ℝ)) * |δ₁|) := by
    rw [← hsid, abs_mul, hsabs, one_mul]
  rw [hgoalRHS]
  -- `x ≠ 0`, since `x = 0` would force `b = q_{n+1}·y ≥ q_{n+1}`
  have hxne : x ≠ 0 := by
    intro hx0
    rw [hx0, mul_zero, zero_add] at hsysB
    have h1 : 0 < b₁ * y := by rw [hsysB]; exact hb_pos
    have h0 : b₁ * 0 < b₁ * y := by rw [mul_zero]; exact h1
    have hypos : 0 < y := _root_.lt_of_mul_lt_mul_left h0 hb₁pos.le
    have h2 : b₁ * y < b₁ * 1 := by rw [mul_one, hsysB]; exact hbb
    have hylt : y < 1 := _root_.lt_of_mul_lt_mul_left h2 hb₁pos.le
    omega
  have hx1R : (1 : ℝ) ≤ |(x : ℝ)| := by rw [← Int.cast_abs]; exact_mod_cast Int.one_le_abs hxne
  by_cases hy : y = 0
  · -- `y = 0`: then `(a, b) = (x·a₀, x·b₀)`, forcing `x ≥ 2`
    rw [hy] at hsysA hsysB
    have hbeq : b₀ * x = b := by simpa using hsysB
    have haeq : a₀ * x = a := by simpa using hsysA
    simp only [hy, Int.cast_zero, neg_zero, zero_mul, add_zero, abs_mul, abs_abs]
    have hxpos : 0 < x := by
      have h0 : b₀ * 0 < b₀ * x := by rw [mul_zero, hbeq]; exact hb_pos
      exact _root_.lt_of_mul_lt_mul_left h0 hb₀pos.le
    have hxne1 : x ≠ 1 := by
      intro hx1
      apply hne
      rw [hx1, mul_one] at hbeq haeq
      exact Prod.ext_iff.2 ⟨by rw [← haeq]; exact hconvN, by rw [← hbeq]; exact hconvD⟩
    have hx2 : 2 ≤ x := by omega
    have hx2R : (2 : ℝ) ≤ (x : ℝ) := by exact_mod_cast hx2
    rw [abs_of_pos (by exact_mod_cast hxpos : (0 : ℝ) < (x : ℝ))]
    nlinarith [habs0pos, hx2R]
  · -- `y ≠ 0`: then `x` and `y` have opposite signs, so `x·δ₀` and `−y·δ₁` agree in sign
    have hxy : x * y ≤ 0 := by
      by_contra hpos
      rw [not_le] at hpos
      rcases mul_pos_iff.1 hpos with ⟨hxp, hyp⟩ | ⟨hxn, hyn⟩
      · have hxp1 : 1 ≤ x := by omega
        have hyp1 : 1 ≤ y := by omega
        have ex : b₀ ≤ b₀ * x := le_mul_of_one_le_right hb₀pos.le hxp1
        have ey : b₁ ≤ b₁ * y := le_mul_of_one_le_right hb₁pos.le hyp1
        linarith [hsysB, ex, ey, hb₀pos, hbb]
      · have ex : b₀ * x < 0 := mul_neg_of_pos_of_neg hb₀pos hxn
        have ey : b₁ * y < 0 := mul_neg_of_pos_of_neg hb₁pos hyn
        linarith [hsysB, ex, ey, hb_pos]
    have huv : 0 ≤ ((x : ℝ) * |δ₀|) * ((-(y : ℝ)) * |δ₁|) := by
      have hxyR : (x : ℝ) * (y : ℝ) ≤ 0 := by exact_mod_cast hxy
      have key : ((x : ℝ) * |δ₀|) * ((-(y : ℝ)) * |δ₁|) = (-(x * y : ℝ)) * (|δ₀| * |δ₁|) := by ring
      rw [key]
      exact mul_nonneg (by linarith) (mul_nonneg (abs_nonneg δ₀) (abs_nonneg δ₁))
    rw [abs_add_of_mul_nonneg huv, abs_mul, abs_mul, abs_abs, abs_abs, abs_neg]
    have hy1 : (1 : ℝ) ≤ |(y : ℝ)| := by rw [← Int.cast_abs]; exact_mod_cast Int.one_le_abs hy
    have e1 : |δ₀| ≤ |(x : ℝ)| * |δ₀| := le_mul_of_one_le_left (abs_nonneg δ₀) hx1R
    have e2 : |δ₁| ≤ |(y : ℝ)| * |δ₁| := le_mul_of_one_le_left (abs_nonneg δ₁) hy1
    linarith [e1, e2, habs1pos]

/-- (C1) restated purely in terms of `Real.convergent`'s numerator and denominator, with no
reference to the private continuant aliases — convenient for downstream specializations. -/
theorem convergent_best_approx_second_kind' (hξ : Irrational ξ) {n : ℕ} {a b : ℤ}
    (hb_pos : 0 < b) (hb_lt : (b : ℝ) < ((ξ.convergent (n + 1)).den : ℝ))
    (hne : (a, b) ≠ ((ξ.convergent n).num, (Nat.cast (ξ.convergent n).den : ℤ))) :
    |((ξ.convergent n).den : ℝ) * ξ - ((ξ.convergent n).num : ℝ)|
      < |(b : ℝ) * ξ - (a : ℝ)| := by
  have hb_lt' : (b : ℝ) < cfDen ξ (n + 1) := by
    rw [convergent_den_cast hξ (n + 1)] at hb_lt; exact hb_lt
  have h := convergent_best_approx_second_kind hξ hb_pos hb_lt' hne
  rwa [convergent_den_cast hξ n, convergent_num_cast hξ n]

/-! ## (C2) Optimal denominators are exactly the convergent denominators

For irrational `ξ`, `N ≥ 1` is a *strict best-so-far approximation denominator* (its distance
`‖N·ξ‖` to the integers beats every smaller `M`) if and only if `N` is a convergent denominator
of `ξ`. Both directions are immediate consequences of (C1). -/

/-- Distance from `N · ξ` to the nearest integer. -/
noncomputable def nearestError (ξ : ℝ) (N : ℕ) : ℝ :=
  |(N : ℝ) * ξ - (round ((N : ℝ) * ξ) : ℝ)|

private theorem succ_le_fib_add_two : ∀ n : ℕ, n + 1 ≤ Nat.fib (n + 2)
  | 0 => le_refl 1
  | (n + 1) => by
    have ih : n + 1 ≤ Nat.fib (n + 1 + 1) := succ_le_fib_add_two n
    have hpos : 1 ≤ Nat.fib (n + 1) := Nat.fib_pos.2 n.succ_pos
    rw [Nat.fib_add_two]
    omega

private theorem fib_le_convergent_den (hξ : Irrational ξ) (n : ℕ) :
    Nat.fib (n + 1) ≤ (ξ.convergent n).den := by
  have h : (Nat.fib (n + 1) : ℝ) ≤ (GenContFract.of ξ).dens n :=
    succ_nth_fib_le_of_nth_den (K := ℝ) (v := ξ)
      (Or.inr (not_terminatedAt_of_irrational hξ (n - 1)))
  rw [← convergent_den_cast hξ n] at h
  exact_mod_cast h

private theorem convergent_den_mono (hξ : Irrational ξ) :
    Monotone (fun n => (ξ.convergent n).den) :=
  monotone_nat_of_le_succ (fun n => convergent_den_le_succ hξ n)

theorem best_approx_iff_convergent_den (hξ : Irrational ξ) (N : ℕ) (hN : 1 ≤ N) :
    (∀ M : ℕ, 1 ≤ M → M < N → nearestError ξ N < nearestError ξ M)
      ↔ (∃ n : ℕ, N = (ξ.convergent n).den ∧ ∀ m : ℕ, m < n → (ξ.convergent m).den < N) := by
  classical
  have hmono := convergent_den_mono hξ
  -- `‖q_n·ξ‖ ≤ |q_n·ξ − p_n|`: the nearest-integer distance is at most the convergent error.
  have hErrLe : ∀ n : ℕ,
      nearestError ξ ((ξ.convergent n).den) ≤ |cfDen ξ n * ξ - cfNum ξ n| := by
    intro n
    have h := round_le (((ξ.convergent n).den : ℝ) * ξ) ((ξ.convergent n).num)
    rw [convergent_den_cast hξ n, convergent_num_cast hξ n] at h
    rw [nearestError, convergent_den_cast hξ n]
    exact h
  -- `(C1)` repackaged: any `M` with `0 < M < q_{n+1}`, `M ≠ q_n` is strictly beaten.
  have hC1lt : ∀ (n M : ℕ), 1 ≤ M → ((M : ℤ) : ℝ) < cfDen ξ (n + 1) →
      M ≠ (ξ.convergent n).den → |cfDen ξ n * ξ - cfNum ξ n| < nearestError ξ M := by
    intro n M hM hMlt hMne
    have hne_pair : (round ((M : ℝ) * ξ), (M : ℤ))
        ≠ ((ξ.convergent n).num, (Nat.cast (ξ.convergent n).den : ℤ)) := by
      intro hpair
      apply hMne
      have hsnd : (M : ℤ) = (Nat.cast (ξ.convergent n).den : ℤ) := congrArg Prod.snd hpair
      exact_mod_cast hsnd
    have hMpos : (0 : ℤ) < (M : ℤ) := by exact_mod_cast hM
    have hC1 := convergent_best_approx_second_kind hξ hMpos hMlt hne_pair
    have hcast : ((M : ℤ) : ℝ) = (M : ℝ) := by push_cast; ring
    rw [hcast] at hC1
    rw [nearestError]; exact hC1
  -- `q_0 = 1`, used to locate the first index whose denominator exceeds `N`.
  have hq0 : (ξ.convergent 0).den = 1 := by rw [convergent_zero]; simp
  constructor
  · -- `LHS → RHS`: if `N` were not a convergent denominator, `(C1)` exhibits a smaller, better `M`.
    intro hbest
    have key_notDen : (¬ ∃ n, N = (ξ.convergent n).den) →
        ∃ M, 1 ≤ M ∧ M < N ∧ nearestError ξ M ≤ nearestError ξ N := by
      intro hND
      have hexists : ∃ n, N < (ξ.convergent n).den :=
        ⟨N + 1, by
          have h1 : N + 1 ≤ Nat.fib (N + 2) := succ_le_fib_add_two N
          have h2 : Nat.fib (N + 2) ≤ (ξ.convergent (N + 1)).den := fib_le_convergent_den hξ (N + 1)
          omega⟩
      set k := Nat.find hexists with hk
      have hkspec : N < (ξ.convergent k).den := Nat.find_spec hexists
      have hkpos : 1 ≤ k := by
        rcases Nat.eq_zero_or_pos k with h0 | h
        · exfalso; rw [h0, hq0] at hkspec; omega
        · exact h
      have hk1 : ¬ N < (ξ.convergent (k - 1)).den := Nat.find_min hexists (by omega)
      have hqn_le : (ξ.convergent (k - 1)).den ≤ N := not_lt.mp hk1
      have hk_eq : k = (k - 1) + 1 := by omega
      have hkspec' : N < (ξ.convergent ((k - 1) + 1)).den := by rw [← hk_eq]; exact hkspec
      have hNeqn : N ≠ (ξ.convergent (k - 1)).den := fun h => hND ⟨k - 1, h⟩
      have hqn_lt : (ξ.convergent (k - 1)).den < N := lt_of_le_of_ne hqn_le (Ne.symm hNeqn)
      refine ⟨(ξ.convergent (k - 1)).den, convergent_den_pos hξ (k - 1), hqn_lt, ?_⟩
      have hNlt : ((N : ℤ) : ℝ) < cfDen ξ ((k - 1) + 1) := by
        show ((N : ℤ) : ℝ) < (GenContFract.of ξ).dens ((k - 1) + 1)
        rw [← convergent_den_cast hξ ((k - 1) + 1)]; exact_mod_cast hkspec'
      have hC1 := hC1lt (k - 1) N hN hNlt hNeqn
      exact le_trans (hErrLe (k - 1)) (le_of_lt hC1)
    by_contra hRHS
    have hND : ¬ ∃ n, N = (ξ.convergent n).den := by
      rintro ⟨n, hn⟩
      apply hRHS
      have hex : ∃ k, (ξ.convergent k).den = N := ⟨n, hn.symm⟩
      refine ⟨Nat.find hex, (Nat.find_spec hex).symm, ?_⟩
      intro m hm
      have hmne : (ξ.convergent m).den ≠ N := Nat.find_min hex hm
      have hmle : (ξ.convergent m).den ≤ N := by
        have hle : (ξ.convergent m).den ≤ (ξ.convergent (Nat.find hex)).den :=
          hmono (le_of_lt hm)
        rw [Nat.find_spec hex] at hle
        exact hle
      exact lt_of_le_of_ne hmle hmne
    obtain ⟨M, hM1, hMN, hMle⟩ := key_notDen hND
    exact absurd (hbest M hM1 hMN) (not_lt.mpr hMle)
  · -- `RHS → LHS`: `q_n` already beats every smaller `M` by `(C1)`, and `‖N·ξ‖ ≤ |q_n·ξ − p_n|`.
    rintro ⟨n, hNeq, hrec⟩ M hM1 hMN
    have hMne : M ≠ (ξ.convergent n).den := by rw [← hNeq]; exact ne_of_lt hMN
    have h1 : (ξ.convergent n).den ≤ (ξ.convergent (n + 1)).den := convergent_den_le_succ hξ n
    have hMqn : M < (ξ.convergent n).den := hNeq ▸ hMN
    have hMlt : ((M : ℤ) : ℝ) < cfDen ξ (n + 1) := by
      have hMq1 : M < (ξ.convergent (n + 1)).den := by omega
      show ((M : ℤ) : ℝ) < (GenContFract.of ξ).dens (n + 1)
      rw [← convergent_den_cast hξ (n + 1)]
      have hcast : ((M : ℤ) : ℝ) = (M : ℝ) := by push_cast; ring
      rw [hcast]; exact_mod_cast hMq1
    have hC1 := hC1lt n M hM1 hMlt hMne
    have hEN : nearestError ξ N ≤ |cfDen ξ n * ξ - cfNum ξ n| := by rw [hNeq]; exact hErrLe n
    exact lt_of_le_of_lt hEN hC1

end

end Real
