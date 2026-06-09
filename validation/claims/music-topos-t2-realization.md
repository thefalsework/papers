# Claim: the music substrate is a concrete presheaf topos (T2), with a Lawvere–Tierney realization of the distinction operator

**Status:** Lattice-and-operator level **and topos-object level kernel-checked in-repo** (Lean 4 / Mathlib4 `v4.30.0-rc2`, axiom audit `propext, Classical.choice, Quot.sound`, no `sorry`). As of 2026-06 the topos-object plumbing is **closed** (`Examples/MusicTopos.lean`), the explicit `Subobject (⊤_ MusicTopos) ≅ Div12` iso is **closed [K]** (`Examples/MusicToposSub.lean`), and the sheafification-endofunctor route is **resolved as a come-apart** (`Examples/MusicToposTrace.lean`): the tritone nucleus does not lift to the `Im(η)` kernel of any sheafification monad. Only canonicity and a bespoke non-terminal-witness endofunctor remain **open**. Not externally validated.

**Papers / notes:** four-position-partition preprint `music-anchor/mazzola-bridge-note.md` §5; synthesis note `papers/connecting-the-spine.md` §3; companion to `music-kernel-umbrella.md`.

**Date opened:** 2026-06-08.

---

## What is being claimed (and at what strength)

This claim records the 2026-06 formalization work that connects the music anchor to the central four-position-partition theorem at the level of the subobject lattice and the distinction operator, **without depending on any external categorical-music framework**.

### Kernel-checked (in-repo) — strength [K]

1. **T2 realization (Birkhoff).** `Div12 ≅ Sub_{Set^{Pᵒᵖ}}(1)`: the divisor lattice of `ℤ/12` is the lattice of down-sets of its poset `P` of join-irreducibles (the three symmetric pitch-class generators — tritone `⟨6⟩`, diminished seventh `⟨3⟩`, augmented triad `⟨4⟩`, with `⟨6⟩ < ⟨3⟩` and `⟨4⟩` incomparable). Since down-sets of `P` are exactly the subobjects of the terminal object in the presheaf topos `Set^{Pᵒᵖ}`, the music lattice is the subobject lattice of a concrete, canonical presheaf topos.
   - Lean: `FalseWork.Lattice.Examples.Div12.birkhoff_representation` (`DivisorLattice12Birkhoff.lean`). Injective, bounded, meet- and join-preserving, surjective onto down-sets.

2. **Lawvere–Tierney realization of the distinction operator.** The maximal tritone-closing closure operator `tritoneNucleus` is a nucleus (inflationary, idempotent, meet-preserving) — the subobject trace of a Lawvere–Tierney topology on `Set^{Pᵒᵖ}` — whose kernel image is the tritone, still non-regular. So the music kernel has a genuine *geometric* (sheaf-theoretic) realization, not merely a reflective one.
   - Lean: `tritone_kernel_has_lawvere_tierney_realization` (`DivisorLattice12Nucleus.lean`).

3. **Correction (negative).** The *minimal* tritone-closing operator `tritoneClosure` is **not** a nucleus — it fails meet-preservation (witness `j(⟨4⟩⊓⟨3⟩) = ⟨6⟩ ≠ ℤ/12`). An earlier draft of the bridge note speculated it might be a sheafification; it is not. Its lift is a general (non-left-exact) idempotent monad.
   - Lean: `tritoneClosure_not_nucleus` (`DivisorLattice12Nucleus.lean`).

4. **Topos-object instantiation (closed 2026-06).** `Set^{Pᵒᵖ}` is now an actual Lean `CategoryTheory` object — `MusicTopos := Pᵒᵖ ⥤ Type` for `P` the join-irreducible poset — and the **full elementary-topos hypothesis bundle resolves for it** (`HasSubobjectClassifier`, `HasPullbacks`, `HasEqualizers`, `HasInitial`, `HasImages`, `HasBinaryCoproducts`, `InitialMonoClass`). Hence `Sub_{Set^{Pᵒᵖ}}(1)` is a Heyting algebra on the concrete topos, and the central theorem `four_position_partition` typechecks and fires against the concrete topos object. The earlier blocker (no presheaf subobject classifier in Mathlib) was removed in Mathlib `v4.30` (`CategoryTheory.Presheaf.classifier`).
   - Lean: `musicTopos_isElementaryTopos`, `subTerminalHeytingAlgebra`, `four_position_partition_musicTopos` (`MusicTopos.lean`).

