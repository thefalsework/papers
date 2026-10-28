/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# XOR is classical: Minsky–Papert's line is not the regularity line

Companion to `PerceptronRegular.lean`.  Minsky and Papert (1969) showed
that XOR is not linearly separable: no single threshold unit computes
it.  That is a statement about *what one unit can compute*.  This file
shows that the XOR decision region, as an element of the Heyting algebra
`Opens (ℝ × ℝ)`, is nonetheless **regular** — `¬¬U = U` — and hence
classical in the sense of the four-position partition.

So two different lines are drawn at the same depth:

* **linear separability** (Minsky–Papert): XOR falls on the far side;
* **regularity** (this program): XOR falls on the classical side.

Every open half-space is regular (`unitAbove_regular` for the line; the
same argument in any dimension), so linear separability implies
regularity.  The converse fails, and XOR is the witness: a region needing
two layers that is still Boolean.  Non-classicality requires composition
(every single unit is regular), but composition does not deliver it; what
delivers it is a *seam* — a piece of boundary with the region on both
sides and nothing else, as at `x = 1` in `(0,1) ∪ (1,2)`.  XOR's boundary
is the two axes, and every point of either axis is a limit of points
outside the closure (the quadrants where `xy > 0`), so there is no seam
and double negation gives back the region unchanged.

Results:

1. **`xorRegion_regular`** — `xorRegionᶜᶜ = xorRegion` in `Opens (ℝ × ℝ)`.
2. **`xorRegion_not_dense`** — `xorRegionᶜ ≠ ⊥`; the complement contains
   the open quadrants where `xy > 0`.
3. **`xorRegion_not_ordinary`** — so by `isOrdinary_iff_allFourCells` the
   four-position partition around XOR is degenerate.
4. **`xorRegion_seam`** — the `¬¬`-remainder of XOR is empty, in contrast
   to `composed_seam` (`= {1}`).

The non-separability half of the comparison is Minsky–Papert's theorem,
cited, not formalized here.
-/
import Mathlib.Topology.MetricSpace.Pseudo.Constructions
import Mathlib.Topology.Instances.Real.Lemmas
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import FalseWorkPapers.Examples.PerceptronRegular

namespace FalseWork.Lattice

open TopologicalSpace Set

/-- The XOR decision region in the plane: exactly one of `x > 0`, `y > 0`,
i.e. the union of the second and fourth open quadrants, `{xy < 0}`. -/
def xorRegion : Opens (ℝ × ℝ) :=
  ⟨{p : ℝ × ℝ | p.1 * p.2 < 0},
    isOpen_lt (continuous_fst.mul continuous_snd) continuous_const⟩

theorem coe_xorRegion : ((xorRegion : Opens (ℝ × ℝ)) : Set (ℝ × ℝ)) = {p | p.1 * p.2 < 0} := rfl

/-- The closure of the XOR region lies inside `{xy ≤ 0}` (the region plus
the two axes). -/
theorem closure_xorRegion_subset :
    closure {p : ℝ × ℝ | p.1 * p.2 < 0} ⊆ {p : ℝ × ℝ | p.1 * p.2 ≤ 0} :=
  closure_minimal (fun p hp => by
      simp only [Set.mem_setOf_eq] at hp ⊢; exact le_of_lt hp)
    (isClosed_le (continuous_fst.mul continuous_snd) continuous_const)

/-- A ball inside `{xy ≤ 0}` contains no point with positive product. -/
private theorem no_pos_in_ball {p q : ℝ × ℝ} {ε : ℝ}
    (hball : Metric.ball p ε ⊆ {p : ℝ × ℝ | p.1 * p.2 ≤ 0})
    (hq : dist q p < ε) (hpos : 0 < q.1 * q.2) : False :=
  absurd (hball hq) (not_le.mpr hpos)

