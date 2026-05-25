# A Four-Position Partition of Morphisms in Elementary Topoi with Distinction Structure

**Chris Brink**
falsework.dev
May 2026 — preprint, not yet submitted.

---

## Abstract

We define a *distinction structure* on a category as an idempotent endofunctor with unit, encoding the calling axiom of Spencer-Brown's *Laws of Form* (Spencer-Brown 1969) as monadic idempotency. In an elementary topos equipped with a non-trivial distinction structure, we prove that the morphism space partitions into exactly four pairwise-disjoint structural classes, characterized by Heyting conditions on the morphism's image relative to the kernel image (the image of the unit). The four classes are mutually exclusive and jointly exhaustive over morphisms with non-trivial image. The proof reduces to standard Heyting algebra identities and a case analysis on lattice position. The fourth class — the *closure-residue* between a subobject and its double-negation — exists specifically as a feature of non-Boolean intuitionistic structure and collapses in Boolean settings. The construction is formalized in Lean 4 against Mathlib and kernel-checked; the underlying Heyting algebra instance on subobjects of an elementary topos has been contributed to Mathlib as [PR #39618](https://github.com/leanprover-community/mathlib4/pull/39618).

---

## 1. Introduction

The subobject lattice Sub(X) of an object X in an elementary topos carries a Heyting algebra structure (Mac Lane and Moerdijk 1992, IV.6). When the topos is non-Boolean, this Heyting algebra exhibits a specific asymmetry: for a subobject a ∈ Sub(X), the double-negation closure ¬¬a need not equal a, and the strict difference between them — the *closure-residue* — is in general non-trivial.

This paper identifies a structural partition of morphisms into an elementary topos that exploits this closure-residue. We work with an additional categorical structure — a *distinction structure* (D, η, ι) consisting of an endofunctor D with unit η and a coherent idempotency D ⋙ D ≅ D — that encodes the calling axiom of Spencer-Brown (1969) in categorical form. The *kernel image* at an object Y is the subobject Im(η_Y) ∈ Sub(D(Y)), and we ask how the D-image of an arbitrary morphism relates to this kernel image.

We prove that, under the assumption that D is non-trivial (η is not a natural isomorphism), every morphism with non-trivial D-image satisfies exactly one of four pairwise-disjoint Heyting conditions:

- the image lies inside the kernel image (**Infrastructure**),
- the image straddles the kernel image and its complement (**Distribution**),
- the image lies in the closure-residue — inside the double-negation closure but not in the kernel image itself (**Exploitation**),
- the image lies in the Heyting complement (**Refusal**).

The proof is a case analysis whose disjointness reduces to the Heyting identities a ⊓ aᶜ = ⊥ and aᶜ ⊓ aᶜᶜ = ⊥, and whose exhaustiveness follows from the trichotomy of how a subobject can position itself relative to another in a Heyting algebra.

The fourth class (Exploitation) is structurally distinctive: it exists as a separate region of the lattice only because ¬¬a need not equal a. In a Boolean topos the closure-residue collapses, Exploitation merges with its neighbors, and the partition reduces to three classes. The four-fold structure is a specific feature of non-Boolean intuitionistic logic.

The construction is implemented in Lean 4 against Mathlib4 (Mathlib Community 2026) and verified by the kernel. The underlying Heyting algebra instance on Sub(X) for elementary topoi — required by the partition theorem and missing from Mathlib's standard development — has been contributed upstream as [PR #39618](https://github.com/leanprover-community/mathlib4/pull/39618) and follows the Mac Lane–Moerdijk equalizer-residual construction (Mac Lane and Moerdijk 1992, IV.6 Proposition 2).

The paper is organized as follows. Section 2 establishes notation and recalls the relevant categorical structure. Section 3 defines the distinction structure and the kernel image. Section 4 states the four position predicates. Section 5 proves the partition theorem. Section 6 discusses the formalization. Section 7 addresses motivation, related work, and scope limits.

---

## 2. Preliminaries

We work throughout in a category C satisfying the elementary-topos hypothesis bundle currently exposed in Mathlib:

- **HasClassifier**: C has a subobject classifier Ω with universal morphism true: 1 → Ω.
- **HasPullbacks**: C has pullbacks of all cospans.
- **HasEqualizers**: C has equalizers of all parallel pairs.
- **HasInitial**: C has an initial object 0.
- **InitialMonoClass**: the unique morphism 0 → X is monic for every X.
- **HasImages**: every morphism in C has an image factorization.
- **HasBinaryCoproducts**: C has binary coproducts.

This bundle is entailed by C being an elementary topos in the standard sense (Mac Lane and Moerdijk 1992, IV.1; Johnstone 2002a). We work with the explicit bundle rather than a unified elementary-topos typeclass because current Mathlib exposes the constituents rather than a single typeclass for the bundled signature.

For X ∈ Ob(C), Sub(X) denotes the lattice of subobjects of X. Under the stated hypotheses, Sub(X) carries a Heyting algebra structure (Mac Lane and Moerdijk 1992, IV.6 Proposition 2): meet is given by pullback, the bottom subobject is the image of the unique morphism from 0, the top subobject is X itself, the implication P ⇒ Q is the residual constructed as the equalizer of the characteristic morphisms χ_{P⊓Q} and χ_P, and the complement is ¬P = (P ⇒ ⊥).

This Heyting structure is in general non-Boolean. The double-negation operation P ↦ ¬¬P satisfies P ≤ ¬¬P always, with equality iff Sub(X) is Boolean at P. We write Pᶜ for the Heyting complement ¬P and Pᶜᶜ for the double-negation closure ¬¬P. The strict closure-residue at P is the structural region between P and Pᶜᶜ; in non-Boolean settings, this region is non-trivial.

For f: X → Y in C, we write Im(f) for the image of f as a subobject of Y, via the image factorization that HasImages provides.

---

## 3. Distinction Structure

**Definition 3.1.** A *distinction structure* on a category C is a triple (D, η, ι) where:

- D: C ⥤ C is an endofunctor,
- η: 1_C ⟹ D is a natural transformation,
- ι: D ⋙ D ≅ D is a natural isomorphism

satisfying the coherence condition

η_{D(X)} ≫ ι.hom_X = 1_{D(X)}

for every X ∈ Ob(C).

The functor D is the *distinction operation*; η is the *unit* of the distinction; ι is the *idempotency*. The coherence condition relates the two natural morphisms from D(X) to D(X) and reflects the calling axiom of Spencer-Brown (1969): applying the distinction operation to an already-distinguished object is structurally equivalent to the original distinction. Monadic idempotency D ⋙ D ≅ D, together with the coherence condition, is the categorical encoding of Spencer-Brown's "the value of the call is the value of the call."

**Definition 3.2.** A distinction structure (D, η, ι) is *non-trivial* if there exists X ∈ Ob(C) such that η_X is not an isomorphism in C.

Non-triviality is the assumption that the distinction operation produces structural difference somewhere. If η were a natural isomorphism, the distinction would be vacuous and the partition theorem would degenerate.

**Definition 3.3.** For Y ∈ Ob(C), the *kernel image* at Y is the subobject

a_Y := Im(η_Y) ∈ Sub(D(Y)),

via the image factorization of the unit at Y.

The kernel image is the territory in D(Y) that the unit reaches when applied at Y. Sub(D(Y)) is the Heyting algebra in which the partition predicates will be stated.

---

## 4. The Four Position Predicates

For a morphism f: X → Y in C, write img_f := Im(D.map f) ∈ Sub(D(Y)).

**Definition 4.1.** The four *position predicates* on a morphism f: X → Y are:

- IsInfrastructure(f) := img_f ≤ a_Y
- IsDistribution(f) := (img_f ⊓ a_Y ≠ ⊥) ∧ (img_f ⊓ a_Yᶜ ≠ ⊥)
- IsExploitation(f) := (img_f ≤ a_Yᶜᶜ) ∧ ¬(img_f ≤ a_Y)
- IsRefusal(f) := img_f ≤ a_Yᶜ

where ⊥ is the bottom subobject in Sub(D(Y)), and complementation and double-negation are taken in the Heyting algebra of Sub(D(Y)).

Each predicate captures a specific structural relationship between the morphism's D-image and the kernel image. Infrastructure is containment in the kernel image. Distribution is non-trivial straddling of the kernel image and its complement. Exploitation is containment in the closure-residue: inside the double-negation closure but not in the kernel image itself. Refusal is containment in the strict complement.

---

## 5. The Partition Theorem

**Theorem 5.1.** Let C be an elementary topos satisfying the hypothesis bundle of Section 2. Let (D, η, ι) be a non-trivial distinction structure on C. Then for every morphism f: X → Y in C such that img_f ≠ ⊥ in Sub(D(Y)), exactly one of IsInfrastructure(f), IsDistribution(f), IsExploitation(f), IsRefusal(f) holds.

*Proof.* The proof consists of two parts: disjointness and exhaustiveness.

**Disjointness.** For each pair of position predicates, we show their conjunction is incompatible with img_f ≠ ⊥.

*Infrastructure and Refusal disjoint.* Suppose IsInfrastructure(f) ∧ IsRefusal(f). Then img_f ≤ a_Y ⊓ a_Yᶜ = ⊥, contradicting img_f ≠ ⊥.

*Infrastructure and Exploitation disjoint.* IsExploitation(f) requires ¬(img_f ≤ a_Y), which directly contradicts IsInfrastructure(f) := img_f ≤ a_Y.

*Infrastructure and Distribution disjoint.* IsInfrastructure(f) gives img_f ≤ a_Y, hence img_f ⊓ a_Yᶜ ≤ a_Y ⊓ a_Yᶜ = ⊥, contradicting the second conjunct of IsDistribution(f).

*Refusal and Exploitation disjoint.* Suppose IsRefusal(f) ∧ IsExploitation(f). Then img_f ≤ a_Yᶜ ⊓ a_Yᶜᶜ = ⊥ (using the Heyting identity aᶜ ⊓ aᶜᶜ = ⊥), contradicting img_f ≠ ⊥.

*Refusal and Distribution disjoint.* IsRefusal(f) gives img_f ≤ a_Yᶜ, hence img_f ⊓ a_Y ≤ a_Yᶜ ⊓ a_Y = ⊥, contradicting the first conjunct of IsDistribution(f).

*Exploitation and Distribution disjoint.* Suppose IsExploitation(f) ∧ IsDistribution(f). IsExploitation(f) gives img_f ≤ a_Yᶜᶜ. The first conjunct of IsDistribution(f) gives img_f ⊓ a_Y ≠ ⊥. The second conjunct gives img_f ⊓ a_Yᶜ ≠ ⊥. But img_f ≤ a_Yᶜᶜ implies img_f ⊓ a_Yᶜ ≤ a_Yᶜᶜ ⊓ a_Yᶜ = ⊥, contradicting the second conjunct.

**Exhaustiveness.** Let f satisfy img_f ≠ ⊥. We proceed by case analysis on whether img_f ≤ a_Y, and on the meet structure of img_f with a_Y and its complement.

*Case 1.* img_f ≤ a_Y. Then IsInfrastructure(f) holds.

*Case 2.* ¬(img_f ≤ a_Y) and img_f ⊓ a_Y = ⊥. In any Heyting algebra, b ⊓ a = ⊥ ↔ b ≤ aᶜ. Hence img_f ≤ a_Yᶜ, so IsRefusal(f) holds.

*Case 3.* ¬(img_f ≤ a_Y) and img_f ⊓ a_Y ≠ ⊥ and img_f ⊓ a_Yᶜ ≠ ⊥. Then IsDistribution(f) holds.

*Case 4.* ¬(img_f ≤ a_Y) and img_f ⊓ a_Y ≠ ⊥ and img_f ⊓ a_Yᶜ = ⊥. The third condition gives img_f ≤ a_Yᶜᶜ. Combined with ¬(img_f ≤ a_Y), this gives IsExploitation(f).

The four cases are exhaustive: they cover all combinations of the binary conditions (img_f ≤ a_Y) and (img_f ⊓ a_Y = ⊥) and (img_f ⊓ a_Yᶜ = ⊥). Disjointness was established above. □

**Remark 5.2.** The exhaustiveness of the four cases relies on the trichotomy in the Heyting algebra of subobjects: any subobject b is either contained in a, or has trivial meet with a, or has non-trivial meet with a without being contained. The fourth case (Exploitation) splits the third by checking the meet with the complement. This case structure is exhaustive in any Heyting algebra but produces non-trivial distinct classes only when the algebra is non-Boolean.

**Remark 5.3.** In a Boolean topos, where aᶜᶜ = a for all a ∈ Sub(X), the Exploitation predicate becomes (img_f ≤ a_Y) ∧ ¬(img_f ≤ a_Y), which is unsatisfiable. The partition reduces to three classes. The four-position structure is therefore specifically a feature of non-Boolean intuitionistic topoi.

**Remark 5.4.** The proof of Theorem 5.1 does not invoke the idempotency or coherence axioms of Definition 3.1; the partition argument uses only the action of D on morphisms, the unit η at Y, and the Heyting structure of Sub(D(Y)). The theorem therefore holds for any endofunctor-with-unit (D, η) on C satisfying the hypothesis bundle of Section 2. The full distinction-structure apparatus encodes the intended Spencer-Brown semantics — applying the distinction operation to an already-distinguished object is structurally trivial — but the partition itself is purely lattice-theoretic. The axioms are nonetheless *structurally constraining* at the level of admissible (D, η, ι): a constructive investigation (see [`examples/construction-choice.md`](examples/construction-choice.md)) finds that many natural endofunctor-with-unit candidates on small toposes — the codomain-projection endofunctor on Set^→, constant functors at the subobject classifier, hand-engineered constant-image variants — fail the coherence condition η_{D(X)} ≫ ι.hom_X = 1_{D(X)}. A weakening of Definition 3.1 to "endofunctor with unit" would broaden the theorem's hypothesis class substantially, admitting pathological structures alongside the Spencer-Brown-faithful ones. The axioms are doing work at the level of *which structures are admissible* even though they are not load-bearing in the proof itself.

**Remark 5.5.** An *idempotent monad* on C is a monad (T, η, µ) with µ: T ∘ T → T a natural isomorphism. Idempotent monads on C correspond, up to equivalence, to reflective subcategories D ⊆ C: the Eilenberg-Moore category of an idempotent monad is the reflective subcategory of η-fixed objects, and conversely every reflection composed with inclusion produces an idempotent monad (Borceux 1994, Vol. 1, §4.2). Every idempotent monad satisfies the conditions of Definition 3.1 (taking ι.hom := µ; the left unit law gives coherence and µ being an iso gives idempotency). Conversely, Definition 3.1 imposes only the left unit law and idempotency, not the right unit law or associativity, so distinction structures are *a priori* more general than idempotent monads; the well-behaved cases coincide.

The connection identifies a canonical source of distinction structures: every reflective subcategory of every elementary topos provides one, and in particular sheafification for any Lawvere-Tierney topology j on C is an idempotent monad. The partition theorem can therefore be read as a statement about morphism structure induced by reflection onto any reflective subcategory of an elementary topos — a categorical interpretation that situates the apparatus inside mainstream topos theory rather than treating the (D, η, ι) signature as bespoke framework apparatus.

The corresponding non-vacuity question — *does some concrete reflective subcategory of some elementary topos produce a configuration in which all four cells of the partition are simultaneously inhabited?* — is open. Phase 1.1 of an in-progress investigation ([`examples/construction-choice.md`](examples/construction-choice.md)) establishes that the Sierpinski topos Set^→ is too small for this: it admits exactly five Lawvere-Tierney topologies (the trivial topology, the double-negation topology, two intermediate topologies whose sheaves are trivial, and the maximal topology), of which only the double-negation case gives a non-trivial sheafification, and that sheafification lands in the Boolean part of the topos and collapses Exploitation. A non-vacuous witness requires either a richer base topos or a non-sheafification reflective subcategory. The investigation is ongoing.

---

## 6. Formalization

The theorem and supporting infrastructure are formalized in Lean 4 against Mathlib4 at a recent pin. The formalization comprises:

- A definition of `DistinctionStructure` as a structure type bundling D, η, and ι with the coherence condition.
- Position predicates `IsInfrastructure`, `IsDistribution`, `IsExploitation`, `IsRefusal` as defined in Section 4.
- Supporting lemmas for pairwise disjointness, each reducing to the relevant Heyting identity.
- The partition theorem `four_position_partition` proving exhaustive disjoint partition.

Kernel verification through `#print axioms` confirms that `four_position_partition` and all supporting theorems depend on exactly the standard Mathlib axioms (`propext`, `Classical.choice`, `Quot.sound`) with no `sorry` declarations in the transitive dependency closure. The formalization is available at the project repository (Brink 2026).

The two formalizable claims of Remarks 5.3 and 5.5 — the partition-level Boolean collapse and the idempotent-monad bridge — are mechanized in a separate companion module `FalseWork.Positions.SpencerBrown`. `boolean_partition_three_cells` lifts `exploitation_requires_nonBoolean` (the cell-level Boolean collapse) through `four_position_partition` to obtain a three-cell exhaustive disjoint partition under the local Boolean hypothesis on the subobject lattice of D(Y). `DistinctionStructure.ofIdempotentMonad` constructs a distinction structure from any Mathlib `Monad C` whose multiplication is a natural isomorphism, with the coherence condition discharged via the monad's left-unit law. Both are kernel-checked against the standard three axioms; neither closes the open construction question of Remark 5.5 in the reverse direction (whether every distinction structure of Definition 3.1 arises from an idempotent monad), which remains an open Zulip question at the time of writing.

A further companion module `FalseWork.Positions.CanonizationClosure` formalizes a *conditional* recursive partition theorem: given a canonization-closure witness (data of an idempotent monad with iso multiplication) for a morphism `f`, the four-position partition theorem applies to the induced distinction structure on the ambient topos, producing a secondary four-cell classification of every morphism relative to the canonization figure. This is the closure layer of the framework's canonization apparatus (cf. companion document [`closure-canonization.md`](closure-canonization.md)); the recursive partition is a direct application of `four_position_partition` to the structure produced by `DistinctionStructure.ofIdempotentMonad` and is kernel-checked against the standard three axioms. The substantive open question of the closure layer is the specification of *which* idempotent monads count as canonization closures of a given morphism; three candidate predicates are surveyed in the companion document and selection is deferred pending substantive future work.

The Heyting algebra structure on Sub(X) for elementary topoi — required by the partition theorem but not present in Mathlib at the time of this work — has been contributed upstream as Pull Request [#39618](https://github.com/leanprover-community/mathlib4/pull/39618) to mathlib4 (Brink 2026, PR). The PR implements the Mac Lane–Moerdijk equalizer-residual construction (Mac Lane and Moerdijk 1992, IV.6 Proposition 2): implication is defined as `Subobject.mk (equalizer.ι (χ (P ⊓ Q).arrow) (χ P.arrow))`, and the Galois connection R ≤ P ⇒ Q ↔ R ⊓ P ≤ Q is established through six private bridging lemmas. The hypothesis bundle required by the PR matches that of Theorem 5.1.

The development was undertaken with AI collaboration using Cursor with Anthropic Claude as the underlying model, in accordance with the project's documented validation architecture (Brink 2026, Paper 2). The kernel verification is independent of AI assistance: Lean's kernel mechanically checks the proof against the type theory regardless of how the proof terms were constructed.

---

## 7. Motivation, Related Work, and Scope

### 7.1 Motivation

The partition theorem emerged from the development of the FalseWork project (Brink 2026, Paper 1), a cross-domain structural analysis framework that proposes practitioners across creative and intellectual domains distribute into a small number of structural positions relative to generative operations that produce irreducible features. The four positions of the theorem are intended to formalize this structural typology in the categorical setting where it admits precise statement.

The framework operates with the intuition that an asymmetry in a domain forces a distinction operation, which when iterated produces a kernel whose failure to close on itself generates an irreducible structural gap. The four positions represent the structurally distinct ways practitioners can relate to this gap: by operating in the territory the kernel reaches (Infrastructure), by distributing across the boundary (Distribution), by working in the asymmetric closure-residue (Exploitation), or by operating in the strict complement (Refusal).

The theorem establishes that whenever this structural intuition can be formalized as a non-trivial distinction structure on an elementary topos, the four positions arise as a necessary and exhaustive partition. The framework's broader claim — that specific domains across music, cinema, painting, literature, software, and physics instantiate this structural condition — is an empirical claim about each domain that the theorem does not itself establish.

### 7.2 Related Work

**Spencer-Brown.** *Laws of Form* (Spencer-Brown 1969) introduces the calling axiom and the crossing axiom as foundational moves for a calculus of distinctions. Monadic idempotency D ⋙ D ≅ D in categorical settings is a natural translation of the calling axiom. Prior categorical work on Spencer-Brown's calculus includes Kauffman (various) and the broader cybernetic tradition; the specific encoding of the calling axiom as the idempotency component of an endofunctor-with-unit structure, applied to elementary topoi, follows the framework's development (Brink 2026, Paper 1, Paper 3) and does not appear in the standard topos theory literature surveyed by the author. A companion document [`spencer-brown-anchor.md`](spencer-brown-anchor.md) develops the structural correspondence in detail: Definition 3.1 lifts the calling axiom into category theory; the partition theorem's four cells read as four Spencer-Brown registers (under the mark, straddling the mark, in the failure-of-crossing residue, crossed out); and Exploitation is identified as the cell that exists precisely because Spencer-Brown's crossing axiom (the Boolean condition ¬¬p = p) fails in non-Boolean Heyting algebras.

**Mac Lane and Moerdijk.** The Heyting algebra structure on subobjects of an elementary topos (Mac Lane and Moerdijk 1992, IV.6, IV.8) is the standard reference for the construction the partition theorem depends on. The PR #39618 formalization follows IV.6 Proposition 2 directly.

**Mathematical music theory.** Mazzola's topos-theoretic framework for music (Mazzola 2002) provides categorical apparatus for musical structure that operates in adjacent territory to the framework's interest in music as a domain instantiating the partition. Tymoczko's voice-leading geometry (Tymoczko 2011) provides a different but related categorical perspective. Whether either framework's specific categorical setting supports a non-trivial distinction structure of the kind required by the partition theorem is open work.

**Reflective subcategories and idempotent monads.** As recorded in Remark 5.5, the distinction structures of Definition 3.1 are closely related to idempotent monads on C, and idempotent monads on a category correspond to reflective subcategories of it (Borceux 1994, Vol. 1, §4.2; Adámek and Rosický 1994). Sheafification for a Lawvere-Tierney topology on a topos is the canonical example. The framing of the partition theorem as a statement about reflection-induced morphism partitions — i.e., a structural statement about how morphisms of an elementary topos distribute relative to the kernel image of the reflection unit, organized by Heyting position in the parent topos's subobject lattice — does not appear in the standard literature on reflective subcategories or sheafifications surveyed by the author. Standard treatments focus on the algebraic properties of reflections (closure under limits, the localization equivalence, the Eilenberg-Moore correspondence) rather than on the closure-residue / non-Boolean structure of subobject lattices in the parent topos.

**Categorical logic and topos theory.** Standard references include Johnstone (2002a, 2002b), Awodey (2010), Lawvere (1969). The non-Boolean character of subobject lattices in elementary topoi is well-established; the framing as a structural partition with the specific Heyting conditions of Section 4 has not been located in the standard literature.

### 7.3 Scope

The theorem establishes a structural partition in elementary topoi with non-trivial distinction structure. Several questions are deliberately not addressed.

The theorem does not establish that any specific domain instantiates the structural condition. Whether music, cinema, painting, literature, software, physics, or other domains have the categorical structure the theorem requires is empirical work that the framework pursues separately (Brink 2026, Paper 3 on music; Paper 5 on the Pythagorean comma specifically).

The theorem does not validate classifications of specific works or practitioners as occupying specific positions. The framework's broader claims about Bach as Infrastructure, Coltrane as Exploitation, Schoenberg as Refusal, and similar classifications across domains are supported by specialist correspondence (Tymoczko, Cutting, Suhr) and by structural analysis of specific works, but they require domain-level construction of the relevant categorical settings to be made formal.

The theorem does not address the framework's *Commitment gate* — a binary predicate operating orthogonally within each position to characterize structural completion. The gate is documented as schema-level architecture in the framework's papers (Brink 2026, [`comma-formal-structure-note`](../../papers/comma-formal-structure-note.md)) and has been shown through formalization testing to not admit theorem-grade unification of its four position-specific extension operators.

The theorem does not claim novelty as topos theory in any strong sense. The mathematical building blocks are standard. The framing as a structural partition with these specific Heyting conditions tied to the distinction-structure apparatus does not appear in the standard topos theory literature the author has surveyed; specialist literature search has not been undertaken and prior work in adjacent registers may exist that has not been located.

---

## Acknowledgments

Thanks to Edward van de Meent and Fernando Chu for substantive engagement on the Mathlib gap in a Lean Zulip thread that shaped the construction's contribution form. Thanks to the broader specialist correspondence that supported the framework's development: Dmitri Tymoczko for music kernel corroboration, James Cutting for cinema kernel engagement, Ilya Levin for ongoing substantive correspondence on the relationship between the framework and his geometric apparatus for AI cognition. The Lean 4 community and Mathlib contributors provide the formal infrastructure on which this work rests.

---

## References

- Adámek, J., and Rosický, J. (1994). *Locally Presentable and Accessible Categories*. London Mathematical Society Lecture Note Series 189, Cambridge University Press.
- Awodey, S. (2010). *Category Theory* (2nd ed.). Oxford Logic Guides, Oxford University Press.
- Borceux, F. (1994). *Handbook of Categorical Algebra*, 3 volumes. Encyclopedia of Mathematics and its Applications 50–52, Cambridge University Press.
- Brink, C. (2026). *FalseWork Papers*. [github.com/thefalsework/papers](https://github.com/thefalsework/papers).
- Brink, C. (2026, PR). *Heyting algebra structure on Subobject in elementary topoi*. Mathlib4 Pull Request #39618. [github.com/leanprover-community/mathlib4/pull/39618](https://github.com/leanprover-community/mathlib4/pull/39618).
- Johnstone, P. T. (2002a). *Sketches of an Elephant: A Topos Theory Compendium, Volume 1*. Oxford Logic Guides, Oxford University Press.
- Johnstone, P. T. (2002b). *Sketches of an Elephant: A Topos Theory Compendium, Volume 2*. Oxford Logic Guides, Oxford University Press.
- Lawvere, F. W. (1969). Adjointness in foundations. *Dialectica*, 23(3-4), 281–296.
- Mac Lane, S., and Moerdijk, I. (1992). *Sheaves in Geometry and Logic: A First Introduction to Topos Theory*. Universitext, Springer-Verlag.
- Mathlib Community (2026). *Mathlib4*. [github.com/leanprover-community/mathlib4](https://github.com/leanprover-community/mathlib4).
- Mazzola, G. (2002). *The Topos of Music: Geometric Logic of Concepts, Theory, and Performance*. Birkhäuser.
- Spencer-Brown, G. (1969). *Laws of Form*. Allen and Unwin.
- Tymoczko, D. (2011). *A Geometry of Music: Harmony and Counterpoint in the Extended Common Practice*. Oxford University Press.
