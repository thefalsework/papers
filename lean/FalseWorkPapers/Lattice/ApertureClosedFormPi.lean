/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# Theorem 5.1 for any number of prime chains (the r > 2 iteration)

Kernel-checks the aperture closed form on finite products of finite
bounded chains indexed by an arbitrary finite type — every divisor
lattice, every number of primes, every kernel.  This closes the gap
left by `ApertureClosedForm.lean`, whose assembly was binary
(`Fin (a+1) × Fin (b+1)`, the two-prime case).

The mathematical reason this iteration is cheap: the inclusion–
exclusion never grows with the number of chains.  The two events are
"all coordinates world-dense" and "all coordinates world-regular"
whether there are two chains or twenty, so the assembled identity keeps
the shape |Ap(k)| + ∏D + ∏R = ∏N + ∏DR, and the per-chain counts are
the ones already kernel-checked.

* **Pi factorization.**  Nuclei on `Π i, α i` are exactly the
  componentwise families (`nucleusPiEquiv`), by the same argument as
  the binary case: `x = ⨅ i, update ⊤ i (x i)`, finite-meet
  preservation, and inflation pinning the `⊤` coordinates.

* **Pi coordinate-locality.**  `WorldDense`/`WorldRegular` on a
  componentwise nucleus are coordinatewise (`worldDense_piMap_iff`,
  `worldRegular_piMap_iff`) — implication and bottom on a Pi Heyting
  algebra are pointwise.

* **Pi assembly.**  `aperture_card_add_eq_pi`: for finite Heyting
  algebras `α i` and kernel `k`,
  |Ap(k)| + ∏ᵢ Dᵢ + ∏ᵢ Rᵢ = ∏ᵢ Nᵢ + ∏ᵢ DRᵢ  (additive form, in ℕ).

* **The closed form on chains.**  `aperture_closed_form_pi`: on
  `Π i : Fin r, Fin (a i + 1)` — the exponent lattice of
  `Div(p₁^{a₁} ⋯ p_r^{a_r})` — the paper's Theorem 5.1 verbatim, over ℤ:
  |Ap(k)| = 2^{Σaᵢ} − ∏((2^{kᵢ}−1)·2^{aᵢ−kᵢ}+1) − ∏(2^{aᵢ−kᵢ}+2^{kᵢ}−1)
            + 2^{Σkᵢ}.

* **The correction witnesses, kernel-checked.**  The v0.3 correction
  (paper Result 6.3) found the old latency rule wrong in both
  directions; both counterexamples are now theorems:
  Div180 = 2²·3²·5, element 30 = (1,1,1): aperture **4** (the rule said
  it could not be latent); Div8 = 2³, elements 2 and 4: aperture **0**
  (the rule said they must be).  The Div12 cross-check from the binary
  file is reproduced through the Pi theorem for consistency.
-/
import FalseWorkPapers.Lattice.ApertureClosedForm
import Mathlib.Data.Fin.VecNotation

set_option linter.unusedSectionVars false

namespace FalseWork.Lattice

/-- Decidable order on finite Pi types, fixed once for the whole file
so that every statement below bakes the *same* instance term (the
assembly theorem and its instantiations must agree syntactically for
the final `linear_combination` to see one atom). -/
local instance piDecidableLE {ι : Type*} [Fintype ι] {α : ι → Type*}
    [∀ i, Preorder (α i)] [∀ i, DecidableLE (α i)] :
    DecidableLE (∀ i, α i) := fun x y =>
  inferInstanceAs (Decidable (∀ i, x i ≤ y i))

/-! ## Finite-meet preservation for nuclei -/

section FinsetInf

variable {H : Type*} [SemilatticeInf H] [OrderTop H]

