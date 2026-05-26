/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# Lattice-level four-position partition (Layer L)

The Heyting-algebra core of `FalseWork.Positions.four_position_partition`.

The topos-level theorem partitions morphisms `f : X ⟶ Y` based on the
position of `Im(D.map f) ∈ Sub(D Y)` relative to the kernel image
`Im(η_Y) ∈ Sub(D Y)`.  The argument is entirely Heyting-algebraic:
the topos-side machinery (image factorisation, `kernelImage`) only
delivers the two participating subobjects; once they exist, the
partition is a fact about Heyting algebras.

This file isolates that fact.  For any `HeytingAlgebra H`, a chosen
`a : H` (playing the role of the kernel image), and any `x : H` with
`x ≠ ⊥`, exactly one of four conditions holds:

* `x ≤ a`                       (`IsLatticeInfrastructure`)
* `x ⊓ a ≠ ⊥ ∧ x ⊓ aᶜ ≠ ⊥`     (`IsLatticeDistribution`)
* `x ≤ aᶜᶜ ∧ ¬ x ≤ a`          (`IsLatticeExploitation`)
* `x ≤ aᶜ`                      (`IsLatticeRefusal`)

This is **Layer L** of the four-position framework: the partition at
the lattice level, prior to any topos or distinction-structure
instantiation.

## Relation to the topos-level theorem

`FalseWork.Positions.four_position_partition` is Layer L applied to
`H = Subobject (D Y)` with `a = kernelImage Δ Y` and `x = img(D.map f)`,
plus the equivalence `IsRefusal Δ f ↔ img(D.map f) ≤ aᶜ` that connects
the factorisation-based `IsRefusal` to the subobject-containment
form.  The Heyting-algebra reasoning is identical; this file makes
that reasoning available without the topos-side scaffolding.

## Relation to the music anchor

The music anchor (`preprints/four-position-partition/music-anchor/`)
instantiates Layer L on the divisor lattice of 12 — equivalently the
subgroup lattice of `Z/12`, equivalently the lattice of
transposition-symmetric pitch-class subsets of `Z/12`.  See
`FalseWorkPapers.Examples.DivisorLattice12` for the concrete
inhabitation and `wolfram/music-anchor/four-position-music-v3-path-b.wl`
for the computational companion.

## Main results

* `lattice_four_position_partition` — exhaustive + pairwise disjoint
  partition of `H ∖ {⊥}` into the four cells, parameterised by a
  chosen `a : H`.
-/
import Mathlib.Order.Heyting.Basic

namespace FalseWork.Lattice

variable {H : Type*} [HeytingAlgebra H]

/-! ## The four lattice-level position predicates -/

/-- **Infrastructure.** `x` lies in the kernel: `x ≤ a`. -/
def IsLatticeInfrastructure (a x : H) : Prop := x ≤ a

/-- **Refusal.** `x` lies in the Heyting complement of the kernel: `x ≤ aᶜ`. -/
def IsLatticeRefusal (a x : H) : Prop := x ≤ aᶜ

/-- **Exploitation.** `x` lies in the closure-residue: `x ≤ aᶜᶜ` and `x ⊄ a`.

This region is empty in Boolean algebras (where `aᶜᶜ = a`) and non-empty
exactly when the Heyting algebra is non-Boolean at `a`. -/
def IsLatticeExploitation (a x : H) : Prop :=
  x ≤ aᶜᶜ ∧ ¬ x ≤ a

/-- **Distribution.** `x` straddles the kernel and its complement non-trivially:
both `x ⊓ a` and `x ⊓ aᶜ` are non-zero. -/
def IsLatticeDistribution (a x : H) : Prop :=
  (x ⊓ a ≠ ⊥) ∧ (x ⊓ aᶜ ≠ ⊥)

/-! ## The lattice-level partition theorem -/

/-- **Lattice-level four-position partition (Layer L).**

Let `H` be a Heyting algebra and `a x : H`.  If `x ≠ ⊥`, then exactly
one of the four predicates `IsLatticeInfrastructure`,
`IsLatticeDistribution`, `IsLatticeExploitation`, `IsLatticeRefusal`
holds at `(a, x)`.

