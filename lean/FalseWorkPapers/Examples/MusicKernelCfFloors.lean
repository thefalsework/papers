/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# Continued-fraction floor lemmas for `α = log₂(3/2)`

Certified from `αLo`/`αHi` via the fract pipeline in `MusicKernelLogBounds`.
Partial quotients through depth six: `1, 1, 2, 2, 3, 1, 5`.
-/
import FalseWorkPapers.Examples.MusicKernelLogBounds

namespace FalseWork.MusicKernelCfFloors

open Real FalseWork.MusicKernel FalseWork.MusicKernelLogBounds

noncomputable section

set_option maxHeartbeats 800000 in

private def cfF1 : ℝ := Int.fract (1 / α)
private def cfI1 : ℝ := 1 / cfF1
private def cfF2 : ℝ := Int.fract cfI1
private def cfI2 : ℝ := 1 / cfF2
private def cfF3 : ℝ := Int.fract cfI2
private def cfI3 : ℝ := 1 / cfF3
private def cfF4 : ℝ := Int.fract cfI3
private def cfI4 : ℝ := 1 / cfF4
private def cfF5 : ℝ := Int.fract cfI4
private def cfI5 : ℝ := 1 / cfF5
private def cfF6 : ℝ := Int.fract cfI5
private def cfI6 : ℝ := 1 / cfF6

private def loF1 : ℝ := 1 / αHi - 1
private def hiF1 : ℝ := 1 / αLo - 1
private def loI1 : ℝ := (5953011031984665464908921 : ℝ) / 4223728622736800109581191
private def hiI1 : ℝ := (347352544090073572470703 : ℝ) / 246450440268977610917969
private def loF2 : ℝ := (1729282409247865355327730 : ℝ) / 4223728622736800109581191
private def hiF2 : ℝ := (100902103821095961552734 : ℝ) / 246450440268977610917969
private def loI2 : ℝ := (246450440268977610917969 : ℝ) / 100902103821095961552734
private def hiI2 : ℝ := (4223728622736800109581191 : ℝ) / 1729282409247865355327730
private def loF3 : ℝ := (44646232626785687812501 : ℝ) / 100902103821095961552734
private def hiF3 : ℝ := (765163804241069398925731 : ℝ) / 1729282409247865355327730
private def loI3 : ℝ := (1729282409247865355327730 : ℝ) / 765163804241069398925731
private def hiI3 : ℝ := (100902103821095961552734 : ℝ) / 44646232626785687812501
private def loF4 : ℝ := (198954800765726557476268 : ℝ) / 765163804241069398925731
private def hiF4 : ℝ := (11609638567524585927732 : ℝ) / 44646232626785687812501
private def loI4 : ℝ := (44646232626785687812501 : ℝ) / 11609638567524585927732
private def hiI4 : ℝ := (765163804241069398925731 : ℝ) / 198954800765726557476268
private def loF5 : ℝ := (9817316924211930029305 : ℝ) / 11609638567524585927732
private def hiF5 : ℝ := (168299401943889726496927 : ℝ) / 198954800765726557476268
private def loI5 : ℝ := (198954800765726557476268 : ℝ) / 168299401943889726496927
private def hiI5 : ℝ := (11609638567524585927732 : ℝ) / 9817316924211930029305
private def loF6 : ℝ := (30655398821836830979341 : ℝ) / 168299401943889726496927
private def hiF6 : ℝ := (1792321643312655898427 : ℝ) / 9817316924211930029305
private def loI6 : ℝ := (9817316924211930029305 : ℝ) / 1792321643312655898427
private def hiI6 : ℝ := (168299401943889726496927 : ℝ) / 30655398821836830979341

private theorem cfF1_gt_loF1 : loF1 < cfF1 := by
  unfold cfF1 loF1
  exact fract_one_div_α_lo

private theorem cfF1_lt_hiF1 : cfF1 < hiF1 := by
  unfold cfF1 hiF1
  exact fract_one_div_α_hi

private theorem cfF1_pos : 0 < cfF1 := fract_one_div_α_pos

private theorem loF1_pos : 0 < loF1 := by unfold loF1; rw [invAlphaHi]; norm_num
private theorem hiF1_pos : 0 < hiF1 := by unfold hiF1; rw [invAlphaLo]; norm_num
private theorem loI1_pos : 0 < loI1 := by unfold loI1; norm_num
private theorem hiI1_pos : 0 < hiI1 := by unfold hiI1; norm_num

