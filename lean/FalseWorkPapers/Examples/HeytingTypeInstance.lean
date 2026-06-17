/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink
-/
import FalseWorkPapers.Heyting.SubobjectInstance
import FalseWorkPapers.Positions
import FalseWorkPapers.Lattice.FourPositionLattice
import FalseWorkPapers.Examples.CanonizationGeneratorInstance
import FalseWorkPapers.Examples.DivisorLattice12
import FalseWorkPapers.Examples.DivisorLattice12Distinction
import FalseWorkPapers.Examples.DivisorLattice12Birkhoff
import FalseWorkPapers.Examples.DivisorLattice12Nucleus
import FalseWorkPapers.Examples.DiophantineFloor
import FalseWorkPapers.Examples.MathFloorCantor
import FalseWorkPapers.Examples.NishimuraTruncations
import FalseWorkPapers.Examples.NishimuraKernelLaw
import FalseWorkPapers.Examples.NishimuraNormalForm
import FalseWorkPapers.Examples.UniqueOrdinaryConverse
import FalseWorkPapers.Examples.Z6PlusChain3
import FalseWorkPapers.Examples.GlivenkoCollapse
import FalseWorkPapers.Examples.LadderCore
import FalseWorkPapers.Examples.WhyTwelve
import FalseWorkPapers.Examples.MusicKernelZMod12
import FalseWorkPapers.Examples.MusicKernelIrrationality
import FalseWorkPapers.Examples.MusicKernelEndofunctor
import FalseWorkPapers.Examples.PythagoreanComma
import FalseWorkPapers.Examples.MusicTopos
import FalseWorkPapers.Examples.MusicToposSub
import FalseWorkPapers.Examples.MusicToposTrace

/-!
# Sanity-check examples for `FalseWork.Heyting.heytingAlgebra`

This file is a smoke test for the universal `HeytingAlgebra (Subobject X)`
instance constructed in `FalseWorkPapers.Heyting.SubobjectInstance`.  It
contains no theorems used elsewhere in the project; its sole purpose is to
exhibit that Lean's typeclass resolution finds the instance and that the
constructed implication behaves Heyting-correctly, giving a
reader/reviewer immediate confidence that the construction is wired right.

Phase 4 prep for the upstream Mathlib PR (`MATHLIB-PR-DRAFT.md`).  A
concrete-topos instantiation (`PUnitᵒᵖ ⥤ Type`) was attempted here but is
blocked by a universe / `InitialMonoClass` resolution gap in Mathlib's
presheaf-category instances (not a problem with our construction — the
universal instance resolves cleanly the moment the bundle is in scope).
That gap is the kind of plumbing issue the upstream PR review will surface
naturally; for now, the abstract examples below are sufficient to verify
that the instance exists and that its Galois behaviour is the expected one.
-/

namespace FalseWork.Heyting.Examples

open CategoryTheory CategoryTheory.Limits

/-- Smoke test 1.  Under the elementary-topos hypothesis bundle, the
Heyting-algebra instance on `Subobject X` resolves via typeclass search. -/
noncomputable example {C : Type*} [Category C]
    [HasSubobjectClassifier C] [HasPullbacks C] [HasEqualizers C]
    [HasInitial C] [HasImages C] [HasBinaryCoproducts C]
    [InitialMonoClass C] {X : C} :
    HeytingAlgebra (Subobject X) := inferInstance

/-- Smoke test 2.  The Galois connection holds (a direct consumer of the
typeclass: `le_himp_iff`). -/
example {C : Type*} [Category C]
    [HasSubobjectClassifier C] [HasPullbacks C] [HasEqualizers C]
    [HasInitial C] [HasImages C] [HasBinaryCoproducts C]
    [InitialMonoClass C] {X : C} (P Q : Subobject X) :
    (P ⇨ Q) ⊓ P ≤ Q := by
  rw [← le_himp_iff]

