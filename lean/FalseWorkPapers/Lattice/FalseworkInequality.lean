/-
# The falsework inequality

An observer's misperception of conemass is bounded, cone by cone, by
twice its relative phantom mass — and the bound is an identity on every
nonempty cone, so the constant 2 is tight.

Setup. `V` finite. `C u` is the (truncated) dependency cone of node
`u`. The conemass field is `mass C x = ∑_{u : x ∈ C u} 1/|C u|` —
exactly what the conemass tool computes (empty cones contribute
nothing; the `(0 : ℚ)⁻¹ = 0` convention makes this automatic).

An observer is any blur `J` with `C u ⊆ J u` for every `u`. Only
inflationarity is used: if `j` is a nucleus on the down-set algebra of
the dependency order (the observers of the Heyting-observer papers),
then `J u := j (C u)` qualifies, and `|J u| - |C u|` is precisely the
phantom mass of `u`'s cone under `j`. The observer's perceived load is
the conemass field of the blurred cones.

Results:

* `falsework_inequality` — the observer's total (L¹) misperception of
  the load field is at most `∑_u 2 · p_u / (|C u| + p_u)`, where
  `p_u = |J u| - |C u|` is the phantom mass on `u`'s cone.
* `sum_abs_err_eq` — per nonempty cone the bound holds with equality.
* `perfect_observer` — an observer with zero phantom mass on every
  cone perceives load exactly (a pocket of reducibility, structural
  version).
* `mass_conserved` — total mass equals the number of nonempty cones,
  for any cone assignment. Note this does NOT make conservation under
  blur automatic: an observer that inflates an empty cone to a
  nonempty one creates exactly one unit of mass (priced by the empty
  case of `sum_abs_err_le`).
* `mass_conserved_iff_dense` — conservation holds *if and only if* the
  observer preserves empty cones, i.e. is *dense* (`j ⊥ = ⊥` in
  nucleus language). Density is not merely sufficient: each empty cone
  inflated to a nonempty one adds exactly one unit of spurious load,
  so equality of totals forces density. For a dense observer, blur
  redistributes load but cannot create or destroy it: misperception
  is strictly about *where* load sits, never *how much* there is.
* `falsework_inequality_observer` — the main bound specialized to a
  single inflationary operator `Finset V → Finset V` applied to every
  cone, the literal shape of a Heyting observer acting on cones.

Remark (not formalized here): per cone, the blurred credit
distribution — uniform on `J (C u)` — is majorized by the true one —
uniform on `C u`. Observers can only flatten a cone's contribution to
the load field, never sharpen it. A Schur-flattening statement for the
full field is a candidate follow-up.
-/
import Mathlib.Tactic

open Finset

namespace Falsework

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- The conemass field of a cone assignment `C`. -/
def mass (C : V → Finset V) (x : V) : ℚ :=
  ∑ u, if x ∈ C u then ((C u).card : ℚ)⁻¹ else 0

/-- Per-cone credit error between the blurred field and the true one. -/
def err (C J : V → Finset V) (u x : V) : ℚ :=
  (if x ∈ J u then ((J u).card : ℚ)⁻¹ else 0) -
    (if x ∈ C u then ((C u).card : ℚ)⁻¹ else 0)

