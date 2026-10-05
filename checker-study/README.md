# Checker study: does a checker move valid outputs beyond ordinary newness?

A small transformer (4.8M parameters) was trained from scratch on 100,000
proofs in intuitionistic propositional logic, written as typed lambda
terms, so that the training set is known exactly and the checker is exact.
The registered question: when a type-checker steers generation (pruning
refuted prefixes as the model writes), do the valid proofs it produces
land further from the training data than ordinary new proofs do? Zones
(inside / crack / exterior) are defined by an estimated morphological
closing of the training set in two embeddings; the base rate for
"ordinary newness" is the held-out proofs.

Registration `a04cb9e` (2026-09-28). Feasibility GO `4be68e3`
(`FEASIBILITY.md`). Code frozen at `bc3d688`; run at `d29d19e` (one
approved runtime-only exception, byte-identical output). Results committed
at `c723af4`. The authoritative record is `SPEC.md`, whose dated
postscripts carry every decision in order; this file is the report, and
every number in it is copied from `out/analysis-main-seed{0,1,2}-T{1,0.7}.json`,
`out/seeds-main-T{1,0.7}.json`, or `models/main/seed*.log.json`. Nothing
is from memory.

## Verdict

**H1 dead (K1) in all three seeds, at both temperatures.** Checker-guided
search (C3) puts its novel valid proofs in the joint exterior at 0.82–0.85;
term-novel held-out proofs sit at 0.83–0.85. The differences are
+0.002 / −0.007 / −0.011 at T = 1.0 and −0.002 / −0.003 / −0.016 at
T = 0.7, every 95% interval includes zero, and the sign is not even stable
across seeds. `claim_eligible.H1` is false at both temperatures.

**H1m (search vs. selection): no difference.** On matched prompts, guided
search and filtered unguided sampling land in the same place (differences
within ±0.007, intervals of width ~0.02 including zero). The checker finds
valid proofs faster; it does not find different ones. K1m is null because
K1 fired.

**H2 not claim-eligible.** Whether the model's valid outputs fill cracks
more than a model-free grammar enumerator does cannot be called: the
registered verdict is embedding-dependent / embedding-dependent / dead at
T = 1.0 and embedding-dependent / embedding-dependent / survives at
T = 0.7, dead everywhere under the alternative rule, with crack fractions
of 0.02–0.09 throughout. Any report of H2 carries the deviation below.

**H3 (descriptive, no kill) came out inverted.** The registered wording
expected invalid outputs to be enriched in the cracks. They are depleted
there by a factor of about ten (enrichment 0.07–0.17, every interval
below 1) and enriched in the exterior by about two (1.83–1.95, every
interval above 1.7), in both embeddings, every seed, both temperatures.
The registered expectation that exterior enrichment be at least as strong
as crack enrichment holds.

**Gates clear.** K-check 2,000/2,000 (`afff7e7`). On the main held-out
set K2 did not fire in any seed (crack fractions 0.16–0.19 primary,
0.09–0.11 alternative, both embeddings, threshold 0.05) and K-agree did
not fire (kappa 0.383 / 0.396 / 0.389, threshold 0.2).

**One deviation.** The registered 1,024-sample Monte Carlo rerun was
recommended in all six jobs, solely by the K-H2 trigger, and was not run,
for cost, by a decision taken after the 256-sample results had been seen.
Details in the Deviation section and in `SPEC.md`.

The result that decided H1 was registered the day before the run. Against
*all* 5,000 held-out proofs the difference would have been +0.44 to +0.47
with intervals nowhere near zero. The 2026-09-29 postscript restricted the
base rate to term-novel held-out proofs because a reused term is not
newness; that restriction turned a 45-point artefact into a null. It is
the single most important thing this study did.

## What was run