5. **Explicit `Subobject (⊤_ MusicTopos) ≅ Div12` (closed 2026-06).** The Birkhoff iso is upgraded from the *down-set* level (`Div12 ≅ O(P)`) to an order isomorphism of Mathlib's actual `Subobject` type of the terminal presheaf: `Subobject (⊤_ MusicTopos) ≃o Subobject oneF` (transport along the terminal iso, `Subobject.mapIsoToOrderIso`) `≃o Subfunctor oneF` (`Subfunctor.orderIsoSubobject`, Mathlib `v4.30`) `≃o Div12` (the down-set correspondence, built by hand — a subfunctor of the constant-`PUnit` presheaf is exactly a down-set of `P`). The topos's own `Sub(1)` cells thus map onto the named pitch-class objects of `Div12`.
   - Lean: `subobjectTerminalEquivDiv12`, `fromDownset_birkhoff` (`MusicToposSub.lean`).

6. **Trace check on the sheafification route (negative, 2026-06).** The four-position kernel is `kernelImage Δ Y = Im(η.app Y)` — the image of the *marking unit*. Any iso unit forces `kernelImage = ⊤` (`kernelImage_eq_top_of_isIso_unit`); and the terminal presheaf is a sheaf for every Grothendieck topology, so every sheafification monad has iso unit at `1`, giving `kernelImage Δ 1 = ⊤` while the tritone nucleus value is `⟨6⟩ ≠ ⊤`. Hence the sheafification-at-`1` route to a non-degenerate tritone partition degenerates **identically to `trivialDistinction`** — the lattice nucleus (a closure operator on `Sub(1)`) and the topos-level `Im(η)` kernel come apart at `1`. Recorded rather than mechanized.
   - Lean: `kernelImage_eq_top_of_isIso_unit`, `isInfrastructure_of_isIso_unit` (`MusicToposTrace.lean`).

### Open

- **Bespoke non-terminal-witness endofunctor (substantive).** Item 6 shows the tritone is *not* `kernelImage Δ 1` for any sheafification. Realizing the tritone as `kernelImage Δ Y` for a *non-terminal* witness object `Y` (with `Sub(D Y) ≅ Div12` and `Im(η_Y)` the tritone subobject) via a bespoke idempotent endofunctor — so the non-degenerate partition runs on the topos itself rather than only on the lattice `Div12` — remains open. The non-degenerate partition is meanwhile kernel-checked at the lattice level (`lattice_four_position_partition`, `music_anchor_witness`), and item 5 now identifies that lattice with the topos's own `Sub(1)`.
- **Canonicity (specialist).** Is `Set^{Pᵒᵖ}` *the* music topos, or does it embed as a natural slice of a richer one (Mazzola's denotator topos; a presheaf topos on the dihedral groupoid `D₁₂`)? This is the one remaining question of `mazzola-bridge-note.md` §5 — a question of canonicity, not existence. Awaiting a categorical music theorist.

## What's asked of a validator

1. Confirm the Birkhoff representation and the topos-theoretic identification `O(P) = Sub_{Set^{Pᵒᵖ}}(1)` are correctly applied (category theorist / topos theorist — mostly a sanity check, the lattice content is kernel-checked).
2. Assess the canonicity question above (categorical music theorist).

## Scope limits

The kernel-checked content now spans the subobject **lattice**, the **operator** (nucleus / idempotent monad), the **topos object** (`Set^{Pᵒᵖ}` as a Lean elementary topos against which `four_position_partition` typechecks), and the **explicit `Subobject`-API iso** `Subobject (⊤_ MusicTopos) ≅ Div12`. It does **not** include a *non-trivial topos endofunctor* making the topos-level partition non-degenerate: the trace check (item 6) shows the natural candidate — the sheafification monad — degenerates at `1` (the tritone is not its `Im(η)` kernel), so the non-degenerate partition remains the **lattice-level** theorem (now bridged to the topos's `Sub(1)` by item 5), and a bespoke non-terminal-witness endofunctor is open. It does **not** claim canonicity. These limits are load-bearing and must not be elided.
