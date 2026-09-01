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

---

**POSTSCRIPT (2026-09-01): two Phase-A feasibility adjustments, as
provided for in §8.** The first exploratory pass produced ZERO evaluable
kernels on every rule, and the census machinery localized why — a
structural fact worth keeping:

1. **No roots, no partition.** With out-degree m ∈ {1..4}, every
   dependency chain strictly descends and terminates at node 0, so a
   universal ancestor sits in every kernel's down-set, every node has a
   path into every down-set, Refusal is empty for every kernel, and the
   four-position structure degenerates *globally*. Fix: m ∈ {0..4} —
   the zero mass creates dependency roots, as in every real corpus
   (fonts, data packages, importless theories).
2. **Popularity-weighted platforms re-create the universal ancestor.**
   With PC platforms drawn ∝ in-degree+1, all cones funnel through a
   few primordial hubs and Refusal empties again even with roots
   present (and an unconditional platform dependency made PC nodes
   rootless besides). Fix: uniform platform choice, and m = 0 nodes
   are roots under every rule. The mechanism under test (cone
   locality) is untouched; what was lost is only a popularity
   confound the estimator matches away anyway.

Both adjustments are openly made in Phase A, before any Phase-B
registration, exactly as §8 reserves. The structural finding is worth a
line in the eventual paper: **pure rich-get-richer accretion without
roots cannot even host the four-position partition — evaluability
itself requires a population that refuses the hub stratum.** Post-fix
feasibility (N = 5,000 pilot, 300 kernels sampled): U 246 evaluable,
PA 246, PC(0) 230, PC(1) 234.

---

**POSTSCRIPT (2026-09-01, later): THE SELF-TEST FIRED. Phase A's
instrument audit found a program-wide calibration flaw; the exploratory
grid, the calibration, and the consequences follow. This is the most
consequential postscript in the repository.**

**1. The exploratory grid (seed set A, no confirmatory weight).**
Verdicts under the original pair-level sign-flip null: U — ER
"REVERSES", ED "HOLDS"; PA — ER "HOLDS", ED "HOLDS"; PC(0), PC(0.25),
PC(0.5) — ER "REVERSES", ED "HOLDS"; PC(0.75) — both "HOLDS"; PC(1) —
both "REVERSE". Two of these are impossible: under U every alive node
has identical expected gain conditional on the baseline graph, and
under PA at matched baseline in-degree the two members' gain processes
are exchangeable. Feature-blind generators were returning significant
verdicts. C1's failure row fired — but at the calibration layer, not
the leakage layer: see (2).

**2. Replicate-universe calibration (01b; 20 universes per rule).**
The gold standard available only in synthetic worlds: regenerate the
universe and watch the statistic's true spread.
- The POINT ESTIMATOR IS UNBIASED on null generators: across-universe
  mean Δ_ER = +0.008 (U), −0.029 (PA), both ≈ 0 within their SDs. The
  matching machinery does not leak.
- The PAIR-LEVEL SIGN-FLIP NULL UNDERSTATES VARIANCE ≈ 9–11×:
  across-universe SD ≈ 0.055–0.067 against sign-flip-implied SD
  ≈ 0.005–0.007, on both contrasts, all three rules tested.
- PC(0) HAS A REAL, REPLICATED EFFECT — AND IT CONTRADICTS C2 AS
  REGISTERED: all 20 universes give Δ_ER < 0 (mean −0.164, SD 0.066)
  and all 20 give Δ_ED > 0 (mean +0.081, SD 0.025). Cone-local
  accretion robustly produces the ordering R > E > D at matched
  battery, not the predicted E > R. The conjecture set needs rebuilding
  before any Phase B.

**3. Clustered nulls do not fix it (01c).** Kernel-level sign flips
yield half-bands ≈ the pair-level ones (≈ 0.009 vs the honest ≈ 0.11).
The dependence is not within-kernel; it is UNIVERSE-LEVEL — every
kernel, stratum, and pair shares the one realized graph, and members
recur across kernels. No within-universe resampling scheme can recover
generator-level variance. This is a mathematical point, not an
implementation defect.

**4. What this means for the FIELD results (the audit clause of §7,
executed).** Every single-corpus percentile in the program — the
growth studies, the deflation control, the gauntlet, the Debian bet —
is a CONDITIONAL statement: "in this realized corpus, at matched
features, the cell labels align with gains beyond within-stratum
relabeling." That statement is true as computed and worth keeping. What
it is NOT is a generator-level statement — "this ecosystem's growth
process reads the cell" — because a feature-blind generator can
produce |Δ| up to ~0.14 in a single universe while its within-universe
permutation null shows percentile 0 or 100. Generator-level claims can
only be carried by REPLICATION ACROSS UNIVERSES: independent corpora
agreeing in sign, and sealed out-of-sample directional hits. On that
honest scale the program currently has: battery-grade Δ_ER positive on
Go (+0.22) and Debian (+0.098, sealed direction, landed) — two of two,
with crates null — and the proof-corpora reversals at distance grain.
Evidence, genuinely; proof, no. If synthetic universe-scale noise
(SD ≈ 0.06) transfers even roughly, Debian's +0.098 is ≈ 1.6–2σ of
generator noise and Go's +0.22 ≈ 3–4σ — suggestive-to-strong, not
"percentile 100." The 2028 forward register becomes MORE important
under this reframing, not less: fresh time is the only fresh
randomness a real corpus ever provides.

**5. Actions.** (a) This postscript, the session log, and a caveat
postscript in the synthesis paper are committed today; the briefs'
"percentile 100" language will be tempered in the next editorial pass
(queued, not silent). (b) `sim-lib.mjs` now supports kernel-clustered
nulls; adopted for completeness, insufficient alone. (c) Phase B as
registered (single-universe verdicts) is CANCELLED; the confirmatory
design must be replicate-based: R fresh universes per rule, statistic
= across-universe mean against across-universe SD. New conjectures to
be drafted from the Phase A landscape (the PC family's R > E > D is
the anchor). (d) Phase C's target shifts accordingly: prove
unbiasedness (done empirically) AND characterize the sign of the
PC-family effect analytically.

---

## Postscript 2 (2026-09-01, later the same day): Phase B′ registered; Phase C delivered

Action (c) is executed: `02-confirm.mjs` is the replicate-based
confirmation, committed before its first run. Registered content: B1 —
U and PA, 20 fresh universes each (seed base 910000/915000, disjoint
from every Phase A seed), both contrasts |t| < 2 or the estimator is
declared biased; B2 — PC(0), 20 fresh universes, t_ER ≤ −3 AND
t_ED ≥ +3 confirms the R > E > D signature; B3 — descriptive β
gradient at R = 10 per point, scores nothing. No within-universe
percentile appears in any verdict.

Action (d) is executed on paper: `THEORY.md` proves the U null exactly
and the PA null given exact in-degree matching (Propositions 1–2),
separates the two correlation levels behind the sign-flip failure
(within-kernel, priceable; universe-level, not priceable by any
within-universe scheme), and derives the PC flux law — expected gain
under cone-local accretion tracks truncated up-set size, a quantity
absent from the battery. The sign of the PC(0) effect (why R above E
at matched battery) remains open, with a registered next measurable
(mean baseline up-set size by cell at matched battery). The flux law
also yields a field methods improvement, queued as "battery v2": add
truncated transitive-dependent count to the matching battery and re-run
Go/Debian.
