/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# The opposition figure: Aristotle's square, degraded intuitionistically

The classical square of opposition, read propositionally at an element
`a` of a Heyting algebra, generates six landmarks:

* `⊥`        — the contradiction pole
* `aᶜ`       — the E corner (universal negative)
* `a`        — the A corner (universal affirmative)
* `aᶜᶜ`      — the I corner (particular affirmative, "not impossible")
* `a ⊔ aᶜ`   — the U vertex (excluded middle at `a`)
* `⊤`        — the tautology pole

Classically these crush down: `aᶜᶜ = a` identifies I with A, and
`a ⊔ aᶜ = ⊤` identifies U with the top pole — the square never shows
more than four distinct positions, which is why classical logic never
saw the extra two.  Intuitionistically the figure opens up, and this
file proves exactly when: **the six landmarks are pairwise distinct iff
`a` is ordinary** (neither regular nor dense — Citkin's condition, the
same condition that makes the four-position partition non-degenerate).

The figure is not a new object.  Its six values are the map
`ladderEmbed a : Div12 → H` of `LadderCore.lean` — the bottom five
rungs of the Rieger–Nishimura ladder plus `⊤`, indexed by the
six-element lattice `Z₆` they form.  This file re-reads that map as
the degraded square of opposition and adds the theorems the reading
needs.

## Main results

* `oppositionFigure_injective_iff` (**T1, the figure law**): the six
  landmarks are pairwise distinct iff `a` is ordinary.  The hard
  direction is inherited from `ladderEmbed_le_iff`.
* `compl_compl_eq_of_sup_compl_eq_top` (**the classical collapse**):
  a complemented element is regular — if excluded middle holds at `a`,
  the I corner lands on A.  This is why Aristotle's square, in a
  classical ambient logic, cannot exhibit six positions.
* `oppositionFigure_not_injective_of_regular` (**regular collapse**):
  `aᶜᶜ = a` kills the figure (I = A).
* `oppositionFigure_of_dense` (**dense collapse**): `aᶜ = ⊥` crushes
  the figure onto the three-chain `⊥ ≤ a ≤ ⊤` (E dies, I and U
  saturate).
* `boolean_oppositionFigure_degenerate`: in a Boolean algebra the
  figure is degenerate at *every* element — the algebraic form of
  "2,300 years of structural invisibility", companion to
  `boolean_no_kernel`.
* `oppositionFigure_skeleton` (**the skeleton theorem**): at an
  ordinary `a` the four middle landmarks inhabit the four cells of the
  lattice partition, one each — `a` in Infrastructure, `aᶜ` in Refusal,
  `aᶜᶜ` in Exploitation, `a ⊔ aᶜ` in Distribution.  The figure is the
  partition's set of canonical representatives.
* `oppositionFigure_tritone_eq_id`: on `Div12` at the tritone the
  figure is the identity — at the unique ordinary element of `Z₆` the
  six landmarks *are* the six elements of the algebra.
* `BlancheHexagon.not_orderIso_div12` (**T2, the Blanché refutation**):
  Blanché's 1966 hexagon, as an entailment poset, is **not**
  order-isomorphic to `Z₆`.  The two six-element completions of the
  square are different figures: the hexagon has three minimal elements
  and no bottom; `Z₆` is a bounded lattice.

## The Blanché encoding (cover table for human review)

`BlancheHexagon` encodes the hexagon of Blanché, *Structures
intellectuelles* (1966): the square's corners `A`, `E`, `I`, `O`
plus `U := A ∨ E` and `Y := I ∧ O`, ordered by entailment
(`x ≤ y` iff `x` entails `y`).  Cover relations:

| edge    | reading                          |
|---------|----------------------------------|
| `A ≤ I` | subalternation (left side)       |
| `E ≤ O` | subalternation (right side)      |
| `A ≤ U` | disjunct below its disjunction   |
| `E ≤ U` | disjunct below its disjunction   |
| `Y ≤ I` | conjunction below its conjunct   |
| `Y ≤ O` | conjunction below its conjunct   |

`A`, `E`, `Y` are pairwise incomparable (contraries), as are
`I`, `O`, `U` (subcontraries); `U` and `Y` are contradictories and in
particular incomparable.  **Statement-matches-source review of this
table against Blanché (1966) is a human task**, same discipline as
`Challenge.lean`.

## Prior art and claim discipline

