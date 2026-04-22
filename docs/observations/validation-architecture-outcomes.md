# Validation architecture — outcomes record

**Purpose.** Rolling research record of what the project's validation architecture produces in practice across venues (scholarly correspondence, conference threads, community chats, outreach emails). The record is empirical: entries are facts about what happened and what the repo absorbed as a result, not commentary on the people or venues involved.

**Scope.** This file sits alongside [`validation/RESOLVED.md`](../../validation/RESOLVED.md). `RESOLVED.md` is the per-claim canonical record of what changed in the papers. This file is the per-engagement index, one row per contact event, showing the shape of engagement across venues over time. The two files cross-reference; neither duplicates the other's role.

**Why this record exists.** Paper 2 argues that AI-assisted scholarship requires disclosed correction architecture. The programme committed to that architecture at launch. For the thesis to be evaluable, the architecture's outputs have to be observable. This file is where the outputs are listed so anyone auditing the programme — the author six months from now, a specialist sizing up whether engagement is worth their time, or a reader of Paper 2 v-next looking for empirical grounding — has a single place to go.

**Attribution discipline.** Contributors are named when their engagement is public and substantive. Moderation and venue-norm observations are stated factually without verbatim quoting of named individuals; the primary-source permalink is provided for anyone who wants the exact text. Placeholder attributions (e.g., display names pending confirmation of a preferred credit form) are marked as such.

**Scope-limit discipline.** Each entry names what the contributor did *and what they did not do*. Overclaiming is the dominant failure mode for scholarly-infrastructure projects and the architecture is structured against it.

---

## Categories

Four engagement types are distinguished. The same categories are used in [`validation/RESOLVED.md`](../../validation/RESOLVED.md); a fifth is specific to this file.

1. **Correction.** A specialist identified a specific error; a paper was revised.
2. **Validation.** A specialist reviewed a specific open claim and confirmed or corrected its formulation.
3. **Corroboration.** Independent scholarly work — pre-existing or contemporaneous — converges on a paper's claim without the scholar having reviewed FalseWork at the programme level. Inter-framework agreement; not framework endorsement.
4. **Formalization.** A formal proof, Lean verification, or equivalent machine-checkable derivation.
5. **Venue-norm observation** *(this file only).* A venue surfaced a norm — about disclosure, about drafting method, about citation form, about the register of engagement — that the project absorbed as a constraint on future engagement in similar venues. Not validation of content; a structural observation about how scholarly communities receive AI-assisted work in different venues. Recorded because the observation is itself data about the architecture's operating environment.

---

## Entries

Entries are in chronological order of the engagement producing them, most recent first.

---

### 2026-04-18 to 2026-04-19 — Lean Zulip thread: *Music-kernel + Pythagorean comma formalization target*

**Venue.** Lean Zulip (Lean prover community chat), `#new members` channel. Thread permalink: https://leanprover.zulipchat.com/#narrow/channel/113489-new-members/topic/Music-kernel.20.2B.20Pythagorean.20comma.20formalization.20target/near/588730901

**Engagement type(s).** Correction (1); venue-norm observation (1); refinement request leading to new validation claim (1); follow-on theoretical pointers from a single contributor (3).

**Contributors named in this entry.**
- **suhr** (Zulip display name; placeholder pending confirmation of preferred credit form).
- **Chris Henson** (Zulip display name).
- Lean Zulip moderators (not named in this record; attributed as "moderators" with thread permalink for primary source).

**Outcomes.**

