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

## Proposed Lean 4 signatures (tightened against mathlib4)

The claim is elementary enough to state directly against mathlib4. Three equivalent forms are given; a validator or Lean contributor is explicitly invited to say which is preferred, and to flag any phrasing issue, before a proof is attempted.

**Compilation status.** The block below has been verified to type-check against current mathlib4 via the `live.lean-lang.org` web editor with `import Mathlib` (2026-04-19). Narrowing to specific imports is a downstream refinement and does not affect the statements.

```lean
import Mathlib

open Real

/-- Form A (primary). `α = log₂(3/2)` is irrational.

Proof sketch: if `Real.logb 2 (3/2) = p/q` in lowest terms with `q > 0`,
then `2^p = (3/2)^q`, i.e. `2^(p+q) = 3^q`. The fundamental theorem of
arithmetic forces `p + q = 0` and `q = 0`, contradicting `q > 0`. -/
theorem log_three_halves_irrational :
    Irrational (Real.logb 2 (3/2)) := by
  sorry

/-- Form B. `log₂ 3` is irrational. Equivalent to Form A via
`Real.logb 2 (3/2) = Real.logb 2 3 − 1` and the fact that irrationals
are closed under integer translation (`Irrational.sub_int` /
`Irrational.int_add`). -/
theorem log_two_three_irrational :
    Irrational (Real.logb 2 3) := by
  sorry

/-- Form C. The Pythagorean-comma non-vanishing as a rank-2
linear-form-in-logs statement. Equivalent to Form A via
`Real.logb 2 x = Real.log x / Real.log 2` and scaling.

Proof sketch: if `12 log 3 = 19 log 2` then `3^12 = 2^19` (apply `Real.exp`),
contradicting the fundamental theorem of arithmetic. -/
theorem pythagorean_comma_nonzero :
    (12 : ℝ) * Real.log 3 - 19 * Real.log 2 ≠ 0 := by
  sorry
```

**Statement-level questions for a validator** (independent of proof):

1. Is `Irrational (Real.logb 2 (3/2))` the right primary target, or does mathlib's convention prefer the log-ratio form `Real.log 3 / Real.log 2 ∉ ℚ` — e.g. because `Real.logb` has definitional edge cases at non-positive arguments that the `Real.log` form sidesteps?
2. Does mathlib4 already contain an `Irrational.logb` lemma (or equivalent) under coprime-base-and-argument hypotheses that would make Form A a one-liner? If so, this claim collapses to a citation.
3. For Form C, is the `Real.log`-based statement preferred to an `Real.exp`-composed FTA argument, or is there a cleaner mathlib idiom (e.g. via `Nat.log` and `Nat.Coprime`) for the pure-arithmetic content?
4. Is the statement-level handoff between these three forms worth proving explicitly in the repo (as two small lemmas: Form A ↔ Form B via integer translation; Form A ↔ Form C via `logb`-to-`log` conversion), or should only one of the three be chosen and the other two omitted?

See [`lean/README.md`](../../lean/README.md) for the broader Tier-1 formalization context.

## Why it matters

This is the foundational datum. If `α` were rational, every downstream claim (Fix(D) = {∅}, no terminal coalgebra, colimit escape, ℤ/12ℤ quotient being a true quotient, the Pythagorean comma being non-zero) would collapse or simplify. The irrationality of `α` is what forces the music-kernel category-theoretic machinery to be non-trivial.

## Related claims

- [`music-kernel-06-baker`](music-kernel-06-baker.md) — the rank-2 quantitative extension of the same non-vanishing fact, via Baker's theorem.
- [`optimal-ntet-continued-fraction`](optimal-ntet-continued-fraction.md) — the Diophantine-approximation structure of `α` that picks out Pythagorean-comma-optimal temperaments; depends on the irrationality stated here.

## Changelog
- 2026-04-20: Claim created.
- 2026-04-21: Added tentative Lean signature block (Tier 1 formalization target). Equivalent forms included to invite statement-level feedback from Lean collaborators per Chris Henson's suggestion on Lean Zulip (2026-04-19).
- 2026-04-19: Tightened the Lean 4 signature block against current mathlib4. Fixed the import path (`Mathlib.NumberTheory.Real.Irrational`, not the older `Mathlib.NumberTheory.Irrational`). Added explicit proof sketches for each form and four specific statement-level questions for a validator.
- 2026-04-19: Verified the Lean signature block type-checks against current mathlib4 via `live.lean-lang.org` (using `import Mathlib`). All three forms (`Irrational (Real.logb 2 (3/2))`, `Irrational (Real.logb 2 3)`, and the rank-2 linear-form-in-logs statement) elaborate with only the expected `sorry` warnings. Block updated to use `import Mathlib` consistently with the verified configuration.
