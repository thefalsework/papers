# Canonization as Closure

## A Closure Framework for the Structural Effects of Commitment-Yes

**Chris Brink**
falsework.dev
May 2026 — companion to [`paper.md`](paper.md), drafted as a sketch and not yet a complete development.

---

## Abstract

The four-position partition theorem of [`paper.md`](paper.md) classifies morphisms in an elementary topos with non-trivial distinction structure into four pairwise-disjoint structural cells. The framework's *Commitment gate* (cf. [`../../lean/FalseWorkPapers/Positions/CommitmentGate.lean`](../../lean/FalseWorkPapers/Positions/CommitmentGate.lean)) is a binary fixedness condition applied within each cell, currently formalized at schema level with placeholder per-cell iteration content. This document opens a *structurally different* question: not "what is Commitment-yes?" but "what are the **structural consequences** of being Commitment-yes for the rest of the morphism space?" The thesis advanced here is that commitment-yes morphisms generate *reflective subcategories* of the ambient topos, that these reflections induce new distinction structures via the idempotent-monad bridge formalized in [`../../lean/FalseWorkPapers/Positions/SpencerBrown.lean`](../../lean/FalseWorkPapers/Positions/SpencerBrown.lean), and that the four-position partition theorem applied to the induced distinction structure produces a *recursive* secondary classification — every morphism in the ambient topos receives a four-cell sub-classification relative to the canonization figure. The framework eats itself one level deeper around stabilized practitioners. A *conditional* form of the recursive partition theorem is kernel-checked in Lean at [`../../lean/FalseWorkPapers/Positions/CanonizationClosure.lean`](../../lean/FalseWorkPapers/Positions/CanonizationClosure.lean); the load-bearing piece left as open mathematical work is the precise specification of *which* idempotent monads count as canonization closures of a given morphism.

---

## 1. Motivation

The framework's existing structural dictionary contains two distinct layers:

* **Classification (theorem-grade).** The four-position partition theorem (Theorem 5.1 of [`paper.md`](paper.md)). Every morphism with non-trivial D-image falls into exactly one of Infrastructure, Distribution, Exploitation, or Refusal. Kernel-checked in Lean.

* **Commitment (schema-grade).** Within each cell, a binary fixedness condition — Commitment-yes or Commitment-no — characterizing morphisms at their cell's structural limit. The schema is uniform across cells (cf. [`CommitmentGate.lean`](../../lean/FalseWorkPapers/Positions/CommitmentGate.lean)); the per-cell iteration content is open framework work.

What neither layer addresses is the *historical* phenomenon that practitioners who become Commitment-yes in their cell appear to alter the structural geometry of the cell itself for everyone who works in it subsequently. Bach exists in the historical record as Infrastructure-yes in the music topos; after Bach, the question for a later composer is not merely "what position in the partition does this work occupy?" but "what position does this work occupy *relative to Bach*?" Coltrane exists as Exploitation-yes in late jazz; after Coltrane, the question for a later improvising musician includes "what position relative to Coltrane?" Schoenberg as Refusal-yes; after Schoenberg, the question for a later composer of atonal or twelve-tone music includes "what position relative to Schoenberg?"

The pattern is not specific to one cell. It applies across the partition: a Commitment-yes morphism at any position generates a *second axis* of classification operating within (and possibly beyond) its cell. Subsequent works are positioned both in the original four-cell partition and in a four-cell sub-partition centered on the canonized figure.

This document proposes a categorical formalization of that pattern. The proposal is *conditional* — it identifies the data of a *canonization closure* as the load-bearing object, formalizes the recursive partition theorem in terms of that data, and leaves as an open mathematical question *which* concrete categorical constructions instantiate the closure data for which morphisms. The structural shape of the recursion, however, is precisely specifiable, and a conditional form of the recursive partition theorem is mechanizable in Lean as a composition of existing theorems.

---

## 2. The closure intuition

The intuition is most easily stated through analogy and example.

