# Re-transduction study: comma-derivation repeatability

**Pre-registered 2026-08-11, before passes 2 and 3 were run.** The
predictions, metrics, and decision rule below are fixed by this
commit; the results section is empty at registration and will be
appended after the runs. Nothing in this file above the results
section may change after the passes execute.

## Why

The comma-shape graduation's cell-8 replicate checks showed both
same-work pairs mismatching (one transduction derives a comma, the
other does not). At n=2 that is an anecdote. Worse, the existing
"replicate pairs" are **cross-profile**: two different falsework.dev
structural profiles of the same work, each transduced once. They
measure profile variance and transduction variance *combined*, and
are therefore excluded from the repeatability pooling below. This
study isolates transduction repeatability for the first time:
same profile, same prompt, same settings, repeated passes.

Two live hypotheses (design-notes.md, V2 addendum part 2):

- **H1 (transduction variance):** instability is upstream of the
  witness gate — `requires`/`contradicts` placement wobbles run to
  run, changing whether tension poles are load-bearing.
- **H2 (gate selects for thinness):** derivation systematically
  favors sparser descriptions through a channel other than w2 (the
  single-pass probe already cleared w2, which binds in only 3 of 38
  failures). H2's standing evidence: in both cross-profile pairs,
  the sparser member derived (2-for-2).

## Instrument (recorded, not varied)

- Model `claude-fable-5`, prompt `corev2-transduce/1.0`, effort
  high, fallback temperature 0.0, max 6,000 tokens, ≤ 3 attempts
  with validator-error feedback (node0000 `lib/corev2/transduce.ts`).
- Pass 1 = the existing `corpus-v2/` (all 15 files generated
  2026-08-11 under exactly these settings; provenance homogeneous).
- Passes 2 and 3: the same 15 profiles by id (from
  `corpus-v2/index.json`), transduced again into separate
  directories. Nothing about the instrument changes between passes;
  observed variance is the instrument's own.

## Pre-registered metrics

Per work, per unordered pass-pair (3 pairs × 15 works), layered so
the entry point of instability is localizable:

1. **Node layer** — Jaccard on node-id sets (caveat: alignment is
   lexical; element ids are semantic slugs, mechanism ids are
   positional, so this layer under-reports semantic agreement).
2. **Edge layer** — Jaccard on `from|kind|to` triples.
3. **Tension layer** — Jaccard on unordered contradicts-pair sets.
4. **Witness layer** — Jaccard on witness pole-pair sets (comma
   gate applied, pre-committed definitions from
   `comma-graduation.wl`, unchanged).
5. **Status layer** — binary comma status (derived/underived).

Aggregates:

- **Fleiss' kappa** on binary status (15 items × 3 raters), the
  headline number.
- Raw pairwise status agreement **printed beside its chance
  baseline** `1 − 2p(1−p)` at the observed base rate p (at p ≈ 1/3,
  chance ≈ 0.56 — raw agreement alone would flatter the result).
- **Stability classes** per work: stable-derived (3/3),
  stable-underived (0/3), unstable (mixed). Whether a stable
  regime exists at all is a separate finding from the kappa.

## Pre-registered predictions

- **H2 predicts** (directional, stated before the runs): among
  eligible transductions (≥ 1 tension pair), derivation
  anti-correlates with edge count and with edge density
  (edges/nodes); and within unstable works, deriving passes have
  fewer edges than non-deriving passes in a majority of
  comparisons.
- **H1 predicts**: no consistent density direction; agreement
  degrades monotonically down the layers (nodes ≥ edges ≥ tension
  pairs ≥ witnesses), i.e. instability enters at edge placement,
  not at vocabulary or gate arithmetic.

## Pre-registered decision rule

- If **Fleiss kappa < 0.4** on comma status: the comma channel is
  **excluded from the Wolfram email as a capability claim** and
  reported solely as a measured-unreliability finding with these
  numbers. The graduation's headline becomes the replication rate,
  full stop.
- If **kappa ≥ 0.4** and the H2 density direction does **not**
  hold: the channel is presented with stability classes and the
  layer decomposition as caveats.
- If the **H2 direction holds** in fresh passes (negative
  association with edge count and density, majority sparser-derives
  within unstable works): the witness-gate design is rethought
  before any comma result is used anywhere, email included.
- All numbers publish regardless of outcome.

## Results

*(empty at registration — appended after passes 2 and 3)*
