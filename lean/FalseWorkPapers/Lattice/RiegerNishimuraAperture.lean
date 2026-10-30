/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# Unique unspoilable triple on Z_{2m}

The join-irreducibles of the Rieger–Nishimura truncations are the
ladder `q₁, q₂, q₃, …` with `q₁, q₂` minimal, `q₃` covering `q₁`, and
`qₘ` covering `qₘ₋₂` and `qₘ₋₃` for `m ≥ 4`.  `Z_{2m}` is the down-set
algebra of the first `m` rungs (`m ≥ 3`).  The generator is `{q₁}`.

This file proves that the generator has a unique witness triple
`{q₁, q₂, q₃}`, that the triple is unspoilable, and therefore that
`j_S` opens the generator iff `S` contains those three points.  The
count `2^{m−3}` (one-eighth of the nuclei) is then the number of
supersets of a 3-set in an `m`-set.

Companion to `ApertureCriterion.lean` and to
`preprints/aperture/aperture-shape-note.md` C4.
-/
import FalseWorkPapers.Lattice.ApertureCriterion

set_option linter.unusedSectionVars false

namespace FalseWork.Lattice

/-! ## The Rieger–Nishimura covering -/

/-- `rnMem i j` iff index `i` lies in the down-set of index `j`. -/
def rnMem : ℕ → ℕ → Bool
  | i, 0 => decide (i = 0)
  | i, 1 => decide (i = 1)
  | i, 2 => decide (i = 0 ∨ i = 2)
  | i, n + 3 => decide (i = n + 3) || rnMem i (n + 1) || rnMem i n

private theorem or_true3 {a b c : Bool} :
    (a || b || c) = true ↔ a = true ∨ b = true ∨ c = true := by
  cases a <;> cases b <;> cases c <;> simp

theorem rnMem_le {i j : ℕ} (h : rnMem i j = true) : i ≤ j := by
  induction j using Nat.strong_induction_on with
  | h j ih =>
    match j with
    | 0 =>
      simp [rnMem] at h; omega
    | 1 =>
      simp [rnMem] at h; omega
    | 2 =>
      simp [rnMem] at h; omega
    | n + 3 =>
      change (decide (i = n + 3) || rnMem i (n + 1) || rnMem i n) = true at h
      rw [or_true3] at h
      rcases h with h | h | h
      · simp at h; omega
      · exact Nat.le_trans (ih (n + 1) (by omega) h) (by omega)
      · exact Nat.le_trans (ih n (by omega) h) (by omega)

theorem rnMem_refl (i : ℕ) : rnMem i i = true := by
  match i with
  | 0 => simp [rnMem]
  | 1 => simp [rnMem]
  | 2 => simp [rnMem]
  | n + 3 => simp [rnMem]

theorem rnMem_zero (j : ℕ) : rnMem 0 j = true ↔ j ≠ 1 := by
  induction j using Nat.strong_induction_on with
  | h j ih =>
    match j with
    | 0 => simp [rnMem]
    | 1 => simp [rnMem]
    | 2 => simp [rnMem]
    | n + 3 =>
      have : n + 3 ≠ 1 := by omega
      change (decide (0 = n + 3) || rnMem 0 (n + 1) || rnMem 0 n) = true ↔ n + 3 ≠ 1
      rw [or_true3]
      simp [this]
      by_cases hn : n = 1
      · subst hn; simp [rnMem]
      · have h := (ih n (by omega)).mpr hn
        simp [h]

theorem rnMem_one (j : ℕ) : rnMem 1 j = true ↔ j = 1 ∨ 3 ≤ j := by
  induction j using Nat.strong_induction_on with
  | h j ih =>
    match j with
    | 0 => simp [rnMem]
    | 1 => simp [rnMem]
    | 2 => simp [rnMem]
    | n + 3 =>
      have : 3 ≤ n + 3 := by omega
      change (decide (1 = n + 3) || rnMem 1 (n + 1) || rnMem 1 n) = true ↔
        n + 3 = 1 ∨ 3 ≤ n + 3
      rw [or_true3]
      simp [this]
      by_cases h0 : n = 0
      · subst h0; simp [rnMem]
      · by_cases h1 : n = 1
        · subst h1; simp [rnMem]
        · by_cases h2 : n = 2
          · subst h2
            have h := (ih 3 (by omega)).mpr (Or.inr (by decide))
            simp [h]
          · have h := (ih n (by omega)).mpr (Or.inr (by omega))
            simp [h]

