# Acknowledgements

This file records external contributions to [thefalsework/papers](https://github.com/thefalsework/papers) — validations, corrections, formalizations, and substantive critical engagement. Every contributor credited here has either given explicit consent to be named, or made their contribution under the handle listed here in a public forum.

The project treats attribution as a matter of record and repair, not promotion. If a named contributor asks for their credit to be changed (different name, different handle, anonymized, removed), that request is honoured and the prior state is preserved in the git history.

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the three channels through which contributions are recognized: paper-level acknowledgements in the revision note, project-level acknowledgement here, and reference letters on request for graduate-student contributors.

---

## Corrections

### 2026-04-21 — Paper 5 §§ 2.2, 4.2, 7.1

**Contributor.** **suhr** (Lean Zulip display name). Attribution placeholder; will be updated to the contributor's preferred credit form on request.

**Venue.** Lean Zulip chat, `#new members` topic *Music-kernel + Pythagorean comma formalization target*, [2026-04-19 reply](https://leanprover.zulipchat.com/#narrow/channel/113489-new-members/topic/Music-kernel.20.2B.20Pythagorean.20comma.20formalization.20target/near/588730901).

**Contribution.** Three corrections to Paper 5 v1.1:

1. The prose at § 2.2 skipped the 24/41 convergent of log₂(3/2) and referred to 31/53 as "the next" convergent after 7/12. Fixed: the continued-fraction narration now runs 7/12 → 24/41 → 31/53 and names 41-TET alongside 12-TET and 53-TET.
2. The paper's three claims about "practically usable temperaments" (§§ 2.2, 4.2, 7.1) implicitly identified practicality with minimization of the Pythagorean comma, ignoring that 31-TET, 41-TET, and 53-TET are preferred in other harmonic contexts (11-limit, 7-limit, 5-limit respectively) for reasons that are Baker-type problems over extended prime bases. Fixed: the three statements are now scoped to "equal temperaments that minimize the Pythagorean comma specifically," with explicit acknowledgement of the other harmonic optimization targets.
3. The phrase "53-TET is impractical for keyboard construction" (§ 2.2) was anachronistic: isomorphic keyboards (Bosanquet 1875; Lumatone; Kite guitar) make 53-TET and other large equal divisions of the octave physically playable. Fixed: the remark is removed and replaced with a short note pointing to the isomorphic-keyboard landscape.

**Resolution.** Paper 5 v1.1 → v1.2. Tracked at [Issue #9](https://github.com/thefalsework/papers/issues/9). Archived at [`papers/pythagorean-shared-floor/archive/v1.2.docx`](papers/pythagorean-shared-floor/archive/v1.2.docx). The v1.2 commit message names the contributor and links to their Zulip message.

---

## Validations

*No validations merged yet.*

---

## Formalizations

*No formalizations merged yet.*

---

## Maintenance

This file is updated at the same time as the paper revision or claim file that absorbs the contribution. Entries are organized by contribution type and date. The git history is the authoritative record of when entries were added and modified.
