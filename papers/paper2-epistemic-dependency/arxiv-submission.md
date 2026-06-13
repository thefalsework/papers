# arXiv submission metadata — Paper 2 (v8.18 / arXiv v2 prep)

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

## Comments field (paste into arXiv)

30 pages, no figures. arXiv v1 (June 2026). AI disclosure: this paper and the
FalseWork development it documents were produced with AI assistance (Anthropic
Claude), under the documented correction architecture the paper specifies —
expert correspondence, [K]/[C]/[A]/[O] status tags, pre-registration, and
contemporaneous ledgers; formal contributions disclosed AI use per venue policy
(Mathlib PR #39618). arXiv v2 planned after Stage 4 (Tymoczko correspondence)
closes, with changelog in appendix.

## Versioning plan

| Version | When | What changes |
|---------|------|--------------|
| **arXiv v1** | Initial post (June 2026) | Repo v8.17. Stage 4 open; Tymoczko contact not yet initiated. |
| **arXiv v2** | After Stage 4 closes + Citkin closure (v8.18) | Update §3.4 from Tymoczko response; §4.6 Citkin second reply; reclassify Stage 3 if warranted; record change in appendix revision log. |

Upload v1 now. Do not hold for Stage 4 — the open cycle is itself the
documented condition. Replace with v2 (new arXiv version, not silent overwrite)
when the correspondence lands.

## Citation audit (verified 2026-06-13)

All resolvable external references checked. arXiv and DOI links included in
`paper2.md` References section.

| Reference | Resolver | Status |
|-----------|----------|--------|
| Tymoczko & Newman (2024) arXiv:2407.21130 | https://arxiv.org/abs/2407.21130 | OK (200) |
| Døring (2012) arXiv:1202.2750 | https://arxiv.org/abs/1202.2750 | OK (200) |
| Citkin (2024) DOI 10.3390/logics2040007 | https://doi.org/10.3390/logics2040007 | DOI resolves (MDPI) |
| Citkin preprint (closure) arXiv:2512.05633 | https://arxiv.org/abs/2512.05633 | OK (200) |
| Tymoczko (2006) Science | https://doi.org/10.1126/science.1126287 | Standard DOI |
| Weatherby & Justie (2022) | https://doi.org/10.1086/717312 | Standard DOI |
| Brink (2026a) Zenodo | https://doi.org/10.5281/zenodo.19673673 | OK (200) |
| Brink preprint concept DOI | https://doi.org/10.5281/zenodo.19673672 | OK |
| Mathlib PR #39618 | https://github.com/leanprover-community/mathlib4/pull/39618 | OK (opened 2026-05-20, closed 2026-05-28) |
| FalseWork repo | https://github.com/thefalsework/papers | OK |

**No URL required (standard book/journal/correspondence):** Kuhn (1962), Polanyi
(1958, 1966), Latour & Woolgar (1979), Mac Lane & Moerdijk (1992), Tymoczko
(2011), Cutting (forthcoming), personal correspondence entries (Tymoczko,
Cutting).

## Submission format decision

LaTeX source (cs.AI convention). **Regenerate from `paper2.md` with the build script** — do not hand-edit `paper2.tex`:

```powershell
cd papers\paper2-epistemic-dependency
.\build-paper2-arxiv.ps1          # writes paper2.tex
.\build-paper2-arxiv.ps1 -Compile # also runs tectonic -> paper2.pdf
```

The script:

- Skips the markdown title block (lines 1–7); re-injects the version/AI-disclosure note after `\maketitle`.
- Runs `pandoc` with `arxiv-metadata.yaml` and `arxiv-preamble.tex` (`\statustag`, Unicode glyphs, `hyperref`).
- Post-processes: `{[}K{]}` → `\statustag{K}`, `\begin{abstract}`, `\appendix`, escapes `#` in PR references.

**arXiv upload:** submit `paper2.tex` only (preamble is inlined). Optional local check: `paper2.pdf`.

## Compilation notes

- **Engine: XeLaTeX or LuaLaTeX (not pdfLaTeX).** Unicode glyphs (♭, ⇒, ⊓, ø in Døring, etc.). Select **XeLaTeX** on arXiv.
- **Status tags:** `[K]` / `[C]` / `[A]` / `[O]` render as `\statustag{…}` → `\texttt{[K]}` throughout.
- **Local recompile:** `.tools\tectonic.exe --outdir papers\paper2-epistemic-dependency papers\paper2-epistemic-dependency\paper2.tex`

## Trimmed abstract (for the arXiv abstract field)

Epistemic dependency — the condition in which a knowledge-producing system's outputs reflect the theoretical commitments embedded in its formation — is not unique to AI systems. It is a structural condition shared by all knowledge-producing systems, human and computational. What differs is not the presence of the dependency but the maturity of the correction mechanism available to address it. This paper demonstrates the claim through a documented live case study: the development of FalseWork, a computational classification framework built using an AI system trained on the theoretical traditions it classifies within. The paper specifies the correction architecture and its operational implementation: every substantive claim carries an explicit epistemic-status tag ([K] kernel-checked, [C] classical, [A] analogy, [O] open), with pre-registration, demotion-by-artifact, and contemporaneous correction ledgers. Six stages are documented: two of dependency generation, two of correction-mechanism activation, one of the mechanism existing but not yet deployed, and one formal-verification cycle in a public mathematical library whose contribution was machine-checked and then declined under the library's AI-use policy. The case grounds two methodological claims: hallucination and genuine correction are distinguishable not by the process that produces them but by external validation; and inherited validity — correct results produced through an unacknowledged absorbed analytical frame — is a third category requiring the same external validation as hallucination to distinguish from independent derivation. Correction architecture is not quality control applied after the fact; it is the epistemological design of AI-assisted scholarship.