theorem rnMem_trans {a b c : ℕ}
    (hab : rnMem a b = true) (hbc : rnMem b c = true) : rnMem a c = true := by
  induction c using Nat.strong_induction_on generalizing a b with
  | h c ih =>
    match c with
    | 0 =>
      simp [rnMem] at hbc
      subst hbc
      exact hab
    | 1 =>
      simp [rnMem] at hbc
      subst hbc
      exact hab
    | 2 =>
      simp [rnMem] at hbc
      rcases hbc with hbc | hbc
      · subst hbc
        simp [rnMem] at hab
        subst hab
        simp [rnMem]
      · subst hbc
        exact hab
    | n + 3 =>
      change (decide (b = n + 3) || rnMem b (n + 1) || rnMem b n) = true at hbc
      rw [or_true3] at hbc
      rcases hbc with hbc | hbc | hbc
      · have : b = n + 3 := by simpa using hbc
        subst this
        exact hab
      · have h := ih (n + 1) (by omega) hab hbc
        change (decide (a = n + 3) || rnMem a (n + 1) || rnMem a n) = true
        rw [or_true3]; exact Or.inr (Or.inl h)
      · have h := ih n (by omega) hab hbc
        change (decide (a = n + 3) || rnMem a (n + 1) || rnMem a n) = true
        rw [or_true3]; exact Or.inr (Or.inr h)

/-! ## The ladder poset of the first `m` rungs (`Z_{2m}`) -/

@[ext]
structure Ladder (m : ℕ) where
  idx : Fin m
  deriving DecidableEq, Repr

namespace Ladder

variable {m : ℕ}

instance : Fintype (Ladder m) :=
  Fintype.ofEquiv (Fin m)
    { toFun := fun i => ⟨i⟩
      invFun := idx
      left_inv := fun _ => rfl
      right_inv := fun _ => rfl }

instance : Finite (Ladder m) := inferInstance

instance : LE (Ladder m) where
  le a b := rnMem a.idx.val b.idx.val = true

instance : LT (Ladder m) where
  lt a b := a ≤ b ∧ ¬ b ≤ a

instance : DecidableLE (Ladder m) := fun a b =>
  inferInstanceAs (Decidable (rnMem a.idx.val b.idx.val = true))

instance : PartialOrder (Ladder m) where
  le_refl a := rnMem_refl a.idx.val
  le_trans _ _ _ hab hbc := rnMem_trans hab hbc
  le_antisymm _ _ hab hba :=
    Ladder.ext (Fin.ext (Nat.le_antisymm (rnMem_le hab) (rnMem_le hba)))
  lt_iff_le_not_ge _ _ := Iff.rfl

theorem le_iff {a b : Ladder m} :
    a ≤ b ↔ rnMem a.idx.val b.idx.val = true := Iff.rfl

def q1 (hm : 3 ≤ m) : Ladder m := ⟨⟨0, by omega⟩⟩
def q2 (hm : 3 ≤ m) : Ladder m := ⟨⟨1, by omega⟩⟩
def q3 (hm : 3 ≤ m) : Ladder m := ⟨⟨2, by omega⟩⟩

@[simp] theorem q1_val (hm : 3 ≤ m) : (q1 hm).idx.val = 0 := rfl
@[simp] theorem q2_val (hm : 3 ≤ m) : (q2 hm).idx.val = 1 := rfl
@[simp] theorem q3_val (hm : 3 ≤ m) : (q3 hm).idx.val = 2 := rfl

theorem q1_le_iff (hm : 3 ≤ m) {x : Ladder m} :
    q1 hm ≤ x ↔ x.idx.val ≠ 1 := by
  rw [le_iff, q1_val, rnMem_zero]

theorem q2_le_iff (hm : 3 ≤ m) {x : Ladder m} :
    q2 hm ≤ x ↔ x.idx.val = 1 ∨ 3 ≤ x.idx.val := by
  rw [le_iff, q2_val, rnMem_one]

theorem q1_not_le_q2 (hm : 3 ≤ m) : ¬ q1 hm ≤ q2 hm := by
  rw [q1_le_iff hm]; simp

theorem q2_not_le_q3 (hm : 3 ≤ m) : ¬ q2 hm ≤ q3 hm := by
  rw [q2_le_iff hm]; simp

theorem q1_lt_q3 (hm : 3 ≤ m) : q1 hm < q3 hm := by
  refine ⟨?_, ?_⟩
  · rw [q1_le_iff hm]; simp
  · intro h
    have : (q3 hm).idx.val ≤ (q1 hm).idx.val := rnMem_le h
    simp at this

def g (_hm : 3 ≤ m) : LowerSet (Ladder m) :=
  ⟨{x | x.idx.val = 0}, by
    intro a b hba ha
    simp only [Set.mem_setOf_eq] at ha ⊢
    have h : rnMem b.idx.val a.idx.val = true := hba
    rw [ha] at h
    simpa [rnMem] using h⟩

