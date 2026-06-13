# Open validation items

This file is the canonical index of every currently-open validation item across the paper series. Each entry points to an authoritative claim statement in [`claims/`](claims/) and to a matching [GitHub Issue](https://github.com/thefalsework/papers/issues) for discussion.

When a claim is validated, corrected, or disputed, its entry moves to [`RESOLVED.md`](RESOLVED.md) with the validator's name and a pointer to the revision that absorbed the outcome.

---

## Domain: Category theory

### `music-kernel-umbrella` — Formalization of the music-kernel endofunctor (post-calibration split)
- **Authoritative statement:** [`claims/music-kernel-umbrella.md`](claims/music-kernel-umbrella.md)
- **GitHub issue:** [#1](https://github.com/thefalsework/papers/issues/1)
- **Paper:** Paper 3 § 4 (v9.4; § 4 substantively unchanged since v9.1 — the v9.4 architectural-status note refines the categorical object D1–D4 produces); targeted for v10.0 revision
- **What's asked:** verification of the LLM-supplied formalization of the music-kernel endofunctor `D`. After the 2026-04-26 calibration pass (see umbrella file's "Calibration note"), the originally-flat six-point list now splits into **background facts** (Point 1, Point 6 Sub-target A — textbook FTA results, cite don't validate; Lean expression confirmed idiomatic via Zulip 2026-04-26) and a **genuine validation queue** (Points 2, 3, 4, 5, and Point 6 Sub-target B): cardinality argument for `Fix(D) = {∅}`; no terminal coalgebra via Lambek; colimit escape via Weyl; the `ℤ/12ℤ` corrected structural claim (where the LLM draft asserted `D_12^12 = id`, which the author identified as false); and the effective Baker quantitative bound (blocked on upstream mathlib).
- **Time estimate for validator:** ~1 hour for the genuine queue
- **Status:** awaiting category theorist + number theorist for the genuine queue (Points 2–5 and 6B). Background facts (Point 1, 6A) require citation only.
- **Sub-items:** [`music-kernel-01`](claims/music-kernel-01-irrationality.md) (background fact), [`02`](claims/music-kernel-02-fixed-points.md), [`03`](claims/music-kernel-03-terminal-coalgebra.md), [`04`](claims/music-kernel-04-colimit-escape.md), [`05`](claims/music-kernel-05-z12z-cycle.md), [`06`](claims/music-kernel-06-baker.md) (Sub-target A background; Sub-target B in queue, blocked) — see also issue [#2](https://github.com/thefalsework/papers/issues/2) for number-theory focus on Sub-target B

### `five-position-derivation-formalization` — Position dictionary as a categorical object (four-position partition + Commitment gate)
- **Authoritative statement:** [`claims/five-position-derivation-formalization.md`](claims/five-position-derivation-formalization.md)
- **GitHub issue:** (pending)
- **Paper:** Paper 1 § 3.4 (v11.8 architectural-revision note); Paper 3 § 4 (v9.4 architectural-status note); canonical prose statement at [`../papers/comma-formal-structure-note.md`](../papers/comma-formal-structure-note.md); Lean formalization at [`../lean/FalseWorkPapers/Positions/`](../lean/FalseWorkPapers/Positions/) (partition theorem kernel-checked 2026-05-19; full tree sorry-free 2026-05-20)
- **What's asked:** verify (i) the Level-1 schema as a categorical object — four-position partition (Infrastructure, Distribution, Exploitation, Refusal) as Heyting conditions over the kernel image plus a Commitment gate as binary fixedness within each cell; (ii) the closure-residue commitment for Exploitation (`img ≤ ¬¬Im(η) ∧ ¬(img ≤ Im(η))`); (iii) the four-cells-pairwise-disjoint claim in the topos register; (iv) the two-parameter unification negative result (the four predicates are propositional-shape-distinct Heyting conditions, not specializations of any uniform Heyting term); (v) the moment-relativization scoping. Level 2 (the derivation theorem: that exactly these four cells plus the gate are forced) is named as a downstream open problem, not claimed established.
- **Time estimate for validator:** ~4–8 hours (category theorist / topos theorist already familiar with Heyting algebras of subobjects)
- **Status:** awaiting category theorist or topos theorist; the partition theorem (`four_position_partition`) and the asymptotic-residue theorem (`refusal_residue` under `Δ.HasIrregularKernel`) are both kernel-checked. Mathlib PR [#39618](https://github.com/leanprover-community/mathlib4/pull/39618) opened 2026-05-20 for the underlying `HeytingAlgebra (Subobject _)` construction. The `HasIrregularKernel` bridge is tracked separately at [`refusal-bridge`](claims/refusal-bridge.md).
- **Related:** [`music-kernel-umbrella`](claims/music-kernel-umbrella.md) (the position dictionary's music instantiation runs on the music-kernel endofunctor); [`refusal-bridge`](claims/refusal-bridge.md) (the depth-of-application conjecture for `refusal_residue`)

### `refusal-bridge` — When does a non-trivial distinction structure escape the regular sub-algebra?
- **Authoritative statement:** [`claims/refusal-bridge.md`](claims/refusal-bridge.md)
- **GitHub issue:** (pending)
- **Paper:** Paper 1 § 3.4 (Refusal as one of four cells); Paper 3 § 4 (D1–D4 categorical formalization); Lean source at [`../lean/FalseWorkPapers/Positions/Refusal.lean`](../lean/FalseWorkPapers/Positions/Refusal.lean) — `DistinctionStructure.HasIrregularKernel` predicate and `refusal_residue` theorem (closed under that hypothesis 2026-05-20)
- **What's asked:** verify or refute the conjecture that every non-trivial distinction structure `Δ` on a non-Boolean elementary topos `C` has an irregular kernel — i.e., `kernelImage Δ Y ≠ (kernelImage Δ Y)ᶜᶜ` at some object `Y`. Equivalently, that no non-trivial `Δ` can confine its kernel image entirely to the regular (Boolean) sub-algebra of every subobject lattice. The conjecture is non-trivial because the regulars of any Heyting algebra form a Boolean sub-algebra, so a regularly-confined non-trivial `Δ` (e.g., lifted from the topos's Boolean reflection) is a generically available class rather than a constructed counterexample. The validator is asked to (i) attempt the conjecture under additional structural hypotheses (Spencer-Brown coherence; the `¬¬`-modality), (ii) attempt a counterexample via the Boolean-reflection lift, or (iii) verify the bridge case-by-case in specific non-Boolean topoi of interest.
- **Time estimate for validator:** ~4–10 hours (topos theorist familiar with the regular sub-algebra of a Heyting algebra and the `¬¬`-topology on an elementary topos)
- **Status:** awaiting topos theorist or category theorist. The `refusal_residue` theorem stands either way (it is closed under the `HasIrregularKernel` hypothesis); the bridge controls how broadly the asymptotic-residue phenomenology applies, not whether the theorem is correct.
- **Related:** [`five-position-derivation-formalization`](claims/five-position-derivation-formalization.md) (the umbrella formalization claim this conjecture sits under)

### `music-topos-t2-realization` — the music substrate is a concrete presheaf topos (T2), with a Lawvere–Tierney realization of the distinction operator
- **Authoritative statement:** [`claims/music-topos-t2-realization.md`](claims/music-topos-t2-realization.md)
- **GitHub issue:** (pending)
- **Paper / note:** four-position-partition preprint `music-anchor/mazzola-bridge-note.md` §5; synthesis note [`../papers/connecting-the-spine.md`](../papers/connecting-the-spine.md) §3; Lean at [`../lean/FalseWorkPapers/Examples/DivisorLattice12Birkhoff.lean`](../lean/FalseWorkPapers/Examples/DivisorLattice12Birkhoff.lean) and [`DivisorLattice12Nucleus.lean`](../lean/FalseWorkPapers/Examples/DivisorLattice12Nucleus.lean)
- **What's kernel-checked (in-repo):** `Div12 ≅ Sub_{Set^{Pᵒᵖ}}(1)` (Birkhoff, `birkhoff_representation`); a Lawvere–Tierney topology on `Set^{Pᵒᵖ}` with the tritone as non-regular kernel (`tritone_kernel_has_lawvere_tierney_realization`); and the negative correction that the minimal tritone-closing operator is not a nucleus (`tritoneClosure_not_nucleus`).
- **What's asked / open:** (i) topos-object plumbing — instantiate `Set^{Pᵒᵖ}` as a Lean elementary topos so the abstract `four_position_partition` typechecks against it directly (blocked by a Mathlib presheaf universe / `InitialMonoClass` gap; mechanical, not mathematical); (ii) **canonicity** — is `Set^{Pᵒᵖ}` *the* music topos, or a natural slice of a richer one (Mazzola's denotator topos; a `D₁₂`-groupoid presheaf topos)? A question of canonicity, not existence.
- **Time estimate for validator:** ~1–2 hours for (i) sanity check; (ii) is an open specialist question.
- **Status:** lattice-and-operator level kernel-checked in-repo; awaiting categorical music theorist on canonicity. Drops the Mazzola dependency for the *existence* of the bridge.

### `lawvere-unification-of-formal-groundings` — Cantor and Gödel as Lawvere instances; G ∧ R ∧ C as domain-facing analog of Lawvere's hypothesis
- **Authoritative statement:** [`claims/lawvere-unification-of-formal-groundings.md`](claims/lawvere-unification-of-formal-groundings.md)
- **GitHub issue:** (pending)
- **Paper:** Paper 1 § 2 and § 2.1 (v11.8; §§ 2 and 2.1 substantively unchanged since v11.5 — the v11.8 architectural-revision note refines the position dictionary but not the Lawvere framing)
- **What's asked:** verify three claims. (1) Cantor's diagonal argument, Cantor's theorem, and Gödel's first incompleteness theorem are instances of Lawvere's fixed-point theorem per Yanofsky 2003. (2) Wolfram's PCE is a universality-class claim rather than a Lawvere instance; its consequences (halting problem, Rice's theorem) are Lawvere instances. (3) G ∧ R ∧ C corresponds to Lawvere's categorical hypothesis (G ↔ B^A, R ↔ point-surjection, C ↔ cartesian closure); the extension-to-practice problem is reformulable as specifying the ambient CCC and endofunctor for each kernel. Claims 1 and 2 are standard literature; Claim 3 is speculative and the one where pushback is most likely and most useful.
- **Time estimate for validator:** ~2–6 hours (three primary texts plus two adjacent paper sections)
- **Status:** awaiting category theorist or mathematical logician; AI-synthesis origin disclosed in the claim file

---

## Domain: Set theory / formal logic

### `cantor-cumulative-caveat` — Cantor application across four papers
- **Authoritative statement:** [`claims/cantor-cumulative-caveat.md`](claims/cantor-cumulative-caveat.md)
- **GitHub issue:** [#3](https://github.com/thefalsework/papers/issues/3)
- **Paper:** canonical at Paper 4 § 2.5 (v5.3); invoked at Paper 1 § 2, Paper 3 § 9. *(Removed from Paper 2 at v8.15 arXiv scope cut; historical v8.2 § 2.3 only.)*
- **What's asked:** advise whether each of four applications of Cantor's power-set theorem is direct, formalizable under additional structure, an analogy, or a category error.
- **Time estimate for validator:** ~3–5 hours
- **Status:** awaiting set theorist or formal logician

### `ladder-core-threshold` — Nishimura normal form (de-[C]s the all-n law) and V(Z₆) primitiveness
- **Authoritative statement:** [`claims/ladder-core-threshold.md`](claims/ladder-core-threshold.md)
- **GitHub issue:** (pending)
- **Paper / note:** [`../papers/connecting-the-spine.md`](../papers/connecting-the-spine.md) §3.4 + ledger row 20g; Lean at [`../lean/FalseWorkPapers/Examples/LadderCore.lean`](../lean/FalseWorkPapers/Examples/LadderCore.lean)
- **What's kernel-checked (in-repo, 2026-06-11):** universal ≥6 threshold for any Heyting algebra with an ordinary element; `Div12 = Z_6` order-embeds into every such algebra (`propext` only); `H8`'s ladder core ≅ `Z_7`; tritone = unique generator of `Div12`; dense-bottom lemma.
- **What's open:** (i) **Nishimura normal form** — every element of the subalgebra generated by `g` is a Nishimura term value in `g` (the RN meet/join/implication tables as derived identities). Formalizing it would prove Citkin's Prop. 3.1 in full (ladder *subalgebra*, not just order-embedding, in every non-degenerate instance) and remove the [C] from the all-n kernel law, making the math anchor unconditional. Highest-value remaining Lean target in the math anchor; estimate weeks. (ii) **V(Z₆) primitiveness** — is the si-logic of the music lattice hereditarily structurally complete? Route written in the claim file (Citkin's criterion + Jónsson + cardinality); blocked only on reading the Hasse diagrams of prohibited algebras `P3–P5` from arXiv:2512.05633 Fig. 1 (figures, not text). A finite check once read.
- **Status:** (i) open formalization target, pre-registered; (ii) blocked on figure access, then mechanical

---

## Domain: Number theory

### `music-kernel-06-baker` — Baker's 1966 theorem applied to the Pythagorean comma (Sub-target B only)
- **Authoritative statement:** [`claims/music-kernel-06-baker.md`](claims/music-kernel-06-baker.md)
- **GitHub issue:** [#2](https://github.com/thefalsework/papers/issues/2)
- **Paper:** Paper 5 (Pythagorean) § 4 (v1.3); Paper 3 § 5 (v9.4)
- **What's asked:** verify that Baker's 1966 theorem on linear forms in logarithms of algebraic numbers applies to |12 log 3 − 19 log 2| and that the resulting effective lower bound is qualitatively the right tool, not misapplied. (Sub-target A — qualitative non-vanishing — was reclassified as a background fact in the 2026-04-26 calibration pass and is no longer an open validation item; this entry now tracks Sub-target B only.)
- **Time estimate for validator:** ~30 min – 1 hour
- **Status:** awaiting number theorist; full Lean formalization blocked on Baker's theorem not being in current mathlib4, but reference-level confirmation of the cited claim against standard number-theory texts is not blocked

### `pythagorean-explanatory-debts` — Three debts from Pythagorean companion § 7.5
- **Authoritative statement:** [`claims/pythagorean-explanatory-debts.md`](claims/pythagorean-explanatory-debts.md)
- **GitHub issue:** [#5](https://github.com/thefalsework/papers/issues/5)
- **Paper:** Paper 5 § 7.5 (v1.3)
- **What's asked:** three open questions named by the paper itself — (1) uniform framework unifying rank-1 and rank-≥2 Diophantine cases; (2) typology-mapping nuance for foundations-of-mathematics schools; (3) specific cents-level numerical bound from Baker's theorem.
- **Time estimate for validator:** variable; each debt is independently tractable.
- **Status:** awaiting number theorist

---

## Domain: Research direction (not bounded one-hour validation)

### `ladder-wide-d4` — Arithmetical-ladder D4 question
- **Authoritative statement:** [`claims/ladder-wide-d4.md`](claims/ladder-wide-d4.md)
- **GitHub issue:** [#4](https://github.com/thefalsework/papers/issues/4)
- **Paper:** Paper 3 § 5.2 (v9.4; § 5.2 substantively unchanged since v9.1)
- **What's asked:** does the D4 subcategory-vs-full-Lawvere-comma question admit a clean categorical answer for each rung `ℕ → ℤ, ℤ → ℚ, ℚ → ℝ, ℝ → ℂ, ℂ → ℍ, ℍ → 𝕆`?
- **Status:** open research direction; no time estimate; contributions via any of validation, correction, PR, or discussion welcome.

### `methodology-scaffolding-ablation` — Does the epistemic scaffolding carry the discipline? (pre-registered ablation)
- **Authoritative statement:** [`claims/methodology-scaffolding-ablation.md`](claims/methodology-scaffolding-ablation.md)
- **GitHub issue:** (pending)
- **Paper:** Paper 2 § 6.3 (v8.17 / arXiv v1) — the methodology stated as methodology: the [K]/[C]/[A]/[O] status-tag ladder and supporting practices as the designed implementation of the paper's correction architecture
- **What's asked / open:** two separated claims. (1) *Pre-registered ablation:* run matched AI instances on real repository tasks against the scaffolded corpus vs. a scaffolding-stripped copy; measure the rate of unlicensed promotion ([A]/[O] asserted as [K], dropped hedges, fabricated specifics, inherited-record errors). All three outcomes pre-registered as acceptable — scaffolding carries rigor / scaffolding is operator ergonomics / scaffolding masks error behind fluent register. (2) *Generalization:* whether the method survives an operator other than its designer — testable only by external replication. First logged observation (2026-06-12, the "§ 6.4" instance): a stale index entry was inherited verbatim by an AI instance, initially misdiagnosed as confabulation, then traced to the record itself — evidence that the record is part of the dependency structure it documents.
- **Status:** (1) pre-registered, not yet run; (2) awaiting any external operator adopting the practice. Until then the methodology's standing is: demonstrated once, in one project, by the operator who designed it — [A]/[O], not a paradigm.

### `g-r-c-practice-domains` — Extension of G∧R∧C beyond formal systems
- **Authoritative statement:** [`claims/g-r-c-practice-domains.md`](claims/g-r-c-practice-domains.md)
- **GitHub issue:** [#7](https://github.com/thefalsework/papers/issues/7)
- **Paper:** Paper 1 § 3 and § 5 (v11.8; §§ 3 and 5 substantively unchanged since v11.4); downgraded to structural analogy at Paper 3 § 7 (v9.4; § 7 substantively unchanged since v9.2); Paper 1 § 2.1 (v11.5) reframes the question through a G ∧ R ∧ C ↔ Lawvere's-hypothesis correspondence; Paper 1 § 2.1 (v11.6) introduces the candidate seventh kernel (`threshold-kernel-candidate`) as one specific instance for which the extension is independently derivable rather than postulated
- **What's asked:** precise definition of "generative sufficiency" for non-recursively-enumerable systems (literature, cinema, architecture); whether the G∧R∧C mapping to D1–D3 can be upgraded from structural analogy to derivation in any formal setting.
- **Status:** open research direction
- **Related:** [`threshold-kernel-candidate`](claims/threshold-kernel-candidate.md) — generative AI as one specific instance where the extension is grounded in independent mathematical work (Levin 2026)

---

## Domain: Philosophy of science

### `ellis-cartwright-philosophical-support` — Ellis and Cartwright as scholarly precedent for domain-dependent formalism
- **Authoritative statement:** [`claims/ellis-cartwright-philosophical-support.md`](claims/ellis-cartwright-philosophical-support.md)
- **GitHub issue:** [#10](https://github.com/thefalsework/papers/issues/10)
- **Papers:** Paper 1 § 5.4 (v11.8; § 5.4 substantively unchanged since v11.4); Paper 3 § 7.3 (v9.4; § 7.3 substantively unchanged since v9.2)
- **What's asked:** verify that Ellis (2016, multi-level emergence and top-down causation) and Cartwright (1999, dappled-world thesis) are appropriately scoped as *adjacent scholarly precedent* — not endorsement — for the FalseWork programme's methodological commitment that different domains admit different degrees of formalism. Three named disjoints (vertical vs. horizontal hierarchy; causation vs. kernel/comma topology; Cartwright's naturalism vs. FalseWork's structural claim) should each be specifically assessed.
- **Time estimate for validator:** ~2–4 hours (two primary texts plus the adjacent paper sections)
- **Status:** awaiting philosopher of science with emergence / multi-level-ontology / philosophy-of-physics expertise

---

## Domain: Humanities / reception studies

### `posthumous-canonization` — Posthumous / delayed canonical rehabilitation as a testable prediction
- **Authoritative statement:** [`claims/posthumous-canonization.md`](claims/posthumous-canonization.md)
- **GitHub issue:** [#8](https://github.com/thefalsework/papers/issues/8)
- **Paper:** Paper 6 § 5, § 7 (v2.1, exploratory companion)
- **What's asked:** systematic historical test of the claim that posthumous / delayed canonical rehabilitation correlates with structural markers of kernel-level confrontation — using Bach, El Greco, and the Homeric epics as paradigm cases and seeking both matched and counter-example cases across music, visual art, and literature.
- **Status:** awaiting historian of music / art / literature or reception-studies scholar
- **Register note:** Paper 6 is the exploratory / practitioner-outcome companion. This item is its single empirically bounded sub-claim; the rest of Paper 6 is structural-interpretive and is not tracked as a validation item.

---

## Domain: Generative AI / philosophy of computation

### `threshold-kernel-candidate` — The Threshold as candidate seventh kernel (GenAI)
- **Authoritative statement:** [`claims/threshold-kernel-candidate.md`](claims/threshold-kernel-candidate.md)
- **GitHub issue:** (pending)
- **Paper:** Paper 1 § 2.1 (v11.8; § 2.1 substantively unchanged since v11.6); candidate seventh kernel proposed in light of Levin (2026, arXiv:2604.02476 and arXiv:2602.17116)
- **What's asked:** four sub-questions, each independently tractable. (1) Four-criteria validation — does The Threshold satisfy each of prior, monogenic, inescapable, and self-limiting at the level of formal precision the framework requires? Sketched in § 2.1 prose; specialist audit pending. (2) Comma formulation — is manifold-membership undecidability the correct comma description, or do alternative formulations (entropy-based, computational-irreducibility-based, information-theoretic) fit better? (3) Domain-medium framing — the original six domains have practitioners engaging with passive media governed by their kernels; GenAI's medium is itself a navigator of its own kernel. Does the practitioner-position-toward-medium classification carry through cleanly when the medium is non-passive, or does this require a multi-level account? (4) Topology applicability — does the five-position partition (Infrastructure, Distribution, Exploitation, Commitment, Refusal) match observable GenAI practitioner stances? The substrate / deployment / navigation / constraint / refusal mapping (registered on the platform at [falsework.dev/kernels](https://falsework.dev/kernels) and sketched in correspondence with Levin) is a prediction the framework makes, not a confirmed reading.
- **Time estimate for validator:** variable; each sub-question is independently tractable. Sub-question 1 (four-criteria audit) is the closest analog to the audits Tymoczko ran on The Fifth and Cutting on The Cut.
- **Status:** awaiting AI/ML researcher or philosopher of computation; Levin engagement is ongoing. Full § 3-style kernel specification deferred until validation supports it; if the candidate fails validation, Paper 1 v12.x will retract the seventh-domain framing and recharacterize Levin's contribution as a parallel framework that engages the same structure under a different theoretical apparatus.
- **Platform mirror:** the candidate is registered as `the-threshold` (status: `proposed`) on the FalseWork platform — kernel specification, five-territory topology, and pathway structure are publicly inspectable at [falsework.dev/kernels](https://falsework.dev/kernels) and seeded in the platform repo at `db/0167_threshold_kernel_genai.sql`.

---

## Domain: Physics / foundations of physics

### `paper4-higgs-vev-debt` — Higgs VEV magnitude explanatory debt
- **Authoritative statement:** [`claims/paper4-higgs-vev-debt.md`](claims/paper4-higgs-vev-debt.md)
- **GitHub issue:** [#6](https://github.com/thefalsework/papers/issues/6)
- **Paper:** Paper 4 § 6.3 (v5.3; § 6.3 expanded in v5.3 with scholarly-company paragraph naming Penrose / Smolin / Carroll / Verlinde — the VEV-magnitude debt itself is unchanged from v5.1)
- **What's asked:** the process-primacy framing explains the *existence* of the Higgs VEV as a symmetry-breaking residue but does not re-derive its specific magnitude (≈ 246 GeV). This debt is acknowledged in the paper; a resolution would re-derive the magnitude from the proposed framework.
- **Status:** open; awaiting a quantum-foundations or particle-theory engagement

---

## How this file is maintained

Entries are added when a new `[REQUIRES FORMAL VALIDATION]` flag appears in a paper or when a contributor opens an Open-Research-Direction issue. Entries are moved to [`RESOLVED.md`](RESOLVED.md) when a validation PR merges, a correction PR lands, or a dispute settles.

The canonical version of each claim is the `.md` file in [`claims/`](claims/), not the GitHub Issue. Issues are for discussion; claim files are for the record.

See [`../CONTRIBUTING.md`](../CONTRIBUTING.md) for acceptance criteria.