| | |
|---|---|
| Corpus | 100,000 training / 5,000 held-out / 2,000 test prompts, disjoint by canonical formula, stratified by formula size (corpus seed 20260928). 1,433 of the 5,000 held-out proofs are novel as terms. |
| Model | decoder-only transformer, 6 × 256 × 8, 4,772,352 parameters, block size 96, trained on 98,000 / validated on 2,000 (2% slice), early stopping on validation loss. Seeds 0 / 1 / 2: best val loss 0.1808 / 0.1780 / 0.1823 at epochs 12 / 15 / 13, 541 / 636 / 565 s each. |
| Conditions | C1 unguided (64 samples per prompt); C2 = C1's valid subset; C3 checker-guided constrained decoding at exactly C1's draw budget (matched on 2,000 / 2,000 prompts in every job, `c3_exhausted_root` 0); C4 model-free bounded enumeration size-matched to C2 within tertiles; B held-out. T = 1.0 registered, T = 0.7 sensitivity. |
| Competence | C1 valid rate 0.912 / 0.930 / 0.915 at T = 1.0 and 0.937 / 0.949 / 0.935 at T = 0.7, of 128,000 samples per job (floor 0.20). Unparseable 0.002 at T = 1.0, < 0.001 at T = 0.7. C1's valid outputs are term-novel 25–27% of the time (feasibility: 10.6%). |
| Zones | E1 = mean-pooled final-layer hidden states (seed's own model); E2 = 20 structural features. Standardize, PCA on training only, d = 16 (sensitivity 8, 32; E2 capped at 20). Closing by Monte Carlo containment, 256 ball samples per point. Primary calibration: 50% of held-out inside-or-crack per embedding; alternative: 90th percentile of training NN distance. |
| Analysis | unit = prompt; 10,000 bootstrap resamples over prompts; independent two-sample for H1, paired for H1m. |
| Hardware | one machine, 8× A100-SXM4-80GB, 2× EPYC 7J13 (240 cores). Python 3.10.12, PyTorch 2.14.0+cu130, NumPy 2.2.6, SciPy 1.15.3. Wall clock 15:19:34Z–22:13:01Z on 2026-09-30. |

## Gates on the main held-out set

Primary rule, d = 16. The radii depend only on the model, so both
temperatures share them.

| Seed | Held-out crack E1 primary / alt. | E2 primary / alt. | K2 | Kappa E1 vs E2 | K-agree |
|---|---|---|---|---|---|
| 0 | 0.193 / 0.097 | 0.179 / 0.086 | not fired | 0.383 | not fired |
| 1 | 0.192 / 0.105 | 0.177 / 0.086 | not fired | 0.396 | not fired |
| 2 | 0.161 / 0.105 | 0.178 / 0.086 | not fired | 0.389 | not fired |

Crack fractions roughly halved from feasibility (0.30 / 0.26 on 5,000
training points) to the main run (0.16–0.19 on 100,000). The closing finds
fewer gaps as the training set densifies; the crack construct is
scale-dependent.

## H1: checker-guided vs. ordinary newness

Joint-exterior fraction (exterior in both embeddings) of C3's novel valid
outputs, per-prompt averaged, minus that of the 1,433 term-novel held-out
proofs (B-novel). Primary rule, d = 16.

| T | Seed | C3 novel (n prompts) | B-novel | Difference [95% CI] | K1 |
|---|---|---|---|---|---|
| 1.0 | 0 | 0.847 (969) | 0.846 | +0.002 [−0.026, +0.029] | fired |
| 1.0 | 1 | 0.823 (967) | 0.829 | −0.007 [−0.034, +0.022] | fired |
| 1.0 | 2 | 0.840 (979) | 0.851 | −0.011 [−0.039, +0.016] | fired |
| 0.7 | 0 | 0.842 (944) | 0.844 | −0.002 [−0.030, +0.026] | fired |
| 0.7 | 1 | 0.826 (953) | 0.829 | −0.003 [−0.032, +0.025] | fired |
| 0.7 | 2 | 0.836 (971) | 0.852 | −0.016 [−0.044, +0.011] | fired |

With ~970 prompts and 1,433 base-rate proofs, the intervals are about
±0.028 wide. A few-point effect would have been seen. There is none.

**Against all held-out proofs (secondary descriptive).** B-all joint
exterior is 0.380 / 0.383 / 0.381; the difference is +0.467 [+0.443,
+0.491], +0.440 [+0.415, +0.465], +0.458 [+0.434, +0.482] at T = 1.0 and
+0.462, +0.443, +0.454 at T = 0.7. 3,567 of 5,000 held-out proofs are
identical as terms to a training proof and sit trivially inside the zone
model, while every C3 output counted is novel by construction. Comparing
against them would have measured the deduplication, not the checker.

**Length control.** Tertile bounds 5.0 / 8.0 on the 5,000 held-out
proofs. No novel term has size ≤ 5 in any seed, so the small band is empty
and robustness rests on two bands. Positive in both bands for seed 0 at
T = 1.0 (+0.027, +0.004) and seed 1 at T = 0.7 (+0.037, +0.001); in one
band or none otherwise. `agrees` false at both temperatures.

**Sensitivity in d** (primary, T = 1.0). d = 8: −0.023 [−0.053, +0.008],
−0.020 [−0.051, +0.011], −0.034 [−0.065, −0.004]; d = 32: +0.001 [−0.026,
+0.028], +0.004 [−0.024, +0.033], −0.009 [−0.036, +0.018]. K1 fires at
every d, seed and temperature; at d = 8 seed 2 the interval excludes zero
on the negative side.

**Rule dependence.** Under the alternative calibration rule K1 does not
fire in four of six jobs (T = 1.0 seed 2: +0.0044 [+0.0010, +0.0081];
T = 0.7 seeds 0 / 1 / 2: +0.0087 [+0.0049, +0.0127], +0.0062 [+0.0025,
+0.0099], +0.0057 [+0.0023, +0.0094]). That rule leaves 0.07–0.35% of
B-novel and 0.55–1.0% of C3's novel outputs in the exterior, and was
declared descriptive at feasibility (kappa 0.145 there; held-out crack
0.09–0.11 under it here).
Reported, not used.

## H1m: search vs. selection

On prompts where both C1 and C3 produced a valid novel proof, C3's joint
exterior minus C2's (C2 is C1's valid subset, so this is the only
search-versus-selection contrast; postscript item 7).

