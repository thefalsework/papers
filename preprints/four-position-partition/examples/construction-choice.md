# Tier 1: Construction-Choice Analysis for the Non-Vacuity Demonstration

**Status.** Phase 1.1 (analysis). Lean mechanization in Phase 1.2 not yet started.
**Author.** Chris Brink (with AI collaboration per the project's validation architecture).
**Companion to.** [`../paper.md`](../paper.md) — the partition theorem this analysis is choosing a witness for.
**Date.** 2026-05-24.

---

## What this document is

The partition theorem (Theorem 5.1 of [`../paper.md`](../paper.md)) is a conditional: *given* an elementary topos C and a non-trivial distinction structure (D, η, ι) on it, the morphisms into a fixed Y with non-trivial D-image partition into four cells. A standard worry about such a conditional is whether the antecedent is ever satisfied in a way that makes *all four cells of the conclusion non-empty*. If, for every concrete (C, D, η, ι, Y), one or more cells is always empty for structural reasons, the partition reduces in practice to a partition with fewer cells — and the theorem becomes less informative than its statement suggests.

This document surveys candidate concrete constructions and identifies what is required for a four-cell non-vacuity demonstration. The provisional finding is that the minimal viable construction requires non-trivial subobject structure on D(Y) — specifically a Heyting algebra with at least one non-regular middle element whose complement is also non-trivial. This rules out the most obvious "small" candidates and is itself a structural fact about the partition theorem worth recording.

## Structural requirements for four-cell non-vacuity

For all four cells to be inhabited at some Y in some elementary topos C with non-trivial distinction structure (D, η, ι), it is necessary and sufficient that:

1. **C is an elementary topos** satisfying the §2 hypothesis bundle.
2. **(D, η, ι) is non-trivial**: there is some Y₀ with η_{Y₀} not an isomorphism.
3. **Coherence**: η_{D(X)} ≫ ι_X = 1_{D(X)} for all X.
4. **Idempotency**: ι: D ⋙ D ≅ D is a natural isomorphism.
5. **At the chosen Y**: in Sub(D(Y)), the kernel image a_Y := Im(η_Y) satisfies all three of:
   - **a_Y ≠ ⊤** (otherwise Refusal is empty — every non-zero image meets a_Y);
   - **a_Yᶜ ≠ ⊥** (otherwise Distribution is empty — img ⊓ a_Yᶜ ≤ ⊥ for all img);
   - **a_Yᶜᶜ ≠ a_Y** (otherwise Exploitation is empty — collapses to a_Yᶜ ∨ a_Y by Remark 5.3 of the paper).

The third condition forces Sub(D(Y)) to be non-Boolean at a_Y. The first two force a_Y to sit at a *middle* position of Sub(D(Y)) with both a "down side" (the kernel image proper) and an "up side" (its complement) non-trivial.

Sub(D(Y)) being non-Boolean is a property of C and D(Y), not just C. A non-Boolean topos can have specific objects whose subobject lattices are Boolean (e.g., subterminals in many toposes). The construction must engineer D so that D(Y) sits at a richly non-Boolean spot of C.

## Survey of candidate constructions

### Candidate A — Sierpinski topos C = Set^→ with elementary D

The Sierpinski topos (presheaves on the walking arrow `0 → 1`) is the simplest non-Boolean topos. Objects are triples X = (X₀, X₁, X_e: X₀ → X₁). The subobject classifier is the three-element pair Ω = ({⊥, mid, ⊤}, {⊥, ⊤}, Ω_e: ⊥↦⊥, mid↦⊤, ⊤↦⊤).

Heyting structure on Sub(X) for a subobject S = (S₀, S₁) with X_e(S₀) ⊆ S₁:

- (Sᶜ)₀ = {x ∈ X₀ : x ∉ S₀ ∧ X_e(x) ∉ S₁}
- (Sᶜ)₁ = X₁ ∖ S₁
- (Sᶜᶜ)₀ = X_e⁻¹(S₁) — the full preimage of S₁
- (Sᶜᶜ)₁ = S₁
- S is regular iff S₀ = X_e⁻¹(S₁).

**Candidate distinction structure.** The natural "projection to codomain" construction:
- D(X) := (X₁, X₁, id_{X₁})
- η_{X,0} := X_e, η_{X,1} := id_{X₁}
- ι_X := id (since D(D(X)) = D(X) on the nose)

This satisfies idempotency, coherence (trivially, since ι = id and η_{D(X)} = id), and non-triviality (η_X is iso iff X_e is iso).

**Why this candidate fails.** For any Y, D(Y) = (Y₁, Y₁, id) and η_Y has image a_Y = (image of Y_e, Y₁) ∈ Sub(D(Y)). The level-1 component is always Y₁ — the *full* level-1 of D(Y). Therefore (a_Y)ᶜ at level 1 = Y₁ ∖ Y₁ = ∅. And then (a_Y)ᶜ at level 0 is also forced to ∅. So **a_Yᶜ = ⊥ for every Y**, and Distribution is empty.

The same failure mode applies to the dual "projection to domain" candidate D(X) := (X₀, X₀, id_{X₀}) with the appropriate η.

**Verdict.** Sierpinski with elementary projection D inhabits at most three of the four cells. Not viable.

### Candidate B — Sierpinski topos with constant-Ω D

Take D = const Ω (the constant functor at the subobject classifier) and η_X = "the constant true map" X → Ω (which is the characteristic morphism of X as a subobject of itself).

Idempotency ι: D ⋙ D = const Ω = D, so ι = id_Ω.

**Why this candidate fails.** Coherence requires η_{D(X)} ≫ ι_X = 1_{D(X)}, i.e., η_Ω = id_Ω. But η_Ω is the constant true map Ω → Ω, not id_Ω. **Coherence fails.**

**Verdict.** Not viable for the formal definition of distinction structure. (A weaker condition relaxing coherence to "η_{D(X)} is split mono with retraction ι" would admit this, but that is not what Definition 3.1 says, and Remark 5.4 already notes that the partition proof itself does not use coherence.)

### Candidate C — Sierpinski topos with hand-engineered D

For any object Y of Set^→ and any non-regular subobject S ∈ Sub(Y), one can in principle write down four morphisms into Y whose D-images hit each of the four cells — *if* a D can be found that produces Y from some Y' and engineers a_{Y'} = S.

