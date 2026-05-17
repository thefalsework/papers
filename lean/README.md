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

**Status.** Sketch quality. Most theorems carry `sorry`. Not yet expected to `lake build` cleanly. The point of the sketch is to make the formal shape visible, identify upstream Mathlib gaps, and localize each open framework decision to a specific file with documented candidates.

**Files.**
- [`FalseWorkPapers/Positions.lean`](FalseWorkPapers/Positions.lean) — index file; partition-theorem statement; ranked open questions; gate schema summary; two-parameter-unification closure summary.
- [`FalseWorkPapers/Positions/Setup.lean`](FalseWorkPapers/Positions/) — `DistinctionStructure` (idempotent endofunctor `D` with marking unit `η` and Spencer-Brown coherence), `NonTrivial` predicate, `kernelImage` subobject. Documents the upstream Mathlib gap.
- [`FalseWorkPapers/Positions/Infrastructure.lean`](FalseWorkPapers/Positions/) — `IsInfrastructure` as image-subobject condition `img ≤ kernelImage` (revised 2026-05-17 from the earlier endpoint-iso predicate, which would have left an exhaustiveness hole in the four-position partition). The retired endpoint-iso predicate survives as the sufficient sub-condition `Trivialized`; the pointwise-`D` signature lemma re-attaches to `Trivialized`. Deep Infrastructure level-stratified sketch unchanged.
- [`FalseWorkPapers/Positions/Distribution.lean`](FalseWorkPapers/Positions/) — `IsDistribution` as image straddling `Im(η)` and `¬Im(η)`.
- [`FalseWorkPapers/Positions/Exploitation.lean`](FalseWorkPapers/Positions/) — **closure-residue construction committed.** `IsExploitation Δ f` defined as `img(D.map f) ≤ ¬¬Im(η) ∧ ¬(img ≤ Im(η))`, at the level of generalized elements. Two signature theorems (non-Boolean dependence; Heyting disjointness from Refusal). A third theorem distinguishing Exploitation from Commitment was drafted as a "transverse-vs-pole" claim and *withdrawn* on 2026-05-09; the underlying problem subsequently *dissolved* on 2026-05-10 when Commitment was reframed as a gate within each cell rather than a fifth cell.
- [`FalseWorkPapers/Positions/Refusal.lean`](FalseWorkPapers/Positions/) — `IsRefusal` as factoring through `(Im(η))ᶜ`. `refusal_residue` theorem stated: in non-Boolean topoi, `Im(η) < ¬¬Im(η)` strictly.
- [`FalseWorkPapers/Positions/Partition.lean`](FalseWorkPapers/Positions/) — **the four-position partition theorem (Theorem 0).** Full statement of exactly-one-cell claim plus pairwise disjointness, with proof structure documented and `sorry` carrying the case-split. Imports the four cell files and assumes the Mathlib `[HeytingAlgebra (Subobject _)]` instance. Helper lemma `isRefusal_iff_image_le_compl` re-characterises Refusal in image-subobject form (separate `sorry`).
- [`FalseWorkPapers/Positions/Commitment.lean`](FalseWorkPapers/Positions/) — pre-reframe sketch of `IsCommitment` as colimit of iterated `D`-application. The Spencer-Brown idempotency-collapse problem remains; under the 2026-05-10 reframe, this file describes one of the four cell-restricted iterations (the schema-uniform shape) rather than a fifth lattice cell. Continuous-iteration refinement still flagged.
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
2. **`HeytingAlgebra (Subobject _)` for topoi** — Mathlib upstream gap (verified 2026-05). Currently parameterized in as a local hypothesis. ~200–400 lines following Mac Lane–Moerdijk IV.8 would unblock Refusal, Distribution, and Exploitation simultaneously. *This is the cleanest upstream-PR target.*
3. **Continuous iteration of `D`** — needed for the per-cell restricted iterations. Three resolutions documented (relax idempotency, parameterize over interval object, enriched setting).
4. **Hypothesis on `Δ`** to make `refusal_residue` provable.
5. **Level structure** for Deep Infrastructure (Kurosawa case).
6. **Balance condition** for Distribution.
7. **Categorical specification of `Moment`.** Moment-relativization is currently a working hypothesis (filtered preorder + monotone boundary-state). Whether `Moment` should be a derived construct is open.

**Relation to the validation claim.** The corresponding claim file at [`../validation/claims/five-position-derivation-formalization.md`](../validation/claims/five-position-derivation-formalization.md) (currently v0.4) defines the schema in the **F-coalgebra-with-comma-subcategory `L`** register. The Lean sketch uses a different but related register — the **distinction-structure** register with `D : C ⥤ C` and `η : 𝟭 ⟶ D`. The two are translatable but not identical. In one specific place — the **Exploitation** predicate — the Lean's closure-residue construction `img(D.map f) ≤ ¬¬Im(η) ∧ ¬(img ≤ Im(η))` is a tighter and *different* condition from the claim's "α factors through `L ↪ C`" predicate. The validation claim's v0.3 / v0.4 changelog records this divergence and (v0.4) records the two-parameter unification closure and the Commitment-as-gate reframe.

**Expository companion.** [`../papers/comma-formal-structure-note.md`](../papers/comma-formal-structure-note.md) is the prose-and-context companion to this Lean sketch. It carries the four-position-partition + Commitment-gate architecture, the closure-residue construction, the four cell predicates, the three signature theorems committed at this stage, the four-claims-with-four-statuses honesty table, the ten ranked open problems, and an honesty section on the classification-status asymmetry across domains and the register hazards — written for category theorists and topos theorists who want to assess the apparatus without reading Lean source. The two documents are reciprocal: the Lean is the formal commitment, the note is the prose statement of what the Lean commits to and what is still open. Changes to formal content should ideally land in both at once.

