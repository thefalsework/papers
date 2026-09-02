# Standing forward predictions

**Registered 2026-08-27. Scoring date: the first session after 2028-07-01.**

*This file is the program's only true forward registration: every empirical
study so far predicted a past that existed but had not been looked at
(blinded retrodiction). The predictions below concern corpus states that do
not yet exist. The git history of this file and of `frozen-2026.json` is the
timestamp. Grades as elsewhere: everything here is [H]. Deviations and the
eventual scoring appear below the line as dated postscripts, never edits.*

---

## 1. What is predicted

The growth finding this registers forward: **at matched degree and age,
Exploitation-cell members out-grow Distribution-cell members** — observed
retrodictively on Mathlib (`mathlib-study/18`), Go (`software-study/04`,
the program's first registered directional hit), and crates.io (same
script, failed the museum prediction by growing through E), and observed
*reversed* on AFP (`afp-study/07`). Four bets, one per corpus, each scored
independently:

| # | Corpus | Baseline (frozen here) | Prediction at horizon |
|---|---|---|---|
| P1 | Go stdlib | `software-study/history/go-2026.json` | **G_ED > 0** at ≥ 97.5th pct of null |
| P2 | crates.io | `software-study/history/crates-2026.json` | **G_ED > 0** at ≥ 97.5th pct of null |
| P3 | Mathlib (Order, Topology, Algebra) | 2026-05 pin (`lean/.lake/packages/mathlib`) | **G_ED > 0** at ≥ 97.5th pct of null |
| P4 | AFP | `afp-study/history/2026.json` | **G_ED < 0** at ≤ 2.5th pct of null (the reversal *persists*) |

