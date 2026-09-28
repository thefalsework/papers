# Study spec: Does a checker move valid outputs beyond ordinary newness?

**Draft committed 2026-09-28. NOT REGISTERED.** Registration is a later
commit, after the literature check in Step 0, and is identified by that
commit's hash. Until then this file may be edited; after it, changes go
in a dated postscript.

## Status and framing

This is a pre-registration draft. It is not registered until committed
to the papers repo with a hash, after the literature check in Step 0.

The study asks one empirical question about generative models and
checkers. It does not apply the four-position theorem to a transformer.
Zones here are defined by an estimated closing of the training set in a
registered embedding. The partition appears only in the reading
paragraph near the end.

Prior work it follows: the ReLU phantom-mass pilot
(`phantom-study/SPEC.md`; 80 runs: 2 datasets × 4 depths × 10 seeds;
registered kill fired; remainder at or below about 0.1% at data scale;
depth effect survived). That pilot measured decision regions of
classifiers. This study measures where generated outputs land relative
to training data.

Terminology: morphological closing is a closure operator used here as
an estimator of the double-negation nucleus on open sets. It is not
itself a nucleus.

## Question and hypotheses

**Registered question:** does a checker move valid outputs further out
than ordinary newness does?

### Definitions

- **Valid:** the proof term type-checks against its prompt formula.
- **Novel:** the proof term, in eta-long, alpha-normalized form, is not
  identical to any training proof term, whatever formula either proves.
  A training term reused for a new formula is not novel.
- **Zones** (per embedding, defined in the Embeddings section):
  *inside* (within radius r of a training point), *crack* (in the
  estimated closing but not inside), *exterior* (outside the estimated
  closing).
- **Base rate:** the zone distribution of held-out proofs, which stand
  in for ordinary newness.

### Hypotheses

**H1 (primary).** Among valid novel outputs, the exterior fraction under
checker-guided search exceeds the held-out base rate. The difference's
95% bootstrap CI must exclude zero. Exterior means exterior in both
embeddings.

**H1 contrast (reported, same test):** guided (C3) vs filtered (C2).
C2 is the valid subset of the unguided samples, so this single contrast
is the search-versus-selection comparison: C2 is selection at C1's
budget, C3 is search at the same budget.

**H1m (matched, co-reported).** On prompts solved by both guided and
unguided sampling, the guided exterior fraction exceeds the unguided
one. If H1 holds and H1m does not, the claim is limited to: the checker
reaches new problems, not new solutions to the same problems.

**H2.** Unguided valid novel outputs have a higher crack fraction than
the grammar null.

**H3 (secondary, the generative version of Levin problem 3).** Among
raw unguided samples, the invalid rate is enriched in cracks relative
to the overall invalid rate. Registered expectation: invalid outputs
are enriched in the exterior at least as strongly as in cracks. Both
enrichments are reported. H3 zones are computed only for invalid
samples that parse (well-formed but ill-typed), so that E1 and E2 are
computed on the same population; the unparseable fraction of raw
samples is reported separately.

## Step 0: literature check

No registration until this is done. The deliverable is a short
related-work note committed beside the spec.

**Status (2026-09-28): done.** See `RELATED-WORK.md`. Verdict: the
reframing condition below is not met; no located work places
checker-accepted outputs relative to training geometry against a
held-out base rate. Nearest precedents, to be cited and
distinguished: Meehan, Chaudhuri, Dasgupta (2020) for the base-rate
logic; Li, Tian et al. (arXiv:2604.18587) for guided-vs-unguided
distribution shift; Mendoza-Smith (arXiv:2606.28572) for containment
relative to a train-only encoder; Somani (arXiv:2607.16997) for
"conditional on success, was the route standard." One edit made as a
result: the Meehan statistic added to the always-reported list.

Areas to search:

- Interpolation vs extrapolation in high dimension (Balestriero,
  Pesenti and LeCun, 2021) and follow-ups. This is the main threat to
  measurable zones.
