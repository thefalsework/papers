# `music-kernel-06-baker` — Baker's 1966 theorem applied to the Pythagorean comma

**Status:**
- **Sub-target A (qualitative non-vanishing `|12 log 3 − 19 log 2| ≠ 0`):** BACKGROUND FACT (FTA-elementary; standard textbook result). Lean formalization status: idiomatic statement confirmed via reduction to `music-kernel-01-irrationality` (Lean Zulip, 2026-04-26).
- **Sub-target B (effective Baker quantitative bound):** OPEN — genuine validation target, blocked on Baker's theorem not being in current mathlib4.
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

## Status note (calibration)

This claim has two parts at very different difficulty levels:

- **The qualitative non-vanishing** `|12 log 3 − 19 log 2| ≠ 0` is a **textbook result** by FTA (apply `exp` to a hypothetical equality and read off `3^12 = 2^19`, contradicting unique factorisation). It is equivalent to the irrationality of `log₂ 3`, which is itself a textbook result (see [`music-kernel-01-irrationality`](music-kernel-01-irrationality.md)). It does not require external validation, only citation. Earlier framing of Sub-target A as "REQUIRES FORMAL VALIDATION" was over-cautious; the right framing is "BACKGROUND FACT, with the *Lean formalization* a small confirmable item" — exactly the same two-axis treatment as Point 1.

- **The effective quantitative Baker bound** is genuinely a non-textbook claim from the perspective of mathlib4: Baker's theorem is not in current mathlib, and even the precise constant is non-trivial to extract. Sub-target B is therefore a real open target, not a textbook citation.

Conflating the two would over-credit the validation status of Sub-target B by association with A, and over-flag A as if it were a research-level question. The split below preserves the distinction.

## Argument as stated in Paper 5 § 4

**Step 1 — Non-vanishing (qualitative floor).** `|12 log 3 − 19 log 2| ≠ 0` because otherwise `3^{12} = 2^{19}`, contradicting the fundamental theorem of arithmetic. This is the rank-2 analogue of the rank-1 irrationality of √2 (which uses FTA applied to `p² = 2 q²`).

**Step 2 — Effective quantitative floor (Baker 1966).** Baker's theorem gives an effective lower bound on `|b_1 log a_1 + b_2 log a_2 + ⋯ + b_n log a_n|` for algebraic `a_i` and integers `b_i`, with the bound depending explicitly and computably on the heights and degrees of the `a_i` and the magnitudes of the `b_i`. Applied to `a_1 = 2, a_2 = 3, b_1 = −19, b_2 = 12`, this gives:

`|12 log 3 − 19 log 2| > C(2, 3, 19, 12)`

for some explicit `C > 0`.

The paper claims this is the *effective quantitative Diophantine floor* on the Pythagorean comma, distinct from but continuous with the rank-1 qualitative floor supplied by FTA alone.

## Validation record

