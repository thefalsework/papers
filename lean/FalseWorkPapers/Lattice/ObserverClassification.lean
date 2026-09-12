/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# Observer classification and the trace characterization (C1–C2 / E5)

Registered spec: `bridge-study/SPEC.md`, Phase 2 (committed 2026-09-12
before the brute-force check ran; postscript same day).  This file
kernel-checks the two facts the Phase-2 script confirmed on all 92
Phase-1 algebras:

* **C1 (`subNucleusEquiv`).**  On the down-set algebra `D(P)` of a
  finite poset, nuclei are exactly **sub-ecosystem observers**: the map
  `S ↦ j_S`, where `j_S U = { x | ↓x ∩ S ⊆ U }`, is a bijection from
  subsets of `P` to nuclei on `LowerSet P`.  Injectivity is the
  strict-cone probe (`x` survives in `j_S(↓x ∖ {x})` iff `x ∉ S`);
  surjectivity recovers `S` from any nucleus as the set of points that
  `j` distinguishes from their strict cone, by well-founded induction
  on the finite order.  This is the finite Alexandrov case of the
  frame-theoretic classification (Simmons; Bezhanishvili–Harding).

* **C2 / E5 (`opens_subNucleus_iff`).**  The observer `j_S` keeps the
  distinction `k` open — `Opens (j_S) k`, the aperture membership
  predicate — **iff the trace `k ∩ S` is ordinary in the
  sub-ecosystem's own down-set algebra** `D(S)` (`OrdinaryElement`
  verbatim: not regular and not dense).  Combined with C1 this yields
  the characterization theorem (`aperture_eq_card_ordinary_traces`):

      aperture(k) = #{ S ⊆ P : k ∩ S is ordinary in D(S) }

  — the count of perspectives from which the cone remains a generative
  (four-cell-inhabiting) distinction.  This is the weld that turns the
  Phase-2 empirical identity into a theorem: the graph-side quantity
  the depth-test scripts compute is *definitionally* the lattice-side
  aperture of `CoApertureClosedForm`.
-/
import FalseWorkPapers.Lattice.CoApertureClosedForm
import Mathlib.Order.UpperLower.CompleteLattice
import Mathlib.Order.UpperLower.Principal

set_option linter.unusedSectionVars false

namespace FalseWork.Lattice

variable {P : Type*} [PartialOrder P]

/-! ## Pointwise formulas for the Heyting operations on down-sets

The Heyting structure on `LowerSet P` comes abstractly from complete
distributivity; these lemmas give the concrete membership formulas the
rest of the file computes with. -/

theorem LowerSet.le_iff' {U V : LowerSet P} :
    U ≤ V ↔ ∀ ⦃x⦄, x ∈ U → x ∈ V :=
  Iff.rfl

/-- Membership in a Heyting implication of lower sets is the Kripke
clause: `x ∈ U ⇨ V` iff every point below `x` that is in `U` is in
`V`. -/
theorem LowerSet.mem_himp_iff {U V : LowerSet P} {x : P} :
    x ∈ U ⇨ V ↔ ∀ y, y ≤ x → y ∈ U → y ∈ V := by
  constructor
  · intro hx y hyx hyU
    have hy : y ∈ U ⇨ V := (U ⇨ V).lower hyx hx
    exact LowerSet.le_iff'.mp (himp_inf_le (a := U) (b := V)) ⟨hy, hyU⟩
  · intro h
    have hle : (⟨{z | ∀ y, y ≤ z → y ∈ U → y ∈ V},
        fun a b hba ha y hyb hyU => ha y (hyb.trans hba) hyU⟩ : LowerSet P)
        ≤ U ⇨ V := by
      rw [le_himp_iff]
      exact LowerSet.le_iff'.mpr fun z hz => hz.1 z le_rfl hz.2
    exact LowerSet.le_iff'.mp hle h

/-! ## The sub-ecosystem observer `j_S` -/

