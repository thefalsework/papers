# FalseWork Algebra Prototype (Wolfram Language)

> **Note on framework version.** This prototype was assembled against
> Paper 1 v11.6 (May 4, 2026) and references that version throughout its
> source files and bundled artifacts. The framework has since advanced to
> Paper 1 v11.8 (architectural revision-note bump recording the
> *four-position partition + Commitment gate* refinement; see
> [`../papers/comma-formal-structure-note.md`](../papers/comma-formal-structure-note.md)
> for the canonical statement of the refined architecture). The
> prototype's references reflect its 2026-05-04 evaluation state and are
> left intact for reproducibility of the artifact at
> [`results/wolfram-cloud-run-2026-05-04-v1.5.nb`](results/wolfram-cloud-run-2026-05-04-v1.5.nb).
> The five-position-themed `PaperReference` annotations in the source
> remain accurate to v11.6 § 3.4; the v11.8 architectural revision
> retains the same empirical structure and refines its formal
> description.

A small Wolfram Language prototype that operationalises the FalseWork
kernel/comma framework as a typed symbolic algebra over structural cores,
demonstrating the four queries Ellynne Dec specified on behalf of the
Wolfram Institute Computational Metaphysics group (May 3, 2026):

1. **Mechanism + constraint match** — find works in a corpus whose cores
   contain a given mechanism type and constraint type
2. **Transfer candidate identification** — given two cores, surface
   candidate cross-domain mechanism transfers, with the compatibility
   basis made explicit
3. **Computational removal test** — given a core and a mechanism, project
   the structural profile after removing the mechanism (a rewrite, not
   an interpretation)
4. **Recursive self-application failure-mode detection** — feed the
   methodology its own structural core and surface failure modes
   computationally

The centerpiece demonstration is a **Tymoczko ↔ Cutting transfer query**:
the algebra computationally identifies that voice-leading parsimony in
Tymoczko's voice-leading geometry and cut/dissolve discrimination in
Cutting's film-primitive framework are kernel-shape-equivalent, on
grounds it can articulate. Two scholars, two domains, two independent
vocabularies, one underlying algebraic shape — surfaced by code, not
prose.

## File layout

