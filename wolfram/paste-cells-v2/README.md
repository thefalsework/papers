# Multi-Cell Workflow for the V2 Machine-Fed Run (Wolfram Cloud)

Seven cells, evaluated in order in a fresh Wolfram Cloud notebook.
Cells 1 and 2 are existing files pasted directly — single source of
truth, no duplicated copies to drift:

| Cell | Paste the contents of | What it does |
|---|---|---|
| 1 | `../falsework-algebra.wl` | type system, predicates, Q1–Q4 implementations (unchanged V1 algebra) |
| 2 | `../corev2-loader.wl` | CoreV2 JSON → `Core[...]` loader, in-WL revalidation, fixpoint executor, assertion audit |
| 3 | `3-corpus.wl` | fetches the 15-graph machine corpus from this repository (commit-pinned raw URLs), revalidates every file inside WL, constructs cores, prints the validation table |
| 4 | `4-q1-q2.wl` | Q1 (type + constraint match over derived types) and Q2 (transfer candidates over all cross-domain pairs, comma-channel silence check) |
| 5 | `5-q3-cascade-audit.wl` | Q3 (fixpoint cascade with per-node causes; V1 single-step shown beside it) plus the corpus-wide machine-checkable claim audit and the prose-assertion audit table |
| 6 | `6-q4-recursive.wl` | Q4 (recursive self-application across all machine cores: self-transfers, load-bearing ranking, deepest cascades) |
| 7 | `7-results-table.wl` | results table: machine-fed rerun vs the V1 reference run |

## Requirements

- Cell 3 fetches JSON from `raw.githubusercontent.com` and therefore
  needs outbound HTTP from the cloud sandbox. If that is unavailable,
  run locally instead: set
  `corpusBase = "<path to wolfram/corpus-v2>"` (no trailing slash)
  before evaluating the rest of cell 3 — the loader accepts a local
  directory transparently.
- Cells must be evaluated in order; later cells consume variables
  (`corpusV2`, `coresById`, `q1Results`, `allCands`, `evaluated`,
  `contradicted`, …) defined by earlier ones.

## Pre-registered expected results (differential test)

The cascade executor's semantics were independently implemented twice:
in `../corev2-loader.wl` (Wolfram Language) and in a throwaway Node.js
reference run against the same pinned corpus before this workflow was
committed. The WL run must reproduce the following, computed by the
Node.js reference on 2026-08-11. Divergence means one of the two
implementations is wrong — do not adjust the expectation to fit.

**Q1** — most frequent cross-domain derived type: `Sig[out:-|in:requires]`
(42 nodes; spans cinema, literature, painting). With constraint type
`requires`: **14 of 15 cores** match.

**Q2** — not pre-registered numerically (the V1 `TransferBasis` /
`TransferConfidence` scoring was deliberately not reimplemented
outside WL). Two qualitative expectations: `comma_shape_match` fires
**0** times, and max confidence is **at most 0.68**.

**Q3** — corpus-wide largest element-seeded cascade:
core `red-book-of-westmarch-0bd9ff72`, seed `E_note_on_shire_records`,
closure **9 nodes**:
`E_amputated_terminal_link, E_blank_final_leaves, E_note_on_shire_records,
E_title_page_palimpsest, M1, M2, M5, M6, M7`.
Degraded survivors: `E_beyond_witness_scenes` (tension_released:M2),
`E_appendix_b_tale_of_years` (tension_released:M7).
Failure statuses: F2, F6, F8 `Triggered`; F7 `NotTriggered`;
F1, F3, F4, F5 `NotEvaluableUnderRemoval`.
Survivor-claim contradiction: **F8 claims M1, M2, M7 survive; the
cascade removes all three.**

**Corpus-wide audit** — **47** failure conditions machine-evaluated
under their own removal seeds; **4** survivor-claim contradictions:

| Core | Failure | Claimed survivors removed by cascade |
|---|---|---|
| `the-calling-of-saint-matthew-09065764` | F2 | M4 |
| `red-book-of-westmarch-0bd9ff72` | F8 | M1, M2, M7 |
| `sátántangó-559aa980` | F6 | M2 |
| `dreams-cf67d3e8` | F6 | M1 |

These four are the deliverable in miniature: the transduction's own
structured claims checked against the transduction's own graph, with
the machine catching the inconsistencies.

## Capturing the reference run

After a successful evaluation, save the notebook (with outputs) into
`../results/` following the V1 naming convention, e.g.
`wolfram-cloud-run-YYYY-MM-DD-v2.0.nb`, and update the results table
in `../README.md` with the measured numbers. The corpus URLs in cell 3
are pinned to the commit that introduced the corpus, so the run is
reproducible bit-for-bit regardless of later repository history.
