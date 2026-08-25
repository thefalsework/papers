# Study 10 — Aperture on Cellular Automaton Causal Graphs

The aperture instrument (proved on divisor lattices [K], measured on Mathlib
[computed]) applied to the counterfactual causal structure of Conway's Life.
The precondition question: does the invariant distinguish structured from
unstructured computational history at all?

## Protocol documents, in order

- **`PREREGISTRATION-v1.0.md`** — the original protocol (2026-08-24),
  **never executed**: its syntactic edge relation is state-independent, so
  all non-trivial conditions produce isomorphic cones. The a priori proof is
  its dated postscript. Kept for the record: a dead protocol caught by
  inspection, not by a wasted run.
- **`PREREGISTRATION-v1.1.md`** — the operative protocol (2026-08-25),
  committed before any run: counterfactual edges (single-flip dependence),
  order = transitive closure (with the non-transitivity caveat stated),
  census-before-budget, all parameters and RNG seeds pinned.
- **`seeds.json`** — every seed, grid, and RNG constant.

## Scripts, in run order (Node ≥ 18, no packages; run from this directory)

1. **`01-anchors.mjs`** — must pass before any Life cone: Div12/Div36
   kernel-checked anchor values, closed-form agreement, chain negatives,
   and the v1.0 pyramid as a documented negative anchor.
2. **`02-cone-census.mjs`** — cone sizes at every depth for every seed;
   fixes each cone's exhaustive-tier depth (n ≤ 18). Writes
   `results/census.json`.
3. **`03-aperture-study.mjs`** — the study: full 2^n observer census per
   kernel per cone; evaluates P1, P2, P4, P5. Writes
   `results/study-raw.json`. (`--sampled` adds the secondary tier.)
4. **`04-nulls.mjs`** — N1 (100 degree-preserving rewirings) and N2 (20
   random totalistic rules) on the five primary cones; evaluates P3.
   Writes `results/nulls.json`.

`ca-lib.mjs` is the shared engine; its world-verdict code reproduces
`mathlib-study/02-subspace-nuclei.mjs` (shared-bug risk logged, v1.1 §9).

## Second implementation

`wl/ca-aperture.wl` — independent Wolfram Language implementation (single
cloud cell): anchors plus per-kernel apertures of the five primary cones.
Must agree exactly with the Node reference; any mismatch stops the study.

## Results

Three protocol versions, one day (2026-08-25), all in `RESULTS.md`:

- **v1.0** died by inspection before any run (state-independent edges).
- **v1.1** executed; P1 failed by artifact — its depth policy forced 21 of
  29 cones into depth-1 fans, which are provably aperture-blind.
- **v1.2** (depth-matched d = 2, calibrated mixed estimator, scripts
  05–07) executed clean: **P1′ fails as a real measurement** — pooled
  coherent patterns vs soup do not differ (p = 0.263) — while **P6′ holds**
  (still-life cones ~17× wider than soup, p = 0.044, size entanglement
  recorded), latency is generic (67–94% of kernels in every non-trivial
  cone), and the Mathlib narrowness does **not** transfer (real cones sit
  inside their degree-matched null distributions).

Raw per-kernel output under `results/`; session log in
`wolfram/next-session.md`. Named follow-up (new registration required):
size-controlled figure-vs-ground comparison. Pending: WL cloud
confirmation of the primary cones (`wl/ca-aperture.wl`).