**Cities and bridges.** Before a bridge spans a river, traffic distributes across many crossings — ferries, fords, longer overland routes. The bridge's construction does not *forbid* the other crossings, but it reorganizes the topology of motion around itself. The bridge is not a destination; it is a passage point that subsequent infrastructure (roads, markets, neighborhoods) accretes around. A canonization-yes morphism is structurally akin to a bridge: it does not capture every subsequent morphism in its cell, but it reorganizes the cell's topology around itself.

**Bach as Infrastructure-axis.** Before Bach, tonal organization existed in scattered, locally-coherent practices. After Bach, tonal music has *the Bach axis*: counterpoint pedagogy, the well-tempered system as institutional fact, the chorale harmonization as exemplar. A later composer's tonal work positions itself relative to Bach — some inside the territory Bach organized (Sub-Infrastructure of Infrastructure at the Bach axis), some straddling (Sub-Distribution at Bach), some in the asymmetric closure of Bach-canonical without fully entering it (Sub-Exploitation at Bach), some in the complement (Sub-Refusal at Bach, where post-tonal work classifies even when its global position is Infrastructure-adjacent). The work of a working composer in 1850, 1920, 1960, and 2020 is differently positioned not only in the global four-cell partition but in the *Bach sub-partition* of whichever cell it inhabits.

**Schoenberg as Refusal-axis.** Before Schoenberg, atonality existed as scattered experiments. After Schoenberg, there is *the Schoenberg axis*: serial method, twelve-tone procedure, institutional pedagogy of post-tonal composition. A later atonal or post-tonal composer's work positions itself relative to Schoenberg — some inside the territory Schoenberg organized (the serialists at darmstadt as Sub-Infrastructure at the Schoenberg axis within Refusal globally), some in active negotiation with it (later atonalists, spectralists, post-minimalists as various sub-positions at the Schoenberg axis).

**The pattern across cases.** Whatever cell a canonized morphism inhabits, the cell appears to develop a *second-order partition* organized around the canonized morphism. This is the closure phenomenon the framework wants to formalize.

---

## 3. The mathematical proposal

The proposal in one sentence: **a commitment-yes morphism `f` at position `P` generates a reflective subcategory `S_f` of the ambient topos `C`, the reflection induces an idempotent monad `T_f`, and the four-position partition theorem applied to the distinction structure induced by `T_f` produces a recursive secondary classification of every morphism in `C`.**

Spelled out structurally:

1. **Start with a distinction structure `Δ` on an elementary topos `C`.** The four-position partition theorem applies; every morphism `g` with non-trivial D-image is classified by `Δ` into exactly one of the four cells.

2. **Suppose `f : X → Y` is commitment-yes at its position `P`.** The Commitment-yes condition (per [`CommitmentGate.lean`](../../lean/FalseWorkPapers/Positions/CommitmentGate.lean), schema-level: `f` is at the structural limit of cell-restricted iteration) is the *trigger* for the closure layer to engage. The structural content of "is commitment-yes" is the schema-grade material in `CommitmentGate.lean`; the closure layer takes commitment-yes as given and asks about its consequences.

3. **Posit a canonization closure for `f`.** This is data of an idempotent monad `T_f : Monad C` together with `IsIso T_f.μ`. Mathematically, by Borceux (1994, Vol. 1, §4.2), this is equivalent to a reflective subcategory `S_f ⊆ C`. The closure represents the "stable operational territory" that `f` generates — the closure under composition, transformation, inheritance, reinterpretation, and extension that the analogy in §2 gestures at.

4. **The induced distinction structure.** By `DistinctionStructure.ofIdempotentMonad` (kernel-checked in [`SpencerBrown.lean`](../../lean/FalseWorkPapers/Positions/SpencerBrown.lean) as of 2026-05-24), the idempotent monad `T_f` gives rise to a distinction structure `Δ_f : DistinctionStructure C` whose D-functor is `T_f.toFunctor`, whose unit is `T_f.η`, and whose idempotency is `asIso T_f.μ`. The coherence condition follows from the monad's left-unit law.

5. **The recursive partition.** By the four-position partition theorem (Theorem 5.1 of [`paper.md`](paper.md), kernel-checked in [`Partition.lean`](../../lean/FalseWorkPapers/Positions/Partition.lean)) applied to `Δ_f`, every morphism `g : A → B` in `C` with non-trivial `Δ_f`-image satisfies exactly one of `IsInfrastructure Δ_f g`, `IsDistribution Δ_f g`, `IsExploitation Δ_f g`, `IsRefusal Δ_f g`.