P4 is the referee bet: the AFP reversal is hypothesized to be institutional
(the refereed-acceptance gate exports the corpus's E phase), so it should
not wash out with two more years of accretion.

**Horizon.** One rule for all corpora: the last commit on the default branch
on or before **2028-07-01** (for Mathlib, the Mathlib4 master pin nearest
below that date; for AFP, the mirror-afp-devel default branch).

## 2. The frozen baseline

`01-freeze-cells.mjs` (committed with this file; run once) computes, at each
corpus's 2026 baseline, the evaluable principal kernels and, per kernel, the
E- and D-cell members, exactly per the frozen designs (`mathlib-study/18`
for Mathlib; `software-study/04` for Go/crates; the same condensation gate
for AFP), and writes `frozen-2026.json`: per corpus, a per-member record
(name, cell, baseline in-degree d0, first-seen checkpoint index fs) grouped
into (kernel × stratum) cells, where a stratum is degree-bin
(0 / 1-2 / 3-7 / 8+) × exact first-seen index — the same age-and-degree
matching as the retrodictive originals.

**Size-control subsampling (declared, label-blind, seeded).** To keep the
frozen artifact committable, kernels are subsampled per corpus and each
(kernel, stratum, side) member list is capped by seeded uniform subsample
(constants in the script header). Uniform within-side subsampling leaves
the weighted mean-difference estimator unbiased and preserves within-cell
exchangeability under the null (the `software-study/04` argument). These
constants were tuned only for artifact size; since the outcome variable
(2028 in-degree) does not exist yet, no tuning can bias the test — the one
thing it can affect is power, and only downward.

## 3. Scoring (frozen now, in `02-score-2028.mjs`)

At the horizon, extract name → in-degree per corpus with the existing
extractors (`software-study/01` for Go/crates at the 2028 pins;
`afp-study/04` for AFP; the `mathlib-study/18` per-namespace loader for
Mathlib — Mathlib dependents are counted within the namespace subgraph, as
in the original). Then, per frozen (kernel × stratum) cell:

- drop members absent at horizon (death; renames = death + birth, as in
  the originals);
- if both sides are still nonempty: gains = horizon-degree − d0, weight
  = min(nE, nD);
- **G_ED** = Σ weight·(meanGain(E) − meanGain(D)) / Σ weight, pooled per
  corpus;
- null: within-cell label permutation, 1,000 draws, PRNG mulberry32, seed
  **20280701** (fixed now); observed scored as a percentile.

**Failure semantics.** Each of P1–P4 passes or fails alone; there is no
pooled verdict. A corpus with fewer than 30 scorable cells (both sides
alive) is **uninformative**, not failed. A significant reversal (wrong side
of the null band) is failure by reversal and is reported at full
prominence, as always. Operator's registered-directional record at time of
writing: 1 for 12.

**What a pass buys.** P1–P3 passing would upgrade "E is the growth engine"
from blinded retrodiction to genuine prediction on three corpora spanning
proofs and software. P4 passing would be the first predictive success of an
*institutional* reading (the referee hypothesis). Any failure scopes the
claim exactly as the tables above state — and is worth as much.

## 4. Standing prediction restated: the CWComplex island

Carried forward from the first field day (2026-08-19), restated here so all
forward bets live in one place: the `Topology.CWComplex.Classical` cluster's
empty Distribution cell — a genuine import island at the 2026-05 pin —
either fills with bridging modules or the cluster is re-founded. Scorable
against any future Mathlib revision by rerunning `mathlib-study/01` [H].

---

*Registered 2026-08-27, before any horizon data exists. Postscripts below.*

**NOTE (2026-08-27, same session, before push).** The freeze ran once
(deterministic; a rerun to switch the artifact to gzip produced
byte-identical content). Frozen populations: Mathlib 450 kernels / 7,711
cells; Go 355 / 5,384; crates 100 / 2,331; AFP 511 / 4,626. The scorer's
plumbing was smoke-tested against the baselines themselves (all gains zero
by construction, G_ED = 0.0000 on all corpora, every frozen cell matched) —
a parsing check, carrying no information about 2028.

**POSTSCRIPT (2026-08-30): P4's rationale is dead; the bet stands.** The
referee hypothesis behind P4's "because the mechanism is institutional"
was killed by its registered within-community test (`isabelle-study/03`,
RF2 failed by reversal: the continuously-maintained, ungated Isabelle
distribution grows through D exactly like refereed AFP). P4 itself is
unchanged — the prediction that the AFP reversal persists is frozen and
will be scored as registered — but a pass now confirms persistence of an
ecosystem-level regularity, not a referee mechanism. Nothing else in this
registration is affected.

**POSTSCRIPT (2026-08-30, later): what the deflation control means for
P1–P4.** The distance-matched control (`deflation-control/`) tested E-vs-R,
not the E-vs-D contrast these bets score, so no prediction here changes.
For the record of what a pass would mean: the control showed the E-vs-D
ordering is *not* a connectivity artifact anywhere it was measured —
Mathlib's E > D, Go's and crates' E > D, and both Isabelle-ecosystem
corpora's D > E all persist at matched exact distance. So P1–P4 remain
tests of a cell-level regularity that has already survived the distance
confound retrodictively; 2028 tests whether it persists forward. The
E-vs-R law, by contrast, deflated on all three proof corpora (null on
Mathlib, reversed on AFP and the Isabelle distribution) and survived
loudly on Go and crates — the registered-directional record after that
five-verdict study stands at 3 for 18.

**POSTSCRIPT (2026-09-01): expectations reprice; the bets stand.** Battery
v5 (`battery-v5/`) killed the program's last certified growth claim:
functional role (archive Section, institutional metadata invisible to
every graph feature) reverses Debian's E-over-R and nulls its D-over-E at
exact same-section stratification, after the effect had survived four
generations of graph-structural and autoregressive controls. Every growth
effect the program ever certified is now explained in-house (crates: fine
popularity; Go E-R: up-set flux; Go E-D: cone-mass; Debian: role). No
prediction here changes — P1–P4 are frozen and will be scored as written
in 2028 — but the program's own expectation is now that cell-level growth
orderings reflect corpus-specific composition, not a cell mechanism, and
misses will be reported as misses of the worldview that registered them.
These corpora (Mathlib, Go, crates, AFP) carry no functional-role control;
a 2028 pass would therefore be evidence of persistence, not of mechanism,
and will be stated as such when scored.
