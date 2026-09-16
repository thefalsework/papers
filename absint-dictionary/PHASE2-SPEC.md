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

## Amendment 1 (2026-09-16, same day, before any loop-corpus result was read): H-L0 fired, diagnosed as a mis-registered gate, replaced by a stronger one

First execution stopped at the continuity gate, as designed: the
loop-free control corpus came in at pooled +0.470, under the
registered 0.5. Diagnosis before proceeding, per the gate's own
instruction: an exact cross-engine check ran the identical 30
programs × 48 inputs through the Phase 1 engine and this harness —
**1,440 runs, zero mismatches in both ε and P.** The harness is
computationally identical to the validated Phase 1 engine on
loop-free code; T0 held; A-W reproduced by hand values (P = 0,
ε = 5).

So the gate fired on sampling variation, not a bug: the pooled
statistic sits near 0.5 across corpora (+0.503 Phase 1, +0.538
World B, +0.470 here on a smaller 30-program corpus), and the
registration mistook "harness correct" for "noisy statistic clears
an arbitrary line on a fresh seed." The gate is **replaced by the
strictly stronger check**: exact cross-engine equality on the full
control corpus, asserted in the script. The control correlation is
recorded descriptively. **H-L1 thresholds, the attenuated band, and
K-W are unchanged.** No loop-corpus number had been computed or read
at the time of this amendment (the script asserts the gate before
the loop sweep runs).

## Non-claims

No tool, no real analyzer, no narrowing study, no relational
domains, no claim beyond the toy language. One run; repairs logged
with their nature per house rules.

---

## Postscript (2026-09-16, same day): survives attenuated — by 0.006 — and the autopsy says exactly where it lives and dies

`03-phase2-loops.py`, first complete run after Amendment 1 (no
loop-corpus number was read before the amendment). A-W reproduced
exactly (P = 0, ε = 5, W = 7). H-L0 gate passed in its amended
form: zero cross-engine mismatches on 1,440 loop-free runs, T0
holds there; control correlation +0.470 recorded descriptively.

**H-L1: ATTENUATED, and barely.** Loop corpus (50 programs, 2,400
runs, ε > 0 in 49.5% — loops generate error at more than twice the
straight-line rate): pooled Spearman(P, ε) = **+0.306**, item-count
strata median +0.292. The registered bands put this in "survives
attenuated" (pooled in [0.3, 0.5)); the full H-L1 pass needed
strata median ≥ 0.3 and did not get it. **The kill line was 0.3;
the result is 0.306. A different seed could plausibly have fired
K-W.** Stated so nobody reads "survives" without the margin.

**The A-W mechanism is common at scale:** 286 runs (11.9% of the
corpus, roughly a quarter of all nonzero-error runs) have ε > 0 at
P = 0 — error with no intrinsic phantom anywhere on the trajectory,
manufactured entirely by widening.

**D-W autopsy (registered as run): the split is the finding.**

- Widening mass W predicts error at +0.491 — better than the
  intrinsic count on this corpus.
- Within the low-W tercile (n = 1,558, mostly runs where widening
  never jumped): Spearman(P, ε) = **+0.457** — near straight-line
  strength. The instrument works where widening is quiet.
- Within the high-W tercile (n = 769): **+0.102** — where widening
  acts, the intrinsic signal is swamped.
- The pooled +0.306 is just this mixture.

**Layer-1 statement after Phase 2, current form:** phantom mass
predicts accumulated interval-analysis error on straight-line code
(robust across worlds, seeds, boundary conventions) and on
loop code *where widening does not fire*; where widening fires, the
manufactured imprecision dominates and the intrinsic count is
nearly uninformative. The analysis-side quantity W is the better
predictor there — but W requires running the analysis, which is
precisely what the intrinsic instrument was supposed to avoid. The
export sentence carries this qualifier permanently unless a
narrowing study (not registered, not planned) changes the widening
regime itself.

**Disposition.** The three-phase arc (straight-line pass,
robustness, partition closure, loops attenuation with mechanism) is
a complete, honest, self-contained result. The natural next
artifact is the write-up, not a fourth phase; a narrowing follow-up
would only be worth registering if a reader of the note asks for
it.