Concrete target: pick X = ({a, b}, {x, y}, a↦x, b↦x) and S = ({a}, {x}) ∈ Sub(X). Verification:

- S is non-regular: X_e⁻¹({x}) = {a, b} ⊋ {a}.
- Sᶜ = (∅, {y}) ≠ ⊥.
- Sᶜᶜ = ({a, b}, {x}) ≠ S.

So if X = D(Y) and S = a_Y for some Y and some D, all four cells can be witnessed:
- **Infrastructure**: img = ({a}, {x}) — equals a_Y.
- **Distribution**: img = ({a}, {x, y}) — meets a_Y (via a) and Sᶜ (via y).
- **Exploitation**: img = ({a, b}, {x}) — lies in Sᶜᶜ, but not in S (contains b).
- **Refusal**: img = (∅, {y}) — equals Sᶜ.

**The remaining task** is to construct a D: Set^→ → Set^→ such that some specific Y maps to X and η_Y has image S. This is hard because D must be a *functor*: it must be defined coherently on all objects of Set^→ and on all morphisms, not just at Y. Concretely:

- D = const X with η_Y' a natural family of maps Y' → X. The natural family is constrained by naturality to specific maps. For the chosen X, the only natural family η: 1 → const X is given by a "global element" 1 → X, which factors through one of the global elements of X. Global elements of X = ({a, b}, {x, y}, a↦x, b↦x) correspond to pairs (point in X₀, point in X₁) with X_e mapping point-in-X₀ to point-in-X₁. The valid global elements are (a, x) and (b, x). For η_Y' = const_(a, x), the image a_{Y'} = ({a}, {x}) = S for *any* Y' with Y'₀, Y'₁ non-empty. Good.
- Idempotency: D = const X, so D ⋙ D = const X = D. ι = id_X.
- Coherence: η_X ≫ ι_X = η_X = id_X required. But η_X = const_(a, x) ≠ id_X. **Coherence fails again.**

