/-
Copyright (c) 2026 Chris Brink.
Released under the same license as the rest of the FalseWork Papers.

Authors: Chris Brink (FalseWork)

# The five-position dictionary

This is the index file for the candidate formalization of the
five-position theorem from Paper 1 v11.7 § 4 in the topos register
described in Paper 3 v9.3 § 2 and the asymmetry-principle opening of
Paper 1 v11.7 § 1.

## The dictionary

For a category `C` (a "field of practice") equipped with a non-trivial
`DistinctionStructure Δ` (the kernel: an idempotent endofunctor `D`
with marking unit `η`), every morphism `f : X ⟶ Y` falls into one of
five disjoint structural classes:

| Position       | Definition (informal)                                       | File                  |
|----------------|-------------------------------------------------------------|-----------------------|
| Infrastructure | `η` invertible at endpoints; `D` acts trivially             | `Infrastructure.lean` |
| Distribution   | `D.map f` straddles `Im(η)` and `¬Im(η)`                    | `Distribution.lean`   |
| Exploitation   | `img(D.map f) ≤ ¬¬Im(η)` and `img ⊄ Im(η)` (closure-residue)| `Exploitation.lean`   |
| Commitment     | `f ≅ colim D^n(g)` (asymptotic, one pole pursued)           | `Commitment.lean`     |
| Refusal        | `D.map f` factors through `(Im(η))ᶜ`                        | `Refusal.lean`        |

**Framework commitment (2026-05-09): closure-residue construction.**
The comma object `L_d` is the closure-residue territory — defined
at the level of generalized elements as the property
`Im(D.map f) ≤ ¬¬Im(η) ∧ Im(D.map f) ⊄ Im(η)`. Note that
`¬¬Im(η) ∖ Im(η)` is empty as a strict Heyting sub-element
(`¬¬a ⊓ ¬a = ⊥` is a Heyting identity); the residue is well-defined
only at the level of generalized elements, not as a single
subobject. Exploitation factors into this territory; no separate
`CommaObject` parameter is needed. Exploitation and Refusal occupy
disjoint Heyting regions (`(Im(η))ᶜᶜ` and `(Im(η))ᶜ` respectively),
both leveraging non-Boolean structure.

## The theorem candidate

> *Theorem candidate (revised, Paper 1 v11.7 § 4).* Let `C` be an
> elementary topos equipped with a non-trivial distinction structure
> `Δ`. Suppose `C` is non-Boolean (so the internal logic is
> intuitionistic but not classical) and equipped with a comma-object
> structure `Λ : CommaObject Δ`. Then every morphism `f : X ⟶ Y` in
> `C` falls into exactly one of the five disjoint classes
> `IsInfrastructure`, `IsDistribution`, `IsExploitation Λ`,
> `IsCommitment`, `IsRefusal` — modulo a hybrid region at adjacent-
> position boundaries whose "thickness" is computable from `Δ`'s
> behavior.

The disjointness claim and the exhaustiveness claim (modulo the
hybrid region) are the substantive content. The hybrid region
explains the empirical observation that some works produce
classifier dissent on multiple axes (e.g., Kurosawa's *Ikiru* and
*Throne of Blood*).

## Status of each position

* **Infrastructure.** Cleanest standalone — `IsIso (η.app _)`, no
  Heyting needed. Signature theorem `D.map f` is determined by `f`
  via `η`'s naturality.

* **Refusal.** Clean *given* Heyting structure on `Subobject _`.
  Asymptotic-residue theorem follows from intuitionistic
  `¬¬a > a` strict-inequality in non-Boolean topoi.

* **Distribution.** Clean given Heyting structure. Signature theorem:
  Distribution sits strictly between Infrastructure (where image
  ⊆ `Im(η)`) and Refusal (where image ⊆ `¬Im(η)`).

* **Commitment.** Needs continuous-iteration refinement of `D`
  (Spencer-Brown's discrete idempotency collapses the iterated
  diagram). With `Ind`-objects, the colimit-formulation works; needs
  framework-level decision on the right hypothesis.

