/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# Layer-D distinction operator and the literal Z/12 realization

This file completes two items that the music-anchor feasibility memo
(`preprints/four-position-partition/music-anchor/feasibility.md`)
flagged as the remaining lattice-level work on the divisor lattice of
12, and which the previous Lean artefact (`DivisorLattice12.lean`) left
as documentation rather than proof:

* **Layer-D lattice slice (§12.6 of the memo).** `DivisorLattice12.lean`
  takes the kernel `a = two` (the tritone) as a *given* and shows the
  four cells are inhabited there.  But that choice is not arbitrary: it
  is the kernel image `Im(η)` of a concrete idempotent distinction
  operation.  Here we exhibit that operation — `tritoneClosure`, the
  minimal tritone-closing closure operator (the Moore family
  `{tritone, chromatic} = {⟨6⟩, Z/12}`) — and prove it is a genuine
  closure operator (extensive, monotone, idempotent) whose closure of
  `⊥` is exactly the tritone, a non-regular element.  This is the
  lattice-level shadow of a `DistinctionStructure`: a closure operator
  on a Heyting algebra is precisely what `Im(η)` of an idempotent monad
  cuts out at the subobject level (cf.
  `FalseWork.Positions.DistinctionStructure.ofIdempotentMonad`,
  Remark 5.5 of the paper).  It de-arbitrarizes the kernel used by
  `music_anchor_witness`.

* **Literal Z/12 realization (§12.1, §12.4).** `DivisorLattice12.lean`
  asserts in prose that its six abstract elements *are* the six
  transposition-symmetric pitch-class subsets (subgroups) of `Z/12`.
  Here we make that correspondence a kernel-checked fact: a map
  `pcset : Div12 → Finset (ZMod 12)` sending each element to the actual
  pitch-class set, proven to be injective, to land in additive
  subgroups (closed under `0`, `+`, negation), and to be a lattice
  embedding (order = inclusion, meet = intersection).

Both developments are finite and discharged by `decide`, in the same
style as the parent file.  Neither touches the topos level: the
remaining step — lifting `tritoneClosure` to an idempotent monad on a
concrete elementary topos `T` with `Sub_T(1) ≅ Div12` and recovering it
as `kernelImage` — is the genuinely deferred "Layer-T/Layer-D topos
lift" (memo §12.7), and is the natural object of outreach to a
specialist in categorical music theory.

## Cross-reference

* `FalseWorkPapers.Examples.DivisorLattice12` — the parent Layer-L
  witness (`music_anchor_witness`, `tritone_non_regular`).
* `FalseWorkPapers.Positions.SpencerBrown` —
  `DistinctionStructure.ofIdempotentMonad`, the topos-level constructor
  this file's closure operator is the lattice shadow of.
* `preprints/four-position-partition/music-anchor/feasibility.md` §12.6
  (Layer-D candidate enumeration) and §12.7 (status table).
-/
import FalseWorkPapers.Examples.DivisorLattice12
import Mathlib.Data.ZMod.Basic

namespace FalseWork.Lattice.Examples

namespace Div12

/-! ## Part 1 — The tritone-closing distinction operator (Layer-D slice)

`tritoneClosure` is the closure operator on `Div12` whose set of closed
(fixed) points is the Moore family `{two, twelve}`.  Computed pointwise,
the closure of `x` is the least closed element `≥ x`:

```
  one ↦ two      (⊥ closes up to the tritone)
  two ↦ two      (the tritone is closed: it is Im(η))
  three ↦ twelve (augmented triad is not below the tritone, closes to ⊤)
  four ↦ twelve  (diminished 7th, ditto)
  six ↦ twelve   (whole-tone, ditto)
  twelve ↦ twelve
```

This is candidate `{2, 12}` — the *minimal* tritone-closing Moore
family — from §12.6 of the music-anchor memo. -/
def tritoneClosure : Div12 → Div12
  | one    => two
  | two    => two
  | three  => twelve
  | four   => twelve
  | six    => twelve
  | twelve => twelve

/-- `tritoneClosure` is extensive: every element sits below its closure. -/
theorem tritoneClosure_le_self : ∀ a : Div12, a ≤ tritoneClosure a := by decide

/-- `tritoneClosure` is monotone. -/
theorem tritoneClosure_monotone :
    ∀ a b : Div12, a ≤ b → tritoneClosure a ≤ tritoneClosure b := by decide