/-- On a nonempty cone the per-cone L¹ error is exactly
`2 (|J u| - |C u|) / |J u|`: the falsework constant 2 is tight. -/
lemma sum_abs_err_eq (C J : V → Finset V) (h : ∀ u, C u ⊆ J u) (u : V)
    (hC : (C u).Nonempty) :
    ∑ x, |err C J u x| =
      2 * (((J u).card : ℚ) - ((C u).card : ℚ)) / ((J u).card : ℚ) := by
  have hsub : C u ⊆ J u := h u
  have hcpos : 0 < (C u).card := card_pos.mpr hC
  have hjpos : 0 < (J u).card := lt_of_lt_of_le hcpos (card_le_card hsub)
  have hcq : (0 : ℚ) < ((C u).card : ℚ) := by exact_mod_cast hcpos
  have hjq : (0 : ℚ) < ((J u).card : ℚ) := by exact_mod_cast hjpos
  have hcj : ((C u).card : ℚ) ≤ ((J u).card : ℚ) := by
    exact_mod_cast card_le_card hsub
  have hinv : ((J u).card : ℚ)⁻¹ ≤ ((C u).card : ℚ)⁻¹ := by
    gcongr
  -- split the universe: outside J u, then J u \ C u, then C u
  have hzero : ∀ x ∈ univ \ J u, |err C J u x| = 0 := by
    intro x hx
    rw [mem_sdiff] at hx
    have hxJ : x ∉ J u := hx.2
    have hxC : x ∉ C u := fun hc => hxJ (hsub hc)
    simp [err, hxJ, hxC]
  have hphantom : ∀ x ∈ J u \ C u, |err C J u x| = ((J u).card : ℚ)⁻¹ := by
    intro x hx
    rw [mem_sdiff] at hx
    rw [err, if_pos hx.1, if_neg hx.2, sub_zero]
    exact abs_of_nonneg (by positivity)
  have hcore : ∀ x ∈ C u,
      |err C J u x| = ((C u).card : ℚ)⁻¹ - ((J u).card : ℚ)⁻¹ := by
    intro x hx
    rw [err, if_pos (hsub hx), if_pos hx,
      abs_of_nonpos (sub_nonpos.mpr hinv), neg_sub]
  calc ∑ x, |err C J u x|
      = ∑ x ∈ univ \ J u, |err C J u x| + ∑ x ∈ J u, |err C J u x| := by
        rw [sum_sdiff (subset_univ (J u))]
    _ = ∑ x ∈ J u, |err C J u x| := by
        rw [sum_eq_zero hzero, zero_add]
    _ = ∑ x ∈ J u \ C u, |err C J u x| + ∑ x ∈ C u, |err C J u x| := by
        rw [sum_sdiff hsub]
    _ = ((J u \ C u).card : ℚ) * ((J u).card : ℚ)⁻¹ +
          ((C u).card : ℚ) * (((C u).card : ℚ)⁻¹ - ((J u).card : ℚ)⁻¹) := by
        rw [sum_congr rfl hphantom, sum_congr rfl hcore,
          sum_const, sum_const, nsmul_eq_mul, nsmul_eq_mul]
    _ = 2 * (((J u).card : ℚ) - ((C u).card : ℚ)) / ((J u).card : ℚ) := by
        rw [card_sdiff, inter_eq_left.mpr hsub,
          Nat.cast_sub (card_le_card hsub)]
        have hc0 : ((C u).card : ℚ) ≠ 0 := ne_of_gt hcq
        have hj0 : ((J u).card : ℚ) ≠ 0 := ne_of_gt hjq
        field_simp
        ring

/-- Per-cone bound, all cases: at most `2 (|J u| - |C u|) / |J u|`. -/
lemma sum_abs_err_le (C J : V → Finset V) (h : ∀ u, C u ⊆ J u) (u : V) :
    ∑ x, |err C J u x| ≤
      2 * (((J u).card : ℚ) - ((C u).card : ℚ)) / ((J u).card : ℚ) := by
  rcases (C u).eq_empty_or_nonempty with hC | hC
  · -- empty true cone: the blur invents at most one unit of mass
    rcases (J u).eq_empty_or_nonempty with hJ | hJ
    · simp [err, hC, hJ]
    · have hjpos : 0 < (J u).card := card_pos.mpr hJ
      have hjq : (0 : ℚ) < ((J u).card : ℚ) := by exact_mod_cast hjpos
      have hval : ∀ x ∈ (univ : Finset V), |err C J u x| =
          if x ∈ J u then ((J u).card : ℚ)⁻¹ else 0 := by
        intro x _
        by_cases hx : x ∈ J u
        · rw [err, if_pos hx, hC, if_neg (notMem_empty x), sub_zero]
          exact abs_of_nonneg (by positivity)
        · rw [err, if_neg hx, hC, if_neg (notMem_empty x), sub_zero]
          exact abs_zero
      rw [sum_congr rfl hval, sum_ite_mem, univ_inter, sum_const, nsmul_eq_mul,
        mul_inv_cancel₀ (ne_of_gt hjq), hC]
      simp only [card_empty, Nat.cast_zero, sub_zero]
      rw [mul_div_assoc, div_self (ne_of_gt hjq), mul_one]
      norm_num
  · exact le_of_eq (sum_abs_err_eq C J h u hC)

/-- **The falsework inequality.** For any observer `J` blurring the
cones `C` outward (`C u ⊆ J u` — inflationarity, the nucleus axiom),
the total misperception of the conemass load field is bounded by the
sum over cones of twice the relative phantom mass:

`‖mass J − mass C‖₁ ≤ ∑_u 2 · p_u / (|C u| + p_u)`,

