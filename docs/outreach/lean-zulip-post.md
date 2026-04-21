# Outreach draft — Lean Zulip introduction post

**Purpose.** Introduce the formalization targets to the Lean community on Zulip and invite collaboration.
**Target channel.** `#mathlib4 > general` or `#new members`; may also post in `#maths > category theory` for tier-2/3 points.
**Length target.** ≤ 300 words; link-heavy rather than prose-heavy.
**Tone.** Technical, specific, non-imposing; match Zulip community norms.
**Related:** [`../../lean/README.md`](../../lean/README.md), [`../../validation/claims/music-kernel-umbrella.md`](../../validation/claims/music-kernel-umbrella.md).

---

## Subject line

> Formalization opportunity: small endofunctor-on-poset theorems motivated by music theory and Pythagorean comma

## Post body

Hi all — I am the maintainer of [thefalsework/papers](https://github.com/thefalsework/papers), an open-source research programme on structural incompleteness across domains (CC-BY-4.0, 5 papers, ongoing). The programme has a well-defined Lean 4 formalization target that I think would suit someone looking for a small-to-medium project with mathlib4.

The primary target is the music-kernel endofunctor formalization from Paper 3 § 4. Concretely, six elementary mathematical claims:

- **Tier 1** (each ~50–100 lines, mathlib has everything needed):
  - Irrationality of `log₂(3/2)` via FTA.
  - `Fix(D) = {∅}` for `D(X) = X ∪ (X + α)` on `Finset (ℝ / ℤ)`, by cardinality.
- **Tier 2** (mathlib has the frameworks; glue required):
  - Lambek's lemma applied to this specific `C` and `D` ⇒ no terminal coalgebra for `D`.
  - Weyl equidistribution (or just density) ⇒ colimit of `D`-iteration escapes the ambient category.
- **Tier 3** (Baker's theorem is not yet in mathlib, so a qualitative version for now):
  - `ℤ / 12ℤ` quotient structure and the musical `H = ⟨4⟩` (Giant Steps) substructure.
  - Non-vanishing of `|12 log 3 − 19 log 2|` via FTA (qualitative Pythagorean comma).

Full specifications with paper cross-references:

- **Claim statements:** [validation/claims/music-kernel-*.md](https://github.com/thefalsework/papers/tree/main/validation/claims)
- **Formalization target README:** [lean/README.md](https://github.com/thefalsework/papers/blob/main/lean/README.md)

A first contribution picking any one Tier 1 point would be very welcome. I am happy to discuss approaches, review early drafts, and credit contributors by name in the corresponding paper's revision note. The repo has a CONTRIBUTING.md with acceptance criteria for formalization PRs.

The broader theoretical framing is not a prerequisite — the six points stand on their own as elementary mathematics. Questions about the framing are also welcome; the repo is the best place for them.

Happy to answer anything here.

— Chris Brink / [@ChrisBrink](https://github.com/node0000)  (`chris@falsework.dev`)

---

## Posting log

| Date | Channel / topic | Permalink | Notes |
|---|---|---|---|
| 2026-04-19 | `#new members` > *Music-kernel + Pythagorean comma formalization target* | [link](https://leanprover.zulipchat.com/#narrow/channel/113489-new-members/topic/Music-kernel.20.2B.20Pythagorean.20comma.20formalization.20target/near/588730901) | Initial post. Bare-URL variant (no `[text](url)` markdown). Awaiting response. |
