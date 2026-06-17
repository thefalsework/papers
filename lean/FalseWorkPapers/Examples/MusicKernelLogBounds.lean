/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# Certified rational bounds on `log 2`, `log 3`, and `α = log₂(3/2)`

Paper 5 §2.2 and `PythagoreanComma.qConv_first_six` need interval bounds on
`α = log 3 / log 2 - 1`.  Bounds come from the power series for
`½ log((1+x)/(1-x))` at `x = 1/3` and `x = 1/2`.

Strict lower bounds use positive tail terms in the power series (partial sums
are strictly increasing).  Strict upper bounds use an `n = 13` series majorant
strictly below the certified `n = 11` rational upper bound.
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Deriv
import Mathlib.Topology.Algebra.InfiniteSum.Basic
import Mathlib.Topology.Algebra.InfiniteSum.Real
import FalseWorkPapers.Examples.MusicKernelIrrationality

namespace FalseWork.MusicKernelLogBounds

open Real Finset FalseWork.MusicKernel

noncomputable section

set_option maxHeartbeats 800000 in

private def logTwoSeries (n : ℕ) : ℝ :=
  2 * ∑ i ∈ range n, (1 / 3 : ℝ) ^ (2 * i + 1) / (2 * i + 1)

private def logThreeSeries (n : ℕ) : ℝ :=
  2 * ∑ i ∈ range n, (1 / 2 : ℝ) ^ (2 * i + 1) / (2 * i + 1)

private def logTwoTail (n : ℕ) : ℝ :=
  2 * ((1 / 3 : ℝ) ^ (2 * n + 1) / (1 - (1 / 3 : ℝ) ^ 2))

private def logThreeTail (n : ℕ) : ℝ :=
  2 * ((1 / 2 : ℝ) ^ (2 * n + 1) / (1 - (1 / 2 : ℝ) ^ 2))

private def logTwoTerm (i : ℕ) : ℝ :=
  2 * (1 / (2 * i + 1 : ℝ)) * (1 / 3 : ℝ) ^ (2 * i + 1)

private def logThreeTerm (i : ℕ) : ℝ :=
  2 * (1 / (2 * i + 1 : ℝ)) * (1 / 2 : ℝ) ^ (2 * i + 1)

private lemma log_sub_log_two :
    log (1 + 1 / 3) - log (1 - 1 / 3) = log 2 := by
  have h := log_div (by norm_num : (1 + 1 / 3 : ℝ) ≠ 0) (by norm_num : (1 - 1 / 3 : ℝ) ≠ 0)
  rw [← h]
  field_simp
  norm_num

private lemma log_sub_log_three :
    log (1 + 1 / 2) - log (1 - 1 / 2) = log 3 := by
  have h := log_div (by norm_num : (1 + 1 / 2 : ℝ) ≠ 0) (by norm_num : (1 - 1 / 2 : ℝ) ≠ 0)
  rw [← h]
  field_simp
  norm_num

private lemma half_log_two :
    (1 / 2 : ℝ) * log ((1 + 1 / 3) / (1 - 1 / 3)) = log 2 / 2 := by
  have h := log_div (by norm_num : (1 + 1 / 3 : ℝ) ≠ 0) (by norm_num : (1 - 1 / 3 : ℝ) ≠ 0)
  rw [h, log_sub_log_two]
  ring

private lemma half_log_three :
    (1 / 2 : ℝ) * log ((1 + 1 / 2) / (1 - 1 / 2)) = log 3 / 2 := by
  have h := log_div (by norm_num : (1 + 1 / 2 : ℝ) ≠ 0) (by norm_num : (1 - 1 / 2 : ℝ) ≠ 0)
  rw [h, log_sub_log_three]
  ring

private theorem logTwoSeries_eq (n : ℕ) :
    logTwoSeries n = ∑ i ∈ range n, logTwoTerm i := by
  unfold logTwoSeries logTwoTerm
  simp [div_eq_mul_inv, mul_assoc, mul_comm, Finset.mul_sum]

