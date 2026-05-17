/-
Copyright (c) 2026 Chris Brink.
Released under the same license as the rest of the FalseWork Papers.

Authors: Chris Brink (FalseWork)

# The four-position partition + Commitment gate dictionary

This is the index file for the framework's structural dictionary in
the topos register, as committed in `papers/comma-formal-structure-note.md`
(2026-05-17 revision).

The architecture has **two structural layers**:

* A **four-position partition** over morphisms — Infrastructure,
  Distribution, Exploitation, Refusal — disjoint and exhaustive over
  the morphism space of `C` (modulo the trivial-image edge case).
  This is the theorem-grade core. See `Partition.lean` for the
  partition theorem (Theorem 0).

* A **Commitment gate** — a binary fixedness condition applied
  *within each cell*, not as a fifth cell of its own. The gate's
  uniformity is schema-level (uniform shape across cells, content
  cell-specific); its theorem-grade unification was tested on
  2026-05-10 and closed negative. See `CommitmentGate.lean` and
  `MomentRelative.lean`.

This index supersedes the earlier "five-position theorem" framing
(Paper 1 v11.7 §4) following the architectural refinement on
2026-05-10. The reframe was driven by Lean exploration showing that
treating Commitment as a fifth cell created a Commitment/Exploitation
disjointness problem inside `(Im(η))ᶜᶜ` that *dissolves* once
Commitment is recognized as a gate operating within each cell.

## The dictionary

For a category `C` (a "field of practice") equipped with a
non-trivial `DistinctionStructure Δ` (an idempotent endofunctor `D`
with marking unit `η`), every morphism `f : X ⟶ Y` with non-trivial
`D`-image falls into one of four disjoint structural cells:

| Cell           | Predicate (informal)                              | File                  |
|----------------|---------------------------------------------------|-----------------------|
| Infrastructure | `image(D.map f) ≤ Im(η)`                          | `Infrastructure.lean` |
| Distribution   | `image(D.map f)` straddles `Im(η)` and `(Im(η))ᶜ` | `Distribution.lean`   |
| Exploitation   | `image(D.map f) ≤ (Im(η))ᶜᶜ ∧ ¬(≤ Im(η))`         | `Exploitation.lean`   |
| Refusal        | `image(D.map f) ≤ (Im(η))ᶜ`                       | `Refusal.lean`        |

Within each cell `P`, a morphism `f` is additionally either
**Commitment-yes at `P`** (a fixed point of the cell-restricted
iteration of `D`, i.e., at the structural limit of the cell) or
**Commitment-no at `P`**. This is the gate.

| Layer            | File                                          |
|------------------|-----------------------------------------------|
| Partition theorem| `Partition.lean` — Theorem 0                       |
| Commitment gate  | `CommitmentGate.lean` — schema-level uniformity    |
| Gate exploration | `MomentRelative.lean` — 2-parameter closed neg     |

## Status of each cell predicate