The coherence axiom is the consistent stumbling block for the easy candidates. It demands that η, when restricted to objects in the image of D, agree with the identity. For constant D this forces η_X = id_X, which conflicts with the constant choice. For non-constant D with explicit image-engineering, the naturality square pins η too tightly.

**Verdict.** Sierpinski + hand-engineered D is delicate. The right move is either to relax to a different topos (Candidate D below) or to engineer D as a sheafification-style construction (Candidate E).

### Candidate D — M-Set for an idempotent monoid M

Let M = {1, e} with e² = e. The category M-Set of left M-sets is an elementary topos (presheaves on the one-object category corresponding to M).

Subobjects of an M-set (X, f: X → X) are f-stable subsets. For X = ({a, b, c}, f: a↦a, b↦a, c↦c) with idempotent f, the f-stable subsets are:

∅, {a}, {c}, {a, c}, {a, b}, {a, b, c}

— a 6-element Heyting algebra. The Heyting implication is:

(S ⇒ T) = {x ∈ X : (x ∈ S ⇒ x ∈ T) ∧ (f(x) ∈ S ⇒ f(x) ∈ T)}.

Computing complements:
- {a}ᶜ = {c}, {a}ᶜᶜ = {a, b} ≠ {a}. **Non-regular.**
- {c}ᶜ = {a, b}, {c}ᶜᶜ = {c}. **Regular.**
- {a, c}ᶜ = ∅, regular but trivially so.
- {a, b}ᶜ = {c}, regular.

So {a} ∈ Sub(X) is the non-regular middle element with non-trivial complement {c} and non-trivial closure {a, b}. The closure-residue {a, b} ∖ {a} = {b} is non-trivial.

If we can construct D, η, ι such that D(Y) = X and a_Y = {a}, all four cells are inhabited:
- **Infrastructure**: img = {a}.
- **Distribution**: img = {a, c} — meets {a} at a and {c} at c.
- **Exploitation**: img = {a, b} — in closure {a, b}, not in {a}.
- **Refusal**: img = {c} — in complement {c}.

**Status of D construction**: not yet settled. The candidates considered to date all face the same coherence-axiom obstruction encountered in Sierpinski. Two promising directions for Phase 1.2:

1. **Coreflection construction**: Take D to be the right adjoint of an inclusion of a reflective subcategory of M-Set, such that D(Y) lands at the fixed point image of f. This produces an idempotent comonad rather than monad; one would then check whether the partition theorem accepts the dual structure or whether the construction can be flipped.
2. **Free idempotent monad construction**: Build D as the free idempotent monad on a specific endofunctor. The standard categorical construction (Adámek-Rosický) produces such monads when the underlying category has enough limits; the Mathlib coverage of this is partial.

**Verdict.** Subobject structure of M-Set for idempotent M supports four-cell non-vacuity. Concrete D construction needs Phase 1.2 mathematical work.

### Candidate E — Sheaf topos for a Lawvere-Tierney topology on Sierpinski

For a Lawvere-Tierney topology j on Set^→, the associated sheaf functor (-)_j: Set^→ → Set^→ is idempotent (sheafification of a sheaf is the sheaf), with unit η: 1 → (-)_j the sheafification map. Coherence is satisfied automatically: η_{F_j} is an iso (since F_j is already a sheaf), and the iso is precisely ι_F at F.

This is the **categorically correct** way to produce (D, η, ι) satisfying all of Definition 3.1. The questions for Phase 1.2:

- Which topology j on Set^→ to choose, such that the j-sheafification preserves enough non-Boolean structure that some object Y has D(Y) = Y_j with non-Boolean Sub(Y_j) and a_Y in a middle position?
- The double-negation topology j_¬¬ is known to land in the Boolean reflection — bad for our purposes.
- A non-trivial *non-double-negation* topology would work. Candidates include the dense topology with a non-trivial dense subobject of Ω, or a topology induced by a specific subterminal.

