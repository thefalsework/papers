# Accretion study

**Question.** Which graph growth rules force which growth signatures
(E-vs-R, E-vs-D at matched battery)? Run the program's own Debian-grade
estimator on synthetic universes grown from known rules — partly to map
the generative landscape, partly as the instrument's own audit: on a
rule that is provably blind to the cells, the estimator had better say
nothing.

**What happened, in order.**

1. **Phase A feasibility** (`01-explore.mjs`): the first synthetic
   universes were degenerate — with dependency count m drawn from
   {1..4}, node 0 is a universal ancestor, Refusal is empty for every
   kernel, nothing is evaluable. Fixed by allowing m = 0 (root nodes,
   as in every real corpus) and by making PC's platform choice uniform
   rather than popularity-weighted (which had recreated the universal
   ancestor through primordial hubs). Both fixes documented in
   `SPEC.md`'s first postscript and `sim-lib.mjs` comments.
2. **The audit finding** (`01b-calibrate.mjs`, `01c-validate-clustered-null.mjs`):
   replicate-universe calibration showed the point estimator is
   *unbiased* on null generators, but the within-corpus sign-flip null
   — the machinery behind every "percentile" in the program's field
   studies — understates true across-universe variance ≈ 10×, and
   kernel-clustered flips do not repair it (the dependence is
   universe-level). Consequences for the field results are spelled out
   in `SPEC.md` postscript 1 §4 and in dated postscripts across the
   briefs and the synthesis paper: single-corpus percentiles are
   conditional statements; generator-level warrant comes only from
   cross-corpus replication and sealed out-of-sample bets.
3. **Phase B′ confirmation** (`02-confirm.mjs`, registered before its
   one run, fresh seeds): **all three registered verdicts landed.**
   B1 CONFIRMS-NULL — U and PA read zero on both contrasts (|t| ≤ 1.8,
   20 universes each). B2 CONFIRMS — PC(0) forces **R > E > D** at
   matched battery, t_ER = −10.2 (0/20 positive), t_ED = +10.8 (20/20
   positive). B3 (descriptive β gradient): R-over-E fades smoothly with
   footprint breadth; E-over-D is flat positive through β = 0.75 and
   dead at β = 1 — the two contrasts decouple from a single dial,
   reproducing the field's dissociation of the two axes.
4. **Phase C theory** (`THEORY.md`): exact unbiasedness proof for U,
   exchangeability argument for PA, the two-level analysis of the
   sign-flip failure, and the **PC flux law**: expected gain under
   cone-local accretion tracks truncated up-set size (transitive
   dependents), a quantity absent from the matching battery — the
   constructive explanation of how a cell can legitimately out-inform
   the reviewer's arsenal. The sign of the PC(0) effect is stated open,
   with a registered next measurable.

**What this study does *not* say.** PC produces the inverse of the
Go/Debian field ordering (R > E, not E > R), so no rule in this family
models package-ecosystem growth. The open generative question: which
rule families force E > R.

**Queued methods improvement ("battery v2").** Per the flux law, add
truncated transitive-dependent count to the field matching battery and
re-run Go/Debian: if E-over-R survives, the claim strengthens
materially; if it dissolves, that's the third artifact caught in-house.

**Files.**
- `SPEC.md` — registered spec + two dated postscripts (audit; B′/C).
- `sim-lib.mjs` — growers (U, PA, PC(β)) + the shared Debian-grade estimator.
- `01-explore.mjs` / `results-explore.json` — exploratory grid (single-universe; superseded by replicate designs).
- `01b-calibrate.mjs` / `results-calibrate.json` — the replicate calibration that found the null failure.
- `01c-validate-clustered-null.mjs` — kernel-clustered flips tested and found insufficient.
- `02-confirm.mjs` / `results-confirm.json` — registered Phase B′; verdicts in the postscript.
- `THEORY.md` — Phase C.
