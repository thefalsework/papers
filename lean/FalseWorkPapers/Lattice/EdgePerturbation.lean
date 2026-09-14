/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# One step of dynamics: single-edge perturbation

Registered spec: `perturbation-study/SPEC.md` (committed 2026-09-14
before the oracle ran; E0 amendment also pre-code).  The oracle
surveyed 406 posets exhaustively (n ≤ 5) plus 180 sampled (n = 6, 7):
29,646 cone perturbations.  Two facts survived with zero exceptions
and are kernel-checked here.

* **L4, the ratchet (`dense_cone_ratchet`).**  Density of a principal
  cone is *absorbing*: if `↓p` is dense in the down-set algebra of
  `(α, ≤)` and the order is extended in any way (a single added
  dependency edge, or many), `↓p` stays dense in the extended order's
  algebra.  The oracle found 0 violations in 29,646 trials; the
  theorem covers every finite and infinite case at once, and is
  stronger than the survey — any extension, not just one edge.
  Combined with the oracle's L2/L3 witnesses (one edge can create and
  destroy *ordinariness* — 3-antichain + edge = the H3 motif;
  H3 + edge = a chain), density is the **unique absorbing class**
  among the three.  Edges are a one-way door into density: the
  arrow-of-time statement, and the reason a maturing ecosystem
  starves the aperture instrument (RubyGems K-R1) *necessarily*
  rather than accidentally.

* **L0, a time step is not an observer (`timeStep_not_observer`).**
  Adding an edge restricts the down-set algebra to
  `D(P') = {U : b ∈ U → a ∈ U}` — closed under ∪ and ∩ but **not**
  under `⇨`, hence never the fixed-point set of a nucleus (fix-sets
  are exponential ideals, `IsNucleus.himp_fixed`).  Witness: the
  2-antichain gaining its only edge.  The oracle found the same on
  every one of 284 tested edge-additions: dynamics does not reduce to
  the observer classification (C1).  Time and observation are
  different operations on the same algebra.
-/
import FalseWorkPapers.Lattice.BridgeDownSets

set_option linter.unusedSectionVars false

namespace FalseWork.Lattice

/-! ## Density as "meets everything", both directions -/

section MeetsAll

variable {H : Type*} [HeytingAlgebra H]

/-- Converse of `compl_eq_bot_of_meets_all`: a dense element meets
every nonzero element. -/
theorem meets_all_of_compl_eq_bot {u : H} (h : uᶜ = ⊥) {v : H}
    (hv : v ≠ ⊥) : u ⊓ v ≠ ⊥ := by
  intro hint
  apply hv
  have hle : v ≤ uᶜ := by
    rw [← himp_bot]
    exact le_himp_iff.mpr (by rw [inf_comm]; exact hint.le)
  rw [h, le_bot_iff] at hle
  exact hle

end MeetsAll

/-! ## The density criterion for principal cones -/

section DensityCriterion

variable {α : Type*} [Preorder α]

/-- A lower set with a member is nonzero. -/
theorem LowerSet.ne_bot_of_mem' {U : LowerSet α} {x : α} (hx : x ∈ U) :
    U ≠ ⊥ := by
  intro h
  rw [h] at hx
  simp at hx

/-- A nonzero lower set has a member. -/
theorem LowerSet.exists_mem_of_ne_bot {U : LowerSet α} (hU : U ≠ ⊥) :
    ∃ x, x ∈ U := by
  by_contra h
  push Not at h
  exact hU (SetLike.ext fun y => by simp [h y])

/-- **Density criterion.**  The principal cone `↓p` is dense in the
down-set algebra iff every element shares a lower bound with `p` —
the elementwise form the oracle computes. -/
theorem LowerSet.compl_Iic_eq_bot_iff (p : α) :
    (LowerSet.Iic p)ᶜ = ⊥ ↔ ∀ x : α, ∃ y, y ≤ x ∧ y ≤ p := by
  constructor
  · intro h x
    have hxne : (LowerSet.Iic x) ≠ ⊥ :=
      LowerSet.ne_bot_of_mem' (by simp : x ∈ LowerSet.Iic x)
    obtain ⟨y, hy⟩ :=
      LowerSet.exists_mem_of_ne_bot (meets_all_of_compl_eq_bot h hxne)
    have hyp : y ∈ LowerSet.Iic p := hy.1
    have hyx : y ∈ LowerSet.Iic x := hy.2
    exact ⟨y, by simpa using hyx, by simpa using hyp⟩
  · intro h
    refine compl_eq_bot_of_meets_all fun V hV => ?_
    obtain ⟨x, hx⟩ := LowerSet.exists_mem_of_ne_bot hV
    obtain ⟨y, hyx, hyp⟩ := h x
    exact LowerSet.ne_bot_of_mem' (x := y) ⟨by simpa using hyp, V.lower hyx hx⟩

