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
│   └── four-position-physics-v3.wl  Route A v3 Bohrification-native kernel
│                                      candidates: discretised V(M_2(C) (+) C)
│                                      vs. poset-isomorphic V_d(C^7) classical
│                                      control. Tests 7 kernel candidates
│                                      (sec. 4.1-4.6, 4.8 of v3-scope.md) plus
│                                      exhaustive non-regular sweep (sec. 4.7).
│                                      Sanity-check + cell-cardinality-baseline
│                                      run; dimensionality caveat (M_2(C) has
│                                      dim < KS threshold) means negative or
│                                      mixed result expected on cell-non-
│                                      emptiness criterion. To be executed.
├── notebook-script.wl         demo script: loads corpus, runs all four queries
├── paste-cells/               multi-cell version for Wolfram Cloud
│   ├── README.md              workflow instructions
│   ├── 1-setup.wl             algebra + kernels + four cores (load only)
│   ├── 2-queries.wl           Q1–Q4 with text output
│   ├── 3-vis-transfer.wl      Tymoczko ↔ Cutting transfer network graph
│   ├── 4-vis-removal.wl       Tymoczko removal-cascade graph
│   ├── 5-vis-self-transfer.wl methodology self-transfer graph
│   └── 6-vis-discrimination.wl  cross-pair comparison panel
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
- **Paper 2 v8.2** — *The Distinction Operation and Inherited Validity*
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
