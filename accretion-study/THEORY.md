# Accretion study — theory notes (Phase C)

Status: analysis on paper, written 2026-09-01 alongside the Phase B′
run. Three items: (1) a proof that the estimator is exactly unbiased on
U and approximately unbiased on PA, which upgrades the Phase A
calibration from "observed" to "expected"; (2) a precise statement of
*why* the sign-flip null fails, separating the two levels of
correlation involved; (3) a flux law for PC(β) accretion that explains
mechanically how a cell can carry growth signal at matched battery,
identifies the quantity the battery is missing, and leaves the sign of
the PC(0) effect (R > E > D) as a stated open problem with a registered
next measurable.

## 1. Unbiasedness of the point estimator on null generators

Setup. A generator grows nodes 0..N−1; the estimator takes a baseline
snapshot at time T, computes cells and features from the baseline graph
only, forms E-vs-R and E-vs-D pairs matched within kernel and exact
distance under the battery caliper, and scores each pair by the
difference in in-degree gain over the horizon. All matching decisions
are measurable functions of the baseline graph plus independent
estimator randomness.

**Proposition 1 (U is exactly null).** Under uniform attachment, for
any pairing rule measurable in the baseline graph, E[Δ] = 0.

*Proof.* At every future step t > T, each dependency is drawn uniformly
from the t existing nodes, so every baseline node is hit with the same
probability 1/t regardless of any property it has. All baseline nodes
are alive for the whole horizon. Hence E[gain | baseline] is one
constant shared by every baseline node, and every pair difference has
conditional expectation zero; the tower property finishes it. ∎

**Proposition 2 (PA is null given exact in-degree matching).** Under
preferential attachment, two baseline nodes with equal baseline
in-degree have identical conditional gain distributions; hence any
pairing that matches in-degree exactly has E[Δ] = 0.

*Proof sketch.* The PA bag weights a node by (in-degree + 1) and by
nothing else; the future dynamics are invariant under swapping two
baseline nodes of equal weight (relabeling is a measure-preserving
bijection on trajectories, since only weights enter the transition
law). Equal baseline in-degree therefore implies exchangeable futures,
and exchangeable futures give equal expected gains. ∎

*Caveat, stated honestly:* the estimator matches log1p(in-degree)
within a 0.5 caliper on z-scores, not exactly, so a residual
within-pair in-degree mismatch correlated with cell could bias PA in
principle. The balance gate bounds the mismatch in mean (SMD ≤ 0.10)
and the Phase A replicate calibration measured means statistically
indistinguishable from zero on both U and PA — which is what
Propositions 1–2 predict. Phase B′'s B1 tests the same on fresh seeds.

## 2. Why the sign-flip null fails: two levels of correlation

The pair-level sign-flip null draws Var(mean) = Σdᵢ²/n², which is the
truth only if pair differences are independent (or at least
uncorrelated) given the observed magnitudes. They are not, at two
distinct levels:

- **Within kernel/epoch.** Pairs sharing a kernel share the E-side's
  local neighborhood; a growth wave hitting that region moves many
  pairs together. Kernel-clustered flips (flip all of a kernel's pairs
  as one block) price exactly this level.
- **Across the whole universe.** Epochs share the global growth
  process: which sectors of the graph are fertile over a horizon is a
  property of the one realized trajectory, and every kernel's pairs
  ride it. No within-universe rearrangement can price this level,
  because every rearrangement sees the same single trajectory — this is
  why the kernel-clustered null helped only marginally in `01c` while
  the replicate-universe calibration in `01b` found the true SD roughly
  an order of magnitude above the flip band.

The lesson generalizes beyond simulations: a within-corpus percentile
is a statement about pair-exchangeable rearrangements of one realized
history, not about the ensemble of histories. For a single realized
corpus (Debian exists once) the ensemble is not samplable, so the
honest warrant for a field claim is replication across independent
corpora and sealed out-of-sample bets — which is how the program's
surviving claims are now stated everywhere.

## 3. A flux law for PC(β), and what the battery is missing

Under PC(0) a newcomer picks a uniform platform u and draws its
remaining dependencies from cone(u), the truncated down-set of u. Fix
an existing node x at time t and let up(x) = {u : x ∈ cone(u)} be x's
(truncated) set of transitive dependents. Per step, x gains

  P(x gains) ≈ (1/t) · [ 1 + (m̄ − 1) · Σ_{u ∈ up(x)} 1/|cone(u)| ]

— one term for being picked as platform (uniform), one for being
sampled out of a cone that contains it. So **expected gain under
cone-local accretion tracks the size of a node's up-set (weighted by
inverse cone sizes), not its in-degree.** In-degree is the first *step*
of the up-set; the flux law integrates the whole transitive closure.

Consequences:

- **How a cell can beat the battery.** The battery (log-in, log-out,
  age, PageRank, k-core) contains no up-set measure. PageRank on the
  "is depended on by" orientation is a damped cousin, but damping and
  normalization truncate it hard. So any generator whose flux tracks
  up-set size leaves room for a baseline-definable partition to carry
  growth signal at matched battery — which is exactly what PC(0) does
  (R > E > D, 20/20 replicates in `01b`), and it is a constructive
  possibility proof for the field pattern: cells *can* legitimately
  out-inform the reviewer's arsenal, no magic required.
- **Battery v2, a registered methods improvement for future field
  designs.** Add truncated transitive-dependent count (up-set size at
  baseline) to the matching battery. If Go's and Debian's E-over-R
  survives *that*, the claim strengthens materially; if it dissolves,
  the program will have caught its third artifact in-house — either
  way the flux law says this is the sharpest cheap knife not yet run.
- **The open sign problem.** Why R above E at matched battery in
  PC(0)? Conjecture: E-members sit *interior* to the kernel's sector
  (their cones fall inside its territory), while distance- and
  battery-matched R-members are relatively more root-like within
  foreign sectors and therefore appear in more future cones — larger
  up-sets at equal battery. This is checkable without new machinery:
  measure mean baseline up-set size by cell at matched battery in the
  PC(0) universes. Registered as the first exploratory question of any
  Phase D. Until measured, the sign explanation is conjecture and is
  graded so.
- **What PC(0) does *not* explain.** It produces the inverse of the
  Go/Debian ordering, so uniform-platform cone-locality as-is is not a
  model of package-ecosystem growth. The generative question Phase B′
  leaves open: which rule families (popularity-weighted platforms?
  territory-correlated platform choice? β between the tested points?)
  force E > R. That search belongs to a future phase and should be run
  replicate-first from birth.
