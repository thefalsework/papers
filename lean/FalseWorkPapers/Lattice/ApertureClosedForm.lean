/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# Steps 2–3 of the aperture closed form

Kernel-checks the remaining two steps of Theorem 5.1 of the aperture
note (`preprints/aperture/paper.md` §5).  Step 1 — nuclei on products
factor componentwise — is `nucleus_prod_iff` in
`Lattice/NucleusFactorization.lean`.  This file adds:

* **Step 2 (coordinate-locality).**  `WorldDense`/`WorldRegular` — the
  two halves of the aperture membership predicate `Opens` — are
  componentwise on product algebras (`worldDense_prodMap_iff`,
  `worldRegular_prodMap_iff`), and the factorization theorem upgrades
  to an equivalence of nucleus types (`nucleusProdEquiv`).

* **Step 3 (chain counts).**  On a finite bounded chain the nuclei are
  exactly the operators induced by subsets containing `⊤`
  (`nucleusEquivTopSets`), and the counts of all / world-dense /
  world-regular / both are `2^n`, `(2^b − 1)·2^u + 1`, `2^u + 2^b − 1`,
  `2^b`, where `n` counts non-top elements, `b` those strictly below
  the kernel, `u` the non-top ones above (`card_nuclei`,
  `card_worldDense_add`, `card_worldRegular_add`,
  `card_worldDenseRegular`).

* **The assembled closed form.**  For any two finite Heyting algebras
  (inclusion–exclusion, `aperture_card_add_eq`), hence for products of
  two finite bounded chains, hence — instantiated at
  `Fin (a+1) × Fin (b+1)`, the exponent lattice of `Div(p^a·q^b)` —
  the paper's formula |Ap(k)| = N − ∏D − ∏R + ∏DR
  (`aperture_closed_form_two_chains`, `aperture_closed_form_exponents`).

The two-prime case of Theorem 5.1 is thereby [K]; the r-prime
generalization (iterating the same factorization) remains open here.
-/
import FalseWorkPapers.Lattice.NucleusFactorization
import Mathlib.Data.Finset.Powerset
import Mathlib.Data.Fintype.Prod
import Mathlib.Order.Interval.Finset.Fin
import Mathlib.Tactic

/- The chain lemmas live in sections that also serve the counting
theorems, which do need `Fintype`; the unused-section-variable lint
would otherwise cascade through every lemma that happens not to
count. -/
set_option linter.unusedSectionVars false

namespace FalseWork.Lattice

/-! ## Step 2a: density and regularity inside the world of a nucleus -/

section World

variable {W : Type*} [HeytingAlgebra W]

/-- `j k` is **dense in the world of `j`**: its world-negation
`j k ⇨ j ⊥` is the world's bottom.  First conjunct of `Opens`, negated. -/
def WorldDense (j : W → W) (k : W) : Prop := (j k ⇨ j ⊥) = j ⊥

/-- `j k` is **regular in the world of `j`**: world double-negation
returns it.  Second conjunct of `Opens`, negated. -/
def WorldRegular (j : W → W) (k : W) : Prop := ((j k ⇨ j ⊥) ⇨ j ⊥) = j k

/-- `Opens` is exactly "neither world-dense nor world-regular"
(definitional; paper Definition 3.1). -/
theorem opens_iff_world (j : W → W) (k : W) :
    Opens j k ↔ ¬WorldDense j k ∧ ¬WorldRegular j k := Iff.rfl

instance [DecidableEq W] (j : W → W) (k : W) : Decidable (WorldDense j k) :=
  inferInstanceAs (Decidable (_ = _))

instance [DecidableEq W] (j : W → W) (k : W) : Decidable (WorldRegular j k) :=
  inferInstanceAs (Decidable (_ = _))

end World

/-! ## Step 2b: coordinate-locality on products

Implication and bottom on a product Heyting algebra are componentwise,
so world-density and world-regularity of a componentwise nucleus are
conjunctions of the coordinate conditions.  This is Step 2 of the
paper's derivation, verbatim. -/

section WorldProd

variable {W₁ W₂ : Type*} [HeytingAlgebra W₁] [HeytingAlgebra W₂]

theorem worldDense_prodMap_iff (jA : W₁ → W₁) (jB : W₂ → W₂) (k : W₁ × W₂) :
    WorldDense (fun p : W₁ × W₂ => (jA p.1, jB p.2)) k ↔
      WorldDense jA k.1 ∧ WorldDense jB k.2 := by
  constructor
  · exact fun h => ⟨congrArg Prod.fst h, congrArg Prod.snd h⟩
  · exact fun h => Prod.ext h.1 h.2

theorem worldRegular_prodMap_iff (jA : W₁ → W₁) (jB : W₂ → W₂) (k : W₁ × W₂) :
    WorldRegular (fun p : W₁ × W₂ => (jA p.1, jB p.2)) k ↔
      WorldRegular jA k.1 ∧ WorldRegular jB k.2 := by
  constructor
  · exact fun h => ⟨congrArg Prod.fst h, congrArg Prod.snd h⟩
  · exact fun h => Prod.ext h.1 h.2

end WorldProd

/-! ## Step 1, upgraded to an equivalence of types -/

section ProdEquiv

variable {A B : Type*} [SemilatticeInf A] [SemilatticeInf B]
  [OrderTop A] [OrderTop B]

