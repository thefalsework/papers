# Music-Anchor Feasibility Memo

**Author:** Chris Brink
**Date:** May 2026
**Status:** Scoping document (Step A of the music-anchor test plan); no computation performed yet.

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