/-- **The axes are not a seam.**  Every point of `{xy ≤ 0}` that is not in
`{xy < 0}` lies on an axis, and every neighbourhood of a point on an axis
meets a quadrant where `xy > 0`.  So the interior of `{xy ≤ 0}` is `{xy < 0}`. -/
theorem interior_xorClosed_subset :
    interior {p : ℝ × ℝ | p.1 * p.2 ≤ 0} ⊆ {p : ℝ × ℝ | p.1 * p.2 < 0} := by
  intro p hp
  have hle : p.1 * p.2 ≤ 0 := by simpa using interior_subset hp
  rcases lt_or_eq_of_le hle with h | h
  · exact h
  · exfalso
    rw [mem_interior_iff_mem_nhds, Metric.mem_nhds_iff] at hp
    obtain ⟨ε, hε, hball⟩ := hp
    rcases mul_eq_zero.mp h with h1 | h2
    · -- `p` is on the `y`-axis: step off it toward the quadrant that
      -- shares the sign of `p.2`.
      rcases le_or_gt 0 p.2 with hy | hy
      · refine no_pos_in_ball (q := (ε / 2, p.2 + ε / 2)) hball ?_ ?_
        · rw [Prod.dist_eq, max_lt_iff]
          constructor <;> (rw [Real.dist_eq, abs_lt]; constructor <;> linarith)
        · exact mul_pos (by linarith) (by linarith)
      · refine no_pos_in_ball (q := (-(ε / 2), p.2 - ε / 2)) hball ?_ ?_
        · rw [Prod.dist_eq, max_lt_iff]
          constructor <;> (rw [Real.dist_eq, abs_lt]; constructor <;> linarith)
        · exact mul_pos_of_neg_of_neg (by linarith) (by linarith)
    · -- `p` is on the `x`-axis: symmetric.
      rcases le_or_gt 0 p.1 with hx | hx
      · refine no_pos_in_ball (q := (p.1 + ε / 2, ε / 2)) hball ?_ ?_
        · rw [Prod.dist_eq, max_lt_iff]
          constructor <;> (rw [Real.dist_eq, abs_lt]; constructor <;> linarith)
        · exact mul_pos (by linarith) (by linarith)
      · refine no_pos_in_ball (q := (p.1 - ε / 2, -(ε / 2))) hball ?_ ?_
        · rw [Prod.dist_eq, max_lt_iff]
          constructor <;> (rw [Real.dist_eq, abs_lt]; constructor <;> linarith)
        · exact mul_pos_of_neg_of_neg (by linarith) (by linarith)

/-- The regularization of XOR is XOR: `↑(xorRegionᶜᶜ) = {xy < 0}`. -/
theorem coe_xorRegion_hnot_hnot :
    ((xorRegionᶜᶜ : Opens (ℝ × ℝ)) : Set (ℝ × ℝ)) = {p | p.1 * p.2 < 0} := by
  rw [coe_hnot_hnot, coe_xorRegion]
  apply subset_antisymm
  · exact (interior_mono closure_xorRegion_subset).trans interior_xorClosed_subset
  · exact interior_maximal subset_closure xorRegion.isOpen

/-- **XOR is a regular element** of `Opens (ℝ × ℝ)`: `¬¬U = U`.  The
canonical function a single perceptron cannot compute is nonetheless
classical. -/
theorem xorRegion_regular : ((xorRegion)ᶜᶜ : Opens (ℝ × ℝ)) = xorRegion :=
  Opens.ext coe_xorRegion_hnot_hnot

/-- **XOR is not dense**: its Heyting complement contains the quadrants
where `xy > 0`. -/
theorem xorRegion_not_dense : ((xorRegion)ᶜ : Opens (ℝ × ℝ)) ≠ ⊥ := by
  intro h
  have h11 : ((1 : ℝ), (1 : ℝ)) ∈ ((xorRegionᶜ : Opens (ℝ × ℝ)) : Set (ℝ × ℝ)) := by
    rw [coe_hnot]
    refine mem_interior.mpr ⟨{p : ℝ × ℝ | 0 < p.1 * p.2}, ?_,
      isOpen_lt continuous_const (continuous_fst.mul continuous_snd), by norm_num⟩
    intro q hq hq'
    have h1 : 0 < q.1 * q.2 := hq
    have h2 : q.1 * q.2 < 0 := hq'
    linarith
  rw [h] at h11
  simp at h11

/-- **No four-fold opens around XOR**: it is regular, hence not ordinary,
so the four-position partition around it is degenerate.  Depth two is
necessary for non-classicality (every single unit is regular) but not
sufficient. -/
theorem xorRegion_not_ordinary : ¬ IsOrdinary xorRegion :=
  fun h => h.1 xorRegion_regular

/-- **XOR has no seam**: its `¬¬`-remainder is empty.  Compare
`composed_seam`, where the remainder is `{1}`. -/
theorem xorRegion_seam :
    ((xorRegionᶜᶜ : Opens (ℝ × ℝ)) : Set (ℝ × ℝ)) \ ((xorRegion : Opens (ℝ × ℝ)) : Set (ℝ × ℝ)) = ∅ := by
  rw [coe_xorRegion_hnot_hnot, coe_xorRegion, Set.diff_self]

end FalseWork.Lattice
