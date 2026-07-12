/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# The substitution monoid of a one-generated Heyting algebra

Almeida's pointer, formalized.  The endomorphisms of a Heyting algebra
form a monoid under composition; for a *one-generated* algebra every
endomorphism is a **substitution** (determined by where it sends the
generator), and the monoid identity is pinned down *order-theoretically*
by the four-position kernel law:

> **the identity is the unique endomorphism fixing the unique ordinary
> element.**

Two layers, mirroring the repo's abstract/concrete discipline:

## Abstract (any one-generated `H`)

* `heytingHom_map_nishimuraTerm`: homs commute with the Rieger–Nishimura
  term sequence — `f xₙ(g) = xₙ(f g)`.  Substitution acts on the ladder
  index-wise.
* `heytingHom_ext_of_generated`: two homs out of a one-generated algebra
  agreeing on the generator agree everywhere.  End(H) embeds into `H` by
  evaluation at `g`.
* `heytingHom_eq_id_iff`: an endomorphism is the identity iff it fixes
  the generator.
* `endo_eq_id_iff_fixes_kernel`: with `g` ordinary, an endomorphism is
  the identity iff it fixes every element at which all four cells are
  inhabited — and by `nishimura_kernel_unique_of_generated` there is
  exactly one such element, `g` itself.  The monoid structure and the
  partition's non-degeneracy pin the same point.

## Concrete (`Div12 = Z₆`, the music lattice)

* `Div12.subst b` — the substitution `x ↦ x[g := b]`, given by the
  six-entry table `⊥, b, ¬b, ¬¬b, b ∨ ¬b, ⊤`.
* `Div12.substHom b` — each substitution IS a Heyting endomorphism
  (kernel-checked), and `Div12.endo_eq_substHom` shows **every**
  endomorphism arises this way, uniquely (`Div12.endo_bijection`):
  `End(Z₆) ≅ Z₆` as sets, six endomorphisms in all.
* `Div12.substHom_comp`: composition corresponds to the substitution
  product `(b, c) ↦ subst b c`, with identity laws and associativity
  kernel-checked — the full monoid table.
* `Div12.substHom_eq_id_iff`: the identity of End(Z₆) is exactly the
  substitution at the unique kernel (the tritone).
* `Div12.subst_kernel_iff`: no non-identity endomorphism preserves
  ordinariness — composing with any other substitution lands the kernel
  in a degenerate cell.
* `Div12.subst_cube` (Ruitenburg instance): every endomorphism satisfies
  `f³ = f` — iteration stabilizes with period ≤ 2 after one step, the
  one-variable case of Ruitenburg's theorem, kernel-checked at `Z₆`.
* `Div12.subst_idem_iff`: the only non-idempotent substitution is the
  one at `¬g` (it swaps with `¬¬g`); `Div12.subst_unit_iff`: the group
  of units is trivial.
-/
import Mathlib.Order.Heyting.Hom
import FalseWorkPapers.Examples.NishimuraNormalForm

namespace FalseWork.Lattice

/-! ## 1. Abstract: endomorphisms of a one-generated Heyting algebra -/

section EndoDetermination

variable {H : Type*} [HeytingAlgebra H] {K : Type*} [HeytingAlgebra K]

/-- **Homs commute with the Nishimura term sequence**: `f xₙ(g) = xₙ(f g)`.
A Heyting hom transports the whole Rieger–Nishimura ladder over `g` onto
the ladder over `f g`, index by index — substitution acts ladder-to-ladder. -/
theorem heytingHom_map_nishimuraTerm (f : HeytingHom H K) (g : H) :
    ∀ n : ℕ, f (nishimuraTerm g n) = nishimuraTerm (f g) n := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    match n with
    | 0 => simp only [nishimuraTerm, map_bot]
    | 1 => simp only [nishimuraTerm, map_compl]
    | 2 => simp only [nishimuraTerm]
    | 3 => simp only [nishimuraTerm, map_compl]
    | 4 => simp only [nishimuraTerm, map_sup, map_compl]
    | (m + 5) =>
      by_cases hm : m % 2 = 0
      · simp only [nishimuraTerm, hm, if_true]
        rw [map_himp, ih (m + 3) (by omega), ih (m + 2) (by omega)]
      · simp only [nishimuraTerm, hm, if_false]
        rw [map_sup, ih (m + 2) (by omega), ih (m + 3) (by omega)]

