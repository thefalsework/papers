# Open validation items

This file is the canonical index of every currently-open validation item across the paper series. Each entry points to an authoritative claim statement in [`claims/`](claims/) and to a matching [GitHub Issue](https://github.com/thefalsework/papers/issues) for discussion.

When a claim is validated, corrected, or disputed, its entry moves to [`RESOLVED.md`](RESOLVED.md) with the validator's name and a pointer to the revision that absorbed the outcome.

---

## Domain: Category theory

### `music-kernel-umbrella` — Six-point formalization of the music-kernel endofunctor
- **Authoritative statement:** [`claims/music-kernel-umbrella.md`](claims/music-kernel-umbrella.md)
- **GitHub issue:** [#1](https://github.com/thefalsework/papers/issues/1)
- **Paper:** Paper 3 § 4 (v9.1); targeted for v10.0 revision
- **What's asked:** verification that a set of six elementary mathematical claims (irrationality of log₂(3/2); Fix(D) = {∅}; no terminal coalgebra via Lambek; colimit escapes via Weyl; ℤ/12ℤ quotient with D_12^12 = id failure note; Baker's 1966 application to the Pythagorean comma) are correctly stated and supported.
- **Time estimate for validator:** ~1 hour
- **Status:** awaiting category theorist + number theorist
- **Sub-items:** [`music-kernel-01`](claims/music-kernel-01-irrationality.md), [`02`](claims/music-kernel-02-fixed-points.md), [`03`](claims/music-kernel-03-terminal-coalgebra.md), [`04`](claims/music-kernel-04-colimit-escape.md), [`05`](claims/music-kernel-05-z12z-cycle.md), [`06`](claims/music-kernel-06-baker.md) — see also issue [#2](https://github.com/thefalsework/papers/issues/2) for number-theory focus on point 6

---

## Domain: Set theory / formal logic

### `cantor-cumulative-caveat` — Cantor application across four papers
- **Authoritative statement:** [`claims/cantor-cumulative-caveat.md`](claims/cantor-cumulative-caveat.md)
- **GitHub issue:** [#3](https://github.com/thefalsework/papers/issues/3)
- **Paper:** canonical at Paper 4 § 2.5 (v5.1); invoked at Paper 1 § 2, Paper 2 § 2.3, Paper 3 § 9
- **What's asked:** advise whether each of four applications of Cantor's power-set theorem is direct, formalizable under additional structure, an analogy, or a category error.
- **Time estimate for validator:** ~3–5 hours
- **Status:** awaiting set theorist or formal logician

---

## Domain: Number theory

### `music-kernel-06-baker` — Baker's 1966 theorem applied to the Pythagorean comma
- **Authoritative statement:** [`claims/music-kernel-06-baker.md`](claims/music-kernel-06-baker.md)
- **GitHub issue:** [#2](https://github.com/thefalsework/papers/issues/2)
- **Paper:** Paper 5 (Pythagorean) § 4 (v1.1); Paper 3 § 5 (v9.1)
- **What's asked:** verify that Baker's 1966 theorem on linear forms in logarithms of algebraic numbers applies to |12 log 3 − 19 log 2| and that the resulting effective lower bound is qualitatively the right tool, not misapplied.
- **Time estimate for validator:** ~30 min – 1 hour
- **Status:** awaiting number theorist

### `pythagorean-explanatory-debts` — Three debts from Pythagorean companion § 7.5
- **Authoritative statement:** [`claims/pythagorean-explanatory-debts.md`](claims/pythagorean-explanatory-debts.md)
- **GitHub issue:** [#5](https://github.com/thefalsework/papers/issues/5)
- **Paper:** Paper 5 § 7.5 (v1.1)
- **What's asked:** three open questions named by the paper itself — (1) uniform framework unifying rank-1 and rank-≥2 Diophantine cases; (2) typology-mapping nuance for foundations-of-mathematics schools; (3) specific cents-level numerical bound from Baker's theorem.
- **Time estimate for validator:** variable; each debt is independently tractable.
- **Status:** awaiting number theorist

---

## Domain: Research direction (not bounded one-hour validation)

### `ladder-wide-d4` — Arithmetical-ladder D4 question
- **Authoritative statement:** [`claims/ladder-wide-d4.md`](claims/ladder-wide-d4.md)
- **GitHub issue:** [#4](https://github.com/thefalsework/papers/issues/4)
- **Paper:** Paper 3 § 5.2 (v9.1)
- **What's asked:** does the D4 subcategory-vs-full-Lawvere-comma question admit a clean categorical answer for each rung `ℕ → ℤ, ℤ → ℚ, ℚ → ℝ, ℝ → ℂ, ℂ → ℍ, ℍ → 𝕆`?
- **Status:** open research direction; no time estimate; contributions via any of validation, correction, PR, or discussion welcome.

### `g-r-c-practice-domains` — Extension of G∧R∧C beyond formal systems
- **Authoritative statement:** [`claims/g-r-c-practice-domains.md`](claims/g-r-c-practice-domains.md)
- **GitHub issue:** [#7](https://github.com/thefalsework/papers/issues/7)
- **Paper:** Paper 1 § 3 and § 5 (v11.3); downgraded to structural analogy at Paper 3 § 7 (v9.1)
- **What's asked:** precise definition of "generative sufficiency" for non-recursively-enumerable systems (architecture, cinema, painting); whether the G∧R∧C mapping to D1–D3 can be upgraded from structural analogy to derivation in any formal setting.
- **Status:** open research direction

---

## Domain: Physics / foundations of physics

### `paper4-higgs-vev-debt` — Higgs VEV magnitude explanatory debt
- **Authoritative statement:** [`claims/paper4-higgs-vev-debt.md`](claims/paper4-higgs-vev-debt.md)
- **GitHub issue:** [#6](https://github.com/thefalsework/papers/issues/6)
- **Paper:** Paper 4 § 6.3 (v5.1)
- **What's asked:** the process-primacy framing explains the *existence* of the Higgs VEV as a symmetry-breaking residue but does not re-derive its specific magnitude (≈ 246 GeV). This debt is acknowledged in the paper; a resolution would re-derive the magnitude from the proposed framework.
- **Status:** open; awaiting a quantum-foundations or particle-theory engagement

---

## How this file is maintained

Entries are added when a new `[REQUIRES FORMAL VALIDATION]` flag appears in a paper or when a contributor opens an Open-Research-Direction issue. Entries are moved to [`RESOLVED.md`](RESOLVED.md) when a validation PR merges, a correction PR lands, or a dispute settles.

The canonical version of each claim is the `.md` file in [`claims/`](claims/), not the GitHub Issue. Issues are for discussion; claim files are for the record.

See [`../CONTRIBUTING.md`](../CONTRIBUTING.md) for acceptance criteria.
