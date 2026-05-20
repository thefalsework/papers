# `refusal-bridge` — When does a non-trivial distinction structure escape the regular sub-algebra?

**Status:** OPEN — named conjecture, no proof attempt yet
**Paper:** Paper 1 § 3.4 (v11.8; Refusal as one of four cells); Paper 3 § 4 (v9.4; D1–D4 categorical formalization)
**Lean file:** [`../../lean/FalseWorkPapers/Positions/Refusal.lean`](../../lean/FalseWorkPapers/Positions/Refusal.lean) — `DistinctionStructure.HasIrregularKernel` predicate; `refusal_residue` theorem closed under that hypothesis (2026-05-20)
**Domain:** Category theory / topos theory / Heyting-algebra structure of subobject lattices
**Time estimate:** ~4–10 hours (topos theorist familiar with regular elements of Heyting algebras and the internal logic of an elementary topos)

---

## Setup

Let `C` be an elementary topos (`HasSubobjectClassifier`, `HasPullbacks`, `HasEqualizers`, `HasInitial`, `HasImages`, `HasBinaryCoproducts`, `InitialMonoClass`). For any object `Y : C`, the subobject lattice `Subobject Y` carries a `HeytingAlgebra` structure — constructed in [`../../lean/FalseWorkPapers/Heyting/SubobjectInstance.lean`](../../lean/FalseWorkPapers/Heyting/SubobjectInstance.lean) and submitted upstream as Mathlib PR [#39618](https://github.com/leanprover-community/mathlib4/pull/39618).

A *distinction structure* `Δ` on `C` is an idempotent endofunctor `D : C ⥤ C` together with a marking unit `η : 𝟭 ⟶ D` satisfying Spencer-Brown coherence. `Δ` is *non-trivial* when `η.app X` fails to be an isomorphism at some object `X`. The *kernel image* at `Y` is `kernelImage Δ Y := image.ι (η.app Y) ∈ Subobject (D.obj Y)`.

`C` is *non-Boolean* when some subobject lattice contains an irregular element: `∃ Y, ∃ S : Subobject Y, Sᶜᶜ ≠ S`.

The framework's predicate `DistinctionStructure.HasIrregularKernel Δ` says the kernel image *itself* is irregular at some object: `∃ Y : C, (kernelImage Δ Y)ᶜᶜ ≠ kernelImage Δ Y`.

## Background: regulars of a Heyting algebra

In any Heyting algebra `H`, the *regular* elements — those `x` with `x = xᶜᶜ` — form a Boolean sub-algebra `H_reg ⊆ H`. The inherited meet on `H_reg` agrees with `H`'s meet; the join is given by `x ⊔_reg y := ¬¬(x ∨ y)`. Top and bottom are the same. On `H_reg` the law of double negation holds by construction, so classical reasoning is internally valid there.

The irregular elements of `H` are precisely those exhibiting intuitionistic strictness `x < xᶜᶜ`. They are where the topos's non-classical content lives.

## Claim (the bridge conjecture)

For every non-trivial distinction structure `Δ` on a non-Boolean elementary topos `C`:

> `Δ.HasIrregularKernel` holds.

Equivalently: no non-trivial distinction structure on a non-Boolean topos can confine its kernel image entirely to the regular sub-algebra of every subobject lattice.

## Why the conjecture is non-trivial

The naive expectation is that non-Booleanness of `C` should propagate everywhere — the topos has intuitionistic content, so a structure that *does* something in the topos should *see* that content. The bridge conjecture is the formal expression of this expectation.

The reason it does not close trivially is that the regulars are themselves a complete, well-behaved sub-algebra. Three concrete reasons:

1. **Regulars are closed under meets and double-negation.** A subobject built by intersecting regulars or by applying `¬¬` to anything is regular. A distinction operation whose kernel image is built from regular generators by these operations stays inside `H_reg` at every object.

2. **The `¬¬`-sheafification is a functor.** Every topos `C` has a universal map to its Boolean reflection (the sheaves of `¬¬`-closed subobjects). A distinction structure that factors through this reflection is regularly-confined by construction; whether some non-trivial `Δ` factoring this way exists in a generic non-Boolean topos is precisely the question.

3. **A regularly-confined non-trivial `Δ` is not a constructed counterexample — it is a generically available class.** Any non-trivial endofunctor `D' : C_Bool ⥤ C_Bool` on the Boolean reflection of `C` lifts to a distinction structure on `C` whose kernel image lives entirely in the regular elements. Ruling out this lift requires structural information about `D` that is not in the bare definition of `DistinctionStructure`.

Path-2 transport — proving the conjecture without adding any hypothesis to `Δ` — therefore requires *negating* this generic class, not merely *constructing* a positive argument. That is structurally harder than a typical existence proof; it is closer in shape to a rigidity theorem.

## What a validator should investigate

A topos theorist or category theorist engaging this conjecture should consider:

1. **The Boolean-reflection counterexample.** Is the lift `D' : C_Bool ⥤ C_Bool` → `D : C ⥤ C` (with `η` induced from the reflection's unit) actually a distinction structure in the framework's sense? If yes, it is a counterexample to the bridge as currently stated and the conjecture must be strengthened with a hypothesis ruling out such lifts. If no, what condition on `D` rules it out, and is that condition framework-motivated?

2. **Spencer-Brown coherence vs. regularity.** The framework requires `D ⋙ D ≅ D` and a marking-unit coherence. Does Spencer-Brown coherence on a regularly-confined `D` force `D` to be either trivial or non-coherent? If yes, the bridge follows from coherence alone.

3. **The `(¬¬)`-modality and the kernel image.** In any topos, the kernel image `image.ι (η.app Y)` has a `¬¬`-closure. Is there a structural reason — independent of coherence — that the closure is *strictly* larger than the image whenever `η.app Y` is not iso? This is the most direct path to closing the bridge.

4. **Topoi-of-interest case analysis.** For specific non-Boolean topoi the framework cares about (Sh(X) for a non-discrete `X`, the effective topos, presheaf topoi on small categories, the Sierpinski topos), can the bridge be verified case-by-case? Even partial results — "the bridge holds in any sheaf topos on a topological space with a non-isolated point" — are useful framework input.

5. **Counterexamples in degenerate cases.** Is there a small non-Boolean topos in which a non-trivial regularly-confined `Δ` exists? If yes, the bridge fails as stated; the framework's response is to add a hypothesis (some structural condition on `Δ` ruling out the counterexample) and rename the bridge.

## Implication for the framework

The bridge conjecture is the framework's deepest claim about how the distinction operation interacts with the ambient logic of the topos. If it closes positively, the framework gains a strong statement: any non-trivial distinction operation in any non-Boolean topos *automatically* exhibits the asymptotic-residue phenomenology — Refusal-as-position has content wherever the framework's setup applies.

If it closes with a counterexample, the framework's commitment shifts: studying *Δ with `HasIrregularKernel`* is a specific class, defined by the framework's interest in irregular operations, and the framework's pedagogical reach narrows accordingly. The Lean theorem `refusal_residue` stands either way — it is closed under the `HasIrregularKernel` hypothesis — but the breadth of its application depends on the bridge.

Either outcome is informative. The conjecture is well-formed, the resolution affects framework scope rather than framework validity, and the regulars framing gives the question a definite mathematical shape that a topos theorist can engage with productively.

## Cross-references

* Lean source for the closed `refusal_residue` theorem and the `HasIrregularKernel` predicate: [`../../lean/FalseWorkPapers/Positions/Refusal.lean`](../../lean/FalseWorkPapers/Positions/Refusal.lean)
* The Heyting-algebra-on-subobject construction the regulars sit inside: [`../../lean/FalseWorkPapers/Heyting/SubobjectInstance.lean`](../../lean/FalseWorkPapers/Heyting/SubobjectInstance.lean) (also Mathlib PR [#39618](https://github.com/leanprover-community/mathlib4/pull/39618))
* The four-position partition theorem the framework hangs on: [`../../lean/FalseWorkPapers/Positions/Partition.lean`](../../lean/FalseWorkPapers/Positions/Partition.lean), `four_position_partition` (kernel-checked, no dependency on this conjecture)
* The umbrella validation claim for the formalization: [`five-position-derivation-formalization.md`](five-position-derivation-formalization.md)
* Standard reference for regulars / Boolean sub-algebra of a Heyting algebra: Johnstone, *Sketches of an Elephant* I.A1.4 (esp. the discussion of `¬¬`-sheaves and the Boolean reflection); Mac Lane–Moerdijk *Sheaves in Geometry and Logic* VI.1 (the `¬¬`-topology and its associated sheaf subtopos)

## Changelog

- 2026-05-20: Claim created. Promoted from a parked `sorry` in `Refusal.lean` (Phase 3 leftover) to a named open conjecture after the architectural decision (Path 1 + Path 4) to close `refusal_residue` under the `HasIrregularKernel` hypothesis. The regulars framing was suggested in-session as a sharpening of the brute-existential form of the hypothesis, giving the bridge question a structural shape that maps onto how Refusal-as-position actually reads (the residue exists where the operation refuses to factor through the Boolean part of the ambient logic).
