/-
Copyright (c) 2026 Chris Brink.
Released under the same license as the rest of the FalseWork Papers.

Authors: Chris Brink (FalseWork)

# Heyting algebra on `Subobject X` for elementary topoi

This file closes the upstream Mathlib gap recorded in `lean/HEYTING-GAP.md`:
under the hypothesis bundle for an elementary topos, every subobject
lattice `Subobject X` carries a canonical Heyting-algebra structure, with
implication given by Mac Lane–Moerdijk *Sheaves in Geometry and Logic*
IV.6 Proposition 2.

## The construction

For subobjects `P Q : Subobject X` of an object `X` in `C`, the residual
`P ⇒ Q` is defined as the equalizer of the two characteristic morphisms
`χ (P ⊓ Q).arrow, χ P.arrow : X ⇉ Ω`:

  P ⇒ Q := Sub.mk (eq.ι (χ (P ⊓ Q).arrow) (χ P.arrow))

Equivalently: `P ⇒ Q` is the largest subobject of `X` on which `P ⊓ Q`
and `P` are classified by the same morphism into `Ω` — operationally,
"the part of `X` where `P` implies `Q`."

The Heyting adjunction `R ≤ (P ⇒ Q) ⇔ R ⊓ P ≤ Q` decomposes into six
bridging lemmas:

* **Elimination (⇒)**: `R ≤ (P ⇒ Q) → R ⊓ P ≤ Q`.
  - `residual_E1`: `R ≤ (P ⇒ Q) → R.arrow ≫ χ(P ⊓ Q).arrow = R.arrow ≫ χ P.arrow`.
  - `residual_E2`: that equality → equal pullbacks in `Subobject (R : C)`.
  - `residual_E3`: that pullback identity → `R ⊓ P ≤ Q` in `Subobject X`.

* **Introduction (⇐)**: `R ⊓ P ≤ Q → R ≤ (P ⇒ Q)`.
  - `residual_I1`: pullback distributes over `⊓` (direct from `Subobject.inf_pullback`).
  - `residual_I2`: `R ⊓ P ≤ Q → pullback R.arrow P = pullback R.arrow (P ⊓ Q)`.
  - `residual_I3`: that pullback equality → `R ≤ (P ⇒ Q)` via classifier uniqueness.

## Hypothesis bundle

```
[HasSubobjectClassifier C] [HasPullbacks C] [HasEqualizers C]
[HasInitial C] [HasImages C] [HasBinaryCoproducts C] [InitialMonoClass C]
```

These together are entailed by `C` being an elementary topos. The
hypotheses break down as:
* Classifier: `HasSubobjectClassifier C` for `χ : (U ⟶ X) → (X ⟶ Ω)`.
* Meet structure: `HasPullbacks C` for `Subobject.SemilatticeInf` plus
  `OrderTop`, `HasInitial C` + `InitialMonoClass C` for `OrderBot`.
* Join structure: `HasImages C` + `HasBinaryCoproducts C` for
  `Subobject.SemilatticeSup`.
* Residual: `HasEqualizers C` for the equalizer construction itself.

## Phase status

* **Phase 1** (this draft): residual definition, `HImp`/`Compl` field
  provision, Galois-connection signature assembled from the six bridging
  lemmas, `HeytingAlgebra` instance assembly. `residual_I1` proven
  in-place; five sorrys remain on `residual_E1`, `residual_E2`,
  `residual_E3`, `residual_I2`, `residual_I3`.
* **Phase 2**: discharge the five remaining sorrys.
* **Phase 3**: wire the instance into `Positions/{Distribution,
  Exploitation, Refusal, Partition}.lean`.
* **Phase 4**: refactor for upstream Mathlib PR — parameterize on
  chosen classifier, priority discipline, Mathlib-style doc.

## Cross-reference

* `lean/HEYTING-GAP.md` — the upstream-Mathlib gap this file closes,
  with context, alternative paths, and engagement record.
* `lean/PHASE-0-DECISIONS.md` — the three semantic decisions on which
  this construction sits; in particular Decision 2 fixes the
  `[∀ Y : C, HeytingAlgebra (Subobject Y)]` binder shape in the cell
  files, which this instance satisfies universally.
