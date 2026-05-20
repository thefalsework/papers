# Heyting / native-Subobject instance diamond

> **Resolved**: Option 1 (drop the abstract binder; consume the universal
> `FalseWork.Heyting.heytingAlgebra` instance directly via `Setup.lean`).
> Phase 3 commit, 2026-05-19.  See
> `lean/PHASE-0-DECISIONS.md` § "Decision 2 superseded (Phase 3,
> 2026-05-19)" for the audit trail.  This file is preserved as
> historical record of the triage that led to the supersession.

---

**Status (2026-05-19, pre-resolution):** Discovered during Phase 3 cell-sorry pass.
Blocks all five Heyting-blocked `sorry`s in the cell files
(`Distribution`, `Exploitation`, `Refusal`, `Partition x2`).  Needs a
Phase-0-level decision before Phase 3 can proceed.  Phase 2 work
(SubobjectInstance.lean) is unaffected and remains audit-clean.

## What the diamond is

The cell files have the abstract binder
`[∀ Y : C, HeytingAlgebra (Subobject Y)]` (Phase-0 Decision 2) and
work with subobjects coming from Mathlib's `Subobject Y` type.
Mathlib ships *its own* lattice instances on `Subobject Y`:

* `instance semilatticeInf : SemilatticeInf (Subobject B)`  (always)
* `instance orderTop       : OrderTop (Subobject B)`        (always)
* `instance orderBot       : OrderBot (Subobject B)`        (needs `HasInitial C` + `InitialMonoClass C`)
* `instance lattice        : Lattice (Subobject B)`         (always)
* `instance boundedOrder   : BoundedOrder (Subobject B)`    (needs `HasInitial C` + `InitialMonoClass C`)

