# Replicate-First: Honest Uncertainty, a Flux Law, and Complete Mechanism Identification for Matched-Pair Growth Studies on Evolving Dependency Graphs

**Author.** Chris Brink (independent)
**Version.** Draft v0.1, 2026-09-02. Assembled from the accretion-study
laboratory (`accretion-study/`: `SPEC.md`, `SPEC-D.md`, `THEORY.md`,
scripts `01`–`05` with registered results committed beside them) and the
five-generation field program it audited (`debian-study/`,
`battery-v2/`–`battery-v5/`). This paper contains no new runs: every
number cites a registration committed before its single scored execution.
**Status discipline.** Claims carry grades: **[C]** classical mathematics,
proved in text or cited; **[computed]** registered finite computation,
single scored run per registration; **[A]** interpretive. The grades are
load-bearing.

---

## Abstract

Matched-pair designs are a standard instrument for growth claims on
evolving networks: pair structurally similar nodes, difference their
future gains, and read significance off a permutation null. We report
three results about this instrument, each established in a synthetic
laboratory where ground truth is available by construction, and then
demonstrated end-to-end on a real registered program whose final act was
killing its own headline claim. **(1) The audit.** The matched-pair point
estimator is unbiased on generators provably blind to the tested
partition — exactly under uniform attachment, by exchangeability under
preferential attachment [C] — but the standard within-corpus sign-flip
null understates true across-universe variance by roughly an order of
magnitude [computed]. The failure has two levels, only one of which any
within-corpus resampling can price: pairs sharing a kernel share a
neighborhood (repairable by clustered flips), and all pairs share the one
realized growth history (not repairable by any rearrangement of it). For
a corpus that exists once, ensemble uncertainty is not samplable from
within; the honest warrant is replication across independent corpora and
sealed out-of-sample prediction. **(2) The flux law.** Under cone-local
accretion — newcomers pick a platform and draw dependencies from its
truncated transitive closure — expected per-step gain is affine in
**ORACLE(x) = Σ_{u : x ∈ cone(u)} 1/|cone(u)|**, harmonic cone-membership
mass [C-style derivation, confirmed 10/10 universes]. This quantity is
absent from standard predictor batteries (degree, age, PageRank, k-core),
which is a constructive proof that a baseline-computable partition can
carry growth signal beyond any such battery without magic. **(3) Complete
mechanism identification.** In the laboratory, matching on ORACLE
extinguishes the partition's signal exactly (t = −0.25 from t = −10.2),
while matching on exact *uncapped* descendant counts does not (t = −7.0):
the operative structure is concentration of reach, not volume [computed].
The field demonstration: five sealed battery generations on the Debian
archive, in which the laboratory's derived features killed two prior
certified effects on another corpus, and an institutional-metadata
control — outside the graph, hence outside the audit's guarantee —
finally killed the program's own four-generation-stable headline. We
distill the method into a checklist we commit to and recommend:
replicate-first designs for generators, cross-corpus replication and
sealed bets for single-history corpora, flux-law features and
non-structural covariates in the battery from generation one, and
interpretation tables fixed before every run.

## 1. Setting

A growing directed graph is observed at snapshots; a study fixes a
baseline snapshot, computes node features and a node partition from the
baseline only, and asks whether partition membership predicts in-degree
gain over a horizon beyond the features. The estimator throughout: for a
sampled set of *kernels* (reference nodes making the partition
non-degenerate), candidate nodes are grouped by partition cell and exact
undirected graph distance to the kernel's territory; cross-cell pairs are
matched greedily without replacement within a 0.5-caliper ball in the
z-space of the feature battery, subject to a pre-registered balance gate
(max |SMD| ≤ 0.10 per feature); the statistic is the mean within-pair
gain difference; the conventional null flips pair signs. The partition
under study is the aperture program's four-cell structure (Exploitation /
Refusal / Infrastructure / Distribution; `preprints/aperture/paper.md`),
but nothing in this paper depends on its specifics: the results apply to
any baseline-computable node classification tested by matched pairs.

The laboratory (`accretion-study/sim-lib.mjs`) grows synthetic universes
from fixed rules — uniform attachment (U), preferential attachment (PA),
and platform-cone accretion PC(β), where a newcomer picks a platform
uniformly and draws dependencies from the platform's truncated down-set
(β mixes cone-local with global draws) — and runs the *identical*
estimator code on them. Two features of real corpora proved structurally
necessary for non-degeneracy and are part of the recipe: root nodes must
exist (dependency count m = 0 with positive probability; otherwise the
first node is a universal ancestor and the Refusal cell is empty
everywhere), and platform choice must not be popularity-weighted from
birth (or primordial hubs recreate the universal ancestor). Both
failures, and their fixes, are documented in `SPEC.md` [computed].

