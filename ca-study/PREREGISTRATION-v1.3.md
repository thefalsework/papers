# Study 10 — Aperture on CA Causal Graphs, v1.3 (size-controlled figure-vs-ground)

**Pre-registration. Written before the v1.3 study run. Version 1.3, 2026-08-25.**

*Fourth protocol version, and the first that is a follow-up to a positive
rather than a fix to a broken design. v1.2's P6′ held (still-life cones ~17×
wider than soup cones at matched depth, p = 0.044) with a named entanglement:
the B signal is carried entirely by beehive and loaf, whose d = 2 cones have
n = 9 against 23–31 elsewhere, and aperture fractions covary with cone size.
This registration is the size-controlled test that P6′ was required to pass
before graduating to a claim (`RESULTS.md`, v1.2 disposition 3). Registered
in a later session than v1.2, as its branch rule required. Committed
unchanged, together with the pre-check output it cites, before the study
script runs; deviations logged as dated postscripts.*

**Provenance disclosure, stated up front.** Written with all v1.1/v1.2
results in hand. Two committed facts bear directly on the prediction and cut
in opposite directions, and both are prior information, not evidence:
beehive/loaf at n = 9 run ~17× wider than soup (for), while **block — the
one still life with a soup-sized cone, n = 23 — sits at medAp 0.0074,
inside the soup range** (against). The deflationary reading (aperture tracks
cone size, not figure-vs-ground) is the better-supported prior. P7 below is
registered so that it can fail.

---

## 1. Structural pre-check (sizes only — done before registration, cited)

`08-sizematch-precheck.mjs` enumerates every live-cell focus at t = T in the
20 committed v1.1 soup histories and builds each focus's d = 2 counterfactual
cone, recording **size and local quiescence class only. No down-set algebra
is constructed and no aperture is computed by the pre-check**, so every
prediction below is blind to outcomes. Output committed at
`results/sizematch-precheck.json`. Facts cited from it:

1. 697 soup foci; d = 2 cone sizes span 6–34.
2. **Stratum feasibility:** distinct soups offering ≥ 1 focus at the
   still-life cone sizes — n = 9: **5 soups**; n = 16: 15; n = 23: 14;
   n = 8: 0.
3. The four new still lifes (seeds-v13.json) at d = 2: tub n = 8,
   pond n = 9, boat n = 16, ship n = 16 (all still-class, as they must be).
4. Of the 23 soup foci at n = 9, 12 are still-class and 11 active-class:
   decayed soup contains actual still lifes, which makes the S1 contrast in
   §4 possible within matched size.
5. The registered soup-extension trigger (fewer than 5 matched soups in the
   primary stratum) did **not** fire; the extension seeds in seeds-v13.json
   are unused.

## 2. Design

Everything not stated here is v1.2's unchanged (grid, T = 8, rule, focus
rule for named patterns, counterfactual construction, d = 2, down-set
algebra, kernels = principal down-sets, per-cone statistic = median aperture
fraction across all kernels).

- **B side (still lifes, 7):** block, beehive, loaf (v1.1 seeds) + tub,
  pond, boat, ship (seeds-v13.json). Standard focus rule. All are
  re-measured in this run under the v1.3 estimator stream — no value is
  carried over from v1.2.
- **E side (size-matched soup cones):** for each committed soup history and
  each stratum size n\*, the **first live focus in row-major order whose
  d = 2 cone has exactly n = n\* nodes**, at most one focus per soup per
  stratum. Deterministic, no discretion.
- **Strata (pinned from the pre-check):** n\* ∈ {9, 16, 23} — every
  still-life cone size with ≥ 5 matched soups. Tub (n = 8, zero matched
  soups) is excluded from the primary and reported descriptively.
  Expected counts: n = 9 → B {beehive, loaf, pond} vs E 5;
  n = 16 → B {boat, ship} vs E 15; n = 23 → B {block} vs E 14.