private theorem logThreeSeries_eq (n : ℕ) :
    logThreeSeries n = ∑ i ∈ range n, logThreeTerm i := by
  unfold logThreeSeries logThreeTerm
  simp [div_eq_mul_inv, mul_assoc, mul_comm, Finset.mul_sum]

private theorem log_two_series_le (n : ℕ) : logTwoSeries n ≤ log 2 := by
  have hx₀ : (0 : ℝ) ≤ 1 / 3 := by norm_num
  have hx₁ : (1 / 3 : ℝ) < 1 := by norm_num
  have h := sum_range_le_log_div hx₀ hx₁ n
  rw [show logTwoSeries n = 2 * ∑ i ∈ range n, (1 / 3 : ℝ) ^ (2 * i + 1) / (2 * i + 1) from rfl]
  nlinarith [h, half_log_two]

private theorem log_two_series_ge (n : ℕ) :
    log 2 ≤ logTwoSeries n + logTwoTail n := by
  have hx₀ : (0 : ℝ) ≤ 1 / 3 := by norm_num
  have hx₁ : (1 / 3 : ℝ) < 1 := by norm_num
  have h := log_div_le_sum_range_add hx₀ hx₁ n
  rw [half_log_two] at h
  rw [show logTwoSeries n = 2 * ∑ i ∈ range n, (1 / 3 : ℝ) ^ (2 * i + 1) / (2 * i + 1) from rfl]
  unfold logTwoTail
  linarith

private theorem log_three_series_le (n : ℕ) : logThreeSeries n ≤ log 3 := by
  have hx₀ : (0 : ℝ) ≤ 1 / 2 := by norm_num
  have hx₁ : (1 / 2 : ℝ) < 1 := by norm_num
  have h := sum_range_le_log_div hx₀ hx₁ n
  rw [show logThreeSeries n = 2 * ∑ i ∈ range n, (1 / 2 : ℝ) ^ (2 * i + 1) / (2 * i + 1) from rfl]
  nlinarith [h, half_log_three]

private theorem log_three_series_ge (n : ℕ) :
    log 3 ≤ logThreeSeries n + logThreeTail n := by
  have hx₀ : (0 : ℝ) ≤ 1 / 2 := by norm_num
  have hx₁ : (1 / 2 : ℝ) < 1 := by norm_num
  have h := log_div_le_sum_range_add hx₀ hx₁ n
  rw [half_log_three] at h
  rw [show logThreeSeries n = 2 * ∑ i ∈ range n, (1 / 2 : ℝ) ^ (2 * i + 1) / (2 * i + 1) from rfl]
  unfold logThreeTail
  linarith

private theorem logTwoSeries_twelve :
    logTwoSeries 12 =
      (346617686907988864 : ℝ) / 500063617986634845 := by
  unfold logTwoSeries
  norm_num [Finset.sum_range_succ, pow_succ, pow_mul]

private theorem logThreeSeries_twelve :
    logThreeSeries 12 =
      (1541989106264611 : ℝ) / 1403578975518720 := by
  unfold logThreeSeries
  norm_num [Finset.sum_range_succ, pow_succ, pow_mul]

private theorem logTwo_thirteen_majorant_lt_upper_eleven :
    logTwoSeries 13 + logTwoTail 13 <
      (1386470747637267191 : ℝ) / 2000254471946539380 := by
  unfold logTwoSeries logTwoTail
  norm_num [Finset.sum_range_succ, pow_succ, pow_mul]

private theorem logThree_thirteen_majorant_lt_upper_eleven :
    logThreeSeries 13 + logThreeTail 13 <
      (770994608905523 : ℝ) / 701789487759360 := by
  unfold logThreeSeries logThreeTail
  norm_num [Finset.sum_range_succ, pow_succ, pow_mul]

private theorem logTwoTerm_pos (i : ℕ) : 0 < logTwoTerm i := by
  unfold logTwoTerm
  positivity

