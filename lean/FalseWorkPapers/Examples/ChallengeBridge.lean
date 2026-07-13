-- `import Mathlib` FIRST and in full: comparator requires the challenge and
-- solution statements to elaborate to identical terms, so this file must see
-- exactly the instance set `Challenge.lean` sees (a selective import changes
-- which `OfNat (Fin _)` instance elaborates the literal `(1, 0)` in
-- `twelve_unique_kernel`, and comparator then rejects the statement match).
import Mathlib
import FalseWorkPapers.Examples.NishimuraNormalForm
import FalseWorkPapers.Examples.LadderCore
import FalseWorkPapers.Examples.WhyTwelve

/-!
# Challenge bridge

Proves the exact statements of `Challenge.lean` (repository root of the Lean
project) from the existing `FalseWork.Lattice` theorems, for verification with
[comparator](https://github.com/leanprover/comparator).

Comparator requires the solution environment to contain declarations with the
same names and statements as the challenge environment. The definitions
`OrdinaryElement`, `HeytingGeneratedBy`, `rnLadder`, `FourRegionsInhabited`
below are therefore **character-for-character copies** of the ones in
`Challenge.lean`; do not edit one without the other. The six theorems then
bridge those Mathlib-vocabulary statements to the project's internal names:

| Challenge theorem | proved from |
|---|---|
| `four_regions_iff_ordinary` | `FalseWork.Lattice.isOrdinary_iff_allFourCells` |
| `nishimura_normal_form` | `FalseWork.Lattice.generatedBy_isLadderValue` |
| `unique_ordinary_element` | `FalseWork.Lattice.nishimura_ordinary_unique` |
| `ordinary_forces_card_ge_six` | `FalseWork.Lattice.ordinary_card_ge_six` |
| `ordinary_gives_z6_embedding` | `FalseWork.Lattice.div12OrderEmbedding` ∘ `Div12.div12OrderIsoChains` |
| `twelve_unique_kernel` | `FalseWork.Lattice.Examples.twelve_kernel_unique` |

The definitional matches (`OrdinaryElement` = `IsOrdinary`,
`FourRegionsInhabited` = `AllFourCellsInhabited` unfolded,
`HeytingGeneratedBy` ≅ `GeneratedBy`, `rnLadder` = `nishimuraTerm`) are
discharged by `exact`-level defeq or by the two explicit lemmas in the
`ChallengeBridge` namespace.

AI-authored (Claude, in Cursor), directed and reviewed by Chris Brink.
-/

variable {H : Type*} [HeytingAlgebra H]

/-- An element of a Heyting algebra is **ordinary** (Citkin's term) if it is
neither *regular* (`aᶜᶜ = a`) nor *dense* (`aᶜ = ⊥`). -/
def OrdinaryElement (a : H) : Prop := aᶜᶜ ≠ a ∧ aᶜ ≠ ⊥

/-- `HeytingGeneratedBy g x`: `x` lies in the Heyting subalgebra generated
by `g` — the closure of `{g}` under `⊤`, `⊥`, `⊔`, `⊓`, `⇨`, and `ᶜ`.
(The `compl` constructor is redundant given `himp` and `bot`, since
`xᶜ = x ⇨ ⊥`; it is kept so the closure reads off the signature directly.) -/
inductive HeytingGeneratedBy (g : H) : H → Prop
  | gen : HeytingGeneratedBy g g
  | top : HeytingGeneratedBy g ⊤
  | bot : HeytingGeneratedBy g ⊥
  | sup {x y} : HeytingGeneratedBy g x → HeytingGeneratedBy g y → HeytingGeneratedBy g (x ⊔ y)
  | inf {x y} : HeytingGeneratedBy g x → HeytingGeneratedBy g y → HeytingGeneratedBy g (x ⊓ y)
  | himp {x y} : HeytingGeneratedBy g x → HeytingGeneratedBy g y → HeytingGeneratedBy g (x ⇨ y)
  | compl {x} : HeytingGeneratedBy g x → HeytingGeneratedBy g xᶜ

/-- The **Rieger–Nishimura ladder** over `g`: the standard enumeration of the
one-variable Heyting terms. Rungs `0`–`4` are `⊥`, `gᶜ`, `g`, `gᶜᶜ`,
`gᶜ ⊔ g`; above that the ladder alternates implication rungs and join rungs. -/
def rnLadder (g : H) : ℕ → H
  | 0 => ⊥
  | 1 => gᶜ
  | 2 => g
  | 3 => gᶜᶜ
  | 4 => gᶜ ⊔ g
  | (n + 5) =>
      if n % 2 = 0 then rnLadder g (n + 3) ⇨ rnLadder g (n + 2)
      else rnLadder g (n + 2) ⊔ rnLadder g (n + 3)

/-- The four regions of a Heyting algebra relative to a fixed element `a` are
all (non-trivially) inhabited:
1. something non-`⊥` lies below `a`;
2. something meets both `a` and `aᶜ` non-trivially;
3. something lies below the double negation `aᶜᶜ` without lying below `a`;
4. something non-`⊥` lies below the pseudocomplement `aᶜ`. -/
def FourRegionsInhabited (a : H) : Prop :=
  (∃ x, x ≠ ⊥ ∧ x ≤ a) ∧
  (∃ x, x ⊓ a ≠ ⊥ ∧ x ⊓ aᶜ ≠ ⊥) ∧
  (∃ x, x ≤ aᶜᶜ ∧ ¬ x ≤ a) ∧
  (∃ x, x ≠ ⊥ ∧ x ≤ aᶜ)

namespace ChallengeBridge

/-- `HeytingGeneratedBy` maps constructor-for-constructor onto the project's
`FalseWork.Lattice.GeneratedBy`. -/
theorem toGeneratedBy {g x : H} (h : HeytingGeneratedBy g x) :
    FalseWork.Lattice.GeneratedBy g x := by
  induction h with
  | gen => exact .gen
  | top => exact .top
  | bot => exact .bot
  | sup _ _ ihx ihy => exact .sup ihx ihy
  | inf _ _ ihx ihy => exact .inf ihx ihy
  | himp _ _ ihx ihy => exact .himp ihx ihy
  | compl _ ih => exact .compl ih

/-- `rnLadder` is the project's `nishimuraTerm`, rung by rung. -/
theorem rnLadder_eq_nishimuraTerm (g : H) :
    ∀ n, rnLadder g n = FalseWork.Lattice.nishimuraTerm g n
  | 0 => rfl
  | 1 => rfl
  | 2 => rfl
  | 3 => rfl
  | 4 => rfl
  | (n + 5) => by
    rw [rnLadder, FalseWork.Lattice.nishimuraTerm,
        rnLadder_eq_nishimuraTerm g (n + 3), rnLadder_eq_nishimuraTerm g (n + 2)]

/-- Repackage the project's normal-form conclusion in `rnLadder` vocabulary. -/
theorem ladderValue_repackage {g x : H}
    (h : x = ⊤ ∨ ∃ n : ℕ, x = FalseWork.Lattice.nishimuraTerm g n) :
    x = ⊤ ∨ ∃ n : ℕ, x = rnLadder g n := by
  rcases h with h | ⟨n, hn⟩
  · exact Or.inl h
  · exact Or.inr ⟨n, by rw [hn, rnLadder_eq_nishimuraTerm]⟩

end ChallengeBridge

/-- **Non-degeneracy.** The four regions relative to `a` are simultaneously
inhabited if and only if `a` is ordinary. -/
theorem four_regions_iff_ordinary (a : H) :
    FourRegionsInhabited a ↔ OrdinaryElement a :=
  (FalseWork.Lattice.isOrdinary_iff_allFourCells a).symm

/-- **Nishimura's one-variable normal form.** Every element of the Heyting
subalgebra generated by `g` is `⊤` or a value of the Rieger–Nishimura ladder
over `g`. -/
theorem nishimura_normal_form (g : H) {x : H} (h : HeytingGeneratedBy g x) :
    x = ⊤ ∨ ∃ n : ℕ, x = rnLadder g n :=
  ChallengeBridge.ladderValue_repackage
    (FalseWork.Lattice.generatedBy_isLadderValue g (ChallengeBridge.toGeneratedBy h))

/-- **Uniqueness of the ordinary element.** If a Heyting algebra is generated
(as a Heyting algebra) by an ordinary element `g`, then `g` is its one and
only ordinary element. The statement appears without proof in Citkin,
arXiv:2512.05633 (p. 13). -/
theorem unique_ordinary_element (g : H) (hg : OrdinaryElement g)
    (hgen : ∀ y : H, HeytingGeneratedBy g y) (a : H) :
    OrdinaryElement a ↔ a = g :=
  FalseWork.Lattice.nishimura_ordinary_unique g hg
    (fun y => FalseWork.Lattice.generatedBy_isLadderValue g
      (ChallengeBridge.toGeneratedBy (hgen y)))
    a

/-- **The six-element threshold.** Any finite Heyting algebra containing an
ordinary element has at least six elements. -/
theorem ordinary_forces_card_ge_six [Fintype H] {g : H} (hg : OrdinaryElement g) :
    6 ≤ Fintype.card H :=
  FalseWork.Lattice.ordinary_card_ge_six hg

/-- **The Z₆ order-embedding.** Any Heyting algebra containing an ordinary
element admits an order-embedding of the six-element lattice `Fin 3 × Fin 2`
(the product of a three-chain and a two-chain under the componentwise order —
equivalently, the divisor lattice of 12, or the one-generated Heyting algebra
Z₆). -/
theorem ordinary_gives_z6_embedding {g : H} (hg : OrdinaryElement g) :
    Nonempty ((Fin 3 × Fin 2) ↪o H) :=
  ⟨(FalseWork.Lattice.Examples.Div12.div12OrderIsoChains.symm.toOrderEmbedding).trans
    (FalseWork.Lattice.div12OrderEmbedding hg)⟩

/-- **The arithmetic instance at n = 12.** In the divisor lattice of 12 —
`Fin 3 × Fin 2` under the componentwise order, coordinates the 2-adic and
3-adic valuations, carrying Mathlib's product Heyting structure — the four
regions are simultaneously inhabited at exactly one point: `(1, 0)`, the
divisor 2 (in the pitch-class reading of ℤ/12ℤ, the tritone). -/
theorem twelve_unique_kernel :
    ∀ a : Fin 3 × Fin 2, FourRegionsInhabited a ↔ a = (1, 0) :=
  fun a => FalseWork.Lattice.Examples.twelve_kernel_unique a
