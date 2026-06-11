/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# The ladder core: universal threshold and the order-embedded music lattice
(pre-registered in `validation/claims/ladder-core-threshold.md`, 2026-06-11)

Trigger: Citkin's Proposition 3.1 (arXiv:2512.05633, Dec 2025) — *any Heyting
algebra containing an ordinary element contains a subalgebra isomorphic to
`Z_n`, `n ≥ 6`* — welded to our trichotomy (`allFourCellsInhabited_iff`)
reads: every Heyting algebra with a non-degenerate four-cell kernel contains
the Rieger–Nishimura ladder inside it.  This file kernel-checks the fragment
of that weld available without the Nishimura normal-form theorem:

1. **Universal six-element threshold [K], unconditional.**
   `ordinary_card_ge_six` / `allFourCells_card_ge_six`: any finite Heyting
   algebra with an ordinary element — equivalently, with a non-degenerate
   four-cell kernel — has cardinality ≥ 6.  Abstract proof, *no enumeration,
   no [C]*: stronger on both sides than Citkin 2024 Prop. 4(c), which bounds
   one-generated algebras with ordinary generators.  `Z5.no_kernel` becomes
   a corollary of a universal law (`Z5.no_kernel_via_threshold`).

2. **The music lattice order-embeds into every non-degenerate instance [K].**
   `div12OrderEmbedding`: for ordinary `g`, the six elements
   `⊥, g, ¬g, ¬¬g, g ⊔ ¬g, ⊤` realize the exact Hasse structure of
   `Div12 = Z_6` — including both incomparabilities (`¬g ∥ ¬¬g`,
   `¬¬g ∥ g ⊔ ¬g`).  **Scope guard**: this is an *order*-embedding, NOT a
   Heyting-subalgebra embedding (the six elements need not be closed under
   `⇨`; in `Z_7` the ladder continues).  The subalgebra version is exactly
   Citkin's Prop. 3.1 [C], whose formalization needs the normal-form
   theorem — pre-registered [O], not claimed.

3. **H8 anatomy: the ladder core of the converse-counterexample is `Z_7`
   [K].**  `h8_ladder_core`: the explicit map `z7ToH8` is an injective
   Heyting embedding of `Z_7` into `H8` whose range is exactly the seven
   elements `≠ d` — the closed set from the non-generation proof.  So
   `H8 = Z_7-core + one extra dense element`, instantiating Citkin's
   Prop. 3.1 at the counterexample, and every Nishimura term value in `a`
   stays inside the core (`nishimuraTerm_a_mem_core`).

4. **The tritone is the unique generator of the music lattice [K].**
   `Div12.generator_unique`: no element of `Div12` other than the tritone
   Nishimura-generates it.  Kernel-checked instance of Citkin's remark
   (pers. comm. 2026-06-11) that one-generated Heyting algebras of
   cardinality > 5 have a unique generator.

5. **The dense-bottom lemma [K].**  `no_ordinary_of_least_nonzero`: a
   Heyting algebra with a least nonzero element has no ordinary elements —
   every nonzero element is dense.  Consequence ([C]-level, prose): the
   prohibited algebra `P2 ≅ 2 + Z_7` of Citkin's hereditary-structural-
   completeness criterion has *no* non-degenerate kernel, while
   `P1 ≅ Z_7` has exactly one — the prohibited family does not correlate
   with kernel-bearing.
-/
import Mathlib.Order.Heyting.Basic
import Mathlib.Order.Hom.Basic
import Mathlib.Data.Fintype.Card
import FalseWorkPapers.Examples.NishimuraTruncations
import FalseWorkPapers.Examples.NishimuraKernelLaw
import FalseWorkPapers.Examples.UniqueOrdinaryConverse

namespace FalseWork.Lattice

/-! ## 1. Consequences of ordinariness, abstractly -/

section OrdinaryFacts

variable {H : Type*} [HeytingAlgebra H] {g : H}

namespace IsOrdinary