/-- Smoke test 3.  The pseudo-complement is the residual against `⊥`
(definitionally — `himp_bot := rfl` in the instance). -/
example {C : Type*} [Category C]
    [HasSubobjectClassifier C] [HasPullbacks C] [HasEqualizers C]
    [HasInitial C] [HasImages C] [HasBinaryCoproducts C]
    [InitialMonoClass C] {X : C} (P : Subobject X) :
    Pᶜ = P ⇨ ⊥ := rfl

/-- Smoke test 4.  De Morgan and `aᶜᶜ`-style consequences fall out from the
typeclass without further hypotheses. -/
example {C : Type*} [Category C]
    [HasSubobjectClassifier C] [HasPullbacks C] [HasEqualizers C]
    [HasInitial C] [HasImages C] [HasBinaryCoproducts C]
    [InitialMonoClass C] {X : C} (P : Subobject X) :
    P ≤ Pᶜᶜ := le_compl_compl

end FalseWork.Heyting.Examples

/-! ## Kernel-axiomatic-dependence audit

Empirical verification that `four_position_partition` does not
transitively depend on `sorry`.  `#print axioms` exposes the full
axiom set the Lean kernel needs to accept the theorem; if `sorryAx`
appears in the output, the theorem is not kernel-checked in the
strict sense (some link in its dependency chain is `sorry`).

The expected output is exactly the three standard Mathlib axioms
(`propext`, `Classical.choice`, `Quot.sound`).  If `sorryAx` appears,
this audit fails and the four-position-partition status claim must
be retracted.
-/

#print axioms FalseWork.Positions.four_position_partition
#print axioms FalseWork.Positions.isRefusal_iff_image_le_compl
#print axioms FalseWork.Heyting.heytingAlgebra
#print axioms FalseWork.Heyting.le_residual_iff_inf_le
#print axioms FalseWork.Positions.isDistribution_implies_neither_polar
#print axioms FalseWork.Positions.exploitation_refusal_disjoint
#print axioms FalseWork.Positions.trivialized_implies_isInfrastructure
#print axioms FalseWork.Positions.refusal_residue

/-! Spencer-Brown anchor (companion to
`preprints/four-position-partition/spencer-brown-anchor.md`).
Both audit lines must report only the standard three axioms. -/
#print axioms FalseWork.Positions.boolean_partition_three_cells
#print axioms FalseWork.Positions.DistinctionStructure.ofIdempotentMonad

/-! Canonization closure (companion to
`preprints/four-position-partition/closure-canonization.md`).
The conditional recursive partition theorem and the conditional
separation theorem must report only the standard three axioms. -/
#print axioms FalseWork.Positions.recursive_partition
#print axioms FalseWork.Positions.canonization_separation

/-! Concrete instantiation of `CanonizationGenerator`
(companion to `Examples/CanonizationGeneratorInstance.lean`).  The
worked-example witness and its application of `canonization_separation`
must report only the standard three axioms.  These audit lines close
the "concrete instantiation" item from the framework's status ledger;
the structure type is now demonstrably inhabited and the conditional
separation theorem fires on a kernel-checked concrete witness. -/
#print axioms FalseWork.Positions.Examples.DiscretePUnit.canonizationGenerator
#print axioms FalseWork.Positions.Examples.DiscretePUnit.separation_example

/-! Cross-layer alignment (Commitment-yes ⇒ canonization-generator
witness; companion to `preprints/four-position-partition/closure-
canonization.md` §8b).  The conditional cross-layer definition and
its propositional companion must report only the standard three
axioms.  These audit lines close the cross-layer architectural item
from the framework's status ledger: the connection between the
Commitment gate and the canonization closure-and-generator layer is
now formally recorded at the type level. -/
#print axioms FalseWork.Positions.CanonizationGenerator.ofCommitmentYes
#print axioms FalseWork.Positions.commitment_yes_admits_canonization_generator

