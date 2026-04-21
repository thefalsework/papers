# Lean 4 formalization — placeholder

This directory is a deliberate placeholder. It exists from day one of the repository to signal that a Lean 4 formalization of the paper series' mathematical claims is a first-class target of the project, and to give any Lean contributor a single, well-defined place to propose work.

At this moment the directory contains:
- This README describing the formalization target.
- A skeletal `lakefile.lean` and `lean-toolchain` so a contributor can clone, `lake update`, and begin work without friction.
- No actual proofs yet.

This README serves as the authoritative specification of what a Lean formalization of this project would cover. Contributions — partial or complete, bounded or ambitious — are warmly welcomed.

---

## The primary target

**The music-kernel endofunctor formalization from Paper 3 § 4 (v9.1).**

Full statement of the six points to formalize is in [`../validation/claims/music-kernel-umbrella.md`](../validation/claims/music-kernel-umbrella.md) and in the individual sub-claim files. A Lean formalization of the following, in order of increasing technical demand, would be substantive:

### Tier 1 — Elementary (well within mathlib4's range)

1. **Irrationality of `α = log₂(3/2)`** via FTA. mathlib4 has `Irrational`, `Real.log`, and `Real.logb`, so the statement `Irrational (Real.logb 2 (3/2))` should be expressible in ~20–50 lines. The same FTA argument gives the qualitative non-vanishing of `|12 · Real.log 3 − 19 · Real.log 2|` (the Pythagorean-comma case as a linear-form-in-logarithms statement), which is logically the same claim restated. See [`../validation/claims/music-kernel-01-irrationality.md`](../validation/claims/music-kernel-01-irrationality.md).

2. **`Fix(D) = {∅}` in the poset of finite subsets of `ℝ / ℤ`.** mathlib4 has `UnitAddCircle` (= `AddCircle (1 : ℝ)`, equivalent to `ℝ / ℤ`) and the standard `Finset` / `Set` machinery. A Lean proof of "no non-empty finite subset of `UnitAddCircle` is invariant under translation by an irrational element" should be moderate (~100 lines), with the cardinality argument as the core step. See [`../validation/claims/music-kernel-02-fixed-points.md`](../validation/claims/music-kernel-02-fixed-points.md).

### Tier 2 — Intermediate

3. **Lambek's lemma applied to the poset category `C`.** Lambek's lemma is in mathlib4 under `CategoryTheory.Coalgebra`. Verifying that its hypotheses are satisfied for our specific `C` and `D` (and thus concluding that `Coalg(D)` has no terminal object) is a straightforward category-theoretic exercise. See [`../validation/claims/music-kernel-03-terminal-coalgebra.md`](../validation/claims/music-kernel-03-terminal-coalgebra.md).

4. **Weyl equidistribution (or just density)** for `{n α : n ∈ ℤ}` in `ℝ / ℤ` with `α` irrational. mathlib4 has some equidistribution content; density is elementary. Conclude that the sequential colimit of `D`-iteration escapes `C`. See [`../validation/claims/music-kernel-04-colimit-escape.md`](../validation/claims/music-kernel-04-colimit-escape.md).

### Tier 3 — Advanced / requires additional mathlib development

5. **`ℤ / 12ℤ` quotient structure.** The quotient functor `Q : C → C_{12}`, the two operations `D_{12}` (accumulation) and `T_{12}` (translation), and the distinct behavior of each. See [`../validation/claims/music-kernel-05-z12z-cycle.md`](../validation/claims/music-kernel-05-z12z-cycle.md). The `H = ⟨4⟩` observation (Giant Steps substructure). Finite-group computations in mathlib4 (`ZMod 12`) make this accessible; the categorical packaging may require more setup.

6. **Baker's 1966 theorem — effective bounds.** mathlib4 does not currently have Baker's theorem formalized. The qualitative non-vanishing of `|12 · Real.log 3 − 19 · Real.log 2|` is already covered by point 1 via FTA. The Tier 3 target here is the **effective quantitative bound** from Baker's theorem, which requires formalizing Baker's theorem first — a multi-year mathlib project in its own right rather than a first contribution. Listed here as the long-horizon target; not recommended as a first PR. See [`../validation/claims/music-kernel-06-baker.md`](../validation/claims/music-kernel-06-baker.md).

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
