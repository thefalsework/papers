/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# The perceptron is a classical element; composition opens the four-fold

Bridge file between the four-position/ordinariness machinery and
threshold logic (Levin 2026, arXiv:2604.02476; *From Symbols to
Geometry*, Synthese 208:132).

A threshold unit's decision region is an open set, and the open sets of
any topological space form a Heyting algebra — so threshold devices are
literally elements of the algebras the four-position theorems quantify
over.  No analogy is involved.  This file computes where they sit:

1. **`coe_hnot` / `coe_hnot_hnot`** — in `Opens X`, Heyting negation is
   the interior of the set complement, and double negation is the
   interior of the closure.  (The classical facts, stated for the
   `Opens` frame so the project's `IsOrdinary` applies verbatim.)

2. **`unitAbove_regular` / `unitBelow_regular` / `unit_not_ordinary`** —
   a single threshold unit (`x > θ` or `x < θ`) is a *regular* element:
   `Uᶜᶜ = U`.  By `isOrdinary_iff_allFourCells`, no four-position
   structure opens around a lone perceptron.  This derives, rather than
   describes, the claim that the low-dimensional perceptron is a
   "logical device": its only undecidable locus is its own decision
   boundary, and double negation erases boundaries — the unit lives in
   the Boolean pocket.

3. **`composed_ordinary` / `composed_allFourCells`** — the composed
   decision region `(0 < x < 1) ∨ (1 < x < 2)`, a two-layer
   threshold circuit built inside the lattice from four units by
   `⊓`/`⊔`, is **ordinary**: neither regular nor dense.  The
   four-position partition around it is non-degenerate
   (`AllFourCellsInhabited`).  Composition is what first manufactures
   non-classicality.

4. **`composed_seam`** — the double-negation remainder of the composed
   region is exactly the phantom wall: `↑(Uᶜᶜ) \ ↑U = {1}`.  This is
   the locus invisible to every classical reduction — undecidable from
   inside, erased by the Boolean observer.  It is the algebraic form of
   the manifold-membership undecidability that Levin identifies as the
   hallucination mechanism.

**What is *not* claimed here [O]:** that the learned manifolds of real
generative models have substantial `¬¬`-remainder, and the corridor
conjecture (realizable regions regular below the Cover transition,
saturating toward density above it, ordinary only in between) are open.
This file is the checkable spine, not the interpretation.
-/
import Mathlib.Topology.Sets.Opens
import Mathlib.Topology.Order.Real
import Mathlib.Topology.Instances.Real.Lemmas
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import FalseWorkPapers.Examples.NishimuraKernelLaw

namespace FalseWork.Lattice

open TopologicalSpace Set

/-! ## Heyting negation in `Opens X` is interior-of-complement -/

section OpensHeyting

variable {X : Type*} [TopologicalSpace X]

/-- In the frame `Opens X`, the Heyting complement of `U` is the interior
of the set-complement of `U`. -/
theorem coe_hnot (U : Opens X) :
    ((Uᶜ : Opens X) : Set X) = interior ((U : Set X)ᶜ) := by
  apply subset_antisymm
  · -- `↑(Uᶜ)` is an open set disjoint from `↑U`, hence inside the interior
    -- of the complement.
    apply interior_maximal ?_ (Uᶜ : Opens X).isOpen
    have hd : (Uᶜ ⊓ U : Opens X) = ⊥ := disjoint_iff.mp disjoint_compl_left
    intro x hx hxU
    have hmem : x ∈ ((Uᶜ ⊓ U : Opens X) : Set X) := by
      rw [Opens.coe_inf]; exact ⟨hx, hxU⟩
    rw [hd, Opens.coe_bot] at hmem
    exact hmem
  · -- Conversely, `interior (↑U)ᶜ` is an open disjoint from `U`, so it lies
    -- below `Uᶜ` by the Galois connection.
    have hV : (⟨interior ((U : Set X)ᶜ), isOpen_interior⟩ : Opens X) ≤ Uᶜ := by
      rw [le_compl_iff_disjoint_right, disjoint_iff]
      apply Opens.ext
      simp only [Opens.coe_inf, Opens.coe_mk, Opens.coe_bot]
      apply Set.subset_empty_iff.mp
      rintro x ⟨hxi, hxU⟩
      exact absurd hxU (interior_subset hxi)
    simpa using hV

/-- In the frame `Opens X`, double Heyting negation is interior-of-closure:
the regularization operator. -/
theorem coe_hnot_hnot (U : Opens X) :
    ((Uᶜᶜ : Opens X) : Set X) = interior (closure (U : Set X)) := by
  rw [coe_hnot (Uᶜ), coe_hnot U, ← closure_eq_compl_interior_compl]

end OpensHeyting

/-! ## Threshold units on the real line -/

/-- A threshold unit firing above `θ`: decision region `x > θ`. -/
def unitAbove (θ : ℝ) : Opens ℝ := ⟨Set.Ioi θ, isOpen_Ioi⟩

/-- A threshold unit firing below `θ`: decision region `x < θ`. -/
def unitBelow (θ : ℝ) : Opens ℝ := ⟨Set.Iio θ, isOpen_Iio⟩

/-- **A single threshold unit is a regular element** — `Uᶜᶜ = U`.
The perceptron is classical: double negation heals its only
undecidable locus (the decision hyperplane itself). -/
theorem unitAbove_regular (θ : ℝ) : ((unitAbove θ)ᶜᶜ : Opens ℝ) = unitAbove θ := by
  apply Opens.ext
  rw [coe_hnot_hnot]
  show interior (closure (Set.Ioi θ)) = Set.Ioi θ
  rw [closure_Ioi, interior_Ici]

/-- The mirror unit is regular as well. -/
theorem unitBelow_regular (θ : ℝ) : ((unitBelow θ)ᶜᶜ : Opens ℝ) = unitBelow θ := by
  apply Opens.ext
  rw [coe_hnot_hnot]
  show interior (closure (Set.Iio θ)) = Set.Iio θ
  rw [closure_Iio, interior_Iic]

/-- **No four-fold opens around a lone perceptron**: a single threshold
unit is not ordinary (it is regular), so by
`isOrdinary_iff_allFourCells` the four-position partition around it is
degenerate. -/
theorem unit_not_ordinary (θ : ℝ) :
    ¬ IsOrdinary (unitAbove θ) ∧ ¬ IsOrdinary (unitBelow θ) :=
  ⟨fun h => h.1 (unitAbove_regular θ), fun h => h.1 (unitBelow_regular θ)⟩

/-! ## A composed threshold region is ordinary -/

/-- A two-layer threshold circuit, built inside the lattice from four
units: `(0 < x < 1) ∨ (1 < x < 2)`.  Two same-class cells glued along a
phantom wall at `x = 1`. -/
def composed : Opens ℝ :=
  (unitAbove 0 ⊓ unitBelow 1) ⊔ (unitAbove 1 ⊓ unitBelow 2)

theorem coe_composed :
    ((composed : Opens ℝ) : Set ℝ) = Set.Ioo 0 1 ∪ Set.Ioo 1 2 := by
  simp only [composed, unitAbove, unitBelow, Opens.coe_sup, Opens.coe_inf,
    Opens.coe_mk, Set.Ioi_inter_Iio]

/-- The regularization of the composed region fills the phantom wall:
`↑(composedᶜᶜ) = (0, 2)`. -/
theorem coe_composed_hnot_hnot :
    ((composedᶜᶜ : Opens ℝ) : Set ℝ) = Set.Ioo 0 2 := by
  rw [coe_hnot_hnot, coe_composed, closure_union,
    closure_Ioo (by norm_num : (0 : ℝ) ≠ 1),
    closure_Ioo (by norm_num : (1 : ℝ) ≠ 2),
    Set.Icc_union_Icc_eq_Icc (by norm_num : (0 : ℝ) ≤ 1)
      (by norm_num : (1 : ℝ) ≤ 2),
    interior_Icc]

/-- The composed region is **not regular**: its double negation strictly
exceeds it (the wall at `1` is recovered by `¬¬`). -/
theorem composed_not_regular : (composedᶜᶜ : Opens ℝ) ≠ composed := by
  intro h
  have h1 : (1 : ℝ) ∈ ((composedᶜᶜ : Opens ℝ) : Set ℝ) := by
    rw [coe_composed_hnot_hnot]
    constructor <;> norm_num
  rw [h, coe_composed] at h1
  rcases h1 with h1 | h1
  · exact absurd h1.2 (lt_irrefl 1)
  · exact absurd h1.1 (lt_irrefl 1)

/-- The composed region is **not dense**: its Heyting complement is
non-trivial (everything above `2`, below `0`). -/
theorem composed_not_dense : (composedᶜ : Opens ℝ) ≠ ⊥ := by
  intro h
  have h3 : (3 : ℝ) ∈ ((composedᶜ : Opens ℝ) : Set ℝ) := by
    rw [coe_hnot]
    refine mem_interior.mpr ⟨Set.Ioi 2, ?_, isOpen_Ioi, by norm_num⟩
    rw [coe_composed]
    rintro x (hx : (2 : ℝ) < x) (⟨_, h₂⟩ | ⟨_, h₂⟩) <;> linarith
  rw [h] at h3
  simp at h3

/-- **The composed threshold region is ordinary** — neither regular nor
dense.  Composition is the operation that first manufactures
non-classicality out of classical units. -/
theorem composed_ordinary : IsOrdinary composed :=
  ⟨composed_not_regular, composed_not_dense⟩

/-- **The four-position partition around the composed region is
non-degenerate**: all four cells (Infrastructure, Distribution,
Exploitation, Refusal) are inhabited.  A position space opens exactly
where the device stops being classical. -/
theorem composed_allFourCells : AllFourCellsInhabited composed :=
  (isOrdinary_iff_allFourCells composed).mp composed_ordinary

/-! ## The seam: the double-negation remainder is the phantom wall -/

/-- **The `¬¬`-remainder of the composed region is exactly the wall**:
`↑(composedᶜᶜ) \ ↑composed = {1}`.  The locus invisible to every
classical reduction of the world — undecidable from inside, erased by
the Boolean observer. -/
theorem composed_seam :
    ((composedᶜᶜ : Opens ℝ) : Set ℝ) \ ((composed : Opens ℝ) : Set ℝ) = {1} := by
  rw [coe_composed_hnot_hnot, coe_composed]
  ext x
  simp only [Set.mem_diff, Set.mem_Ioo, Set.mem_union, Set.mem_singleton_iff,
    not_or]
  constructor
  · rintro ⟨⟨h0, h2⟩, hn1, hn2⟩
    by_contra hne
    rcases lt_or_gt_of_ne hne with hlt | hgt
    · exact hn1 ⟨h0, hlt⟩
    · exact hn2 ⟨hgt, h2⟩
  · rintro rfl
    refine ⟨⟨by norm_num, by norm_num⟩, ?_, ?_⟩
    · rintro ⟨-, h⟩; exact lt_irrefl 1 h
    · rintro ⟨h, -⟩; exact lt_irrefl 1 h

end FalseWork.Lattice