/-! Layer-L lattice-level four-position partition (companion to
`FalseWorkPapers.Lattice.FourPositionLattice` and
`preprints/four-position-partition/music-anchor/feasibility.md` §12).
The abstract Heyting-algebra theorem and the concrete divisor-lattice-
of-12 music-anchor witness must report only the standard three axioms.
These audit lines close the Layer-L item of the music anchor: the
four-position partition is now kernel-checked at the lattice level
on a Heyting algebra isomorphic to the subgroup lattice of `Z/12`. -/
#print axioms FalseWork.Lattice.lattice_four_position_partition
#print axioms FalseWork.Lattice.Examples.Div12.heytingAlgebra
#print axioms FalseWork.Lattice.Examples.Div12.tritone_non_regular
#print axioms FalseWork.Lattice.Examples.Div12.music_anchor_witness

/-! Layer-D distinction operator and the literal `Z/12` realization
(companion to `Examples/DivisorLattice12Distinction.lean` and
`preprints/four-position-partition/music-anchor/feasibility.md` §12.6).
The closure-operator "distinction slice" — whose kernel image
`tritoneClosure ⊥` is the tritone, de-arbitrarizing the kernel used by
`music_anchor_witness` — and the kernel-checked correspondence between
the six divisor-lattice elements and the six transposition-symmetric
pitch-class subgroups of `Z/12` must report only the standard three
axioms. -/
#print axioms FalseWork.Lattice.Examples.Div12.tritoneClosure_is_distinction_slice
#print axioms FalseWork.Lattice.Examples.Div12.tritoneClosure_bot
#print axioms FalseWork.Lattice.Examples.Div12.tritoneClosure_bot_non_regular
#print axioms FalseWork.Lattice.Examples.Div12.pcset_realizes_subgroup_lattice
#print axioms FalseWork.Lattice.Examples.Div12.pcset_tritoneClosure_bot

/-! Birkhoff representation of the music lattice (companion to
`Examples/DivisorLattice12Birkhoff.lean` and the T2 construction of
`music-anchor/mazzola-bridge-note.md` §5).  The divisor lattice of 12 is
realized as the lattice of down-sets of its poset of join-irreducibles,
i.e. `Sub_{Set^{Pᵒᵖ}}(1)` of a concrete presheaf topos built from the
symmetric pitch-class generators of `Z/12`. -/
#print axioms FalseWork.Lattice.Examples.Div12.birkhoff_representation
#print axioms FalseWork.Lattice.Examples.Div12.birkhoff_tritoneKernel

/-! The tritone kernel as a Lawvere–Tierney topology (companion to
`Examples/DivisorLattice12Nucleus.lean`).  A nucleus on the T2 topos with
the tritone as its non-regular kernel exists; the minimal tritone-closing
closure operator is *not* a nucleus — the reflective vs. geometric lifts
of the same kernel. -/
#print axioms FalseWork.Lattice.Examples.Div12.tritone_kernel_has_lawvere_tierney_realization
#print axioms FalseWork.Lattice.Examples.Div12.tritoneClosure_not_nucleus

/-! The shared Diophantine floor (companion to `Examples/DiophantineFloor.lean`
and Paper 5).  Rank-1 (`√2` irrational) and rank-2 (`2`–`3` multiplicative
independence / the Pythagorean comma) as the two faces of unique
factorization. -/
#print axioms FalseWork.Diophantine.shared_diophantine_floor

/-! The mathematics floor: the diagonal as Level-0 comma (companion to
`Examples/MathFloorCantor.lean`, math anchor Phase 1).  The diagonal residue
(`diagonal_escapes`), Cantor non-surjection (handed over by Mathlib), and the
Lawvere fixed-point unification (Cantor as a fixed-point obstruction) must
report only the standard three axioms.  Structural identification with the
FalseWork comma is prose, not theorem. -/
#print axioms FalseWork.MathFloor.mathematics_floor
#print axioms FalseWork.MathFloor.lawvere_fixedPoint
#print axioms FalseWork.MathFloor.diagonal_escapes

