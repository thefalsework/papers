# `music-kernel-01-irrationality` — Irrationality of log₂(3/2)

**Status:** BACKGROUND FACT (FTA-elementary; standard textbook result)
**Lean formalization status:** CONFIRMED IDIOMATIC via Lean Zulip 2026-04-26 (Kevin Buzzard, "looks idiomatic" + two `loogle` searches confirming absence from current mathlib)
**Part of:** [`music-kernel-umbrella`](music-kernel-umbrella.md)
**Paper:** Paper 3 § 4 (v9.1); Paper 5 § 4 (v1.1)
**Domain:** Number theory (elementary)
**Time estimate:** 5–10 minutes

---

## Claim

Let `α = log₂(3/2) ∈ ℝ / ℤ`. The real number `α` is irrational.

## Status note (calibration)

This is a **standard textbook result**, not an open question. The irrationality of `log₂(3/2)` (equivalently, of `log₂ 3`) follows from the Fundamental Theorem of Arithmetic by an argument in any introductory number-theory text (Niven, *Irrational Numbers*, Ch. 2; Hardy & Wright, *An Introduction to the Theory of Numbers*, § 4 on irrationality of logarithms; Apostol, *Introduction to Analytic Number Theory*, Ch. 1). It has been known since the 19th century at the latest and is implicit in classical work on transcendence (Lambert, Hermite, Lindemann).

Earlier versions of this file carried a status of "OPEN — REQUIRES FORMAL VALIDATION." That framing was over-cautious: the underlying mathematical fact does not require validation, only citation. What did require (a small amount of) attention was the *Lean formal expression* of the fact — confirming that `Irrational (Real.logb 2 (3/2))` is the idiomatic mathlib statement, and that no existing mathlib lemma already provides it. Those formalization-level questions were resolved via Lean Zulip on 2026-04-26 (see Validation record below).