6. **Two-axis classification.** A morphism `g` therefore carries *two* four-cell classifications: its position in the original `Δ`-partition, and its position in the `Δ_f`-partition. The pair of positions is the framework's secondary structural fingerprint of `g`, calibrated relative to the canonization figure `f`.

The recursive partition is the framework eating itself. The same partition theorem applies twice — once to classify morphisms globally, once to classify them relative to a canonized axis — using the same partition theorem and the same definitional apparatus, just instantiated with a different distinction structure.

---

## 4. The conditional theorem, formalized

The recursive partition theorem, as a *conditional* statement on the closure data, is:

> *Recursive partition (conditional on canonization closure).* Let `C` be an elementary topos satisfying the hypothesis bundle of [`paper.md`](paper.md) §2. Let `Δ` be a distinction structure on `C`. Let `f : X → Y` be a morphism in `C`. Suppose `cc` is a canonization-closure witness for `f` relative to `Δ` (data: an idempotent monad `T_f` on `C` with `IsIso T_f.μ`). Then the induced distinction structure `cc.inducedDistinction := DistinctionStructure.ofIdempotentMonad T_f` partitions the morphism space of `C` into the four cells of the partition theorem: for every `g : A → B` with non-trivial `cc.inducedDistinction`-image, exactly one of `IsInfrastructure cc.inducedDistinction g`, `IsDistribution cc.inducedDistinction g`, `IsExploitation cc.inducedDistinction g`, `IsRefusal cc.inducedDistinction g` holds, with the same pairwise-disjointness clauses as Theorem 5.1.

This is provable in Lean by direct composition of `DistinctionStructure.ofIdempotentMonad` (from `SpencerBrown.lean`) with `four_position_partition` (from `Partition.lean`). The theorem is therefore mechanizable as a single-line proof against the existing tree, and it is kernel-checked in the companion module [`CanonizationClosure.lean`](../../lean/FalseWorkPapers/Positions/CanonizationClosure.lean) as `recursive_partition`. `#print axioms` reports only the three standard Mathlib axioms.

**What this theorem says, and does not say.** The conditional theorem says: *if* the closure data exists for `f`, then the recursive partition operates as expected. It does *not* say which morphisms admit closure data, nor under what conditions the closure exists, nor that the closure is unique up to natural equivalence. Those are the load-bearing open questions of §5.

The conditional theorem is therefore an exhibit of *structural readiness*: the framework's existing infrastructure suffices to express and prove the recursive partition once the closure data is provided. The substantive remaining work is mathematical (specifying the closure construction), not formal (the conditional theorem is already kernel-checked).

---

## 5. The load-bearing question: what does "generates" mean?

The conditional theorem requires only the *data* of an idempotent monad `T_f` (with `μ` an iso) on `C`. It does not require that `T_f` is in any specific sense *generated by* `f`. Without a generation predicate, the theorem is trivially applicable to any idempotent monad and the connection to canonization is severed: every idempotent monad would be "the canonization closure of every morphism." That is mathematically vacuous and historically false.

The load-bearing question is therefore: **what additional predicate `Generates Δ f T_f` distinguishes canonization closures of `f` from arbitrary idempotent monads?**

Three candidate predicates are surveyed below. Each has tradeoffs; the framework's empirical work on canon formation does not currently distinguish between them. Selecting one is a substantive mathematical decision that this document does not make.

### 5.1 Smallest reflective subcategory containing `Y`

**Predicate.** `T_f` is the smallest idempotent monad on `C` whose Eilenberg-Moore category contains `Y` (the codomain of `f`).