/-- `tritoneClosure` is idempotent: marking twice = marking once
(Spencer-Brown's Calling axiom at the lattice level). -/
theorem tritoneClosure_idem :
    ∀ a : Div12, tritoneClosure (tritoneClosure a) = tritoneClosure a := by decide

/-- The fixed-point set of `tritoneClosure` is exactly the Moore family
`{tritone, chromatic}`. -/
theorem tritoneClosure_fixedPoints :
    ∀ a : Div12, tritoneClosure a = a ↔ (a = two ∨ a = twelve) := by decide

/-- The Moore family is closed under meet (the defining property of a
closure operator's closed sets). -/
theorem tritoneClosure_meet_closed :
    ∀ a b : Div12, tritoneClosure a = a → tritoneClosure b = b →
      tritoneClosure (a ⊓ b) = a ⊓ b := by decide

/-- **The kernel image of the distinction operation is the tritone.**
The closure of `⊥` is `two` — i.e. `tritoneKernel`.  This is the
lattice-level analogue of `Im(η) = a`: the kernel that
`music_anchor_witness` partitions around is *not stipulated* but is the
image of the concrete idempotent operation `tritoneClosure`. -/
theorem tritoneClosure_bot : tritoneClosure ⊥ = tritoneKernel := by decide

/-- The kernel image is non-regular, which is exactly what makes the
Exploitation cell non-empty (cf. `tritone_non_regular`). -/
theorem tritoneClosure_bot_non_regular :
    (tritoneClosure ⊥)ᶜᶜ ≠ tritoneClosure ⊥ := by decide

/-- **Layer-D lattice slice (bundled).**

`tritoneClosure` is a closure operator (extensive, monotone,
idempotent) on the divisor lattice of 12 whose kernel image
`tritoneClosure ⊥` is the tritone — a non-regular element.  Combined
with `music_anchor_witness`, this shows the four-position partition's
kernel on the music substrate is the `Im(η)` of a concrete idempotent
distinction operation, not a free parameter.  The only step left to a
full `FalseWork.Positions.four_position_partition` instance is the
topos-level lift of this closure operator (deferred; memo §12.7). -/
theorem tritoneClosure_is_distinction_slice :
    (∀ a : Div12, a ≤ tritoneClosure a) ∧
    (∀ a b : Div12, a ≤ b → tritoneClosure a ≤ tritoneClosure b) ∧
    (∀ a : Div12, tritoneClosure (tritoneClosure a) = tritoneClosure a) ∧
    tritoneClosure ⊥ = tritoneKernel ∧
    (tritoneClosure ⊥)ᶜᶜ ≠ tritoneClosure ⊥ :=
  ⟨tritoneClosure_le_self, tritoneClosure_monotone, tritoneClosure_idem,
   tritoneClosure_bot, tritoneClosure_bot_non_regular⟩

/-! ## Part 2 — The literal `Z/12` realization

Each abstract `Div12` element is sent to the actual transposition-
symmetric pitch-class subset of `Z/12` it stands for.  The labels in
`DivisorLattice12.lean` use *order of subgroup*:

| `Div12` | subgroup    | pitch classes              |
|---------|-------------|----------------------------|
| `one`   | `{0}`       | `{0}`                      |
| `two`   | `⟨6⟩`       | `{0, 6}` (tritone)         |
| `three` | `⟨4⟩`       | `{0, 4, 8}` (aug triad)    |
| `four`  | `⟨3⟩`       | `{0, 3, 6, 9}` (dim 7th)   |
| `six`   | `⟨2⟩`       | whole-tone hexachord       |
| `twelve`| `Z/12`      | full chromatic             |
-/

/-- The pitch-class set (subgroup of `Z/12`) realizing each abstract
divisor-lattice element. -/
def pcset : Div12 → Finset (ZMod 12)
  | one    => {0}
  | two    => {0, 6}
  | three  => {0, 4, 8}
  | four   => {0, 3, 6, 9}
  | six    => {0, 2, 4, 6, 8, 10}
  | twelve => Finset.univ

/-- Distinct lattice elements realize as distinct pitch-class sets. -/
theorem pcset_injective : Function.Injective pcset := by decide

/-- Every realized set contains the identity `0` (the subgroup unit). -/
theorem pcset_zero_mem : ∀ a : Div12, (0 : ZMod 12) ∈ pcset a := by decide

/-- Every realized set is closed under addition (subgroup closure). -/
theorem pcset_add_closed :
    ∀ a : Div12, ∀ x ∈ pcset a, ∀ y ∈ pcset a, x + y ∈ pcset a := by decide

/-- Every realized set is closed under negation (subgroup closure). -/
theorem pcset_neg_closed :
    ∀ a : Div12, ∀ x ∈ pcset a, -x ∈ pcset a := by decide

/-- The realization is order-reflecting and order-preserving: lattice
order is subgroup inclusion. -/
theorem pcset_mono :
    ∀ a b : Div12, a ≤ b ↔ pcset a ⊆ pcset b := by decide

/-- The realization sends meet to intersection. -/
theorem pcset_meet :
    ∀ a b : Div12, pcset (a ⊓ b) = pcset a ∩ pcset b := by decide

/-- **The `Z/12` realization (bundled).**

The six divisor-lattice elements realize as the six transposition-
symmetric pitch-class subsets of `Z/12`, with lattice order = subgroup
inclusion and meet = intersection, each set an additive subgroup.  This
upgrades the parent file's "equivalently the subgroup lattice of Z/12"
remark from documentation to a kernel-checked correspondence. -/
theorem pcset_realizes_subgroup_lattice :
    Function.Injective pcset ∧
    (∀ a : Div12, (0 : ZMod 12) ∈ pcset a) ∧
    (∀ a : Div12, ∀ x ∈ pcset a, ∀ y ∈ pcset a, x + y ∈ pcset a) ∧
    (∀ a : Div12, ∀ x ∈ pcset a, -x ∈ pcset a) ∧
    (∀ a b : Div12, a ≤ b ↔ pcset a ⊆ pcset b) ∧
    (∀ a b : Div12, pcset (a ⊓ b) = pcset a ∩ pcset b) :=
  ⟨pcset_injective, pcset_zero_mem, pcset_add_closed, pcset_neg_closed,
   pcset_mono, pcset_meet⟩

/-- Sanity: the realization matches the closure operator's kernel image.
`tritoneClosure ⊥` realizes as the literal tritone dyad `{0, 6}`. -/
theorem pcset_tritoneClosure_bot :
    pcset (tritoneClosure ⊥) = {0, 6} := by decide

end Div12

end FalseWork.Lattice.Examples
