# `music-kernel-06-baker` — Baker's 1966 theorem applied to the Pythagorean comma

**Status:** OPEN
**Part of:** [`music-kernel-umbrella`](music-kernel-umbrella.md)
**Paper:** Paper 5 (Pythagorean) § 4 (v1.1); Paper 3 § 5 (v9.1)
**Domain:** Number theory (transcendence)
**Time estimate:** 30 min – 1 hour

---

## Claim

The Pythagorean comma

`|12 log 3 − 19 log 2| > 0`

has an effective positive lower bound given by Baker's 1966 theorem on linear forms in logarithms of algebraic numbers.

The bound can be expressed in cents (hundredths of an equal-tempered semitone) as an effective quantitative floor: the comma cannot be made smaller than some computable constant by choosing different integer combinations of log 2 and log 3.

## Argument as stated in Paper 5 § 4

**Step 1 — Non-vanishing (qualitative floor).** `|12 log 3 − 19 log 2| ≠ 0` because otherwise `3^{12} = 2^{19}`, contradicting the fundamental theorem of arithmetic. This is the rank-2 analogue of the rank-1 irrationality of √2 (which uses FTA applied to `p² = 2 q²`).

**Step 2 — Effective quantitative floor (Baker 1966).** Baker's theorem gives an effective lower bound on `|b_1 log a_1 + b_2 log a_2 + ⋯ + b_n log a_n|` for algebraic `a_i` and integers `b_i`, with the bound depending explicitly and computably on the heights and degrees of the `a_i` and the magnitudes of the `b_i`. Applied to `a_1 = 2, a_2 = 3, b_1 = −19, b_2 = 12`, this gives:

`|12 log 3 − 19 log 2| > C(2, 3, 19, 12)`

for some explicit `C > 0`.

The paper claims this is the *effective quantitative Diophantine floor* on the Pythagorean comma, distinct from but continuous with the rank-1 qualitative floor supplied by FTA alone.

## What a validator should confirm

1. The FTA argument for `|12 log 3 − 19 log 2| ≠ 0` is correct (trivial).
2. Baker's 1966 theorem, as cited in standard number-theory references, applies to the linear form `|12 log 3 − 19 log 2|` in the claimed way. In particular, both `log 2` and `log 3` are logarithms of rational numbers (which are algebraic of height and degree 1), so the theorem applies in its standard form.
3. The paper's framing — FTA as shared qualitative floor (rank-1 and rank-2); Baker as quantitative extension for rank ≥ 2 — is a defensible way to describe the relationship, not an overstatement.
4. If a specific effective cents-level numerical bound from Baker is known (see [`pythagorean-explanatory-debts.md`](pythagorean-explanatory-debts.md) point 3), please note it. If no tight explicit bound is easily available, that is also fine — the qualitative "there exists an effective positive bound" claim is sufficient for the paper.

## Why it matters

This claim does double duty:

- In **Paper 5** it is the technical core of the "shared Diophantine floor" thesis unifying √2 irrationality and the Pythagorean comma.
- In **Paper 3** it underwrites the more general claim that the arithmetical ladder `ℕ → ℤ → ℚ → ℝ → ℂ → ℍ → 𝕆` is a sequence of Diophantine-style obstructions, each forcing a structural extension.

If Baker's theorem does *not* apply as claimed, the paper retains the FTA-based qualitative argument but loses the effective-bound framing. The author would revise the paper to reflect that.

## Changelog
- 2026-04-20: Claim created.
