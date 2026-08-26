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

---

# v1.2 results (2026-08-25, same day; depth-matched d = 2)

**Protocol:** `PREREGISTRATION-v1.2.md`, committed with the passing
calibration (106/108 per-kernel estimates within CI) at `c64ce3c`, before
execution. Raw outputs: `results/study-v12.json`, `results/nulls-v12.json`.

## Outcomes, as registered

| prediction | outcome |
|---|---|
| **P1′ (differentiation)** | **FAILS — and this time it is a real measurement, not an artifact.** Pooled A–D vs E per-cone median aperture fraction: Mann–Whitney U = 102, z = 1.119, p = 0.263. Every cone has nonzero apertures; nothing is structurally blind at d = 2. |
| P2′–P4′ | Not evaluated (P1′ gate). |
| P5′ (control) | HOLDS (F clean). |
| **P6′ (figure-vs-ground)** | **HOLDS**, direction and significance: median of B-cone medians 0.0977 vs E 0.0057 (~17×), Mann–Whitney p = 0.044 < 0.05. |
| P3′ | Not evaluated (gate), but the N1 data is decisive descriptively: **no narrowness on this substrate** — real cones sit at percentiles 6, 88, 64, 76, 4 of their own 100 degree-preserving rewirings. The Mathlib ≈18× narrowness does not transfer; it is a fact about curated dependency structures. |

## What the depth-matched data says

- **The pooled structured-vs-random contrast is genuinely absent.** With
  the fan confound removed, gliders, oscillators, and spaceships have
  aperture profiles statistically indistinguishable from soup (movers'
  medians 0.0040/0.0040 sit *inside* the soup range). The v1.1 stop-rule
  negative is thus confirmed by a clean design: on Life causal cones,
  "authored zoo object vs random soup" is not what the aperture measures.
- **Post-hoc reading, flagged as such:** condition E at T = 8 is not
  "unstructured" — decayed soup is largely ash (still lifes, blinkers).
  The A–D vs E contrast compared zoo objects to a population containing
  the same kinds of objects. The registered question may have been
  ill-posed for this substrate at this horizon, which is a different
  statement from "the invariant sees nothing."
