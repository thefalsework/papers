# Prediction study: does the aperture add predictive information?

Registered 2026-09-13, before any aperture was computed on registry
data and before any outcome variable was joined to any feature.
Instrument and thresholds frozen here; deviations will be recorded as
deviations.

## The question

The bridge study established (kernel-checked, `ObserverClassification.lean`)
that the aperture of a dependency cone is a well-defined lattice
invariant with an exact combinatorial form, and (Phase 3) that it is
not any standard centrality in disguise — median |ρ| ≤ 0.51 against
nine comparison measures. Orthogonal means new signal or noise. This
study decides which, on the axis a practitioner cares about:

> Does the aperture of a package's dependency cone add predictive
> information about future security-advisory outcomes, beyond what
> cheap centralities and popularity proxies already provide?

The claim under test is **incremental validity only**. Registered
prior from the literature: absolute predictability of advisories from
metadata/graph features is weak (KTH thesis 2021: best F1 ≈ 0.25,
popularity and age dominate; Zimmermann et al., USENIX Security 2019:
implicit-trust count vs. vulnerability count, Pearson ≈ 0.495).
Nothing here expects a strong classifier; the question is whether
aperture moves held-out prediction *at all* once the known predictors
are in the model.

Named confound, absorbed into the baseline by design: **surveillance
bias.** Advisories measure discovered vulnerabilities; popular,
depended-upon, old packages get more scrutiny. Popularity proxies
(degrees, cone sizes, age, version count, prior advisories) are
therefore baseline features, not the quantity under test.

## Data (frozen)

- **Ecosystem:** crates.io. Rationale: complete daily DB dump as one
  tarball (`static.crates.io/db-dump.tar.gz`) with per-version
  `created_at` timestamps, enabling honest temporal reconstruction;
  advisory ground truth via OSV's per-ecosystem export
  (`osv-vulnerabilities.storage.googleapis.com/crates.io/all.zip`);
  scale (~180k crates) large enough to be real, small enough to
  process exactly. One ecosystem only; generalization to npm/PyPI is
  explicitly out of scope.
- **Feature time T0 = 2024-09-01 00:00 UTC.** The dependency graph
  and all features are computed from the registry state
  reconstructable at T0: a crate exists if it has ≥1 version with
  `created_at` < T0; its edges are those of its **latest version by
  `created_at` < T0**; dependency rows with `kind = 0` (normal) only,
  optional dependencies included, all targets. Yank status is
  as-of-snapshot and is ignored (recorded limitation). Edges to
  crates that don't exist at T0 are dropped.
- **Crate-level graph.** Node = crate, edge p → q if p's selected
  version depends on q. If cycles occur at crate level, strongly
  connected components are condensed before any poset computation.
- **Outcome window (T0, snapshot date].** Outcome for package p:
  ≥1 OSV advisory for p with `published` in the window (binary,
  primary), advisory count (secondary). Advisories `published` < T0
  are *features* (prior_advisories), not outcomes. OSV records
  without a `published` field, and withdrawn advisories, are
  excluded from outcomes.
- **Population:** crates existing at T0 with ≥1 direct dependent at
  T0. (Aperture on never-depended-upon leaves answers no criticality
  question.)
- **Design: case-control.** All outcome-positive packages in the
  population, plus 10,000 controls sampled uniformly without
  replacement from the outcome-negative population, RNG seed
  20260913. AUC and likelihood-ratio statistics are rank/likelihood
  based and valid under random control sampling; absolute prevalence
  is not claimed.

## Instrument: ego-aperture (frozen)

Exact aperture is feasible to ~20–25 nodes; registries are 10^5. The
localization is therefore part of the instrument and frozen before
any outcome is seen:

- **Ego-poset of p:** BFS in the T0 graph. Fill order: p; then
  dependency-side layer 1; dependent-side layer 1; dependency-side
  layer 2; dependent-side layer 2. Within a layer, order by direct
  dependents at T0 descending, ties by crate name ascending.
  **Cap: 16 nodes total** (2^16 subsets exactly enumerable). Induced
  edges among selected nodes; SCC-condense; order = reachability.
- **Ego-aperture of p:** aperture(↓p) in D(ego-poset) via the
  kernel-checked subset formula
  (`aperture_eq_card_ordinary_traces`): the number of S ⊆ ego-poset
  whose trace ↓p ∩ S is ordinary (neither regular nor dense) in
  D(S), computed with the O(|S|²) bitmask predicate verified in
  bridge-study Phase 2 (E0'' cross-engine check passed there).

