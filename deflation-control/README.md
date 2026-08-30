# Deflation control: does E > R survive distance matching?

The one dynamical statement that had held on every corpus measured —
exploitation-cell members out-grow matched refusal-cell members — had an
obvious skeptic's compression: *connected periphery grows, disconnected
periphery doesn't.* E-members are by construction downward-connected to
the kernel; R-members are not; degree matching can't dispose of that
because degree is local and connectivity is global. This study added
**exact undirected graph distance to the kernel's down-set** to the
matching key (degree bin × first-seen × exact distance) and re-ran the
growth comparison on all five corpora with history.

## Verdict

| corpus | DC1: E > R at matched distance | DC2 (descriptive): E vs D |
|---|---|---|
| Mathlib (3 namespaces) | **NULL** (obs 0.006, pct 79) | E > D **survives** (pct 100) |
| AFP | **REVERSES** (obs −0.103, pct 0.3) | D > E persists |
| Isabelle distribution | **REVERSES** (obs −0.113, pct 0.0) | D > E persists |
| Go index | **HOLDS** (obs 2.42, null ±0.51) | E > D holds |
| crates.io | **HOLDS** (obs 15.68, null ±3.58) | E > D holds |

The universal law is dead, and the split that killed it is sharper than
the law was:

- **Proof corpora: deflated or inverted.** Mathlib's E > R was
  connectivity in costume — at matched distance it is null. AFP and the
  Isabelle distribution invert: among equally-distant members, the
  *refusal* side grows more. Their unmatched E > R was proximity masking
  an R advantage. The "AFP anomaly" was never an anomaly; it was the
  proof-archive regime showing through first.
- **Software ecosystems: survives loudly.** In Go and crates.io, at
  identical degree, age, and connectivity, the exploitation cell still
  predicts several extra dependents of growth. There the cell carries
  information graph distance does not.
- **Mathlib's E > D is not a proximity artifact** (DC2, pct 100 on
  99,231 matched cells), even though its E > R was. The partition is
  not empty in proof corpora — it just doesn't say what we said.

Scoreboard: five registered per-corpus verdicts — two hits, two
reversals, one null. Registered-directional record now 3 for 18.

## Files

- `lib.mjs` — shared loaders (same graphs, gate, and cell classifier as
  the original growth studies) plus per-kernel undirected multi-source
  BFS distance.
- `01-precheck.mjs` — **blind** pre-check: stratum occupancy and
  distance distributions only, no gains read. Confirmed the confound is
  real (E masses at distance 1–4, R spreads to 15+ with large
  unreachable populations) and the matched comparison exists on all
  five corpora.
- `02-control.mjs` — the registered run. Pre-registration header,
  interpretation table fixed in advance, operator prior on record
  (leaning deflation — half right). Postscript with results.
- `results-precheck.json`, `results-control.json` — outputs.

## Reproduction

Needs the same inputs as the original growth studies: the mathlib
historical checkouts in `.scratch_mathlib_hist/` plus the current lake
checkout, and the committed history files in `afp-study/history/`,
`isabelle-study/history/`, `software-study/history/`.

```
node deflation-control/01-precheck.mjs
node deflation-control/02-control.mjs
```

Seeds are hardcoded; both runs are deterministic.