```
wolfram/
├── README.md                  this file
├── design-notes.md            architecture overview and design rationale
├── falsework-algebra.wl       type system, predicates, query implementations
├── kernels.wl                 Kernel and Comma definitions for the corpus
├── cores/
│   ├── tymoczko.wl            Tymoczko, A Geometry of Music (2011) — KernelTheFifth
│   ├── tymoczko-2026.wl       Tymoczko, The Concept of Musical Space (2026 JMT) — KernelTheFifth (groupoid/π₁ formalism)
│   ├── heunen-landsman-spitters-2009.wl
│   │                          Heunen-Landsman-Spitters, A Topos for Algebraic Quantum Theory (2009 CMP) —
│   │                          KernelTheWaveFunction (Bohrification / topos quantum mechanics; physics-anchor
│   │                          corroborator; KernelTheWaveFunction stubbed locally pending promotion to kernels.wl)
│   ├── cutting.wl             Cutting, F1 film primitives — KernelTheCut
│   ├── nks.wl                 Wolfram, A New Kind of Science — KernelTheConditionalBranch
│   └── methodology.wl         FalseWork methodology self-core — KernelOfMethodology
├── music-anchor/              divisor-lattice Layer-L/T/D computational companion to
│                              preprints/four-position-partition/music-anchor/feasibility.md
├── physics-anchor/            Route-B + Route-A-checkpoint companions to
│                              preprints/four-position-partition/physics-anchor/feasibility.md
│   ├── four-position-physics-v1.wl  Route B: finite physics-interpretable
│   │                                  down-set-of-poset lattices (executed v1.1,
│   │                                  all five candidates degenerate)
│   ├── four-position-physics-v2.wl  Route A computational checkpoint:
│   │                                  Sub_cl(Sigma) enumeration on small finite
│   │                                  context categories with non-trivial joins
│   │                                  (Doering 2012 stagewise Heyting NOT).
│   │                                  Candidates P1 (diamond) and P2 (V(C^3));
│   │                                  both executed NON-VACUOUS 2026-05-26.
│   ├── four-position-physics-v2-p3.wl  Same machinery as v2, P3 (two-MASA;
│   │                                  incompatible maximal contexts) split out
│   │                                  with direct subobject construction and
│   │                                  short-circuit witness search to fit the
│   │                                  Wolfram Cloud cell budget. Executed
│   │                                  NON-VACUOUS 2026-05-26.
│   ├── four-position-physics-v3.wl  Route A v3 Bohrification-native kernel
│   │                                  candidates: discretised V(M_2(C) (+) C)
│   │                                  vs. poset-isomorphic V_d(C^7) classical
│   │                                  control. Tests 7 kernel candidates
│   │                                  (sec. 4.1-4.6, 4.8 of v3-scope.md) plus
│   │                                  exhaustive non-regular sweep (sec. 4.7).
│   │                                  Executed 2026-05-26: cell-non-emptiness
│   │                                  NEGATIVE across all seven candidates
│   │                                  (matches dim < KS threshold prediction);
│   │                                  cell-CARDINALITY POSITIVE on candidates
│   │                                  4.1 and 4.3 with clean ratios ~2^3
│   │                                  traceable to off-direction daseinisation
│   │                                  lifts. Exhaustive sweep (sec. 4.7) cut
│   │                                  off mid-run but is structurally null
│   │                                  (lattice-iso pins both sides to match);
│   │                                  see v3-scope.md sec. 10.4 for argument.
│   ├── four-position-physics-v4.wl  Route A v4 Bohrification on M_3(C):
│                                      structural-break detection at dim >= 3.
│                                      Configuration: 4 MASAs of M_3(C) (the
│                                      cardinal triple + 3 Hadamard-pair MASAs
│                                      each sharing one atom with cardinal),
│                                      8 contexts total. Two classical
│                                      comparators: minimal C^3 (cleanest
│                                      contrast) and best-effort same-Hasse
│                                      C^9 (v3-discipline check). Primary
│                                      signal: |GlobalSections(Sigma)| (count
│                                      of atomic-everywhere clopen subobjects).
│                                      Secondary: v3-style cardinality kernels
│                                      4.1' and 4.5' on this richer config.
│                                      Executed 2026-05-26: primary structural-
│                                      break signal NEGATIVE (|GlobalSections|
│                                      = 12 on both Q and C-best-effort,
│                                      confirming 4-MASA M_3(C) is not KS-
│                                      blocking; |GlobalSections(C_min)| = 3
│                                      shows the categorical-contrast baseline).
│                                      Secondary cardinality kernels also
│                                      match between Q and C-best-effort
│                                      (lattice-iso pins counts). SUB-
│                                      structural finding *in the framework's
│                                      truncated context category* (per
│                                      feasibility.md sec. 3.5): dasein(P)
│                                      is Heyting-non-regular with
│                                      Exploitation = 128 (first non-regular
│                                      daseinisation across v2/v3/v4 in the
│                                      truncation); mechanism is round-up-
│                                      to-identity at every off-direction
│                                      sub-MASA of the truncation. Calibrated
│                                      reading (feasibility.md sec. 8.6,
│                                      added after reconciliation with
│                                      Doering 2012): the non-regularity is
│                                      a property of the framework's
│                                      truncated V(M_3(C)), NOT of
│                                      M_3(C) Bohrification over the full
│                                      V(M_3(C)) (where daseinisations are
│                                      Heyting-regular by Doering 2012
│                                      Prop. 5 + Cor. 2). The finding stands
│                                      as a property of the truncated topos
│                                      and is conditional on whether the
│                                      truncation is regarded as principled.
│                                      Penrose-40 / Peres-33 are research
│                                      scope for v5 (KS-blocking required for
│                                      the categorical structural break,
│                                      which is robust to the truncation
│                                      question — see v5 below).
│   ├── four-position-physics-v5.wl  Route A v5 Peres-33 KS-blocking
│                                      structural-break test. Configuration:
│                                      the full Peres-33 set (33 explicit
│                                      rays + 24 dyad-completion rays = 57
│                                      rays; 16 explicit triads + 24 implicit
│                                      triads = 40 triads), per Peres 1991
│                                      and Aravind & Lee-Elkin 2007. Skips
│                                      Sub_cl(Sigma) enumeration entirely;
│                                      computes |GlobalSections(Sigma_Q)|
│                                      directly via Mathematica's
│                                      SatisfiabilityCount on 57 boolean
│                                      variables with 40 "exactly-one-of-
│                                      three" constraints. By the Kochen-
│                                      Specker theorem, this count is 0;
│                                      the script makes that computation
│                                      explicit in the framework's machinery.
│                                      Comparator: minimal C^3 with 3 global
│                                      sections. EXECUTED 2026-05-26:
│                                      |GlobalSections(Sigma_Q)| = 0 (in
│                                      24 milliseconds); |GlobalSections
│                                      (Sigma_C_min)| = 3; strict inequality
│                                      0 < 3 confirmed. STRUCTURAL BREAK
│                                      DETECTED -- the framework's machinery
│                                      (Bohrification + Doering stagewise
│                                      Heyting NOT) faithfully witnesses
│                                      Kochen-Specker as a finite computation.
│                                      ROBUST TO TRUNCATION CHOICE: unlike
│                                      v4's substructural finding (which is
│                                      conditional on feasibility.md sec.
│                                      3.5), v5's categorical signal holds
│                                      in both the framework's truncated
│                                      V(M_3(C)) and Doering's full V(M_3(C))
│                                      (KS theorem applies to the maximal
│                                      MASAs; unshared sub-MASAs add no
│                                      global-section constraints). Physics
│                                      anchor crosses the structural-
│                                      feasibility threshold at the categorical
│                                      level; v5 is the threshold-crossing
│                                      artefact for the physics anchor,
│                                      analogous to v3-path-b for music.
│   ├── four-position-physics-v6a.wl Route A v6a Heyting-collapse verification
│   │                                  (fast, no SAT). Computational verifier
│   │                                  for the analytical pre-finding in
│   │                                  v6-scope.md sec. 2: in the framework's
│   │                                  truncated context category V'(M_3(C))
│   │                                  on the Peres-33 substrate (74 contexts:
│   │                                  V_0 + 33 V_k + 40 T_a, where m_{V_k}
│   │                                  = {V_0} for every sub-MASA), every
│   │                                  non-bottom S in Sub_cl(Sigma) satisfies
│   │                                  NOT(S) = bottom. Stagewise Heyting NOT
│   │                                  on delta(P_1) (P_1 = |0><0|) computed
│   │                                  in 0.009 s on Wolfram Cloud. EXECUTED
│   │                                  2026-05-27: NOT(delta(P_1)) = bottom
│   │                                  componentwise (all 74 contexts empty);
│   │                                  NOTNOT(delta(P_1)) = top; delta(P_1)
│   │                                  Heyting-non-regular. Heyting-collapse
│   │                                  theorem confirmed at Peres-33 scale.
│   │                                  Cloud-friendly (no Package directive,
│   │                                  no SAT step); intended as the headline
│   │                                  v6 result when v6.wl's SAT step hits
│   │                                  the Wolfram Cloud memory limit.
│   └── four-position-physics-v6.wl  Route A v6 full Heyting-collapse +
│                                      cardinality measurement. PARTS 0-5
│                                      duplicate v6a (Heyting-collapse
│                                      verification); PARTS 6-9 attempt to
│                                      measure |Sub_cl(Sigma)| and
│                                      |down delta(P_1)| via SatisfiabilityCount
│                                      on 187 boolean variables and 354
│                                      clopen-subobject implications across
│                                      129 Hasse-cover edges. Two-cell
│                                      partition sizes (|I|, 0, |E|, 0)
│                                      derived from those counts under the
│                                      Heyting-collapse. EXECUTED 2026-05-27
│                                      on Wolfram Cloud: PARTS 0-5 match
│                                      v6a (Heyting-collapse VERIFIED).
│                                      PARTS 7-8 aborted by Cloud::memlimit
│                                      at ~50 s; SAT counts unmeasured.
│                                      Cardinality magnitudes |I| and |E|
│                                      deferred to a non-cloud run (local
│                                      Mathematica with more RAM, alternative
│                                      SAT engine, or structural enumeration
│                                      of the implication DAG). The
│                                      Heyting-collapse theorem (the
│                                      categorical signal) does not depend
│                                      on these cardinalities and remains
│                                      established.
├── notebook-script.wl         demo script: loads corpus, runs all four queries
├── paste-cells/               multi-cell version for Wolfram Cloud
│   ├── README.md              workflow instructions
│   ├── 1-setup.wl             algebra + kernels + four cores (load only)
│   ├── 2-queries.wl           Q1–Q4 with text output
│   ├── 3-vis-transfer.wl      Tymoczko ↔ Cutting transfer network graph
│   ├── 4-vis-removal.wl       Tymoczko removal-cascade graph
│   ├── 5-vis-self-transfer.wl methodology self-transfer graph
│   └── 6-vis-discrimination.wl  cross-pair comparison panel
├── corev2-loader.wl           V2: CoreV2 JSON → Core[...] loader, in-WL
│                              revalidation, fixpoint removal executor,
│                              assertion audit (see "V2" section below)
├── corpus-v2/                 V2: machine-fed corpus — 15 CoreV2 typed
│                              dependency graphs transduced from falsework.dev
│                              structural profiles (+ index.json manifest);
│                              copied verbatim from node0000 exports/corev2
├── paste-cells-v2/            V2: multi-cell Wolfram Cloud workflow for the
│                              machine-fed rerun of Q1–Q4 (see its README.md)
└── results/
    └── wolfram-cloud-run-2026-05-04-v1.5.nb   reference evaluated run
```

