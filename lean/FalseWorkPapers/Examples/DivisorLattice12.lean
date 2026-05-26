/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# Concrete instantiation of Layer L on the divisor lattice of 12

The lattice-level four-position partition theorem
(`FalseWork.Lattice.lattice_four_position_partition`) applied to a
concrete, hand-rolled 6-element Heyting algebra: the divisor lattice
of 12, equivalently the subgroup lattice of `Z/12`, equivalently the
lattice of transposition-symmetric pitch-class subsets of `Z/12`.

The music interpretation:

```
      twelve  (full chromatic Z/12)
      /    \
   six      four
   (whole-  (diminished 7th  <3>)
   tone <2>)
   /   \    /
 two    three
 (tritone (augmented triad
  <6>)    <4>)
   \   /
    one (trivial {0})
```

Edges = divisibility; equivalently = subgroup inclusion.  Six elements,
distributive (divisor lattices are), non-Boolean (12 = 2²·3 is not
squarefree).

At kernel `a = two` (the tritone), the four position cells of Layer L
are inhabited as follows:

| Cell           | Element  | Subgroup of `Z/12`          |
|----------------|----------|-----------------------------|
| Infrastructure | two      | tritone `<6>`               |
| Refusal        | three    | augmented triad `<4>`       |
| Exploitation   | four     | diminished 7th `<3>`        |
| Distribution   | six      | whole-tone hexachord `<2>`  |
| Distribution   | twelve   | full chromatic `Z/12`       |

## Implementation note

The Heyting algebra is built by hand-rolling the six-element
`inductive` type `Div12`, defining the order, meet, join, and
implication explicitly by case distinction, and discharging the
lattice and Heyting axioms via case-splits + `decide`.  The finitely
many cases (≤ 6³ = 216) all reduce to ground boolean checks.
-/
import Mathlib.Order.Heyting.Basic
import Mathlib.Data.Fintype.Basic
import FalseWorkPapers.Lattice.FourPositionLattice

namespace FalseWork.Lattice.Examples

/-! ## The six elements -/

/-- The six divisors of 12, equivalently the orders of subgroups of `Z/12`,
equivalently the six transposition-symmetric pitch-class structures
of `Z/12`. -/
inductive Div12 : Type
  | one    : Div12
  | two    : Div12
  | three  : Div12
  | four   : Div12
  | six    : Div12
  | twelve : Div12
  deriving DecidableEq, Repr

namespace Div12

instance : Fintype Div12 :=
  ⟨{one, two, three, four, six, twelve}, by intro x; cases x <;> decide⟩

/-! ## Order, meet, join, implication (all by case distinction) -/

/-- `a` divides `b`, as a `Bool` function on the six elements. -/
def leb : Div12 → Div12 → Bool
  | one,    _      => true
  | two,    two    => true
  | two,    four   => true
  | two,    six    => true
  | two,    twelve => true
  | three,  three  => true
  | three,  six    => true
  | three,  twelve => true
  | four,   four   => true
  | four,   twelve => true
  | six,    six    => true
  | six,    twelve => true
  | twelve, twelve => true
  | _,      _      => false

instance : LE Div12 := ⟨fun a b => leb a b = true⟩
instance : LT Div12 := ⟨fun a b => a ≤ b ∧ ¬ b ≤ a⟩

instance decLE : ∀ a b : Div12, Decidable (a ≤ b) := fun a b => by
  show Decidable (leb a b = true); exact decEq _ _

instance decLT : ∀ a b : Div12, Decidable (a < b) := fun a b => by
  show Decidable (a ≤ b ∧ ¬ b ≤ a); exact inferInstance

/-- Meet = gcd of divisors. -/
def meet : Div12 → Div12 → Div12
  | one,    _      => one
  | two,    one    => one
  | two,    two    => two
  | two,    three  => one
  | two,    four   => two
  | two,    six    => two
  | two,    twelve => two
  | three,  one    => one
  | three,  two    => one
  | three,  three  => three
  | three,  four   => one
  | three,  six    => three
  | three,  twelve => three
  | four,   one    => one
  | four,   two    => two
  | four,   three  => one
  | four,   four   => four
  | four,   six    => two
  | four,   twelve => four
  | six,    one    => one
  | six,    two    => two
  | six,    three  => three
  | six,    four   => two
  | six,    six    => six
  | six,    twelve => six
  | twelve, one    => one
  | twelve, two    => two
  | twelve, three  => three
  | twelve, four   => four
  | twelve, six    => six
  | twelve, twelve => twelve

