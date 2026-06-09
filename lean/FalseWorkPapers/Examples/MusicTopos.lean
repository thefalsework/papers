/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# The music presheaf topos `Set^{Pᵒᵖ}` as a Lean elementary-topos object

This file discharges the concrete-topos gap recorded in
`Examples/HeytingTypeInstance.lean` and `Examples/DivisorLattice12Birkhoff.lean`
(the "universe / `InitialMonoClass` resolution gap"): it instantiates the
**T2 construction** of the bridge note as an actual `CategoryTheory`
object in Lean, on which the framework's central theorem typechecks.

`P` is the poset of join-irreducibles of `Div12` — the three symmetric
pitch-class generators of `Z/12` (tritone `⟨6⟩` < diminished-7th `⟨3⟩`,
augmented-triad `⟨4⟩` incomparable) — made into a (small) category via
`Preorder.smallCategory`.  `MusicTopos := Pᵒᵖ ⥤ Type` is the presheaf
topos `Set^{Pᵒᵖ}`.

As of Mathlib `v4.30` the presheaf subobject classifier
(`CategoryTheory.Presheaf.classifier`; the instance
`HasSubobjectClassifier (Cᵒᵖ ⥤ Type w)` for essentially-small `C`) is
available.  This was the missing piece when the gap was first recorded:
with it, the full elementary-topos hypothesis bundle of
`FalseWorkPapers.Heyting.SubobjectInstance` /
`FalseWorkPapers.Positions.Partition` now resolves for this concrete,
music-derived topos, so the canonical Heyting-algebra structure on
`Subobject X` — the carrier of the four-position partition — is realized
on the actual subobject lattices of `Set^{Pᵒᵖ}`, with **no appeal to
Mazzola's framework**.

## What is established here (`[K]`, new)

* `musicTopos_isElementaryTopos` — every instance in the elementary-topos
  hypothesis bundle resolves for `MusicTopos` (the previously-deferred
  "Lean topos-object plumbing").
* `subTerminalHeytingAlgebra` — `Sub_{Set^{Pᵒᵖ}}(1)`, the subobject lattice
  of the terminal object (the lattice Birkhoff-identified with `Div12`), is
  a Heyting algebra on the concrete music topos.
* `four_position_partition_musicTopos` — the central theorem
  `four_position_partition` *typechecks and fires against the concrete music
  topos object*, which was the stated remaining step of bridge-note §5 /
  spine-note §5.1.

## What is **not** established here (honest boundary)

The distinction structure used in `four_position_partition_musicTopos` is the
*trivial* (identity-monad) one, `trivialDistinction MusicTopos`: this
demonstrates that the abstract theorem applies to the concrete topos object,
but over the trivial `Δ` the partition is degenerate (every non-trivial
morphism is `IsInfrastructure`; see `trivialDistinction`).  The
musically-loaded distinction operator — the tritone closure / nucleus with
its non-regular kernel — is carried at the **lattice** level
(`lattice_four_position_partition` on `Div12`, `music_anchor_witness`,
`tritone_kernel_has_lawvere_tierney_realization`).

Two follow-on steps, both now resolved:

* The explicit order-iso `Subobject (⊤_ MusicTopos) ≅ Div12` at the level of
  Mathlib's `Subobject` type (rather than the down-set level of
  `birkhoff_representation`) is **now kernel-checked** in
  `Examples/MusicToposSub.lean` (`subobjectTerminalEquivDiv12`).
* Lifting the tritone operator to a non-trivial *endofunctor on `Set^{Pᵒᵖ}`*
  via the sheafification monad **comes apart from the tritone at `1`**
  (`Examples/MusicToposTrace.lean`): the kernel `kernelImage Δ Y = Im(η.app Y)`
  is forced to `⊤` whenever the unit is iso, and the terminal is a sheaf for
  every topology, so no sheafification realizes the tritone (`⟨6⟩ ≠ ⊤`) as
  `kernelImage Δ 1`.  The non-degenerate partition therefore stays at the
  lattice level; a bespoke non-terminal-witness endofunctor remains open.
-/
import FalseWorkPapers.Examples.DivisorLattice12Birkhoff
import FalseWorkPapers.Heyting.SubobjectInstance
import FalseWorkPapers.Positions.Partition
import FalseWorkPapers.Examples.CanonizationGeneratorInstance
import Mathlib.CategoryTheory.Topos.Sheaf
import Mathlib.CategoryTheory.Limits.FunctorCategory.Basic
import Mathlib.CategoryTheory.Limits.FunctorCategory.Shapes.Images

namespace FalseWork.Lattice.Examples

namespace Div12

open CategoryTheory CategoryTheory.Limits

/-! ## The poset `P` of join-irreducibles as a small category -/

/-- The join-irreducible poset is a partial order (reusing the `leb`-based
`≤` of `DivisorLattice12Birkhoff`): `j2 < j4`, `j3` incomparable. -/
instance instPartialOrderJoinIrr : PartialOrder JoinIrr where
  le := (· ≤ ·)
  le_refl := by decide
  le_trans := by decide
  le_antisymm := by decide