/-- **Evaluation at the generator is injective on homs.**  Two Heyting homs
out of a one-generated algebra agreeing on the generator agree everywhere:
induction over the generated subalgebra, one Heyting operation at a time. -/
theorem heytingHom_ext_of_generated {f₁ f₂ : HeytingHom H K} {g : H}
    (hgen : ∀ y : H, GeneratedBy g y) (h : f₁ g = f₂ g) : f₁ = f₂ := by
  ext y
  induction hgen y with
  | gen => exact h
  | top => rw [map_top, map_top]
  | bot => rw [map_bot, map_bot]
  | sup _ _ ihx ihy => rw [map_sup, map_sup, ihx, ihy]
  | inf _ _ ihx ihy => rw [map_inf, map_inf, ihx, ihy]
  | himp _ _ ihx ihy => rw [map_himp, map_himp, ihx, ihy]
  | compl _ ihx => rw [map_compl, map_compl, ihx]

/-- An endomorphism of a one-generated Heyting algebra is the identity iff
it fixes the generator. -/
theorem heytingHom_eq_id_iff {g : H} (hgen : ∀ y : H, GeneratedBy g y)
    (f : HeytingHom H H) :
    f = HeytingHom.id H ↔ f g = g := by
  constructor
  · rintro rfl; rfl
  · intro h
    exact heytingHom_ext_of_generated hgen (h.trans rfl)

/-- **The monoid identity is pinned by the kernel.**  For a one-generated
Heyting algebra with ordinary generator, an endomorphism is the identity of
End(H) iff it fixes every element at which all four cells of the partition
are inhabited.  By `nishimura_kernel_unique_of_generated` there is exactly
one such element — the generator — so the order-theoretic non-degeneracy
condition and the monoid structure single out the same point. -/
theorem endo_eq_id_iff_fixes_kernel (g : H) (h1 : gᶜ ≠ ⊥) (h2 : gᶜᶜ ≠ g)
    (hgen : ∀ y : H, GeneratedBy g y) (f : HeytingHom H H) :
    f = HeytingHom.id H ↔ ∀ a : H, AllFourCellsInhabited a → f a = a := by
  constructor
  · rintro rfl a _; rfl
  · intro h
    have hker : AllFourCellsInhabited g :=
      (nishimura_kernel_unique_of_generated g h1 h2 hgen g).mpr rfl
    exact heytingHom_ext_of_generated hgen (h g hker)

end EndoDetermination

/-! ## 2. Concrete: `End(Z₆) ≅ Z₆`, the music lattice's six substitutions -/

namespace Examples

namespace Div12

/-- **The substitution `x ↦ x[g := b]`** on the music lattice: each of the
six elements is a term in the tritone generator (`tritone_generates`), and
`subst b` re-evaluates that term at `b`.  The table is forced:
`⊥ ↦ ⊥`, `g ↦ b`, `¬g ↦ ¬b`, `¬¬g ↦ ¬¬b`, `g ∨ ¬g ↦ b ∨ ¬b`, `⊤ ↦ ⊤`. -/
def subst (b : Div12) : Div12 → Div12
  | one    => ⊥
  | two    => b
  | three  => bᶜ
  | four   => bᶜᶜ
  | six    => b ⊔ bᶜ
  | twelve => ⊤

private theorem subst_map_sup :
    ∀ b x y : Div12, subst b (x ⊔ y) = subst b x ⊔ subst b y := by decide

private theorem subst_map_inf :
    ∀ b x y : Div12, subst b (x ⊓ y) = subst b x ⊓ subst b y := by decide

private theorem subst_map_himp :
    ∀ b x y : Div12, subst b (x ⇨ y) = subst b x ⇨ subst b y := by decide

/-- **Every substitution is a Heyting endomorphism** — the six candidate
maps all respect `⊓`, `⊔`, `⇨`, `⊥` (kernel-checked over all 6·6·6
argument triples).  In particular the truncation congruence that carves
`Z₆` out of the free algebra is preserved by every substitution. -/
def substHom (b : Div12) : HeytingHom Div12 Div12 where
  toFun := subst b
  map_sup' := subst_map_sup b
  map_inf' := subst_map_inf b
  map_bot' := rfl
  map_himp' := subst_map_himp b

@[simp]
theorem substHom_apply (b x : Div12) : substHom b x = subst b x := rfl

/-- Evaluating a substitution at the generator recovers the substituted
element: `substHom b (g) = b`. -/
@[simp]
theorem substHom_gen (b : Div12) : substHom b two = b := rfl

/-- **Every endomorphism of the music lattice is a substitution**,
determined by its value at the tritone generator: `f = substHom (f g)`.
Case-by-case: each element is a Heyting term in `g`, and a hom must
commute with each operation. -/
theorem endo_eq_substHom (f : HeytingHom Div12 Div12) :
    f = substHom (f two) := by
  ext x
  cases x with
  | one =>
      rw [show (one : Div12) = ⊥ from rfl, map_bot]; rfl
  | two => rfl
  | three =>
      rw [show (three : Div12) = twoᶜ from by decide, map_compl]; rfl
  | four =>
      rw [show (four : Div12) = twoᶜᶜ from by decide, map_compl, map_compl]; rfl
  | six =>
      rw [show (six : Div12) = two ⊔ twoᶜ from by decide, map_sup, map_compl]; rfl
  | twelve =>
      rw [show (twelve : Div12) = ⊤ from rfl, map_top]; rfl

