# FalseWork Algebra Prototype (Wolfram Language)

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
│   ├── tymoczko.wl            Tymoczko, A Geometry of Music — KernelTheFifth
│   ├── cutting.wl             Cutting, F1 film primitives — KernelTheCut
│   ├── nks.wl                 Wolfram, A New Kind of Science — KernelTheConditionalBranch
│   └── methodology.wl         FalseWork methodology self-core — KernelOfMethodology
├── notebook-script.wl         demo script: loads corpus, runs all four queries
├── paste-cells/               multi-cell version for Wolfram Cloud
│   ├── README.md              workflow instructions
│   ├── 1-setup.wl             algebra + kernels + four cores (load only)
│   ├── 2-queries.wl           Q1–Q4 with text output
│   ├── 3-vis-transfer.wl      Tymoczko ↔ Cutting transfer network graph
│   ├── 4-vis-removal.wl       Tymoczko removal-cascade graph
│   └── 5-vis-self-transfer.wl methodology self-transfer graph
└── results/
    └── wolfram-cloud-run-2026-05-04-with-graphs.nb   reference evaluated run
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

The five cells are:

1. `paste-cells/1-setup.wl`           — algebra + kernels + four cores (load only)
2. `paste-cells/2-queries.wl`         — runs Q1–Q4 with text output
3. `paste-cells/3-vis-transfer.wl`    — Tymoczko ↔ Cutting transfer network graph
4. `paste-cells/4-vis-removal.wl`     — Tymoczko removal-cascade graph
5. `paste-cells/5-vis-self-transfer.wl` — methodology self-transfer graph

A reference evaluated run (all five cells, with graphs rendered) is
saved to `results/wolfram-cloud-run-2026-05-04-with-graphs.nb`.

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
