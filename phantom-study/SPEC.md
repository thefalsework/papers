# Phantom mass in trained decision regions: registered spec

**Date registered: 2026-09-09.** Written before Phase 0 (literature
check) and before any code. Expectations E1'–E3 and kill conditions
K0–K3 are binding; deviations at execution time get a dated postscript.

## The question

`PerceptronRegular.lean` [K]: single threshold units are regular
(classical) elements of `Opens ℝⁿ`; composing them manufactures
ordinary (non-classical) regions, and the `¬¬`-remainder of the
composed region is the phantom — a locus the region confidently
misclassifies as inside, healed by double negation.
`CoApertureClosedForm.lean` [K]: on finite lattices the total phantom
mass over all observers has a closed form, and it is genuinely new
information relative to the aperture.

The open question flagged in the status note: **do real trained
decision regions carry substantial phantom mass?** If yes, that is a
measure of a network's confident-error zone derived from decision
geometry alone — no test set, no probability distribution.

## The instrument, and what it is not (registered up front)

At grid resolution ε, interior-of-closure is **morphological
closing**: rasterize the decision region, dilate by one cell, erode by
one cell; the closing residual `C_ε(U) \ U` is the phantom at that
resolution.

**Honesty note, promoted from the eventual paper to this spec at
review:** closing at resolution ε is *one* nucleus. The resolution
sweep is a one-parameter chain of nuclei out of an infinite lattice of
observers, chosen for computability. The instrument does not measure
the co-aperture; it samples a single family. A negative result
therefore means *this family sees nothing*, not that no observer does.
The eventual writeup, if any, is bound to this framing.

## Registered priors (the case against, written first)

1. **ReLU geometry.** ReLU networks partition input space into convex
   polytopes; the decision region is a finite union of them, glued
   along shared faces. This is exactly the composed-perceptron case,
   so the theory predicts phantom structure — but the phantom from
   face-gluing is **measure zero** (faces, walls, slits of zero
   width). The continuum-limit phantom mass of a ReLU decision region
   is plausibly always zero. What can be nonzero at data-relevant
   scales is *thin positive-width* structure: low-confidence corridors
   and pockets narrower than ε. The study lives or dies on whether
   such structure exists in trained nets, at scales that matter, in
   amounts that matter.

2. **The pockets rebuttal.** Szegedy et al. (2013) hypothesized
   adversarial examples live in low-probability "pockets" inside class
   regions. Subsequent work largely rebutted this: adversarial
   examples concentrate near decision boundaries, and class regions
   in trained nets appear topologically simple (connected, few holes)
   in several studies. This is evidence *against* substantial phantom
   mass and is the prior: **~30% that E1'–E3 all survive, probably
   generous.**

3. **Rasterization artifacts cut both ways.** A grid straddling a
   measure-zero face can manufacture phantom cells (spurious pass),
   and center-sampling can miss zero-width walls entirely (spurious
   fail). Hence the scaling and stability controls in E1'.

## Phase 0: literature check (kill-before-build)

Half a day. Four literatures, each a potential kill:

- **P0a.** Persistent homology / topology of decision boundaries
  (Ramamurthy et al. style). If closing residuals or healed decision
  regions have been measured, the study is redundant → K0.
- **P0b.** The adversarial-pockets thread and its rebuttals — extract
  the strongest quantitative anti-pocket result as the named prior.
- **P0c.** Linear-region counting (Montúfar et al. and successors) —
  what is known about how region complexity scales with depth at
  fixed accuracy; E2's competition.
- **P0d.** Connectivity of decision regions. If someone has *proved*
  decision regions are simply connected (or hole-free) under
  conditions our pilot nets satisfy, that is a kill **before**
  Phase 1, not after → K0.

**K0 (Phase 0 kill):** the measurement already exists, or a theorem
rules out the structure for our net class. Report and stop.

## Phase 1: the 2D pilot

Datasets: two-moons and two-spirals (generative ground truth known
exactly). Nets: fully-connected ReLU MLPs, depths {1, 2, 4, 8},
widths adjusted so all depths land in a fixed validation-accuracy band
(registered: 96% ± 1.5% on two-moons; spirals band set after a
calibration run, before the measurement runs, and logged). 10 seeds
per depth. Rasterization: cell is in U iff the net's decision at the
cell center is class 1. Closing: 3×3 structuring element (one cell —
the nucleus scale is tied to ε; this is the one-parameter family).

Resolutions: ε over ≥ 3 octaves, from ~4× median nearest-neighbor
distance of the training data down to ~ε*/8, where **ε\* = median
nearest-neighbor distance** is the registered "data scale."

Measured quantity: **p(ε)** = closing-residual cell count / region
cell count, per net, per resolution.

### E1' (existence with the scaling discipline — amended at review)

Phantom mass from measure-zero seams scales like the grid: its cell
count is boundary-like, so its *fraction* p(ε) vanishes linearly as
ε → 0. Genuine interior structure (positive-width slits, multi-scale
cracks) does not vanish that way. Therefore:

- Register the **full curve p(ε)** and the fitted exponent α in
  p(ε) ~ ε^α over the sweep, per depth.
