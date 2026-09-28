# Checker study: Step 0 related-work note

**Date: 2026-09-28.** Written before registration of `SPEC.md`, as the
spec requires. Method: web search across the five registered areas
plus one decisive query ("verifier-accepted outputs relative to
training geometry"), reading abstracts and method sections of the
closest hits. This is a scoped check, not a systematic review. Items
are cited by arXiv identifier where that is all that was verified;
several are 2026 preprints and may change.

## Decision

The spec's decision rule: *if published work already measures where
verifier-accepted outputs sit relative to training-data geometry,
reframe as a replication with a closing-based extension.*

**Finding: the reframing condition is not met.** No located work
places checker-accepted generated outputs in zones relative to the
training set, against a held-out base rate, with a search-versus-
selection contrast. Three works come close on one axis each and must
be cited and distinguished (section 3). One older work (Meehan et al.
2020) supplies the exact logic of the base-rate comparison and the
spec must name it as the ancestor of H1's C3 − B test.

**One spec edit made before registration as a result of this note:**
the Meehan data-copying statistic (Mann–Whitney on nearest-
training-point distances, each condition against B) is added to the
"always reported" list. It is descriptive, not a hypothesis.

## 1. Interpolation vs extrapolation in high dimension

- **Balestriero, Pesenti, LeCun (2021)**, *Learning in High Dimension
  Always Amounts to Extrapolation*, arXiv:2110.09485. Interpolation
  defined as convex-hull membership. Theorem and experiments: to keep
  new samples inside the hull, dataset size must grow exponentially in
  d*, the dimension of the smallest affine subspace containing the
  data, regardless of intrinsic manifold dimension. Above ~100
  ambient dimensions, test points are essentially never inside.
  **Bearing on the spec:** this is the threat K2 guards against. The
  spec's zones are not convex-hull membership; they are r-ball
  neighbourhoods and their closing, in a d = 16 PCA space. The
  exponential-in-d* argument still applies to whether a fixed r
  captures held-out points, which is why r is calibrated on held-out
  data rather than fixed a priori.
- **Bonnasse-Gahot (2022)**, sole author, *Interpolation,
  extrapolation, and local generalization in common neural networks*,
  arXiv:2207.08648. Reply to the above: in the low-dimensional
  intrinsic space of the last hidden layer (recovered by an
  autoencoder), most test points *are* inside the training hull, and
  proximity-to-training measures relate to accuracy better than hull
  membership does. **Bearing:** direct support for the spec's design
  choice (reduce, then measure proximity) and the source to cite when
  a reviewer raises Balestriero. Their reduction is a learned
  autoencoder; the spec's is PCA, registered for simplicity, with d
  sensitivity runs.
- Reproduction: SMHendryx (2022) GitHub reproduction on MNIST finds
  hull-membership near zero by embedding dimension ~30. Consistent
  with the spec's choice of d = 16 and the d = 32 sensitivity run
  being the one most likely to lose cracks.

## 2. Topological data analysis of neural representations

- **Wheeler, Bouza, Bubenik (2021)**, *Activation Landscapes as a
  Topological Summary of Neural Network Performance*,
  arXiv:2110.10136. Persistent homology of per-layer activations,
  summarised as persistence landscapes; topological complexity
  correlates with accuracy and does not decrease layer by layer.
- **Purvine et al. (2023)**, *Experimental Observations of the Topology
  of Convolutional Neural Network Activations* (AAAI). PH distances
  between layers; mapper graphs of class organisation.
- **Athreya and Rosen (2025)**, *HOLE: Homological Observation of
  Latent Embeddings*, arXiv:2512.07988. PH on latent embeddings for
  interpretability, without dimension reduction.
- **Higham and coauthors**, *On the hidden layer-to-layer topology of
  the representations of reality* (Edinburgh preprint P172). H1
  cycles in hidden-layer point clouds; prominence via log(death/birth).

**Bearing:** these detect holes in a point cloud by Vietoris–Rips
filtration over a scale parameter, which is the same union-of-balls
construction as the spec's U at radius r. Persistent H1 features at
scale r are cycles around gaps; the spec's *cracks* are gaps of a
particular kind (those a ball of radius r fits into but which are
covered at 2r). The two are not the same object: PH counts
independent cycles, closing measures the volume of enclosed
remainder and assigns individual points to it. Distinguish in the
paper; a PH barcode of the training set at the calibrated r is a
cheap descriptive to include.

## 3. Checkers, search, and novelty of proofs (the decisive area)

Closest on the "verifier-accepted vs training geometry" axis:

- **Li, Tian, Wang (Tsinghua, 2026)**, *Compile to Compress: Boosting
  Formal Theorem Provers by Compiler Outputs*, arXiv:2604.18587.
  Tests whether compiler-conditioned refinement produces a different
  distribution over Lean programs than unconditioned generation, via
  an energy two-sample test on string edit distance. Also notes that
  the distribution of failed attempts drifts under refinement, and
  uses expert iteration on refinement trajectories. **Distinction:**
  this compares the model's guided and unguided outputs *with each
  other*, not with the training set, and has no base rate. It is the
  nearest published version of the spec's C3-vs-C1 contrast. Cite as
  the precedent that checker feedback changes the output
  distribution; the spec asks *where* it moves relative to training.
- **Mendoza-Smith (2026)**, *Geometric Measurements of the Axiom of
  Choice in Neural Proof Embeddings*, arXiv:2606.28572. Trains a
  denoising encoder on constructive Mathlib proofs only, then
  measures classical proofs by k-NN distance to training proofs,
  reconstruction loss, and containment in density superlevel sets
  (43% of shallow-boundary classical proofs fall outside the
  constructive 90% region; effect decays with dependency depth).
  **Distinction:** the geometry-relative-to-training-only-encoder is
  the spec's E1 idea, and superlevel-set containment is a one-zone
  inside/outside partition. But the objects are human library proofs
  partitioned by axiom dependence, not model outputs, and there is no
  checker condition. Cite for the measurement idiom (train-only
  encoder, containment fraction) and the mean-pooled hidden-state
  embedding, which matches E1.
- **Somani (2026)**, *PriorProof: A Point-in-Time Measure of Technique
  Novelty for Formal Proofs*, arXiv:2607.16997. Scores a checked
  Lean proof by the surprisal of its dependency-family footprint
  against the library as it stood at a date; explicitly "conditional
  on success, did the model recover a standard route." Proposes
  scoring human vs model vs search-variant proofs of the same theorem
  as the natural downstream experiment. **Distinction:** novelty is
  library-footprint surprisal, not embedding geometry; no training
  set of a from-scratch model; the downstream experiment is proposed,
  not run. This is the closest statement of the spec's H1m question
  in the literature. Cite and say the spec runs a small controlled
  version of the experiment PriorProof proposes.

Adjacent:

- **Porto (2026)**, *Beyond Correctness: Toward Automated Novelty
  Verification with Lean 4*, arXiv:2608.14669. Pipeline for
  novelty verdicts on formalised statements: corpus retrieval,
  non-triviality by automation, Jaccard distance over premise sets.
  Novelty of *statements* against a library, not outputs against
  training data.
- **Patel, Rammal, Hayat, Munos, Kempe (FAIR, 2026)**, *Learning to
  Discover Interesting Mathematics*, arXiv:2609.28603. Defines a
  theorem's interestingness as proof length over statement length,
  shows it tracks downstream utility, and post-trains a 27B model to
  predict premise-conditioned proof difficulty. Post-training a
  conjecturer on this metric (§3.3) cuts substantial-or-full mathlib
  overlap of generated statements from 91.9% to 30.6%. Separately
  (§3.4), an inference-time discovery loop grows a premise set
  P0 ⊂ P1 ⊂ … ⊂ PN over six rounds from 80 graph-theory premises,
  promoting ten verified statements per round under four rules, with
  frozen weights. **Bearing:** the §3.4 loop is a premise-growth
  version of the canonization idea the spec puts out of scope, but it
  is small (six rounds) and does not retrain; the overlap reduction
  is a training effect on the conjecturer, not a loop effect. Cite
  for the mathlib-containment measure of out-of-distribution
  statements and for the loop's existence; do not cite it as
  retraining-on-verified-outputs at scale.
- **DeepMind (2026)**, *Advancing Mathematics Research with AI-Driven
  Formal Proof Search*, arXiv:2605.22763. AlphaEvolve-style
  evolutionary agents for formal proofs; notes the mismatch between
  graded fitness and binary verification. Success-rate framing only.
- **FunSearch**: Romera-Paredes et al., Nature 2024. States
  explicitly that theorem proving falls outside its scope for lack of
  a rich scoring signal. **AlphaEvolve**: Novikov et al. 2025.
- Neural provers, for the standard citations: GPT-f (Polu and
  Sutskever 2020), expert iteration (Polu et al. 2022), LeanDojo
  (Yang et al. 2023; its novel-premises split is a distribution-shift
  evaluation, not a geometric one), DeepSeek-Prover (Xin et al.
  2024), AlphaProof (Hubert et al. 2025), STaR (Zelikman et al.
  2022). All measure success rates or transfer.
- Memorisation concern in LLM proof synthesis: the FSCQ case study
  (2025) uses normalised Levenshtein distance to argue generated
  proofs are not verbatim copies and states that the true test would
  need a model pretrained from scratch on a controlled corpus. The
  spec does exactly that.
- OOD detection in mathematical reasoning: TV Score (NeurIPS 2024,
  trajectory volatility) and Mahalanobis-on-embedding baselines.
  Relevant if E1 zone assignments prove unstable; not a competitor.

## 4. Memorisation and novelty measures for generative models

- **Meehan, Chaudhuri, Dasgupta (2020)**, *A Non-Parametric Test to
  Detect Data-Copying in Generative Models* (AISTATS). Three-sample
  test: nearest-neighbour distance to the training set for generated
  samples vs held-out samples, Mann–Whitney U, z-scored (Z_U ≪ 0 is
  copying, ≫ 0 underfitting). Distances taken in an embedding space.
  **Bearing: this is the ancestor of the spec's design.** The
  held-out base rate B, the nearest-training-point distance
  distributions, and the "more novel than ordinary newness" question
  are Meehan's logic. The spec adds (a) a three-zone partition of
  that distance axis via closing, so that "not near a training point"
  splits into enclosed and exterior, and (b) the checker conditions.
  The spec now reports Z_U per condition vs B as a descriptive.
- **Alaa et al. (2022)**, *How Faithful is your Synthetic Data?*
  (ICML). α-precision, β-recall, authenticity; authenticity is a
  sample-level copy test. Later work finds both CT and authenticity
  can confuse copying with mode shrinkage, which is a reason to
  report full distance distributions, as the spec does.
- n-gram novelty for language models: McCoy et al. (2023, RAVEN),
  Merrill, Smith, Elazar (2024, RUSTY-DAWG, EMNLP), and the
  originality-times-quality frontier of arXiv:2504.09389. All measure
  novelty as absence from training text; none place outputs
  geometrically or condition on a checker. The spec's "novel"
  definition (term not in training) is the exact-match end of this
  family.

## 5. What is new, stated for the paper

1. Zones by estimated closing (inside / crack / exterior) rather than
   a single distance threshold or hull membership. Nearest precedents
   are Mendoza-Smith's superlevel containment (one zone) and PH
   cycles (counts, not point assignment).
2. Verifier-accepted outputs placed relative to the training set of a
   from-scratch model, against a held-out base rate. Nearest
   precedents: Compile-to-Compress (guided vs unguided, no training
   reference), PriorProof (proposes the experiment, library-footprint
   metric), Meehan (base-rate logic, no checker).
3. Search vs selection at matched budget (C3 vs C2) as the mechanism
   split.
4. H3, invalid outputs by zone. No precedent located.

## 6. Corrections (2026-09-28, same day, external check of all six
## primary citations)

- Bonnasse-Gahot (arXiv:2207.08648) is sole author; "and Nadal" was
  an error, fixed above.
- Patel et al. (arXiv:2609.28603) was characterised as "the
  canonization loop at scale." Wrong: the loop is inference-time
  premise growth over six rounds with frozen weights, and the 91.9% →
  30.6% overlap figure is from post-training the conjecturer, not
  from the loop. Fixed above.
- Meehan et al. 2020 (arXiv:2004.05675), Li–Tian–Wang
  (arXiv:2604.18587), Mendoza-Smith (arXiv:2606.28572) and Somani
  (arXiv:2607.16997) confirmed as described.

## 7. Debts and gaps

- Not searched: rough-set boundary region and formal concept analysis
  as alternative names for the crack zone (program-level bridge, not
  needed for this spec).
- Not verified: exact venue and final author lists for the 2026
  preprints; cite by arXiv id until checked.
- A systematic review remains owed before any paper; this note
  clears the registration gate only.
