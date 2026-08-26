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
- **`PREREGISTRATION-v1.2.md`** — depth-matched redesign (d = 2 everywhere,
  calibrated mixed estimator), committed with its passing calibration
  before execution.
- **`PREREGISTRATION-v1.3.md`** — the size-controlled follow-up to v1.2's
  P6′, committed with its sizes-only pre-check before execution.
- **`seeds.json`** — every v1.1 seed, grid, and RNG constant.
  **`seeds-v13.json`** — the four v1.3 still lifes and v1.3 RNG constants.

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
5. **`05-sampling-calibration.mjs`** / **`06-depthmatched-study.mjs`** /
   **`07-depthmatched-nulls.mjs`** — the v1.2 pipeline (calibration gate,
   depth-matched study, estimator-matched nulls). Write
   `results/study-v12.json`, `results/nulls-v12.json`.
6. **`08-sizematch-precheck.mjs`** — v1.3 structural pre-check, **sizes and
   quiescence classes only, no apertures** (keeps the registration blind).
   Writes `results/sizematch-precheck.json`.
7. **`09-sizematch-study.mjs`** — the v1.3 size-controlled study (strata
   n = 9/16/23, stratified permutation test, quiescence disambiguation).
   Writes `results/sizematch-v13.json`.

`ca-lib.mjs` is the shared engine; its world-verdict code reproduces
`mathlib-study/02-subspace-nuclei.mjs` (shared-bug risk logged, v1.1 §9).

## Second implementation

`wl/ca-aperture.wl` — independent Wolfram Language implementation (single
cloud cell): anchors, per-kernel apertures of the five primary cones, and
the v1.3 exact-tier still lifes. Reference values in `wl/EXPECTED.md`.
**Confirmed 2026-08-26 in Wolfram Cloud: exact agreement on every line**
(see the confirmation section of `RESULTS.md`). The sampled tier (n ≥ 19)
remains single-implementation.

## Results

Four protocol versions, two days (2026-08-24/25), all in `RESULTS.md`:

- **v1.0** died by inspection before any run (state-independent edges).
- **v1.1** executed; P1 failed by artifact — its depth policy forced 21 of
  29 cones into depth-1 fans, which are provably aperture-blind.
- **v1.2** (depth-matched d = 2, calibrated mixed estimator, scripts
  05–07) executed clean: **P1′ fails as a real measurement** — pooled
  coherent patterns vs soup do not differ (p = 0.263) — while P6′ held
  provisionally (still-life cones ~17× wider than soup, p = 0.044, size
  entanglement recorded), latency is generic (67–94% of kernels in every
  non-trivial cone), and the Mathlib narrowness does **not** transfer
  (real cones sit inside their degree-matched null distributions).
- **v1.3** (size-controlled, scripts 08–09) killed P6′: at matched cone
  size, still lifes and soup are indistinguishable (P7 p = 0.364; every
  n = 9 cone in the study is one structural class), and quiescence carries
  nothing (S1 p = 1.0). **The study closes fully negative on every
  differentiation claim.** What stands: latency generic, narrowness scoped
  to curated corpora, and the size law (median aperture fraction
  0.098 → 0.016 → 0.0075 across n = 9 → 16 → 23).

Raw per-kernel output under `results/`; session log in
`wolfram/next-session.md`. The WL cloud confirmation ran 2026-08-26:
exact agreement on every exact-tier value; no pending steps remain for
this study.