where `p_u = |J u| − |C u|`. What an observer can perceive of a
structure's load is bounded by its blur. -/
theorem falsework_inequality (C J : V → Finset V) (h : ∀ u, C u ⊆ J u) :
    ∑ x, |mass J x - mass C x| ≤
      ∑ u, 2 * (((J u).card : ℚ) - ((C u).card : ℚ)) / ((J u).card : ℚ) := by
  have hdecomp : ∀ x, mass J x - mass C x = ∑ u, err C J u x := by
    intro x
    rw [mass, mass, ← sum_sub_distrib]
    rfl
  calc ∑ x, |mass J x - mass C x|
      = ∑ x, |∑ u, err C J u x| := by
        exact sum_congr rfl fun x _ => by rw [hdecomp]
    _ ≤ ∑ x, ∑ u, |err C J u x| :=
        sum_le_sum fun x _ => abs_sum_le_sum_abs _ _
    _ = ∑ u, ∑ x, |err C J u x| := sum_comm
    _ ≤ _ := sum_le_sum fun u _ => sum_abs_err_le C J h u

/-- Zero phantom mass on every cone means the observer perceives load
exactly: a pocket of reducibility, structural version. -/
theorem perfect_observer (C J : V → Finset V) (h : ∀ u, J u = C u) :
    mass J = mass C := by
  funext x
  unfold mass
  exact sum_congr rfl fun u _ => by rw [h u]

/-- Total conemass equals the number of nonempty cones. (Conservation
under blur is NOT automatic from this: inflating an empty cone to a
nonempty one creates one unit of mass. See `mass_conserved_of_dense`.) -/
theorem mass_conserved (C : V → Finset V) :
    ∑ x, mass C x = (((univ : Finset V).filter fun u => (C u).Nonempty).card : ℚ) := by
  unfold mass
  rw [sum_comm, ← Finset.sum_boole]
  refine sum_congr rfl fun u _ => ?_
  rcases (C u).eq_empty_or_nonempty with hC | hC
  · simp [hC]
  · have hcpos : 0 < (C u).card := card_pos.mpr hC
    have hcq : ((C u).card : ℚ) ≠ 0 := by
      exact_mod_cast Nat.pos_iff_ne_zero.mp hcpos
    rw [sum_ite_mem, univ_inter, sum_const, nsmul_eq_mul,
      mul_inv_cancel₀ hcq, if_pos hC]

/-- **Conservation is characterized by density.** An inflationary blur
conserves total load *if and only if* it preserves empty cones — a
*dense* observer, `j ⊥ = ⊥` in nucleus language. Dense observers can
only move mass; non-dense observers mint exactly one unit per inflated
empty cone, so equality of totals forces density. -/
theorem mass_conserved_iff_dense (C J : V → Finset V) (h : ∀ u, C u ⊆ J u) :
    (∑ x, mass J x = ∑ x, mass C x) ↔ ∀ u, C u = ∅ → J u = ∅ := by
  have hsubF : ((univ : Finset V).filter fun u => (C u).Nonempty) ⊆
      (univ : Finset V).filter fun u => (J u).Nonempty := by
    intro v hv
    rw [mem_filter] at hv ⊢
    obtain ⟨a, ha⟩ := hv.2
    exact ⟨hv.1, a, h v ha⟩
  constructor
  · intro heq u hCu
    rw [mass_conserved, mass_conserved, Nat.cast_inj] at heq
    have hFeq := eq_of_subset_of_card_le hsubF (le_of_eq heq)
    by_contra hJne
    have hu : u ∈ (univ : Finset V).filter fun u => (C u).Nonempty := by
      rw [hFeq, mem_filter]
      exact ⟨mem_univ u, nonempty_iff_ne_empty.mpr hJne⟩
    have := (mem_filter.mp hu).2
    rw [hCu] at this
    exact not_nonempty_empty this
  · intro hd
    rw [mass_conserved, mass_conserved, Nat.cast_inj]
    have hset : ((univ : Finset V).filter fun u => (J u).Nonempty) =
        (univ : Finset V).filter fun u => (C u).Nonempty := by
      ext u
      simp only [mem_filter, mem_univ, true_and]
      constructor
      · intro hJ
        by_contra hC
        rw [not_nonempty_iff_eq_empty] at hC
        rw [hd u hC] at hJ
        exact not_nonempty_empty hJ
      · intro hC
        obtain ⟨a, ha⟩ := hC
        exact ⟨a, h u ha⟩
    rw [hset]

/-- The falsework inequality in observer form: a single inflationary
operator on `Finset V` (the shape of a Heyting observer acting on
cones) applied to every cone. -/
theorem falsework_inequality_observer (C : V → Finset V)
    (J : Finset V → Finset V) (hJ : ∀ s, s ⊆ J s) :
    ∑ x, |mass (fun u => J (C u)) x - mass C x| ≤
      ∑ u, 2 * (((J (C u)).card : ℚ) - ((C u).card : ℚ)) /
        ((J (C u)).card : ℚ) :=
  falsework_inequality C (fun u => J (C u)) fun u => hJ (C u)

end Falsework