private theorem loI1_eq_inv_hiF1 : loI1 = 1 / hiF1 := by unfold loI1 hiF1; rw [invAlphaLo]; norm_num
private theorem hiI1_eq_inv_loF1 : hiI1 = 1 / loF1 := by unfold hiI1 loF1; rw [invAlphaHi]; norm_num
private theorem loI1_gt_one : (1 : ℝ) < loI1 := by unfold loI1; norm_num

private theorem cfI1_gt_loI1 : loI1 < cfI1 := by
  unfold cfI1
  rw [loI1_eq_inv_hiF1]
  exact (one_div_lt_one_div hiF1_pos cfF1_pos).mpr cfF1_lt_hiF1

private theorem cfI1_lt_hiI1 : cfI1 < hiI1 := by
  unfold cfI1
  rw [hiI1_eq_inv_loF1]
  exact (one_div_lt_one_div cfF1_pos loF1_pos).mpr cfF1_gt_loF1

private theorem cfI1_pos : 0 < cfI1 := loI1_pos.trans cfI1_gt_loI1

private theorem loF2_eq_loI1_sub_one : loF2 = loI1 - 1 := by unfold loF2 loI1; norm_num

private theorem hiF2_eq_hiI1_sub_one : hiF2 = hiI1 - 1 := by unfold hiF2 hiI1; norm_num

private theorem cfF2_eq : cfF2 = cfI1 - 1 := by
  unfold cfF2
  rw [Int.fract]
  unfold cfI1 cfF1
  rw [floor_one_div_fract_one_div_α_eq_one]
  ring

private theorem cfF2_gt_loF2 : loF2 < cfF2 := by
  rw [cfF2_eq, loF2_eq_loI1_sub_one]
  linarith [cfI1_gt_loI1]

private theorem cfF2_lt_hiF2 : cfF2 < hiF2 := by
  rw [cfF2_eq, hiF2_eq_hiI1_sub_one]
  linarith [cfI1_lt_hiI1]

private theorem loF2_pos : 0 < loF2 := by unfold loF2; norm_num

private theorem cfF2_pos : 0 < cfF2 := loF2_pos.trans cfF2_gt_loF2

private theorem hiF2_le_half : hiF2 ≤ (1 / 2 : ℝ) := by unfold hiF2; norm_num

private theorem loF2_gt_third : (1 / 3 : ℝ) < loF2 := by unfold loF2; norm_num

private theorem hiF2_pos : 0 < hiF2 := by unfold hiF2; norm_num
private theorem loI2_eq_inv_hiF2 : loI2 = 1 / hiF2 := by unfold loI2 hiF2; field_simp
private theorem hiI2_eq_inv_loF2 : hiI2 = 1 / loF2 := by unfold hiI2 loF2; field_simp
private theorem loI2_pos : 0 < loI2 := by unfold loI2; norm_num

private theorem cfI2_gt_loI2 : loI2 < cfI2 := by
  unfold cfI2
  rw [loI2_eq_inv_hiF2]
  exact (one_div_lt_one_div hiF2_pos cfF2_pos).mpr cfF2_lt_hiF2

private theorem cfI2_lt_hiI2 : cfI2 < hiI2 := by
  unfold cfI2
  rw [hiI2_eq_inv_loF2]
  exact (one_div_lt_one_div cfF2_pos loF2_pos).mpr cfF2_gt_loF2

theorem floor_cfI2_eq_two : ⌊cfI2⌋ = 2 := by
  have hle : 2 * cfF2 ≤ 1 := by linarith [cfF2_lt_hiF2, hiF2_le_half]
  have hlo : (2 : ℝ) ≤ cfI2 := (le_div_iff₀ cfF2_pos).2 hle
  have hgt : (1 / 3 : ℝ) < cfF2 := loF2_gt_third.trans cfF2_gt_loF2
  have hlt : cfI2 < 3 := (div_lt_iff₀ cfF2_pos).2 (by linarith : 1 < 3 * cfF2)
  exact (Int.floor_eq_iff).2 ⟨by exact_mod_cast hlo, by exact_mod_cast hlt⟩

private theorem cfF3_eq : cfF3 = cfI2 - 2 := by
  unfold cfF3
  rw [Int.fract, floor_cfI2_eq_two]
  ring