## Phase 1: instrument validation (no outcomes touched)

Run on 200 packages sampled uniformly from the population, seed
20260913. Outcome data is not loaded in this phase.

- **E-P1 (stability).** Spearman ρ between ego-aperture at cap 16
  and cap 12 (same fill rule) over the sample: **pass if ρ ≥ 0.7.**
  Also reported (no threshold): cap 16 vs. cap 20 on the subsample
  where cap-20 is feasible.
- **E-P2 (non-degeneracy).** No single value (including 0) covers
  more than 90% of the sample: **pass if max value share ≤ 0.9.**

**K1:** E-P1 fails → the localized instrument does not measure a
stable quantity; study ends, recorded. **K2:** E-P2 fails → the
instrument is degenerate at registry scale; study ends, recorded.
No re-tuning of caps/fill rules after seeing Phase-1 numbers; a
failed instrument is a result.

## Phase 2: incremental validity (the test)

- **Baseline features (all at T0):** log1p direct dependents, log1p
  direct dependencies, log1p transitive dependents (conemass), log1p
  transitive dependencies, PageRank (damping 0.85, on p → q edges),
  age in days (T0 − first version), log1p version count before T0,
  prior advisory count (published < T0).
- **Model:** logistic regression, standardized features, L2 with
  fixed λ = 1.0 (no tuning), 5-fold stratified cross-validation,
  fold seed 20260913. Baseline model vs. baseline + log1p
  ego-aperture.
- **E-P3 (incremental validity).** Pass if **mean held-out
  ΔAUC ≥ 0.01** and the likelihood-ratio test for the aperture
  term on the full sample has **p < 0.01**. **K3:** ΔAUC < 0.005 →
  the aperture carries no usable predictive increment over cheap
  baselines; the applied claim dies (the mathematics is unaffected).
  Between 0.005 and 0.01, or p ≥ 0.01: registered as inconclusive —
  no claim in either direction.
- **E-P4 (secondary, the quiet-criticality reading).** Within the
  top conemass quartile of the sample: odds ratio of outcome for
  bottom-aperture-quartile vs. top-aperture-quartile packages
  (quartiles within the stratum). Reported with 95% CI. Directional
  register: the inverted hypothesis from
  `notes/aperture-is-generativity.md` predicts OR > 1 (quiet = more
  dangerous). Secondary: informs interpretation, cannot rescue a K3.

## Honest limits, registered now

- One ecosystem, one T0, one outcome type (advisories ≠ exploitation
  ≠ malice). A pass here is a foothold, not a criticality theory.
- The ego-net cap is a real truncation; Phase 1 measures its
  stability but a cap-16 aperture is not the global aperture. H1
  (`BridgeDownSets.lean`) warns that a universal base makes ambient
  cones degenerate; ego-nets rarely contain a global minimum, but
  where they do, the aperture will be structurally 0 — that is the
  instrument working, not failing.
- Downloads-at-T0 are not reconstructable from the dump without
  leakage, so popularity is proxied by degrees/age/versions/prior
  advisories instead. Recorded.
- The E9 lesson from bridge-study Phase 3 stands: no post-hoc
  re-cutting. Whatever passes, passes as registered; whatever dies,
  dies with its data published.

## Amendment 1 (2026-09-13, after Phase 1 on instrument v1, before
any outcome data was loaded)

**Instrument v1 is dead by theorem, and the death is recorded:** all
200 sampled ego-apertures were 0 (K1 and K2 both fired,
`out/phase1.json`, instrument v1). Diagnosis is mathematical, not
empirical. The v1 fill order (p, dep-layers, dependent-layers)
collects only nodes comparable to p. If every element of S is
comparable to p, the trace ↓p ∩ S is ⊥ (below-p elements absent) or
dense (any x ≤ p in S lies in the trace; any x ≥ p in S has
↓x ∩ S ⊇ trace), so it is never ordinary — this is the H3 necessary
condition (`BridgeDownSets.lean`: ordinariness needs a
dependency-disjoint witness) applied to the ego-net. v1 ego-aperture
is identically zero for every package in every graph. The kill
carries no information about outcomes (none were loaded); amending
the instrument now is a correction of a provable construction error,
not tuning.

