/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# Irrationality of `log₂(3/2)` — music-kernel Point 1

Paper 3 § 4 and Paper 5 § 4 use `α = log₂(3/2)` as the fundamental irrational
driving the music-kernel endofunctor.  The mathematical content is the
standard FTA-elementary fact that `log₂ 3` (equivalently `log₂(3/2)`) is
irrational; this file kernel-checks that fact in Lean.

Reuses `DiophantineFloor.rank_two_floor` for the closing contradiction.
Complements `PythagoreanComma.lean` (convergent scaffold) and feeds the
planned music-kernel endofunctor formalization (Points 2–4).
-/
import Mathlib.NumberTheory.Real.Irrational
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import FalseWorkPapers.Examples.DiophantineFloor

namespace FalseWork.MusicKernel

open Real

/-- `log₂ 3`, the octave-to-fifth ratio in log coordinates. -/
noncomputable def logTwoThree : ℝ := log 3 / log 2

/-- The Pythagorean-comma fundamental irrational: `log₂(3/2) = log₂ 3 − 1`. -/
noncomputable def α : ℝ := logTwoThree - (1 : ℕ)

theorem logTwoThree_pos : 0 < logTwoThree := by
  unfold logTwoThree
  exact div_pos (log_pos (by norm_num : (1 : ℝ) < 3)) (log_pos (by norm_num : (1 : ℝ) < 2))

theorem α_pos : 0 < α := by
  unfold α logTwoThree
  have hlog2 : 0 < log 2 := log_pos (by norm_num : (1 : ℝ) < 2)
  have h : (1 : ℝ) < log 3 / log 2 := by
    rw [lt_div_iff₀ hlog2]
    calc
      (1 : ℝ) * log 2 = log 2 := one_mul _
      _ < log 3 := log_lt_log (by norm_num : (0 : ℝ) < 2) (by norm_num : (2 : ℝ) < 3)
  linarith

theorem logTwoThree_ne_zero : logTwoThree ≠ 0 := logTwoThree_pos.ne'

theorem log_three_halves_eq : α = log 3 / log 2 - (1 : ℕ) := rfl

/-- If `b > 0` and `b * log 3 = a * log 2`, then `3^b = 2^a` as positive reals. -/
private theorem pow_eq_of_log_eq {a : ℤ} {b : ℕ} (_hb : 0 < b)
    (h : (b : ℝ) * log 3 = (a : ℝ) * log 2) :
    (3 : ℝ) ^ (b : ℝ) = (2 : ℝ) ^ (a : ℝ) := by
  have h3 : 0 < (3 : ℝ) := by norm_num
  have h2 : 0 < (2 : ℝ) := by norm_num
  have hpos3 : 0 < (3 : ℝ) ^ (b : ℝ) := rpow_pos_of_pos h3 _
  have hpos2 : 0 < (2 : ℝ) ^ (a : ℝ) := rpow_pos_of_pos h2 _
  have hlog' : log ((3 : ℝ) ^ (b : ℝ)) = log ((2 : ℝ) ^ (a : ℝ)) := by
    rw [log_rpow h3, log_rpow h2, h]
  exact log_injOn_pos (Set.mem_Ioi.mpr hpos3) (Set.mem_Ioi.mpr hpos2) hlog'

