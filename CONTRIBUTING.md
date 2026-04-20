# Contributing to the FalseWork Papers

This document describes what kinds of contributions are welcome, what counts as "valid" for each kind, and the mechanics of getting your contribution into the repository.

The project operates on the premise that **validation is distributed and modular**. You do not need to read the whole series to contribute. You do not need to endorse any claim outside your specialty. You are invited to verify, correct, dispute, formalize, or extend any single claim within your expertise, and that contribution will be treated as a first-class part of the research record.

---

## Types of contribution

### 1. Validation (verifying a stated claim)

**What it is.** A written confirmation, from someone with relevant expertise, that a specific claim in the papers is correctly stated, correctly argued, and correctly cited — i.e., that the paper's claim is what the paper says it is and that the argument given supports it.

**Acceptance criteria.**
- The contribution must be written (Markdown, PDF, or inline in a PR description). Verbal statements are welcome as a starting point but must be committed to writing before they enter the record.
- The contribution must name the specific claim being validated (paper, section, version) and quote or restate it precisely.
- The contribution must confirm each discrete step of the argument or explicitly note any that are waived (e.g., "I confirm steps 1, 2, 4, 5; step 3 is standard and I assume it without checking in detail").
- The contribution must be signed with a name that can be credited publicly, or attached to a GitHub identity the contributor owns. Pseudonymous validations are accepted if the claim is verifiable by inspection (e.g., a Lean proof).
- The contributor should briefly describe their relevant background (e.g., "category theorist, work on coalgebras for endofunctors on locally presentable categories"). This is not gatekeeping — it is for downstream readers to assess the weight of the validation.