* **Exploitation.** *Closure-residue committed 2026-05-09.*
  Exploitation factors into `¬¬Im(η)` but not into `Im(η)` (at the
  level of generalized elements). Two signature theorems committed
  (non-Boolean dependence, disjointness from Refusal). A third
  theorem distinguishing Exploitation from Commitment within
  `¬¬Im(η)` was drafted and *withdrawn* — see open question 1
  below. The closure-residue commitment makes Exploitation
  formalizable; the Commitment/Exploitation disjointness is now
  the framework's central open problem.

## Open questions, ranked

1. **Commitment/Exploitation disjointness within `¬¬Im(η)`.** Both
   positions live in the closure; the theorem candidate's
   disjointness claim requires a categorical distinction between
   them that is *not yet specified*. A "transverse direction vs
   pole direction" framing was drafted 2026-05-09 and withdrawn
   pending specification. Three candidate hypotheses are flagged in
   `Exploitation.lean`. This is the framework's central open
   problem post-closure-residue commitment.

2. **`HeytingAlgebra (Subobject _)` for topoi.** Mathlib gap;
   PR-able. ~200–400 lines following Mac Lane–Moerdijk IV.8.
   Unblocks Refusal, Distribution, and Exploitation simultaneously.

3. **Continuous iteration of `D`.** Either relax Spencer-Brown
   idempotency, add interval-object parameterization, or work in an
   enriched setting. Decision is framework-level. Affects Commitment
   primarily; may also affect the resolution of open question 1 if
   the Commitment/Exploitation distinction turns out to live in the
   iteration parameterization.

4. **Hypothesis on `Δ` to make `refusal_residue` go through.** Step 3
   of the proof sketch needs a hypothesis identifying when
   `kernelImage` plays the role of the non-Boolean witness. Two
   candidate hypotheses are flagged in `Refusal.lean`.

5. **Level structure for Deep Infrastructure.** Fibration of `C`
   over `ℕ` (or over a more general level-poset). Two paths
   documented in `Infrastructure.lean`.

6. **Balance condition for Distribution.** Three candidate
   refinements (anti-chain, equimeasure, categorical decomposition)
   documented in `Distribution.lean`.

## Framework writeup pending

The closure-residue commitment for Exploitation has consequences that
should land in the framework's exposition, not just the Lean files:

* **Abstraction movements as Exploitation.** Modernist painting, late
  modernist music, modernist literature, set-theoretic foundations in
  mathematics — each is the specific form Exploitation takes when
  practitioners aggressively pursue closure the underlying kernel
  cannot deliver. The closure-residue construction provides the
  formal home; whether the further empirical claim (the
  four-mechanism cluster, the Coltrane–Hendrix pairing) reduces to
  categorical content within the residue or operates at a different
  level is part of open question 1.

* **Exploitation/Refusal as disjoint Heyting regions.** Both depend
  on non-Boolean topos structure; they occupy disjoint regions of
  the subobject lattice (`(Im(η))ᶜ` for Refusal, `(Im(η))ᶜᶜ ∖ Im(η)`
  at the level of generalized elements for Exploitation). This
  disjointness is a Heyting theorem, not an additional commitment.

These belong either as a section in Paper 1 or as a dedicated
comma-object paper. Care should be taken not to overcommit to the
finer-grained empirical structure (mechanism distinctions,
direction language) before the categorical content is specified.

## Register

The dictionary's home register is **Heyting-algebraic / locale-theoretic /
intuitionistic-logical** (one structure, four names). See
[`Positions/REGISTER.md`](Positions/REGISTER.md) for the framing note,
including the explicit hazard of conflating this register with
manifold / measure-concentration "geometry" that shares the word but
not the structure.

## Cross-reference

* Paper 1 v11.7 § 1 — asymmetry principle
* Paper 1 v11.7 § 4 — five-position theorem
* Paper 3 v9.3 § 2 — distinction operation as primitive output
* Paper 4 — mathematics as comma; comma-object construction
* `papers/comma-formal-structure-note.md` — expository companion to this
  Lean dictionary; prose statement of the closure-residue construction,
  the five-position predicates, the three signature theorems, and the
  ranked open problems, for category-theorist and topos-theorist readers
  who want the apparatus without the Lean source
* [`Positions/REGISTER.md`](Positions/REGISTER.md) — register note (Heyting / locale / intuitionistic)
* `validation/claims/five-position-derivation-formalization.md` —
  open theorem this file targets

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
import FalseWorkPapers.Positions.Commitment
import FalseWorkPapers.Positions.Refusal
