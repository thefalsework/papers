# Acknowledgements

This file records external contributions to [thefalsework/papers](https://github.com/thefalsework/papers) — validations, corrections, formalizations, and substantive critical engagement. Every contributor credited here has either given explicit consent to be named, or made their contribution under the handle listed here in a public forum.

The project treats attribution as a matter of record and repair, not promotion. If a named contributor asks for their credit to be changed (different name, different handle, anonymized, removed), that request is honoured and the prior state is preserved in the git history.

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the three channels through which contributions are recognized: paper-level acknowledgements in the revision note, project-level acknowledgement here, and reference letters on request for graduate-student contributors.

---

## Corroboration

Entries in this section record independent scholarly work that converges on a FalseWork claim. This is not validation in the review sense — it is inter-framework agreement that counts as empirical grounding for a claim without counting as endorsement of the framework producing the claim. Each entry states the scope and the scope limits explicitly.

### Dmitri Tymoczko — independent corroboration of the three-way Coltrane discrimination (Paper 1 § 4.1)

**Contributor.** Dmitri Tymoczko, Professor of Music, Princeton University. Primary sources used in Paper 1: Tymoczko (2006), "The geometry of musical chords," *Science* 313(5783), 72–74; Tymoczko (2011), *A Geometry of Music: Harmony and Counterpoint in the Extended Common Practice*, Oxford University Press. Additional engagement: personal correspondence with Chris Brink, 2026.

**Scope.** Tymoczko's geometric framework, developed independently of FalseWork, maps Coltrane's *A Love Supreme*, *Giant Steps*, and late period onto the same three structural fields (diatonic, symmetric/quasi-symmetric, chromatic) that FalseWork's classification arrives at from a different analytical starting point. The convergence of two independent analytical systems on the same three-way mapping is the strongest empirical grounding the music kernel currently has; Paper 1 § 4.1 names it as such. In the 2026 correspondence, Tymoczko additionally refined the exploitation target for *Giant Steps* from the circle of fifths (as originally framed by FalseWork) to the major-third cycle's specific topological properties within the symmetric territory; this refinement was absorbed into Paper 1 prior to v11.0.

**Scope limits.** Tymoczko has not reviewed the five-position derivation, the G ∧ R ∧ C condition, the kernel/comma topology at the programme level, or the papers in the series other than via the Coltrane case in Paper 1 § 4.1. His engagement is specific to the music-kernel empirical demonstrations. In the same correspondence, Tymoczko expressed **skepticism** that the Pythagorean comma remains operative as a structural condition for practitioners working in fixed temperament — an open theoretical caveat documented at Paper 1 § 4.1 and § 4.4 that is treated as a hypothesis pending the proxy feature program, not as a resolved claim. The corroboration counts as inter-framework convergence, not as endorsement of FalseWork's broader framework.

**Tracked in.** [`validation/RESOLVED.md`](validation/RESOLVED.md) under Corroboration.

---

### James E. Cutting — cinema-kernel four-criteria empirical grounding and the *Psycho* shower-scene discrimination (Paper 1 § 4.2)

**Contributor.** James E. Cutting, Susan Linn Sage Professor of Psychology Emeritus, Cornell University. Primary sources used in Paper 1: Cutting, DeLong & Nothelfer (2010), "Attention and the evolution of Hollywood film," *Psychological Science* 21(3), 432–439; Cutting (forthcoming), *Four cinematic forms and their psychological bases*, University of Texas Press. Additional engagement: personal correspondence with Chris Brink, 2026.

**Scope.** Cutting's empirical taxonomy of cinematic forms provides grounding for three of the four kernel criteria of the cinema kernel (prior, monogenic, inescapable). Cutting, DeLong & Nothelfer (2010)'s 78-cuts-in-45-seconds threshold analysis is the empirical anchor for Paper 1 § 4.2's exploitation-target discrimination between Hitchcock's *Psycho* shower scene and Eisenstein's Odessa Steps sequence — two works sharing the coordinate *Exploitation · montage · SELF_CONSTRAINS × EXPOSED × EXPLOITS* but differing in what they exploit (density vs. juxtaposition).

**Scope limits.** Cutting's work and correspondence do **not** confirm the comma formulation for the cinema kernel. Paper 1 § 4's introduction explicitly notes this: *"Cutting's correspondence provides strong empirical grounding for three of the four kernel criteria (prior, monogenic, inescapable) but does not confirm the comma formulation, which is treated as a hypothesis throughout this section."* The engagement is content-specific, not a programme-level endorsement.

**Tracked in.** [`validation/RESOLVED.md`](validation/RESOLVED.md) under Corroboration.

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

**Tracked in.** [`validation/RESOLVED.md`](validation/RESOLVED.md) under Corrections.

---

## Validations

*No validations merged yet.*

---

## Formalizations

*No formalizations merged yet.*

---

## Maintenance

This file is updated at the same time as the paper revision or claim file that absorbs the contribution. Entries are organized by contribution type and date. The git history is the authoritative record of when entries were added and modified.
