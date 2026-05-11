# Design notes: FalseWork algebra prototype

This document records the design rationale of the prototype: why
the schema is shaped the way it is, what each design choice
preserves about the FalseWork programme, and what is deferred to
V2. It is intended for a reader (Ellynne, the Computational
Metaphysics group, or anyone reviewing the artifact) who wants to
understand not just what the code does but why it was built this
way.

## Five design constraints

Every choice below traces back to one of these:

1. **Kernel-anchored.** Every mechanism, comma, and core must
   carry a kernel reference. The kernel framework is the type
   discipline of the algebra, not commentary on it. A schema
   without a kernel anchor is malformed.
2. **WL-native idiom.** Symbolic heads (`Mechanism[...]`,
   `Kernel[...]`, `Comma[...]`), associations with `<| ... |>`,
   pattern matching with `_Mechanism`, named functions over the
   schema. The notebook should read as something a Wolfram
   Language native wrote.
3. **Four-query exercisable.** All four of Ellynne's queries
   must be implementable as pure functions over the schema, with
   crisp input/output signatures.
4. **Recursion-capable.** The methodology must be representable
   in the same schema as a work, so that query 4 is the same
   operation as queries 1–3 with a different corpus item.
5. **Composable.** Mechanisms that satisfy a compatibility
   predicate must compose into derived behaviour whose properties
   are computable from the inputs, not asserted.

## Type architecture

Six symbolic heads, each wrapping an Association.

| Head | Role | Canonical fields |
|---|---|---|
| `Kernel` | Top-level generative operation in a domain | `Slug`, `Domain`, `Operation`, `Comma` |
| `Comma` | Irreducibility witness for a kernel | `Slug`, `Type`, `IrreducibilityKind`, `FormalGround` |
| `Mechanism` | Operational shadow of a kernel in a specific work | `Id`, `Kernel`, `Type`, `Compatibility`, `CompositionRules`, `RemovalSignature`, `TransferConditions`, `FailureMode` |
| `Constraint` | Dependency statement (removing A breaks B) | `Id`, `Type`, `DependedOnBy` |
| `FailureMode` | Pattern that emerges under removal or misuse | `Id`, `TriggeredBy`, `Signature` |
| `Core` | Full assembly: a structural core for one work | `Id`, `Title`, `Domain`, `Kernel`, `Mechanisms`, `Constraints`, `FailureModes` |

The strict predicate-required subset is narrower: `KernelQ` requires
`Slug`, `Domain`, `Operation`; `CommaQ` requires `Slug`, `Type`,
`IrreducibilityKind`, `FormalGround`; `MechanismQ` requires `Id`,
`Kernel`, `Type`; `CoreQ` requires `Id`, `Kernel`, `Mechanisms`.
The remaining canonical fields above are universally present across
the corpus and are what the queries operate on, but they are not
strictly required for an object to pass its `*Q` predicate. Note
that commas do not carry a back-reference to their kernel: the
kernel→comma relationship is one-way to avoid circular construction.

The `WellFormedCoreQ` predicate validates a core at construction
time. A core that fails validation is rejected by the queries.

### Why every mechanism carries a kernel reference

This is the load-bearing structural commitment. Without it, the
algebra is freestanding — a typed object library that anyone
could have built. With it, the algebra is the operational
instantiation of the kernel framework, and stripping the framework
makes the algebra unintelligible.

Concretely:

- `KernelShapeMatchQ` requires `CommaShapeMatchQ` between the
  two kernels' commas. Without commas (the irreducibility
  witnesses, formally grounded), no transfer claim has any
  basis.
- `WellFormedCoreQ` requires `KernelQ[field[c, "Kernel"]]`. A
  core whose kernel slot is absent or malformed is rejected.
- `MechanismQ` requires `Kernel` as an option. Mechanisms
  without kernel anchors are not first-class objects in the
  algebra.

This is the structural defense against ontological absorption
when the prototype is read by adjacent research programmes
(Wolfram Physics, Computational Metaphysics, etc.). The kernel
framework cannot be quietly subordinated because the schema
depends on it.

## Query implementation rationale

### Query 1 — `FindWorksByType`

