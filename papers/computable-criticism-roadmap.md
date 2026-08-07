# Computable Criticism: Roadmap and Specification

**From machine-assisted structural analysis to a computational structuralism**

FalseWork (falsework.dev)

*Version 0.3 (August 2026; v0.2 added §5.0 — the computational layer is not greenfield, two prototypes exist; v0.3 adds §7.1 on where the layers merge, disambiguates Core v2 from the algebra's deferred V2, and promotes two findings from the algebra review into spec requirements). Register note: this is a programme document — part argument, part engineering specification. Everything argumentative is **[A]**; everything speculative is marked **[O]**; the engineering sections are a spec, graded by acceptance criteria rather than epistemic tags. Nothing here is kernel-checked. This document is written to be handed to a collaborator or engineer who has not read the surrounding corpus: §1–§3 say why, §4 says what changes in the theory, §5–§7 say what to build (§5.0 says what already exists), §8 says in what order, §9 says what is not being claimed.*

---

## 1. Where this starts

As of August 2026 the platform runs two analysis pipelines over cultural works:

- **Structural Profile** (single work): a staged analysis producing a canonical **Core** — generative principle, mechanisms with removal tests, constraints, failure modes, transfer domains, detected patterns — plus derived prose (the **Wrapper**). Epistemic rule: the Core is the source of truth; the Wrapper is a rendering.
- **Deep Synthesis** (two works): functional analyses, qualified mappings, counter-mappings, a generative principle uniting the pair, robustness assessment, and a critical essay.

Behind them sits the FalseWork formal spine: the four-position partition of acts relative to a kernel, machine-checked in Lean (`four_position_partition`, `allFourCellsInhabited_iff`, the opened square), with the **[K]/[C]/[A]/[O]** tag ladder keeping theorem and interpretation visibly distinct.

A recent specimen — the two Red Books, Tolkien's *Red Book of Westmarch* and Jung's *Liber Novus*, profiled separately and then synthesized (see `two-red-books.md`) — demonstrated four things worth building on:

1. **Uncoordinated convergence.** Two pipelines with different stage architectures reached the same load-bearing findings independently (e.g., "suspension is load-bearing; a producible original would collapse the system" ↔ "simulated incompleteness is what authenticates").
2. **Discrimination.** The pattern classifier found nine canonical patterns in the apparatus-saturated Tolkien object and three in the Jung object — it is not spraying matches.
3. **A computable-looking invariant.** Both works contain a *load-bearing flaw* — an element that violates the work's governing rule while carrying maximal structural load (Tolkien's undocumented final link; Jung's medieval-breaking timestamps). This was discovered by reading, but it has the shape of a graph property.
4. **A visible seam.** The Jung profile's Core classified terminal incompletion as *incidental* while its Wrapper built a thematic argument on it. Today that divergence is caught by editorial attention. It should be caught by a machine.

The thesis of this document: the pipelines currently produce structured **description** — records of claims a model made. The next stage is to produce **computable objects** — symbolic structures whose consequences are calculated rather than asserted. The LLM keeps the one job it is uniquely good at (reading an artwork into a representation) and everything downstream becomes computation.

## 2. Why this is forward progress

A method makes progress when it becomes capable of being wrong in new ways.

- Prose criticism cannot be incorrect; there is nothing to check.
- The current pipelines are checkable weakly: removal tests are stated specifically enough to dispute.
- The computational layer makes them checkable strongly: a subtraction cascade either follows from the declared dependency graph or it does not; a pattern signature is either satisfied or not; a claimed cross-work mapping either extends or hits an obstruction.

The standing test for the whole enterprise, stated now so it can fail later: **if the computed layer never catches the LLM layer in an error, it is doing no work; if it catches errors constantly, the representations are too weak to compute over.** Either result is informative. That is what distinguishes an instrument from a rhetoric.

## 3. What kind of structuralism this is

Structuralism's founding bet — cultural objects have describable formal skeletons whose *relations*, not contents, carry the load — was never refuted. It was abandoned for lack of infrastructure: no procedure for producing representations (two analysts, two structures, no adjudication), no way to compute consequences of a proposed structure, no separation between formal claim and interpretive gloss.

The present programme supplies all three, in a division of labor:

| Layer | Role | Analogue in the corpus |
|---|---|---|
| LLM pipelines | **Perception**: read works into representations | proposes, never confirms (Paper 2: a model is a sound refuter, unsound confirmer) |
| Computational layer (this spec) | **Consequence**: derive what follows from a representation | prototyped twice, disconnectedly (§5.0); unified by this document |
| Lean | **Verification**: check universal claims about the machinery | [K] floor |

Historical placement, for orientation: structuralism 1.0 had theory without instruments; distant reading had instruments without depth; structure-mapping theory (Gentner, SME, 1980s) had the comparison algorithm but no way to produce representations of real artworks. LLMs are the missing perception layer. The tag ladder is the missing epistemics. **[A]**

What this is *not* is a way to compute culture — see §9.

## 4. Theoretical reframing: commas are broad, kernels are local

*Status: [A] proposal, revising the domain-level framing of Paper 1. One row of consequences is [O].*

Paper 1 proposes working kernels at **domain** level (Music: the Fifth; Cinema: the Cut; Physics: measurement — the last admittedly strained). The evidence that "domain" is too coarse is internal: the corpus already rules that centerless process music "does not enter — no kernel → classifier undefined," although process music is indisputably music. The kernel never belonged to *music*; it belongs to the twelve-tone equal-temperament **practice**, which was hegemonic enough to pass for the domain.

The rescaling, stated as a principle:

> **Commas are inherited broadly; kernels are founded locally.**
> A comma (a distinction that fails to cancel) is shared across a tradition. A kernel (the minimal generative operation that manages the comma) is founded by a commitment-grade act within a practice — and each founding opens its own four-fold.

Worked example (music): the Pythagorean comma — fifths never close the octave — is *tradition-wide*. 12-TET is not the comma but one **response**: equal temperament distributes the comma across all twelve fifths (a Distribution-cell act relative to the shared obstruction). Meantone and just intonation are rival responses. Temperaments are rival practice-level kernels founded against one tradition-level comma.

Payoff (physics): "physics" has no kernel because physics is not monogenic — nothing generates all of it. But its shared commas are identifiable (the QFT/GR incompatibility; the measurement problem). **String theory** passes Paper 1's four working-kernel criteria at practice level: *prior* (inherits the QFT/GR tension), *monogenic* (one generative move — replace point particles with extended objects), *inescapable* (inside the practice everything routes through the string), *self-limiting* (the landscape: ~10⁵⁰⁰ vacua the theory generates and cannot select among from inside). Loop quantum gravity is then not a puzzle but a **rival kernel founded against the same comma** — a different temperament for the same non-closing fifth. The structure of a discipline's schools becomes: one comma, several kernel-foundings, each with its own four-fold. **[A]**; a *formal* kernel (ordinary-element realization) for any physics practice remains unbuilt **[O]**.

Instance level: a Structural Profile is already a work-level kernel–comma analysis. The generative principle is the work's kernel (conspicuously monogenic in strong works); the constraints are its inescapability conditions; the failure modes are its comma. The Red Books' mirrored flaw is the instance-level thesis in miniature: each work is generated by its relation to a distinction it cannot cancel.

The guardrail against vacuity is already a theorem: the four-fold opens **iff the kernel element is ordinary** — neither regular nor dense (`allFourCellsInhabited_iff`). Most instance-level marks are degenerate: they cancel (regular) or saturate (dense), and no four-fold opens. Ordinariness is the scale-gate. The machinery is scale-indifferent; ordinariness decides where it bites. Recursive nesting of foundings is already available as `CanonizationClosure` (recursive partition **[K]** for the abstract composition).

Revision cost: Paper 1's domain table is reframed — "Music: the Fifth" becomes "the 12-TET practice within music"; the physics row points at practices. The music-instance [K] results are untouched; the lattice never cared what the unit around it was called.

## 5. Specification: the computational layer

### 5.0 Prior art: two existing prototypes

The layer specified below is not greenfield. Two prototypes already implement complementary halves of it, with **opposite representation choices and no connection to each other**:

**The Wolfram Language algebra** (`wolfram/` in the papers repository; May 2026, built to a specification from the Wolfram Institute's Computational Metaphysics group). A typed symbolic algebra — six heads: `Kernel`, `Comma`, `Mechanism`, `Constraint`, `FailureMode`, `Core` — over a five-work hand-authored corpus. It already has: a working **removal-test executor** (`RemoveAndProject`: a rewrite that drops the mechanism, drops orphaned constraints, marks dependents degraded, surfaces the declared failure mode); **predicate-based cross-work transfer** (`TransferCandidates`, five predicates including comma-shape match between hosting kernels — the Tymoczko ↔ Cutting result, and the only pair where comma-shape match fires); and **recursive self-application** (`RecursiveAnalysis` computationally re-derives the methodology's own latent failure modes, originally found interpretively). The physics-anchor scripts alongside it are executed computational results, not sketches — v5 witnesses Kochen–Specker as a finite computation; v6a verifies the Heyting-collapse at Peres-33 scale. Limits: the corpus is hand-authored, the schema is frozen against Paper 1 v11.6, and nothing feeds it from the production pipelines.

**The Lab** (falsework.dev/lab; `lib/lab/` in node0000). The production-side counterpart: a **25-feature typed vector** extracted per profile by LLM (`feature-schema.ts` v3 — integers 1–5, booleans, small enums, deliberately no floats), with a `feature_source` column already anticipating the migration from LLM extraction to computed proxies. Over the vectors: a **predicate engine** ("the computational core — predicates parse and evaluate, no LLM required") linked to canonical patterns; **detection-conflict resolution** (`detection-conflicts.ts`) that compares LLM pattern detection against predicate detection and flags `llm_only` / `predicate_only` / `agreement` — the computed-vs-asserted seam of §5.2, already running, applied to pattern detection; **cross-validation rules** within a vector; **feature-distance structural neighbors** (structure similarity no text embedding can find); and an **edge materializer** that turns shared predicate matches into the corpus graph rendered at `/map/patterns`. Limit: a flat vector cannot represent which element depends on which, so removal cascades are impossible over it.

The complementarity is exact, and so is the gap:

| Spec item | Wolfram algebra | Lab | Missing |
|---|---|---|---|
| §5.1 typed schema | graph-shaped, hand-authored, 5 works | flat vector, pipeline-fed, whole corpus | a dependency graph emitted by the pipeline |
| §5.2 executor + audit | executor ✓, audit ✗ | audit pattern ✓ (for detections), executor ✗ | the two halves joined on one representation |
| §5.3 signatures | transfer predicates | full predicate engine + conflict flags | signatures over graphs rather than vectors |
| §5.4 structure mapping | predicate-based transfer | feature-distance neighbors | actual subgraph homomorphism |
| §5.5 enumeration | lattice enumeration in the physics anchors (different target) | — | mechanism-graph enumeration |

The Wolfram prototype has an executor but no audit because its cores are hand-authored (there is no independent assertion to audit against); the Lab has an audit but no executor because its vectors cannot cascade. **Core v2 (§5.1) is the merge**: graph-shaped like the algebra, pipeline-fed and audited like the Lab. Phase 1 of the roadmap is therefore an integration job, not a build-from-scratch.

### 5.1 Core v2 — the typed dependency graph

The current Core buries a graph in prose ("C1: the double-time effect *requires* diary timestamps"). Core v2 makes the graph the object.

```ts
// Core v2 — schema sketch (node0000)

type NodeId = string;

interface StructureNode {
  id: NodeId;                    // "M1", "E_dates"
  kind: 'mechanism' | 'element';
  label: string;                 // "Two-register stratification"
  description: string;
  confidence: 'high' | 'medium' | 'low';   // LLM self-report, uncalibrated
  evidence: string[];
  rules?: string[];              // governing rules this node OBEYS (for signature checks)
  rule_violations?: string[];    // governing rules this node INVERTS (load-bearing flaw detection)
}

type EdgeKind =
  | 'requires'      // A is inert/incoherent without B
  | 'amplifies'     // A strengthens B but B survives A's removal
  | 'certifies'     // A supplies the authority/warrant B trades on
  | 'contradicts';  // A and B assert incompatible rules (productive or fatal per constraints)

interface StructureEdge {
  from: NodeId;
  to: NodeId;
  kind: EdgeKind;
  rationale: string;             // the old constraint prose, preserved as annotation
}

interface FailureMode {
  id: string;                    // "F1"
  condition: { removed?: NodeId[]; violated?: string[] };  // machine-evaluable trigger
  consequence: string;           // prose, plus optionally:
  collapses_to?: 'nothing' | NodeId[];  // what survives
}

interface CoreV2 {
  schema: 'v2';
  work: { title: string; creator: string; domain: string; practice?: string };
  principle: string;             // the work-level kernel, one sentence
  nodes: StructureNode[];
  edges: StructureEdge[];
  failure_modes: FailureMode[];
  asserted_removal_tests: Record<NodeId, string>;  // LLM's claims, kept for audit
  provenance: { model: string; prompt_version: string; generated_at: string };
}
```

Migration: the Stage 1–6 pipeline gains a final transduction stage that emits Core v2 from the existing stages; the v1 Core remains until v2 is validated. The LLM authors nodes and edges; it no longer authors what follows from them.

### 5.2 The removal-test executor and the Core audit

`subtract(core, nodeIds) → CollapseReport`: delete nodes, propagate along `requires` edges to fixpoint, evaluate failure-mode conditions, return the surviving subgraph and triggered failures.

The **audit** is the point: for each node, compare the computed cascade against `asserted_removal_tests[node]` (LLM judges agreement — the one place a model re-enters, as a *refuter*: it flags mismatches, never confirms). Output per profile:

- `consistent`: cascade matches assertion,
- `graph_gap`: assertion implies an edge the graph lacks (candidate edge, human-reviewable),
- `prose_overclaim`: assertion exceeds what the graph supports (Wrapper discipline, mechanized).

The existing "Test this claim" UI buttons stop displaying the model's answer and start running the test.

Neither piece starts from zero, but neither is a straight port. The executor starts from the Wolfram algebra's `RemoveAndProject` semantics (§5.0) with one **mandatory upgrade**: `RemoveAndProject` propagates one step only (direct dependents marked degraded, no further consequences); the executor must cascade to fixpoint, so that a degraded or deleted node's own dependents are re-evaluated until nothing changes. The audit's architecture — two independent detection paths, disagreements flagged rather than auto-resolved — is already running in the Lab's `detection-conflicts.ts` and generalizes from pattern detections to removal tests.

**Acceptance criteria:** executor is deterministic and pure; audit runs on every new profile; the Jung incidental/thematic seam (known specimen) is detected as `prose_overclaim` when reproduced.

### 5.3 Pattern signatures as graph predicates

Each canonical pattern in the library gains a `signature`: a predicate over `CoreV2`. Examples from the current library:

- **Embedded Rule Negation**: ∃ exactly one node `n` with `rule_violations ≠ ∅` whose violated rules are obeyed by all other nodes, and `n` is connected (not an appendix).
- **Structural Consequentiality**: ∃ node whose removal cascade eliminates > k% of nodes (threshold declared in the signature).
- **Load-bearing flaw** (new, from the Red Books specimen): ∃ node with `rule_violations ≠ ∅` whose removal cascade is maximal among all nodes. Both Red Books satisfy it; most works should not — that is the claim, now checkable corpus-wide.

Detection becomes: LLM proposes patterns (as now); the checker evaluates signatures; disagreements are audit events. **Novel mechanism** gets a computable meaning: a subgraph satisfying no library signature. Base rates across the corpus come free, answering the promiscuity question (nine patterns on Tolkien, three on Jung) with data instead of anecdote.

**Acceptance criteria:** ≥ 5 canonical patterns carry signatures; signature evaluation reproduces the Red Books detections; corpus base-rate table generated.

### 5.4 Deep Synthesis as structure mapping

Comparing two works becomes searching for a **maximal partial homomorphism** between their Core v2 graphs (respecting node kinds and edge kinds):

- **Qualified mappings** = the matched subgraph (LLM annotates `shared_function` / `difference_qualifier` on computed matches — perception again, not consequence).
- **Counter-mappings** = obstructions: places where no consistent extension of the mapping exists. "The mechanisms are mutually annihilating" becomes a statement of non-extendability — a property of two graphs, not a rhetorical flourish.
- The **generative principle** stage receives the computed mapping as input rather than free-form prose, constraining the principle to what the mapping supports.

This is the Structure-Mapping Engine lineage (Falkenhainer–Forbus–Gentner) with the missing front end supplied: representations of real artworks, produced by a repeatable procedure.

Two requirements inherited from the algebra review (§5.0):

- **No bare numeric confidence.** The algebra's hand-set rubric (0.92, 0.81, …) does not survive into production. Mapping strength is reported as structured evidence — which nodes matched, which edge kinds were respected, which predicates fired — the algebra's own deferred `TransferEvidence` form, adopted here as a requirement rather than a wishlist item.
- **The mapping and the license must be auditable against each other.** The algebra's transfer query (comma-shape match between hosting kernels) and this homomorphism search are the same operation at two granularities: the practice layer supplies the coarse *license* for a cross-work mapping, the instance layer computes the fine *content*. Prediction, checkable once both run over the same corpus: homomorphism-found correspondences should concentrate on pairs whose kernels comma-shape match. Disagreement between the two granularities is an audit event, not an embarrassment — the same seam discipline as §5.2, one altitude up (see §7.1).

**Acceptance criteria:** homomorphism search implemented (exact for graphs ≤ ~40 nodes; greedy + repair above); Red Books rerun computes ≥ 4 of the 6 published correspondences and locates the authorship obstruction; mapping output carries structured evidence, no bare scores.

### 5.5 Enumeration and computed positions

Two [O]-grade directions once §5.1–§5.4 are stable — the most Wolfram-flavored steps:

- **Enumerate the small space.** With mechanisms as typed combinators and constraints as consistency rules, enumerate small consistent mechanism-graphs. Locate the corpus in that space. Unoccupied-but-consistent cells are **predictions** — structurally viable works no one has made. Criticism has never produced a falsifiable prediction of this kind; `why_twelve` (enumerate the temperaments, find the forced instance) is the in-house precedent for the move.
- **Compute kernel positions.** Where a practice has a declared kernel object, derive the work's four-fold position from its graph's relation to it, instead of asking a classifier. The LLM classification remains as a cross-check — two independent instruments again.

Substrate note: a TypeScript executor inside node0000 covers §5.1–§5.4 with no new infrastructure. Wolfram Language is the natural richer substrate for §5.5 (symbolic expressions, graph isomorphism machinery, cheap enumeration) and for **computational essays** as a publication format — a *Two Red Books* notebook in which the reader executes the subtraction tests themselves. The existing algebra (§5.0) is the starting point on that side: pointing it at pipeline-emitted Core v2 objects instead of hand-authored cores turns the demonstration artifact into an instrument, and its deferred V2 questions (schema mutation under recursion, `FourCriteriaAudit`, `KernelTopologyProjection`) become live once the corpus is machine-fed. The architecture is vendor-indifferent; the seam discipline is not.

## 6. The reliability programme

The instrument becomes a research object in its own right. Four studies, each a paper, roughly in order of increasing cost:

1. **Test–retest.** Same work, same model, N independent profile runs: how stable are the graph, the principle, the signatures? (Entropy metrics and consensus machinery already exist on the platform.)
2. **Model-change natural experiment.** The database already contains syntheses and profiles produced under Sonnet 4, Sonnet 4.5, and Fable 5 on overlapping material. Quantify what changed. Model-dependence is the new analyst-dependence; study it rather than hide it.
3. **Expert calibration.** Where domain experts hold committed positions on a specimen (the Jung–Tolkien pair has a named, reachable expert), solicit structured disagreement: which nodes, edges, and verdicts does the expert reject, and does the rejection indicate a perception failure (bad reading) or a scope limit (imagery outside the schema)?
4. **Generative validation.** The Alexander test: principles claim to be generative — have someone make a small work by following one, and profile the result. If the pattern is real, the new work's graph should satisfy it.

## 7. Architecture summary

```
artwork / text
     │
     ▼
LLM pipelines (perception)          — proposes representations; sound refuter, unsound confirmer
     │  Core v2: typed graph
     ▼
Computational layer (consequence)   — subtraction cascades, signatures, homomorphisms, enumeration
     │  computed findings + audit against asserted findings
     ▼
Lean (verification)                 — universal claims about the machinery itself [K]
```

The seam between **computed** and **asserted** is the platform's version of the corpus's seam between **[K]** and **[A]**: never silently promoted, always displayed. The audit (§5.2) is the mechanism that keeps it honest.

### 7.1 Where the layers merge

The middle box above is not one thing. The computational layer has three altitudes, already prototyped separately (§5.0), and they stack rather than compete:

```
practice layer   — WL algebra:   kernels, commas, cross-domain transfer LICENSE
       ▲  anchors (kernel reference)          ▼ derives comma shapes
instance layer   — Core v2:      one work's dependency structure (this spec's center)
       ▲  aggregates                          ▼ projects
corpus layer     — Lab vectors:  fingerprints, base rates, neighbors, /map
```

The merge point is the **kernel anchor** — the algebra's own load-bearing design commitment (every `Mechanism` carries a `Kernel` reference; a schema without one is malformed) meeting Core v2's `work.practice` and `principle` fields (the work-level kernel of §4). Three consequences:

- **Instance → practice.** A transduction from pipeline-emitted `CoreV2` objects into the algebra's `Core[...]` heads turns the algebra's five hand-authored cores into a machine-fed corpus. This repairs the algebra's main epistemic weakness: comma-shape match currently reduces to hand-authored label equality (`IrreducibilityKind` strings — the Tymoczko ↔ Cutting match was planted in the data before the code found it). With instance graphs underneath, a claimed comma shape becomes *checkable against structure* rather than asserted; the algebra's headline capability changes grade from articulation to measurement.
- **Practice → instance.** The algebra supplies what instance graphs alone lack: the semantics of cross-work comparison. A homomorphism between two Core v2 graphs (§5.4) is just a subgraph alignment until the practice layer says *why* it should exist — shared kernel shape against a shared comma. The two granularities audit each other (§5.4).
- **Instance → corpus.** The Lab's 25-feature vector becomes, feature by feature, a computed *projection* of the instance graph (several features are already graph statistics in disguise: self-reference depth, constraint exposure, element density). This is the Lab's own planned `feature_source` migration, given its target representation.

**Naming discipline: "Core v2" ≠ the algebra's "V2."** The algebra's design notes defer a V2 wishlist; every item on it lands in an existing section of this spec. No part of the Wolfram direction diverges from this document — the layers were always aimed at the same architecture from different altitudes:

| Algebra V2 item (design-notes.md) | Where it lands here |
|---|---|
| `TransferEvidence` (structured basis, no bare scores) | §5.4 requirement — adopted, mandatory |
| `FourCriteriaAudit` (Paper 1 §3 audit as a function) | §5.5 computed kernel positions |
| `KernelTopologyProjection` (project a core onto the four-fold) | §5.5 computed kernel positions |
| Schema mutation under recursion (new types from self-analysis) | §5.3 novel-mechanism promotion: a subgraph satisfying no library signature is a *candidate* new pattern type, human-gated before it enters the library |
| Paper 2 linkage (encode the distinction operation itself) | Lean layer — a universal claim about the machinery, verified there or not at all |

## 8. Roadmap

**Phase 1 — the merge** (node0000; smallest useful increment)
This is integration, not greenfield (§5.0). Core v2 schema + transduction stage — graph-shaped like the Wolfram algebra, pipeline-fed like the Lab's vectors; removal-test executor ported from `RemoveAndProject` semantics; Core audit generalized from `detection-conflicts.ts` and wired into every new profile; "Test this claim" buttons execute. The Lab's 25-feature vector is not discarded — it remains the coarse fingerprint (neighbors, corpus statistics) alongside the graph, and its `feature_source` migration to computed proxies proceeds independently. *Exit test: the known Jung seam is machine-caught.*

**Phase 2 — signatures and mapping**
Pattern signatures for the most-used library entries; corpus base rates; homomorphism-based synthesis behind a flag, compared against the LLM synthesis on ~10 known pairs. Plus the merge transduction (§7.1): `CoreV2 → Core[...]`, so the WL algebra runs over the machine-fed corpus and the practice-vs-instance consistency audit (comma-shape license vs computed homomorphism) becomes runnable. *Exit test: Red Books correspondences and the authorship obstruction reproduced computationally.*

**Phase 3 — reliability studies 1–2**
Test–retest and the model-change study, run against the existing database plus scheduled reruns. Publishable regardless of outcome. *Exit test: a stability number per pipeline stage, with confidence intervals.*

**Phase 4 — enumeration, positions, and the notebook**
Small-space enumeration; computed kernel positions cross-checked against classifier output; one computational essay (Two Red Books, executable). *Exit test: at least one unoccupied-but-consistent cell stated as a public prediction.*

**Phase 5 — the papers**
(i) Methods preprint: the pipeline as instrument, honestly graded, reliability questions posed. (ii) The kernel-scale note (§4: commas broad, kernels local, ordinariness as scale-gate; temperaments worked example; string theory payoff). (iii) Reliability results. (iv) Expert-calibration case study.

Phases 1–2 are engineering inside the existing platform. Phase 3 is mostly queries against data that already exists. Nothing in Phases 1–3 requires new theory; §4 can proceed in parallel as writing.

## 9. What this does not claim

- **Not computing culture.** The system computes the consequence structure of *formal representations of artifacts*. The representation is theory-laden (the schema decides what is visible; a dependency graph has no slot for how gold leaf feels under lamplight); the artifact is not the practice; the formalization is silent on worth and affect, as the corpus already declares itself to be.
- **The instrument has its own comma.** Representing a work as a distinction-structure of mechanisms and constraints is itself a kernel-act, and Paper 1's thesis applies reflexively: the residue — everything real but not schema-representable — is the instrument's own unresolvable limit. The interesting question is not "can criticism be computed?" but "where exactly does the computation stop?" — and the programme's four positions (work inside the schema; refuse it; work the residue; distribute across the seam) predict the field that will form around the boundary.
- **Confidence labels are not probabilities** until study 1 calibrates them; computed findings are not truths about works, only truths about representations; and every claim in this document above the engineering layer remains [A] or [O] until something checks it.

---

*Companion documents: `two-red-books.md` (specimen), `field-guide.md` (programme overview), Paper 1 (kernels and commas), Paper 2 (epistemic dependency and correction), `wolfram/README.md` and `wolfram/design-notes.md` (the existing WL algebra, §5.0). Platform: node0000 (falsework.dev) — pipelines currently Claude Fable 5 with Sonnet 4.5 fallback; the Lab at `/lab` (feature vectors, predicate engine, detection conflicts); the pattern map at `/map/patterns`.*
