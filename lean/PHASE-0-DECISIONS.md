# Phase 0 decisions — pre-Heyting-instance state

**Date**: 2026-05-19
**Commit**: 806b7f6 (first successful build of `FalseWork.Positions`)
**Audience**: future Lean-formalization sessions (especially Phase 1, which closes the Heyting gap)

This document records the three semantic choices made during Phase −1 (build stand-up) that the Heyting instance work sits on top of. The choices are recorded here so future sessions can avoid second-guessing them and so the rationale is preserved if the choices ever need to be revisited.

---

## 1. The `coherent` axiom in `DistinctionStructure`

**File**: `lean/FalseWorkPapers/Positions/Setup.lean`, line 73.

**Prior (sketch, did not type-check):**

```lean
η.app (D.obj X) ≫ idempotent.hom.app X = D.map (η.app X)
```

LHS has type `D(X) ⟶ D(X)`; RHS has type `D(X) ⟶ D(D(X))`. Type mismatch; the original `DistinctionStructure` declaration never compiled. The file was written as documentation-shaped Lean and was never `lake build`-checked before this session.

**Chosen:**

```lean
η.app (D.obj X) ≫ idempotent.hom.app X = 𝟙 (D.obj X)
```

The standard idempotent-monad section axiom: the unit at `D(X)` is a right inverse to the idempotency collapse. Both sides type `D(X) ⟶ D(X)`. This is the categorical statement of Spencer-Brown's *calling* axiom (marking twice = marking once) — the second marking is undone by idempotency.

**Alternatives not chosen:**

- `D.map (η.app X) ≫ idempotent.hom.app X = 𝟙 (D.obj X)` — also valid; the "D-applied-to-unit" version of the section axiom. Could be added as an additional axiom (full idempotent-comonad coherence) if the framework needs both directions.
- A framework-specific reading of Spencer-Brown calling not captured by either standard axiom.

**Status**: open to revision if the framework intends different coherence. The Heyting work does *not* depend on this choice — Heyting structure is on `Subobject Y`, not on `D` or `η`. A future revision of the coherent axiom would not require re-opening the Heyting instance.

---

## 2. `[HeytingAlgebra (Subobject (Δ.D.obj _))]` → `[∀ Y : C, HeytingAlgebra (Subobject Y)]`

**Files**: `Distribution.lean`, `Exploitation.lean`, `Refusal.lean`, `Partition.lean` (multiple occurrences across all four).

**Prior (sketch, did not compile):**

```lean
[HeytingAlgebra (Subobject (Δ.D.obj _))]
```

The `_` placeholder cannot be inferred in a binder context where `Y` is not yet bound. The sketch was reaching for "Heyting algebra on the codomain lattice for some `Y` the compiler will figure out," which is not a thing Lean supports in instance binders.

**Chosen:**

```lean
[∀ Y : C, HeytingAlgebra (Subobject Y)]
```

Universally quantified instance hypothesis: "for any `Y` in `C`, `Sub Y` carries the Heyting structure." Stronger than what the sketch was reaching for (the sketch implicitly wanted just the `D`-image case), but **matches exactly what the Mathlib gap actually provides when closed** — every classifier topos gives Heyting on every `Sub Y`, not just `Sub (D Y)`. The strengthening therefore costs nothing.

**Implication for Phase 1**: the instance we write in `SubobjectHeytingAlgebra.lean` will satisfy `∀ Y : C, HeytingAlgebra (Subobject Y)` automatically, since the construction (MLM IV.6 residual) doesn't depend on `Y` being in the image of any functor. No signature mismatch when wiring the instance into the cell files.

**Same fix also applied to**: `NonBoolean` and `refusal_residue` in `Refusal.lean`, which originally had `[HeytingAlgebra ...]` *inside* an existential (syntactically invalid). Moved to the def/theorem signature in the standard topos-theoretic form: "assuming the canonical Heyting structure on each `Sub Y`, there exists `Y` where double-negation fails."

---

## 3. `trivialized_iff_D_pointwise` third conjunct reformulated

**File**: `lean/FalseWorkPapers/Positions/Infrastructure.lean`, line 142.

**Prior (sketch, circularly typed):**

```lean
Δ.D.map f = inv (Δ.η.app X) ≫ f ≫ Δ.η.app Y
```

The `inv` requires `IsIso (Δ.η.app X)` to elaborate, but the `IsIso` witnesses were being *asserted alongside this equation* in the same conjunction. Lean can't elaborate a type signature that depends on hypotheses introduced later in the same signature.

**Chosen:**

```lean
Δ.η.app X ≫ Δ.D.map f = f ≫ Δ.η.app Y
```

The naturality form of `η` at `f`. **Provably equivalent to the inv-form** given the `IsIso` witnesses in the same conjunction (multiply by `inv (η.app X)` on both sides), but well-formed in the type signature itself.

Proof body simplifies from a 7-line `calc` (using `inv_hom_id`, `assoc`, `hnat`) to a one-liner: `exact ⟨hX, hY, (Δ.η.naturality f).symm⟩`.

**Mathematical content preserved**: the IFF asserts the same equivalence; only the *shape* of the third conjunct changed.

**Adding the inv-form as a corollary if needed**: trivial — one line. Can be added later if downstream code references the original shape. Not needed for the Heyting work.

---

## What was NOT touched

The mathematical content of the framework is unchanged. Phase 0 did not modify:

- The four cell predicates `IsInfrastructure`, `IsDistribution`, `IsExploitation`, `IsRefusal`.
- The four-position partition theorem in `Partition.lean`.
- The closure-residue construction for Exploitation (`img ≤ Im(η)ᶜᶜ ∧ ¬(img ≤ Im(η))`).
- The asymptotic-residue claim (`refusal_residue`).
- The Heyting-identity disjointness arguments (`exploitation_refusal_disjoint`, etc.).
- The Spencer-Brown framing, the `kernelImage` definition, the Commitment gate schema.

What changed: scaffolding (type bindings, one broken coherence axiom, one statement-shape reformulation, one stub cleanup). What didn't: the framework's structural commitments.

---

## Pointer to the gap

For the standing Mathlib gap that Phase 1 closes, see `HEYTING-GAP.md` in this directory.
