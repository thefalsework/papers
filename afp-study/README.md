# The AFP referendum: the aperture instrument on a second proof ecosystem

**Date.** 2026-08-26, one session. **Corpus.** The Archive of Formal Proofs
(Isabelle), git mirror `github.com/isabelle-prover/mirror-afp-devel`, HEAD pin
`1e072b5cc6b4a19ed1f4f905feddb07b884c9f2c` (2026-08-25): 1,014 entries, 10,371
theory files; full 22-year history (16,738 commits, root 2004-02-12) for the
biennial checkpoints. **Status.** [computed] throughout; every test
pre-registered in the script headers before first run, blind pre-checks
committed first.

## Why "referendum"

Everything the program had found empirically, it had found on one corpus
(Mathlib) — one assistant, one community, one grain, one ground-truth
instrument. This study was designed as the decision point named in the session
record: the two load-bearing findings face a different assistant (Isabelle),
a different social object (refereed archive of contributions vs. one
integrated library), a different grain (entries, not modules), and a different
ground truth (author-assigned topic labels from the archive's curated
taxonomy, not name paths). Nothing about Mathlib's outcomes leaks into any
input here.

## Setup

Node ≥ 18, git. Fetch the corpus:

```bash
git clone https://github.com/isabelle-prover/mirror-afp-devel .scratch_afp
git -C .scratch_afp checkout 1e072b5cc6b4a19ed1f4f905feddb07b884c9f2c
```

Historical edge lists are committed under `history/` (regenerate with 04,
which reads blobs straight from the object database — old snapshots contain
Windows-reserved filenames like `Aux.thy`, so no tree is ever materialized).

## Scripts, in narrative order

1. **`01-census.mjs`** — blind structural census. 10,370/10,371 theories
   parse; entry graph 1,014 nodes / 1,360 edges, near-DAG (one 4-entry knot);
   550 evaluable kernels; 1,013 entries carry topics (CS 482, Mathematics 372,
   Logic 135, Tools 24).
2. **`02-referendum-precheck.mjs`** — blind resolution pre-check: the
   topic-sharing measure has real dynamic range (pair fraction 0.055 overall,
   0.096–0.157 within strata); evaluable populations Logic 54 / Mathematics
   172 / Computer science 208. (Bug caught mid-run and fixed before any
   measurement: JS `|` returns signed int32, `Uint32Array` reads are unsigned —
   fixpoint closure spun forever once bit 31 was set.)
3. **`03-referendum.mjs`** — part 1, registered. **R1 HOLDS at the 100th
   percentile**: Exploitation-cell entries share the kernel's topic territory,
   sED = +0.0334 vs a null band of ±0.0055 — and descriptively at the 100th
   percentile inside every stratum (Logic +0.385). "Exploitation is
   on-territory" has now survived two assistants, two communities, two grains,
   and two ground-truth instruments. **R2 FAILS**: the foundational-strata
   reading of R/D geography (post-hoc on Mathlib, registered here) does not
   replicate — Logic shows no refusal-proximity (sRD −0.032, percentile 20);
   the working strata behave like Mathlib's working namespaces (D nearer,
   percentile 0). R/D geography stays dead.
4. **`04-history-extract.mjs`** — blind: biennial checkpoint edge lists
   2006–2026 (25 entries / 1 edge → 950 / 1,219).
5. **`05-consolidation.mjs`** — part 2, registered. Eight eligible
   checkpoints. **H1 holds** (latency arrow, Spearman +0.83); **H2 fails
   decisively** (apertures *widen*, +0.64 vs required ≤ −0.6) — the
   **consolidation arrow FAILS on AFP** and is scoped to Mathlib in every
   outward mention. Instrument observation: the top-5 pick freezes from 2022
   (old entries never change). Post-hoc, flagged, untested: consolidation may
   be a property of *maintained* corpora (Mathlib is continuously refactored)
   rather than *accumulated* ones (AFP entries are frozen at acceptance) —
   testable on maintained-vs-archival pairs elsewhere, not here.

## The referendum's verdict

- **Exploitation-on-territory graduates**: from a Mathlib fact to a
  cross-ecosystem regularity of collective formal work (16/16 registered
  Mathlib namespaces + AFP whole-graph and all strata at the 100th
  percentile).
- **The consolidation arrow is scoped**: real, null-controlled, and
  three-years-strong on Mathlib; absent (reversed) on a 22-year frozen
  archive. Latency rising is common to both.
- **R/D geography is dead everywhere it has been scored**: original glosses,
  corrected glosses, and the foundational-strata reading — all failed under
  registration. The proved cell definitions are untouched.

## Modeling choices (fixed before any run)

Entry-level import graph (edge A→B when any theory of A imports a theory of
B); resolution rules and their measured rates in 01 (8% of import tokens
unresolved — a stated approximation, like Mathlib's namespace-internal edges);
Isabelle-distribution imports (HOL etc.) excluded; the one import knot handled
by cycle-tolerant down-closure (preorder reflection). Seeded PRNGs; seeds in
script headers.