/-! Rieger–Nishimura truncations (companion to
`Examples/NishimuraTruncations.lean`, math anchor Phases 2–4).  The forced-
kernel experiment on the canonical finite truncations `Z_n` of the free
Heyting algebra on one generator, pre-registered in
`validation/claims/math-anchor-cantor-floor.md`.  Result: outcome (A) —
unique truncation-stable kernel = the free generator at `n = 6, 7, 8`, no
kernel at `n = 5`; and `Div12 ≅ Z_6` (the music lattice is one-generated by
the tritone).  All lines must report only the standard axioms. -/
#print axioms FalseWork.Lattice.Examples.rn_truncation_outcome_A
#print axioms FalseWork.Lattice.Examples.Div12.one_generated_by_tritone
#print axioms FalseWork.Lattice.Examples.Div12.kernel_unique
#print axioms FalseWork.Lattice.Examples.Z7.kernel_unique
#print axioms FalseWork.Lattice.Examples.Z7.witness
#print axioms FalseWork.Lattice.Examples.Z8.kernel_unique
#print axioms FalseWork.Lattice.Examples.Z8.witness
#print axioms FalseWork.Lattice.Examples.Z5.no_kernel

/-! The all-n kernel law (companion to `Examples/NishimuraKernelLaw.lean`).
The abstract upgrade of outcome (A): in any Heyting algebra all four cells
are inhabited at `a` iff `a` is non-zero, non-polar, non-regular
(`allFourCellsInhabited_iff`); and in any Heyting algebra whose elements
are Nishimura term values in an ordinary generator `g`, the unique
four-cell kernel is `g` (`nishimura_kernel_unique`).  Conditional only on
the classical Nishimura enumeration [C], this covers every truncation
`Z_n` and the full Rieger–Nishimura lattice.  `Div12.kernel_unique_via_law`
re-derives the tritone result from the law (hypothesis discharged inside
Lean) — the consistency weld with the exhaustive `decide` proof. -/
#print axioms FalseWork.Lattice.allFourCellsInhabited_iff
#print axioms FalseWork.Lattice.four_le_nishimuraTerm
#print axioms FalseWork.Lattice.nishimura_kernel_unique
#print axioms FalseWork.Lattice.Examples.Div12.nishimura_generated
#print axioms FalseWork.Lattice.Examples.Div12.kernel_unique_via_law

/-! Ordinary-element form (the algebraic statement, as posed for prior-art
adjudication): ordinary ⟺ non-degenerate kernel
(`isOrdinary_iff_allFourCells`); a Nishimura-generated algebra with
ordinary generator has that generator as its **unique ordinary element**
(`nishimura_ordinary_unique`); unconditional exhaustive checks at
`n = 6, 7, 8`. -/
#print axioms FalseWork.Lattice.isOrdinary_iff_allFourCells
#print axioms FalseWork.Lattice.nishimura_ordinary_unique
#print axioms FalseWork.Lattice.Examples.Div12.ordinary_unique
#print axioms FalseWork.Lattice.Examples.Z7.ordinary_unique
#print axioms FalseWork.Lattice.Examples.Z8.ordinary_unique

/-! The converse of the all-n law is FALSE (companion to
`Examples/UniqueOrdinaryConverse.lean`; pre-registered in
`validation/claims/unique-ordinary-structure.md`).  `H8` — the 8-element
downset lattice of `{0<1<3<4, 2<3}`, found minimal by exhaustive
enumeration ≤ 12 [C] — has a unique ordinary element `a` but is not
Nishimura-generated by it: the seven elements `≠ d` are a closed
subalgebra (`nishimuraTerm_mem_of_closed`).  The salvage lemma
(`unique_ordinary_dense_iff`): unique ordinariness pins the dense
elements to the filter `↑(a ⊔ ¬a)`, in any Heyting algebra. -/
#print axioms FalseWork.Lattice.nishimuraTerm_mem_of_closed
#print axioms FalseWork.Lattice.unique_ordinary_dense_iff
#print axioms FalseWork.Lattice.Examples.H8.ordinary_unique
#print axioms FalseWork.Lattice.Examples.H8.kernel_unique
#print axioms FalseWork.Lattice.Examples.H8.dense_filter
#print axioms FalseWork.Lattice.Examples.H8.not_nishimura_generated
#print axioms FalseWork.Lattice.Examples.unique_ordinary_converse_false

