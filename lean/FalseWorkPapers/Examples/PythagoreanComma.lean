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

Complements `WhyTwelve.lean` (lattice-side forcing of 12) with the
Diophantine-approximation side.
-/
import Mathlib.NumberTheory.Real.Irrational
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.NumberTheory.DiophantineApproximation.Basic

namespace FalseWork.Pythagorean

open Real

/-- The fundamental irrational of the Pythagorean comma: `log₂(3/2)`. -/
noncomputable def α : ℝ := log 3 / log 2 - 1

/-- The `n`-th convergent denominator of `α`. -/
noncomputable def qConv (n : ℕ) : ℕ := (α.convergent n).den

/-- The `n`-th convergent numerator of `α`. -/
noncomputable def pConv (n : ℕ) : ℤ := (α.convergent n).num

/-- Distance from `N · α` to the nearest integer — the Pythagorean-comma
error of `N`-TET in log₂ coordinates. -/
noncomputable def pythagoreanCommaError (N : ℕ) : ℝ :=
  |(N : ℝ) * α - (round ((N : ℝ) * α) : ℝ)|

/-! ## Phase 1: convergent denominators (sanity check) -/

/-- First convergent denominators of `α = log₂(3/2)` match the Paper 5
narration (`1, 2, 5, 12, 41, 53, …`).  Full `(C2)` remains open. -/
theorem qConv_first_six :
    qConv 0 = 1 ∧ qConv 2 = 2 ∧ qConv 3 = 5 ∧ qConv 4 = 12 ∧
    qConv 5 = 41 ∧ qConv 6 = 53 := by
  sorry

end FalseWork.Pythagorean
