# Study 10 — Aperture on Cellular Automaton Causal Graphs

**Pre-registration. Written before any run. Version 1.1, 2026-08-25.**

*Supersedes v1.0 (2026-08-24), which was proved degenerate by inspection
before any execution — its syntactic edge relation is state-independent, so
all non-trivial conditions produce isomorphic cones; see the dated postscript
in `PREREGISTRATION-v1.0.md` for the a priori proof. v1.0 was never run.
This version promotes the counterfactual edge relation (named but deferred in
v1.0 §2.1) to the primary construction and pins every previously loose
parameter. Status discipline as elsewhere in this program: [K] kernel-checked
in Lean; [C] classical, cited; [computed] exhaustive finite computation under
two-implementation agreement; [A] interpretive; [O] open. This document is a
protocol, not a result. It is committed unchanged before first execution; any
deviation is logged as a dated postscript rather than an edit.*

---

## 1. Motivation and the claim under test

Unchanged from v1.0 §1, restated in one paragraph: the aperture invariant is
proved on divisor lattices [K] and measured on Mathlib's import structure
[computed], where latency (11/18 principal kernels in a pre-registered cone)
and narrow apertures (≈18× vs degree-matched null) were found. This study
moves the instrument to the causal structure of a running cellular automaton
and asks the precondition question: **does the invariant distinguish
structured from unstructured computational history at all?** The interpretive
hypothesis [A] — structure at a level is constituted by what that level treats
as indistinguishable; a glider needs a background — motivates but is not
tested here; no outcome below confirms it.

---

## 2. Construction (fixed before any run)

### 2.1 The causal relation (amended at v1.1)

Run Conway's Life (B3/S23) on a bounded grid with dead boundary from a
specified seed for T steps.

- **Nodes.** One node per cell-update: the pair (cell c, time t) for
  1 ≤ t ≤ T. Updates, not cells, not states.
- **Direct edges (counterfactual).** u → v for u = (c′, t−1), v = (c, t),
  c′ ∈ Moore(c) ∪ {c}, **iff flipping u's state — with the other eight
  neighborhood states held fixed — changes v's value under the rule**
  (single-flip counterfactual dependence). This is state-dependent by
  construction: the DAG reads the actual run.
- **Order.** The reflexive-transitive closure of the direct edges, a partial
  order (edges strictly decrease t, so there are no cycles). **Stated
  explicitly:** single-flip dependence need not be transitive — u may matter
  to v and v to w with u's influence on w blocked by the rule's totalistic
  thresholds — so the closure may add comparabilities with no direct
  counterfactual reading. The order is "chains of single-flip influence,"
  not "joint counterfactual influence," and every claim below is about that
  order.
- **Rejected alternative (was v1.0 §2.1 primary).** The syntactic relation
  (edge for every Moore pair regardless of values) is state-independent and
  provably measures nothing about the run — v1.0 postscript. Recorded here so
  it is not retried.

**Boundary behaviour, recorded before the census.** A dead cell in an empty
region has no potent parents (0 → 1 live neighbors never crosses a birth
threshold), so the deep vacuum contributes no nodes to any cone. But the
quiescent margin *adjacent* to a pattern does contribute: a dead cell with
exactly two live neighbors is one flip from birth, and a dead cell with three
is one flip from non-birth. That margin — where figure meets ground — is
expected to appear in cones, which is wanted; the consequence is that cone
sizes are not predictable a priori, and §4 therefore fixes the budget only
after a size census.

### 2.2 The algebra

Unchanged from v1.0. Elements are down-sets of the cone's poset; Down(P) is a
Heyting algebra [C] with ∧ = ∩, ∨ = ∪, ¬a = { y : ↓y ∩ a = ∅ }. Observers are
the nuclei on Down(P), which for finite P are exactly the 2^|P| subspace
nuclei j_S, S ⊆ P, with Fix(j_S) ≅ Down(S) [C: Simmons 1980 Thm 4.5;
Bezhanishvili et al., Order 37 (2020); verified from the axioms in
`mathlib-study/02-subspace-nuclei.mjs` Part A]. The Boolean power-set
alternative remains rejected (no ordinary elements in a Boolean algebra [C]).

### 2.3 Kernels

Unchanged. Candidate kernels are the principal down-sets ↓x, one per cone
node. Aperture per kernel: Ap(↓x) = { S ⊆ P : ↓x ∩ S ordinary in Down(S) },
exactly as in the Mathlib study.

### 2.4 Cones

A cone is the past cone of a focus update truncated to depth d: all nodes
with a directed path to the focus, at temporal distance ≤ d. Truncation cuts
parents below the last layer; the cut layer's nodes become minimal. Depth is
chosen per cone by the census policy of §4.

