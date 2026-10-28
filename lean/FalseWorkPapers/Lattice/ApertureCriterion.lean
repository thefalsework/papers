/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# The aperture criterion: a pointwise test for `j_S` opening `k`

Companion to `ObserverClassification.lean` (C1–C2 / E5) and to the
route-1 sweep `wolfram/aperture-shape.mjs` (2026-10-28); write-up in
`preprints/aperture/aperture-shape-note.md`.

The trace characterization says `j_S` opens `k` iff the trace `k ∩ S`
is ordinary in `D(S)`.  This file makes that test *pointwise*.  In the
down-set algebra of a finite poset `Q`, write `min Q` for the minimal
points.  Then for a lower set `D`:

* `D` is **dense** (`Dᶜ = ⊥`) iff `min Q ⊆ D`
  (`LowerSet.compl_eq_bot_iff_isMin_mem`);
* `x ∈ Dᶜᶜ` iff every minimal point below `x` lies in `D`
  (`LowerSet.mem_compl_compl_iff_isMin`), so `D` is **regular** iff
  every point outside `D` has a minimal point below it outside `D`
  (`LowerSet.compl_compl_eq_self_iff_isMin`).

Specializing to `Q = ↥S` and transporting along the trace gives the

* **Aperture criterion** (`opens_subNucleus_iff_minimal`).  With
  `M = min S` (the minimal elements of `S` in the induced order),
  `j_S` opens `k` iff

      (i)  some point of `M` lies outside `k`, and
      (ii) some `s ∈ S ∖ k` has every `M`-point below it inside `k`.

Two consequences are drawn here.

* **The bottom is the up-closure's complement**
  (`mem_subNucleus_bot_iff`): `x ∈ j_S ⊥` iff no point of `S` lies
  below `x`.  So two observers have the same bottom iff `S` and `T`
  have the same up-closure, iff they have the same minimal elements
  (`minimal_mem_iff_of_subNucleus_bot_eq`).

* **Fiber monotonicity** (`opens_subNucleus_of_subset_of_bot_eq`): if
  `S ⊆ T` and `j_S ⊥ = j_T ⊥`, then `j_S` opens `k` implies `j_T`
  opens `k`.  Refinement that keeps the bottom never closes a
  four-fold.  Only refinement that lowers the bottom — revealing a
  point beneath something the coarser observer took as ground — can.

* **Witness triples** (`opens_subNucleus_iff_witnessTriple`).  A
  *witness triple* for `k` is a 2-chain `c < x` with `c` inside `k`
  and `x` outside, plus a point `u` outside `k` incomparable to both
  — the join-irreducibles of Div12, with `k` as the tritone.  `j_S`
  opens `k` iff `S` contains a triple *valid in `S`* (no point of
  `S ∩ k` below `u`; every point of `S \ k` below `x` anchored by a
  point of `S ∩ k`).  The coarsest opening observers are exactly the
  triples themselves (`WitnessTriple.eq_of_subset_opens`): every
  observer that keeps a distinction generative contains a
  sub-observer seeing exactly the tritone lattice.  The triple form
  was stated 2026-10-27; this file kernel-checks it.

The sweep found that apertures are *not* order-convex in the nucleus
lattice in general (12,355 of 31,910 non-empty apertures through seven
points fail), and the smallest failure is in the aperture paper's own
data.  It is `decide`d here on the exponent poset of Div180
(`Div180Exp`, `{0<3} ⊔ {1<4} ⊔ {2}`), kernel `6 = {0, 1}`:
`S₁ = {0,3,4}` opens it, `S₂ = S₁ ∪ {1}` does not, `S₃ = P` does
(`aperture_not_convex_div180`).  `S₂` is exactly the step that lowers
the bottom: adding the point `1` beneath `4`.
-/
import FalseWorkPapers.Lattice.ObserverClassification
import Mathlib.Data.Set.Card
import Mathlib.Order.Minimal
import Mathlib.Order.Preorder.Finite