/-- `P` — the music index poset, viewed as a (small) category via
`Preorder.smallCategory`. -/
abbrev P : Type := JoinIrr

/-- **The music presheaf topos** `Set^{Pᵒᵖ}` — the T2 construction realized
as an actual Lean category. -/
abbrev MusicTopos : Type _ := Pᵒᵖ ⥤ Type

/-! ## The elementary-topos hypothesis bundle resolves for `MusicTopos` -/

/-- **The music presheaf topos is a Lean elementary topos.**  Every instance
in the hypothesis bundle of `FalseWorkPapers.Positions.Partition`
(`four_position_partition`) and `FalseWorkPapers.Heyting.SubobjectInstance`
(`heytingAlgebra`) is found by typeclass search for the concrete,
music-derived presheaf topos `Set^{Pᵒᵖ}`.

This is the previously-deferred "topos-object plumbing": the gap recorded in
`HeytingTypeInstance.lean` was the absence of a presheaf subobject classifier
in Mathlib, supplied in `v4.30` by `CategoryTheory.Presheaf.classifier`.  The
key non-trivial component is `HasSubobjectClassifier MusicTopos`. -/
theorem musicTopos_isElementaryTopos :
    HasSubobjectClassifier MusicTopos ∧
    HasPullbacks MusicTopos ∧
    HasEqualizers MusicTopos ∧
    HasInitial MusicTopos ∧
    HasImages MusicTopos ∧
    HasBinaryCoproducts MusicTopos ∧
    InitialMonoClass MusicTopos :=
  ⟨inferInstance, inferInstance, inferInstance, inferInstance,
   inferInstance, inferInstance, inferInstance⟩

/-- For every object `X` of the music topos, `Subobject X` carries the
canonical Heyting-algebra structure of an elementary topos
(`FalseWork.Heyting.heytingAlgebra`). -/
theorem subobjectHeytingAlgebra (X : MusicTopos) :
    Nonempty (HeytingAlgebra (Subobject X)) := ⟨inferInstance⟩

/-- **`Sub_{Set^{Pᵒᵖ}}(1)` is a Heyting algebra on the concrete music topos.**
The subobject lattice of the terminal object — the lattice that
`birkhoff_representation` identifies (at the down-set level) with the music
algebra `Div12` — is realized here as a Heyting algebra on a bona-fide Lean
topos object, no longer merely cited from general topos theory. -/
theorem subTerminalHeytingAlgebra :
    Nonempty (HeytingAlgebra (Subobject (⊤_ MusicTopos))) := ⟨inferInstance⟩

/-! ## The central theorem fires on the concrete music topos -/

open FalseWork.Positions FalseWork.Positions.Examples

/-- **The four-position partition theorem typechecks and fires against the
concrete music presheaf topos.**  For the trivial distinction structure on
`Set^{Pᵒᵖ}` and any morphism with non-trivial `D`-image, the four cell
predicates partition it (exhaustively and pairwise-disjointly).

This is the bridge-note §5 / spine-note §5.1 deliverable — "wrap the topos
object so the abstract theorem typechecks against it directly."  The
distinction here is `trivialDistinction` (identity monad): the instantiation
witnesses that the central theorem *applies to the concrete topos object*;
over the trivial `Δ` the partition degenerates (every non-trivial morphism is
`IsInfrastructure`).  The non-degenerate, musically-loaded partition — with
the tritone as a non-regular kernel — is the lattice-level theorem
`lattice_four_position_partition` on `Div12`.  See this file's header for the
honest boundary. -/
theorem four_position_partition_musicTopos
    {X Y : MusicTopos} (f : X ⟶ Y)
    (h_nontriv :
      Subobject.mk (image.ι ((trivialDistinction MusicTopos).D.map f)) ≠ ⊥) :
    (IsInfrastructure (trivialDistinction MusicTopos) f ∨
        IsDistribution (trivialDistinction MusicTopos) f ∨
        IsExploitation (trivialDistinction MusicTopos) f ∨
        IsRefusal (trivialDistinction MusicTopos) f) ∧
      (IsInfrastructure (trivialDistinction MusicTopos) f →
        ¬ IsDistribution (trivialDistinction MusicTopos) f) ∧
      (IsInfrastructure (trivialDistinction MusicTopos) f →
        ¬ IsExploitation (trivialDistinction MusicTopos) f) ∧
      (IsInfrastructure (trivialDistinction MusicTopos) f →
        ¬ IsRefusal (trivialDistinction MusicTopos) f) ∧
      (IsDistribution (trivialDistinction MusicTopos) f →
        ¬ IsExploitation (trivialDistinction MusicTopos) f) ∧
      (IsDistribution (trivialDistinction MusicTopos) f →
        ¬ IsRefusal (trivialDistinction MusicTopos) f) ∧
      (IsExploitation (trivialDistinction MusicTopos) f →
        ¬ IsRefusal (trivialDistinction MusicTopos) f) :=
  four_position_partition (trivialDistinction MusicTopos) f h_nontriv

end Div12

end FalseWork.Lattice.Examples
