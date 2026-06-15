/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# `Z_6 + Z_3`: the Citkin gluing construction

Alex Citkin (pers. comm., 2026-06-11) identified the minimal converse
counterexample `H8` (`UniqueOrdinaryConverse.lean`) with the eight-element
algebra obtained by **gluing a 3-element chain Heyting algebra atop
`Z_6`**: identify the top of `Z_6` (= `Div12.twelve`) with the bottom of
the chain, yielding eight elements.

This file names that construction `Z6PlusChain3`, proves **`Z6PlusChain3 ≅ H8`**
as Heyting algebras, and records the order embedding `Div12 ↪ Z6PlusChain3`
on the lower part (`twelve` lands on the glue point, not the top).  The
enumeration witness and the expert construction now coincide at [K].

Pre-registered in `validation/claims/unique-ordinary-structure.md` §4c.
-/
import Mathlib.Order.Heyting.Basic
import FalseWorkPapers.Examples.DivisorLattice12
import FalseWorkPapers.Examples.UniqueOrdinaryConverse

namespace FalseWork.Lattice.Examples

open FalseWork.Lattice.Examples (H8)

/-! ## The eight elements of `Z_6 + Z_3` -/

inductive Z6PlusChain3 : Type
  | z_one | z_two | z_three | z_four | z_six | z_glue | z_mid | z_top
  deriving DecidableEq, Repr

namespace Z6PlusChain3

instance : Fintype Z6PlusChain3 :=
  ⟨{z_one, z_two, z_three, z_four, z_six, z_glue, z_mid, z_top},
    by intro x; cases x <;> decide⟩

/-! ## Isomorphism with `H8` -/

def toH8 : Z6PlusChain3 → H8
  | z_one   => H8.bot
  | z_two   => H8.a
  | z_three => H8.n
  | z_four  => H8.r
  | z_six   => H8.an
  | z_glue  => H8.rn
  | z_mid   => H8.d
  | z_top   => H8.top

def fromH8 : H8 → Z6PlusChain3
  | H8.bot => z_one
  | H8.a   => z_two
  | H8.n   => z_three
  | H8.r   => z_four
  | H8.an  => z_six
  | H8.rn  => z_glue
  | H8.d   => z_mid
  | H8.top => z_top

theorem left_toFrom (y : H8) : toH8 (fromH8 y) = y := by
  cases y <;> rfl

theorem right_toFrom (x : Z6PlusChain3) : fromH8 (toH8 x) = x := by
  cases x <;> rfl

/-! ## Heyting structure transported from `H8` -/

def leb : Z6PlusChain3 → Z6PlusChain3 → Bool
  | x, y => (toH8 x).leb (toH8 y)

instance : LE Z6PlusChain3 := ⟨fun x y => leb x y = true⟩
instance : LT Z6PlusChain3 := ⟨fun x y => x ≤ y ∧ ¬ y ≤ x⟩

instance decLE : ∀ x y : Z6PlusChain3, Decidable (x ≤ y) := fun x y => by
  show Decidable (leb x y = true); exact decEq _ _

instance : DecidableLE Z6PlusChain3 := decLE

def meet (x y : Z6PlusChain3) : Z6PlusChain3 := fromH8 (toH8 x ⊓ toH8 y)
def join (x y : Z6PlusChain3) : Z6PlusChain3 := fromH8 (toH8 x ⊔ toH8 y)
def himpFun (x y : Z6PlusChain3) : Z6PlusChain3 := fromH8 (toH8 x ⇨ toH8 y)
def complFun (x : Z6PlusChain3) : Z6PlusChain3 := fromH8 (toH8 x)ᶜ

instance : Min Z6PlusChain3 := ⟨meet⟩
instance : Max Z6PlusChain3 := ⟨join⟩
instance : Top Z6PlusChain3 := ⟨z_top⟩
instance : Bot Z6PlusChain3 := ⟨z_one⟩
instance : HImp Z6PlusChain3 := ⟨himpFun⟩
instance : Compl Z6PlusChain3 := ⟨complFun⟩

theorem map_inf (x y : Z6PlusChain3) : toH8 (x ⊓ y) = toH8 x ⊓ toH8 y := by
  cases x <;> cases y <;> decide

theorem map_sup (x y : Z6PlusChain3) : toH8 (x ⊔ y) = toH8 x ⊔ toH8 y := by
  cases x <;> cases y <;> decide

theorem map_himp (x y : Z6PlusChain3) : toH8 (x ⇨ y) = toH8 x ⇨ toH8 y := by
  cases x <;> cases y <;> decide

