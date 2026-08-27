# The software pair: the garden/museum axis, executed and killed

**Date.** 2026-08-27, one session; protocol registered 2026-08-26, *before any
data acquisition* (`PROTOCOL.md` v1.0 — preregistration in its strongest form).
**Corpora.** The Go standard library (`github.com/golang/go`, `src/` tree,
intra-stdlib package imports — the *garden*: continuously refactored by one
community since 2009) and the crates.io index (`github.com/rust-lang/crates.io-index`,
newest-version normal dependencies — the *museum*: published versions immutable
by platform policy). Biennial checkpoints 2016–2026, pinned by SHA in
`01-census.mjs`. **Status.** [computed] throughout; predictions, thresholds,
and failure semantics fixed in the protocol before the corpora were touched.

## The hypothesis, and what happened to it

Mathlib (maintained) and AFP (frozen) had separated along one axis on two
independent measurements — consolidation direction and growth-cell identity.
The protocol promoted that reading to a cross-domain test with four quadrant
predictions. **The axis died on both rows**: the garden did not consolidate,
and the museum grew through Exploitation — the largest effect the instrument
has ever measured, in the predicted-opposite cell. The same run produced the
program's first registered directional hit (Go's growth quadrant). Full
results as dated postscripts in `PROTOCOL.md` and the script headers.

## Setup

Node ≥ 18, git. Fetch the corpora (untracked scratch dirs):

```bash
git clone --bare https://github.com/golang/go .scratch_go.git
git clone --bare --filter=blob:none https://github.com/rust-lang/crates.io-index .scratch_crates.git
# crates history 2016-2022 lives in snapshot branches of the archive repo
# (the live index's master is squashed):
git clone --bare --filter=blob:none https://github.com/rust-lang/crates.io-index-archive .scratch_crates_hist.git
```

Checkpoint SHAs are pinned in `01-census.mjs`. Extracted history graphs are
committed under `history/` except `crates-2024.json` and `crates-2026.json`
(large; regenerate with 01 against the pins).

## Scripts, in narrative order

1. **`01-census.mjs`** — blind structural census (sizes, parse rates, SCC
   structure, evaluable-kernel counts only). One plumbing repair logged
   mid-census: the Go parser was reading imports from build-ignored generator
   files (`//go:build ignore`), creating an SCC the compiler provably forbids;
   with those skipped, all Go checkpoints are acyclic. Crates condensations
   run 5k → 285k nodes.
2. **`02-gates.mjs`** — the manipulation checks that license all scoring.
   **MC1 passes narrowly** (edge-rewiring ratio garden/museum 3.13, threshold
   ≥ 3); **MC2 passes** (≥ 3 evaluable kernels at 6/6 checkpoints, both
   corpora). The pair is a real regime contrast, so the quadrants scored.
3. **`03-consolidation.mjs`** — registered, single run. **Q1-CONS FAILS by
   absence**: Go's aperture trend clears the slope (Spearman −0.71) but the
   2026 checkpoint sits at percentile 43.3 of its own 30 degree-preserving
   nulls — mature Go is indistinguishable from its degree-random twin.
   **Q2-CONS holds** (crates does not narrow; the predicted absence). **SP1
   fails on both corpora**: latency *falls* on Go (−0.66), flat on crates
   (+0.31) — the latency arrow, generic on proof corpora, is now scoped to
   proof libraries.
4. **`04-growth.mjs`** — registered, single run; degree- and age-matched
   within-kernel E-vs-D contrast, label-permutation nulls (design of
   `mathlib-study/18`). **Q1-GROWTH HOLDS** — on Go, G_ED = +0.396 vs null
   ±0.058, percentile 100: **the operator's first registered directional hit
   (record 1–11)**. **Q2-GROWTH FAILS BY REVERSAL** — crates grows through
   Exploitation at G_ED = +5.83 vs null ±0.59, percentile 100.

## The verdict

- **The garden/museum axis is dead** — consolidation row failed by absence,
  growth row by reversal; the maintained/frozen reading of the Mathlib-vs-AFP
  contrast was a two-corpus coincidence, as the protocol's stated prior
  expected.
- **What replaces it is cleaner**: E out-grows D at matched degree and age on
  Mathlib, Go, and crates.io — maintained and archival, proofs and software —
  and reverses only on AFP. The anomaly to explain is AFP, not a regime.
- **Scoping ledger after this study**: consolidation arrow → Mathlib only;
  latency arrow → proof libraries only; E-on-territory (untouched here) →
  cross-ecosystem; E-growth → three of four corpora.

## Modeling choices (fixed before any run)

Go: packages under `src/` (pre-2019 layout handled), imports enforced by the
compiler, vendored/external and build-ignored files excluded. Crates: newest
published version per crate at the checkpoint; normal (non-dev, non-optional)
dependencies only. Cycles handled by SCC condensation (`afp-study/01` design).
Large-graph adaptations declared in script headers before first run (kernel
sampling and per-side caps on crates — label-blind and seeded). PRNG seeds in
script headers.