/-- Join = lcm of divisors. -/
def join : Div12 → Div12 → Div12
  | one,    a      => a
  | two,    one    => two
  | two,    two    => two
  | two,    three  => six
  | two,    four   => four
  | two,    six    => six
  | two,    twelve => twelve
  | three,  one    => three
  | three,  two    => six
  | three,  three  => three
  | three,  four   => twelve
  | three,  six    => six
  | three,  twelve => twelve
  | four,   one    => four
  | four,   two    => four
  | four,   three  => twelve
  | four,   four   => four
  | four,   six    => twelve
  | four,   twelve => twelve
  | six,    one    => six
  | six,    two    => six
  | six,    three  => six
  | six,    four   => twelve
  | six,    six    => six
  | six,    twelve => twelve
  | twelve, _      => twelve

instance : Min Div12 := ⟨meet⟩
instance : Max Div12 := ⟨join⟩
instance : Top Div12 := ⟨twelve⟩
instance : Bot Div12 := ⟨one⟩

/-- Heyting implication `a ⇨ b` = largest `c` with `gcd(a, c) | b`. -/
def himpFun : Div12 → Div12 → Div12
  | one,    _      => twelve
  | _,      twelve => twelve
  | two,    one    => three
  | two,    two    => twelve
  | two,    three  => three
  | two,    four   => twelve
  | two,    six    => twelve
  | three,  one    => four
  | three,  two    => four
  | three,  three  => twelve
  | three,  four   => four
  | three,  six    => twelve
  | four,   one    => three
  | four,   two    => six
  | four,   three  => three
  | four,   four   => twelve
  | four,   six    => six
  | six,    one    => one
  | six,    two    => four
  | six,    three  => three
  | six,    four   => four
  | six,    six    => twelve
  | twelve, one    => one
  | twelve, two    => two
  | twelve, three  => three
  | twelve, four   => four
  | twelve, six    => six

instance : HImp Div12 := ⟨himpFun⟩
instance : Compl Div12 := ⟨fun a => himpFun a one⟩

/-! ## Lattice axioms (each discharged by case-splits + `decide`)

These proofs are exhaustive case enumerations; the type has only six
constructors, and after `cases` the goal reduces to a ground boolean
check. -/

instance : PartialOrder Div12 where
  le := (· ≤ ·)
  lt := (· < ·)
  le_refl       := fun a       => by cases a <;> decide
  le_trans      := fun a b c   => by cases a <;> cases b <;> cases c <;> decide
  le_antisymm   := fun a b     => by cases a <;> cases b <;> decide
  lt_iff_le_not_ge := fun _ _  => Iff.rfl

instance : SemilatticeInf Div12 where
  inf           := (· ⊓ ·)
  inf_le_left   := fun a b     => by cases a <;> cases b <;> decide
  inf_le_right  := fun a b     => by cases a <;> cases b <;> decide
  le_inf        := fun a b c   => by cases a <;> cases b <;> cases c <;> decide

instance : SemilatticeSup Div12 where
  sup           := (· ⊔ ·)
  le_sup_left   := fun a b     => by cases a <;> cases b <;> decide
  le_sup_right  := fun a b     => by cases a <;> cases b <;> decide
  sup_le        := fun a b c   => by cases a <;> cases b <;> cases c <;> decide

instance : Lattice Div12 where
  __ := (inferInstance : SemilatticeInf Div12)
  __ := (inferInstance : SemilatticeSup Div12)

instance : DistribLattice Div12 where
  le_sup_inf    := fun a b c   => by cases a <;> cases b <;> cases c <;> decide

instance : BoundedOrder Div12 where
  top := twelve
  bot := one
  le_top a := by cases a <;> decide
  bot_le a := by cases a <;> decide

/-! ## Heyting-algebra instance -/

theorem le_himp_iff_div12 (a b c : Div12) : a ≤ b ⇨ c ↔ a ⊓ b ≤ c := by
  cases a <;> cases b <;> cases c <;> decide

instance heytingAlgebra : HeytingAlgebra Div12 :=
  HeytingAlgebra.ofHImp himpFun le_himp_iff_div12

