# Lean 4 formalization

This directory exists from day one of the repository to signal that a Lean 4 formalization of the paper series' mathematical claims is a first-class target of the project, and to give any Lean contributor a single, well-defined place to propose work.

At this moment the directory contains:
- This README describing the formalization target.
- A skeletal `lakefile.lean` and `lean-toolchain` so a contributor can clone, `lake update`, and begin work without friction.
- A first sketch of the **four-position partition + Commitment gate** formalization under [`FalseWorkPapers/Positions/`](FalseWorkPapers/) — see *Sketch in flight* below.
- No completed proofs yet.

This README serves as the authoritative specification of what a Lean formalization of this project would cover. Contributions — partial or complete, bounded or ambitious — are warmly welcomed.

---

## Sketch in flight: the four-position partition + Commitment gate

The directory [`FalseWorkPapers/Positions/`](FalseWorkPapers/) contains a first Lean 4 sketch of the position-dictionary theorem candidate from Paper 1 v11.8 (architectural revision-note) / v11.9 (planned body rewrite) § 4, in the topos register described in Paper 3 v9.4 § 4. The canonical prose statement of the refined architecture lives at [`../papers/comma-formal-structure-note.md`](../papers/comma-formal-structure-note.md).

**Architecture (revised 2026-05-10).** The dictionary is a *four-position partition* over morphisms (Infrastructure, Distribution, Exploitation, Refusal) — disjoint and exhaustive in the topos register — plus a *Commitment gate*, a binary fixedness condition that applies *within each cell*. The previously-named "five positions" structure has been refined: Commitment is not a fifth lattice cell but a binary annotation across the four cells. The 2026-05-10 two-parameter unification test (see *MomentRelative* below) closed the question of whether the four cell-restricted iterations derive from a single uniform construction (negative on theorem-grade, positive on schema-level).

**Status (2026-05-20, second pass).** `lake build`-green.  **Zero `sorry`s in the entire formalization tree.**  Both load-bearing theorems are kernel-checked with `#print axioms` reporting only the three standard Mathlib axioms (`propext`, `Classical.choice`, `Quot.sound`):

* **`four_position_partition`** — every morphism with non-trivial `D`-image falls in exactly one of Infrastructure, Distribution, Exploitation, Refusal.  The headline structural theorem.
* **`refusal_residue`** — the asymptotic-residue strict-inequality theorem closed under the `Δ.HasIrregularKernel` hypothesis (the kernel image escapes the regular sub-algebra at some object).  See *Refusal residue: closure and the bridge conjecture* below.

A single-page orientation document showing the proof dependency, the cell geometry, and the proven/submitted/open ledger lives at [`ARCHITECTURE.md`](ARCHITECTURE.md).