## Running the demo

### Option A — local Mathematica or Wolfram Engine

Set the working directory to `wolfram/` and:

```mathematica
SetDirectory[NotebookDirectory[]]
Get["notebook-script.wl"]
```

The script loads the algebra, instantiates the four-work corpus, and
runs the four queries with formatted output. Expected total runtime:
under 1 second on a laptop.

### Option B — Wolfram Cloud (recommended for reviewers without a
local Mathematica install)

Wolfram Cloud has per-cell output limits that truncate single-cell
runs of the full prototype once the visualisations are included. Use
the multi-cell workflow in `paste-cells/` instead: paste each `.wl`
file into its own cell in a fresh cloud notebook and evaluate them in
order. See `paste-cells/README.md` for the full procedure.

The six cells are:

1. `paste-cells/1-setup.wl`             — algebra + kernels + four cores (load only)
2. `paste-cells/2-queries.wl`           — runs Q1–Q4 with text output
3. `paste-cells/3-vis-transfer.wl`      — Tymoczko ↔ Cutting transfer network graph
4. `paste-cells/4-vis-removal.wl`       — Tymoczko removal-cascade graph
5. `paste-cells/5-vis-self-transfer.wl` — methodology self-transfer graph
6. `paste-cells/6-vis-discrimination.wl` — discrimination panel: Tymoczko ↔ NKS
   and Cutting ↔ NKS alongside the centerpiece, so the algebra's
   discriminative behaviour is visible (the centerpiece is the only
   pair where comma-shape match fires; off-pairs cap at lower confidence)