/-! ## Non-Boolean witness -/

/-- The tritone is non-regular: `¬¬two = four ≠ two`.  This is the
load-bearing structural fact that makes the Exploitation cell at the
tritone kernel non-empty. -/
theorem tritone_non_regular : (twoᶜ)ᶜ ≠ two := by decide

/-- The whole-tone hexachord is the other non-regular element.
Recorded for completeness; not used in the music-anchor witness below. -/
theorem wholeTone_non_regular : (sixᶜ)ᶜ ≠ six := by decide

/-! ## Layer-L music-anchor witness -/

open FalseWork.Lattice

/-- The tritone kernel: `a = two` ↔ subgroup `<6> = {0, 6} ⊂ Z/12`. -/
def tritoneKernel : Div12 := two

/-- Infrastructure cell at the tritone kernel is inhabited by the
tritone itself. -/
theorem tritone_is_infrastructure :
    IsLatticeInfrastructure tritoneKernel two := by
  show two ≤ two; decide

/-- Refusal cell at the tritone kernel is inhabited by the augmented
triad (subgroup `<4> = {0, 4, 8}`). -/
theorem augmentedTriad_is_refusal :
    IsLatticeRefusal tritoneKernel three := by
  show three ≤ twoᶜ; decide

/-- Exploitation cell at the tritone kernel is inhabited by the
diminished 7th (subgroup `<3> = {0, 3, 6, 9}`).  Witnesses both the
double-negation containment and the strict non-containment in the
kernel. -/
theorem diminishedSeventh_is_exploitation :
    IsLatticeExploitation tritoneKernel four := by
  refine ⟨?_, ?_⟩
  · show four ≤ (twoᶜ)ᶜ; decide
  · show ¬ four ≤ two; decide

/-- Distribution cell at the tritone kernel is inhabited by the
whole-tone hexachord (subgroup `<2> = {0, 2, 4, 6, 8, 10}`). -/
theorem wholeTone_is_distribution :
    IsLatticeDistribution tritoneKernel six := by
  refine ⟨?_, ?_⟩
  · show six ⊓ two ≠ ⊥; decide
  · show six ⊓ twoᶜ ≠ ⊥; decide

/-- Distribution is also inhabited by the full chromatic. -/
theorem chromatic_is_distribution :
    IsLatticeDistribution tritoneKernel twelve := by
  refine ⟨?_, ?_⟩
  · show twelve ⊓ two ≠ ⊥; decide
  · show twelve ⊓ twoᶜ ≠ ⊥; decide

/-- **The Layer-L music-anchor witness.**

At the tritone kernel `a = two` in the divisor lattice of 12, all four
cells of `lattice_four_position_partition` are inhabited by elements
corresponding to musically-meaningful transposition-symmetric
pitch-class subsets of `Z/12`:

* Infrastructure  ← tritone `<6>`             (the kernel itself)
* Refusal         ← augmented triad `<4>`
* Exploitation    ← diminished 7th `<3>`      (the closure-residue)
* Distribution    ← whole-tone hexachord `<2>`

Combined with `lattice_four_position_partition`, this establishes
that the four-position partition theorem is **non-vacuous on a
music-derived Heyting algebra**, kernel-checked.

Layer L (lattice level) is what this witness covers.  Layer T (topos
realization of the lattice as `Sub_T(Y)` for some elementary topos `T`)
and Layer D (a specific non-trivial distinction structure
`(D, η, ι)` whose unit's image lands at the tritone) are general-theory
facts: any non-Boolean finite Heyting algebra is `Sub_{Sh(H)}(1)`, and
any closure operator on the algebra lifts to an idempotent monad on
the topos via `DistinctionStructure.ofIdempotentMonad`.  Concrete
Layer-T and Layer-D constructions are deferred. -/
theorem music_anchor_witness :
    IsLatticeInfrastructure tritoneKernel two ∧
    IsLatticeRefusal        tritoneKernel three ∧
    IsLatticeExploitation   tritoneKernel four ∧
    IsLatticeDistribution   tritoneKernel six :=
  ⟨tritone_is_infrastructure,
   augmentedTriad_is_refusal,
   diminishedSeventh_is_exploitation,
   wholeTone_is_distribution⟩

end Div12

end FalseWork.Lattice.Examples