/-- `substHom` is injective: distinct elements give distinct
endomorphisms (evaluate at the generator). -/
theorem substHom_injective : Function.Injective substHom := by
  intro b c h
  have := DFunLike.congr_fun h two
  simpa using this

/-- **`End(Z₆) ≅ Z₆` as sets**: every endomorphism is `substHom b` for a
*unique* `b`.  The music lattice has exactly six endomorphisms — the same
"one-generated freeness at cardinality 6" that drives the normal form. -/
theorem endo_bijection (f : HeytingHom Div12 Div12) :
    ∃! b : Div12, f = substHom b := by
  refine ⟨f two, endo_eq_substHom f, fun c h => ?_⟩
  rw [h]; rfl

/-- **Composition is the substitution product**: `φ_b ∘ φ_c = φ_{subst b c}`
(evaluate the composite at the generator and apply the classification).
`(b, c) ↦ subst b c` is thus the multiplication of End(Z₆) transported to
the six elements. -/
theorem substHom_comp (b c : Div12) :
    (substHom b).comp (substHom c) = substHom (subst b c) :=
  endo_eq_substHom _

/-- Left identity of the substitution product: substituting *into* the
generator's own term does nothing — `subst g x = x`. -/
theorem subst_id_left : ∀ x : Div12, subst two x = x := by decide

/-- Right identity: `subst b g = b`. -/
theorem subst_id_right : ∀ b : Div12, subst b two = b := by decide

/-- Associativity of the substitution product (kernel-checked over all
216 triples) — with the identity laws, `(Z₆, subst, g)` is a monoid,
isomorphic to End(Z₆) under `substHom`. -/
theorem subst_assoc :
    ∀ a b c : Div12, subst (subst a b) c = subst a (subst b c) := by decide

/-- **The identity of End(Z₆) is the substitution at the unique kernel.**
`substHom b` is the identity iff all four cells are inhabited at `b` —
iff `b` is the tritone.  The monoid identity and the partition's unique
non-degeneracy point coincide. -/
theorem substHom_eq_id_iff (b : Div12) :
    substHom b = HeytingHom.id Div12 ↔ AllFourCellsInhabited b := by
  rw [kernel_unique b]
  constructor
  · intro h
    have := DFunLike.congr_fun h two
    simpa using this
  · rintro rfl
    ext x
    cases x <;> rfl

/-- **No non-identity endomorphism preserves ordinariness**: the image of
the kernel under `substHom b` is ordinary iff `b` is the kernel itself.
Every proper substitution lands the tritone in a degenerate cell. -/
theorem subst_kernel_iff :
    ∀ b : Div12, AllFourCellsInhabited (subst b two) ↔ b = two := by decide

/-- **Ruitenburg's theorem at `Z₆`** (one-variable instance): every
endomorphism satisfies `f³ = f`.  In substitution-product form:
`subst b (subst b b) = b` for all six `b` — iteration of any substitution
stabilizes with period at most 2 after a single step. -/
theorem subst_cube : ∀ b : Div12, subst b (subst b b) = b := by decide

/-- Iterated composition form of `subst_cube`: `φ_b ∘ φ_b ∘ φ_b = φ_b`. -/
theorem substHom_cube (b : Div12) :
    (substHom b).comp ((substHom b).comp (substHom b)) = substHom b := by
  rw [substHom_comp, substHom_comp, subst_cube]

/-- The idempotents of End(Z₆) are all substitutions except the one at
`¬g`, which swaps with `¬¬g` (period exactly 2). -/
theorem subst_idem_iff : ∀ b : Div12, subst b b = b ↔ b ≠ three := by decide

/-- The group of units of End(Z₆) is trivial: only the identity is
invertible.  (The free algebra's automorphism group is trivial; its
truncation inherits this.) -/
theorem subst_unit_iff :
    ∀ b : Div12, (∃ c, subst b c = two ∧ subst c b = two) ↔ b = two := by
  decide

/-- **The abstract law, instantiated at the music lattice**: an
endomorphism of `Div12` is the identity iff it fixes every ordinary
element (of which the tritone is the only one). -/
theorem endo_id_iff_fixes_kernel (f : HeytingHom Div12 Div12) :
    f = HeytingHom.id Div12 ↔ ∀ a : Div12, AllFourCellsInhabited a → f a = a :=
  endo_eq_id_iff_fixes_kernel two (by decide) (by decide)
    tritone_generates f

end Div12

end Examples

end FalseWork.Lattice
