# Resolved validation items

This file records external engagements with the paper series that have produced outcomes the papers absorbed — corrections, validations, corroborations, and formalizations. It serves as the project's memory of what the validation architecture has actually produced, and distinguishes between types of engagement for readers inferring the programme's external reception.

Four categories are kept deliberately distinct:

- **Corrections.** A specialist identified a specific error, and a paper was revised to fix it.
- **Validations.** A specialist reviewed a specific open claim and confirmed or corrected its formulation.
- **Corroboration.** Independent scholarly work (pre-existing or contemporaneous) converges on a paper's claim without the scholar having reviewed FalseWork at the programme level. This is not validation in the review sense — it is inter-framework agreement that counts as empirical grounding for a claim without counting as endorsement of the framework producing the claim.
- **Formalizations.** A formal proof, Lean verification, or equivalent machine-checkable derivation of a paper claim.

Each entry names the contributor's scope carefully, to avoid overstating what they did. Scope limits are stated explicitly because overclaiming is the dominant failure mode for scholarly-infrastructure projects of this kind.

---

## Corrections

### 2026-04-21 — suhr: Paper 5 §§ 2.2, 4.2, 7.1
- **Contributor:** **suhr** (Lean Zulip display name; attribution placeholder subject to update on request).
- **Venue:** Lean Zulip chat, `#new members`, topic *Music-kernel + Pythagorean comma formalization target*, [2026-04-19 reply](https://leanprover.zulipchat.com/#narrow/channel/113489-new-members/topic/Music-kernel.20.2B.20Pythagorean.20comma.20formalization.20target/near/588730901).
- **Scope:** three corrections to Paper 5 v1.1 —
  1. § 2.2 continued-fraction narration skipped the `24/41` convergent of `log₂(3/2)` and referred to `31/53` as "the next" convergent after `7/12`. Fixed: narration now runs `7/12 → 24/41 → 31/53`, with `41-TET` named alongside `12-TET` and `53-TET`.
  2. §§ 2.2, 4.2, 7.1 claims about "practically usable temperaments" conflated minimization of the Pythagorean comma with practicality in other harmonic contexts (11-limit, 7-limit, 5-limit — Baker-type problems over extended prime bases). Fixed: all three statements re-scoped to "equal temperaments that minimize the Pythagorean comma specifically," with explicit acknowledgement of other harmonic-optimization targets.
  3. § 2.2 "53-TET is impractical for keyboard construction" was anachronistic given isomorphic-keyboard instruments (Bosanquet 1875; Lumatone; Kite guitar). Fixed: remark removed; replaced with a short note pointing to the isomorphic-keyboard landscape.
- **Resolution:** corrected. Paper 5 v1.1 → v1.2. Tracked at [Issue #9](https://github.com/thefalsework/papers/issues/9). Archived at [`papers/pythagorean-shared-floor/archive/v1.2.docx`](../papers/pythagorean-shared-floor/archive/v1.2.docx).
- **Scope limits:** the corrections resolved the three specific errors listed. The six-point music-kernel check ([`music-kernel-umbrella`](claims/music-kernel-umbrella.md)) and the Pythagorean explanatory debts ([`pythagorean-explanatory-debts`](claims/pythagorean-explanatory-debts.md)) remain open.
- **Crediting:** [`ACKNOWLEDGEMENTS.md`](../ACKNOWLEDGEMENTS.md) under Corrections.

---

## Validations

*None yet.* The first active validation engagement is expected on one of the open items in [`OPEN.md`](OPEN.md). The outreach drafts in [`docs/outreach/`](../docs/outreach/) document the engagement paths opened for each specialist domain.

---

## Corroboration

### Dmitri Tymoczko — Paper 1 § 4.1: three-way Coltrane discrimination and exploitation-target refinement
- **Contributor:** Dmitri Tymoczko (Professor of Music, Princeton University).
- **Primary sources:** Tymoczko (2006), "The geometry of musical chords," *Science* 313(5783), 72–74. Tymoczko (2011), *A Geometry of Music: Harmony and Counterpoint in the Extended Common Practice*, Oxford University Press.
- **Additional engagement:** personal correspondence with Chris Brink, 2026.
- **Scope:**
  1. **Independent corroboration** of FalseWork's three-way structural discrimination of Coltrane's output — without being asked to validate the classifications, Tymoczko described Coltrane's *A Love Supreme*, *Giant Steps*, and late period mapping onto the same three structural fields (diatonic, symmetric/quasi-symmetric, chromatic) from his own geometric framework, noting that this tripartition organizes the entire history of twentieth-century music from Rimsky and Debussy onward. The convergence of two independent analytical systems on the same three-way mapping is the strongest empirical grounding the music kernel has; Paper 1 names it as such.
  2. **Refinement of the exploitation target** for *Giant Steps* — from the circle of fifths (as originally framed by FalseWork) to the major-third cycle's specific topological properties within the symmetric territory. The refinement was absorbed into Paper 1 prior to v11.0.
- **Scope limits:** Tymoczko has not reviewed the five-position derivation, the G ∧ R ∧ C condition, the kernel/comma topology at the programme level, or the other papers in the series. His engagement is specific to the music-kernel empirical demonstrations. In the same correspondence, Tymoczko expressed **skepticism** that the Pythagorean comma remains operative as a structural condition for practitioners working in fixed temperament — an open theoretical caveat documented at Paper 1 § 4.1 and § 4.4 that is treated as a hypothesis pending the proxy feature program, not as a resolved claim. The corroboration counts as inter-framework convergence, not as endorsement of FalseWork's broader framework.
- **Absorbed in:** Paper 1 v11.4 § 4.1 (abstract, body text, references). Exploitation-target refinement absorbed before v11.0.
- **Crediting:** [`ACKNOWLEDGEMENTS.md`](../ACKNOWLEDGEMENTS.md) under Corroboration.

### James E. Cutting — Paper 1 § 4.2 and cinema-kernel four-criteria evidence
- **Contributor:** James E. Cutting (Susan Linn Sage Professor of Psychology Emeritus, Cornell University).
- **Primary sources:** Cutting, DeLong & Nothelfer (2010), "Attention and the evolution of Hollywood film," *Psychological Science* 21(3), 432–439. Cutting (forthcoming), *Four cinematic forms and their psychological bases*, University of Texas Press.
- **Additional engagement:** personal correspondence with Chris Brink, 2026.
- **Scope:**
  1. **Empirical grounding** for three of the four kernel criteria of the cinema kernel (prior, monogenic, inescapable) via Cutting's empirical taxonomy of cinematic forms.
  2. **The 78-cuts-in-45-seconds threshold analysis** for Hitchcock's *Psycho* shower scene — the anchor for Paper 1 § 4.2's exploitation-target discrimination between Hitchcock and Eisenstein's Odessa Steps sequence, both of which share the coordinate *Exploitation · montage · SELF_CONSTRAINS × EXPOSED × EXPLOITS* but differ in what they exploit (density vs. juxtaposition).
- **Scope limits:** Cutting's work does **not** confirm the comma formulation for the cinema kernel. Paper 1 § 4's introduction explicitly notes this: *"Cutting's correspondence provides strong empirical grounding for three of the four kernel criteria (prior, monogenic, inescapable) but does not confirm the comma formulation, which is treated as a hypothesis throughout this section."* The correspondence is content-specific, not a programme-level endorsement.
- **Absorbed in:** Paper 1 v11.4 § 4 (abstract, body text, references). Cutting's published work absorbed before v11.0; the 2026 personal correspondence cited at v11.0+.
- **Crediting:** [`ACKNOWLEDGEMENTS.md`](../ACKNOWLEDGEMENTS.md) under Corroboration.

---

## Formalizations

*None yet.* The Lean 4 formalization target is specified at [`lean/README.md`](../lean/README.md); no mathlib-level formal proof of any paper claim has been produced. Engagement is tracked at [`docs/outreach/lean-zulip-post.md`](../docs/outreach/lean-zulip-post.md), and the first Zulip engagement (suhr, 2026-04-19) produced a correction rather than a formalization — recorded under Corrections above.

---

## Template for new entries

When a new item moves from [`OPEN.md`](OPEN.md) to this file, use:

```
### YYYY-MM-DD — <contributor-short-name>: <one-line description>
- **Contributor:** <name> (<affiliation if public>)
- **Venue:** <specific URL / conference / correspondence>
- **Scope:** <what specifically was done>
- **Scope limits:** <what was NOT done — guards against overstating>
- **Resolution:** corrected / verified / partially verified / disputed / withdrawn
- **Paper revision absorbing outcome:** Paper N v<X.Y> § <section> (<date>)
- **Crediting:** [`ACKNOWLEDGEMENTS.md`](../ACKNOWLEDGEMENTS.md) under <category>
```

The scope-and-scope-limits discipline is load-bearing. It is easy to overstate what an external engagement produced; the architecture guards against this by requiring explicit limits in every entry.