The intuitionistic square of opposition is studied informally
(Béziau's negation-corner analyses; the 2012 Birkhäuser volume *Around
and Beyond the Square of Opposition*; Demey–Smessaert logical
geometry).  What is claimed here is not the square's intuitionistic
reading but, as far as we know, the first **kernel-checked** statements
of (i) the exact algebraic law for when the degraded square is
non-degenerate (= Citkin ordinariness), (ii) its identification with
`Z₆` and the partition skeleton, and (iii) the non-identification with
Blanché's hexagon.  Wording: "first kernel-checked", never "first".
-/
import FalseWorkPapers.Examples.LadderCore

namespace FalseWork.Lattice

variable {H : Type*} [HeytingAlgebra H] {a : H}

/-! ## 1. The figure -/

/-- The **opposition figure** at `a`: the six landmarks of the degraded
square of opposition, indexed by the six-element lattice `Z₆` they form.
Definitionally this is `ladderEmbed a` (`one ↦ ⊥`, `three ↦ aᶜ`,
`two ↦ a`, `four ↦ aᶜᶜ`, `six ↦ a ⊔ aᶜ`, `twelve ↦ ⊤`) — the bottom
five rungs of the Rieger–Nishimura ladder plus `⊤`. -/
abbrev oppositionFigure (a : H) : Examples.Div12 → H := ladderEmbed a

/-! ## 2. The classical collapse: complemented ⟹ regular -/

/-- **The classical collapse.**  A complemented element is regular: if
excluded middle holds at `a` (`a ⊔ aᶜ = ⊤`), then `aᶜᶜ = a` and the
I corner of the square lands on the A corner.  Distributivity does the
work.  This is the algebraic reason Aristotle's square, in a classical
ambient logic, cannot show six positions. -/
theorem compl_compl_eq_of_sup_compl_eq_top (h : a ⊔ aᶜ = ⊤) : aᶜᶜ = a := by
  have h1 : aᶜᶜ ⊓ a = a := inf_eq_right.mpr le_compl_compl
  have h2 : aᶜᶜ ⊓ aᶜ = ⊥ := compl_inf_self aᶜ
  calc aᶜᶜ = aᶜᶜ ⊓ (a ⊔ aᶜ) := by rw [h, inf_top_eq]
    _ = aᶜᶜ ⊓ a ⊔ aᶜᶜ ⊓ aᶜ := inf_sup_left aᶜᶜ a aᶜ
    _ = a ⊔ ⊥ := by rw [h1, h2]
    _ = a := sup_bot_eq a

/-- A complemented element is never ordinary. -/
theorem not_isOrdinary_of_sup_compl_eq_top (h : a ⊔ aᶜ = ⊤) :
    ¬ IsOrdinary a :=
  fun ha => ha.1 (compl_compl_eq_of_sup_compl_eq_top h)

/-- At an ordinary element the U vertex sits **strictly** below `⊤` —
the visible intuitionistic gap in the figure. -/
theorem IsOrdinary.sup_compl_ne_top (ha : IsOrdinary a) : a ⊔ aᶜ ≠ ⊤ :=
  fun h => ha.1 (compl_compl_eq_of_sup_compl_eq_top h)

/-! ## 3. T1: the figure law -/

/-- **T1 (the figure law).**  The six landmarks of the opposition
figure at `a` are pairwise distinct iff `a` is ordinary.

Forward: distinctness of the I/A pair gives `aᶜᶜ ≠ a`; distinctness of
the E/⊥ pair gives `aᶜ ≠ ⊥`.  Backward: `ladderEmbed_le_iff` makes the
figure an order-embedding of `Z₆`, hence injective.

Together with `isOrdinary_iff_allFourCells`, the figure and the
four-position partition are non-degenerate under exactly the same
condition. -/
theorem oppositionFigure_injective_iff (a : H) :
    Function.Injective (oppositionFigure a) ↔ IsOrdinary a := by
  constructor
  · intro h
    constructor
    · intro e
      have h42 : oppositionFigure a Examples.Div12.four =
          oppositionFigure a Examples.Div12.two := e
      exact absurd (h h42) (by decide)
    · intro e
      have h31 : oppositionFigure a Examples.Div12.three =
          oppositionFigure a Examples.Div12.one := e
      exact absurd (h h31) (by decide)
  · intro ha x y hxy
    exact le_antisymm ((ladderEmbed_le_iff ha x y).mp hxy.le)
      ((ladderEmbed_le_iff ha y x).mp hxy.ge)