/-- The **sub-ecosystem observer** induced by `S ⊆ P`:
`j_S U = { x | ↓x ∩ S ⊆ U }`.  The observer sees only the packages in
`S`; a point is "in `U` as far as `j_S` can tell" when every `S`-package
below it is genuinely in `U`. -/
def subNucleus (S : Set P) (U : LowerSet P) : LowerSet P :=
  ⟨{x | ∀ s ∈ S, s ≤ x → s ∈ U},
   fun _a _b hba ha s hs hsb => ha s hs (hsb.trans hba)⟩

@[simp]
theorem mem_subNucleus {S : Set P} {U : LowerSet P} {x : P} :
    x ∈ subNucleus S U ↔ ∀ s ∈ S, s ≤ x → s ∈ U :=
  Iff.rfl

/-- `j_S` is a nucleus (inflationary, idempotent, meet-preserving). -/
theorem subNucleus_isNucleus (S : Set P) : IsNucleus (subNucleus S) := by
  refine ⟨fun U => ?_, fun U => ?_, fun U V => ?_⟩
  · exact LowerSet.le_iff'.mpr fun x hx s _hs hsx => U.lower hsx hx
  · refine SetLike.ext fun x => ?_
    constructor
    · intro h s hs hsx
      exact h s hs hsx s hs le_rfl
    · intro h s hs hsx s' hs' hs's
      exact h s' hs' (hs's.trans hsx)
  · refine SetLike.ext fun x => ?_
    constructor
    · intro h
      exact ⟨fun s hs hsx => (h s hs hsx).1, fun s hs hsx => (h s hs hsx).2⟩
    · intro h s hs hsx
      exact ⟨h.1 s hs hsx, h.2 s hs hsx⟩

/-! ## Injectivity: the strict-cone probe -/

/-- The strict cone `↓x ∖ {x}` as a lower set (needs antisymmetry). -/
def strictLower (x : P) : LowerSet P :=
  ⟨{y | y ≤ x ∧ y ≠ x}, by
    intro a b hba ha
    refine ⟨hba.trans ha.1, fun hbx => ha.2 (le_antisymm ha.1 ?_)⟩
    rw [← hbx]
    exact hba⟩

@[simp]
theorem mem_strictLower {x y : P} :
    y ∈ strictLower x ↔ y ≤ x ∧ y ≠ x :=
  Iff.rfl

/-- The probe: `x` survives in `j_S (↓x ∖ {x})` exactly when the
observer does not see `x`. -/
theorem mem_subNucleus_strictLower_self {S : Set P} {x : P} :
    x ∈ subNucleus S (strictLower x) ↔ x ∉ S := by
  constructor
  · intro h hxS
    exact (h x hxS le_rfl).2 rfl
  · intro hxS s hs hsx
    exact ⟨hsx, fun hsx' => hxS (hsx' ▸ hs)⟩

/-- Distinct subsets give distinct observers. -/
theorem subNucleus_injective :
    Function.Injective (subNucleus : Set P → LowerSet P → LowerSet P) := by
  intro S S' h
  ext x
  have h1 : x ∈ subNucleus S (strictLower x) ↔
      x ∈ subNucleus S' (strictLower x) := by rw [h]
  rw [mem_subNucleus_strictLower_self, mem_subNucleus_strictLower_self] at h1
  exact not_iff_not.mp h1

/-! ## Surjectivity: every nucleus is a sub-ecosystem observer -/

/-- The **support** of a nucleus on `D(P)`: the points `j` can tell
apart from their strict cone.  For `j_S` this recovers `S`. -/
def nucleusSupport (j : LowerSet P → LowerSet P) : Set P :=
  {x | x ∉ j (strictLower x)}

@[simp]
theorem nucleusSupport_subNucleus (S : Set P) :
    nucleusSupport (subNucleus S) = S := by
  ext x
  simp only [nucleusSupport, Set.mem_setOf_eq,
    mem_subNucleus_strictLower_self, not_not]

