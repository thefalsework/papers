/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# Nuclei on finite products factor componentwise

Step 1 of the aperture closed form (`preprints/aperture/paper.md` §5,
Theorem 5.1).  The aperture note derives a closed form for the number of
nuclei under which an element of a divisor lattice is *ordinary in the
nucleus's world*; the derivation rests on one structural lemma — every
nucleus on a product `A × B` is a product of nuclei on the factors — plus
coordinate-locality of density/regularity and elementary chain counting.
This file kernel-checks that structural lemma in full generality.

The proof is the four-line argument from the paper: for a nucleus `j` on
`A × B`,

* `(a, b) = (a, ⊤) ⊓ (⊤, b)`, so meet-preservation gives
  `j (a, b) = j (a, ⊤) ⊓ j (⊤, b)`;
* inflation pins the `⊤` coordinates: `j (a, ⊤) = (j₁ a, ⊤)` and
  `j (⊤, b) = (⊤, j₂ b)` where `j₁ a := (j (a, ⊤)).1`,
  `j₂ b := (j (⊤, b)).2`;
* hence `j (a, b) = (j₁ a, j₂ b)`, and `j₁`, `j₂` inherit the three
  nucleus laws coordinatewise.

Conversely every product of nuclei is a nucleus (`IsNucleus.prodMap`),
so the nuclei on `A × B` are *exactly* the componentwise pairs — which
is why nucleus counts multiply over chain-product factors in every
enumeration reported in `wolfram/aperture-closed-form.mjs`.

## Main results

* `IsNucleus` — general nucleus predicate (inflationary, idempotent,
  binary-meet-preserving), on any meet-semilattice.
* `IsNucleus.monotone`, `IsNucleus.map_top`, `IsNucleus.fix_inf`,
  `IsNucleus.le_of_fix` — basic facts: monotonicity, ⊤ fixed, fix-sets
  meet-closed, `j a` is the least fixed point above `a`.
* `IsNucleus.prodMap` — products of nuclei are nuclei.
* `IsNucleus.fst`/`IsNucleus.snd` — the components of a product nucleus
  are nuclei.
* `IsNucleus.eq_prodMap` — every nucleus on `A × B` acts componentwise.
* `nucleus_prod_iff` — the bundled characterization.
* `Opens` — the aperture membership predicate of the paper's
  Definition 3.1, stated on any Heyting algebra.

## Cross-reference

* `Examples/DivisorLattice12Nucleus.lean` — the concrete Div12 nucleus
  anchors this generalizes.
* `Examples/ApertureAnchors.lean` — decide-checked aperture instances:
  the Div12 anchors of `wolfram/aperture-prototype.wl` and the latent
  ordinariness witness on the 3×3 chain product (Div36).
* `wolfram/aperture-closed-form.mjs` — the closed form this lemma
  underwrites, verified on all 164 elements of 15 divisor lattices.
-/
import Mathlib.Order.Heyting.Basic
import Mathlib.Data.Fintype.Basic

namespace FalseWork.Lattice

/-! ## The general nucleus predicate -/

variable {H : Type*}

/-- A **nucleus**: an inflationary, idempotent, binary-meet-preserving
operator.  (Monotonicity follows from meet-preservation,
`IsNucleus.monotone`.)  On the subobject lattice of a topos these are
exactly the traces of Lawvere–Tierney topologies; here only the
meet-semilattice structure is assumed. -/
def IsNucleus [SemilatticeInf H] (j : H → H) : Prop :=
  (∀ a, a ≤ j a) ∧
  (∀ a, j (j a) = j a) ∧
  (∀ a b, j (a ⊓ b) = j a ⊓ j b)

namespace IsNucleus

variable [SemilatticeInf H] {j : H → H}

theorem monotone (hj : IsNucleus j) : Monotone j := by
  intro a b hab
  have h : a ⊓ b = a := inf_eq_left.mpr hab
  calc j a = j (a ⊓ b) := by rw [h]
    _ = j a ⊓ j b := hj.2.2 a b
    _ ≤ j b := inf_le_right

