/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# An infinite family of latently ordinary kernels

The identity is the unique opening observer iff the poset itself is a
witness triple (`rigid_aperture_iff`).  Latency is the other extreme:
triples exist, but every one is spoiled at full resolution
(`latent_iff_all_triples_spoiled`).  This file exhibits an infinite
family.

Let `P` be the disjoint union of an `n`-chain and an `m`-chain,
`n, m ≥ 2`, and let `k` be the two bottoms.  Then `k` is dense (it
contains every minimal point), so identity sees no four-fold; yet the
two triples sitting on the first two rungs of each chain open it, and
every triple is spoiled in `P` by the other bottom.  The case
`n = m = 2` is Div36's element 6.

Companion to `ApertureCriterion.lean` and to
`preprints/aperture/witness-triples.md` §3.
-/
import FalseWorkPapers.Lattice.ApertureCriterion

set_option linter.unusedSectionVars false

namespace FalseWork.Lattice

/-- Disjoint union of an `n`-chain and an `m`-chain. -/
inductive TwoChain (n m : ℕ) where
  | left : Fin n → TwoChain n m
  | right : Fin m → TwoChain n m
  deriving DecidableEq, Repr

namespace TwoChain

variable {n m : ℕ}

instance : Fintype (TwoChain n m) :=
  Fintype.ofEquiv (Fin n ⊕ Fin m)
    { toFun := fun
        | .inl i => .left i
        | .inr j => .right j
      invFun := fun
        | .left i => .inl i
        | .right j => .inr j
      left_inv := fun x => by cases x <;> rfl
      right_inv := fun x => by cases x <;> rfl }

instance : Finite (TwoChain n m) := inferInstance

/-- Order is comparison of indices on the same chain; distinct sides
are incomparable.  Stored as `ℕ`-inequalities so the `PartialOrder`
laws reduce to `Nat.le_*`. -/
def le : TwoChain n m → TwoChain n m → Prop
  | left i, left j => (i : ℕ) ≤ (j : ℕ)
  | right i, right j => (i : ℕ) ≤ (j : ℕ)
  | _, _ => False

instance : LE (TwoChain n m) := ⟨le⟩

instance : LT (TwoChain n m) where
  lt a b := a ≤ b ∧ ¬ b ≤ a

instance : DecidableLE (TwoChain n m) := fun a b =>
  match a, b with
  | left i, left j => inferInstanceAs (Decidable ((i : ℕ) ≤ (j : ℕ)))
  | right i, right j => inferInstanceAs (Decidable ((i : ℕ) ≤ (j : ℕ)))
  | left _, right _ => isFalse fun h => nomatch h
  | right _, left _ => isFalse fun h => nomatch h

instance : PartialOrder (TwoChain n m) where
  le_refl
    | left i => Nat.le_refl (i : ℕ)
    | right j => Nat.le_refl (j : ℕ)
  le_trans a b c hab hbc := by
    match a, b, c with
    | left _, left _, left _ => exact Nat.le_trans hab hbc
    | right _, right _, right _ => exact Nat.le_trans hab hbc
    | left _, left _, right _ => exact (hbc : False).elim
    | left _, right _, left _ => exact (hab : False).elim
    | left _, right _, right _ => exact (hab : False).elim
    | right _, left _, left _ => exact (hab : False).elim
    | right _, left _, right _ => exact (hab : False).elim
    | right _, right _, left _ => exact (hbc : False).elim
  le_antisymm a b hab hba := by
    match a, b with
    | left i, left j =>
        exact congrArg left (Fin.ext (Nat.le_antisymm hab hba))
    | right i, right j =>
        exact congrArg right (Fin.ext (Nat.le_antisymm hab hba))
    | left _, right _ => exact (hab : False).elim
    | right _, left _ => exact (hab : False).elim
  lt_iff_le_not_ge _ _ := Iff.rfl