---

## The primary target

**The music-kernel endofunctor formalization from Paper 3 § 4 (currently v9.4; § 4 unchanged since v9.1 — the v9.4 architectural-status note refines the categorical object D1–D4 produces but does not change § 4 itself).**

Full statement of the six points to formalize is in [`../validation/claims/music-kernel-umbrella.md`](../validation/claims/music-kernel-umbrella.md) and in the individual sub-claim files. A Lean formalization of the following, in order of increasing technical demand, would be substantive:

### Tier 1 — Elementary (well within mathlib4's range)

1. **Irrationality of `α = log₂(3/2)`** via FTA. mathlib4 has `Irrational` (in `Mathlib.NumberTheory.Real.Irrational`), `Real.log`, and `Real.logb`, so the statement `Irrational (Real.logb 2 (3/2))` should be expressible in ~20–50 lines. The same FTA argument gives the qualitative non-vanishing of `|12 · Real.log 3 − 19 · Real.log 2|` (the Pythagorean-comma case as a linear-form-in-logarithms statement), which is logically the same claim restated. See [`../validation/claims/music-kernel-01-irrationality.md`](../validation/claims/music-kernel-01-irrationality.md), which carries three equivalent Lean 4 formulations (Form A: `Irrational (Real.logb 2 (3/2))`; Form B: `Irrational (Real.logb 2 3)`; Form C: the `Real.log` linear-form non-vanishing) and four statement-level questions a validator is invited to answer before a proof is attempted.

2. **`Fix(D) = {∅}` in the poset of finite subsets of `ℝ / ℤ`.** mathlib4 has `UnitAddCircle` (= `AddCircle (1 : ℝ)`, equivalent to `ℝ / ℤ`) and the standard `Finset` / `Set` machinery. A Lean proof of "no non-empty finite subset of `UnitAddCircle` is invariant under translation by an irrational element" should be moderate (~100 lines), with the cardinality argument as the core step. See [`../validation/claims/music-kernel-02-fixed-points.md`](../validation/claims/music-kernel-02-fixed-points.md).

3. **Optimal N-TET as strict record-holders in the convergent-denominator sequence of `α`** (the Henson target). The claim formalized in [`../validation/claims/optimal-ntet-continued-fraction.md`](../validation/claims/optimal-ntet-continued-fraction.md) binds to `Real.convergent : ℝ → ℕ → ℚ` from `Mathlib.NumberTheory.DiophantineApproximation.Basic`. Two theorem statements are given — (C1) best-approximation-of-the-second-kind for the convergents of `α`, and (C2) the equivalence between strict-best-so-far Pythagorean temperaments and convergent-denominator record-holders. mathlib has the Legendre-direction (`Real.exists_rat_eq_convergent`) and the error bounds (`GenContFract.abs_sub_convs_le`); (C1) is classical but does not appear to be named in current mathlib and would need a small lemma. (C2) follows from (C1) plus standard lore about strict best-so-far sequences. Four statement-level questions for a validator are enumerated in the claim file.

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
- 2026-04-19: Directory created as placeholder.
- 2026-04-19: README tightened — version reference corrected to Paper 3 § 4 (v9.1); mathlib references aligned with current naming (`UnitAddCircle`, `Real.log`, `Real.logb`); Tier 3 scope clarified (qualitative non-vanishing promoted to Tier 1 alongside irrationality; Baker Tier 3 restricted to the effective bound).
- 2026-04-19: Added Tier 1 point 3 (optimal N-TET ↔ convergent-denominator record-holders), reflecting the Henson suggestion. Pointed Tier 3 point 6 at the refined split between elementary sub-target A and Baker-blocked sub-target B. Updated Tier 1 point 1 to reference the three-forms formulation in the tightened claim file.
- 2026-05-09: Added "Sketch in flight" section documenting the first concrete sketch under `FalseWorkPapers/Positions/` — five-position theorem candidate in the topos / distinction-structure register. Sketch-quality (sorries throughout), not yet `lake build`-clean. Closure-residue construction committed for Exploitation; Commitment/Exploitation disjointness within `¬¬Im(η)` flagged as the central open problem; `HeytingAlgebra (Subobject _)` for topoi flagged as a Mathlib upstream gap. Divergence in the Exploitation predicate from the F-coalgebra register of `validation/claims/five-position-derivation-formalization.md` recorded explicitly.
- 2026-05-10: Architectural reframe — five positions → four-position partition + Commitment gate. Commitment is no longer a fifth lattice cell but a binary fixedness condition within each of the four cells; the previously-named central open problem of Commitment/Exploitation disjointness within `¬¬Im(η)` *dissolved* (Commitment is not a separate cell), replaced by four independent per-cell restricted-iteration characterization problems. Added `FalseWorkPapers/Positions/MomentRelative.lean` recording the 2026-05-10 two-parameter unification test: negative on theorem-grade unification (the four predicates are propositional-shape-distinct Heyting conditions), positive on schema-level uniformity (uniform moment-relative kernel image, uniform Heyting register, uniform gate shape). Closes the unification question. README's "Sketch in flight" section rewritten around the new architecture; remaining files (`Commitment.lean`, `Positions.lean`, etc.) carry the prior sketches with cross-references to the reframe. Architectural canonical statement lives at `papers/comma-formal-structure-note.md` (revised 2026-05-10); validation status at `validation/claims/five-position-derivation-formalization.md` v0.4.