private theorem loI2_gt_two : (2 : ℝ) < loI2 := by unfold loI2; norm_num

private theorem cfF3_pos : 0 < cfF3 := by
  rw [cfF3_eq]
  linarith [cfI2_gt_loI2, loI2_gt_two]

private theorem loF3_eq_loI2_sub_two : loF3 = loI2 - 2 := by unfold loF3 loI2; norm_num
private theorem hiF3_eq_hiI2_sub_two : hiF3 = hiI2 - 2 := by unfold hiF3 hiI2; norm_num

private theorem cfF3_gt_loF3 : loF3 < cfF3 := by
  rw [cfF3_eq, loF3_eq_loI2_sub_two]
  linarith [cfI2_gt_loI2]

private theorem cfF3_lt_hiF3 : cfF3 < hiF3 := by
  rw [cfF3_eq, hiF3_eq_hiI2_sub_two]
  linarith [cfI2_lt_hiI2]

private theorem hiF3_le_half : hiF3 ≤ (1 / 2 : ℝ) := by unfold hiF3; norm_num

private theorem loF3_gt_third : (1 / 3 : ℝ) < loF3 := by unfold loF3; norm_num

private theorem loF3_pos : 0 < loF3 := by unfold loF3; norm_num
private theorem hiF3_pos : 0 < hiF3 := by unfold hiF3; norm_num
private theorem loI3_eq_inv_hiF3 : loI3 = 1 / hiF3 := by unfold loI3 hiF3; field_simp
private theorem hiI3_eq_inv_loF3 : hiI3 = 1 / loF3 := by unfold hiI3 loF3; field_simp
private theorem loI3_pos : 0 < loI3 := by unfold loI3; norm_num

private theorem cfI3_gt_loI3 : loI3 < cfI3 := by
  unfold cfI3
  rw [loI3_eq_inv_hiF3]
  exact (one_div_lt_one_div hiF3_pos cfF3_pos).mpr cfF3_lt_hiF3

private theorem cfI3_lt_hiI3 : cfI3 < hiI3 := by
  unfold cfI3
  rw [hiI3_eq_inv_loF3]
  exact (one_div_lt_one_div cfF3_pos loF3_pos).mpr cfF3_gt_loF3

theorem floor_cfI3_eq_two : ⌊cfI3⌋ = 2 := by
  have hle : 2 * cfF3 ≤ 1 := by linarith [cfF3_lt_hiF3, hiF3_le_half]
  have hlo : (2 : ℝ) ≤ cfI3 := (le_div_iff₀ cfF3_pos).2 hle
  have hgt : (1 / 3 : ℝ) < cfF3 := loF3_gt_third.trans cfF3_gt_loF3
  have hlt : cfI3 < 3 := (div_lt_iff₀ cfF3_pos).2 (by linarith : 1 < 3 * cfF3)
  exact (Int.floor_eq_iff).2 ⟨by exact_mod_cast hlo, by exact_mod_cast hlt⟩

private theorem cfF4_eq : cfF4 = cfI3 - 2 := by
  unfold cfF4
  rw [Int.fract, floor_cfI3_eq_two]
  ring

private theorem loI3_gt_two : (2 : ℝ) < loI3 := by unfold loI3; norm_num

private theorem cfF4_pos : 0 < cfF4 := by
  rw [cfF4_eq]
  linarith [cfI3_gt_loI3, loI3_gt_two]

private theorem cfF4_gt_loF4 : loF4 < cfF4 := by
  rw [cfF4_eq, show loF4 = loI3 - 2 by unfold loF4 loI3; norm_num]
  linarith [cfI3_gt_loI3]

private theorem cfF4_lt_hiF4 : cfF4 < hiF4 := by
  rw [cfF4_eq, show hiF4 = hiI3 - 2 by unfold hiF4 hiI3; norm_num]
  linarith [cfI3_lt_hiI3]

private theorem hiF4_le_third : hiF4 ≤ (1 / 3 : ℝ) := by unfold hiF4; norm_num

private theorem loF4_gt_quarter : (1 / 4 : ℝ) < loF4 := by unfold loF4; norm_num

