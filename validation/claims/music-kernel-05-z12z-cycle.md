# `music-kernel-05-z12z-cycle` — `ℤ / 12ℤ` quotient: structure and a suspected error

**Status:** OPEN
**Part of:** [`music-kernel-umbrella`](music-kernel-umbrella.md)
**Paper:** Paper 3 § 4 (v9.1); targeted for v10.0 revision
**Domain:** Category theory, finite group theory (elementary)
**Time estimate:** 10–15 minutes

---

## Setup

Define `q : ℝ / ℤ → ℤ / 12ℤ` by `q(x) = round(12 x) mod 12`. This induces a functor `Q : C → C_{12}`, where `C_{12}` is the poset of subsets of `ℤ / 12ℤ`. Define `D_{12} : C_{12} → C_{12}` by `D_{12}(Y) = Y ∪ (Y + 7)`, the finite-group analogue of `D` (with `7` as the integer nearest to `12 α = 12 log₂(3/2) ≈ 7.02`).

## Suspected error in the external reviewer's draft

The external reviewer asserted: "`D_{12}^{12} = id_{C_{12}}` and `Fix(D_{12}) = {∅, ℤ / 12ℤ}`."

For the stated definition `D_{12}(Y) = Y ∪ (Y + 7)`, iteration monotonically grows `Y`: `Y ⊆ D_{12}(Y) ⊆ D_{12}²(Y) ⊆ ⋯`. Since `7` generates `ℤ / 12ℤ` (because `gcd(7, 12) = 1`), for any non-empty `Y` the iteration saturates to `ℤ / 12ℤ` in at most 12 steps and remains there. Hence:

- `D_{12}^{n}(Y) = ℤ / 12ℤ` for all `n ≥ 12` and any non-empty `Y`.
- `D_{12}^{12} = id_{C_{12}}` is **false**: e.g., `D_{12}^{12}(\{0\}) = ℤ / 12ℤ ≠ \{0\}`.
- `Fix(D_{12}) = {∅, ℤ / 12ℤ}`: this part appears correct (the only sets invariant under translation by 7 are `∅` and the whole group).

## Proposed corrected claim (what the paper should assert)

There are two natural operations on `ℤ / 12ℤ` corresponding to the fifth:

### (A) Additive accumulation `D_{12}(Y) = Y ∪ (Y + 7)`
- Monotone, eventually saturating to `ℤ / 12ℤ` for any non-empty `Y`.
- `Fix(D_{12}) = {∅, ℤ / 12ℤ}`.
- Colimit `⋃_n D_{12}^n(Y) = ℤ / 12ℤ` for non-empty `Y`, which *does* lie in `C_{12}` — the comma is absorbed. This is the formal correlate of "equal temperament closes the circle."

### (B) Translation `T_{12}(Y) = Y + 7` (without union)
- `T_{12}^{12} = id_{C_{12}}` because `12 · 7 ≡ 0 (mod 12)`.
- `⟨7⟩ = ℤ / 12ℤ` since `gcd(7, 12) = 1`: the circle of fifths visits every pitch class in 12 steps.
- `Fix(T_{12}) = {∅, ℤ / 12ℤ}` for the same reason.
- This is the operation implicitly meant by "the circle of fifths closes in 12 steps."

The paper should use `(A)` for the endofunctor formalization (its structure matches `D : C → C`) and `(B)` for the claim about the 12-step circle. The external reviewer conflated them.

## Giant Steps observation (correct as stated)

Inside `ℤ / 12ℤ`, the subgroup `H = ⟨4⟩ = {0, 4, 8}` is cyclic of order 3. Its preimage `q^{-1}(H) ⊂ ℝ / ℤ` is *not* closed under `D` in **C**: `(0, 0, 0) + 4 α = 4 log₂(3/2) ≈ 2.34` is not equal modulo 1 to any element of `{0, 4/12, 8/12} = {0, 1/3, 2/3}`. So the major-third cycle is a closed 3-loop that exists only downstream of `q` — it is, in the paper's language, a structure "made available by the comma's absorption into temperament."

## What a validator should confirm

1. The suspected error in the external reviewer's `D_{12}^{12} = id_{C_{12}}` claim is indeed an error (and not a subtlety I have missed).
2. The proposed split into `D_{12}` (accumulation) and `T_{12}` (translation) is the right way to state the corrected content.
3. The Giant-Steps observation about `H = ⟨4⟩` and its preimage not being `D`-closed is correct.

## Implication for the paper

The v10.0 revision will adopt the split: `D_{12}` for the endofunctor analogue (which saturates), `T_{12}` for the 12-step closure (which genuinely returns to identity). The Giant-Steps paragraph can stand as a clean formal statement.

## Changelog
- 2026-04-20: Claim created with flagged correction to external reviewer's draft.
