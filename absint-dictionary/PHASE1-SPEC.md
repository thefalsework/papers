# Phase 1: the worked example — is phantom mass a predictor or a definition?

*Registered 2026-09-16, committed before any Phase 1 code exists.
Authorized by the Phase 0 verdict (SPEC.md, Postscript 3):
conditional GO for layer 1 only. This is a study script, not a tool.
The question, verbatim from the verdict: does the intrinsic
per-element conflation count (phantom mass) predict the run-level
completeness error that ε-partial completeness (Campion–Dalla
Preda–Giacobazzi, POPL 2022) bounds? The kill was written in
Phase 0 and is operationalized below.*

## World

Σ = {−8..8} (17 integers). Concrete carrier ℘(Σ). All computations
exact by enumeration; no sampling except where seeded and stated.

**Domains (all ucos on ℘(Σ); none is a nucleus there, per P0-A):**

1. Parity — partition {even, odd}; ρ = union of met classes.
2. Mod3 — partition by x mod 3 (three classes).
3. Sign — partition {<0, =0, >0}.
4. Sign×Parity — the joint partition (six classes; the reduced
   product of 1 and 3 in partition form).
5. Interval — ρ(U) = [min U, max U] ∩ Σ; the one non-partition
   domain, deliberately different in shape.

**Operations (functions Σ → Σ lifted pointwise, or guards):**
inc, dec, double (all saturating at ±8), neg, abs (saturating),
square (saturating), halve (toward 0), mod3, guard_pos (∩ {x > 0}),
guard_even (∩ evens). Saturation is a fixed convention of the toy
world, noted, not defended.

**Programs:** the 10 single operations, plus 40 seeded random
compositions of length 2–4 (seed 20260916). 50 programs total.

**Inputs:** all 17 singletons, ∅, Σ, evens, odds, positives,
negatives, plus 25 seeded random subsets. ~47 inputs.

## Quantities

For a program p = f_n ∘ … ∘ f_1, input U, domain ρ:

- **Concrete trajectory:** V_0 = U, V_{k+1} = f_{k+1}(V_k).
- **Abstract run (stepwise bca, as real analyzers compose):**
  a_0 = ρ(U), a_{k+1} = ρ(f_{k+1}(a_k)) (elements represented by
  their γ-sets, i.e. fixpoints of ρ).
- **Run-level completeness error (the CDG-style target, counting
  measure):** ε(p, U, ρ) = |a_n ∖ ρ(V_n)| — spurious mass beyond
  the best the domain could represent.
- **False-alarm mass (descriptive companion):** |a_n ∖ V_n|.
- **The intrinsic predictor (no abstract run):**
  P(p, U, ρ) = Σ_{k=0}^{n−1} s_ρ(V_k), where s_ρ(V) = |ρ(V) ∖ V|
  is the phantom count at V. On a Boolean carrier the official
  phantom mass is |Icc(V, ρV)| = 2^{s_ρ(V)}; s is the informative
  exponent, and s(V) is exactly the counting-measure quasi-metric
  from V to ρV — the precise CDG bridge, stated once here.
- **Input-only variant:** s_ρ(U) alone (no trajectory at all).

## Hand anchors, registered before the run (process rule)

- **T0 (theorem, two lines, checked as an assertion not a
  finding):** if s_ρ(V_k) = 0 for all k ≤ n then ε = 0 — an exact
  trajectory forces a complete run (induction: a_k = V_k). The
  qualitative direction is free; only the statistical claim is at
  stake.
- **A1 (phantom without error):** Parity has s > 0 on many inputs
  yet ε = 0 for inc on every input (inc maps parity classes to
  parity classes). Likewise Sign for neg. Phantom does NOT imply
  error; error requires an operation that splits the phantom. The
  study cannot "discover" A1.
- **A2 (error exists):** Sign on U = {−1}, p = inc:
  a_1 = γ(≤0)-shaped, ρ(V_1) = {0}, ε > 0. The signal the study
  needs exists at n = 1.

## Registered claims

- **H1 (primary, moderate confidence).** Within each domain,
  Spearman correlation between P and ε over all (program, input)
  pairs is ≥ 0.5, AND the median of the length-stratified
  correlations (programs of length 1, 2, 3, 4 separately) is
  ≥ 0.3. The stratification guard is the pocket-study Q3 lesson:
  longer programs accumulate both phantom and error, and a pooled
  correlation carried entirely by length is a confound, not a
  prediction.
- **H1b (low confidence).** The input-only predictor s_ρ(U) retains
  Spearman ≥ 0.3 pooled, within each domain.
- **H2 (secondary, descriptive, deflation pre-registered).** Rank
  the five domains by mean intrinsic phantom (over inputs) and by
  mean ε (over runs); record Kendall agreement. The deflationary
  reading — coarser domains have more of both, so cross-domain
  agreement is nearly free — is pre-registered; H2 carries no
  weight without H1.

## Kill

- **KP0 (validation):** T0 assertion violated, or A1/A2 fail to
  reproduce. Stop, fix, rerun from scratch.
- **KP1 (the Phase 0 kill, operationalized):** if in EVERY domain
  the pooled Spearman(P, ε) is < 0.3, the intrinsic count and the
  run-level error have decoupled on the worked example: **phantom
  mass is a definition, not a predictor, and the layer-1 bet ends
  there.** The postscript states it and the dictionary reverts to
  vocabulary-only status.
- Partial outcomes (some domains pass, some fail) are recorded
  per-domain with no aggregate spin; H1 as registered then fails
  and the postscript says which shapes of domain carry signal.

## Non-claims

No tool, no real analyzer, no benchmark suite, no claim about
octagons or relational domains, no layer-2 (four-position) content.
One run; repairs, if any, logged with their nature (formatting vs
logic) per house rules.
