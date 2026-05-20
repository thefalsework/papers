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

---

## Decision 2 superseded (Phase 3, 2026-05-19)

**Status**: superseded — not rewritten.  Section 2 above stands as the historical record of what was decided on 2026-05-19 *before* the Heyting instance was constructed.  This addendum documents why and how that decision was retired after Phase 2 closed the underlying gap.

**What changed**: the cell files (`Distribution.lean`, `Exploitation.lean`, `Refusal.lean`, `Partition.lean`) no longer carry the `[∀ Y : C, HeytingAlgebra (Subobject Y)]` binder on their predicates and theorems.  Instead, each cell's section variables include the topos hypothesis bundle (`[HasInitial C] [InitialMonoClass C] [HasBinaryCoproducts C] [HasEqualizers C]`, alongside the pre-existing `[HasImages C] [HasPullbacks C] [HasSubobjectClassifier C]`) and `Positions/Setup.lean` imports `FalseWorkPapers.Heyting.SubobjectInstance` so the universal `FalseWork.Heyting.heytingAlgebra` instance fires via typeclass search.

**Why the change was necessary**: during Phase 3 (cell-sorry pass), attempts to discharge the Heyting-blocked `sorry`s against the abstract binder ran into an instance diamond between Mathlib's native `instPartialOrderSubobject` (always available, derived from `Subobject.semilatticeInf`) and the abstract binder's `HeytingAlgebra.toGeneralizedHeytingAlgebra.toSemilatticeInf.toPartialOrder`.  The two `PartialOrder` instances are mathematically the same relation on `Subobject Y` but Lean treats them as distinct.  Cell hypotheses like `hle : img ≤ K` were inferred with the native instance; Heyting lemmas (`LE.le.disjoint_compl_right`, `inf_compl_self`, etc.) demanded the binder's instance.  No proof went through.

The full triage — three resolution options weighed, recommendation, and the cost/benefit analysis — was written up in `lean/HEYTING-DIAMOND.md` (kept as historical record with a "Resolved" header).  The diamond would have been avoidable if the binder were *coherent* with the native lattice, but the abstract binder leaves that coherence unenforceable.  Phase 2's concrete instance is built directly on top of `Subobject.semilatticeInf, Subobject.semilatticeSup, Subobject.orderTop, Subobject.orderBot` — so when consumed directly (not shadowed by a binder) the diamond dissolves.

**Why the supersession is consistent with Decision 2's *spirit***: Decision 2 was a stopgap.  It pinned the binder shape pre-Phase-1 to avoid second-guessing during the instance construction and to ensure the Phase 1 instance's signature matched what the cells consumed.  That goal was achieved — the universal instance is exactly `∀ X : C, HeytingAlgebra (Subobject X)` under the topos hypothesis bundle — but achieving it made the abstract binder redundant.  Phase 2 closed the gap that justified the binder; Phase 3 retiring the binder is the consistent next move.

**What's preserved from Decision 2**: the universal-quantification shape (`∀ Y : C`, not just `∀ Y, Y = Δ.D.obj _`) is preserved.  The Phase 2 instance is `noncomputable instance heytingAlgebra : HeytingAlgebra (Subobject X)` parameterized on any `X : C` in the topos, exactly matching the strengthening Section 2 above defended.

**Concrete sorry accounting after the supersession (build state at commit time)**:
* `Distribution.lean` — `isDistribution_implies_neither_polar` closed.
* `Exploitation.lean` — `exploitation_refusal_disjoint` closed.
* `Refusal.lean` — `refusal_residue` *not* closed; the remaining blocker is framework-level (step 3, transport of the non-Boolean witness onto `kernelImage`), not Heyting.
* `Partition.lean` — `four_position_partition` closed *modulo* the image-API helper `isRefusal_iff_image_le_compl` (two image-API `sorry`s).  The partition's own proof body has no direct `sorry`.
* `Infrastructure.lean` — image-API `sorry` unchanged (Path 5 in the working sequencing).

Three of the five "Heyting-blocked" sorries in `HEYTING-GAP.md`'s pre-Phase-3 inventory turned out to be cleanly closable by the universal instance.  The other two (the two halves of `isRefusal_iff_image_le_compl`) were *mis-classified* — they are image-API-blocked, not Heyting-blocked.  This is the audit move the supersession enables: now that Heyting is no longer a confound, the remaining gaps are visible.

**Decision 1 and Decision 3** are unaffected by the supersession.