@[simp] theorem left_le_left_iff {i j : Fin n} :
    (left i : TwoChain n m) ≤ left j ↔ (i : ℕ) ≤ (j : ℕ) := Iff.rfl

@[simp] theorem right_le_right_iff {i j : Fin m} :
    (right i : TwoChain n m) ≤ right j ↔ (i : ℕ) ≤ (j : ℕ) := Iff.rfl

theorem not_left_le_right (i : Fin n) (j : Fin m) :
    ¬ (left i : TwoChain n m) ≤ right j := fun h => nomatch h

theorem not_right_le_left (j : Fin m) (i : Fin n) :
    ¬ (right j : TwoChain n m) ≤ left i := fun h => nomatch h

def idxNat : TwoChain n m → ℕ
  | left i => i.val
  | right j => j.val

def botL (hn : 1 ≤ n) : TwoChain n m := left ⟨0, by omega⟩
def botR (hm : 1 ≤ m) : TwoChain n m := right ⟨0, by omega⟩
def nextL (hn : 2 ≤ n) : TwoChain n m := left ⟨1, by omega⟩
def nextR (hm : 2 ≤ m) : TwoChain n m := right ⟨1, by omega⟩

@[simp] theorem botL_eq (hn : 1 ≤ n) : botL (n := n) (m := m) hn = left ⟨0, by omega⟩ := rfl
@[simp] theorem botR_eq (hm : 1 ≤ m) : botR (n := n) (m := m) hm = right ⟨0, by omega⟩ := rfl
@[simp] theorem nextL_eq (hn : 2 ≤ n) : nextL (n := n) (m := m) hn = left ⟨1, by omega⟩ := rfl
@[simp] theorem nextR_eq (hm : 2 ≤ m) : nextR (n := n) (m := m) hm = right ⟨1, by omega⟩ := rfl

theorem botL_le_left (hn : 1 ≤ n) (i : Fin n) :
    botL (n := n) (m := m) hn ≤ left i :=
  Nat.zero_le (i : ℕ)

theorem botR_le_right (hm : 1 ≤ m) (j : Fin m) :
    botR (n := n) (m := m) hm ≤ right j :=
  Nat.zero_le (j : ℕ)

def g (hn : 2 ≤ n) (hm : 2 ≤ m) : LowerSet (TwoChain n m) :=
  ⟨{x | x = botL (by omega) ∨ x = botR (by omega)}, by
    intro a b hba ha
    simp only [Set.mem_setOf_eq] at ha ⊢
    rcases ha with ha | ha
    · subst ha
      cases b with
      | left j =>
        have hj : j.val = 0 := Nat.eq_zero_of_le_zero hba
        exact Or.inl (congrArg left (Fin.ext hj))
      | right j =>
        exact (not_right_le_left j _ hba).elim
    · subst ha
      cases b with
      | left i =>
        exact (not_left_le_right i _ hba).elim
      | right j =>
        have hj : j.val = 0 := Nat.eq_zero_of_le_zero hba
        exact Or.inr (congrArg right (Fin.ext hj))⟩

theorem mem_g (hn : 2 ≤ n) (hm : 2 ≤ m) {x : TwoChain n m} :
    x ∈ g hn hm ↔ x = botL (by omega) ∨ x = botR (by omega) := Iff.rfl

theorem botL_mem_g (hn : 2 ≤ n) (hm : 2 ≤ m) : botL (by omega) ∈ g hn hm :=
  (mem_g hn hm).mpr (Or.inl rfl)

theorem botR_mem_g (hn : 2 ≤ n) (hm : 2 ≤ m) : botR (by omega) ∈ g hn hm :=
  (mem_g hn hm).mpr (Or.inr rfl)

theorem nextL_notMem_g (hn : 2 ≤ n) (hm : 2 ≤ m) : nextL hn ∉ g hn hm := by
  intro h
  rcases (mem_g hn hm).mp h with hx | hx
  · have : (1 : ℕ) = 0 := by
      simpa [idxNat] using congrArg (idxNat (n := n) (m := m)) hx
    omega
  · cases hx