/-! ## 4. The collapse laws -/

/-- **Regular collapse.**  If `a` is regular (`aᶜᶜ = a`), the I corner
lands on A and the figure is degenerate. -/
theorem oppositionFigure_not_injective_of_regular (h : aᶜᶜ = a) :
    ¬ Function.Injective (oppositionFigure a) := fun hinj =>
  absurd
    (hinj (show oppositionFigure a Examples.Div12.four =
      oppositionFigure a Examples.Div12.two from h))
    (by decide)

/-- **Dense collapse.**  If `a` is dense (`aᶜ = ⊥`), the figure crushes
onto the three-chain `⊥ ≤ a ≤ ⊤`: the E corner dies (`aᶜ = ⊥`), the
I corner saturates (`aᶜᶜ = ⊤`), the U vertex falls back onto A
(`a ⊔ aᶜ = a`). -/
theorem oppositionFigure_of_dense (h : aᶜ = ⊥) :
    ∀ x, oppositionFigure a x = ⊥ ∨ oppositionFigure a x = a ∨
      oppositionFigure a x = ⊤ := by
  intro x
  cases x with
  | one => exact Or.inl rfl
  | two => exact Or.inr (Or.inl rfl)
  | three => exact Or.inl h
  | four => exact Or.inr (Or.inr (by show aᶜᶜ = ⊤; rw [h, compl_bot]))
  | six => exact Or.inr (Or.inl (by show a ⊔ aᶜ = a; rw [h, sup_bot_eq]))
  | twelve => exact Or.inr (Or.inr rfl)

/-- **Boolean degeneracy at every element.**  In a Boolean algebra the
opposition figure is degenerate everywhere: every element is regular,
so the I corner always lands on A.  The algebraic form of the square's
2,300-year silence about the two extra positions; companion to
`boolean_no_kernel`. -/
theorem boolean_oppositionFigure_degenerate {B : Type*} [BooleanAlgebra B]
    (b : B) : ¬ Function.Injective (oppositionFigure b) :=
  oppositionFigure_not_injective_of_regular (compl_compl b)

/-! ## 5. The skeleton theorem: the figure inhabits the partition -/

/-- The A corner inhabits Infrastructure (trivially: `a ≤ a`). -/
theorem oppositionFigure_infrastructure (a : H) :
    IsLatticeInfrastructure a a := le_rfl

/-- The E corner inhabits Refusal (trivially: `aᶜ ≤ aᶜ`). -/
theorem oppositionFigure_refusal (a : H) : IsLatticeRefusal a aᶜ := le_rfl

/-- The I corner inhabits Exploitation when `a` is ordinary: `aᶜᶜ` is
under the double negation but (by non-regularity) not under `a`. -/
theorem oppositionFigure_exploitation (ha : IsOrdinary a) :
    IsLatticeExploitation a aᶜᶜ :=
  ⟨le_rfl, fun h => ha.1 (le_antisymm h le_compl_compl)⟩

/-- The U vertex inhabits Distribution when `a` is ordinary: `a ⊔ aᶜ`
meets both the kernel and its complement non-trivially. -/
theorem oppositionFigure_distribution (ha : IsOrdinary a) :
    IsLatticeDistribution a (a ⊔ aᶜ) := by
  refine ⟨?_, ?_⟩
  · rw [inf_eq_right.mpr le_sup_left]
    exact ha.ne_bot
  · rw [inf_eq_right.mpr le_sup_right]
    exact ha.2

/-- **The skeleton theorem.**  At an ordinary `a`, the four middle
landmarks of the opposition figure inhabit the four cells of the
lattice partition, one landmark per cell:

* A corner (`two ↦ a`)        — Infrastructure
* E corner (`three ↦ aᶜ`)     — Refusal
* I corner (`four ↦ aᶜᶜ`)     — Exploitation
* U vertex (`six ↦ a ⊔ aᶜ`)   — Distribution

