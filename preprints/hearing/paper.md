# Hearing at a Blur: A Testable Hypothesis on Auditory Attention as a Nucleus

**Author.** Chris Brink (independent)
**Version.** Draft v0.1, August 2026 — not yet posted
**Target.** companion to `preprints/aperture/` (the mathematics); candidate venues to be determined (music cognition / theoretical psychology)
**Status discipline.** Every claim carries one of six grades: **[K]** kernel-checked in Lean 4 against Mathlib4; **[C]** classical mathematics or established empirical literature, cited; **[computed]** exhaustive finite computation under two-implementation agreement; **[A]** structural analogy or interpretive mapping, argued not proved; **[H]** falsifiable empirical hypothesis, stated in testable form but untested; **[O]** open. This paper's central contribution is graded [H] — that is the point of it. Nothing below claims more than its tag.

---

## Abstract

A companion paper defines the **aperture** of a distinction in a Heyting algebra: the set of nuclei — lawful coarse-grainings — under which the distinction retains a non-degenerate four-position structure inside the coarse-grained world **[K]/[computed]**. The mathematics is unconditional and says nothing about minds. This paper states the cognitive hypothesis the mathematics makes testable: that a settled mode of auditory attention — a *hearing*, in the sense of a metrical grouping a listener entrains to — behaves as a nucleus on the lattice of metrical grids. The hypothesis decomposes into three axioms, each independently a falsifiable claim about perception: attention merges distinctions but never invents them (inflation); a settled hearing is stable under itself (idempotence); grouping commutes with structural combination (meet-preservation) **[H]**. If the axioms hold, three proved theorems transfer to cognition as exact laws: the space of possible hearings of an n-pulse cycle is finite and enumerable (eight for the 12-pulse cycle, sixteen for the 36-pulse cycle) **[K]**; the founding distinction of the 12-pulse world survives no coarsened hearing whatsoever **[K]**; and the 36-pulse world contains a structural level with *no* four-position organization at full resolution that acquires complete organization under exactly two specific hearings and provably no others **[K]**. The last is the sharpest transfer: it predicts that some auditory organization is in-principle closed to fully detailed attention and open only to specific blurs — not hard to notice at full detail, but nonexistent there. The hypothesis is located against the metrical-hierarchy and dynamic-attending literatures, which supply the lattice and the entrainment mechanism respectively but have not asked whether grouping satisfies the nucleus laws **[C]**. A pre-registrable experimental design is given: a latency-detection paradigm on 36-pulse material with entrainment-primed conditions, whose predictions are exact, directional, and — because the closed form counts the aperture — quantitative. Failure modes are mapped to axioms, so a negative result localizes which law perception violates. Canonical practice supplies informal existence proofs of the phenomena (the baroque hemiola; the cantus firmus of *Wachet auf*; augmentation in *The Art of Fugue*) but is offered as illustration, not evidence **[A]**.

## 1. The question

The companion paper (`preprints/aperture/paper.md`) proves facts about an abstract space: all lawful ways of merging distinctions in a finite grid-world, and what structure survives each merger. Kernel-checked, unconditional — and silent about human beings.

This paper asks the question those theorems make precise: **what is the cognitive content, if any, of hearing by ear?** When a listener settles into hearing six beats as two groups of three rather than three groups of two, something operates on the space of available distinctions. The hypothesis of this paper is that this something is a nucleus, in the exact technical sense — and therefore that the theorems of the companion paper, including its strangest one, are candidate laws of auditory attention.

The structure of the claim matters. The mathematics is proved; whether perception satisfies its axioms is an empirical question. The relation is the same as geometry's relation to physical space: Euclid is unconditional, and whether the world is Euclidean is a measurement. This paper states the measurement.

## 2. The proved core, imported

We summarize what is proved, with pointers; all details and proofs are in the companion paper and the repository's Lean development.

**2.1 The lattice [C].** The metrical grids of an n-pulse cycle — for each divisor d of n, the grid of d evenly spaced attacks — form the divisor lattice Div(n) under refinement, a finite Heyting algebra. For n = 12: six grids. For n = 36: nine.

**2.2 The four-cell theorem [K].** A distinguished element (*kernel*) supports a non-degenerate four-position partition — Infrastructure, Distribution, Exploitation, Refusal all inhabited — if and only if it is *ordinary*: neither dense (its complement vanishes) nor regular (it is exactly its double complement). Kernel-checked as `isOrdinary_iff_allFourCells` (`lean/FalseWorkPapers/Positions/OrdinaryKernel.lean`).