- **2026-04-26** — Sub-target A (qualitative non-vanishing of the Pythagorean comma, `12 log 3 − 19 log 2 ≠ 0`) **CONFIRMED via reduction to [`music-kernel-01-irrationality`](music-kernel-01-irrationality.md)**. The reduction:

  `12 · log 3 = 19 · log 2`
  `↔ log 3 / log 2 = 19/12` (dividing by `log 2 ≠ 0`)
  `↔ Real.logb 2 3 = 19/12 ∈ ℚ`
  `↔ Real.logb 2 3` is rational.

  But `Real.logb 2 3` is irrational (this is exactly the statement Confirmed-as-stated in `music-kernel-01-irrationality` via Kevin Buzzard's Zulip response of 2026-04-26 endorsing Form A as idiomatic and the `loogle` searches confirming no shorter mathlib citation). Hence `12 log 3 − 19 log 2 ≠ 0`.

  The same reduction additionally falls out as a corollary of Snir Broshi's WIP scaffold `Real.irrational_logb_rat_rat_iff` for the case `b = 2, x = 3`: the multiplicative-independence condition holds (`2^kb = 3^kx → kb = kx = 0` by FTA), and the iff would yield `Irrational (Real.logb 2 3)` directly. If that scaffold matures into a merged mathlib lemma, Sub-target A becomes a one-line citation; if it does not, the reduction above stands on Buzzard's Confirmed-as-stated alone.

- **Sub-target B** (effective Baker quantitative bound) — remains OPEN. Blocked on Baker's 1966 theorem on linear forms in logarithms not being in current mathlib4 (verified 2026-04). No external validation possible until that upstream development lands. The statement-only target in this file remains a structural specification, not a closeable claim.

## What a validator should confirm

Sub-target A does not require validation of its mathematical content (textbook FTA; see Status note). What can be validated:

1. (Sub-target A, formalization-level only.) That the Lean phrasing `(12 : ℝ) * Real.log 3 − 19 * Real.log 2 ≠ 0` is the idiomatic mathlib statement of the qualitative floor, and that the FTA-via-`Real.exp` proof strategy is the cleanest available against current mathlib primitives. (This is the same kind of question the Zulip thread settled for Point 1.)

The remaining items pertain to **Sub-target B**, where validation is genuinely needed:

2. Baker's 1966 theorem, as cited in standard number-theory references, applies to the linear form `|12 log 3 − 19 log 2|` in the claimed way. In particular, both `log 2` and `log 3` are logarithms of rational numbers (which are algebraic of height and degree 1), so the theorem applies in its standard form.
3. The paper's framing — FTA as shared qualitative floor (rank-1 and rank-2); Baker as quantitative extension for rank ≥ 2 — is a defensible way to describe the relationship, not an overstatement.
4. If a specific effective cents-level numerical bound from Baker is known (see [`pythagorean-explanatory-debts.md`](pythagorean-explanatory-debts.md) point 3), please note it. If no tight explicit bound is easily available, that is also fine — the qualitative "there exists an effective positive bound" claim is sufficient for the paper.

## Why it matters

This claim does double duty:

- In **Paper 5** it is the technical core of the "shared Diophantine floor" thesis unifying √2 irrationality and the Pythagorean comma.
- In **Paper 3** it underwrites the more general claim that the arithmetical ladder `ℕ → ℤ → ℚ → ℝ → ℂ → ℍ → 𝕆` is a sequence of Diophantine-style obstructions, each forcing a structural extension.

If Baker's theorem does *not* apply as claimed, the paper retains the FTA-based qualitative argument but loses the effective-bound framing. The author would revise the paper to reflect that.

## Proposed Lean 4 signatures (statement-only; partial targets only)

**Important caveat about mathlib4 scope.** Baker's 1966 theorem on linear forms in logarithms of algebraic numbers is **not** currently in mathlib4 (verified 2026-04). Mathlib4 contains the Lindemann–Weierstrass theorem (`Mathlib.NumberTheory.Transcendental.Lindemann`) and related transcendence results, but the Baker bound — which requires a substantially heavier machinery around heights, Kummer theory, and the interpolation determinants of Gelfond / Baker / Wüstholz — is long-horizon mathlib territory, not a short PR. This claim therefore has two distinct formalization sub-targets with very different difficulties.

**Sub-target A (Tier 1; elementary; fits on a page).** The qualitative non-vanishing `|12 log 3 − 19 log 2| ≠ 0`, which follows from FTA alone with no transcendence theory. This is a restatement of Form C from [`music-kernel-01-irrationality`](music-kernel-01-irrationality.md#proposed-lean-4-signatures-tightened-against-mathlib4) and is already formalizable today:

```lean
import Mathlib.Analysis.SpecialFunctions.Log.Basic

open Real

/-- (A) Qualitative floor: the Pythagorean comma is nonzero.
Proof by FTA: if `12 log 3 = 19 log 2` then `3^12 = 2^19`, contradiction. -/
theorem pythagorean_comma_nonzero :
    (12 : ℝ) * Real.log 3 - 19 * Real.log 2 ≠ 0 := by
  sorry
```

**Sub-target B (Tier 3; blocked on Baker's theorem not being in mathlib).** The effective quantitative bound. The statement is presented below as a *statement-only target* — it cannot be proven against current mathlib4 because the hypothesis `Baker1966` is an axiom the repo would have to introduce (or the formalization target would have to wait on upstream mathlib development):

```lean
/-- (B) Effective quantitative floor via Baker's 1966 theorem.

This theorem cannot be formalized against current mathlib4 because
Baker's theorem on linear forms in logarithms is not in mathlib.
The target below is a specification of what one would prove once
the theorem is available, and is written as a parametrised statement
taking Baker's bound as a hypothesis rather than deriving it. -/
theorem pythagorean_comma_lower_bound
    (Baker1966 : ∀ (a₁ a₂ : ℕ) (b₁ b₂ : ℤ),
      1 < a₁ → 1 < a₂ → (b₁ ≠ 0 ∨ b₂ ≠ 0) →
      ∃ C : ℝ, 0 < C ∧
        C ≤ |(b₁ : ℝ) * Real.log a₁ + (b₂ : ℝ) * Real.log a₂| ∨
        (b₁ : ℝ) * Real.log a₁ + (b₂ : ℝ) * Real.log a₂ = 0) :
    ∃ C : ℝ, 0 < C ∧ C ≤ |(12 : ℝ) * Real.log 3 - 19 * Real.log 2| := by
  sorry
```

The hypothesis above is a cartoon of Baker's theorem, not its real statement. Any serious formalization target would need the full statement with algebraic numbers of given heights and degrees, explicit bound formulas, and the Kummer-theoretic dependencies. The Baker hypothesis as written is *not* suitable as a real target; it is included here to make explicit that Paper 5 § 4's "effective lower bound" claim is *structurally specifiable* but not *provable today* in mathlib4.

**Statement-level questions for a validator**:

1. Is the decomposition into Sub-target A (elementary; formalizable now) vs. Sub-target B (blocked on Baker) correctly placed for what Paper 5 § 4 actually needs?
2. For the paper's argument, does the *qualitative* non-vanishing (A) suffice, or is the *effective* lower bound (B) doing real work that would be lost if the paper used only (A)?
3. Does a tracking issue for "Baker's theorem in mathlib4" already exist on the leanprover-community side? If so, this claim's Sub-target B should point at it rather than attempting to specify its own statement.
4. Is there a weaker-than-Baker but stronger-than-FTA intermediate result (e.g. a specific Gelfond or Mahler bound for the `log 2, log 3` case) that *is* in mathlib4 and that would give an effective-but-not-optimal bound Paper 5 § 4 could cite instead?

The separation between (A) and (B) in the formalization directly mirrors the paper's separation between the qualitative and quantitative floor claims. Feedback that confirms, amends, or rejects either sub-target is independently useful.

## Changelog
- 2026-04-26: **Calibration pass.** Sub-target A reframed from "CONFIRMED via reduction" to two-axis "BACKGROUND FACT (textbook FTA) + Lean formalization idiomatic." The earlier framing implicitly suggested the qualitative non-vanishing was a claim requiring external validation, which it is not — it is a textbook consequence of FTA, equivalent to the irrationality of `log₂ 3`. Sub-target B framing unchanged: it remains a genuine open target, blocked on upstream mathlib development. New "Status note (calibration)" section added; "What a validator should confirm" section updated to mark item 1 as formalization-level-only and items 2–4 as the actual validation queue.
- 2026-04-26: **Sub-target A flipped from OPEN to CONFIRMED via reduction to `music-kernel-01-irrationality`.** Sub-target B remains OPEN, blocked on upstream mathlib development. Top-level status updated to PARTIAL. Validation record section added documenting the reduction.
- 2026-04-20: Claim created.
- 2026-04-19: Added Lean 4 signature block splitting the claim into two sub-targets. Sub-target A (qualitative, FTA-only) is formalizable against current mathlib4 today. Sub-target B (effective Baker bound) is explicitly marked as blocked on Baker's theorem not being in mathlib4, with a cartoon hypothesis shown to make the structural specification explicit without pretending the proof is achievable without upstream development.
