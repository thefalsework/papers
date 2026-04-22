# `music-kernel-01-irrationality` — Irrationality of log₂(3/2)

**Status:** OPEN
**Part of:** [`music-kernel-umbrella`](music-kernel-umbrella.md)
**Paper:** Paper 3 § 4 (v9.1); Paper 5 § 4 (v1.1)
**Domain:** Number theory (elementary)
**Time estimate:** 5–10 minutes

---

## Claim

Let `α = log₂(3/2) ∈ ℝ / ℤ`. The real number `α` is irrational.

## Argument as stated

If `α ∈ ℚ`, write `α = p/q` for coprime integers `p, q` with `q > 0`. Then `2^p = (3/2)^q`, i.e., `2^{p+q} = 3^q`. By the fundamental theorem of arithmetic, `2^{p+q}` has only 2 as a prime factor and `3^q` has only 3 as a prime factor, which requires `p + q = 0` and `q = 0`. This contradicts `q > 0`. Hence `α ∉ ℚ`.

An equivalent chain: `log₂ 3` is irrational (standard; a corollary of the Gelfond–Schneider theorem, or more elementary still by FTA applied to `3 = 2^{log₂ 3}` supposing rationality). `α = log₂ 3 − 1` inherits irrationality.

## What a validator should confirm

1. The FTA-based argument is correct as stated.
2. The choice of FTA rather than Gelfond–Schneider as primary citation is appropriate for this elementary case (the paper cites both).
3. There is no simpler or more standard argument that should be preferred.

## Proposed Lean signature (tentative)

The claim is elementary enough to state directly against mathlib4:

```lean
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.NumberTheory.Irrational

-- α = log₂(3/2) is irrational
theorem log_three_halves_irrational : Irrational (Real.logb 2 (3/2)) := by
  sorry
```

Equivalent forms that may be easier to prove against current mathlib4:

```lean
-- The Pythagorean-comma non-vanishing as a rank-2 linear-form statement
-- |12 · log 3 − 19 · log 2| ≠ 0, by FTA applied to 2^19 = 3^12.
theorem pythagorean_comma_nonzero :
    (12 : ℝ) * Real.log 3 - 19 * Real.log 2 ≠ 0 := by
  sorry

-- log₂ 3 is irrational (from which α = log₂ 3 − 1 irrational follows trivially).
theorem log_two_three_irrational : Irrational (Real.logb 2 3) := by
  sorry
```

These are offered as starting points, not commitments. A validator or Lean contributor is explicitly invited to say whether the statement should be phrased differently (e.g., against `Nat.log` and `Rat` rather than `Real.logb`, or as a non-vanishing linear form rather than an irrationality claim) before a proof is attempted. Feedback at the statement level is as welcome as a completed proof. See [`lean/README.md`](../../lean/README.md) for the broader Tier-1 formalization context.

## Why it matters

This is the foundational datum. If `α` were rational, every downstream claim (Fix(D) = {∅}, no terminal coalgebra, colimit escape, ℤ/12ℤ quotient being a true quotient, the Pythagorean comma being non-zero) would collapse or simplify. The irrationality of `α` is what forces the music-kernel category-theoretic machinery to be non-trivial.

## Related claims

- [`music-kernel-06-baker`](music-kernel-06-baker.md) — the rank-2 quantitative extension of the same non-vanishing fact, via Baker's theorem.
- [`optimal-ntet-continued-fraction`](optimal-ntet-continued-fraction.md) — the Diophantine-approximation structure of `α` that picks out Pythagorean-comma-optimal temperaments; depends on the irrationality stated here.

## Changelog
- 2026-04-20: Claim created.
- 2026-04-21: Added tentative Lean signature block (Tier 1 formalization target). Equivalent forms included to invite statement-level feedback from Lean collaborators per Chris Henson's suggestion on Lean Zulip (2026-04-19).