**How to submit.**
1. Open the relevant [validation issue](https://github.com/thefalsework/papers/issues) (or open a new one using the **Validation Claim** template if none exists).
2. Post your written validation as an issue comment, or open a PR that updates `validation/claims/[slug].md` with your validation status block and your name in the "Validators" table.
3. The author will review, thank you, and — with your permission — move the item to [`validation/RESOLVED.md`](validation/RESOLVED.md) and add your name to the next revision's acknowledgements.

### 2. Correction (identifying and fixing an error)

**What it is.** A written identification of an error in a paper — a misstatement, a mis-citation, a faulty argument, a wrong numerical value, a broken link, a typo in a formula — together with a proposed fix.

**Acceptance criteria.**
- The contribution must name the specific location of the error (paper, section, line number in the current Markdown, or quoted sentence).
- The contribution must explain what the error is and why the existing text is incorrect.
- The contribution must propose a specific replacement text. "This is wrong" without a proposed correction becomes an issue, not a correction; both are welcome, but they are different contribution types.
- If the correction substantively changes a paper's argument (not just cleanup), the contributor and author will discuss whether a version bump is warranted and how the revision note should describe the change.

**How to submit.**
1. Open an issue using the **Correction** template.
2. Or, if the fix is small and obvious: open a PR directly against the paper's Markdown file. Reference the issue (if any) in the PR description. The PR should modify only the specific text needing correction and should not bundle unrelated changes.
3. The author reviews, merges, and credits the contributor in the next revision's notes.

### 3. Formalization (Lean 4 contributions)

**What it is.** A Lean 4 proof of a stated theorem from the papers, contributed to the `lean/` subdirectory.

**Acceptance criteria.**
- The proof must compile with `lake build` in the repository's declared `lean-toolchain`.
- The proof's theorem statement must match the paper's claim, with any deviations (e.g., working in a slightly different category, adjusted hypotheses) documented in a comment block at the top of the Lean file.
- Dependencies on `mathlib4` are welcome; dependencies on other libraries require a brief justification in the PR description.
- The contributor is invited (but not required) to add a paragraph-length natural-language summary of the formalization to `lean/README.md` describing what was proved and any technical choices.

**How to submit.**
1. Open a PR against the `lean/` directory with your new or updated Lean files.
2. The PR description should state which paper claim is being formalized, which mathlib version the proof was written against, and any caveats.
3. CI will run `lake build`; once green, the author reviews and merges.
4. Successful formalizations are credited in the relevant paper's next revision.

### 4. Open research direction (proposing a new question)

**What it is.** A well-posed research question that the papers touch on but do not settle, which the project would benefit from tracking as an open item.

**Examples:** "Can the music-kernel formalization template (Lambek + Weyl) be applied to the wave function kernel in Paper 1 § 5.6?" / "Does the Cantor cumulative caveat admit a sheaf-theoretic resolution?"

**Acceptance criteria.**
- The question must be specific enough that a reasonable path to progress is conceivable.
- The question should reference the relevant paper sections that frame it.
- The question should name what a "resolution" would look like (a proof, a counterexample, an alternative framing, a referenced prior result).

**How to submit.**
1. Open an issue using the **Open Research Direction** template.
2. After brief review, the author will add an entry to [`validation/OPEN.md`](validation/OPEN.md) pointing at the issue.
3. Direction-setting proposals do not bump paper versions but may inspire future revisions.

### 5. Translation

**What it is.** Translation of any paper or document into another language.

**Acceptance criteria.**
- The translation must preserve the precise technical content, including all citations, formulas, and revision notes.
- The translator's name and the source version translated from must be included in the translated document's header.
- Translations live at `papers/[paper-name]/translations/[language-code]/[paper].md`.

Translations are welcomed and credited but are derivative works under CC-BY-4.0 — they follow the paper's license and the translator retains separate authorship of the translation itself.

### 6. Other

Anything that doesn't fit above — bibliographic corrections, new precedent suggestions, diagrams, tooling — is welcome. Open an issue first to discuss scope before investing significant effort.

---

## The PR workflow

1. **Fork** the repository.
2. **Branch** from `main` with a descriptive name: `validation/music-kernel-point-3-lambek`, `correction/paper2-section-6-2-typo`, `formalization/music-kernel-points-1-5`.
3. **Commit** using [Conventional Commit](https://www.conventionalcommits.org/) style where possible:
   - `validation: confirm music-kernel point 3 (Lambek application)`
   - `correction(paper2): fix typo in § 6.2 Gemini incident`
   - `formalization(lean): add Fix(D) = {∅} proof via cardinality argument`
   - `docs: add n-Category Café announcement draft`
4. **Push** your branch and open a PR against `main`.
5. The author typically responds within 1–2 weeks. This is a single-maintainer project; response times are best-effort. If you need faster turnaround for a specific reason (conference deadline, grant application), say so in the PR.
6. **Merge** happens after review. Your contribution becomes part of the record. Your name is added to the relevant paper's acknowledgements in the next revision, with your permission.

---

## Communication norms

- **Assume good faith.** The author's claims are working drafts; mistakes are expected; you identifying one is a gift, not an attack.
- **Be specific.** "This section is unclear" is less useful than "Paper 3 § 4 claim D4 conflicts with the stated definition of Coalg_nf(D)." Both are welcome; specificity accelerates resolution.
- **Expertise isn't gatekeeping.** If you are a musician who spots a musicological error, or a software engineer who notices a broken link, or a philosopher who pushes back on a philosophical framing, your contribution is as welcome as a category theorist's categorical one.
- **Anonymous or pseudonymous contributions are fine** for technical fixes and Lean proofs (which speak for themselves). Validations carrying epistemic weight should be attached to a verifiable identity.

See [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) for the full community covenant. In short: be decent.

---

## Recognition

Contributors are recognized in three ways:

1. **Paper-level acknowledgements.** Named in the relevant paper's next revision note and acknowledgements section.
2. **Project-level acknowledgements.** Named in [`ACKNOWLEDGEMENTS.md`](ACKNOWLEDGEMENTS.md) (created on first merged contribution).
3. **Reference letters.** Graduate-student contributors whose work is substantive are invited to request reference letters for academic applications. This is offered at the author's discretion and is independent of any monetary or authorship consideration.

Co-authorship on a revision is offered, at the author's invitation, when a contributor's work meaningfully reshapes a paper's argument. This is rare and is discussed openly when relevant.

---

## What this project is not asking for

- **Endorsement of the whole research programme.** Contributors are welcome to validate narrow claims while remaining neutral or skeptical about the broader framework.
- **Agreement with the framing.** If you think the paper series uses a category-theoretic vocabulary it shouldn't, say so in an issue — it becomes an open research direction, not a blocker to other contributions.
- **Free unpaid labor as a substitute for funded research.** The project has no funding. Contributions are welcome but are not promised compensation. See [`FUNDING.md`](FUNDING.md) for the door that's left open for future funding.
