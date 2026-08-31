# Debian study: the tiebreaker bet

After the deflation control killed E > R on the proof corpora
(`deflation-control/`) and the baseline gauntlet deflated crates.io to
fine-grained popularity (`baseline-gauntlet/`), the growth claim stood
on one corpus (Go), and the gauntlet's pre-registered interpretation
table named a fresh out-of-sample corpus the tiebreaker. This is that
study: the Debian archive (main/binary-amd64), ten stable releases
2007–2025, a corpus untouched by any script in this repository until
the day before the bet — and the strongest reuse semantics available
(a Debian dependency is installed, executed code).

## Verdict

**DB1 HOLDS.** At matched exact distance AND matched full battery
(log in-degree, log out-degree, age, log PageRank, k-core; caliper 0.5,
balance gate 0.10 passed at 0.0097), Exploitation-cell members out-grow
their Refusal-cell twins: Δ_ER = +0.098 dependents, null band ±0.015,
100th percentile, 264,330 pairs, 2,400 kernels, eight baselines.

The sealed bet landed on the first try. The two-ecosystem claim now
exists: **membership in the Exploitation cell predicts future
dependency growth beyond every standard graph predictor, pre-registered,
on Go and Debian — with crates.io's deflation reported alongside as the
method catching its own artifact.** Registered-directional record:
5 for 21.

Descriptive secondary (unpredicted, reported at the same volume):
Δ_ED = −0.155, percentile 0 — Debian's *Distribution* cell out-grows
its Exploitation cell at matched everything, like the Isabelle-ecosystem
archives and unlike Go. So E-vs-R (battery-proof on two ecosystems) and
E-vs-D (corpus-contingent) are independent axes.

## Files

- `01-extract.mjs` — extraction; all parsing choices fixed in the
  header before any analysis (Depends + Pre-Depends, first alternative,
  unresolved virtuals dropped and logged).
- `02-census.mjs` — **blind**: graph structure (near-acyclic, survival
  70–81% at +2), kernel evaluability (2,400/2,773), pair feasibility
  and balance per caliper. No gains read. Caliper 0.5 fixed from this.
- `03-bet.mjs` — the registered run; interpretation table fixed in
  advance; postscript with results.
- `history/*.json` — the ten snapshots ({nodes, edges}, ~17.7k → 68.8k
  packages).
- `results-census.json`, `results-bet.json` — outputs.

## Reproduction

```
node debian-study/01-extract.mjs   # re-fetches from archive.debian.org / deb.debian.org
node debian-study/02-census.mjs
node debian-study/03-bet.mjs
```

Seeds hardcoded; deterministic given the committed history files.