---

## 3. Conditions and pinned parameters

Six conditions as in v1.0. All seeds in `seeds.json`, committed with this
document.

| # | Condition | Seeds | Expected behaviour |
|---|---|---|---|
| A | Glider | standard 5-cell glider | translates diagonally, period 4 |
| B | Still life | block, beehive, loaf | static |
| C | Oscillator | blinker (p2), toad (p2), pulsar (p3) | periodic, no translation |
| D | Spaceship | LWSS | translates orthogonally, period 4 |
| E | Random soup | 20 seeds | chaotic, mostly decaying |
| F | Dies immediately | single live cell | dead at t=1; degenerate control |

**Pinned at v1.1 (loose or unstated in v1.0):**

- Grid 40×40, dead boundary. Patterns centered (offset = ⌊(40 − bbox)/2⌋ per
  axis).
- T = 8 for A–E; T = 1 for F.
- Soup: central 12×12 region filled at p = 0.30, cell (r, c) live iff
  PRNG() < 0.30 in row-major order; PRNG = mulberry32; the 20 seeds are
  listed in `seeds.json` (20260825001–20260825020).
- **Focus rule, unified for all conditions:** among live cells at t = T,
  lowest row, then lowest column; the focus is that cell's update at t = T.
  For F: the seed cell's update at t = 1 (a dying update; there are no live
  cells at t = 1). If a run has no live cells at t = T, the cone is logged
  as undefined and excluded — pre-registered handling, expected to occur
  only in condition E soups and N2 rules, and counted when it does.

---

## 4. Budget and enumeration policy

The observer census is 2^n for an n-node cone [C]; the Mathlib budget
2^18 = 262,144 worlds per kernel applies unchanged.

