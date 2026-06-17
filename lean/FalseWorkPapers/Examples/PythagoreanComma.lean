/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# Pythagorean-comma optimal N-TET and continued-fraction convergents

Paper 5 §2.2 narrates the classical fact that the denominators of best
Pythagorean-comma temperaments are the convergent denominators of
`α = log₂(3/2)`.  This file is the Lean scaffold for claim
`validation/claims/optimal-ntet-continued-fraction.md`:

* **Phase 1 (this file):** definitions + computable sanity checks on the
  first convergent denominators.
* **Phase 2:** `(C1)` best-approximation-of-the-second-kind for convergents.
* **Phase 3:** `(C2)` equivalence with strict record-holder denominators.

`α` is aligned with `FalseWork.MusicKernel.α` in
`Examples/MusicKernelIrrationality.lean`.  Complements `WhyTwelve.lean`
(lattice-side forcing of 12) with the Diophantine-approximation side.
-/
import Mathlib.NumberTheory.DiophantineApproximation.Basic
import FalseWorkPapers.Examples.MusicKernelIrrationality
import FalseWorkPapers.Examples.PythagoreanCommaConvergents
import FalseWorkPapers.NumberTheory.ContinuedFractionBestApprox

namespace FalseWork.Pythagorean

open Real FalseWork.MusicKernel

/-- The fundamental irrational of the Pythagorean comma: `log₂(3/2)`.
Aligned with `FalseWork.MusicKernel.α`. -/
noncomputable abbrev α : ℝ := MusicKernel.α

theorem α_eq_musicKernel : α = MusicKernel.α := rfl

theorem α_eq_log_ratio : α = log 3 / log 2 - (1 : ℕ) := by
  rw [α_eq_musicKernel, log_three_halves_eq]

theorem α_pos : 0 < α := MusicKernel.α_pos

/-- `α = log₂(3/2)` lies in `(0, 1)`, as Paper 5 assumes. -/
theorem α_lt_one : α < 1 := by
  rw [α_eq_log_ratio]
  have hlog2 : 0 < log 2 := log_pos (by norm_num : (1 : ℝ) < 2)
  have h : log 3 < log 4 := log_lt_log (by norm_num : (0 : ℝ) < 3) (by norm_num : (3 : ℝ) < 4)
  have h₄ : log 4 = 2 * log 2 := by
    calc log 4
        _ = log (2 ^ 2) := by norm_num
        _ = 2 * log 2 := by rw [log_pow]; norm_num
  have h32 : log 3 < 2 * log 2 := by rw [← h₄]; exact h
  linarith [(div_lt_iff₀ hlog2).2 h32]

theorem α_irrational : Irrational α := log_three_halves_irrational

/-- The `n`-th convergent denominator of `α`. -/
noncomputable def qConv (n : ℕ) : ℕ := (α.convergent n).den

/-- The `n`-th convergent numerator of `α`. -/
noncomputable def pConv (n : ℕ) : ℤ := (α.convergent n).num

/-- Distance from `N · α` to the nearest integer — the Pythagorean-comma
error of `N`-TET in log₂ coordinates. -/
noncomputable def pythagoreanCommaError (N : ℕ) : ℝ :=
  |(N : ℝ) * α - (round ((N : ℝ) * α) : ℝ)|

/-! ## Phase 1: convergent denominators (sanity check) -/

/-- `⌊α⌋ = 0` since `α ∈ (0, 1)`. -/
theorem floor_α_eq_zero : ⌊α⌋ = 0 := by
  have h₀ : (0 : ℤ) ≤ α := by exact_mod_cast α_pos.le
  have h₁ : α < (0 : ℤ) + 1 := by simpa using α_lt_one
  exact (Int.floor_eq_iff).2 ⟨h₀, h₁⟩

/-- The zeroth convergent denominator is `1` (`0/1`). -/
theorem qConv_zero : qConv 0 = 1 := by
  dsimp only [qConv]
  rw [convergent_zero, floor_α_eq_zero]
  rfl

/-- First convergent denominators of `α = log₂(3/2)` match the Paper 5
narration (`1, 2, 5, 12, 41, 53, …`).  Full `(C2)` remains open. -/
theorem qConv_first_six :
    qConv 0 = 1 ∧ qConv 2 = 2 ∧ qConv 3 = 5 ∧ qConv 4 = 12 ∧
    qConv 5 = 41 ∧ qConv 6 = 53 := by
  constructor
  · exact qConv_zero
  · constructor
    · dsimp [qConv]; exact qConv_two
    · constructor
      · dsimp [qConv]; exact qConv_three
      · constructor
        · dsimp [qConv]; exact qConv_four
        · constructor
          · dsimp [qConv]; exact qConv_five
          · dsimp [qConv]; exact qConv_six

/-! ## Phase 2–3: `(C1)` and `(C2)` for `α = log₂(3/2)`

These specialize the general continued-fraction results in
`FalseWorkPapers.NumberTheory.ContinuedFractionBestApprox` to the irrational `α`. -/

/-- `(C1)` Best-approximation of the second kind for the convergents of `α`:
the convergent `(pConv n, qConv n)` strictly beats every other integer pair
`(a, b)` with `0 < b < qConv (n+1)` on the quantity `|b·α − a|`. -/
theorem convergent_best_approx_second_kind
    (n : ℕ) (a b : ℤ) (hb_pos : 0 < b) (hb_lt : b < (qConv (n + 1) : ℤ))
    (hne : (a, b) ≠ (pConv n, (qConv n : ℤ))) :
    |((qConv n : ℤ) : ℝ) * α - (pConv n : ℝ)| < |(b : ℝ) * α - (a : ℝ)| := by
  have hb_ltR : (b : ℝ) < ((α.convergent (n + 1)).den : ℝ) := by
    have hbq : (b : ℝ) < ((qConv (n + 1) : ℤ) : ℝ) := by exact_mod_cast hb_lt
    simpa [qConv] using hbq
  have h := Real.convergent_best_approx_second_kind' α_irrational hb_pos hb_ltR hne
  simpa only [qConv, pConv, Int.cast_natCast] using h

/-- `(C2)` The Pythagorean-comma-optimal temperaments are exactly the strict
record-holders in the convergent-denominator sequence of `α`: `N ≥ 1` strictly
improves on every smaller `M` iff `N` is a convergent denominator of `α`. -/
theorem best_tet_iff_record_convergent_denominator (N : ℕ) (hN : 1 ≤ N) :
    (∀ M : ℕ, 1 ≤ M → M < N → pythagoreanCommaError N < pythagoreanCommaError M)
      ↔ (∃ n : ℕ, N = qConv n ∧ ∀ m : ℕ, m < n → qConv m < N) :=
  Real.best_approx_iff_convergent_den α_irrational N hN

end FalseWork.Pythagorean