end DensityCriterion

/-! ## L4: the ratchet -/

/-- **The ratchet (L4).**  Density of a principal cone is absorbing
under any extension of the order: if every element shares a lower
bound with `p` and relations are only ever *added* (a package gains a
dependency; edges accumulate as an ecosystem matures), the shared
lower bounds survive, so the cone stays dense.  One edge can create
ordinariness and one edge can destroy it (oracle witnesses L2, L3);
density, once entered, is never left.  Oracle: 0 violations in
29,646 single-edge cone perturbations; this theorem covers arbitrary
extensions of arbitrary (finite or infinite) preorders. -/
theorem dense_cone_ratchet {α : Type*} (P P' : Preorder α)
    (ext : ∀ a b : α, P.le a b → P'.le a b) (p : α)
    (h : (@LowerSet.Iic α P p)ᶜ = ⊥) :
    (@LowerSet.Iic α P' p)ᶜ = ⊥ := by
  rw [@LowerSet.compl_Iic_eq_bot_iff α P p] at h
  rw [@LowerSet.compl_Iic_eq_bot_iff α P' p]
  intro x
  obtain ⟨y, hyx, hyp⟩ := h x
  exact ⟨y, ext _ _ hyx, ext _ _ hyp⟩

/-! ## L0: a time step is not an observer -/

section TimeStep

variable {H : Type*} [HeytingAlgebra H] {j : H → H}

/-- Fix-sets of nuclei are exponential ideals: `a ⇨ s` is fixed
whenever `s` is, for *any* `a`.  (The gap through which L0 walks:
the down-sets of an extended order are meet- and join-closed in the
old algebra but not `⇨`-closed.) -/
theorem IsNucleus.himp_fixed (hj : IsNucleus j) (a : H) {s : H}
    (hs : j s = s) : j (a ⇨ s) = a ⇨ s := by
  refine le_antisymm ?_ (hj.1 _)
  rw [le_himp_iff]
  calc j (a ⇨ s) ⊓ a
      ≤ j (a ⇨ s) ⊓ j a := inf_le_inf_left _ (hj.1 a)
    _ = j ((a ⇨ s) ⊓ a) := (hj.2.2 _ _).symm
    _ ≤ j s := hj.monotone himp_inf_le
    _ = s := hs

end TimeStep

section TimeStepWitness

attribute [local instance] piDecidableLE

local instance (n : ℕ) : BiheytingAlgebra (Fin (n + 1)) :=
  LinearOrder.toBiheytingAlgebra (Fin (n + 1))

/-- D(2-antichain) presented as the product of two 2-chains: the
coordinates are "a ∈ U" and "b ∈ U". -/
abbrev DAnti := ∀ _ : Fin 2, Fin (1 + 1)

/-- The down-sets of the *extended* order (a < b added), viewed inside
D(2-antichain): those `U` with `b ∈ U → a ∈ U`. -/
def chainFix (x : DAnti) : Prop := x 1 ≤ x 0

instance : DecidablePred chainFix := fun x =>
  inferInstanceAs (Decidable (x 1 ≤ x 0))

/-- **L0.**  No nucleus on D(2-antichain) has the extended order's
down-sets as its fixed points: adding the edge `a < b` is not an act
of observation.  Proof: `⊥` is fixed, so `{a} ⇨ ⊥ = {b}` would be
fixed (`IsNucleus.himp_fixed`), but `{b}` violates `b ∈ U → a ∈ U`.
The oracle found the same non-closure on 284 of 284 edge-additions
tested; this is the minimal witness, kernel-checked. -/
theorem timeStep_not_observer :
    ¬ ∃ j : DAnti → DAnti, IsNucleus j ∧ ∀ x, (j x = x ↔ chainFix x) := by
  rintro ⟨j, hj, hfix⟩
  have hbot : j ![0, 0] = ![0, 0] := (hfix _).mpr (by decide)
  have hfixed : j (![1, 0] ⇨ ![0, 0]) = ![1, 0] ⇨ ![0, 0] :=
    hj.himp_fixed _ hbot
  have hmem : chainFix (![1, 0] ⇨ ![0, 0]) := (hfix _).mp hfixed
  revert hmem
  decide

end TimeStepWitness

end FalseWork.Lattice
