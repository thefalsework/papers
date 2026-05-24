# Tier 1: Construction-Choice Analysis for the Non-Vacuity Demonstration

**Status.** Phase 1.1 (analysis) — complete. Phase 1.2 (concrete construction + Lean mechanization) — pending; revised plan below.
**Author.** Chris Brink (with AI collaboration per the project's validation architecture).
**Companion to.** [`../paper.md`](../paper.md) — the partition theorem this analysis is choosing a witness for. Two paper revisions (Remarks 5.4 and 5.5) absorb Phase 1.1's findings.
**Date.** 2026-05-24 (Phase 1.1 complete).

---

## What this document is

The partition theorem (Theorem 5.1 of [`../paper.md`](../paper.md)) is a conditional: *given* an elementary topos C and a non-trivial distinction structure (D, η, ι) on it, the morphisms into a fixed Y with non-trivial D-image partition into four cells. A standard worry about such a conditional is whether the antecedent is ever satisfied in a way that makes *all four cells of the conclusion non-empty*. If, for every concrete (C, D, η, ι, Y), one or more cells is always empty for structural reasons, the partition reduces in practice to a partition with fewer cells — and the theorem becomes less informative than its statement suggests.

This document surveys candidate concrete constructions and identifies what is required for a four-cell non-vacuity demonstration. **The Phase 1.1 finding is that the minimal viable construction requires a base topos strictly richer than the Sierpinski topos.** Among the five Lawvere-Tierney topologies on Set^→, plus the standard non-LT reflective subcategories, none produces a non-vacuous four-cell witness. This is a structural fact about the partition theorem worth recording, and it sharpens the recommendation for Phase 1.2 from "use Sierpinski" to "escalate to a richer base topos (presheaves on a 3-chain, or M-Set for a non-trivial idempotent monoid)."

The Phase 1.1 work also surfaced a categorical connection worth recording independently: distinction structures in the sense of Definition 3.1 are closely related to idempotent monads, which correspond to reflective subcategories. The partition theorem can therefore be read as a statement about morphism structure under any reflection of an elementary topos. This is reflected in Remark 5.5 of [`../paper.md`](../paper.md).

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

For any Lawvere-Tierney topology j on Set^→, the associated sheaf functor (-)_j: Set^→ → Set^→ is idempotent (sheafifying a sheaf yields the sheaf), with unit η: 1 → (-)_j the sheafification map. Coherence holds automatically: η_{F_j} is an iso (since F_j is already a sheaf), and that iso is precisely ι.hom_F. Sheafification is thus the **categorically correct** way to produce (D, η, ι) satisfying all of Definition 3.1.

The Phase 1.1 question is which topology to pick. Deeper investigation shows this question has no satisfactory answer on Set^→.

**Classification of Lawvere-Tierney topologies on Set^→.**

A Lawvere-Tierney topology is a morphism j: Ω → Ω satisfying j ∘ true = true, j ∘ j = j, j ∘ ∧ = ∧ ∘ (j × j). For Set^→ with Ω = ({⊥, mid, ⊤}, {⊥, ⊤}, Ω_e: ⊥↦⊥, mid↦⊤, ⊤↦⊤), j is determined by j_0: Ω_0 → Ω_0 (idempotent, fixing ⊤, monotone) and j_1: Ω_1 → Ω_1, with the commuting condition Ω_e ∘ j_0 = j_1 ∘ Ω_e forcing j_1.

Enumerating (j_0(⊥), j_0(mid)):

| (j_0(⊥), j_0(mid)) | j_1 | j-sheaves | Reflection target |
|---|---|---|---|
| (⊥, mid) | id | whole topos | trivial |
| (⊥, ⊤) | id | {X : X_e iso} | Boolean reflection (j_¬¬) |
| (mid, mid) | const ⊤ | trivial topos | trivial topos |
| (mid, ⊤) | const ⊤ | trivial topos | trivial topos |
| (⊤, ⊤) | const ⊤ | trivial topos | trivial topos |

(Verification of the j-sheaves columns: for (mid, mid), j-closure of (S_0, S_1) is (S_0, X_1) by computing j_0 on χ_S; the only object with all subobjects of this form is the zero object. For (mid, ⊤), j-closure is (X_e⁻¹(S_1), X_1); only the zero object has only trivial subobjects. For (⊥, ⊤), j-closure is (X_e⁻¹(S_1), S_1) = Sᶜᶜ; sheaves are objects where every subobject is regular, equivalent to X_e iso.)

**Consequence.** Set^→ admits exactly five Lawvere-Tierney topologies. Four of these (trivial, (mid, mid), (mid, ⊤), maximal) give either the identity reflection or the zero-object reflection — both useless for the four-cell goal. The fifth (double-negation) lands in the Boolean reflection, where Sub((Y)_{¬¬}) is Boolean for every Y, collapsing Exploitation by Remark 5.3 of the paper.

**Verdict.** **No Lawvere-Tierney topology on Set^→ produces a non-vacuous four-cell witness.** Sheafification on Sierpinski is not a viable candidate.

## Phase 1.1 conclusion: Sierpinski is too small

Combining the analyses of Candidates A through E, plus an independent check of non-LT reflective subcategories of Set^→ (codomain projection, source projection, subterminals, monos, epis — all collapse), the structural conclusion is:

> **The Sierpinski topos Set^→ is too small to host a non-vacuous instance of the four-cell partition.** No distinction structure (D, η, ι) on Set^→ produces a configuration in which all four cells are simultaneously inhabited.

This is itself a structural fact about the partition theorem worth recording (and is now reflected in Remark 5.5 of [`../paper.md`](../paper.md)). The four-cell partition requires a non-Boolean subobject lattice with a non-regular middle element whose complement is also non-trivial, and Sierpinski's Sub-lattices are too rigid: in any reflection target reachable from Set^→, either a_Y is forced to ⊤ (Refusal empty), a_Y^c is forced to ⊥ (Distribution empty), or the lattice is Boolean (Exploitation empty).

## Revised recommendation for Phase 1.2: escalate to a richer base topos

Phase 1.2 must escalate from Sierpinski to a topos with strictly richer structure. Three candidates ranked by tractability:

1. **Presheaves on the linear 3-chain {0 < 1 < 2}.** Set^{(2)^op} has a 4-element subobject classifier at level 0 and a 3-element classifier at level 1, with richer Heyting structure. Reflective subcategories are more abundant. Mathlib's `CategoryTheory.Functor.Category` and presheaf machinery cover this well.
2. **M-Set for an idempotent monoid with multiple idempotents.** E.g., M = {1, e, f} with e² = e, f² = f, ef = e, fe = f. The category of M-sets is a topos with multiple non-trivial reflective subcategories (fixed points of e, fixed points of f, joint fixed points). Sub-lattices of typical M-sets are non-Boolean with multiple non-regular middle elements.
3. **The classifying topos of an algebraic theory.** Specifically, the theory of "an object equipped with an idempotent endomorphism" produces the universal topos hosting an idempotent monad. This is the categorically correct *minimal* example, but its concrete realization is more elaborate than 1 or 2.

**Recommended path.** Pursue Candidate 1 (presheaves on the 3-chain) as the primary path; Candidate 2 (idempotent-monoid M-Set) as the fallback if Candidate 1's reflective subcategory analysis bogs down.

The reasoning has two parts. First, Candidate 1's topos has a known richer subobject classifier and is easier to compute with by hand. Second, both candidates avoid the LT-topology dead-end identified above by working *outside* the small five-topology classification of Set^→ — they admit non-LT reflective subcategories that produce useful distinction structures.

## What Phase 1.1 has settled

Five structural facts about the partition theorem visible from Phase 1.1, two now reflected in the paper and three carried forward:

1. **The four-cell non-vacuity property is non-trivial.** Obvious distinction structures (projections, constant functors at the classifier) fail to inhabit all four cells. [Captured in Remark 5.4 of the paper.]
2. **The coherence axiom is structurally constraining at the structure level.** Many would-be distinction structures fail coherence, so the axiom does work even though the partition proof doesn't use it. [Captured in Remark 5.4 of the paper.]
3. **Distinction structures are closely related to idempotent monads, hence to reflective subcategories.** This identifies sheafification (for any Lawvere-Tierney topology) as a canonical example class. [Captured in Remark 5.5 of the paper.]
4. **The Sierpinski topos is too small for non-vacuity.** Its five Lawvere-Tierney topologies, plus its non-LT reflective subcategories, all fail to produce a configuration with all four cells simultaneously inhabited. [Captured in Remark 5.5 of the paper.]
5. **The minimum-size question is well-posed and open.** What is the smallest elementary topos C admitting a reflective subcategory D ⊆ C such that all four cells of the partition are inhabited at some Y? Phase 1.1 establishes a lower bound (Sierpinski is too small); the upper bound is unknown.

Fact 5 is the natural Phase 1.2 question. A constructive answer (find such a C) would settle the non-vacuity question. A non-constructive answer (prove no such C exists below some size) would be a deeper structural result.

## Open tasks for Phase 1.2

- [ ] Choose base topos: presheaves on 3-chain (recommended) or M-Set for {1, e, f} (fallback).
- [ ] Survey reflective subcategories of the chosen base.
- [ ] Identify a specific reflection (D, η, ι) on the base with a Y for which Sub(D(Y)) has a non-regular middle element with non-trivial complement.
- [ ] Construct one morphism per cell with explicit witness.
- [ ] Mechanize the construction in Lean 4 against Mathlib.
- [ ] Run `#print axioms` on each cell-witness to confirm dependence on standard Mathlib axioms only.
- [ ] Write the math-prose companion `non-vacuity-witness.md` (or analogous, depending on construction).
- [ ] Add §5.6 ("Demonstration") to [`../paper.md`](../paper.md) once the construction lands.
- [ ] Update [`../../lean/ARCHITECTURE.md`](../../lean/ARCHITECTURE.md) with the example sitting under the partition theorem.

## Revised estimated cost for Phase 1.2

Originally estimated at 2-3 weeks. After Phase 1.1's LT-topology classification ruling out Sierpinski: **4-8 weeks**. The escalation to a richer base topos introduces both more mathematical work (analyzing reflective subcategories of the chosen base) and more Lean mechanization work (the richer topos requires more setup in Mathlib). The minimum-size question (Fact 5) could in principle take longer if pursued as a research question rather than as a "find any example" task.

## Provenance

Phase 1.1 conducted on 2026-05-24 in conversation with Anthropic Claude (Cursor IDE), per the project's documented validation architecture. The candidate-survey and LT-topology classification are exploratory mathematical work; verification of all claims will be done mechanically in Phase 1.2. Specific hand computations made in Phase 1.1 and to be checked when Phase 1.2 begins:

- The Heyting complement formulas in Set^→ (used for Candidates A–C and for the LT-topology classification).
- The five-topology enumeration of LT-topologies on Set^→ and the j-sheaf computations for the (mid, mid), (mid, ⊤), and (⊤, ⊤) cases.
- The 6-element subobject lattice and complement structure for X = ({a, b, c}, f: a↦a, b↦a, c↦c) in M-Set (used for Candidate D).

If any of these turns out to have a hand-computation error, the survey conclusions and the corresponding paper remarks should be re-derived. The Lean mechanization in Phase 1.2 will catch any such error.
