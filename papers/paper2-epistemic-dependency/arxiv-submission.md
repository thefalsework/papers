# arXiv submission metadata — Paper 2 (v8.16)

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

Rationale: the paper's central contribution is methodological — a
correction-architecture account of AI-assisted scholarship with a documented
case study — which sits most naturally in cs.AI with cs.CY as secondary. The
Lean/Mathlib material (§ 3.6) is evidence for a correction mode, not a logic
contribution in its own right.

## License

CC BY 4.0 (matches the repository `LICENSE`).

## Comments field

~24 pages, no figures.

## Submission format decision

LaTeX source (cs.AI convention). Scaffold generated with `pandoc 3.9` from
`paper2.md`:

```
pandoc paper2.md --standalone --from markdown --to latex \
  -V documentclass=article -V geometry:margin=1in -V fontsize=11pt -o paper2.tex
```

Output is `paper2.tex` (title block hand-edited into `\title`/`\maketitle`).

## Compilation notes

- **Status: regenerate from `paper2.md` after v8.15 scope cut, then recompile.**
  Prior build (v8.5): 30 pages with tectonic 0.16.9. v8.15 removes ~6 pages
  (Levin §6, compressed §2, trimmed digressions); expect ~24 pages.
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

Epistemic dependency — the condition in which a knowledge-producing system's outputs reflect the theoretical commitments embedded in its formation — is not unique to AI systems. It is a structural condition shared by all knowledge-producing systems, human and computational. What differs is not the presence of the dependency but the maturity of the correction mechanism available to address it. This paper demonstrates the claim through a documented live case study: the development of FalseWork, a computational classification framework built using an AI system trained on the theoretical traditions it classifies within. The paper specifies the correction architecture and its operational implementation: every substantive claim carries an explicit epistemic-status tag ([K] kernel-checked, [C] classical, [A] analogy, [O] open), with pre-registration, demotion-by-artifact, and contemporaneous correction ledgers. Six stages are documented: two of dependency generation, two of correction-mechanism activation, one of the mechanism existing but not yet deployed, and one formal-verification cycle in a public mathematical library whose contribution was machine-checked and then declined under the library's AI-use policy. The case grounds two methodological claims: hallucination and genuine correction are distinguishable not by the process that produces them but by external validation; and inherited validity — correct results produced through an unacknowledged absorbed analytical frame — is a third category requiring the same external validation as hallucination to distinguish from independent derivation. Correction architecture is not quality control applied after the fact; it is the epistemological design of AI-assisted scholarship.
