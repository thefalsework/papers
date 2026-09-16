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

---

## Amendment 2 (2026-09-15, evening): the deflation check

External review of the Phase-1 postscript raised three deflationary
readings; all were run to ground (`03-deflation-check.py`) before
any use of the results. Verdicts:

**Q1's 100% was forced — the reviewer was right.** Hand theorem,
proved during the check and confirmed on all 4,252 steps with zero
exceptions: **the future-watcher S = {b} commutes with every step
(a, b) on every poset.** Proof: b ≰ a, so nothing at or above b
changes (↑′b = ↑b, b ∉ ↓a); j_{b} therefore has the same closed
form (⊤ if b ∈ U, else P∖↑b) on both sides, and cl′ fixes P∖↑b
since it misses ↑b. Stronger forced family, also exceptionless:
**every singleton {x} with x ≰ a commutes** (↑′x = ↑x and
↓a ∩ ↑x = ∅, so cl′ absorbs ↓a into P∖↑x harmlessly). The
sufficient condition is not necessary (1,078 compatible singletons
with x ≤ a). Q1 as registered is hereby reinterpreted: the middle
is never empty *because membership is partially free*, not because
the dynamics is everywhere reducible.

**What survives Q1: weak discrimination at small scale.** Counting
only compatibles beyond the forced supply (non-singleton,
nontrivial): min 0, median 14, max 18 per step; exactly 2 of 4,252
steps have zero excess. So the definition does discriminate — but
barely, and at n ≤ 5 most observers commute with most steps.
Whether compatibility becomes *rare* on large or adversarial
structures is the real question and is **outside this survey's
reach**; nothing here licenses "pockets are abundant" beyond n ≤ 5,
and the registered summary line above is weakened accordingly.

**Q3's whisper is retracted as a selection artifact.** Stratified
by support size |S|, the compatible-vs-incompatible gap in phantom
change shrinks within every stratum and flips sign at |S| = 4
(−0.42 vs −0.44). The unconditioned gap (−2.61 vs −1.61) was
carried by compatible observers being disproportionately coarse,
and coarser observers having more phantom to lose. Q3 is
downgraded from whisper to artifact; recorded, closed.

**The lattice conjecture is genuinely open in both halves.** The
reviewer's guess that meet-closure might be a two-line argument
does not go through: support-union closure requires cl′ to
preserve the pointwise meet j_S U ∩ j_T U, and cl′ (a left
adjoint) preserves joins, not meets — the meet is exactly where
the easy route breaks. No trivial proof was found for either half;
the 5,984-for-5,984 empirical closure stands as evidence for a
conjecture that has no cheap proof and no counterexample.

---

## Amendment 3 (2026-09-15, night): the lattice interrogation

Follow-up demanded by the same review, corrected picture in hand:
nuclei on a frame form a frame with pointwise meets, so the
difficulty was never whether j ∧ j′ is a nucleus — it is whether
compatibility survives the meet, and that reduces to whether the
step preserves binary meets on the relevant elements. Oracle:
`04-lattice-interrogation.py`, one run (one print-encoding fix
after first execution, no logic change). Three verdicts:

- **V1: cl′ fails binary meet-preservation on every step, by the
  universal witness.** U = ↓a, V = ↓b: cl′U ∩ cl′V owns a,
  cl′(U ∩ V) does not. Fired on 4,252 of 4,252 steps. The
  three-line route to meet-closure is dead, permanently.
- **V2: image meet-preservation is exceptionless on compatible
  pairs** (792,595 pairs, zero violations): for compatible S, T,
  cl′(j_S U ∩ j_T U) = cl′(j_S U) ∩ cl′(j_T U) for every U.
  **Honesty note, before anyone cites this as evidence:** since
  j_{S∪T}U = j_S U ∩ j_T U pointwise, V2 is *logically equivalent*
  to the meet-closure the survey already observed — it is the same
  fact rewritten, not independent confirmation. Its value is that
  it isolates the Lean target: prove that joint compatibility
  forces cl′ to preserve the meet of the two images. Recorded [O].