private theorem logThreeTerm_pos (i : ℕ) : 0 < logThreeTerm i := by
  unfold logThreeTerm
  positivity

private theorem logTwoSeries_summable : Summable logTwoTerm :=
  (hasSum_log_sub_log_of_abs_lt_one (by norm_num : |(1 / 3 : ℝ)| < 1)).summable

private theorem logThreeSeries_summable : Summable logThreeTerm :=
  (hasSum_log_sub_log_of_abs_lt_one (by norm_num : |(1 / 2 : ℝ)| < 1)).summable

private theorem sum_range_lt_tsum_of_pos {f : ℕ → ℝ} (hf : ∀ i, 0 < f i)
    (hsumm : Summable f) (n : ℕ) :
    ∑ i ∈ range n, f i < ∑' i, f i := by
  have hmono : StrictMono fun k => ∑ i ∈ range k, f i := by
    refine strictMono_nat_of_lt_succ fun k => ?_
    rw [sum_range_succ]
    linarith [hf k]
  have h1 : ∑ i ∈ range n, f i < ∑ i ∈ range (n + 1), f i := hmono (Nat.lt_succ_self n)
  have h2 : ∑ i ∈ range (n + 1), f i ≤ ∑' i, f i :=
    hsumm.sum_le_tsum (range (n + 1)) fun _ _ => (hf _).le
  linarith

private theorem logTwoSeries_twelve_lt_log_two : logTwoSeries 12 < log 2 := by
  have hfull :
      ∑' i, logTwoTerm i = log (1 + 1 / 3) - log (1 - 1 / 3) :=
    (hasSum_log_sub_log_of_abs_lt_one (by norm_num : |(1 / 3 : ℝ)| < 1)).tsum_eq
  have hlt := sum_range_lt_tsum_of_pos (f := logTwoTerm) (fun i => logTwoTerm_pos i)
    logTwoSeries_summable 12
  rw [hfull, log_sub_log_two] at hlt
  exact (logTwoSeries_eq 12) ▸ hlt

private theorem logThreeSeries_twelve_lt_log_three : logThreeSeries 12 < log 3 := by
  have hfull :
      ∑' i, logThreeTerm i = log (1 + 1 / 2) - log (1 - 1 / 2) :=
    (hasSum_log_sub_log_of_abs_lt_one (by norm_num : |(1 / 2 : ℝ)| < 1)).tsum_eq
  have hlt := sum_range_lt_tsum_of_pos (f := logThreeTerm) (fun i => logThreeTerm_pos i)
    logThreeSeries_summable 12
  rw [hfull, log_sub_log_three] at hlt
  exact (logThreeSeries_eq 12) ▸ hlt

private theorem logThree_lo_le_series_twelve :
    (1541989106264611 : ℝ) / 1403578975518720 ≤ logThreeSeries 12 := by
  rw [logThreeSeries_twelve]

private theorem α_lower_cross :
    ((5953011031984665464908921 : ℝ) / 10176739654721465574490112 + 1) *
        (1386470747637267191 : ℝ) / 2000254471946539380 =
      (1541989106264611 : ℝ) / 1403578975518720 := by norm_num

private theorem α_upper_cross_strict :
    (1541989106264611 : ℝ) / 1403578975518720 <
      ((347352544090073572470703 : ℝ) / 593802984359051183388672 + 1) *
        (1386470747637267191 : ℝ) / 2000254471946539380 := by norm_num

theorem log_two_gt : (69314718055984 : ℝ) / 100000000000000 < log 2 := by
  have h := logTwoSeries_twelve_lt_log_two
  rw [logTwoSeries_twelve] at h
  linarith [h, show (69314718055984 : ℝ) / 100000000000000 ≤
    (346617686907988864 : ℝ) / 500063617986634845 from by norm_num]

theorem log_two_lt :
    log 2 < (1386470747637267191 : ℝ) / 2000254471946539380 := by
  linarith [log_two_series_ge 13, logTwo_thirteen_majorant_lt_upper_eleven]