* Mac Lane & Moerdijk, *Sheaves in Geometry and Logic*, IV.6 Prop 2.
-/

import Mathlib.CategoryTheory.Subobject.Classifier.Defs
import Mathlib.CategoryTheory.Subobject.Lattice
import Mathlib.CategoryTheory.Limits.Shapes.Equalizers
import Mathlib.Order.Heyting.Basic

namespace FalseWork.Heyting

open CategoryTheory CategoryTheory.Limits HasSubobjectClassifier

universe v u

variable {C : Type u} [Category.{v} C]
  [HasSubobjectClassifier C] [HasPullbacks C] [HasEqualizers C]
  [HasInitial C] [HasImages C] [HasBinaryCoproducts C]
  [InitialMonoClass C]

variable {X : C}

/-! ## The residual `P ⇒ Q` -/

/-- The Heyting residual of two subobjects of `X`.

Defined as the equalizer of the characteristic morphisms of `P ⊓ Q`
and `P`, viewed as parallel arrows `X ⇉ Ω`:

  residual P Q := Subobject.mk (equalizer.ι (χ (P ⊓ Q).arrow) (χ P.arrow))

The Galois connection `R ≤ residual P Q ↔ R ⊓ P ≤ Q` is
`le_residual_iff_inf_le` below; this is the load-bearing fact making
`residual` the right adjoint to `(· ⊓ P)`, hence the Heyting
implication. -/
noncomputable def residual (P Q : Subobject X) : Subobject X :=
  Subobject.mk (equalizer.ι (χ (P ⊓ Q).arrow) (χ P.arrow))

/-! ## Bridging lemmas: elimination half (`R ≤ residual P Q → R ⊓ P ≤ Q`) -/

/-- **E1.** If `R ≤ residual P Q`, then `R.arrow` equalizes the two
characteristic morphisms `χ (P ⊓ Q).arrow` and `χ P.arrow`. -/
theorem residual_E1 (R P Q : Subobject X) (h : R ≤ residual P Q) :
    R.arrow ≫ χ (P ⊓ Q).arrow = R.arrow ≫ χ P.arrow := by
  -- Step 1: `R ≤ residual P Q` ⇒ R factors through `residual P Q` =
  -- `Subobject.mk (equalizer.ι (χ (P ⊓ Q).arrow) (χ P.arrow))`.
  have hfac : (residual P Q).Factors R.arrow :=
    Subobject.factors_of_le R.arrow h (Subobject.factors_self R)
  -- Step 2: Unfold the residual to expose the equalizer-based mono.
  -- `(Subobject.mk f).Factors g` is definitionally `∃ h, h ≫ f = g`
  -- (via `Subobject.mk_factors_iff = Iff.rfl`), so `obtain` destructures.
  change (Subobject.mk (equalizer.ι (χ (P ⊓ Q).arrow) (χ P.arrow))).Factors R.arrow at hfac
  obtain ⟨g, hg⟩ := hfac
  -- `hg` is displayed by Lean with the `MonoOver.mk _ .arrow` wrapper still
  -- visible; coerce it via defeq to the underlying `equalizer.ι` form so
  -- `equalizer.condition` can fire below.
  change g ≫ equalizer.ι (χ (P ⊓ Q).arrow) (χ P.arrow) = R.arrow at hg
  -- Step 3: Substitute `R.arrow = g ≫ equalizer.ι _ _`, reassociate, and
  -- close. The `rw [equalizer.condition ...]` form fails here because the
  -- `[HasEqualizer ...]` instance synthesized in the lemma application
  -- ends up syntactically distinct from the one in `hg` (even though
  -- propositionally equal). `congr 1` sidesteps this by peeling off the
  -- outer `g ≫` and letting term-mode `equalizer.condition _ _` close
  -- the inner equation with the instance in scope.
  rw [← hg, Category.assoc, Category.assoc]
  congr 1
  exact equalizer.condition _ _

