/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# The topos-level kernel trace comes apart from the tritone nucleus at `1`

This file records the result of the **trace check** demanded before attempting
to lift the tritone nucleus to a non-trivial *distinction structure on the music
topos* `Set^{Pᵒᵖ}` (item (ii) of `connecting-the-spine.md` §5.1a): construct the
sheafification monad of the tritone Lawvere–Tierney topology as an endofunctor
`D` on `MusicTopos`, and feed it to `four_position_partition` in place of
`trivialDistinction`, hoping all four cells become inhabited at the tritone
kernel.

**The check returns negative, and this file proves why.**

## The obstruction (`[K]`)

The four-position kernel is `kernelImage Δ Y = Im(η.app Y) ⊆ D Y` — the *image
of the unit*, not the value of a closure operator on `Sub(Y)`.  And:

`kernelImage_eq_top_of_isIso_unit`: **whenever the unit `η.app Y` is an
isomorphism, `kernelImage Δ Y = ⊤`** (the proof is the one already used in
`Infrastructure.trivialized_implies_isInfrastructure`).  By
`four_position_partition`, the partition at such a `Y` then degenerates to
Infrastructure-only — identically to `trivialDistinction`.

Now the carrier the musical reading needs is the **terminal** object `1`
(`Sub_{Set^{Pᵒᵖ}}(1) ≅ Div12`, item (i), `MusicToposSub.lean`).  For *any*
reflective localization — in particular *any* sheafification monad — the
terminal presheaf is already a sheaf, so the reflection unit `η.app 1 : 1 → D 1`
is an isomorphism (classical, Mac Lane–Moerdijk III.5 / the reflector is the
identity on the subcategory).  Hence

```
  kernelImage (sheafificationDistinction) 1 = ⊤ ,
```

while the tritone nucleus value is `⟨6⟩ ≠ ⊤` (and indeed `⟨6⟩ᶜ = ⊥`,
`music_anchor_witness`).  **The lattice-level nucleus and the topos-level
`Im(η)` kernel come apart exactly at `1`** — the place the user flagged as where
"the lattice-level result and the topos-level result could come apart."

## What this means for the program (honest boundary)

* The non-degenerate, musically-loaded four-position partition with the tritone
  as a non-regular kernel is the **lattice-level theorem**
  `lattice_four_position_partition` on `Div12` (`[K]`, unchanged), and item (i)
  now identifies that lattice *with the topos's own* `Sub_{Set^{Pᵒᵖ}}(1)` — so
  the tritone partition already lives on a genuine topos subobject lattice, with
  its cells mapped to the named pitch-class objects of `Div12`.
* What does **not** lift is the encoding of that nucleus as the `Im(η)` kernel
  of an endofunctor-monad on the whole presheaf category: the tritone is a
  *closure operator on `Sub(1)`*, whereas `kernelImage` is *the image of a
  marking unit into `D 1`*, and a sheafification's unit at `1` is forced to be
  an iso.  Realizing the tritone as `kernelImage Δ Y` would require a bespoke
  distinction structure whose unit-image at a *non-terminal* witness object is
  the tritone subobject of an object with `Sub ≅ Div12`; that is a separate
  construction (sheafification does not supply it) and is left genuinely open.

So item (ii) is not a missing mechanization of a true topos statement — it is a
**category error in the naïve form**, made precise here.  The disciplined
outcome is to keep the tritone partition at the lattice level (now bridged to
the topos by item (i)) and to record the come-apart rather than mechanize a
degenerate or false instance.
-/
import FalseWorkPapers.Examples.MusicTopos
import FalseWorkPapers.Positions.Partition

namespace FalseWork.Positions

open CategoryTheory CategoryTheory.Limits

universe v u

variable {C : Type u} [Category.{v} C] [HasImages C] [HasPullbacks C]

/-- **Trace-collapse lemma.**  If the marking unit `η.app Y` is an isomorphism,
the kernel image at `Y` is the maximal subobject `⊤`.

This is the formal core of the come-apart between the tritone nucleus and the
topos-level `Im(η)` kernel: the four-position kernel `kernelImage Δ Y` is the
image of the unit, and an iso unit has image `⊤`.  (Same proof as the
`kernelImage = ⊤` step of `trivialized_implies_isInfrastructure`.)

Consequently — since the terminal object is a sheaf for every Grothendieck
topology, so every sheafification monad has iso unit at `1` — no sheafification
distinction structure realizes the tritone (`⟨6⟩ ≠ ⊤`) as `kernelImage Δ 1`. -/
theorem kernelImage_eq_top_of_isIso_unit
    (Δ : DistinctionStructure C) (Y : C) (h : IsIso (Δ.η.app Y)) :
    kernelImage Δ Y = ⊤ := by
  haveI := h
  unfold kernelImage
  exact (imageSubobject_mono (Δ.η.app Y)).trans (Subobject.mk_eq_top_of_isIso _)

/-- **The partition collapses to Infrastructure-only where the unit is iso.**
A direct consequence of `kernelImage_eq_top_of_isIso_unit`: at any `Y` where
`η.app Y` is an isomorphism, every morphism `f : X ⟶ Y` is in Infrastructure
position, exactly as under `trivialDistinction`.  Applied with `Y = ⊤_` and a
sheafification `Δ` (whose unit at the terminal is iso), this is the degeneracy
that makes the sheafification-at-`1` route to a non-degenerate tritone partition
impossible. -/
theorem isInfrastructure_of_isIso_unit
    (Δ : DistinctionStructure C) {X Y : C} (f : X ⟶ Y) (h : IsIso (Δ.η.app Y)) :
    IsInfrastructure Δ f := by
  unfold IsInfrastructure
  rw [kernelImage_eq_top_of_isIso_unit Δ Y h]
  exact le_top

end FalseWork.Positions
