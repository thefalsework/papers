# Checker study: feasibility go/no-go note

**Date: 2026-09-28** (analysis ran 2026-09-29 01:00 UTC, i.e. the
evening of the 28th local time). **Registration commit: `a04cb9e`.**
Results file: `out/feasibility-seed0.json`; held-out novelty
descriptives (added 2026-09-29, see the postscript of the same date
in `SPEC.md`) from `out/heldout-novelty-seed0.json`. Every number
below is copied from one of those files, from the training log
`models/feasibility/seed0.log.json`, or from the version check
recorded at the end. Nothing is from memory.

## Verdict

**GO.** K2 did not fire in either embedding. K-agree did not fire
under the primary rule. The model's valid rate is 0.498, above the
0.20 competence floor, so no scaling is needed before the main build.

| Gate | Registered rule | Result | Fired |
|------|-----------------|--------|-------|
| K-check | Python checker and Lean must agree on 2,000 terms | 2,000/2,000 (`out/crosscheck.json`, commit `afff7e7`) | no |
| K2 | an embedding whose held-out crack fraction is below 0.05 under **both** rules | E1: 0.302 primary, 0.086 alternative; E2: 0.257 primary, 0.100 alternative | no |
| K-agree | Cohen's kappa E1 vs E2 on held-out below 0.2, primary rule, d = 16 | 0.330 | no |
| Valid rate | below 0.20 means scale up before main build | 0.498 (1,595 / 3,200) | no |

## What was run

- Corpus: feasibility profile, 5,000 training pairs, 1,000 held-out
  pairs (`n_train`, `n_heldout`).
