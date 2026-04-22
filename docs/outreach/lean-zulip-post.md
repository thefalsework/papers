# Outreach draft — Lean Zulip introduction post

**Purpose.** Introduce the formalization targets to the Lean community on Zulip and invite collaboration.
**Target channel.** `#mathlib4 > general` or `#new members`; may also post in `#maths > category theory` for tier-2/3 points.
**Length target.** ≤ 300 words; link-heavy rather than prose-heavy.
**Tone.** Technical, specific, non-imposing; match Zulip community norms.
**Related:** [`../../lean/README.md`](../../lean/README.md), [`../../validation/claims/music-kernel-umbrella.md`](../../validation/claims/music-kernel-umbrella.md).

---

## Subject line

> Formalization opportunity: small endofunctor-on-poset theorems motivated by music theory and Pythagorean comma

## Post body

Hi all — I am the maintainer of [thefalsework/papers](https://github.com/thefalsework/papers), an open-source research programme on structural incompleteness across domains (CC-BY-4.0, 5 papers, ongoing). The programme has a well-defined Lean 4 formalization target that I think would suit someone looking for a small-to-medium project with mathlib4.

The primary target is the music-kernel endofunctor formalization from Paper 3 § 4. Concretely, six elementary mathematical claims:

- **Tier 1** (each ~50–100 lines, mathlib has everything needed):
  - Irrationality of `log₂(3/2)` via FTA.
  - `Fix(D) = {∅}` for `D(X) = X ∪ (X + α)` on `Finset (ℝ / ℤ)`, by cardinality.
- **Tier 2** (mathlib has the frameworks; glue required):
  - Lambek's lemma applied to this specific `C` and `D` ⇒ no terminal coalgebra for `D`.
  - Weyl equidistribution (or just density) ⇒ colimit of `D`-iteration escapes the ambient category.
- **Tier 3** (Baker's theorem is not yet in mathlib, so a qualitative version for now):
  - `ℤ / 12ℤ` quotient structure and the musical `H = ⟨4⟩` (Giant Steps) substructure.
  - Non-vanishing of `|12 log 3 − 19 log 2|` via FTA (qualitative Pythagorean comma).

Full specifications with paper cross-references:

- **Claim statements:** [validation/claims/music-kernel-*.md](https://github.com/thefalsework/papers/tree/main/validation/claims)
- **Formalization target README:** [lean/README.md](https://github.com/thefalsework/papers/blob/main/lean/README.md)

A first contribution picking any one Tier 1 point would be very welcome. I am happy to discuss approaches, review early drafts, and credit contributors by name in the corresponding paper's revision note. The repo has a CONTRIBUTING.md with acceptance criteria for formalization PRs.

The broader theoretical framing is not a prerequisite — the six points stand on their own as elementary mathematics. Questions about the framing are also welcome; the repo is the best place for them.

Happy to answer anything here.

— Chris Brink / [@ChrisBrink](https://github.com/node0000)  (`chris@falsework.dev`)

---

## Posting log

| Date | Channel / topic | Permalink | Notes |
|---|---|---|---|
| 2026-04-19 | `#new members` > *Music-kernel + Pythagorean comma formalization target* | [link](https://leanprover.zulipchat.com/#narrow/channel/113489-new-members/topic/Music-kernel.20.2B.20Pythagorean.20comma.20formalization.20target/near/588730901) | Initial post. Bare-URL variant (no `[text](url)` markdown). |

## Responses received

| Date | Contributor | Venue | Summary | Resolution |
|---|---|---|---|---|
| 2026-04-19 | **suhr** (Zulip display name; placeholder pending consent) | Lean Zulip, same topic as initial post ([message link](https://leanprover.zulipchat.com/#narrow/channel/113489-new-members/topic/Music-kernel.20.2B.20Pythagorean.20comma.20formalization.20target/near/588730901)) | Three substantive corrections to Paper 5 v1.1: (i) prose at § 2.2 skipped the 24/41 convergent; (ii) "practically usable temperaments" claims at §§ 2.2, 4.2, 7.1 conflated Pythagorean-comma optimization with general musical practicality (31-TET/41-TET/53-TET optimize different harmonic targets); (iii) the "53-TET is impractical for keyboard construction" remark is outdated given Bosanquet 1875, Lumatone, and Kite guitar. | [Issue #9](https://github.com/thefalsework/papers/issues/9) · Paper 5 v1.1 → [v1.2](https://github.com/thefalsework/papers/blob/main/papers/pythagorean-shared-floor/archive/v1.2.docx) · listed in [`ACKNOWLEDGEMENTS.md`](../../ACKNOWLEDGEMENTS.md). Reply posted to Zulip topic asking for preferred attribution form. |
| 2026-04-19 | **Chris Henson** (Zulip display name) | Lean Zulip, same topic | Distinguished the mathematical topic from the AI-use concern; recommended John Baez's *Tuning Book* (https://math.ucr.edu/home/baez/tuning_book/); observed that the most interesting part of formalization is "setting up the exact statement of what you want to verify," and suggested specifically the relationship between "optimal" N-TET and the corresponding continued fraction. | New claim file [`validation/claims/optimal-ntet-continued-fraction.md`](../../validation/claims/optimal-ntet-continued-fraction.md) created to isolate the theorem Henson named, with a tentative Lean 4 signature and explicit invitation for statement-level feedback. [`validation/claims/music-kernel-01-irrationality.md`](../../validation/claims/music-kernel-01-irrationality.md) updated in the same commit with a tentative Lean signature for `Irrational (Real.logb 2 (3/2))`. |
| 2026-04-19 | Lean Zulip moderators (not named here; see thread permalink for primary source) | Lean Zulip, same topic | Raised concern about AI-drafted posts in that venue; stated the community has moved from "discouraged" to "disallowed" on this practice. | Author committed to not drafting Zulip posts with AI assistance going forward, without making a programme-level commitment. Rationale: Paper 2's correction architecture treats AI disclosure as the primary transparency requirement and does not constrain drafting *form* across venues; Lean Zulip's norm constrains drafting form in that venue; the two are compatible. Recorded as a venue-norm observation at [`docs/observations/validation-architecture-outcomes.md`](../observations/validation-architecture-outcomes.md). Not a paper-level claim change; not recorded in `RESOLVED.md`. |

## Outcomes (repo changes flowing from this thread)

- **Paper 5 v1.1 → v1.2** — three corrections at §§ 2.2, 4.2, 7.1 from suhr; archived at [`papers/pythagorean-shared-floor/archive/v1.2.docx`](../../papers/pythagorean-shared-floor/archive/v1.2.docx).
- **New claim file** — [`validation/claims/optimal-ntet-continued-fraction.md`](../../validation/claims/optimal-ntet-continued-fraction.md), prompted by Chris Henson's observation that the most interesting formalization work is in setting up the exact statement.
- **New tentative Lean signature** — [`validation/claims/music-kernel-01-irrationality.md`](../../validation/claims/music-kernel-01-irrationality.md) gained a "Proposed Lean signature" block (`Irrational (Real.logb 2 (3/2))` plus two equivalent forms), explicitly inviting statement-level feedback.
- **Canonical records updated** — [`validation/RESOLVED.md`](../../validation/RESOLVED.md) under Corrections (suhr entry); [`ACKNOWLEDGEMENTS.md`](../../ACKNOWLEDGEMENTS.md) under Corrections (suhr entry); [`papers/INDEX.md`](../../papers/INDEX.md) and [`README.md`](../../README.md) updated to Paper 5 v1.2.
- **GitHub issue** — [#9](https://github.com/thefalsework/papers/issues/9) tracks suhr's corrections from proposal to absorption.
- **Programme-level record** — thread logged at [`docs/observations/validation-architecture-outcomes.md`](../observations/validation-architecture-outcomes.md) alongside the Tymoczko and Cutting correspondence records; that file is the per-engagement index across all venues and serves as input for Paper 2 v-next's empirical grounding.

## Notes for the draft going forward

- This draft is the authoritative record of the 2026-04-19 outreach and its outcomes.
- If the Lean community is re-engaged on the formalization target in the future, a fresh draft should be created in the same directory (e.g. `lean-zulip-post-2.md`) rather than editing this one. Preserve the 2026-04-19 record as-is so the outcomes above remain auditable.
- Future Lean-community engagement should use human-authored posts; repo-side work (claim files, Lean signatures, paper revisions) is unaffected by the venue-norm observation and continues under the standard AI-disclosure discipline documented in the repo root.