- **E1' passes** iff p(ε*) ≥ 0.1% of region mass at some depth AND
  the fitted α is substantially below 1 (registered threshold:
  α ≤ 0.5) over at least the two finest octaves — i.e. the mass is
  not explained by grid-straddled faces alone.
- **Stability control:** phantom cells must persist in *location*
  under grid offset (re-rasterize at 4 random sub-cell offsets;
  registered: ≥ 50% of phantom area at ε* recurs within one cell
  radius in ≥ 3 of 4 offsets). Fails → K2.

### E2 (composition manufactures phantom)

The theorem says composition is the source of non-classicality.
Prediction: at matched accuracy, p(ε*) increases with depth.
Registered test: Spearman correlation between depth and per-seed
p(ε*) positive with permutation p < 0.05 across the 40 runs
(10 seeds × 4 depths), plus the seed-level distributions reported in
full (replicate-first house method — no within-run resampling nulls).

### E3 (error enrichment, distance-matched — amended at review)

Phantom cells are near boundaries and thin structures by
construction; error also concentrates there for reasons that have
nothing to do with phantoms. Enrichment relative to the region
average is therefore **not** the test. Registered test:

- For each phantom cell at ε*, match a non-phantom cell with the
  same predicted class in the same **distance-to-boundary decile**
  (deciles computed over the region's cells; distance = Euclidean
  distance to the rasterized decision boundary).
- Compare generative-truth error rates: phantom vs matched control.
- **E3 passes** iff phantom error rate exceeds matched-control error
  rate at every depth where E1' mass exists, pooled across seeds,
  with a registered margin ≥ 5 percentage points.
- If enrichment appears unmatched but vanishes under matching, the
  registered conclusion is: *phantom is boundary proximity wearing a
  costume* → K3, descriptive result only.

### Kill conditions (binding)

- **K0** — Phase 0: measurement exists or theorem forecloses it.
- **K1** — p(ε*) < 0.1% at all depths: trained nets carry no phantom
  at data scale; thread dead, finding reported as such.
- **K2** — phantom fails the grid-offset stability control:
  rasterization artifact; thread dead.
- **K3** — E3 fails under distance matching: no error signal beyond
  boundary proximity; E1'/E2 may still stand as descriptive geometry,
  but the "confident-error measure" framing is dead and the writeup,
  if any, must not use it.

## Phase 0 postscript (2026-09-09, before any pilot code)

Verdict: **no K0 — proceed**, with one sharpening and one amendment.

- **P0a.** The TDA-of-decision-boundaries line (Ramamurthy et al. 2019,
  ICML; Li et al. 2020, NeurIPS) infers *homology* of the between-class
  boundary from labeled samples, for model selection. No closing
  residuals, no healed decision regions, no error-signal use. Not
  redundant.
- **P0b.** Named prior against us: Goodfellow, Shlens & Szegedy 2014 —
  adversarial examples occupy broad contiguous subspaces along
  gradient directions; "space is not full of pockets." Plus the
  boundary-tilting account (Tanay & Griffin). Both say confident error
  lives near tilted boundaries, not in interior structure.
- **P0c → protocol amendment (pre-execution, binding).** Hanin &
  Rolnick 2019: in trained and initialized nets the number of linear
  regions scales with **total neuron count**, far below the
  exponential-in-depth bound, and is roughly depth-independent at
  fixed budget. This is a direct competing account of E2. Amendment:
  the depth sweep holds **total hidden neurons fixed at 64**
  (64×1, 32×2, 16×4, 8×8) in addition to the accuracy band. Under
  Hanin–Rolnick, p(ε*) should be flat across depths; under the
  composition mechanism, increasing. E2 is thereby a discriminator
  between two named accounts, not just a trend test.
- **P0d — the sharpening.** Path-connectivity of class regions is
  empirically supported (Fawzi et al. 2018), connectivity has
  theorem-level support under architectural conditions (Nguyen et al.
  2018; extensions 2019), and 2026 work reports empirical *simple*
  connectivity (loop-filling, six architectures). None of this
  forecloses the phantom: **slits and fjords are invisible to
  homology** — a disk minus a slit is still simply connected — while
  closing sees exactly them. The phantom is a morphological invariant,
  not a homological one; the literature's instruments are structurally
  blind to it. What P0d does foreclose (jointly with P0b) is
  island-type phantom. Registered refinement: any phantom mass found
  is expected to be *attached* thin structure (fjords/slits), and the
  pilot logs, per phantom component, whether it touches the rival
  region (fjord) or not (island); a predominance of islands would
  contradict the connectivity literature and demand extra scrutiny of
  the rasterization before being believed.

## What passing buys, and what it does not

E1'+E2 alive: composition measurably manufactures phantom in trained
nets — the Lean theorem's mechanism observed in the wild. E3 alive on
top: the healed decision is better than the raw one where they
disagree, i.e. a zero-training-cost correction exists and phantom mass
is a test-set-free error signal — that is the result worth a paper.
Any pass is 2D-only; scaling to real data (2D slices through data
triples) is Phase 2, registered separately, with the battery
discipline (boundary length, margin, capacity as controls) applied
before any claim that phantom is its own signal.
