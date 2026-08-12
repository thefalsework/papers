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

Three further cells run the **comma-shape graduation** (email
artifact 2). They can be appended to the same notebook after cell 7:

| Cell | Paste the contents of | What it does |
|---|---|---|
| 8a | `../comma-graduation.wl` | pre-committed witness/feature definitions, `GraduateCore` (derives commas from graph structure; kernels that earn none stay underived) |
| 8b | `8-comma-graduation.wl` | graduates the corpus; per-core table, kind distribution, the two replicate stability checks |
| 9 | `9-q2-graduated.wl` | Q2 rerun over the graduated corpus; every difference from cell 4 is attributable to the graduation alone |

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

## Pre-registered expected results — comma graduation (cells 8–9)

Same discipline, same independent Node.js reference (run 2026-08-11,
before the WL cells were committed). **Status: reproduced in Wolfram
Cloud 2026-08-11** — 5/15 derived on the expected five cores, kind
distribution 4 + 1, both replicate pairs mismatching, 128 candidates
at the graduated 0.92 tier. The WL run must reproduce:

**Graduation (cell 8b)** — **5 of 15** cores derive a comma:

| Core | Principal poles | Derived kind |
|---|---|---|
| `seven-samurai-16b09742` | M1, M4 | `tension_disjoint_balanced_constitutive` |
| `throne-of-blood-2eedaf0f` | E_fog_exteriors, M1 | `tension_disjoint_balanced_constitutive` |
| `girl-with-a-pearl-earring-5fe5bb51` | E_direct_gaze, E_pearl_earring | `tension_disjoint_balanced_constitutive` |
| `the-red-book-8c596e2f` | E_septem_sermones, M3 | `tension_disjoint_balanced_constitutive` |
| `ran-a74be626` | E_army_color_banners, E_hidetora_desaturation | `tension_disjoint_balanced_unmarked` |

Each derived core has exactly **1 witness** among its tension pairs;
the other ten cores have tension pairs but zero witnesses. Kind
distribution: 4× `..._constitutive`, 1× `..._unmarked` — the kind
vocabulary discriminates weakly; the witness gate carries the
selectivity. **Both replicate checks MISMATCH** (Red Book: 8c596e2f
derives, 9181ad6f underived; Seven Samurai: 16b09742 derives,
18591654 underived) — comma derivation is not stable under
re-transduction, reported as a headline reliability finding.

**Graduated Q2 (cell 9)** — candidates **11,839** (baseline 10,991);
max confidence **0.92** (baseline 0.68); `comma_shape_match` fired in
**1,678** candidates (baseline 0); confidence tiers:
0.92 → **128**, 0.68 → **1,516**, 0.62 → **1,550**, 0.30 → **8,645**.
The comma channel fires on **5** cross-domain core pairs:

- `girl-with-a-pearl-earring-5fe5bb51` ↔ `seven-samurai-16b09742`
- `girl-with-a-pearl-earring-5fe5bb51` ↔ `the-red-book-8c596e2f`
- `girl-with-a-pearl-earring-5fe5bb51` ↔ `throne-of-blood-2eedaf0f`
- `seven-samurai-16b09742` ↔ `the-red-book-8c596e2f`
- `the-red-book-8c596e2f` ↔ `throne-of-blood-2eedaf0f`

(One within-domain kind match exists outside Q2's scope:
`seven-samurai-16b09742` ↔ `throne-of-blood-2eedaf0f`.)

## Capturing the reference run

After a successful evaluation, save the notebook (with outputs) into
`../results/` following the V1 naming convention, e.g.
`wolfram-cloud-run-YYYY-MM-DD-v2.0.nb`, and update the results table
in `../README.md` with the measured numbers. The corpus URLs in cell 3
are pinned to the commit that introduced the corpus, so the run is
reproducible bit-for-bit regardless of later repository history.