/-- A nucleus preserves finite infima (from binary meets and `j ⊤ = ⊤`). -/
theorem IsNucleus.map_finset_inf {j : H → H} (hj : IsNucleus j)
    {β : Type*} [DecidableEq β] (s : Finset β) (f : β → H) :
    j (s.inf f) = s.inf fun b => j (f b) := by
  induction s using Finset.induction_on with
  | empty => simpa using hj.map_top
  | insert a s _ ih => rw [Finset.inf_insert, Finset.inf_insert, hj.2.2, ih]

end FinsetInf

/-! ## Pi factorization: nuclei on `Π i, α i` are componentwise -/

section PiFactorization

variable {ι : Type*} [Fintype ι] [DecidableEq ι]
  {α : ι → Type*} [∀ i, SemilatticeInf (α i)] [∀ i, OrderTop (α i)]

/-- Componentwise families of nuclei are nuclei on the Pi type
(the easy direction, mirroring `IsNucleus.prodMap`). -/
theorem IsNucleus.piMap {jP : ∀ i, α i → α i} (h : ∀ i, IsNucleus (jP i)) :
    IsNucleus (fun x : ∀ i, α i => fun i => jP i (x i)) :=
  ⟨fun x i => (h i).1 (x i),
   fun x => funext fun i => (h i).2.1 (x i),
   fun x y => funext fun i => (h i).2.2 (x i) (y i)⟩

/-- The `i`-th component of a nucleus on a Pi type:
`jᵢ a = (j (update ⊤ i a)) i`, the Pi analogue of `nucleusFst`. -/
def nucleusProj (j : (∀ i, α i) → ∀ i, α i) (i : ι) : α i → α i :=
  fun a => j (Function.update ⊤ i a) i

/-- Pointwise evaluation of the canonical meet-decomposition:
`(⨅ i, update ⊤ i (y i)) k = y k`. -/
theorem inf_update_apply (y : ∀ i, α i) (k : ι) :
    Finset.univ.inf (fun i => Function.update ⊤ i (y i)) k = y k := by
  rw [Finset.inf_apply]
  refine le_antisymm ?_ ?_
  · exact (Finset.inf_le (Finset.mem_univ k)).trans (by simp)
  · refine Finset.le_inf fun i _ => ?_
    rcases eq_or_ne k i with rfl | hki
    · simp
    · simp [Function.update_of_ne hki]

/-- Every element of a finite Pi type is the meet of its coordinate
cylinders: `x = ⨅ i, update ⊤ i (x i)`.  The Pi analogue of
`(a, b) = (a, ⊤) ⊓ (⊤, b)`. -/
theorem pi_eq_inf_update (x : ∀ i, α i) :
    x = Finset.univ.inf (fun i => Function.update ⊤ i (x i)) :=
  funext fun k => (inf_update_apply x k).symm

variable {j : (∀ i, α i) → ∀ i, α i}

/-- Inflation pins every coordinate of `j (update ⊤ i a)` except the
`i`-th at `⊤` — the Pi analogue of `IsNucleus.apply_fst_top`. -/
theorem IsNucleus.apply_update_top (hj : IsNucleus j) (i : ι) (a : α i) :
    j (Function.update ⊤ i a) = Function.update ⊤ i (nucleusProj j i a) := by
  funext k
  rcases eq_or_ne k i with rfl | hk
  · simp [nucleusProj]
  · have h1 : (⊤ : α k) ≤ j (Function.update ⊤ i a) k := by
      have h2 := Pi.le_def.mp (hj.1 (Function.update ⊤ i a)) k
      rwa [Function.update_of_ne hk, Pi.top_apply] at h2
    rw [Function.update_of_ne hk, Pi.top_apply]
    exact le_antisymm le_top h1

