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

*(appended 2026-08-11, after passes 2 and 3; registration commit
913fc4b)*

Passes 2 and 3 ran 2026-08-11 evening, 15/15 generated each, zero
failures (one profile needed attempt 2 after a validator retry:
Saint Matthew, pass 2). Corpora committed verbatim in
`corpus-v2-pass2/` and `corpus-v2-pass3/`. Analysis over all 45
transductions, gate definitions unchanged from
`comma-graduation.wl`.

### Status layer — the decision-rule numbers

| quantity | value |
|---|---|
| base rate p(derived), 45 transductions | 0.333 |
| raw pairwise agreement | 0.822 |
| chance baseline 1 − 2p(1−p) | 0.556 |
| **Fleiss kappa** | **0.600** |
| kappa 95% CI (bootstrap over works, 10⁵ resamples) | **[0.18, 0.90]** |
| P(kappa < 0.4) under the bootstrap | 0.18 |
| stability classes | 3 stable-derived / 8 stable-underived / 4 unstable |

Kappa 0.600 ≥ the pre-registered 0.4 threshold, so per the decision
rule the comma channel is presentable **with stability classes and
the layer decomposition as caveats** — not as an unqualified
capability. The interval is stated because n = 15 cannot pin the
second decimal: the lower bound sits *below* the decision
threshold, and roughly a fifth of the bootstrap mass is under 0.4.
The threshold was cleared by the point estimate the rule named; the
uncertainty around it is reported, not hidden.

**Two different reliabilities, and only one of them is 0.600.**
Status-level kappa measures the *gate's sensitivity* — does the
yes/no fire consistently on this work? It does not measure the
*derivation's identity* — is it the same comma each time? Those
come apart cleanly in this data (see *Ran* below), and any use of
the channel has to say which reliability it is claiming.

Stability classes (status per pass, pass 1 → 3):

- **Stable-derived (3/3):** *Girl with a Pearl Earring*,
  *The Red Book* (8c596e2f), *Ran*.
- **Stable-underived (0/3):** 8 works.
- **Unstable:** *Seven Samurai* 16b09742 [DuD], *Throne of Blood*
  [Duu], *The Red Book* 9181ad6f [uDD], *Stray Dog* [uDu].

So a reliable regime exists: 11 of 15 works answer identically
three times out of three. Practical consequence stated plainly: 2
of the 5 cores that derived commas in the original cell-8 run
(Seven Samurai 16b09742, Throne of Blood) are in the unstable
class, so the graduated Q2 top tier's membership is
pass-dependent for those works.

### H2 adjudication — refuted on its own pre-registered predictions

- point-biserial r(derived, edge count) = **+0.038** (predicted
  negative)
- point-biserial r(derived, edge density) = **+0.028** (predicted
  negative)
- within unstable works, deriving pass sparser than non-deriving:
  **4/8** (predicted majority)

No thinness selection. The 2-for-2 sparser-member direction in the
cross-profile pairs was coincidence, as the single-pass probe
suggested and this fresh sample confirms.

### H1 adjudication — supported at its core, with one artifact noted

Mean pairwise Jaccard by layer: nodes **0.598**, edges **0.364**,
tension pairs **0.393**, witnesses **0.711**. Instability enters at
the **edge layer** — the transducer roughly agrees on what the
parts are and substantially disagrees on how they connect — which
is H1's core claim. The witness-layer mean is inflated by
empty–empty agreement (stable-underived works score Jaccard 1 by
definition); among works that ever derive, witness agreement is low
(see the headline finding). The monotone-degradation prediction
fails at the witness layer for exactly that artifactual reason; the
informative ordering (nodes ≥ tension ≈ edges) holds.

Two consequences, stated plainly:

- **The instrument's ceiling is currently set by edge placement.**
  The executor is closure over `requires`; the witness gate is
  disjointness over the edge structure; every derived quantity in
  the algebra inherits from the least stable layer. Improving edge
  placement is the highest-leverage intervention available to the
  programme.
- **Node Jaccard 0.598 is not high.** Two passes over the same
  profile agree on about six parts in ten. "The same work" is more
  of an approximation than the pipeline currently assumes; the
  edges do not get to take all the blame.

### The headline finding: one stable comma, not three stable works

**One work out of fifteen produces the same comma three times.**
*The Red Book* (8c596e2f) has witness Jaccard 1.00 — identical
poles in all three passes. It is not merely the strongest case; it
is the *only* case. *Ran* is the sharp counterpoint: status-stable
but comma-unstable — it derives a comma every pass, from entirely
different poles each time (witness Jaccard 0.00). *Girl with a
Pearl Earring* is intermediate (0.33). So "this work has a comma"
replicates for three works, while "this is the comma" replicates
for exactly one — and the two claims come apart cleanly.
"Three stable-derived" and "one stable comma" are very different
claims; the second is the honest headline, with the gate's
consistent yes/no on 11 of 15 works as the second-tier claim.

### Findings beyond the pre-registered questions
- **The cross-profile "replicate mismatch" partially dissolves.**
  In passes 2 and 3, *both* Red Book profiles derive. The pass-1
  mismatch that motivated this study was partly transduction noise
  on profile 9181ad6f, not a stable profile-level disagreement.
- **The Saint Matthew retry is visible in the data:** its pass-2
  transduction differs most from its siblings (edge Jaccard 0.22),
  consistent with a regenerated-after-validation-failure output.

### What goes in the email

Per the decision rule: the comma channel appears, with the claims
graded. Headline: **one stable comma** (*The Red Book*, witness
Jaccard 1.00 across three passes). Second tier: the gate's yes/no
fires consistently on 11 of 15 works (kappa 0.600, 95% CI
[0.18, 0.90], chance baseline printed beside raw agreement).
Standing rule: **the 0.92 tier never appears without the note that
its membership is pass-dependent for two of the five originally
derived works.** The unstable works are listed, not hidden.
