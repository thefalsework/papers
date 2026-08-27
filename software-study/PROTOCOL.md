# The garden/museum test: a registered, unrun protocol

**Pre-registration. Version 1.0, 2026-08-26. Written and committed before any
corpus is acquired — no census, no pre-check, no data of any kind has been
collected from either target. This is preregistration in its strongest form:
before acquisition, not merely before analysis.**

*Status discipline as elsewhere in this program: this document is a protocol,
not a result. Everything in it is [H]. Any deviation at execution time is
logged as a dated postscript, never an edit. Anyone — including a skeptic —
may execute this protocol; the predictions bind regardless of who runs it.*

---

## 1. The hypothesis under test

Two independent measurements now separate the program's two historical corpora
along the same axis, and neither was predicted:

1. **Consolidation direction.** On Mathlib (continuously maintained,
   refactored daily), apertures narrow over three years, surviving
   per-snapshot degree-preserving nulls (`mathlib-study/06`, `08`). On the
   Archive of Formal Proofs (entries frozen at acceptance, never rewired),
   apertures *widen* over twenty-two years (`afp-study/05`, H2 failed by
   reversal). Latency rises on both.
2. **Growth-cell identity.** At matched degree, within-kernel, against
   label-permutation nulls: on AFP, Distribution-cell members become
   load-bearing (D > E > R; `afp-study/07`, GP1 failed by reversal). On
   Mathlib, with age matched away, Exploitation-cell members do
   (E > D > R; `mathlib-study/18`, MG1 failed by opposite reversal).

The post-hoc reading, now promoted to the hypothesis this protocol tests:

> **The maintenance regime determines both.** A *garden* — a corpus whose
> existing dependency structure is continuously rewired by its community —
> consolidates (apertures narrow) and grows through its Exploitation cell.
> A *museum* — a corpus that only accretes, never rewiring what is already
> accepted — does not consolidate (apertures widen or stay flat) and grows
> through its Distribution cell.

Two corpora are a line through two points, and both current points are proof
libraries. The discriminating test requires a maintained/archival pair from a
**different domain**, chosen for the regime contrast rather than for any
resemblance to mathematics.

## 2. The pair (fixed here, before any inspection)

- **Garden: the Go standard library.** One repository
  (`github.com/golang/go`, `src/` tree), continuously refactored by a single
  community for fifteen-plus years; internal package-import graph enforced by
  the compiler; history in git. Nodes: standard-library packages. Edges:
  package A imports package B (intra-stdlib edges only; vendored and external
  modules excluded).
- **Museum: the crates.io index.** The registry index
  (`github.com/rust-lang/crates.io-index`), full history in git since 2014.
  Published crate versions are immutable by policy — the platform enforces the
  museum regime rather than merely encouraging it. Nodes: crates. Edges:
  crate A's newest published version at the checkpoint declares a normal
  (non-dev, non-optional) dependency on crate B.

Both corpora satisfy the instrument's two standing requirements: a dependency
order nobody can argue with (compiler / registry enforced) and ground-truth
labels made by people who have never heard of this program (Go package paths;
crate name prefixes and registry categories).

**Checkpoints.** Biennial, aligned where both corpora exist: 2016, 2018,
2020, 2022, 2024, 2026 (six per corpus; Go's pre-2016 history may be added
descriptively but is not scored). Checkpoint = last commit on or before
July 1 of the year, recorded by SHA in the census script.

## 3. Manipulation check (gate — nothing is scored if it fails)

The design assumes the two corpora actually differ in regime, not just in
folklore. Before any prediction is scored:

- **MC1.** Among nodes present at consecutive checkpoints, the fraction whose
  out-edge set changed must be at least **3× higher** in the Go stdlib than in
  crates.io (crate edges can only change via a *new* published version, so
  their surviving-version edge sets are frozen by construction; the check
  guards against the museum being secretly gardened through rapid
  re-publication).
- **MC2.** Both corpora must yield ≥ 3 evaluable kernels (ordinary, with E, D,
  R all nonempty) at ≥ 4 checkpoints, under the same cone construction as the
  prior studies (principal down-sets on the import DAG, cycles handled by
  condensation as in `afp-study/01`).

If either check fails, the pair is wrong, the study is **uninformative**, and
no prediction is scored — report, register a replacement pair, stop.

## 4. Predictions (the four quadrants)

All tests use the instruments already built and frozen in
`mathlib-study/`/`afp-study/`: the latency and aperture arrows as Spearman
trends over checkpoints with per-snapshot degree-preserving nulls
(`mathlib-study/08` design); growth-cell identity as the within-kernel,
degree- and age-matched E-vs-D contrast against label-permutation nulls
(`mathlib-study/18` design, which already includes the age matching AFP
lacked). Thresholds identical to the registered originals: arrows require
|Spearman| ≥ 0.6 in the stated direction; growth contrasts score against the
2.5th/97.5th percentiles of their nulls.

