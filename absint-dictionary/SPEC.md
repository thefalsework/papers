# The abstract-interpretation dictionary: Phase 0 spec

*Registered 2026-09-16, committed before any literature check runs and
before any code. This is the applied bet chosen by the 2026-09-16
plan for algebra-friendliness: abstract interpretation is the one
host domain where the coarsenings practitioners use are already
closure operators on lattices (Cousot–Cousot represent abstract
domains as upper closure operators on the concrete lattice), the
algebras are designed rather than found, and ground truth about
imprecision exists (false positives are measured things). Phase 0 is
dictionary-or-death: no tool, no measurement, no claim until the
translation table survives. The two previous applied bets (packages,
trained networks) died where the host algebra was hostile; this spec
writes the possible deaths down first.*

## Hand-derived no-go, recorded before anything else (process rule of 2026-09-15)

**P0-A (the Boolean-carrier no-go).** The naive dictionary —
"an abstract domain is a nucleus on the concrete powerset ℘(Σ)" — is
**dead on arrival**, and provably so: ℘(Σ) is a complete Boolean
algebra, and on a Boolean frame every nucleus is closed
(j_A = A ∪ −; equivalently, every sublocale of a Boolean locale is
closed). The classical numerical closures are not of that form and
fail binary meet-preservation outright — the interval closure ρ on
℘(ℤ) has ρ(evens) ∩ ρ(odds) = ℤ while ρ(evens ∩ odds) = ∅. This is
the ε-closing failure mode again (extensive + monotone + idempotent,
not meet-preserving; cf. `tritoneClosure_not_nucleus` and the §7
erratum). Any honest dictionary must therefore name a **non-Boolean
carrier** on which the domain's coarsening acts. Candidates to be
assessed in P0-C; a dictionary that stays on ℘(Σ) is not one.

**P0-B (the compatibility–completeness suspicion).** Abstract
interpretation's *completeness* condition ρ∘f = ρ∘f∘ρ (and its
backward twin) is a commutation condition between a closure operator
and a step function — the same shape as the pocket study's dynamical
compatibility (cl′∘j = j′∘cl′). If the identification is exact, the
program's compatibility questions land in a literature that has
studied completeness for decades (completeness cores and shells), and
the meet-half theorem (`compatible_union`) may already exist there as
a fact about complete domains being closed under reduced product
(the meet in the uco lattice). **This must be checked before any
claim of novelty about the dynamical results is ever made outside
the repo.** Both outcomes are useful: if known, the pocket study
gains a literature and loses a priority claim (recorded, re-aimed at
the quantitative layer); if the identification is inexact, the gap
is exactly where the program's contribution would live.

## Phase 0 questions

**D1 (the carrier).** For each candidate carrier, determine whether
the domain's coarsening is a nucleus *there*:

  a. The abstract lattice A itself (via γ∘α). Known risk: A is often
     non-distributive (intervals already fail distributivity:
     ([0,1] ∨ [2,3]) ∧ {1.5} ≠ ⊥), hence not Heyting; record per
     domain.
  b. Giacobazzi–Scozzari's Heyting-completion territory: carriers
     built by intuitionistic-implication completion of a domain.
     This is the literature item most likely to have pre-built the
     dictionary; the check must retrieve what they proved and where
     they stopped.
  c. The program's own move: a specialization/Alexandrov carrier
     (down-sets of a finite order derived from the analysis, e.g.
     abstract states ordered by precision, or trace prefixes), where
     the observer machinery applies verbatim.

