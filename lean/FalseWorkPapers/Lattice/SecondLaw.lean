/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# The second-law package for phantom mass

Registered spec: `preprints/aperture/second-law-spec.md` (committed
2026-09-13, before this file existed).  The thermodynamic reading of
the ledger predicts that phantom mass behaves like entropy production
under coarsening of the observer.  This file kernel-checks the four
registered clauses:

* **S1 (`phantomMass_mono`).**  Coarser observation never
  manufactures less phantom: `j ≤ j'` pointwise implies
  `phantomMass j k ≤ phantomMass j' k`.  As the spec notes, this is
  order-trivial (interval inclusion plus card monotonicity) and does
  not even need the nucleus hypotheses; the nucleus-phrased corollary
  is `IsNucleus.phantomMass_mono`.

* **S2 (`isNucleus_id`, `phantomMass_id`, `IsNucleus.one_le_phantomMass`,
  `IsNucleus.id_le`).**  The identity is a nucleus with phantom mass
  exactly 1 everywhere (the interval `[k, k]` is `{k}`; mass counts
  `k` itself, so 1 is "manufactures nothing").  Every nucleus
  dominates it pointwise, hence every observer's mass is ≥ 1
  everywhere: the identity is the zero-production floor of the
  observer order.

* **S3 (`exists_phantomMass_lt`).**  No free coarsening: if `j ≤ j'`
  pointwise and `j ≠ j'`, some kernel has strictly larger phantom
  mass under `j'`.  The witness is any `x` where they differ; there
  `j x < j' x` and `j' x` lies in the second interval but not the
  first.  (Only `j'` needs to be inflationary; stated with the
  hypotheses the spec registered.)

* **S4 (`IsNucleus.phantomMass_eq_one_iff`).**  Zero manufacture
  characterizes equilibrium: `phantomMass j k = 1 ↔ j k = k`.
  Production vanishes exactly at the fixed points of the observer —
  the opens of `j`.

Per the spec's honesty notes: this is one law, not a thermodynamics.
No temperature analogue, no work theorem, no dynamics.  S3 uses
`LocallyFiniteOrder` (finite intervals), nothing more.
-/
import FalseWorkPapers.Lattice.CoApertureClosedForm

set_option linter.unusedSectionVars false

namespace FalseWork.Lattice

variable {H : Type*} [SemilatticeInf H] [LocallyFiniteOrder H]

/-! ## S1: monotonicity — the second law -/

/-- **S1, general form.**  If `j k ≤ j' k` then the confusion interval
at `k` can only grow.  No nucleus hypotheses are needed for this
direction; the law is order-theoretic. -/
theorem phantomMass_mono {j j' : H → H} (h : ∀ x, j x ≤ j' x) (k : H) :
    phantomMass j k ≤ phantomMass j' k :=
  Finset.card_le_card (Finset.Icc_subset_Icc_right (h k))

/-- **S1 as registered**: for nuclei `j ≤ j'` pointwise, coarser
observation never manufactures less phantom. -/
theorem IsNucleus.phantomMass_mono {j j' : H → H}
    (_hj : IsNucleus j) (_hj' : IsNucleus j') (h : ∀ x, j x ≤ j' x) (k : H) :
    phantomMass j k ≤ phantomMass j' k :=
  FalseWork.Lattice.phantomMass_mono h k

/-! ## S2: the reversible observer is the floor -/

/-- The identity is a nucleus: the lossless observer. -/
theorem isNucleus_id : IsNucleus (id : H → H) :=
  ⟨fun _ => le_rfl, fun _ => rfl, fun _ _ => rfl⟩

/-- The identity manufactures nothing: its phantom mass is exactly 1
(the interval `[k, k] = {k}`, the kernel alone, no confusion). -/
theorem phantomMass_id (k : H) : phantomMass (id : H → H) k = 1 := by
  unfold phantomMass
  rw [id_eq, Finset.Icc_self, Finset.card_singleton]

/-- Every nucleus dominates the identity pointwise (inflationarity
restated): the identity is the bottom of the observer order. -/
theorem IsNucleus.id_le {j : H → H} (hj : IsNucleus j) (x : H) :
    id x ≤ j x :=
  hj.1 x

/-- Every observer's phantom mass is at least the identity's: mass ≥ 1
everywhere.  With `phantomMass_id`, the identity is the
zero-production floor. -/
theorem IsNucleus.one_le_phantomMass {j : H → H} (hj : IsNucleus j)
    (k : H) : 1 ≤ phantomMass j k := by
  rw [← phantomMass_id k]
  exact FalseWork.Lattice.phantomMass_mono hj.id_le k

/-! ## S3: strictness — no free coarsening -/

/-- **S3.**  A strictly coarser observer manufactures strictly more
phantom somewhere: if `j ≤ j'` pointwise and `j ≠ j'`, some kernel
separates their masses.  The witness is any point where they differ. -/
theorem exists_phantomMass_lt {j j' : H → H}
    (_hj : IsNucleus j) (hj' : IsNucleus j')
    (hle : ∀ x, j x ≤ j' x) (hne : j ≠ j') :
    ∃ k, phantomMass j k < phantomMass j' k := by
  obtain ⟨x, hx⟩ := Function.ne_iff.mp hne
  have hlt : j x < j' x := lt_of_le_of_ne (hle x) hx
  refine ⟨x, Finset.card_lt_card ?_⟩
  rw [Finset.ssubset_iff_of_subset (Finset.Icc_subset_Icc_right (hle x))]
  exact ⟨j' x, Finset.mem_Icc.mpr ⟨hj'.1 x, le_rfl⟩,
    fun hmem => absurd (lt_of_lt_of_le hlt (Finset.mem_Icc.mp hmem).2)
      (lt_irrefl _)⟩

/-! ## S4: zero production characterizes equilibrium -/

/-- **S4.**  An observer manufactures nothing at `k` exactly when `k`
is one of its fixed points: `phantomMass j k = 1 ↔ j k = k`.
Production vanishes precisely at equilibrium states — the opens of
`j`. -/
theorem IsNucleus.phantomMass_eq_one_iff {j : H → H} (hj : IsNucleus j)
    (k : H) : phantomMass j k = 1 ↔ j k = k := by
  unfold phantomMass
  constructor
  · intro h
    have hk : k ∈ Finset.Icc k (j k) :=
      Finset.mem_Icc.mpr ⟨le_rfl, hj.1 k⟩
    have hjk : j k ∈ Finset.Icc k (j k) :=
      Finset.mem_Icc.mpr ⟨hj.1 k, le_rfl⟩
    exact Finset.card_le_one.mp h.le _ hjk _ hk
  · intro h
    rw [h, Finset.Icc_self, Finset.card_singleton]

end FalseWork.Lattice
