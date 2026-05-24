# Examples

Concrete instantiations of the four-position partition theorem ([`../paper.md`](../paper.md)).

## Current contents

- [`construction-choice.md`](construction-choice.md) — Phase 1.1 analysis: survey of candidate constructions for a four-cell non-vacuity demonstration, with the provisional recommendation to pursue a sheafification-style distinction structure in Phase 1.2.

## Roadmap

This subdirectory implements the Tier 1 work plan: build the simplest concrete elementary topos with a non-trivial distinction structure such that all four cells of the partition theorem are inhabited. The goal is to demonstrate that the partition theorem is not vacuous and to provide a worked example readers can verify in detail.

Forthcoming files (Phase 1.2 onward):

- `sierpinski-sheaf.md` (or analogous, depending on construction) — math-prose companion describing the explicit witness construction.
- Lean source: `../../../lean/FalseWorkPapers/Positions/Examples/` — mechanized verification of the construction.

Once Phase 1.2 lands, the main paper [`../paper.md`](../paper.md) will receive a §5.5 ("Demonstration") forward-referencing this directory.