theorem nextR_notMem_g (hn : 2 ≤ n) (hm : 2 ≤ m) : nextR hm ∉ g hn hm := by
  intro h
  rcases (mem_g hn hm).mp h with hx | hx
  · cases hx
  · have : (1 : ℕ) = 0 := by
      simpa [idxNat] using congrArg (idxNat (n := n) (m := m)) hx
    omega

/-- One of the two coarsest opening observers: first two rungs of the
left chain, plus the second rung of the right. -/
def leftTriple (hn : 2 ≤ n) (hm : 2 ≤ m) : WitnessTriple (g hn hm) where
  c := botL (by omega)
  x := nextL hn
  u := nextR hm
  c_mem := botL_mem_g hn hm
  x_notMem := nextL_notMem_g hn hm
  u_notMem := nextR_notMem_g hn hm
  c_lt_x := by
    refine ⟨?_, ?_⟩
    · simp [botL, nextL]
    · simp [botL, nextL]
  c_not_le_u := not_left_le_right _ _
  u_not_le_x := not_right_le_left _ _

/-- Every witness triple of `g` is spoiled at full resolution: `u` sits
on the chain opposite `c`, so the other bottom lies in `k` below `u`. -/
theorem all_triples_spoiled (hn : 2 ≤ n) (hm : 2 ≤ m)
    (t : WitnessTriple (g hn hm)) : ¬ t.IsValidIn Set.univ := by
  intro hv
  have hc := (mem_g hn hm).mp t.c_mem
  rcases hc with hc | hc
  · have hu_not : ¬ botL (n := n) (m := m) (by omega) ≤ t.u := by
      simpa [hc] using t.c_not_le_u
    have hu_right : ∃ j, t.u = right j := by
      cases hu : t.u with
      | left i => exact (hu_not (hu ▸ botL_le_left (by omega) i)).elim
      | right j => exact ⟨j, rfl⟩
    obtain ⟨j, hj⟩ := hu_right
    have hbot : botR (n := n) (m := m) (le_trans (by decide : 1 ≤ 2) hm) ≤ t.u := by
      rw [hj]
      exact botR_le_right (le_trans (by decide : 1 ≤ 2) hm) j
    exact hv.2.1 (botR (le_trans (by decide : 1 ≤ 2) hm)) trivial
      (botR_mem_g hn hm) hbot
  · have hu_not : ¬ botR (n := n) (m := m) (by omega) ≤ t.u := by
      simpa [hc] using t.c_not_le_u
    have hu_left : ∃ i, t.u = left i := by
      cases hu : t.u with
      | left i => exact ⟨i, rfl⟩
      | right j => exact (hu_not (hu ▸ botR_le_right (by omega) j)).elim
    obtain ⟨i, hi⟩ := hu_left
    have hbot : botL (n := n) (m := m) (le_trans (by decide : 1 ≤ 2) hn) ≤ t.u := by
      rw [hi]
      exact botL_le_left (le_trans (by decide : 1 ≤ 2) hn) i
    exact hv.2.1 (botL (le_trans (by decide : 1 ≤ 2) hn)) trivial
      (botL_mem_g hn hm) hbot

/-- **Latent family.**  The two-bottoms kernel on the disjoint union of
two chains of length at least 2 is latently ordinary.  Instantiating
at `n = m = 2` recovers Div36's element 6. -/
theorem twoChain_latent (hn : 2 ≤ n) (hm : 2 ≤ m) :
    ¬ Opens (subNucleus Set.univ) (g hn hm) ∧
      ∃ S, Opens (subNucleus S) (g hn hm) := by
  rw [latent_iff_all_triples_spoiled]
  exact ⟨⟨leftTriple hn hm⟩, all_triples_spoiled hn hm⟩

end TwoChain

#print axioms TwoChain.twoChain_latent
#print axioms TwoChain.all_triples_spoiled

end FalseWork.Lattice