- Model: seed 0, 4 layers × 128 width × 4 heads, block size 80,
  vocabulary 34, **807,936 parameters** (`n_params` in the training
  log; the spec's "about 1M" is rounded). Best validation loss
  0.6219 at epoch 25 (`model_val_loss` 0.6218546, `model_epoch` 25);
  early-stopped at epoch 31 with patience 6. Checkpoint committed at
  `b6489df`.
- Zones: PCA on training only; registered d = 16, sensitivity d = 8
  and d = 32; Monte Carlo containment with 256 ball samples per
  point (`n_mc`); zone seed 20260928; both calibration rules.
- Valid-rate check: 200 held-out formulas × 16 unguided samples at
  temperature 1.0 = 3,200 samples.
- Runtime: 790.3 s total on this laptop (embedding 22.4 s, sampling
  52.5 s, the rest is Monte Carlo containment), CPU, one thread.

## Zones on held-out proofs (registered d = 16)

Fractions inside / crack / exterior, from `heldout_zones`.

| Embedding | Rule | r | inside | crack | exterior |
|-----------|------|---|--------|-------|----------|
| E1 (model, raw dim 128) | primary | 3.030 | 0.203 | 0.302 | 0.495 |
| E1 | alternative | 5.735 | 0.914 | 0.086 | 0.000 |
| E2 (structural, raw dim 20) | primary | 1.038 | 0.247 | 0.257 | 0.496 |
| E2 | alternative | 2.645 | 0.880 | 0.100 | 0.020 |

Joint (both-embedding) exterior fraction of held-out proofs, which is
the B term in H1: **0.354 under the primary rule, 0.000 under the
alternative rule** (`heldout_joint_exterior`).

Cohen's kappa between E1 and E2 zone labels on held-out: **0.330
primary, 0.145 alternative** (`verdict.kappa`).

### Held-out novelty as terms (added 2026-09-29)

Found while writing this note, before any main-run outcome: the
corpus is split by canonical formula, not by proof term, so a
held-out proof can be identical as a term to a training proof. From
`out/heldout-novelty-seed0.json` (stored proofs are already in
eta-long normal form; re-normalising changed none):

- Training: 5,000 pairs, **2,500 distinct proof terms**.
- Held-out: 1,000 pairs, 653 distinct terms; **593 reused** (identical
  to a training term), **407 novel** under the spec's definition
  (40.7%).
- Novelty rate comparison: held-out proofs 40.7% novel; the model's
  valid unguided samples 10.6% novel (169 of 1,595).

By the postscript of 2026-09-29, H1's base rate B is the novel-only
subset; calibration and the gates above stay on the full held-out
set. The zone labels below are the same labels as the table above
(the script reproduces the run's radii and all-held-out fractions
exactly before reporting), split by subset, d = 16:

| Subset (n) | Rule | E1 inside/crack/ext | E2 inside/crack/ext | joint exterior | kappa |
|---|---|---|---|---|---|
| novel (407) | primary | 0.020 / 0.219 / 0.762 | 0.057 / 0.084 / 0.860 | **0.678** | 0.132 |
| novel (407) | alternative | 0.838 / 0.162 / 0.000 | 0.713 / 0.238 / 0.049 | 0.000 | 0.063 |
| reused (593) | primary | 0.329 / 0.359 / 0.312 | 0.378 / 0.376 / 0.246 | 0.132 | 0.225 |
| reused (593) | alternative | 0.966 / 0.034 / 0.000 | 0.995 / 0.005 / 0.000 | 0.000 | 0.079 |
| all (1,000) | primary | 0.203 / 0.302 / 0.495 | 0.247 / 0.257 / 0.496 | 0.354 | 0.330 |
| all (1,000) | alternative | 0.914 / 0.086 / 0.000 | 0.880 / 0.100 / 0.020 | 0.000 | 0.145 |

Two consequences, both descriptive:

- **B's joint exterior under the primary rule is 0.678 novel-only,
  against 0.354 over all held-out.** Reused terms sit mostly inside or
  in cracks, so excluding them raises the bar H1 must clear; the
  restriction works against H1, as the postscript's rationale
  intends.
- **E1/E2 agreement on the novel-only subset is kappa 0.132**, below
  the 0.2 that K-agree uses. The registered K-agree test is on all
  held-out proofs and passed at 0.330; the gate stands as computed.
  But the agreement that passed is carried largely by the reused
  proofs, and on the population B now uses the two embeddings
  disagree about zone assignment more than the threshold tolerates.
  This is the "K-agree most at risk" worry re-emerging on the
  relevant population, recorded now. Novel-only E2 crack under the
  primary rule is 0.084, thin.

### Sensitivity dimensions

| Embedding | d used | explained var. | primary inside/crack/ext | alternative inside/crack/ext |
|-----------|--------|----------------|--------------------------|------------------------------|
| E1 | 8  | 0.760 | 0.194 / 0.307 / 0.499 | 0.900 / 0.095 / 0.005 |
| E1 | 16 | 0.919 | 0.203 / 0.302 / 0.495 | 0.914 / 0.086 / 0.000 |
| E1 | 32 | 0.973 | 0.195 / 0.305 / 0.500 | 0.899 / 0.101 / 0.000 |
| E2 | 8  | 0.836 | 0.330 / 0.168 / 0.502 | 0.898 / 0.075 / 0.027 |
| E2 | 16 | 1.000 | 0.247 / 0.257 / 0.496 | 0.880 / 0.100 / 0.020 |
| E2 | 32 → 20 (capped, as registered) | 1.000 | 0.214 / 0.283 / 0.503 | 0.880 / 0.101 / 0.019 |

Crack fractions are above 0.05 at every dimension under the primary
rule and above 0.05 at every dimension under the alternative rule
too, so K2 would not have fired at any sensitivity setting either.

## Reading the numbers (descriptive; no threshold is touched)

1. **K2 margin.** The kill needs *both* rules below 0.05 in one
   embedding. Under the primary rule the cracks are 0.26 to 0.30,
   nowhere near the kill. Under the alternative rule alone they are
   0.086 (E1) and 0.100 (E2). The spec records that the Monte Carlo
   containment test can only inflate cracks, so the alternative-rule
   crack fractions are upper estimates. The registered 1,024-sample
   rerun clause is written for "K2 survives narrowly or H1 passes
   narrowly"; K2 did not survive narrowly, since the primary rule
   alone rules it out, so the clause is not triggered here. A
   1,024-sample rerun remains cheap (the containment step is the
   bulk of the 790 s) and would be a reasonable descriptive before
   the main build; it is recorded as optional, not required.
2. **The alternative rule leaves no exterior.** Held-out proofs are
   0.000 exterior in E1 and 0.020 in E2 under the alternative rule;
   joint exterior 0.000. In the main study, H1 under the alternative
   rule therefore reduces to whether guided search produces *any*
   joint-exterior outputs, and any conclusion that holds under only
   one rule is reported as rule-dependent, per the spec.
3. **K-agree under the alternative rule is 0.145**, below 0.2. The
   registered K-agree test is under the primary rule at d = 16 and
   is passed (0.330). But the alternative-rule agreement is weak,
   so alternative-rule zone results in the main study should be
   read as descriptive only. Recorded now so it is not a post-hoc
   reading later.
4. **Novelty among valid samples is low.** Of 3,200 unguided
   samples, 3,079 parsed (0.962), 1,595 were valid (0.498), and
   **169 were valid and novel** (a term not in the training set
   after normalisation), i.e. 10.6% of valid samples. 166 of 200
   formulas received at least one valid sample. H1's unit is the
   prompt's unique valid *novel* outputs, so the count of usable
   outputs per prompt in the main runs may be an order of magnitude
   below the valid count. This is a power consideration for the
   main build (64 samples × 2,000 prompts), not a kill; the spec
   sets no threshold on novelty and none is added. For comparison,
   40.7% of held-out proofs are novel as terms (section above): the
   model reuses training terms about four times as often as the
   generator does.
5. **E2 is rank-deficient.** Sixteen PCA components explain 1.000
   of E2's variance, so the d = 16 and d = 20 runs span the same
   space; the difference between their zone fractions (0.247 / 0.257
   / 0.496 vs 0.214 / 0.283 / 0.503) is Monte Carlo and calibration
   noise, and gives a rough scale for that noise (about three
   points).
6. **Meehan Z_U sanity reference** (held-out vs a random half of
   training, at d = 16): E1 0.025, E2 −0.581. Both near zero, as
   expected when the held-out set is drawn from the same generator
   as training; the statistic behaves.
7. **What the pre-registration debug run said, and what happened.**
   The status log recorded the subsample debug run's rough figures
   (primary ≈ 0.1 / 0.4 / 0.5, alternative ≈ 0.9 / 0.08 / 0.0,
   kappa ≈ 0.16, valid rate 0.20 on 10 formulas) and the guess that
   K-agree was the kill most at risk. The full run gives kappa
   0.330, so that guess was wrong in the safe direction; the zone
   shape under each rule is as the debug run suggested.

## Environment

- Machine: laptop, AMD Ryzen 5 7520U (reported as AMD64 Family 23
  Model 160), about 6 GB RAM, no GPU, CPU only, `--threads 1`.
- Python 3.13.7, PyTorch 2.14.0+cpu, NumPy 2.4.3, SciPy 1.18.1.
- Lean 4.30.0-rc2 core for the K-check (from `out/crosscheck.json`).

## Decision and next step

GO to the main build as specified: main corpus (100,000 / 5,000 /
2,000), 6 × 256 × 8 model (about 5M parameters), three seeds, then
the four conditions and the base rate. Before training starts, the
hardware is checked and a time estimate given; a Pascal-generation
card needs the PyTorch build for CUDA 12.6. No hypothesis, kill,
rule or threshold changes as a result of this note. One population
change, fixed by dated postscript before any main-run data: B is
the term-novel subset of held-out proofs (`SPEC.md`, postscript
2026-09-29); the main-run results must report the held-out novelty
count and B under both populations.
