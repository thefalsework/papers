/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# Aperture anchors: Div12 observer facts and the latent-ordinariness witness

Kernel-checked instances for the aperture note
(`preprints/aperture/paper.md`).  The **aperture** of an element `k` is
the set of nuclei `j` under which `j k` is ordinary *inside the world
`Fix j`* (with the world's bottom `j ⊥`); membership is the predicate
`FalseWork.Lattice.Opens` of `Lattice/NucleusFactorization.lean`.

Two groups of results, all discharged by `decide` on hand-rolled or
chain-product finite Heyting algebras:

* **Div12 anchors** — the four PASS lines that
  `wolfram/aperture-prototype.wl` prints against Lean expectations:
  the identity opens the kernel `two` (it is ambient-ordinary); the
  tritone nucleus does *not* open it (in its own world the kernel has
  become the bottom, and bottoms are regular — paper Remark 3.3); the
  double-negation observer sees no four-fold (its world is Boolean);
  the blind observer `const ⊤` sees nothing.

* **The latent-ordinariness witness (paper Result 6.1)** — on the 3×3
  chain product (the exponent lattice of Div36 = 2²·3², with
  `6 = 2¹·3¹ ↦ ((1 : Fin 3), (1 : Fin 3))`), the element `6` is *not*
  ambient-ordinary, yet two explicit proper nuclei open it.  **Some
  distinctions exist only at a blur** is hereby a kernel-checked
  existence statement, not only an enumeration result.  (That these
  two nuclei are the *only* members of Ap(6) — aperture size exactly
  2 — remains [computed], from the exhaustive enumerations in
  `wolfram/aperture-closed-form.mjs` and the Wolfram Cloud runs.)

Also included: `opens_id_iff_isOrdinary`, the formal form of paper
Remark 3.4 — the identity observer opens exactly the ambient-ordinary
elements.
-/
import FalseWorkPapers.Lattice.NucleusFactorization
import FalseWorkPapers.Examples.NishimuraKernelLaw
import FalseWorkPapers.Examples.DivisorLattice12Nucleus
import Mathlib.Order.Fin.Basic

namespace FalseWork.Lattice.Examples

open FalseWork.Lattice

/-! ## Remark 3.4, formally: identity opens exactly the ordinary elements -/

/-- The identity nucleus opens `k` iff `k` is ordinary in the ambient
algebra.  (`Opens` is stated with `⇨ ⊥`; `IsOrdinary` with `ᶜ`; they
agree by `himp_bot`, with the conjuncts swapped.) -/
theorem opens_id_iff_isOrdinary {H : Type*} [HeytingAlgebra H] (k : H) :
    Opens (id : H → H) k ↔ IsOrdinary k := by
  simp only [Opens, id_eq, himp_bot, IsOrdinary]
  exact and_comm

/-! ## Div12 anchors (the four PASS lines of `aperture-prototype.wl`) -/

namespace Div12Anchors

open Div12 (two tritoneNucleus)

local instance : DecidableLE Div12 := Div12.decLE

/-- The identity observer on Div12. -/
theorem identity_isNucleus : IsNucleus (id : Div12 → Div12) := by decide

/-- The identity opens the kernel `two`: full resolution sees the
four-fold (equivalently, `two` is ambient-ordinary). -/
theorem identity_opens_two : Opens (id : Div12 → Div12) two := by decide

/-- The general `IsNucleus` agrees with the file-local predicate of
`DivisorLattice12Nucleus.lean` on Div12 — same three laws. -/
theorem isNucleus_iff (j : Div12 → Div12) :
    IsNucleus j ↔ Div12.IsNucleus j := Iff.rfl

/-- **The tritone nucleus does not open the kernel** (paper Remark 3.3):
in its own world the kernel image `tritoneNucleus ⊥ = two` *is* the
world's bottom, and bottoms are regular.  This coexists with the
ambient fact `tritoneNucleus_bot_non_regular` — the two statements ask
ordinariness in different algebras, and both are true. -/
theorem tritoneNucleus_not_opens_two :
    ¬ Opens tritoneNucleus two := by decide

/-- The double-negation observer on Div12. -/
def doubleNeg : Div12 → Div12 := fun a => aᶜᶜ

theorem doubleNeg_isNucleus : IsNucleus doubleNeg := by decide

/-- The fully reduced (Boolean) observer sees no four-fold anywhere:
double negation does not open the kernel. -/
theorem doubleNeg_not_opens_two : ¬ Opens doubleNeg two := by decide

/-- The blind observer (one-point world). -/
def constTop : Div12 → Div12 := fun _ => ⊤

theorem constTop_isNucleus : IsNucleus constTop := by decide

theorem constTop_not_opens_two : ¬ Opens constTop two := by decide

/-- **The Div12 aperture anchors, bundled** — the exact expectations the
Wolfram prototype prints as PASS/FAIL. -/
theorem aperture_anchors :
    IsNucleus (id : Div12 → Div12) ∧ Opens (id : Div12 → Div12) two ∧
    ¬ Opens tritoneNucleus two ∧
    ¬ Opens doubleNeg two ∧
    ¬ Opens constTop two :=
  ⟨identity_isNucleus, identity_opens_two, tritoneNucleus_not_opens_two,
   doubleNeg_not_opens_two, constTop_not_opens_two⟩

end Div12Anchors

/-! ## The latent-ordinariness witness (paper Result 6.1) -/

section Latent

/-- The 3-element chain `{0 < 1 < 2}` as a Heyting algebra (linear
orders with bounds are biheyting; Mathlib's `LinearOrder.toBiheytingAlgebra`). -/
local instance : BiheytingAlgebra (Fin 3) := LinearOrder.toBiheytingAlgebra (Fin 3)

/-- Div36 = 2²·3² as its exponent lattice: the chain product C₃ × C₃.
The divisor `2^i·3^j` is the pair `(i, j)`. -/
abbrev Div36E := Fin 3 × Fin 3

local instance : DecidableLE Div36E := fun p q =>
  decidable_of_iff ((p.1 ≤ q.1) ∧ (p.2 ≤ q.2)) Prod.le_def.symm

/-- The element `6 = 2¹·3¹`. -/
def sixE : Div36E := (1, 1)

/-- Blur one chain: merge `0` into `1` (fix-set `{1, 2}`; the induced
nucleus of the Moore family).  On the divisor side this is the observer
whose world is `{2, 4, 6, 12, 18, 36}` (respectively
`{3, 6, 9, 12, 18, 36}` on the other factor). -/
def blur3 : Fin 3 → Fin 3 := fun i => if i = 0 then 1 else i

/-- Blur the 2-chain factor, keep the 3-chain factor sharp. -/
def jLeft : Div36E → Div36E := fun p => (blur3 p.1, p.2)

/-- Keep the 2-chain factor sharp, blur the 3-chain factor. -/
def jRight : Div36E → Div36E := fun p => (p.1, blur3 p.2)

theorem jLeft_isNucleus : IsNucleus jLeft := by decide

theorem jRight_isNucleus : IsNucleus jRight := by decide

/-- Both witnesses are proper coarse-grainings, not the identity. -/
theorem jLeft_ne_id : jLeft ≠ id := by decide

theorem jRight_ne_id : jRight ≠ id := by decide

/-- `6` is **not** ordinary at full resolution: the identity does not
open it (it is dense — both exponents are positive). -/
theorem six_not_ambient_ordinary : ¬ Opens (id : Div36E → Div36E) sixE := by
  decide

theorem jLeft_opens_six : Opens jLeft sixE := by decide

theorem jRight_opens_six : Opens jRight sixE := by decide

/-- **Latent ordinariness exists (kernel-checked).**  On the exponent
lattice of Div36 there is an element — `6` — that no full-resolution
observer sees as ordinary, together with two distinct proper nuclei
that each open it.  "Some distinctions exist only at a blur" is a
theorem, not a slogan. -/
theorem latent_ordinariness_witness :
    ¬ Opens (id : Div36E → Div36E) sixE ∧
    IsNucleus jLeft ∧ IsNucleus jRight ∧
    jLeft ≠ id ∧ jRight ≠ id ∧ jLeft ≠ jRight ∧
    Opens jLeft sixE ∧ Opens jRight sixE :=
  ⟨six_not_ambient_ordinary, jLeft_isNucleus, jRight_isNucleus,
   jLeft_ne_id, jRight_ne_id, by decide, jLeft_opens_six, jRight_opens_six⟩

/-- **Completeness: Ap(6) = {jLeft, jRight} exactly (kernel-checked).**

Enumerating all `9⁹` self-maps of the product is infeasible for the
kernel, and unnecessary: by the factorization theorem
(`nucleus_prod_iff`) every nucleus on `C₃ × C₃` is a componentwise pair,
so it suffices to decide the claim over the `3³ × 3³ = 729` pairs of
factor maps.  This is the paper's Step 1 doing in the proof assistant
exactly the work it does in the counting argument (paper §5,
Theorem 5.1): the general lemma collapses the search space, `decide`
sweeps what remains.  The aperture of the latent element is exactly 2. -/
private theorem aperture_six_complete_pairs :
    ∀ jA jB : Fin 3 → Fin 3, IsNucleus jA → IsNucleus jB →
      Opens (fun p : Div36E => (jA p.1, jB p.2)) sixE →
      (∀ p : Div36E, (jA p.1, jB p.2) = jLeft p) ∨
      (∀ p : Div36E, (jA p.1, jB p.2) = jRight p) := by decide

theorem aperture_six_complete :
    ∀ j : Div36E → Div36E, IsNucleus j → Opens j sixE →
      j = jLeft ∨ j = jRight := by
  intro j hj hopen
  obtain ⟨jA, jB, hA, hB, hfun⟩ := (nucleus_prod_iff j).mp hj
  have hj_eq : j = fun p => (jA p.1, jB p.2) := funext hfun
  rw [hj_eq] at hopen ⊢
  rcases aperture_six_complete_pairs jA jB hA hB hopen with h | h
  · exact Or.inl (funext fun p => h p)
  · exact Or.inr (funext fun p => h p)

end Latent

/-! ## Completeness on Div12: Ap(2) = {identity} (paper Result 4.1)

Deciding this directly over all `6⁶ = 46656` self-maps of the
hand-rolled `Div12` is infeasible for the kernel (enumerated functions
evaluate through list machinery).  The rigorous route is the same one
the paper takes: Div12 = 2²·3 *is* the chain product C₃ × C₂ presented
differently.  We decide completeness on the exponent lattice — where
the factorization theorem collapses the search to `3³ · 2² = 108`
componentwise pairs — and transport it across the explicit exponent
isomorphism, every structure-preservation fact of which is itself
decided. -/

namespace Div12Completeness

open Div12 (two)

local instance : BiheytingAlgebra (Fin 3) := LinearOrder.toBiheytingAlgebra (Fin 3)
local instance : BiheytingAlgebra (Fin 2) := LinearOrder.toBiheytingAlgebra (Fin 2)

/-- Div12 = 2²·3 as its exponent lattice: the chain product C₃ × C₂.
The divisor `2^i·3^j` is the pair `(i, j)`. -/
abbrev Div12E := Fin 3 × Fin 2

local instance : DecidableLE Div12E := fun p q =>
  decidable_of_iff ((p.1 ≤ q.1) ∧ (p.2 ≤ q.2)) Prod.le_def.symm

local instance : DecidableLE Div12 := Div12.decLE

/-- The exponent map `2^i·3^j ↦ (i, j)`. -/
def toE : Div12 → Div12E
  | Div12.one    => (0, 0)
  | Div12.two    => (1, 0)
  | Div12.three  => (0, 1)
  | Div12.four   => (2, 0)
  | Div12.six    => (1, 1)
  | Div12.twelve => (2, 1)

/-- The inverse of the exponent map. -/
def ofE : Div12E → Div12 := fun p =>
  match p with
  | (0, 0) => Div12.one
  | (1, 0) => Div12.two
  | (2, 0) => Div12.four
  | (0, 1) => Div12.three
  | (1, 1) => Div12.six
  | (2, 1) => Div12.twelve

/-- The kernel `two = 2¹·3⁰` on the exponent side. -/
def twoE : Div12E := (1, 0)

/- The isomorphism facts, each decided over the finite algebras. -/
theorem ofE_toE : ∀ a, ofE (toE a) = a := by decide
theorem toE_ofE : ∀ p, toE (ofE p) = p := by decide
theorem toE_mono : ∀ a b : Div12, a ≤ b → toE a ≤ toE b := by decide
theorem toE_inf : ∀ a b : Div12, toE (a ⊓ b) = toE a ⊓ toE b := by decide
theorem toE_himp : ∀ a b : Div12, toE (a ⇨ b) = toE a ⇨ toE b := by decide
theorem ofE_inf : ∀ p q : Div12E, ofE (p ⊓ q) = ofE p ⊓ ofE q := by decide
theorem ofE_bot : ofE (⊥ : Div12E) = ⊥ := by decide
theorem toE_two : toE two = twoE := by decide

/-- The decidable core: over all `108` componentwise pairs on C₃ × C₂,
the only nucleus that opens the kernel is the identity. -/
private theorem aperture_twoE_complete_pairs :
    ∀ (jA : Fin 3 → Fin 3) (jB : Fin 2 → Fin 2),
      IsNucleus jA → IsNucleus jB →
      Opens (fun p : Div12E => (jA p.1, jB p.2)) twoE →
      ∀ p : Div12E, (jA p.1, jB p.2) = p := by decide

/-- **Completeness: Ap(2) = {identity} on Div12 (kernel-checked; paper
Result 4.1).**  Maximal fragility at the threshold: the only nucleus on
Div12 that opens the kernel `two` is the identity.  Every proper
coarse-graining closes the four-fold on the minimal kernel-bearing
algebra.  Proof: conjugate to the exponent lattice C₃ × C₂, factor
componentwise (`nucleus_prod_iff`), decide the 108 remaining pairs,
transport back. -/
theorem aperture_two_complete :
    ∀ j : Div12 → Div12, IsNucleus j → Opens j two → j = id := by
  intro j hj hopen
  have hJnuc : IsNucleus (fun p : Div12E => toE (j (ofE p))) :=
    IsNucleus.conj ofE_toE toE_ofE toE_mono ofE_inf toE_inf hj
  have hJopen : Opens (fun p : Div12E => toE (j (ofE p))) twoE := by
    have h := Opens.conj ofE_toE toE_himp ofE_bot hopen
    rwa [toE_two] at h
  obtain ⟨jA, jB, hA, hB, hfun⟩ := (nucleus_prod_iff _).mp hJnuc
  have hopen' : Opens (fun p : Div12E => (jA p.1, jB p.2)) twoE := by
    rwa [funext hfun] at hJopen
  have hfix : ∀ p : Div12E, toE (j (ofE p)) = p := fun p =>
    (hfun p).trans (aperture_twoE_complete_pairs jA jB hA hB hopen' p)
  funext a
  have h := hfix (toE a)
  rw [ofE_toE] at h
  have h2 := congrArg ofE h
  rwa [ofE_toE, ofE_toE] at h2

end Div12Completeness

/-! ## Status

All theorems total, no `sorry`; every concrete fact is discharged by
`decide` over the finite algebras, with the two completeness theorems
(`aperture_two_complete`, `aperture_six_complete`) obtained by the
factorization theorem collapsing the search space to componentwise
pairs before `decide` sweeps what remains.  Both headline aperture
facts of the paper — Ap(2) = {identity} on Div12 (Result 4.1) and
Ap(6) = {jLeft, jRight} on Div36 (Result 6.1, size exactly 2) — are
now [K], not merely [computed].  The exhaustive enumerations of
`wolfram/aperture-prototype.wl`, `wolfram/aperture-scaling.wl`, and
`wolfram/aperture-closed-form.mjs` remain the [computed] evidence for
the other thirteen lattices and the closed form's 164-element sweep.
-/

end FalseWork.Lattice.Examples
