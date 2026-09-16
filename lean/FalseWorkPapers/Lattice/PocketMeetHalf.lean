/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# The meet half of the dynamical lattice conjecture, and the forced supply

Registered spec: `pocket-study/SPEC.md`, Amendments 2–4 (hand proofs
recorded 2026-09-15/16 before this file; oracle verification
`03-deflation-check.py` and `05-lemma-a-check.py`, zero exceptions).

Setting: a poset `P`, an incomparable pair `(a, b)`, and the time step
that adds the edge `a < b`.  `step` is the down-closure map
`cl′ : D(P) → D(P′)`; `obs S` is the sub-ecosystem observer `j_S` in
raw-set form (its restriction to lower sets is `subNucleus` of
`ObserverClassification.lean`); `Compatible` is dynamical
compatibility exactly as the oracle computes it.

Results, in dependency order:

* **D1 (`futureWatcher_compatible`).**  The future-watcher `{b}`
  commutes with every step on every poset — no hypotheses at all.
  This is the theorem that deflated the survey's 100%: the middle is
  never empty because this member is free.
* **D1b (`singleton_compatible`).**  Every singleton `{x}` with
  `¬ x ≤ a` commutes.  The forced supply is large; only observers
  watching *below* the change can fail.
* **Lemma A (`mem_obs_of_le_a`).**  Compatibility has teeth: if `S`
  is compatible, `b ∈ j_S U`, and `b ∉ U`, then the whole cone `↓a`
  already lies in `j_S U`.  This is the structural reason the
  interrogation's V2 was exceptionless.
* **The meet half (`compatible_union`).**  Compatible supports are
  closed under union — the pointwise meet of the two nuclei is
  compatible.  Half of the lattice conjecture (5,984/5,984 in the
  survey) is now a theorem; the join half (intersection of supports)
  remains open.
* **Trajectory Phase 0 (`survival_composes`, `freeSupply_antitone`).**
  Surviving a trajectory is surviving each step (pasting squares,
  two lines), and the free supply provably thins as the order grows.
  Both registered as pre-derivations for the trajectory study, per
  the derive-before-surveying rule.
-/
import Mathlib.Order.UpperLower.Basic

namespace FalseWork.Lattice.Pocket

variable {α : Type*} [PartialOrder α]

/-! ## The step and the observers, raw-set form -/

/-- Reachability after adding the edge `a < b`:
`x ≤′ y` iff `x ≤ y` or (`x ≤ a` and `b ≤ y`). -/
def le' (a b x y : α) : Prop := x ≤ y ∨ (x ≤ a ∧ b ≤ y)

/-- The time step `cl′`: the down-closure, in the extended order, of a
down-set of the old order.  Concretely it adds `↓a` exactly when the
set reaches `b`. -/
def step (a b : α) (U : Set α) : Set α := U ∪ {x | x ≤ a ∧ b ∈ U}

/-- The sub-ecosystem observer `j_S` in the old order (raw-set form of
`subNucleus`). -/
def obs (S U : Set α) : Set α := {x | ∀ s ∈ S, s ≤ x → s ∈ U}