/-! Citkin gluing `Z_6 + Z_3 ≅ H8` (companion to `Examples/Z6PlusChain3.lean`;
registered in `validation/claims/unique-ordinary-structure.md` §4c).  Names
the expert construction; upgrades identification from [C] to [K]. -/
#print axioms FalseWork.Lattice.Examples.Z6PlusChain3.isoH8
#print axioms FalseWork.Lattice.Examples.Z6PlusChain3.z6_plus_chain3_eq_h8
#print axioms FalseWork.Lattice.Examples.Z6PlusChain3.fromDiv12_map_le

/-! The ladder core (companion to `Examples/LadderCore.lean`; pre-registered
in `validation/claims/ladder-core-threshold.md`).  The kernel-checkable
fragment of Citkin's Prop. 3.1 weld: the universal six-element threshold
(any Heyting algebra with an ordinary element / non-degenerate kernel has
≥ 6 elements — abstract, no enumeration, generalizing Citkin 2024
Prop. 4(c)); the music lattice `Div12 = Z_6` order-embeds into every
non-degenerate instance; `H8`'s ladder core is `Z_7` (Heyting embedding
with range exactly `≠ d`); the tritone is the unique generator of the
music lattice; and the dense-bottom lemma (least nonzero element ⟹ no
ordinary elements; `P2 ≅ 2 + Z_7` carries no kernel). -/
#print axioms FalseWork.Lattice.ladderEmbed_le_iff
#print axioms FalseWork.Lattice.div12OrderEmbedding
#print axioms FalseWork.Lattice.ordinary_card_ge_six
#print axioms FalseWork.Lattice.allFourCells_card_ge_six
#print axioms FalseWork.Lattice.Z5.no_kernel_via_threshold
#print axioms FalseWork.Lattice.no_ordinary_of_least_nonzero
#print axioms FalseWork.Lattice.Examples.h8_ladder_core
#print axioms FalseWork.Lattice.Examples.nishimuraTerm_a_mem_core
#print axioms FalseWork.Lattice.Examples.Div12.generator_unique

/-! The Glivenko collapse (companion to `Examples/GlivenkoCollapse.lean`).
No Boolean algebra has an ordinary element or a non-degenerate kernel;
the double-negation reflection `a ↦ ¬¬a` lands every element of any
Heyting algebra on a non-ordinary one; and the Boolean algebra of regular
elements (Glivenko, Mathlib `Heyting.Regular`) carries no four-cell
kernel at all.  The four positions do not survive passage to the
classical shadow. -/
#print axioms FalseWork.Lattice.boolean_no_ordinary
#print axioms FalseWork.Lattice.boolean_no_kernel
#print axioms FalseWork.Lattice.not_isOrdinary_compl_compl
#print axioms FalseWork.Lattice.glivenko_no_kernel
#print axioms FalseWork.Lattice.glivenko_collapse

/-! Why 12 (companion to `Examples/WhyTwelve.lean`).  The arithmetic side
of the music–logic weld: on the divisor lattices of the equal temperaments
`ℤ/n` (products of chains, one per prime), chains never carry a four-cell
kernel (all prime powers, abstract); squarefree `pq` never does; a kernel
exists iff some exponent is ≥ 2 and is unique iff `n = p²q` — least
instance 12 — where, under the explicit Heyting iso `Div12 ≃o C₃ × C₂`,
the unique kernel is the tritone.  Boundary failures kernel-checked at
24, 36, 60.  All lines must report only the standard axioms. -/
#print axioms FalseWork.Lattice.total_no_kernel
#print axioms FalseWork.Lattice.prod_kernel_iff
#print axioms FalseWork.Lattice.Examples.chainProd_kernel_exists_iff
#print axioms FalseWork.Lattice.Examples.chainProd_kernel_unique_iff
#print axioms FalseWork.Lattice.Examples.twelve_kernel_unique
#print axioms FalseWork.Lattice.Examples.twentyfour_kernel_two
#print axioms FalseWork.Lattice.Examples.sixty_kernel_three
#print axioms FalseWork.Lattice.Examples.Div12.toChains_himp
#print axioms FalseWork.Lattice.Examples.Div12.div12OrderIsoChains
#print axioms FalseWork.Lattice.Examples.why_twelve

