# arXiv submission metadata — Paper 2 (v8.5)

This file holds the metadata for the arXiv submission of `paper2.md`. It is not
part of the paper. The trimmed abstract below is sized for arXiv's abstract
field (1920-character limit); the in-paper abstract (§ Abstract of `paper2.md`)
remains the full-length version.

---

## Title

Epistemic Dependency as Structural Condition: A Documented Case Study of AI-Assisted Scholarship and the Maturity of Correction Mechanisms

## Authors

Chris Brink (FalseWork)

## Primary class

cs.AI

## Secondary class

cs.CY (Computers and Society)

Rationale: the paper's central contribution is methodological/sociological — a
correction-architecture account of AI-assisted scholarship — which sits most
naturally in Computers and Society. cs.LO was considered and rejected as
understating the AI-epistemology framing; the Lean/Mathlib material (§ 3.6) is
evidence for a correction mode, not a logic contribution in its own right.

## License

CC BY 4.0 (matches the repository `LICENSE`).

## Comments field

30 pages, no figures.

## Submission format decision

LaTeX source (cs.AI convention). Scaffold generated with `pandoc 3.9` from
`paper2.md`:

```
pandoc paper2.md --standalone --from markdown --to latex \
  -V documentclass=article -V geometry:margin=1in -V fontsize=11pt -o paper2.tex
```

Output is `paper2.tex` (title block hand-edited into `\title`/`\maketitle`).

## Compilation notes

- **Status: compiles cleanly to 30 pages, no figures, zero missing-glyph
  warnings.** Verified locally with `tectonic 0.16.9` (XeTeX engine).
- **Engine: XeLaTeX or LuaLaTeX (not pdfLaTeX).** The paper contains Unicode
  categorical glyphs (Σ, δ, ι, χ, ⇒, ⊓, ≤, ↔), the music flat ♭ (the "A♭"
  in § 3.1), and the Danish ø in "Døring". The pandoc preamble loads
  `unicode-math` under xetex/luatex; pdfLaTeX would fail on these. On arXiv,
  select the XeLaTeX toolchain for this submission.
- **Manual post-pandoc fix applied to `paper2.tex`:** a `newunicodechar`
  preamble block maps the Unicode operators (♭ ⇒ ⊓ ⊔ ≤ ≥ ↔ δ ι χ Σ Δ) to
  their math symbols so they render under XeLaTeX. Latin Modern Roman/Mono
  lack these glyphs; without the block they are silently dropped. **If
  `paper2.tex` is regenerated from `paper2.md` via pandoc, re-add this block.**
- **References** are inline plain-text paragraphs under `\section{References}`;
  no `.bib` is required.
- **Recompile command** (tectonic binary lives at repo `.tools\tectonic.exe`,
  not committed):
  `.tools\tectonic.exe --outdir papers\paper2-epistemic-dependency papers\paper2-epistemic-dependency\paper2.tex`

## Trimmed abstract (for the arXiv abstract field)

Epistemic dependency — the condition in which a knowledge-producing system's outputs reflect the theoretical commitments embedded in its formation — is not unique to AI systems. It is a structural condition shared by all knowledge-producing systems, human and computational. What differs is not the presence of the dependency but the maturity of the correction mechanism available to address it. This paper demonstrates the claim through a documented live case study: the development of FalseWork, a computational structural classification framework built using an AI system trained on the theoretical traditions it classifies within. The case study provides what prior work on AI epistemic dependency has lacked — a formal framework that predicts the dependency, a working instrument that produces it in real time, a correction mechanism that activates against it, and full documentation of the complete cycle from generation to correction. Six stages are documented: two of dependency generation, two of correction-mechanism activation, one of the mechanism existing but not yet deployed, and one of formal-verification correction in a public mathematical library, kernel-verified but declined under the library's AI-use policy. The case grounds a general claim: hallucination and genuine correction are distinguished not by the process that produces them — both are navigations of an inherited semantic manifold — but by the external validation that determines which is which. The study further introduces a third category, inherited validity, in which the dependency produces results that are correct but whose relationship to prior analytical framing is not transparent, requiring the same external validation as hallucination to distinguish from independent derivation. The correction mechanism is not quality control applied after the fact; it is the epistemological architecture of the project.
