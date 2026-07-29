# The Opened Square: Aristotle, Spencer-Brown, and the Kernel-Checked Foundation of the Four-Position Lens

**Author:** Chris Brink (FalseWork) — chris@falsework.dev
**Date:** July 2026
**Register:** Unification spine. This is the front door to the program's formal foundation: it states, in order, the chain that runs from the oldest diagram in logic to the four-position interpretive lens, and identifies every arrow in the chain as either a Lean 4 theorem or an explicitly graded interpretive step. Markdown authoritative.
**Status of claims:** Each claim is tagged — **[K]** kernel-checked in Lean 4 / Mathlib4 (toolchain `v4.30.0-rc2`; no `sorry`, no `native_decide`; per-theorem `#print axioms` reporting at most `propext, Classical.choice, Quot.sound`); **[C]** classical mathematics, cited not re-proved; **[A]** structural analogy / interpretive claim, not a theorem; **[O]** open. **[A]** and **[O]** are never silently promoted to **[K]**.
**Provenance:** All Lean in scope was AI-authored (Claude, working in Cursor) under the author's direction and review; prose likewise drafted with AI assistance under direction. See `formalization.yaml` at the repository root.

---

## 0. What this document does

The FalseWork program has, until now, kept its formal results in three separate places: a **topos stack** (the distinction structure and the four-position partition theorem), a **lattice stack** (ordinary elements, the Rieger–Nishimura ladder, Z₆, the arithmetic forcing at 12), and a **historical layer** (Aristotle's square, Spencer-Brown's *Laws of Form*) that lived in prose. The connections between them were carried by analogy.

Two new Lean developments close the gaps:

1. **The bridge theorem** (`Positions/OrdinaryKernel.lean`): the four-position partition at an object `Y` is non-degenerate — all four cells realizable — **iff** the kernel image at `Y` is an *ordinary element* (Citkin's term: neither regular nor dense) of the subobject lattice. The morphism-level cell predicates are, definitionally, the lattice-level cell predicates at the image subobject. **[K]**
2. **The opposition figure** (`Examples/OppositionFigure.lean`): the six landmarks that Aristotle's square generates under Heyting negation — `⊥, ¬a, a, ¬¬a, a ∨ ¬a, ⊤` — are pairwise distinct **iff** `a` is ordinary; the four middle landmarks inhabit the four partition cells one-for-one (the figure is the partition's skeleton); and the figure is *not* Blanché's hexagon, machine-refuted. **[K]**

With these in place, the chain below is welded end to end. Everything proved in the ordinary-elements preprint — uniqueness of the ordinary element, the six-element threshold, the Z₆ embedding, the p²q law — is now, formally and not by analogy, a statement about the kernels of the interpretive lens.

**The chain, in one line:**

> distinction drawn (Spencer-Brown, calling) → ambient logic non-Boolean (crossing fails) → four positions forced (partition theorem) → non-degeneracy = ordinariness (bridge theorem) → six landmarks = the opened square = Z₆ = the divisor lattice of 12 (figure law + two-sided forcing) → the interpretive glosses, graded.

Sections 1–6 walk the chain. Section 7 is the interpretive layer with its evidential grades. Section 8 is the reflexivity caveat. Section 9 is prior art. Section 10 is the theorem-by-theorem audit table.

---

## 1. The oldest diagram in logic, and its silence

Aristotle's square of opposition, read propositionally at an element `a` of an algebra of propositions, has corners

- **A** (universal affirmative) — `a`
- **E** (universal negative) — `¬a`
- **I** (particular affirmative, "not impossible") — `¬¬a`
- **O** (particular negative) — `¬a` again, in the propositional reading,

together with the two poles `⊥` (contradiction) and `⊤` (tautology) and the vertex `a ∨ ¬a` (excluded middle at `a`). Six landmarks in all: `⊥, ¬a, a, ¬¬a, a ∨ ¬a, ⊤`.

Classically the figure **cannot** show six distinct positions. Two collapse laws do the crushing:

- **The regular collapse.** If `¬¬a = a`, the I corner lands on the A corner. In a Boolean algebra this holds at *every* element, so the figure is degenerate everywhere. **[K]** `oppositionFigure_not_injective_of_regular`, `boolean_oppositionFigure_degenerate`.
- **The classical collapse.** A complemented element is regular: if `a ∨ ¬a = ⊤`, then `¬¬a = a` (distributivity does the work). Excluded middle at `a` alone kills the figure. **[K]** `compl_compl_eq_of_sup_compl_eq_top`.

This is the algebraic form of a 2,300-year fact: as long as the ambient logic was classical, the square's two extra positions were not merely unobserved — they were *invisible in principle*. The same fact in partition vocabulary is `boolean_no_kernel`: a Boolean algebra has no element at which all four cells inhabit. **[K]** And Glivenko's theorem sharpens it: even inside an intuitionistic algebra, the *regular* elements — the fragment a classical observer can see — carry no non-degenerate kernel (`glivenko_collapse`). **[K]** The classical eye is blind to the figure not by accident but by theorem.

There is also a third collapse, on the other flank:

- **The dense collapse.** If `¬a = ⊥` (the kernel is dense, undeniable), the figure crushes onto the three-chain `⊥ ≤ a ≤ ⊤`: the E corner dies, the I corner saturates to `⊤`, the vertex falls back onto `a`. **[K]** `oppositionFigure_of_dense`.

Between the two flanks — regular on one side, dense on the other — sits the condition under which the figure lives. That condition has a name.

---

## 2. Distinction drawn: Spencer-Brown, categorified

Spencer-Brown's *Laws of Form* (1969) founds its calculus on the act of drawing a distinction, governed by two axioms: **calling** (marking twice is marking once) and **crossing** (marking and unmarking cancel). The program's kernel object is the categorification of the first axiom *without* the second:

- A **distinction structure** on a category `C` is an endofunctor `D` with a marking unit `η : 𝟭 → D` and an idempotency witness `D ∘ D ≅ D` — calling, at the natural-transformation level. **[K]** `DistinctionStructure` (`Positions/Setup.lean`); constructible from any idempotent monad (`DistinctionStructure.ofIdempotentMonad`, `Positions/SpencerBrown.lean`). The categorification is interpretive — it is not in *Laws of Form* — but once written down, its consequences are theorems.
- **Crossing is the axiom that is allowed to fail.** When it holds — when the subobject lattices are Boolean — the Exploitation cell is empty and the partition sees three cells, not four. **[K]** `exploitation_requires_nonBoolean`, `boolean_partition_three_cells`.

So the fourth cell is precisely the register that exists *because* crossing fails: the trace, inside the classification, of the distinction's failure to close on itself. The known extensions of *Laws of Form* (Spencer-Brown's imaginary values, Varela's third value, Kauffman's waveform algebras) all move the other way — adding truth values. Weakening negation to the Heyting case and reading the calculus in subobject lattices is, as far as we know, this program's move (§9).

---

## 3. The four positions, forced

For a non-trivial distinction structure `Δ` and a morphism `f : X → Y` with non-trivial image, exactly one of four conditions holds for `img := image(D f)` relative to the kernel image `k := Im(η_Y)`:

| Cell | Condition | Heyting shape |
|---|---|---|
| Infrastructure | `img ≤ k` | inside the kernel |
| Distribution | `img ⊓ k ≠ ⊥` and `img ⊓ ¬k ≠ ⊥` | straddles |
| Exploitation | `img ≤ ¬¬k` and not `img ≤ k` | closure-residue |
| Refusal | `img ≤ ¬k` | inside the complement |

Disjointness and exhaustiveness are Heyting-algebra identities. **[K]** `four_position_partition` (`Positions/Partition.lean`), with the pure lattice form isolated as `lattice_four_position_partition` (`Lattice/FourPositionLattice.lean`).

The partition is a *classification* theorem: it says every act falls somewhere. It does not by itself say the classification is informative — all four cells could fail to be realizable at a given `Y`. When is it non-degenerate?

---

## 4. The bridge: non-degeneracy is ordinariness

Call `a` **ordinary** (Citkin) if it is neither regular (`¬¬a = a`) nor dense (`¬a = ⊥`). The new bridge file welds the two stacks:

- **The cell predicates are the lattice cells.** Each morphism-level predicate *is* the corresponding lattice-level predicate at `img` relative to `k` — definitionally for Infrastructure, Distribution, Exploitation (the translation lemmas are `Iff.rfl`), and via the image-factorization equivalence for Refusal. **[K]** `isInfrastructure_iff_lattice` etc. (`Positions/OrdinaryKernel.lean`).
- **The bridge theorem.** The four cells of the partition at `Y` admit subobject witnesses **iff** `kernelImage Δ Y` is an ordinary element of `Sub(D Y)`. **[K]** `partition_nondegenerate_iff_kernel_ordinary`.
- **Occupied cells force an ordinary kernel.** If all four positions are actually occupied by morphisms at `Y` (non-trivially, where triviality would be vacuous), the kernel image is ordinary. **[K]** `kernel_ordinary_of_cells_occupied`.
- **Ordinary kernels carry Z₆.** An ordinary kernel forces the six-element lattice `Div12 ≅ Z₆` to order-embed into `Sub(D Y)`, kernel to the tritone slot; composing, occupied positions at `Y` force Z₆ inside the lens. **[K]** `ordinary_kernel_div12_embedding`, `cells_occupied_div12_embedding`.

The consequence is the point of this document. The ordinary-elements preprint proved a structure theory of ordinary elements in the abstract: the four-region criterion, the uniqueness of the ordinary element in one-generated algebras (statement Citkin, first written proof there), the six-element threshold, the Z₆ order-embedding, Nishimura's normal form, the p²q law and its k-prime generalization. Through the bridge, **every one of those theorems is now a formal statement about the kernels of the interpretive lens.** The lens is non-degenerate exactly at ordinary kernels, and ordinary kernels carry all the structure the preprint proved.

---

## 5. The opened square

Now the historical layer becomes a theorem. The six landmarks of §1, indexed by the six-element lattice they form (`Examples/OppositionFigure.lean`, re-reading `ladderEmbed` of `Examples/LadderCore.lean`):

- **T1, the figure law.** The six landmarks `⊥, ¬a, a, ¬¬a, a ∨ ¬a, ⊤` are pairwise distinct **iff** `a` is ordinary. **[K]** `oppositionFigure_injective_iff`. The three collapse laws of §1 are its named corollaries. So the figure and the partition are non-degenerate under *exactly the same condition* — one iff, two vocabularies.
- **The skeleton theorem.** At an ordinary `a`, the four middle landmarks inhabit the four cells one-for-one: `a` in Infrastructure, `¬a` in Refusal, `¬¬a` in Exploitation, `a ∨ ¬a` in Distribution. The figure is the partition's set of canonical representatives — its capital cities. **[K]** `oppositionFigure_skeleton`.
- **The figure is the ladder's foot.** The six landmarks are the bottom five rungs of the Rieger–Nishimura ladder plus `⊤` — the opened square is the visible base of the free one-generated structure whose normal form the preprint formalizes. **[K]** by definition (`oppositionFigure := ladderEmbed`; ladder in `NishimuraNormalForm.lean`).
- **At the tritone, the figure is the whole algebra.** On `Div12 = Z₆` at its unique ordinary element, the figure map is the identity: the six landmarks *are* the six elements, each in its own slot. **[K]** `oppositionFigure_tritone_eq_id`. The music table of the ordinary-elements preprint §9 — tritone, augmented triad, diminished seventh, whole-tone scale as the four cell witnesses — was the figure's first appearance in the program, unnamed.
- **T2, the Blanché refutation.** Blanché (1966; independently Sesmat, 1951) also completed the square to six positions — the hexagon with `U := A ∨ E` and `Y := I ∧ O`. As an entailment poset the hexagon has three pairwise-incomparable minimal vertices (the contraries) and no bottom; Z₆ is a bounded lattice. They are **not order-isomorphic**. **[K]** `BlancheHexagon.not_orderIso_div12`. Adding vertices classically and degrading the logic intuitionistically both yield six positions, and the two figures are different objects — the near-miss is machine-refuted, not waved at. (Fidelity of the hexagon encoding: reviewed 2026-07-29 against three independent specialist descriptions of the 1966 hexagon — Béziau 2013; Dubois–Prade–Rico 2015; standard references — all six entailment edges and all incomparability relations match; the French primary text itself was not consulted. Record in the Lean docstring.)

