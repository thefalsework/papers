# Does the epistemic scaffolding carry the discipline? (methodology ablation, pre-registered)

**Status:** pre-registered 2026-06-12, before any run. Open.
**Domain:** methodology of AI-assisted scholarship (Paper 2's object, turned on the project itself).
**Paper:** Paper 2 § 7.3 (added at v8.14) states the methodology as a designed artifact and cites this file as the test that would convert its central claim from introspection to evidence.

---

## The claim under test

The repository's epistemic scaffolding — the `[K]/[C]/[A]/[O]` status-tag ladder traveling with each claim, pre-registration files, kept negatives, correction ledgers (`OPEN.md`/`RESOLVED.md`) — is claimed to function as the **integrity layer** of AI-collaborative scholarship: any AI instance re-entering the repository inherits not just the project's content but its discipline, so that continuity across instances preserves rigor and not merely facts.

Two sub-claims must be separated, because they have different standings:

1. **Records are portable evidence of past enforcement.** An outsider can audit `RESOLVED.md`, the kept negatives, and the pre-registered outcomes against published sources and the commit record without trusting the developer or any AI instance. This is true by construction — the artifacts exist and are public.
2. **The artifact induces discipline in a new operator (human or AI).** This is the untested claim, and the one the "new way of scholarship" framing rests on. It is currently supported only by introspection across instances of one project driven by one operator — n = 1, with the operator and the artifact confounded.

## Evidence already in hand (logged before the experiment)

* **For:** multiple AI instances entering the repository cold have reproduced the tag discipline unprompted — applying the [K]/[A] line correctly to new prose, flagging overclaims against the registered standard (e.g. the 2026-06-12 "obligatory core" → "order-skeleton" tightening in `bach-at-the-kernel.md` § 3, caught by review against the order-embedding's actual scope).
* **Against — and then corrected twice (the "§ 6.4" instance, 2026-06-12 — first logged observation):** an AI instance with full repository access recommended placing a proposed addition in "§ 6.4" of Paper 2, quoting a section title verbatim. **No such section exists in the paper.** A second instance caught the mismatch by checking the file and recorded it as a confabulation. That diagnosis was itself wrong: while drafting the Paper 2 writeup of the incident, the quoted phrase was found **verbatim in `papers/INDEX.md`** (Paper 2 entry, "Open validation items this paper carries"), where it had stood since the initial DOCX migration (commit `dfcb4b4`, 2026-04-20), describing a section structure the paper no longer has. The instance had faithfully inherited a stale record, not invented a citation. Three readings, each narrower than the last: (1) "scaffolded instance confabulates" — wrong; (2) "the record itself is part of the dependency structure and propagates stale inscriptions across instances exactly as a training distribution does" — correct, and it cuts against the strongest version of the integrity-layer claim in a more interesting way than confabulation would have (the scaffolding *transmitted* the error); (3) the catch chain ran entirely on artifacts — output vs. paper file, then diagnosis vs. wider repository — so the same architecture that carried the error also located it. The stale index entry was corrected the same day. Recorded in Paper 2 § 4.5 (coda) and § 7.3. Scoring note for the ablation: this instance shows the error taxonomy needs a category the original design under-weighted — *inherited-record errors* (true of an earlier state of the corpus, false of the current one) alongside fabrications; Arm S is *more* exposed to that category than Arm X, since the stripped corpus carries less record to go stale.

## Pre-registered experiment (the ablation)

**Design.** Take real tasks from the repository's history (e.g. "summarize the standing of the uniqueness result for an outside reader," "draft a claims paragraph for the weld," "place this new result in the exposition"). Run matched AI instances on each task against two corpora:

* **Arm S (scaffolded):** the repository as-is — tags, pre-registrations, correction records intact.
* **Arm X (stripped):** the same content with the epistemic scaffolding mechanically removed — tags deleted, claim-file status sections cut, hedges and prior-art notes excised — leaving the mathematical and prose content otherwise identical.

**Measure.** Rate of *unlicensed promotion* in the outputs, scored against the repository's own ground truth: [A]/[O] content asserted with [K]-grade confidence; [C] inputs absorbed without citation; hedges dropped; novelty claims exceeding the recorded adjudication; fabricated specifics (citations, section numbers, theorem names).

**Pre-registered outcomes, all acceptable:**

* **(A) Arm X overclaims at a materially higher rate.** Evidence that the scaffolding carries rigor and not just content — the integrity-layer claim gains its first non-introspective support, scoped to AI operators on this corpus.
* **(B) No material difference.** The scaffolding is ergonomics for the human operator, not an integrity mechanism for AI instances; the discipline lives in the operator and the re-check practice. The methodology claim shrinks accordingly and Paper 2 § 7.3 is corrected to say so.
* **(C) Arm S overclaims more or differently** (e.g. tag-fluent confabulation — wrong specifics made *more* plausible by fluent use of the house register, as in the logged § 6.4 instance). The most interesting outcome: the scaffolding would then be evidenced as a *style* that can mask error, and the methodology section must carry that finding prominently.

**Falsifier discipline:** outcome (A) is the only one that supports the integrity-layer claim, and even (A) does not establish operator-independence — that requires the second test below.

## The second, slower test (generalization)

Whether the method survives a different operator is testable only by an external party running the practice on their own project and reporting back — the same outside-the-loop move the project's mathematical claims required (Tymoczko, Cutting, Citkin). Until at least one such replication exists, the honest standing of "a new way of scholarship" is: **demonstrated once, in one project, by the operator who designed it** — a methodological hypothesis [O], not a paradigm.

## Resolution

*Pending. Results to be recorded here with dates; Paper 2 § 7.3 and § 4.5 to be updated per outcome.*