set_option linter.unusedSectionVars false

namespace FalseWork.Lattice

/-! ## Pointwise negation on down-sets of a finite poset -/

section Pointwise

variable {Q : Type*} [PartialOrder Q]

/-- `x ∈ Dᶜ` iff nothing below `x` is in `D`. -/
theorem LowerSet.mem_compl_iff' {D : LowerSet Q} {x : Q} :
    x ∈ Dᶜ ↔ ∀ y, y ≤ x → y ∉ D := by
  rw [← himp_bot, LowerSet.mem_himp_iff]
  simp

/-- Every point of a finite poset has a minimal point below it. -/
theorem exists_isMin_le' [Finite Q] (x : Q) : ∃ m, IsMin m ∧ m ≤ x := by
  obtain ⟨m, hmx, hm⟩ := Finite.exists_le_minimal (p := fun _ : Q => True) (a := x) trivial
  exact ⟨m, minimal_true.mp hm, hmx⟩

/-- **Density is a condition on the minimal points.**  `Dᶜ = ⊥` iff
every minimal point of `Q` lies in `D`. -/
theorem LowerSet.compl_eq_bot_iff_isMin_mem [Finite Q] {D : LowerSet Q} :
    Dᶜ = ⊥ ↔ ∀ m, IsMin m → m ∈ D := by
  constructor
  · intro h m hm
    by_contra hmD
    have hmc : m ∈ Dᶜ := by
      rw [LowerSet.mem_compl_iff']
      intro y hym hyD
      exact hmD (D.lower (hm hym) hyD)
    rw [h] at hmc
    simp at hmc
  · intro h
    apply le_antisymm _ bot_le
    refine LowerSet.le_iff'.mpr fun x hx => ?_
    rw [LowerSet.mem_compl_iff'] at hx
    obtain ⟨m, hm, hmx⟩ := exists_isMin_le' x
    exact absurd (h m hm) (hx m hmx)

/-- **Double negation is a condition on the minimal points below.**
`x ∈ Dᶜᶜ` iff every minimal point below `x` lies in `D`. -/
theorem LowerSet.mem_compl_compl_iff_isMin [Finite Q] {D : LowerSet Q} {x : Q} :
    x ∈ Dᶜᶜ ↔ ∀ m, IsMin m → m ≤ x → m ∈ D := by
  rw [LowerSet.mem_compl_iff']
  constructor
  · intro h m hm hmx
    have h1 := h m hmx
    rw [LowerSet.mem_compl_iff'] at h1
    by_contra hmD
    apply h1
    intro y hym hyD
    exact hmD (D.lower (hm hym) hyD)
  · intro h y hyx hyc
    rw [LowerSet.mem_compl_iff'] at hyc
    obtain ⟨m, hm, hmy⟩ := exists_isMin_le' y
    exact hyc m hmy (h m hm (hmy.trans hyx))

/-- **Regularity, pointwise.**  `Dᶜᶜ = D` iff every point outside `D`
has a minimal point below it that is also outside `D`. -/
theorem LowerSet.compl_compl_eq_self_iff_isMin [Finite Q] {D : LowerSet Q} :
    Dᶜᶜ = D ↔ ∀ x, x ∉ D → ∃ m, IsMin m ∧ m ≤ x ∧ m ∉ D := by
  constructor
  · intro h x hxD
    by_contra hno
    push Not at hno
    have hx : x ∈ Dᶜᶜ := LowerSet.mem_compl_compl_iff_isMin.mpr fun m hm hmx => hno m hm hmx
    rw [h] at hx
    exact hxD hx
  · intro h
    apply le_antisymm _ le_compl_compl
    refine LowerSet.le_iff'.mpr fun x hx => ?_
    by_contra hxD
    obtain ⟨m, hm, hmx, hmD⟩ := h x hxD
    exact hmD (LowerSet.mem_compl_compl_iff_isMin.mp hx m hm hmx)

end Pointwise

/-! ## The aperture criterion -/

section Criterion

variable {P : Type*} [PartialOrder P]

/-- Minimality in the subtype `↥S` is minimality among members of `S`. -/
theorem isMin_subtype_iff {S : Set P} (s : ↥S) :
    IsMin s ↔ Minimal (· ∈ S) (s : P) := by
  rw [← minimal_true_subtype, minimal_true]

/-- **The aperture criterion.**  Writing `M` for the minimal elements of
`S`: `j_S` opens `k` iff (i) some point of `M` is outside `k`, and
(ii) some `s ∈ S` outside `k` has every point of `M` below it inside
`k`. -/
theorem opens_subNucleus_iff_minimal [Finite P] (S : Set P) (k : LowerSet P) :
    Opens (subNucleus S) k ↔
      (∃ m, Minimal (· ∈ S) m ∧ m ∉ k) ∧
      (∃ s ∈ S, s ∉ k ∧ ∀ m, Minimal (· ∈ S) m → m ≤ s → m ∈ k) := by
  rw [opens_subNucleus_iff, and_comm]
  haveI : Finite ↥S := Subtype.finite
  constructor
  · rintro ⟨hd, hr⟩
    refine ⟨?_, ?_⟩
    · by_contra hno
      push Not at hno
      apply hd
      rw [LowerSet.compl_eq_bot_iff_isMin_mem]
      intro m hm
      exact hno m ((isMin_subtype_iff m).mp hm)
    · by_contra hno
      push Not at hno
      apply hr
      rw [LowerSet.compl_compl_eq_self_iff_isMin]
      intro s hs
      obtain ⟨m, hmS, hms, hmk⟩ := hno s s.2 hs
      exact ⟨⟨m, hmS.1⟩, (isMin_subtype_iff _).mpr hmS, Subtype.coe_le_coe.mpr hms, hmk⟩
  · rintro ⟨⟨m, hm, hmk⟩, ⟨s, hsS, hsk, hs⟩⟩
    refine ⟨?_, ?_⟩
    · intro h
      rw [LowerSet.compl_eq_bot_iff_isMin_mem] at h
      exact hmk (h ⟨m, hm.1⟩ ((isMin_subtype_iff _).mpr hm))
    · intro h
      rw [LowerSet.compl_compl_eq_self_iff_isMin] at h
      obtain ⟨m', hm', hm's, hm'k⟩ := h ⟨s, hsS⟩ hsk
      exact hm'k (hs m' ((isMin_subtype_iff _).mp hm') (Subtype.coe_le_coe.mp hm's))

/-! ## The bottom of an observer's world -/

/-- `x` is in the observer's bottom iff no point of `S` lies below it:
`j_S ⊥ = P ∖ ↑S`. -/
theorem mem_subNucleus_bot_iff {S : Set P} {x : P} :
    x ∈ subNucleus S ⊥ ↔ ∀ s ∈ S, ¬ s ≤ x := by
  simp [mem_subNucleus]

/-- Equal bottoms means equal up-closures. -/
theorem upperClosure_eq_of_subNucleus_bot_eq {S T : Set P}
    (h : subNucleus S ⊥ = subNucleus T ⊥) :
    ∀ x, (∃ s ∈ S, s ≤ x) ↔ (∃ t ∈ T, t ≤ x) := by
  intro x
  have hx : x ∈ subNucleus S ⊥ ↔ x ∈ subNucleus T ⊥ := by rw [h]
  rw [mem_subNucleus_bot_iff, mem_subNucleus_bot_iff] at hx
  constructor
  · rintro ⟨s, hs, hsx⟩
    by_contra hno
    push Not at hno
    exact hx.mpr hno s hs hsx
  · rintro ⟨t, ht, htx⟩
    by_contra hno
    push Not at hno
    exact hx.mp hno t ht htx

/-- Minimality among members of `S` depends only on the up-closure of
`S`; hence observers with equal bottoms have equal minimal sets. -/
theorem minimal_mem_iff_of_subNucleus_bot_eq {S T : Set P}
    (h : subNucleus S ⊥ = subNucleus T ⊥) (m : P) :
    Minimal (· ∈ S) m ↔ Minimal (· ∈ T) m := by
  have hup := upperClosure_eq_of_subNucleus_bot_eq h
  -- Minimal (· ∈ S) m ↔ Minimal (∃ s ∈ S, s ≤ ·) m, for any S
  have key : ∀ (S : Set P) (m : P),
      Minimal (· ∈ S) m ↔ Minimal (fun x => ∃ s ∈ S, s ≤ x) m := by
    intro S m
    constructor
    · rintro ⟨hmS, hmin⟩
      refine ⟨⟨m, hmS, le_rfl⟩, ?_⟩
      rintro y ⟨s, hs, hsy⟩ hym
      exact (hmin hs (hsy.trans hym)).trans hsy
    · rintro ⟨⟨s, hs, hsm⟩, hmin⟩
      have hms : m ≤ s := hmin ⟨s, hs, le_rfl⟩ hsm
      have : m = s := le_antisymm hms hsm
      subst this
      refine ⟨hs, ?_⟩
      intro y hy hym
      exact hmin ⟨y, hy, le_rfl⟩ hym
  rw [key S, key T]
  constructor
  · rintro ⟨h1, h2⟩
    exact ⟨(hup m).mp h1, fun y hy hym => h2 ((hup y).mpr hy) hym⟩
  · rintro ⟨h1, h2⟩
    exact ⟨(hup m).mpr h1, fun y hy hym => h2 ((hup y).mp hy) hym⟩

/-! ## Fiber monotonicity -/

/-- **Refinement that keeps the bottom never closes a four-fold.**  If
`S ⊆ T` and `j_S ⊥ = j_T ⊥`, then `j_S` opens `k` implies `j_T` opens
`k`.  Within each fiber of the bottom map, the aperture is an up-set. -/
theorem opens_subNucleus_of_subset_of_bot_eq [Finite P] {S T : Set P}
    (hST : S ⊆ T) (hbot : subNucleus S ⊥ = subNucleus T ⊥) (k : LowerSet P)
    (h : Opens (subNucleus S) k) : Opens (subNucleus T) k := by
  have hmin := minimal_mem_iff_of_subNucleus_bot_eq hbot
  rw [opens_subNucleus_iff_minimal] at h ⊢
  obtain ⟨⟨m, hm, hmk⟩, ⟨s, hsS, hsk, hs⟩⟩ := h
  exact ⟨⟨m, (hmin m).mp hm, hmk⟩,
    ⟨s, hST hsS, hsk, fun m' hm' hm's => hs m' ((hmin m').mpr hm') hm's⟩⟩

/-! ## Witness triples: every opening observer contains a Div12 -/

/-- A **witness triple** for a down-set `k`: a 2-chain `c < x` with
`c` inside `k` and `x` outside, plus a point `u` outside `k`
incomparable to both.  The induced poset on `{c, x, u}` is a 2-chain
plus a point — the join-irreducibles of Div12 — and the trace of `k`
on it is the tritone. -/
structure WitnessTriple (k : LowerSet P) where
  c : P
  x : P
  u : P
  c_mem : c ∈ k
  x_notMem : x ∉ k
  u_notMem : u ∉ k
  c_lt_x : c < x
  c_not_le_u : ¬ c ≤ u
  u_not_le_x : ¬ u ≤ x

namespace WitnessTriple

variable {k : LowerSet P}

/-- The three points of the triple, as a set. -/
def carrier (t : WitnessTriple k) : Set P := {t.c, t.x, t.u}

@[simp]
theorem mem_carrier {t : WitnessTriple k} {y : P} :
    y ∈ t.carrier ↔ y = t.c ∨ y = t.x ∨ y = t.u := by
  simp [carrier]

theorem c_mem_carrier (t : WitnessTriple k) : t.c ∈ t.carrier := by simp
theorem x_mem_carrier (t : WitnessTriple k) : t.x ∈ t.carrier := by simp
theorem u_mem_carrier (t : WitnessTriple k) : t.u ∈ t.carrier := by simp

theorem c_ne_x (t : WitnessTriple k) : t.c ≠ t.x := t.c_lt_x.ne
theorem c_ne_u (t : WitnessTriple k) : t.c ≠ t.u := fun h => t.c_not_le_u (h ▸ le_rfl)
theorem x_ne_u (t : WitnessTriple k) : t.x ≠ t.u := fun h => t.u_not_le_x (h ▸ le_rfl)

/-- `u` is incomparable to `c`. -/
theorem u_not_le_c (t : WitnessTriple k) : ¬ t.u ≤ t.c :=
  fun h => t.u_not_le_x (h.trans t.c_lt_x.le)

/-- `x` is incomparable to `u`. -/
theorem x_not_le_u (t : WitnessTriple k) : ¬ t.x ≤ t.u :=
  fun h => t.c_not_le_u (t.c_lt_x.le.trans h)

theorem ncard_carrier (t : WitnessTriple k) : t.carrier.ncard = 3 := by
  classical
  rw [Set.ncard_eq_three]
  exact ⟨t.c, t.x, t.u, t.c_ne_x, t.c_ne_u, t.x_ne_u, rfl⟩

/-- A triple is **valid in `S`** when `S` sees all three points, no
point of `S ∩ k` lies below `u` (so `u` still witnesses non-density),
and every point of `S \ k` below `x` is anchored by a point of
`S ∩ k` (so `x` still witnesses non-regularity). -/
def IsValidIn (t : WitnessTriple k) (S : Set P) : Prop :=
  t.carrier ⊆ S ∧
    (∀ y ∈ S, y ∈ k → ¬ y ≤ t.u) ∧
    (∀ y ∈ S, y ∉ k → y ≤ t.x → ∃ z ∈ S, z ∈ k ∧ z ≤ y)

/-- A witness triple is always valid in itself: `c ≰ u`, and the only
point of the triple outside `k` below `x` is `x` itself, which `c`
anchors. -/
theorem valid_in_self (t : WitnessTriple k) : t.IsValidIn t.carrier := by
  refine ⟨subset_rfl, ?_, ?_⟩
  · intro y hy hyk hyu
    rcases mem_carrier.mp hy with rfl | rfl | rfl
    · exact t.c_not_le_u hyu
    · exact t.x_notMem hyk
    · exact t.u_notMem hyk
  · intro y hy hyk hyx
    rcases mem_carrier.mp hy with rfl | rfl | rfl
    · exact (hyk t.c_mem).elim
    · exact ⟨t.c, t.c_mem_carrier, t.c_mem, t.c_lt_x.le⟩
    · exact (t.u_not_le_x hyx).elim

end WitnessTriple

/-- Every member of a finite set has an `S`-minimal point below it. -/
theorem exists_minimal_le_mem [Finite P] {S : Set P} {s : P} (hs : s ∈ S) :
    ∃ m, Minimal (· ∈ S) m ∧ m ≤ s := by
  haveI : Finite ↥S := Subtype.finite
  obtain ⟨m, hle, hmin⟩ :=
    Finite.exists_le_minimal (p := fun _ : ↥S => True) (a := ⟨s, hs⟩) trivial
  exact ⟨m.1, (isMin_subtype_iff m).mp (minimal_true.mp hmin),
    Subtype.coe_le_coe.mp hle⟩

/-- **The witness-triple theorem.**  `j_S` opens `k` iff `S` contains
a witness triple valid in `S`.  Equivalent to
`opens_subNucleus_iff_minimal`; the triple form makes the coarsest
observers visible as copies of Div12. -/
theorem opens_subNucleus_iff_witnessTriple [Finite P] (S : Set P)
    (k : LowerSet P) :
    Opens (subNucleus S) k ↔ ∃ t : WitnessTriple k, t.IsValidIn S := by
  rw [opens_subNucleus_iff_minimal]
  constructor
  · rintro ⟨⟨m, hm, hmk⟩, ⟨s, hsS, hsk, hs⟩⟩
    obtain ⟨c, hcMin, hcs⟩ := exists_minimal_le_mem hsS
    have hck : c ∈ k := hs c hcMin hcs
    have hclt : c < s := lt_of_le_of_ne hcs fun he => hsk (he ▸ hck)
    have hmns : ¬ m ≤ s := fun hms => hmk (hs m hm hms)
    have hcnm : ¬ c ≤ m := fun hcm =>
      hmk (by rw [le_antisymm (hm.le_of_le hcMin.prop hcm) hcm]; exact hck)
    refine ⟨⟨c, s, m, hck, hsk, hmk, hclt, hcnm, hmns⟩, ?_⟩
    refine ⟨?_, ?_, ?_⟩
    · intro y hy
      rcases WitnessTriple.mem_carrier.mp hy with rfl | rfl | rfl
      · exact hcMin.prop
      · exact hsS
      · exact hm.prop
    · intro y hyS hyk hyu
      exact hmk (by rw [le_antisymm (hm.le_of_le hyS hyu) hyu]; exact hyk)
    · intro y hyS hyk hys
      obtain ⟨m', hm'Min, hm'y⟩ := exists_minimal_le_mem hyS
      exact ⟨m', hm'Min.prop, hs m' hm'Min (hm'y.trans hys), hm'y⟩
  · rintro ⟨t, hcar, hnd, hnr⟩
    obtain ⟨m, hmMin, hmu⟩ := exists_minimal_le_mem (hcar t.u_mem_carrier)
    have hmk : m ∉ k := fun h => hnd m hmMin.prop h hmu
    refine ⟨⟨m, hmMin, hmk⟩, ⟨t.x, hcar t.x_mem_carrier, t.x_notMem, ?_⟩⟩
    intro m' hm'Min hm'x
    by_contra hm'k
    obtain ⟨z, hzS, hzk, hzm'⟩ := hnr m' hm'Min.prop hm'k hm'x
    exact hm'k (by rw [le_antisymm (hm'Min.le_of_le hzS hzm') hzm']; exact hzk)

/-- Every opening observer contains a sub-observer whose world is the
tritone lattice, with `k` as the tritone. -/
theorem exists_witnessTriple_subset [Finite P] {S : Set P} {k : LowerSet P}
    (h : Opens (subNucleus S) k) :
    ∃ t : WitnessTriple k, t.carrier ⊆ S ∧ Opens (subNucleus t.carrier) k := by
  obtain ⟨t, hv⟩ := (opens_subNucleus_iff_witnessTriple S k).mp h
  exact ⟨t, hv.1,
    (opens_subNucleus_iff_witnessTriple t.carrier k).mpr ⟨t, t.valid_in_self⟩⟩

/-- The coarsest observers that open `k` are exactly the witness
triples: no proper subset of a triple opens `k`. -/
theorem WitnessTriple.eq_of_subset_opens [Finite P] {k : LowerSet P}
    (t : WitnessTriple k)
    {T : Set P} (hT : T ⊆ t.carrier) (hopen : Opens (subNucleus T) k) :
    T = t.carrier := by
  obtain ⟨t', hv⟩ := (opens_subNucleus_iff_witnessTriple T k).mp hopen
  have hsub : t'.carrier ⊆ t.carrier := hv.1.trans hT
  have : t'.carrier = t.carrier :=
    Set.eq_of_subset_of_ncard_le hsub (by simp [t'.ncard_carrier, t.ncard_carrier])
  exact subset_antisymm hT (this ▸ hv.1)

/-- An inclusion-minimal opening observer is a witness triple. -/
theorem exists_witnessTriple_eq_carrier_of_minimal [Finite P]
    {S : Set P} {k : LowerSet P}
    (h : Opens (subNucleus S) k)
    (hmin : ∀ T ⊆ S, Opens (subNucleus T) k → T = S) :
    ∃ t : WitnessTriple k, S = t.carrier := by
  obtain ⟨t, hv⟩ := (opens_subNucleus_iff_witnessTriple S k).mp h
  have : t.carrier = S :=
    hmin t.carrier hv.1
      ((opens_subNucleus_iff_witnessTriple t.carrier k).mpr ⟨t, t.valid_in_self⟩)
  exact ⟨t, this.symm⟩

/-- **Positivity.**  Some observer opens `k` iff `P` contains a witness
triple. -/
theorem exists_opens_iff_exists_witnessTriple [Finite P] (k : LowerSet P) :
    (∃ S, Opens (subNucleus S) k) ↔ Nonempty (WitnessTriple k) := by
  constructor
  · rintro ⟨S, h⟩
    obtain ⟨t, _⟩ := (opens_subNucleus_iff_witnessTriple S k).mp h
    exact ⟨t⟩
  · rintro ⟨t⟩
    exact ⟨t.carrier,
      (opens_subNucleus_iff_witnessTriple t.carrier k).mpr ⟨t, t.valid_in_self⟩⟩

/-- The identity (full-resolution) observer opens `k` iff some witness
triple is unspoiled in `P`. -/
theorem opens_univ_iff_exists_valid [Finite P] (k : LowerSet P) :
    Opens (subNucleus Set.univ) k ↔ ∃ t : WitnessTriple k, t.IsValidIn Set.univ :=
  opens_subNucleus_iff_witnessTriple Set.univ k

/-- **Latency.**  `k` is latent — not ordinary at full resolution, yet
some observer opens it — iff `P` contains witness triples and every
one of them is spoiled in `P`. -/
theorem latent_iff_all_triples_spoiled [Finite P] (k : LowerSet P) :
    (¬ Opens (subNucleus Set.univ) k ∧ ∃ S, Opens (subNucleus S) k) ↔
      Nonempty (WitnessTriple k) ∧ ∀ t : WitnessTriple k, ¬ t.IsValidIn Set.univ := by
  rw [exists_opens_iff_exists_witnessTriple, opens_univ_iff_exists_valid, not_exists, and_comm]

end Criterion

/-! ## Non-convexity: the Div180 witness -/

/-- The exponent poset of Div180 = 2²·3²·5: two 2-chains and a point.
`e0 < e3`, `e1 < e4`, `e2` isolated.  Down-sets of this poset are the
divisors of 180; the kernel `6` is the down-set `{e0, e1}`. -/
inductive Div180Exp : Type
  | e0 | e1 | e2 | e3 | e4
  deriving DecidableEq, Repr

namespace Div180Exp

instance : Fintype Div180Exp :=
  ⟨{e0, e1, e2, e3, e4}, by intro x; cases x <;> decide⟩

def leb : Div180Exp → Div180Exp → Bool
  | e0, e0 => true
  | e0, e3 => true
  | e1, e1 => true
  | e1, e4 => true
  | e2, e2 => true
  | e3, e3 => true
  | e4, e4 => true
  | _,  _  => false

instance : LE Div180Exp := ⟨fun a b => leb a b = true⟩
instance : LT Div180Exp := ⟨fun a b => a ≤ b ∧ ¬ b ≤ a⟩

instance decLE : ∀ a b : Div180Exp, Decidable (a ≤ b) := fun a b => by
  show Decidable (leb a b = true); exact decEq _ _

instance : DecidableLE Div180Exp := decLE

instance : PartialOrder Div180Exp where
  le_refl := by decide
  le_trans := by decide
  le_antisymm := by decide
  lt_iff_le_not_ge := fun _ _ => Iff.rfl

/-- The kernel `6 = {e0, e1}`, as a lower set. -/
def six : LowerSet Div180Exp :=
  ⟨{x | x = e0 ∨ x = e1}, by
    intro a b hba ha
    revert hba ha
    revert a b
    decide⟩

theorem mem_six {x : Div180Exp} : x ∈ six ↔ x = e0 ∨ x = e1 := Iff.rfl

/-- `S₁ = {e0, e3, e4}`, `S₂ = S₁ ∪ {e1}`, `S₃ = P`. -/
def S₁ : Set Div180Exp := {x | x = e0 ∨ x = e3 ∨ x = e4}
def S₂ : Set Div180Exp := {x | x = e0 ∨ x = e1 ∨ x = e3 ∨ x = e4}
def S₃ : Set Div180Exp := Set.univ

theorem S₁_subset_S₂ : S₁ ⊆ S₂ := by
  intro x hx
  simp only [S₁, S₂, Set.mem_setOf_eq] at hx ⊢
  tauto

theorem S₂_subset_S₃ : S₂ ⊆ S₃ := fun _ _ => Set.mem_univ _

/-- The criterion's right-hand side, as a decidable proposition. -/
private def crit (S : Set Div180Exp) [DecidablePred (· ∈ S)] : Prop :=
  (∃ m, (m ∈ S ∧ ∀ y, y ∈ S → y ≤ m → m ≤ y) ∧ ¬ (m = e0 ∨ m = e1)) ∧
  (∃ s, s ∈ S ∧ ¬ (s = e0 ∨ s = e1) ∧
    ∀ m, (m ∈ S ∧ ∀ y, y ∈ S → y ≤ m → m ≤ y) → m ≤ s → (m = e0 ∨ m = e1))

private theorem opens_iff_crit (S : Set Div180Exp) [DecidablePred (· ∈ S)] :
    Opens (subNucleus S) six ↔ crit S := by
  rw [opens_subNucleus_iff_minimal]
  simp only [crit, Minimal, mem_six]

instance : DecidablePred (· ∈ S₁) := fun x => by unfold S₁; infer_instance
instance : DecidablePred (· ∈ S₂) := fun x => by unfold S₂; infer_instance
instance : DecidablePred (· ∈ S₃) := fun x => by unfold S₃; infer_instance

theorem opens_S₁ : Opens (subNucleus S₁) six := by
  rw [opens_iff_crit]; unfold crit S₁; decide

theorem not_opens_S₂ : ¬ Opens (subNucleus S₂) six := by
  rw [opens_iff_crit]; unfold crit S₂; decide

theorem opens_S₃ : Opens (subNucleus S₃) six := by
  rw [opens_iff_crit]; unfold crit S₃; decide

/-- **Apertures are not order-convex in the nucleus lattice.**  On
Div180 at kernel 6: `S₁ ⊆ S₂ ⊆ S₃`, the outer two open the kernel, the
middle one does not.  (`S₂` lowers the bottom: it adds `e1` beneath
`e4`.) -/
theorem aperture_not_convex_div180 :
    S₁ ⊆ S₂ ∧ S₂ ⊆ S₃ ∧
      Opens (subNucleus S₁) six ∧ ¬ Opens (subNucleus S₂) six ∧
      Opens (subNucleus S₃) six :=
  ⟨S₁_subset_S₂, S₂_subset_S₃, opens_S₁, not_opens_S₂, opens_S₃⟩

/-- The step that closes the four-fold is the step that lowers the
bottom: `j_{S₁} ⊥ ≠ j_{S₂} ⊥`. -/
theorem bot_S₁_ne_bot_S₂ : subNucleus S₁ ⊥ ≠ subNucleus S₂ ⊥ := by
  intro h
  have h1 : e1 ∈ subNucleus S₁ ⊥ := by
    rw [mem_subNucleus_bot_iff]; unfold S₁; decide
  have h2 : e1 ∉ subNucleus S₂ ⊥ := by
    rw [mem_subNucleus_bot_iff]; unfold S₂; decide
  exact h2 (h ▸ h1)

end Div180Exp

end FalseWork.Lattice