theorem map_top [OrderTop H] (hj : IsNucleus j) : j ⊤ = ⊤ :=
  le_antisymm le_top (hj.1 ⊤)

/-- Fix-sets are closed under binary meets. -/
theorem fix_inf (hj : IsNucleus j) {a b : H} (ha : j a = a) (hb : j b = b) :
    j (a ⊓ b) = a ⊓ b := by
  rw [hj.2.2, ha, hb]

/-- `j a` is the **least** fixed point above `a`: any fixed point above
`a` is above `j a`.  This is what makes the Moore-family enumeration in
the computational layer sound. -/
theorem le_of_fix (hj : IsNucleus j) {a f : H} (hf : j f = f) (haf : a ≤ f) :
    j a ≤ f := by
  calc j a ≤ j f := hj.monotone haf
    _ = f := hf

end IsNucleus

/-! ## Products of nuclei are nuclei -/

variable {A B : Type*} [SemilatticeInf A] [SemilatticeInf B]

/-- The componentwise product of two nuclei is a nucleus on the product. -/
theorem IsNucleus.prodMap {jA : A → A} {jB : B → B}
    (hA : IsNucleus jA) (hB : IsNucleus jB) :
    IsNucleus (fun p : A × B => (jA p.1, jB p.2)) := by
  refine ⟨fun p => ⟨hA.1 p.1, hB.1 p.2⟩, fun p => ?_, fun p q => ?_⟩
  · exact Prod.ext (hA.2.1 p.1) (hB.2.1 p.2)
  · exact Prod.ext (hA.2.2 p.1 q.1) (hB.2.2 p.2 q.2)

/-! ## Every nucleus on a product factors componentwise -/

section Factorization

variable [OrderTop A] [OrderTop B]

/-- First component of a nucleus on a product: `j₁ a = (j (a, ⊤)).1`. -/
def nucleusFst (j : A × B → A × B) : A → A := fun a => (j (a, ⊤)).1

/-- Second component of a nucleus on a product: `j₂ b = (j (⊤, b)).2`. -/
def nucleusSnd (j : A × B → A × B) : B → B := fun b => (j (⊤, b)).2

variable {j : A × B → A × B}

omit [OrderTop A] in
/-- Inflation pins the second coordinate of `j (a, ⊤)` at `⊤`. -/
theorem IsNucleus.apply_fst_top (hj : IsNucleus j) (a : A) :
    j (a, ⊤) = (nucleusFst j a, ⊤) :=
  Prod.ext rfl (le_antisymm le_top (hj.1 (a, ⊤)).2)

omit [OrderTop B] in
/-- Inflation pins the first coordinate of `j (⊤, b)` at `⊤`. -/
theorem IsNucleus.apply_snd_top (hj : IsNucleus j) (b : B) :
    j (⊤, b) = (⊤, nucleusSnd j b) :=
  Prod.ext (le_antisymm le_top (hj.1 (⊤, b)).1) rfl

/-- **The factorization identity**: a nucleus on a product acts
componentwise.  The whole proof is `(a, b) = (a, ⊤) ⊓ (⊤, b)` plus
meet-preservation plus the pinned coordinates. -/
theorem IsNucleus.eq_prodMap (hj : IsNucleus j) (p : A × B) :
    j p = (nucleusFst j p.1, nucleusSnd j p.2) := by
  have hsplit : p = (p.1, ⊤) ⊓ ((⊤ : A), p.2) := by
    ext <;> simp
  calc j p = j ((p.1, ⊤) ⊓ ((⊤ : A), p.2)) := by rw [← hsplit]
    _ = j (p.1, ⊤) ⊓ j ((⊤ : A), p.2) := hj.2.2 _ _
    _ = (nucleusFst j p.1, ⊤) ⊓ ((⊤ : A), nucleusSnd j p.2) := by
        rw [hj.apply_fst_top, hj.apply_snd_top]
    _ = (nucleusFst j p.1, nucleusSnd j p.2) := by ext <;> simp

