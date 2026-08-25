# Study 10 — Results (2026-08-25, single session)

**Protocol:** `PREREGISTRATION-v1.1.md`, committed before execution at
`0b1c40a`. Anchors: all 8 PASS (Div12 Ap(2) = {identity}, Div36 |Ap(6)| = 2
latent, closed-form agreement on every element, chain and pyramid
negatives). Raw outputs: `results/census.json`, `results/study-raw.json`.

## Outcomes, as registered

| prediction | outcome |
|---|---|
| **P1 (differentiation)** | **FAILS.** Per-cone median aperture fraction, pooled A–D (8 cones) vs E (20 cones): Mann–Whitney U = 85, z = 0.334, p = 0.738 — nowhere near α = 0.01. |
| P2 (latency) | Criterion met (beehive 14/15 latent, loaf 15/16, vs E median 0) — but **uninterpretable under P1's stop rule**, reported for the record only. |
| P3 (narrowness) | **Not run.** P1's stop rule governs; `04-nulls.mjs` was not executed. |
| P4 (motion) | Inconclusive as registered (A, D medians = 0, inside the B∪C range) — uninterpretable under the stop rule. |
| P5 (control) | HOLDS (F: no ordinary kernels, no latency). |

Per §8: this is the negative result, reported first. **On this substrate,
under this protocol, the invariant did not distinguish structured from
unstructured computational history.**

## Postmortem: the failure has a two-line structural cause

The census (`results/census.json`) put **21 of 29 cones at depth 1**,
because counterfactual cones around live structure grow fast (glider:
9 → 27 → 57; every dense pattern is over the n ≤ 18 budget by d = 2) and
the registered depth policy takes the largest in-budget depth.

A depth-1 cone is a **fan**: the focus on top, its potent parents an
antichain below. Down(fan) is the powerset of the atoms with a dense top
glued on: any down-set containing the top is everything, so every proper
down-set is a set of atoms, its pseudocomplement is the complementary atom
set, and double negation is the identity there — **every element is regular
or dense, and every world of a fan is a fan or an antichain, so the aperture
of every kernel is 0 in every world.** The exhaustive runs confirm it
(all 21 depth-1 cones: medAp = maxAp = 0, no latency), but it was provable
before running: this is the v1.0 pyramid (postscript item 3) again,
state-dependently sized. The v1.1 amendment fixed *which* two-layer poset
the budget buys; it did not fix the fact that **all two-layer posets are
aperture-blind**. P1 therefore drowned: both pools were mostly structural
zeros, and the test compared noise floors.

**What the in-budget deep cones showed** (descriptive only; no claim is
licensed by this registration, since P1 failed and depths differ across
conditions):

- Still lifes have the *thinnest* counterfactual margins, hence the deepest
  in-budget cones — beehive n = 15 at d = 3, loaf n = 16 at d = 3 — and
  they are latency-dense: 14/15 and 15/16 latent kernels, median aperture
  fractions 0.153 and 0.171.
- The five depth-2 soup cones run an order of magnitude narrower (median
  aperture fractions 0.004–0.016, latent fractions 0.67–0.94).
- `soup-20260825005` contains the substrate's first **ambient-ordinary**
  kernels (2 of 12 ordinary at the identity).
- The sampled tier (registered secondary) was uninformative as implemented:
  it samples only the focus kernel, which is the cone's top — 0/262,144
  ordinary worlds at every d = 2 cone. Implementation-scope limitation,
  logged; cones with n > 30 additionally exceeded the 32-bit mask engine
  and are marked skipped in the raw output.

## Disposition

1. The registered result stands: **P1 negative under v1.1.** Nulls not run.
2. The confound is identified and structural: the depth policy, not the
   invariant, decided the outcome. A depth-matched design — fixed d = 2 for
   every condition, all-kernel enumeration under a wide-mask engine (or a
   budget raise to n ≤ 24), primary comparison at equal depth — is the
   named follow-up. **It requires a new pre-registration (v1.2) and is not
   run in this session.**
3. Two-implementation status: the Node results above are single-
   implementation until the Wolfram twin (`wl/ca-aperture.wl`, depths now
   filled from the census: A 1, B 1, C 1, D 1, E-primary 2) is run in
   Wolfram Cloud. Under the stop rule the only primary claim is P1's
   negative, which the WL run should confirm or break; pending manual step.
4. Instrument-history note: this is the fifth time the program's
   discipline has overruled its operator's expectation, and the second time
   in this study alone (v1.0 died by inspection; v1.1's load-bearing
   prediction died by measurement with a cause the v1.0 postscript had
   already named). The lesson generalizes: *a budget policy is part of the
   instrument, and it can be the part that goes blind.*
