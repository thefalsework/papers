# Accretion study — specification (committed before anything runs)

**Status: SPEC ONLY. Nothing in this folder has been executed.** This
document fixes the question, the models, the estimator, the conjectures,
the phase structure, and the interpretation table before any simulation
is written or run. Registered per the program's discipline: exploratory
and confirmatory tiers are separated in advance, and the confirmatory
tier's predictions will be committed before its first run, on seeds the
exploratory tier never touched.

## 1. The question

The field campaign left a two-part regularity with no theory under it:

1. **E > R beyond the battery** — Exploitation-cell members out-grow
   Refusal-cell members at matched degree, out-degree, age, exact graph
   distance, PageRank, and k-core — holds on Go and Debian (sealed
   out-of-sample hit), deflates on crates.io at fine grain, and is null
   or inverted on all three proof corpora.
2. **The engine ordering is corpus-local** — E > D on Go and Mathlib;
   D > E on Debian, AFP, and the Isabelle distribution — and every
   corpus-level axis proposed to explain the split is dead by
   registered test (maintained/frozen, refereed/open, proofs/software,
   entry/file grain).

Dead axes at the corpus level suggest the governing variable lives in
the **growth process itself**. This study asks, in a setting where the
growth process is fully known because we choose it: **which accretion
rules force which growth signature?**

## 2. The setting

Growing directed acyclic graphs. At step t, node t arrives and chooses
a set of dependencies among existing nodes according to a rule ρ; edges
are immutable after birth; nothing is deleted. Snapshots are taken at
fixed node counts T_0 < T_1 < … (the graph at size T is exactly nodes
0..T−1 and their edges, so snapshots are free). This mirrors the real
corpora: near-acyclic, accretion-dominated, with age = arrival index.