The right citation pattern in any paper using this fact is:
- For the mathematical claim: cite a textbook (Niven; Hardy & Wright; or any equivalent).
- For the Lean formalization: cite the Zulip thread (and, if Snir Broshi's WIP scaffold matures into a merged mathlib lemma, cite the merged lemma instead).

Conflating the two — citing the Zulip thread as if it were validation of the math — would misrepresent what occurred.

## Argument as stated

If `α ∈ ℚ`, write `α = p/q` for coprime integers `p, q` with `q > 0`. Then `2^p = (3/2)^q`, i.e., `2^{p+q} = 3^q`. By the fundamental theorem of arithmetic, `2^{p+q}` has only 2 as a prime factor and `3^q` has only 3 as a prime factor, which requires `p + q = 0` and `q = 0`. This contradicts `q > 0`. Hence `α ∉ ℚ`.

An equivalent chain: `log₂ 3` is irrational (standard; a corollary of the Gelfond–Schneider theorem, or more elementary still by FTA applied to `3 = 2^{log₂ 3}` supposing rationality). `α = log₂ 3 − 1` inherits irrationality.

## What a validator should confirm

The mathematical claim does not require validation (see Status note above; this is a standard textbook result). The remaining items below pertain only to the **Lean formalization** of the fact, not to the fact itself:

1. Is `Irrational (Real.logb 2 (3/2))` the idiomatic mathlib statement of the fact, or would another form be preferred?
2. Does mathlib already contain an equivalent lemma that would collapse the formalization to a citation?
3. Is the proof strategy (FTA-based) the cleanest available against current mathlib primitives?

All three were addressed in the Zulip thread of 2026-04-26 (see Validation record). They are listed here so future readers understand what the validation effort covered and what it did not (it did not cover whether `log₂(3/2)` is irrational; that was never in question).

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

## Validation record

- **2026-04-26** — Posted to Lean Zulip, stream `#Is there code for X?`, topic `Irrational (Real.logb 2 (3/2))`: <https://leanprover.zulipchat.com/#narrow/channel/217875-Is-there-code-for-X.3F/topic/Irrational.20.28Real.2Elogb.202.20.283.2F2.29.29/with/591010576>. Asked (1) whether mathlib has an existing `Irrational.logb` / `Nat.log_irrational` lemma covering this case, and (2) which of Form A / log-ratio form / rank-2 linear-form-in-logs form is the idiomatic statement.

- **2026-04-26** — Response from Kevin Buzzard (Imperial College London; Xena Project; senior mathlib maintainer):
  - **Statement form:** "This looks idiomatic to me." → Form A (`Irrational (Real.logb 2 (3/2))`) confirmed as the right primary target. Question 2 of the umbrella's statement-level questions resolved.
  - **Existing-lemma check:** Two `loogle` searches (`Irrational, Real.logb` and `Irrational, Nat, Real.log`) both returned no results. Buzzard: "I can't find your lemmas in mathlib." → Question 2 of the umbrella's statement-level questions resolved: no citation collapse; the lemma is genuinely absent from current mathlib.
  - **Forward action:** Buzzard invited proposed statements as candidates for upstream contribution: "These might be welcome additions to mathlib."
  - **Status determination:** This response satisfies the umbrella's "Confirmed as stated" criterion for Point 1. The statement is precise, the form is mathlib-idiomatic per a senior maintainer, and the underlying math (FTA-based irrationality of log₂(3/2)) is implicitly endorsed by Buzzard treating the claim as a well-known target worth upstreaming.

- **2026-04-26** — In the same Zulip thread, Snir Broshi shared a working WIP scaffold for a substantially stronger result: `Real.irrational_logb_rat_rat_iff`, an iff characterization of `Irrational (Real.logb b x)` for any `b, x : ℚ` via multiplicative independence of integer powers, plus three sketched `Decidable` instances (for `ℕ`, `ℤ`, `ℚ`), a separate transcendence-theoretic theorem (`Real.irrational_logb_transcendental_algebraic` for transcendental base / algebraic argument), a list of six candidate predicate forms tied to existing mathlib `pow_eq_pow_*` API in PR #28557, and a flagged technical obstacle (`Finsupp.zipWith` is `noncomputable`, complicating the factorization-based `Decidable` route). The scaffold does not compile end-to-end but is a substantive starting point: once the `ℚ` `Decidable` instance lands, the music-kernel-01 application reduces to `by decide`. Status of this scaffold: WIP, public on Zulip, not yet a mathlib PR. The Confirmed-as-stated determination above is independent of whether this scaffold matures — it stands on Buzzard's response alone.

- **Anticipated upgrade path.** If Snir Broshi's WIP scaffold matures into a merged mathlib PR — yielding a stable lemma name (provisionally `Real.irrational_logb_rat_rat_iff`) and a working `Decidable` instance for `b, x : ℚ` — this record will be updated to cite the merged lemma directly with PR number and commit hash, and the music-kernel-01 application will be expressible as a one-line Lean proof (likely `by decide` or `Real.irrational_logb_rat_rat_iff.mpr ⟨…⟩`). At that point, status terminology will be tightened from "Confirmed as stated" to "Confirmed and formalized," and Paper 3 § 4 / Paper 5 § 4 footnotes will cite the mathlib lemma rather than this Zulip thread. **The Confirmed-as-stated determination above does not depend on this anticipated upgrade.** If the scaffold does not merge — whether due to scope creep, refactoring, or Snir not continuing — Point 1's validation status remains intact on Buzzard's response, and the Zulip thread remains the citable artifact. The upgrade path is opportunistic, not load-bearing.

## Why it matters

This is the foundational datum. If `α` were rational, every downstream claim (Fix(D) = {∅}, no terminal coalgebra, colimit escape, ℤ/12ℤ quotient being a true quotient, the Pythagorean comma being non-zero) would collapse or simplify. The irrationality of `α` is what forces the music-kernel category-theoretic machinery to be non-trivial.

## Related claims

- [`music-kernel-06-baker`](music-kernel-06-baker.md) — the rank-2 quantitative extension of the same non-vanishing fact, via Baker's theorem.
- [`optimal-ntet-continued-fraction`](optimal-ntet-continued-fraction.md) — the Diophantine-approximation structure of `α` that picks out Pythagorean-comma-optimal temperaments; depends on the irrationality stated here.

## Changelog
- 2026-04-26: **Calibration pass.** Status reframed from "CONFIRMED AS STATED via Lean Zulip" to two-axis "BACKGROUND FACT (textbook)" + "Lean formalization status: CONFIRMED IDIOMATIC via Zulip." The earlier framing implicitly suggested the mathematical fact required external validation, which was over-cautious — the irrationality of `log₂(3/2)` is a standard FTA-elementary textbook result (Niven; Hardy & Wright). What the Zulip exchange validated was the *Lean formulation*, not the underlying mathematics. New "Status note (calibration)" section makes this distinction explicit. "What a validator should confirm" section updated to describe only the formalization-level questions, since the mathematical question is not open.
- 2026-04-26: Added explicit "Anticipated upgrade path" note to the Validation record describing what changes if Snir's scaffold merges into mathlib (status terminology tightens, paper footnotes cite the merged lemma directly) versus what stays the same if it does not (Confirmed-as-stated determination is intact on Buzzard's response alone). Makes the dependency structure between this record and any future merge explicit.
- 2026-04-26: Snir Broshi's WIP iff scaffold and three `Decidable` instances added to the validation record. Confirmed-as-stated determination unchanged (it rests on Buzzard's response, not on Snir's scaffold compiling).
- 2026-04-26: **Status flipped from OPEN to CONFIRMED AS STATED.** Kevin Buzzard's Zulip response endorsed Form A as idiomatic and confirmed via `loogle` that no existing mathlib lemma covers the case. See Validation record above.
- 2026-04-26: Posted statement-level question to Lean Zulip (`#Is there code for X?`). See Validation record above for thread URL.
- 2026-04-20: Claim created.
- 2026-04-21: Added tentative Lean signature block (Tier 1 formalization target). Equivalent forms included to invite statement-level feedback from Lean collaborators per Chris Henson's suggestion on Lean Zulip (2026-04-19).
- 2026-04-19: Tightened the Lean 4 signature block against current mathlib4. Fixed the import path (`Mathlib.NumberTheory.Real.Irrational`, not the older `Mathlib.NumberTheory.Irrational`). Added explicit proof sketches for each form and four specific statement-level questions for a validator.
- 2026-04-19: Verified the Lean signature block type-checks against current mathlib4 via `live.lean-lang.org` (using `import Mathlib`). All three forms (`Irrational (Real.logb 2 (3/2))`, `Irrational (Real.logb 2 3)`, and the rank-2 linear-form-in-logs statement) elaborate with only the expected `sorry` warnings. Block updated to use `import Mathlib` consistently with the verified configuration.