theorem mem_g (hm : 3 ≤ m) {x : Ladder m} :
    x ∈ g hm ↔ x.idx.val = 0 := Iff.rfl

theorem q1_mem_g (hm : 3 ≤ m) : q1 hm ∈ g hm := by simp [mem_g]
theorem q2_notMem_g (hm : 3 ≤ m) : q2 hm ∉ g hm := by simp [mem_g]
theorem q3_notMem_g (hm : 3 ≤ m) : q3 hm ∉ g hm := by simp [mem_g]

def genTriple (hm : 3 ≤ m) : WitnessTriple (g hm) where
  c := q1 hm
  x := q3 hm
  u := q2 hm
  c_mem := q1_mem_g hm
  x_notMem := q3_notMem_g hm
  u_notMem := q2_notMem_g hm
  c_lt_x := q1_lt_q3 hm
  c_not_le_u := q1_not_le_q2 hm
  u_not_le_x := q2_not_le_q3 hm

/-- Every witness triple of `g` is `(q₁, q₃, q₂)`. -/
theorem triple_unique (hm : 3 ≤ m) (t : WitnessTriple (g hm)) :
    t.c = q1 hm ∧ t.x = q3 hm ∧ t.u = q2 hm := by
  have hc : t.c.idx.val = 0 := (mem_g hm).mp t.c_mem
  have hcQ : t.c = q1 hm := Ladder.ext (Fin.ext (by simp [hc]))
  have hx0 : t.x.idx.val ≠ 0 := fun h => t.x_notMem ((mem_g hm).mpr h)
  have hx_ge : q1 hm ≤ t.x := by simpa [hcQ] using t.c_lt_x.le
  have hx_ne1 : t.x.idx.val ≠ 1 := by
    rw [q1_le_iff hm] at hx_ge; exact hx_ge
  have hu_ne_le : ¬ q1 hm ≤ t.u := by simpa [hcQ] using t.c_not_le_u
  have hu1 : t.u.idx.val = 1 := by
    rw [q1_le_iff hm] at hu_ne_le; omega
  have huQ : t.u = q2 hm := Ladder.ext (Fin.ext (by simp [hu1]))
  have hx_not : ¬ q2 hm ≤ t.x := by simpa [huQ] using t.u_not_le_x
  have hx2 : t.x.idx.val = 2 := by
    rw [q2_le_iff hm] at hx_not
    omega
  exact ⟨hcQ, Ladder.ext (Fin.ext (by simp [hx2])), huQ⟩

theorem triple_carrier_unique (hm : 3 ≤ m) (t : WitnessTriple (g hm)) :
    t.carrier = (genTriple hm).carrier := by
  obtain ⟨hc, hx, hu⟩ := triple_unique hm t
  simp only [WitnessTriple.carrier, genTriple, hc, hx, hu]

theorem genTriple_unspoilable (hm : 3 ≤ m) : (genTriple hm).Unspoilable := by
  rw [WitnessTriple.unspoilable_iff]
  constructor
  · intro y hyk hyu
    have : y.idx.val = 0 := (mem_g hm).mp hyk
    have : y = q1 hm := Ladder.ext (Fin.ext (by simp [this]))
    subst this
    exact q1_not_le_q2 hm hyu
  · intro y hyk hyx
    have hy0 : y.idx.val ≠ 0 := fun h => hyk ((mem_g hm).mpr h)
    have : rnMem y.idx.val 2 = true := by
      simpa [le_iff] using hyx
    simp [rnMem] at this
    rcases this with hval | hval
    · exact (hy0 hval).elim
    · have : y = q3 hm := Ladder.ext (Fin.ext (by simp [hval]))
      subst this
      exact (q1_lt_q3 hm).le

/-- **The one-eighth law, membership form, for `Z_{2m}`.**  `j_S` opens
the generator iff `S` contains `{q₁, q₂, q₃}`. -/
theorem opens_g_iff_core_subset (hm : 3 ≤ m) (S : Set (Ladder m)) :
    Opens (subNucleus S) (g hm) ↔ (genTriple hm).carrier ⊆ S :=
  opens_iff_core_subset (genTriple hm) (genTriple_unspoilable hm)
    (triple_carrier_unique hm) S

end Ladder

#print axioms Ladder.opens_g_iff_core_subset
#print axioms Ladder.triple_unique
#print axioms Ladder.genTriple_unspoilable
#print axioms WitnessTriple.unspoilable_iff
#print axioms rigid_aperture_iff

end FalseWork.Lattice
