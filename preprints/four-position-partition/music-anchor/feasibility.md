# Music-Anchor Feasibility Memo

**Author:** Chris Brink
**Date:** May 2026 (initial scoping); updated May 2026 with Step B outcome and Path B redirection.
**Status:** Step A (scoping) complete. Step B (initial Wolfram empirical test) complete with a documented negative result: the diatonic-closure Moore lattice on Z/12 is not Heyting (§11). Path B (subgroup / divisor lattice of 12, layered framing — Layer L kernel-checked, Layer T cited from topos theory, Layer D deferred) delivered (§12); see `lean/FalseWorkPapers/Lattice/FourPositionLattice.lean` for the abstract theorem and `lean/FalseWorkPapers/Examples/DivisorLattice12.lean` for the concrete music-anchor witness.

---

## 1. Purpose and scope

This memo scopes a concrete feasibility test for instantiating the four-position partition theorem (Brink 2026, `paper.md`) in the music domain, using the categorical apparatus of Tymoczko (2026, *Journal of Music Theory* 70:1), Atif et al. (2013), and Freund/Andreatta/Giavitto (2017).

The memo does *not* attempt the test itself. It specifies (a) which music topos to use, (b) which distinction operator to construct, (c) what the falsifiable empirical prediction is, and (d) what the obstacles are. The output is a list of "this is what would need to be computed or verified, and this is what would constitute success or failure" — not a result.

If this memo identifies blocking obstacles before any code is written, that is a win. If it identifies a path that survives scrutiny, the next step (Step B) is a computational implementation, likely in the project's existing Wolfram environment.

This memo is **not** related to the existing music-kernel formalization work (Paper 3 § 4, Paper 5, `validation/claims/music-kernel-umbrella.md`). That work formalizes The Fifth as an endofunctor on subsets of ℝ/ℤ, with terminal-coalgebra failure as the irreducible-feature signature. The present memo addresses a different and complementary question: instantiating the four-position partition theorem on a music topos. The two efforts converge on the same domain but operate at different levels of the framework's apparatus.

---

## 2. The test claim

The framework asserts that the four-position partition theorem (Theorem 5.1 of `paper.md`) applies to elementary topoi with non-trivial distinction structure, and that music is one domain admitting such a structure. This memo specifies a falsifiable test of that claim:

**Claim under test.** There exists a small concrete music topos C, with a non-trivial distinction structure (D, η, ι) on it, such that the four-cell partition of morphisms in C is *non-vacuous* (all four cells are inhabited) and *empirically aligns* with Tymoczko's independent three-field classification of three reference works:

- *A Love Supreme* (Coltrane 1965) — Tymoczko: diatonic field. Framework prediction: **Infrastructure**.
- *Giant Steps* (Coltrane 1959) — Tymoczko: symmetric field (augmented-triad cycle). Framework prediction: **Exploitation**.
- *Interstellar Space* (Coltrane 1967) — Tymoczko: chromatic field. Framework prediction: **Refusal**.

Tymoczko has stated this three-field classification of these three works in published work and in personal correspondence (cited with permission, March 2026). If the framework's classification under D matches Tymoczko's three-field classification, the test is provisionally passed. If it disagrees, the test is failed and diagnostic work follows.

The Distribution cell is not tested by this trio; the test is over three of four cells. A second test target (likely an Ellington or Strayhorn work) would be needed to test Distribution.

---

## 3. Choice of music topos

### 3.0 Instrumental use of existing apparatus

This memo proposes constructing a small music topos for the feasibility test. The construction is *instrumental*: it borrows categorical apparatus developed by Mazzola, Tymoczko, Andreatta, Popoff, Ehresmann, Freund, Giavitto, Atif, and others, and tests whether the framework's partition theorem (Theorem 5.1 of `paper.md`) instantiates on that apparatus to produce a classification matching Tymoczko's independent three-field tripartition of Coltrane's three works.

The memo does *not* propose a contribution to music theory. The categorical music infrastructure already exists in published form; this memo and the work it scopes use that infrastructure as a *test-bed* for the framework's general theorem. Specifically:

- The underlying music category (a small pitch-class groupoid) is drawn from Tymoczko 2026.
- The general topos-theoretic music apparatus that legitimates the construction (presheaf topoi on music groupoids, sheafification, subobject classifiers) is Mazzola's (Mazzola 2002).
- The functor-and-natural-transformation machinery for encoding specific works as PK-Nets is Mazzola-Andreatta (2006) and Popoff-Andreatta-Ehresmann (2018).
- The empirical three-field classification of Coltrane's works against which the test is calibrated is Tymoczko's (Tymoczko 2011, 2026, plus correspondence).
- The lattice-theoretic representation of musical relations as concept lattices is Freund-Andreatta-Giavitto (2017); the mathematical-morphology operators on those lattices that inform the choice of D are Atif et al. (2013).

The framework's contribution at the music layer is the structural-typological reading of the partition's four cells as practitioner-positions and the demonstration that the partition theorem instantiates non-vacuously on this borrowed infrastructure. The contribution does not include the music infrastructure itself.

### 3.1 Candidate: presheaves on Tymoczko's chromatic pitch-class groupoid

Tymoczko (2026) formalizes musical space as a groupoid. The simplest relevant groupoid for the Coltrane test is:

