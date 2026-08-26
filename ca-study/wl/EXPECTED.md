# Expected output for the Wolfram Cloud confirmation run

Reference values extracted from the committed Node outputs
(`results/study-raw.json` for the v1.1 primary cones,
`results/sizematch-v13.json` for the v1.3 still lifes) on 2026-08-26.
Every `|Ap|` printed by `ca-aperture.wl` must equal the value below
**exactly** (kernel index order is the same in both implementations:
nodes sorted by (t, r, c) ascending). Any mismatch stops the study and is
reported as a two-implementation disagreement.

## How to run

1. Open [wolframcloud.com](https://www.wolframcloud.com) and create a new
   notebook (a free account is enough).
2. Paste the entire contents of `ca-aperture.wl` into a single cell.
3. Evaluate (Shift+Enter). Expected runtime: 1–3 minutes (the n = 16
   cones dominate; everything is exact enumeration, no sampling).
4. Compare every printed line against this file.

## Anchors

```
Div12 Ap(2) = 1  (must be 1)
Div36 Ap(6) = 2  (must be 2)
```

## v1.1 primary cones (registered depths from the committed census)

Per-kernel |Ap| in kernel order 0, 1, 2, …:

| cone | n | d | per-kernel apertures |
|---|---|---|---|
| A/glider | 9 | 1 | all 0 (nine kernels) |
| B/block | 6 | 1 | all 0 (six kernels) |
| C/blinker | 9 | 1 | all 0 (nine kernels) |
| D/lwss | 9 | 1 | all 0 (nine kernels) |
| E/soup-20260825001 | 16 | 2 | 4094, 126, 4186, 1138, 1022, 126, 1022, 4186, 126, 1138, 126, 1022, 360, 12672, 288, 0 |

The four depth-1 fans must be all-zero (the aperture-blindness of
two-layer posets, proved in `RESULTS.md`); the soup cone is the real
content of the v1.1 tier. In the soup cone every kernel with |Ap| > 0
must print `LATENT` except none are ordinary at identity.

## v1.3 still lifes at d = 2 (exact tier)

| cone | n | per-kernel apertures |
|---|---|---|
| B/beehive | 9 | 64, 50, 50, 30, 30, 104, 56, 56, 0 |
| B/loaf | 9 | 64, 50, 50, 30, 30, 104, 56, 56, 0 |
| B/tub | 8 | 24, 22, 22, 22, 8, 8, 8, 0 |
| B/pond | 9 | 64, 50, 50, 30, 30, 104, 56, 56, 0 |
| B/boat | 16 | 1022, 1022, 1022, 1022, 4094, 4094, 1022, 1022, 4094, 2010, 1022, 1022, 0, 960, 960, 0 |
| B/ship | 16 | 1022, 1022, 1022, 1022, 4094, 4094, 1022, 1022, 4094, 2010, 1022, 1022, 0, 960, 960, 0 |

Beehive, loaf, and pond printing the identical vector is not an error —
it is the v1.3 finding that all n = 9 depth-2 cones are one structural
class. Boat and ship identical likewise. Block is omitted (Node values
are sampled-tier estimates; no exact reference exists).

## What confirmation licenses

Exact agreement on every line completes the two-implementation
requirement (v1.1 §9) for: the anchors, the v1.1 primary-tier
measurements, the depth-1 fan blindness, and the exact-tier cones the
v1.3 deflation verdict rests on. The sampled-tier values (n ≥ 19) remain
single-implementation Node estimates with stated confidence intervals —
they support no exact claim, and this run does not change that.