private theorem loF4_pos : 0 < loF4 := by unfold loF4; norm_num
private theorem hiF4_pos : 0 < hiF4 := by unfold hiF4; norm_num
private theorem loI4_eq_inv_hiF4 : loI4 = 1 / hiF4 := by unfold loI4 hiF4; field_simp
private theorem hiI4_eq_inv_loF4 : hiI4 = 1 / loF4 := by unfold hiI4 loF4; field_simp
private theorem loI4_pos : 0 < loI4 := by unfold loI4; norm_num

private theorem cfI4_gt_loI4 : loI4 < cfI4 := by
  unfold cfI4
  rw [loI4_eq_inv_hiF4]
  exact (one_div_lt_one_div hiF4_pos cfF4_pos).mpr cfF4_lt_hiF4

private theorem cfI4_lt_hiI4 : cfI4 < hiI4 := by
  unfold cfI4
  rw [hiI4_eq_inv_loF4]
  exact (one_div_lt_one_div cfF4_pos loF4_pos).mpr cfF4_gt_loF4

theorem floor_cfI4_eq_three : ⌊cfI4⌋ = 3 := by
  have hle : 3 * cfF4 ≤ 1 := by linarith [cfF4_lt_hiF4, hiF4_le_third]
  have hlo : (3 : ℝ) ≤ cfI4 := (le_div_iff₀ cfF4_pos).2 hle
  have hgt : (1 / 4 : ℝ) < cfF4 := loF4_gt_quarter.trans cfF4_gt_loF4
  have hlt : cfI4 < 4 := (div_lt_iff₀ cfF4_pos).2 (by linarith : 1 < 4 * cfF4)
  exact (Int.floor_eq_iff).2 ⟨by exact_mod_cast hlo, by exact_mod_cast hlt⟩

private theorem cfF5_eq : cfF5 = cfI4 - 3 := by
  unfold cfF5
  rw [Int.fract, floor_cfI4_eq_three]
  ring

private theorem loI4_gt_three : (3 : ℝ) < loI4 := by unfold loI4; norm_num

private theorem cfF5_pos : 0 < cfF5 := by
  rw [cfF5_eq]
  linarith [cfI4_gt_loI4, loI4_gt_three]

private theorem cfF5_gt_loF5 : loF5 < cfF5 := by
  rw [cfF5_eq, show loF5 = loI4 - 3 by unfold loF5 loI4; norm_num]
  linarith [cfI4_gt_loI4]

private theorem cfF5_lt_hiF5 : cfF5 < hiF5 := by
  rw [cfF5_eq, show hiF5 = hiI4 - 3 by unfold hiF5 hiI4; norm_num]
  linarith [cfI4_lt_hiI4]

private theorem hiF5_lt_one : hiF5 < (1 : ℝ) := by unfold hiF5; norm_num

private theorem loF5_gt_half : (1 / 2 : ℝ) < loF5 := by unfold loF5; norm_num

private theorem loF5_pos : 0 < loF5 := by unfold loF5; norm_num
private theorem hiF5_pos : 0 < hiF5 := by unfold hiF5; norm_num
private theorem loI5_eq_inv_hiF5 : loI5 = 1 / hiF5 := by unfold loI5 hiF5; field_simp
private theorem hiI5_eq_inv_loF5 : hiI5 = 1 / loF5 := by unfold hiI5 loF5; field_simp
private theorem loI5_pos : 0 < loI5 := by unfold loI5; norm_num
private theorem loI5_gt_one : (1 : ℝ) < loI5 := by unfold loI5; norm_num

private theorem cfI5_gt_loI5 : loI5 < cfI5 := by
  unfold cfI5
  rw [loI5_eq_inv_hiF5]
  exact (one_div_lt_one_div hiF5_pos cfF5_pos).mpr cfF5_lt_hiF5

private theorem cfI5_lt_hiI5 : cfI5 < hiI5 := by
  unfold cfI5
  rw [hiI5_eq_inv_loF5]
  exact (one_div_lt_one_div cfF5_pos loF5_pos).mpr cfF5_gt_loF5

theorem floor_cfI5_eq_one : ⌊cfI5⌋ = 1 := by
  have hle : 1 * cfF5 ≤ 1 := by linarith [cfF5_lt_hiF5, hiF5_lt_one]
  have hlo : (1 : ℝ) ≤ cfI5 := (le_div_iff₀ cfF5_pos).2 hle
  have hgt : (1 / 2 : ℝ) < cfF5 := loF5_gt_half.trans cfF5_gt_loF5
  have hlt : cfI5 < 2 := (div_lt_iff₀ cfF5_pos).2 (by linarith : 1 < 2 * cfF5)
  exact (Int.floor_eq_iff).2 ⟨by exact_mod_cast hlo, by exact_mod_cast hlt⟩