omit [OrderTop A] in
/-- The first component of a nucleus on a product is a nucleus. -/
theorem IsNucleus.fst (hj : IsNucleus j) : IsNucleus (nucleusFst j) := by
  refine ⟨fun a => (hj.1 (a, ⊤)).1, fun a => ?_, fun a b => ?_⟩
  · have h := hj.apply_fst_top a
    calc nucleusFst j (nucleusFst j a)
        = (j (nucleusFst j a, ⊤)).1 := rfl
      _ = (j (j (a, ⊤))).1 := by rw [h]
      _ = (j (a, ⊤)).1 := by rw [hj.2.1]
      _ = nucleusFst j a := rfl
  · have h : ((a ⊓ b : A), (⊤ : B)) = (a, (⊤ : B)) ⊓ (b, (⊤ : B)) := by
      ext <;> simp
    calc nucleusFst j (a ⊓ b)
        = (j ((a ⊓ b : A), (⊤ : B))).1 := rfl
      _ = (j (a, (⊤ : B)) ⊓ j (b, (⊤ : B))).1 := by rw [h, hj.2.2]
      _ = nucleusFst j a ⊓ nucleusFst j b := rfl

omit [OrderTop B] in
/-- The second component of a nucleus on a product is a nucleus. -/
theorem IsNucleus.snd (hj : IsNucleus j) : IsNucleus (nucleusSnd j) := by
  refine ⟨fun b => (hj.1 (⊤, b)).2, fun b => ?_, fun a b => ?_⟩
  · have h := hj.apply_snd_top b
    calc nucleusSnd j (nucleusSnd j b)
        = (j ((⊤ : A), nucleusSnd j b)).2 := rfl
      _ = (j (j (⊤, b))).2 := by rw [h]
      _ = (j (⊤, b)).2 := by rw [hj.2.1]
      _ = nucleusSnd j b := rfl
  · have h : ((⊤ : A), (a ⊓ b : B)) = ((⊤ : A), a) ⊓ ((⊤ : A), b) := by
      ext <;> simp
    calc nucleusSnd j (a ⊓ b)
        = (j ((⊤ : A), (a ⊓ b : B))).2 := rfl
      _ = (j ((⊤ : A), a) ⊓ j ((⊤ : A), b)).2 := by rw [h, hj.2.2]
      _ = nucleusSnd j a ⊓ nucleusSnd j b := rfl

/-- **Nuclei on a finite product are exactly the componentwise pairs.**
Forward: the components of a nucleus are nuclei and reconstruct it.
Backward: `IsNucleus.prodMap`.  This is Step 1 of the aperture closed
form (paper §5, Theorem 5.1) and the reason nucleus counts multiply
over chain-product factors in every enumeration. -/
theorem nucleus_prod_iff (j : A × B → A × B) :
    IsNucleus j ↔
      ∃ (jA : A → A) (jB : B → B), IsNucleus jA ∧ IsNucleus jB ∧
        ∀ p : A × B, j p = (jA p.1, jB p.2) := by
  constructor
  · intro hj
    exact ⟨nucleusFst j, nucleusSnd j, hj.fst, hj.snd, hj.eq_prodMap⟩
  · rintro ⟨jA, jB, hA, hB, hfun⟩
    have : j = fun p : A × B => (jA p.1, jB p.2) := funext hfun
    rw [this]
    exact hA.prodMap hB

end Factorization

/-! ## The aperture membership predicate -/

/-- **`j` opens `k`** (paper Definition 3.1): the image `j k` is ordinary
*inside the world `Fix j`* — non-dense and non-regular with respect to
the world's bottom `j ⊥`.  The implication used is the ambient `⇨`,
which for arguments in `Fix j` agrees with the world's own implication
(fix-sets of nuclei inherit implication; Johnstone, cited in the paper
as [C]).  The aperture of `k` is `{ j | IsNucleus j ∧ Opens j k }`. -/
def Opens [HeytingAlgebra H] (j : H → H) (k : H) : Prop :=
  (j k ⇨ j ⊥) ≠ j ⊥ ∧ ((j k ⇨ j ⊥) ⇨ j ⊥) ≠ j k

/-! ## Transport along structure-preserving bijections

