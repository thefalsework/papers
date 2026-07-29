# The Opened Square: Aristotle, Spencer-Brown, and the Kernel-Checked Foundation of the Four-Position Lens

- **Paper:** [`paper.md`](paper.md) (authoritative source; markdown only for now).
- **Status:** unification spine, July 2026. Not an arXiv target in its current
  form — it is the front door that strings the program's formal results into
  one chain; a LaTeX version follows only if a submission venue materializes.
- **Lean formalization:** the two new files are
  [`../../lean/FalseWorkPapers/Positions/OrdinaryKernel.lean`](../../lean/FalseWorkPapers/Positions/OrdinaryKernel.lean)
  (the bridge theorem: partition non-degeneracy = ordinary kernel) and
  [`../../lean/FalseWorkPapers/Examples/OppositionFigure.lean`](../../lean/FalseWorkPapers/Examples/OppositionFigure.lean)
  (the figure law T1, the collapse laws, the skeleton theorem, the Blanché
  refutation T2). Theorem-by-theorem audit table in §10 of the paper.

## What it claims

That the chain

> distinction drawn → ambient logic non-Boolean → four positions forced →
> non-degeneracy = ordinariness → six landmarks = the opened square = Z₆

is kernel-checked end to end, and that the interpretive glosses riding on it
are explicitly graded (**[A]**), never silently promoted. Claim discipline for
the historical layer: **first kernel-checked**, never "first" — the informal
intuitionistic-square literature (Béziau; the 2012 Birkhäuser volume;
Demey–Smessaert logical geometry) is the acknowledged precedent.

## Human-review items (open)

- The `BlancheHexagon` cover table against Blanché (1966) — same
  statement-matches-source discipline as `Challenge.lean` (flagged in the Lean
  docstring).
- The two 2012 Birkhäuser chapters on the intuitionistic square, to confirm
  neither states the ordinariness equivalence informally (gates any outreach
  that leans on novelty).

## Provenance

AI-authored (Claude, in Cursor) under the direction and review of Chris Brink.
See [`../../formalization.yaml`](../../formalization.yaml).
