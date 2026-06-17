/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# Continued-fraction convergent denominators of `α = log₂(3/2)` — Phase 1
-/
import Mathlib.NumberTheory.DiophantineApproximation.Basic
import FalseWorkPapers.Examples.MusicKernelLogBounds
import FalseWorkPapers.Examples.MusicKernelCfFloors

namespace FalseWork.Pythagorean

open Real FalseWork.MusicKernel FalseWork.MusicKernelLogBounds FalseWork.MusicKernelCfFloors

noncomputable section

private theorem α_lt_one_local : α < 1 := by
  rw [log_three_halves_eq]
  have hlog2 : 0 < log 2 := log_pos (by norm_num : (1 : ℝ) < 2)
  have h : log 3 < log 4 := log_lt_log (by norm_num : (0 : ℝ) < 3) (by norm_num : (3 : ℝ) < 4)
  have h₄ : log 4 = 2 * log 2 := by
    calc log 4
        _ = log (2 ^ 2) := by norm_num
        _ = 2 * log 2 := by rw [log_pow]; norm_num
  have h32 : log 3 < 2 * log 2 := by rw [← h₄]; exact h
  linarith [(div_lt_iff₀ hlog2).2 h32]

private theorem floor_α_eq_zero : ⌊α⌋ = 0 := by
  have h₀ : (0 : ℤ) ≤ α := by exact_mod_cast α_pos.le
  have h₁ : α < (0 : ℤ) + 1 := by simpa using α_lt_one_local
  exact (Int.floor_eq_iff).2 ⟨h₀, h₁⟩

private theorem fract_α_eq : Int.fract α = α := by
  rw [Int.fract, floor_α_eq_zero]
  ring