**Census before budget (new at v1.1, required by §2.1's boundary note).**
Script `02-cone-census.mjs` reports cone size at every depth d = 1…T for
every condition seed, before any aperture is computed. Per cone:

- **Exhaustive tier (primary):** run at the largest d with n ≤ 18. Full
  enumeration of all 2^n observers per kernel. All primary claims come from
  this tier. (A depth-1 cone has at most 10 nodes, so this tier always
  exists.)
- **Sampled tier (secondary, exploratory):** additionally, at the largest d
  with 19 ≤ n ≤ 40 where such d exists: uniform sample of 2^18 observers per
  kernel, PRNG seed 20260825103, reported as a sample with binomial 95%
  confidence intervals. No primary claim rests on this tier; it is run only
  when invoked with `--sampled`.
- **Excluded:** n > 40 at all depths ≤ T — the cone is used at the largest
  in-budget depth, never spatially truncated (v1.0's spatial-truncation
  clause is dropped: with counterfactual edges the depth-1 cone is always in
  budget).

---

## 5. Measures

Per kernel (unchanged from v1.0): ambient ordinariness at the identity
(S = P); |Ap(↓x)|; aperture fraction |Ap|/2^n; latency flag (not ambient-
ordinary and |Ap| > 0); cell occupancy — node counts in Infrastructure /
Refusal / Exploitation / Distribution, classified exactly as in
`mathlib-study/01-ordinariness-gate.mjs` (↓y ⊆ a → I; ↓y ⊆ ¬a → R;
↓y ⊆ ¬¬a → E; else D) — at the identity and at up to three sample opening
worlds per latent kernel.

Per cone: distribution across kernels; latent count and fraction; median and
max aperture fraction. Raw per-kernel output is committed under
`ca-study/results/`, not only summaries.

---

## 6. Nulls (pinned at v1.1)

Two, kept distinct and never pooled. Both run on the **primary cone** of each
condition A–E (first seed of the condition: glider, block, blinker, pulsar's
place is C's blinker — explicitly: A glider, B block, C blinker, D LWSS,
E soup seed 20260825001), at that cone's exhaustive-tier depth.

**N1 — degree-preserving rewiring.** Rewire the cone's direct-edge set by
double-edge swaps within each consecutive-layer bipartite graph
((u1→v1),(u2→v2) ⇒ (u1→v2),(u2→v1) when the images are absent and distinct),
10·|E| attempted swaps per rewiring, node set fixed, so every node keeps its
in-degree, out-degree, and layer. 100 rewirings, PRNG seed 20260825101. All
measures recomputed on the rewired poset (same node set; kernels are the
same nodes' principal down-sets). Matched null, direct analogue of
`mathlib-study/03`.

**N2 — rule randomization.** Random totalistic rules of matched table
density: B = {b} with b uniform on {1,…,8}, S a uniform 2-subset of
{0,…,8} (|B| + |S| = 3 = Life's table density). **B0 rules are excluded and
the exclusion is a recorded scope restriction:** a B0 vacuum is unstable, so
"seed on a quiescent background" — the construction every condition depends
on — is undefined there. 20 rules, PRNG seed 20260825102. Full pipeline rerun
from the same seed grid: evolve under the random rule, rebuild counterfactual
DAG, same focus rule, same census policy; undefined foci (pattern dead at
t = T) are counted and logged. Under the counterfactual construction this
null is now meaningful — the DAG depends on the rule — where under v1.0 it
was provably a no-op. Reported as a separate comparison, never pooled with
N1.

---

## 7. Predictions (pre-registered, before any run)

P1–P3 primary, as in v1.0, with the operational units pinned:

**P1 (differentiation — load-bearing).** The per-cone median aperture
fraction differs between pooled A–D (8 cones) and E (defined cones of 20),
two-sided Mann–Whitney U with normal approximation and tie correction,
α = 0.01. *If P1 fails, the invariant does not distinguish structured from
unstructured computational history; P2–P5 are uninterpretable. Report and
stop.*

**P2 (latency in coherent structures).** At least one A–D cone's latent
fraction exceeds the median E cone's latent fraction.

**P3 (narrowness).** Nulls are run on the four primary A–D cones (§6).
Pinned: **for at least 3 of the 4 primary A–D cones, the real cone's median
aperture fraction is below the median of its 100 N1 rewirings.** Direction
predicted; magnitude not predicted (Mathlib's 18× is not a prediction here).

**P4 (motion discriminates).** Translating cones (A, D: 2 cones) differ from
static/periodic ones (B, C: 6 cones) in median aperture fraction. With n = 2
vs 6 a significance test is theater and none is claimed: pinned criterion is
**non-overlapping ranges** (both A and D outside the [min, max] of B∪C, same
side); anything else is reported as inconclusive, not as failure.

**P5 (degenerate control).** Condition F shows no ordinary kernels and no
latency. Failure = pipeline bug, fix before reporting anything else.

**Explicitly not predicted:** which observers open a glider's kernel; whether
opening observers correspond to anything recognizable as "background"; any
quantitative aperture law; any specific cone size from the census.

---

## 8. Failure semantics

Unchanged from v1.0: P1 fails → negative result, publish fastest. P1 holds,
P2 fails → latency is a mathematical-corpus feature; narrowed scope, still
publishable. P3 fails → narrowness is a curated-library fact. P4
inconclusive → report as such; P4 reversed (B∪C strictly wider… i.e., A and D
strictly *inside* the B∪C range with the E comparison also flat) → the
invariant tracks something other than coherent motion; investigate before
interpretive work. P5 fails → bug.

---

## 9. Implementation and verification discipline

- **Shared-engine log (per v1.0's own requirement):** all Node scripts share
  `ca-lib.mjs`; its world-verdict and aperture enumeration reproduce
  `mathlib-study/02-subspace-nuclei.mjs` Part B, so shared-bug risk with the
  Mathlib study is on the record. The independent second implementation is
  `wl/ca-aperture.wl` (Wolfram Language), written against this document and
  the seed file only, run in Wolfram Cloud; it must agree exactly with the
  Node reference on every primary cone's per-kernel aperture counts. Any
  mismatch stops the study.
- **Anchors before any Life cone** (`01-anchors.mjs`): Div12 = Down(C2⊔C1)
  must give Ap(2) = 1 with the identity as sole member [K anchor]; Div36 =
  Down(C2⊔C2) must give |Ap(6)| = 2 with the two kernel-checked worlds
  [K anchor]; every element of both must match the closed form [K]; a
  3-chain must give all-zero apertures (chain worlds are chains); the
  9-antichain-under-a-top must give a dense ⊤ kernel and regular atom
  kernels (the v1.0 pyramid, kept as a documented negative anchor).
- All PRNG seeds fixed above and committed in `seeds.json`.
- Raw per-kernel output committed under `results/`.

---

## 10. Scope and what this cannot show [O]

As v1.0 §10, with one amendment: the causal relation is now single-flip
counterfactual rather than syntactic, which is still one specific choice —
joint interventions, probabilistic perturbations, and light-cone information
measures are all different relations and are not probed. One CA rule, one
grid topology, bounded windows, small cones. Nothing here connects the
aperture to computational cost or irreducibility, and no outcome licenses the
interpretive hypothesis of §1.

---

*Committed unchanged before first execution. Deviations logged as dated
postscripts below this line.*