- **V3: the closure is not the singleton artifact wearing a third
  hat.** Among excess-compatible pairs (non-singleton,
  nontrivial): 76.0% of meets (support unions) and 58.2% of joins
  (support intersections) land back in the *excess*, not the
  forced set (405,076 pairs). The lattice has genuine non-forced
  structure closing on itself.

The join half stays hard for its own reason (joins of nuclei are
not pointwise); no claim is made about it beyond the survey.

---

## Amendment 4 (2026-09-16): the meet half is a theorem

Found by hand while scoping the Lean target that Amendment 3
isolated; verified against the full survey before recording
(`05-lemma-a-check.py`: Lemma A on 169,889 instances, meet half on
792,595 pairs, zero failures of either).

**Lemma A.** Let S be compatible with the step (a, b), U a
down-set with b ∈ j_S U and b ∉ U. Then ↓a ⊆ j_S U.

*Proof.* Since b ∉ U, cl′U = U. Compatibility of S at U reads
cl′(j_S U) = j′_S U, and since b ∈ j_S U the left side is
j_S U ∪ ↓a. For any x ≤ a we have ↓′x = ↓x (nothing gains b below
it without gaining b ≤ a, contradicting incomparability), so
x ∈ j′_S U iff ↓x ∩ S ⊆ U iff x ∈ j_S U. Every x ≤ a lies in the
left side, hence in j′_S U, hence in j_S U. ∎

**Theorem (meet half).** If S and T are compatible with (a, b),
so is S ∪ T (the pointwise meet of the two nuclei).

*Proof.* j_{S∪T}V = j_S V ∩ j_T V pointwise. Fix U and set
A = j_S U, B = j_T U; by compatibility of each it suffices to show
cl′(A ∩ B) = cl′A ∩ cl′B. If b ∈ A ∩ B both sides are
(A ∩ B) ∪ ↓a by distributivity. If b ∉ A and b ∉ B both sides are
A ∩ B. In the mixed case b ∈ A, b ∉ B: inflation gives b ∉ U, so
Lemma A yields ↓a ⊆ A, hence
cl′A ∩ cl′B = (A ∪ ↓a) ∩ B = (A ∩ B) ∪ (↓a ∩ B) = A ∩ B =
cl′(A ∩ B). ∎

**Status change.** The lattice conjecture splits: the **meet half
is proved** (compatible supports are closed under union); the
**join half** (closure under intersection) remains open with
5,984/5,984 empirical support and no proof. Lemma A also explains
Amendment 3's V2 structurally: image meet-preservation was
exceptionless because compatibility forces ↓a inside any image
that contains b without its ground truth. Lean formalization same
day (`Lattice/PocketMeetHalf.lean`).

**Postscript (2026-09-16): the Lean file builds clean.** Contents,
all kernel-checked over any finite `DecidableEq` partial order with
an incomparable pair (a, b):

- `futureWatcher_compatible` (Amendment 2's forced future-watcher,
  D1) and `singleton_compatible` (the stronger forced family
  {x : x ≰ a}, D1b).
- `mem_obs_of_le_a` — Lemma A, exactly as stated above.
- `compatible_union` — **the meet half of the lattice conjecture is
  now kernel-grade.** Compatible supports are closed under union;
  equivalently, compatible nuclei are closed under pointwise meet.
- Two trajectory pre-derivations banked cheaply per the 2026-09-16
  plan, ahead of any trajectory spec: `survival_composes`
  (compatibility with each step in a sequence composes to
  compatibility with the whole trajectory) and `freeSupply_antitone`
  (the forced-singleton family {x : ¬ x ≤ a} only shrinks as the
  order grows — the half of the scarcity hunch that is free; any
  registered trajectory claim must therefore be about the excess).

The join half remains open, empirical support unchanged
(5,984/5,984, no proof, no counterexample).
