# Phase 2: loops and widening — does the Interval predictor survive the feature that makes real analysis hard?

*Registered 2026-09-16, committed before any Phase 2 code exists.
Follows PHASE1-SPEC.md and PHASE1B-SPEC.md. The surviving claim:
phantom mass along the concrete trajectory predicts accumulated
completeness error for the Interval domain, robust across worlds,
seeds, and boundary conventions — on straight-line code. Real
interval analysis loses its precision in loops, through widening.
This phase asks the reviewer's question first. Still no tool.*

## The structural threat, stated and hand-witnessed before the run

Widening deliberately over-jumps to force termination. That
imprecision is **manufactured by the analysis**, not intrinsic to
the states, so the Phase 1 theorem-anchor T0 (exact trajectory ⟹
zero error) is **provably false** in this phase:

**A-W (hand anchor, must reproduce):** program `while (x < 3) inc`,
input {0}. Concrete: reachable set grows {0}→{0,1}→{0,1,2}→{0,1,2,3},
exit = {3}; every set the analysis touches is an exact interval, so
the intrinsic phantom P = 0. Abstract with widening: the invariant
jumps to [0, 8], exit = [3, 8], ε = 5. **Error at zero phantom.**
If this mechanism dominates statistically, the instrument is a
straight-line instrument and this phase says so. T0 is asserted only
on the loop-free control corpus.

## World

Σ = {−8..8}, saturating arithmetic (Phase 1b showed the boundary
convention doesn't matter; one world suffices). Seed 20260918.
Domain: **Interval only** (the partition side closed in Phase 1b).

**Language:** top-level items are either single ops (Phase 1
alphabet) or loops `while (g) body`, body = 1–2 ops, guards g from
{x > 0, x < 0, x < 3, x > −3, x even}. Programs of 2–4 items.

**Corpora:**
- **Control (loop-free):** 30 seeded straight-line programs — the
  Phase 1 shape, run in the *new* harness.
- **Loop corpus:** 10 canonical single loops (5 guards × 2 fixed
  bodies: inc, dec) + 40 seeded programs each containing ≥ 1 loop.

**Inputs:** all 17 singletons, ∅, Σ, evens, odds, positives,
negatives, 25 seeded random subsets (~48).

**Concrete semantics (collecting):** loop output =
lfp(λR. V ∪ body(R ∩ G)) restricted to ¬G. Finite, exact.

**Abstract semantics:** stepwise interval bca for ops; loops by the
standard widening iteration X ← X ∇ (a_in ⊔ body♯(X ⊓ G♯)) to
stability, exit = X ⊓ (¬G)♯. Widening jumps unstable bounds to the
world bounds (the finite stand-in for ±∞). No narrowing (noted
convention; narrowing would only help the analysis, i.e. make the
test easier — its absence is the harder world for the *analysis*,
not for the claim). Guards and negated guards abstracted by their
best interval over-approximations (x even and its negation both
abstract to ⊤ — intervals cannot see parity; that incompleteness is
the world's, not a bug).

## Quantities

- **P (the predictor, unchanged in spirit, extended canonically):**
  every application of an op to a concrete set V — including each
  loop-body application to R ∩ G at each fixpoint round, and the
  input — contributes s(V) = |ρ(V) ∖ V|.
- **ε (target, unchanged):** |a_final ∖ ρ(V_final)| counting
  measure, final program point.
- **W (descriptive only, the threat's own meter):** total widening
  jump mass — at each widening application, |γ(X_new) ∖ γ(X ⊔ Y)|.
  Registered as a covariate for the autopsy, carries no claim.

## Registered claims

- **H-L0 (continuity gate):** the loop-free control corpus passes
  the unchanged thresholds (pooled Spearman(P, ε) ≥ 0.5, stratified
  median ≥ 0.3) in the new harness, and T0 holds on it. Failure
  here is a harness bug, not a finding; stop and fix.
- **H-L1 (primary):** on the loop corpus, pooled Spearman(P, ε)
  ≥ 0.5 AND median over item-count strata ≥ 0.3.
- **Attenuated band:** pooled in [0.3, 0.5) is recorded as
  "survives attenuated" — a real but weakened instrument; no spin
  either way.
- **K-W (the kill):** pooled < 0.3 on the loop corpus ⟹ widening's
  manufactured imprecision swamps the intrinsic signal; **the
  instrument is a straight-line-code instrument**, the export
  sentence gains that qualifier permanently, and the planned note
  reports the death of the loops extension alongside the
  straight-line result.
- **D-W (descriptive autopsy, either outcome):** Spearman(W, ε) on
  the loop corpus, and Spearman(P, ε) within W-terciles. If ε is
  carried almost entirely by W, that is the A-W mechanism at scale
  and gets said plainly.

## Non-claims

No tool, no real analyzer, no narrowing study, no relational
domains, no claim beyond the toy language. One run; repairs logged
with their nature per house rules.