- **Objects:** the twelve pitch classes ℤ/12 = {0, 1, 2, ..., 11}.
- **Morphisms:** generated by transposition `T_n` (n ∈ ℤ/12) and inversion `I`, subject to the standard relations of the dihedral group `D_12`. All morphisms are isomorphisms (it's a groupoid).

Call this groupoid `G_chrom`. The corresponding presheaf topos is `Set^G_chromᵒᵖ`, abbreviated `[G_chrom, Set]`.

This is a Grothendieck topos. By standard topos theory (Mac Lane and Moerdijk 1992, I.4; Johnstone 2002a, A.4.1), it is an elementary topos satisfying the hypothesis bundle of Section 2 of `paper.md`.

### 3.2 Why this groupoid

Three reasons:

1. **Published rigor.** Tymoczko 2026 is a peer-reviewed JMT paper. Using his groupoid means using a specialist-vetted apparatus, not one of our own invention.
2. **Small enough to compute.** Twelve objects; |G_chrom| = 24 morphisms (T_n and I·T_n for n ∈ ℤ/12). Subobject lattices of small objects in this topos are computable.
3. **Generic enough to host the test.** Coltrane's pitch material is articulated in chromatic pitch classes; transposition and inversion are the natural symmetries; the topos has the right vocabulary.

### 3.3 Alternative considered: Tymoczko's four-object Tonnetz groupoid

Tymoczko (2026, §3) identifies four distinct objects called the Tonnetz, formalized as a four-object groupoid with specific morphism structure. This is a richer apparatus but adds complexity without obvious benefit for the Coltrane test. The chromatic groupoid is the cleaner starting point. The Tonnetz groupoid is a natural next test target if the chromatic test works.

### 3.4 Alternative considered: concept lattices on chord/scale relations (Freund/Andreatta/Giavitto)

Freund et al. (2017) build concept lattices from binary relations (e.g., "chord X is contained in scale Y"). Concept lattices are complete lattices and therefore carry Heyting structure under suitable conditions, but the lift to a topos with a *functorial* distinction operation requires more bridging work than the presheaf-on-groupoid approach. Better as a *second* construction once the presheaf-topos test is run.

---

## 4. Choice of distinction operator D

### 4.1 The construction: D from a reflection onto the diatonic subcategory

A *diatonic scale* is the orbit of a chosen rotation of {0, 2, 4, 5, 7, 9, 11} (C-major in pitch-class notation) under transposition by ℤ/12. There are 12 diatonic scales (one per transposition), each a 7-element subset of ℤ/12, related to each other by `T_1` shifts.

Consider the full subcategory `G_diat ⊆ G_chrom` whose objects are pitch classes 0–11 (same as G_chrom) but whose morphisms are restricted to *diatonic-preserving* transformations: transpositions and inversions that map some chosen reference diatonic scale to itself or to another diatonic scale. This restriction is well-defined and `G_diat` is a (smaller) groupoid.

The inclusion `i: G_diat ↪ G_chrom` induces a restriction-of-presheaves functor `i*: [G_chrom, Set] → [G_diat, Set]` which has a right adjoint `i_*` (right Kan extension). The composition

```
D := i_* ∘ i* : [G_chrom, Set] → [G_chrom, Set]
```

is an endofunctor on the music topos.

The unit `η: 1 ⟹ D` of this construction is the unit of the adjunction `i* ⊣ i_*`.

**Claim (to be verified in Step B):** D is an idempotent monad on `[G_chrom, Set]`, hence by Remark 5.5 of `paper.md` it determines a distinction structure with `ι.hom = µ: D ∘ D ⟹ D` the multiplication of the monad. The "diatonic-coherent" presheaves are the algebras for this monad and form a reflective subcategory of the music topos.

### 4.2 Why this D

This construction is principled:
- It is an instance of the general "reflect onto a full subcategory" construction (Borceux 1994, vol. 1, §4.2).
- It is the categorical formalization of the informal operation "find the diatonic content of a musical object."
- It is non-trivial (η is not an iso): inverting η at a non-diatonic pitch-class set fails because the diatonic content is strictly smaller.
- Under D, the kernel image `a_Y := Im(η_Y)` is exactly the diatonic-projected part of Y. This matches the informal reading of "the diatonic kernel."

### 4.3 Alternative D considered

Three alternatives are worth recording but deferred:

1. **Morphological closure (Atif et al. 2013).** Define `D = εδ` where δ is dilation by perfect-fifth relations and ε is the adjoint erosion. This is idempotent (closure operators are) but requires the subobject lattice to be a concept lattice in the FCA sense, which holds for some choices of underlying relation but not automatically for an arbitrary presheaf topos. Better-suited to the Freund/Andreatta concept-lattice approach (§3.4) than to the presheaf-topos approach proposed here.

2. **Sheafification for a Lawvere-Tierney topology.** Pick j on `[G_chrom, Set]` corresponding to "diatonic coverage." Sheafification gives an idempotent monad and hence a distinction structure. This is roughly equivalent to D above but more abstractly specified; the reflection-onto-subcategory version is more concrete.

3. **Voice-leading closure (Tymoczko 2011).** For a pitch-class set S, D(S) = the orbit of S under voice-leading distance ≤ ε for some chosen ε. This is closer to Tymoczko's empirical practice but requires a metric structure on the topos that the bare presheaf topos doesn't carry.

For the Coltrane test, the diatonic-reflection D is the cleanest first move. The alternatives are natural follow-ups.

---

## 5. Non-Boolean check

**The critical structural requirement.** The four-cell partition collapses to three cells if `Sub(D(Y))` is Boolean at every Y of interest (Remark 5.3 of `paper.md`). Exploitation exists as a distinct cell *only* if the subobject lattice carries non-trivial double-negation closure.

### 5.1 Generic expectation

Presheaf topoi `[C, Set]` on a non-trivial category C are generically non-Boolean. The subobject lattice of a representable presheaf `y(c) = Hom(-, c)` is the lattice of *sieves* on `c`, which is non-Boolean whenever `c` has a non-trivial sieve structure. For `G_chrom` (a groupoid where every morphism is iso), the sieve structure is determined by the automorphism group at each object, and the resulting subobject lattices are computable.

### 5.2 The specific check

For Y = the representable presheaf `y(0)` (pitch class 0 = C), compute `Sub(y(0))` explicitly and check whether `Pᶜᶜ = P` holds for all `P ∈ Sub(y(0))`.

Heuristic: a groupoid presheaf topos has Boolean subobject lattices iff the groupoid is *discrete* (only identity morphisms). `G_chrom` is far from discrete (24 morphisms on 12 objects), so generically we expect non-Boolean structure. But this needs verification, not just expectation.

**Falsifiable claim 1:** `Sub(D(Y))` is non-Boolean for at least one Y ∈ Ob([G_chrom, Set]).

If false, the framework's music anchor fails at the structural level (Sierpinski-style failure mode from Phase 1.1, escalated to a different reason). If true, the test can proceed to the Coltrane check.

---

## 6. The Coltrane test

### 6.1 Encoding the three works as morphisms

Each work is represented by its *characteristic pitch-class material*, encoded as a morphism into a representable presheaf in `[G_chrom, Set]`. The encoding is sketched here; full formalization is Step B.

**A Love Supreme — "Acknowledgement" theme.** The four-note motif F-Ab-Bb-Eb-F (the "a love supreme" vocal figure, pitch classes 5, 8, 10, 3, 5). Embedded in the F-minor / Db-major diatonic context. The pitch-class set {3, 5, 8, 10} sits inside the Db-major diatonic scale {1, 3, 5, 6, 8, 10, 0}.

The morphism `f_LS: X_LS → Y` has its `D.map`-image inside `a_Y` (the diatonic kernel image) under the diatonic-reflection D. **Prediction: IsInfrastructure(f_LS).**

**Giant Steps — augmented-triad cycle.** The three tonics B-G-Eb (pitch classes 11, 7, 3) form an augmented triad. The full chord progression cycles through three diatonic keys (B-major, G-major, Eb-major) related by major thirds. The pitch-class set of the *combined* tonal material spans all three diatonic scales: {11, 7, 3} as tonics, with B-major = {11, 1, 3, 4, 6, 8, 10}, G-major = {7, 9, 11, 0, 2, 4, 6}, Eb-major = {3, 5, 7, 8, 10, 0, 2}.

The union of these three diatonic scales is a 10-element pitch-class set — not contained in any single diatonic scale. Hence `D.map(f_GS)` is *not* contained in the diatonic kernel image `a_Y`.

But the union is also not the full chromatic complement of any diatonic scale. The set is in the *double-negation closure* of the union of "all diatonic scales reachable by major-third symmetry from the starting key" — a closure-residue.

**Prediction: IsExploitation(f_GS).** That is, `D.map(f_GS) ≤ a_Yᶜᶜ` but not `≤ a_Y`.

**Interstellar Space — chromatic-saxophone exploration.** The pitch material is not bound to any diatonic context; Coltrane uses the full chromatic gamut, often gliding microtonally. The pitch-class set under D-projection reduces to the trivial subobject (no diatonic content) or to a subobject in the strict diatonic complement.

**Prediction: IsRefusal(f_IS).** That is, `D.map(f_IS) ≤ a_Yᶜ`.

### 6.2 Falsification criteria

The test fails if any of the following hold after computation:

1. `D.map(f_LS)` does *not* satisfy `≤ a_Y` — A Love Supreme does not classify as Infrastructure.
2. `D.map(f_GS)` satisfies `≤ a_Y` — Giant Steps classifies as Infrastructure (wrong cell).
3. `D.map(f_GS)` satisfies `≤ a_Yᶜ` — Giant Steps classifies as Refusal (wrong cell).
4. `D.map(f_GS)` does not satisfy `≤ a_Yᶜᶜ` — Giant Steps is unclassified by any of the four cells, which would indicate the partition is incomplete or the encoding is wrong.
5. `D.map(f_IS)` does not satisfy `≤ a_Yᶜ` — Interstellar Space does not classify as Refusal.

Any of these failures is informative. The most concerning failure is #4 (Giant Steps falling outside all four cells), since it would mean the framework's apparatus does not capture the symmetric-field music at all. Failure #2 or #3 would mean the framework captures Giant Steps but misclassifies it — diagnostic for the choice of D rather than the partition itself.

### 6.3 Success criterion

All three predictions hold under the computed D-images. This would constitute the first kernel-checked (or computationally checked) instance of the four-position partition theorem on a domain-specific topos, with classification matching independent specialist work.

---

## 7. Connection to existing project work

Two existing pieces of project work are relevant and should be referenced rather than duplicated:

### 7.1 Music-kernel formalization (Papers 3, 5; `validation/claims/music-kernel-umbrella.md`)

That work formalizes The Fifth as an endofunctor on subsets of ℝ/ℤ and shows terminal-coalgebra failure. It does *not* construct a topos and does *not* apply the four-position partition. The present memo proposes a complementary construction at a different level of the apparatus.

**Connection point:** the music kernel's endofunctor `D_kernel(Y) = Y ∪ (Y + α)` on subsets of ℝ/ℤ is a *separate* object from the present D on the presheaf topos. The kernel work establishes that *generative iteration of The Fifth* has a specific structural signature (irreducibility, terminal-coalgebra failure). The present work proposes that *practitioners' relationship to The Fifth as a generator* partitions into the four cells via a distinction structure that captures "how the practitioner engages the diatonic vs. non-diatonic content the kernel produces."

If both efforts succeed, they constitute two complementary formalizations of music at different levels: the *kernel* level (what the generator is and why it produces irreducible features) and the *practitioner-position* level (how morphisms into the kernel territory distribute structurally).

### 7.2 Existing extraction data

The project has Wolfram-based extraction infrastructure (`wolfram/paste-cells/`, `wolfram/wolfram-bundle.wl`) and Bach chorale data. This infrastructure could be repurposed for the Step B computational implementation. Specifically:

- Pitch-class extraction routines exist and can produce the pitch-class sets needed for the Coltrane encoding.
- Spectrum validation infrastructure can verify the diatonic-projection D is computed consistently.
- The "structural profile" pipeline at falsework.dev is *not* used in this test; the test is purely categorical computation on a small topos, not human-readable profile generation.

---

## 8. Open questions and obstacles

Honest accounting of what could block the test.

**Obstacle 1: D not actually idempotent.** The reflection-onto-subcategory construction usually produces idempotent monads but verification on the specific G_diat ⊆ G_chrom inclusion needs explicit computation. The inclusion of one groupoid into another is full and faithful, so the right Kan extension is fully faithful too, so the monad is idempotent — but this is a textbook-level check that should be carried out concretely rather than asserted.

**Obstacle 2: Boolean collapse.** The subobject lattice of presheaves on G_chrom could turn out Boolean at the objects of interest. Generic theory says probably non-Boolean, but specific check needed. If Boolean, escalate to a richer topos (e.g., presheaves on the four-object Tonnetz groupoid, or a presheaf topos on a non-discrete category).

**Obstacle 3: Encoding ambiguity for the three works.** Each work has many possible pitch-class encodings (the whole work? the head theme? the recurring motif? a representative measure?). The test as stated uses characteristic motivic material. A more rigorous encoding would integrate over the full pitch-class profile of the work. The choice affects the result. The encoding choice should be specified and defended before computation.

**Obstacle 4: The Distribution cell isn't tested.** Three works exercise three of four cells. To test all four, a fourth work needs to be picked — one Tymoczko has classified as occupying the *hybrid* region between two fields. Candidates: Ellington's "Sophisticated Lady," Strayhorn's "Lush Life," or a Bartok string quartet movement. Choice deferred until Coltrane test result is in.

**Obstacle 5: Computability of the music topos.** Subobject lattices of presheaves on G_chrom may be large enough to require careful algorithmic enumeration. Wolfram has the tools; this is engineering, not blocking, but worth flagging.

**Obstacle 6: The Wolfram environment is not Lean.** Step B in Wolfram gives a *computational check*, not a *kernel-checked proof*. The kernel-checked version would require Lean implementation parallel to the Phase 1.2 M-Set work. The Wolfram check is appropriate for feasibility; a Lean version would be appropriate if the feasibility test passes.

---

## 9. Recommended next step

If the memo's specification survives review, **Step B is a Wolfram notebook** implementing the following minimal pipeline:

1. Construct `G_chrom` (dihedral-12 groupoid on 12 pitch classes).
2. Construct `G_diat` as the chosen subgroupoid.
3. Construct the restriction `i*` and the right Kan extension `i_*` of presheaves.
4. Define D = i_* ∘ i* and verify idempotency on a small test object.
5. Compute `Sub(D(y(0)))` and check whether it is Boolean.
6. Encode the three Coltrane works as morphisms via their characteristic pitch-class material.
7. Compute the D-images and classify into cells.
8. Compare against Tymoczko's three-field classification.

Expected effort: a few days of focused Wolfram work. The deliverable is a notebook with cell-by-cell intermediate results and a final classification table.

If the notebook succeeds, the third step (Step C) is a writeup as a short companion paper to `paper.md`, perhaps titled "A Heyting Refinement of Tymoczko's Tripartition," intended for a music-theory audience. That paper would be the framework's music-anchor publication.

If the notebook fails at any stage, the failure mode determines the next move:
- Failure at idempotency check → revise the D construction.
- Failure at non-Boolean check → escalate to richer base topos.
- Failure at classification match → diagnostic on the choice of D or the encoding of the works.

---

## 10. What this memo does *not* claim

For honest scope-limiting:

- It does not claim the test will succeed.
- It does not claim that even a successful test would validate the framework's cross-domain typology — only the music instantiation.
- It does not claim that the diatonic-reflection D is the canonical choice; it is one principled candidate among several.
- It does not claim that the Coltrane classification is settled music theory; Tymoczko's three-field classification is one specialist's view, and the framework's matching it would be corroboration, not proof.
- It does not address the framework's *Commitment gate* (binary fixedness within each cell); that is orthogonal to the partition test and would be a separate exercise.
- It does not address the *canonization closure* layer (`FalseWork.Positions.CanonizationClosure`); that layer applies once a non-trivial canonical figure is identified within a cell, and is downstream of the present test.

The test scoped here is the *minimum* concrete computation that would move the music anchor from "claimed application" to "demonstrated application." It is not a full music-domain treatment, and it should not be presented as one.

---

## 11. Step B outcome (May 2026): the diatonic-closure Moore lattice is not Heyting

The initial Step B implementation lived at `wolfram/music-anchor/four-position-music.wl` (v1) and `four-position-music-v2.wl` (v2). The construction sidestepped the full `[G_chrom, Set]` presheaf-topos setup of §3.1–§4.1 and worked directly at the *lattice level* via a Moore closure operator

```
diatonicClosure[P] = intersection of all 12 diatonic scales containing P,
                      or Z/12 if no scale contains P.
```

The closed sets under this closure form a complete lattice of 92 elements, with 54 non-regular elements (`P ≠ ¬¬P` under the lattice's apparent Heyting operations) — sufficient material *in principle* for the four-position partition to apply non-vacuously.

### 11.1 What v2 ran

Removed all Tymoczko-prediction anchoring (per user direction: "stick to math"). For four mathematically-picked non-regular kernels (`{0}`, `{0,7}`, `{0,2,7}`, `{3,5,8,10}`), v2 classified all 92 closed sets and 12 pitch-class test inputs into the four cells of Definition 4.1 of `paper.md`. Each kernel produced an UNCLASSIFIED count in the lattice partition (22, 18, 13, 7 respectively) — a category that should be empty if the four cells truly partition `Sub(D(Y)) ∖ {⊥}` as Theorem 5.1 asserts.

### 11.2 Diagnosis: the lattice is not Heyting

The UNCLASSIFIED counts are the symptom; the cause is that the closed-set lattice is **non-distributive**, hence not a Heyting algebra. Two concrete witnesses (both kernel-computable in v2 §9):

**Witness 1 (Heyting identity failure).** Take kernel `a = {0}` and test set `X = D_11 = B-major = {1,3,4,6,8,10,11}`.

- `X ⊓ a = X ∩ {0} = ∅ = ⊥`
- `¬a = D_2 = D-major = {1,2,4,6,7,9,11}` (the largest closed set disjoint from `{0}`)
- `X ⊆ ¬a`? **No** — `X` contains `3, 8, 10`, none of which are in `D-major`.

In a Heyting algebra, `b ⊓ a = ⊥ ⟺ b ≤ aᶜ`. Here the implication fails: `X ⊓ a = ⊥` but `X ⊄ aᶜ`.

**Witness 2 (distributivity failure).** Take
- `P = {0,1,3,5,8,10} = D_1 ∩ D_8` (closed)
- `Q = D_0 = C-major`
- `R = D_3 = Eb-major`

Then:
- `Q ⊔ R = closure({0,2,3,4,5,7,8,9,10,11}) = Z/12` (no diatonic scale contains 10 chromatic pitches)
- `P ⊓ (Q ⊔ R) = P = {0,1,3,5,8,10}`
- `P ⊓ Q = {0,5}`, `P ⊓ R = {0,3,5,8,10}`
- `(P ⊓ Q) ⊔ (P ⊓ R) = closure({0,3,5,8,10}) = {0,3,5,8,10}`

`P ⊓ (Q ⊔ R) = {0,1,3,5,8,10} ≠ {0,3,5,8,10} = (P ⊓ Q) ⊔ (P ⊓ R)`. The lattice fails distributivity, hence cannot be Heyting.

### 11.3 What this means

The diatonic-closure Moore-closure construction on `Z/12` does **not** satisfy the hypothesis of Theorem 5.1. The four-position partition theorem requires `Sub(D(Y))` to carry a Heyting algebra structure (paper.md §2, building on Mac Lane and Moerdijk 1992, IV.6 Proposition 2). The lattice here is a complete lattice but not a distributive one; the apparent "Heyting operations" computed in v2 (`heytingNot[P]` as the largest closed set disjoint from `P`) do not satisfy the Heyting identities, and the four position predicates do not partition the lattice.

This is a clean negative result at the lattice-level construction. It is **not** a refutation of the four-position partition theorem (which is a theorem about elementary topoi, independently kernel-checked in Lean against Mathlib4) and it is **not** a refutation of the music application (which was never claimed at this construction level). It is a refutation of the specific *shortcut* — sidestepping the presheaf-topos apparatus by working directly with a Moore closure on `Z/12` — that v1/v2 attempted.

The framework's machinery is genuinely picky about what counts as a distinction structure. Not every natural-looking closure on `Z/12` qualifies; distributivity is a real constraint.

### 11.4 What survives from v2

- The 92-element closed-set lattice of `diatonicClosure` is correctly computed.
- The two diagnostic witnesses (§9 of v2.wl) are reproducible and certify the diagnosis.
- The Coltrane test was *not run* in v2 (v2 stripped that section per the math-only directive). The Coltrane test as scoped in §6 of this memo is deferred to the topos-level construction.

---

## 12. Path B: the subgroup-lattice / divisor-lattice route (corrected and layered)

**Correction (May 2026).** An earlier draft of this section claimed
that the divisor lattice of 12 arises as `Sub_{Z/12-Sets}(Z/12)` (the
subobject lattice of the regular `Z/12`-set in the topos of
`Z/12`-actions). This is false. The category `Z/12-Sets` is a
**Boolean** topos (in fact every group-action topos is): its
subobject classifier `Ω = sieves on the single object of B(Z/12) = {∅,
Z/12}`, so `Sub(Y) = {⊥, Y}` for every transitive `Z/12`-set `Y`. The
sub-`Z/12`-sets of `Z/12`-regular are not subgroups; they are subsets
closed under the regular action, of which there are only two. The
lattice of *subgroups* of `Z/12` is the subobject lattice of `Z/12`
**in the category of groups**, which is not an elementary topos.

The corrected forward direction has two parts. **Layer L** (lattice
level): the divisor lattice of 12 is a 6-element non-Boolean Heyting
algebra; the four-position partition theorem applies to it at the
tritone kernel non-vacuously. **Layer T** (topos realization): this
lattice arises as `Sub_T(Y)` for at least two clean elementary topoi,
both standard constructions. **Layer D** (distinction structure): a
non-trivial `(D, η, ι)` with `Im(η_Y)` landing on a non-regular element
of the lattice lifts the lattice-level witness to a full
Theorem-5.1 instance.

### 12.1 The lattice (Layer L)

The lattice of subgroups of `Z/12` is isomorphic to the divisor lattice
of 12 (a standard group-theory fact: subgroups of a cyclic group of
order `n` correspond bijectively to divisors of `n`):

  ```
                  Z/12  (order 12, = full chromatic)
                  /    \
              <2>      <3>
            (order 6,   (order 4,
            whole-      diminished
            tone        7th)
            hexachord)  /
              |    /  
              |  /   
              <6>     <4>
            (order 2,  (order 3,
            tritone)   augmented triad)
                  \    /
                   {0}  (order 1, trivial)
  ```

  Six elements, distributive (divisor lattices are always distributive), hence Heyting; non-Boolean (12 = 2²·3 is not squarefree, so the divisor lattice is not Boolean).

### 12.2 Heyting structure on the lattice (Layer L)

Computing in the divisor lattice (with subgroup-order labels): meet is gcd, join is lcm, `¬a = lcm{b : gcd(a,b) = 1}`.

| `a` (order) | subgroup        | `¬a` (order) | subgroup        | `¬¬a` (order) | regular? |
|-------------|-----------------|--------------|-----------------|---------------|----------|
| 1           | `{0}`           | 12           | `Z/12`          | 1             | yes      |
| 2           | `<6>` (tritone) | 3            | `<4>` (aug)     | 4             | **no**   |
| 3           | `<4>` (aug)     | 4            | `<3>` (dim7)    | 3             | yes      |
| 4           | `<3>` (dim7)    | 3            | `<4>` (aug)     | 4             | yes      |
| 6           | `<2>` (whole)   | 1            | `{0}`           | 12            | **no**   |
| 12          | `Z/12`          | 1            | `{0}`           | 12            | yes      |

Two non-regular elements: the tritone (order 2) and the whole-tone hexachord (order 6). Both have non-trivial closure residue. The lattice is provably non-Boolean.

### 12.3 The partition at kernel `a = <6>` (tritone)

With kernel `a = <6>` (subgroup of order 2, the tritone `{0, 6}`):

- `¬a = <4>` (augmented triad `{0, 4, 8}`)
- `¬¬a = <3>` (diminished 7th `{0, 3, 6, 9}`)
- Closure residue `¬¬a ∖ a` is exactly the diminished 7th (which strictly contains the tritone)

The four cells of Definition 4.1 of `paper.md`, lifted to the lattice level via `FalseWork.Lattice.lattice_four_position_partition`, applied to candidate elements `X ∈ L ∖ {⊥}`:

- **Infrastructure** (`X ≤ a = <6>`): `X ∈ {<6>}`, i.e., the **tritone** itself.
- **Refusal** (`X ≤ ¬a = <4>`): `X ∈ {<4>}`, i.e., the **augmented triad**.
- **Exploitation** (`X ≤ ¬¬a = <3>`, `X ⊄ <6>`): `X ∈ {<3>}`, i.e., the **diminished 7th**.
- **Distribution** (`X ⊓ <6> ≠ ⊥` ∧ `X ⊓ <4> ≠ ⊥`): `X` must contain a multiple of 6 and a multiple of 4, so `X ⊇ <gcd(6,4)> = <2>`. Therefore `X ∈ {<2>, Z/12}`, i.e., the **whole-tone hexachord** and the **full chromatic**.

All four cells are inhabited. Excluding the bottom element, every non-bottom element of `L` lands in exactly one of the four cells. The partition is exhaustive and disjoint, as the lattice-level theorem `FalseWork.Lattice.lattice_four_position_partition` (the Heyting-algebra core of Theorem 5.1) requires.

**Uniqueness (computational).** An exhaustive enumeration over the six possible kernel choices `a ∈ L` (run as §5 of `wolfram/music-anchor/layer-t-d-checks.wl`) confirms that the tritone is the *unique* kernel at which all four cells are non-vacuously inhabited. The other non-regular element — the whole-tone hexachord `<2>` — has `¬<2> = {0} = ⊥`, which collapses both Refusal and Distribution to the empty set, leaving only Infrastructure and Exploitation populated. The four regular elements (`{0}`, `<4>`, `<3>`, `Z/12`) each yield even more degenerate partitions (some give *only* Refusal, others *only* Infrastructure). So the lattice empirically singles out the tritone as the kernel choice that fully exercises the partition machinery. This is a structural fact about the divisor lattice of 12, not a stipulated feature of the anchor.

### 12.4 Why this is a non-vacuous music witness

Each subgroup of `Z/12` is a transposition-symmetric pitch-class set with established musical significance:

- `<6>` tritone — the smallest non-trivial symmetric set
- `<4>` augmented triad — symmetric by major third
- `<3>` diminished 7th — symmetric by minor third
- `<2>` whole-tone hexachord — symmetric by whole step
- `Z/12` — full chromatic

These structures are not a contribution of any specific recent author. They underlie Messiaen's "modes of limited transposition" (1944) and the pitch-class set theory of Forte (1973), Rahn (1980), and others. They sit at the level of "elementary group theory of `Z/12`," not at the level of categorical music theory; using them does not depend on or instantiate Tymoczko, Mazzola, Lewin, or Andreatta's specific frameworks. With the tritone chosen as kernel, the partition reads:

| Cell           | Subgroup           | Musical reading                              |
|----------------|--------------------|----------------------------------------------|
| Infrastructure | tritone            | operating in the kernel's territory          |
| Refusal        | augmented triad    | operating in the strict complement           |
| Exploitation   | diminished 7th     | the closure-residue: contains the tritone, but is not the tritone, sitting in the double-negation closure |
| Distribution   | whole-tone, Z/12   | straddling kernel and complement             |

### 12.5 Topos realization (Layer T): existence

The divisor lattice of 12 (= subgroup lattice of `Z/12`) **does not** arise as `Sub_{Z/12-Sets}(Y)` for any `Y` — see the correction at the top of §12. But it does arise as the subobject lattice of an elementary topos in at least two clean ways. Both are general topos theory (no novelty claim attaches to identifying them; the role here is "exhibit any topos realizing the lattice").

**Realization T1 (sheaves on the locale).** Any finite distributive lattice `L` is a frame, hence corresponds to a locale, and the topos `Sh(L)` of sheaves on that locale is an elementary (in fact Grothendieck) topos with `Sub_{Sh(L)}(1) ≅ L`. For our `L` = divisor lattice of 12, `Sh(L)` is a 6-element-subterminal elementary topos. (Mac Lane and Moerdijk 1992, Ch. II; Johnstone 2002a, C1.) The construction is uniform across `L`; the topos has no further music-theoretic content beyond what the lattice carries.

**Realization T2 (presheaves on the join-irreducible poset).** By Birkhoff's representation theorem for finite distributive lattices, `L ≅ O(P)` where `O(P)` is the lattice of down-closed subsets of the poset `P` of join-irreducible elements of `L` (excluding the bottom). For our `L`, the join-irreducibles excluding `1` are `{2, 3, 4}` with order: `2 < 4`, `3` incomparable. Read musically:

```
       4 (diminished 7th  <3>)
       |
       2 (tritone <6>)        3 (augmented triad <4>)
```

— "the augmented triad is incomparable with the chain `tritone ⊂ diminished 7th`." Then `Set^{Pᵒᵖ}` is an elementary topos with `Sub_{Set^{Pᵒᵖ}}(1) ≅ L`. T2 has *some* music-theoretic readability: the underlying category is a 3-object poset of basic symmetric pitch-class types under inclusion.

T1 and T2 are existence proofs by general topos theory. T1 is not constructed in this round (would require localic topos infrastructure). T2's Birkhoff isomorphism `O(P) ≅ L` is **computationally verified** in §2–§3 of `wolfram/music-anchor/layer-t-d-checks.wl`: the script builds `P = {2, 3, 4}` with `2 < 4`, enumerates its six down-closed subsets, and verifies bijection, meet (= intersection), join (= union), and Heyting NOT all match the divisor-lattice operations. The Layer-L theorem is what is kernel-checked in Lean; T2's lattice slice is what is empirically certified in Wolfram.

### 12.6 Distinction structure (Layer D): enumerated candidate slices

To lift Layer L to a full Theorem-5.1 instance, we need a non-trivial distinction structure `(D, η, ι)` on the chosen `T` such that `Im(η_Y)` lands at a non-regular element of `L` (so Exploitation is non-empty).

By Remark 5.5 of `paper.md` and the kernel-checked constructor `FalseWork.Positions.DistinctionStructure.ofIdempotentMonad`, it suffices to exhibit any idempotent monad on `T` with the right kernel image.

For `T = Sh(L)` or `T = Set^{Pᵒᵖ}`, idempotent monads on `T` correspond to closure operators on `L`, which in turn correspond bijectively to *Moore families* on `L` (subsets `F ⊆ L` containing the top and closed under meet; the closure operator's fixed-point set is exactly `F`). For our 6-element `L`, this is small enough to enumerate by brute force.

**Enumeration (§6 of `layer-t-d-checks.wl`).** The divisor lattice of 12 admits exactly **23 distinct closure operators**, distributed by the smallest non-trivial closed element ("closure of bottom") as follows:

| min element | musical reading        | # of Moore families |
|-------------|------------------------|---------------------|
| 1           | trivial `{0}`          | 14                  |
| 2           | tritone `<6>`          | **4**               |
| 3           | augmented triad `<4>`  | 2                   |
| 4           | diminished 7th `<3>`   | 1                   |
| 6           | whole-tone hexachord `<2>` | **1**           |
| 12          | full chromatic `Z/12`  | 1                   |

The 14 with min = 1 are "degenerate" (they include the bottom in the closed set, so the closure operator does not restrict the lattice meaningfully at the bottom). The remaining 9 are the *substantive* Layer-D candidate space. Of these, the 5 with a *non-regular* closure-of-bottom (4 tritone-closing + 1 whole-tone-closing) are the candidates whose corresponding distinction structure would put the kernel image at a non-regular element, thereby supporting a non-empty Exploitation cell.

**The four tritone-closing candidates** (Moore families with min element = 2):

1. `{2, 12}` — minimal: the kernel image is the tritone, and the only other closed element is the top.
2. `{2, 4, 12}` — the kernel image plus the closure-residue element (diminished 7th).
3. `{2, 6, 12}` — the kernel image plus the whole-tone hexachord.
4. `{2, 4, 6, 12}` — all four non-trivial elements above the tritone are closed.

Each of these is the *lattice-level slice* of a candidate Layer-D witness. To upgrade a lattice-level slice to a full distinction structure on `T`, one needs to (i) choose `T` (either `Sh(L)` or `Set^{Pᵒᵖ}`), (ii) lift the closure operator to an idempotent monad on `T` (standard topos-theoretic construction), (iii) verify the lift via `DistinctionStructure.ofIdempotentMonad`. Steps (i)–(iii) are routine but not done in this round. The point is that the candidate space is **finite, enumerated, and small** — a concrete list of 5 lattice shapes, not an abstract template.

The single whole-tone-closing candidate `{6, 12}` exists but is less informative as a witness: at kernel `<2>` (the whole-tone hexachord) the lattice-level partition is partially degenerate (Refusal and Distribution both collapse; see §12.3 uniqueness paragraph). The tritone-closing candidates are the ones to pursue.

### 12.7 Status summary

| Layer | Claim                                              | Status                          |
|-------|----------------------------------------------------|---------------------------------|
| L     | Divisor lattice of 12 is non-Boolean Heyting; four-position partition non-vacuous at tritone kernel; tritone is the *unique* fully non-vacuous kernel choice | **Kernel-checked in Lean** (`FalseWork.Lattice.lattice_four_position_partition` abstract, `FalseWork.Lattice.Examples.Div12.music_anchor_witness` concrete; audit lines in `Examples/HeytingTypeInstance.lean`). **Uniqueness verified computationally** in §5 of `wolfram/music-anchor/layer-t-d-checks.wl`. |
| T     | The lattice arises as `Sub_T(1)` for at least two elementary topoi (T1 = `Sh(L)`, T2 = `Set^{Pᵒᵖ}`) | **T1 cited from general topos theory.** **T2's lattice slice computationally verified** in §2–§3 of `layer-t-d-checks.wl` (Birkhoff isomorphism: bijection, meet, join, Heyting NOT all match). Neither T1 nor T2 is constructed in Lean in this round. |
| D     | A concrete distinction structure on T with the right kernel image lifts Layer L to Theorem 5.1 | **Candidate space enumerated, finite, small.** 23 closure operators total on `L`; 5 substantive ones (4 tritone-closing + 1 whole-tone-closing); kernel-checked lift constructor `FalseWork.Positions.DistinctionStructure.ofIdempotentMonad` already in place. The topos-level lift of any of the 4 tritone-closing candidates to a full distinction structure is deferred. |

This is the rigorous slot: Layer L kernel-checked, Layer T's lattice slice computationally verified for T2 and cited for T1, Layer D's candidate space finitely enumerated with the lift constructor pre-installed. The Wolfram scripts `four-position-music-v3-path-b.wl` (per-element comma table) and `layer-t-d-checks.wl` (Layer T Birkhoff verification, per-kernel exhaustive tabulation, Layer D Moore-family enumeration) together cover the computational companion story end-to-end.

### 12.8 Scope honesty

This music anchor uses elementary group-theoretic structure (subgroups of `Z/12` = transposition-symmetric pitch-class subsets, due to Messiaen 1944 and pitch-class set theory; not to Tymoczko, Mazzola, Lewin, or Andreatta). The choice was made because it is **the smallest concrete music-meaningful Heyting lattice on which the four-position partition is non-vacuous**, not because it is the deepest music-theoretic instantiation possible. The categorical music apparatus (Tymoczko's groupoid voice-leading geometry, Mazzola's denotator framework, Lewin's transformational theory, Andreatta's SMIR program, etc.) remains available for richer follow-up instantiations; none of it is needed for the lattice-level witness here.

The Coltrane classification of §6 remains deferred. With Layer L kernel-checked, the work needed for the Coltrane test is: (i) a Layer-D witness, (ii) a defended pitch-class encoding of each work, (iii) classification under the resulting distinction structure. None of these are blocking; all are downstream of the work in this round.

---

## 13. Independent formalism: Tymoczko (2026) and the topology-vs-Heyting correspondence

Tymoczko's 2026 *Journal of Music Theory* paper, "The Concept of Musical Space," develops a groupoid-categorical reformulation of transformational music theory. It is a separate work from the 2011 *A Geometry of Music* (which is the corroborator cited elsewhere in the music-kernel cluster) and pushes the formalism in a direction structurally adjacent to the FalseWork machinery. This section records the parallels and where they stop being parallels.

### 13.1 Two formalisms, one structural phenomenon

Both frameworks identify the same load-bearing fact — *the iterated music kernel fails to close, and that failure has structural content* — but they formalise it in different mathematical categories.

| | Tymoczko (2026) | FalseWork (this paper, Layer L) |
|---|---|---|
| Substrate | A music-theoretic groupoid (e.g. a Tonnetz) with arrows = transformations | The Heyting algebra `Sub(D Y)` of subobjects of `D Y` in an elementary topos |
| Kernel image | A distinguished arrow / iterated generator (the perfect fifth, lifted to the groupoid) | `Im(η_Y) ∈ Sub(D Y)` |
| Comma content | The vertex group at each point — the fundamental group of the underlying space — recording "which loops fail to be trivial" | The closure-residue `(Im(η_Y))ᶜᶜ ∖ Im(η_Y)` — strict in non-Boolean topoi at non-regular elements |
| Characterisation theorem | Commas exist exactly when `π₁` is non-trivial, i.e. exactly when the arrow algebra is strictly richer than the point algebra (a homotopy-theoretic statement) | The Exploitation cell is inhabited exactly when the Heyting algebra is non-regular at the kernel image (`a ≠ aᶜᶜ`); for the music anchor this is `Div12.tritone_non_regular`, kernel-checked at the lattice level |
| Canonical case | The Pythagorean comma as winding-number index of `C → F♯` via clockwise vs. counterclockwise iterated fifths | The Pythagorean comma as the canonical case the framework's name preserves; in the divisor-lattice instantiation, the tritone is the canonical non-regular witness |

The structural identification is real; the formal identity is *not* claimed. Tymoczko's machinery is topology-of-arrows; ours is lattice-of-subobjects. A locale/topology bridge connects them in principle — for any topological space `X` and the topos `Sh(X)` of sheaves, `Sub_{Sh(X)}(1) ≅ Ω(X)` (the lattice of opens), and the fundamental group of `X` is recoverable from the étale homotopy of `Sh(X)`. Constructing this bridge for the music-anchor substrate is **deferred mathematical work**; this paper does not claim it.

### 13.2 The four-Tonnetz / multiple-distinction-structure correspondence

Tymoczko's §3 demonstrates that the same underlying graph supports four genuinely distinct groupoid spaces (harmonic, Cohnian, scalar, Weber) with four genuinely distinct vertex groups (trivial, `Z_3`, `Z_7`, `Z_{21}`). Theorists, he argues, systematically conflate them. The choice of which arrows count as equivalent is what fixes the space and therefore the comma structure.

In FalseWork terms: this is the choice of distinction structure `(D, η, ι)` on a fixed underlying category `C`. Same `C`, four different `Δ`, four different `kernelImage Δ Y`, four different four-position partitions. The architecture predicts the position-dependence Tymoczko documents; his four-Tonnetz instance is, structurally, four worked Layer-D witnesses on the same substrate — though they are constructed in his topology-of-arrows formalism rather than ours.

Concrete worked Lean instance of "same `C`, two distinct `Δ`, two distinct partitions on the same morphism set" remains absent from FalseWork as of this round. Tymoczko's four Tonnetzes are a candidate target if the framework moves to formalise position-dependence empirically rather than architecturally; flagged here, not committed.

### 13.3 What Tymoczko has that FalseWork has not engaged with

One observation in Tymoczko's §1 and §7 is *not* mirrored in FalseWork: the symmetry/interval duality. Symmetries act on elements; intervals act on attributes. Tymoczko explicitly notes the same duality recurs across domains: active/passive (physics), action by lifting / action by deck transformations (algebraic topology), left/right actions (group theory), perspectival/nonperspectival or de dicto/de se (philosophy of mind). He notes the parallel and declines to theorise it, writing that he knows of no prior description accessible to music theorists.

This is a candidate cross-domain structural invariant that FalseWork is set up to host (the framework's appetite is precisely for things-that-show-up-across-domains-with-the-same-structure) but currently has *no slot for*. The four-position partition is about where a morphism's image lands relative to a kernel; the symmetry/interval duality is about how actions on elements relate to actions on attributes. The two are not the same shape. Recorded as an open research direction in `wolfram/cores/tymoczko-2026.wl` (the `CrossDomainDualitySignal` field); not committed framework content.

### 13.4 Calibrating the triangulation

The 2026 paper adds evidential weight to the music-kernel cluster at the *kernel-comma structural* level — a second independent formalism (groupoid topology) identifying the same comma the framework's Heyting formalism identifies. It does *not* add evidential weight to the *four-cell partition* test on specific works; that test (the Coltrane test of §6) remains deferred and is not what the 2026 paper does.

The 2011 book remains the primary corroborator for the music-kernel cluster (via its three-way scale-space discrimination, which independently identifies the same major-third / diatonic / chromatic structure FalseWork derives from Coltrane). The 2026 paper supplements this with a structural-formalism corroboration at the kernel-comma level. Both are independent in the sense that Tymoczko's work is not informed by FalseWork.

---

## References

- Andreatta, M. (2018). From music to mathematics and backwards: introducing algebra, topology and category theory into computational musicology. In *Imagine Math 6: Mathematics and Culture*, Springer.
- Atif, J., Bloch, I., Distel, F., Hudelot, C. (2013). Mathematical morphology operators over concept lattices. In *Formal Concept Analysis*, ICFCA 2013, Lecture Notes in Computer Science 7880, Springer, 28–43.
- Borceux, F. (1994). *Handbook of Categorical Algebra*, Volume 1. Cambridge University Press.
- Brink, C. (2026). *A Four-Position Partition of Morphisms in Elementary Topoi with Distinction Structure*. Preprint, `preprints/four-position-partition/paper.md`.
- Freund, A., Andreatta, M., Giavitto, J.-L. (2017). Lattice-based and topological representations of binary relations with an application to music. *Annals of Mathematics and Artificial Intelligence*, 79(3-4), 217–243.
- Johnstone, P. T. (2002a). *Sketches of an Elephant: A Topos Theory Compendium*, Volume 1. Oxford University Press.
- Lewin, D. (1987). *Generalized Musical Intervals and Transformations*. Yale University Press.
- Mac Lane, S., Moerdijk, I. (1992). *Sheaves in Geometry and Logic*. Springer.
- Mazzola, G. (2002). *The Topos of Music: Geometric Logic of Concepts, Theory, and Performance*. Birkhäuser.
- Mazzola, G., and Andreatta, M. (2006). From a categorical point of view: K-nets as limit denotators. (Venue details to be verified before external submission.)
- Popoff, A., Andreatta, M., and Ehresmann, A. (2018). From K-nets to PK-nets: a categorical approach. *Journal of Mathematics and Music*. (Venue details to be verified before external submission.)
- Tymoczko, D. (2011). *A Geometry of Music*. Oxford University Press.
- Tymoczko, D. (2026). The concept of musical space. *Journal of Music Theory*, 70(1).
- Tymoczko, D. (March 2026). Personal correspondence, cited with permission. (Re Coltrane three-field classification.)