/-! The music kernel "The Fifth" on `ℤ/12` (companion to
`Examples/MusicKernelZMod12.lean` and `music-kernel-05-z12z-cycle.md`).
The circle of fifths closes in the tempered quotient — the complement of
the rank-2 Diophantine non-closure. -/
#print axioms FalseWork.MusicKernel.fifth_closes_in_quotient

/-! Music-kernel Point 1: irrationality of `log₂(3/2)` (companion to
`Examples/MusicKernelIrrationality.lean` and
`validation/claims/music-kernel-01-irrationality.md`).  FTA-elementary;
closes via `DiophantineFloor.rank_two_floor`. -/
#print axioms FalseWork.MusicKernel.log_two_three_irrational
#print axioms FalseWork.MusicKernel.log_three_halves_irrational
#print axioms FalseWork.MusicKernel.pythagorean_comma_log_nonzero
#print axioms FalseWork.MusicKernel.music_kernel_irrationality

/-! Pythagorean-comma convergent scaffold (companion to
`Examples/PythagoreanComma.lean`, `Examples/MusicKernelLogBounds.lean`,
`Examples/MusicKernelCfFloors.lean`, and
`validation/claims/optimal-ntet-continued-fraction.md`).  Phase 1 denominators
through `qConv_first_six` are kernel-checked from certified log bounds. -/
#print axioms FalseWork.Pythagorean.α_eq_musicKernel
#print axioms FalseWork.Pythagorean.α_lt_one
#print axioms FalseWork.Pythagorean.α_irrational
#print axioms FalseWork.Pythagorean.qConv_zero
#print axioms FalseWork.Pythagorean.qConv_first_six
#print axioms FalseWork.Pythagorean.convergent_best_approx_second_kind
#print axioms FalseWork.Pythagorean.best_tet_iff_record_convergent_denominator

/-! Music-kernel endofunctor Points 2–3 (companion to
`Examples/MusicKernelEndofunctor.lean`). -/
#print axioms FalseWork.MusicKernel.music_kernel_endofunctor_points_two_three

/-! The music presheaf topos `Set^{Pᵒᵖ}` as a concrete Lean elementary-topos
object (companion to `Examples/MusicTopos.lean` and the T2 construction of
`music-anchor/mazzola-bridge-note.md` §5 / `connecting-the-spine.md` §5.1).
The previously-deferred "topos-object plumbing": the full elementary-topos
hypothesis bundle resolves for the concrete music-derived presheaf topos, so
`Sub_{Set^{Pᵒᵖ}}(1)` is a Heyting algebra and the central theorem
`four_position_partition` fires against the concrete topos object (over the
trivial distinction — the non-degenerate musical partition is the
lattice-level theorem). -/
#print axioms FalseWork.Lattice.Examples.Div12.musicTopos_isElementaryTopos
#print axioms FalseWork.Lattice.Examples.Div12.subTerminalHeytingAlgebra
#print axioms FalseWork.Lattice.Examples.Div12.four_position_partition_musicTopos

/-! `Sub_{Set^{Pᵒᵖ}}(1) ≅ Div12` as a Mathlib-level order isomorphism
(companion to `Examples/MusicToposSub.lean`).  This upgrades
`birkhoff_representation` from the down-set level `O(P)` to an isomorphism of
the actual `Subobject` lattice of the terminal object of the concrete music
topos, mapping the subobject lattice cells onto the named pitch-class objects of
`Div12`.  Item (i) of `connecting-the-spine.md` §5.1a. -/
#print axioms FalseWork.Lattice.Examples.Div12.subobjectTerminalEquivDiv12
#print axioms FalseWork.Lattice.Examples.Div12.fromDownset_birkhoff