- **P6′ is the surviving positive thread, with a named caveat.** Still-life
  cones are an order of magnitude wider than soup cones at matched depth —
  but the B signal is carried by beehive/loaf, whose d = 2 cones have
  n = 9 versus 23–31 elsewhere, and aperture *fractions* covary with cone
  size. The small cone size is itself part of the still-life phenomenon
  (thin counterfactual margins are what "static figure against quiet
  ground" looks like in this construction), so the confound and the signal
  are entangled. A size-controlled comparison is required before P6′
  graduates to a claim.
- **Latency is generic on this substrate** — 67–94% of kernels latent in
  every non-trivial cone, soup included, with only 0–2 ambient-ordinary
  kernels per cone (the substrate's first, found in oscillator and soup
  cones). Cross-substrate picture now: latency rare on divisor lattices,
  generic on Mathlib cones, generic on Life cones — full-resolution
  ordinariness is the exception in the wild, not the rule.
- **N2 (rule randomization, separate comparison):** random matched-density
  rules kill the pattern before T = 8 in 45–60% of runs (undefined foci,
  counted as registered); where defined, aperture medians run 0.0000–0.0018
  versus Life's 0.0037–0.0147 on the same seeds. Life's rule produces
  wider-aperture causal structure than a random totalistic rule of the
  same table density — descriptive, not tested.

## Disposition

1. **The load-bearing negative stands and is now real:** the aperture does
   not separate pooled coherent-pattern cones from soup cones on Life at
   d = 2. Reported with the same prominence as any positive, per §8.
2. **The narrowness result is now scoped:** it does not transfer to CA
   causal graphs; Mathlib's 18× is about curated libraries. This sharpens
   the program's empirical map rather than damaging it.
3. **P6′ survives as the registered, falsifiable thread** — still lifes vs
   soup, with the size entanglement named. Follow-up (new registration,
   not this session): size-controlled figure-vs-ground comparison, e.g.
   still-life cones vs soup sub-cones matched on n, plus more still-life
   seeds (pond, tub, boat, ship) to break the beehive/loaf duopoly.
   *(Run as v1.3, below: the follow-up killed it.)*
4. Two-implementation status unchanged: Node-side results; WL cloud
   confirmation of the primary cones remains the pending manual step.

---

# v1.3 results (2026-08-25, later session; size-controlled)

**Protocol:** `PREREGISTRATION-v1.3.md`, committed at `e7252b2` with the
sizes-only pre-check (`results/sizematch-precheck.json` — no aperture
computed before registration), before execution. Anchors all PASS at run
start. Raw output: `results/sizematch-v13.json`.

## Outcomes, as registered

| prediction | outcome |
|---|---|
| **P7 (size-controlled figure-vs-ground)** | **FAILS, decisively.** Stratified rank permutation test (strata n = 9, 16, 23; one-sided B > E; 100,000 permutations): p = 0.364. Stratum medians B vs E: 0.09766 vs 0.09766, 0.01559 vs 0.01559, 0.00743 vs 0.00753. |
| **S1 (quiescence disambiguation)** | **R3 — deflation.** Still-class vs active-class soup cones at n = 9: identical (all medAp = 0.09766, Mann–Whitney p = 1.0). Local quiescent figure carries nothing at matched size. |
| S2 (new still lifes) | The duopoly is broken and confirms the size law, not the condition: pond (n = 9) lands exactly on beehive/loaf; boat/ship (n = 16) land exactly on the n = 16 soup median; tub (n = 8, unmatched) fits the size trend. |
| S3 (size effect) | The law that generated the illusion, now on the record: E-side median aperture fraction 0.098 → 0.016 → 0.0075 across n = 9 → 16 → 23. |

## What the size-controlled data says

- **v1.2's P6′ was a cone-size artifact.** The ~17× still-life/soup ratio
  was the size law read across strata. The registration's disclosed prior
  (block, the one still life with a soup-sized cone, sitting in the soup
  range) pointed the right way and the permutation test confirmed it.
- **At n = 9 the comparison was between identical objects.** All ten n = 9
  cones — beehive, loaf, pond, and every matched soup focus, quiescent and
  active alike — share a single per-kernel aperture multiset
  (0, 30, 30, 50, 50, 56, 56, 64, 104 of 512): one structural class. The
  d = 2 counterfactual construction around any size-9 history apparently
  produces one poset up to the invariant. At n = 16 there are seven
  distinct classes (boat/ship even have one to themselves), and the B–E
  medians *still* coincide — variety exists and the condition label still
  carries nothing.
- **The CA study therefore closes fully negative on differentiation, end
  to end:** not authored-vs-random (P1, P1′), not figure-vs-ground (P7),
  not local quiescence (S1). On Life causal cones at d = 2 under this
  construction, the aperture measures cone size and cone isomorphism
  class, and nothing about what the pattern *is*.
- **What stands, unaffected:** latency is generic on this substrate
  (v1.3 data agrees: 7–22 latent kernels per cone, every cone); the
  narrowness scoping (Mathlib's ≈18× is about curated dependency
  structures, not causal graphs in general); and the size law itself, a
  clean descriptive fact nobody registered a prediction about.

## Disposition

1. Per v1.3 §5 (R3 branch): **report at full prominence and stop.** No
   v1.4 in this session; any return to this substrate needs a construction
   that breaks the size-dominance (deeper horizons, different edge
   relations, or intensive rather than extensive invariants), and that is
   an open design question, not a scheduled study.
2. The outward documents (both briefs) are updated in the same commit:
   the still-life lead they reported this morning is retracted as a size
   artifact, at the same prominence it was reported.
3. Instrument-history note: sixth overrule. The program's one positive
   lead on this substrate was killed by its own registered follow-up
   within hours of being reported. The v1.3 registration named the
   deflationary prior as better-supported before running; the discipline's
   job was to make the hope pay rent, and it couldn't.
4. Two-implementation status: Node-side; the WL twin remains the pending
   manual confirmation step for the study as a whole.

---

# Two-implementation confirmation (2026-08-26, Wolfram Cloud)

`wl/ca-aperture.wl` (extended 2026-08-26 with the v1.3 exact-tier still
lifes; reference values in `wl/EXPECTED.md`) was run in Wolfram Cloud by
the operator. **Every exact-tier number matches the Node reference
exactly:**

- Anchors: Div12 Ap(2) = 1, Div36 Ap(6) = 2.
- v1.1 primary cones at registered depths: the four depth-1 fans all-zero
  (fan blindness confirmed independently); the E/soup-20260825001 d = 2
  cone matches on all sixteen per-kernel apertures (4094, 126, 4186,
  1138, 1022, 126, 1022, 4186, 126, 1138, 126, 1022, 360, 12672, 288, 0),
  latency flags and identity verdicts included.
- v1.3 still lifes at d = 2: beehive/loaf/pond identical vectors
  (64, 50, 50, 30, 30, 104, 56, 56, 0), tub (24, 22, 22, 22, 8, 8, 8, 0),
  boat/ship identical (…, 2010, …, 960, 960, 0) — the single-structural-
  class facts the deflation verdict rests on, reproduced by an
  implementation written without reference to the Node code.

This closes the two-implementation requirement (v1.1 §9) for the anchors,
the v1.1 primary tier, the depth-1 blindness, and the exact-tier basis of
the v1.3 verdict. The sampled tier (n ≥ 19) remains single-implementation
Node estimates with stated confidence intervals, supporting no exact
claim. The [computed] grade on the study's exact-tier findings is now
fully earned under the program's own definition.
