# Heyting gap — the upstream-Mathlib dependency that gates our partition proofs

**Status:** open. Tracked as the single named upstream blocker for the four-position partition theorem and the per-cell disjointness corollaries.

**Last update:** 2026-05-17.

---

## The gap, stated precisely

For `C` an elementary topos (`[HasClassifier C]`, `[HasPullbacks C]`, `[CartesianMonoidalCategory C]`, `[MonoidalClosed C]`), Mathlib provides `SemilatticeInf`, `SemilatticeSup`, and `OrderTop` on `Subobject Y`, but **does not** provide a `HeytingAlgebra (Subobject Y)` instance. The instance is theoretically forced by the structure of an elementary topos (Mac Lane–Moerdijk *Sheaves in Geometry and Logic* IV.8), but has not been formalised in Mathlib4 as of 2026-05.

Our partition theorem and three of the four cell-predicates (Distribution, Exploitation, Refusal) are stated as conditions over `Subobject (D.obj Y)` involving `ᶜ` (Heyting pseudo-complement) and `ᶜᶜ` (double-negation closure). The proofs reduce to Heyting-algebra identities — most centrally `aᶜ ⊓ aᶜᶜ = ⊥` and the trichotomy on `(img, kernelImage)` — but cannot close without the instance.

---

## Mathlib state (verified 2026-05)

Available now in `Mathlib.CategoryTheory.Subobject.Lattice`:

- `SemilatticeInf (Subobject Y)` — meet via pullback
- `SemilatticeSup (Subobject Y)` — join via image of coproduct
- `OrderTop (Subobject Y)` — top element via the identity subobject
- `OrderBot (Subobject Y)` — bottom element when `C` has an initial object that is strict
- Various `Subobject` ↔ `(Y ⟶ Ω)` correspondences via `Subobject.representativeIsoCorepresented` and friends

**Not available:**

- `HeytingAlgebra (Subobject Y)` for elementary topoi
- `CoheytingAlgebra (Subobject Y)` (the dual)
- `BiheytingAlgebra (Subobject Y)`

A Zulip thread on `leanprover.zulipchat.com` (2026-05, "Heyting algebra on subobjects in an elementary topos") confirmed with Edward van de Meent that the instance is genuinely absent and that no in-flight PR currently targets it.

---

## CwFTT — the closest existing scaffold

Edward van de Meent's scratch project [`edegeltje/CwFTT`](https://github.com/edegeltje/CwFTT) (commit on `main` as of 2026-05) builds the topos internal logic from a different axiomatisation (a `ToposData` class bundling classifier + cartesian-monoidal + closed + chosen pullbacks along truth) and targets `(X ⟶ Ω)` rather than `Subobject Y`. The two are order-isomorphic in any topos, so the structure transports cleanly.

What CwFTT has, as of 2026-05:

| File | Content | Status |
|------|---------|--------|
| `CwFTT/Classifier/Semilattice.lean` | `LE`, `PartialOrder`, `SemilatticeInf` on `(X ⟶ Ω)` | proven, no `sorry` |
| `CwFTT/Classifier/Ops/And.lean` | `and : Ω ⊗ Ω ⟶ Ω`, commutativity, associativity | proven |
| `CwFTT/Classifier/Ops/Imp.lean` | `imp` + `HImp (X ⟶ Ω)` + full Heyting adjunction (`le_himp_iff`) + ~12 derived lemmas | proven |
| `CwFTT/Classifier/Ops/Not.lean` | `not` + `truth_not`/`falsity_not` | one `sorry` in `truth_not` |
| `CwFTT/Classifier/Ops/Eq.lean` | equality predicate | proven |
| `CwFTT/Classifier/Ops/Falsity.lean` | bottom element | proven |
| `CwFTT/Classifier/Ops/Or.lean` | join classifier | **empty file** |
| `CwFTT/Classifier/Semilattice.lean` (bottom) | `Lattice` and `HeytingAlgebra` blueprint | commented out, not implemented |

**To close the gap relative to our needs**, the missing pieces are:

1. `Or.lean` — implement the disjunction classifier (~100–200 lines following Mac Lane–Moerdijk IV.6)
2. Finish the one `sorry` in `truth_not`
3. Wire `And`, `Or`, `Imp`, `Not`, `Falsity` into `Lattice (X ⟶ Ω)` and `HeytingAlgebra (X ⟶ Ω)` (blueprint exists in `Semilattice.lean` comments)
4. Transport across the `Subobject Y ≃o (Y ⟶ Ω)` order-isomorphism to produce `HeytingAlgebra (Subobject Y)`

Edward's repository is **scratch** — not Mathlib. Direct dependency on it is fragile. Its value is as roadmap and proof-technique reference, not as importable library.

---

## Sorrys in our tree that this gap unblocks

When the instance lands in Mathlib, the following `sorry`s in `lean/FalseWorkPapers/Positions/` can be discharged:

| File | Sorry | What it needs |
|------|-------|---------------|
| `Partition.lean` line 158 | Main `four_position_partition` proof | `HeytingAlgebra` on `Subobject` for the four-way disjunction-of-cells trichotomy |
| `Partition.lean` line 197 | `isRefusal_iff_image_le_compl` forward | Standard image-factorisation against the Heyting complement subobject |
| `Partition.lean` line 204 | `isRefusal_iff_image_le_compl` backward | Same |
| `Exploitation.lean` line 220 | `exploitation_refusal_disjoint` | `aᶜ ⊓ aᶜᶜ = ⊥` as a `Subobject` Heyting identity |
| `Refusal.lean` line 130 | `refusal_residue` (`Im(η) < ¬¬Im(η)` strictly in non-Boolean topoi) | Pseudo-complement structure on `Subobject` |
| `Distribution.lean` line 87 | `isDistribution_implies_neither_polar` | Heyting identities reading off the meet conditions in `IsDistribution` |

