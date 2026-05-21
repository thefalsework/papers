# The Comma: A Formal Structure Note

**Status.** Companion document. Partially-formalized apparatus with expository scaffolding (Theorem 0 kernel-checked; Theorem 1 kernel-checked under a strengthened hypothesis; Theorems 2 and 3 are observation-grade; see §6). Not a paper.

**Audience.** Category theorists, topos theorists, mathematical philosophers, and reviewers who want to assess the framework's formal apparatus without reading Lean source.

**What this document is.** A focused expository description of the *closure-residue construction* — the framework's current commitment for the formal structure of the comma — and the **four-position partition plus Commitment gate** dictionary that sits inside it. It states the apparatus, gives the predicates, names the open problems honestly, and points at the Lean source for everything that has been mechanized.

**Architecture (revised 2026-05-10).** The framework's central architectural claim has been refined through formalization. The dictionary is now: a *four-position partition* over morphisms (Infrastructure, Distribution, Exploitation, Refusal) — disjoint and exhaustive in the topos register — plus a *Commitment gate*, a binary fixedness condition that applies *within each cell* rather than as a fifth cell of its own. The two-parameter unification question (whether the four cells' extension operators derive from a single uniform construction) was tested in Lean on 2026-05-10 and closed: negative on theorem-grade unification, positive on schema-level uniformity. The previously-named "central open problem" of Commitment/Exploitation disjointness *dissolves* under this architecture — Commitment is no longer a separate cell competing with Exploitation for the closure-residue region.

**What this document is not.** A paper. Not in the sense of being polished, peer-reviewable expository writing. The companion to a paper. The published-paper version of this content is destined for Paper 3 § 4 in the v10.0 revision, conditional on the open problems clearing or the schema being revised by specialist engagement.

**Companion to.** [`paper1-kernels-and-commas/paper1.md`](paper1-kernels-and-commas/paper1.md) (the empirical dictionary), [`paper3-distinction-operation/paper3.md`](paper3-distinction-operation/paper3.md) (the informal categorical framing), [`paper4-mathematics-as-comma/paper4.md`](paper4-mathematics-as-comma/paper4.md) (the ontological account of comma-as-substrate), [`../validation/claims/five-position-derivation-formalization.md`](../validation/claims/five-position-derivation-formalization.md) (the schema specification with hedging), [`../lean/FalseWorkPapers/Positions.lean`](../lean/FalseWorkPapers/Positions.lean) (the Lean dictionary), [`../lean/FalseWorkPapers/Positions/MomentRelative.lean`](../lean/FalseWorkPapers/Positions/MomentRelative.lean) (the two-parameter-unification exploration that closed the question), [`../lean/FalseWorkPapers/Positions/REGISTER.md`](../lean/FalseWorkPapers/Positions/REGISTER.md) (the register note).

