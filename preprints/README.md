# Preprints

Focused, peer-review-targeted mathematical papers extracted from the FalseWork framework. This directory holds artefacts in a different *register* from the broader framework essays in [`../papers/`](../papers/) — they are narrower in scope, mathematics-only in voice, and aimed at submission to mathematical venues (or pre-submission engagement on arXiv, Zulip, or specialist correspondence).

## What lives here vs. what lives in `papers/`

| `papers/` | `preprints/` |
|---|---|
| Framework essays (Papers 1–6) | Focused mathematical artefacts |
| CC-BY-4.0, cross-domain register | Mathematics venue conventions |
| Empirical claims, motivation, scope | Theorem statements and proofs |
| Open validation queue | Standalone publishable |
| Markdown source authoritative | Markdown source authoritative; DOCX archive when applicable |

A reader who wants the framework's broader argument should read [`../papers/`](../papers/). A reader who wants a single self-contained mathematics paper to verify in an evening should read what lives here.

## Current contents

### [`four-position-partition/`](four-position-partition/) — *A Four-Position Partition of Morphisms in Elementary Topoi with Distinction Structure*

**Author.** Chris Brink (independent)
**Version.** Preprint, May 2026
**Status.** Not yet submitted; preprint draft for specialist engagement.
**One-line gloss.** Formalizes the framework's central structural claim as a theorem about elementary topoi: in any elementary topos with a non-trivial distinction structure, the morphism space partitions into exactly four pairwise-disjoint structural classes characterized by Heyting conditions on the image relative to the kernel image.
**Formalization status.** The theorem is kernel-checked in Lean 4 against Mathlib4; the supporting `HeytingAlgebra (Subobject Y)` instance for elementary topoi is upstreamed as [Mathlib PR #39618](https://github.com/leanprover-community/mathlib4/pull/39618).
**Companion documents.** The broader expository companion [`../papers/comma-formal-structure-note.md`](../papers/comma-formal-structure-note.md) states the same theorem in a framework-internal register alongside three other signature theorems and the named open *refusal-bridge* conjecture. The Lean source lives at [`../lean/FalseWorkPapers/Positions/`](../lean/FalseWorkPapers/) and is summarized in [`../lean/ARCHITECTURE.md`](../lean/ARCHITECTURE.md).
**Active work-in-progress.** A *non-vacuity demonstration* (Tier 1 strengthening) is in development under [`four-position-partition/examples/`](four-position-partition/examples/). The goal is to exhibit a concrete elementary topos and distinction structure in which all four cells of the partition are simultaneously inhabited, and to mechanize the construction in Lean. Phase 1.1 (construction-choice analysis) is complete and has been absorbed into the main paper as Remarks 5.4 and 5.5; the Phase 1.1 finding is that the Sierpinski topos is too small for non-vacuity (its five Lawvere-Tierney topologies all collapse one or more cells), and that distinction structures are closely related to reflective subcategories / idempotent monads. Phase 1.2 (concrete construction in a richer base topos + Lean mechanization) is the next work block.

## Submission and versioning conventions

- Markdown source is authoritative.
- When a preprint is submitted or accepted at a venue, the directory README is updated with the venue and submission state.
- Pre-submission revisions are tracked via git history; major revisions may be archived under `archive/`.
- AI-assisted drafting is disclosed in each paper per the project's [validation architecture](../docs/observations/validation-architecture-outcomes.md) and Paper 2's framework for epistemic dependency.