- Topological data analysis of neural representations: holes and gaps
  in data manifolds.
- Neural theorem proving with checkers (GPT-f, LeanDojo,
  DeepSeek-Prover, AlphaProof) and evaluator-guided search (FunSearch,
  AlphaEvolve).
- Novelty and memorization measures for generative models.
- Any work placing verifier-accepted samples relative to training-data
  geometry.

Decision rule: if published work already measures where
verifier-accepted outputs sit relative to training geometry, reframe
this study as a replication with a closing-based extension before
registering.

## Domain and checker

The domain is proofs in intuitionistic propositional logic, written as
typed lambda terms. It is chosen for one design reason: the checker is
exact, so "valid" means valid. Unit tests on programs would admit false
positives.

- **Fragment:** implication, conjunction, disjunction and falsum, over
  atoms p1 to p6.
- **Terms:** lambda, application, pairs and projections, injections and
  case, and abort. Proofs are stored in beta-normal, eta-long form, so
  eta-equivalent proofs count as duplicates.
- **Checker:** a bidirectional type-checker in Python. It also checks
  well-typed prefixes, which guided search needs.
- **Generator:** random well-typed term generation with term depth at
  most 10 and formula size 3 to 20 symbols (atoms plus connectives).
  Each term yields a (formula, proof) pair.
- **Cross-check (gate):** translate 1,000 random valid terms and 1,000
  mutated invalid terms (at least half well-formed but ill-typed, not
  parse errors) into Lean as `example : T := term`. The Python checker
  and Lean must agree on all 2,000. Any disagreement stops the study
  until fixed.

## Corpus

Three disjoint sets, all from the same generator, all with fixed seeds
recorded in the spec.

| Set          | Size (main)     | Size (feasibility) | Role                                         |
|--------------|-----------------|--------------------|----------------------------------------------|
| Training     | 100,000 pairs   | 5,000 pairs        | Defines the region U                         |
| Held-out     | 5,000 pairs     | 1,000 pairs        | Base rate for ordinary newness; calibration  |
| Test prompts | 2,000 formulas  | none               | Prompts for the four conditions              |

- **Disjointness:** no formula appears in more than one set.
- **Deduplication:** proofs deduplicated after alpha-normalization in
  eta-long form; formulas after atom-order canonicalization.
- **Stratification:** all sets stratified by formula size, so size
  bands are comparable across sets.

## Model and training

A small decoder-only transformer trained from scratch, so the training
data is known exactly.

| Setting                 | Main                          | Feasibility  |
|-------------------------|-------------------------------|--------------|
| Layers × width × heads  | 6 × 256 × 8                   | 4 × 128 × 4  |
| Parameters              | about 5M                      | about 1M     |
| Input format            | formula, separator, proof     | same         |
| Tokenization            | term-syntax tokens            | same         |
| Stopping                | best validation loss on a 2% slice of training | same |
| Seeds                   | 3                             | 1            |

- **Starting code:** nanoGPT or equivalent minimal implementation.
- **Minimum competence:** at least 20% of unguided samples on test
  prompts must be valid. Below that, scale the model or data before the
  main runs; the threshold is not an outcome measure.
- **Seeds:** every main result is reported per seed. A claim requires
  the same direction in all three.

## Embeddings and zones

Zones are computed separately in two embeddings. H1 counts an output as
exterior only if it is exterior in both.

### Embeddings

- **E1, model:** final-layer hidden states, mean-pooled over the proof
  tokens (formula tokens given as context, not pooled). Computed with
  the seed's own model.
- **E2, structural:** counts of each term constructor, term depth and
  size, and formula features (atoms, connectives, depth).
- **Reduction:** standardize, then PCA fitted on the training set only.
  Registered dimension d = 16; sensitivity runs at d = 8 and d = 32.

### Zones at radius r (in the reduced space)