Historically, then: Aristotle's square is the classical special case (figure crushed by the collapse laws); Spencer-Brown's calculus is the modern face of the same closure assumption (crossing = excluded middle at the kernel); and the four-position partition is the opened form of both — what the square becomes when the ambient logic stops being classical, with Z₆ as its shape.

### 5.1 The relation profile

The square-of-opposition tradition describes a figure not by its order structure but by its **opposition relations**: contradictories (exclusive and exhaustive), contraries (exclusive, not exhaustive), subcontraries (exhaustive, not exclusive), subalternation (one-way entailment) — plus, in Demey–Smessaert logical geometry, *unconnectedness* (none of the above). `Examples/OppositionRelations.lean` computes the full profile of the opened square's four middle landmarks `A := a`, `E := ¬a`, `I := ¬¬a`, `U := a ∨ ¬a` at an ordinary `a`:

- **A–E: contraries, never contradictories.** `a ∧ ¬a = ⊥` always, but `a ∨ ¬a ≠ ⊤` at every ordinary element. The negation pair — classically the paradigm contradiction — weakens to contrariety exactly where the figure opens. This is the element-local algebraic form of Béziau's observation (2003) that intuitionistic negation is a paracomplete, contrariety-forming negation. **[K]** `IsOrdinary.contraries_compl`, `IsOrdinary.not_contradictories_compl`; classical contrast `boolean_contradictories_compl`.
- **Three strict subalternations:** `A < I`, `A < U`, `E < U`. **[K]** `IsOrdinary.lt_compl_compl`, `IsOrdinary.lt_sup_compl`, `IsOrdinary.compl_lt_sup_compl`.
- **The two remaining pairs are not settled by ordinariness.** They split on the *Stone identity at `a`* (`¬a ∨ ¬¬a = ⊤`, weak excluded middle): if it holds, E–I are contradictories and I–U subcontraries; if it fails, E–I weaken to contraries and I–U become **unconnected** — a pair of distinct contingent vertices standing in no Aristotelian relation at all, which is impossible in the classical square. **[K]** `stoneAt_contradictories_compl`, `not_stoneAt_contraries_compl`, `IsOrdinary.subcontraries_of_stoneAt`, `IsOrdinary.unconnected_of_not_stoneAt`. (Both cases are realized: Z₆ at the tritone satisfies the identity; the regular-open figure `(0,1) ∪ (1,2)` in the opens of ℝ fails it.)
- **The profile theorem.** At an ordinary `a` with the Stone identity, the four middle landmarks realize exactly one contrariety, one contradiction, one subcontrariety, and three subalternations — the classical square's full relation inventory, redistributed over different pairs. On Z₆ at the tritone the whole profile holds computably. **[K]** `oppositionRelationProfile`, `div12_tritone_profile`; the I–U meet is the A corner (`complCompl_inf_sup_compl` — the Exploitation and Distribution landmarks intersect in Infrastructure).

The profile is what makes the figure legible to the logical-geometry tradition on its own terms: not "here is a lattice" but "here is which pairs are contraries, which contradictories, which unconnected — as a function of one algebraic condition."

---

## 6. Why twelve: the two-sided forcing

The figure needs an ordinary element to live; where do ordinary elements live? The arithmetic side of the program answers for the equal-temperament family: among divisor lattices of `n`, a kernel exists iff `n` has at least two prime factors, one squared, and is *unique* iff `n = p²q` — least instance `12`, kernel the tritone. **[K]** `why_twelve`, `twelve_kernel_unique` (`Examples/WhyTwelve.lean`), with the general k-prime existence/uniqueness/count laws in `WhyTwelveGeneral.lean`. Together with `oppositionFigure_tritone_eq_id`, the divisor lattice of 12 is not merely *an* example: it is the smallest arithmetic object that *is* its own opened square. The full two-sided forcing argument (Diophantine floor on one side, Heyting structure on the other) is the ordinary-elements preprint §8–9 and `papers/connecting-the-spine.md` §3.4; this document only needs its conclusion.