**2.3 Nuclei and worlds [C]/[K].** A nucleus j is an inflationary, idempotent, meet-preserving operator; its fix-set Fix(j) is again a Heyting algebra — the *world at that coarse-graining*. On finite products, nuclei factor componentwise (`nucleus_prod_iff` **[K]**); on finite chains they are classified by the subsets containing ⊤ (`nucleusEquivTopSets` **[K]**). Consequently the hearings of Div(12) number exactly 8, and of Div(36) exactly 16.

**2.4 The aperture and its closed form [K]/[computed].** Ap(k) = the set of nuclei under which k is ordinary *inside the nucleus's world* — equivalently, by 2.2, the set of coarse-grainings under which the four-fold around k stays open. |Ap(k)| is given by a closed formula over prime chains, kernel-checked on all two-prime divisor lattices (`aperture_closed_form_exponents`), exhaustively verified on 164 elements of fifteen lattices.

**2.5 Fragility [K].** On Div(12), the unique ordinary element is 2 and Ap(2) = {identity} (`aperture_two_complete`): every proper coarsening closes the four-fold. At the threshold of possibility, structure exists only at full resolution.

**2.6 Latency [K].** On Div(36), the element 6 is dense — *no* four-position structure at full resolution — yet exactly two proper nuclei open a complete four-fold around it: the hearing fixing the even grids {2,4,6,12,18,36} and the hearing fixing the multiples of three {3,6,9,12,18,36} (`latent_ordinariness_witness`, `aperture_six_complete`; exactness quantified over all sixteen nuclei). Some distinctions exist only at a blur.

## 3. The hypothesis

**Hypothesis H (hearing as nucleus) [H].** A settled mode of auditory attention to an n-pulse cycle — the entrained state in which a listener registers some metrical grids and not others — acts on Div(n) as a nucleus whose fix-set is the set of registered grids.

The force of H is carried by three sub-hypotheses, one per nucleus axiom. Each is independently falsifiable, and each is a substantive claim about perception rather than a formal convenience:

- **H1 (inflation): blurring never invents detail.** A coarser hearing can reorganize the distinctions available to it, but cannot make the listener register a grid distinction the attended material does not support. Perceptually: entrainment merges; it does not split.
- **H2 (idempotence): a settled hearing is stable under itself.** Once entrainment has settled, re-applying the same attentional set changes nothing — hearing your own hearing is the same hearing. Perceptually: entrained states are fixed points, not stages of an ongoing drift.
- **H3 (meet-preservation): grouping commutes with combination.** The hearing of two structures presented jointly agrees with the combination of their individual hearings — attention does not apply one merging policy to parts and a different one to wholes.

H is a *modeling* hypothesis in the same sense that "physical space is Euclidean" was: the axioms are individually plausible, jointly strong, and the interesting science is in where they fail, if they fail.

**The dictionary [A].** The mapping that renders H applicable — divisor d of n ↔ the grid of d evenly spaced attacks per cycle; nucleus ↔ settled hearing; fix-set ↔ the grids that hearing registers; unregistered grid ↔ conflated with the nearest registered refinement — is the interpretive layer, argued not proved. It is the same species of commitment as the companion paper's nuclei-as-observers reading (its §7), instantiated for rhythm, where the identification of "grid" with "metrical level" is most literal.

## 4. What transfers if H holds

Each proved theorem becomes an exact cognitive law under H. None of these is available to introspection or to informal music theory at this precision; that is what the algebra adds.

**4.1 The hearing space is finite and known [K under H].** A listener attending a 12-pulse cycle has exactly eight possible settled hearings; a 36-pulse cycle, sixteen. Not approximately, and not "in this model as one option among many" — the classification theorem enumerates them, and H says the enumeration is exhaustive of perception.

**4.2 Fragility is perceptual [K under H].** The founding distinction of the 12-pulse world (the half-cycle division; in the pitch reading, the tritone split of the octave) supports a full four-position organization under exactly one hearing: full resolution. Every entrained coarsening — including the hearing built from the distinction itself — collapses it. A listener who groups *at all* loses the four-fold.

