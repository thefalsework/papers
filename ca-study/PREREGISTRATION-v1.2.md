# Study 10 — Aperture on CA Causal Graphs, v1.2 (depth-matched)

**Pre-registration. Written before any v1.2 run. Version 1.2, 2026-08-25.**

*Third protocol version. v1.0 died by inspection (state-independent edges);
v1.1 died by measurement (its depth policy forced 21 of 29 cones into
depth-1 fans, which are provably aperture-blind — see `RESULTS.md`). This
version fixes the identified cause and nothing else: the causal
construction, algebra, kernels, seeds, and conditions are v1.1's unchanged.
The change is the enumeration policy — **every cone is taken at the same
depth d = 2**, with a sampled observer census where exhaustive enumeration
does not fit. Committed unchanged before first v1.2 execution; deviations
logged as dated postscripts.*

**Provenance disclosure, stated up front.** This protocol is written with
v1.1's committed results in hand. Everything v1.1 measured is prior
information here, and one prediction below (P6′) is the registered,
falsifiable version of a pattern v1.1 could only exhibit descriptively
across unequal depths. That is the honest epistemic situation; nothing about
it is blind, and no P below is presented as a surprise-free replication.

---

## 1. Structural pre-checks (done before registration, results cited)

1. **Three-layer posets are not aperture-blind as a class.** Existence
   proof from v1.1's committed exhaustive tier: the five depth-2 soup cones
   (n = 12–17) have nonzero apertures (median fractions 0.004–0.016, latent
   fractions 0.67–0.94), and one has ambient-ordinary kernels. The fan
   lemma that killed v1.1 does not extend to depth 2. A cone measured at
   zero at d = 2 is therefore a measurement, not a structural artifact.
2. **The sampling estimator is calibrated before use.**
   `05-sampling-calibration.mjs` runs the sampled estimator (2^18 uniform
   worlds with replacement, seed 20260825201) against the exact exhaustive
   fractions on every v1.1 cone with depth ≥ 2 and n ≤ 18 (beehive d3,
   loaf d3, five soups d2), per kernel. Requirement: ≥ 95% of per-kernel
   estimates inside their binomial 95% CI of the exact value. Calibration
   must pass before the study script runs; its output is committed with
   this registration.

---

## 2. Design (all else inherited from v1.1)

- **Depth-matched:** every defined cone is built at d = 2 exactly (F, whose
  single node has no depth-2 cone, is retained as the pipeline control at
  its d = 1 singleton). No per-cone depth selection: the confound that
  decided v1.1 is removed by construction.
- **Census fact (from committed v1.1 census):** d = 2 cone sizes span
  9–31 nodes. The 32-bit engine covers n ≤ 31; nothing is excluded.
- **Enumeration policy, pinned:**
  - n ≤ 18: exact — all 2^n worlds per kernel (as v1.1).
  - 19 ≤ n ≤ 31: sampled — 2^18 uniform worlds with replacement per
    kernel, PRNG mulberry32, seed 20260825201, one stream per study run in
    cone order. Fractions reported with binomial 95% CIs.
  - Identity verdict is always computed exactly (one world).
  - **Latency-at-resolution:** a kernel is latent iff not ambient-ordinary
    and its (exact or sampled) aperture count > 0. A sampled zero bounds
    the fraction below ~1.1 × 10⁻⁵ (0 hits in 2^18) rather than proving
    emptiness; this asymmetry is accepted and stated wherever latency
    rates are reported.
- **Measures:** per kernel and per cone as v1.1 §5, with "aperture
  fraction" meaning the exact fraction (n ≤ 18) or the sampled estimate
  (n ≥ 19). Cell occupancy at identity as before; occupancy at opening
  worlds only for exact-tier cones.

## 3. Nulls (v1.1 §6 semantics, resolutions pinned)

Run on the five primary cones (A glider, B block, C blinker, D lwss,
E soup-20260825001) at d = 2.

- **N1:** 100 degree-preserving rewirings (double-edge swaps within
  consecutive-layer bipartite graphs, 10·|E| attempts), seed 20260825202.
  Null measures use 2^14 samples per kernel; **for the null comparison the
  real cone is re-measured with the same 2^14-sample estimator** so the
  comparison is estimator-matched (seed 20260825203 for the real-cone
  re-measurement).
- **N2:** 20 random totalistic rules (B = {b}, b ~ U{1..8}; S = uniform
  2-subset of {0..8}; B0 excluded as registered in v1.1), seed
  20260825204, full pipeline at d = 2, 2^14 samples per kernel, undefined
  foci counted. Separate comparison, never pooled with N1.

## 4. Predictions

**P1′ (differentiation — load-bearing, gate for P2′/P3′/P4′).** Per-cone
median aperture fraction, pooled A–D (8 cones) vs E (defined cones of 20),
two-sided Mann–Whitney U, normal approximation with tie correction,
α = 0.01. *If P1′ fails, P2′–P4′ are uninterpretable and are not evaluated.*

**P2′ (latency).** Some A–D cone's latent-at-resolution fraction exceeds
the median E cone's.

**P3′ (narrowness).** Real median aperture fraction below the median of
its 100 N1 rewirings in ≥ 3 of the 4 primary A–D cones (estimator-matched
per §3).

**P4′ (motion).** A and D cone medians both outside the [min, max] of the
B∪C cone medians, same side; anything else inconclusive.

**P5′ (control).** F: no ordinary kernels, no latency. Failure = bug.

**P6′ (figure-against-ground — registered promotion of v1.1's descriptive
pattern, evaluated regardless of P1′).** At matched depth 2, still-life
cones are wider than soup cones: median of B-cone median aperture fractions
> median of E-cone median aperture fractions; Mann–Whitney B vs E reported
at α = 0.05. Direction is predicted from v1.1's cross-depth observation
(beehive/loaf at d = 3), which is prior information, not evidence — P6′ can
fail exactly where the suggestion came from.

**Stop/branch rule.** If P1′ and P6′ both fail: full negative for this
substrate under this construction; report, stop, and do not register a
v1.3 in the same session. If P1′ fails and P6′ holds: report both; the
surviving thread is figure-vs-ground differentiation, not
structured-vs-random. Script 07 (nulls) runs iff P1′ or P6′ holds; P3′ is
evaluated only under P1′.

## 5. Scope

As v1.1 §10. Additionally: d = 2 is one horizon — nothing here says
aperture structure at deeper horizons behaves the same way; the exact tier
and the sampled tier use different estimators (stated wherever pooled);
and P6′, if it holds, licenses a still-life-vs-soup difference at one
depth on one rule, nothing more.

---

*Committed unchanged before first v1.2 execution, together with the passing
calibration output. Deviations logged as dated postscripts below this
line.*
