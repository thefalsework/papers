# Transformational Signatures of the Four Positions — a bridge note

**Author / disclosure.** Chris Brink, independent researcher (`chris@falsework.dev`). Drafted with AI assistance; all commitments are the author's. Working note, not a paper.

**Status.** **Exploratory `[A]`.** This note proposes a falsifiable operationalisation of the four-position partition in the vocabulary of transformational music theory (Lewin / neo-Riemannian / Popoff). Nothing here is kernel-checked; the four-position partition itself is `[K]` (`papers/comma-formal-structure-note.md`, `Positions/Partition.lean`), but **every mapping in this note from the Heyting cells to a transformational signature is an interpretive bridge `[A]`** and is the contestable content.

**Purpose.** Stage-two prep for the Popoff correspondence. The question this answers: *can his transformational data adjudicate the framework's interpretive placements without circularity?* Conclusion: yes, **if** the cell-placement of a work is sourced independently of its transformational signature, and the signature is treated as a derived prediction to be checked — not as the definition of the cell. This note states the four signatures, the measurable proxies, the non-circularity guard, and the sharp test case (Berg vs. Schoenberg).

---

## 1. The non-circularity discipline (read first)

The entire exercise is worthless if circular. The trap: define "Exploitation" as "drives a symmetric cycle," then declare cycle-driving passages Exploitation. That proves nothing — it relabels his data in our vocabulary.

The guard, in three layers that must stay separate:

1. **Cell (definition, `[K]`).** A Heyting predicate on where a work's image sits relative to the kernel image `K`: Infrastructure `img ≤ K`; Distribution `img ⊓ K ≠ ⊥ ∧ img ⊓ Kᶜ ≠ ⊥`; Exploitation `img ≤ Kᶜᶜ ∧ ¬(img ≤ K)`; Refusal `img ≤ Kᶜ`. Defined in the lattice, independent of any transformation.
2. **Placement (sourcing, must be independent).** To *place* a specific work in a cell for the test, the argument may use **only** (a) the framework's existing interpretive/historical readings, made on grounds other than transformation-counting, or (b) the pitch-class lattice content directly. It may **not** use the transformational signature of §3.
3. **Signature (derived prediction, `[A]`).** A predicted transformational fingerprint that *follows from* the cell. This is what gets checked against his networks.

The test is valid only when placement (2) is sourced independently of signature (3). If the only way to place a work is by its signature, there is no test — there is a tautology.

---

## 2. The kernel in the transformational register

The framework's kernel is the **perfect fifth** as generative operation (ratio 3:2; formal avatar in `Div12` = the tritone, the ordinary element). Its **structural ground `K`** in music is the **fifth-generated diatonic collection** and tonal centricity — the structure a stack of fifths produces. The **comma** is the non-closure of the fifth cycle, managed by equal temperament.

Three regions of the lattice, read into transformational structure:

- **`K` (kernel image)** — the diatonic, fifth-organised ground; a recoverable tonal centre.
- **`Kᶜ` (complement)** — organisation by a generator *disjoint from the fifth*: the serial row, where all twelve pitch-classes are equally weighted and no transposition orbit is privileged.
- **`Kᶜᶜ ∖ K` (closure-residue)** — the **symmetric divisions of the octave**: the cyclic groups `⟨Tk⟩` for `k | 12`, `k ∉ {1}` (whole-tone `⟨T2⟩`, octatonic/dim-7 `⟨T3⟩`, hexatonic/augmented `⟨T4⟩`, tritone `⟨T6⟩` — Messiaen's modes of limited transposition). These exist *because* the octave's symmetric subdivisions are the divisors of 12 — the same arithmetic as the kernel lattice (`why-twelve-tet.md`). They are not in the diatonic ground, but they are in its chromatic closure: exactly the closure-residue.

This reading is the framework's existing `[A]` prose (Infrastructure = tonal-in-key; Distribution = equal-tempered comma-spreading; Exploitation = symmetric-cycle residue, e.g. Coltrane's `⟨T4⟩`; Refusal = serial). The note's only new step is making the transformational fingerprint of each explicit and measurable.

---

## 3. The four signatures (derived predictions)

| Cell | Organising group of the network | Tonal centre | Canonical fingerprint |
|---|---|---|---|
| **Infrastructure** | Diatonic-confined: `P, L, R` and transpositions kept within one key region; generated group acts inside a diatonic neighbourhood | **Strong, stable** | Bach WTC within a key — moves orbit a fixed centre |
| **Distribution** | Wide — ranges over the full `T/I` vocabulary (chromatic) — but the orbit stays **recentred**: reference recovered repeatedly, no single symmetric cycle dominates | **Recoverable, repeatedly re-established** | Late-Romantic chromatic tonality; "managed everywhere, concentrated nowhere" |
| **Exploitation** | A proper **symmetric subgroup `⟨Tk⟩`, `k \| 12`, `k ≠ 1`** organises the passage, driven *past its closure* as material | **Suppressed / ambiguous** by design — the symmetric cycle has no tonic | Coltrane *Giant Steps* `⟨T4⟩`; film-music hexatonic "wonder" cues (P/L alternation) |
| **Refusal** | The **serial group** (row symmetries `P, I, R, RI` on an ordering) replaces pitch-centric moves; organising principle is an *ordering*, not a transposition orbit | **Absent / non-recoverable** (flat pc distribution) | Schoenberg / Webern integral serialism |

