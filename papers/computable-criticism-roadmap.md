# Computable Criticism: Roadmap and Specification

**From machine-assisted structural analysis to a computational structuralism**

FalseWork (falsework.dev)

*Version 0.1 (August 2026). Register note: this is a programme document — part argument, part engineering specification. Everything argumentative is **[A]**; everything speculative is marked **[O]**; the engineering sections are a spec, graded by acceptance criteria rather than epistemic tags. Nothing here is kernel-checked. This document is written to be handed to a collaborator or engineer who has not read the surrounding corpus: §1–§3 say why, §4 says what changes in the theory, §5–§7 say what to build, §8 says in what order, §9 says what is not being claimed.*

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
| Computational layer (this spec) | **Consequence**: derive what follows from a representation | new — the subject of this document |
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

**Acceptance criteria:** homomorphism search implemented (exact for graphs ≤ ~40 nodes; greedy + repair above); Red Books rerun computes ≥ 4 of the 6 published correspondences and locates the authorship obstruction.

### 5.5 Enumeration and computed positions

Two [O]-grade directions once §5.1–§5.4 are stable — the most Wolfram-flavored steps:

- **Enumerate the small space.** With mechanisms as typed combinators and constraints as consistency rules, enumerate small consistent mechanism-graphs. Locate the corpus in that space. Unoccupied-but-consistent cells are **predictions** — structurally viable works no one has made. Criticism has never produced a falsifiable prediction of this kind; `why_twelve` (enumerate the temperaments, find the forced instance) is the in-house precedent for the move.
- **Compute kernel positions.** Where a practice has a declared kernel object, derive the work's four-fold position from its graph's relation to it, instead of asking a classifier. The LLM classification remains as a cross-check — two independent instruments again.

Substrate note: a TypeScript executor inside node0000 covers §5.1–§5.4 with no new infrastructure. Wolfram Language is the natural richer substrate for §5.5 (symbolic expressions, graph isomorphism machinery, cheap enumeration) and for **computational essays** as a publication format — a *Two Red Books* notebook in which the reader executes the subtraction tests themselves. The architecture is vendor-indifferent; the seam discipline is not.

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

## 8. Roadmap

**Phase 1 — the graph and the executor** (node0000; smallest useful increment)
Core v2 schema + transduction stage; removal-test executor; Core audit wired into every new profile; "Test this claim" buttons execute. *Exit test: the known Jung seam is machine-caught.*

**Phase 2 — signatures and mapping**
Pattern signatures for the most-used library entries; corpus base rates; homomorphism-based synthesis behind a flag, compared against the LLM synthesis on ~10 known pairs. *Exit test: Red Books correspondences and the authorship obstruction reproduced computationally.*

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

*Companion documents: `two-red-books.md` (specimen), `field-guide.md` (programme overview), Paper 1 (kernels and commas), Paper 2 (epistemic dependency and correction). Platform: node0000 (falsework.dev), pipelines currently Claude Fable 5 with Sonnet 4.5 fallback.*