**D2 (the phantom's meaning).** For each surviving (domain, carrier)
pair: what is [U, jU] in the analyst's language? The candidate
reading — phantom mass = the set of concrete behaviors the analysis
*confidently conflates* with U, i.e. the false-alarm generator — must
be checked against how the field already quantifies incompleteness
(completeness distances, "measuring imprecision" literature), and
against P0-B: if completeness theory already has a *quantitative*
layer, the dictionary adds nothing and dies honestly.

**D3 (the four positions).** Whether ordinary / regular / dense
have existing names in the domain-theory literature (e.g. regular =
"condensing"? dense = trivially-refinable?). Pure translation
question; a table with citations or blanks.

## Kills (Phase 0)

- **KD1 (nuclei-representability).** If, after D1, no honest carrier
  makes any standard domain's coarsening a nucleus: record it and
  stop. The postscript states the program's instrument does not
  apply to abstract interpretation, with the Boolean no-go and the
  per-domain failures as the record. No carrier-shopping past the
  three registered candidates.
- **KD2 (absorption).** If P0-B resolves to "compatibility is
  backward-completeness, meet-half is a known shell/product fact,
  and phantom mass is a known incompleteness measure": record the
  three citations, mark the pocket study's general results as
  rediscoveries in AI clothing (kernel-checked, which the field's
  versions are not — that remains true and stated), and stop the
  applied bet. Rediscovery with a kernel is not nothing, but it is
  not a bet worth tools.
- **KD3 (dictionary without ground truth).** If a carrier survives
  but the phantom quantity cannot be put against any measured
  imprecision data that already exists (D2), the bet reverts to
  queued — the whole point of choosing this domain was that ground
  truth is pre-paid.

## Deliverable

One document (this file's postscript): the dictionary table
(domain / carrier / nucleus? / phantom meaning / ground-truth
dataset), the P0-B verdict with citations, and a go/no-go. **No tool
until this survives**, per the registered plan.

---

## Postscript (2026-09-16, same day): Phase 0 first pass — P0-B run to ground at search depth, one finding that redraws the kill map

**P0-B, first pass.** The suspicion is confirmed as a real absorption
risk and is not yet resolved either way:

- Giacobazzi–Ranzato–Scozzari, *Making abstract interpretations
  complete*, JACM 47(2), 2000: completeness (ρ∘f = ρ∘f∘ρ, plus the
  paired form for f : C → D with a domain on each side) is a property
  of the domain alone; complete shells and cores exist constructively
  for continuous f; **the relative complete shell is the reduced
  product of A and R_f(B), and absolute complete shells are computed
  modularly by reduced product.** The pocket study's dynamical
  compatibility is exactly a *tied* domain-pair completeness (same
  support S interpreted on both sides of cl′), so the framework is
  theirs, and the meet-half theorem's shape — complete domains closed
  under reduced product — is present in their *untied* setting.
  Whether the tied-support version (Lemma A's content: the tie is
  what forces ↓a into the image) is an instance of their shell
  results or genuinely outside them requires reading §5 of the paper,
  not searching it. **KD2 is live and undecided.** Standing rule
  until decided: no novelty claim about the dynamical results leaves
  the repo.
- Giacobazzi–Scozzari, *Intuitionistic implication in abstract
  interpretation* (PLILP 1997) / *A logical model for relational
  abstract domains* (ACM TOPLAS 20(5), 1998): **Heyting completion is
  established prior art** — a domain refinement modeling Cousot's
  reduced cardinal power, with abstract domains specified by
  intuitionistic implication formulas. The D1b carrier exists in the
  literature, built by specialists, twenty-eight years ago. Their
  abstracts also use "condensing" as a domain property — D3's guess
  that the program's classes have existing names is supported and
  must be tabled properly.

**The finding that redraws the kill map.** Re-reading the E0 proof
(`IsNucleus.le_apply_iff`, `CoApertureClosedForm.lean`): it uses
inflationary + monotone + idempotent only — `map_inf` is never
invoked. The confusion-class lemma, and with it phantom mass, is a
**closure-operator-level instrument**, not a nucleus-level one.
Consequences, recorded before any use:

1. KD1's scope narrows. The Boolean-carrier no-go (P0-A) kills the
   *four-position/ordinariness* layer on ℘(Σ); it does not touch the
   *phantom-mass* layer, which is well-defined for every abstract
   domain as-is (the interval [U, ρU] under an upper closure ρ).
2. The dictionary therefore splits into two layers with separate
   survival conditions: **(i)** phantom mass ↔ measured imprecision
   of a uco (survives P0-A trivially; lives or dies on D2's ground
   truth); **(ii)** the four positions ↔ requires a non-Boolean
   carrier (Heyting completion or an Alexandrov carrier; lives or
   dies on D1).
3. The corresponding absorption check for layer (i) moves to the
   "measuring incompleteness/imprecision" literature and is **not yet
   run** — it is the same hostile-reviewer search the phantom study
   ran for morphological closing, and D2 cannot be graded before it.

**Go/no-go: not issued.** Remaining before a verdict: the D1
per-domain table, the D2 ground-truth mapping with its absorption
search, the D3 name table, and a real read of GRS §5 and
Giacobazzi–Scozzari 1998 for KD2. Phase 0 continues; nothing here
authorizes a tool.

---

## Postscript 2 (2026-09-16, same day): the GRS read — KD2 resolved into "framework absorbed, theorem apparently not"

The real read happened same day (GRS JACM 2000 §§3–5; Ranzato–Tapparo,
arXiv cs/0612120 and JLC 2007, for the forward notion). Three findings,
the hand proofs recorded inline as [H] (oracle re-check against the
pocket survey queued; the proofs are two lines each and use nothing
beyond idempotence).

**1. The decomposition theorem [H]: dynamical compatibility is exactly
backward completeness plus forward completeness of the tied pair.**
GRS Definition 3.2(i): ⟨ρ, η⟩ is (backward-)complete for f iff
η∘f = η∘f∘ρ. Ranzato–Tapparo: ρ is forward complete iff
f∘ρ = η∘f∘ρ (the image of ρ-fixed elements is η-fixed). Claim: with
ρ = j_S, η = j′_S, f = cl′,

    compatibility (cl′∘j_S = j′_S∘cl′) ⟺ backward ∧ forward.

*Proof.* (⟹) η f ρ = η (f ρ) = η (η f) = η f (idempotence): backward.
Then f ρ = η f = η f ρ: forward. (⟸) f ρ = η f ρ = η f. ∎
So the pocket study's central definition is a conjunction of two
notions this field has owned since 1979/2000 (backward) and 2001/2004
(forward: Giacobazzi–Quintarelli; Ranzato–Tapparo "strong
preservation"). **Absorbed.** Every public statement of the pocket
results must henceforth use this vocabulary and cite these papers.

**2. What else is absorbed: the cheap closure direction.** GRS
Theorem 4.3 decouples backward completeness: ⟨ρ, η⟩ complete iff a
generator set determined by η alone lands in Fix(ρ) (their
max(f⁻¹(↓y)) sets; cl′ is additive — it is a left adjoint — so their
continuity hypothesis holds with room to spare). Corollary [H]:
compatible pairs are closed under coordinatewise **uco-lub** (going
more abstract): Fix of the lub is the intersection of the Fix sets,
the generator set only shrinks, and the forward half is closed under
intersection of Fix-families by pure logic. Three lines, essentially
theirs. Caution recorded: this does **not** settle the survey's open
join half, because the support-intersection observer j_{S∩T} is
strictly more abstract than the uco-lub of j_S and j_T in general
(Fix(j_{S∩T}) ⊊ Fix(j_S) ∩ Fix(j_T)); the join half of the lattice
conjecture is a statement about a *different, stronger* operation and
stays open.

**3. What is not absorbed on this read: the meet half.** Union of
supports is the **reduced product** (the glb, going more concrete):
Fix(j_{S∪T}) = {A ∩ B : A ∈ Fix(j_S), B ∈ Fix(j_T)} [H — one line
each way, using j_{S∪T}U = j_S U ∩ j_T U]. And reduced-product
closure is exactly the direction the known theory does *not* give:
backward-complete domains are not closed under reduced product in
general (that failure is why GRS complete shells need the R_F
iteration rather than being trivial), and neither are
forward-complete domains (why Ranzato–Tapparo shells need a gfp).
The obstruction in both cases is mixed meets A ∩ B — precisely where
cl′'s meet-preservation failure (pocket Amendment 3, V1) lives. The
meet-half theorem (`compatible_union`) asserts reduced-product
closure *anyway*, for the tied support family on down-set algebras,
and Lemma A is the tie-specific mechanism that rescues it. **On this
read, that theorem is not in their corpus.** This is a
structure-match performed in one day, not a proof of absence; a
specialist could still produce the special case, and the standing
rule (no public novelty claim) stays until a specialist or a deeper
search has been given the chance.

**Bonus D3 entries found in passing** (SAS 2008 invited, Giacobazzi–
Ranzato): disjunctive completion = forward completeness w.r.t. ∨;
complementation = backward completeness w.r.t. ∧; Heyting completion
= the implication layer. The D3 table has begun filling itself from
the literature, as hoped.

**KD2 verdict update:** downgraded from "live and undecided" to
**"framework absorbed; meet-half theorem retains apparent novelty in
the reduced-product direction."** Consequences: (i) the pocket
study's definitions get a vocabulary erratum (compatibility =
backward + forward completeness of the tied pair — an upgrade, not a
correction: the results now sit inside a mature field instead of
beside it); (ii) the honest sentence for any future write-up is
"kernel-checked reduced-product closure for a family where the
general theory predicts failure," which is a smaller and better
claim than "a new lattice of observers."

---

## Postscript 3 (2026-09-16, same day): D2 absorption search run — the quantitative layer is *not* virgin territory, and the dictionary survives in a sharper form

**Oracle re-check first (house rule).** The two [H] proofs of
Postscript 2 were re-checked against the pocket survey
(`pocket-study/06-decomposition-check.py`): decomposition confirmed
on 131,320 (step, S) pairs with 0 mismatches (and both completeness
notions are independently violable, so the conjunction is genuinely
stronger than either); the reduced-product reading confirmed on
~10⁶ checks with 0 failures. Both upgraded from [H] to
oracle-confirmed.

**D2 absorption verdict: partial hit, favorable geometry.** The
hostile-reviewer search found the absorber candidate on the first
pass: Campion–Dalla Preda–Giacobazzi, *Partial (In)Completeness in
Abstract Interpretation: Limiting the Imprecision in Program
Analysis*, POPL 2022 (building on Bruni–Giacobazzi–Gori–Ranzato's
local completeness, LICS 2021). They enrich abstract domains with
order-compatible quasi-metrics and define ε-partial completeness:
the distance between the abstraction of the concrete result and the
abstract result is at most ε, with a proof system for error bounds.
**Correction to this morning's status, on the record: the sentence
"the field only has a yes/no" is retracted.** Graded incompleteness
has existed there since 2021–2022.

What their apparatus measures and ours does not, and conversely —
this is the dictionary's actual content now:

- *Theirs:* imprecision of an **analysis run** — per program, per
  input, per domain, along an externally supplied quasi-metric on
  the **abstract** lattice. Their canonical interval metric even
  uses the same intuition as phantom mass ("counts the number of
  spurious elements added").
- *Ours:* the **intrinsic conflation of the domain at an element** —
  phantom mass |[U, ρU]| needs no supplied metric, no program, and
  no input; it is the order-theoretic count of what the coarsening
  manufactures at U, with the confusion-class lemma giving it exact
  semantics (the states conflated with U from above). And the
  ledger sums — co-aperture (one element, all observers) and
  aperture (the survival count) — have no analogue in their theory
  at all: they grade programs against one domain; the ledger grades
  elements against the whole lattice of domains, with closed forms
  and (per today's census) genuinely independent coordinates.

The honest positioning sentence: **phantom mass is the metric-free,
per-element, per-observer primitive that their per-run,
metric-supplied theory does not have; their partial-completeness
classes are the ground-truth-bearing framework the ledger can be
priced against.** Complementary, not identical — but the reviewer
who says "phantom mass is the path-length quasi-metric applied to
(U, ρU)" is nearly right on one axis and must be answered in any
write-up by the ledger axis (aperture/co-aperture), which is the
part with no counterpart.

**D1, resolved by the layer split.** On the concrete carrier, no
standard domain is a nucleus (P0-A settles the column wholesale);
every standard domain is a uco, so **layer 1 applies to all of them
as-is** — intervals, signs, parity, octagons enter the table with
"uco: yes, nucleus: no, phantom: well-defined." Layer 2's carrier
question is exactly the Heyting-completion literature and stays
open (read owed before any claim).

**D3, filling from the literature:** disjunctive completion =
forward completeness w.r.t. ∨; complementation = backward
completeness w.r.t. ∧; Heyting completion = the implication layer;
"condensing" (Giacobazzi–Scozzari 1998) still owed a precise match
against regular/dense.

**Phase 0 verdict, per the registered kills:**

- **KD1 does not fire** — under the layer split, layer 1 is
  nuclei-independent and applies everywhere; layer 2 is blocked on
  the Heyting-completion read, not killed.
- **KD2: framework absorbed, meet-half apparently retained**
  (Postscript 2, now oracle-backed).
- **KD3 does not fire** — ground truth exists twice over: measured
  false-alarm data in the tooling world, and the ε-partial
  completeness classes as the theory-side target.

**Go/no-go: conditional GO for layer 1, QUEUED for layer 2.** The
authorized next step is a *registered Phase 1 spec* — not a tool:
pick one worked toy analysis (finite carrier, e.g. sign or parity
on a small integer world), compute phantom mass and the ledger sums
exactly, and test the registered claim that phantom mass at the
analyzed properties predicts the false-alarm behavior that
ε-partial completeness bounds — with the kill written as "if the
intrinsic count and the run-level error decouple on the worked
example, the instrument is a definition, not a predictor, and the
bet ends there." Layer 2 waits for the Giacobazzi–Scozzari read.
