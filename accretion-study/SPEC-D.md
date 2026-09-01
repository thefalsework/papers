# Accretion study, Phase D — the search for the field's ordering (spec committed before anything runs)

**Status: SPEC ONLY at commit time.** Phase B′ established that the
PC(β) family forces R > E > D (or nothing) — the *inverse* of the field
ordering on the E-R axis. Go (v1 battery) and Debian (v1 and v2
batteries) show E > R. No rule yet built produces it. This phase
searches, under the discipline the audit forced: **replicate-first
everywhere; no within-universe percentile appears in any verdict; the
target battery is v2** (six features including truncated up-set size),
because after `battery-v2/` that is the only battery at which a field
claim still stands.

## 1. What a hit would mean

A rule family that forces mean Δ_ER > 0 at matched battery v2 across
replicate universes is a *candidate mechanism class* for how package
ecosystems actually accrete — the beginning of "we understand it"
rather than "we measured it." Per the flux law, such a rule must reward
E-position through some channel that is neither any battery feature nor
truncated up-set size. The spec's job is to name candidate channels in
advance.

## 2. Candidate rules (exploratory tier, fixed now)

All share the Phase A skeleton: m ~ uniform {0..4} dependencies per
newcomer (m = 0 makes roots), edges only backward, N = 30k, snapshots
every 5k.

- **SIB (co-user rule).** Newcomer picks a uniform anchor u, and for
  each dependency: walk DOWN into cone(u) (uniform member of u's
  truncated down-BFS, cap 200), then one step UP (uniform dependent of
  that member, if any; else keep the member). Channel: "adopt the
  libraries other users of your foundations use." Rewards nodes that
  sit OVER well-used foundations — the E-position relative to kernels
  in the foundation layer. Prior: best shot at E > R.
- **FRONT(K).** PC(0) with the platform drawn uniformly from the K
  most recent nodes (K = 2000) instead of all nodes. Channel: cones of
  the *frontier* rather than of history; recent platforms' cones are
  shallower and sit higher in the graph. Prior: weakens the R
  advantage, direction of any E effect unknown.
- **MIX(p).** Each dependency: with prob p a SIB draw, else uniform.
  p = 0.5. Dose-response check on SIB's channel.

Declared exclusions: popularity-weighted platform choice (Phase A
showed it degenerates the partition via universal ancestors);
explicitly kernel-aware rules (they would beg the question — the rule
may not read the cells it is being scored on).

## 3. Design constants

Estimator: the Phase B′ machinery with `battery: 6` (adds z-scored
log1p(upset_200) to the caliper and the balance gate) — byte-shared
with the confirmatory code. Baselines 0..3, horizon +2, kernel cap
300, side cap 300, caliper 0.5, SMD gate 0.10 over all six features,
min 50 pairs.

Exploratory tier: R = 5 fresh universes per rule (seed base 930000;
estimator 935000). Statistic: across-universe mean and t. Nothing in
this tier scores; it maps. Any rule with mean Δ_ER > 0 at |t| ≥ 3
graduates to a registered confirmatory run: R = 20 fresh universes
(seed base 940000), predictions sealed first, thresholds as Phase B′.

## 4. Honesty clauses

- If no rule shows E > R, that is the reported result: the field
  ordering remains unexplained by every mechanism tried, stated at
  full volume in the synthesis paper. The graveyard is the product.
- SIB's up-step uses in-degree information locally (a node's dependent
  list). This is legitimate mechanism (a newcomer can see who uses a
  library) but must be reported as such: SIB is not degree-blind, and
  a SIB hit would need the battery-v2 gate to certify the cell carries
  signal beyond the degree family.
- Exploratory findings, including any suggestive β/K/p gradients, are
  reported as exploratory. Only the sealed confirmatory tier scores.