**Verdict.** This is the most natural Phase 1.2 candidate. Sheafification automatically satisfies coherence and idempotency; the remaining work is choosing the topology and computing the four-cell witnesses.

## Provisional recommendation for Phase 1.2

Pursue **Candidate E** (sheafification for a non-double-negation Lawvere-Tierney topology on Set^→) as the primary path, with **Candidate D** (M-Set with explicit idempotent monad construction) as the fallback if the Lean tooling for Lawvere-Tierney topologies in Mathlib turns out to be too thin.

The reasoning:
- Candidate E provides (D, η, ι) satisfying all of Definition 3.1 *by construction*, eliminating the coherence obstruction that defeats Candidates A–C.
- Sheaf topoi are well-supported in Mathlib (`CategoryTheory.Sites.Sheafification`).
- The Sierpinski-base is the smallest non-Boolean elementary topos available; building on it keeps the demonstration minimal.

## What this analysis has settled

Three structural facts about the partition theorem are visible from Phase 1.1 even before any construction is completed:

1. **The four-cell non-vacuity property is non-trivial.** The most obvious distinction structures (projections, constant functors at the classifier) fail to inhabit all four cells. This is informative and worth recording as a remark in [`../paper.md`](../paper.md) at a later revision.
2. **The coherence axiom is structurally constraining.** Even though the partition proof itself does not invoke coherence (per Remark 5.4 of the paper), coherence rules out a large class of would-be distinction structures and is therefore not redundant at the level of the *structure*, only at the level of the *partition*. This sharpens what Remark 5.4 says.
3. **Sheafification-style distinction structures are the natural source of non-vacuous examples.** The fact that sheafification automatically satisfies all of Definition 3.1 means the partition theorem effectively applies to *sheafification-induced* partitions of morphisms — a category-theoretic interpretation worth eventually flagging in the paper.

## Open tasks for Phase 1.2

- [ ] Select the Lawvere-Tierney topology j on Set^→ (or alternative base topos).
- [ ] Verify the j-sheafification produces D, η, ι satisfying Definition 3.1.
- [ ] Identify a specific Y in Set^→ such that Sub(D(Y)) has a non-regular middle a_Y.
- [ ] Construct one morphism per cell with explicit witness.
- [ ] Mechanize the construction in Lean 4 against Mathlib.
- [ ] Run `#print axioms` on each cell-witness to confirm dependence on standard Mathlib axioms only.
- [ ] Write the math-prose companion `sierpinski-sheaf.md` (or analogous, depending on construction).
- [ ] Add §5.5 ("Demonstration") to [`../paper.md`](../paper.md) forward-referencing the example.
- [ ] Update [`../../lean/ARCHITECTURE.md`](../../lean/ARCHITECTURE.md) with the example sitting under the partition theorem.

## Estimated cost for Phase 1.2

Originally estimated at 2-3 weeks of focused work. Revised estimate based on Phase 1.1 findings: **3-5 weeks**. The coherence-axiom obstruction discovered in Phase 1.1 means the construction is meaningfully harder than the original scoping suggested. The sheafification route appears tractable but will require careful navigation of Mathlib's `CategoryTheory.Sites` infrastructure.

## Provenance

Phase 1.1 conducted on 2026-05-24 in conversation with Anthropic Claude (Cursor IDE), per the project's documented validation architecture. The candidate-survey analysis is exploratory; verification of all claims will be done mechanically in Phase 1.2. Two specific computations have been done by hand in Phase 1.1 and should be checked when Phase 1.2 begins:
- The Heyting complement formulas in Set^→ (used for Candidates A–C).
- The 6-element subobject lattice and complement structure for X = ({a, b, c}, f: a↦a, b↦a, c↦c) in M-Set (used for Candidate D).

If either turns out to have a hand-computation error, the survey conclusions should be re-derived. The Lean mechanization in Phase 1.2 will catch any such error.