The figure is the partition's set of canonical representatives — its
skeleton.  (These are the same witnesses exhibited inside the proof of
`allFourCellsInhabited_iff`, exposed as API; the music table of the
ordinary-elements paper §9 is this theorem instantiated at the
tritone.) -/
theorem oppositionFigure_skeleton (ha : IsOrdinary a) :
    IsLatticeInfrastructure a (oppositionFigure a Examples.Div12.two) ∧
    IsLatticeRefusal a (oppositionFigure a Examples.Div12.three) ∧
    IsLatticeExploitation a (oppositionFigure a Examples.Div12.four) ∧
    IsLatticeDistribution a (oppositionFigure a Examples.Div12.six) :=
  ⟨oppositionFigure_infrastructure a, oppositionFigure_refusal a,
   oppositionFigure_exploitation ha, oppositionFigure_distribution ha⟩

/-! ## 6. Z₆: the figure at the tritone is the whole algebra -/

open Examples in
/-- On `Div12 = Z₆` at the tritone — the unique ordinary element — the
opposition figure is the identity: the six landmarks are not merely
six distinct elements, they are *the* six elements, each in its own
slot.  `Z₆` is exactly its own opposition figure. -/
theorem oppositionFigure_tritone_eq_id :
    ∀ x : Div12, oppositionFigure Div12.two x = x := by decide

/-! ## 7. T2: the Blanché refutation -/

namespace Examples

/-- **Blanché's hexagon** (1966) as an entailment poset: the square's
corners `A`, `E`, `I`, `O` plus `U := A ∨ E` and `Y := I ∧ O`, with
`x ≤ y` iff `x` entails `y`.  See the module docstring for the cover
table and the human-review flag on its fidelity to the 1966 source. -/
inductive BlancheHexagon : Type
  | A | E | I | O | U | Y
  deriving DecidableEq, Repr

namespace BlancheHexagon

instance : Fintype BlancheHexagon :=
  ⟨{A, E, I, O, U, Y}, by intro x; cases x <;> decide⟩

/-- Entailment on the hexagon, as a `Bool` function: the six cover
relations of the docstring table plus reflexivity. -/
def leb : BlancheHexagon → BlancheHexagon → Bool
  | .A, .A => true
  | .A, .I => true
  | .A, .U => true
  | .E, .E => true
  | .E, .O => true
  | .E, .U => true
  | .Y, .Y => true
  | .Y, .I => true
  | .Y, .O => true
  | .I, .I => true
  | .O, .O => true
  | .U, .U => true
  | _,  _  => false

instance : LE BlancheHexagon := ⟨fun x y => leb x y = true⟩

instance decLE : ∀ x y : BlancheHexagon, Decidable (x ≤ y) := fun x y => by
  show Decidable (leb x y = true); exact decEq _ _

instance : PartialOrder BlancheHexagon where
  le := (· ≤ ·)
  le_refl x := by cases x <;> decide
  le_trans x y z := by cases x <;> cases y <;> cases z <;> decide
  le_antisymm x y := by cases x <;> cases y <;> decide

/-- The hexagon has no least element: `A`, `E`, `Y` are three pairwise
incomparable minimal vertices (the contraries). -/
theorem no_least : ¬ ∃ b : BlancheHexagon, ∀ x, b ≤ x := by decide

/-- **T2 (the Blanché refutation).**  Blanché's hexagon is **not**
order-isomorphic to `Z₆`: the hexagon has no least element (three
minimal contraries), while `Z₆` is a bounded lattice.  The two
six-element completions of the square of opposition are different
figures — adding vertices classically (Blanché) and degrading the
logic intuitionistically (the opposition figure) do not commute. -/
theorem not_orderIso_div12 : IsEmpty (BlancheHexagon ≃o Div12) := by
  refine ⟨fun e => no_least ⟨e.symm ⊥, fun x => ?_⟩⟩
  have h : e.symm ⊥ ≤ e.symm (e x) := e.symm.monotone bot_le
  simpa using h

end BlancheHexagon

end Examples

/-! ## Axiom audit

Uncomment locally, or run `lake env lean` on a scratch importing this
module, to confirm: every theorem above reports at most
`[propext, Classical.choice, Quot.sound]`.

```
#print axioms FalseWork.Lattice.oppositionFigure_injective_iff
#print axioms FalseWork.Lattice.compl_compl_eq_of_sup_compl_eq_top
#print axioms FalseWork.Lattice.oppositionFigure_skeleton
#print axioms FalseWork.Lattice.oppositionFigure_tritone_eq_id
#print axioms FalseWork.Lattice.Examples.BlancheHexagon.not_orderIso_div12
```
-/

end FalseWork.Lattice
