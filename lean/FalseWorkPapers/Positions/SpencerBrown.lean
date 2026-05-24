/-
Copyright (c) 2026 Chris Brink.
Released under the same license as the rest of the FalseWork Papers.

Authors: Chris Brink (FalseWork)

# Spencer-Brown anchor: the structural correspondences, mechanized

This file mechanizes the two pieces of the Spencer-Brown anchor
(`preprints/four-position-partition/spencer-brown-anchor.md`) that
have a directly Lean-formalizable form. Both are kernel-checkable
elaborations of the partition theorem rather than independent results,
and both correspond to *Remarks* in the preprint paper:

* **Boolean collapse (Remark 5.3).** In a Boolean topos — equivalently,
  on any object `Y` where every subobject of `D.obj Y` satisfies
  `Sᶜᶜ = S` — the four-position partition reduces to a three-cell
  partition (Infrastructure / Distribution / Refusal). Exploitation
  is structurally identified as the cell that exists *only* when the
  ambient logic fails to satisfy Spencer-Brown's crossing axiom; in
  any topos that does satisfy it, Exploitation becomes uninhabited.

* **Idempotent-monad bridge (Remark 5.5).** Every idempotent monad
  `T : Monad C` (i.e., one with `T.μ` a natural isomorphism) gives
  rise to a `DistinctionStructure C` by taking `D := T.toFunctor`,
  `η := T.η`, and `idempotent := asIso T.μ`. The coherence condition
  of Definition 3.1 reduces to the monad's left-unit law. This
  identifies idempotent monads — and hence every reflective
  subcategory of an elementary topos — as a canonical source of
  distinction structures.

Both formalize content that is already discussed in the paper as
remarks; turning them into kernel-checked theorems closes the gap
between the prose-level claim and the formal artefact and makes the
SB-anchor companion mechanizable rather than purely interpretive.

## Provenance

The cell-level version of the Boolean collapse is the
`exploitation_requires_nonBoolean` theorem in `Exploitation.lean`
(2026-05-19). This file lifts that theorem from the cell predicate
level to the partition theorem level, combining it with
`four_position_partition` from `Partition.lean` (2026-05-19), and
adds the idempotent-monad bridge as a new constructor. Nothing in
the partition theorem itself changes.

## Cross-reference

* `preprints/four-position-partition/spencer-brown-anchor.md` —
  the companion document developing the structural correspondence
  in prose; this file is its mechanized counterpart.
* `preprints/four-position-partition/paper.md` — Remarks 5.3 and 5.5
  are the propositions this file kernel-checks.
* `Exploitation.lean` — `exploitation_requires_nonBoolean` (the
  cell-level Boolean collapse).
* `Partition.lean` — `four_position_partition` (the four-cell
  exhaustive disjoint partition).
* Mathlib `CategoryTheory.Monad.Basic` — the `Monad` structure used
  by the idempotent-monad bridge.
-/

import FalseWorkPapers.Positions.Setup
import FalseWorkPapers.Positions.Exploitation
import FalseWorkPapers.Positions.Partition
import Mathlib.CategoryTheory.Monad.Basic

namespace FalseWork.Positions

open CategoryTheory CategoryTheory.Limits

universe v u

variable {C : Type u} [Category.{v} C]

/-! ## 1. The idempotent-monad bridge -/

/-- **Every idempotent monad gives a distinction structure.** Given a
monad `T : Monad C` whose multiplication `T.μ : T ⋙ T ⟶ T` is a
natural isomorphism, we construct a `DistinctionStructure C` with
`D := T.toFunctor`, `η := T.η`, and `idempotent := asIso T.μ`. The
coherence condition `η_{D X} ≫ ι.hom_X = 𝟙 (D X)` follows directly
from the monad's left-unit law `T.η_{T X} ≫ T.μ_X = 𝟙 (T X)`, since
`(asIso T.μ).hom = T.μ` by `asIso_hom`.

This is the content of Remark 5.5 of the paper: every idempotent
monad satisfies the conditions of Definition 3.1. Idempotent monads
on `C` correspond to reflective subcategories of `C` (Borceux 1994,
Vol. 1, §4.2), so this bridge identifies reflective subcategories of
elementary topoi as a canonical source of distinction structures. -/
noncomputable def DistinctionStructure.ofIdempotentMonad
    (T : Monad C) [IsIso T.μ] : DistinctionStructure C where
  D := T.toFunctor
  η := T.η
  idempotent := asIso T.μ
  coherent X := by
    show T.η.app (T.toFunctor.obj X) ≫ (asIso T.μ).hom.app X
      = 𝟙 (T.toFunctor.obj X)
    rw [asIso_hom]
    exact T.left_unit X

/-! ## 2. The Boolean collapse at the partition level

