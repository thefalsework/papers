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

## Why it matters

This is the foundational datum. If `α` were rational, every downstream claim (Fix(D) = {∅}, no terminal coalgebra, colimit escape, ℤ/12ℤ quotient being a true quotient, the Pythagorean comma being non-zero) would collapse or simplify. The irrationality of `α` is what forces the music-kernel category-theoretic machinery to be non-trivial.

## Changelog
- 2026-04-20: Claim created.