private theorem cfF6_eq : cfF6 = cfI5 - 1 := by
  unfold cfF6
  rw [Int.fract, floor_cfI5_eq_one]
  ring

private theorem loF6_pos : 0 < loF6 := by unfold loF6; norm_num

private theorem cfF6_gt_loF6 : loF6 < cfF6 := by
  rw [cfF6_eq, show loF6 = loI5 - 1 by unfold loF6 loI5; norm_num]
  linarith [cfI5_gt_loI5]

private theorem cfF6_pos : 0 < cfF6 := loF6_pos.trans cfF6_gt_loF6

private theorem cfF6_lt_hiF6 : cfF6 < hiF6 := by
  rw [cfF6_eq, show hiF6 = hiI5 - 1 by unfold hiF6 hiI5; norm_num]
  linarith [cfI5_lt_hiI5]

private theorem hiF6_le_fifth : hiF6 ≤ (1 / 5 : ℝ) := by unfold hiF6; norm_num

private theorem loF6_gt_sixth : (1 / 6 : ℝ) < loF6 := by unfold loF6; norm_num

private theorem hiF6_pos : 0 < hiF6 := by unfold hiF6; norm_num
private theorem loI6_eq_inv_hiF6 : loI6 = 1 / hiF6 := by unfold loI6 hiF6; field_simp
private theorem hiI6_eq_inv_loF6 : hiI6 = 1 / loF6 := by unfold hiI6 loF6; field_simp
private theorem loI6_pos : 0 < loI6 := by unfold loI6; norm_num

private theorem cfI6_gt_loI6 : loI6 < cfI6 := by
  unfold cfI6
  rw [loI6_eq_inv_hiF6]
  exact (one_div_lt_one_div hiF6_pos cfF6_pos).mpr cfF6_lt_hiF6

private theorem cfI6_lt_hiI6 : cfI6 < hiI6 := by
  unfold cfI6
  rw [hiI6_eq_inv_loF6]
  exact (one_div_lt_one_div cfF6_pos loF6_pos).mpr cfF6_gt_loF6

theorem floor_cfI6_eq_five : ⌊cfI6⌋ = 5 := by
  have hle : 5 * cfF6 ≤ 1 := by linarith [cfF6_lt_hiF6, hiF6_le_fifth]
  have hlo : (5 : ℝ) ≤ cfI6 := (le_div_iff₀ cfF6_pos).2 hle
  have hlt : cfI6 < 6 := (div_lt_iff₀ cfF6_pos).2 (by linarith [cfF6_gt_loF6, loF6_gt_sixth] : 1 < 6 * cfF6)
  exact (Int.floor_eq_iff).2 ⟨by exact_mod_cast hlo, by exact_mod_cast hlt⟩

/-! Nested `Int.fract` forms (for `Real.convergent` recursion). -/

theorem floor_invFract2_eq_two :
    ⌊(1 / (Int.fract (1 / (Int.fract (1 / α)))))⌋ = 2 :=
  floor_cfI2_eq_two

theorem floor_invFract3_eq_two :
    ⌊(1 / (Int.fract (1 / (Int.fract (1 / (Int.fract (1 / α)))))))⌋ = 2 :=
  floor_cfI3_eq_two

theorem floor_invFract4_eq_three :
    ⌊(1 / (Int.fract (1 / (Int.fract (1 / (Int.fract (1 / (Int.fract (1 / α)))))))))⌋ = 3 :=
  floor_cfI4_eq_three

theorem floor_invFract5_eq_one :
    ⌊(1 / (Int.fract (1 / (Int.fract (1 / (Int.fract (1 / (Int.fract (1 / (Int.fract (1 / α)))))))))))⌋ = 1 :=
  floor_cfI5_eq_one

theorem floor_invFract6_eq_five :
    ⌊(1 / (Int.fract (1 / (Int.fract (1 / (Int.fract (1 / (Int.fract (1 / (Int.fract (1 / (Int.fract (1 / α)))))))))))))⌋ = 5 :=
  floor_cfI6_eq_five

end

end FalseWork.MusicKernelCfFloors