## 2. The audit: what permutation percentiles measure

**Proposition 1 (uniform attachment is exactly null) [C].** Under U,
for any pairing rule measurable in the baseline graph, E[Δ] = 0. *Proof:*
at each future step every existing node is hit with equal probability
regardless of any baseline property; conditional expected gain is a
shared constant; pair differences vanish in expectation by the tower
property. ∎

**Proposition 2 (PA is null given in-degree matching) [C].** Under PA,
baseline nodes of equal in-degree have exchangeable futures (the
transition law sees only the weights), hence equal expected gains; any
exact-in-degree pairing has E[Δ] = 0. ∎ (The estimator matches log
in-degree within a caliper, not exactly; the balance gate bounds the
residual, and replicate calibration measured means indistinguishable
from zero on both U and PA, as the propositions predict [computed].)

**The variance failure [computed].** Replicate calibration — many
independent universes per rule, the estimator run once per universe —
found the across-universe standard deviation of the statistic roughly
**10× the sign-flip band**, on generators where the truth is null. The
percentile attached to any single universe's run is therefore not a
generator-level tail probability; confident false positives on provably
null rules are routine. Kernel-clustered flips (flipping each kernel's
pairs as a block) were tested and found insufficient
(`01c-validate-clustered-null.mjs`).

**Why, precisely.** Var(mean) = Σd²/n² is correct only if pair
differences are uncorrelated given magnitudes. They are correlated at two
levels: *within kernel* — pairs sharing a kernel share the local
neighborhood, and a growth wave moves them together (clustered flips
price exactly this) — and *across the universe* — which regions of the
graph are fertile over a horizon is a property of the one realized
trajectory, and every kernel rides it. No within-corpus rearrangement can
price the second level, because every rearrangement sees the same single
trajectory. A within-corpus percentile is a statement about
pair-exchangeable rearrangements of one history, not about the ensemble
of histories.

**Consequences for practice.** For synthetic generators, run
replicate-first: the universe, not the pair, is the unit of inference
(the laboratory's confirmatory phase used 20 universes per rule and
t-statistics across universes [computed]). For a real corpus — which
exists once — the ensemble is not samplable from within; report
percentiles only as conditional statements, and carry the warrant with
replication across independent corpora and sealed out-of-sample
directional bets registered before first measurement. We adopted this
reading discipline retroactively for an entire field program the same day
the calibration landed, repricing every previously reported percentile
(`SPEC.md` postscript; the briefs' dated corrections).

## 3. The flux law, and the feature batteries cannot see

Under PC(0), fix a node x and let up(x) = {u : x ∈ cone(u)} be the set
of nodes whose truncated dependency cone contains x. Per growth step,

  P(x gains) ≈ (1/t) · [ 1 + (m̄ − 1) · Σ_{u ∈ up(x)} 1/|cone(u)| ],

one term for being drawn as platform, one for being sampled from a cone
containing x. Expected gain is affine in **harmonic cone-membership
mass**, ORACLE(x) = Σ_{u ∈ up(x)} 1/|cone(u)|: *being a large share of
many small toolchains* [C-style derivation, `THEORY.md` §3; direct
confirmation, 10/10 universes, `03-sign.mjs`].

Standard batteries (in/out-degree, age, PageRank, k-core) contain no
up-set measure — PageRank in the depended-upon orientation is a damped,
normalized cousin, truncated hard by both. Consequently a generator whose
flux tracks cone mass leaves room for a baseline-computable partition to
carry growth signal *at matched battery*. PC(0) realizes this: its cell
ordering R > E > D holds at t ≈ 10 across 20 universes against the full
five-feature battery [computed]. This is a constructive possibility
proof with two edges, and we state both: a partition can legitimately
out-inform a reviewer's arsenal (no leakage, no artifact — the battery
is simply blind to the operative quantity), and *any* field claim
certified "beyond battery X" is one derived feature away from
reclassification.

## 4. Complete mechanism identification, demonstrated

The laboratory then closed its own loop under registration
(`05-oracle.mjs`) [computed]:

- **O1.** ORACLE out-predicts truncated descendant *count* in 10/10
  universes (r ≈ 0.44 vs 0.23).
- **O2.** With ORACLE added to the battery, the PC(0) cell effect
  vanishes exactly: Δ_ER = −0.004, t = −0.25 (from t = −10.2). The
  mechanism is *completely* identified — nothing residual remains for
  the partition to explain.
- **O3.** With exact **uncapped** descendant counts matched instead, the
  effect persists at t = −7.0. Volume of reach is not the structure;
  **concentration** of reach is, and only the harmonic weighting
  expresses it.

We know of no published matched-pair growth study that identifies the
complete mechanism of its own effect in closed form and then
demonstrates extinction-by-matching. The loop is available to any study
with a generative model of its domain: derive what the model rewards,
express it as a baseline feature, and aim it at your own result.

## 5. The field demonstration: five batteries, four kills

The method's field trial was a registered program on real dependency
corpora, run at full adversarial volume (primary sources:
`debian-study/`, `battery-v2/`–`battery-v5/`; narrative account:
`preprints/seedbed/paper.md`). In brief [all computed]:

| Generation | Knife added | Origin | Outcome |
|---|---|---|---|
| v1 | fine-grain degree, out, age, PageRank, k-core | reviewer's arsenal | killed crates.io (+15.7 → popularity); Debian sealed bet landed (+0.098) |
| v2 | truncated up-set size | flux law (§3) | killed Go E-over-R (+0.22 → up-set imbalance, unrepairable); Debian held |
| v3 | ORACLE | mechanism (§4) | killed Go E-over-D (+0.152 → +0.018); Debian held |
| v4 | momentum (prior-interval gain) | standard autoregressive control | Debian held (+0.083; marginal contribution +0.002) |
| v5 | functional role (archive Section, exact stratum) | institutional metadata | **killed Debian** (+0.083 → −0.076; within-role null-to-negative, reversal javascript-dominated) |

Two lessons carry beyond the program. First, the theory-derived knives
(v2, v3) killed effects that had survived everything a reviewer would
ask for — derived confounds are sharper than guessed ones. Second, the
fatal covariate for the final claim was *not a function of the graph*:
package role lives in archive metadata, and the audit of §2 — which
certifies the estimator against structural confounds on generators —
is constitutionally silent about covariates outside the object the
generator produces. A matched-pair estimate stable under any number of
structural controls is evidence only about the controls you have. The
program's blind pre-check protocol surfaced the danger before the run
(role imbalance leaned *with* the deflating story, the first knife to do
so), the registration fixed the kill condition before the verdict, and
the claim's obituary was published at the volume its survival would have
received, the same day.

## 6. The checklist

For any matched-pair growth study on an evolving network, we commit to
and recommend:

1. **Replicate-first for anything with a generator.** The universe is
   the unit of inference. Single-universe percentiles on synthetic data
   are not evidence.
2. **For single-history corpora:** percentiles as conditional statements
   only; warrant from independent-corpus replication and sealed
   directional bets registered before first measurement.
3. **Battery contents, from generation one:** the standard arsenal,
   *plus* truncated up-set size, *plus* ORACLE (both pure graph
   features, cheap at cap 200), *plus* the node's own prior-interval
   gain, *plus* every available non-structural covariate of node kind
   (role taxonomies, categories, institutional metadata) — the last as
   exact strata, not z-features, where cardinality permits.
4. **Blind pre-checks** (balance and composition audits touching no
   outcomes) before every registered run; publish them with the run.
5. **Interpretation tables fixed before execution**, including what
   kills the claim; single scored run per registration; kills reported
   at the volume of wins.
6. **If a generative model of the domain exists, derive its reward
   functional and aim it at your own result** before anyone else does.

## 7. Reproducibility

Every number above cites a registration committed before its single
scored run; seeds are constants in the scripts; raw outputs are committed
beside them. Laboratory chain: `accretion-study/SPEC.md` →
`01-explore.mjs` → `01b-calibrate.mjs` → `01c-validate-clustered-null.mjs`
→ `02-confirm.mjs` → `THEORY.md` → `SPEC-D.md` → `03-sign.mjs` →
`04-explore-d.mjs` → `05-oracle.mjs`. Field chain: see
`preprints/seedbed/paper.md` §8. Repository:
github.com/thefalsework/papers.

**Disclosure.** Drafting was AI-assisted under direction; the grades are
the author's warrant.