- **Estimator, matched within stratum:** exact (all 2^n worlds per kernel)
  for n ≤ 18, i.e. strata 9 and 16; sampled (2^18 uniform worlds per
  kernel, mulberry32 seed 20260825301, one stream in registered cone order)
  for stratum 23 — both sides of a stratum always measured the same way.
  Identity verdict always exact.

## 3. Primary prediction

**P7 (size-controlled figure-vs-ground).** Within matched strata, still-life
cones are wider than size-matched soup cones. Test: stratified rank
permutation test on per-cone median aperture fractions — within each
stratum, ranks are assigned (average ranks on ties) over the pooled B and E
members; the statistic is the summed rank of the B cones across strata;
labels are permuted within stratum only; 100,000 permutations, mulberry32
seed 20260825302; **one-sided** (direction B > E, firmly predicted by v1.2's
P6′), α = 0.05, p = (1 + #{T_perm ≥ T_obs}) / (1 + 100,000).

*If P7 holds:* P6′ graduates — figure-vs-ground survives size control and
becomes the study's registered positive finding at this depth on this rule.

*If P7 fails:* P6′ does not graduate, and S1 decides between the two
readings of the failure (§4).

## 4. Secondaries

**S1 (quiescence disambiguation — evaluated only if P7 fails, interpreted
descriptively either way).** Within the n = 9 stratum, per soup, the first
still-class and the first active-class focus (row-major; up to 2 per soup)
are measured with the exact estimator. Comparison: still-class soup cones vs
active-class soup cones, same statistic, Mann–Whitney reported at α = 0.05
with counts disclosed. Semantics:

- **R2 (relocation):** P7 fails and still-class soup cones run wide (like
  the B cones) while active-class run narrow → aperture tracks **local
  quiescent figure regardless of provenance**; the condition contrast was
  the wrong cut, and "figure-vs-ground" survives as a claim about local
  structure. Any pursuit of R2 requires its own registration.
- **R3 (deflation):** P7 fails and still-class ≈ active-class at matched
  size → the v1.2 P6′ signal was a cone-size artifact; the CA study closes
  fully negative on every differentiation claim.

**S2 (replication, descriptive).** Per-cone profiles of the four new still
lifes, reported next to beehive/loaf/block. No test; the check is whether
new small still lifes land in the beehive/loaf band or scatter.

**S3 (size effect, descriptive).** Per-stratum medians on the E side,
reported so the size–aperture relation this design controls for is itself
on the record.

## 5. Failure and stop semantics

- P7 holds → graduate P6′ (size-controlled), update RESULTS.md and the
  outward documents; the follow-up thread (if any) is R2-style locality,
  separately registered.
- P7 fails + R2 → report relocation; condition-based differentiation is
  dead on this substrate, structure-based is alive with a named next test.
- P7 fails + R3 → the study closes negative end to end: no differentiation
  claim of any kind survives on Life causal cones under this construction.
  Report at full prominence and stop; no v1.4 in the same session.
- Anchor regression (any Div12/Div36/chain/pyramid anchor failing at run
  start) → bug; fix before any result is read.

## 6. Scope

As v1.2 §5, plus: size control here means *within-stratum exact matching on
n at fixed d = 2 under one rule and one focus policy* — no claim about other
depths, sizes outside {9, 16, 23}, other rules, or the sampled-tier strata
generalizing to exact-tier behavior. Multiple foci drawn from the same soup
across different strata share a history and are not independent across
strata; the permutation test is within-stratum, where each soup contributes
at most one cone, so the primary is unaffected; cross-stratum dependence is
noted for S3. Two-implementation status: Node-side, with the WL twin's
cloud confirmation still the pending manual step for the study as a whole.

---

*Committed unchanged before the v1.3 study run, together with
`results/sizematch-precheck.json`, `seeds-v13.json`,
`08-sizematch-precheck.mjs`, and `09-sizematch-study.mjs`. Deviations logged
as dated postscripts below this line.*
