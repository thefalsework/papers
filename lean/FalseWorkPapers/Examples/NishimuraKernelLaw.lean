/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# The all-n kernel law: forced kernel = free generator, abstractly
(math anchor, upgrade of `NishimuraTruncations.lean` outcome (A) from
three checked sizes to a law for the whole one-generated family)

`NishimuraTruncations.lean` established by `decide` that at `n = 6, 7, 8`
the unique four-cell kernel of the one-generated Heyting algebra `Z_n` is
the free generator, and pre-registered that the extension to *all* `n`
remained open.  This file closes that gap **abstractly** — without building
any further finite algebras — by factoring the result into two pieces:

1. **`allFourCellsInhabited_iff` (general, unconditional [K]).**
   In *any* Heyting algebra, all four cells are inhabited at kernel `a` iff

   `a ≠ ⊥  ∧  aᶜ ≠ ⊥  ∧  aᶜᶜ ≠ a`

   — the kernel must be non-zero, non-polar (its complement is not `⊥`),
   and non-regular (double negation does not collapse).  This is the
   abstract characterization of non-degenerate Layer-L kernels; it
   retroactively explains every earlier instance (Boolean algebras have no
   kernel because every element is regular; `Z_5` has none because every
   element fails one of the three conditions).

2. **`nishimura_kernel_unique` (conditional, [K]).**
   If every element of `H` is a value of a Nishimura term in `g`
   (`nishimuraTerm g n`, the canonical term sequence of the
   Rieger–Nishimura lattice) and `g` is *ordinary* (`¬g ≠ ⊥`, `¬¬g ≠ g`),
   then the **unique** element of `H` at which all four cells are inhabited
   is `g` itself.  Proof shape: `x₀ = ⊥` fails non-zeroness; `x₁ = ¬g` and
   `x₃ = ¬¬g` are regular by the triple-negation law `¬¬¬b = ¬b`; every
   `xₙ` with `n ≥ 4` lies above `x₄ = ¬g ⊔ g` (`four_le_nishimuraTerm`,
   by strong induction on the term recursion) and hence has `⊥` complement;
   only `x₂ = g` survives.

## What this upgrades, and what stays [C]

By Nishimura's theorem (Nishimura 1960; algebraic proof in Citkin 2024),
*every* one-generated Heyting algebra has the enumeration property required
by the hypothesis `hgen`: each of its elements is a Nishimura term value in
the generator.  Hence — conditional only on that classical enumeration
result **[C]** — the law covers:

* **every finite truncation `Z_n`** (`n ≥ 6`, generator ordinary), not just
  the three sizes checked by `decide`; and
* **the full infinite Rieger–Nishimura lattice `F(1)`** — the free Heyting
  algebra on one generator — itself: its unique four-cell kernel is the
  free generator `p`.

The conditional theorem itself is kernel-checked with the hypothesis
explicit, so nothing is borrowed: the [C] citation enters only when the
hypothesis is *discharged* for a particular algebra by quoting Nishimura's
enumeration.  For `Div12 = Z_6` the hypothesis is discharged *inside Lean*
(`Div12.nishimura_generated`, by `decide`), giving a second, independent
derivation of `Div12.kernel_unique` (`Div12.kernel_unique_via_law`) — an
internal consistency weld between the abstract law and the exhaustive
finite check.

## What is NOT claimed