The discriminating axes are two, both computable: **(i) the organising subgroup** (diatonic-confined / full-but-centred / symmetric-cyclic / serial) and **(ii) tonal-centre recoverability** (strong / recoverable / suppressed / absent).

---

## 4. Measurable proxies (runnable, incl. via Opycleid)

- **Organising subgroup.** From an annotated network, take the subgroup of `T/I` generated by the transformations labelling its arrows; classify it as diatonic-confined, full-but-centred, symmetric-cyclic `⟨Tk⟩`, or serial. This is native Opycleid territory (it already computes group/monoid actions and orbits).
- **Tonal-centre recoverability.** Krumhansl–Schmuckler key-finding on the passage's pitch-class distribution → centre *clarity* and *concentration* (the same instrument used in `scripts/wolframtones-classification-experiment.py`). Equivalently: presence/absence of an orbit fixed point under the network's group.

Two numbers per passage — (organising-subgroup class, centre clarity) — and the four cells predict four distinct regions of that 2-D space.

---

## 5. Test cases with independently-sourced placements

Placements below are fixed by the framework's *existing* readings or by lattice content — **not** by the signatures — so the signature check is non-circular.

| Work | Placement (independent source) | Predicted signature |
|---|---|---|
| Bach WTC, single key | Infrastructure (in-key, comma absorbed) | diatonic-confined; strong centre |
| Wagner, *Tristan* chromatic tonal | Distribution (chromatic, still referential) | full vocabulary; recoverable centre |
| Coltrane, *Giant Steps* | Exploitation (existing anchor; Tymoczko `⟨T4⟩`) | `⟨T4⟩` cycle dominates; centre suppressed |
| Lehman hexatonic film cues | Exploitation (closure-residue cycle) | hexatonic P/L cycle; centre suppressed |
| Schoenberg, op. 25 / Webern | Refusal (serial replaces fifth) | serial group; centre absent |

If the measured fingerprints land where predicted, the operationalisation holds. If they scatter, the framework has found a real limit — which is the point.

---

## 6. The sharp test: Berg vs. Schoenberg

This is the one to put in front of Popoff, because **he has analysed Berg op. 5/2** and the prediction is sharp, falsifiable, and computable on his own material.

The framework places **Berg = Exploitation** and **Schoenberg = Refusal** — both twelve-tone, but distinguished on grounds independent of transformation-counting (Berg keeps tonal/triadic residue and tonal reference inside the row; Schoenberg's break is polemically total). The framework therefore predicts they **separate on a measurable axis** despite sharing the serial apparatus:

> **Prediction.** Berg's serial passages retain **recoverable tonal centres / triadic residue** (Krumhansl clarity above the serial baseline; triadic subsets surfacing in the network), whereas Schoenberg's do **not** (flat distribution, no recoverable centre). The organising group is "serial" for both; the *centre-recoverability* axis splits them.

This is exactly the kind of claim his networks can confirm or kill, on repertoire he already works in. A clean separation is corroboration the framework did not manufacture; a null result (Berg measures as flat as Schoenberg) falsifies the Berg = Exploitation placement, which is information either way.

---

## 7. What would kill this

- **Collapse of the discriminator.** If symmetric-cycle passages and serial passages do not separate on (subgroup, centre) — e.g. if Exploitation cycles measure as centre-absent and so do Refusal rows, with no further distinguishing structure — then the four signatures collapse to fewer than four, and the partition is not transformationally legible.
- **Placement leakage.** If, in practice, the only available way to place works is by their signatures (no independent interpretive or lattice-content source), the study is circular and must be abandoned, not patched.
- **The bridge map is contestable.** The step from "a passage's pitch-class content" to "`img` in the Heyting lattice" is itself `[A]` and not unique (generate-the-subgroup vs. characteristic-in-`Div12` vs. content-as-set). A reviewer who rejects the map rejects the study. State it as a modelling choice, defend it, do not hide it.

---

## 8. Honest standing

The four-position partition is `[K]`. Its musical prose gloss is `[A]`, long-standing. This note adds a *third* layer — transformational fingerprints — that is `[A]` built on `[A]`, and whose only virtue is that it is **computable and falsifiable** against real annotated corpora rather than asserted. That is the same upgrade the formal side already made (replacing "Wolfram-verified" with kernel-checked theorems): it does not make the interpretation true, it makes it *testable*. The value is entirely in the testability, and the test only counts if §1's discipline holds.