These derive a native `PartialOrder (Subobject B)` (called
`instPartialOrderSubobject` after Lean's auto-naming).

The cell binder `[∀ Y, HeytingAlgebra (Subobject Y)]` also induces a
`PartialOrder (Subobject Y)` along a *different* projection chain:
`HeytingAlgebra → GeneralizedHeytingAlgebra → SemilatticeInf →
PartialOrder`.

Both chains end with a `PartialOrder (Subobject Y)` whose underlying
`≤` is the same *mathematical* relation in any sensible model — but
Lean sees them as **two distinct `PartialOrder` instances**, hence two
distinct `SemilatticeInf` instances, hence two distinct `⊓`s, hence two
distinct `OrderBot`s, hence two distinct `⊥`s.

Concretely:

```
hle has type
  @LE.le ... (instPartialOrderSubobject (Δ.D.obj Y)) ...

LE.le.disjoint_compl_right expects type
  @LE.le ... HeytingAlgebra.toGeneralizedHeytingAlgebra
                          .toSemilatticeInf.toPartialOrder ...
```

The cell-sorry proof tries to mix Heyting-specific lemmas
(`disjoint_compl_right`, `inf_compl_eq_bot`, `le_compl_iff_disjoint_right`)
— which use the binder's chain — with the theorem's hypothesis `hle`,
which Lean elaborates with the native chain (because `instPartialOrderSubobject`
is the shorter, more direct path).  No proof goes through.

## Why our Phase-2 instance still works

The universal `FalseWork.Heyting.heytingAlgebra` is built *on top of*
the native lattice instances:

```lean
noncomputable instance heytingAlgebra : HeytingAlgebra (Subobject X) :=
  { Subobject.semilatticeInf, Subobject.semilatticeSup,
    Subobject.orderTop, Subobject.orderBot with
    himp := residual
    ... }
```

By construction the Heyting chain and the native chain land on
`Subobject.semilatticeInf` definitionally — so when the universal
instance is in scope *without an abstract binder shadowing it*, the two
`PartialOrder` projections are `rfl`-equal and the diamond dissolves.

The abstract `[∀ Y, HeytingAlgebra (Subobject Y)]` binder shadows the
universal instance inside the cell-file theorems.  Lean treats the
binder as an opaque `HeytingAlgebra`, with no guarantee that its
lattice agrees with the native one.

## Resolution options

### Option 1 — Drop the binder; use the universal instance directly

Replace `[∀ Y : C, HeytingAlgebra (Subobject Y)]` in each cell file with
the concrete topos hypothesis bundle (`[HasInitial C] [InitialMonoClass C]
[HasBinaryCoproducts C] [HasEqualizers C]`), and let
`FalseWork.Heyting.heytingAlgebra` fire automatically.

* **Pro:** trivially closes all five sorries via standard Heyting +
  Subobject lemmas, with no diamond.
* **Con:** violates Phase-0 Decision 2 literally (the binder shape
  changes — the abstract layer is dropped).
* **Effect on framework:** the cell theorems now require a full
  elementary-topos hypothesis bundle.  This was the framework's
  intended scope anyway; the abstract binder was a hedge against the
  Mathlib gap that Phase 2 has now closed.

### Option 2 — Strengthen the binder with a coherence hypothesis

Keep `[∀ Y, HeytingAlgebra (Subobject Y)]` but *add* a hypothesis
asserting the Heyting lattice equals the native Subobject lattice.
Either:

* Inline:  `[∀ Y, (inferInstance : HeytingAlgebra (Subobject Y))
                  .toGeneralizedHeytingAlgebra.toSemilatticeInf
                = Subobject.semilatticeInf]` — verbose and fragile.
* Class:   Define a `CoherentSubobjectHeytingAlgebra` class extending
  `HeytingAlgebra (Subobject Y)` and asserting the underlying-lattice
  coherence as a field.  Cleaner but invents new infrastructure.

* **Pro:** preserves the binder shape (mostly).  Lets the cell proofs
  rewrite native LE to Heyting LE via the coherence hypothesis.
* **Con:** uglier signature.  The coherence assertion is propositional
  equality of typeclass instances, which Lean handles awkwardly.

### Option 3 — Annotate theorem statements with explicit Heyting LE

Keep the binder; explicitly type the `≤` in each theorem statement to
the binder's Heyting-derived LE (so `hle` is *born* Heyting-typed).

Example:
```lean
theorem isDistribution_implies_neither_polar (Δ : DistinctionStructure C)
    [∀ Y : C, HeytingAlgebra (Subobject Y)]
    {X Y : C} (f : X ⟶ Y) (h : IsDistribution Δ f) :
    let img := Subobject.mk (image.ι (Δ.D.map f))
    ¬(@LE.le _
        HeytingAlgebra.toGeneralizedHeytingAlgebra.toSemilatticeInf
          .toPartialOrder.toPreorder.toLE
        img (kernelImage Δ Y)) ∧
    ¬(@LE.le _ ...
        img (kernelImage Δ Y)ᶜ) := by
  ...
```

* **Pro:** preserves binder shape and the abstract Heyting layer.
* **Con:** every Heyting-using theorem needs the explicit-LE annotation.
  Downstream uses (e.g.\ from `Partition.lean`) propagate the annotation.
  The cell predicates `IsDistribution`, `IsExploitation`, etc. similarly
  need careful annotation so the `⊓` and `⊥` in their bodies match the
  Heyting chain (otherwise the `obtain ⟨h_lo, h_hi⟩` destructuring lands
  in a mixed-instance state again).

## Recommendation

**Option 1** is the cleanest and most aligned with the framework's
*actual* scope.  The Heyting binder was a Phase-0 workaround for the
Mathlib gap.  Phase 2 has closed the gap; the binder is now a vestigial
abstraction that doesn't carry useful generality (it allows *incoherent*
HeytingAlgebra instances that wouldn't satisfy the framework's intent
anyway).  Replacing the binder with the topos-hypothesis bundle moves
the cell files into the same posture as `Partition.lean` already uses,
and lets all five sorries close trivially.

Decision 2 should be revisited in light of Phase 2's completion:
the binder was a *temporary* shape pinned during the gap.  Closing the
gap arguably *fulfils* the spirit of Decision 2 even while changing its
letter.

**Option 2** is the second choice if Decision 2 is read strictly.
The `CoherentSubobjectHeytingAlgebra` class is the cleanest way to keep
the abstraction layer while making the coherence requirement
type-system-visible.

**Option 3** is not recommended.  It preserves the binder shape at the
cost of pervasive ugliness and downstream fragility.

## State at time of write-up

* Phase 2 (`SubobjectInstance.lean`, six bridging lemmas + Heyting
  instance) — committed at `2fed510`, audit-clean, no sorries.
* Phase 3 setup (import wiring in `Positions.lean`, retired TODOs) —
  committed at `a57619f`.
* Phase 3 cell-sorry pass — paused on this diamond.  `Distribution.lean`
  still carries its original sorry plus an in-file comment pointing here.
  Other four sorries (`Exploitation` line 208, `Refusal` line 105,
  `Partition` lines 114 + 184) are untouched.
* Build is green: only the five Heyting-blocked sorries plus the
  Infrastructure image-API sorry remain.
