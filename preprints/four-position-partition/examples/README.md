# Examples

Concrete instantiations of the four-position partition theorem ([`../paper.md`](../paper.md)).

## Current contents

- [`construction-choice.md`](construction-choice.md) — Phase 1.1 analysis: surveys candidate constructions and establishes that the Sierpinski topos is too small to host a non-vacuous four-cell partition. Classifies the five Lawvere-Tierney topologies on Set^→ and identifies the reflective-subcategory / idempotent-monad interpretation of distinction structures. Closes with a revised Phase 1.2 plan (escalate to a richer base topos).

## Roadmap

This subdirectory implements the Tier 1 work plan: build the simplest concrete elementary topos with a non-trivial distinction structure such that all four cells of the partition theorem are inhabited. The goal is to demonstrate that the partition theorem is not vacuous and to provide a worked example readers can verify in detail.

**Status.** Phase 1.1 (construction-choice analysis) is complete. Two findings have been absorbed into the main paper as Remarks 5.4 and 5.5. Phase 1.2 (explicit construction in a richer base topos + Lean mechanization) is the next work block; the revised Phase 1.2 plan and its 4–8 week estimate are documented in [`construction-choice.md`](construction-choice.md).

**Forthcoming files (Phase 1.2 onward):**

- `non-vacuity-witness.md` (or analogous, depending on construction) — math-prose companion describing the explicit witness construction in the chosen richer base topos.
- Lean source: `../../../lean/FalseWorkPapers/Positions/Examples/` — mechanized verification of the construction.

Once Phase 1.2 lands, the main paper [`../paper.md`](../paper.md) will receive a §5.6 ("Demonstration") forward-referencing this directory.
