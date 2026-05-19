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
theorem residual_E1 (R P Q : Subobject X) (_h : R ≤ residual P Q) :
    R.arrow ≫ χ (P ⊓ Q).arrow = R.arrow ≫ χ P.arrow := by
  -- Phase 2:
  --   `_h : R ≤ residual P Q` ⇒ `R.arrow` factors through `(residual P Q).arrow`.
  --   `(residual P Q).arrow ≃ equalizer.ι (χ (P ⊓ Q).arrow) (χ P.arrow)`
  --     via `Subobject.underlyingIso` and `Subobject.mk_arrow`.
  --   Postcompose the factorisation with `equalizer.condition`.
  -- Mathlib hooks: `Subobject.le_def`, `Subobject.factorThru_arrow`,
  --   `Subobject.underlyingIso_arrow`, `equalizer.condition`.
  sorry

/-- **E2.** Equal characteristic morphisms (after precomposing with
`R.arrow`) yield equal pullbacks in `Subobject (R : C)`. -/
theorem residual_E2 (R P Q : Subobject X)
    (_h : R.arrow ≫ χ (P ⊓ Q).arrow = R.arrow ≫ χ P.arrow) :
    (Subobject.pullback R.arrow).obj (P ⊓ Q) =
      (Subobject.pullback R.arrow).obj P := by
  -- Phase 2:
  --   The identity `(pullback R.arrow).obj S = (pullback (R.arrow ≫ χ S.arrow)).obj truth_as_sub`
  --     follows from pullback pasting (Beck-Chevalley for the classifier).
  --   Apply with `S = P ⊓ Q` and `S = P`; equality of LHSs from `_h` forces equality of RHSs.
  -- Mathlib hooks: `Subobject.Classifier.pullback_χ_obj_mk_truth`,
  --   `Subobject.pullback_comp`, classifier-uniqueness argument.
  sorry

/-- **E3.** Pullback equality
`pullback R.arrow (P ⊓ Q) = pullback R.arrow P` (in `Subobject (R : C)`)
gives `R ⊓ P ≤ Q` (in `Subobject X`). -/
theorem residual_E3 (R P Q : Subobject X)
    (_h : (Subobject.pullback R.arrow).obj (P ⊓ Q) =
          (Subobject.pullback R.arrow).obj P) :
    R ⊓ P ≤ Q := by
  -- Phase 2:
  --   `inf_pullback`: pullback R.arrow (P ⊓ Q) = pullback R.arrow P ⊓ pullback R.arrow Q.
  --   With `_h`: pullback R.arrow P = pullback R.arrow P ⊓ pullback R.arrow Q,
  --     hence `pullback R.arrow P ≤ pullback R.arrow Q` (via `inf_eq_left`).
  --   Apply `map R.arrow` and `inf_eq_map_pullback` + `pullback_self R.arrow`
  --     to lift to `R ⊓ P ≤ R ⊓ Q` in Subobject X; then `inf_le_right` gives `≤ Q`.
  -- Mathlib hooks: `Subobject.inf_pullback`, `Subobject.inf_eq_map_pullback`,
  --   `Subobject.pullback_self`, `inf_eq_left`, transitivity with `inf_le_right`.
  sorry

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
theorem residual_I2 (R P Q : Subobject X) (_h : R ⊓ P ≤ Q) :
    (Subobject.pullback R.arrow).obj P =
      (Subobject.pullback R.arrow).obj (P ⊓ Q) := by
  -- Phase 2:
  --   From `_h`: `R ⊓ P = R ⊓ P ⊓ Q` in Subobject X (i.e., `R ⊓ P ≤ Q ↔ R ⊓ P = R ⊓ P ⊓ Q`,
  --     via `inf_eq_left.mpr`).
  --   Pull back along `R.arrow`: `pullback R.arrow (R ⊓ P) = pullback R.arrow (R ⊓ P ⊓ Q)`.
  --   Apply `inf_pullback` repeatedly + `pullback_self R.arrow` (so
  --     `pullback R.arrow R = ⊤` in `Subobject (R : C)`):
  --     LHS = ⊤ ⊓ pullback R.arrow P = pullback R.arrow P
  --     RHS = ⊤ ⊓ pullback R.arrow P ⊓ pullback R.arrow Q = pullback R.arrow (P ⊓ Q) [by I1].
  -- Mathlib hooks: `inf_eq_left.mpr` / `left_eq_inf`, `Subobject.inf_pullback`,
  --   `Subobject.pullback_self`, `Subobject.mk_arrow`, `residual_I1`.
  sorry

/-- **I3.** Pullback equality
`pullback R.arrow P = pullback R.arrow (P ⊓ Q)` (in `Subobject (R : C)`)
forces `R.arrow ≫ χ P.arrow = R.arrow ≫ χ (P ⊓ Q).arrow` (classifier
uniqueness), hence `R.arrow` factors through `equalizer.ι (χ (P ⊓ Q).arrow)
(χ P.arrow)` = the underlying mono of `residual P Q`. -/
theorem residual_I3 (R P Q : Subobject X)
    (_h : (Subobject.pullback R.arrow).obj P =
          (Subobject.pullback R.arrow).obj (P ⊓ Q)) :
    R ≤ residual P Q := by
  -- Phase 2:
  --   From `_h` and classifier uniqueness (`χ` injects on `Subobject` via the
  --     representable bijection), derive
  --     R.arrow ≫ χ P.arrow = R.arrow ≫ χ (P ⊓ Q).arrow.
  --   Hence R.arrow factors through `equalizer.ι (χ (P ⊓ Q).arrow) (χ P.arrow)`
  --     via `equalizer.lift R.arrow ‹eq›`.
  --   That factorisation realises `R ≤ Subobject.mk (equalizer.ι ...) = residual P Q`
  --     via `Subobject.mk_le_mk_of_comm` (or `Subobject.le_of_comm`).
  -- Mathlib hooks: `Subobject.Classifier.pullback_χ_obj_mk_truth_arrow` (the
  --   inverse of the `χ`-pullback identity used in E2), `equalizer.lift`,
  --   `equalizer.lift_ι`, `Subobject.mk_arrow`, `Subobject.le_of_comm`.
  sorry

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
