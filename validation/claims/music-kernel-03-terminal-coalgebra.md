# `music-kernel-03-terminal-coalgebra` — No terminal coalgebra for `D`

**Status:** OPEN
**Part of:** [`music-kernel-umbrella`](music-kernel-umbrella.md)
**Paper:** Paper 3 § 4 (v9.1); targeted for v10.0 revision as Theorem 4.X
**Domain:** Category theory
**Time estimate:** 10–15 minutes

---

## Setup

As in [`music-kernel-02`](music-kernel-02-fixed-points.md): **C** is the poset category of finite subsets of `ℝ / ℤ` with inclusions as morphisms; `D : C → C` is defined by `D(X) = X ∪ (X + α)` for `α = log₂(3/2)` irrational; `Coalg(D)` is the category of `D`-coalgebras in **C** with the usual morphisms.

## Claim

`D` admits no terminal coalgebra in `Coalg(D)`.

## Argument as stated

By **Lambek's lemma**: the structure map of a terminal coalgebra `(A, a : A → D(A))` is an isomorphism. Hence a terminal coalgebra would require `A ≅ D(A)` in `C`, i.e., `A ∈ Fix(D) = {∅}` by [`music-kernel-02`](music-kernel-02-fixed-points.md).

But the empty coalgebra `(∅, ! : ∅ → D(∅) = ∅)` is *initial* in `Coalg(D)` (the unique map from `∅` to any coalgebra's carrier is a coalgebra morphism). It is not terminal: any non-empty coalgebra has no coalgebra morphism into `(∅, !)` because there is no map from a non-empty set to `∅`.

Therefore `Coalg(D)` has no terminal object.

## What a validator should confirm

1. The Lambek's lemma application is correct in this setting. (The standard statement: if `F : C → C` is an endofunctor on a category and `(A, a : A → F(A))` is terminal in `Coalg(F)`, then `a` is an iso. This is usually stated for endofunctors on `Set` or enriched settings; please flag any issue with applying it to a poset category.)
2. The observation that `∅` is initial rather than terminal in `Coalg(D)` is correct.
3. The conclusion that `Coalg(D)` has no terminal object follows cleanly.

## Implication for the paper

This is the substantive replacement for the earlier D4 condition. The paper's original D4 assumed `Coalg_nf(D)` (a non-fixed-point coalgebra subcategory) was the "comma" in Lawvere's sense. The external reviewer's move of proposing D4 as a theorem-by-definition was circular. The honest theorem is: *`Coalg(D)` has no terminal object*, which captures the paper's intuition that the comma is irresolvable.

The v10.0 revision will replace the original D4 with this theorem, cite Lambek, and note that the Coalg_nf(D) construction is retained only as analogy, not as the formal kernel.

## Changelog
- 2026-04-20: Claim created.
