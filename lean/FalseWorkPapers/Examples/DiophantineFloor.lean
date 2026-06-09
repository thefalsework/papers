/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# The shared Diophantine floor (Paper 5)

Paper 5 (`papers/pythagorean-shared-floor/pythagorean.md`) argues that the
irrationality of `√2` (rank 1) and the non-closure of the Pythagorean
comma (rank 2) "are the same discovery at different ranks," both
consequences of the fundamental theorem of arithmetic (unique prime
factorization).  This file kernel-checks the two floors and their common
shape: a *monomial equation in distinct primes has no nontrivial
solution*.

* **Rank 1** (`rank_one_floor`).  `√2` is irrational — there is no
  rational `a/b` with `a² = 2 b²`.  This is the obstruction underlying
  the equal-tempered semitone `2^(1/12)`.

* **Rank 2** (`rank_two_floor`).  `3^a = 2^b` only when `a = b = 0` —
  powers of 3 (stacked fifths) never coincide with powers of 2 (stacked
  octaves).  This is the qualitative non-closure of the circle of fifths:
  the Pythagorean comma `3^12 / 2^19 ≠ 1` (`pythagorean_comma_nontrivial`)
  is the smallest near-miss.

Both are instances of the multiplicative independence of distinct primes
in `ℚˣ` — the "shared floor" of Paper 5 — and neither depends on the
surrounding FalseWork program.  The *quantitative* refinement (an
effective lower bound on `|12 log 3 − 19 log 2|` via Baker's theorem) is
**not** formalized here: Baker's theorem is not in Mathlib4
(`validation/claims/music-kernel-06-baker.md`).  Only the qualitative
floor — the part that follows from FTA — is kernel-checked.
-/
import Mathlib.NumberTheory.Real.Irrational
import Mathlib.Data.Nat.Prime.Basic

namespace FalseWork.Diophantine

/-! ## Rank 1: the irrationality of `√2` -/

/-- **Rank-1 floor.** `√2` is irrational: no `a/b ∈ ℚ` has `a² = 2 b²`.
The obstruction underlying the equal-tempered semitone. -/
theorem rank_one_floor : Irrational (Real.sqrt 2) := irrational_sqrt_two

/-! ## Rank 2: the multiplicative independence of 2 and 3 -/

/-- **Rank-2 floor.** Powers of 3 and powers of 2 coincide only trivially:
`3 ^ a = 2 ^ b → a = 0 ∧ b = 0`.  Musically: stacking perfect fifths
(`3 : 2` frequency ratio) never closes into a whole number of octaves
(`2 : 1`).  This is the qualitative non-closure of the circle of fifths,
a direct consequence of unique prime factorization. -/
theorem rank_two_floor (a b : ℕ) (h : 3 ^ a = 2 ^ b) : a = 0 ∧ b = 0 := by
  rcases Nat.eq_zero_or_pos a with ha | ha
  · subst ha
    rw [pow_zero] at h
    rcases (Nat.pow_eq_one).mp h.symm with h2 | hb
    · omega
    · exact ⟨rfl, hb⟩
  · exfalso
    have h3 : (3 : ℕ) ∣ 2 ^ b := by rw [← h]; exact dvd_pow_self 3 ha.ne'
    have : (3 : ℕ) ∣ 2 := Nat.prime_three.dvd_of_dvd_pow h3
    norm_num at this

/-- The Pythagorean comma is a genuine near-miss, not a closure:
`3^12 ≠ 2^19` (twelve fifths overshoot seven octaves by the comma
`531441 / 524288 ≈ 23.46` cents). -/
theorem pythagorean_comma_nontrivial : (3 : ℕ) ^ 12 ≠ 2 ^ 19 := by norm_num

/-- **The shared floor (bundled).**  Rank 1 (`√2` irrational) and rank 2
(`2`–`3` multiplicative independence, witnessed by the Pythagorean comma)
are the two faces of the Diophantine floor of Paper 5 — both consequences
of unique prime factorization. -/
theorem shared_diophantine_floor :
    Irrational (Real.sqrt 2) ∧
    (∀ a b : ℕ, 3 ^ a = 2 ^ b → a = 0 ∧ b = 0) ∧
    (3 : ℕ) ^ 12 ≠ 2 ^ 19 :=
  ⟨rank_one_floor, rank_two_floor, pythagorean_comma_nontrivial⟩

end FalseWork.Diophantine
