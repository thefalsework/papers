/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# The Aristotelian relation profile of the opened square

`OppositionFigure.lean` proves the six landmarks `⊥, aᶜ, a, aᶜᶜ,
a ⊔ aᶜ, ⊤` are pairwise distinct iff `a` is ordinary.  This file
computes what the square-of-opposition tradition actually asks about a
figure: the **opposition relations** among its vertices.  In the
algebraic transcription standard in logical geometry (Smessaert–Demey,
*Logical Geometries and Information in the Square of Oppositions*,
JoLLI 2014), for elements `x y` of a bounded lattice:

* **contradictories** — `x ⊓ y = ⊥` and `x ⊔ y = ⊤` (Mathlib's `IsCompl`);
* **contraries**      — `x ⊓ y = ⊥` and `x ⊔ y ≠ ⊤`;
* **subcontraries**   — `x ⊓ y ≠ ⊥` and `x ⊔ y = ⊤`;
* **subalternation**  — `x < y` (`x` entails `y`, not conversely);
* **unconnected**     — none of the above (Demey–Smessaert's fourth
  opposition relation).

## Main results

At an **ordinary** `a` (neither regular nor dense), among the four
middle landmarks `A := a`, `E := aᶜ`, `I := aᶜᶜ`, `U := a ⊔ aᶜ`:

* `IsOrdinary.contraries_compl` — **A and E are contraries, never
  contradictories.**  Classically `a` and `¬a` are contradictories
  (`boolean_contradictories_compl`); at an ordinary element the pair
  weakens to contrariety.  This is the element-local algebraic form of
  Béziau's observation that intuitionistic negation is a paracomplete,
  *contrariety-forming* negation ("New light on the nameless corner of
  the square of oppositions", 2003).
* `IsOrdinary.lt_compl_compl`, `IsOrdinary.lt_sup_compl`,
  `IsOrdinary.compl_lt_sup_compl` — **three strict subalternations**
  `A < I`, `A < U`, `E < U` (each pure: the joins stay below `⊤`).
* The remaining two pairs are **not determined by ordinariness**: they
  split on the *Stone identity at `a`* (`StoneAt a : aᶜ ⊔ aᶜᶜ = ⊤`,
  weak excluded middle at `a`):
  - `stoneAt_contradictories_compl` / `not_stoneAt_contraries_compl` —
    E and I are contradictories iff `StoneAt a`, else contraries;
  - `IsOrdinary.subcontraries_of_stoneAt` /
    `IsOrdinary.unconnected_of_not_stoneAt` — I and U are
    subcontraries iff `StoneAt a`, else **unconnected**.
* `oppositionRelationProfile` — the aggregate: at an ordinary `a`
  satisfying `StoneAt a`, the four middle landmarks realize **exactly
  one contrariety, one contradiction, one subcontrariety, and three
  subalternations** — the same relation inventory as the classical
  square, redistributed over different pairs.
* `div12_tritone_stoneAt`, `div12_tritone_profile` — `Z₆` at the
  tritone satisfies the Stone identity, so the full profile holds
  there; with `oppositionFigure_tritone_eq_id`, `Z₆` carries the
  complete relation inventory on its own six elements.

## Reading

The classical square has: contradiction on both diagonals (A–O, E–I),
contrariety on the top edge (A–E), subcontrariety on the bottom edge
(I–O), subalternation down both sides.  The opened square keeps the
*inventory* but moves it: the negation pair A–E weakens from
(propositional-reading) contradiction to contrariety, the diagonal
contradiction survives only between E and I and only where weak
excluded middle holds, and where it fails a genuinely new relation
appears — I and U become *unconnected*, a pair standing in no
Aristotelian relation at all, which is impossible among distinct
contingent vertices of the classical square's Boolean closure.

## Prior art and claim discipline

That intuitionistic negation forms contraries rather than
contradictories is Béziau's informal observation (2003), at the level
of the logic as a whole.  What is claimed as new here, as far as we
know: the element-local statements, the exact Stone-identity dichotomy
for the E–I and I–U pairs, the appearance of unconnectedness inside
the opened square, and the kernel-checking of all of it.  Wording:
"first kernel-checked", never "first".
-/
import FalseWorkPapers.Examples.OppositionFigure

namespace FalseWork.Lattice

variable {H : Type*} [HeytingAlgebra H] {a : H}

/-! ## 1. The opposition relations, algebraically -/

/-- `x` and `y` are **contradictories**: they exclude each other and
exhaust the algebra.  Equivalent to Mathlib's `IsCompl`
(`areContradictories_iff_isCompl`). -/
def AreContradictories (x y : H) : Prop := x ⊓ y = ⊥ ∧ x ⊔ y = ⊤

/-- `x` and `y` are **contraries**: they exclude each other but do not
exhaust the algebra (both can "fail"). -/
def AreContraries (x y : H) : Prop := x ⊓ y = ⊥ ∧ x ⊔ y ≠ ⊤

/-- `x` and `y` are **subcontraries**: they exhaust the algebra but do
not exclude each other (both can "hold"). -/
def AreSubcontraries (x y : H) : Prop := x ⊓ y ≠ ⊥ ∧ x ⊔ y = ⊤

/-- `x` and `y` are **unconnected** (Demey–Smessaert): no exclusion, no
exhaustion, no entailment either way — no Aristotelian relation at
all. -/
def AreUnconnected (x y : H) : Prop :=
  x ⊓ y ≠ ⊥ ∧ x ⊔ y ≠ ⊤ ∧ ¬ x ≤ y ∧ ¬ y ≤ x

/-- Contradictoriness is Mathlib's `IsCompl`. -/
theorem areContradictories_iff_isCompl {x y : H} :
    AreContradictories x y ↔ IsCompl x y := by
  rw [isCompl_iff, disjoint_iff, codisjoint_iff]
  exact Iff.rfl

/-! ## 2. The A–E pair: negation weakens contradiction to contrariety -/

/-- The negation pair is contradictory **iff** excluded middle holds at
`a`.  (The meet `a ⊓ aᶜ = ⊥` is free; the join is the whole
question.) -/
theorem contradictories_compl_iff :
    AreContradictories a aᶜ ↔ a ⊔ aᶜ = ⊤ :=
  ⟨fun h => h.2, fun h => ⟨inf_compl_self a, h⟩⟩

/-- In a Boolean algebra, `b` and `bᶜ` are contradictories — the
classical reading of the square's diagonal. -/
theorem boolean_contradictories_compl {B : Type*} [BooleanAlgebra B]
    (b : B) : AreContradictories b bᶜ :=
  ⟨inf_compl_eq_bot, sup_compl_eq_top⟩

/-- **A–E contrariety.**  At an ordinary element, `a` and `aᶜ` are
contraries: mutually exclusive but not exhaustive.  Intuitionistic
negation, at exactly the elements where the figure opens, forms
contraries — not contradictories. -/
theorem IsOrdinary.contraries_compl (ha : IsOrdinary a) :
    AreContraries a aᶜ :=
  ⟨inf_compl_self a, ha.sup_compl_ne_top⟩

/-- At an ordinary element the negation pair is **never**
contradictory. -/
theorem IsOrdinary.not_contradictories_compl (ha : IsOrdinary a) :
    ¬ AreContradictories a aᶜ :=
  fun h => ha.sup_compl_ne_top h.2

/-! ## 3. The three subalternations -/

/-- **A < I.**  At an ordinary element the subalternation from `a` to
`aᶜᶜ` is strict — the I corner sits properly above A. -/
theorem IsOrdinary.lt_compl_compl (ha : IsOrdinary a) : a < aᶜᶜ :=
  lt_of_le_of_ne le_compl_compl fun h => ha.1 h.symm

/-- **A < U.**  At an ordinary element `a` sits strictly below the
excluded-middle vertex. -/
theorem IsOrdinary.lt_sup_compl (ha : IsOrdinary a) : a < a ⊔ aᶜ := by
  refine lt_of_le_of_ne le_sup_left fun h => ?_
  have hle : aᶜ ≤ a := le_sup_right.trans h.ge
  have h1 : aᶜ ⊓ a = aᶜ := inf_eq_left.mpr hle
  exact ha.2 (by rw [← h1]; exact compl_inf_self a)

/-- **E < U.**  At an ordinary element `aᶜ` sits strictly below the
excluded-middle vertex. -/
theorem IsOrdinary.compl_lt_sup_compl (ha : IsOrdinary a) :
    aᶜ < a ⊔ aᶜ := by
  refine lt_of_le_of_ne le_sup_right fun h => ?_
  have hle : a ≤ aᶜ := le_sup_left.trans h.ge
  have h1 : a ⊓ aᶜ = a := inf_eq_left.mpr hle
  exact ha.ne_bot (by rw [← h1]; exact inf_compl_self a)

/-! ## 4. The Stone dichotomy: the pairs ordinariness does not settle -/

/-- The **Stone identity at `a`**: weak excluded middle, `¬a ∨ ¬¬a`.
Holds at every element iff `H` is a Stone algebra.  It holds at the
tritone in `Z₆` (`div12_tritone_stoneAt`) and fails, e.g., at
`(0,1) ∪ (1,2)` in the opens of `ℝ`. -/
def StoneAt (a : H) : Prop := aᶜ ⊔ aᶜᶜ = ⊤

/-- **E–I dichotomy, positive half.**  Under the Stone identity, `aᶜ`
and `aᶜᶜ` are contradictories — the classical diagonal survives on
this one pair. -/
theorem stoneAt_contradictories_compl (h : StoneAt a) :
    AreContradictories aᶜ aᶜᶜ :=
  ⟨inf_compl_self aᶜ, h⟩

/-- **E–I dichotomy, negative half.**  Without the Stone identity, `aᶜ`
and `aᶜᶜ` are merely contraries: even the surviving diagonal
weakens. -/
theorem not_stoneAt_contraries_compl (h : ¬ StoneAt a) :
    AreContraries aᶜ aᶜᶜ :=
  ⟨inf_compl_self aᶜ, h⟩

/-- The I–U meet is the A corner: `aᶜᶜ ⊓ (a ⊔ aᶜ) = a`.  (So the meet
of the Exploitation and Distribution landmarks is the Infrastructure
landmark.) -/
theorem complCompl_inf_sup_compl (a : H) : aᶜᶜ ⊓ (a ⊔ aᶜ) = a :=
  calc aᶜᶜ ⊓ (a ⊔ aᶜ) = aᶜᶜ ⊓ a ⊔ aᶜᶜ ⊓ aᶜ := inf_sup_left aᶜᶜ a aᶜ
    _ = a ⊔ ⊥ := by rw [inf_eq_right.mpr le_compl_compl, compl_inf_self aᶜ]
    _ = a := sup_bot_eq a

/-- The I–U join is the E–I join: `aᶜᶜ ⊔ (a ⊔ aᶜ) = aᶜ ⊔ aᶜᶜ`. -/
theorem complCompl_sup_sup_compl (a : H) :
    aᶜᶜ ⊔ (a ⊔ aᶜ) = aᶜ ⊔ aᶜᶜ := by
  rw [← sup_assoc, sup_eq_left.mpr le_compl_compl]
  exact sup_comm aᶜᶜ aᶜ

/-- **I–U dichotomy, positive half.**  At an ordinary `a` with the
Stone identity, `aᶜᶜ` and `a ⊔ aᶜ` are subcontraries: they exhaust the
algebra and overlap (in exactly `a`). -/
theorem IsOrdinary.subcontraries_of_stoneAt (ha : IsOrdinary a)
    (h : StoneAt a) : AreSubcontraries aᶜᶜ (a ⊔ aᶜ) := by
  constructor
  · rw [complCompl_inf_sup_compl]; exact ha.ne_bot
  · rw [complCompl_sup_sup_compl]; exact h

/-- **I–U dichotomy, negative half.**  At an ordinary `a` without the
Stone identity, `aᶜᶜ` and `a ⊔ aᶜ` are **unconnected** — no exclusion,
no exhaustion, no entailment either way.  A pair of distinct
contingent vertices with *no* Aristotelian relation is impossible in
the classical square; its appearance is a genuinely intuitionistic
phenomenon. -/
theorem IsOrdinary.unconnected_of_not_stoneAt (ha : IsOrdinary a)
    (h : ¬ StoneAt a) : AreUnconnected aᶜᶜ (a ⊔ aᶜ) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · rw [complCompl_inf_sup_compl]; exact ha.ne_bot
  · rw [complCompl_sup_sup_compl]; exact h
  · intro hle
    exact ha.1 (by rw [← inf_eq_left.mpr hle]; exact complCompl_inf_sup_compl a)
  · intro hle
    have h1 : aᶜ ⊓ aᶜᶜ = aᶜ := inf_eq_left.mpr (le_sup_right.trans hle)
    exact ha.2 (by rw [← h1]; exact inf_compl_self aᶜ)

/-! ## 5. The profile theorem -/

/-- **The relation profile of the opened square.**  At an ordinary `a`
satisfying the Stone identity, the four middle landmarks realize the
full classical relation inventory, redistributed:

* one **contrariety**     — A–E (`a`, `aᶜ`), where classically the
  negation pair is contradictory;
* one **contradiction**   — E–I (`aᶜ`, `aᶜᶜ`);
* one **subcontrariety**  — I–U (`aᶜᶜ`, `a ⊔ aᶜ`);
* three **subalternations** — A < I, A < U, E < U.

(The classical square has the same inventory over its four corners:
one contrariety, diagonal contradictions, one subcontrariety, two
subalternations.)  Without `StoneAt a` the E–I pair weakens to
contrariety and the I–U pair to unconnectedness
(`not_stoneAt_contraries_compl`, `unconnected_of_not_stoneAt`). -/
theorem oppositionRelationProfile (ha : IsOrdinary a) (hs : StoneAt a) :
    AreContraries a aᶜ ∧
    AreContradictories aᶜ aᶜᶜ ∧
    AreSubcontraries aᶜᶜ (a ⊔ aᶜ) ∧
    a < aᶜᶜ ∧ a < a ⊔ aᶜ ∧ aᶜ < a ⊔ aᶜ :=
  ⟨ha.contraries_compl, stoneAt_contradictories_compl hs,
   ha.subcontraries_of_stoneAt hs, ha.lt_compl_compl, ha.lt_sup_compl,
   ha.compl_lt_sup_compl⟩

/-! ## 6. Z₆: the tritone carries the full profile -/

open Examples in
/-- `Z₆` satisfies the Stone identity at the tritone. -/
theorem div12_tritone_stoneAt : StoneAt Div12.two := by
  show Div12.twoᶜ ⊔ Div12.twoᶜᶜ = ⊤
  decide

open Examples in
/-- The tritone is ordinary in `Z₆` (also available via
`isOrdinary_iff_allFourCells`; restated here computably). -/
theorem div12_tritone_ordinary : IsOrdinary Div12.two :=
  ⟨by decide, by decide⟩

open Examples in
/-- **The tritone profile.**  On `Div12 = Z₆` at its unique ordinary
element, the full relation profile holds; with
`oppositionFigure_tritone_eq_id`, the six elements of `Z₆` themselves
stand in exactly these Aristotelian relations. -/
theorem div12_tritone_profile :
    AreContraries Div12.two Div12.twoᶜ ∧
    AreContradictories Div12.twoᶜ Div12.twoᶜᶜ ∧
    AreSubcontraries Div12.twoᶜᶜ (Div12.two ⊔ Div12.twoᶜ) ∧
    Div12.two < Div12.twoᶜᶜ ∧ Div12.two < Div12.two ⊔ Div12.twoᶜ ∧
    Div12.twoᶜ < Div12.two ⊔ Div12.twoᶜ :=
  oppositionRelationProfile div12_tritone_ordinary div12_tritone_stoneAt

/-! ## Axiom audit

Run on a scratch importing this module to confirm: at most
`[propext, Classical.choice, Quot.sound]`.

```
#print axioms FalseWork.Lattice.areContradictories_iff_isCompl
#print axioms FalseWork.Lattice.contradictories_compl_iff
#print axioms FalseWork.Lattice.boolean_contradictories_compl
#print axioms FalseWork.Lattice.IsOrdinary.contraries_compl
#print axioms FalseWork.Lattice.IsOrdinary.not_contradictories_compl
#print axioms FalseWork.Lattice.IsOrdinary.lt_compl_compl
#print axioms FalseWork.Lattice.IsOrdinary.lt_sup_compl
#print axioms FalseWork.Lattice.IsOrdinary.compl_lt_sup_compl
#print axioms FalseWork.Lattice.stoneAt_contradictories_compl
#print axioms FalseWork.Lattice.not_stoneAt_contraries_compl
#print axioms FalseWork.Lattice.complCompl_inf_sup_compl
#print axioms FalseWork.Lattice.complCompl_sup_sup_compl
#print axioms FalseWork.Lattice.IsOrdinary.subcontraries_of_stoneAt
#print axioms FalseWork.Lattice.IsOrdinary.unconnected_of_not_stoneAt
#print axioms FalseWork.Lattice.oppositionRelationProfile
#print axioms FalseWork.Lattice.div12_tritone_stoneAt
#print axioms FalseWork.Lattice.div12_tritone_profile
```
-/

end FalseWork.Lattice