**Instrument v2 (frozen now):** fill order p; dependency layer 1;
dependent layer 1; **sibling-up** (dependents of dependency-layer-1
nodes, i.e. co-users of p's dependencies); **sibling-down**
(dependencies of dependent-layer-1 nodes, i.e. what p's dependents
also use); dependency layer 2; dependent layer 2. Within-layer order
and cap unchanged (direct dependents desc, name asc; cap 16, checks
at 12 and 20). Sibling layers supply the incomparable elements that
the H3 condition requires; on the xz motif, v2 recovers the full
motif from the liblzma position (aperture 21). Phase-1 thresholds
(E-P1 ρ ≥ 0.7, E-P2 max-share ≤ 0.9) apply to v2 unchanged. If v2
also fails Phase 1, the study ends — no v3.

---

## Phase 1 postscript, v2 (2026-09-13, same day)

Engine: `02-phase1-instrument.py`, sanity-anchored to the
kernel-checked motif values (minimal motif 1/0/0, xz 21/21/15).
Population: 52,099 crates with ≥1 dependent at T0. **Both checks
pass:** E-P1 Spearman(cap16, cap12) = 0.761 ≥ 0.7, and
Spearman(cap16, cap20) = 0.841 on the n=50 subsample (stability
improves with cap, as it should if the cap is a truncation of a real
quantity rather than its source). E-P2: modal value 0 covers 26.5%,
112 distinct values, median 12,285, max 41,997. The v2 instrument
measures something stable and non-degenerate. Proceed to Phase 2.

## Phase 2 postscript (2026-09-13, same day, after the run)

Engine: `03-phase2-prediction.py`, output `out/phase2.json`.
Sample: 514 cases (population crates with ≥1 OSV advisory published
in the window), 10,000 controls, seed as registered.

**K3 fired. The primary claim is dead as registered.** Mean held-out
ΔAUC = +0.0034 (folds: −0.0005, +0.0053, +0.0056, +0.0042, +0.0023),
below the 0.005 kill line, nowhere near the 0.01 pass line. Baseline
AUC 0.83–0.88 — the popularity proxies do the heavy lifting exactly
as the registered prior (KTH 2021) predicted. As a *classifier
improvement*, the ego-aperture adds nothing a practitioner could
deploy. That was the primary registered claim; it dies with its data
published.

**Two registered secondaries came apart from the kill, in the same
direction, and are reported separately without rescuing it:**

- The LR test (part of E-P3, registered) is decisive that the
  aperture term is *real*: LR = 24.2, p = 8.7×10⁻⁷, standardized
  coefficient **−0.32**. Negative: conditional on the baselines,
  *lower* aperture means *higher* advisory odds. The information is
  genuine; it is simply too correlated with the baseline features to
  move held-out rank performance by the registered floor.
- **E-P4 (secondary, direction registered in advance from
  `notes/aperture-is-generativity.md`): the quiet-criticality odds
  ratio is 2.85, 95% CI [2.06, 3.93].** Within the top conemass
  quartile (n = 2,692), bottom-aperture-quartile packages had 250
  cases in 1,384 vs. 48 in 673 for the top-aperture quartile. Heavy
  load + low distinction-visibility is the dangerous cell, direction
  as registered, CI well clear of 1.

**Honest reading.** This is the phantom-study E2 pattern again: the
mechanism's direction is confirmed while the deployable magnitude is
not, and those are separate claims that came apart. The registered
primary (incremental AUC) is dead. The quiet-criticality direction
(high-reach/low-aperture packages carry elevated advisory risk,
conditional on popularity) survives as a *registered secondary with
a clean CI* — a hypothesis with supporting evidence, not an
established claim. If it is ever to be a claim, it needs its own
preregistered primary on data this study has not touched: a
different ecosystem (npm/PyPI) or a later T0, with the E-P4
contrast as the primary endpoint and its own kill line. No such
claim is made here.

**Limits as registered, plus one observed:** one ecosystem, one T0;
advisories ≠ exploitation; cap-16 ego-aperture ≠ global aperture;
and the case-control OR conditions only on conemass stratification,
not the full baseline vector (the LR coefficient, which does
condition on everything, agrees in direction — but the OR magnitude
should not be quoted as if fully adjusted).