---

## 7. The interpretive layer, graded

The lens reads cultural acts through the partition. The glosses are interpretive; their *preconditions* are theorems. The discipline is to keep the grades attached:

- **Refusal requires a deniable kernel.** The Refusal cell (`x ≤ ¬k`, non-trivially) is inhabitable iff `¬k ≠ ⊥` — iff the kernel is not dense. A domain whose kernel is undeniable (dense) admits no Refusal position; refusal of the undeniable is not a position but a mistake. **[K]** for the precondition (the dense collapse; the `¬a ≠ ⊥` conjunct of ordinariness); **[A]** for the cultural reading.
- **Exploitation is classically invisible.** The Exploitation cell lives strictly between `k` and `¬¬k`; a classical observer, for whom `¬¬k = k`, cannot distinguish Exploitation from Infrastructure — the cell is not merely empty classically, it is *unstatable*. **[K]** for the algebra (`exploitation_requires_nonBoolean`, `glivenko_collapse`); **[A]** for the reading (why exploitation-registers in practice go unnamed by classically-minded criticism).
- **Distribution straddles.** The Distribution landmark `k ∨ ¬k` sits strictly below `⊤` at an ordinary kernel (**[K]** `IsOrdinary.sup_compl_ne_top`): the both-sides position exists as a *position* only because excluded middle fails — otherwise it is everything, hence nothing. **[A]** for the reading.
- **The Commitment gate is a judgment stroke.** The binary fixedness condition applied within each cell is structurally the Fregean assertion sign: it marks the difference between occupying a position and *asserting from* it. **[A]** throughout — the gate is schema-grade (its theorem-grade unification was tested and closed negative, `MomentRelative.lean`, 2026-05-10), and the Frege precedent is an analogy, claimed as nothing more.

---

## 8. The reflexivity caveat

This document explains the partition; it does not force it. The forcing arguments — that the distinction operation is the right categorification, that specific domains instantiate `Δ` non-trivially, that the music anchor is canonical — live in Papers 1 and 3, the four-position preprint, and `connecting-the-spine.md`, each with its own open items (canonicity of the music topos **[O]**, the comma functor **[O]**, the vertical Lawvere unification **[O]**). What this document adds is narrower and harder: that once the kernel object is granted, the path from Aristotle's square to the four-position lens is theorem all the way down, with the interpretive residue explicitly fenced in §7. A reader who rejects the glosses keeps every theorem; a reader who accepts them knows exactly what they are accepting beyond the theorems.

---

## 9. Prior art and claim discipline