| T | Seed | n prompts | C3 | C2 | Difference [95% CI] |
|---|---|---|---|---|---|
| 1.0 | 0 | 950 | 0.846 | 0.840 | +0.006 [−0.004, +0.016] |
| 1.0 | 1 | 958 | 0.821 | 0.827 | −0.006 [−0.016, +0.004] |
| 1.0 | 2 | 965 | 0.838 | 0.845 | −0.006 [−0.015, +0.002] |
| 0.7 | 0 | 923 | 0.839 | 0.833 | +0.007 [−0.004, +0.017] |
| 0.7 | 1 | 935 | 0.822 | 0.821 | +0.002 [−0.009, +0.012] |
| 0.7 | 2 | 955 | 0.835 | 0.838 | −0.003 [−0.013, +0.005] |

K1m is null (not applicable) in every seed because K1 fired. Had H1 held,
the matched result would have limited the claim to "the checker reaches
new problems, not new solutions"; as it is, both are null.

## H2: do the model's valid outputs fill cracks more than a grammar null?

K-H2 per embedding on U4 (C4's novel outputs), primary rule, d = 16. C1's
crack fraction (parsed valid novel outputs, per-prompt averaged) against
C4's with its 95% interval. H2 survives only if it survives in both
embeddings.

| T | Seed | E1: C1 / C4 [CI] | E2: C1 / C4 [CI] | Verdict |
|---|---|---|---|---|
| 1.0 | 0 | 0.072 / 0.058 [0.046, 0.071] | 0.026 / 0.026 [0.017, 0.034] | embedding-dependent |
| 1.0 | 1 | 0.086 / 0.064 [0.051, 0.077] | 0.031 / 0.024 [0.016, 0.032] | embedding-dependent |
| 1.0 | 2 | 0.067 / 0.054 [0.043, 0.067] | 0.029 / 0.027 [0.018, 0.036] | dead |
| 0.7 | 0 | 0.075 / 0.059 [0.047, 0.072] | 0.032 / 0.025 [0.017, 0.034] | embedding-dependent |
| 0.7 | 1 | 0.090 / 0.067 [0.054, 0.081] | 0.029 / 0.023 [0.016, 0.032] | embedding-dependent |
| 0.7 | 2 | 0.069 / 0.053 [0.041, 0.065] | 0.034 / 0.023 [0.015, 0.031] | survives |

Prompts entering: 991 / 991 / 999 (T = 1.0), 978 / 974 / 991 (T = 0.7);
none dropped for lack of a common tertile. The descriptive difference
C1 − C4 is positive in every job in both embeddings (E1 +0.012 to +0.022,
E2 +0.000 to +0.012), but the registered verdict disagrees across seeds at
both temperatures and across embeddings within five of six jobs, and is
dead in both embeddings in all six jobs under the alternative rule.
`claim_eligible.H2` false. The honest sentence: at crack fractions of
0.02–0.09 this study cannot distinguish "the model preferentially fills
cracks" from "no effect".

## H3: where do the model's invalid outputs land?

Among parsed C1 samples (embedded as sampled, not normalized), invalid
rate by zone divided by the overall invalid rate. Primary rule, d = 16.
Overall invalid rate 0.086 / 0.068 / 0.084 (T = 1.0), 0.063 / 0.050 /
0.064 (T = 0.7).

| T | Seed | E1 inside / crack [CI] / exterior [CI] | E2 inside / crack [CI] / exterior [CI] |
|---|---|---|---|
| 1.0 | 0 | 0.011 / 0.098 [0.062, 0.142] / 1.896 [1.828, 1.970] | 0.103 / 0.165 [0.106, 0.246] / 1.827 [1.757, 1.901] |
| 1.0 | 1 | 0.014 / 0.106 [0.076, 0.142] / 1.920 [1.850, 1.994] | 0.132 / 0.146 [0.086, 0.226] / 1.835 [1.757, 1.918] |
| 1.0 | 2 | 0.016 / 0.099 [0.060, 0.148] / 1.923 [1.855, 1.999] | 0.062 / 0.153 [0.087, 0.239] / 1.861 [1.791, 1.933] |
| 0.7 | 0 | 0.005 / 0.095 [0.050, 0.153] / 1.912 [1.841, 1.988] | 0.096 / 0.159 [0.077, 0.270] / 1.842 [1.763, 1.922] |
| 0.7 | 1 | 0.009 / 0.070 [0.043, 0.103] / 1.947 [1.873, 2.024] | 0.134 / 0.120 [0.047, 0.222] / 1.857 [1.768, 1.950] |
| 0.7 | 2 | 0.006 / 0.078 [0.038, 0.131] / 1.943 [1.871, 2.019] | 0.032 / 0.139 [0.051, 0.252] / 1.894 [1.818, 1.975] |

In absolute terms (seed 0, T = 1.0, E1): invalid rate 0.1% inside, 0.8%
in the cracks, 16.3% in the exterior, where 52% of parsed outputs land.
The model is still right about 84% of the time in the exterior; it is
roughly twenty times more error-prone there than in the gaps between
training proofs. This is the only effect in the run that is large,
cross-embedding and stable across every seed and temperature. It was not
the registered expectation and is reported as a descriptive, post hoc
observation.

## Other descriptives

**Joint exterior by condition** (primary, d = 16, T = 1.0, seeds
0 / 1 / 2): B-novel 0.846 / 0.829 / 0.851; U2 (C1 novel) 0.889 / 0.872 /
0.906; U3 (C3 novel) 0.903 / 0.880 / 0.914; U4 (C4 novel) 0.936 / 0.927 /
0.942; C2-all 0.739 / 0.728 / 0.755; C4-all 0.788 / 0.781 / 0.794; C1
parsed 0.393 / 0.386 / 0.394. The model-free grammar enumerator's novel
outputs are more exterior than the checker-guided model's. Anything that
produces novel valid proofs lands outside the training region; the
enumerator does it most.

**Meehan Z_U** (z-scored Mann–Whitney on nearest-training distance, each
condition vs. B-novel; positive means farther from training than B-novel;
T = 1.0, E1 / E2): U3 +4.9 / +9.8, +4.9 / +9.4, +4.4 / +10.9; U4 +12.5 /
+11.7, +11.7 / +11.8, +11.3 / +12.3; U2 −0.7 / +4.9, +0.8 / +5.1, +0.8 /
+6.4; C2-all −11.2 / −7.4 and C1-parsed −32.8 / −34.3 (seed 0; these
include reused terms). By raw nearest-neighbour distance, C3's novel
outputs are farther from training than B-novel even though their zone
fractions are indistinguishable. Z_U carries no hypothesis; the zone test
is the registered measure.

**Novel-only kappa** is low, as `FEASIBILITY.md` anticipated: 0.10–0.16
on B-novel, 0.04–0.10 on U2 / U3 / U4 (vs. 0.38–0.40 on B-all). The two
embeddings agree on which outputs are copies and disagree on where the
novel ones sit.

**Run record.** C3 attempts that hit the per-attempt cap and restarted:
10,828 / 10,657 / 10,833 (T = 1.0), 10,623 / 10,501 / 10,710 (T = 0.7).
C4 shortfall 40 / 48 / 51 and 23 / 37 / 34 outputs per job, nearly all in
the top tertile; `node_cap` 0, `list_cap` 27–31 prompts, `max_count`
353–377 prompts. Seed 0's E1 primary radius differs between the two
temperature jobs in the seventh decimal (2.419725175 vs 2.419725624),
GPU floating-point non-determinism in the embedding; seeds 1 and 2 agree
to the last digit.

## Deviation: the 1,024-sample Monte Carlo rerun was not performed

`08-analysis` recommends the rerun in all six jobs. In every job the only
trigger is K-H2, in both embeddings: C4's crack interval has an upper
bound within 0.02 of C1's crack fraction. No H1 trigger and no K2 trigger
fired. The 0.02 tolerance was written for feasibility-scale crack
fractions (0.2–0.3); at 0.02–0.09, with the widest C4 interval spanning
0.027, it is met almost automatically. Monte Carlo noise in the closing
moves per-row labels, while H2's uncertainty is dominated by the
prompt-level bootstrap the intervals already report, and H2 is not
claim-eligible on the 256-sample results regardless. The 256-sample zones
stage took 10,492–11,959 s per job with six sharing the machine; the rerun
was estimated at 10–24 machine-hours, `run-main.sh` stopped (exit 3) for a
decision, and the author decided not to run it, for cost, on 2026-09-30
after the 256-sample results had been seen. All numbers in this file are
256-sample numbers.

## Reading (not a registered claim)

[A] `SPEC.md`'s reading paragraph cast the crack zone as an estimate of
the double-negation remainder, the exterior as ground the training data
does not force, and a checker as what lets search cross unforced ground.
That reading was firewalled from the registered test, and the firewall
holds. But if it had empirical content in this domain, H1 is what it
would have predicted, and H1 is null: the checker is a sieve, not a
vehicle. C3 lands where the model's own filtered draws land (H1m) and
where held-out novelty lands (H1), and a model-free enumerator lands
further out than either.

[A] H3 bears on a localisation claim made elsewhere in this repository
(the perceptron-bridge discussion; `wolfram/next-session.md`), which
identified the remainder with the hallucination locus. In this domain the
estimated remainder is the model's most reliable zone and its errors sit
in the exterior with its novelty. Novelty and error co-locate; neither is
in the cracks. The correction belongs in that discussion, not only here.

[A] The crack fraction halved between 5,000 and 100,000 training points.
Cracks are a feature of the training set at a scale; at some scale there
are none. This is how morphological closing behaves and is noted as
description, not as anything the framework predicted.

Scope: one 4.8M-parameter model, propositional logic, PCA-16 of two
embeddings, one checker. None of this touches the kernel-checked
mathematics in `lean/`, which was never at stake here.

## Files

- `SPEC.md` — registered spec and all dated postscripts (B-novel
  restriction, conditions parameters, review resolutions, runtime
  exception, main-run results and deviation). Canonical.
- `RELATED-WORK.md` — Step 0 literature check. `FEASIBILITY.md` — go/no-go
  note. `REVIEW.md`, `REVIEW-CLOSURE.md` — independent review of the
  analysis code against the spec, 22 items, closed before any main-run
  data.
- `ipl/` — generator, bidirectional checker with prefix checking, eta-long
  normaliser, Lean export, zone model. Frozen at `bc3d688` except the
  `workers=-1` exception.
- `01-crosscheck.py` … `09-seeds.py` — the pipeline in registered order.
- `out/crosscheck.{json,lean}` — K-check, 2,000 / 2,000.
  `out/feasibility-seed0.json`, `out/heldout-novelty-seed0.json` —
  feasibility phase. `out/conditions-feasibility-seed0-mechanics-*.json` —
  mechanics test on 20 fresh formulas (the `prune` file is the
  draw-then-prune accounting that was considered and not used).
- `out/analysis-main-seed{0,1,2}-T{1,0.7}.json` — per-job results, every
  setting (both rules × d = 8 / 16 / 32), gates, run record.
  `out/seeds-main-T{1,0.7}.json` — three-seed agreement and
  `claim_eligible`.
- `models/main/seed*.log.json`, `run/logs/` — training logs, placement,
  stage timings, per-job logs. `run/run-main.sh` — orchestration.
  `run/identity-check-workers.txt` — byte-identity check for the runtime
  exception.
- Not in git (regenerate from seeds, or see the archive manifest):
  `data/main/`, `models/main/seed*.pt` (19 MB each),
  `out/conditions-main-*.json` (~71 MB each), `out/zones-main-*.json`
  (~47 MB each). `archive/MANIFEST.sha256` lists the 57 archived files.

## Reproduction

Everything is seeded from the spec (corpus 20260928, zones 20260928 + d,
bootstrap 20260928; per-prompt SHA-256 streams for sampling), so outputs
do not depend on device, batch layout or prompt order
(`tests/test_batching.py`). Training needs a GPU; conditions and zones
are CPU-heavy (the zones stage used 240 cores).

```
python 01-crosscheck.py                       # K-check against Lean 4 core
python 02-corpus.py --profile main            # 100,000 / 5,000 / 2,000
bash run/run-main.sh                          # trains 3 seeds, runs 6 condition jobs, zones, analysis, seeds summary
```

`run-main.sh` refuses to start if any main-profile output exists, stops on
any job failure, and exits 3 at the Monte Carlo rerun check (as it did on
2026-09-30) when the rerun would exceed two hours. The individual stages
are `03-train.py`, `06-conditions.py`, `07-embed-zones.py`,
`08-analysis.py`, `09-seeds.py`, each with `--profile main --seed s
[--temperature T]`; `08-analysis.py` refuses `--n-boot` overrides on
registered runs.