theorem log_three_gt : (1541989106264611 : ℝ) / 1403578975518720 < log 3 := by
  linarith [logThreeSeries_twelve_lt_log_three, logThree_lo_le_series_twelve]

theorem log_three_lt :
    log 3 < (770994608905523 : ℝ) / 701789487759360 := by
  linarith [log_three_series_ge 13, logThree_thirteen_majorant_lt_upper_eleven]

theorem α_gt : (5953011031984665464908921 : ℝ) / 10176739654721465574490112 < α := by
  unfold α logTwoThree
  have hlog2 : (0 : ℝ) < log 2 := log_pos (by norm_num : (1 : ℝ) < 2)
  have hmain :
      ((5953011031984665464908921 : ℝ) / 10176739654721465574490112 + 1) * log 2 < log 3 := by
    nlinarith [log_three_gt, log_two_lt, α_lower_cross]
  calc
    (5953011031984665464908921 : ℝ) / 10176739654721465574490112
        < log 3 / log 2 - (1 : ℝ) := (lt_sub_iff_add_lt).2 ((lt_div_iff₀ hlog2).2 hmain)
    _ = α := by unfold α logTwoThree; ring

private theorem α_lt_main :
    log 3 <
      ((347352544090073572470703 : ℝ) / 593802984359051183388672 + 1) * log 2 := by
  nlinarith [log_two_gt, log_two_lt, log_three_gt, log_three_lt, α_upper_cross_strict]

theorem α_lt : α < (347352544090073572470703 : ℝ) / 593802984359051183388672 := by
  unfold α logTwoThree
  have hlog2 : (0 : ℝ) < log 2 := log_pos (by norm_num : (1 : ℝ) < 2)
  have hmain := α_lt_main
  calc
    α = log 3 / log 2 - 1 := by unfold α logTwoThree; ring
    _ < (347352544090073572470703 : ℝ) / 593802984359051183388672 :=
      (sub_lt_iff_lt_add).2 ((div_lt_iff₀ hlog2).2 hmain)

theorem α_interval :
    (5953011031984665464908921 : ℝ) / 10176739654721465574490112 < α ∧
    α < (347352544090073572470703 : ℝ) / 593802984359051183388672 :=
  ⟨α_gt, α_lt⟩

/-- Certified lower bound on `α = log₂(3/2)` (Paper 5 §2.2 interval arithmetic). -/
def αLo : ℝ := (5953011031984665464908921 : ℝ) / 10176739654721465574490112

/-- Certified upper bound on `α`. -/
def αHi : ℝ := (347352544090073572470703 : ℝ) / 593802984359051183388672

theorem αLo_lt_α : αLo < α := α_gt

theorem α_lt_αHi : α < αHi := α_lt

theorem αLo_lt_αHi : αLo < αHi := by linarith [αLo_lt_α, α_lt_αHi]

theorem αLo_pos : 0 < αLo := by unfold αLo; norm_num

theorem αHi_pos : 0 < αHi := by unfold αHi; norm_num

theorem αLo_lt_one : αLo < 1 := by unfold αLo; norm_num

theorem αHi_lt_one : αHi < 1 := by unfold αHi; norm_num

theorem α_lt_one_bound : α < 1 := by linarith [α_lt_αHi, αHi_lt_one]

theorem αLo_gt_half : (1 / 2 : ℝ) < αLo := by unfold αLo; norm_num

theorem invAlphaLo : (1 : ℝ) / αLo =
    (10176739654721465574490112 : ℝ) / 5953011031984665464908921 := by
  unfold αLo; field_simp

theorem invAlphaHi : (1 : ℝ) / αHi =
    (593802984359051183388672 : ℝ) / 347352544090073572470703 := by
  unfold αHi; field_simp

theorem one_div_α_lt_one_div_αLo : 1 / α < 1 / αLo :=
  (one_div_lt_one_div α_pos αLo_pos).mpr αLo_lt_α