**4.3 Latency is the strong prediction [K under H].** In the 36-pulse world, the level-6 structural relation has no four-position organization at full attention — the organization is not subtle there; it is *absent*, provably — and complete organization under exactly two entrained hearings. Under H this asserts: **there is auditory organization that fully detailed attention cannot access in principle, reachable only through specific coarsenings, and the set of coarsenings that reach it is exactly computable.** This is stronger than any extant claim in the attention literature known to us, and it is the claim the experiment of §6 tests.

**4.4 The four positions specify what "organization" means [K under H].** Openness is not an aesthetic judgment: it is the joint inhabitation of the four cells of 2.2 — something that grounds the distinction, something that carries it across both sides, something that exploits its remainder, something that refuses it. The two collapse modes are equally specific: a world-dense verdict empties the Refusal side (the distinction's complement vanishes — nothing in that hearing can stand outside it); a world-regular verdict starves Infrastructure (the distinction carries no surplus beyond its double complement — nothing is left to build on).

## 5. Location in the literature

**What existing theory supplies [C].** The lattice is not new to cognition: the metrical well-formedness rules of Lerdahl and Jackendoff (*A Generative Theory of Tonal Music*, 1983) treat meter as a hierarchy of nested isochronous levels — precisely the chains of Div(n). That attention to such hierarchies is a settled, periodic, entrained state is the core of dynamic attending theory (Jones and Large, "The dynamics of attending," *Psychological Review* 1999) and of London's account of meter as "a mode of attending" (*Hearing in Time*, 2004). Grouping as a lawful merging of auditory distinctions is Bregman's auditory scene analysis (1990). The components of H are therefore all individually familiar.

**What is new [H].** No work known to us asks whether entrained grouping satisfies the nucleus axioms — whether attention's mergings are inflationary, idempotent, and meet-preserving *as a package* — and therefore none inherits the classification, fragility, or latency theorems. Dynamic attending theory models *how* entrainment locks; H states *what algebraic object* the locked state is. The gap is the same one the companion paper found in the mathematical literature (nuclei studied without ordinariness; ordinariness without nuclei): here, entrainment is studied without algebra, and the algebra existed without a perceptual reading.

**Canonical practice as informal witness [A].** Three Bach commonplaces are the phenomena of §4 avant la lettre, offered as illustration only. The baroque **hemiola** — six pulses heard as 2×3 or 3×2 — is the two-hearings structure in miniature: identical material, two legal groupings, different structure under each. The chorale prelude **"Wachet auf, ruft uns die Stimme"** (BWV 645) is informal latency: the hymn tune lives on the long-note grid, is famously missable under note-level attention to the figuration, and appears when attention coarsens to the cantus firmus level — more detail, less structure. The augmentation counterfugues of ***The Art of Fugue*** run the nucleus by hand: the subject against itself on a coarser time-grid, both resolutions sounding at once. That a composer of Bach's rank built systematically in exactly the space H formalizes is why the hypothesis is worth the cost of testing; it is not evidence that H is true.

## 6. The experiment

The design is stated so it can be pre-registered; it requires a psychoacoustics collaboration and is not run. Grade of everything in this section: **[H]**, with the stimulus construction flagged as the hard interpretive step.

**Material.** Isochronous 36-pulse cycles (cycle length ≈ 2.4 s; pulse ≈ 67 ms) rendered as superimposed click layers, one layer per grid, pitch-mapped by level (the repository's sonification: coarse grids low and loud, fine grids high and soft). Target items embed a four-position structural relation at level 6 — concretely, layer relations that realize the four cells of the level-6 four-fold *as computed in the two key worlds*; foils scramble the level-6 relation while matching layer content, density, and spectral profile. Constructing target/foil pairs that differ only in the level-6 relation is the interpretive crux; the construction must be fixed and frozen before data collection.

**Conditions.** Between-block entrainment priming by count-in and instruction: (i) full-resolution attention (track every pulse); (ii) even-grouping entrainment (the {2,4,6,12,18,36} hearing); (iii) threes-grouping entrainment (the {3,6,9,12,18,36} hearing); (iv) a non-aperture coarse hearing of matched depth (e.g. fours-grouping) as active control; (v) the same paradigm on 30-pulse material — a square-free cycle, where latency is provably impossible for every element — as structural control.

**Task.** Two-interval same/different discrimination on the level-6 relation (target vs. matched foil).

**Predictions.** P1: discrimination above chance in conditions (ii) and (iii). P2: discrimination at chance in (i) — the strong, counterintuitive prediction: *full attention fails*. P3: chance in (iv) — coarsening per se does not unlock; only the two computed keys do. P4: chance in all conditions of (v) — no entrainment unlocks anything in a square-free world. P5 (quantitative, weaker form): across a battery of levels and cycles, unlocked conditions coincide with computed apertures, whose sizes Theorem 5.1 of the companion paper gives in closed form.

**Failure semantics.** The design localizes a negative result. Success in (i) falsifies the latency transfer outright — either the dictionary (§3) misidentifies "full resolution" or perception accesses structure the algebra says is absent, i.e. H1 fails (attention at full detail is already merging, or splitting). Success in (iv) but not (i–iii) indicts the classification transfer — the perceptual hearing space is not the nucleus space, pointing at H2 or H3. Failure everywhere, including (ii)–(iii), leaves H untouched but the dictionary dead: metrical entrainment would not be the perceptual realization of these nuclei, and the stimulus construction returns to the drawing board. Each outcome is informative; that is the design's justification.

## 7. What is not claimed

- **Not neuroscience.** H is stated at the algebraic level of description; it entails nothing about mechanism, and no claim is made that nuclei are implemented neurally as such.
- **Not a theory of music.** Pitch, harmony, timbre, voice leading, and everything aesthetic are outside the formalism. The Bach examples are illustrations of grouping phenomena, not analyses of the works.
- **Not established.** The mathematics is [K]; the hypothesis is [H]; the dictionary is [A]. The paper's one-sentence summary keeps the grades attached: *the mathematics proves the exact laws that hearing would obey if attention blurs lawfully — the three axioms are the wager, Bach is the anecdote, and latency is the experiment waiting to be run.*
- **Not dependent on the reading.** If H fails, the theorems of the companion paper are untouched; they were proved about lattices, not listeners.

## 8. Epistemic status of every claim

| claim | grade |
|---|---|
| four-cell theorem; nucleus factorization; chain classification; aperture closed form (two-prime); Div12 fragility; Div36 latency with exactness | [K] (companion paper §§2, 4–6; Lean files cited there) |
| closed form on ≥ 3 primes; aperture tables | [computed] (companion paper §§4–5) |
| metrical hierarchy as nested isochronous levels; entrainment as attending mode; auditory grouping as lawful merging | [C] (Lerdahl–Jackendoff 1983; Jones–Large 1999; London 2004; Bregman 1990) |
| grid ↔ metrical level; hearing ↔ nucleus dictionary | [A] |
| H1, H2, H3 (attention satisfies the nucleus axioms) | [H] |
| latency transfer: organization in-principle closed to full attention, open to exactly two computable hearings | [H], conditional on H1–H3 and the dictionary |
| experimental predictions P1–P5 | [H], pre-registrable as stated |
| stimulus construction realizing the level-6 four-fold acoustically | [O] — the named hard step |
| Bach illustrations (hemiola; BWV 645; augmentation) | [A], illustration only |
| whether perception's violation pattern, if any, localizes to a specific axiom | [O], the experiment's purpose |

## 9. Reproducibility and materials

The mathematical claims resolve to the companion paper and the repository (github.com/thefalsework/papers): `preprints/aperture/paper.md` with its Lean development (`lean/FalseWorkPapers/Positions/OrdinaryKernel.lean`, `lean/FalseWorkPapers/Lattice/NucleusFactorization.lean`, `lean/FalseWorkPapers/Lattice/ApertureClosedForm.lean`, `lean/FalseWorkPapers/Examples/ApertureAnchors.lean`; axiom audit: `propext`, `Classical.choice`, `Quot.sound` only). The hearings of Div(12) and Div(36), their fix-sets, per-hearing verdicts, and audible renderings (click-layer sonification, one layer per registered grid) are computed and playable in the project's interactive worksheet; the sonification scheme doubles as the stimulus-generation spec for §6. The two-keyed-lock demonstration — level 6 of the 36-cycle, inaudible as structure at full resolution, articulated under exactly the two computed hearings — is reproducible by ear from that worksheet today; what §6 adds is the discipline of not trusting our own ears about it.

**Disclosure.** Drafting was AI-assisted under direction, per the project's validation architecture; the grade table in §8 is the author's warrant, not the assistant's.