- **Béziau (2003)** observed that intuitionistic negation is a paracomplete, *contrariety-forming* negation — the global, logic-level form of the A–E entry of the relation profile (§5.1). The profile's element-local statements, the Stone-identity dichotomy, and the appearance of unconnectedness inside the opened square are, as far as we know, first written down (and first kernel-checked) here.
- **The intuitionistic square of opposition** is studied informally, and always at the proof-theoretic or sentence level rather than the algebra-element level. The two closest chapters — reviewed 2026-07-29 via abstracts, the authors' own congress summaries, and citing literature (full texts paywalled) — are: Mélès, "No Group of Opposition for Constructive Logics: The Intuitionistic and Linear Cases" (in Béziau–Jacquette, *Around and Beyond the Square of Opposition*, Birkhäuser 2012, pp. 201–217), a group-theoretic impossibility result (no Klein-style group of opposition, because subcontrariety fails intuitionistically); and Vidal-Rosset, "The Exact Intuitionistic Meaning of the Square of Opposition" (in Béziau–Basti, *The Square of Opposition: A Cornerstone of Thought*, Birkhäuser 2017, pp. 291–303), a prover-driven answer (IMOGEN, ileanCoP) showing contra Mélès that the square survives *as a square* with some classically-derivable relations amputated — the closest informal precedent to this document's "the square opens rather than dies," but at the level of derivable sentences, not lattice elements. (An earlier version of this note misplaced the Vidal-Rosset chapter in the 2012 volume.) Neither chapter — nor anything found in targeted searches for square-of-opposition + Rieger–Nishimura or square + regular/dense elements — states the algebraic law T1 (non-degeneracy = Citkin ordinariness), the Z₆ identification, or the partition-skeleton equivalence. Claim wording throughout: **first kernel-checked**, never "first" — the informal literature is the precedent.
- **Laws of Form extensions** (Spencer-Brown's imaginary values; Varela's extended calculus; Kauffman's waveform and four-valued algebras; boundary mathematics) add truth values or temporal structure. Weakening negation to the Heyting case and reading the calculus in the subobject lattices of a topos does not appear in that literature; the categorification is interpretive and is labeled as such (§2). One targeted check (Bricken's boundary logics; Kauffman's topological readings) remains open before publication.
- **Blanché (1966)** is prior art *for the hexagon*; T2 is not a criticism of it but a machine-checked non-identification: the hexagon and the opened square are different six-element completions.
- **Citkin (arXiv:2512.05633)** is the source of the ordinariness notion and the uniqueness statement; the ordinary-elements preprint records the prior-art adjudication by correspondence.

---

## 10. Formalization audit

Every arrow of the chain, by Lean name. "all three" = `propext, Classical.choice, Quot.sound`; audits by per-theorem `#print axioms`.

| Claim | Lean name | File | Axioms |
|---|---|---|---|
| Four-position partition (topos) | `four_position_partition` | `Positions/Partition.lean` | all three |
| Four-position partition (lattice) | `lattice_four_position_partition` | `Lattice/FourPositionLattice.lean` | propext |
| Boolean ⟹ three cells | `boolean_partition_three_cells` | `Positions/SpencerBrown.lean` | all three |
| Exploitation needs non-Boolean | `exploitation_requires_nonBoolean` | `Positions/Exploitation.lean` | all three |
| Boolean ⟹ no kernel; Glivenko | `boolean_no_kernel`, `glivenko_collapse` | `Examples/GlivenkoCollapse.lean` | propext |
| Cell translation lemmas | `isInfrastructure_iff_lattice` (+D, E, R) | `Positions/OrdinaryKernel.lean` | all three |
| **Bridge**: non-degeneracy = ordinary kernel | `partition_nondegenerate_iff_kernel_ordinary` | `Positions/OrdinaryKernel.lean` | all three |
| Occupied cells ⟹ ordinary kernel | `kernel_ordinary_of_cells_occupied` | `Positions/OrdinaryKernel.lean` | all three |
| Ordinary kernel ⟹ Z₆ embeds | `ordinary_kernel_div12_embedding`, `cells_occupied_div12_embedding` | `Positions/OrdinaryKernel.lean` | all three |
| Classical collapse (complemented ⟹ regular) | `compl_compl_eq_of_sup_compl_eq_top` | `Examples/OppositionFigure.lean` | propext |
| **T1**: figure law | `oppositionFigure_injective_iff` | `Examples/OppositionFigure.lean` | propext |
| Regular collapse | `oppositionFigure_not_injective_of_regular` | `Examples/OppositionFigure.lean` | none |
| Dense collapse | `oppositionFigure_of_dense` | `Examples/OppositionFigure.lean` | propext |
| Boolean degeneracy everywhere | `boolean_oppositionFigure_degenerate` | `Examples/OppositionFigure.lean` | all three |
| Skeleton theorem | `oppositionFigure_skeleton` | `Examples/OppositionFigure.lean` | propext |
| U strictly below ⊤ at ordinary | `IsOrdinary.sup_compl_ne_top` | `Examples/OppositionFigure.lean` | propext |
| Tritone figure = identity | `oppositionFigure_tritone_eq_id` | `Examples/OppositionFigure.lean` | propext, Quot.sound |
| **T2**: Blanché refutation | `BlancheHexagon.not_orderIso_div12` | `Examples/OppositionFigure.lean` | propext, Quot.sound |
| A–E contrariety at ordinary | `IsOrdinary.contraries_compl`, `IsOrdinary.not_contradictories_compl` | `Examples/OppositionRelations.lean` | propext |
| Three strict subalternations | `IsOrdinary.lt_compl_compl`, `IsOrdinary.lt_sup_compl`, `IsOrdinary.compl_lt_sup_compl` | `Examples/OppositionRelations.lean` | propext |
| Stone dichotomy (E–I, I–U) | `stoneAt_contradictories_compl`, `not_stoneAt_contraries_compl`, `IsOrdinary.subcontraries_of_stoneAt`, `IsOrdinary.unconnected_of_not_stoneAt` | `Examples/OppositionRelations.lean` | propext (or none) |
| Relation profile; tritone instance | `oppositionRelationProfile`, `div12_tritone_profile` | `Examples/OppositionRelations.lean` | propext |
| Non-degeneracy criterion (lattice) | `allFourCellsInhabited_iff`, `isOrdinary_iff_allFourCells` | `Examples/NishimuraKernelLaw.lean` | propext |
| Z₆ order-embedding | `div12OrderEmbedding` | `Examples/LadderCore.lean` | propext |
| Unique ordinary element | `nishimura_ordinary_unique` | `Examples/NishimuraKernelLaw.lean` | propext, Quot.sound |
| Nishimura normal form | `generatedBy_isLadderValue` | `Examples/NishimuraNormalForm.lean` | propext, Quot.sound |
| p²q law; unique kernel at 12 | `why_twelve`, `twelve_kernel_unique` | `Examples/WhyTwelve.lean` | all three |

## 11. Reproducing

```
cd lean
lake exe cache get
lake build
```

The new files are `lean/FalseWorkPapers/Positions/OrdinaryKernel.lean`, `lean/FalseWorkPapers/Examples/OppositionFigure.lean`, and `lean/FalseWorkPapers/Examples/OppositionRelations.lean` (the §5.1 relation profile); all are imported by the library root. Axiom audits: import either file in a scratch and run the `#print axioms` lines listed in each file's footer. The comparator setup (`lean/Challenge.lean`, `lean/Solution.lean`, `lean/config.json`) covers the ordinary-elements preprint's six principal theorems and is unchanged by this document.

### References

- Aristotle, *De Interpretatione* 6–7 (the square's source).
- R. Blanché, *Structures intellectuelles*, Vrin, 1966. (Hexagon independently: A. Sesmat, *Logique II*, Hermann, 1951.)
- G. Spencer-Brown, *Laws of Form*, Allen & Unwin, 1969.
- J.-Y. Béziau & D. Jacquette (eds.), *Around and Beyond the Square of Opposition*, Birkhäuser, 2012 — incl. B. Mélès, "No Group of Opposition for Constructive Logics: The Intuitionistic and Linear Cases," pp. 201–217.
- J.-Y. Béziau & G. Basti (eds.), *The Square of Opposition: A Cornerstone of Thought*, Birkhäuser, 2017 — incl. J. Vidal-Rosset, "The Exact Intuitionistic Meaning of the Square of Opposition," pp. 291–303.
- J.-Y. Béziau, "The metalogical hexagon of opposition," *Argumentos* 5(10), 2013 (secondary source for the hexagon's structure as reviewed; cites Blanché 1966 directly).
- J.-Y. Béziau, "New light on the nameless corner of the square of oppositions" (2003) — intuitionistic negation as contrariety-forming; the informal precedent for §5.1's A–E entry.
- H. Smessaert & L. Demey, "Logical Geometries and Information in the Square of Oppositions," *JoLLI* 23 (2014) — source of the relation definitions transcribed in `OppositionRelations.lean`, including unconnectedness.
- A. Citkin, on ordinary elements and one-generated Heyting algebras, arXiv:2512.05633; correspondence June 2026, cited with permission (`docs/outreach/citkin-email.md`).
- I. Nishimura, "On formulas of one variable in intuitionistic propositional calculus," *JSL* 25 (1960).
- FalseWork: `preprints/ordinary-elements-z6/paper.md`; `preprints/four-position-partition/` (incl. `spencer-brown-anchor.md`); `papers/connecting-the-spine.md`; Papers 1 and 3.