**Not gated on this:**

| File | Sorry | What it needs |
|------|-------|---------------|
| `Infrastructure.lean` line 128 | `trivialized_implies_isInfrastructure` | Mathlib `image.ι`-iso lemma + `Subobject.mk_eq_top` — routine, not Heyting |

Six Heyting-gated `sorry`s. One non-Heyting `sorry` that should be closable independently.

---

## The four options

**(A) Active Mathlib collaboration.** Coordinate with Edward to finish `Or.lean` → `Lattice` → `HeytingAlgebra` on `(X ⟶ Ω)` → `Subobject Y` bridge → PR. ~300–500 lines of new Lean on his foundation. Real Mathlib contribution path. Requires sustained engagement and review cycles.

**(B) Local port to `Subobject Y`.** Use CwFTT proofs as templates; redo on `Subobject Y` locally. ~200–400 lines local. Does not upstream. Duplicates effort that will eventually be redone in (A).

**(C) Sorry-state cleanly, build everything else.** Keep the six Heyting-gated `sorry`s in place with citations to this document. Close everything that's not Heyting-gated. Track the gap as a single named blocker. Minimal cost.

**(D) Axiomatic approach.** State our theorems under `[HeytingAlgebra (Subobject _)]` as an instance hypothesis. Mathematically misleading in a topos (the structure is forced, not assumed) but logically clean.

---

## Current posture: (C)

Adopted 2026-05-17. Reasoning:

1. The trajectory classification work (Tier 2) is gating Paper 1 v11.9 and the empirical pipeline — higher real-world priority than formalisation closure.
2. (B) is wasted effort: anything we build locally we would want upstream eventually.
3. (A) requires sustained engagement and Edward's collaboration cadence; better to start that when other priorities aren't competing.
4. (D) misrepresents the mathematics; preserved as a fallback if (A) and (C) both stall indefinitely.

Under (C), every remaining `sorry` in the partition tree is attributed to one of:

- **This gap.** Six sorrys, listed in the table above.
- **One routine Mathlib lemma.** `trivialized_implies_isInfrastructure` — non-Heyting; closable in (C) phase.
- **Pending categorical content from outside the Heyting register.** Commitment/Exploitation disjointness within `¬¬Im(η)` — flagged as the central open problem post-closure-residue commitment (see `validation/claims/five-position-derivation-formalization.md` § "Open problems the sketch surfaced").

---

## Threshold for switching to (A)

The posture upgrades from (C) to (A) when **at least two** of the following hold:

1. Tier 2 trajectory work is complete and the classifier change is deployed.
2. Edward indicates willingness to collaborate on `Or.lean` and/or the `HeytingAlgebra` wrap-up, or his pace of work on CwFTT slows enough that taking over a slice would not duplicate work.
3. A second use-site for `HeytingAlgebra (Subobject Y)` appears (e.g., the Lawvere-unification claim's category-theoretic substrate needs it, or a separate Mathlib contributor opens a related PR).
4. Six months have elapsed without movement on the Mathlib gap from any other party.

Re-evaluation cadence: quarterly. Next review 2026-08-17.

---

## Engagement record

- **2026-05 Zulip thread.** Author-drafted question on `leanprover.zulipchat.com` confirming the absence of `HeytingAlgebra (Subobject Y)` for elementary topoi. Edward van de Meent confirmed the gap and pointed to (i) Jaap van Oosten's topos-theory lecture notes as his source for the proofs and (ii) his scratch project `edegeltje/CwFTT` as scaffolding in progress.
- **2026-05 follow-up.** Reviewed CwFTT contents (`Classifier/Semilattice.lean`, `Classifier/Ops/`). Identified that ~60–70 % of the operator-level work for a Heyting instance is already done on `(X ⟶ Ω)`. Recorded the threshold and posture above.
- **Related Mathlib PRs in flight from Edward.**
  - [#37045](https://github.com/leanprover-community/mathlib4/pull/37045) — Pullback squares in cartesian monoidal categories
  - [#37844](https://github.com/leanprover-community/mathlib4/pull/37844) — Strict bicategory of partial maps in a category
  - [#38130](https://github.com/leanprover-community/mathlib4/pull/38130) — Category of partial map diagrams
  
  These do not directly target the Heyting gap but indicate Edward is actively upstreaming related machinery; the partial-map work supports the same elementary-topos foundation our work depends on.

Author conduct on Zulip follows the `docs/observations/validation-architecture-outcomes.md` venue-norm observation: author-drafted (not AI-drafted) posts, narrowly scoped questions, expectations calibrated to community pace.

---

## See also

- `lean/README.md` — overview of the Lean formalisation
- `papers/comma-formal-structure-note.md` § 6 — Theorem 0 (four-position partition) prose statement
- `validation/claims/five-position-derivation-formalization.md` — the corresponding validation claim; v0.5 changelog references this gap
- `lean/FalseWorkPapers/Positions/Setup.lean` — the shared definitions used by all four cell files
- `lean/FalseWorkPapers/Positions/Partition.lean` — the gated theorem itself