The proof is a classical case-split on `x ≤ a`, `x ⊓ a = ⊥`,
`x ⊓ aᶜ = ⊥`, with each pairwise-disjointness clause reducing to a
standard Heyting identity. -/
theorem lattice_four_position_partition (a x : H) (hx : x ≠ ⊥) :
    (IsLatticeInfrastructure a x ∨ IsLatticeDistribution a x ∨
      IsLatticeExploitation a x ∨ IsLatticeRefusal a x) ∧
    (IsLatticeInfrastructure a x → ¬ IsLatticeDistribution a x) ∧
    (IsLatticeInfrastructure a x → ¬ IsLatticeExploitation a x) ∧
    (IsLatticeInfrastructure a x → ¬ IsLatticeRefusal a x) ∧
    (IsLatticeDistribution a x → ¬ IsLatticeExploitation a x) ∧
    (IsLatticeDistribution a x → ¬ IsLatticeRefusal a x) ∧
    (IsLatticeExploitation a x → ¬ IsLatticeRefusal a x) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · -- EXHAUSTIVENESS.  Case-split on `x ≤ a`, then on the two
    -- non-triviality flags `x ⊓ a = ⊥` and `x ⊓ aᶜ = ⊥`.
    by_cases h1 : x ≤ a
    · exact Or.inl h1
    · by_cases h2 : x ⊓ a = ⊥
      · -- `x ⊓ a = ⊥` ⟹ `x ≤ aᶜ` (Galois connection).
        refine Or.inr (Or.inr (Or.inr ?_))
        show x ≤ aᶜ
        rw [le_compl_iff_disjoint_right, disjoint_iff]
        exact h2
      · by_cases h3 : x ⊓ aᶜ = ⊥
        · -- `x ⊓ aᶜ = ⊥` ⟹ `x ≤ aᶜᶜ`; combined with `¬ x ≤ a` ⟹ Exploitation.
          refine Or.inr (Or.inr (Or.inl ⟨?_, h1⟩))
          rw [le_compl_iff_disjoint_right, disjoint_iff]
          exact h3
        · exact Or.inr (Or.inl ⟨h2, h3⟩)
  · -- Infrastructure → ¬ Distribution.  `x ≤ a` forces
    -- `x ⊓ aᶜ ≤ a ⊓ aᶜ = ⊥`, contradicting Distribution's 2nd clause.
    intro hInfra ⟨_, h_dist_hi⟩
    exact h_dist_hi (hInfra.disjoint_compl_right.eq_bot)
  · -- Infrastructure → ¬ Exploitation.  Exploitation's 2nd clause is `¬ x ≤ a`.
    intro hInfra ⟨_, h_neg⟩
    exact h_neg hInfra
  · -- Infrastructure → ¬ Refusal.  Combining `x ≤ a` with `x ≤ aᶜ`
    -- gives `x ≤ a ⊓ aᶜ = ⊥`, contradicting `x ≠ ⊥`.
    intro hInfra hRef
    apply hx
    exact le_bot_iff.mp ((le_inf hInfra hRef).trans (inf_compl_self a).le)
  · -- Distribution → ¬ Exploitation.  `x ≤ aᶜᶜ` forces
    -- `x ⊓ aᶜ ≤ aᶜᶜ ⊓ aᶜ = ⊥`, contradicting Distribution's 2nd clause.
    intro ⟨_, h_dist_hi⟩ ⟨hClos, _⟩
    apply h_dist_hi
    exact le_bot_iff.mp ((inf_le_inf_right _ hClos).trans (compl_inf_self aᶜ).le)
  · -- Distribution → ¬ Refusal.  `x ≤ aᶜ` forces
    -- `x ⊓ a ≤ aᶜ ⊓ a = ⊥`, contradicting Distribution's 1st clause.
    intro ⟨h_dist_lo, _⟩ hRef
    apply h_dist_lo
    exact le_bot_iff.mp ((inf_le_inf_right _ hRef).trans (compl_inf_self a).le)
  · -- Exploitation → ¬ Refusal.  Combining `x ≤ aᶜᶜ` with `x ≤ aᶜ`
    -- gives `x ≤ aᶜ ⊓ aᶜᶜ = ⊥`, contradicting `x ≠ ⊥`.
    intro ⟨hClos, _⟩ hRef
    apply hx
    exact le_bot_iff.mp ((le_inf hRef hClos).trans (inf_compl_self aᶜ).le)

/-! ## Convenience: an `ExactlyOne` form of the partition

The partition above expresses exhaustiveness and pairwise disjointness
as a conjunction.  Some downstream uses want the "exactly one" packaging
explicitly. -/

/-- Exactly-one form of the partition: there exists a unique cell among
the four such that the corresponding predicate holds. -/
theorem lattice_four_position_exists_unique (a x : H) (hx : x ≠ ⊥) :
    (IsLatticeInfrastructure a x ∨ IsLatticeDistribution a x ∨
      IsLatticeExploitation a x ∨ IsLatticeRefusal a x) :=
  (lattice_four_position_partition a x hx).1

end FalseWork.Lattice