/-- The factorization theorem (`nucleus_prod_iff`) as an equivalence:
nuclei on `A × B` correspond exactly to pairs of nuclei on the
factors.  This is what makes nucleus counts multiply. -/
def nucleusProdEquiv :
    {j : A × B → A × B // IsNucleus j} ≃
      {jA : A → A // IsNucleus jA} × {jB : B → B // IsNucleus jB} where
  toFun j := (⟨nucleusFst j.1, j.2.fst⟩, ⟨nucleusSnd j.1, j.2.snd⟩)
  invFun p := ⟨fun x => (p.1.1 x.1, p.2.1 x.2), p.1.2.prodMap p.2.2⟩
  left_inv j := Subtype.ext (funext fun p => (j.2.eq_prodMap p).symm)
  right_inv _ := rfl

end ProdEquiv

/-! ## Step 3a: nuclei on a finite bounded chain are the top-sets

On a chain, every subset `F ∋ ⊤` induces a nucleus (send `e` to the
least member of `F` above it), every nucleus arises this way from its
fix-set, and the correspondence is a bijection. -/

section ChainNuclei

variable {α : Type*} [LinearOrder α] [Fintype α] [BoundedOrder α]

local instance : BiheytingAlgebra α := LinearOrder.toBiheytingAlgebra α

omit [Fintype α] in
/-- On a bounded linear order, `a ⇨ b = ⊤` when `a ≤ b`. -/
theorem himp_of_le {a b : α} (h : a ≤ b) : a ⇨ b = ⊤ :=
  eq_top_iff.mpr (le_himp_iff.mpr (by rwa [top_inf_eq]))

omit [Fintype α] in
/-- On a bounded linear order, `a ⇨ b = b` when `b < a`. -/
theorem himp_of_lt {a b : α} (h : b < a) : a ⇨ b = b := by
  refine le_antisymm ?_ le_himp
  rcases le_total (a ⇨ b) a with hle | hge
  · have h2 := himp_inf_le (a := a) (b := b)
    rwa [inf_eq_left.mpr hle] at h2
  · have h2 := himp_inf_le (a := a) (b := b)
    rw [inf_eq_right.mpr hge] at h2
    exact absurd h2 (not_le.mpr h)

variable {F : Finset α}

omit [Fintype α] in
private theorem filter_le_nonempty (F : Finset α) (htop : ⊤ ∈ F) (e : α) :
    (F.filter fun x => e ≤ x).Nonempty :=
  ⟨⊤, Finset.mem_filter.mpr ⟨htop, le_top⟩⟩

/-- The operator induced on a chain by a subset `F ∋ ⊤`: send `e` to
the least member of `F` above `e`. -/
def chainNucleus (F : Finset α) (htop : ⊤ ∈ F) : α → α := fun e =>
  (F.filter fun x => e ≤ x).min' (filter_le_nonempty F htop e)

variable (htop : ⊤ ∈ F)

omit [Fintype α] in
theorem le_chainNucleus (e : α) : e ≤ chainNucleus F htop e :=
  (Finset.mem_filter.mp ((F.filter fun x => e ≤ x).min'_mem _)).2

omit [Fintype α] in
theorem chainNucleus_mem (e : α) : chainNucleus F htop e ∈ F :=
  (Finset.mem_filter.mp ((F.filter fun x => e ≤ x).min'_mem _)).1

omit [Fintype α] in
theorem chainNucleus_le {e f : α} (hf : f ∈ F) (hef : e ≤ f) :
    chainNucleus F htop e ≤ f :=
  Finset.min'_le _ f (Finset.mem_filter.mpr ⟨hf, hef⟩)

theorem chainNucleus_fixed {f : α} (hf : f ∈ F) : chainNucleus F htop f = f :=
  le_antisymm (chainNucleus_le htop hf le_rfl) (le_chainNucleus htop f)

theorem chainNucleus_mono : Monotone (chainNucleus F htop) := fun _ e' h =>
  chainNucleus_le htop (chainNucleus_mem htop e')
    (h.trans (le_chainNucleus htop e'))

/-- Every top-set induces a nucleus on the chain.  (Meet-preservation
follows from monotonicity because meet is `min` on a chain.) -/
theorem chainNucleus_isNucleus : IsNucleus (chainNucleus F htop) := by
  refine ⟨le_chainNucleus htop,
    fun a => chainNucleus_fixed htop (chainNucleus_mem htop a),
    fun a b => ?_⟩
  rcases le_total a b with h | h
  · rw [inf_eq_left.mpr h, inf_eq_left.mpr (chainNucleus_mono htop h)]
  · rw [inf_eq_right.mpr h, inf_eq_right.mpr (chainNucleus_mono htop h)]

/-- The fix-set of `chainNucleus F` is exactly `F`. -/
theorem chainNucleus_fix_iff {e : α} : chainNucleus F htop e = e ↔ e ∈ F :=
  ⟨fun h => h ▸ chainNucleus_mem htop e, fun h => chainNucleus_fixed htop h⟩

/-- The fix-set of an operator, as a finset. -/
def nucleusFixSet (j : α → α) : Finset α :=
  Finset.univ.filter fun x => j x = x

theorem top_mem_nucleusFixSet {j : α → α} (hj : IsNucleus j) :
    ⊤ ∈ nucleusFixSet j :=
  Finset.mem_filter.mpr ⟨Finset.mem_univ _, hj.map_top⟩

/-- **Every nucleus on a chain is induced by its fix-set.**  `j e` is
the least fixed point above `e` (`IsNucleus.le_of_fix`), which is what
`chainNucleus` computes. -/
theorem chainNucleus_nucleusFixSet {j : α → α} (hj : IsNucleus j) :
    chainNucleus (nucleusFixSet j) (top_mem_nucleusFixSet hj) = j := by
  funext e
  refine le_antisymm ?_ ?_
  · exact chainNucleus_le _
      (Finset.mem_filter.mpr ⟨Finset.mem_univ _, hj.2.1 e⟩) (hj.1 e)
  · exact hj.le_of_fix
      (Finset.mem_filter.mp (chainNucleus_mem (top_mem_nucleusFixSet hj) e)).2
      (le_chainNucleus (top_mem_nucleusFixSet hj) e)

theorem nucleusFixSet_chainNucleus (htop : ⊤ ∈ F) :
    nucleusFixSet (chainNucleus F htop) = F := by
  ext x
  simp [nucleusFixSet, chainNucleus_fix_iff htop]

/-- **The classification (Step 3, structural half):** nuclei on a
finite bounded chain are exactly the subsets containing `⊤`. -/
def nucleusEquivTopSets :
    {j : α → α // IsNucleus j} ≃ {F : Finset α // ⊤ ∈ F} where
  toFun j := ⟨nucleusFixSet j.1, top_mem_nucleusFixSet j.2⟩
  invFun F := ⟨chainNucleus F.1 F.2, chainNucleus_isNucleus F.2⟩
  left_inv j := Subtype.ext (chainNucleus_nucleusFixSet j.2)
  right_inv F := Subtype.ext (nucleusFixSet_chainNucleus F.2)

end ChainNuclei

/-! ## Step 3b: where a chain observer sees density and regularity

For the nucleus induced by `F ∋ ⊤` at kernel exponent `e`:
dense in its world iff some member of `F` lies strictly below `e` or
the world is trivial; regular iff no member lies strictly below `e` or
the image is `⊤`; both iff the image is `⊤`. -/

section ChainCharacterization

variable {α : Type*} [LinearOrder α] [Fintype α] [BoundedOrder α]

local instance : BiheytingAlgebra α := LinearOrder.toBiheytingAlgebra α

variable {F : Finset α} (htop : ⊤ ∈ F)

theorem chainNucleus_bot_lt_iff {e : α} :
    chainNucleus F htop ⊥ < chainNucleus F htop e ↔ ∃ x ∈ F, x < e := by
  constructor
  · intro h
    refine ⟨chainNucleus F htop ⊥, chainNucleus_mem htop ⊥, ?_⟩
    by_contra hne
    rw [not_lt] at hne
    exact absurd (chainNucleus_le htop (chainNucleus_mem htop ⊥) hne)
      (not_le.mpr h)
  · rintro ⟨x, hxF, hxe⟩
    exact lt_of_le_of_lt (chainNucleus_le htop hxF bot_le)
      (hxe.trans_le (le_chainNucleus htop e))

theorem chainNucleus_eq_bot_iff {e : α} :
    chainNucleus F htop e = chainNucleus F htop ⊥ ↔ ¬∃ x ∈ F, x < e := by
  rw [← chainNucleus_bot_lt_iff htop]
  constructor
  · intro h
    rw [h]
    exact lt_irrefl _
  · intro h
    exact le_antisymm (not_lt.mp h) (chainNucleus_mono htop bot_le)

theorem chainNucleus_eq_top_iff {e : α} :
    chainNucleus F htop e = ⊤ ↔ ¬∃ x ∈ F, e ≤ x ∧ x ≠ ⊤ := by
  constructor
  · rintro h ⟨x, hxF, hex, hxt⟩
    have hle := chainNucleus_le htop hxF hex
    rw [h] at hle
    exact hxt (top_le_iff.mp hle)
  · intro h
    by_contra hne
    exact h ⟨_, chainNucleus_mem htop e, le_chainNucleus htop e, hne⟩

theorem chainNucleus_bot_eq_top_iff :
    chainNucleus F htop ⊥ = ⊤ ↔ ∀ x ∈ F, x = ⊤ := by
  constructor
  · intro h x hxF
    have hle := chainNucleus_le htop hxF bot_le
    rw [h] at hle
    exact top_le_iff.mp hle
  · intro h
    exact h _ (chainNucleus_mem htop ⊥)

/-- **Density characterization on a chain**: the observer `F` sees the
kernel `e` as dense iff `F` has a member strictly below `e` (the world
bottom sits below the image) or the world is trivial. -/
theorem worldDense_chainNucleus_iff {e : α} :
    WorldDense (chainNucleus F htop) e ↔
      (∃ x ∈ F, x < e) ∨ ∀ x ∈ F, x = ⊤ := by
  by_cases hex : ∃ x ∈ F, x < e
  · have hlt := (chainNucleus_bot_lt_iff htop).mpr hex
    unfold WorldDense
    rw [himp_of_lt hlt]
    simp [hex]
  · have heq := (chainNucleus_eq_bot_iff htop).mpr hex
    unfold WorldDense
    rw [heq, himp_self, ← chainNucleus_bot_eq_top_iff htop]
    simp [hex, eq_comm]

/-- **Regularity characterization on a chain**: the observer `F` sees
the kernel `e` as regular iff its image is the world bottom or `⊤`. -/
theorem worldRegular_chainNucleus_iff {e : α} :
    WorldRegular (chainNucleus F htop) e ↔
      (¬∃ x ∈ F, x < e) ∨ chainNucleus F htop e = ⊤ := by
  by_cases hex : ∃ x ∈ F, x < e
  · have hlt := (chainNucleus_bot_lt_iff htop).mpr hex
    unfold WorldRegular
    rw [himp_of_lt hlt, himp_self]
    simp [hex, eq_comm]
  · have heq := (chainNucleus_eq_bot_iff htop).mpr hex
    unfold WorldRegular
    rw [heq, himp_self, top_himp]
    simp [hex]

/-- **Dense-and-regular characterization on a chain**: both hold iff
the image is `⊤` — no member of `F` other than `⊤` lies at or above
the kernel. -/
theorem worldDenseRegular_chainNucleus_iff {e : α} :
    (WorldDense (chainNucleus F htop) e ∧ WorldRegular (chainNucleus F htop) e)
      ↔ ¬∃ x ∈ F, e ≤ x ∧ x ≠ ⊤ := by
  have hbot_top : (∀ x ∈ F, x = ⊤) → chainNucleus F htop e = ⊤ := fun h =>
    h _ (chainNucleus_mem htop e)
  have htop_cases : chainNucleus F htop e = ⊤ →
      (∃ x ∈ F, x < e) ∨ ∀ x ∈ F, x = ⊤ := by
    intro hT
    by_cases hex2 : ∃ x ∈ F, x ≠ ⊤
    · obtain ⟨x, hxF, hx⟩ := hex2
      rcases lt_or_ge x e with h | h
      · exact Or.inl ⟨x, hxF, h⟩
      · exact absurd ⟨x, hxF, h, hx⟩ ((chainNucleus_eq_top_iff htop).mp hT)
    · simp only [not_exists, not_and, not_not] at hex2
      exact Or.inr hex2
  rw [worldDense_chainNucleus_iff htop, worldRegular_chainNucleus_iff htop,
    ← chainNucleus_eq_top_iff htop]
  constructor
  · rintro ⟨hd, hr⟩
    rcases hr with hne | hT
    · rcases hd with hex | hall
      · exact absurd hex hne
      · exact hbot_top hall
    · exact hT
  · intro hT
    exact ⟨htop_cases hT, Or.inr hT⟩

end ChainCharacterization

/-! ## Step 3c: the four chain counts

With `S` the non-top elements, `B` those strictly below the kernel
exponent `e`, `U` the non-top ones at or above it (`S = B ⊎ U`), the
top-set correspondence turns each count into a powerset count:
all = `2^|S|`, dense = `(2^|B| − 1)·2^|U| + 1`, regular =
`2^|U| + 2^|B| − 1`, both = `2^|B|`.  Stated additively to stay in ℕ. -/

section ChainCounts

variable {α : Type*} [LinearOrder α] [Fintype α] [BoundedOrder α]

local instance : BiheytingAlgebra α := LinearOrder.toBiheytingAlgebra α

/-- Transfer a predicate-constrained nucleus count to a count of
top-sets, along the classification. -/
def nucleusCountEquiv (P : (α → α) → Prop) (Q : Finset α → Prop)
    (hPQ : ∀ (F : Finset α) (htop : ⊤ ∈ F), P (chainNucleus F htop) ↔ Q F) :
    {j : α → α // IsNucleus j ∧ P j} ≃ {F : Finset α // ⊤ ∈ F ∧ Q F} where
  toFun j := ⟨nucleusFixSet j.1, top_mem_nucleusFixSet j.2.1, by
    have h := hPQ (nucleusFixSet j.1) (top_mem_nucleusFixSet j.2.1)
    rw [chainNucleus_nucleusFixSet j.2.1] at h
    exact h.mp j.2.2⟩
  invFun F := ⟨chainNucleus F.1 F.2.1, chainNucleus_isNucleus F.2.1,
    (hPQ F.1 F.2.1).mpr F.2.2⟩
  left_inv j := Subtype.ext (chainNucleus_nucleusFixSet j.2.1)
  right_inv F := Subtype.ext (nucleusFixSet_chainNucleus F.2.1)

/-- Top-sets with a property, counted as subsets of the non-top part. -/
theorem card_topSets_filter (Q : Finset α → Prop) [DecidablePred Q] :
    Fintype.card {F : Finset α // ⊤ ∈ F ∧ Q F}
      = (((Finset.univ.erase (⊤ : α)).powerset).filter
          fun G => Q (insert ⊤ G)).card := by
  rw [← Fintype.card_coe]
  refine Fintype.card_congr ⟨fun F => ⟨F.1.erase ⊤, ?_⟩,
    fun G => ⟨insert ⊤ G.1, Finset.mem_insert_self _ _, ?_⟩, ?_, ?_⟩
  · have hsub : F.1.erase ⊤ ⊆ Finset.univ.erase ⊤ :=
      Finset.erase_subset_erase _ (Finset.subset_univ _)
    have hins : insert ⊤ (F.1.erase ⊤) = F.1 := Finset.insert_erase F.2.1
    simp only [Finset.mem_filter, Finset.mem_powerset]
    exact ⟨hsub, by rw [hins]; exact F.2.2⟩
  · have hG := G.2
    simp only [Finset.mem_filter, Finset.mem_powerset] at hG
    exact hG.2
  · intro F
    exact Subtype.ext (Finset.insert_erase F.2.1)
  · intro G
    have hG := G.2
    simp only [Finset.mem_filter, Finset.mem_powerset] at hG
    have hnot : ⊤ ∉ G.1 := fun h => (Finset.mem_erase.mp (hG.1 h)).1 rfl
    exact Subtype.ext (Finset.erase_insert hnot)

/-- Plain top-set count: `2^|S|`. -/
theorem card_topSets :
    Fintype.card {F : Finset α // (⊤ : α) ∈ F}
      = 2 ^ (Finset.univ.erase (⊤ : α)).card := by
  rw [← Finset.card_powerset, ← Fintype.card_coe]
  refine Fintype.card_congr ⟨fun F => ⟨F.1.erase ⊤, ?_⟩,
    fun G => ⟨insert ⊤ G.1, Finset.mem_insert_self _ _⟩, ?_, ?_⟩
  · exact Finset.mem_powerset.mpr
      (Finset.erase_subset_erase _ (Finset.subset_univ _))
  · intro F
    exact Subtype.ext (Finset.insert_erase F.2)
  · intro G
    have hG : G.1 ⊆ Finset.univ.erase ⊤ := Finset.mem_powerset.mp G.2
    have hnot : ⊤ ∉ G.1 := fun h => (Finset.mem_erase.mp (hG h)).1 rfl
    exact Subtype.ext (Finset.erase_insert hnot)

/-- **Count N: nuclei on a chain number `2^|S|`** — Step 3's first
count, the source of every "nuclei counts multiply" observation. -/
theorem card_nuclei_chain :
    Fintype.card {j : α → α // IsNucleus j}
      = 2 ^ (Finset.univ.erase (⊤ : α)).card :=
  (Fintype.card_congr nucleusEquivTopSets).trans card_topSets

/-- The below/at-or-above partition of the non-top elements. -/
theorem card_below_add_card_above (e : α) :
    ((Finset.univ.erase (⊤ : α)).filter fun x => x < e).card
      + ((Finset.univ.erase (⊤ : α)).filter fun x => e ≤ x).card
      = (Finset.univ.erase (⊤ : α)).card := by
  have h : ((Finset.univ.erase (⊤ : α)).filter fun x => e ≤ x)
      = ((Finset.univ.erase (⊤ : α)).filter fun x => ¬(x < e)) :=
    Finset.filter_congr fun x _ => by simp [not_lt]
  rw [h, Finset.card_filter_add_card_filter_not]

/-! Translation of the three characterizations to erased subsets. -/

private theorem denseRegular_topset_iff (e : α) (G : Finset α)
    (hGS : G ⊆ Finset.univ.erase ⊤) :
    (¬∃ x ∈ insert (⊤ : α) G, e ≤ x ∧ x ≠ ⊤) ↔ ∀ x ∈ G, x < e := by
  constructor
  · intro h x hxG
    by_contra hlt
    exact h ⟨x, Finset.mem_insert_of_mem hxG, not_lt.mp hlt,
      (Finset.mem_erase.mp (hGS hxG)).1⟩
  · rintro h ⟨x, hx, hex, hxt⟩
    rcases Finset.mem_insert.mp hx with rfl | hxG
    · exact hxt rfl
    · exact absurd hex (not_le.mpr (h x hxG))

private theorem dense_topset_iff (e : α) (G : Finset α)
    (hGS : G ⊆ Finset.univ.erase ⊤) :
    ((∃ x ∈ insert (⊤ : α) G, x < e) ∨ ∀ x ∈ insert (⊤ : α) G, x = ⊤)
      ↔ (∃ x ∈ G, x < e) ∨ G = ∅ := by
  constructor
  · rintro (⟨x, hx, hxe⟩ | hall)
    · rcases Finset.mem_insert.mp hx with rfl | hxG
      · exact absurd (hxe.trans_le le_top) (lt_irrefl _)
      · exact Or.inl ⟨x, hxG, hxe⟩
    · refine Or.inr (Finset.eq_empty_iff_forall_notMem.mpr fun x hxG => ?_)
      exact (Finset.mem_erase.mp (hGS hxG)).1
        (hall x (Finset.mem_insert_of_mem hxG))
  · rintro (⟨x, hxG, hxe⟩ | rfl)
    · exact Or.inl ⟨x, Finset.mem_insert_of_mem hxG, hxe⟩
    · refine Or.inr fun x hx => ?_
      rcases Finset.mem_insert.mp hx with rfl | h
      · rfl
      · exact absurd h (Finset.notMem_empty x)

omit [Fintype α] in
private theorem notbelow_topset_iff (e : α) (G : Finset α) :
    (¬∃ x ∈ insert (⊤ : α) G, x < e) ↔ ∀ x ∈ G, e ≤ x := by
  constructor
  · intro h x hxG
    by_contra hlt
    exact h ⟨x, Finset.mem_insert_of_mem hxG, not_le.mp hlt⟩
  · rintro h ⟨x, hx, hxe⟩
    rcases Finset.mem_insert.mp hx with rfl | hxG
    · exact absurd (hxe.trans_le le_top) (lt_irrefl _)
    · exact absurd hxe (not_lt.mpr (h x hxG))

omit [BoundedOrder α] in
/-- Subsets all of whose members satisfy `p` are the subsets of the
`p`-filter. -/
private theorem filter_forall_eq_powerset_filter (S : Finset α) (p : α → Prop)
    [DecidablePred p] :
    S.powerset.filter (fun G => ∀ x ∈ G, p x) = (S.filter p).powerset := by
  ext G
  rw [Finset.mem_filter, Finset.mem_powerset, Finset.mem_powerset]
  constructor
  · rintro ⟨hGS, h⟩ x hxG
    exact Finset.mem_filter.mpr ⟨hGS hxG, h x hxG⟩
  · intro hGT
    exact ⟨hGT.trans (Finset.filter_subset _ _),
      fun x hxG => (Finset.mem_filter.mp (hGT hxG)).2⟩

/-- **Count DR: dense-and-regular observers number `2^|B|`.** -/
theorem card_worldDenseRegular (e : α) :
    Fintype.card {j : α → α //
        IsNucleus j ∧ (WorldDense j e ∧ WorldRegular j e)}
      = 2 ^ ((Finset.univ.erase (⊤ : α)).filter fun x => x < e).card := by
  rw [Fintype.card_congr (nucleusCountEquiv _
      (fun F => ¬∃ x ∈ F, e ≤ x ∧ x ≠ ⊤)
      (fun F htop => worldDenseRegular_chainNucleus_iff htop)),
    card_topSets_filter, ← Finset.card_powerset]
  congr 1
  rw [← filter_forall_eq_powerset_filter]
  exact Finset.filter_congr fun G hG =>
    denseRegular_topset_iff e G (Finset.mem_powerset.mp hG)

/-- **Count D (additive form): dense observers number
`(2^|B| − 1)·2^|U| + 1`, stated as `D + 2^|U| = 2^|S| + 1`.** -/
theorem card_worldDense_add (e : α) :
    Fintype.card {j : α → α // IsNucleus j ∧ WorldDense j e}
      + 2 ^ ((Finset.univ.erase (⊤ : α)).filter fun x => e ≤ x).card
      = 2 ^ (Finset.univ.erase (⊤ : α)).card + 1 := by
  rw [Fintype.card_congr (nucleusCountEquiv _
      (fun F => (∃ x ∈ F, x < e) ∨ ∀ x ∈ F, x = ⊤)
      (fun F htop => worldDense_chainNucleus_iff htop)),
    card_topSets_filter]
  have hcong : ((Finset.univ.erase (⊤ : α)).powerset).filter
        (fun G => (∃ x ∈ insert ⊤ G, x < e) ∨ ∀ x ∈ insert ⊤ G, x = ⊤)
      = ((Finset.univ.erase (⊤ : α)).powerset).filter
        (fun G => (∃ x ∈ G, x < e) ∨ G = ∅) :=
    Finset.filter_congr fun G hG =>
      dense_topset_iff e G (Finset.mem_powerset.mp hG)
  rw [hcong, Finset.filter_or]
  have hempty : ((Finset.univ.erase (⊤ : α)).powerset).filter
      (fun G => G = ∅) = {∅} := by
    ext G
    simp only [Finset.mem_filter, Finset.mem_powerset, Finset.mem_singleton,
      and_iff_right_iff_imp]
    rintro rfl
    exact Finset.empty_subset _
  have hdisj : Disjoint
      (((Finset.univ.erase (⊤ : α)).powerset).filter fun G => ∃ x ∈ G, x < e)
      (((Finset.univ.erase (⊤ : α)).powerset).filter fun G => G = ∅) := by
    rw [Finset.disjoint_left]
    rintro G hG1 hG2
    obtain ⟨x, hxG, -⟩ := (Finset.mem_filter.mp hG1).2
    rw [(Finset.mem_filter.mp hG2).2] at hxG
    exact Finset.notMem_empty x hxG
  rw [Finset.card_union_of_disjoint hdisj, hempty, Finset.card_singleton]
  have hneg : ((Finset.univ.erase (⊤ : α)).powerset).filter
        (fun G => ¬∃ x ∈ G, x < e)
      = (((Finset.univ.erase (⊤ : α)).filter fun x => e ≤ x)).powerset := by
    rw [← filter_forall_eq_powerset_filter]
    refine Finset.filter_congr fun G _ => ?_
    constructor
    · intro h x hxG
      by_contra hlt
      exact h ⟨x, hxG, not_le.mp hlt⟩
    · rintro h ⟨x, hxG, hxe⟩
      exact absurd hxe (not_lt.mpr (h x hxG))
  have hcompl : (((Finset.univ.erase (⊤ : α)).powerset).filter
        (fun G => ∃ x ∈ G, x < e)).card
      + (((Finset.univ.erase (⊤ : α)).powerset).filter
        (fun G => ¬∃ x ∈ G, x < e)).card
      = ((Finset.univ.erase (⊤ : α)).powerset).card :=
    Finset.card_filter_add_card_filter_not ..
  rw [hneg, Finset.card_powerset, Finset.card_powerset] at hcompl
  omega

/-- **Count R (additive form): regular observers number
`2^|U| + 2^|B| − 1`, stated as `R + 1 = 2^|U| + 2^|B|`.** -/
theorem card_worldRegular_add (e : α) :
    Fintype.card {j : α → α // IsNucleus j ∧ WorldRegular j e} + 1
      = 2 ^ ((Finset.univ.erase (⊤ : α)).filter fun x => e ≤ x).card
        + 2 ^ ((Finset.univ.erase (⊤ : α)).filter fun x => x < e).card := by
  rw [Fintype.card_congr (nucleusCountEquiv _
      (fun F => (¬∃ x ∈ F, x < e) ∨ ¬∃ x ∈ F, e ≤ x ∧ x ≠ ⊤)
      (fun F htop => (worldRegular_chainNucleus_iff htop).trans
        (or_congr_right (chainNucleus_eq_top_iff htop)))),
    card_topSets_filter]
  have hcong : ((Finset.univ.erase (⊤ : α)).powerset).filter
        (fun G => (¬∃ x ∈ insert ⊤ G, x < e) ∨
          ¬∃ x ∈ insert ⊤ G, e ≤ x ∧ x ≠ ⊤)
      = ((Finset.univ.erase (⊤ : α)).powerset).filter
        (fun G => (∀ x ∈ G, e ≤ x) ∨ ∀ x ∈ G, x < e) :=
    Finset.filter_congr fun G hG => or_congr (notbelow_topset_iff e G)
      (denseRegular_topset_iff e G (Finset.mem_powerset.mp hG))
  rw [hcong, Finset.filter_or, filter_forall_eq_powerset_filter,
    filter_forall_eq_powerset_filter]
  have hint : (((Finset.univ.erase (⊤ : α)).filter fun x => e ≤ x)).powerset
      ∩ (((Finset.univ.erase (⊤ : α)).filter fun x => x < e)).powerset
      = {∅} := by
    ext G
    simp only [Finset.mem_inter, Finset.mem_powerset, Finset.mem_singleton]
    constructor
    · rintro ⟨hU, hB⟩
      refine Finset.eq_empty_iff_forall_notMem.mpr fun x hxG => ?_
      exact absurd (Finset.mem_filter.mp (hU hxG)).2
        (not_le.mpr (Finset.mem_filter.mp (hB hxG)).2)
    · rintro rfl
      exact ⟨Finset.empty_subset _, Finset.empty_subset _⟩
  have hunion := Finset.card_union_add_card_inter
    (((Finset.univ.erase (⊤ : α)).filter fun x => e ≤ x)).powerset
    (((Finset.univ.erase (⊤ : α)).filter fun x => x < e)).powerset
  rw [hint, Finset.card_singleton, Finset.card_powerset,
    Finset.card_powerset] at hunion
  omega

end ChainCounts

/-! ## Assembly: inclusion–exclusion on a product of two finite
Heyting algebras

Pure counting, no chain structure needed: transfer the aperture count
across the factorization equivalence, split the complement of `Opens`
into the dense-pair and regular-pair events, and apply
`card_union_add_card_inter`.  Stated additively (no ℕ-subtraction). -/

section Assembly

variable {A B : Type*}
  [HeytingAlgebra A] [Fintype A] [DecidableEq A] [DecidableLE A]
  [HeytingAlgebra B] [Fintype B] [DecidableEq B] [DecidableLE B]

private theorem card_filter_subtype {γ : Type*} [Fintype γ]
    (P Q : γ → Prop) [DecidablePred P] [DecidablePred Q] :
    (Finset.univ.filter fun x : {x // P x} => Q x.1).card
      = Fintype.card {x : γ // P x ∧ Q x} := by
  rw [← Fintype.card_subtype]
  exact Fintype.card_congr (Equiv.subtypeSubtypeEquivSubtypeInter P Q)

/-- Inclusion–exclusion for two decidable events on a finset, phrased
without subtraction.  Isolated so union and intersection share one
`DecidableEq` instance. -/
private theorem card_filter_or_add_card_filter_and {γ : Type*} [DecidableEq γ]
    (s : Finset γ) (P Q : γ → Prop) [DecidablePred P] [DecidablePred Q] :
    (s.filter fun x => P x ∨ Q x).card + (s.filter fun x => P x ∧ Q x).card
      = (s.filter P).card + (s.filter Q).card := by
  rw [Finset.filter_or, Finset.filter_and]
  exact Finset.card_union_add_card_inter _ _

/-- **Inclusion–exclusion for the aperture on a product (additive
form).**  |Ap(k)| + D_A·D_B + R_A·R_B = N_A·N_B + DR_A·DR_B, where on
each factor N counts all nuclei, D the world-dense ones at the kernel
coordinate, R the world-regular ones, DR both.  With the chain counts
this is the paper's Theorem 5.1 for two prime chains. -/
theorem aperture_card_add_eq (k : A × B) :
    Fintype.card {j : A × B → A × B // IsNucleus j ∧ Opens j k}
      + Fintype.card {jA : A → A // IsNucleus jA ∧ WorldDense jA k.1}
        * Fintype.card {jB : B → B // IsNucleus jB ∧ WorldDense jB k.2}
      + Fintype.card {jA : A → A // IsNucleus jA ∧ WorldRegular jA k.1}
        * Fintype.card {jB : B → B // IsNucleus jB ∧ WorldRegular jB k.2}
      = Fintype.card {jA : A → A // IsNucleus jA}
        * Fintype.card {jB : B → B // IsNucleus jB}
      + Fintype.card {jA : A → A //
          IsNucleus jA ∧ (WorldDense jA k.1 ∧ WorldRegular jA k.1)}
        * Fintype.card {jB : B → B //
          IsNucleus jB ∧ (WorldDense jB k.2 ∧ WorldRegular jB k.2)} := by
  -- Opens on the product = neither dense-pair nor regular-pair,
  -- through the factorization of the nucleus.
  have key : ∀ j : {j : A × B → A × B // IsNucleus j},
      Opens j.1 k ↔
        ¬(WorldDense (nucleusFst j.1) k.1 ∧ WorldDense (nucleusSnd j.1) k.2) ∧
        ¬(WorldRegular (nucleusFst j.1) k.1 ∧
          WorldRegular (nucleusSnd j.1) k.2) := by
    intro j
    have hfun : j.1
        = fun p : A × B => (nucleusFst j.1 p.1, nucleusSnd j.1 p.2) :=
      funext j.2.eq_prodMap
    calc Opens j.1 k
        ↔ Opens (fun p : A × B =>
            (nucleusFst j.1 p.1, nucleusSnd j.1 p.2)) k := by rw [← hfun]
      _ ↔ _ := by
          rw [opens_iff_world, worldDense_prodMap_iff, worldRegular_prodMap_iff]
  have e1 : {j : A × B → A × B // IsNucleus j ∧ Opens j k} ≃
      {p : {jA : A → A // IsNucleus jA} × {jB : B → B // IsNucleus jB} //
        ¬(WorldDense p.1.1 k.1 ∧ WorldDense p.2.1 k.2) ∧
        ¬(WorldRegular p.1.1 k.1 ∧ WorldRegular p.2.1 k.2)} :=
    (Equiv.subtypeSubtypeEquivSubtypeInter _ _).symm.trans
      (nucleusProdEquiv.subtypeEquiv fun j => key j)
  have hc1 : Fintype.card {j : A × B → A × B // IsNucleus j ∧ Opens j k}
      = (Finset.univ.filter fun p :
            {jA : A → A // IsNucleus jA} × {jB : B → B // IsNucleus jB} =>
          ¬(WorldDense p.1.1 k.1 ∧ WorldDense p.2.1 k.2) ∧
          ¬(WorldRegular p.1.1 k.1 ∧ WorldRegular p.2.1 k.2)).card :=
    (Fintype.card_congr e1).trans (Fintype.card_subtype _)
  -- generic product-filter factorization
  have hprod : ∀ (PA : {jA : A → A // IsNucleus jA} → Prop)
      (PB : {jB : B → B // IsNucleus jB} → Prop)
      [DecidablePred PA] [DecidablePred PB],
      (Finset.univ.filter fun p :
          {jA : A → A // IsNucleus jA} × {jB : B → B // IsNucleus jB} =>
        PA p.1 ∧ PB p.2).card
        = (Finset.univ.filter PA).card * (Finset.univ.filter PB).card := by
    intro PA PB _ _
    have huniv : (Finset.univ : Finset
          ({jA : A → A // IsNucleus jA} × {jB : B → B // IsNucleus jB}))
        = Finset.univ ×ˢ Finset.univ := Finset.univ_product_univ.symm
    rw [huniv, Finset.filter_product, Finset.card_product]
  -- complement split
  have hsplit : (Finset.univ.filter fun p :
        {jA : A → A // IsNucleus jA} × {jB : B → B // IsNucleus jB} =>
        (WorldDense p.1.1 k.1 ∧ WorldDense p.2.1 k.2) ∨
        (WorldRegular p.1.1 k.1 ∧ WorldRegular p.2.1 k.2)).card
      + (Finset.univ.filter fun p :
        {jA : A → A // IsNucleus jA} × {jB : B → B // IsNucleus jB} =>
        ¬((WorldDense p.1.1 k.1 ∧ WorldDense p.2.1 k.2) ∨
          (WorldRegular p.1.1 k.1 ∧ WorldRegular p.2.1 k.2))).card
      = Fintype.card
          ({jA : A → A // IsNucleus jA} × {jB : B → B // IsNucleus jB}) := by
    rw [← Finset.card_univ]
    exact Finset.card_filter_add_card_filter_not ..
  have hnegcong : (Finset.univ.filter fun p :
        {jA : A → A // IsNucleus jA} × {jB : B → B // IsNucleus jB} =>
        ¬((WorldDense p.1.1 k.1 ∧ WorldDense p.2.1 k.2) ∨
          (WorldRegular p.1.1 k.1 ∧ WorldRegular p.2.1 k.2))).card
      = (Finset.univ.filter fun p :
        {jA : A → A // IsNucleus jA} × {jB : B → B // IsNucleus jB} =>
        ¬(WorldDense p.1.1 k.1 ∧ WorldDense p.2.1 k.2) ∧
        ¬(WorldRegular p.1.1 k.1 ∧ WorldRegular p.2.1 k.2)).card := by
    congr 1
    exact Finset.filter_congr fun p _ => not_or
  -- inclusion–exclusion for the union
  have hunion : (Finset.univ.filter fun p :
        {jA : A → A // IsNucleus jA} × {jB : B → B // IsNucleus jB} =>
        (WorldDense p.1.1 k.1 ∧ WorldDense p.2.1 k.2) ∨
        (WorldRegular p.1.1 k.1 ∧ WorldRegular p.2.1 k.2)).card
      + (Finset.univ.filter fun p :
        {jA : A → A // IsNucleus jA} × {jB : B → B // IsNucleus jB} =>
        (WorldDense p.1.1 k.1 ∧ WorldDense p.2.1 k.2) ∧
        (WorldRegular p.1.1 k.1 ∧ WorldRegular p.2.1 k.2)).card
      = (Finset.univ.filter fun p :
        {jA : A → A // IsNucleus jA} × {jB : B → B // IsNucleus jB} =>
        WorldDense p.1.1 k.1 ∧ WorldDense p.2.1 k.2).card
      + (Finset.univ.filter fun p :
        {jA : A → A // IsNucleus jA} × {jB : B → B // IsNucleus jB} =>
        WorldRegular p.1.1 k.1 ∧ WorldRegular p.2.1 k.2).card := by
    exact card_filter_or_add_card_filter_and Finset.univ
      (fun p : {jA : A → A // IsNucleus jA} × {jB : B → B // IsNucleus jB} =>
        WorldDense p.1.1 k.1 ∧ WorldDense p.2.1 k.2)
      (fun p : {jA : A → A // IsNucleus jA} × {jB : B → B // IsNucleus jB} =>
        WorldRegular p.1.1 k.1 ∧ WorldRegular p.2.1 k.2)
  -- reassociate the intersection into a coordinatewise conjunction
  have hintcong : (Finset.univ.filter fun p :
        {jA : A → A // IsNucleus jA} × {jB : B → B // IsNucleus jB} =>
        (WorldDense p.1.1 k.1 ∧ WorldDense p.2.1 k.2) ∧
        (WorldRegular p.1.1 k.1 ∧ WorldRegular p.2.1 k.2)).card
      = (Finset.univ.filter fun p :
        {jA : A → A // IsNucleus jA} × {jB : B → B // IsNucleus jB} =>
        (WorldDense p.1.1 k.1 ∧ WorldRegular p.1.1 k.1) ∧
        (WorldDense p.2.1 k.2 ∧ WorldRegular p.2.1 k.2)).card := by
    congr 1
    exact Finset.filter_congr fun p _ => by tauto
  -- the three product counts, converted to flat subtype counts
  have hDD : (Finset.univ.filter fun p :
        {jA : A → A // IsNucleus jA} × {jB : B → B // IsNucleus jB} =>
        WorldDense p.1.1 k.1 ∧ WorldDense p.2.1 k.2).card
      = Fintype.card {jA : A → A // IsNucleus jA ∧ WorldDense jA k.1}
        * Fintype.card {jB : B → B // IsNucleus jB ∧ WorldDense jB k.2} := by
    have h := hprod (fun jA => WorldDense jA.1 k.1)
      (fun jB => WorldDense jB.1 k.2)
    rw [card_filter_subtype (fun jA : A → A => IsNucleus jA)
        (fun jA => WorldDense jA k.1),
      card_filter_subtype (fun jB : B → B => IsNucleus jB)
        (fun jB => WorldDense jB k.2)] at h
    exact h
  have hRR : (Finset.univ.filter fun p :
        {jA : A → A // IsNucleus jA} × {jB : B → B // IsNucleus jB} =>
        WorldRegular p.1.1 k.1 ∧ WorldRegular p.2.1 k.2).card
      = Fintype.card {jA : A → A // IsNucleus jA ∧ WorldRegular jA k.1}
        * Fintype.card {jB : B → B // IsNucleus jB ∧ WorldRegular jB k.2} := by
    have h := hprod (fun jA => WorldRegular jA.1 k.1)
      (fun jB => WorldRegular jB.1 k.2)
    rw [card_filter_subtype (fun jA : A → A => IsNucleus jA)
        (fun jA => WorldRegular jA k.1),
      card_filter_subtype (fun jB : B → B => IsNucleus jB)
        (fun jB => WorldRegular jB k.2)] at h
    exact h
  have hDRDR : (Finset.univ.filter fun p :
        {jA : A → A // IsNucleus jA} × {jB : B → B // IsNucleus jB} =>
        (WorldDense p.1.1 k.1 ∧ WorldRegular p.1.1 k.1) ∧
        (WorldDense p.2.1 k.2 ∧ WorldRegular p.2.1 k.2)).card
      = Fintype.card {jA : A → A //
            IsNucleus jA ∧ (WorldDense jA k.1 ∧ WorldRegular jA k.1)}
        * Fintype.card {jB : B → B //
            IsNucleus jB ∧ (WorldDense jB k.2 ∧ WorldRegular jB k.2)} := by
    have h := hprod (fun jA => WorldDense jA.1 k.1 ∧ WorldRegular jA.1 k.1)
      (fun jB => WorldDense jB.1 k.2 ∧ WorldRegular jB.1 k.2)
    rw [card_filter_subtype (fun jA : A → A => IsNucleus jA)
        (fun jA => WorldDense jA k.1 ∧ WorldRegular jA k.1),
      card_filter_subtype (fun jB : B → B => IsNucleus jB)
        (fun jB => WorldDense jB k.2 ∧ WorldRegular jB k.2)] at h
    exact h
  have htotal : Fintype.card
        ({jA : A → A // IsNucleus jA} × {jB : B → B // IsNucleus jB})
      = Fintype.card {jA : A → A // IsNucleus jA}
        * Fintype.card {jB : B → B // IsNucleus jB} := Fintype.card_prod _ _
  rw [hc1, ← hnegcong]
  rw [htotal] at hsplit
  rw [hintcong, hDRDR, hDD, hRR] at hunion
  omega

end Assembly

/-! ## The closed form on a product of two finite bounded chains -/

section TwoChains

variable {α β : Type*}
  [LinearOrder α] [Fintype α] [BoundedOrder α]
  [LinearOrder β] [Fintype β] [BoundedOrder β]

local instance : BiheytingAlgebra α := LinearOrder.toBiheytingAlgebra α
local instance : BiheytingAlgebra β := LinearOrder.toBiheytingAlgebra β

/-- **Theorem 5.1 on two chains (abstract form).**  For a kernel
`k = (k₁, k₂)` on a product of two finite bounded chains, with
`n, b, u` the cardinalities of the non-top elements, those strictly
below the kernel coordinate, and the non-top ones at or above it:
|Ap(k)| = 2^(n_α+n_β) − D_α·D_β − R_α·R_β + 2^(b_α+b_β). -/
theorem aperture_closed_form_two_chains (k : α × β) :
    (Fintype.card {j : α × β → α × β // IsNucleus j ∧ Opens j k} : ℤ)
      = 2 ^ ((Finset.univ.erase (⊤ : α)).card
            + (Finset.univ.erase (⊤ : β)).card)
        - ((2 ^ ((Finset.univ.erase (⊤ : α)).filter fun x => x < k.1).card - 1)
              * 2 ^ ((Finset.univ.erase (⊤ : α)).filter fun x => k.1 ≤ x).card
            + 1)
          * ((2 ^ ((Finset.univ.erase (⊤ : β)).filter fun x => x < k.2).card - 1)
              * 2 ^ ((Finset.univ.erase (⊤ : β)).filter fun x => k.2 ≤ x).card
            + 1)
        - (2 ^ ((Finset.univ.erase (⊤ : α)).filter fun x => k.1 ≤ x).card
              + 2 ^ ((Finset.univ.erase (⊤ : α)).filter fun x => x < k.1).card
            - 1)
          * (2 ^ ((Finset.univ.erase (⊤ : β)).filter fun x => k.2 ≤ x).card
              + 2 ^ ((Finset.univ.erase (⊤ : β)).filter fun x => x < k.2).card
            - 1)
        + 2 ^ (((Finset.univ.erase (⊤ : α)).filter fun x => x < k.1).card
            + ((Finset.univ.erase (⊤ : β)).filter fun x => x < k.2).card) := by
  set bA := ((Finset.univ.erase (⊤ : α)).filter fun x => x < k.1).card with hbA
  set uA := ((Finset.univ.erase (⊤ : α)).filter fun x => k.1 ≤ x).card with huA
  set nA := (Finset.univ.erase (⊤ : α)).card with hnA
  set bB := ((Finset.univ.erase (⊤ : β)).filter fun x => x < k.2).card with hbB
  set uB := ((Finset.univ.erase (⊤ : β)).filter fun x => k.2 ≤ x).card with huB
  set nB := (Finset.univ.erase (⊤ : β)).card with hnB
  have hPA : bA + uA = nA := card_below_add_card_above k.1
  have hPB : bB + uB = nB := card_below_add_card_above k.2
  -- the four counts on each factor, over ℤ
  have hNAZ : (Fintype.card {jA : α → α // IsNucleus jA} : ℤ)
      = 2 ^ bA * 2 ^ uA := by
    have h := card_nuclei_chain (α := α)
    rw [← hnA, ← hPA, pow_add] at h
    exact_mod_cast h
  have hNBZ : (Fintype.card {jB : β → β // IsNucleus jB} : ℤ)
      = 2 ^ bB * 2 ^ uB := by
    have h := card_nuclei_chain (α := β)
    rw [← hnB, ← hPB, pow_add] at h
    exact_mod_cast h
  have hDAZ : (Fintype.card
        {jA : α → α // IsNucleus jA ∧ WorldDense jA k.1} : ℤ)
      = (2 ^ bA - 1) * 2 ^ uA + 1 := by
    have h := card_worldDense_add (α := α) k.1
    rw [← huA, ← hnA, ← hPA, pow_add] at h
    have hz : (Fintype.card {jA : α → α // IsNucleus jA ∧ WorldDense jA k.1}
        : ℤ) + 2 ^ uA = 2 ^ bA * 2 ^ uA + 1 := by exact_mod_cast h
    linear_combination hz
  have hDBZ : (Fintype.card
        {jB : β → β // IsNucleus jB ∧ WorldDense jB k.2} : ℤ)
      = (2 ^ bB - 1) * 2 ^ uB + 1 := by
    have h := card_worldDense_add (α := β) k.2
    rw [← huB, ← hnB, ← hPB, pow_add] at h
    have hz : (Fintype.card {jB : β → β // IsNucleus jB ∧ WorldDense jB k.2}
        : ℤ) + 2 ^ uB = 2 ^ bB * 2 ^ uB + 1 := by exact_mod_cast h
    linear_combination hz
  have hRAZ : (Fintype.card
        {jA : α → α // IsNucleus jA ∧ WorldRegular jA k.1} : ℤ)
      = 2 ^ uA + 2 ^ bA - 1 := by
    have h := card_worldRegular_add (α := α) k.1
    rw [← hbA, ← huA] at h
    have hz : (Fintype.card {jA : α → α // IsNucleus jA ∧ WorldRegular jA k.1}
        : ℤ) + 1 = 2 ^ uA + 2 ^ bA := by exact_mod_cast h
    linear_combination hz
  have hRBZ : (Fintype.card
        {jB : β → β // IsNucleus jB ∧ WorldRegular jB k.2} : ℤ)
      = 2 ^ uB + 2 ^ bB - 1 := by
    have h := card_worldRegular_add (α := β) k.2
    rw [← hbB, ← huB] at h
    have hz : (Fintype.card {jB : β → β // IsNucleus jB ∧ WorldRegular jB k.2}
        : ℤ) + 1 = 2 ^ uB + 2 ^ bB := by exact_mod_cast h
    linear_combination hz
  have hDRAZ : (Fintype.card {jA : α → α //
        IsNucleus jA ∧ (WorldDense jA k.1 ∧ WorldRegular jA k.1)} : ℤ)
      = 2 ^ bA := by
    have h := card_worldDenseRegular (α := α) k.1
    rw [← hbA] at h
    exact_mod_cast h
  have hDRBZ : (Fintype.card {jB : β → β //
        IsNucleus jB ∧ (WorldDense jB k.2 ∧ WorldRegular jB k.2)} : ℤ)
      = 2 ^ bB := by
    have h := card_worldDenseRegular (α := β) k.2
    rw [← hbB] at h
    exact_mod_cast h
  -- the assembled inclusion–exclusion, over ℤ
  have hmain := aperture_card_add_eq (A := α) (B := β) k
  have hmainZ := congrArg (fun n : ℕ => (n : ℤ)) hmain
  push_cast at hmainZ
  rw [hNAZ, hNBZ, hDAZ, hDBZ, hRAZ, hRBZ, hDRAZ, hDRBZ] at hmainZ
  rw [← hPA, ← hPB]
  linear_combination hmainZ

end TwoChains

/-! ## Theorem 5.1, two-prime case, on the exponent lattices -/

section Exponents

local instance (n : ℕ) : BiheytingAlgebra (Fin (n + 1)) :=
  LinearOrder.toBiheytingAlgebra (Fin (n + 1))

theorem fin_card_nontop (m : ℕ) :
    (Finset.univ.erase (⊤ : Fin (m + 1))).card = m := by
  rw [Finset.card_erase_of_mem (Finset.mem_univ _), Finset.card_univ,
    Fintype.card_fin]
  omega

theorem fin_card_below (m : ℕ) (e : Fin (m + 1)) :
    ((Finset.univ.erase (⊤ : Fin (m + 1))).filter fun x => x < e).card
      = (e : ℕ) := by
  have h1 : (Finset.univ.erase (⊤ : Fin (m + 1))).filter (fun x => x < e)
      = Finset.univ.filter fun x => x < e := by
    ext x
    simp only [Finset.mem_filter, Finset.mem_erase, Finset.mem_univ,
      true_and, and_true]
    constructor
    · rintro ⟨-, h⟩
      exact h
    · intro h
      exact ⟨fun hx => absurd (hx ▸ h) (not_lt.mpr le_top), h⟩
  have h2 : Finset.univ.filter (fun x => x < e) = Finset.Iio e := by
    ext x
    simp [Finset.mem_Iio]
  rw [h1, h2, Fin.card_Iio]

theorem fin_card_above (m : ℕ) (e : Fin (m + 1)) :
    ((Finset.univ.erase (⊤ : Fin (m + 1))).filter fun x => e ≤ x).card
      = m - (e : ℕ) := by
  have h := card_below_add_card_above (α := Fin (m + 1)) e
  rw [fin_card_below, fin_card_nontop] at h
  omega

/-- **Theorem 5.1, two-prime case (kernel-checked).**  On the exponent
lattice `Fin (a+1) × Fin (b+1)` of `Div(p^a · q^b)`, the aperture of
the kernel `k = (i, j)` — the divisor `p^i · q^j` — has size

  `2^(a+b) − D_p·D_q − R_p·R_q + 2^(i+j)`

with `D = (2^e − 1)·2^(chain − e) + 1` and
`R = 2^(chain − e) + 2^e − 1` per chain, exactly the paper's formula. -/
theorem aperture_closed_form_exponents (a b : ℕ)
    (k : Fin (a + 1) × Fin (b + 1)) :
    (Fintype.card {j : Fin (a + 1) × Fin (b + 1) → Fin (a + 1) × Fin (b + 1) //
        IsNucleus j ∧ Opens j k} : ℤ)
      = 2 ^ (a + b)
        - ((2 ^ (k.1 : ℕ) - 1) * 2 ^ (a - (k.1 : ℕ)) + 1)
          * ((2 ^ (k.2 : ℕ) - 1) * 2 ^ (b - (k.2 : ℕ)) + 1)
        - (2 ^ (a - (k.1 : ℕ)) + 2 ^ (k.1 : ℕ) - 1)
          * (2 ^ (b - (k.2 : ℕ)) + 2 ^ (k.2 : ℕ) - 1)
        + 2 ^ ((k.1 : ℕ) + (k.2 : ℕ)) := by
  have h := aperture_closed_form_two_chains
    (α := Fin (a + 1)) (β := Fin (b + 1)) k
  rw [fin_card_nontop, fin_card_nontop, fin_card_below, fin_card_below,
    fin_card_above, fin_card_above] at h
  exact h

/-- Cross-check on Div12's exponent lattice C₃ × C₂ with kernel
`2 = (1,0)`: the closed form evaluates to exactly `1`, matching the
independently kernel-checked completeness result `aperture_two_complete`
(Ap(2) = {identity} on Div12). -/
example :
    (Fintype.card {j : Fin (2 + 1) × Fin (1 + 1) → Fin (2 + 1) × Fin (1 + 1) //
        IsNucleus j ∧ Opens j ((1 : Fin (2 + 1)), (0 : Fin (1 + 1)))} : ℤ)
      = 1 := by
  have h := aperture_closed_form_exponents 2 1 ((1 : Fin (2 + 1)), (0 : Fin (1 + 1)))
  rw [h]
  decide

end Exponents

end FalseWork.Lattice