/-- The sub-ecosystem observer `j_S` in the extended order. -/
def obs' (a b : α) (S U : Set α) : Set α :=
  {x | ∀ s ∈ S, le' a b s x → s ∈ U}

/-- **Dynamical compatibility**, exactly as the oracle computes it:
compress-then-evolve equals evolve-then-compress on every down-set. -/
def Compatible (a b : α) (S : Set α) : Prop :=
  ∀ U : Set α, IsLowerSet U → step a b (obs S U) = obs' a b S (step a b U)

@[simp] theorem mem_step {a b x : α} {U : Set α} :
    x ∈ step a b U ↔ x ∈ U ∨ (x ≤ a ∧ b ∈ U) := Iff.rfl

@[simp] theorem mem_obs {S U : Set α} {x : α} :
    x ∈ obs S U ↔ ∀ s ∈ S, s ≤ x → s ∈ U := Iff.rfl

@[simp] theorem mem_obs' {a b : α} {S U : Set α} {x : α} :
    x ∈ obs' a b S U ↔ ∀ s ∈ S, le' a b s x → s ∈ U := Iff.rfl

/-! ## Order facts about the extended relation -/

/-- Nothing new arrives above `b`: `b ≤′ x` iff `b ≤ x`. -/
theorem le'_from_b {a b x : α} : le' a b b x ↔ b ≤ x := by
  constructor
  · rintro (h | ⟨_, h⟩) <;> exact h
  · exact Or.inl

/-- Below `a` the extended cone is the old cone (needs `¬ b ≤ a`):
for `x ≤ a`, `s ≤′ x` iff `s ≤ x`. -/
theorem le'_to_below_a {a b x s : α} (hba : ¬ b ≤ a) (hx : x ≤ a) :
    le' a b s x ↔ s ≤ x := by
  constructor
  · rintro (h | ⟨_, hbx⟩)
    · exact h
    · exact absurd (hbx.trans hx) hba
  · exact Or.inl

/-- A set not reaching `b` is untouched by the step. -/
theorem step_of_not_mem {a b : α} {U : Set α} (h : b ∉ U) :
    step a b U = U := by
  ext x
  simp only [mem_step]
  exact or_iff_left fun hx => h hx.2

/-- Observers are inflationary on lower sets. -/
theorem mem_obs_of_mem {S U : Set α} (hU : IsLowerSet U) {x : α}
    (hx : x ∈ U) : x ∈ obs S U :=
  fun _s _hs hsx => hU hsx hx

/-- The step preserves lower-set-ness into the extended order (needs
`¬ b ≤ a`): `cl′` really lands in `D(P′)`. -/
theorem step_isLower' {a b : α} (hba : ¬ b ≤ a) {U : Set α}
    (hU : IsLowerSet U) {x y : α} (hyx : le' a b y x)
    (hx : x ∈ step a b U) : y ∈ step a b U := by
  rcases hx with hxU | ⟨hxa, hbU⟩
  · rcases hyx with hyx | ⟨hya, hbx⟩
    · exact Or.inl (hU hyx hxU)
    · exact Or.inr ⟨hya, hU hbx hxU⟩
  · rcases hyx with hyx | ⟨hya, hbx⟩
    · exact Or.inr ⟨hyx.trans hxa, hbU⟩
    · exact absurd (hbx.trans hxa) hba

/-! ## D1 and D1b: the forced supply -/

/-- **D1: the future-watcher is free.**  The observer watching only
`b` commutes with the step `(a, b)` on every poset — no hypotheses,
not even incomparability.  This is the theorem behind the deflation of
the survey's 100%: nontrivial compatible observers exist for *any*
step because this one costs nothing. -/
theorem futureWatcher_compatible (a b : α) : Compatible a b {b} := by
  intro U _hU
  by_cases hbU : b ∈ U
  · ext x
    simp only [mem_step, mem_obs, mem_obs', Set.mem_singleton_iff]
    constructor
    · intro _ s hs _
      subst hs
      exact Or.inl hbU
    · intro _
      refine Or.inl fun s hs _ => ?_
      subst hs
      exact hbU
  · have h1 : b ∉ obs {b} U := fun h => hbU (h b rfl le_rfl)
    rw [step_of_not_mem h1, step_of_not_mem hbU]
    ext x
    simp only [mem_obs, mem_obs', Set.mem_singleton_iff]
    constructor
    · intro h s hs hle
      subst hs
      exact h s rfl (le'_from_b.mp hle)
    · intro h s hs hle
      subst hs
      exact h s rfl (le'_from_b.mpr hle)

/-- **D1b: singletons above the change are free.**  Any observer
watching a single point `x₀` with `¬ x₀ ≤ a` commutes with the step.
Compatibility can only be threatened by watching *below* the arrival
site of the new edge. -/
theorem singleton_compatible {a b x₀ : α} (hx : ¬ x₀ ≤ a) :
    Compatible a b {x₀} := by
  intro U _hU
  by_cases h0 : x₀ ∈ U
  · ext x
    simp only [mem_step, mem_obs, mem_obs', Set.mem_singleton_iff]
    constructor
    · intro _ s hs _
      subst hs
      exact Or.inl h0
    · intro _
      refine Or.inl fun s hs _ => ?_
      subst hs
      exact h0
  · have h1 : x₀ ∉ step a b U := by
      rintro (h | ⟨ha, _⟩)
      · exact h0 h
      · exact hx ha
    ext x
    simp only [mem_step, mem_obs, mem_obs', Set.mem_singleton_iff]
    constructor
    · rintro (h | ⟨hxa, hb⟩)
      · intro s hs hle
        subst hs
        rcases hle with hle | ⟨hsa, _⟩
        · exact absurd (h s rfl hle) h0
        · exact absurd hsa hx
      · intro s hs hle
        subst hs
        rcases hle with hle | ⟨hsa, _⟩
        · exact absurd (hle.trans hxa) hx
        · exact absurd hsa hx
    · intro h
      refine Or.inl fun s hs hsx => ?_
      subst hs
      exact absurd (h s rfl (Or.inl hsx)) h1

/-! ## Lemma A: compatibility forces the cone -/

/-- **Lemma A.**  If `S` is compatible, `U` is a down-set with
`b ∈ j_S U` but `b ∉ U`, then all of `↓a` lies in `j_S U`.  Proof:
compatibility at `U` (where `cl′U = U`) reads
`j_S U ∪ ↓a = j′_S U`; below `a` the extended cone is the old cone,
so membership in `j′_S U` there reduces to membership in `j_S U`. -/
theorem mem_obs_of_le_a {a b : α} (hba : ¬ b ≤ a) {S : Set α}
    (hS : Compatible a b S) {U : Set α} (hU : IsLowerSet U)
    (hbj : b ∈ obs S U) (hbU : b ∉ U) {x : α} (hx : x ≤ a) :
    x ∈ obs S U := by
  have hcomp := hS U hU
  rw [step_of_not_mem hbU] at hcomp
  have hxstep : x ∈ step a b (obs S U) := Or.inr ⟨hx, hbj⟩
  rw [hcomp] at hxstep
  intro s hs hsx
  exact hxstep s hs ((le'_to_below_a hba hx).mpr hsx)

/-! ## Pointwise meets -/

/-- The union of supports is the pointwise meet of observers (old
order). -/
theorem obs_union (S T U : Set α) :
    obs (S ∪ T) U = obs S U ∩ obs T U := by
  ext x
  simp only [mem_obs, Set.mem_union, Set.mem_inter_iff]
  constructor
  · intro h
    exact ⟨fun s hs => h s (Or.inl hs), fun s hs => h s (Or.inr hs)⟩
  · rintro ⟨h1, h2⟩ s (hs | hs)
    · exact h1 s hs
    · exact h2 s hs

/-- The union of supports is the pointwise meet of observers (extended
order). -/
theorem obs'_union (a b : α) (S T U : Set α) :
    obs' a b (S ∪ T) U = obs' a b S U ∩ obs' a b T U := by
  ext x
  simp only [mem_obs', Set.mem_union, Set.mem_inter_iff]
  constructor
  · intro h
    exact ⟨fun s hs => h s (Or.inl hs), fun s hs => h s (Or.inr hs)⟩
  · rintro ⟨h1, h2⟩ s (hs | hs)
    · exact h1 s hs
    · exact h2 s hs

/-! ## The meet half of the lattice conjecture -/

/-- **The meet half.**  If `S` and `T` are both compatible with the
step `(a, b)`, so is `S ∪ T` — the pointwise meet of the two nuclei
commutes with time.  The mixed case (`b` visible to one observer's
image but not the other's) is closed by Lemma A: compatibility forces
`↓a` inside the image that reaches `b`, so the step's added cone never
separates the two images.  Oracle: 792,595 compatible pairs, zero
exceptions; this theorem covers every poset and every step at once.
The join half (intersection of supports) remains open. -/
theorem compatible_union {a b : α} (hba : ¬ b ≤ a) {S T : Set α}
    (hS : Compatible a b S) (hT : Compatible a b T) :
    Compatible a b (S ∪ T) := by
  intro U hU
  rw [obs_union, obs'_union, ← hS U hU, ← hT U hU]
  ext x
  simp only [mem_step, Set.mem_inter_iff]
  constructor
  · rintro (⟨hxA, hxB⟩ | ⟨hxa, hbA, hbB⟩)
    · exact ⟨Or.inl hxA, Or.inl hxB⟩
    · exact ⟨Or.inr ⟨hxa, hbA⟩, Or.inr ⟨hxa, hbB⟩⟩
  · rintro ⟨hA | ⟨hxa, hbA⟩, hB | ⟨hxa', hbB⟩⟩
    · exact Or.inl ⟨hA, hB⟩
    · -- x ∈ j_S U, x ≤ a, b ∈ j_T U: is b ∈ j_S U?
      by_cases hbA : b ∈ obs S U
      · exact Or.inr ⟨hxa', hbA, hbB⟩
      · -- mixed case: b ∉ U (else inflation), Lemma A on T
        have hbU : b ∉ U := fun h => hbA (mem_obs_of_mem hU h)
        exact Or.inl ⟨hA, mem_obs_of_le_a hba hT hU hbB hbU hxa'⟩
    · by_cases hbB : b ∈ obs T U
      · exact Or.inr ⟨hxa, hbA, hbB⟩
      · have hbU : b ∉ U := fun h => hbB (mem_obs_of_mem hU h)
        exact Or.inl ⟨mem_obs_of_le_a hba hS hU hbA hbU hxa, hB⟩
    · exact Or.inr ⟨hxa, hbA, hbB⟩

/-- **The step is not meet-preserving** — so the meet half is not
forced.  With `a, b` incomparable, `U = ↓a`, `V = ↓b`: the element
`a` lies in `step U ∩ step V` (the step adds `↓a` to `V` because `V`
reaches `b`) but not in `step (U ∩ V)` (which never reaches `b`).
Hence `compatible_union` is not an instance of the general fact
"compatibles are meet-closed under a meet-preserving step": that
sufficient condition is provably unavailable here, and the proof
above must (and does) run through Lemma A instead.  This is the
kernel form of the universal witness recorded in
`pocket-study/SPEC.md` Amendment 3 (V1). -/
theorem step_not_meet_preserving {a b : α} (hab : ¬ a ≤ b)
    (hba : ¬ b ≤ a) :
    a ∈ step a b {x | x ≤ a} ∩ step a b {x | x ≤ b} ∧
    a ∉ step a b ({x | x ≤ a} ∩ {x | x ≤ b}) := by
  constructor
  · exact ⟨Or.inl le_rfl, Or.inr ⟨le_rfl, le_rfl⟩⟩
  · rintro (⟨-, hb⟩ | ⟨-, hb, -⟩)
    · exact hab hb
    · exact hba hb

/-! ## Trajectory Phase 0: survival composes, the free supply thins -/

/-- **Survival composes** (pasting squares).  If an observer commutes
with step 1 and its image-observer commutes with step 2, the
composite trajectory commutes: surviving a whole history is exactly
surviving each tick.  Stated for any staged system: `LX`/`LY` are the
"is a down-set of this stage" predicates, `cl₁`/`cl₂` the steps.
Registered as a pre-derivation for the trajectory study: the
interesting object there is the per-step compatible set's
intersection, not any new composition phenomenon. -/
theorem survival_composes {X Y Z : Type*}
    {LX : Set X → Prop} {LY : Set Y → Prop}
    {cl₁ : Set X → Set Y} {cl₂ : Set Y → Set Z}
    {j₁ : Set X → Set X} {j₂ : Set Y → Set Y} {j₃ : Set Z → Set Z}
    (hcl₁ : ∀ U, LX U → LY (cl₁ U))
    (h₁ : ∀ U, LX U → cl₁ (j₁ U) = j₂ (cl₁ U))
    (h₂ : ∀ V, LY V → cl₂ (j₂ V) = j₃ (cl₂ V)) :
    ∀ U, LX U → cl₂ (cl₁ (j₁ U)) = j₃ (cl₂ (cl₁ U)) := by
  intro U hU
  rw [h₁ U hU, h₂ (cl₁ U) (hcl₁ U hU)]

omit [PartialOrder α] in
/-- **The free supply thins** as the order grows: the forced-singleton
family `{x : ¬ x ≤ a}` of D1b is antitone in the order.  Every added
edge can only move positions *under* `a`, never out.  This is the
half of the scarcity hunch that is forced by construction — the
trajectory study's registered claim must therefore be about the
excess beyond this family. -/
theorem freeSupply_antitone (P P' : Preorder α)
    (ext : ∀ x y : α, P.le x y → P'.le x y) (a : α) :
    {x : α | ¬ P'.le x a} ⊆ {x : α | ¬ P.le x a} :=
  fun _x hx hle => hx (ext _ _ hle)

end FalseWork.Lattice.Pocket
