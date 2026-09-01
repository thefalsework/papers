# Battery v2 — the confound the program's own theory found

**Question.** The accretion study's flux law (`accretion-study/THEORY.md`)
proves that under cone-local growth, expected gain tracks truncated
**up-set size** (transitive dependents) — a quantity carried by no
feature of the standard matching battery. Does the program's surviving
field claim (E > R at matched battery: Go and Debian) survive adding
that feature to the battery?

**Verdict, in one breath:** Debian's claim survives and upgrades; Go's
E-over-R is reclassified as up-set-confounded (the third artifact
caught in-house, the first caught by theory); Go keeps a clean
battery-v2-proof E-over-D effect. Registered record after this study:
8 for 24, with three directional hits in a row.

**What the blind pre-check found** (`01-precheck.mjs`, `01b-go-sweep.mjs` —
structure only, no gains): in the 182 five-feature pairs behind Go's
celebrated +0.22, E-members carried far larger up-sets than their R
twins (signed SMD **+0.69** — the inflation direction, exactly as the
flux law would have it). And it is unrepairable: at every caliper
0.25–0.5 only 51 balanceable pairs exist, still over the 0.10 gate.
Debian's old pairs were already nearly balanced (0.048), and its
six-feature match balances beautifully (239,587 ER pairs, maxSMD 0.010).

**The registered run** (`02-batteryv2.mjs`, committed before execution):

- **BV1 (Debian E-vs-R, primary): HOLDS.** Δ = +0.0834 against a
  conditional null of ±0.012, 237,078 pairs, all six SMDs ≤ 0.0104.
  Barely moved from v1 (+0.098). Debian's Exploitation cell now
  predicts growth beyond in-degree, out-degree, age, exact distance,
  PageRank, k-core, **and transitive-dependent count**.
- **BV2 (Go E-vs-D): HOLDS.** Δ = +0.1524, unchanged from v1 — Go's
  E-over-D was never up-set flux.
- **Descriptive (pre-declared unscoreable):** Go E-vs-R on its 51
  near-balanced pairs reads **−1.00** — at approximately matched
  up-set size the advantage is gone and inverted. Together with the
  +0.69 imbalance and the mechanism, Go's E > R is honestly read as
  up-set flux in costume.
- Debian E-vs-D still reverses (−0.165): the two-axis picture
  (E-over-R battery-proof; E-vs-D corpus-contingent) is up-set-robust.

**Why this study is methodologically new for the program:** every prior
confound (degree bins, distance, PageRank) was a reviewer's classic.
This one was *derived* — the synthetic model said "here is a quantity
that cone-local growth must reward and your battery cannot see," and
the field data confirmed both halves: it was imbalanced exactly where
the old design had its biggest effect, and matching it away killed that
effect while leaving the sealed-bet corpus standing.

**Files.**
- `lib.mjs` — the sixth feature: log1p(upset_200) via truncated BFS over dependents.
- `01-precheck.mjs` / `precheck.json` — blind balance/feasibility, old-pair imbalance audit.
- `01b-go-sweep.mjs` — blind caliper sweep for Go E-R (unrepairable at every caliper).
- `02-batteryv2.mjs` / `results.json` — the registered run; results and the record correction in its postscript.
