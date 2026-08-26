# Music cell study — design document (pre-registration NOT yet earned)

**Status: [O] / design phase. Version 0.1, 2026-08-26. No predictions are
registered by this document and none may be inferred from it.** This is the
analysis that must be survived *before* a registration is written. The
protocol shape it instantiates is the one validated on Mathlib
(`mathlib-study/` scripts 09–16): independent ground truth fixed first,
cells computed blind, permutation null, resolution pre-check, fixed
interpretation table, two implementations.

## 1. What the study would test

The four-position partition at the tritone kernel in Div12 is [K], and the
work→cell dictionary for music (`papers/bach-at-the-kernel.md` §1–2) is [A]:
Infrastructure ↔ the tritone domesticated, Refusal ↔ the augmented world,
Exploitation ↔ the diminished-seventh machinery, Distribution ↔ the
whole-tone / excluded-middle programme. The Mathlib arc (2026-08-26) showed
exactly what such a dictionary is worth untested — and what testing does to
it: one gloss (Exploitation) came out a corpus regularity at 16/16; the
R/D spatial glosses died in both directions. The music dictionary has the
same epistemic standing the Mathlib one had on 08-25: plausible, worked,
and unpaid.

The testable core: **do musical events that map algebraically to a cell
occur in contexts that independent annotators — who have never heard of
this program — label in ways the cell's gloss predicts?**

## 2. What Mathlib had that music must replace

The Mathlib study rested on two uncontestable inputs:

1. **The order** — imports, enforced by a compiler. Nobody argues about
   what depends on what.
2. **The ground truth** — module name paths, written by the library's own
   authors for their own purposes, machine-readable, and blind to us.

Music has neither for free. The candidate replacements, with their costs:

- **The algebra.** Use the fixed Div12 subgroup lattice (six elements;
  every element's cell relative to ⟨6⟩ is forced by the [K] theorem:
  I = {⊥, ⟨6⟩}, R = {⟨4⟩}, E = {⟨3⟩}, D = {⟨2⟩, ⊤}). No corpus-derived
  poset: dependency relations between musical works (borrowing, quotation,
  influence) are contestable at every edge, which is disqualifying — the
  Mathlib study's authority came precisely from the edge relation being
  beyond argument. Consequence: unlike Mathlib, the algebra contributes no
  statistics; all statistics live in the *mapping* of corpus events onto
  the six elements.
- **The event→element mapping (THE contestable dictionary — the study's
  actual subject of discipline).** A sonority (verticality or short window)
  must map to a lattice element by a rule fixed before any ground truth is
  seen. Candidate rule, to be stress-tested in Phase 0: map a pitch-class
  set to the smallest subgroup of Z12 (transposition-closure) containing
  its interval structure's generated group, or to ⊥ when it generates none
  of the six; events generating all of Z12 map to ⊤. Every choice here
  (window size, chord segmentation, enharmonic policy) is a degree of
  freedom and must be pinned in Phase 0, blind.
- **The ground truth.** Third-party annotated corpora built for unrelated
  purposes: Roman-numeral / harmonic-function annotation sets
  (When-in-Rome aggregation; BPS-FH; TAVERN; the ABC Beethoven corpus).
  These supply labels like "applied dominant", "modulatory pivot",
  "diminished-seventh chord resolving as...", per event, from annotators
  blind to this program.

## 3. Known failure modes to pre-check (lessons already paid for)

- **Saturation (Mathlib v1's death).** The mapping may send nearly all
  common-practice sonorities to ⊥ or ⊤ (triads and seventh chords generate
  all of Z12 or nothing among the six). If the E-relevant class
  (diminished-seventh-type, mapping to ⟨3⟩) or R-relevant class
  (augmented-type, ⟨4⟩) is vanishingly rare, the null cannot move.
  Phase 0 measures occupancy of all six elements over the corpus BEFORE
  any prediction is written; the inclusion rule (minimum event counts per
  cell) is fixed from those counts alone.
- **Degeneracy by construction (CA v1.0's death).** If the mapping is
  insensitive to what the music actually does (e.g., every window of
  sufficient size generates Z12), the study is dead a priori. Phase 0
  includes the check: does the element distribution differ between
  repertoires that must differ if the mapping sees anything (Bach chorales
  vs. Debussy)? This is a *sanity gate on the instrument*, run on corpora
  that will then be EXCLUDED from the registered test.
- **Gloss overreach (Mathlib G2/G3's death).** Predictions must be derived
  from the dictionary as written, per cell, each able to fail alone — and
  after the R/D outcome on Mathlib, any spatial/geographic phrasing is
  banned from the predictions. What survives as predictable: contexts.
  Sketch (NOT registered): E-mapped events are over-represented at
  annotated modulation/pivot sites relative to the permutation null
  (the "mining the residue" gloss); R-mapped events are under-represented
  in common-practice corpora and their rate rises with repertoire date
  (the "empty cell fills late" reading from the Bach essay). Both sketches
  must be re-derived and sharpened at registration time from the corpus
  counts of Phase 0 only.
- **Null choice.** The analogue of the name-permutation null: shuffle the
  annotation labels across events (preserving label counts and per-piece
  structure), recompute the statistic. Preserves everything about the
  mapping and the algebra; breaks only the alignment under test. Strata:
  per piece, to keep piece-level style out of the null.

## 4. Phases

- **Phase 0 (feasibility, blind).** Pick corpora; pin the event→element
  mapping; measure element occupancy and instrument sanity (chorales vs.
  Debussy gate); publish the counts. No ground-truth labels touched.
  Deliverable: `music-study/PHASE0.md` + scripts + counts, committed.
- **Phase 1 (registration).** Predictions per cell with fixed
  interpretation table and failure semantics, written from Phase 0 counts
  only. Committed before any label is read by any script.
- **Phase 2 (run).** Two implementations, exact agreement required on the
  contingency tables; permutation null; postscripts win or lose.

## 5. What this cannot show, whatever happens

A positive result would show the [A] dictionary predicts independent
annotation practice on the tested corpora — not that music "is" the
algebra, and nothing about perception (that is `preprints/hearing/`'s
lane). A negative result kills the music dictionary's testable content on
the tested corpora, and the Bach essay's placements would then carry an
explicit unsupported-where-tested flag, exactly as the Mathlib R/D glosses
now do. Either way the essay's [K] spine (the partition theorem, the
opened square, the Div12 weld) is untouched — what would die or survive is
interpretation, which is the only part that was ever at risk.