/-- **C1, surjectivity.**  On the down-set algebra of a finite poset,
every nucleus is the sub-ecosystem observer of its support.  One
inclusion is meet-preservation applied to `↓s ⊓ U ≤ ↓s ∖ {s}`; the
other is well-founded induction on the finite order using idempotence.
-/
theorem IsNucleus.eq_subNucleus [Finite P] {j : LowerSet P → LowerSet P}
    (hj : IsNucleus j) : j = subNucleus (nucleusSupport j) := by
  funext U
  apply le_antisymm
  · -- j U ≤ j_S U
    refine LowerSet.le_iff'.mpr fun x hx s hs hsx => ?_
    by_contra hsU
    have hsub : LowerSet.Iic s ⊓ U ≤ strictLower s := by
      refine LowerSet.le_iff'.mpr fun y hy => ?_
      exact ⟨LowerSet.mem_Iic_iff.mp hy.1, fun hys => hsU (hys ▸ hy.2)⟩
    have h2 : s ∈ j (LowerSet.Iic s) :=
      LowerSet.le_iff'.mp (hj.1 _) (LowerSet.mem_Iic_iff.mpr le_rfl)
    have h3 : s ∈ j U := (j U).lower hsx hx
    have h4 : s ∈ j (LowerSet.Iic s ⊓ U) := by
      rw [hj.2.2]
      exact ⟨h2, h3⟩
    exact hs (LowerSet.le_iff'.mp (hj.monotone hsub) h4)
  · -- j_S U ≤ j U, by well-founded induction on x
    refine LowerSet.le_iff'.mpr fun x => ?_
    induction x using WellFoundedLT.induction with
    | ind x ih =>
      intro hx
      by_cases hxS : x ∈ nucleusSupport j
      · exact LowerSet.le_iff'.mp (hj.1 U) (hx x hxS le_rfl)
      · have hxj : x ∈ j (strictLower x) := not_not.mp hxS
        have hstep : strictLower x ≤ j U := by
          refine LowerSet.le_iff'.mpr fun y hy => ?_
          exact ih y (lt_of_le_of_ne hy.1 hy.2)
            ((subNucleus (nucleusSupport j) U).lower hy.1 hx)
        have hle : j (strictLower x) ≤ j U := by
          calc j (strictLower x) ≤ j (j U) := hj.monotone hstep
            _ = j U := hj.2.1 U
        exact LowerSet.le_iff'.mp hle hxj

/-- **C1 (observer classification).**  On the down-set algebra of a
finite poset, `S ↦ j_S` is a bijection between subsets of `P` and
nuclei on `D(P)`.  In particular there are exactly `2^|P|` observers —
the count the Phase-2 script verified on all 92 Phase-1 algebras. -/
def subNucleusEquiv [Finite P] :
    Set P ≃ {j : LowerSet P → LowerSet P // IsNucleus j} where
  toFun S := ⟨subNucleus S, subNucleus_isNucleus S⟩
  invFun j := nucleusSupport j.1
  left_inv S := nucleusSupport_subNucleus S
  right_inv j := Subtype.ext j.2.eq_subNucleus.symm

/-! ## The trace and its transfer lemmas -/

/-- The **trace** of a lower set on a sub-ecosystem `S`: the down-set
`k ∩ S` inside `D(S)` (lower sets of the induced order on `↥S`). -/
def traceDown (S : Set P) (U : LowerSet P) : LowerSet ↥S :=
  ⟨{s | (s : P) ∈ U},
   fun _a _b hba ha => U.lower (Subtype.coe_le_coe.mpr hba) ha⟩

@[simp]
theorem mem_traceDown {S : Set P} {U : LowerSet P} {s : ↥S} :
    s ∈ traceDown S U ↔ (s : P) ∈ U :=
  Iff.rfl

/-- The observer cannot refine its own world: `j_S U` and `U` have the
same trace on `S`. -/
theorem traceDown_subNucleus (S : Set P) (U : LowerSet P) :
    traceDown S (subNucleus S U) = traceDown S U := by
  refine SetLike.ext fun s => ?_
  constructor
  · intro h
    exact h s s.2 le_rfl
  · intro h s' _hs' hle
    exact U.lower hle h

/-- The trace of the observer's bottom is bottom. -/
theorem traceDown_subNucleus_bot (S : Set P) :
    traceDown S (subNucleus S ⊥) = ⊥ := by
  refine SetLike.ext fun s => ?_
  constructor
  · intro h
    have h2 := h s s.2 le_rfl
    simp at h2
  · intro h
    simp at h

/-- Lower sets with equal traces are identified by the observer. -/
theorem subNucleus_eq_of_traceDown_eq {S : Set P} {U V : LowerSet P}
    (h : traceDown S U = traceDown S V) :
    subNucleus S U = subNucleus S V := by
  refine SetLike.ext fun x => ?_
  constructor <;> intro hx s hs hsx
  · have hm : (⟨s, hs⟩ : ↥S) ∈ traceDown S U := hx s hs hsx
    rw [h] at hm
    exact hm
  · have hm : (⟨s, hs⟩ : ↥S) ∈ traceDown S V := hx s hs hsx
    rw [← h] at hm
    exact hm

/-- Equality of `j_S`-fixed elements is detected on traces. -/
theorem eq_iff_traceDown_eq_of_fix {S : Set P} {X Y : LowerSet P}
    (hX : subNucleus S X = X) (hY : subNucleus S Y = Y) :
    X = Y ↔ traceDown S X = traceDown S Y :=
  ⟨fun h => h ▸ rfl,
   fun h => by rw [← hX, ← hY]; exact subNucleus_eq_of_traceDown_eq h⟩

/-- Implications into `j_S`-fixed elements are `j_S`-fixed (the fix-set
of a nucleus inherits the ambient Heyting implication). -/
theorem subNucleus_himp_fix {S : Set P} (A : LowerSet P) {B : LowerSet P}
    (hB : subNucleus S B = B) :
    subNucleus S (A ⇨ B) = A ⇨ B := by
  apply le_antisymm
  · refine LowerSet.le_iff'.mpr fun x hx => ?_
    rw [LowerSet.mem_himp_iff]
    intro y hyx hyA
    rw [← hB, mem_subNucleus]
    intro s hs hsy
    have hsAB : s ∈ (A ⇨ B : LowerSet P) := hx s hs (hsy.trans hyx)
    rw [LowerSet.mem_himp_iff] at hsAB
    exact hsAB s le_rfl (A.lower hsy hyA)
  · exact (subNucleus_isNucleus S).1 _

/-- The trace intertwines the ambient implication with the
sub-ecosystem's own implication, provided the consequent is
`j_S`-fixed. -/
theorem traceDown_himp {S : Set P} {A B : LowerSet P}
    (hB : subNucleus S B = B) :
    traceDown S (A ⇨ B) = traceDown S A ⇨ traceDown S B := by
  refine SetLike.ext fun s => ?_
  have hamb : (s : P) ∈ A ⇨ B ↔ ∀ y, y ≤ (s : P) → y ∈ A → y ∈ B :=
    LowerSet.mem_himp_iff
  have hsub : s ∈ traceDown S A ⇨ traceDown S B ↔
      ∀ t : ↥S, t ≤ s → (t : P) ∈ A → (t : P) ∈ B :=
    LowerSet.mem_himp_iff
  constructor
  · intro h
    refine hsub.mpr fun t hts htA => ?_
    exact hamb.mp h t (Subtype.coe_le_coe.mpr hts) htA
  · intro h
    refine hamb.mpr fun y hys hyA => ?_
    rw [← hB, mem_subNucleus]
    intro s' hs' hs'y
    have hts : (⟨s', hs'⟩ : ↥S) ≤ s := Subtype.coe_le_coe.mp (hs'y.trans hys)
    exact hsub.mp h ⟨s', hs'⟩ hts (A.lower hs'y hyA)

/-! ## C2 / E5: the trace characterization -/

/-- **C2 / E5 (the trace characterization).**  The observer `j_S` keeps
the distinction `k` open iff the trace `k ∩ S` is **ordinary** in the
sub-ecosystem's own down-set algebra `D(S)` — neither regular
(`Tᶜᶜ = T`) nor dense (`Tᶜ = ⊥`).  This is the Phase-2 empirical
identity as a theorem: aperture membership is trace-ordinariness. -/
theorem opens_subNucleus_iff (S : Set P) (k : LowerSet P) :
    Opens (subNucleus S) k ↔
      ((traceDown S k)ᶜᶜ ≠ traceDown S k ∧ (traceDown S k)ᶜ ≠ ⊥) := by
  have hBfix : subNucleus S (subNucleus S ⊥) = subNucleus S ⊥ :=
    (subNucleus_isNucleus S).2.1 ⊥
  have hAfix : subNucleus S (subNucleus S k) = subNucleus S k :=
    (subNucleus_isNucleus S).2.1 k
  have hwfix : subNucleus S (subNucleus S k ⇨ subNucleus S ⊥)
      = subNucleus S k ⇨ subNucleus S ⊥ :=
    subNucleus_himp_fix _ hBfix
  have hw2fix : subNucleus S ((subNucleus S k ⇨ subNucleus S ⊥) ⇨ subNucleus S ⊥)
      = (subNucleus S k ⇨ subNucleus S ⊥) ⇨ subNucleus S ⊥ :=
    subNucleus_himp_fix _ hBfix
  have htA : traceDown S (subNucleus S k) = traceDown S k :=
    traceDown_subNucleus S k
  have htB : traceDown S (subNucleus S ⊥) = ⊥ :=
    traceDown_subNucleus_bot S
  have htw : traceDown S (subNucleus S k ⇨ subNucleus S ⊥)
      = (traceDown S k)ᶜ := by
    rw [traceDown_himp hBfix, htA, htB, himp_bot]
  have htw2 : traceDown S ((subNucleus S k ⇨ subNucleus S ⊥) ⇨ subNucleus S ⊥)
      = (traceDown S k)ᶜᶜ := by
    rw [traceDown_himp hBfix, htw, htB, himp_bot]
  unfold Opens
  constructor
  · rintro ⟨h1, h2⟩
    refine ⟨fun he => h2 ?_, fun he => h1 ?_⟩
    · rw [eq_iff_traceDown_eq_of_fix hw2fix hAfix, htw2, htA]
      exact he
    · rw [eq_iff_traceDown_eq_of_fix hwfix hBfix, htw, htB]
      exact he
  · rintro ⟨h2, h1⟩
    refine ⟨fun he => h1 ?_, fun he => h2 ?_⟩
    · rw [← htw, ← htB]
      exact congrArg (traceDown S) he
    · rw [← htw2, ← htA]
      exact congrArg (traceDown S) he

/-! ## The characterization theorem -/

/-- The bijection between aperture witnesses and ordinary traces:
observers keeping `k` open correspond exactly to sub-ecosystems in
which `k`'s trace is ordinary. -/
def apertureWitnessEquiv [Finite P] (k : LowerSet P) :
    {S : Set P //
      (traceDown S k)ᶜᶜ ≠ traceDown S k ∧ (traceDown S k)ᶜ ≠ ⊥}
    ≃ {j : LowerSet P → LowerSet P // IsNucleus j ∧ Opens j k} where
  toFun S := ⟨subNucleus S.1, subNucleus_isNucleus S.1,
    (opens_subNucleus_iff S.1 k).mpr S.2⟩
  invFun j := ⟨nucleusSupport j.1, by
    have h := j.2.2
    rw [j.2.1.eq_subNucleus] at h
    exact (opens_subNucleus_iff _ k).mp h⟩
  left_inv S := Subtype.ext (nucleusSupport_subNucleus S.1)
  right_inv j := Subtype.ext j.2.1.eq_subNucleus.symm

/-- **The characterization theorem (Phase 2 headline).**  On the
down-set algebra of a finite poset,

    aperture(k) = #{ S ⊆ P : k ∩ S is ordinary in D(S) }

— the aperture of a dependency cone is the number of sub-ecosystems
from whose perspective the cone remains a generative distinction.  The
left side is the aperture of `CoApertureClosedForm`; the right side is
what the bridge-study scripts compute. -/
theorem aperture_eq_card_ordinary_traces [Finite P] (k : LowerSet P) :
    Nat.card {j : LowerSet P → LowerSet P // IsNucleus j ∧ Opens j k}
      = Nat.card {S : Set P //
          (traceDown S k)ᶜᶜ ≠ traceDown S k ∧ (traceDown S k)ᶜ ≠ ⊥} :=
  Nat.card_congr (apertureWitnessEquiv k).symm

end FalseWork.Lattice