**Provenance.** Drafted May 2026 following the closure-residue commitment for the Exploitation predicate and the register-note clarification. Revised 2026-05-10 to reflect the Commitment-as-gate reframe, the closure of the two-parameter-unification question, and the dissolution of the previously-named Commitment/Exploitation disjointness problem. Revised 2026-05-17 to repair the Infrastructure predicate (originally stated as endpoint-iso, which would have left an exhaustiveness hole in the four-position partition for images that stay in the kernel image without the endpoints being trivialized) and to state the four-position partition theorem explicitly as Theorem 0 in §6. Revised 2026-05-19/20 to record the kernel-checked closure of Theorem 0 against the in-repo `HeytingAlgebra (Subobject Y)` instance, the upstream Mathlib PR ([#39618](https://github.com/leanprover-community/mathlib4/pull/39618)), the kernel-checked closure of Theorem 1 (refusal residue) under the strengthened hypothesis `HasIrregularKernel`, and the promotion of the gap to a named open conjecture (*refusal bridge*) tracked at [`../validation/claims/refusal-bridge.md`](../validation/claims/refusal-bridge.md); these closures are recorded in §6 (intro line, Theorem 1 statement and content, proof walk-throughs for Theorems 0 and 1, axiom audit), §7 (Open Problems 2 and 5), §8 (honesty table first row, disjointness paragraph), and §9 (conclusion). Records framework state at those moments. Subsequent revisions either land here as patches or escalate to Paper 3 v10.0.

---

## 1. Disambiguation: kernel and comma

Two terms in this document are also standard category-theoretic vocabulary, used here in a different sense from the standard one. The non-standard usage has to be flagged before anything else, or the entire document is unreadable.

**Kernel** in standard category theory denotes the equalizer of a morphism with the zero morphism, in a category with a zero object: `ker(f : X → Y)` is the largest subobject of `X` that `f` sends to zero. Abelian-categories vocabulary.

**Kernel** in the framework's sense is something else entirely. It denotes the *minimal generative operation that produces a domain's structure by failing to close on itself*. In music it is the perfect fifth (frequency ratio 3:2). In cinema it is the cut. In architecture it is gravity. In quantum physics it is the operation coupling unitary evolution with measurement. In generative AI (the candidate seventh kernel) it is the threshold function operating in high-dimensional indexical space. The four criteria that pin down the framework's kernel are:

- **Prior.** The kernel is the operation the domain depends on, not a derived structure.
- **Monogenic.** The kernel is a single operation, not a composite apparatus.
- **Inescapable.** Work in the domain cannot proceed without engaging the kernel.
- **Self-limiting.** The kernel generates its own boundary by failing to close on itself when iterated.

The fourth criterion is the structural one — what makes the kernel *generative through incompleteness*. Iterated perfect fifths do not return to the starting pitch (the Pythagorean comma is the irrational `log₂(3/2)`). Iterated cuts do not produce continuous experience. Iterated gravity-loaded structural decisions never resolve into stasis. The failure to close is what produces the work for the domain.

Full development of the four criteria, with the empirical instantiations across six domains, is in Paper 1 § 3. The candidate seventh (generative AI under Levin's threshold logic) is in Paper 1 § 2.1 (introduced at v11.6, unchanged through v11.8), and its formalization is the open work tracked at [`../validation/claims/threshold-kernel-candidate.md`](../validation/claims/threshold-kernel-candidate.md).

**Comma** in standard category theory denotes the comma category `(F ↓ G)` of a pair of functors. Lawvere–Mac Lane vocabulary.

**Comma** in the framework's sense is something else. It denotes the *structural gap that the kernel generates from its own logic and cannot itself resolve*. The Pythagorean comma (the gap between 12 fifths and 7 octaves; equivalently, the irrationality of `log₂(3/2)`) is the canonical case the framework's name preserves. Cinema's comma is the gap between the cut's discontinuity and attention's continuity. Architecture's comma is the irreducible tension between gravity's constant force and a building's discrete structural decisions. Each domain's comma is the formal residue of the kernel's failure to close.

In this document, "kernel" and "comma" always carry the framework's senses unless explicitly marked otherwise. Where the framework's structures admit a category-theoretic representation (as they do in the topos register described below), the framework's *kernel* is represented by an endofunctor `D : C → C`, and the framework's *comma* is the structural content of the lattice of subobjects of `D Y` for varying `Y` — specifically the strict containment `Im(η) < (Im(η))ᶜᶜ` in the Heyting algebra.

---

## 2. The register

The framework's formal home is **Heyting-algebraic**, equivalently **locale-theoretic**, equivalently the algebra of **intuitionistic propositional logic**, equivalently the **poset of subobjects** of an object in an elementary topos with its lattice operations. These are four names for the same mathematical structure, related by Stone–Tarski–Heyting duality and the locale/topos correspondence; see Mac Lane–Moerdijk *Sheaves in Geometry and Logic* Ch. IX or Johnstone *Sketches of an Elephant* C1.

What the register gives the framework, register-revealed:

- `Im(η)` — an element of the lattice. The part of `D Y` that `η.app Y` reaches.
- `(Im(η))ᶜ` — the strict pseudo-complement. The largest element disjoint from `Im(η)`.
- `(Im(η))ᶜᶜ` — the locale-theoretic closure. The smallest closed element containing `Im(η)`.
- `Im(η) ≤ (Im(η))ᶜᶜ` always; equality fails generically in non-Boolean topoi. The strictness of this containment is the formal content of the framework's *comma*.

What the register does not give without further additions:

- A metric (no distance between subobjects).
- A measure (no probability, no concentration of measure).
- Smooth structure (no tangent spaces, no charts, no manifolds).
- High-dimensional Euclidean structure (no `ℝⁿ` for large `n`, no near-orthogonality).
- Points (a locale is "pointless geometry" — reasoning is by regions and inclusions).

The full framing note is at [`../lean/FalseWorkPapers/Positions/REGISTER.md`](../lean/FalseWorkPapers/Positions/REGISTER.md). It includes a hazard discussion of the conflation of *locale geometry* (the framework's home register) with *manifold geometry* (Levin's apparatus, Tymoczko's voice-leading orbifolds, physical spacetime); these share the word "geometry" but are different mathematical structures whose translation requires explicit construction.

---

## 3. The closure-residue construction

The framework's structure is captured, at the level of one fixed `Y : C`, by the following data in the lattice `Subobject (D Y)`:

```
       D Y                           top of the lattice
        |
   (Im(η))ᶜᶜ                         the closure of the kernel image
       /  \
      /    \
   Im(η)    \                        the kernel image proper
      \      \
       \      \
        \    closure-residue territory
         \    (¬¬Im(η) ∖ Im(η),
          \   non-trivial in non-Boolean topoi)
           \
        (Im(η))ᶜ                     the strict pseudo-complement
            |
            0                        bottom of the lattice
```

Three regions of this lattice are doing the structural work:

1. **`Im(η)`** — the kernel image. What the kernel actually delivers.
2. **`(Im(η))ᶜ`** — the pseudo-complement. What the kernel doesn't reach at all.
3. **`(Im(η))ᶜᶜ ∖ Im(η)`** — the closure-residue. What is *in the closure of* `Im(η)` *without being in* `Im(η)` *itself*.

The third region is the framework's home territory for *Exploitation* in the topos register. It is empty in Boolean lattices (where `(Im(η))ᶜᶜ = Im(η)` always); it is non-trivial in non-Boolean ones. The strictness of the containment `Im(η) < (Im(η))ᶜᶜ` is the *comma's* formal content.

A subtlety to flag: in a Heyting algebra, `(Im(η))ᶜᶜ ⊓ (Im(η))ᶜ = ⊥` is an identity. The closure-residue is therefore *empty as a strict sub-element* of `(Im(η))ᶜᶜ` if one demands a single subobject characterizing it. The framework escapes this by characterizing the residue *at the level of generalized elements* — predicates over morphisms `f : X → Y` rather than subobjects of `D Y`. A morphism `f` is in the residue when `D.map f` factors into `(Im(η))ᶜᶜ` but not into `Im(η)`. This is the closure-residue commitment, and it is the technical move that makes Exploitation formalizable in the topos register.

---

## 4. The distinction structure

The framework's kernel, formally, is encoded as a *distinction structure* on a category `C`:

```
DistinctionStructure C :=
  { D : C ⥤ C
  , η : 𝟭 C ⟶ D
  , idempotent : D ⋙ D ≅ D
  , coherent : ∀ X, η.app (D.obj X) ≫ idempotent.hom.app X = D.map (η.app X)
  }
```

The data is the endofunctor `D` (the kernel), the marking unit `η` (the act of drawing the distinction), and a Spencer-Brown-style idempotency witness (marking twice equals marking once). The *non-triviality* hypothesis is `∃ X, ¬ IsIso (η.app X)` — there is some object on which the kernel's marking is not invertible. Without non-triviality the four-cell partition (and the gate that applies within each cell) collapses to a single trivial position.

Spencer-Brown's *Laws of Form* (1969) gives the calculus of distinction-marking with two axioms — *calling* (marking twice is the same as marking once) and *crossing* (marking and unmarking cancel). The idempotency witness encodes calling at the natural-transformation level; the unit `η` encodes crossing.

The *kernel image* `Im(η)` at `Y` is the subobject of `D Y` cut out by the marking morphism `η.app Y`. Formally:

```
kernelImage Δ Y := Subobject.mk (image.ι (η.app Y))
```

The four cells (and the gate that applies within each cell) are characterized by where morphisms `f : X ⟶ Y` land relative to `kernelImage Δ Y` and its Heyting operations.

---

## 5. The position dictionary: four cells plus a gate

The dictionary has two structural layers:

* A **four-position partition** over morphisms: Infrastructure, Distribution, Exploitation, Refusal. These are four Heyting conditions on `Im(D.map f)` relative to `kernelImage Δ Y`. They are disjoint and exhaustive over the morphism space of `C` modulo the trivial-image edge case — this is the framework's headline theorem (Theorem 0 in §6), kernel-checked in Lean as of 2026-05-19.
* A **Commitment gate** that applies *within each cell*: a binary fixedness condition under cell-internal iteration of `D`. A morphism `f` classified in cell `P` is additionally either Commitment-yes or Commitment-no at `P`. The gate has uniform shape across the four cells; its content (which iteration is the relevant one) is cell-specific.

This is a *4 × 2* architecture: four lattice cells, each with a binary gate. The previous "five positions" framing treated Commitment as a fifth lattice cell parallel to the other four; that framing was revised on 2026-05-10 when formalization testing showed that the gate's uniformity holds at schema level but not at theorem level (see §7, "Two-parameter unification: closed negative").

Sections 5.1–5.4 give the four cells. Section 5.5 gives the Commitment gate. Each cell's plain-language definition is followed by the Lean predicate (italicized) and canonical examples from domains with at least adjacent specialist anchoring.

### Infrastructure

The image of the work under `D` lies entirely within the kernel image: `D`'s marking activity does not exceed what `η` already produces. The practitioner works at a level of the field where the kernel's productive asymmetry has been absorbed into the operating apparatus. The gap exists in the surrounding lattice, but the work itself does not surface it — prior work (temperament systems, structural codes, prose conventions, perceptual norms) has already negotiated the comma's consequences into the system the practitioner inhabits.

> *`IsInfrastructure Δ f := image(D.map f) ≤ kernelImage Δ Y`. Signature theorem: under this hypothesis, the work's marking activity does not exceed the kernel's native ground at `Y`. The condition `IsIso (Δ.η.app X) ∧ IsIso (Δ.η.app Y)` — `η` is an isomorphism at both endpoints, so `D` acts trivially on `f` via naturality — is a sufficient sub-condition (it forces `kernelImage Δ Y = ⊤` at `Y`, making the image-subobject inequality vacuous). The broader image-subobject condition is what carries the partition theorem; the endpoint-iso sub-case corresponds to a kernel that is transparent at the work's endpoints.*

*Music:* tonal music within a fixed key, where the temperament system has already absorbed the Pythagorean comma. Bach's Well-Tempered Clavier within one key (without modulation across keys) instantiates this.

*Cinema:* classical continuity editing inside an established genre, where the cut's discontinuity has been managed by inherited Hollywood grammar.

*Refinement: Deep Infrastructure.* When a practitioner does sophisticated work above a transparent kernel — using the Infrastructure level as substrate while the work itself happens at higher levels of structure — the framework wants a *level-stratified* version of the predicate. Kurosawa's late films sit here: deeply considered cinema operating with continuity editing as a transparent substrate while the work happens at the level of pictorial composition, performance rhythm, and structural pairing. Formal level structure for Deep Infrastructure is open work; two candidate paths (fibration over `ℕ`, fibration over a level-poset) are documented in the Lean's `Infrastructure.lean`.

### Distribution

The image of the work under `D` straddles `Im(η)` and `(Im(η))ᶜ`: the work engages both the kernel's reach and what the kernel doesn't reach, simultaneously. The practitioner encounters the gap and responds by distributing the kernel's failure across multiple sites, converting one large unresolved structural problem into many small managed tensions. The gap is not resolved — it is *redistributed*.

> *`IsDistribution Δ f := let img := image(D.map f). img ⊓ kernelImage Δ Y ≠ ⊥ ∧ img ⊓ (kernelImage Δ Y)ᶜ ≠ ⊥`. Signature theorem: Distribution sits strictly between Infrastructure (image entirely in `Im(η)`) and Refusal (image entirely in `(Im(η))ᶜ`).*

*Music:* equal temperament — the 23.46 cents of Pythagorean comma distributed as ≈1.96 cents per semitone across all 12 intervals. The comma is engaged at every interval simultaneously rather than concentrated at one wolf interval.

*Cinema:* classical Hollywood's redundant continuity cues — eyeline match, axis-of-action, screen direction, cause-effect logic — where the cut's discontinuity is managed by multiple small recoveries rather than any single one.

*Physics:* decoherence theory (Zeh, Zurek), where the measurement problem is distributed across system-environment entanglement rather than concentrated at a measurement event.

A balance condition refining "non-trivial intersection at both poles" is open work; three candidates (anti-chain structure, equimeasure, categorical decomposition into components) are in `Distribution.lean`.

### Exploitation

The image of the work under `D` lies in the closure of the kernel image but not in the kernel image itself. The practitioner works in the closure-residue territory: aggressively pursuing a closure that the kernel cannot deliver, treating the kernel's failure to close as the generative material of the work itself.

> *`IsExploitation Δ f := let img := image(D.map f). img ≤ (kernelImage Δ Y)ᶜᶜ ∧ ¬(img ≤ kernelImage Δ Y)`. Signature theorems: (i) `IsExploitation` requires `C` to be non-Boolean (vacuous in Boolean topoi where `aᶜᶜ = a`); (ii) Exploitation and Refusal occupy disjoint Heyting regions, by the identity `aᶜ ⊓ aᶜᶜ = ⊥`.*

*Music:* Coltrane's *Giant Steps* — the major-third cycle compressed until the harmonic apparatus exceeds processing speed. The work's coherence depends on the comma's specific residue-structure (Tymoczko's voice-leading geometry independently identifies the major-third cycle as a topological feature of 12-tone chromatic space). Without the comma's geometry, the work does not exist.

*Painting:* Cézanne's constructive stroke — the pictorial material caught between applied paint and image-bearing surface, struggling toward a unified image that won't resolve. The four-mechanism Exploitation cluster the framework's painting trajectory identifies (Cézanne suspension, Picasso fracture, de Kooning struggle, Pollock allover) all sit in the closure-residue.

*Physics:* quantum computing — the work uses superposition and entanglement (the measurement-problem locus's internal structure) as computational resource. Without the comma's geometry, quantum advantage does not exist.

The empirical observation that the four mechanism-distinct Exploitation modes in painting (and the analogous Coltrane–Hendrix structural pairing in music) might admit *further* categorical refinement was held briefly in May 2026 under "transverse-vs-pole" framing. That framing was withdrawn — geometric vocabulary without categorical content. The further refinement is now documented as open work, not committed structure. See § 7 below.

### Refusal

The work factors through the strict pseudo-complement of the kernel image: `D.map f` factors through `(Im(η))ᶜ`. The practitioner rejects the kernel as a legitimate operation in the field. The work is structured by something *other* than the kernel — a different generative principle, an alternative organizing logic, an announced refusal of the kernel's authority.

> *`IsRefusal Δ f := ∃ (g : D X ⟶ ((kernelImage Δ Y)ᶜ : Subobject (D Y))), D.map f = g ≫ ((kernelImage Δ Y)ᶜ).arrow`. Signature theorem: in non-Boolean topoi, `Im(η) < (Im(η))ᶜᶜ` strictly — the kernel's closure has structural content that the refusing work cannot avoid encountering as residue. This is the framework's `refusal_residue` theorem.*

*Music:* Schoenberg's twelve-tone serialism — the row-permutation logic replacing the perfect-fifth as generator. Reinhardt's contemporaneous painting practice has exactly the same shape one register over.

*Painting:* Reinhardt's near-monochrome black paintings — the geometric form-and-color content refused, with the cruciform reappearing as residue under extended viewing. Malevich's *Black Square* in some readings (contested with Commitment readings).

*Cinema:* Snow's *Wavelength* — the 45-minute zoom refusing the cut as generator of cinematic time. Benning's structural landscape films.

*Physics:* Many-Worlds (Everett) — the universal-unitary-evolution `G` replaces the Born-rule-augmented `F` as generative principle.

The `refusal_residue` claim — that the kernel's closure has more in it than the kernel image — is what makes Refusal a structurally distinct *position* rather than an absence. The refusing work cannot escape the closure of what it refuses; the residue is what shows up under extended attention to the refusing work. Reinhardt's cruciform is this residue, made visible.

### The Commitment gate

A morphism `f` classified in cell `P ∈ {Infrastructure, Distribution, Exploitation, Refusal}` is additionally *Commitment-yes at `P`* when `f` is a fixed point of the `P`-restricted iteration of `D` — that is, when `f` is at the structural limit of its cell, with no further iteration within `P` producing new content. The gate is binary (yes/no per work). The work has either pursued its cell's logic to the cell's structural limit or it has not.

> *Schema. For each cell `P`, the gate has the form: `IsCommitmentYes Δ P f := f ≅ colim_{n} (iter_P^n f)`, where `iter_P` is `D`-iteration restricted to the subcategory cut out by `P`. The shape of this schema is uniform across cells. The content of `iter_P` is cell-specific (the iteration takes place in a different subcategory for each cell). The Lean documents this in [`../lean/FalseWorkPapers/Positions/CommitmentGate.lean`](../lean/FalseWorkPapers/Positions/CommitmentGate.lean), with the open question of continuous iteration of `D` flagged (Spencer-Brown idempotency `D ⋙ D ≅ D` collapses the discrete diagram; continuous parameterization is the framework's intended target).*

**Moment-relativization.** Commitment-yes is *moment-relative*. The structural limit a cell admits is the limit *as understood at the moment* of the work's making. Duchamp's *Fountain* (1917) is Refusal-Commitment-yes at its moment because the readymade-Refusal gesture is structurally complete in the urinal: no subsequent work reduces the artist's transformation further than zero. Subsequent canonical readymade works are Refusal-Commitment-yes at their later moments, with the boundary the work pushes against differently configured. The framework reading: each cell admits a sequence of moment-relative structural limits, and a work canonical at moment `t` is at the cell's structural limit *as of `t`*.

**Schema-level uniformity (what the gate gets right).** Three uniformities hold across the four cells:

1. The moment-relative kernel image `kernelImageAt : Moment → Subobject (D Y)` is a single construction shared by every cell.
2. Every cell predicate lives in the same Heyting register: a condition on `(Im(D.map f), kernelImageAt t Y)`.
3. The gate has uniform shape: binary fixedness under cell-restricted iteration.

**Theorem-grade unity (what the gate does not have).** The four cell predicates are propositional-shape-distinct as Heyting conditions: `≤ a`, straddle-`a`-and-`aᶜ`, `≤ aᶜᶜ ∧ ¬(≤ a)`, `≤ aᶜ`. They are not specializations of a single Heyting expression parameterized by cell. Any uniform formula must internally case-split on cell. The case-split is structural (propositional-shape-distinct), not bookkeeping. The four cell-restricted iterations therefore differ in substance across cells; the gate's uniformity is schema-level, not theorem-grade. The 2026-05-10 Lean exploration in [`../lean/FalseWorkPapers/Positions/MomentRelative.lean`](../lean/FalseWorkPapers/Positions/MomentRelative.lean) is the formal record of this.

**Canonicity claim (open empirical).** The framework's strong canonicity claim is: *moment-relative Commitment-yes at the work's cell is necessary for canonicity*. Canonical works are at their cell's structural limit as of their moment. Commitment-yes-but-not-canonical works exist (sociological filtering, reception timing, accessibility) — so the condition is necessary but not sufficient. The strong claim is falsifiable; a canonical-but-not-Commitment-yes work would falsify it. The empirical test (counterexample search) is open work.

**Empirical examples, pending reclassification.** Works previously classified as "Commitment" under the five-cell framing are candidates for reclassification under the gate framework as (cell, Commitment-yes). Examples include:

* *Music:* Pythagorean tuning extensions (Partch's 43-tone scale; just-intonation traditions); Coltrane's late spiritual works. Likely (Exploitation, yes) or (Refusal, yes) depending on whether the work pursues the kernel's closure or substitutes an alternative generator.
* *Cinema:* Sokurov's *Russian Ark*; Tarkovsky's long takes. Likely (Refusal, yes) or (Exploitation, yes) — the cut is either refused or its continuity-management closure is exploited past the standard stopping point.
* *Painting:* Newman's surface-pole works; Rothko's image-pole works. Likely (Exploitation, yes) under the closure-residue reading.
* *Physics:* pilot-wave theory (Bohm, de Broglie). Likely (Refusal, yes) — the Born postulate is refused; Schrödinger's deterministic generator is extended.

The empirical reclassification of the trajectory artifacts (Coltrane, Painting, Kurosawa, Cinema) under the gate framework is pending work. The four-position partition's empirical adequacy is independently testable; the gate's empirical content tests the canonicity claim.

---

## 6. Signature theorems committed

Four theorems are committed at the level of the closure-residue construction. As of 2026-05-19/20, the formalization status is as follows: Theorem 0 (the four-position partition) is **kernel-checked in Lean** against an in-repo `HeytingAlgebra (Subobject Y)` instance ([`../lean/FalseWorkPapers/Positions/Partition.lean`](../lean/FalseWorkPapers/Positions/Partition.lean), `FalseWork.Positions.four_position_partition`). Theorem 1 (refusal residue) is **kernel-checked under a strengthened hypothesis** (`HasIrregularKernel`; see the Theorem 1 entry and §6 closing paragraphs). Theorem 3 (Exploitation/Refusal disjointness) is **kernel-checked** (`FalseWork.Positions.exploitation_refusal_disjoint`) and is also recoverable as a corollary of Theorem 0's pair-wise disjointness arguments. Theorem 2 (Exploitation requires non-Boolean topos) is an informal observation that follows directly from the cell predicate's definition; it is not a separately named Lean theorem. The Mathlib gap that previously blocked all four formal statements (`HeytingAlgebra (Subobject Y)` for elementary topoi) is closed locally and upstreamed as Mathlib PR [#39618](https://github.com/leanprover-community/mathlib4/pull/39618), open at time of this revision.

**Theorem 0 (Four-position partition).** Let `Δ` be a non-trivial distinction structure on an elementary topos `C` with the requisite Heyting structure on its subobject lattices. For every morphism `f : X ⟶ Y` in `C` with non-trivial image (`image(D.map f) ≠ ⊥`), exactly one of `IsInfrastructure Δ f`, `IsDistribution Δ f`, `IsExploitation Δ f`, `IsRefusal Δ f` holds. The four cells are pairwise disjoint Heyting conditions on `(image(D.map f), kernelImage Δ Y)` and exhaustive over the morphism space of `C` (modulo the trivial-image edge case, in which every cell holds vacuously).

> *Content: This is the framework's central structural claim. The four cells emerge from a case-split over the Heyting algebra `Sub(D Y)` of where `image(D.map f)` lies relative to `kernelImage Δ Y` and its pseudo-complements. The disjointness reduces to Heyting-algebra identities; the exhaustiveness reduces to a nested case-split that refines into the four cells. A prose walk-through of the proof, following the Lean tactic structure in [`../lean/FalseWorkPapers/Positions/Partition.lean`](../lean/FalseWorkPapers/Positions/Partition.lean), is given below.*

**Proof of Theorem 0 (walk-through).**

Abbreviate `img := Subobject.mk (image.ι (Δ.D.map f))` and `K := kernelImage Δ Y`. The non-triviality hypothesis is `h_nontriv : img ≠ ⊥`. The proof structure mirrors `four_position_partition` in Lean line-for-line.

*Exhaustiveness.* A nested classical case-split on three Heyting flags:

1. First, case on `img ≤ K`.
   * **If `img ≤ K`:** the morphism is **Infrastructure** by definition.
   * **If `¬(img ≤ K)`:** proceed.
2. Second, case on `img ⊓ K = ⊥`.
   * **If `img ⊓ K = ⊥`:** by the Heyting Galois connection `a ⊓ b = ⊥ ↔ a ≤ bᶜ`, we have `img ≤ Kᶜ`. Composed with `isRefusal_iff_image_le_compl` (the image-API helper in `Partition.lean` that rewrites the factorization-through-`Kᶜ`-as-subobject form of `IsRefusal` as the `img ≤ Kᶜ` inequality), the morphism is **Refusal**.
   * **If `img ⊓ K ≠ ⊥`:** proceed.
3. Third, case on `img ⊓ Kᶜ = ⊥`.
   * **If `img ⊓ Kᶜ = ⊥`:** by the same Galois connection, `img ≤ Kᶜᶜ`. Combined with the outer case's `¬(img ≤ K)`, the morphism satisfies the two clauses of `IsExploitation` and so is **Exploitation**.
   * **If `img ⊓ Kᶜ ≠ ⊥`:** both meets `img ⊓ K` and `img ⊓ Kᶜ` are non-trivial, so the morphism is **Distribution**.

*Disjointness (six pair-wise arguments).* Each reduces to a Heyting identity.

1. *Infrastructure ⊥ Distribution.* `img ≤ K ⇒ img ⊓ Kᶜ ≤ K ⊓ Kᶜ = ⊥`, contradicting Distribution's second clause (`img ⊓ Kᶜ ≠ ⊥`).
2. *Infrastructure ⊥ Exploitation.* `IsExploitation` includes the clause `¬(img ≤ K)`, which contradicts `IsInfrastructure := img ≤ K` directly. No Heyting identity needed.
3. *Infrastructure ⊥ Refusal.* From `img ≤ K` and `img ≤ Kᶜ` (the latter via `isRefusal_iff_image_le_compl`), `img ≤ K ⊓ Kᶜ = ⊥`, contradicting `h_nontriv`.
4. *Distribution ⊥ Exploitation.* From `img ≤ Kᶜᶜ` (Exploitation's first clause), `img ⊓ Kᶜ ≤ Kᶜᶜ ⊓ Kᶜ = ⊥`, contradicting Distribution's second clause.
5. *Distribution ⊥ Refusal.* From `img ≤ Kᶜ`, `img ⊓ K ≤ Kᶜ ⊓ K = ⊥`, contradicting Distribution's first clause (`img ⊓ K ≠ ⊥`).
6. *Exploitation ⊥ Refusal.* From `img ≤ Kᶜᶜ` and `img ≤ Kᶜ`, `img ≤ Kᶜᶜ ⊓ Kᶜ = ⊥`, contradicting `h_nontriv`. (This is also Theorem 3 below, named separately because it is the Heyting identity that originally motivated the partition's coherence.)

The role of `h_nontriv` is to exclude the trivial-image edge case `img = ⊥`, in which all four cell conditions hold vacuously; Lemma `four_position_partition` carries this hypothesis explicitly.

The only Heyting-algebra facts used are the meet/complement identities `a ⊓ aᶜ = ⊥` and `aᶜᶜ ⊓ aᶜ = ⊥` (equivalently `aᶜ ⊓ aᶜᶜ = ⊥` by commutativity of meet), the Galois connection `a ⊓ b = ⊥ ↔ a ≤ bᶜ`, and the image-factorization helper `isRefusal_iff_image_le_compl` (a category-theory fact about images and subobject inclusions, closed in Path 5 on 2026-05-19 — see `Partition.lean`'s docstring). All four facts resolve against the in-repo `FalseWork.Heyting.heytingAlgebra` instance (constructed in [`../lean/FalseWorkPapers/Heyting/SubobjectInstance.lean`](../lean/FalseWorkPapers/Heyting/SubobjectInstance.lean) and upstreamed as Mathlib PR #39618). ∎

**Theorem 1 (Refusal residue).** Let `Δ` be a distinction structure on a category `C` with the requisite Heyting structure on its subobject lattices, and suppose `Δ` has an *irregular kernel* — that is, `∃ Y : C, (kernelImage Δ Y)ᶜᶜ ≠ kernelImage Δ Y`. Then there exists `Y : C` with `Im(η.app Y) < (Im(η.app Y))ᶜᶜ` strictly in the Heyting algebra `Subobject (D Y)`.

> *Content: Refusal works cannot escape the closure of what they refuse. The residue is the formal content of the kernel's leftover authority — the strict gap between the kernel image and its double-pseudo-complement on objects where the kernel image escapes the regular sub-algebra. The framework's original statement carried the weaker hypothesis "non-trivial `Δ` on a non-Boolean topos"; the formalized version carries the strengthened hypothesis `HasIrregularKernel`, which says the kernel image **is** the non-Boolean witness at some object rather than merely that the topos has non-Boolean content somewhere. The gap between the two hypotheses is the* **refusal bridge conjecture** *— a generic class of regularly-confined `Δ` (those whose kernel image lands in the Boolean sub-algebra of regular elements at every object) shows that the gap is non-trivial and not closeable by routine work. The conjecture is tracked at* [`../validation/claims/refusal-bridge.md`](../validation/claims/refusal-bridge.md) *and recorded as Open Problem 5 in §7.*

**Proof of Theorem 1 (under `HasIrregularKernel`).** Let `⟨Y, hY⟩` be a witness to `HasIrregularKernel`, so `hY : (kernelImage Δ Y)ᶜᶜ ≠ kernelImage Δ Y`. The inequality `kernelImage Δ Y ≤ (kernelImage Δ Y)ᶜᶜ` is the Heyting identity `a ≤ aᶜᶜ` (`le_compl_compl` in Mathlib). Combined with `Ne.symm hY` to upgrade the `≤` to a `<`, `lt_of_le_of_ne` produces the strict inequality `kernelImage Δ Y < (kernelImage Δ Y)ᶜᶜ`. ∎ (`FalseWork.Positions.refusal_residue` in [`../lean/FalseWorkPapers/Positions/Refusal.lean`](../lean/FalseWorkPapers/Positions/Refusal.lean).)

**Theorem 2 (Exploitation requires non-Boolean topos).** Let `Δ` be a distinction structure on an elementary topos `C`. If `C` is Boolean, the Exploitation predicate is vacuous: no morphism satisfies `IsExploitation Δ f`.

> *Content: The closure-residue construction is non-trivial only when the topos is non-Boolean. Exploitation is a position only because intuitionistic logic admits `aᶜᶜ ≠ a`.*

**Theorem 3 (Exploitation and Refusal occupy disjoint Heyting regions).** Let `Δ` be a non-trivial distinction structure on an elementary topos with the requisite Heyting structure. If `IsExploitation Δ f` and `IsRefusal Δ f` both hold for the same `f`, then `image(D.map f) = ⊥`.

> *Content: The disjointness is a Heyting-algebra identity (`aᶜ ⊓ aᶜᶜ = ⊥`), not an additional commitment of the framework. Exploitation and Refusal are formally distinct positions in the topos register, not just empirically distinct stances.*

A further theorem candidate — distinguishing Exploitation from Commitment within `(Im(η))ᶜᶜ` — was drafted in May 2026 as the "transverse-vs-pole" claim and *withdrawn* on 2026-05-09, and the underlying problem subsequently *dissolved* on 2026-05-10 when Commitment was reframed as a binary gate across the four cells rather than a fifth cell. Under the gate framework, there is no cross-cell disjointness question for Commitment and Exploitation — Commitment is not a separate cell. The residual question is the *per-cell characterization* of the cell-restricted iteration whose fixed points give Commitment-yes at each cell. See § 7.

**Axiom audit.** `#print axioms FalseWork.Positions.four_position_partition` and `#print axioms FalseWork.Positions.refusal_residue` (both verified 2026-05-20 via the audit suite in [`../lean/FalseWorkPapers/Examples/HeytingTypeInstance.lean`](../lean/FalseWorkPapers/Examples/HeytingTypeInstance.lean)) show that both theorems depend only on Lean's standard kernel axioms (`propext`, `Classical.choice`, `Quot.sound`); no framework-specific axioms or `sorry`s are invoked. The same holds for the supporting machinery audited in the same file (`isRefusal_iff_image_le_compl`, `heytingAlgebra`, `le_residual_iff_inf_le`, `isDistribution_implies_neither_polar`, `exploitation_refusal_disjoint`, `trivialized_implies_isInfrastructure`). Readers who treat axiomatic minimality as a meaningful credential can take this as the corresponding receipt; readers who do not are unaffected by it.

---

## 7. Open problems

The closure-residue commitment plus the gate reframe make the formalization viable in the topos register. They also surface specific open problems whose resolution determines what gets published in Paper 3 v10.0 versus what remains framework-internal sketch.

**1. Per-cell restricted-iteration characterization.** This is what the previously-named "Commitment/Exploitation disjointness within `(Im(η))ᶜᶜ`" problem turned into when Commitment was reframed as a gate on 2026-05-10. The disjointness question dissolved (Commitment is not a separate cell); the residual question is local to each cell.

For each cell `P ∈ {Infrastructure, Distribution, Exploitation, Refusal}`, the gate requires a *cell-restricted iteration* `iter_P`: the action of `D` restricted to morphisms in `P`, with fixed points characterizing Commitment-yes-at-`P`. The four candidate iterations:

- **Infrastructure-restricted iteration.** Within morphisms with `η` iso at endpoints. Likely trivial in the basic case (every Infrastructure morphism is a fixed point) and gets non-trivial only with the Deep Infrastructure / level-structure refinement.
- **Distribution-restricted iteration.** Within morphisms whose image straddles `Im(η)` and `(Im(η))ᶜ`. Iterating may push the straddle balance or refine its component decomposition.
- **Exploitation-restricted iteration.** Within morphisms in the closure-residue. Iterating expands residue coverage; fixed points are exhaustive coverage of the closure-residue territory.
- **Refusal-restricted iteration.** Within morphisms factoring through `(Im(η))ᶜ`. Iterating under `D` may push out of `(Im(η))ᶜ` as the boundary evolves; fixed points are stable refusers.

Each is local to its cell. None collides with the others because the four subcategories are disjoint by the four-position partition. This is open work but it is *four independent characterization problems*, not one cross-cell disjointness puzzle.

**2. `HeytingAlgebra (Subobject _)` for elementary topoi.** ~~Mathlib upstream gap (verified 2026-05).~~ **CLOSED LOCALLY (2026-05-19); upstream PR open (2026-05-20).** The universal instance was constructed in-repo at [`../lean/FalseWorkPapers/Heyting/SubobjectInstance.lean`](../lean/FalseWorkPapers/Heyting/SubobjectInstance.lean) (`FalseWork.Heyting.heytingAlgebra`), following the classical Mac Lane–Moerdijk Ch. IV.8 residual construction (pseudo-complement as `Subobject.classifier_inv` of the characteristic morphism of the complement; implication as the equalizer of the two characteristic morphisms). The instance is consumed by all cell files via [`../lean/FalseWorkPapers/Positions/Setup.lean`](../lean/FalseWorkPapers/Positions/Setup.lean) and underwrites the kernel-checked proofs of Theorems 0 and 1. The instance was upstreamed as Mathlib PR [#39618](https://github.com/leanprover-community/mathlib4/pull/39618) on 2026-05-20, target file `Mathlib/CategoryTheory/Subobject/Heyting.lean`. Once the PR merges, the local copy in `FalseWorkPapers/Heyting/SubobjectInstance.lean` becomes redundant and can be retired in favour of the upstream version; the cell-file proofs remain unchanged.

**3. Continuous iteration of `D`.** Spencer-Brown idempotency `D ⋙ D ≅ D` is a structural axiom of the distinction structure. It collapses the discrete iterated-`D` diagram, making the cell-restricted iterations of §7.1 degenerate as currently stated. Three resolutions: (a) relax idempotency (move to a weaker distinction-structure axiom); (b) parameterize over an interval object (continuous-iteration in the synthetic-differential-geometry sense); (c) move to enriched category theory (where colimits over directed diagrams have richer behavior). Decision is framework-level. Affects all four cell-restricted iterations symmetrically.

**4. Two-parameter unification: closed negative (2026-05-10).** A side-question raised by the moment-relativization observation (works push their cell's boundary *as understood at their moment*) was whether the four cell-restricted iterations might all derive from a single uniform construction parameterized by `(cell, moment)`. The exploration in [`../lean/FalseWorkPapers/Positions/MomentRelative.lean`](../lean/FalseWorkPapers/Positions/MomentRelative.lean) tested this and produced a negative result: the four cell predicates are propositional-shape-distinct Heyting conditions, not specializations of a single Heyting term parameterized by cell. Schema-level uniformity holds (uniform moment-relative kernel image, uniform Heyting register, uniform gate shape); theorem-grade unity does not. The question is closed; reopening it would require a categorical move outside the Heyting language (substantial commitment, not routine refinement).

**5. Non-trivial-distinction hypothesis for `refusal_residue`.** **PARTIALLY RESOLVED (2026-05-20).** The Lean proof was closed under the hypothesis `Δ.HasIrregularKernel := ∃ Y : C, (kernelImage Δ Y)ᶜᶜ ≠ kernelImage Δ Y`, which is strictly stronger than the framework's original "non-trivial `Δ` on a non-Boolean topos" condition. The strengthened hypothesis says the kernel image **is** the non-Boolean witness at some object, rather than merely that the topos has non-Boolean content somewhere; this closure is recorded in [`../lean/FalseWorkPapers/Positions/Refusal.lean`](../lean/FalseWorkPapers/Positions/Refusal.lean) (theorem `refusal_residue`).

The **refusal bridge conjecture** is the open framework-level question: under what structural conditions does `Δ.NonTrivial + NonBoolean C` imply `Δ.HasIrregularKernel`? The conjecture is non-trivial because the regular elements of any Heyting algebra (those `x` with `x = xᶜᶜ`) form a Boolean sub-algebra; a non-trivial `Δ` whose kernel image lands entirely in the regular sub-algebra at every object would produce a Boolean kernel inside a non-Boolean topos — a generically available class of structures, not a constructed counterexample. The bridge is therefore not a routine refinement of the proof; it is a real conjecture about which structural properties force a distinction operation off the regular sub-algebra. Tracked as a named claim at [`../validation/claims/refusal-bridge.md`](../validation/claims/refusal-bridge.md).

**6. Level structure for Deep Infrastructure.** Two paths in `Infrastructure.lean`: ad-hoc fibration over `ℕ`, or a general level-poset. Also relevant to §7.1's Infrastructure-restricted iteration: with level structure, Infrastructure-Commitment-yes becomes non-trivial (fixed points are level-saturated systems).

**7. Balance condition for Distribution.** Three candidate refinements in `Distribution.lean` (anti-chain, equimeasure, categorical decomposition). Also relevant to §7.1's Distribution-restricted iteration.

**8. Categorical specification of `Moment`.** The moment-relativization currently lives as a working hypothesis: a filtered preorder `T` with a monotone `BoundaryState : T → (Y : C) → Subobject (D Y)`. Whether `Moment` should be made a derived construct (e.g., the indexing category of a filtered diagram of distinction structures, or sheaves over a temporal locale) rather than schematic data is open. Affects the canonicity claim's formal status.

**9. Translation between distinction-structure and F-coalgebra registers.** The validation-claim v0.2 schema operates in the F-coalgebra register; the Lean operates in the distinction-structure register. The translation is not identical — see [`../validation/claims/five-position-derivation-formalization.md`](../validation/claims/five-position-derivation-formalization.md) v0.3 § "Register translation" for the table. Whether the translation is faithful (every `(F, α)` classifying into position `P` lifts to a `(Δ, f)` classifying into the same `P`) is itself open work.

**10. Canonicity claim (empirical).** The strong canonicity claim — *moment-relative Commitment-yes at the work's cell is necessary for canonicity in general* — is empirically falsifiable. The test: a structured canonical-counterexample search (candidates include Stettheimer, Werefkin, late-canonized figures, technical-innovation cases, anonymous or collaborative works). Open empirical work, not formal work. Result calibrates how the claim should be stated in Paper 1 v11.8 and Paper 3 v10.0.

---

## 8. Honesty notes

Four notes a reader should hold while reading the dictionary above.

**Status of the framework's central claims.** The dictionary makes four substantive claims at four different epistemic levels. A reader should keep the four in separate boxes.

| Claim | Status |
|---|---|
| **Four-position partition** over morphisms (Infrastructure, Distribution, Exploitation, Refusal disjoint and exhaustive in the topos register) | **Kernel-checked theorem (2026-05-19).** Both exhaustiveness and the six pair-wise disjointness arguments are discharged in `four_position_partition` ([`../lean/FalseWorkPapers/Positions/Partition.lean`](../lean/FalseWorkPapers/Positions/Partition.lean)) against the in-repo `HeytingAlgebra (Subobject Y)` instance. The instance is upstreamed as Mathlib PR [#39618](https://github.com/leanprover-community/mathlib4/pull/39618). Axiom audit confirms kernel-axioms-only dependence (`propext`, `Classical.choice`, `Quot.sound`). |
| **Commitment as binary gate at each cell** (uniform shape, cell-specific content) | **Schema-level architecture.** No theorem-grade unity claim. The two-parameter unification was tested in Lean (2026-05-10) and found to fail at theorem level while holding at schema level. Operationally a binary fixedness condition per cell; predicate-shape uniform across cells. |
| **Moment-relative Commitment-yes is necessary for canonicity** | **Open empirical claim.** Falsifiable by canonical-counterexample search. The motivating observation (Duchamp's *Fountain* pushes the boundary *as understood in 1917*) suggests the strong claim, but the empirical test is pending. Pending result, the claim should be stated as "necessary for canonicity *via structural completion*" rather than necessary in general. |
| **Moment-relativization itself** | **Working hypothesis.** Categorical structure of `Moment` not yet specified. Current implementation is schematic data (filtered preorder + monotone boundary-state function); whether `Moment` should be a derived construct is open (see §7.8). |

Each line has its own status. The headline is the partition; the gate is operationally useful but architecturally schema-level; the canonicity claim is testable but untested; the moment-relativization is a working hypothesis underwriting both the gate and the canonicity claim.

**Classification status.** Most of the empirical classifications in § 5 are *structurally inferred* — produced by applying the framework's vocabulary to specific works. The level of independent grounding varies by domain:

- *Music:* Tymoczko's three-way scale-space discrimination corroborates the Coltrane / Bach / equal-temperament cluster. Pythagorean number theory and the music-kernel claim cluster (1–6) ground the formal substrate. **Best-anchored.**
- *Cinema:* Cutting's three-of-four kernel-criteria affirmation grounds the cut's status as kernel. Specific work-by-work classifications are LLM-generated. **Mid-anchored.**
- *Physics:* Cubitt et al. (2015) on spectral-gap undecidability anchors the comma's formal substrate; the interpretation-classification (Copenhagen, decoherence, quantum computing, pilot-wave, Many-Worlds) is structural inference. **Mid-anchored.**
- *Painting, literature, software, architecture:* No specialist corroboration of work-by-work classifications. The painting trajectory's four-mechanism Exploitation cluster (Cézanne, Picasso, de Kooning, Pollock) and Commitment pole-symmetry (Rothko, Newman) are sophisticated structural claims that have not been validated by painting specialists. **Structurally inferred.**

A reader should treat the music classifications as having a different epistemic status from the painting classifications. The framework's correction architecture (Paper 2) is designed to handle this asymmetry over time as more specialists engage; it is not yet fully populated.

**Disjointness of the dictionary.** The four-position partition's claim that Infrastructure, Distribution, Exploitation, Refusal are pairwise disjoint is, as of 2026-05-19, a kernel-checked theorem (`four_position_partition`, §6 above). All six pair-wise disjointness arguments and the exhaustiveness case-split reduce to Heyting-algebra identities (`a ⊓ aᶜ = ⊥`, `aᶜᶜ ⊓ aᶜ = ⊥`, the Galois connection `a ⊓ b = ⊥ ↔ a ≤ bᶜ`) plus the image-factorization helper `isRefusal_iff_image_le_compl` (closed in Path 5, 2026-05-19). The Infrastructure predicate was repaired on 2026-05-17 from the original endpoint-iso formulation to the image-subobject form `img ≤ kernelImage Δ Y`, which closed an exhaustiveness gap that the endpoint-iso form had left open. The Commitment-as-gate reframe (2026-05-10) eliminated the prior central disjointness problem (Commitment/Exploitation within `(Im(η))ᶜᶜ`) by making Commitment a gate inside each cell rather than a fifth cell competing for the closure region. A reader should hold the four-position partition as a kernel-checked theorem of the framework, not a candidate. The gate's "yes/no" classification adds a binary annotation within each cell; it does not multiply cells.

**The register's hazards.** The dictionary lives in the Heyting-algebraic / locale-theoretic / intuitionistic-logical register. Adjacent registers — manifold geometry, measure-concentration in high dimensions, Levin's apparatus, Tymoczko's voice-leading orbifolds — share vocabulary but not structure. Bridges between registers require explicit construction, not implicit transfer. See [`../lean/FalseWorkPapers/Positions/REGISTER.md`](../lean/FalseWorkPapers/Positions/REGISTER.md) for the framing-level discussion.

---

## 9. What this document is and isn't, redux

This is a partially-formalized apparatus with expository scaffolding. It records what has been settled (the closure-residue construction for Exploitation; the four-position partition as a **kernel-checked theorem**; the refusal residue as a **kernel-checked theorem under `HasIrregularKernel`**; the in-repo Heyting instance and its upstream PR; the Commitment-as-gate reframe; the closure of the two-parameter unification question; the registers and their hazards) and what has not (the per-cell restricted-iteration characterizations, the continuous-iteration question, the categorical specification of moments, the translation to the F-coalgebra register, the canonical-counterexample empirical test, the classification-anchoring asymmetry, and — at framework level — the refusal bridge conjecture connecting `Δ.NonTrivial + NonBoolean C` to `Δ.HasIrregularKernel`).

The published-paper version is destined for Paper 3 § 4 in the v10.0 revision, conditional on at least the per-cell characterization (open problem 1) progressing or being engaged by specialist input. Until then, this document and the Lean it points at are the framework's formal apparatus, with the validation claim ([`../validation/claims/five-position-derivation-formalization.md`](../validation/claims/five-position-derivation-formalization.md)) carrying the version-tracked schema and its hedges, and [`../validation/claims/refusal-bridge.md`](../validation/claims/refusal-bridge.md) carrying the named open framework-level conjecture.

The document exists for category theorists or topos theorists who want to assess the apparatus. It is not for general readers — Paper 1 § 3.4 carries the verbal derivation of the dictionary for that audience, and Paper 4 carries the ontological account of the comma's status. This document is what to send a Yanofsky, a Leinster, a Corfield, or a Mazzola when asking "is the apparatus coherent? what is it missing? where would a specialist push?"

If you are reading it to assess the framework's formal status: the central structural claim (Theorem 0, four-position partition) is now a kernel-checked theorem in Lean against an in-repo Heyting instance that has been upstreamed to Mathlib (PR [#39618](https://github.com/leanprover-community/mathlib4/pull/39618)). The refusal residue (Theorem 1) is kernel-checked under the strengthened hypothesis `HasIrregularKernel`, with the gap to the original framework hypothesis (`NonTrivial Δ + NonBoolean C`) promoted to a named open conjecture rather than a hidden assumption. The open problems are named honestly, and the remaining substantive work is the per-cell iteration characterization (open problem 1) and the refusal bridge conjecture (open problem 5). One round of specialist engagement plus the per-cell characterization would close the path from this document to a Paper 3 v10.0 § 4 publishable-quality formalization. The four-position partition plus the gate as documented schema, with the per-cell iterations and the refusal bridge as named open work, already constitutes a modest publishable artefact in its current shape.

The framework's central structural claim has been evaluated and survives kernel-level scrutiny; the framework's substantive open questions are now named, scoped, and tracked.

---

## Provenance

Draft created May 2026 following the closure-residue commitment for the Exploitation predicate (commit `205ada5`), the validation-claim v0.3 update recording the divergence from the F-coalgebra schema (commit `fe84c26`), and the register note clarification (commit `4917cdf`). The drafting was prompted in part by reflection on whether a separate "comma paper" was warranted; the conclusion was that the formal apparatus is sketch-quality, and that the appropriate venue is this expository companion document plus the Lean source plus the validation claim, with eventual escalation to Paper 3 § 4 v10.0 conditional on open problems clearing.

Revised 2026-05-10 following two related architectural moves: (i) the *Commitment-as-gate* reframe, which moved Commitment from a fifth lattice cell to a binary fixedness condition within each of the four cells, and dissolved the previously-named "Commitment/Exploitation disjointness within `(Im(η))ᶜᶜ`" problem (the dissolution being a consequence of the reframe rather than a solution); (ii) the *two-parameter unification* test in [`../lean/FalseWorkPapers/Positions/MomentRelative.lean`](../lean/FalseWorkPapers/Positions/MomentRelative.lean), which closed the question of whether the four cell-restricted iterations derive from a single uniform construction (negative on theorem-grade, positive on schema-level). The revision reframes the dictionary as four-cells-plus-gate, replaces the dissolved central open problem with the per-cell characterization problem, and adds the four-claims-with-four-statuses table to §8.

Revised 2026-05-19/20 following the formalization sweep that closed the four-position partition and the refusal residue. Specifically: (i) on 2026-05-19 the in-repo `HeytingAlgebra (Subobject Y)` instance landed at [`../lean/FalseWorkPapers/Heyting/SubobjectInstance.lean`](../lean/FalseWorkPapers/Heyting/SubobjectInstance.lean) (`FalseWork.Heyting.heytingAlgebra`), closing Open Problem 2; the partition theorem `four_position_partition` was kernel-checked against this instance in [`../lean/FalseWorkPapers/Positions/Partition.lean`](../lean/FalseWorkPapers/Positions/Partition.lean) via a Heyting case-split plus the image-API helper `isRefusal_iff_image_le_compl` (closed in Path 5 the same day); (ii) on 2026-05-20 the Heyting instance was upstreamed as Mathlib PR [#39618](https://github.com/leanprover-community/mathlib4/pull/39618); (iii) on 2026-05-20 the refusal residue was kernel-checked under the strengthened hypothesis `Δ.HasIrregularKernel` in [`../lean/FalseWorkPapers/Positions/Refusal.lean`](../lean/FalseWorkPapers/Positions/Refusal.lean), with the gap to the original framework hypothesis (`NonTrivial Δ + NonBoolean C`) promoted to the named open *refusal bridge conjecture* tracked at [`../validation/claims/refusal-bridge.md`](../validation/claims/refusal-bridge.md), partially resolving Open Problem 5. The revision updates §6 (intro line, Theorem 1 statement and content, full proof walk-throughs for Theorems 0 and 1, axiom audit), §7 (Open Problems 2 and 5), §8 (honesty table first row, disjointness paragraph), and §9 (conclusion) to reflect these closures. No new architectural commitments are introduced; the document is updated to state honestly what has been settled and what remains.

Any further substantive change to the formal commitments — closure-residue, predicates, signature theorems, open problems, gate architecture, moment-relativization — should land here as a patch, in the validation claim as a version bump, and in the Lean as commits, in that order or in parallel.