/-! The topos-level **trace-collapse** result (companion to
`Examples/MusicToposTrace.lean`).  The four-position kernel `kernelImage Δ Y` is
`Im(η.app Y)`; an iso unit forces it to `⊤`.  Since the terminal presheaf is a
sheaf for every topology, every sheafification monad has iso unit at `1`, so the
tritone nucleus (`⟨6⟩ ≠ ⊤`) does *not* lift to `kernelImage Δ 1` — the
lattice-level nucleus and the topos-level `Im(η)` kernel come apart at `1`.
Item (ii) of `connecting-the-spine.md` §5.1a, resolved as a category error in
the naïve form (the non-degenerate tritone partition stays lattice-level). -/
#print axioms FalseWork.Positions.kernelImage_eq_top_of_isIso_unit
#print axioms FalseWork.Positions.isInfrastructure_of_isIso_unit

/-! Nishimura normal form — Phase 1 (companion to
`Examples/NishimuraNormalForm.lean`; active spine target in
`validation/claims/nishimura-normal-form.md`).  Ladder-set closure lemmas:
the complement table, and the two **definitional diagonals** read off the
term recursion (`xₙ₊₂ ⊔ xₙ₊₃ = xₙ₊₅` for `n` odd; `xₙ₊₃ ⇨ xₙ₊₂ = xₙ₊₅` for
`n` even) that anchor the forthcoming off-diagonal induction.  Gate-checked
clean **before** any multi-week induction is built on top of them — they must
report only the standard axioms. -/
#print axioms FalseWork.Lattice.compl_nishimuraTerm_ge_four
#print axioms FalseWork.Lattice.isLadderValue_compl
#print axioms FalseWork.Lattice.isLadderValue_compl_of
#print axioms FalseWork.Lattice.nishimuraTerm_join_diagonal
#print axioms FalseWork.Lattice.nishimuraTerm_himp_diagonal
#print axioms FalseWork.Lattice.isLadderValue_join_diagonal
#print axioms FalseWork.Lattice.isLadderValue_himp_diagonal

/-! Nishimura normal form — Phase 2: the positive order characterisation and
the join/meet tables.  `nishimuraTerm_le_of` is the positive Rieger–Nishimura
order (`xₐ ≤ x_b` for the parity/offset comparabilities); `isLadderValue_sup`
and `isLadderValue_inf` close the ladder set under `⊔` and `⊓` — the join and
meet tables, end to end, with the incomparable diagonals proved from the
recursion (no `decide`, hence no collapse-artifact exposure).  These become
load-bearing for the implication table, so gate-check them clean here. -/
#print axioms FalseWork.Lattice.nishimuraTerm_even_le_add_two
#print axioms FalseWork.Lattice.nishimuraTerm_even_le_succ
#print axioms FalseWork.Lattice.nishimuraTerm_odd_le_add_three
#print axioms FalseWork.Lattice.nishimuraTerm_le_of
#print axioms FalseWork.Lattice.nishimuraTerm_join_adjacent
#print axioms FalseWork.Lattice.nishimuraTerm_join_skip
#print axioms FalseWork.Lattice.isLadderValue_sup
#print axioms FalseWork.Lattice.nishimuraTerm_meet_adjacent
#print axioms FalseWork.Lattice.nishimuraTerm_meet_skip
#print axioms FalseWork.Lattice.isLadderValue_inf

/-! Nishimura normal form — Phase 3 (in progress): the implication table.  All
relations are proved (kernel-checked); the terminal cell families and the two
structural reductions are below.  A wrong implication relation cannot typecheck,
so these gate-check the table's correctness ahead of the final well-founded
assembly. -/
#print axioms FalseWork.Lattice.nishimuraTerm_himp_eq_top_of_le
#print axioms FalseWork.Lattice.nishimuraTerm_himp_one
#print axioms FalseWork.Lattice.nishimuraTerm_odd_eq_himp
#print axioms FalseWork.Lattice.nishimuraTerm_even_eq_meet
#print axioms FalseWork.Lattice.isLadderValue_himp_odd
#print axioms FalseWork.Lattice.isLadderValue_himp_even
#print axioms FalseWork.Lattice.nishimuraTerm_himp_succ_odd