1. **Correction — Paper 5 v1.1 → v1.2 (§§ 2.2, 4.2, 7.1).** Contributor: suhr. Three substantive corrections: (i) § 2.2 continued-fraction narration skipped the `24/41` convergent of `log₂(3/2)`; (ii) "practically usable temperaments" claims at §§ 2.2, 4.2, 7.1 conflated Pythagorean-comma optimization with general musical practicality over extended prime bases; (iii) "53-TET is impractical for keyboard construction" was anachronistic given Bosanquet 1875, Lumatone, and the Kite guitar. Absorbed at Paper 5 v1.2. Tracked at [Issue #9](https://github.com/thefalsework/papers/issues/9). Canonical record at [`validation/RESOLVED.md` → Corrections → 2026-04-21 — suhr](../../validation/RESOLVED.md#corrections). Acknowledged at [`ACKNOWLEDGEMENTS.md`](../../ACKNOWLEDGEMENTS.md) under Corrections.

2. **New validation claim prompted — `optimal-ntet-continued-fraction`.** Contributor: Chris Henson. Observation: "the most interesting part is likely thinking about and setting up the exact statement of what you want to verify. For instance, you could probably do something about the relationship between 'optimal' N-TET and the corresponding continued fraction." Action: Paper 5 § 2.2's implicit theorem connecting continued-fraction convergents of `log₂(3/2)` to Pythagorean-comma-optimal equal temperaments was isolated as a first-class validation claim with a tentative Lean 4 signature. See [`validation/claims/optimal-ntet-continued-fraction.md`](../../validation/claims/optimal-ntet-continued-fraction.md). Cross-linked from [`validation/claims/music-kernel-01-irrationality.md`](../../validation/claims/music-kernel-01-irrationality.md) (which also gained a tentative Lean signature in the same change set).

3. **Venue-norm observation — AI-drafted post form in Lean Zulip.** Lean Zulip moderators raised concern about AI-drafted posts in that venue, noting that the community has moved from "discouraged" to "disallowed" on this practice. Author response: committed to not drafting Zulip posts with AI assistance going forward, without making a broader programme-level commitment. Rationale recorded: Paper 2's correction architecture treats AI disclosure as the primary transparency requirement and does not constrain drafting *form* across venues; Lean Zulip's norm constrains drafting form in that venue. The two are compatible if the programme respects each venue's norm on drafting form in that venue specifically. Not recorded in `RESOLVED.md` (it is not a paper-level claim change); recorded here as architectural data about the operating environment.

4. **Follow-on theoretical pointers from suhr (same thread, 2026-04-19, after the v1.1 → v1.2 corrections landed).** Three further contributions from the same contributor, documented in canonical form at [`validation/RESOLVED.md`](../../validation/RESOLVED.md) under the suhr entry:
   - *(i) Xenharmonic Wiki as community reference.* Integrated into Paper 5 v1.2 → v1.3 as a new *Further reading — community resources* subsection in References.
   - *(ii) MOS (Moment of Symmetry) scales and the Stern-Brocot tree as generalization of the continued-fraction framework.* Integrated into [`validation/claims/optimal-ntet-continued-fraction.md`](../../validation/claims/optimal-ntet-continued-fraction.md) as a new *Broader theoretical context* subsection (not a correction of the claim; a refinement of framing for formalization targeting).
   - *(iii) Riemann zeta function approach as a further generalization (all-harmonics optimization).* Integrated as a one-paragraph extension to the same *Broader theoretical context* subsection, completing a three-framework trajectory from single-prime (3-limit) → single-generator-any-limit (MOS) → all-harmonics (Riemann zeta).

**Scope limits on this entry.**
- suhr's corrections closed three specific errors. The six-point music-kernel check ([`music-kernel-umbrella`](../../validation/claims/music-kernel-umbrella.md)) and the three Pythagorean explanatory debts ([`pythagorean-explanatory-debts`](../../validation/claims/pythagorean-explanatory-debts.md)) remain open.
- Chris Henson's suggestion prompted the new claim file; he did not endorse or review its content. The claim file is open for review.
- No formalization was produced in this engagement. The Lean signatures on `music-kernel-01-irrationality.md` and `optimal-ntet-continued-fraction.md` are tentative starting points, not verified proofs.
- Moderator positions are stated factually. Neither moderator reviewed paper content; their intervention was venue-norm only. The venue-norm observation is not a validation of the correction architecture's design or its content, and should not be read as one.
- The three follow-on theoretical pointers from suhr are technical context, not validation of any claim. suhr did not review or endorse the claim file `optimal-ntet-continued-fraction.md`; the pointers enriched its *Broader theoretical context* subsection.

**Candidate pattern surfaced (AI synthesis; not yet paper content).**

During the processing of suhr's three follow-on theoretical pointers, an AI-assisted chat thread on 2026-04-19 produced the following reading: the three frameworks — continued fractions of `log₂(3/2)` (3-limit; the case Paper 5 addresses), MOS / scale tree (any single generator, any specific harmonic limit), Riemann zeta (all prime harmonics simultaneously) — constitute a progressive-generalization trajectory in which each framework handles more of the underlying Diophantine irresolution without any of them closing the Pythagorean comma. All three are approximation-selection apparatus, not resolution apparatus. If the reading holds, the stratification is a potential instance of the FalseWork thesis in the temperament literature itself: working theorists have produced three layered optimization frameworks rather than one master framework, matching the structural-incompleteness pattern Papers 2 and 3 predict.

The reading is preserved here and is **not integrated into any paper**. Reasons: (a) it emerged from AI synthesis in a chat thread, not from the author's independent reading of the microtonal literature, and the project's disclosure discipline requires author-voice write-up for paper claims; (b) object-level incompleteness (the Pythagorean comma itself) and meta-level incompleteness (the layered theorizing about it) are conflated in the synthesis and need disentangling before any publication; (c) Paper 5 has had three version bumps in the week of the engagement and should not absorb further substantive content live. If the reading survives maturation, candidate homes are Paper 5 § 4 or § 7 (as technical observation), Paper 2 (as case study of correction-architecture outcome), or Paper 3 (as empirical illustration of the music-kernel non-closure). Maturation here means at minimum: author-voice independent writing, resolution of the object/meta conflation, and at least one independent reading — ideally from a working microtonal theorist — confirming the "none of the three frameworks closes the comma" characterization.

**Primary sources and repo artefacts.**
- Thread permalink: https://leanprover.zulipchat.com/#narrow/channel/113489-new-members/topic/Music-kernel.20.2B.20Pythagorean.20comma.20formalization.20target/near/588730901
- Draft / log file: [`docs/outreach/lean-zulip-post.md`](../outreach/lean-zulip-post.md)
- Canonical correction record: [`validation/RESOLVED.md`](../../validation/RESOLVED.md)
- GitHub issue: [#9](https://github.com/thefalsework/papers/issues/9)
- Claim file prompted by Henson (with Broader theoretical context subsection added during suhr follow-ons): [`validation/claims/optimal-ntet-continued-fraction.md`](../../validation/claims/optimal-ntet-continued-fraction.md)
- Paper revisions: [`papers/pythagorean-shared-floor/archive/v1.2.docx`](../../papers/pythagorean-shared-floor/archive/v1.2.docx), [`papers/pythagorean-shared-floor/archive/v1.3.docx`](../../papers/pythagorean-shared-floor/archive/v1.3.docx)

---

### 2026 (pre-v11.0, additional engagement through 2026 correspondence) — Dmitri Tymoczko, Princeton

**Venue.** Personal correspondence between Dmitri Tymoczko and Chris Brink (2026). Prior published work: Tymoczko (2006), "The geometry of musical chords," *Science* 313(5783), 72–74; Tymoczko (2011), *A Geometry of Music: Harmony and Counterpoint in the Extended Common Practice*, OUP.

**Engagement type(s).** Corroboration (1); correction / refinement (1); documented skepticism on a specific open claim (1).

**Contributor.** Dmitri Tymoczko, Professor of Music, Princeton University.

**Outcomes.**

1. **Corroboration — three-way Coltrane structural discrimination (Paper 1 § 4.1).** Tymoczko's geometric framework, developed independently of FalseWork, maps Coltrane's *A Love Supreme*, *Giant Steps*, and late period onto the same three structural fields (diatonic, symmetric/quasi-symmetric, chromatic) that FalseWork's classification arrives at from a different analytical starting point. Inter-framework convergence; named in Paper 1 § 4.1 as the strongest empirical grounding the music kernel currently has.

2. **Correction — exploitation target for *Giant Steps*.** Refined from the circle of fifths (as originally framed by FalseWork) to the major-third cycle's specific topological properties within the symmetric territory. Absorbed into Paper 1 prior to v11.0.

3. **Documented skepticism — Pythagorean comma as operative structural condition.** Tymoczko expressed skepticism that the Pythagorean comma remains operative as a structural condition for practitioners working in fixed temperament. Treated as a hypothesis pending the proxy feature program, not as a resolved claim. Documented at Paper 1 § 4.1 and § 4.4.

**Scope limits.** Tymoczko has not reviewed the five-position derivation, the G ∧ R ∧ C condition, the kernel/comma topology at the programme level, or the papers in the series other than via the Coltrane case in Paper 1 § 4.1. His engagement is specific to the music-kernel empirical demonstrations. The corroboration counts as inter-framework convergence, not as endorsement of FalseWork's broader framework.

**Primary sources and repo artefacts.**
- Canonical record: [`validation/RESOLVED.md` → Corroboration → Dmitri Tymoczko](../../validation/RESOLVED.md#corroboration)
- Acknowledgement: [`ACKNOWLEDGEMENTS.md`](../../ACKNOWLEDGEMENTS.md) under Corroboration
- Paper locations: Paper 1 v11.4 § 4.1, § 4.4
- Documented caveat on Pythagorean-comma skepticism: Paper 1 § 4.1 and § 4.4

---

### 2026 (pre-v11.0, additional engagement through 2026 correspondence) — James E. Cutting, Cornell

**Venue.** Personal correspondence between James E. Cutting and Chris Brink (2026). Prior published work: Cutting, DeLong & Nothelfer (2010), "Attention and the evolution of Hollywood film," *Psychological Science* 21(3), 432–439; Cutting (forthcoming), *Four cinematic forms and their psychological bases*, University of Texas Press.

**Engagement type(s).** Corroboration (1).

**Contributor.** James E. Cutting, Susan Linn Sage Professor of Psychology Emeritus, Cornell University.

**Outcomes.**

1. **Corroboration — cinema-kernel four-criteria empirical grounding and *Psycho* shower-scene discrimination (Paper 1 § 4.2).** Cutting's empirical taxonomy of cinematic forms provides grounding for three of the four kernel criteria of the cinema kernel (prior, monogenic, inescapable). The 78-cuts-in-45-seconds threshold from Cutting, DeLong & Nothelfer (2010) is the empirical anchor for Paper 1 § 4.2's exploitation-target discrimination between Hitchcock's *Psycho* shower scene and Eisenstein's Odessa Steps sequence — two works sharing a coordinate but differing in what they exploit (density vs. juxtaposition).

**Scope limits.** Cutting's work and correspondence do **not** confirm the comma formulation for the cinema kernel. Paper 1 § 4's introduction states this explicitly. The engagement is content-specific, not a programme-level endorsement.

**Primary sources and repo artefacts.**
- Canonical record: [`validation/RESOLVED.md` → Corroboration → James E. Cutting](../../validation/RESOLVED.md#corroboration)
- Acknowledgement: [`ACKNOWLEDGEMENTS.md`](../../ACKNOWLEDGEMENTS.md) under Corroboration
- Paper locations: Paper 1 v11.4 § 4.2, § 4

---

## Patterns observed so far

This section is updated when patterns stabilize across enough entries to warrant a generalization. Single-instance observations are kept with their entry above rather than generalized here.

As of 2026-04-21 the record contains three entries. The visible pattern:

- **Engagement is domain-specific, not programme-level.** All three entries are corroboration or correction of specific claims in specific sections of specific papers. None of the contributors has engaged the programme at the thesis level. This is consistent with Paper 2's prediction that correction architecture operates at the level of claims, not at the level of frameworks.

- **Corroboration and correction are both cumulative.** The Tymoczko and Cutting entries document engagement that preceded the GitHub repository launch but is cited here because the repository is now the canonical record. The suhr entry documents engagement that arrived after launch. The architecture absorbs both without distinction.

- **Venue-norm observations are a distinct category.** Paper 2's current form does not anticipate that scholarly communities may have venue-specific norms about AI-assisted drafting that are stricter than the programme's disclosure requirement. The Lean Zulip entry documents one such norm and the programme's response. A future Paper 2 revision could absorb this as a refinement: disclosure is necessary but not sufficient; venue-specific drafting-form norms must also be respected.

- **Skepticism is a valid outcome.** Tymoczko's documented skepticism of the Pythagorean-comma-as-operative claim is a recorded engagement. It is not a correction (nothing was wrong) or a validation (nothing was confirmed). It is a specialist's documented hypothesis about a specific paper claim, and the paper treats it as such. The architecture needs a way to surface skepticism without converting it into either confirmation or refutation.

Further patterns will be added as the record accumulates.

---

## Changelog
- 2026-04-21: File created. Initial entries: Lean Zulip thread (2026-04-18/19), Tymoczko correspondence (2026), Cutting correspondence (2026).
- 2026-04-19: Lean Zulip entry extended. Added Outcome 4 (three follow-on theoretical pointers from suhr producing Paper 5 v1.3 and claim-file *Broader theoretical context* subsection); added scope-limit bullet on follow-on pointers; added *Candidate pattern surfaced (AI synthesis; not yet paper content)* subsection documenting the three-framework-trajectory reading of the temperament optimization literature with explicit disclosure of AI-synthesis origin and reasons for non-integration into any paper at this time.