The cell-level fact that Exploitation is uninhabited in a Boolean
topos is already in `Exploitation.lean` as
`exploitation_requires_nonBoolean`. Lifting that fact through
`four_position_partition` yields the partition-level statement
below: under the Boolean hypothesis, the exhaustiveness disjunction
reduces from four to three cells. The pairwise disjointness clauses
of the three-cell partition are inherited unchanged from the
four-cell partition. -/

section BooleanCollapse

variable [HasImages C] [HasPullbacks C] [HasSubobjectClassifier C]
  [HasEqualizers C] [HasInitial C] [HasBinaryCoproducts C] [InitialMonoClass C]

/-- **Boolean collapse of the partition (Remark 5.3).** Under the
hypothesis that the subobject lattice of `D.obj Y` is Boolean — i.e.
that every subobject `S` of `D.obj Y` is regular, `Sᶜᶜ = S` — the
four-position partition reduces to a three-cell partition over
`IsInfrastructure`, `IsDistribution`, `IsRefusal`. The Exploitation
cell is unsatisfiable under this hypothesis (cf.
`exploitation_requires_nonBoolean`).

The Boolean hypothesis is stated locally at each `Y` rather than
globally on `C`, matching the existing convention of
`exploitation_requires_nonBoolean`. The Spencer-Brown reading: this
is the cell-level shape of "in a setting where the crossing axiom
holds, the partition only sees three of the four structural
positions." -/
theorem boolean_partition_three_cells
    (Δ : DistinctionStructure C)
    (h_boolean : ∀ Y : C, ∀ S : Subobject (Δ.D.obj Y), Sᶜᶜ = S)
    {X Y : C} (f : X ⟶ Y)
    (h_nontriv : Subobject.mk (image.ι (Δ.D.map f)) ≠ ⊥) :
    (IsInfrastructure Δ f ∨ IsDistribution Δ f ∨ IsRefusal Δ f) ∧
      (IsInfrastructure Δ f → ¬ IsDistribution Δ f) ∧
      (IsInfrastructure Δ f → ¬ IsRefusal Δ f) ∧
      (IsDistribution Δ f → ¬ IsRefusal Δ f) := by
  obtain ⟨exhaust, infra_dist, _infra_exp, infra_ref,
            _dist_exp, dist_ref, _exp_ref⟩ :=
    four_position_partition Δ f h_nontriv
  refine ⟨?_, infra_dist, infra_ref, dist_ref⟩
  rcases exhaust with h | h | h | h
  · exact Or.inl h
  · exact Or.inr (Or.inl h)
  · exact absurd h (exploitation_requires_nonBoolean Δ h_boolean f)
  · exact Or.inr (Or.inr h)

end BooleanCollapse

/-! ## Status

DONE (both kernel-checkable in this file):
* `DistinctionStructure.ofIdempotentMonad` — the idempotent-monad
  bridge of Remark 5.5. Construction is direct: take the monad's
  underlying functor, unit, and `asIso T.μ`; coherence follows from
  the monad's left-unit law via `asIso_hom`.
* `boolean_partition_three_cells` — the partition-level Boolean
  collapse of Remark 5.3. Combines `four_position_partition` with
  `exploitation_requires_nonBoolean`.

NOT FORMALIZED HERE (interpretive content, not theorems):
* The vocabulary correspondence between Definition 3.1 and the
  Spencer-Brown Calling axiom (`D` = the mark, `η` = the unit of
  marking, `ι` = the J1 collapse). This is documented in the SB
  anchor companion (`spencer-brown-anchor.md` §3) as a structural
  reading rather than a separate theorem; the categorical content
  it identifies is exactly the existing structure of
  `DistinctionStructure`.
* The reading of the four cells as Spencer-Brown registers (under
  the mark / straddling / failure-of-crossing residue / crossed
  out). This is a vocabulary mapping, not a Lean-formalizable
  proposition.

NOT FORMALIZED HERE (would require substantial separate work):
* A syntactic implementation of Spencer-Brown's primary arithmetic
  as a Lean datatype with the calling and crossing axioms as an
  equivalence relation. This would be a self-contained development
  in its own right and is flagged in the SB anchor companion as a
  possible future research project rather than a continuation of
  the partition theorem.
* The reverse direction of the idempotent-monad bridge — whether
  every distinction structure of Definition 3.1 arises from an
  idempotent monad — is an open question (cf. Remark 5.5 and the
  Zulip thread on `DistinctionStructure` vs. idempotent monads,
  posted 2026-05-24). This file does not address it; the forward
  direction (idempotent monads to distinction structures) is the
  one that is unambiguously true.

UPSTREAM MATHLIB:
* No new gap. The `Mathlib.CategoryTheory.Monad.Basic` import
  provides the `Monad` structure with `left_unit` and `asIso`; no
  additional Mathlib lemmas are required by either theorem in this
  file.
-/

end FalseWork.Positions