| | Consolidation | Growth cell |
|---|---|---|
| **Q1. Go stdlib** | apertures **narrow** (arrow ≤ −0.6, outside null) | **E > D** at matched degree and age (above 97.5th pct) |
| **Q2. crates.io** | apertures **do not narrow** (arrow > −0.6, or inside null) | **D > E** at matched degree and age (below 2.5th pct) |

- **SP1 (secondary, both corpora).** Latency rises (arrow ≥ +0.6). Predicted
  generic; a failure scopes the latency arrow, not the axis.
- **SP2 (bonus, registered but not load-bearing).** Exploitation-on-territory
  holds on both corpora at HEAD, under the corpus's native name-territory
  instrument (Go: shared leading path components; crates: shared name prefix /
  registry category), against the placement-permutation null of
  `mathlib-study/12`. A blind resolution pre-check (as `mathlib-study/11`)
  must vet each instrument's dynamic range before SP2 is scored; if resolution
  is inadequate, SP2 is uninformative, not failed.

## 5. Failure semantics

- **All four quadrants hold** → the axis graduates: maintenance regime
  predicts both consolidation direction and growth-cell identity across
  domains. First cross-domain dynamical regularity of the program.
- **Consolidation quadrants hold, growth quadrants fail** (or conversely) →
  the axis splits: the two fingerprints measure different things and the
  "one axis" reading dies. Report which half survived; the surviving half
  keeps its two-proof-corpus support plus one software point.
- **Diagonal failure** (e.g. the museum consolidates, or the garden grows
  through D) → the axis dies by reversal, which is stronger than dying by
  noise. The maintained/frozen reading was a two-corpus coincidence; say so
  at full prominence.
- **MC failure** → uninformative; see § 3.
- Prior probability, stated for the record: registered operator hypotheses in
  this program are currently 0 for 9. The honest expectation is that this one
  dies too. That is what the registration is for.

## 6. What this cannot show

One garden and one museum are still one pair; a positive result yields a
regularity across two domains and four corpora, not a law. Nothing here
touches the [K] spine, the CA negative, or the E-on-territory finding, all of
which stand or fall independently. No claim about software engineering
practice is made or implied beyond the two named corpora.

## 7. Execution notes (for whoever runs it)

Estimated two to four sessions. Order is fixed: acquisition → census (blind:
sizes, parse rates, SCC structure only) → MC1/MC2 → resolution pre-checks →
registered runs. Corpus acquisition is the risky step (the crates index is
large; Go's pre-module history has layout changes at 2019); acquisition
failures are logged, never smoothed. Two-implementation agreement is required
for any exact-tier aperture computation, per house rules. All PRNG seeds fixed
in script headers before first run.

---

*Committed unexecuted. Deviations, and eventually results, appear below this
line as dated postscripts.*

---

**POSTSCRIPT (2026-08-27 — executed; the axis is dead on both rows).**

Execution: acquisition and census 2026-08-27 (`01-census.mjs`; one plumbing
repair logged there — Go build-ignored generator files were creating a false
SCC; crates history recovered from `crates.io-index-archive` snapshot branches
after the live index proved squashed). Gates passed: MC1 ratio 3.13 (≥ 3,
narrowly), MC2 6/6 checkpoints ≥ 3 evaluable kernels on both corpora
(`02-gates.mjs`, `results-gates.json`). Registered runs `03-consolidation.mjs`
and `04-growth.mjs`, single runs each, seeds as committed.

Results against the quadrant table:

| | Consolidation | Growth cell |
|---|---|---|
| **Q1. Go stdlib** | **FAILS** — Spearman −0.714 clears the threshold but final checkpoint sits at pct 43.3 of its nulls (inside band) | **HOLDS** — G_ED +0.396, null ±0.058, pct 100 |
| **Q2. crates.io** | **HOLDS** — Spearman −0.200, final pct 96.7 (predicted absence) | **FAILS BY REVERSAL** — G_ED +5.826, null ±0.59, pct 100: the museum grows through E |

SP1 fails on both corpora: latency *falls* on Go (Spearman −0.657) and is flat
on crates (+0.314). SP2 was not run: with both load-bearing rows already
decided, the bonus prediction could not change the verdict and was left for a
possible standalone E-on-territory replication.

**Verdict, per §5: the axis dies.** The consolidation row failed by absence
(the garden did not consolidate — no diagonal), and the growth row failed by
reversal (the museum grew through Exploitation, with the largest effect ever
measured in this program). The maintained/frozen reading of the
Mathlib-vs-AFP contrast was a two-corpus coincidence, as the stated prior
expected.

What the four-corpus record now shows instead: **E out-grows D at matched
degree and age on Mathlib, Go, and crates.io — maintained and archival,
proofs and software — and reverses only on AFP.** The anomaly to explain is
AFP, not a regime axis. Mathlib's consolidation arrow, having failed to
appear on AFP, Go, or crates, is now scoped to Mathlib alone. The latency
arrow, which held on both proof corpora, fails on both software corpora and
is scoped to proof libraries.

Operator's registered-primary record: Q1-GROWTH is the first directional hit
(1 for 11).