private theorem inv_fract_α_eq : (Int.fract α)⁻¹ = 1 / α := by
  rw [fract_α_eq]
  field_simp [α_pos.ne']

private theorem conv_one_invAlpha_eq_two : (1 / α).convergent 1 = (2 : ℚ) := by
  rw [convergent_succ (1 / α) 0, floor_one_div_α_eq_one]
  have hfr0 : ((Int.fract (1 / α))⁻¹.convergent 0) = (1 : ℚ) := by
    have hfloor' : ⌊(Int.fract (1 / α))⁻¹⌋ = 1 := by
      simpa [one_div] using floor_one_div_fract_one_div_α_eq_one
    rw [convergent_zero, hfloor']
    norm_cast
  rw [hfr0]
  norm_num

theorem qConv_two : (α.convergent 2).den = 2 := by
  rw [convergent_succ α 1, floor_α_eq_zero, inv_fract_α_eq, conv_one_invAlpha_eq_two]
  native_decide

private theorem conv_xi1_one : ((Int.fract (1 / α))⁻¹.convergent 1) = (3 / 2 : ℚ) := by
  rw [convergent_succ]
  have hfloor1 : ⌊(Int.fract (1 / α))⁻¹⌋ = 1 := by
    simpa [one_div] using floor_one_div_fract_one_div_α_eq_one
  rw [hfloor1]
  have hfloor2 : ⌊((Int.fract (Int.fract (1 / α))⁻¹)⁻¹)⌋ = 2 := by
    simpa [one_div] using floor_invFract2_eq_two
  rw [convergent_zero, hfloor2]
  norm_num

private theorem conv_invAlpha_two : (1 / α).convergent 2 = (5 / 3 : ℚ) := by
  rw [convergent_succ, floor_one_div_α_eq_one, conv_xi1_one]
  norm_num

theorem qConv_three : (α.convergent 3).den = 5 := by
  rw [convergent_succ α 2, floor_α_eq_zero, inv_fract_α_eq, conv_invAlpha_two]
  native_decide

private theorem conv_xi1_two : ((Int.fract (1 / α))⁻¹.convergent 2) = (7 / 5 : ℚ) := by
  rw [convergent_succ]
  have hfloor1 : ⌊(Int.fract (1 / α))⁻¹⌋ = 1 := by
    simpa [one_div] using floor_one_div_fract_one_div_α_eq_one
  rw [hfloor1]
  have hmid : ((Int.fract (Int.fract (1 / α))⁻¹)⁻¹.convergent 1) = (5 / 2 : ℚ) := by
    rw [convergent_succ]
    have hf : ⌊(Int.fract (Int.fract (1 / α))⁻¹)⁻¹⌋ = 2 := by
      simpa [one_div] using floor_invFract2_eq_two
    rw [hf]
    have hfloor2 : ⌊((Int.fract (Int.fract (Int.fract (1 / α))⁻¹)⁻¹)⁻¹)⌋ = 2 := by
      simpa [one_div] using floor_invFract3_eq_two
    rw [convergent_zero, hfloor2]
    norm_num
  rw [hmid]
  norm_num

private theorem conv_invAlpha_three : (1 / α).convergent 3 = (12 / 7 : ℚ) := by
  rw [convergent_succ, floor_one_div_α_eq_one, conv_xi1_two]
  norm_num

theorem qConv_four : (α.convergent 4).den = 12 := by
  rw [convergent_succ α 3, floor_α_eq_zero, inv_fract_α_eq, conv_invAlpha_three]
  native_decide

private theorem conv_xi1_three : ((Int.fract (1 / α))⁻¹.convergent 3) = (24 / 17 : ℚ) := by
  rw [convergent_succ]
  have hfloor1 : ⌊(Int.fract (1 / α))⁻¹⌋ = 1 := by
    simpa [one_div] using floor_one_div_fract_one_div_α_eq_one
  rw [hfloor1]
  have hmid : ((Int.fract (Int.fract (1 / α))⁻¹)⁻¹.convergent 2) = (17 / 7 : ℚ) := by
    rw [convergent_succ]
    have hf : ⌊(Int.fract (Int.fract (1 / α))⁻¹)⁻¹⌋ = 2 := by
      simpa [one_div] using floor_invFract2_eq_two
    rw [hf]
    have hinner : ((Int.fract (Int.fract (Int.fract (1 / α))⁻¹)⁻¹)⁻¹.convergent 1) =
        (7 / 3 : ℚ) := by
      rw [convergent_succ]
      have hf3 : ⌊(Int.fract (Int.fract (Int.fract (1 / α))⁻¹)⁻¹)⁻¹⌋ = 2 := by
        simpa [one_div] using floor_invFract3_eq_two
      rw [hf3]
      have hfloor4 : ⌊((Int.fract (Int.fract (Int.fract (Int.fract (1 / α))⁻¹)⁻¹)⁻¹)⁻¹)⌋ = 3 := by
        simpa [one_div] using floor_invFract4_eq_three
      rw [convergent_zero, hfloor4]
      norm_num
    rw [hinner]
    norm_num
  rw [hmid]
  norm_num

private theorem conv_invAlpha_four : (1 / α).convergent 4 = (41 / 24 : ℚ) := by
  rw [convergent_succ, floor_one_div_α_eq_one, conv_xi1_three]
  norm_num

theorem qConv_five : (α.convergent 5).den = 41 := by
  rw [convergent_succ α 4, floor_α_eq_zero, inv_fract_α_eq, conv_invAlpha_four]
  native_decide

private theorem conv_xi1_four : ((Int.fract (1 / α))⁻¹.convergent 4) = (31 / 22 : ℚ) := by
  rw [convergent_succ]
  have hfloor1 : ⌊(Int.fract (1 / α))⁻¹⌋ = 1 := by
    simpa [one_div] using floor_one_div_fract_one_div_α_eq_one
  rw [hfloor1]
  have hmid : ((Int.fract (Int.fract (1 / α))⁻¹)⁻¹.convergent 3) = (22 / 9 : ℚ) := by
    rw [convergent_succ]
    have hf : ⌊(Int.fract (Int.fract (1 / α))⁻¹)⁻¹⌋ = 2 := by
      simpa [one_div] using floor_invFract2_eq_two
    rw [hf]
    have hinner : ((Int.fract (Int.fract (Int.fract (1 / α))⁻¹)⁻¹)⁻¹.convergent 2) =
        (9 / 4 : ℚ) := by
      rw [convergent_succ]
      have hf3 : ⌊(Int.fract (Int.fract (Int.fract (1 / α))⁻¹)⁻¹)⁻¹⌋ = 2 := by
        simpa [one_div] using floor_invFract3_eq_two
      rw [hf3]
      have hdeepest :
          ((Int.fract (Int.fract (Int.fract (Int.fract (1 / α))⁻¹)⁻¹)⁻¹)⁻¹.convergent 1) =
          (4 : ℚ) := by
        rw [convergent_succ]
        have hf4 : ⌊(Int.fract (Int.fract (Int.fract (Int.fract (1 / α))⁻¹)⁻¹)⁻¹)⁻¹⌋ = 3 := by
          simpa [one_div] using floor_invFract4_eq_three
        rw [hf4]
        have hfloor4 :
            ⌊((Int.fract (Int.fract (Int.fract (Int.fract (Int.fract (1 / α))⁻¹)⁻¹)⁻¹)⁻¹)⁻¹)⌋ = 1 := by
          simpa [one_div] using floor_invFract5_eq_one
        rw [convergent_zero, hfloor4]
        norm_num
      rw [hdeepest]
      norm_num
    rw [hinner]
    norm_num
  rw [hmid]
  norm_num

private theorem conv_invAlpha_five : (1 / α).convergent 5 = (53 / 31 : ℚ) := by
  rw [convergent_succ, floor_one_div_α_eq_one, conv_xi1_four]
  norm_num

theorem qConv_six : (α.convergent 6).den = 53 := by
  rw [convergent_succ α 5, floor_α_eq_zero, inv_fract_α_eq, conv_invAlpha_five]
  native_decide

end

end FalseWork.Pythagorean
