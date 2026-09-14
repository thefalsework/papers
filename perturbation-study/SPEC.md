# Perturbation study: one step of dynamics

*Registered spec, 2026-09-14, before any computation beyond the hand
calculations recorded here. Question: the program's completed math is
equilibrium math — one poset, one observer, one moment. Every
registered empirical kill (crates.io K3, RubyGems K-R1, Debian) died
asking a future-tense question with a snapshot invariant. This study
takes exactly one step of dynamics: what happens to the kernel-checked
invariants — class (ordinary/regular/dense), aperture, phantom mass —
when the poset gains a single relation?*

## Setup and conventions

P a finite poset. A **single-edge addition** picks an incomparable
pair (a, b) and passes to P′ = transitive closure of P ∪ {a < b}.
Ground set unchanged. Conventions and invariant definitions are
verbatim those of bridge-study/SPEC.md (dependencies sit below;
D(P) = down-sets; ordinary/aperture/phantomMass as kernel-checked).

The tracked object is the **principal cone of a package p**, i.e.
↓p computed in whichever poset is current. Note the cone itself moves:
↓′p ⊇ ↓p. Questions are about the cone *of p*, not the frozen set.

Aperture is computed by the characterization theorem
(`aperture_eq_card_ordinary_traces`, kernel-checked 2026-09-12):
aperture(↓p) = #{ S ⊆ P : trace of ↓p on S is ordinary in D(S) }.
Cost 2^|P|, so exhaustive to |P| = 7.

## Phase 0 — literature (done 2026-09-14, before this spec was written)

1. **The lattice-level move is known.** Bordalo–Monjardet (Czech.
   Math. J. 59, 2009, "deletable elements" line): O(P + (a,b)) is a
   sublattice of O(P), obtained by deleting the ideals containing b
   but not a. Known as lattice combinatorics; nothing there about
   Heyting negation, ordinariness, nuclei, or any observer layer.
2. **The genre exists.** Stability of network indices under sparse
   edge perturbation is an established literature: Segarra–Ribeiro
   (2015) define stable/continuous centralities (degree stable,
   betweenness unstable and discontinuous); Pozza–Tudisco (2017)
   prove exponential decay of perturbation effects with distance
   from the modified edge for matrix-function centralities. No
   order-theoretic or Heyting-algebra invariant has been placed in
   this framework. Aperture's stability class is open.
3. **Novelty of the question itself**: no hit for perturbation /
   dynamics of ordinary elements, nuclei, or sublocale structure
   under poset extension. The nearest neighbor is the deletable-
   ideals line above, which is about lattice shape only.

## Hand lemmas (registered as expectations; oracle must confirm each)

**L0 (a time step is not an observer).** D(P′) = {U ∈ D(P) :
b ∈ U → a ∈ U} is closed under ∪ and ∩ but **not** under ⇨, so it is
not the fixed-set of any nucleus on D(P). Witness, registered now:
P = antichain {a, b}, add a < b. U = {a}, V = ∅: U ⇨ V = {b} in
D(P), and {b} ∉ D(P′). Consequence: single-edge dynamics is *not*
reducible to the observer classification (C1). The dynamical layer is
new structure, not a corollary. [Lean target if confirmed.]

**L1 (worlds strictly shrink).** ↓_P b ∈ D(P) \ D(P′), so
|D(P′)| < |D(P)| strictly, for every legal edge addition.

**L2 (one edge can create ordinariness).** 3-antichain {p, b, q},
add p < b: this is exactly the H3 minimal motif, ↓p flips regular →
ordinary. So Booleanness is one edge from breaking.

**L3 (one edge can destroy ordinariness).** H3 motif {p < b, q},
add q < p: P′ is the 3-chain, no ordinary cones. So the four-fold is
one edge from closing. With L2: **class is non-monotone under edge
addition in general.**

**L4 (density is absorbing — the ratchet).** If ↓p is dense in D(P)
(every x ∈ P has ↓x ∩ ↓p ≠ ∅), then after *any* single-edge
addition, ↓′p is dense in D(P′). Hand argument: ↓′x ⊇ ↓x and
↓′p ⊇ ↓p, so every intersection that was nonempty stays nonempty.
Dense cones stay dense forever; edges are a one-way door into
density. [Primary Lean target. Note L2/L3 show neither regularity
nor ordinariness is absorbing, so if L4 holds, density is the
*unique* absorbing class among the three.]

**L4-corollary (maturity starves the instrument).** Ecosystems only
gain edges over time (packages add dependencies; they rarely shed
them at the resolution of dump snapshots). If L4 holds, the fraction
of dense cones is non-decreasing along ecosystem history, and the
RubyGems instrument starvation (85.3% zero-aperture at high reach,
K-R1 postscript) is the *expected late-time state*, not bad luck.
Registered as an interpretation, not a claim; a longitudinal check
is future work, not this study.

## Phase 1 — exhaustive oracle

Engine: reuse bridge-study conventions. Enumerate all labeled posets
on n = 2..5 elements exhaustively (transitive, antisymmetric,
reflexive relations), plus ≥ 300 random posets on n = 6..7. For
every poset, every incomparable pair (a, b), every package p:
compute before/after class of ↓p, aperture(↓p), and total phantom
mass Σ_S phantomMass(j_S, ↓p) (co-aperture restricted to the cone).

**E0 (engine validation).** The engine must reproduce the H3 motif
numbers as recorded in bridge-study/out/pilot-results.json — dep
side: ↓p aperture 1 (of 8), coaperture 18, ordinary; ↓b aperture 0,
coaperture 12, regular; ↓q aperture 0, coaperture 14, regular — and
the L0–L3 hand witnesses exactly. Any mismatch stops the study.