The natural form is type-level matching, not id-level. If we
queried by literal mechanism id, cross-domain matching would be
impossible (Tymoczko's `voice_leading_parsimony` and Cutting's
`cut_dissolve_discrimination` have different ids by design).
Type-level matching makes the algebra cross-domain by default.

Two helper functions are exposed: `FindWorksByType` (for
type-level queries) and `FindWorksByMechanismId` (for the
narrower id-level case, e.g., debugging).

### Query 2 — `TransferCandidates`

The most architecturally significant function. Transfer is judged
by `TransferBasis`, which checks five predicates:

1. Same mechanism `Type` (e.g., both `DiscriminationOperation`)
2. Compatibility-set intersection non-empty
3. Comma-shape match between hosting kernels
4. Cross-domain (the interesting case is when source and target
   domains differ)
5. Runtime transfer-conditions predicate (mechanism-supplied
   override)

A candidate is returned only if at least two predicates succeed,
which prevents incidental matches from polluting results.

`TransferConfidence` returns a number in (0, 1] based on which
predicates fire. The strongest configuration —
type+comma+cross-domain — yields the highest confidence (0.92).
Single-predicate matches yield low confidence (~0.40–0.45).

The number form is a compromise between readability and rigour.
A more rigorous V2 would replace `Confidence` with a
`TransferEvidence[...]` head listing exactly which predicates
fired and their respective grounds. This is the kind of detail
that would matter in a production version but is over-engineered
for a prototype.

### Query 3 — `RemoveAndProject`

Removal is implemented as a rewrite over the core, not a deletion
on a list:

- `KeyDrop` removes the mechanism itself.
- Constraints whose `DependedOnBy` list collapses to the
  removed mechanism alone are dropped (they have nothing left
  to bind).
- Mechanisms whose `CompositionRules` referenced the removed
  mechanism are marked `Degraded -> True` (not deleted; the
  algebra preserves them in the schema but signals downstream
  effect).
- The mechanism's declared `FailureMode` is appended to the
  core's `FailureModes` list.

This means removal is a *predictive* operation: it produces a
core that represents what the framework predicts would happen if
the mechanism were taken out. The prediction can then be
compared to a hypothetical actual core (e.g., a counterfactual
scholarly claim) to assess whether the framework's prediction
matches.

`RemovalDelta` returns a summary Association rather than the full
projected core, for cases where the reader cares about *what
changed* rather than *what remains*. Both forms are exposed.

### Query 4 — `RecursiveAnalysis`

The methodology is just another corpus item. `RecursiveAnalysis`
runs the same three substantive queries on it and assembles the
output:

- `SelfTransfers` reveal procedural symmetry (mechanisms that
  are kernel-shape-equivalent to other mechanisms in the same
  core). A high count is the algebraic signature of procedural
  isomorphism.
- `RemovalProfiles` distinguish load-bearing mechanisms from
  ornamental ones. The framework predicts that some mechanisms
  can be removed without further structural disturbance and
  others cannot. The methodology core lets us check which is
  which under self-application.
- `LatentFailures` are failure modes surfaced by removal
  projections that the methodology did *not* declare in its
  own top-level `FailureModes` list. These are the failure
  modes the methodology does not name about itself —
  computationally derived rather than interpretively narrated.

The interesting result is that the latent failures re-derive
the prose findings from Brink's Jan 4, 2026 reply to Stephen
Wolfram (`variety_in_uniformity`, `transparency_as_opacity`,
`methodology_blind_spot`). The recursion has moved from
self-description to self-computation.

## What is deferred to V2

Three categories of work are flagged in the prototype but not
implemented:

### Schema mutation under recursion

Ellynne's deepest question — *"Can it alter the method, improve
the core schema, or produce new formal distinctions that affect
subsequent analyses?"* — points beyond V1.

The V1 prototype demonstrates failure-mode detection under
recursion. V2 would demonstrate schema mutation: when run on
itself, the algebra produces *new mechanism types* or *new
compatibility relations* that become available for subsequent
analyses.

A V2 sketch:

