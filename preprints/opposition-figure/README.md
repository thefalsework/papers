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
intuitionistic-square literature (Béziau; Mélès 2012; Vidal-Rosset 2017;
Demey–Smessaert logical geometry) is the acknowledged precedent.

## Review record (2026-07-29, AI web-research under direction)

Both formerly-open review items were closed as far as accessible sources
allow; details in §9 of the paper and the Lean docstring.

- **`BlancheHexagon` cover table:** matches three independent specialist
  descriptions of Blanché's hexagon (Béziau, "The metalogical hexagon of
  opposition," *Argumentos* 2013, citing Blanché 1966 directly;
  Dubois–Prade–Rico 2015; standard references) — all six entailment edges,
  both incomparability triangles, all three contradictory pairs. *Residual:*
  the 1966 French primary text was not consulted (no accessible copy).
- **The intuitionistic-square chapters:** a records correction first — only
  one such chapter is in the 2012 volume (Mélès, "No Group of Opposition for
  Constructive Logics," pp. 201–217, group-theoretic); the other is in the
  2017 volume *The Square of Opposition: A Cornerstone of Thought*
  (Vidal-Rosset, "The Exact Intuitionistic Meaning of the Square of
  Opposition," pp. 291–303, prover-driven). Neither works at the
  algebra-element level or states the ordinariness equivalence; targeted
  searches for square + Rieger–Nishimura and square + regular/dense elements
  also came back empty. *Residual:* full chapter texts are paywalled; the
  review rests on abstracts, the authors' own congress summaries, and citing
  literature, all concordant.

## Provenance

AI-authored (Claude, in Cursor) under the direction and review of Chris Brink.
See [`../../formalization.yaml`](../../formalization.yaml).