A reference evaluated run (all six cells, with graphs rendered) is saved
to `results/wolfram-cloud-run-2026-05-04-v1.5.nb`. The numerical results
in that notebook:

| Query | Output |
|---|---|
| Q1 mechanism+constraint match | 4 cores returned |
| Q2 Tymoczko ↔ Cutting (centerpiece) | 9 candidates, max conf 0.92, min 0.62 |
| Q3 removal cascade (TymoczkoCore, voice_leading_parsimony) | 0 constraints dropped, 2 mechanisms degraded, 1 failure mode surfaced |
| Q4 RecursiveAnalysis(MethodologyCore) | 30 self-transfers, 5 load-bearing mechanisms, 5 latent failures (re-derive `variety_in_uniformity`, `transparency_as_opacity`, `methodology_blind_spot`) |
| Q2 discrimination panel | Tymoczko↔NKS: 11 candidates, max 0.68. Cutting↔NKS: 8 candidates, max 0.68. Centerpiece is the only pair reaching 0.92 because it is the only pair where comma_shape_match fires. |

## V2 — the machine-fed corpus (August 2026)

V1's README states its own limit: the corpus was five hand-authored
cores, so every result the algebra produced was downstream of the
analyst's own encoding choices — articulation, not measurement. V2
removes that limit. The production platform (falsework.dev) transduces
its stored structural profiles into **CoreV2 typed dependency graphs**
(specification: `../papers/computable-criticism-roadmap.md` §5.1;
transduction implementation: `lib/corev2/` in the node0000 repository),
and `corev2-loader.wl` loads them as `Core[...]` objects the four
queries run on unchanged. Fifteen graphs spanning literature, cinema,
and painting are bundled verbatim in `corpus-v2/`. The corpus includes
two independent transductions of the same work (Jung's *Red Book*) and
two of *Seven Samurai* — deliberate replicate pairs for future
stability measurement.

### The four design decisions

1. **No fabricated comma.** Machine work-kernels carry
   `"CommaStatus" -> "underived"` and no `Comma` field. The
   transduction has not derived an irreducibility witness, so none is
   asserted. Measured consequence: `comma_shape_match` never fires on
   machine cores and the Q2 confidence ceiling is 0.68
   (type + cross-domain), not V1's 0.92. V1's 0.92 was reachable only
   because the Tymoczko ↔ Cutting comma match was hand-planted; the
   machine corpus's silence on that channel is the honest baseline the
   comma-shape graduation must beat.
2. **Derived structural types.** Machine mechanisms carry no curated
   type taxonomy. `Type` is computed from the graph — the sorted sets
   of edge kinds a node participates in, outgoing and incoming
   (`Sig[out:...|in:...]`). Crude, but derived rather than
   hand-planted: the exact opposite failure mode from V1's curated
   vocabulary, stated as such.
3. **Fixpoint removal executor.** V1's `StandardRemovalSignature` is
   single-step. The roadmap (§5.2) mandates cascade to fixpoint:
   `requires` propagates removal, `amplifies`/`certifies` degrade
   survivors with recorded bases, `contradicts` marks released
   tension, and declared failure conditions are evaluated against the
   computed closure (`Triggered` / `PartiallySatisfied` /
   `NotEvaluableUnderRemoval` — rule-violation conditions are not
   evaluable under removal semantics, and the executor says so rather
   than guessing). `CascadeProject` is attached as every machine
   mechanism's `RemovalSignature`, so V1's `RemoveAndProject`
   dispatches to it automatically.
4. **Audit split.** `collapses_to` survival claims are
   machine-checked against the computed closure — a claimed survivor
   the cascade removes is a reported contradiction. Prose
   `asserted_removal_tests` are presented beside the computed cascade
   for human adjudication and are never string-matched.

### Validation discipline

Nothing is trusted across the language boundary. The TypeScript
validator ran at transduction time; `corev2-loader.wl` re-runs the
full contract inside WL — schema shape (`CoreV2SchemaErrors`) and
referential integrity (`CoreV2IntegrityReport`: edge endpoints,
duplicate/self-loop edges, failure-condition references,
removal-test keys, undeclared violated rules, isolated nodes, weak
connectivity) — before any core is constructed. A file that fails
loads as `$Failed` and is excluded, visibly, from the corpus.

### Running V2

Use the multi-cell workflow in `paste-cells-v2/` (see its README).
Cells 1–2 are `falsework-algebra.wl` and `corev2-loader.wl` pasted
directly — single source of truth, no duplicated copies. Cell 3
fetches the corpus from this repository's raw GitHub URLs
(commit-pinned for reproducibility) and revalidates it; cells 4–6
run Q1–Q4 plus the corpus-wide claim audit; cell 7 prints the
results table against the V1 reference run.

### V2 reference run (August 11, 2026)

Evaluated notebook: `results/wolfram-cloud-run-2026-08-11-v2.0.nb`.
Every value pre-registered from the independent Node.js reference
implementation (see `paste-cells-v2/README.md`) was reproduced
exactly — a passed differential test of the cascade semantics across
two independently written implementations.

| Query | Measured output |
|---|---|
| Corpus load | 15 of 15 files fetched, revalidated in WL, constructed, `WellFormedCoreQ` |
| Q1 | type `Sig[out:-|in:requires]` + constraint `requires`: 14 of 15 cores |
| Q2 | 10,991 candidates over 126 ordered cross-domain pairs; max confidence 0.68; `comma_shape_match` fired 0 times |
| Q3 | largest element-seeded cascade: `red-book-of-westmarch-0bd9ff72`, seed `E_note_on_shire_records`, closure 9 nodes with per-step causes; V1 single-step on the same seed sees 1/0/0/0 vs the fixpoint's 9 removed / 16 edges dropped / 2 degraded / 3 failures surfaced |
| Claim audit | 47 declared failure conditions machine-evaluated under their own removal seeds; 4 survivor-claim contradictions (Saint Matthew F2: M4; Westmarch F8: M1, M2, M7; Sátántangó F6: M2; Dreams F6: M1) |
| Q4 | all 15 machine cores: 250 self-transfers total; deepest cascade 8 nodes beyond seed (Westmarch); element nodes are the deepest cascade seeds in 8 of 15 cores |

Three findings worth naming:

1. **The audit catches the transducer.** Four failure modes claim
   survivors (`collapses_to`) that their own condition's cascade
   removes. The machine checked the LLM's structured claims against
   the LLM's own graph and found the inconsistencies. No hand-authored
   corpus could produce this result, because the analyst who authored
   the claims would have authored the graph to match.
2. **Derived types discriminate weakly.** 10,991 Q2 candidates at a
   flat 0.68 ceiling: with the comma channel silent and types derived
   purely from edge-kind signatures, the transfer query over-fires.
   This is the measured cost of refusing to fabricate commas, and it
   is exactly the gap the comma-shape graduation (deliverable 2) is
   specified to close.
3. **Replicate variance is now a number.** The two independent
   transductions of Jung's *Red Book* produced graphs with deepest
   cascades of 4 (`9181ad6f`, seeded at `E_diary_timestamps`) and 1
   (`8c596e2f`). Same work, same model, different structural
   commitments — the reliability program in the roadmap now has its
   first measured datapoint.

### The comma-shape graduation (email artifact 2)

`comma-graduation.wl` closes the loop V1's README opened: the
Tymoczko ↔ Cutting comma match was planted in the data before the
code found it (both kernels hand-assigned the same
`IrreducibilityKind` string). For machine cores, a comma is now
**earned or absent** — never assigned.

Pre-committed definitions (fixed before any run; results reported,
not tuned): a **tension pair** is two nodes joined by a `contradicts`
edge; a **comma witness** ("a distinction that fails to cancel") is a
tension pair whose poles are both load-bearing (each removal cascades
or triggers a declared failure) and where neither pole falls in the
other's cascade — the work maintains the tension rather than
resolving it by dependence. The derived `IrreducibilityKind` is a
canonical string from three computed features of the tension
(shared requires-ground; dependency symmetry; failure-coupling).
Derived kinds carry a `tension_` prefix, so they can never
accidentally shape-match a V1 hand-authored comma. Derived commas
carry `GroundKind -> "computed"`: their formal ground is
machine-checked graph structure, not a classical theorem — a
different epistemic grade from V1's Baker-1966-grounded Pythagorean
comma, kept distinguishable on purpose.

Measured results (Node.js reference 2026-08-11, pre-registered in
`paste-cells-v2/README.md`; Wolfram Cloud confirmation pending):

- **5 of 15 cores earn a comma** — the witness gate is genuinely
  selective (~43 tension pairs in the corpus, 5 witnesses).
- **The 0.92 tier returns on merit**: 128 candidates reach
  type + derived-comma + cross-domain, against 1,516 at the old 0.68
  ceiling; the comma channel fires on only 5 of ~105 core pairs.
- **The kind vocabulary is the measured weakness**: 4 of 5 derived
  commas share one kind, so current selectivity comes from the
  witness gate, not kind diversity. Refining the feature set is the
  named next step, with the numbers to beat stated here.
- **Both replicate pairs mismatch** — one transduction of the same
  work derives a comma, the other does not (Red Book and Seven
  Samurai alike). Comma derivation is not yet stable under
  re-transduction. This is the roadmap's reliability concern
  surfacing exactly where predicted, reported as a finding.

## What this prototype does

- Defines six symbolic types (`Kernel`, `Comma`, `Mechanism`, `Constraint`,
  `FailureMode`, `Core`) as the type discipline of the algebra
- Populates a four-work corpus drawn from FalseWork's existing analyses,
  each anchored by a kernel from Paper 1 v11.6
- Implements the four queries Ellynne specified, as pure functions over
  the schema
- Demonstrates cross-domain mechanism transfer between Tymoczko and
  Cutting as the load-bearing computational result
- Re-derives, computationally, the recursive-self-application failure
  modes that were originally surfaced interpretively in the January
  exchange with Stephen Wolfram

## What this prototype does not do

- It does not prove the kernel framework is correct. It demonstrates
  that the framework is computationally articulable and that one of its
  central claims (cross-domain kernel-shape equivalence) can be rendered
  as executable code.
- It does not validate any specific empirical claim
  (Tymoczko–Coltrane, Cutting's primitive convergence). It uses those
  claims as inputs; the algebra is downstream.
- It does not produce schema mutation under recursion. The V1
  architecture is V2-capable; V2 (recursion that alters the type system
  itself) is flagged as the natural next direction in the closing
  section of the demo script.
- It does not address Paper 2's distinction operation, the Lawvere
  unification, or the territory-position topology. Those are the
  framework's theoretical layer; this prototype operates at the
  operational layer just below them.

## Theoretical anchor

The algebra is the operational instantiation of the kernel/comma
framework documented in the FalseWork papers
(<https://github.com/thefalsework/papers>):

- **Paper 1 v11.6** — *Kernels and Commas* — defines the kernel framework,
  the four-criteria audit, and the six established kernels plus two
  candidates (The Mark, The Threshold).
- **Paper 2 v8.17 (arXiv v1)** — *Epistemic Dependency as Structural Condition*
  — defines the distinction operation that the algebra's removal tests
  empirically instantiate.
- **Validation record** — `validation/OPEN.md` in the papers repository
  is the open-issue tracker for unresolved questions; the algebra makes
  several of those questions executable.

The schema is designed so that the kernel framework is *required*
infrastructure for the algebra, not commentary on it. Stripping the
kernel layer makes the schema malformed — which is the structural
defense against ontological absorption when the work is read by
adjacent research programmes.

## Provenance

- **Origin email** — Stephen Wolfram, January 3, 2026, in response to a
  cold-contact NKS structural analysis. Asked: can you go from
  syllogism-style structural analysis to something more symbolic? Can
  you apply patterns from one work to another? What does the system do
  if recursively fed its own analyses?
- **Routing** — Stephen Wolfram forwarded the thread to the Wolfram
  Institute philosophy team on April 4, 2026.
- **Specification email** — Ellynne Dec, May 3, 2026, on behalf of the
  Computational Metaphysics group. Requested a small Wolfram Language
  prototype demonstrating the four queries above.

This prototype is the response to that specification.