1. U is the union of balls of radius r around training points.
2. The estimated closing C is the closing of U by a ball of radius r:
   dilate U by r (the 2r-dilation of the training set), then erode by
   r. So p is in C if every point of the ball of radius r around p lies
   within 2r of some training point. Closing is extensive, so U lies
   inside C and the zones nest.
3. The containment test is Monte Carlo: p plus 256 points sampled
   uniformly in the ball of radius r around p (throughout the ball, not
   only its surface), each checked by nearest-neighbour query. The test
   can err only one way: a missed gap makes the ball look contained and
   puts p in C. That inflates cracks and deflates exterior in every
   condition, so it favours surviving K2. The bias has the same sign in
   every condition but is not guaranteed equal in size, so it can move
   H1 either way. If K2 survives narrowly or H1 passes narrowly, a
   rerun at 1,024 samples is reported.
4. Inside: within r of a training point. Crack: in C but not inside.
   Exterior: not in C.

### Calibration of r

- **Primary rule:** choose r so that 50% of held-out proofs are inside
  or in a crack, in each embedding separately. B's exterior fraction is
  then 50% in each embedding by construction; H1 uses B's joint
  (both-embedding) exterior fraction, which is lower.
- **Alternative rule (registered):** r equals the 90th percentile of
  nearest-neighbour distances among training points.
- Results are reported under both rules. A conclusion that holds under
  only one rule is reported as rule-dependent.

**Agreement:** Cohen's kappa between E1 and E2 zone assignments is
reported for held-out proofs and separately for each condition.
Enumerated proofs (C4) may sit where E1 is least reliable.

## Conditions

All conditions use the same 2,000 test prompts. Compute is matched by
the number of tokens the model generates per prompt.

| Condition       | What it does | Budget per prompt |
|-----------------|--------------|-------------------|
| C1 Unguided     | Sample 64 proofs at temperature 1.0 (sensitivity: 0.7) | 64 samples |
| C2 Filtered     | C1's samples, keeping only valid ones | same as C1 |
| C3 Guided       | Type-directed search at temperature 1.0 (sensitivity: 0.7), matching C1: prune partial terms that fail the prefix check, backtrack, repair | exactly C1's token total; search stops when it is spent and reports all distinct valid completions |
| C4 Grammar null | Valid proofs of the same formulas by bounded enumeration, size distribution matched to C1's valid outputs within size tertiles; no model | no model |
| B Base rate     | Held-out proofs | fixed set |

- C2 is the valid subset of C1. There is no separate "unguided-valid"
  arm; C2 is that set. C2 versus C3 separates selecting valid outputs
  from searching for them.
- C4 is the null for H2: where valid proofs land when no model is
  involved.

## Measures and analysis

The unit of analysis is the prompt. Each prompt contributes the zone
fractions of its unique valid novel outputs, so prompts with many
outputs don't dominate. A prompt enters a contrast only if every arm in
it has at least one unique valid novel output. B's unit is the held-out
formula, and the entry rule does not apply to B.

**Primary (H1):** joint exterior fraction in C3 minus joint exterior
fraction in B. 95% CI by bootstrap over prompts (10,000 resamples). The
contrast C3 − C2 uses the same method.

**Matched (H1m):** restricted to prompts where both C1 and C3 produced
at least one valid novel proof.

**Length control:** proof-size tertiles, with boundaries fixed once on
the held-out set and applied to every condition, including C4's
matching. H1 is called robust only if the difference is positive (point
estimate) in at least two of three bands; the CI requirement applies
only to the pooled H1.

**H2:** crack fraction of C1 valid novel outputs minus crack fraction of
C4, computed within size tertiles, same bootstrap.

**H3:** among raw C1 samples that parse, invalid rate by zone divided by
the overall invalid rate (over parseable samples), with bootstrap CIs.
The unparseable fraction is reported alongside.