/-- **Rank-1 irrationality of `log₂ 3`.**  If `log 3 / log 2 = p/q` with `q > 0`,
then `3^q = 2^p`, contradicting unique factorization. -/
theorem log_two_three_irrational : Irrational logTwoThree := by
  rintro ⟨q, hq⟩
  set p := q.num with hpdef
  set b := q.den with hbdef
  have hbpos : 0 < b := q.pos
  have hbne : (b : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr q.den_ne_zero
  have hlog : (b : ℝ) * log 3 = (p : ℝ) * log 2 := by
    have hratio : (p : ℝ) / (b : ℝ) = log 3 / log 2 := by
      calc
        (p : ℝ) / (b : ℝ) = (q : ℝ) := by
          rw [show q = q.num / q.den from (Rat.num_div_den q).symm, hpdef, hbdef]
          norm_cast
        _ = logTwoThree := hq
        _ = log 3 / log 2 := rfl
    field_simp [Nat.cast_ne_zero.mpr q.den_ne_zero] at hratio ⊢
    linarith
  have hpow := pow_eq_of_log_eq hbpos hlog
  rcases lt_trichotomy p 0 with hp | hp | hp
  · -- `p < 0`: `2^p < 1` but `3^b > 1`.
    have hleft : (1 : ℝ) < (3 : ℝ) ^ (b : ℝ) := by
      have hnat : (1 : ℕ) < 3 ^ b := one_lt_pow' (by norm_num : (1 : ℕ) < 3) hbpos.ne'
      rw [rpow_natCast]
      exact_mod_cast hnat
    have hright : (2 : ℝ) ^ (p : ℝ) < 1 :=
      rpow_lt_one_of_one_lt_of_neg (by norm_num : (1 : ℝ) < 2) (by exact_mod_cast hp)
    linarith [hpow]
  · -- `p = 0`: `3^b = 1` forces `b = 0`.
    have hpow1 : (3 : ℝ) ^ (b : ℝ) = 1 := by
      calc
        (3 : ℝ) ^ (b : ℝ) = (2 : ℝ) ^ (p : ℝ) := hpow
        _ = 1 := by rw [hp, rpow_intCast, zpow_zero]
    have hnat : (3 : ℕ) ^ b = 1 := by
      have hcast : (Nat.cast (3 ^ b) : ℝ) = (1 : ℝ) := by
        calc (Nat.cast (3 ^ b) : ℝ)
            _ = (3 : ℝ) ^ b := Nat.cast_pow 3 b
            _ = (3 : ℝ) ^ (b : ℝ) := (Real.rpow_natCast 3 b).symm
            _ = 1 := hpow1
      exact Nat.cast_injective (R := ℝ) (by simpa using hcast)
    rcases FalseWork.Diophantine.rank_two_floor b 0 (by rw [pow_zero]; exact hnat) with ⟨hb0, _⟩
    exact q.pos.ne (by rw [← hbdef, hb0])
  · -- `p > 0`: apply the rank-2 floor on `3^b = 2^p`.
    have hpowNat : 3 ^ b = 2 ^ Int.toNat p := by
      have hcast : (Nat.cast (3 ^ b) : ℝ) = (Nat.cast (2 ^ Int.toNat p) : ℝ) := by
        calc (Nat.cast (3 ^ b) : ℝ)
            _ = (3 : ℝ) ^ b := Nat.cast_pow 3 b
            _ = (3 : ℝ) ^ (b : ℝ) := (Real.rpow_natCast 3 b).symm
            _ = (2 : ℝ) ^ (p : ℝ) := hpow
            _ = (2 : ℝ) ^ p := Real.rpow_intCast 2 p
            _ = (Nat.cast (2 ^ Int.toNat p) : ℝ) := by
              have hpNat : p = Int.ofNat (Int.toNat p) := (Int.toNat_of_nonneg (le_of_lt hp)).symm
              rw [hpNat, Int.ofNat_eq_natCast, zpow_natCast]
              norm_cast
      exact Nat.cast_injective (R := ℝ) hcast
    rcases FalseWork.Diophantine.rank_two_floor b (Int.toNat p) hpowNat with ⟨hb0, _⟩
    exact q.pos.ne (by rw [← hbdef, hb0])

/-- If `b > 0` and `b * log 2 = a * log 10`, then `2^b = 10^a` as positive reals. -/
private theorem pow_eq_of_log_eq_ten {a : ℤ} {b : ℕ} (_hb : 0 < b)
    (h : (b : ℝ) * log 2 = (a : ℝ) * log 10) :
    (2 : ℝ) ^ (b : ℝ) = (10 : ℝ) ^ (a : ℝ) := by
  have h2 : 0 < (2 : ℝ) := by norm_num
  have h10 : 0 < (10 : ℝ) := by norm_num
  have hpos2 : 0 < (2 : ℝ) ^ (b : ℝ) := rpow_pos_of_pos h2 _
  have hpos10 : 0 < (10 : ℝ) ^ (a : ℝ) := rpow_pos_of_pos h10 _
  have hlog' : log ((2 : ℝ) ^ (b : ℝ)) = log ((10 : ℝ) ^ (a : ℝ)) := by
    rw [log_rpow h2, log_rpow h10, h]
  exact log_injOn_pos (Set.mem_Ioi.mpr hpos2) (Set.mem_Ioi.mpr hpos10) hlog'

/-- If `b > 0` and `b * log 3 = a * log 10`, then `3^b = 10^a` as positive reals. -/
private theorem pow_eq_of_log_eq_ten_three {a : ℤ} {b : ℕ} (_hb : 0 < b)
    (h : (b : ℝ) * log 3 = (a : ℝ) * log 10) :
    (3 : ℝ) ^ (b : ℝ) = (10 : ℝ) ^ (a : ℝ) := by
  have h3 : 0 < (3 : ℝ) := by norm_num
  have h10 : 0 < (10 : ℝ) := by norm_num
  have hpos3 : 0 < (3 : ℝ) ^ (b : ℝ) := rpow_pos_of_pos h3 _
  have hpos10 : 0 < (10 : ℝ) ^ (a : ℝ) := rpow_pos_of_pos h10 _
  have hlog' : log ((3 : ℝ) ^ (b : ℝ)) = log ((10 : ℝ) ^ (a : ℝ)) := by
    rw [log_rpow h3, log_rpow h10, h]
  exact log_injOn_pos (Set.mem_Ioi.mpr hpos3) (Set.mem_Ioi.mpr hpos10) hlog'

/-- **`log 2 / log 10` is irrational** — equivalently `2^b = 10^p` only trivially. -/
theorem log_two_over_log_ten_irrational : Irrational (log 2 / log 10) := by
  rintro ⟨q, hq⟩
  set p := q.num with hpdef
  set b := q.den with hbdef
  have hbpos : 0 < b := q.pos
  have hlog : (b : ℝ) * log 2 = (p : ℝ) * log 10 := by
    have hratio : (p : ℝ) / (b : ℝ) = log 2 / log 10 := by
      calc
        (p : ℝ) / (b : ℝ) = (q : ℝ) := by
          rw [show q = q.num / q.den from (Rat.num_div_den q).symm, hpdef, hbdef]
          norm_cast
        _ = log 2 / log 10 := hq
    field_simp [(log_pos (by norm_num : (1 : ℝ) < 10)).ne', Nat.cast_ne_zero.mpr q.den_ne_zero] at hratio ⊢
    linarith
  have hpow := pow_eq_of_log_eq_ten hbpos hlog
  rcases lt_trichotomy p 0 with hp | hp | hp
  · have hleft : (1 : ℝ) < (2 : ℝ) ^ (b : ℝ) := by
      have hnat : (1 : ℕ) < 2 ^ b := one_lt_pow' (by norm_num : (1 : ℕ) < 2) hbpos.ne'
      rw [rpow_natCast]
      exact_mod_cast hnat
    have hright : (10 : ℝ) ^ (p : ℝ) < 1 :=
      rpow_lt_one_of_one_lt_of_neg (by norm_num : (1 : ℝ) < 10) (by exact_mod_cast hp)
    linarith [hpow]
  · have hpow1 : (2 : ℝ) ^ (b : ℝ) = 1 := by
      calc
        (2 : ℝ) ^ (b : ℝ) = (10 : ℝ) ^ (p : ℝ) := hpow
        _ = 1 := by rw [hp, rpow_intCast, zpow_zero]
    have hnat : (2 : ℕ) ^ b = 1 := by
      have hcast : (Nat.cast (2 ^ b) : ℝ) = (1 : ℝ) := by
        calc (Nat.cast (2 ^ b) : ℝ)
            _ = (2 : ℝ) ^ b := Nat.cast_pow 2 b
            _ = (2 : ℝ) ^ (b : ℝ) := (Real.rpow_natCast 2 b).symm
            _ = 1 := hpow1
      exact Nat.cast_injective (R := ℝ) (by simpa using hcast)
    have hb0 := FalseWork.Diophantine.nat_pow_eq_one_of_one_lt 2 b (by norm_num) hnat
    exact hbpos.ne' hb0
  · have hpowNat : 2 ^ b = 10 ^ Int.toNat p := by
      have hcast : (Nat.cast (2 ^ b) : ℝ) = (Nat.cast (10 ^ Int.toNat p) : ℝ) := by
        calc (Nat.cast (2 ^ b) : ℝ)
            _ = (2 : ℝ) ^ b := Nat.cast_pow 2 b
            _ = (2 : ℝ) ^ (b : ℝ) := (Real.rpow_natCast 2 b).symm
            _ = (10 : ℝ) ^ (p : ℝ) := hpow
            _ = (10 : ℝ) ^ p := Real.rpow_intCast 10 p
            _ = (Nat.cast (10 ^ Int.toNat p) : ℝ) := by
              have hpNat : p = Int.ofNat (Int.toNat p) := (Int.toNat_of_nonneg (le_of_lt hp)).symm
              rw [hpNat, Int.ofNat_eq_natCast, zpow_natCast]
              norm_cast
      exact Nat.cast_injective (R := ℝ) hcast
    have hpNat : 0 < Int.toNat p := by omega
    exact FalseWork.Diophantine.rank_two_five_floor b (Int.toNat p) hpNat hpowNat

/-- **`log 3 / log 10` is irrational** — equivalently `3^b = 10^p` only trivially. -/
theorem log_three_over_log_ten_irrational : Irrational (log 3 / log 10) := by
  rintro ⟨q, hq⟩
  set p := q.num with hpdef
  set b := q.den with hbdef
  have hbpos : 0 < b := q.pos
  have hlog : (b : ℝ) * log 3 = (p : ℝ) * log 10 := by
    have hratio : (p : ℝ) / (b : ℝ) = log 3 / log 10 := by
      calc
        (p : ℝ) / (b : ℝ) = (q : ℝ) := by
          rw [show q = q.num / q.den from (Rat.num_div_den q).symm, hpdef, hbdef]
          norm_cast
        _ = log 3 / log 10 := hq
    field_simp [(log_pos (by norm_num : (1 : ℝ) < 10)).ne', Nat.cast_ne_zero.mpr q.den_ne_zero] at hratio ⊢
    linarith
  have hpow := pow_eq_of_log_eq_ten_three hbpos hlog
  rcases lt_trichotomy p 0 with hp | hp | hp
  · have hleft : (1 : ℝ) < (3 : ℝ) ^ (b : ℝ) := by
      have hnat : (1 : ℕ) < 3 ^ b := one_lt_pow' (by norm_num : (1 : ℕ) < 3) hbpos.ne'
      rw [rpow_natCast]
      exact_mod_cast hnat
    have hright : (10 : ℝ) ^ (p : ℝ) < 1 :=
      rpow_lt_one_of_one_lt_of_neg (by norm_num : (1 : ℝ) < 10) (by exact_mod_cast hp)
    linarith [hpow]
  · have hpow1 : (3 : ℝ) ^ (b : ℝ) = 1 := by
      calc
        (3 : ℝ) ^ (b : ℝ) = (10 : ℝ) ^ (p : ℝ) := hpow
        _ = 1 := by rw [hp, rpow_intCast, zpow_zero]
    have hnat : (3 : ℕ) ^ b = 1 := by
      have hcast : (Nat.cast (3 ^ b) : ℝ) = (1 : ℝ) := by
        calc (Nat.cast (3 ^ b) : ℝ)
            _ = (3 : ℝ) ^ b := Nat.cast_pow 3 b
            _ = (3 : ℝ) ^ (b : ℝ) := (Real.rpow_natCast 3 b).symm
            _ = 1 := hpow1
      exact Nat.cast_injective (R := ℝ) (by simpa using hcast)
    have hb0 := FalseWork.Diophantine.nat_pow_eq_one_of_one_lt 3 b (by norm_num) hnat
    exact hbpos.ne' hb0
  · have hpowNat : 3 ^ b = 10 ^ Int.toNat p := by
      have hcast : (Nat.cast (3 ^ b) : ℝ) = (Nat.cast (10 ^ Int.toNat p) : ℝ) := by
        calc (Nat.cast (3 ^ b) : ℝ)
            _ = (3 : ℝ) ^ b := Nat.cast_pow 3 b
            _ = (3 : ℝ) ^ (b : ℝ) := (Real.rpow_natCast 3 b).symm
            _ = (10 : ℝ) ^ (p : ℝ) := hpow
            _ = (10 : ℝ) ^ p := Real.rpow_intCast 10 p
            _ = (Nat.cast (10 ^ Int.toNat p) : ℝ) := by
              have hpNat : p = Int.ofNat (Int.toNat p) := (Int.toNat_of_nonneg (le_of_lt hp)).symm
              rw [hpNat, Int.ofNat_eq_natCast, zpow_natCast]
              norm_cast
      exact Nat.cast_injective (R := ℝ) hcast
    have hpNat : 0 < Int.toNat p := by omega
    exact FalseWork.Diophantine.rank_two_ten_three_floor b (Int.toNat p) hpNat hpowNat

/-- **`log₂(3/2)` is irrational** — the primary music-kernel-01 statement. -/
theorem log_three_halves_irrational : Irrational α := by
  unfold α
  exact log_two_three_irrational.sub_natCast 1

/-- Equivalent rank-2 linear-form non-vanishing (Form C in the claim file). -/
theorem pythagorean_comma_log_nonzero : (12 : ℝ) * log 3 - 19 * log 2 ≠ 0 := by
  intro h
  have hlog2 : log 2 ≠ 0 := (log_pos (by norm_num : (1 : ℝ) < 2)).ne'
  have h1 : 12 * log 3 = 19 * log 2 := by linarith
  have hrat : logTwoThree = (19 : ℝ) / 12 := by
    unfold logTwoThree
    field_simp [hlog2]
    linarith
  exact log_two_three_irrational.ne_rat (19 / 12) (hrat.trans (Rat.cast_div 19 12).symm)

/-- **Music-kernel Point 1 (bundled).** -/
theorem music_kernel_irrationality :
    Irrational α ∧ Irrational logTwoThree ∧
    (12 : ℝ) * log 3 - 19 * log 2 ≠ 0 :=
  ⟨log_three_halves_irrational, log_two_three_irrational, pythagorean_comma_log_nonzero⟩

end FalseWork.MusicKernel