theorem ne_bot (hg : IsOrdinary g) : g ≠ ⊥ := by
  rintro rfl
  exact hg.1 (by rw [compl_bot, compl_top])

theorem compl_compl_ne_bot (hg : IsOrdinary g) : gᶜᶜ ≠ ⊥ := fun h =>
  hg.ne_bot (le_bot_iff.mp (h ▸ le_compl_compl))

theorem ne_top (hg : IsOrdinary g) : g ≠ ⊤ := fun h =>
  hg.2 (by rw [h, compl_top])

end IsOrdinary

end OrdinaryFacts

/-! ## 2. The music lattice order-embeds into every non-degenerate instance -/

section LadderEmbedding

variable {H : Type*} [HeytingAlgebra H] {g : H}

open Examples in
/-- The six ladder elements, indexed by the music lattice: `one ↦ ⊥`,
`two ↦ g` (tritone ↦ kernel), `three ↦ ¬g`, `four ↦ ¬¬g`, `six ↦ g ⊔ ¬g`,
`twelve ↦ ⊤`. -/
def ladderEmbed (g : H) : Div12 → H
  | .one    => ⊥
  | .two    => g
  | .three  => gᶜ
  | .four   => gᶜᶜ
  | .six    => g ⊔ gᶜ
  | .twelve => ⊤