/-- Each component of a nucleus on a Pi type is a nucleus. -/
theorem IsNucleus.proj (hj : IsNucleus j) (i : ι) :
    IsNucleus (nucleusProj j i) := by
  refine ⟨fun a => ?_, fun a => ?_, fun a b => ?_⟩
  · have h := Pi.le_def.mp (hj.1 (Function.update ⊤ i a)) i
    rwa [Function.update_self] at h
  · calc nucleusProj j i (nucleusProj j i a)
        = j (Function.update ⊤ i (nucleusProj j i a)) i := rfl
      _ = j (j (Function.update ⊤ i a)) i := by
          rw [← hj.apply_update_top i a]
      _ = j (Function.update ⊤ i a) i := by rw [hj.2.1]
      _ = nucleusProj j i a := rfl
  · have hupd : Function.update (⊤ : ∀ i, α i) i (a ⊓ b)
        = Function.update ⊤ i a ⊓ Function.update ⊤ i b := by
      funext m
      rcases eq_or_ne m i with rfl | hm
      · simp
      · simp [Function.update_of_ne hm]
    show j (Function.update ⊤ i (a ⊓ b)) i = _
    rw [hupd, hj.2.2]
    rfl

/-- **The Pi factorization identity**: a nucleus on a finite Pi type
acts componentwise.  Proof: decompose into coordinate cylinders,
preserve the finite meet, pin the `⊤` coordinates, recompose. -/
theorem IsNucleus.eq_piMap (hj : IsNucleus j) (x : ∀ i, α i) :
    j x = fun i => nucleusProj j i (x i) := by
  conv_lhs => rw [pi_eq_inf_update x, hj.map_finset_inf]
  have hcong : (Finset.univ.inf fun i => j (Function.update ⊤ i (x i)))
      = Finset.univ.inf fun i => Function.update ⊤ i (nucleusProj j i (x i)) :=
    Finset.inf_congr rfl fun i _ => hj.apply_update_top i (x i)
  rw [hcong]
  exact funext fun k => inf_update_apply (fun i => nucleusProj j i (x i)) k