theorem map_compl (x : Z6PlusChain3) : toH8 xᶜ = (toH8 x)ᶜ := by
  cases x <;> decide

theorem map_le {x y : Z6PlusChain3} : (toH8 x ≤ toH8 y) ↔ x ≤ y := by
  cases x <;> cases y <;> decide

theorem le_trans_map (a b c : Z6PlusChain3) (hab : a ≤ b) (hbc : b ≤ c) : a ≤ c :=
  (map_le).mp (le_trans ((map_le).mpr hab) ((map_le).mpr hbc))

theorem le_antisymm_map (a b : Z6PlusChain3) (hab : a ≤ b) (hba : b ≤ a) : a = b := by
  have heq : toH8 a = toH8 b := le_antisymm ((map_le).mpr hab) ((map_le).mpr hba)
  rw [← right_toFrom a, heq, right_toFrom b]

instance : PartialOrder Z6PlusChain3 where
  le := (· ≤ ·)
  lt := (· < ·)
  le_refl       := fun x       => by cases x <;> decide
  le_trans      := le_trans_map
  le_antisymm   := le_antisymm_map
  lt_iff_le_not_ge := fun _ _  => Iff.rfl

instance : SemilatticeInf Z6PlusChain3 where
  inf           := (· ⊓ ·)
  inf_le_left   := fun a b     => by cases a <;> cases b <;> decide
  inf_le_right  := fun a b     => by cases a <;> cases b <;> decide
  le_inf        := fun a b c   => by cases a <;> cases b <;> cases c <;> decide

instance : SemilatticeSup Z6PlusChain3 where
  sup           := (· ⊔ ·)
  le_sup_left   := fun a b     => by cases a <;> cases b <;> decide
  le_sup_right  := fun a b     => by cases a <;> cases b <;> decide
  sup_le        := fun a b c   => by cases a <;> cases b <;> cases c <;> decide

instance : Lattice Z6PlusChain3 where
  __ := (inferInstance : SemilatticeInf Z6PlusChain3)
  __ := (inferInstance : SemilatticeSup Z6PlusChain3)

instance : DistribLattice Z6PlusChain3 where
  le_sup_inf    := fun a b c   => by cases a <;> cases b <;> cases c <;> decide

instance : BoundedOrder Z6PlusChain3 where
  top := z_top
  bot := z_one
  le_top a := by cases a <;> decide
  bot_le a := by cases a <;> decide

theorem le_himp_iff (a b c : Z6PlusChain3) : a ≤ b ⇨ c ↔ a ⊓ b ≤ c := by
  cases a <;> cases b <;> cases c <;> decide

instance heytingAlgebra : HeytingAlgebra Z6PlusChain3 :=
  HeytingAlgebra.ofHImp himpFun le_himp_iff

theorem card : Fintype.card Z6PlusChain3 = 8 := rfl

def toOrderIso : Z6PlusChain3 ≃o H8 where
  toFun := toH8
  invFun := fromH8
  left_inv := right_toFrom
  right_inv := left_toFrom
  map_rel_iff' := map_le

/-! ## Lower part: `Div12 = Z_6` below the glue point -/

def fromDiv12 : Div12 → Z6PlusChain3
  | Div12.one    => z_one
  | Div12.two    => z_two
  | Div12.three  => z_three
  | Div12.four   => z_four
  | Div12.six    => z_six
  | Div12.twelve => z_glue

theorem fromDiv12_map_le {a b : Div12} : fromDiv12 a ≤ fromDiv12 b ↔ a ≤ b := by
  cases a <;> cases b <;> decide

/-- **`Z6PlusChain3 ≅ H8` [K].**  Citkin's gluing equals the enumeration witness. -/
def isoH8 : Z6PlusChain3 ≃o H8 := toOrderIso

/-- The transported Heyting operations agree with those of `H8` on all pairs. -/
theorem z6_plus_chain3_eq_h8 :
    (∀ x y : Z6PlusChain3, toH8 (x ⊓ y) = toH8 x ⊓ toH8 y) ∧
    (∀ x y : Z6PlusChain3, toH8 (x ⊔ y) = toH8 x ⊔ toH8 y) ∧
    (∀ x y : Z6PlusChain3, toH8 (x ⇨ y) = toH8 x ⇨ toH8 y) ∧
    (∀ x, toH8 xᶜ = (toH8 x)ᶜ) :=
  ⟨map_inf, map_sup, map_himp, map_compl⟩

end Z6PlusChain3

end FalseWork.Lattice.Examples