open Examples in
/-- For ordinary `g`, `ladderEmbed g` reflects and preserves order: the six
ladder elements realize the exact Hasse structure of `Div12 = Z_6`,
incomparabilities included. -/
theorem ladderEmbed_le_iff (hg : IsOrdinary g) (x y : Div12) :
    ladderEmbed g x ≤ ladderEmbed g y ↔ x ≤ y := by
  -- the eighteen non-relations, each forced by ordinariness
  have nb : g ≠ ⊥ := hg.ne_bot
  have ccnb : gᶜᶜ ≠ ⊥ := hg.compl_compl_ne_bot
  have h1 : ¬ g ≤ ⊥ := fun h => nb (le_bot_iff.mp h)
  have h2 : ¬ gᶜ ≤ ⊥ := fun h => hg.2 (le_bot_iff.mp h)
  have h3 : ¬ gᶜᶜ ≤ ⊥ := fun h => ccnb (le_bot_iff.mp h)
  have h4 : ¬ g ⊔ gᶜ ≤ ⊥ := fun h => nb (le_bot_iff.mp (le_sup_left.trans h))
  have h5 : ¬ (⊤ : H) ≤ ⊥ := fun h => hg.2 (le_bot_iff.mp (le_top.trans h))
  have h6 : ¬ g ≤ gᶜ := fun h => nb (by
    have h' := inf_eq_left.mpr h
    rw [inf_compl_self] at h'
    exact h'.symm)
  have h7 : ¬ gᶜ ≤ g := fun h => hg.2 (by
    have h' := inf_eq_left.mpr h
    rw [inf_comm gᶜ g, inf_compl_self] at h'
    exact h'.symm)
  have h8 : ¬ gᶜᶜ ≤ g := fun h => hg.1 (le_antisymm h le_compl_compl)
  have h9 : ¬ gᶜᶜ ≤ gᶜ := fun h => ccnb (by
    have h' := inf_eq_left.mpr h
    rw [inf_comm gᶜᶜ gᶜ, inf_compl_self] at h'
    exact h'.symm)
  have h18 : ¬ gᶜ ≤ gᶜᶜ := fun h => hg.2 (by
    have h' := inf_eq_left.mpr h
    rw [inf_compl_self] at h'
    exact h'.symm)
  have h10 : ¬ gᶜᶜ ≤ g ⊔ gᶜ := fun h => hg.1 (by
    have h' := inf_eq_left.mpr h
    rw [inf_sup_left, inf_eq_right.mpr le_compl_compl, inf_comm gᶜᶜ gᶜ,
      inf_compl_self, sup_bot_eq] at h'
    exact h'.symm)
  have h11 : ¬ g ⊔ gᶜ ≤ g := fun h => h7 (le_sup_right.trans h)
  have h12 : ¬ g ⊔ gᶜ ≤ gᶜ := fun h => h6 (le_sup_left.trans h)
  have h13 : ¬ g ⊔ gᶜ ≤ gᶜᶜ := fun h => h18 (le_sup_right.trans h)
  have h14 : ¬ (⊤ : H) ≤ g := fun h => hg.2 (by rw [top_le_iff.mp h, compl_top])
  have h15 : ¬ (⊤ : H) ≤ gᶜ := fun h => nb (by
    rw [← inf_top_eq g, ← top_le_iff.mp h]
    exact inf_compl_self g)
  have h16 : ¬ (⊤ : H) ≤ gᶜᶜ := fun h => hg.2 (by
    rw [← compl_compl_compl, top_le_iff.mp h, compl_top])
  have h17 : ¬ (⊤ : H) ≤ g ⊔ gᶜ := fun h => hg.1 (by
    rw [← inf_top_eq gᶜᶜ, ← top_le_iff.mp h, inf_sup_left,
      inf_eq_right.mpr le_compl_compl, inf_comm gᶜᶜ gᶜ, inf_compl_self,
      sup_bot_eq])
  cases x <;> cases y <;> simp only [ladderEmbed] <;>
    first
      | exact iff_of_true bot_le (by decide)
      | exact iff_of_true le_rfl (by decide)
      | exact iff_of_true le_top (by decide)
      | exact iff_of_true le_compl_compl (by decide)
      | exact iff_of_true le_sup_left (by decide)
      | exact iff_of_true le_sup_right (by decide)
      | exact iff_of_false h1 (by decide)
      | exact iff_of_false h2 (by decide)
      | exact iff_of_false h3 (by decide)
      | exact iff_of_false h4 (by decide)
      | exact iff_of_false h5 (by decide)
      | exact iff_of_false h6 (by decide)
      | exact iff_of_false h7 (by decide)
      | exact iff_of_false h8 (by decide)
      | exact iff_of_false h9 (by decide)
      | exact iff_of_false h10 (by decide)
      | exact iff_of_false h11 (by decide)
      | exact iff_of_false h12 (by decide)
      | exact iff_of_false h13 (by decide)
      | exact iff_of_false h14 (by decide)
      | exact iff_of_false h15 (by decide)
      | exact iff_of_false h16 (by decide)
      | exact iff_of_false h17 (by decide)
      | exact iff_of_false h18 (by decide)

open Examples in
/-- **The music lattice order-embeds into every Heyting algebra with an
ordinary element [K].**  The kernel goes to the tritone slot, the four
witnesses to the four named pitch-class slots.  Order-embedding only — the
Heyting-subalgebra strengthening is Citkin Prop. 3.1 [C]/[O], not claimed
here. -/
def div12OrderEmbedding (hg : IsOrdinary g) : Div12 ↪o H :=
  OrderEmbedding.ofMapLEIff (ladderEmbed g) (fun x y => ladderEmbed_le_iff hg x y)

end LadderEmbedding

/-! ## 3. The universal six-element threshold -/

section Threshold

variable {H : Type*} [HeytingAlgebra H]

/-- **Universal threshold [K], unconditional.**  Any finite Heyting algebra
containing an ordinary element has cardinality ≥ 6.  Generalizes Citkin 2024
Prop. 4(c) (stated there for generators of one-generated algebras) to
arbitrary ordinary elements of arbitrary Heyting algebras, with an abstract
proof: the order-embedded copy of `Div12 = Z_6` provides six distinct
elements. -/
theorem ordinary_card_ge_six [Fintype H] {g : H} (hg : IsOrdinary g) :
    6 ≤ Fintype.card H := by
  have h := Fintype.card_le_of_injective _ (div12OrderEmbedding hg).injective
  rwa [show Fintype.card Examples.Div12 = 6 from rfl] at h

/-- **The four-position partition needs six elements [K], universal form.**
No Heyting algebra with fewer than six elements admits a non-degenerate
four-cell kernel — on *any* substrate, not just the `Z_n` family.  The
`Z5.no_kernel` exhaustive check becomes an instance of this law. -/
theorem allFourCells_card_ge_six [Fintype H] {a : H}
    (h : AllFourCellsInhabited a) : 6 ≤ Fintype.card H :=
  ordinary_card_ge_six ((isOrdinary_iff_allFourCells a).mpr h)

/-- `Z_5`'s negative result re-derived from the universal threshold instead
of by exhaustion: `|Z_5| = 5 < 6`.  Two independent proofs — one exhaustive
(`Z5.no_kernel`), one structural — agree. -/
theorem Z5.no_kernel_via_threshold :
    ∀ a : Examples.Z5, ¬ AllFourCellsInhabited a := fun _ h =>
  absurd (allFourCells_card_ge_six h) (by decide)

end Threshold

/-! ## 4. The dense-bottom lemma: stacked bottoms kill the partition -/

section DenseBottom

variable {H : Type*} [HeytingAlgebra H]

/-- **Dense-bottom lemma [K].**  If a Heyting algebra has a least *nonzero*
element, it has no ordinary elements: every nonzero element is dense (its
complement must avoid the least element, hence is `⊥`), and `⊥` is regular.
Consequently the four-position partition is degenerate at every kernel.

Application ([C]-level, prose): for any Heyting algebra `A`, the sum
`2 + A` (a new bottom adjoined below `A`) has a least nonzero element — the
old bottom — so `2 + A` has no non-degenerate kernel.  In particular
Citkin's prohibited algebra `P2 ≅ 2 + Z_7` (arXiv:2512.05633 §3.1) carries
no kernel, while `P1 ≅ Z_7` carries exactly one: prohibitedness and
kernel-bearing do not align. -/
theorem no_ordinary_of_least_nonzero (e : H) (he : e ≠ ⊥)
    (hle : ∀ x : H, x ≠ ⊥ → e ≤ x) : ∀ a : H, ¬ IsOrdinary a := by
  rintro a ⟨hreg, hden⟩
  by_cases ha : a = ⊥
  · subst ha
    exact hreg (by rw [compl_bot, compl_top])
  · apply hden
    by_contra hac
    exact he (le_bot_iff.mp
      ((le_inf (hle a ha) (hle aᶜ hac)).trans (inf_compl_self a).le))

end DenseBottom

/-! ## 5. H8 anatomy: the ladder core of the counterexample is `Z_7` -/

namespace Examples

/-- The candidate Heyting embedding `Z_7 → H8`: the generator goes to the
unique ordinary element, the ladder terms to the closed seven-element set
from the non-generation proof. -/
def z7ToH8 : Z7 → H8
  | .bot => .bot
  | .g   => .a
  | .ng  => .n
  | .nng => .r
  | .gng => .an
  | .x6  => .rn
  | .top => .top

/-- **H8's ladder core is `Z_7` [K]** (instance of Citkin Prop. 3.1 [C] at
the converse-refutation witness).  `z7ToH8` is injective, preserves `⊓`,
`⊔`, `⇨`, `ᶜ`, `⊥`, `⊤`, sends the generator to the unique ordinary element
`a`, and its range is exactly the seven elements `≠ d`.  So
`H8 = Z_7-core + one extra dense element`: the subalgebra generated by
`H8`'s kernel is the cardinality-7 ladder truncation, and the surplus that
breaks one-generation is the single dense join-irreducible `d`. -/
theorem h8_ladder_core :
    Function.Injective z7ToH8 ∧
    (∀ x y, z7ToH8 (x ⊓ y) = z7ToH8 x ⊓ z7ToH8 y) ∧
    (∀ x y, z7ToH8 (x ⊔ y) = z7ToH8 x ⊔ z7ToH8 y) ∧
    (∀ x y, z7ToH8 (x ⇨ y) = z7ToH8 x ⇨ z7ToH8 y) ∧
    (∀ x, z7ToH8 xᶜ = (z7ToH8 x)ᶜ) ∧
    z7ToH8 Z7.g = H8.a ∧
    (∀ z : H8, (∃ x, z7ToH8 x = z) ↔ z ≠ H8.d) :=
  ⟨by decide, by decide, by decide, by decide, by decide, rfl, by decide⟩

/-- Every Nishimura term value in `H8`'s kernel lies in the `Z_7` core: the
term ladder never leaves the embedded copy.  (The general engine
`nishimuraTerm_mem_of_closed` applied to the core's complement
characterization.) -/
theorem nishimuraTerm_a_mem_core (m : ℕ) :
    ∃ x : Z7, z7ToH8 x = nishimuraTerm H8.a m := by
  have hne : nishimuraTerm H8.a m ≠ H8.d :=
    nishimuraTerm_mem_of_closed (fun z : H8 => z ≠ H8.d) H8.a
      (by decide) (by decide)
      (fun x => by revert x; decide)
      (fun x y => by revert x y; decide)
      (fun x y => by revert x y; decide) m
  exact (h8_ladder_core.2.2.2.2.2.2 _).mpr hne

/-! ## 6. The tritone is the unique generator of the music lattice -/

namespace Div12

/-- **Unique generator [K] (instance of Citkin's pers.-comm. remark,
2026-06-11: one-generated Heyting algebras of cardinality > 5 have a unique
generator).**  No element of `Div12` other than the tritone
Nishimura-generates the music lattice: for each other element, an explicit
proper closed predicate traps its term ladder away from the tritone. -/
theorem generator_unique (b : Div12)
    (hgen : ∀ y : Div12, y = ⊤ ∨ ∃ n : ℕ, y = nishimuraTerm b n) :
    b = Div12.two := by
  cases b with
  | two => rfl
  | one =>
      exfalso
      rcases hgen Div12.two with h | ⟨n, h⟩
      · exact absurd h (by decide)
      · have hmem := nishimuraTerm_mem_of_closed
          (fun z : Div12 => z = Div12.one ∨ z = Div12.twelve) Div12.one
          (by decide) (by decide) (by decide) (by decide) (by decide) n
        rw [← h] at hmem
        exact absurd hmem (by decide)
  | three =>
      exfalso
      rcases hgen Div12.two with h | ⟨n, h⟩
      · exact absurd h (by decide)
      · have hmem := nishimuraTerm_mem_of_closed
          (fun z : Div12 => z = Div12.one ∨ z = Div12.three ∨
            z = Div12.four ∨ z = Div12.twelve) Div12.three
          (by decide) (by decide) (by decide) (by decide) (by decide) n
        rw [← h] at hmem
        exact absurd hmem (by decide)
  | four =>
      exfalso
      rcases hgen Div12.two with h | ⟨n, h⟩
      · exact absurd h (by decide)
      · have hmem := nishimuraTerm_mem_of_closed
          (fun z : Div12 => z = Div12.one ∨ z = Div12.three ∨
            z = Div12.four ∨ z = Div12.twelve) Div12.four
          (by decide) (by decide) (by decide) (by decide) (by decide) n
        rw [← h] at hmem
        exact absurd hmem (by decide)
  | six =>
      exfalso
      rcases hgen Div12.two with h | ⟨n, h⟩
      · exact absurd h (by decide)
      · have hmem := nishimuraTerm_mem_of_closed
          (fun z : Div12 => z = Div12.one ∨ z = Div12.six ∨
            z = Div12.twelve) Div12.six
          (by decide) (by decide) (by decide) (by decide) (by decide) n
        rw [← h] at hmem
        exact absurd hmem (by decide)
  | twelve =>
      exfalso
      rcases hgen Div12.two with h | ⟨n, h⟩
      · exact absurd h (by decide)
      · have hmem := nishimuraTerm_mem_of_closed
          (fun z : Div12 => z = Div12.one ∨ z = Div12.twelve) Div12.twelve
          (by decide) (by decide) (by decide) (by decide) (by decide) n
        rw [← h] at hmem
        exact absurd hmem (by decide)

end Div12

end Examples

end FalseWork.Lattice