/-- **Nuclei on a finite Pi type are exactly the componentwise
families** — Step 1 of the closed form, iterated to any arity in one
step.  This is what makes every count in the assembly a product. -/
def nucleusPiEquiv :
    {j : (∀ i, α i) → ∀ i, α i // IsNucleus j}
      ≃ ∀ i, {jc : α i → α i // IsNucleus jc} where
  toFun j i := ⟨nucleusProj j.1 i, j.2.proj i⟩
  invFun p := ⟨fun x i => (p i).1 (x i), IsNucleus.piMap fun i => (p i).2⟩
  left_inv j := Subtype.ext (funext fun x => (j.2.eq_piMap x).symm)
  right_inv p := by
    funext i
    refine Subtype.ext (funext fun a => ?_)
    show (p i).1 (Function.update ⊤ i a i) = (p i).1 a
    rw [Function.update_self]

end PiFactorization

/-! ## Pi coordinate-locality of the world predicates -/

section WorldPi

variable {ι : Type*} {α : ι → Type*} [∀ i, HeytingAlgebra (α i)]

theorem worldDense_piMap_iff (jP : ∀ i, α i → α i) (k : ∀ i, α i) :
    WorldDense (fun x : ∀ i, α i => fun i => jP i (x i)) k ↔
      ∀ i, WorldDense (jP i) (k i) := by
  unfold WorldDense
  rw [funext_iff]
  exact forall_congr' fun i => by simp [Pi.himp_apply]

theorem worldRegular_piMap_iff (jP : ∀ i, α i → α i) (k : ∀ i, α i) :
    WorldRegular (fun x : ∀ i, α i => fun i => jP i (x i)) k ↔
      ∀ i, WorldRegular (jP i) (k i) := by
  unfold WorldRegular
  rw [funext_iff]
  exact forall_congr' fun i => by simp [Pi.himp_apply]

end WorldPi

/-! ## Counting helpers -/

section CountingHelpers

/-- Complement split for subtype cardinalities (additive form). -/
theorem card_subtype_add_card_subtype_not {γ : Type*} [Fintype γ]
    (P : γ → Prop) [DecidablePred P] :
    Fintype.card {x // P x} + Fintype.card {x // ¬P x} = Fintype.card γ := by
  rw [Fintype.card_subtype, Fintype.card_subtype, ← Finset.card_univ]
  exact Finset.card_filter_add_card_filter_not ..

/-- Inclusion–exclusion for subtype cardinalities (additive form). -/
theorem card_subtype_or_add_card_subtype_and {γ : Type*} [Fintype γ]
    (P Q : γ → Prop) [DecidablePred P] [DecidablePred Q] :
    Fintype.card {x // P x ∨ Q x} + Fintype.card {x // P x ∧ Q x}
      = Fintype.card {x // P x} + Fintype.card {x // Q x} := by
  classical
  simp only [Fintype.card_subtype]
  rw [Finset.filter_or, Finset.filter_and]
  exact Finset.card_union_add_card_inter _ _

/-- A coordinatewise predicate on a finite Pi type counts as the
product of the per-coordinate counts. -/
theorem card_pi_subtype_forall {ι : Type*} [Fintype ι] [DecidableEq ι]
    {γ : ι → Type*} [∀ i, Fintype (γ i)]
    (Q : ∀ i, γ i → Prop) [∀ i, DecidablePred (Q i)] :
    Fintype.card {p : ∀ i, γ i // ∀ i, Q i (p i)}
      = ∏ i, Fintype.card {x : γ i // Q i x} := by
  rw [Fintype.card_congr (Equiv.subtypePiEquivPi (p := Q)), Fintype.card_pi]

end CountingHelpers

/-! ## Assembly: inclusion–exclusion on any finite product of finite
Heyting algebras

The two events stay "all coordinates dense" and "all coordinates
regular" regardless of arity, so the identity keeps the binary shape
with products in place of the binary products. -/

section PiAssembly

variable {ι : Type*} [Fintype ι] [DecidableEq ι]
  {α : ι → Type*} [∀ i, HeytingAlgebra (α i)]
  [∀ i, Fintype (α i)] [∀ i, DecidableEq (α i)] [∀ i, DecidableLE (α i)]

/-- **Inclusion–exclusion for the aperture on a finite Pi product
(additive form).**  |Ap(k)| + ∏D + ∏R = ∏N + ∏DR.  With the chain
counts this becomes Theorem 5.1 for any number of prime chains. -/
theorem aperture_card_add_eq_pi (k : ∀ i, α i) :
    Fintype.card {j : (∀ i, α i) → ∀ i, α i // IsNucleus j ∧ Opens j k}
      + (∏ i, Fintype.card
          {jc : α i → α i // IsNucleus jc ∧ WorldDense jc (k i)})
      + (∏ i, Fintype.card
          {jc : α i → α i // IsNucleus jc ∧ WorldRegular jc (k i)})
      = (∏ i, Fintype.card {jc : α i → α i // IsNucleus jc})
      + (∏ i, Fintype.card {jc : α i → α i //
          IsNucleus jc ∧ (WorldDense jc (k i) ∧ WorldRegular jc (k i))}) := by
  classical
  -- membership transfer: Opens on the product = ¬(all dense) ∧ ¬(all regular)
  have key : ∀ j : {j : (∀ i, α i) → ∀ i, α i // IsNucleus j},
      Opens j.1 k ↔
        (¬∀ i, WorldDense ((nucleusPiEquiv j) i).1 (k i)) ∧
        (¬∀ i, WorldRegular ((nucleusPiEquiv j) i).1 (k i)) := by
    intro j
    have hfun : j.1 = fun x : ∀ i, α i => fun i => nucleusProj j.1 i (x i) :=
      funext j.2.eq_piMap
    conv_lhs => rw [hfun]
    rw [opens_iff_world, worldDense_piMap_iff, worldRegular_piMap_iff]
    exact Iff.rfl
  have e1 : {j : (∀ i, α i) → ∀ i, α i // IsNucleus j ∧ Opens j k}
      ≃ {p : ∀ i, {jc : α i → α i // IsNucleus jc} //
          (¬∀ i, WorldDense ((p i)).1 (k i)) ∧
          (¬∀ i, WorldRegular ((p i)).1 (k i))} :=
    (Equiv.subtypeSubtypeEquivSubtypeInter _ _).symm.trans
      (nucleusPiEquiv.subtypeEquiv
        (q := fun p => (¬∀ i, WorldDense ((p i)).1 (k i)) ∧
          (¬∀ i, WorldRegular ((p i)).1 (k i))) key)
  have hAp : Fintype.card
        {j : (∀ i, α i) → ∀ i, α i // IsNucleus j ∧ Opens j k}
      = Fintype.card {p : ∀ i, {jc : α i → α i // IsNucleus jc} //
          (¬∀ i, WorldDense ((p i)).1 (k i)) ∧
          (¬∀ i, WorldRegular ((p i)).1 (k i))} :=
    Fintype.card_congr e1
  -- complement split: (¬PD ∧ ¬PR) + (PD ∨ PR) = all
  have hsplit : Fintype.card {p : ∀ i, {jc : α i → α i // IsNucleus jc} //
        (¬∀ i, WorldDense ((p i)).1 (k i)) ∧
        (¬∀ i, WorldRegular ((p i)).1 (k i))}
      + Fintype.card {p : ∀ i, {jc : α i → α i // IsNucleus jc} //
          (∀ i, WorldDense ((p i)).1 (k i)) ∨
          (∀ i, WorldRegular ((p i)).1 (k i))}
      = Fintype.card (∀ i, {jc : α i → α i // IsNucleus jc}) := by
    have h1 : Fintype.card {p : ∀ i, {jc : α i → α i // IsNucleus jc} //
          (¬∀ i, WorldDense ((p i)).1 (k i)) ∧
          (¬∀ i, WorldRegular ((p i)).1 (k i))}
        = Fintype.card {p : ∀ i, {jc : α i → α i // IsNucleus jc} //
            ¬((∀ i, WorldDense ((p i)).1 (k i)) ∨
              (∀ i, WorldRegular ((p i)).1 (k i)))} :=
      Fintype.card_congr (Equiv.subtypeEquivRight fun p => not_or.symm)
    rw [h1, Nat.add_comm]
    exact card_subtype_add_card_subtype_not _
  -- inclusion–exclusion: (PD ∨ PR) + (PD ∧ PR) = PD + PR
  have hie : Fintype.card {p : ∀ i, {jc : α i → α i // IsNucleus jc} //
        (∀ i, WorldDense ((p i)).1 (k i)) ∨
        (∀ i, WorldRegular ((p i)).1 (k i))}
      + Fintype.card {p : ∀ i, {jc : α i → α i // IsNucleus jc} //
          (∀ i, WorldDense ((p i)).1 (k i)) ∧
          (∀ i, WorldRegular ((p i)).1 (k i))}
      = Fintype.card {p : ∀ i, {jc : α i → α i // IsNucleus jc} //
          ∀ i, WorldDense ((p i)).1 (k i)}
      + Fintype.card {p : ∀ i, {jc : α i → α i // IsNucleus jc} //
          ∀ i, WorldRegular ((p i)).1 (k i)} :=
    card_subtype_or_add_card_subtype_and _ _
  -- the four product counts
  have hN : Fintype.card (∀ i, {jc : α i → α i // IsNucleus jc})
      = ∏ i, Fintype.card {jc : α i → α i // IsNucleus jc} :=
    Fintype.card_pi
  have hD : Fintype.card {p : ∀ i, {jc : α i → α i // IsNucleus jc} //
        ∀ i, WorldDense ((p i)).1 (k i)}
      = ∏ i, Fintype.card
          {jc : α i → α i // IsNucleus jc ∧ WorldDense jc (k i)} :=
    (card_pi_subtype_forall fun i (x : {jc : α i → α i // IsNucleus jc}) =>
        WorldDense x.1 (k i)).trans
      (Finset.prod_congr rfl fun i _ =>
        Fintype.card_congr (Equiv.subtypeSubtypeEquivSubtypeInter
          (fun jc : α i → α i => IsNucleus jc)
          (fun jc => WorldDense jc (k i))))
  have hR : Fintype.card {p : ∀ i, {jc : α i → α i // IsNucleus jc} //
        ∀ i, WorldRegular ((p i)).1 (k i)}
      = ∏ i, Fintype.card
          {jc : α i → α i // IsNucleus jc ∧ WorldRegular jc (k i)} :=
    (card_pi_subtype_forall fun i (x : {jc : α i → α i // IsNucleus jc}) =>
        WorldRegular x.1 (k i)).trans
      (Finset.prod_congr rfl fun i _ =>
        Fintype.card_congr (Equiv.subtypeSubtypeEquivSubtypeInter
          (fun jc : α i → α i => IsNucleus jc)
          (fun jc => WorldRegular jc (k i))))
  have hDR : Fintype.card {p : ∀ i, {jc : α i → α i // IsNucleus jc} //
        (∀ i, WorldDense ((p i)).1 (k i)) ∧
        (∀ i, WorldRegular ((p i)).1 (k i))}
      = ∏ i, Fintype.card {jc : α i → α i //
          IsNucleus jc ∧ (WorldDense jc (k i) ∧ WorldRegular jc (k i))} :=
    (Fintype.card_congr (Equiv.subtypeEquivRight fun p => forall_and.symm)).trans
      ((card_pi_subtype_forall fun i (x : {jc : α i → α i // IsNucleus jc}) =>
          WorldDense x.1 (k i) ∧ WorldRegular x.1 (k i)).trans
        (Finset.prod_congr rfl fun i _ =>
          Fintype.card_congr (Equiv.subtypeSubtypeEquivSubtypeInter
            (fun jc : α i → α i => IsNucleus jc)
            (fun jc => WorldDense jc (k i) ∧ WorldRegular jc (k i)))))
  omega

end PiAssembly

/-! ## Theorem 5.1 on any finite family of chains -/

section PiChains

local instance (n : ℕ) : BiheytingAlgebra (Fin (n + 1)) :=
  LinearOrder.toBiheytingAlgebra (Fin (n + 1))

/-- Per-chain nucleus count over ℤ. -/
private theorem chainN_int (m : ℕ) :
    (Fintype.card {jc : Fin (m + 1) → Fin (m + 1) // IsNucleus jc} : ℤ)
      = 2 ^ m := by
  have h := card_nuclei_chain (α := Fin (m + 1))
  rw [fin_card_nontop] at h
  exact_mod_cast h

/-- Per-chain world-dense count over ℤ. -/
private theorem chainD_int (m : ℕ) (e : Fin (m + 1)) :
    (Fintype.card {jc : Fin (m + 1) → Fin (m + 1) //
        IsNucleus jc ∧ WorldDense jc e} : ℤ)
      = (2 ^ (e : ℕ) - 1) * 2 ^ (m - (e : ℕ)) + 1 := by
  have h := card_worldDense_add (α := Fin (m + 1)) e
  rw [fin_card_above, fin_card_nontop] at h
  have hz : (Fintype.card {jc : Fin (m + 1) → Fin (m + 1) //
      IsNucleus jc ∧ WorldDense jc e} : ℤ) + 2 ^ (m - (e : ℕ))
      = 2 ^ m + 1 := by exact_mod_cast h
  have hsplit : (2 : ℤ) ^ m = 2 ^ (e : ℕ) * 2 ^ (m - (e : ℕ)) := by
    rw [← pow_add]
    congr 1
    omega
  rw [hsplit] at hz
  linear_combination hz

/-- Per-chain world-regular count over ℤ. -/
private theorem chainR_int (m : ℕ) (e : Fin (m + 1)) :
    (Fintype.card {jc : Fin (m + 1) → Fin (m + 1) //
        IsNucleus jc ∧ WorldRegular jc e} : ℤ)
      = 2 ^ (m - (e : ℕ)) + 2 ^ (e : ℕ) - 1 := by
  have h := card_worldRegular_add (α := Fin (m + 1)) e
  rw [fin_card_above, fin_card_below] at h
  have hz : (Fintype.card {jc : Fin (m + 1) → Fin (m + 1) //
      IsNucleus jc ∧ WorldRegular jc e} : ℤ) + 1
      = 2 ^ (m - (e : ℕ)) + 2 ^ (e : ℕ) := by exact_mod_cast h
  linear_combination hz

/-- Per-chain dense-and-regular count over ℤ. -/
private theorem chainDR_int (m : ℕ) (e : Fin (m + 1)) :
    (Fintype.card {jc : Fin (m + 1) → Fin (m + 1) //
        IsNucleus jc ∧ (WorldDense jc e ∧ WorldRegular jc e)} : ℤ)
      = 2 ^ (e : ℕ) := by
  have h := card_worldDenseRegular (α := Fin (m + 1)) e
  rw [fin_card_below] at h
  exact_mod_cast h

/-- **Theorem 5.1, all divisor lattices (kernel-checked).**  On the
exponent lattice `Π i : Fin r, Fin (a i + 1)` of
`Div(p₁^{a₁} ⋯ p_r^{a_r})`, the aperture of the kernel
`k = (k₁, …, k_r)` — the divisor `∏ pᵢ^{kᵢ}` — has size

  `2^{Σ aᵢ} − ∏ᵢ((2^{kᵢ}−1)·2^{aᵢ−kᵢ}+1) − ∏ᵢ(2^{aᵢ−kᵢ}+2^{kᵢ}−1)
   + 2^{Σ kᵢ}`

for **any** number of primes `r`, any exponents, any kernel — the
paper's formula with no arity restriction.  The two-prime theorem
`aperture_closed_form_exponents` is the `r = 2` face of this one. -/
theorem aperture_closed_form_pi {r : ℕ} (a : Fin r → ℕ)
    (k : ∀ i, Fin (a i + 1)) :
    (Fintype.card {j : (∀ i, Fin (a i + 1)) → ∀ i, Fin (a i + 1) //
        IsNucleus j ∧ Opens j k} : ℤ)
      = 2 ^ (∑ i, a i)
        - ∏ i, ((2 ^ ((k i : ℕ)) - 1) * 2 ^ (a i - (k i : ℕ)) + 1)
        - ∏ i, (2 ^ (a i - (k i : ℕ)) + 2 ^ ((k i : ℕ)) - 1)
        + 2 ^ (∑ i, (k i : ℕ)) := by
  have hmain := aperture_card_add_eq_pi (α := fun i => Fin (a i + 1)) k
  have hmainZ := congrArg (fun n : ℕ => (n : ℤ)) hmain
  push_cast at hmainZ
  have hN : (∏ i, (Fintype.card
        {jc : Fin (a i + 1) → Fin (a i + 1) // IsNucleus jc} : ℤ))
      = 2 ^ (∑ i, a i) := by
    rw [← Finset.prod_pow_eq_pow_sum]
    exact Finset.prod_congr rfl fun i _ => chainN_int (a i)
  have hD : (∏ i, (Fintype.card {jc : Fin (a i + 1) → Fin (a i + 1) //
        IsNucleus jc ∧ WorldDense jc (k i)} : ℤ))
      = ∏ i, ((2 ^ ((k i : ℕ)) - 1) * 2 ^ (a i - (k i : ℕ)) + 1) :=
    Finset.prod_congr rfl fun i _ => chainD_int (a i) (k i)
  have hR : (∏ i, (Fintype.card {jc : Fin (a i + 1) → Fin (a i + 1) //
        IsNucleus jc ∧ WorldRegular jc (k i)} : ℤ))
      = ∏ i, (2 ^ (a i - (k i : ℕ)) + 2 ^ ((k i : ℕ)) - 1) :=
    Finset.prod_congr rfl fun i _ => chainR_int (a i) (k i)
  have hDR : (∏ i, (Fintype.card {jc : Fin (a i + 1) → Fin (a i + 1) //
        IsNucleus jc ∧ (WorldDense jc (k i) ∧ WorldRegular jc (k i))} : ℤ))
      = 2 ^ (∑ i, (k i : ℕ)) := by
    rw [← Finset.prod_pow_eq_pow_sum]
    exact Finset.prod_congr rfl fun i _ => chainDR_int (a i) (k i)
  rw [hN, hD, hR, hDR] at hmainZ
  linear_combination hmainZ

end PiChains

/-! ## The correction witnesses of v0.3, kernel-checked

Result 6.3 of the paper: the original latency rule ("latent iff every
exponent strictly interior") failed in both directions, and both
counterexamples were found in the paper's own verification data.  Both
are now instances of the closed form, certified by the kernel. -/

section CorrectionWitnesses

local instance (n : ℕ) : BiheytingAlgebra (Fin (n + 1)) :=
  LinearOrder.toBiheytingAlgebra (Fin (n + 1))

/-- **Div180 = 2²·3²·5, element 30 = (1,1,1): aperture 4.**  The old
rule predicted 0 (the 5-exponent sits at its chain top, so 30 is not
all-interior); enumeration found 4, and the closed form now certifies
it.  The kernel-checked witness of the v0.3 correction. -/
example :
    (Fintype.card {j : (∀ i : Fin 3, Fin (![2, 2, 1] i + 1)) →
        ∀ i : Fin 3, Fin (![2, 2, 1] i + 1) //
        IsNucleus j ∧ Opens j
          (fun i => (⟨1, by fin_cases i <;> norm_num⟩ :
            Fin (![2, 2, 1] i + 1)))} : ℤ) = 4 := by
  rw [aperture_closed_form_pi]
  decide

/-- **Div8 = 2³, element 2 = (1): aperture 0.**  The old rule called
this latent (its only exponent is strictly interior); a single chain
has no second coordinate to break density with, so the aperture is
empty.  The other direction of the v0.3 correction. -/
example :
    (Fintype.card {j : (∀ i : Fin 1, Fin (![3] i + 1)) →
        ∀ i : Fin 1, Fin (![3] i + 1) //
        IsNucleus j ∧ Opens j
          (fun i => (⟨1, by fin_cases i; norm_num⟩ :
            Fin (![3] i + 1)))} : ℤ) = 0 := by
  rw [aperture_closed_form_pi]
  decide

/-- Div8, element 4 = (2): aperture 0, same failure direction. -/
example :
    (Fintype.card {j : (∀ i : Fin 1, Fin (![3] i + 1)) →
        ∀ i : Fin 1, Fin (![3] i + 1) //
        IsNucleus j ∧ Opens j
          (fun i => (⟨2, by fin_cases i; norm_num⟩ :
            Fin (![3] i + 1)))} : ℤ) = 0 := by
  rw [aperture_closed_form_pi]
  decide

/-- Consistency with the binary development: Div12's kernel `2 = (1,0)`
through the Pi theorem gives 1, matching `aperture_two_complete` and
the two-chain closed form. -/
example :
    (Fintype.card {j : (∀ i : Fin 2, Fin (![2, 1] i + 1)) →
        ∀ i : Fin 2, Fin (![2, 1] i + 1) //
        IsNucleus j ∧ Opens j
          (fun i => (⟨![1, 0] i, by fin_cases i <;> norm_num⟩ :
            Fin (![2, 1] i + 1)))} : ℤ) = 1 := by
  rw [aperture_closed_form_pi]
  decide

end CorrectionWitnesses

end FalseWork.Lattice
