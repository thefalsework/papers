# Examples

Concrete instantiations of the four-position partition theorem ([`../paper.md`](../paper.md)).

## Current contents

- [`construction-choice.md`](construction-choice.md) — Phase 1.1 analysis: surveys candidate constructions and establishes that the Sierpinski topos is too small to host a non-vacuous four-cell partition. Classifies the five Lawvere-Tierney topologies on Set^→ and identifies the reflective-subcategory / idempotent-monad interpretation of distinction structures. Closes with a revised Phase 1.2 plan (escalate to a richer base topos).
- [`phase-1-2-progress.md`](phase-1-2-progress.md) — Phase 1.2 partial progress: constructs a 4-element M-set X on the 3-element idempotent monoid M = {1, e, f} whose subobject lattice Sub(X) is a 6-element non-Boolean Heyting algebra with a non-regular middle element. Verifies by hand that all four cells of the partition theorem would be inhabited at this lattice-level configuration. Documents the remaining obstruction (constructing a distinction structure (D, η, ι) producing the right kernel image) and three forward paths.

## Roadmap

This subdirectory implements the Tier 1 work plan: build the simplest concrete elementary topos with a non-trivial distinction structure such that all four cells of the partition theorem are inhabited. The goal is to demonstrate that the partition theorem is not vacuous and to provide a worked example readers can verify in detail.

**Status.** Phase 1.1 (construction-choice analysis) is complete. Two findings have been absorbed into the main paper as Remarks 5.4 and 5.5. Phase 1.2 is *partially* complete: the lattice-level four-cell inhabitability has been verified by hand on a concrete M-set in M-Set, but the full distinction-structure construction is blocked by a structural obstruction (standard reflections produce epi units, forcing the kernel image to be ⊤). Three forward paths for completing Phase 1.2 are documented in [`phase-1-2-progress.md`](phase-1-2-progress.md); none has been pursued past the obstruction-identification stage.

**Forthcoming files (Phase 1.2 completion onward):**

- `non-vacuity-witness.md` (or analogous, depending on which forward path closes the construction) — math-prose companion describing the verified witness once one of Paths A/B/C lands.
- Lean source: `../../../lean/FalseWorkPapers/Positions/Examples/` — mechanized verification of the construction.

Once Phase 1.2 is verified-complete, the main paper [`../paper.md`](../paper.md) will receive a §5.6 ("Demonstration") forward-referencing this directory.