**Existence.** The intersection of reflective subcategories of `C` need not be reflective in general. Smallness requires either additional structure (well-poweredness, presentability of `C`) or restriction to subcategories satisfying a coherence condition (e.g., closure under colimits of a specified shape). Under standard hypotheses on elementary topoi (which include Mathlib's `HasColimits` if assumed), this candidate is well-defined.

**Strengths.** Cleanly mathematically. Connects to standard categorical apparatus (Adámek-Rosický 1994 on locally presentable and accessible categories). Naturally parameterized by the codomain `Y` rather than by `f` itself — which matches the intuition that "Bach" as canonization refers to a *body of work* rather than to a single morphism.

**Weaknesses.** Parameterized by `Y` alone, not by `f`. Two morphisms with the same codomain would have the same canonization closure. This may or may not match the historical phenomenon; cases where two figures share a codomain (e.g., two composers working in the same key) but generate different closures would falsify this candidate.

### 5.2 Smallest reflective subcategory through which `f` factors

**Predicate.** `T_f` is the smallest idempotent monad on `C` such that `f : X → Y` factors as `f = g ≫ h ≫ k` where `h : T_f.obj W → T_f.obj W'` is a morphism in the Eilenberg-Moore category for some `W, W'`.

**Existence.** As above, requires either presentability or a coherence restriction.

**Strengths.** Genuinely parameterized by `f`, not just by `Y`. Two morphisms with the same codomain but different "structural signatures" can generate different closures. Closer to the canon-figure intuition: it is *how* Bach organizes tonal counterpoint, not merely *what range of pitches* Bach's works inhabit, that matters.

**Weaknesses.** The factorization condition is technically involved, and the "smallest" qualifier requires checking that factorization-through-T_f is preserved by intersections of reflective subcategories. The construction has not been published in the form needed (to the author's knowledge after a non-exhaustive survey).

### 5.3 Generated by the orbit of `f` under cell-restricted iteration

**Predicate.** `T_f` is the idempotent monad obtained by taking the sequential colimit of cell-restricted iterations of `D` applied to `f`'s structural orbit, then reflecting onto the limit. (Specifying this precisely requires the cell-restricted iteration operators of `CommitmentGate.lean`, which are themselves open work.)

**Strengths.** Directly connects the Commitment gate (binary fixedness under cell-restricted iteration) to the closure (the *limit* of that iteration). The two layers become structurally adjacent rather than independent: commitment-yes ≈ "f reaches the colimit of cell-restricted iteration," and the canonization closure is *that colimit reflected back into `C`*.

**Weaknesses.** Inherits the open-ness of the per-cell iteration content. Cannot be specified independently of the schema-grade work in `CommitmentGate.lean`.

### 5a. The generator refinement (the resolution layer)

The closure framework as developed in §§3–5 specifies the *region* of structural reach a canonization figure has within the ambient topos. A natural refinement adds the condition that, within that region, the figure also acts as a *resolving instrument* — distinctions among later morphisms become legible through composition with maps out of the canonization codomain. This refinement parallels the closure layer in form (an additional structural condition on the canonization data) but addresses a structurally distinct question: not "where does the canonization have reach?" but "within that reach, what does the canonization enable detection of?"

**The categorical condition.** An object `G ∈ C` is a *separator* (or *generator*, in some sources) if morphisms in `C` are determined by their composition with maps out of `G`: for any parallel pair `g₁, g₂ : A ⟶ B`, if `h ≫ g₁ = h ≫ g₂` for every `h : G ⟶ A`, then `g₁ = g₂`. Equivalently, maps out of `G` distinguish any pair of distinct parallel morphisms in `C`. This is the standard categorical separator definition (Mac Lane 1971, Borceux 1994); it identifies an object whose morphisms-out resolve equality.

**The refined canonization data.** A *canonization-generator witness* for `f : X ⟶ Y` relative to `Δ` carries the data of a canonization closure (per §§3–5) *together with* a witness that `Y` is a separator for `C`. The two-layer structure is:

> *Canonization-yes (with resolution)*: `f` admits an idempotent monad `T_f` with `IsIso T_f.μ` (the closure data) *and* `Y` is a separator for the ambient category `C` (the resolution data).

The closure data gives the *region* where the canonization figure has structural reach; the separator data gives the *resolution* with which the figure can be used to distinguish morphisms within that region.

**The Spencer-Brown reading.** Within the calculus of distinctions, the closure layer says the canonization figure has *drawn a stable mark* that organizes a sub-region of the form-space. The generator layer says the canonization figure is *the form against which other forms in that region are compared* — the mark whose calling resolves the distinctions of forms operating in its territory. Bach is not merely the source of the tonal-counterpoint region (closure); within that region, Bach-mediated comparisons resolve equalities and distinctions among later tonal works (generator).

**Concrete examples (informal, illustrative).**

* *Bach as separator.* Maps from the structurally-rich Bach codomain into any tonal-music object resolve distinctions among later tonal morphisms. Two tonal works are structurally equal iff they agree under all Bach-mediated comparisons (the chorale harmonization test, the fugue construction test, the well-tempered organization test). This is the formal reading of "tonal music is taught through Bach" — pedagogy is the operational form of the separator condition.

* *Coltrane as separator.* Within the post-bop jazz topos, maps from the late-Coltrane codomain (with its sheets-of-sound structure and harmonic-spiritual organization) resolve distinctions among post-1960 improvisational morphisms. Whether a later solo agrees with another, as a structural matter, becomes decidable through Coltrane-mediated comparison.

* *Schoenberg as separator.* Within the post-tonal topos, maps from the Schoenberg codomain (twelve-tone procedure, set-class organization, hexachordal combinatoriality) resolve distinctions among post-tonal works. Two atonal works are structurally equal iff they agree under all Schoenberg-mediated comparisons.

These illustrations are interpretive in the same sense as §6's worked example: no specific Lean topos is formally constructed, no specific separator condition is verified for any specific codomain object. The illustrations show what the generator refinement *would* assert if the formal apparatus were filled in.

**The conditional separation theorem.** Given a canonization-generator witness for `f`, parallel morphisms in `C` are determined by their composition with maps out of the canonization codomain `Y`. This is the framework's resolution theorem; its statement is `canonization_separation` in [`CanonizationClosure.lean`](../../lean/FalseWorkPapers/Positions/CanonizationClosure.lean), kernel-checked against the standard three Mathlib axioms.

**Why this refinement is mathematically tractable now.** Unlike the closure's `Generates` predicate (which involves substantive open mathematics about smallest reflective subcategories), the separator condition is mathematically standard and concretely formalizable. Mathlib has separator-related apparatus in `CategoryTheory.Generator` and the separator definition admits no ambiguity. The framework's open question for the generator layer is therefore not *what does separator mean* but *which canonization figures' codomains satisfy it*. This is an empirical/historical question rather than a mathematical-foundations question.

**Two layers together.** The full canonization apparatus, as developed in this document, is the conjunction of the closure layer (§§3–5) and the generator layer (this section). Both are formalized in `CanonizationClosure.lean`; the file's `CanonizationGenerator` structure extends `CanonizationClosure` with the separator field, and the two conditional theorems (`recursive_partition` and `canonization_separation`) deliver the framework's structural and resolution content respectively. The framework's empirical canonization figures — Bach, Coltrane, Schoenberg, and others — are conjectured to admit canonization-generator witnesses; verifying this for any specific case is open work.

### 5.4 Comparison

Candidates 5.1 and 5.2 are reasonable first targets. Candidate 5.3 is conceptually attractive but operationally blocked by the per-cell iteration content. The framework's choice between 5.1 and 5.2 turns on whether the canonization-axis intuition is "the territory of the codomain" (5.1) or "the territory of the structural signature" (5.2). The empirical canon-formation data the framework's broader work collects is not currently in a form that distinguishes these.

The Lean formalization in `CanonizationClosure.lean` is *agnostic* between the candidates: the `CanonizationClosure` structure carries the data of an idempotent monad with `μ` iso, and no `Generates` predicate is enforced. Each instantiation of `CanonizationClosure` for a specific `f` and `T_f` would, in a future refinement of this framework, additionally supply a `Generates Δ f T_f` witness specifying which of 5.1–5.3 (or a fourth alternative) is being used. The conditional theorem `recursive_partition` operates on the data regardless of which predicate is in force.

---

## 6. Worked illustration: Bach as Infrastructure-axis

This section sketches what the recursive partition would predict, using the closure framework, for specific later compositions. It is an *illustration*, not a formal proof: the music topos is not formally specified, no specific `T_Bach` is constructed, and the Sub-cell classifications below are not derived from any verified construction. The illustration's purpose is to show the *shape* of the recursive prediction.

Suppose the music topos `M` carries a distinction structure `Δ_music` whose kernel image at the relevant objects captures "tonal organization" in a structural sense. Suppose Bach's complete tonal corpus is collectively a morphism `f_Bach : X_Bach → Y_music` with `IsInfrastructure Δ_music f_Bach` (Bach is Infrastructure globally in the tonal topos) and `IsCommitmentYes Δ_music .infrastructure f_Bach` (Bach is at the structural limit of Infrastructure in his moment). Posit a canonization closure `cc_Bach : CanonizationClosure Δ_music f_Bach` whose induced distinction structure is `Δ_Bach := cc_Bach.inducedDistinction`. The recursive partition theorem then classifies every later morphism in `M` into four cells relative to the Bach axis:

* **Sub-Infrastructure of Infrastructure at Bach.** A work `g : A → B` with `IsInfrastructure Δ_music g` (the work is tonal) and `IsInfrastructure Δ_Bach g` (the work's image in the Bach-canonized topos lies inside the kernel image of the Bach reflection). Predicted candidates: pedagogical chorale harmonizations, conservatory-tradition counterpoint exercises, Mendelssohn's *St. Paul*, Brahms's *German Requiem* (substantially Bach-mediated tonal Infrastructure).

* **Sub-Distribution at Bach.** A work tonal globally, straddling Bach-canonical and non-Bach-canonical in the recursive partition. Predicted candidates: late-Romantic chromatic music that maintains tonal organization but operates substantially outside Bach's specifically counterpoint-mediated tonality — late Wagner (excluding *Tristan*'s explicit refusal moves), early Strauss tone poems, Mahler's tonal late symphonies.

* **Sub-Exploitation at Bach.** A work tonal globally, in the closure-residue of Bach-canonical but not inside the Bach kernel image. Predicted candidates: late-Romantic and post-tonal-but-tonal-residue music that pulls back through the Bach-canonical territory without fully entering it — Reger's chromatic extensions of contrapuntal procedure, Hindemith's *Ludus Tonalis* in dialectic with Bach's *Well-Tempered Clavier*, Shostakovich's *24 Preludes and Fugues* op. 87.

* **Sub-Refusal at Bach.** A work tonal globally, but in the complement of Bach-canonical. Predicted candidates: neoclassical works that use tonal vocabulary in deliberate distance from Bach-mediated organization — Stravinsky's *Pulcinella* and *Octet*, Prokofiev's "Classical" Symphony, some Poulenc.

These predictions are *interpretive*. The framework does not currently contain a formal specification of `M`, of `Δ_music`, of `cc_Bach`, or of the morphisms representing the individual works above. The illustration shows what the recursive partition *would* assert if the formal apparatus were filled in; whether the predictions match musicological consensus is a separate empirical question.

The illustration's main purpose is to show that the recursive partition's *structural predictions* are concrete and testable in principle. A musicologist looking at the four sub-cells would be able to assess whether the predicted classifications align with disciplinary intuitions. Where they align, the closure framework gains empirical traction; where they fail, the framework is constrained.

---

## 7. Connection to existing apparatus

The closure framework sits within the existing FalseWork formalization as follows:

* **Definition 3.1 (`DistinctionStructure`)** provides the base structural apparatus. Every canonization closure produces a new `DistinctionStructure`.

* **`DistinctionStructure.ofIdempotentMonad` (Remark 5.5, `SpencerBrown.lean`)** is the bridge from idempotent monads to distinction structures. The canonization closure layer is its first non-trivial consumer.

* **`four_position_partition` (Theorem 5.1, `Partition.lean`)** is the partition theorem, applied recursively to the induced distinction structure.

* **`CommitmentGate.lean`** documents the binary fixedness condition that *triggers* the closure layer for a given morphism. The closure layer assumes commitment-yes as input and operates on its consequences.

* **`CanonizationClosure.lean`** (introduced with this document) carries the structure type for canonization closures and the conditional recursive partition theorem.

The closure framework is therefore not a new categorical apparatus but a *recursive use* of the existing apparatus. The same five mathematical building blocks — distinction structure, Heyting algebra of subobjects, four cell predicates, partition theorem, idempotent-monad bridge — combine to produce two-level structural classification: cell-position in `Δ` plus cell-position relative to a canonization-yes figure's closure.

Whether the recursion can iterate further (canonization closures of canonization closures, producing third-order classifications) is a natural follow-up question; the type signature of `CanonizationClosure` admits arbitrary nesting in principle, and the recursive partition theorem applies at each level.

---

## 8. Formalization status

The Lean formalization in [`CanonizationClosure.lean`](../../lean/FalseWorkPapers/Positions/CanonizationClosure.lean) provides:

* **`CanonizationClosure Δ f`** — a structure carrying the data of a candidate canonization closure for `f` relative to `Δ`. Fields: an idempotent monad `T` on the ambient category, a witness `μ_iso` that the multiplication is a natural isomorphism. No `Generates Δ f T` field; the load-bearing predicate is left as open mathematical work per §5.

* **`CanonizationClosure.inducedDistinction`** — the distinction structure induced by `T` via the idempotent-monad bridge.

* **`recursive_partition`** — the conditional recursive partition theorem. Given a canonization-closure witness, the four-position partition theorem applies to the induced distinction structure. Kernel-checked against the three standard Mathlib axioms.

* **`CanonizationGenerator Δ f`** — the generator-refinement structure (per §5a). Extends `CanonizationClosure` with an `isSeparator` field witnessing that the codomain `Y` of `f` is a separator for the ambient category `C`.

* **`canonization_separation`** — the conditional separation theorem. Given a canonization-generator witness, parallel morphisms in `C` are determined by their composition with maps out of `Y`. Kernel-checked against the three standard Mathlib axioms.

What is *not* in the Lean tree:

* The `Generates Δ f T_f` predicate of §5. This is the load-bearing piece left open for the closure layer.

* A construction of `CanonizationClosure` or `CanonizationGenerator` for any specific morphism in any specific topos. The framework's empirical canon-formation work (Bach, Coltrane, Schoenberg) is interpretive; the formal closure-with-separator data for these figures has not been constructed.

* An iteration of the recursion. The recursive partition theorem applies once; the framework does not currently formalize the higher-order recursion (canonization closures of canonization closures).

---

## 9. Open mathematical questions

Three open questions are flagged for future work:

1. **The `Generates` predicate.** As surveyed in §5, three candidate predicates (smallest reflective subcategory containing the codomain, smallest containing the morphism, generated by cell-restricted iteration colimit) all have tradeoffs. Selecting one requires a substantive mathematical and historical decision. The framework's broader empirical work on canon formation may eventually distinguish them; until then, the closure framework operates at the level of *candidate* closures without committing.

2. **Existence under the framework's hypothesis bundle.** Under the elementary-topos hypothesis bundle of [`paper.md`](paper.md) §2, do canonization closures (in any of the senses of §5) exist for morphisms classified at each of the four cells? Cell-by-cell existence may differ. Counterexamples — morphisms that are commitment-yes but for which no canonization closure exists — would constrain the framework substantially.

3. **Uniqueness up to equivalence.** If a canonization closure exists for `f`, is it unique up to natural equivalence of reflective subcategories? Non-uniqueness would mean the recursive partition depends on a choice of closure, which would complicate the structural-fingerprint interpretation. Uniqueness — or at least canonicity-up-to-equivalence — would make the recursion well-defined.

A fourth, more speculative question: whether the closure framework can be iterated indefinitely (closures of closures), and whether the resulting infinite-dimensional structural classification stabilizes at a fixed point in any meaningful sense. This is well beyond the scope of the present sketch.

---

## 10. Caveats

The closure framework as developed here is at *sketch* stage. Three caveats are worth recording:

**Metaphor-collapse risk.** The historical illustrations of §2 and §6 (Bach, Coltrane, Schoenberg) are evocative but not formal. The risk of importing the city-and-bridges analogy as if it were mathematical structure is real and the framework guards against it by isolating the load-bearing definition (§5) and the formal theorem (§4) from the interpretive material (§§2, 6). The recursive partition theorem in `CanonizationClosure.lean` is mathematics; the predictions for specific musical works are illustrations of how that mathematics might apply if it were instantiated for those works.

**The conditional nature of the theorem.** The recursive partition theorem is *conditional on* having a canonization-closure witness. It does not assert that any specific morphism admits such a witness. The framework's empirical claim that Bach, Coltrane, and Schoenberg admit canonization closures is a separate, non-formal claim that this document does not establish.

**The framework's prior caution about premature unification.** The 2026-05-10 exploration (recorded in [`MomentRelative.lean`](../../lean/FalseWorkPapers/Positions/MomentRelative.lean)) closed the question of cross-cell theorem-grade unification of Commitment negatively. The closure framework here is a *different* question — not "is Commitment a unified construction across cells?" but "what are the consequences of Commitment-yes for the rest of the morphism space?" — but the same caution applies: a framework gain from premature unification of related-looking structures is illusory. The closure framework should be developed in the *additive* mode used here (a new layer parameterized by candidate data) rather than the *unifying* mode that the 2026-05-10 exploration ruled out.

---

## 11. Recommended sequence for development

If the closure framework is taken up as a serious research direction, the recommended sequence is:

1. **Select between candidates 5.1, 5.2, and 5.3** as the working specification of `Generates`. This is a mathematical and intuitive decision that the framework's empirical work should inform.

2. **Prove existence and (where possible) uniqueness** of the selected closure under the framework's hypothesis bundle, or identify specific topos hypotheses under which existence holds.

3. **Construct a concrete `CanonizationClosure` for one historical case** — Bach as Infrastructure-axis is probably the simplest, since the relevant musical structures admit some standard formalization in the topos-theoretic music literature (cf. Mazzola 2002 in the related-work paragraph of [`paper.md`](paper.md) §7.2). The point is to verify that the type signature in Lean can be instantiated for at least one non-trivial case.

4. **Mechanize the existence-and-uniqueness theorems** in Lean, and verify the recursive partition theorem on the concrete instance. This closes the conditional nature of `recursive_partition` for at least one case.

5. **Iterate to other historical cases**, accumulating instantiations and constraining the `Generates` predicate empirically by which cases the predicate's various candidates do or don't fit.

Steps 1–2 are the substantial new mathematics. Step 3 is the first interesting instantiation. Steps 4–5 are formal and empirical refinement of the framework as developed.

---

## References

- Adámek, J., and Rosický, J. (1994). *Locally Presentable and Accessible Categories*. London Mathematical Society Lecture Note Series 189, Cambridge University Press.
- Borceux, F. (1994). *Handbook of Categorical Algebra*, 3 volumes. Encyclopedia of Mathematics and its Applications 50–52, Cambridge University Press.
- Brink, C. (2026). *A Four-Position Partition of Morphisms in Elementary Topoi with Distinction Structure*. Preprint, [`paper.md`](paper.md).
- Brink, C. (2026). *Spencer-Brown Anchor: Reading the Four-Position Partition Through Laws of Form*. Companion, [`spencer-brown-anchor.md`](spencer-brown-anchor.md).
- Mathlib Community (2026). *Mathlib4*. [github.com/leanprover-community/mathlib4](https://github.com/leanprover-community/mathlib4).
- Spencer-Brown, G. (1969). *Laws of Form*. Allen and Unwin.

---

## Provenance

Drafted 2026-05-24 in conversation with Anthropic Claude (Cursor IDE), per the project's documented validation architecture. The closure framework as articulated here is a sketch; the conditional recursive partition theorem in [`CanonizationClosure.lean`](../../lean/FalseWorkPapers/Positions/CanonizationClosure.lean) is kernel-checked, but the load-bearing `Generates` predicate of §5 is left open and no concrete `CanonizationClosure` instance is constructed. The framework's prior caution (per the 2026-05-10 exploration in `MomentRelative.lean`) that premature unification of structurally-related constructs is illusory has been respected: the closure framework operates *additively* as a candidate-data layer over the existing partition theorem, not as a new unifying construction. The historical illustrations of §§2 and 6 are interpretive and should be treated as motivating intuitions rather than as formal claims.