Out-degree per new node: m drawn uniform from {1,2,3,4} (mean 2.5,
matching the field corpora's edge/node ratios of ~2.5–4).

## 3. The rules (the independent variable)

- **U (uniform):** each of the m dependencies drawn uniformly from all
  existing nodes. Attachment reads *nothing*.
- **PA (preferential attachment):** each dependency drawn with
  probability proportional to in-degree + 1. Attachment reads
  *popularity only* — the classic model behind "growth goes where the
  traffic is."
- **PC(β) (platform-cone, breadth β):** the new node first picks a
  *platform* u with probability proportional to in-degree + 1 and
  depends on it; each of its remaining dependencies is, independently:
  with probability β, drawn uniformly from all nodes (*integrative* —
  a foot outside the platform's world); otherwise drawn uniformly from
  down(u), the platform's dependency cone (truncated BFS, cap 200
  nodes) (*specialized* — building strictly over the platform's
  claimed territory). Grid: β ∈ {0, 0.25, 0.5, 0.75, 1}.

PC is the cartoon of "redeeming a platform's IOUs": a specialized
package's entire footprint lies over ground its platform already
claims. β is the knob between pure specialization (β = 0) and pure
integration (β = 1).

## 4. The estimator (the fixed instrument)

The **exact Debian-grade estimator**, reused verbatim from
`baseline-gauntlet/` / `debian-study/03`: evaluable principal kernels
(seeded cap 300 per baseline); candidates grouped by cell × exact
undirected distance to the kernel's down-set; sides capped 300 per
group; greedy nearest-neighbor matching without replacement in the
z-space of [log1p in-degree, log1p out-degree, age, log PageRank,
k-core], caliper 0.5; balance gate max SMD ≤ 0.10; gains = horizon
in-degree − baseline in-degree; paired mean difference; within-pair
sign-flip nulls, 1000 draws; verdicts HOLDS / NULL / REVERSES /
INFEASIBLE / UNINFORMATIVE exactly as in the field. Snapshot schedule
and horizon fixed in the scripts (target: 6 checkpoints, horizon +2,
baselines 0..3), subject only to the Phase-A feasibility census.

A synthetic rule "produces E > R" iff this estimator — the same one
that judged Go, crates, and Debian — says HOLDS. No new statistics are
invented for the synthetic worlds.

## 5. Conjectures (fixed now, before any run)

- **C1 (feature-blindness null).** If the attachment law is measurable
  with respect to the matched battery — U reads nothing, PA reads only
  degree — then at matched battery the expected paired difference is
  zero. *Registered expectation: U and PA come out NULL on both
  contrasts.* Sketch of the eventual theorem: conditional on the
  matched features, under a feature-measurable attachment law the
  future edge flux into two matched members is exchangeable, so the
  paired difference is symmetric around 0; the subtlety to handle is
  that matching is at baseline while attachment reads evolving
  features (mean-field / coupling argument needed).
- **C2 (territory-correlation suffices).** PC with low β reads the
  graph's *cone structure* — which member sits over which claimed
  ground — and this is not a function of the battery. *Registered
  expectation: PC(0) comes out E > R HOLDS at matched battery.*
- **C3 (breadth sets the engine).** The E-vs-D ordering is governed by
  β: specialized growth (low β) yields E > D; integrative growth
  (high β) yields D > E or null. If true, the corpus-local engine
  orderings in the field (Go E > D vs Debian D > E) are measurements
  of the characteristic footprint breadth of each ecosystem's new
  arrivals — a named, measurable variable where four named axes died.

## 6. Phases

- **Phase 0 (this document).** Spec committed. Nothing run.
- **Phase A — exploratory, labeled as such.** Seed set A (constants to
  be fixed in the script header). Feasibility census first (kernel
  evaluability, pair counts, balance — the synthetic analogue of the
  blind censuses). Then the estimator over the rule grid
  {U, PA, PC(0), PC(.25), PC(.5), PC(.75), PC(1)}. Purpose: map the
  landscape, check the instrument self-test (U and PA *should* be
  null — if PA shows a battery-proof cell effect, our estimator leaks
  and the field results need re-examination; Phase A doubles as an
  audit of the program's own instrument), and calibrate where the C3
  flip sits. Results carry NO confirmatory weight and will be reported
  as exploration.
- **Phase B — registered confirmation.** FRESH seeds never used in
  Phase A. Predictions fixed from C1–C3 as sharpened by Phase A
  (directions and thresholds committed before the run). This is the
  scored study; its verdicts go in the record alongside the field
  studies.
- **Phase C — the theorem.** Prove C1 (the null direction) on paper:
  feature-measurable attachment ⇒ no cell signal at matched features.
  This is the theorem that converts the field result into a mechanism
  statement: *Go and Debian's battery-proof E > R certifies that real
  attachment reads territory structure that no standard feature
  carries.* The positive direction (PC(β) analytics) is attempted
  second; if it resists, the registered simulations stand as the
  counter-model evidence. Lean formalization is optional and later.

## 7. Interpretation table (fixed in advance)

| outcome | reading |
|---|---|
| C1 holds (U, PA null) + C2 holds (PC(0) E>R) | The battery-proof field hits become mechanism detections: real ecosystems' attachment reads claimed-territory structure. Phase C's theorem is worth proving; the empirical paper gains its theory section. |
| C1 fails (PA shows battery-proof E>R) | **Instrument audit failure** — the estimator leaks degree information the matching should absorb. Report at full prominence; re-examine Go and Debian before any further claims. The most important possible outcome, and the least pleasant. |
| C2 fails (PC(0) null) | Cone-correlated attachment is not sufficient for the field signature; the mechanism is something else; C3 grid may still locate it. The theory chapter stays open. |
| C3 holds (β flips E-vs-D) | The engine ordering has a named governing variable. Next registered field study: measure footprint breadth of new arrivals on Go vs Debian and check the sign matches — turning a post-hoc explanation into a forward test. |
| C3 fails (no flip on the grid) | The engine split is not breadth; strike the candidate, keep the signatures as unexplained spectral types. |

## 8. Costs, risks, caveats

- Compute: each rule-config ≈ one Debian-scale estimator run (minutes);
  the full grid is under an hour. Growing the graphs is trivial.
- The truncated-cone approximation (cap 200) and the m-distribution are
  modeling choices, fixed here; robustness checks (cap 500, m ∈ {1..6})
  are Phase-A descriptives, not knobs to tune after Phase B.
- External validity is the standing caveat: U, PA, PC are cartoons.
  The claim being built is *existence-grade* — that there are natural
  rules forcing each signature and a clean boundary between them — not
  that any real ecosystem literally runs PC(β).
- The known unknown: whether synthetic DAGs of this shape have enough
  evaluable kernels and matchable E–R overlap at all. Phase A's census
  answers this before anything is scored; if infeasible, the snapshot
  schedule/M parameters are adjusted openly in Phase A (never in
  Phase B).

*Spec committed 2026-08-31, before any simulation code exists in the
repository. Deviations will appear below this line as dated postscripts,
never as silent edits.*
