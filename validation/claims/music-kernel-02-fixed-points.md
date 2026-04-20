# `music-kernel-02-fixed-points` — `Fix(D) = {∅}` by cardinality

**Status:** OPEN
**Part of:** [`music-kernel-umbrella`](music-kernel-umbrella.md)
**Paper:** Paper 3 § 4 (v9.1); targeted for v10.0 revision
**Domain:** Category theory (elementary)
**Time estimate:** 5–10 minutes

---

## Setup

Let **C** be the poset category whose objects are finite subsets `X ⊂ ℝ / ℤ` and whose morphisms are inclusions. Let `α = log₂(3/2)` (irrational, see [`music-kernel-01`](music-kernel-01-irrationality.md)). Define the endofunctor `D : C → C` on objects by `D(X) = X ∪ (X + α)` and on morphisms by taking inclusions to inclusions.

**Functoriality** (check): `X ⊆ Y ⇒ D(X) = X ∪ (X + α) ⊆ Y ∪ (Y + α) = D(Y)`. `D` preserves identities. Composition is trivial in a poset. So `D` is a functor.

## Claim

The fixed-point subcategory `Fix(D)` — i.e., the objects `X` with `D(X) = X` — consists only of the empty set:

`Fix(D) = {∅}`.

## Argument as stated

For non-empty finite `X ⊂ ℝ / ℤ`:

- `D(X) = X` iff `X + α ⊆ X`.
- For finite `X`, `X + α ⊆ X` forces `X + α = X` (cardinality; the map `x ↦ x + α` is injective, so `X + α` has the same size as `X`, so the inclusion is an equality).
- `X + α = X` means `α` acts as a period of `X`, i.e., `X` is invariant under translation by `α`.
- A non-empty finite set invariant under translation by a non-zero element would have to contain the whole orbit `{x + n α : n ∈ ℤ}` of any point, which is infinite because `α` is irrational. Contradiction.
- Hence `D(X) ≠ X` for any non-empty finite `X`.
- `D(∅) = ∅ ∪ (∅ + α) = ∅`, so `∅ ∈ Fix(D)`.

Therefore `Fix(D) = {∅}`.

## Implication for the paper

Paper 3 § 4 (v9.1) carries language from earlier versions suggesting that `Fix(D)` is "the kernel — the minimal self-limiting operation of the domain." In the music-kernel setting this reading is false: `Fix(D)` is trivial (the empty set only). The v10.0 revision will reframe so that `Fix(D) = {∅}` is a *positive* result — the sign that the endofunctor is genuinely generative and has no non-trivial finite closure inside `C` — rather than an identification of the kernel with its fixed-point subcategory.

## What a validator should confirm

1. The functoriality check is correct.
2. The `Fix(D) = {∅}` argument is correct as stated.
3. The proposed reframing ("`Fix(D)` triviality is the generativity signal, not an identification of the kernel") is sound. If a better categorical vocabulary exists — e.g., "terminal coalgebra is also trivial," "initial algebra is `∅`," "the functor is continuous but has no non-trivial invariant subobject" — please propose it.

## Changelog
- 2026-04-20: Claim created.
