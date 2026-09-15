# Pocket study: which observers commute with time?

*Registered spec, 2026-09-15, before any computation beyond the hand
calculations recorded here. Context: the program can already
enumerate static pockets of reducibility (observers with high
compression, low phantom mass, trace-ordinariness intact — the
frontier plot of the observer ledger). Wolfram's notion requires
more: the coarse-graining must commute with evolution. Yesterday's
theorem (`timeStep_not_observer`) proved time and observation are
different operations; this study asks when they nevertheless
commute. The background conjecture, from external notes: "the
lattice of dynamics-compatible sublocales" — a rule is irreducible
when that lattice is trivial between its endpoints. Whether that is
a theorem or a restatement is exactly what this study begins to
decide.*

## Setup

P a finite poset; a **step** is a single-edge addition (a, b),
P′ = transitive closure (perturbation-study conventions). Ground set
fixed. Observers are the classified nuclei: j_S for S ⊆ P, acting on
D(P), and the *same support* S acting as j′_S on D(P′).

The evolution map on worlds is the canonical forward map
**cl′ : D(P) → D(P′)**, down-closure in the new order (the left
adjoint of the inclusion D(P′) ⊆ D(P); on principal cones it is
exactly the cone update ↓p ↦ ↓′p of the perturbation study). For a
single added edge: cl′(U) = U ∪ ↓a if U meets ↑b, else U.

**Definition (dynamical compatibility).** S is *compatible with the
step* iff squint-then-evolve equals evolve-then-squint:

    ∀ U ∈ D(P) :  cl′( j_S(U) ) = j′_S( cl′(U) ).

A **dynamical pocket** (for kernel p) is a compatible S whose trace
additionally keeps ↓p ordinary — a static pocket that survives the
step.

## Hand lemmas (registered; oracle must confirm each)

**P0 (endpoints commute).** S = P gives j = id on both sides:
commutes trivially. S = ∅ gives the blind observer j ≡ ⊤; since
cl′ fixes the full carrier, both composites are constant ⊤:
commutes. The endpoints of the notes' conjectured lattice exist.

**P1 (the middle is non-empty — the future-watcher).** P =
2-antichain {a, b}, step a < b, S = {b}. Checked by hand on all four
worlds of D(P): j_{b} and cl′ commute (e.g. at U = ∅ both routes
give {a}). Observing only the state that is about to gain a past
commutes with the step.

**P2 (incompatibility exists — the past-watcher).** Same poset and
step, S = {a}: at U = ∅, squint-then-evolve gives cl′({b}) =
{a, b}, evolve-then-squint gives j′_{a}(∅) = ∅. Fails. Observing
only the state whose futures are changing does not commute.
So compatibility is a proper nontrivial subclass: with P0/P1, the
compatible supports on this step are exactly {∅, {b}, {a,b}} — a
chain, closed under ∪ and ∩.

**P3 (node-addition no-go, recorded to scope the study).** For
steps that *add a state* m (multiway growth) under the same-support
convention, no S ⊆ P commutes: at U = ⊤_P the evolved observer
glues the old top into the new top (m ∈ j′_S(⊤_P) whenever
↓m ∩ S ⊆ P, in particular always for m ∉ S), while cl′(j_S ⊤_P)
never contains the fresh maximal state. Hence this study registers
**edge steps only** as primary; node steps under the extended
convention S ↦ S ∪ {m} are a secondary, descriptive question.

## Phase 1 — exhaustive oracle

Engine: perturbation-study core, verbatim. All labeled posets on
n = 2..5 (exhaustive, deduped), ≥ 100 sampled on n = 6. For every
poset, every incomparable pair (a, b), every S ⊆ P: test the
compatibility condition over all U ∈ D(P).

**E0 (validation).** Reproduce P0, P1, P2 exactly on the
2-antichain step. Any mismatch stops the study.

**Q1 (how empty is the middle?).** Fraction of steps admitting at
least one nontrivial compatible S (S ∉ {∅, P}); distribution of
the count. Registered expectation, low confidence: the middle is
usually non-empty at these scales.

