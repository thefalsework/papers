# Baseline gauntlet: does the cell beat the standard predictors?

After the deflation control (`deflation-control/`) showed the E > R
growth effect survives exact distance matching on Go and crates.io, one
family of cheap explanations remained: the standard graph predictors —
preferential attachment (fine-grained degree), breadth (out-degree),
prestige (PageRank), embeddedness (k-core). This study matched E-members
to R-members (and, descriptively, D-members) within kernel and **exact
distance**, then nearest-neighbor on the full five-feature battery
(log in-degree, log out-degree, age, log PageRank, k-core; caliper 0.5
in z-space, chosen blind), with a pre-registered balance gate
(max standardized mean difference ≤ 0.10) and within-pair sign-flip
nulls.

## Verdict

| corpus | BG (primary): E > R beyond the battery | descriptive: E vs D |
|---|---|---|
| Go | **HOLDS** — Δ +0.220, null ±0.088, pct 100, 182 pairs | **holds** — Δ +0.153, pct 100, 11,478 pairs |
| crates.io | **NULL** — Δ −0.035, null ±0.31, pct 44, 61,444 pairs | null — Δ +0.017, pct 60 |

- **crates.io deflates.** Its huge distance-matched effect (G_ER +15.7)
  lived inside the coarse degree bins of the earlier design: matched at
  fine grain on popularity (continuous log-degree, PageRank, k-core),
  the cell carries nothing. Preferential attachment was hiding in the
  bin widths. The program found the artifact before a referee did,
  which is the system working — but it is a real loss, reported at
  full prominence.
- **Go survives everything.** At matched distance, degree, out-degree,
  age, PageRank, and k-core, Go's E-members still out-grow both their
  R and D twins at the 100th percentile. Go's cell effect has now
  passed every control the program knows how to construct.

Per the pre-registered interpretation table: **partial — the claim
scopes to Go, and the Debian out-of-sample bet is the tiebreaker.**
182 pairs on one corpus is not the gatekeeper sentence; Debian decides
whether it exists. Registered-directional record after this study:
4 for 20 (BG1 hit, BG2 miss).

## Files

- `gauntlet-lib.mjs` — PageRank (α=0.85, depended-upon direction),
  k-core (bucket peeling), z-scoring, greedy nearest-neighbor matching.
- `01-precheck.mjs` — **blind**: pair feasibility and covariate balance
  at calipers 0.25/0.5/1.0, no gains read. First pass showed distance
  was the imbalanced dimension; revised (still blind) to exact-distance
  groups. Caliper 0.5 fixed from this output.
- `02-gauntlet.mjs` — the registered run; postscript with results.
- `results-precheck.json`, `results-gauntlet.json` — outputs.

## Reproduction

Requires `software-study/history/`. Both scripts are seeded and
deterministic:

```
node baseline-gauntlet/01-precheck.mjs
node baseline-gauntlet/02-gauntlet.mjs
```