**Always reported:** the full distributions of nearest-training-point
distance per condition, zone fractions under both calibration rules and
all three PCA dimensions, per-seed results, and the Meehan et al.
(2020) data-copying statistic Z_U (z-scored Mann–Whitney U on
nearest-training-point distances, each condition against B, in each
embedding). Z_U is descriptive; it carries no hypothesis.

**Reporting rule:** every number in the postscript is taken from the
results JSON, never from prose.

## Kill conditions and decision rules

| Code    | Condition | Consequence |
|---------|-----------|-------------|
| K-check | Python checker and Lean disagree on any of the 2,000 cross-check terms | Stop; fix the checker before any run |
| K2      | There is an embedding in which the held-out crack fraction is below 5% under both calibration rules (cracks too thin to measure) | Zones unmeasurable; stop; report as analogous to the ReLU pilot's vanishing remainder. Firing under one rule only: rule-dependent, descriptive |
| K-agree | Cohen's kappa between E1 and E2 below 0.2 on held-out proofs | Zone results descriptive only; no H1 claim |
| K1      | 95% CI of C3 − B joint exterior difference includes zero or is negative | H1 dead |
| K1m     | H1 holds but H1m's CI includes zero | Claim limited to reaching new problems, not new solutions |
| K-H2    | C1 crack fraction not above C4's CI | H2 dead |

- A kill is reported in the postscript at the same prominence as a
  result.
- No hypothesis is added, dropped or reworded after registration.
  Changes go in a dated postscript.
- This spec contains no follow-up study. A search algorithm using the
  zones would be a separate spec, and only if K2 does not fire.

## Feasibility phase

The feasibility phase decides go or no-go before the main build. It
uses the small corpus and the 1M-parameter model, and it runs none of
the four conditions.

1. Run the checker cross-check (K-check).
2. Train the feasibility model, one seed.
3. Compute E1 and E2 for training and held-out proofs.
4. Calibrate r under both rules and compute held-out zone fractions.
5. Apply K2 and K-agree.
6. Check the model's valid rate: unguided sampling, 16 samples per
   formula, on 200 held-out formulas. A rate below 20% means scaling
   the model or data before the main build; it does not affect the K2
   or K-agree verdicts.

Output: a dated go/no-go note committed to the repo, with every number
from a results file. If K2 fires, the study ends here and the note is
the report.

## Reading (not a registered claim)

[A] In the Heyting algebra of open sets, double negation is interior of
closure: it fills gaps a region surrounds but does not cover. The crack
zone is an estimate of that remainder for the training region, and the
exterior is what lies beyond it. Read in partition terms, cracks
correspond to the Exploitation cell and the exterior to ground the
training data does not force.

[A] On this reading, a checker is what lets search cross ground nothing
in the model forces, in the spirit of Markov's principle: where
candidates can be checked, "cannot fail to exist" becomes construction
by search.

None of this is tested here. The zones are computed in a PCA-reduced
embedding, which is not the algebra, and closing is an estimator, not a
nucleus. The study stands or falls on the registered question alone.

## Scope, hardware, sequence and deliverables

**Out of scope:** search algorithms that use the zones as an objective;
retraining on verified outputs; human checkers; large pretrained
models; anything sent to Levin's group.

**Hardware:** generator, checker and zone analysis run on an ordinary
CPU. Training needs a GPU: a home card (Pascal-generation cards need
the PyTorch build for CUDA 12.6) or a rented cloud GPU. Estimated cost:
under a dollar per run at home, a few dollars per run in the cloud.

**Sequence** (each step gates the next):

1. Literature check and related-work note.
2. Register this spec (commit hash).
3. Build the generator and checker; pass K-check.
4. Feasibility phase; go/no-go note.
5. Build the main corpus; train three seeds.
6. Run the four conditions and the base rate.
7. Analysis and dated postscript with verdicts.

**Deliverables:** the registered spec, code, seeds and corpora, the
results JSON, the feasibility note, and the postscript.