/-- **E2.** Equal characteristic morphisms (after precomposing with
`R.arrow`) yield equal pullbacks in `Subobject (R : C)`. -/
theorem residual_E2 (R P Q : Subobject X)
    (h : R.arrow ≫ χ (P ⊓ Q).arrow = R.arrow ≫ χ P.arrow) :
    (Subobject.pullback R.arrow).obj (P ⊓ Q) =
      (Subobject.pullback R.arrow).obj P := by
  -- Strategy (Beck-Chevalley for the classifier): every subobject `S` of `X`
  -- is recovered as `(pullback (χ S.arrow)).obj truth_as_subobject` (this is
  -- `pullback_χ_obj_mk_truth` + `mk_arrow`). Composing with `pullback_comp`,
  --   `(pullback R.arrow).obj S = (pullback (R.arrow ≫ χ S.arrow)).obj truth_as_subobject`.
  -- The hypothesis `h` then forces the two right-hand sides equal.
  -- Bind the chosen classifier explicitly so `pullback_χ_obj_mk_truth` (stated
  -- for `𝒞 : Classifier C`) unifies cleanly with `HasSubobjectClassifier.χ`,
  -- which is definitionally `𝒞.χ` (cf. `Classifier/Defs.lean:191`).  The type
  -- annotation on `𝒞` is required: `HasSubobjectClassifier.exists_classifier`
  -- otherwise leaves `C` as an unsolvable instance-resolution metavariable.
  set 𝒞 : Subobject.Classifier C :=
    HasSubobjectClassifier.exists_classifier.some with h𝒞
  -- Re-cast `h` against `𝒞.χ` to match the rewrite shape below.  This is just
  -- a defeq retype; `χ` and `𝒞.χ` unfold to the same term.
  have h' : R.arrow ≫ 𝒞.χ (P ⊓ Q).arrow = R.arrow ≫ 𝒞.χ P.arrow := h
  -- The key Beck-Chevalley identity.
  have key : ∀ (S : Subobject X),
      (Subobject.pullback R.arrow).obj S =
        (Subobject.pullback (R.arrow ≫ 𝒞.χ S.arrow)).obj 𝒞.truth_as_subobject := by
    intro S
    simp only [Subobject.pullback_comp,
               Subobject.Classifier.pullback_χ_obj_mk_truth, Subobject.mk_arrow]
  rw [key (P ⊓ Q), key P, h']

/-- **E3.** Pullback equality
`pullback R.arrow (P ⊓ Q) = pullback R.arrow P` (in `Subobject (R : C)`)
gives `R ⊓ P ≤ Q` (in `Subobject X`). -/
theorem residual_E3 (R P Q : Subobject X)
    (h : (Subobject.pullback R.arrow).obj (P ⊓ Q) =
         (Subobject.pullback R.arrow).obj P) :
    R ⊓ P ≤ Q := by
  -- Step 1: Unfold `(P ⊓ Q)` via `Subobject.inf_pullback` (this is the lemma
  -- `residual_I1` cites; can't reference `residual_I1` here because E3 is
  -- declared before I1 in file order) to get
  -- `pullback R.arrow P ⊓ pullback R.arrow Q = pullback R.arrow P` in `h`.
  rw [Subobject.inf_pullback] at h
  -- Step 2: From the meet equality, extract
  -- `pullback R.arrow P ≤ pullback R.arrow Q`.
  have hPQ : (Subobject.pullback R.arrow).obj P ≤ (Subobject.pullback R.arrow).obj Q :=
    inf_eq_left.mp h
  -- Step 3: Lift via `inf_eq_map_pullback` and functoriality of
  -- `Subobject.map R.arrow` (a functor between thin categories, hence
  -- order-preserving on its objects).
  have hRP_RQ : R ⊓ P ≤ R ⊓ Q := by
    rw [Subobject.inf_eq_map_pullback R P, Subobject.inf_eq_map_pullback R Q]
    exact leOfHom ((Subobject.map R.arrow).map (homOfLE hPQ))
  -- Step 4: `R ⊓ Q ≤ Q` by `inf_le_right`; compose.
  exact hRP_RQ.trans inf_le_right

/-! ## Bridging lemmas: introduction half (`R ⊓ P ≤ Q → R ≤ residual P Q`) -/

/-- **I1.** Pullback distributes over meet. Direct from
`Subobject.inf_pullback`. (Proven in-place; the only one of the six
that requires no Phase-2 work.) -/
theorem residual_I1 (R P Q : Subobject X) :
    (Subobject.pullback R.arrow).obj (P ⊓ Q) =
      (Subobject.pullback R.arrow).obj P ⊓
        (Subobject.pullback R.arrow).obj Q :=
  Subobject.inf_pullback _ _ _

/-- **I2.** `R ⊓ P ≤ Q` gives the pullback equality
`pullback R.arrow P = pullback R.arrow (P ⊓ Q)` in `Subobject (R : C)`. -/
theorem residual_I2 (R P Q : Subobject X) (h : R ⊓ P ≤ Q) :
    (Subobject.pullback R.arrow).obj P =
      (Subobject.pullback R.arrow).obj (P ⊓ Q) := by
  -- Step 1: `(Subobject.pullback R.arrow).obj R = ⊤` in `Subobject (R : C)`.
  -- (`Subobject.pullback_self` gives the `mk`-form; `mk_arrow` folds it back.)
  have hR : (Subobject.pullback R.arrow).obj R = ⊤ := by
    have hps := Subobject.pullback_self R.arrow
    rwa [Subobject.mk_arrow] at hps
  -- Step 2: From `h : R ⊓ P ≤ Q`, derive `R ⊓ P = (R ⊓ P) ⊓ Q`.
  have h1 : R ⊓ P = (R ⊓ P) ⊓ Q := (inf_eq_left.mpr h).symm
  -- Step 3: Apply the pullback functor to `h1` (via `congrArg` rather than
  -- `rw [h1]`, since the latter would rewrite `R ⊓ P` on both sides of the
  -- target equation and leave a `Q ⊓ Q = Q` residue). Then unfold via
  -- `inf_pullback` and collapse `pullback R.arrow R = ⊤`, `⊤ ⊓ _ = _`.
  have h2 : (Subobject.pullback R.arrow).obj (R ⊓ P) =
            (Subobject.pullback R.arrow).obj ((R ⊓ P) ⊓ Q) :=
    congrArg (Subobject.pullback R.arrow).obj h1
  simp only [Subobject.inf_pullback, hR, top_inf_eq] at h2
  -- `h2 : pullback R.arrow P = pullback R.arrow P ⊓ pullback R.arrow Q`.
  -- Convert the goal's RHS via `residual_I1`.
  rw [residual_I1]
  exact h2

/-- **I3.** Pullback equality
`pullback R.arrow P = pullback R.arrow (P ⊓ Q)` (in `Subobject (R : C)`)
forces `R.arrow ≫ χ P.arrow = R.arrow ≫ χ (P ⊓ Q).arrow` (classifier
uniqueness), hence `R.arrow` factors through `equalizer.ι (χ (P ⊓ Q).arrow)
(χ P.arrow)` = the underlying mono of `residual P Q`. -/
theorem residual_I3 (R P Q : Subobject X)
    (h : (Subobject.pullback R.arrow).obj P =
         (Subobject.pullback R.arrow).obj (P ⊓ Q)) :
    R ≤ residual P Q := by
  -- Strategy: invert the Beck-Chevalley argument from E2 to extract the
  -- characteristic-morphism equality, then use `equalizer.lift` to factor
  -- `R.arrow` through the equalizer underlying `residual P Q`.
  -- (The type annotation on `𝒞` is required — see the same `set` in E2.)
  set 𝒞 : Subobject.Classifier C :=
    HasSubobjectClassifier.exists_classifier.some with h𝒞
  -- Step 1: Reverse the χ → pullback identity to recover the χ equality.
  have hchi : R.arrow ≫ χ (P ⊓ Q).arrow = R.arrow ≫ χ P.arrow := by
    have key : ∀ (S : Subobject X),
        (Subobject.pullback R.arrow).obj S =
          (Subobject.pullback (R.arrow ≫ 𝒞.χ S.arrow)).obj 𝒞.truth_as_subobject := by
      intro S
      simp only [Subobject.pullback_comp,
                 Subobject.Classifier.pullback_χ_obj_mk_truth, Subobject.mk_arrow]
    -- Translate `h` to the Beck-Chevalley side.
    have hpb : (Subobject.pullback (R.arrow ≫ 𝒞.χ P.arrow)).obj 𝒞.truth_as_subobject =
               (Subobject.pullback (R.arrow ≫ 𝒞.χ (P ⊓ Q).arrow)).obj 𝒞.truth_as_subobject := by
      rw [← key P, ← key (P ⊓ Q)]; exact h
    -- Apply `𝒞.χ ∘ (·).arrow` to both sides; that operation undoes
    -- `(pullback ·).obj 𝒞.truth_as_subobject` via `χ_pullback_obj_mk_truth_arrow`.
    -- Spell the resulting type explicitly so `congrArg`'s lambda binder type
    -- is fixed before elaboration of `hpb` — without this, Lean leaves the
    -- domain of the lambda as an unsolvable metavar (the pullbacks live in
    -- `Subobject R.underlying`, not `Subobject X`).
    have h2 :
        𝒞.χ ((Subobject.pullback (R.arrow ≫ 𝒞.χ P.arrow)).obj
              𝒞.truth_as_subobject).arrow =
        𝒞.χ ((Subobject.pullback (R.arrow ≫ 𝒞.χ (P ⊓ Q).arrow)).obj
              𝒞.truth_as_subobject).arrow :=
      congrArg (fun S => 𝒞.χ S.arrow) hpb
    -- `χ_pullback_obj_mk_truth_arrow` is `@[simp]`, so it fires forward.
    simp only [Subobject.Classifier.χ_pullback_obj_mk_truth_arrow] at h2
    -- `h2 : R.arrow ≫ 𝒞.χ P.arrow = R.arrow ≫ 𝒞.χ (P ⊓ Q).arrow`, defeq to the
    -- `HasSubobjectClassifier.χ` form the goal demands.
    exact h2.symm
  -- Step 2: `R.arrow` factors through `equalizer.ι (χ (P ⊓ Q).arrow) (χ P.arrow)`
  -- via `equalizer.lift`; that factorisation realises `R ≤ residual P Q`
  -- through `Subobject.le_mk_of_comm` (recall `residual P Q := mk (equalizer.ι _ _)`).
  exact Subobject.le_mk_of_comm (equalizer.lift R.arrow hchi)
          (equalizer.lift_ι R.arrow hchi)

/-! ## Galois connection: `R ≤ (P ⇒ Q) ↔ R ⊓ P ≤ Q` -/

/-- **The load-bearing identity.** `residual` is the right adjoint to
`(· ⊓ P)`, i.e., a Galois connection holds:
`R ≤ residual P Q ↔ R ⊓ P ≤ Q`.

Assembled from the six bridging lemmas: elimination = E3 ∘ E2 ∘ E1,
introduction = I3 ∘ I2 (with I1 used inside I2 and I3). -/
theorem le_residual_iff_inf_le (R P Q : Subobject X) :
    R ≤ residual P Q ↔ R ⊓ P ≤ Q :=
  ⟨fun h => residual_E3 R P Q (residual_E2 R P Q (residual_E1 R P Q h)),
   fun h => residual_I3 R P Q (residual_I2 R P Q h)⟩

/-! ## The `HeytingAlgebra` instance -/

/-- **The instance.** `Subobject X` carries a canonical Heyting-algebra
structure when `C` has a subobject classifier, equalizers, and the
standard limit/colimit data for the existing semilattice/order
instances on `Subobject X`.

Implication is the residual `residual P Q`; pseudo-complement is
`residual P ⊥`. Distributivity, De Morgan, and the strict containment
`a ≤ aᶜᶜ` fall out as theorems of the `HeytingAlgebra` typeclass —
they are not assumed.

Discharges the upstream Mathlib gap documented in
`lean/HEYTING-GAP.md`. -/
noncomputable instance heytingAlgebra : HeytingAlgebra (Subobject X) :=
  { Subobject.semilatticeInf, Subobject.semilatticeSup,
    Subobject.orderTop, Subobject.orderBot with
    himp := residual
    compl := fun P => residual P ⊥
    le_himp_iff := le_residual_iff_inf_le
    himp_bot := fun _ => rfl }

end FalseWork.Heyting