* The Nishimura enumeration ("one-generated ⇒ every element is a term
  value") is **not** formalized here; it is the [C] input.  Formalizing it
  would mean proving the term-identity tables of the Nishimura theorem.
* The threshold fact "the generator of a one-generated algebra is ordinary
  iff `|H| ≥ 6`" (Citkin Prop. 4(c)) is likewise cited, not proved; the
  law takes ordinariness as an explicit hypothesis instead.
-/
import Mathlib.Order.Heyting.Basic
import FalseWorkPapers.Examples.NishimuraTruncations

namespace FalseWork.Lattice

/-! ## 1. The abstract characterization of non-degenerate kernels -/

section Characterization

variable {H : Type*} [HeytingAlgebra H]

/-- **Kernel non-degeneracy trichotomy (general [K]).**  In any Heyting
algebra, all four cells of the four-position partition are inhabited at
kernel `a` iff `a` is non-zero, non-polar, and non-regular:

* `a ≠ ⊥` — Infrastructure needs a non-zero element below `a`;
* `aᶜ ≠ ⊥` — Refusal needs a non-zero element below the complement
  (and Distribution needs mass on both sides);
* `aᶜᶜ ≠ a` — Exploitation needs the double-negation residue to be a
  *strict* extension of `a`.

The witnesses in the constructive direction are `a` (Infrastructure),
`⊤` (Distribution), `aᶜᶜ` (Exploitation), `aᶜ` (Refusal).  In a Boolean
algebra `aᶜᶜ = a` always, so no kernel is ever non-degenerate — the
partition's fourth cell is an intuitionistic phenomenon.

**Standard terminology**: the right-hand side says exactly that `a` is
*ordinary* in the standard sense (neither regular `¬¬a = a` nor dense
`¬a = ⊥`; the `a ≠ ⊥` conjunct is implied, `⊥` being regular) — the
terminology of Citkin 2024 §2.1.  So: *the four-position partition is
non-degenerate precisely at the ordinary elements.*  Citkin's paper
already observes that `Z_2`–`Z_5` contain no ordinary elements and that
an ordinary generator forces `|A| > 5` (Prop. 4(c)); the `Z5.no_kernel`
check is therefore a kernel-checked re-derivation of a known
observation, while the *uniqueness* of the ordinary element
(`nishimura_kernel_unique` below) is not stated in that paper. -/
theorem allFourCellsInhabited_iff (a : H) :
    AllFourCellsInhabited a ↔ a ≠ ⊥ ∧ aᶜ ≠ ⊥ ∧ aᶜᶜ ≠ a := by
  unfold AllFourCellsInhabited IsLatticeInfrastructure IsLatticeDistribution
    IsLatticeExploitation IsLatticeRefusal
  constructor
  · rintro ⟨⟨x, hx0, hxa⟩, -, ⟨z, hza, hzn⟩, ⟨w, hw0, hwa⟩⟩
    refine ⟨?_, ?_, ?_⟩
    · rintro rfl; exact hx0 (le_bot_iff.mp hxa)
    · intro h; rw [h] at hwa; exact hw0 (le_bot_iff.mp hwa)
    · intro h; rw [h] at hza; exact hzn hza
  · rintro ⟨h0, hc, hr⟩
    refine ⟨⟨a, h0, le_refl a⟩, ⟨⊤, ?_, ?_⟩,
      ⟨aᶜᶜ, le_refl _, fun h => hr (le_antisymm h le_compl_compl)⟩,
      ⟨aᶜ, hc, le_refl _⟩⟩
    · rwa [top_inf_eq]
    · rwa [top_inf_eq]

end Characterization

/-! ## 2. The Nishimura term sequence, in any Heyting algebra -/

section NishimuraTerm

variable {H : Type*} [HeytingAlgebra H]

/-- The Nishimura term sequence in a generator `g`, the canonical element
enumeration of the Rieger–Nishimura lattice (Citkin 2024, §2):

```
x₀ = g ⊓ ¬g (= ⊥),  x₁ = ¬g,  x₂ = g,  x₃ = x₁ ⇨ x₀ (= ¬¬g),
x₄ = x₁ ⊔ x₂,  x_{2k+3} = x_{2k+1} ⇨ x_{2k},  x_{2k+4} = x_{2k+1} ⊔ x_{2k+2}.
```

The base cases `x₀ = ⊥` and `x₃ = ¬¬g` are pre-simplified (justified by
`inf_compl_self` and `himp_bot`; see `nishimuraTerm_zero_eq` /
`nishimuraTerm_three_eq`), so the recursion proper starts at index 5:
odd `m = n+5` with `n` even gives `x_m = x_{m-2} ⇨ x_{m-3}`, even `m`
gives `x_m = x_{m-3} ⊔ x_{m-2}`. -/
def nishimuraTerm (g : H) : ℕ → H
  | 0 => ⊥
  | 1 => gᶜ
  | 2 => g
  | 3 => gᶜᶜ
  | 4 => gᶜ ⊔ g
  | (n + 5) =>
      if n % 2 = 0 then nishimuraTerm g (n + 3) ⇨ nishimuraTerm g (n + 2)
      else nishimuraTerm g (n + 2) ⊔ nishimuraTerm g (n + 3)

/-- Fidelity of the pre-simplified base case `x₀`: `g ⊓ ¬g = ⊥`. -/
theorem nishimuraTerm_zero_eq (g : H) : nishimuraTerm g 0 = g ⊓ gᶜ := by
  simp [nishimuraTerm, inf_compl_self]

/-- Fidelity of the pre-simplified base case `x₃`: `x₁ ⇨ x₀ = ¬g ⇨ ⊥ = ¬¬g`. -/
theorem nishimuraTerm_three_eq (g : H) :
    nishimuraTerm g 3 = nishimuraTerm g 1 ⇨ nishimuraTerm g 0 := by
  simp [nishimuraTerm, himp_bot]

/-- Every Nishimura term from `x₄` on lies above `x₄ = ¬g ⊔ g`.  The key
consequence: all such terms have `⊥` complement, so none of them can be a
non-degenerate kernel. -/
theorem four_le_nishimuraTerm (g : H) :
    ∀ n, 4 ≤ n → gᶜ ⊔ g ≤ nishimuraTerm g n := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro hn
    rcases Nat.lt_or_ge n 5 with h5 | h5
    · -- n = 4: x₄ = ¬g ⊔ g itself.
      obtain rfl : n = 4 := by omega
      simp [nishimuraTerm]
    · obtain ⟨m, rfl⟩ : ∃ m, n = m + 5 := ⟨n - 5, by omega⟩
      by_cases hm0 : m % 2 = 0
      · -- odd index m+5: x_{m+5} = x_{m+3} ⇨ x_{m+2}
        have he : nishimuraTerm g (m + 5)
            = nishimuraTerm g (m + 3) ⇨ nishimuraTerm g (m + 2) := by
          simp [nishimuraTerm, hm0]
        rw [he]
        rcases Nat.eq_zero_or_pos m with rfl | hpos
        · -- the one genuinely new computation: x₅ = ¬¬g ⇨ g ≥ ¬g ⊔ g.
          show gᶜ ⊔ g ≤ nishimuraTerm g 3 ⇨ nishimuraTerm g 2
          have h3 : nishimuraTerm g 3 = gᶜᶜ := by simp [nishimuraTerm]
          have h2 : nishimuraTerm g 2 = g := by simp [nishimuraTerm]
          rw [h3, h2, le_himp_iff, inf_sup_right]
          refine sup_le ?_ inf_le_left
          rw [inf_compl_self]
          exact bot_le
        · -- m even and positive, so m ≥ 2 and x_{m+2} is in induction range.
          have h2m : 2 ≤ m := by omega
          exact le_trans (ih (m + 2) (by omega) (by omega)) le_himp
      · -- even index m+5: x_{m+5} = x_{m+2} ⊔ x_{m+3}
        have hm1 : m % 2 = 1 := by omega
        have he : nishimuraTerm g (m + 5)
            = nishimuraTerm g (m + 2) ⊔ nishimuraTerm g (m + 3) := by
          simp [nishimuraTerm, hm1]
        rw [he]
        exact le_trans (ih (m + 3) (by omega) (by omega)) le_sup_right

end NishimuraTerm

/-! ## 3. The kernel law -/

section KernelLaw

variable {H : Type*} [HeytingAlgebra H]

/-- **The all-n kernel law (conditional [K]).**  Let `H` be a Heyting
algebra and `g : H` an *ordinary* element (`¬g ≠ ⊥`, `¬¬g ≠ g`) such that
every element of `H` is a Nishimura term value in `g`.  Then the unique
element of `H` at which all four cells of the four-position partition are
inhabited is `g` itself.

By Nishimura's theorem **[C]** (Nishimura 1960; Citkin 2024) the
enumeration hypothesis `hgen` holds for *every* one-generated Heyting
algebra with generator `g` — in particular for every finite truncation
`Z_n` and for the full Rieger–Nishimura lattice `F(1)`, the free Heyting
algebra on one generator.  So conditional only on that classical result,
the forced kernel of the *entire* one-generated family is the free
generator: the `n = 6, 7, 8` `decide`-checks of
`NishimuraTruncations.lean` are samples of this law. -/
theorem nishimura_kernel_unique (g : H) (h1 : gᶜ ≠ ⊥) (h2 : gᶜᶜ ≠ g)
    (hgen : ∀ y : H, y = ⊤ ∨ ∃ n : ℕ, y = nishimuraTerm g n) (a : H) :
    AllFourCellsInhabited a ↔ a = g := by
  rw [allFourCellsInhabited_iff]
  constructor
  · rintro ⟨h0, hc, hr⟩
    rcases hgen a with rfl | ⟨n, rfl⟩
    · -- a = ⊤ is polar: ⊤ᶜ = ⊥.
      exact absurd compl_top hc
    · rcases n with - | - | - | - | k
      · -- x₀ = ⊥ fails non-zeroness.
        exact absurd (by simp [nishimuraTerm]) h0
      · -- x₁ = ¬g is regular: ¬¬¬g = ¬g.
        exact absurd (by simp [nishimuraTerm]) hr
      · -- x₂ = g: the kernel.
        simp [nishimuraTerm]
      · -- x₃ = ¬¬g is regular: ¬¬¬¬g = ¬¬g.
        exact absurd (by simp [nishimuraTerm]) hr
      · -- xₙ, n ≥ 4: above ¬g ⊔ g, hence polar.
        exfalso
        apply hc
        have h4 : gᶜ ⊔ g ≤ nishimuraTerm g (k + 4) :=
          four_le_nishimuraTerm g (k + 4) (by omega)
        have hle : (nishimuraTerm g (k + 4))ᶜ ≤ (gᶜ ⊔ g)ᶜ := compl_anti h4
        rw [compl_sup] at hle
        have hz : gᶜᶜ ⊓ gᶜ = ⊥ := by rw [inf_comm]; exact inf_compl_self gᶜ
        rw [hz] at hle
        exact le_bot_iff.mp hle
  · intro ha
    subst ha
    have hg0 : a ≠ ⊥ := by
      rintro rfl
      exact h2 (by rw [compl_bot, compl_top])
    exact ⟨hg0, h1, h2⟩

end KernelLaw

/-! ## 3a. The ordinary-element form: the law as pure algebra

The partition-flavored statement above is, by the trichotomy, exactly a
statement about *ordinary* elements in the standard sense.  This section
states that form directly, so the algebraic claim ("the ordinary element
of a one-generated Heyting algebra is unique") is itself the checked
theorem rather than an inference left to the reader. -/

section OrdinaryForm

variable {H : Type*} [HeytingAlgebra H]

/-- An element of a Heyting algebra is **ordinary** (standard terminology;
Citkin 2024 §2.1) if it is neither regular (`¬¬a = a`) nor dense
(`¬a = ⊥`). -/
def IsOrdinary (a : H) : Prop := aᶜᶜ ≠ a ∧ aᶜ ≠ ⊥

/-- The ordinary elements are exactly the non-degenerate four-cell
kernels — the purely algebraic face of `allFourCellsInhabited_iff`.  The
`a ≠ ⊥` conjunct of the trichotomy is absorbed: `⊥` is regular. -/
theorem isOrdinary_iff_allFourCells (a : H) :
    IsOrdinary a ↔ AllFourCellsInhabited a := by
  rw [allFourCellsInhabited_iff]
  unfold IsOrdinary
  constructor
  · rintro ⟨hr, hc⟩
    refine ⟨?_, hc, hr⟩
    rintro rfl
    exact hr (by rw [compl_bot, compl_top])
  · rintro ⟨-, hc, hr⟩
    exact ⟨hr, hc⟩

/-- **Uniqueness of the ordinary element (algebraic form of the all-n
law).**  If `g` is ordinary and every element of `H` is a Nishimura term
value in `g` — by Nishimura's theorem [C], every one-generated Heyting
algebra with generator `g` qualifies — then `g` is the **unique** ordinary
element of `H`.  This is the exact statement posed for prior-art
adjudication in `docs/outreach/citkin-email.md`, checked directly. -/
theorem nishimura_ordinary_unique (g : H) (hg : IsOrdinary g)
    (hgen : ∀ y : H, y = ⊤ ∨ ∃ n : ℕ, y = nishimuraTerm g n) (a : H) :
    IsOrdinary a ↔ a = g := by
  rw [isOrdinary_iff_allFourCells]
  exact nishimura_kernel_unique g hg.2 hg.1 hgen a

end OrdinaryForm

/-! ## 4. The consistency weld: re-deriving `Div12.kernel_unique` -/

namespace Examples

namespace Div12

/-- `Div12` satisfies the law's enumeration hypothesis *inside Lean*: every
element of the music lattice is a Nishimura term value in the tritone
(indices: `one ↦ x₀`, `three ↦ x₁`, `two ↦ x₂`, `four ↦ x₃`, `six ↦ x₄`,
`twelve ↦ x₆`).  This is `one_generated_by_tritone` re-expressed against
the canonical term sequence — no [C] citation needed at cardinality 6. -/
theorem nishimura_generated :
    ∀ y : Div12, y = ⊤ ∨ ∃ n : ℕ, y = nishimuraTerm Div12.two n := by
  intro y
  right
  cases y with
  | one    => exact ⟨0, by rw [show nishimuraTerm Div12.two 0 = ⊥ from by
                simp [nishimuraTerm]]; decide⟩
  | two    => exact ⟨2, by rw [show nishimuraTerm Div12.two 2 = Div12.two from by
                simp [nishimuraTerm]]⟩
  | three  => exact ⟨1, by rw [show nishimuraTerm Div12.two 1 = Div12.twoᶜ from by
                simp [nishimuraTerm]]; decide⟩
  | four   => exact ⟨3, by rw [show nishimuraTerm Div12.two 3 = Div12.twoᶜᶜ from by
                simp [nishimuraTerm]]; decide⟩
  | six    => exact ⟨4, by rw [show nishimuraTerm Div12.two 4 = Div12.twoᶜ ⊔ Div12.two from by
                simp [nishimuraTerm]]; decide⟩
  | twelve => exact ⟨6, by rw [show nishimuraTerm Div12.two 6
                  = Div12.twoᶜᶜ ⊔ (Div12.twoᶜ ⊔ Div12.two) from by
                simp [nishimuraTerm]]; decide⟩

/-- **Consistency weld.**  `Div12.kernel_unique` re-derived from the
abstract law `nishimura_kernel_unique` instead of by exhaustive `decide`:
the tritone is ordinary and `Div12` is Nishimura-generated by it, so the
law forces the tritone as the unique kernel.  Two independent proofs of the
same statement — one exhaustive, one structural — agreeing is the weld. -/
theorem kernel_unique_via_law :
    ∀ a : Div12, AllFourCellsInhabited a ↔ a = Div12.two := fun a =>
  nishimura_kernel_unique Div12.two (by decide) (by decide)
    nishimura_generated a

/-- **Ordinary-element uniqueness at `n = 6`, unconditional.**  Exhaustive:
the tritone is the unique ordinary element of `Div12 = Z_6`. -/
theorem ordinary_unique : ∀ a : Div12, IsOrdinary a ↔ a = Div12.two := by
  unfold IsOrdinary; decide

end Div12

/-- **Ordinary-element uniqueness at `n = 7`, unconditional.**  Exhaustive:
the generator is the unique ordinary element of `Z_7`. -/
theorem Z7.ordinary_unique : ∀ a : Z7, IsOrdinary a ↔ a = Z7.g := by
  unfold IsOrdinary; decide

/-- **Ordinary-element uniqueness at `n = 8`, unconditional.**  Exhaustive:
the generator is the unique ordinary element of `Z_8`. -/
theorem Z8.ordinary_unique : ∀ a : Z8, IsOrdinary a ↔ a = Z8.g := by
  unfold IsOrdinary; decide

end Examples

end FalseWork.Lattice
