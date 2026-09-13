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
