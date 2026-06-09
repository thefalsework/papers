/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# Birkhoff representation of the divisor lattice of 12 (the T2 topos lattice)

This file realizes the divisor lattice of 12 (`Div12`) as the lattice of
**down-sets of its poset of join-irreducibles**, via Birkhoff's
representation theorem for finite distributive lattices.  This is the
lattice-level content of the **T2 construction** of the music-anchor
bridge note (`music-anchor/mazzola-bridge-note.md` §5): for a finite
distributive lattice `L`, Birkhoff gives `L ≅ O(P)` where `P` is the
poset of join-irreducibles, and `O(P)` (the down-sets of `P`, ordered by
inclusion) is exactly the subobject lattice of the terminal object in the
presheaf topos `Set^{Pᵒᵖ}`:

```
  O(P) = down-sets of P = Sub_{Set^{Pᵒᵖ}}(1).
```

So this file establishes — kernel-checked, by `decide` on finite data —
that the music-derived Heyting algebra `Div12` *is* the subobject lattice
of the terminal object of a concrete, natural presheaf topos, with **no
appeal to Mazzola's framework**: the construction is Birkhoff's theorem
applied to `Z/12`, a canonical mathematical fact.

## The poset of join-irreducibles

The join-irreducibles of `Div12` are the prime-power divisors of 12 —
`{2, 3, 4}` — equivalently the three transposition-symmetric pitch-class
sets that generate the symmetric lattice:

| `JoinIrr` | `Div12` | subgroup | musical object        | covers     |
|-----------|---------|----------|-----------------------|------------|
| `j2`      | `two`   | `⟨6⟩`    | tritone               | minimal    |
| `j4`      | `four`  | `⟨3⟩`    | diminished 7th        | `j2 < j4`  |
| `j3`      | `three` | `⟨4⟩`    | augmented triad       | minimal    |