**Q2 (is it a lattice?).** For each step, test closure of the
compatible-support family under ∪ and ∩. The notes' framing
survives only if closure holds universally; a single counterexample
demotes "lattice of pockets" to "set of pockets."

**Q3 (does compatibility know about the ratchet?).** Descriptive:
among compatible S, the distribution of phantom mass change across
the step, versus incompatible S.

**Q4 (dynamical pockets exist?).** For each (step, kernel p): count
S that are compatible AND trace-ordinary for ↓p before and after.
Registered expectation: nonzero somewhere (P1's S = {b} is not one —
trace on a singleton is never ordinary — so this needs n ≥ 3).

## Kills

- **K0**: E0 mismatch. Stop, fix, rerun from scratch.
- **K1**: Q2 counterexample — the lattice framing dies (recorded,
  study continues as set-of-pockets).
- **K2 (vacuity)**: nontrivial compatible observers in < 1% of
  steps — the middle is generically empty at small scale,
  "irreducibility is generic" in ledger form; pocket-location is
  then a statement about exceptional structure, and the postscript
  must say so.
- **K3 (pocket vacuity)**: Q4 identically zero — compatibility and
  ordinariness never coexist; the dynamical-pocket notion is empty
  and the static frontier was the whole story.

## Phase 2 (conditional) — Lean targets, in order

1. P1 + P2 as decide witnesses on the concrete 2-antichain model
   (the minimal commuting/non-commuting pair).
2. P0 in abstract form if it states cleanly over the cl′ adjunction;
   otherwise as decide on the same model.
3. Whatever general law Q2 suggests, only if it holds without
   exception in the survey.

---

## Postscript (2026-09-15, same day): Phases 1 and 2 complete

Oracle: `01-commutation-oracle.py`, one run, no code changes after
first execution. E0 reproduced P0–P2 exactly. Survey: 406 exhaustive
posets (n ≤ 5) + 100 sampled (n = 6); 5,984 steps.

**Verdicts. No kill fired; two results far exceed registration.**

- **Q1: the middle is non-empty in 100.0% of steps** (registered
  expectation was "usually"). Every surveyed time step admits a
  nontrivial compatible observer — 139,826 nontrivial compatible
  (step, S) pairs in total. At these scales, *edge dynamics always
  has pockets.*
- **Q2: lattice closure held on every one of 5,984 steps** (K1 did
  not fire). The compatible supports are closed under ∪ and ∩
  universally in the survey. **Conjecture, promoted to the Lean
  queue: the dynamically compatible observers of a single-edge step
  form a sublattice of the observer lattice.** This is the notes'
  "lattice of dynamics-compatible sublocales," with survey-grade
  evidence but no proof.
- **Q3 (descriptive):** compatible observers ride the ratchet
  harder — mean total phantom change −2.61 across the step, versus
  −1.61 for incompatible ones. Recorded, uninterpreted.
- **Q4: dynamical pockets are abundant, not marginal** (K3 did not
  fire): 40,765 (step, kernel, S) triples where a nontrivial
  compatible observer also keeps the kernel's trace ordinary on
  both sides of the step.

**Failed post-hoc candidate, recorded.** After the run, a
closed-form characterization was guessed from the minimal witness
("S compatible iff b ∈ S or S ∩ ↓a = ∅") and tested
(`02-characterization-check.py`): **fails**, 13,863 mismatches of
131,320, in both directions (b ∈ S is not sufficient; blindness to
↓a is not necessary). The true characterization is non-local and
open. The lattice-closure conjecture survives independently of it.

**Phase 2 (Lean), same day.** `lean/FalseWorkPapers/Lattice/
PocketWitness.lean`, builds clean: `futureWatcher_commutes` (P1 —
a genuine nucleus, support {b}, commuting with a genuine step;
nontrivial dynamical compatibility exists) and
`pastWatcher_not_commutes` (P2 — compatibility is a proper
subclass), plus nucleus certificates for both observers and the
sanity theorem that the step map lands in and fixes the extended
order's down-sets.

**One-line summary.** Pockets of reducibility, in the program's
sense, exist, are abundant at small scale, are kernel-checked to be
nontrivial, and appear to form a lattice per step — with the
characterization of *which* observers commute with time recorded as
the open problem, one failed guess already on the books.