```mathematica
RecursiveSchemaUpdate[methodologyCore, currentTypeSystem] :=
  Module[{novelties, promoted},
    novelties = SurfaceUntypedMechanisms[methodologyCore,
                                         currentTypeSystem];
    promoted  = Map[PromoteToType, novelties];
    Join[currentTypeSystem, promoted]
  ]
```

This is research, not prototype. The V1 architecture is
V2-capable: the type system is implemented as data (six symbolic
heads with Association payloads), so extending it under recursion
is a manipulation of values, not of code.

### Additional queries

The schema enables many further queries that V1 does not
implement:

- `KernelTopologyProjection[core]` — project a core onto the
  five-position field topology (Substrate, Distribution,
  Exploitation, Commitment, Refusal)
- `CommaWitness[kernel, instance]` — check whether a specific
  instance witnesses the kernel's comma in the formal sense
- `FourCriteriaAudit[core]` — render Paper 1 §3's
  four-criteria audit as a function over the core
- `LawvereUnification[kernels]` — express the G ∧ R ∧ C
  unification across multiple kernels via the Lawvere
  fixed-point theorem

Each of these would extend the prototype's reach. None is
required to demonstrate the four queries Ellynne specified.

### Connection to Paper 2

Paper 2 (the Distinction Operation and Inherited Validity)
formalises the rewrite calculus that the algebra's removal tests
empirically instantiate. The full link between the algebra and
Paper 2's formalism is V2 work. The prototype operates at the
operational layer just below Paper 2's theoretical layer; making
the link rigorous (by encoding the distinction operation
itself as a schema operation) would close the loop.

## Risks and design alternatives

### Numerical confidence vs structured evidence

I used a numerical confidence score on transfer candidates
(0.92, 0.81, etc.). Numbers are easy to read but feel
ungrounded — what does 0.92 mean? An alternative would be to
return a structured `TransferEvidence[...]` head listing exactly
which predicates fired and their respective grounds, with no
number.

The numerical form is V1; the structured form is V2. The number
is fine for demonstration purposes; in a production version it
would be replaced.

### Kernel as a value vs a head

I treated kernels as constants (e.g., `KernelTheFifth = ...`).
An alternative would be to make kernels full symbolic heads
with their own pattern-matching rules
(`KernelTheFifth[op_, args_] := ...`). The second is more
WL-idiomatic for some use cases (e.g., the kernel becomes a
function symbol that can be applied). The first is sufficient for
V1 and avoids the complexity of self-applying kernels.

### Including the methodology in the corpus

I included `MethodologyCore` in the same corpus list as
Tymoczko, Cutting, and NKS, so that query 4 is the same
operation as queries 1–3 with a different corpus item. An
alternative would be to keep the methodology in a separate
`selfCorpus` and have `RecursiveAnalysis` operate only over it.

The unified corpus is cleaner for two reasons. First, it makes
the recursion the same algebra, not a special case. Second, it
means cross-corpus queries (`Tymoczko vs Methodology`,
`Cutting vs Methodology`) are also available — surfacing how the
methodology's structural shape compares to the works it analyses.
This second point is where V2 could go interesting places.

## Provenance and references

- Origin: Stephen Wolfram, Jan 3 2026, in response to a
  cold-contact NKS structural analysis.
- Routing: forwarded to the Wolfram Institute philosophy team,
  Apr 4 2026.
- Specification: Ellynne Dec, May 3 2026, on behalf of the
  Computational Metaphysics group.
- Theoretical anchor: Paper 1 v11.6 (kernels and commas), Paper
  3 v9.2 (distinction operation), `validation/OPEN.md` (open
  questions tracker), at <https://github.com/thefalsework/papers>.
  (Versions cited reflect the framework state at the prototype's
  2026-05-04 evaluation; the framework has since advanced to
  Paper 1 v11.8 / Paper 3 v9.4 with the four-cells-plus-gate
  architectural refinement — see [`../papers/comma-formal-structure-note.md`](../papers/comma-formal-structure-note.md).)
- Empirical anchor: Tymoczko 2011 (voice-leading geometry),
  Cutting 2005 (six component processes in film viewing),
  Wolfram 2002 (NKS).