The `HeytingAlgebra (Subobject _)` construction the partition theorem requires has been built locally at [`Heyting/SubobjectInstance.lean`](FalseWorkPapers/Heyting/SubobjectInstance.lean) following Mac Lane–Moerdijk IV.6 Proposition 2, and submitted upstream as Mathlib PR [#39618](https://github.com/leanprover-community/mathlib4/pull/39618) (opened 2026-05-20, CI green, awaiting review).  One framework-level open conjecture — the *refusal bridge* — is carried at [`../validation/claims/refusal-bridge.md`](../validation/claims/refusal-bridge.md): the question of when `Δ.HasIrregularKernel` follows from `Δ.NonTrivial + NonBoolean C`.  The earlier "sketch in flight" framing below is preserved as historical record.

**Files.**
- [`FalseWorkPapers/Positions.lean`](FalseWorkPapers/Positions.lean) — index file; partition-theorem statement; ranked open questions; gate schema summary; two-parameter-unification closure summary.
- [`FalseWorkPapers/Positions/Setup.lean`](FalseWorkPapers/Positions/) — `DistinctionStructure` (idempotent endofunctor `D` with marking unit `η` and Spencer-Brown coherence), `NonTrivial` predicate, `kernelImage` subobject. Documents the upstream Mathlib gap.
- [`FalseWorkPapers/Positions/Infrastructure.lean`](FalseWorkPapers/Positions/) — `IsInfrastructure` as image-subobject condition `img ≤ kernelImage` (revised 2026-05-17 from the earlier endpoint-iso predicate, which would have left an exhaustiveness hole in the four-position partition). The retired endpoint-iso predicate survives as the sufficient sub-condition `Trivialized`; the pointwise-`D` signature lemma re-attaches to `Trivialized`. Deep Infrastructure level-stratified sketch unchanged.
- [`FalseWorkPapers/Positions/Distribution.lean`](FalseWorkPapers/Positions/) — `IsDistribution` as image straddling `Im(η)` and `¬Im(η)`.
- [`FalseWorkPapers/Positions/Exploitation.lean`](FalseWorkPapers/Positions/) — **closure-residue construction committed.** `IsExploitation Δ f` defined as `img(D.map f) ≤ ¬¬Im(η) ∧ ¬(img ≤ Im(η))`, at the level of generalized elements. Two signature theorems (non-Boolean dependence; Heyting disjointness from Refusal). A third theorem distinguishing Exploitation from Commitment was drafted as a "transverse-vs-pole" claim and *withdrawn* on 2026-05-09; the underlying problem subsequently *dissolved* on 2026-05-10 when Commitment was reframed as a gate within each cell rather than a fifth cell.
- [`FalseWorkPapers/Positions/Refusal.lean`](FalseWorkPapers/Positions/) — `IsRefusal` as factoring through `(Im(η))ᶜ`.  `refusal_residue` theorem closed (2026-05-20, second pass): the strict inequality `kernelImage Δ Y < (kernelImage Δ Y)ᶜᶜ` holds whenever `Δ` has an irregular kernel (i.e., its image at some object escapes the regular sub-algebra of `Subobject (D Y)`).  The bridge from `NonBoolean C` to `HasIrregularKernel` is carried as a named open conjecture at [`../validation/claims/refusal-bridge.md`](../validation/claims/refusal-bridge.md).
- [`FalseWorkPapers/Positions/Partition.lean`](FalseWorkPapers/Positions/) — **the four-position partition theorem (Theorem 0).** Full statement of exactly-one-cell claim plus pairwise disjointness, proof closed against the in-repo `HeytingAlgebra (Subobject _)` construction.  Helper lemma `isRefusal_iff_image_le_compl` re-characterises Refusal in image-subobject form (closed via the image API in Path 5, commit `60d6ef5`).
- [`FalseWorkPapers/Positions/CommitmentGate.lean`](FalseWorkPapers/Positions/) — the gate schema (replaces the retired pre-reframe `Commitment.lean` as of 2026-05-17). Defines `Cell` (the four-cell tag), `iterCell` (the per-cell iteration signature, currently a stub returning the discrete `iterD` placeholder for every cell), `IsCommitmentYes Δ P f` (uniform schema across cells), and `IsCommitmentNo` (the binary complement). The schema-level uniformity is real; the per-cell iteration content is open work, four independent local problems replacing the dissolved Commitment/Exploitation cross-cell disjointness problem.
- [`FalseWorkPapers/Positions/MomentRelative.lean`](FalseWorkPapers/Positions/) — **exploration file (not load-bearing).** Records the 2026-05-10 two-parameter unification test: write `Pos[t] P` and check whether the right-hand side is a single expression in `(P, t)` or case-splits on `P`. Result is negative on theorem-grade unification (the four predicates are propositional-shape-distinct Heyting conditions, not specializations of any single Heyting term) and positive on schema-level uniformity (uniform moment-relative kernel image, uniform Heyting register, uniform gate shape). Closes the unification question for the foreseeable future. The closure-reading variant `Pos'` (image-subobject Infrastructure) was promoted to the official cell predicate on 2026-05-17; the original η-iso `Pos` is preserved as historical record.
- [`FalseWorkPapers/Positions/REGISTER.md`](FalseWorkPapers/Positions/) — register framing note: the framework's home is Heyting-algebraic / locale-theoretic / intuitionistic-logical (one structure, four names). Flags the hazard of conflating locale geometry with manifold geometry.

**Settled by the sketch.**
- The four cells (Infrastructure, Distribution, Exploitation, Refusal) have direct definitions in the topos register.
- The closure-residue construction commits Exploitation's home in `(Im(η))ᶜᶜ ∖ Im(η)` (at the level of generalized elements).
- Refusal and Exploitation occupy disjoint Heyting regions by the identity `aᶜ ⊓ aᶜᶜ = ⊥` (not an additional commitment).
- The Commitment gate has uniform shape across the four cells; the previously-named central open problem of Commitment/Exploitation disjointness within `¬¬Im(η)` *dissolved* under the gate reframe (no longer a cross-cell disjointness question — Commitment is not a separate cell).
- The two-parameter unification question is closed (negative theorem-grade, positive schema-level).

**Documented open problems.**
1. **Per-cell restricted-iteration characterization.** For each of the four cells, the gate requires a cell-restricted iteration of `D` whose fixed points characterize Commitment-yes at that cell. Four independent local problems (Infrastructure, Distribution, Exploitation, Refusal), each documented in its respective file. Not a cross-cell disjointness problem.
2. **`HeytingAlgebra (Subobject _)` for topoi** — *closed locally; PR opened upstream.*  Constructed locally at [`FalseWorkPapers/Heyting/SubobjectInstance.lean`](FalseWorkPapers/Heyting/SubobjectInstance.lean) (commits `d297f4d` skeleton, `2fed510` six bridging lemmas discharged, `d02781f` Mathlib-PR refactor), and submitted upstream as Mathlib PR [#39618](https://github.com/leanprover-community/mathlib4/pull/39618) on 2026-05-20 (CI green, awaiting review).  Full chronology, the Zulip triage record (2026-05-17 with Edward van de Meent and Fernando Chu), and the instance-diamond resolution that retired the abstract `[∀ Y, HeytingAlgebra (Subobject Y)]` binder are at [`HEYTING-GAP.md`](HEYTING-GAP.md) and [`HEYTING-DIAMOND.md`](HEYTING-DIAMOND.md).
3. **Continuous iteration of `D`** — needed for the per-cell restricted iterations. Three resolutions documented (relax idempotency, parameterize over interval object, enriched setting).
4. **The *refusal bridge*** — when does `Δ.NonTrivial + NonBoolean C` force `Δ.HasIrregularKernel`?  The `refusal_residue` theorem itself is now closed (2026-05-20) under the `HasIrregularKernel` hypothesis; the bridge conjecture asks whether that hypothesis is automatic in non-Boolean topoi or whether some non-trivial `Δ` can confine itself to the regular sub-algebra.  The regulars form a Boolean sub-algebra of any Heyting algebra, so a regularly-confined non-trivial `Δ` is a generically available structure rather than a constructed counterexample — Path-2 transport without a hypothesis is structurally hard.  Tracked at [`../validation/claims/refusal-bridge.md`](../validation/claims/refusal-bridge.md).
5. **Level structure** for Deep Infrastructure (Kurosawa case).
6. **Balance condition** for Distribution.
7. **Categorical specification of `Moment`.** Moment-relativization is currently a working hypothesis (filtered preorder + monotone boundary-state). Whether `Moment` should be a derived construct is open.

**Relation to the validation claim.** The corresponding claim file at [`../validation/claims/five-position-derivation-formalization.md`](../validation/claims/five-position-derivation-formalization.md) (currently v0.6) defines the schema in the **F-coalgebra-with-comma-subcategory `L`** register. The Lean sketch uses a different but related register — the **distinction-structure** register with `D : C ⥤ C` and `η : 𝟭 ⟶ D`. The two are translatable but not identical. In one specific place — the **Exploitation** predicate — the Lean's closure-residue construction `img(D.map f) ≤ ¬¬Im(η) ∧ ¬(img ≤ Im(η))` is a tighter and *different* condition from the claim's "α factors through `L ↪ C`" predicate. The claim's changelog records this divergence (v0.3), the two-parameter unification closure and the Commitment-as-gate reframe (v0.4), the Infrastructure-predicate repair and explicit Theorem 0 statement (v0.5), and the Mathlib `HeytingAlgebra (Subobject _)` upstream-gap triage from the 2026-05-17 Zulip thread (v0.6, with the standing posture documented at [`HEYTING-GAP.md`](HEYTING-GAP.md)).

**Expository companion.** [`../papers/comma-formal-structure-note.md`](../papers/comma-formal-structure-note.md) is the prose-and-context companion to this Lean sketch. It carries the four-position-partition + Commitment-gate architecture, the closure-residue construction, the four cell predicates, the three signature theorems committed at this stage, the four-claims-with-four-statuses honesty table, the ten ranked open problems, and an honesty section on the classification-status asymmetry across domains and the register hazards — written for category theorists and topos theorists who want to assess the apparatus without reading Lean source. The two documents are reciprocal: the Lean is the formal commitment, the note is the prose statement of what the Lean commits to and what is still open. Changes to formal content should ideally land in both at once.

---

## The primary target

**The music-kernel endofunctor formalization from Paper 3 § 4 (currently v9.4; § 4 unchanged since v9.1 — the v9.4 architectural-status note refines the categorical object D1–D4 produces but does not change § 4 itself).**

Full statement of the six points to formalize is in [`../validation/claims/music-kernel-umbrella.md`](../validation/claims/music-kernel-umbrella.md) and in the individual sub-claim files. A Lean formalization of the following, in order of increasing technical demand, would be substantive:

### Tier 1 — Elementary (well within mathlib4's range)

1. **Irrationality of `α = log₂(3/2)`** via FTA — **kernel-checked** in `Examples/MusicKernelIrrationality.lean` / `Examples/DiophantineFloor.lean`. See [`../validation/claims/music-kernel-01-irrationality.md`](../validation/claims/music-kernel-01-irrationality.md).

2. **`Fix(D) = {∅}` in the poset of finite subsets of `ℝ / ℤ`.** **Kernel-checked** (Points 2–3) in `Examples/MusicKernelEndofunctor.lean`. See [`../validation/claims/music-kernel-02-fixed-points.md`](../validation/claims/music-kernel-02-fixed-points.md).

3. **Optimal N-TET convergent denominators.** **Kernel-checked (all phases).** Phase 1: `qConv_first_six` in `Examples/PythagoreanComma.lean`, with certified log bounds (`MusicKernelLogBounds.lean`) and CF floor lemmas (`MusicKernelCfFloors.lean`). Phases 2–3: (C1) best-approximation-of-the-second-kind (`convergent_best_approx_second_kind`) and (C2) the strict record-holder equivalence (`best_tet_iff_record_convergent_denominator`), proved for a general irrational `ξ` in `NumberTheory/ContinuedFractionBestApprox.lean` and specialized to `α`. The mathematical content is classical (Khinchin); the contributions are the Lean formalization — (C1) appears absent from Mathlib, which carries only Legendre's converse (`Real.exists_rat_eq_convergent`), so it is a candidate for upstreaming — and the application to the Pythagorean comma. See [`../validation/claims/optimal-ntet-continued-fraction.md`](../validation/claims/optimal-ntet-continued-fraction.md).

### Tier 2 — Intermediate

3. **Lambek's lemma applied to the poset category `C`.** Lambek's lemma is in mathlib4 under `CategoryTheory.Coalgebra`. Verifying that its hypotheses are satisfied for our specific `C` and `D` (and thus concluding that `Coalg(D)` has no terminal object) is a straightforward category-theoretic exercise. See [`../validation/claims/music-kernel-03-terminal-coalgebra.md`](../validation/claims/music-kernel-03-terminal-coalgebra.md).

4. **Weyl equidistribution (or just density)** for `{n α : n ∈ ℤ}` in `ℝ / ℤ` with `α` irrational. mathlib4 has some equidistribution content; density is elementary. Conclude that the sequential colimit of `D`-iteration escapes `C`. See [`../validation/claims/music-kernel-04-colimit-escape.md`](../validation/claims/music-kernel-04-colimit-escape.md).

### Tier 3 — Advanced / requires additional mathlib development

5. **`ℤ / 12ℤ` quotient structure.** The quotient functor `Q : C → C_{12}`, the two operations `D_{12}` (accumulation) and `T_{12}` (translation), and the distinct behavior of each. See [`../validation/claims/music-kernel-05-z12z-cycle.md`](../validation/claims/music-kernel-05-z12z-cycle.md). The `H = ⟨4⟩` observation (Giant Steps substructure). Finite-group computations in mathlib4 (`ZMod 12`) make this accessible; the categorical packaging may require more setup.

6. **Baker's 1966 theorem — effective bounds.** mathlib4 does not currently have Baker's theorem formalized (verified 2026-04). The qualitative non-vanishing of `|12 · Real.log 3 − 19 · Real.log 2|` is already covered by point 1 via FTA and is a Tier 1 formalization target today. The Tier 3 target here is the **effective quantitative bound** from Baker's theorem, which requires formalizing Baker's theorem first — a multi-year mathlib project in its own right rather than a first contribution. Listed here as the long-horizon target; not recommended as a first PR. The claim file at [`../validation/claims/music-kernel-06-baker.md`](../validation/claims/music-kernel-06-baker.md) splits the target explicitly into Sub-target A (formalizable today against current mathlib4) and Sub-target B (blocked on upstream mathlib4 development), with a cartoon-hypothesis statement that makes the structural specification explicit without pretending the proof is achievable without Baker in place.

---

## What a first contribution might look like

A good first Lean PR to this repository would:

- Pick **one of Tier 1** (point 1 or 2).
- Formalize the claim using mathlib4 as a dependency.
- Include a doc-comment block at the top of the file identifying which claim is being formalized, which paper section it corresponds to, and any deviations from the paper's informal statement.
- Pass `lake build` under the `lean-toolchain` specified in this directory.
- Be submitted as a PR against `main` with a description matching the Formalization template in [`../CONTRIBUTING.md`](../CONTRIBUTING.md).

A Tier 2 or Tier 3 contribution, or a contribution that bundles multiple tiers, is equally welcome.

---

## Running locally

```
cd lean/
lake update
lake build
```

The `lakefile.lean` declares a dependency on `mathlib4`. The `lean-toolchain` file pins a specific Lean version (see that file for the current pin). Contributors are welcome to update the pin if newer Lean / mathlib4 versions have better support for the specific formalizations being attempted.

---

## Related projects

- **[mathlib4](https://leanprover-community.github.io/mathlib4_docs/)** — the primary Lean 4 mathematical library.
- **[Lean Zulip](https://leanprover.zulipchat.com/)** — the community discussion forum; the project's first outreach draft for Lean contributors is at [`../docs/outreach/lean-zulip-post.md`](../docs/outreach/lean-zulip-post.md).
- **[nLab](https://ncatlab.org/nlab/show/HomePage)** — for categorical background on Lambek, terminal coalgebras, and the kind of constructions involved here.

---

## Changelog
- 2026-06-17: Optimal N-TET Tier 1 point 3 closed — (C1) `convergent_best_approx_second_kind` and (C2) `best_tet_iff_record_convergent_denominator` kernel-checked for general irrational `ξ` in `NumberTheory/ContinuedFractionBestApprox.lean` and specialized to `α` in `PythagoreanComma.lean`; audit extended in `HeytingTypeInstance.lean` (no `sorryAx`). Mathematical content classical (Khinchin); the contribution is the formalization (C1 appears absent from Mathlib) and the Pythagorean-comma application.
- 2026-06-13: Music-kernel Tier 1 progress — `qConv_first_six` kernel-checked (`PythagoreanComma.lean`, `MusicKernelLogBounds.lean`, `MusicKernelCfFloors.lean`, `PythagoreanCommaConvergents.lean`); Points 2–3 in `MusicKernelEndofunctor.lean`; audit in `HeytingTypeInstance.lean`.
- 2026-05-20 (second pass): `refusal_residue` closed under the `Δ.HasIrregularKernel` hypothesis.  **Zero `sorry`s remain in the entire formalization tree.**  Architectural decision recorded: rather than carry the brute existential `∃ Y, kernelImage Δ Y ≠ (kernelImage Δ Y)ᶜᶜ` as an opaque assumption, the hypothesis is named after its structural content — *the kernel image escapes the regular sub-algebra of the subobject lattices at some object* — and the corresponding open conjecture (when does this follow from `NonTrivial + NonBoolean C`?) is promoted to the validation queue at [`../validation/claims/refusal-bridge.md`](../validation/claims/refusal-bridge.md).  The conjecture is non-trivial because the regulars of any Heyting algebra form a Boolean sub-algebra, so a regularly-confined non-trivial `Δ` would produce a Boolean kernel image in a non-Boolean topos — a generically available class rather than a constructed counterexample.  `#print axioms FalseWork.Positions.refusal_residue` reports the three standard Mathlib axioms only.
- 2026-05-20: Mathlib PR [#39618](https://github.com/leanprover-community/mathlib4/pull/39618) opened — `HeytingAlgebra (Subobject _)` instance for elementary topoi submitted upstream from [`FalseWorkPapers/Heyting/SubobjectInstance.lean`](FalseWorkPapers/Heyting/SubobjectInstance.lean) (refactored into `Mathlib/CategoryTheory/Subobject/Heyting.lean` with module directive, `public import`s, `@[expose] public section`, and `omit [...] in` declarations to satisfy the `unusedSectionVars` linter).  CI green at submission.  [`HEYTING-GAP.md`](HEYTING-GAP.md) status header updated to *CLOSED locally; PR opened upstream*.  Status section above ("Sketch in flight" → **Status (2026-05-20)**) and open-problem entry 2 ("`HeytingAlgebra (Subobject _)` for topoi") updated to reflect the new state.  The original "sketch quality, sorries throughout, not yet expected to `lake build` cleanly" framing — accurate as of 2026-05-09 — is preserved in the body of the *Sketch in flight* section as historical record.
- 2026-05-19: Four-position partition theorem (`four_position_partition` in [`FalseWorkPapers/Positions/Partition.lean`](FalseWorkPapers/Positions/)) kernel-checked.  Three Heyting-blocked `sorry`s closed (Phase 3, commit `75a8919`) and three image-API `sorry`s closed (Path 5, commit `60d6ef5`).  Phase 0 Decision 2 (the abstract `[∀ Y, HeytingAlgebra (Subobject Y)]` binder) explicitly superseded at [`PHASE-0-DECISIONS.md`](PHASE-0-DECISIONS.md) after the instance-diamond triage at [`HEYTING-DIAMOND.md`](HEYTING-DIAMOND.md) chose retiring the binder in favour of the in-repo universal instance.  One `sorry` remains in the entire tree: the substantive `refusal_residue` in `Refusal.lean` (framework-level, not Heyting-related; parked).
- 2026-04-19: Directory created as placeholder.
- 2026-04-19: README tightened — version reference corrected to Paper 3 § 4 (v9.1); mathlib references aligned with current naming (`UnitAddCircle`, `Real.log`, `Real.logb`); Tier 3 scope clarified (qualitative non-vanishing promoted to Tier 1 alongside irrationality; Baker Tier 3 restricted to the effective bound).
- 2026-04-19: Added Tier 1 point 3 (optimal N-TET ↔ convergent-denominator record-holders), reflecting the Henson suggestion. Pointed Tier 3 point 6 at the refined split between elementary sub-target A and Baker-blocked sub-target B. Updated Tier 1 point 1 to reference the three-forms formulation in the tightened claim file.
- 2026-05-09: Added "Sketch in flight" section documenting the first concrete sketch under `FalseWorkPapers/Positions/` — five-position theorem candidate in the topos / distinction-structure register. Sketch-quality (sorries throughout), not yet `lake build`-clean. Closure-residue construction committed for Exploitation; Commitment/Exploitation disjointness within `¬¬Im(η)` flagged as the central open problem; `HeytingAlgebra (Subobject _)` for topoi flagged as a Mathlib upstream gap. Divergence in the Exploitation predicate from the F-coalgebra register of `validation/claims/five-position-derivation-formalization.md` recorded explicitly.
- 2026-05-17: Added [`HEYTING-GAP.md`](HEYTING-GAP.md) — single-document upstream-dependency record for the Mathlib `HeytingAlgebra (Subobject _)` gap. Documents the gap state (verified 2026-05), CwFTT scaffold state (Edward van de Meent's scratch project), the six Heyting-gated `sorry`s in our tree, the four options (active collaboration / local port / sorry-state-and-cite / axiomatic), the current posture (sorry-state-and-cite, gated on Tier 2 trajectory work completing), threshold conditions for upgrading to active collaboration, and the community engagement record (Zulip thread + Edward's three related Mathlib PRs in flight). Open-problem entry 2 in this README now points there.
- 2026-05-10: Architectural reframe — five positions → four-position partition + Commitment gate. Commitment is no longer a fifth lattice cell but a binary fixedness condition within each of the four cells; the previously-named central open problem of Commitment/Exploitation disjointness within `¬¬Im(η)` *dissolved* (Commitment is not a separate cell), replaced by four independent per-cell restricted-iteration characterization problems. Added `FalseWorkPapers/Positions/MomentRelative.lean` recording the 2026-05-10 two-parameter unification test: negative on theorem-grade unification (the four predicates are propositional-shape-distinct Heyting conditions), positive on schema-level uniformity (uniform moment-relative kernel image, uniform Heyting register, uniform gate shape). Closes the unification question. README's "Sketch in flight" section rewritten around the new architecture; remaining files (`Commitment.lean`, `Positions.lean`, etc.) carry the prior sketches with cross-references to the reframe. Architectural canonical statement lives at `papers/comma-formal-structure-note.md` (revised 2026-05-10); validation status at `validation/claims/five-position-derivation-formalization.md` v0.4.
