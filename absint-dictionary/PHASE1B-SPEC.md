# Phase 1b: does the Interval pass survive, and can the partition side be fixed?

*Registered 2026-09-16, committed before any Phase 1b code exists.
Follows PHASE1-SPEC.md and its postscript. Two questions were queued
there; this registers both. Still no tool.*

## Question R1: robustness of the Interval pass

The one H1 pass (Interval, pooled +0.503, stratified median +0.508)
came from a single world (Σ = {−8..8}, saturation, seed 20260916).
A pass that owes its life to one seed and one boundary convention is
not an instrument.

**World B:** Σ = {−12..12} (25 elements), saturating arithmetic,
seed 20260917, fresh random programs (10 singles + 40 compositions,
length 2–4) and fresh inputs (25 singletons... all singletons, ∅, Σ,
evens, odds, positives, negatives, 25 seeded random subsets). Same
op alphabet. Interval domain only.

- **R1a (moderate confidence):** Interval passes the unchanged H1
  thresholds in World B — pooled Spearman(P, ε) ≥ 0.5 AND
  length-stratified median ≥ 0.3.
- **K-R (the real kill of this phase):** if World B pooled < 0.3,
  the original Interval pass was world/seed luck, the export
  sentence from Phase 1 loses its only supporting case, and the
  layer-1 predictor claim dies. Stated in the postscript with no
  softening.

**World C:** same Σ and seeds as World B but wrap-around arithmetic
(wrap(x) = ((x+12) mod 25) − 12). Wrap is adversarial for Interval:
it breaks the alignment between operations and convex hulls (inc
shatters a hull containing the top element). Interval domain only.

- **R1b (exploratory, no pass/fail):** record pooled and stratified
  Spearman. Pre-registered readings, both refinements: sustained
  ≥ 0.3 means the pass is shape-robust; < 0.3 means the pass
  depends on op–hull alignment, and the export sentence narrows to
  "gap-filling closures with convexity-respecting dynamics."

## Question R2: the corrected partition-side predictor

Phase 1 showed phantom cardinality is provably the wrong functional
for partition domains (the run remembers which classes are met,
never how much is missing). The corrected candidate: **the count of
partially-met classes**, c(V) = #{classes C : ∅ ≠ V∩C ≠ C} — the
number of places where phantom lives at all, ignoring its size.
Predictor P2(p, U, ρ) = Σ_{k=0}^{n−1} c(V_k) along the concrete
trajectory. Original World A (Σ = {−8..8}, saturation, original seed,
original programs and inputs), four partition domains.

- **R2 (low-moderate confidence):** pooled Spearman(P2, ε) ≥ 0.3
  AND length-stratified median ≥ 0.2, in at least 3 of the 4
  partition domains (Parity, Mod3, Sign, Sign×Parity).
- **Descriptive D:** P vs P2 side by side per domain; c has a small
  range (0..#classes) so ties are heavy — noted, not excused.
- **K-P (partition-side closure):** if pooled < 0.2 in all four,
  then no cheap intrinsic per-element functional predicts partition
  error on this toy, and the partition side closes as "prediction
  requires op-awareness (class–op alignment), which is not an
  intrinsic property of elements." That is an honest ending, not a
  failure to be retried with a third functional; functional-shopping
  stops at two.

## Validation

- T0 assertion (exact trajectory ⟹ zero error) re-checked in every
  world; any violation stops the run.
- Existence check per (world, domain): at least one run with ε > 0
  (no hand anchors this time; Amendment 1 showed hand anchors are
  where I make mistakes, existence assertions are what the
  machinery is for).

## Non-claims

No tool. No new domains. No claim about real analyzers. World C's
outcome refines wording only; it cannot rescue R1a if K-R fires.
Repairs, if any, logged with their nature per house rules.
