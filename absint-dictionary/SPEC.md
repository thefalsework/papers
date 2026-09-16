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