*Correction, 2026-09-14, before any code: the first commit of this
spec cited the H3 aperture as "3 of 8" from memory. The recorded
bridge-study value is 1 of 8 (hand recomputation via the trace
characterization agrees). Corrected here, registered as an
amendment; no oracle had run.*

**Q1 (signs).** Tabulate the sign distribution of Δaperture and
ΔphantomTotal over all (poset, edge, p) triples. Registered
expectation: both signs occur for both quantities (non-monotone).

**Q2 (locality).** For each triple, record whether the added edge
touches the cone's zone of influence: (a) both endpoints comparable
to p, (b) one, (c) neither. Registered question: can a class change
at p be caused by an edge of type (c) — both endpoints incomparable
to p? Expectation, stated with low confidence: yes for class (¬ is
global), i.e. aperture is **non-local**, unlike the matrix-function
centralities with their decay bounds. If instead type-(c) edges
never change class, that is an invariance theorem and a Lean target.

**Q3 (jump size).** Record max |Δaperture| / 2^|P| over the ensemble
and whether aperture can collapse to 0 in one edge from its ensemble
maximum. Registered expectation: aperture is *unstable* in the
Segarra–Ribeiro sense (relative jumps do not vanish with system
size). A single edge creating a global minimum forces H1 collapse;
the oracle should exhibit the witness.

**Q4 (the ratchet, L4 at scale).** Zero tolerance: any (poset, edge,
p) with ↓p dense before and ↓′p non-dense after kills L4.

## Kill conditions

- **K0**: E0 mismatch. Engine wrong; stop, fix, rerun from scratch.
- **K1**: any counterexample to L4. The ratchet dies, the absorbing-
  state narrative dies with it, and the postscript records that
  the dynamical layer has *no* monotone invariant found yet.
- **K2**: L0 witness fails (D(P′) closed under ⇨ on the registered
  witness or oracle finds edge additions that *are* nuclei in ≥ 99%
  of cases). Then dynamics reduces to observers and this study
  collapses into the C1 classification; record and stop.
- **K3**: Q1 comes back single-signed (aperture monotone under all
  edge additions). Not a kill of the study but of the "dynamics is
  genuinely new" framing — a monotone aperture would be a *stronger*
  theorem and immediately promoted to the Lean queue.

## Phase 2 (conditional) — Lean targets, in order

1. L4 (density absorbing) — expected easy, LowerSet vocabulary.
2. L0 (edge addition is not a nucleus) — finite witness, `decide`.
3. Whatever invariance Q2 finds, if any.

No Phase 3 is registered. In particular, no longitudinal ecosystem
claim is registered here; if the ratchet survives, that claim gets
its own spec with its own kill.

---

## Postscript (2026-09-14, same day): Phase 1 and Phase 2 complete

Oracle: `01-edge-oracle.py`, one run, no code changes after first
execution. E0 matched the recorded bridge-study values exactly; all
hand witnesses (L0, L2, L3) confirmed. Survey: 406 exhaustive posets
(n ≤ 5) + 180 sampled (n = 6, 7); 5,622 edge-additions; 29,646 cone
perturbations.

**Verdicts.**

- **K0, K1, K2, K3: none fired.**
- **L4 (the ratchet) holds with zero exceptions** in 29,646 trials.
  The transition table contains `dense→dense` and *no other
  transition out of dense*, while ordinariness moved both ways
  (regular→ordinary 2,809; ordinary→regular 1,588). Density is the
  unique absorbing class.
- **L0, stronger than registered:** D(P′) was closed under ⇨ in
  **0 of 284** tested edge-additions — not rare, never. A time step
  is not an observer, empirically without exception here.
- **L1 held everywhere** (down-set count strictly decreases).
- **Q1 (signs):** Δaperture +5,231 / −10,497 / 0: 13,918 — both
  signs, non-monotone as registered. Δcoaperture is the surprise:
  +343 / −13,705 / 0: 6,902. Co-aperture is *nearly* monotone
  decreasing (increases in 1.6% of triples). The 343 increase
  witnesses are recorded in out/ and unexplained; characterizing
  them is unregistered future work.
- **Q2 (locality): NON-LOCAL**, as expected with low confidence.
  Edges with both endpoints incomparable to p changed p's class 578
  times (rate ~1/10th that of adjacent edges, but nonzero). No
  invariance theorem is available; aperture joins betweenness in the
  non-local, unstable camp of the network-index taxonomy.
- **Q3 (stability): unstable.** Max relative aperture jump 0.49 —
  a single edge took a cone from aperture 0 to 63 of 128 (n = 7).
  Ten collapse witnesses (ordinary, positive aperture → 0) recorded.

**Phase 2 (Lean), same day.** `lean/FalseWorkPapers/Lattice/
EdgePerturbation.lean`, builds clean against Mathlib:

- `LowerSet.compl_Iic_eq_bot_iff` — density criterion: ↓p is dense
  iff every element shares a lower bound with p.
- `dense_cone_ratchet` — **L4 as a theorem**, stronger than the
  survey: density of a principal cone survives *any* extension of
  *any* preorder (finite or infinite, one edge or many).
- `IsNucleus.himp_fixed` — fix-sets of nuclei are exponential
  ideals (the general gap behind L0).
- `timeStep_not_observer` — **L0 as a theorem** on the minimal
  witness: no nucleus on D(2-antichain) fixes exactly the extended
  order's down-sets.

**One-line summary.** The program's first dynamical theorem: time
(edge accumulation) and observation (nuclei) are provably different
operations on the same algebra, and time has a one-way door — dense
forever, ordinary at risk in both directions. The RubyGems
instrument starvation is now a corollary-shaped fact, not an
accident; the registered longitudinal claim remains unregistered
and would need its own spec.