theorem one_div_αHi_lt_one_div_α : 1 / αHi < 1 / α :=
  (one_div_lt_one_div αHi_pos α_pos).mpr α_lt_αHi

theorem one_div_αHi_lt_two : 1 / αHi < (2 : ℝ) := by
  rw [invAlphaHi]
  norm_num

theorem one_div_α_gt_one : (1 : ℝ) < 1 / α := by
  rw [one_lt_div α_pos]
  exact α_lt_one_bound

theorem one_div_α_lt_two : 1 / α < (2 : ℝ) := by
  rw [div_lt_iff₀ α_pos]
  linarith [αLo_gt_half, αLo_lt_α]

theorem floor_one_div_α_eq_one : ⌊(1 / α)⌋ = 1 := by
  have hlo : (1 : ℝ) ≤ 1 / α := (le_div_iff₀ α_pos).2 (by linarith [α_lt_one_bound])
  have hhi := one_div_α_lt_two
  exact (Int.floor_eq_iff).2 ⟨by exact_mod_cast hlo, by exact_mod_cast hhi⟩

private theorem one_div_αHi_minus_one_pos : 0 < 1 / αHi - 1 := by
  rw [invAlphaHi]; norm_num

private theorem one_div_αLo_minus_one_pos : 0 < 1 / αLo - 1 := by
  rw [invAlphaLo]; norm_num

theorem fract_one_div_α_pos : 0 < Int.fract (1 / α) := by
  rw [Int.fract, floor_one_div_α_eq_one]
  linarith [one_div_αHi_lt_one_div_α, one_div_αHi_minus_one_pos]

theorem fract_one_div_α_lo :
    1 / αHi - 1 < Int.fract (1 / α) := by
  have hfloor : ⌊(1 / α)⌋ = 1 := floor_one_div_α_eq_one
  rw [Int.fract, hfloor]
  linarith [one_div_αHi_lt_one_div_α]

theorem fract_one_div_α_hi :
    Int.fract (1 / α) < 1 / αLo - 1 := by
  have hfloor : ⌊(1 / α)⌋ = 1 := floor_one_div_α_eq_one
  rw [Int.fract, hfloor]
  linarith [one_div_α_lt_one_div_αLo]

theorem one_div_fract_one_div_α_lo :
    (1 : ℝ) / (1 / αLo - 1) < 1 / (Int.fract (1 / α)) :=
  (one_div_lt_one_div one_div_αLo_minus_one_pos fract_one_div_α_pos).mpr fract_one_div_α_hi

theorem one_div_fract_one_div_α_hi :
    1 / (Int.fract (1 / α)) < (1 : ℝ) / (1 / αHi - 1) :=
  (one_div_lt_one_div fract_one_div_α_pos one_div_αHi_minus_one_pos).mpr fract_one_div_α_lo

theorem one_div_fract_one_div_α_gt_one : (1 : ℝ) < 1 / (Int.fract (1 / α)) := by
  calc (1 : ℝ)
      < 1 / (1 / αLo - 1) := by rw [invAlphaLo]; norm_num
    _ < 1 / (Int.fract (1 / α)) := one_div_fract_one_div_α_lo

theorem one_div_fract_one_div_α_lt_two : 1 / (Int.fract (1 / α)) < (2 : ℝ) := by
  calc 1 / (Int.fract (1 / α))
      < 1 / (1 / αHi - 1) := one_div_fract_one_div_α_hi
    _ < 2 := by rw [invAlphaHi]; norm_num

theorem floor_one_div_fract_one_div_α_eq_one :
    ⌊(1 / (Int.fract (1 / α)))⌋ = 1 := by
  have hlo := one_div_fract_one_div_α_gt_one.le
  have hhi := one_div_fract_one_div_α_lt_two
  exact (Int.floor_eq_iff).2 ⟨by exact_mod_cast hlo, by exact_mod_cast hhi⟩

end

end FalseWork.MusicKernelLogBounds
