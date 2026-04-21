# The FalseWork Papers

[![DOI](https://zenodo.org/badge/1216426192.svg)](https://zenodo.org/badge/latestdoi/1216426192) [![License: CC BY 4.0](https://img.shields.io/badge/License-CC_BY_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)

An open-source research programme on structural incompleteness across domains of sustained human practice — music, cinema, painting, architecture, software, physics, knowledge production — and the shared mathematical and epistemological floor underneath them.

This repository holds the papers themselves, the open validation items they contain, and the infrastructure for anyone who wants to read, comment, verify, correct, or formalize their claims.

> **Project status.** Working drafts. Arguments marked `[REQUIRES FORMAL VALIDATION]` need external expert engagement before the claims can be advanced as settled. Nothing in this repository is peer-reviewed in the traditional sense; validation happens here, in the open.

---

## The papers

All papers are authored by **Chris Brink** (independent researcher), distributed under **CC-BY-4.0**, and cite each other as a coherent series. Papers 1–5 form the core research programme; paper 6 is an exploratory / practitioner-outcome companion. The Markdown source is authoritative; each released DOCX is preserved in the per-paper `archive/` subdirectory.

| # | Paper | Current version | Source |
|---|---|---|---|
| 1 | [Kernels and Commas: A Structural Derivation of Universal Positions in Domains with Self-Limiting Generative Operations](papers/paper1-kernels-and-commas/paper1.md) | v11.3 | [archive](papers/paper1-kernels-and-commas/archive/v11.3.docx) |
| 2 | [Epistemic Dependency as Structural Condition](papers/paper2-epistemic-dependency/paper2.md) | v8.2 | [archive](papers/paper2-epistemic-dependency/archive/v8.2.docx) |
| 3 | [The Distinction Operation and the Generative Floor](papers/paper3-distinction-operation/paper3.md) | v9.1 | [archive](papers/paper3-distinction-operation/archive/v9.1.docx) |
| 4 | [Mathematics as Comma: The Distinction Operation and the Unreasonable Effectiveness of Formal Systems](papers/paper4-mathematics-as-comma/paper4.md) | v5.1 | [archive](papers/paper4-mathematics-as-comma/archive/v5.1.docx) |
| 5 | [The Pythagorean Comma, the Irrationality of √2, and a Shared Diophantine Floor](papers/pythagorean-shared-floor/pythagorean.md) | v1.1 | [archive](papers/pythagorean-shared-floor/archive/v1.1.docx) |
| 6 | [Canonical Confrontation: Kernel/Comma Topology and the Structural Production of Canonical Status](papers/paper6-canonical-confrontation/paper6.md) *(exploratory companion)* | v2.1 | [archive](papers/paper6-canonical-confrontation/archive/v2.1.docx) |

A paper-by-paper overview with abstracts, current open validation items, and cross-reference graph lives at [`papers/INDEX.md`](papers/INDEX.md).

---

## Start here

Depending on your background and what brought you here:

- **Curious, want the gist first** → [**falsework.dev/thesis**](https://falsework.dev/thesis) (the narrative argument, ≈10-minute read) or [**falsework.dev/theory**](https://falsework.dev/theory) (the full technical exposition; includes a 3-minute summary at the top).
- **Mathematician / category theorist / logician** → [Paper 3 § 4](papers/paper3-distinction-operation/paper3.md) (the six-point music-kernel categorical claim needing verification) and [Paper 5](papers/pythagorean-shared-floor/pythagorean.md) (Baker's theorem applied to the Pythagorean comma and the irrationality of √2). Concrete open items: [Issue #1](https://github.com/thefalsework/papers/issues/1), [Issue #2](https://github.com/thefalsework/papers/issues/2), [Issue #4](https://github.com/thefalsework/papers/issues/4).
- **Philosopher / humanist / reception studies** → [Paper 2](papers/paper2-epistemic-dependency/paper2.md) (epistemic dependency as structural condition in AI-assisted scholarship) and [Paper 6](papers/paper6-canonical-confrontation/paper6.md) (canonical status as the structural trace of kernel-level confrontation — exploratory companion). Open item with a testable empirical prediction: [Issue #8](https://github.com/thefalsework/papers/issues/8).
- **Practitioner** (composer, architect, filmmaker, software engineer) → [**falsework.dev/kernels**](https://falsework.dev/kernels) (the registered kernels as a working navigational instrument) and [**falsework.dev/structural-profile**](https://falsework.dev/structural-profile) (the analysis pipeline that generates structural profiles of specific works).
- **Lean 4 / formalization contributor** → [`lean/README.md`](lean/README.md) — full specification for the music-kernel endofunctor formalization target. Entry point for anyone who wants to turn the D1–D4 categorical sketch into a verified theorem.

---

## What this project is

The papers make claims that cross mathematics, physics, philosophy, formal logic, musicology, and the practice-based creative domains. Most interdisciplinary work of this kind is either published privately and never validated, or locked inside closed peer-review processes whose outputs are binary (accept/reject) rather than structured. This project operates on a different premise: **validation is a distributed, open, modular process**, and the honest state of a research programme is legible to anyone who wants to inspect it.

Concretely:

- Every `[REQUIRES FORMAL VALIDATION]` flag in the papers is mirrored as a structured entry in [`validation/OPEN.md`](validation/OPEN.md), with an authoritative claim statement in [`validation/claims/`](validation/claims/) and a matching [GitHub Issue](https://github.com/thefalsework/papers/issues) for discussion.
- Any mathematician, philosopher, logician, or domain expert who wants to verify, correct, or dispute a claim can do so by opening an issue or PR. Acceptance criteria are documented in [`CONTRIBUTING.md`](CONTRIBUTING.md).
- Resolved validations move to [`validation/RESOLVED.md`](validation/RESOLVED.md) with the validator's name (with permission) and a pointer to the revision that absorbed their feedback.
- The `lean/` directory hosts a Lean 4 formalization target — currently a placeholder describing what a rigorous categorical formalization of the music-kernel endofunctor would look like; open to collaborators. See [`lean/README.md`](lean/README.md).
- Outreach drafts for specific validator engagements (mathematicians, Lean community, philosophers) live in [`docs/outreach/`](docs/outreach/) — also version-controlled, also open to improvement.

---

## See it applied

The papers describe a framework; the framework runs live as an instrument:

- **[falsework.dev/kernels](https://falsework.dev/kernels)** — the registered-kernels instrument. Each kernel from the papers (the Fifth, the Cut, the Mark, Gravity, the Conditional Branch, the Wave Function, Syntax) appears here with its four-criteria evidence, field topology, and the works empirically classified against its territories. This is where the abstract categorical sketch becomes a working navigational object.
- **[falsework.dev/thesis](https://falsework.dev/thesis)** — the narrative argument with historical and scholarly precedents cited inline (Spencer-Brown, Bruner, Meyer & Land, Feynman, Hurwitz/Frobenius, Baker, Lakatos, and the domain-specific precursors each kernel inherits).
- **[falsework.dev/theory](https://falsework.dev/theory)** — the full technical exposition. Dual-register: a 3-minute summary and a complete reading. Links back to each paper in this repository at the relevant citation.
- **[falsework.dev/structural-profile](https://falsework.dev/structural-profile)** — the seven-stage analysis pipeline that generates structural profiles of specific works. This is where the framework becomes a testable instrument: profiles are hypotheses the papers predict, and their empirical behavior is part of the framework's validation record.

The site is a separate codebase (proprietary). The papers in this repository are the formal record; the site is the applied instrument. Links are one-way: papers point at live URLs, the site points at paper markdown files in this repository.

---

## How to engage

**Currently open:** [`validation/OPEN.md`](validation/OPEN.md) · [all validation-claim issues ↗](https://github.com/thefalsework/papers/issues?q=is%3Aissue+is%3Aopen+label%3Avalidation) · [all open-research-direction issues ↗](https://github.com/thefalsework/papers/issues?q=is%3Aissue+is%3Aopen+label%3Aopen-direction)

### If you just want to read

- Start with [Paper 1 § 1](papers/paper1-kernels-and-commas/paper1.md) for the framework. [Paper 2 § 1](papers/paper2-epistemic-dependency/paper2.md) extends it to AI-assisted knowledge production. [Paper 3 § 1](papers/paper3-distinction-operation/paper3.md) lays the Spencer-Brown / categorical foundation. [Paper 4 § 1](papers/paper4-mathematics-as-comma/paper4.md) is the strongest ontological claim. The [Pythagorean companion](papers/pythagorean-shared-floor/pythagorean.md) is the technical unification of the Pythagorean comma and the irrationality of √2. The [Canonical Confrontation companion](papers/paper6-canonical-confrontation/paper6.md) is an exploratory practitioner-outcome paper applying the kernel/comma topology to the question of canonical persistence.
- Each paper's top matter includes a revision history and explicit `[REQUIRES FORMAL VALIDATION]` markers. Nothing is hidden.

### If you want to validate or correct a specific claim

- Browse [`validation/OPEN.md`](validation/OPEN.md) for the current open items.
- Each claim has an authoritative statement at [`validation/claims/[slug].md`](validation/claims/) and a GitHub Issue for discussion.
- Follow the instructions in [`CONTRIBUTING.md`](CONTRIBUTING.md) for what counts as a valid verification, correction, or disproof.

### If you want to formalize the mathematics

- The highest-leverage target is the six-point music-kernel formalization in Lean 4. See [`lean/README.md`](lean/README.md) for the full specification.
- Any categorical, number-theoretic, or set-theoretic formalization contribution is welcome. Acceptance criterion: passing `lake build` with the claimed theorem proved.

### If you want to propose a new open research direction

- Open an issue using the **Open Research Direction** template. It will be added to `validation/OPEN.md` after a brief review.

---

## Disclosure

The series was developed with substantial AI assistance. Claude (Anthropic) was the primary development collaborator — used for drafting, structural editing, and sustained dialogue through the framework's formation. Other systems used in supporting roles include GPT (OpenAI, for independent formalization attempts and cross-checking), Grok (xAI, for adversarial review), and Gemini (Google, in the specific documented incident [Paper 2 § 7](papers/paper2-epistemic-dependency/paper2.md) treats as a case of inherited validity without correction architecture).

[Paper 2](papers/paper2-epistemic-dependency/paper2.md) is the canonical disclosure: it documents the AI-assisted development of this framework as a live case study and treats epistemic dependency in AI-assisted scholarship as a **structural condition** rather than a peripheral limitation. What differs between knowledge-producing systems is not the presence of epistemic dependency but the maturity of the correction mechanism available to detect and address it. Correction architecture — dependency prediction, expert correspondence, contemporaneous documentation — is built into the framework's design and into how this repository operates: the validation queue, the PR workflow, and the public commit history are the correction mechanism Paper 2 argues for.

---

## Licensing

- **Papers** (all prose, figures, citations in `papers/`, `validation/`, `docs/`): [Creative Commons Attribution 4.0 International (CC-BY-4.0)](LICENSE).
- **Code** (`lean/`, any future tooling): [Apache License 2.0](LICENSE-CODE).

You may read, copy, translate, redistribute, and build on any of the content, commercial or not, provided you give appropriate credit and indicate changes.

---

## How to cite

Every tagged release of this repository is archived to Zenodo and assigned a permanent Digital Object Identifier (DOI). Two DOI variants are available:

- **Concept DOI** — `10.5281/zenodo.19673672` — always resolves to the most recent release. Use this when citing the project as a whole.
- **Version DOI** — e.g. `10.5281/zenodo.19673673` for Release 2026.04 — resolves to one specific release. Use this when citing a specific claim at a specific version, because subsequent revisions may alter it.

**Project-level citation** (concept DOI — follows the latest release):

> Brink, C. (2026). *The FalseWork Papers*. Zenodo. https://doi.org/10.5281/zenodo.19673672

**Release-level citation** (version DOI — pinned to Release 2026.04):

> Brink, C. (2026). *The FalseWork Papers* (Release 2026.04). Zenodo. https://doi.org/10.5281/zenodo.19673673

**Paper-at-version citation** (most precise — pinned to a specific paper inside a specific release):

> Brink, C. (2026). *Kernels and Commas: A Structural Derivation of Universal Positions in Domains with Self-Limiting Generative Operations* (v11.3). In *The FalseWork Papers* (Release 2026.04). Zenodo. https://doi.org/10.5281/zenodo.19673673

BibTeX, RIS, and EndNote entries for any version can be exported directly from the [Zenodo record page](https://zenodo.org/records/19673673). Both concept and version DOIs resolve programmatically — see the [Zenodo REST API](https://developers.zenodo.org/) for structured access. Each subsequent release (per-paper or collection-wide) will receive its own version DOI under the same concept DOI.

---

## Contact

- **Author:** Chris Brink — Independent researcher
- **Email:** `chris@falsework.dev`
- **Site:** [falsework.dev](https://falsework.dev)
- **Preferred channel for validation and correction:** [GitHub Issues](https://github.com/thefalsework/papers/issues)
- **Email is fine for pre-submission discussion or any interaction you would prefer to start privately.** Anything that becomes part of the project's validation record will be moved to a public issue with your consent.

---

## Acknowledgements

See [`ACKNOWLEDGEMENTS.md`](ACKNOWLEDGEMENTS.md) (created on first merged contribution). Every validator, corrector, and formalizer who contributes substantively to the project will be credited by name with their permission. The author gratefully accepts reference-letter requests from graduate-student contributors.