The order is `j2 < j4` (the tritone is contained in the diminished 7th)
with `j3` incomparable to both — the three fundamental symmetric
pitch-class objects (Messiaen's modes of limited transposition), ordered
by inclusion.  `P` is *not* an arbitrary index category: it is the
natural generating structure of the symmetric pitch-class sets of `Z/12`.

## What is and is not established here

Established (kernel-checked): the Birkhoff isomorphism `Div12 ≅ O(P)` as
lattices (injective, surjective onto down-sets, order-preserving and
-reflecting, meet ↦ intersection, join ↦ union).  Since `O(P) =
Sub_{Set^{Pᵒᵖ}}(1)` by general topos theory, this realizes `Div12` as the
subobject lattice of a concrete presheaf topos.

Now also done (`Examples/MusicTopos.lean`, 2026-06): `Set^{Pᵒᵖ}` is
instantiated *in Lean* as an actual `CategoryTheory` object
(`MusicTopos := Pᵒᵖ ⥤ Type`) whose full elementary-topos hypothesis
bundle resolves (`musicTopos_isElementaryTopos`), so `Sub_{Set^{Pᵒᵖ}}(1)`
is a Heyting algebra on the concrete topos and `four_position_partition`
fires against it (`four_position_partition_musicTopos`).  The earlier
blocker — the absence of a presheaf subobject classifier in Mathlib — was
removed in Mathlib `v4.30` (`CategoryTheory.Presheaf.classifier`).

Still finer-grained (see `Examples/MusicTopos.lean` header): identifying
the *down-sets* `O(P)` below with Mathlib's `Subobject (⊤_ MusicTopos)`
type explicitly, and lifting the tritone operator to a non-trivial
endofunctor on the topos.  The lattice isomorphism below remains the full
*lattice-level* mathematical content of the T2 realization.
-/
import FalseWorkPapers.Examples.DivisorLattice12
import Mathlib.Data.Finset.Lattice.Basic
import Mathlib.Data.Finset.Lattice.Fold
import Mathlib.Data.Fintype.Powerset

namespace FalseWork.Lattice.Examples

namespace Div12

/-! ## The poset `P` of join-irreducibles -/

/-- The three join-irreducibles of `Div12`: the prime-power divisors of
12, equivalently the three symmetric pitch-class generators of `Z/12`. -/
inductive JoinIrr : Type
  | j2 : JoinIrr  -- tritone `⟨6⟩`        (= `Div12.two`)
  | j3 : JoinIrr  -- augmented triad `⟨4⟩` (= `Div12.three`)
  | j4 : JoinIrr  -- diminished 7th `⟨3⟩`  (= `Div12.four`)
  deriving DecidableEq, Repr

namespace JoinIrr

instance : Fintype JoinIrr :=
  ⟨{j2, j3, j4}, by intro x; cases x <;> decide⟩

/-- The inclusion order on `P`: `j2 < j4` (tritone ⊂ diminished 7th),
`j3` incomparable. -/
def leb : JoinIrr → JoinIrr → Bool
  | j2, j2 => true
  | j2, j4 => true
  | j3, j3 => true
  | j4, j4 => true
  | _,  _  => false

instance : LE JoinIrr := ⟨fun a b => leb a b = true⟩

instance decLE : ∀ a b : JoinIrr, Decidable (a ≤ b) := fun a b => by
  show Decidable (leb a b = true); exact decEq _ _

/-- The embedding of each join-irreducible into `Div12`. -/
def toDiv12 : JoinIrr → Div12
  | j2 => two
  | j3 => three
  | j4 => four

end JoinIrr

/-! ## Down-sets of `P` -/

open JoinIrr

/-- `S ⊆ P` is a down-set if it is closed downward under the order.  The
down-sets of `P`, ordered by inclusion, are exactly `Sub_{Set^{Pᵒᵖ}}(1)`. -/
def IsDownset (S : Finset JoinIrr) : Prop :=
  ∀ x ∈ S, ∀ y : JoinIrr, y ≤ x → y ∈ S

instance : DecidablePred IsDownset := fun _ => inferInstanceAs (Decidable (∀ _ ∈ _, _))

/-! ## The Birkhoff map `Div12 → O(P)` -/

/-- The Birkhoff representation map: each lattice element is sent to the
set of join-irreducibles below it.  This is the canonical iso of
Birkhoff's theorem, `a ↦ ↓a ∩ J(L)`. -/
def birkhoff (a : Div12) : Finset JoinIrr :=
  Finset.univ.filter (fun j => toDiv12 j ≤ a)

/-- `birkhoff` is injective: distinct lattice elements have distinct
join-irreducible down-sets (the separation half of Birkhoff). -/
theorem birkhoff_injective : Function.Injective birkhoff := by decide

/-- `birkhoff a` is always a down-set: the image lands in `O(P)`. -/
theorem birkhoff_isDownset : ∀ a : Div12, IsDownset (birkhoff a) := by decide

/-- `birkhoff` is an order embedding: lattice order = inclusion of
down-sets. -/
theorem birkhoff_mono : ∀ a b : Div12, a ≤ b ↔ birkhoff a ⊆ birkhoff b := by decide

/-- `birkhoff` sends meet to intersection. -/
theorem birkhoff_meet :
    ∀ a b : Div12, birkhoff (a ⊓ b) = birkhoff a ∩ birkhoff b := by decide

/-- `birkhoff` sends join to union. -/
theorem birkhoff_join :
    ∀ a b : Div12, birkhoff (a ⊔ b) = birkhoff a ∪ birkhoff b := by decide

/-- The inverse of `birkhoff` on down-sets: a set of join-irreducibles is
sent to the join (in `Div12`) of the elements it contains.  On down-sets
this is a two-sided inverse to `birkhoff`. -/
def fromDownset (S : Finset JoinIrr) : Div12 := S.sup toDiv12

/-- `fromDownset` is a left inverse to `birkhoff` on down-sets:
`birkhoff (fromDownset S) = S` whenever `S` is a down-set. -/
theorem birkhoff_fromDownset :
    ∀ S : Finset JoinIrr, IsDownset S → birkhoff (fromDownset S) = S := by decide

/-- `birkhoff` is surjective onto the down-sets: every down-set of `P`
is the image of some lattice element (the representation half of
Birkhoff).  Together with injectivity this gives the bijection
`Div12 ≃ O(P)`. -/
theorem birkhoff_surjOnDownsets
    (S : Finset JoinIrr) (h : IsDownset S) : ∃ a : Div12, birkhoff a = S :=
  ⟨fromDownset S, birkhoff_fromDownset S h⟩

/-- `birkhoff ⊥ = ∅` and `birkhoff ⊤ = univ`: the bounds are preserved. -/
theorem birkhoff_bot : birkhoff ⊥ = (∅ : Finset JoinIrr) := by decide

theorem birkhoff_top : birkhoff ⊤ = (Finset.univ : Finset JoinIrr) := by decide

/-- **Birkhoff representation of the music lattice (bundled).**

The divisor lattice of 12 is isomorphic, as a bounded lattice, to the
lattice `O(P)` of down-sets of its poset of join-irreducibles `P =
{tritone < diminished-7th, augmented-triad}`.  The map `birkhoff` is an
injective, bounded, meet- and join-preserving order embedding whose image
is exactly the down-sets of `P`.

Since `O(P) = Sub_{Set^{Pᵒᵖ}}(1)` by general topos theory, this realizes
`Div12` as the subobject lattice of the terminal object of the concrete
presheaf topos `Set^{Pᵒᵖ}` — the **T2 construction** of the bridge note —
built directly from the join-irreducibles of the symmetric pitch-class
lattice of `Z/12`, with no appeal to Mazzola's framework. -/
theorem birkhoff_representation :
    Function.Injective birkhoff ∧
    (∀ a : Div12, IsDownset (birkhoff a)) ∧
    (∀ S : Finset JoinIrr, IsDownset S → ∃ a : Div12, birkhoff a = S) ∧
    (∀ S : Finset JoinIrr, IsDownset S → birkhoff (fromDownset S) = S) ∧
    (∀ a b : Div12, a ≤ b ↔ birkhoff a ⊆ birkhoff b) ∧
    (∀ a b : Div12, birkhoff (a ⊓ b) = birkhoff a ∩ birkhoff b) ∧
    (∀ a b : Div12, birkhoff (a ⊔ b) = birkhoff a ∪ birkhoff b) ∧
    birkhoff ⊥ = (∅ : Finset JoinIrr) ∧
    birkhoff ⊤ = (Finset.univ : Finset JoinIrr) :=
  ⟨birkhoff_injective, birkhoff_isDownset, birkhoff_surjOnDownsets,
   birkhoff_fromDownset, birkhoff_mono, birkhoff_meet, birkhoff_join,
   birkhoff_bot, birkhoff_top⟩

/-! ## The tritone kernel as a principal down-set -/

/-- The kernel image realizes as the principal down-set of the tritone
generator: `birkhoff (tritoneClosure ⊥) = birkhoff two = {j2}`.  The
four-position kernel on the T2 topos is the down-set generated by the
single join-irreducible `j2` (the tritone). -/
theorem birkhoff_tritoneKernel : birkhoff two = {JoinIrr.j2} := by decide

end Div12

end FalseWork.Lattice.Examples