A hand-rolled algebra (like the `Div12` inductive) and its exponent
lattice (a chain product) are the same Heyting algebra presented twice.
These lemmas move nuclei and aperture membership across such a
presentation change, so that completeness statements can be *decided*
on the chain product — where the factorization theorem collapses the
search space to componentwise pairs — and then *transported* to the
hand-rolled type.  No new mathematical content: only conjugation
`j ↦ e ∘ j ∘ f` along a bijection whose structure-preservation facts
are themselves decidable on the finite algebras. -/

section Transport

variable {K : Type*}

/-- Conjugating a nucleus by an inf-preserving bijection yields a
nucleus.  `e : H → K` and `f : K → H` are mutually inverse;
monotonicity of `e` and inf-preservation of both directions are the
only structure needed. -/
theorem IsNucleus.conj [SemilatticeInf H] [SemilatticeInf K]
    {e : H → K} {f : K → H}
    (hfe : ∀ a, f (e a) = a) (hef : ∀ p, e (f p) = p)
    (hmono : ∀ a b : H, a ≤ b → e a ≤ e b)
    (hinf_f : ∀ p q : K, f (p ⊓ q) = f p ⊓ f q)
    (hinf_e : ∀ a b : H, e (a ⊓ b) = e a ⊓ e b)
    {j : H → H} (hj : IsNucleus j) :
    IsNucleus (fun p : K => e (j (f p))) := by
  refine ⟨fun p => ?_, fun p => ?_, fun p q => ?_⟩
  · calc p = e (f p) := (hef p).symm
      _ ≤ e (j (f p)) := hmono _ _ (hj.1 (f p))
  · show e (j (f (e (j (f p))))) = e (j (f p))
    rw [hfe, hj.2.1]
  · show e (j (f (p ⊓ q))) = e (j (f p)) ⊓ e (j (f q))
    rw [hinf_f, hj.2.2, hinf_e]

/-- Aperture membership transports along a himp-and-bot-preserving
bijection: if `j` opens `k` in `H`, the conjugate `e ∘ j ∘ f` opens
`e k` in `K`. -/
theorem Opens.conj [HeytingAlgebra H] [HeytingAlgebra K]
    {e : H → K} {f : K → H}
    (hfe : ∀ a, f (e a) = a)
    (hhimp : ∀ a b : H, e (a ⇨ b) = e a ⇨ e b)
    (hbot : f (⊥ : K) = ⊥)
    {j : H → H} {k : H} (h : Opens j k) :
    Opens (fun p : K => e (j (f p))) (e k) := by
  have hinj : ∀ a b : H, e a = e b → a = b := fun a b hab => by
    have h2 := congrArg f hab
    rwa [hfe, hfe] at h2
  refine ⟨?_, ?_⟩
  · show (e (j (f (e k))) ⇨ e (j (f ⊥))) ≠ e (j (f ⊥))
    rw [hfe, hbot, ← hhimp]
    exact fun hc => h.1 (hinj _ _ hc)
  · show ((e (j (f (e k))) ⇨ e (j (f ⊥))) ⇨ e (j (f ⊥))) ≠ e (j (f (e k)))
    rw [hfe, hbot, ← hhimp, ← hhimp]
    exact fun hc => h.2 (hinj _ _ hc)

end Transport

/-! ## Decidability on finite algebras (for `decide`-style anchors) -/

instance [SemilatticeInf H] [Fintype H] [DecidableEq H] [DecidableLE H]
    (j : H → H) : Decidable (IsNucleus j) :=
  inferInstanceAs (Decidable
    ((∀ a, a ≤ j a) ∧ (∀ a, j (j a) = j a) ∧ (∀ a b, j (a ⊓ b) = j a ⊓ j b)))

instance [HeytingAlgebra H] [DecidableEq H] (j : H → H) (k : H) :
    Decidable (Opens j k) :=
  inferInstanceAs (Decidable
    ((j k ⇨ j ⊥) ≠ j ⊥ ∧ ((j k ⇨ j ⊥) ⇨ j ⊥) ≠ j k))

end FalseWork.Lattice