* **Infrastructure (revised 2026-05-17).** Image-subobject condition
  `img ≤ kernelImage`. The earlier endpoint-iso predicate
  (`IsIso (η.app X) ∧ IsIso (η.app Y)`) was retired because it would
  have left an exhaustiveness hole; it survives as the sufficient
  sub-condition `Trivialized` (a degenerate case where the kernel is
  transparent at the work's endpoints). Signature lemma:
  `Trivialized` implies `D` acts pointwise via `η`'s naturality.

* **Refusal.** Clean *given* Heyting structure on `Subobject _`.
  Asymptotic-residue theorem (`refusal_residue`) follows from the
  intuitionistic strict inequality `Im(η) < (Im(η))ᶜᶜ` in non-Boolean
  topoi.

* **Distribution.** Clean given Heyting structure. Signature theorem:
  Distribution sits strictly between Infrastructure (image entirely
  in `Im(η)`) and Refusal (image entirely in `(Im(η))ᶜ`).

* **Exploitation (closure-residue committed 2026-05-09).** Factors
  into `(Im(η))ᶜᶜ` but not into `Im(η)` (at the level of generalized
  elements). Two signature theorems committed: `exploitation_requires_nonBoolean`
  and `exploitation_refusal_disjoint`. The earlier
  Commitment/Exploitation disjointness problem inside `(Im(η))ᶜᶜ`
  *dissolved* on 2026-05-10 with the gate reframe — Commitment is
  no longer a separate cell competing with Exploitation for the
  closure-residue region.

## The partition theorem

> *Theorem 0 (Four-position partition).* Let `Δ` be a non-trivial
> distinction structure on an elementary topos `C` with the requisite
> Heyting structure on its subobject lattices. For every morphism
> `f : X ⟶ Y` in `C` with non-trivial `D`-image, exactly one of
> `IsInfrastructure Δ f`, `IsDistribution Δ f`, `IsExploitation Δ f`,
> `IsRefusal Δ f` holds. The four cells are pairwise disjoint
> Heyting conditions on `(image(D.map f), kernelImage Δ Y)` and
> exhaustive over the morphism space of `C` (modulo the trivial-image
> edge case, in which every cell holds vacuously).

The statement is in `Partition.lean`. The proof is `sorry` pending
the Mathlib `HeytingAlgebra (Subobject Y)` instance for topoi (the
upstream gap noted in `Setup.lean`) and two auxiliary lemmas (Refusal
image-subobject characterisation, Heyting trichotomy).

## The Commitment gate (schema-level)

> *Schema. For each cell `P`, the gate has the form:*
> `IsCommitmentYes Δ P f := f ≅ colim_{n} (iter_P^n f)`,
> *where `iter_P` is `D`-iteration restricted to the subcategory cut
> out by `P`. The shape of this schema is uniform across cells. The
> content of `iter_P` is cell-specific (the iteration takes place in
> a different subcategory for each cell).*

The schema is documented in `CommitmentGate.lean`. The schema-level
uniformity vs. theorem-grade unification distinction is the result of
the 2026-05-10 exploration in `MomentRelative.lean`.

## Open problems, ranked

1. **`HeytingAlgebra (Subobject _)` for topoi.** Mathlib gap;
   PR-able. ~200–400 lines following Mac Lane–Moerdijk IV.8.
   Unblocks Refusal, Distribution, Exploitation, *and* the partition
   theorem in `Partition.lean`. This is the load-bearing gap.

2. **Partition theorem proof.** Once the Heyting instance is in
   place, the proof reduces to Heyting-algebra case-split (≈ 50–100
   lines), the Refusal image-subobject characterisation
   (`isRefusal_iff_image_le_compl`, ≈ 20 lines), and the Heyting
   trichotomy lemma.

3. **Continuous iteration of `D`.** Either relax Spencer-Brown
   idempotency, add interval-object parameterization, or work in an
   enriched setting. Decision is framework-level. Affects the
   Commitment gate's content (which iteration is the relevant one),
   not the partition theorem.

4. **Hypothesis on `Δ` to make `refusal_residue` go through.** Step 3
   of the proof sketch needs a hypothesis identifying when
   `kernelImage` plays the role of the non-Boolean witness. Two
   candidate hypotheses are flagged in `Refusal.lean`.

5. **Level structure for Deep Infrastructure.** Fibration of `C`
   over `ℕ` (or over a more general level-poset). Two paths
   documented in `Infrastructure.lean`. Deep Infrastructure is a
   refinement *within* Infrastructure, not a separate cell.

6. **Balance condition for Distribution.** Three candidate
   refinements (anti-chain, equimeasure, categorical decomposition)
   documented in `Distribution.lean`. The current "both intersections
   non-trivial" predicate suffices for the partition theorem; a
   stronger balance condition is a refinement within Distribution.

7. **Per-cell Commitment-iteration content.** With the gate reframe,
   each cell has its own cell-restricted iteration operator whose
   fixed points constitute Commitment-yes at that cell. Specifying
   these four operators categorically is open work, replacing the
   dissolved Commitment/Exploitation disjointness problem.

## Register

The dictionary's home register is **Heyting-algebraic / locale-theoretic /
intuitionistic-logical** (one structure, four names). See
`Positions/REGISTER.md` for the framing note, including the explicit
hazard of conflating this register with manifold / measure-
concentration "geometry" that shares the word but not the structure.

## Cross-reference

* Paper 1 §3.4 — original five-position derivation (v11.7); the v11.8
  top-matter notes the architectural refinement; v11.9 rewrite
  pending the trajectory reclassification work
* Paper 3 §2 — distinction operation as primitive output
* Paper 3 §9 — original five-position framing; the v9.4 top-matter
  notes the reframe; v10.0 rewrite pending specialist engagement
* Paper 4 — mathematics as comma; comma-object construction
* `papers/comma-formal-structure-note.md` — the expository companion
  to this Lean dictionary (current architecture, 2026-05-17 revision)
* `Positions/REGISTER.md` — register note (Heyting / locale / intuitionistic)
* `Positions/MomentRelative.lean` — the 2026-05-10 exploration that
  closed the two-parameter-unification question. *Not* imported here;
  exploration only.
* `validation/claims/five-position-derivation-formalization.md` —
  versioned status of the formal claims

The empirical record against which the dictionary is tested:
* `db/0121_curricula_and_glossary.sql` — Coltrane Trajectory
* `db/0154_painting_curriculum.sql` — Painting Trajectory
* `db/0160_kurosawa_trajectory.sql` — Kurosawa Trajectory
in the FalseWork application repository.
-/

import FalseWorkPapers.Positions.Setup
import FalseWorkPapers.Positions.Infrastructure
import FalseWorkPapers.Positions.Distribution
import FalseWorkPapers.Positions.Exploitation
import FalseWorkPapers.Positions.Refusal
import FalseWorkPapers.Positions.CommitmentGate
import FalseWorkPapers.Positions.Partition
