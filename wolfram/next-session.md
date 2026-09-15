# Status 2026-09-15 (arrangement correction): the census was forced by a two-line formula — Glivenko bridge retracted as arrangement content

External review, having independently confirmed every number
(469,535 opens and 2^11 regulars at n = 4 included), supplied the
generator: in any finite poset with up-set opens, ¬¬U = {x : every
maximal above x lies in U}. Two lines, and everything the scaling
run surveyed drops out of it. Recorded in Amendment 2 of
`arrangement-check/SPEC.md`:

- **Regulars = 2^{#Max} always** — E7 was a paragraph about
  Alexandrov algebras, not a conjecture needing two sizes.
  Booleanization of any finite Alexandrov algebra is the power set
  of its maximal elements.
- **Dense ⟺ U ⊇ Max**, so the whole four-class census reduces to
  two up-set counts: |U(P)| and |U(P∖Max)|. Verified: 621 dense at
  n = 3 is exactly the boundary count.
- **Seam exactness (50/50) was forced** — it could not have come
  out 49/50. K2 could not realistically fire; conceded as not a
  genuine kill.
- **Retracted:** "Cover's object is the Boolean skeleton" in its
  bridge form. It is a general Alexandrov fact wearing arrangement
  clothes and must not go to Levin as a bridge. What survives as
  arrangement-specific: the up-set counts themselves and their
  growth (oriented matroid combinatorics) — that is where any
  Levin-relevant content lives.
- **Process rule adopted (fourth instance of the pattern):** derive
  the closed form for ¬¬ in the ambient algebra *before*
  registering census expectations. Lean target shifts to the
  general theorem, queued.

One caveat logged against over-deflation: ordinary-dominance is not
forced by the formula alone (antichains are all-regular); it needs
the boundary layer to outgrow the cells, which is genuinely
face-poset combinatorics.

# Status 2026-09-15 (pocket deflation): the 100% was forced, the whisper was selection, the lattice stays open

External review of the pocket-study postscript demanded three
interrogations; all run same evening (`03-deflation-check.py`),
recorded in Amendment 2 of the spec:

- **Q1 deflated by theorem**: the future-watcher {b} commutes with
  every step on every poset (hand proof recorded; 0 exceptions in
  4,252 steps), and so does every singleton {x} with x ≰ a. The
  middle is never empty because membership is partially *free*.
  What survives: excess beyond the forced supply has spread
  (min 0 — two steps have none — median 14), so the definition
  discriminates, weakly, at n ≤ 5. No abundance claim beyond that
  scale survives.
- **Q3 retracted**: the phantom-drop gap for compatible observers
  is a coarseness-selection artifact — it shrinks within every
  |S|-stratum and flips sign at |S| = 4.
- **Lattice conjecture**: the cheap-proof route fails honestly
  (cl′ preserves joins, not the meets the argument needs); open in
  both halves, 5,984/5,984 empirical, no counterexample.

The methodological note worth keeping: the failed characterization
guess and this deflation pass are what make the surviving claims
citable. Three dynamical results in two days from one door was
itself flagged as suspicious; the deflation confirms one of the
three was partially free. The other two (ratchet, time ≠
observation) are theorems and unaffected.

# Status 2026-09-15 (arrangement scaling): the mid-tone thickens with n, and Cover's object is the Boolean skeleton — exactly [superseded in part: see the correction entry above]

Follow-up to the morning's arrangement check, prompted by an
independent external reproduction (separate construction, no shared
code) that matched every structural claim and correctly flagged one
convention: ⊤ is both dense and regular; the census is dense-first
(127 regular) where a regular-inclusive recount gets 128. Pinned in
the spec. The recount also exposed 127 + 1 = 2^7, which became E7.

Registered E5–E7/E3′/K2 as a spec amendment before code, then ran
`02-scaling-census.py` (one run, exact rational arithmetic):

- **E5**: enumerator validated against the closed-form face counts
  at n = 3, 4, 5 before any census was trusted.
- **E3′: 50 for 50.** Every adjacent-cell pair at every n (9 + 16 +
  25) is ordinary with ¬¬ recovering exactly the seam. The
  composition result is scale-stable and exact.
- **E6**: ordinary fraction **rises** — 65.5% → 78.8% → 86.2%
  (n = 5 derived via E7; opens number 475M there). K2 did not
  fire. The classical part collapses: 5.9% → 0.44% → 0.014%.
- **E7 holds exactly at n = 3 and n = 4**: regulars (incl. ⊤) =
  2^{#cells}, cell-set map injective. **The Booleanization of the
  arrangement algebra is the power set of Cover's regions** — the
  threshold-counting object is identically the classical skeleton
  of the open-set algebra. Natural Lean target; the one-line hand
  argument (¬V depends only on V ∩ cells) is recorded in the spec.
- For the Levin thread, unhurried: the citable sentence is the seam
  one (50/50 exact recovery), the identity is E7, and the census
  trend is context. Nothing sent; the current exchange resolves
  first.

# Status 2026-09-15 (pocket study): dynamical pockets exist, are abundant, and appear to form a lattice per step

Registered `pocket-study/SPEC.md` before code. The question, direct
from the Wolfram thread: static pockets of reducibility were already
enumerable (the observer-ledger frontier); Wolfram's notion also
requires the coarse-graining to *commute with evolution*. Definition
registered: S is dynamically compatible with a single-edge step iff
cl′ ∘ j_S = j′_S ∘ cl′ on all worlds (cl′ = forward closure, the
same cone-update map as the perturbation study).

- **Hand lemmas first**: endpoints always commute (P0); on the
  2-antichain step the future-watcher {b} commutes and the
  past-watcher {a} does not (P1/P2) — the middle is non-empty and
  proper at minimal scale. Node-addition steps have a no-go under
  the same-support convention (P3), so edge steps are primary.
- **Oracle clean, one run, 5,984 steps, no kill**: the middle is
  non-empty in **100.0%** of steps (registered: "usually");
  **lattice closure of the compatible set held on every step** —
  promoted to conjecture; dynamical pockets (compatible AND
  trace-ordinary through the step) number 40,765 — abundant, not
  marginal. Descriptive: compatible observers show steeper phantom
  decrease across the step (−2.61 vs −1.61).
- **A post-hoc closed-form guess for the characterization failed**
  (13,863/131,320 mismatches, both directions) and is recorded in
  `02-characterization-check.py`. The characterization of which
  observers commute with time is the open problem this study leaves.
- **Lean same day** (`Lattice/PocketWitness.lean`, builds clean):
  P1 and P2 kernel-checked with honest nucleus certificates — the
  minimal commuting/non-commuting observer pair on a genuine step.
- Position in the program: with `timeStep_not_observer` (time ≠
  observation) and `dense_cone_ratchet` (time's one-way door), this
  is the third dynamical result in two days, and the first that
  makes "computational reducibility" a definition inside the
  program rather than an analogy: a pocket is a nucleus that
  commutes with the step and keeps the four-fold alive. Open next
  moves, unregistered: prove the lattice conjecture; find the true
  compatibility characterization; iterate steps (does compatibility
  compose along evolution paths?).

# Status 2026-09-15 (arrangement check): the Cover seam is open — 65% of the three-line arrangement algebra is ordinary

Registered `arrangement-check/SPEC.md` before code. The question,
from external notes worth crediting: the face lattice of a hyperplane
arrangement is geometric, hence complemented, hence nothing is
ordinary — if that were the object, the bridge to Levin's
threshold/Cover material would be closed and Problem 1 of the Sept 13
letter would need restating. The check: build the object the program
actually uses (opens of the stratified plane = up-sets of the face
poset) for three lines in general position, and classify everything.

- **All expectations passed, one run, no kill.** E1: all six
  half-planes regular with ¬ = the opposite half-plane (the
  kernel-checked perceptron result, reappearing inside the
  arrangement algebra). E2: all seven cells regular. E3: all nine
  phantom pairs (adjacent cells minus their shared edge) ordinary,
  with ¬¬ adding exactly the seam, nine for nine.
- **Census (E4): 2,171 opens — 621 dense, 127 regular, 1,423
  ordinary (65.5%).** The classical skeleton is thin; the bulk of
  the arrangement algebra is mid-tone.
- **K1 (seam closed) did not fire. Problem 1 stands as written.**
  The complemented-lattice caution was right about the face lattice
  and irrelevant to the open-set algebra.
- Not done, deliberately: no n-line scaling claim, no trained-network
  claim, no new letter content. The corridor conjecture (Problem 1)
  now has a verified floor object; whether ordinariness tracks the
  Cover transition as capacity grows is exactly the student problem
  and stays theirs.

# Status 2026-09-14 (perturbation study): the first dynamical theorems — density is a ratchet, and a time step is not an observer

Registered `perturbation-study/SPEC.md` before any code (one honest
pre-code amendment: an E0 value cited from memory was corrected to
the recorded bridge-study number). Motivation, from the day's
diagnosis: every completed theorem is equilibrium math — one poset,
one observer, one moment — while every dead empirical claim was
future-tense. This study takes exactly one step of dynamics: add a
single relation to a poset, watch the invariants.

- **Phase 0**: the lattice-level move is known (Bordalo–Monjardet:
  D(P′) is a sublattice of D(P)); the "stability of network indices"
  genre exists (Segarra–Ribeiro; Pozza–Tudisco) with no
  order-theoretic invariant placed in it. Hand lemma L0 found during
  spec-writing: D(P′) is not ⇨-closed, so edge addition is not a
  nucleus.
- **Oracle passed clean, one run** (`01-edge-oracle.py`): 586 posets,
  29,646 cone perturbations. No kill fired.
- **L4, the ratchet, zero exceptions**: a dense cone never leaves
  density under edge addition, while ordinariness moved both ways
  (regular→ordinary 2,809 times, ordinary→regular 1,588). Density is
  the unique absorbing class.
- **L0, stronger than registered**: D(P′) was ⇨-closed in 0 of 284
  edge-additions. Time and observation are different operations.
- Aperture is **non-monotone, non-local, and unstable** (a single
  edge moved a cone from aperture 0 to 63 of 128); co-aperture is
  *nearly* monotone decreasing (increases in only 1.6% of triples —
  the 343 witnesses are recorded, unexplained, unregistered).
- **Lean, same day** (`Lattice/EdgePerturbation.lean`, builds clean):
  `dense_cone_ratchet` proves L4 for *arbitrary* extensions of
  *arbitrary* preorders (stronger than the survey);
  `IsNucleus.himp_fixed` (fix-sets are exponential ideals) plus
  `timeStep_not_observer` prove L0 on the minimal witness.
- **Consequence for the ledger**: the RubyGems instrument starvation
  (K-R1, 85.3% dense at high reach) is now corollary-shaped — mature
  ecosystems accumulate edges, and edges are a one-way door into
  density. The longitudinal claim ("the fraction of dense cones is
  non-decreasing along real ecosystem history") remains unregistered
  and would need its own spec with its own kill.

# Status 2026-09-13 (work theorem): the capacity threshold, kernel-checked; the mathematics is Citkin's

Registered `preprints/aperture/work-theorem-spec.md` (after the
Phase 0 literature check, before any code). The question: what does
ordinariness buy? Candidate answer: capacity — the size of the
subalgebra one element generates.

- **Phase 0 fired a novelty kill first, recorded in the spec before
  any claim was made:** the classification is already in Citkin
  (Logics 2024). Prop. 3: dense generator → Z₂/Z₃. Props. 2 +
  Thm. 6: regular caps at Z₅. Prop. 4(c): ordinary forces > 5. The
  general capacity threshold follows since ⟨k⟩ is one-generated and
  ordinariness transfers to subalgebras. What survived registration:
  a formalization claim, not a mathematics claim.
- **Oracle passed:** all 87 posets on ≤ 5 elements, 938 elements —
  dense caps at 3, regular at 5, ordinary min 6, no kill.
- **Lean (`Lattice/CapacityThreshold.lean`), kernel-checked:** W1
  dense closure `{⊥, k, ⊤}`; W2 regular closure
  `{⊥, k, kᶜ, k ⊔ kᶜ, ⊤}`; W3 six pairwise-distinct witnesses for
  ordinary `k` (direct argument, no dense-filter quotient); **W4 the
  threshold iff** — `k` ordinary ⟺ every operation-closed set
  containing `k` has ≥ 6 elements.
- **This discharges the oldest [C] on the thread**: the six-element
  threshold `NishimuraKernelLaw.lean` has cited since August is now
  [K], two-sided, and abstract.
- Honest ledger for the thermodynamic reading after today: one
  *generated* theorem (the second-law package, below), one *located*
  theorem (this — the frame predicted a work law and found it already
  existing in the literature, which is consistency, not priority).
  No temperature analogue, no work-extraction dynamics. The
  capacity-as-work reading stays grade [O].

# Status 2026-09-13 (second law): phantom mass behaves as entropy production, kernel-checked

Registered `preprints/aperture/second-law-spec.md` (committed before
any Lean), then `lean/FalseWorkPapers/Lattice/SecondLaw.lean`, all
four clauses kernel-checked same day:

- **S1** coarser observers never manufacture less phantom (monotone
  in the pointwise nucleus order; holds with no nucleus hypotheses).
- **S2** the identity is a nucleus with mass exactly 1 everywhere
  (the zero-production floor); every nucleus dominates it; every
  mass ≥ 1.
- **S3** no free coarsening: strictly coarser observers manufacture
  strictly more phantom somewhere (witness: any point of difference).
- **S4** zero production characterizes equilibrium:
  `phantomMass j k = 1 ↔ j k = k` — production vanishes exactly at
  the observer's fixed points.

Context: this was registered as the cheapest falsifiable test of the
thermodynamic reading of the ledger (ordinariness as capacity,
log co-aperture as entropy via the multiplicativity theorem,
Booleanness as the dead state). The reading now has one law that is a
theorem rather than a description. Registered limits: no temperature
analogue (the ε/α readout in the phantom pilot stays empirical), no
work theorem, no dynamics. Honest note: S1 is order-trivial; the
content of the package is that all four clauses of the second-law
shape hold together with nothing weakened — and two hypotheses were
droppable, which is recorded in the spec postscript.

# Status 2026-09-13 (correspondence): reply to Levin sent

The reply to Levin's Sept 10 email went out 2026-09-13 evening. It
followed the registered contents checklist (see 2026-09-09 entry,
items 1–9) in full:

- Opens on his Apr "complementary halves" frame; reports the phantom
  pilot as the first measurement at the seam.
- The co-aperture ledger: phantom mass |[k, j k]| as what an observer
  manufactures, closed forms, independence from aperture both
  directions, kernel-checked; cited by DOI (aperture v0.4,
  10.5281/zenodo.22715068, §7).
- The instrument honesty note (closing = one one-parameter family of
  nuclei, not the full ledger) and the K1 answer: 80 nets, mass
  ≤ ~0.1% at data scale, α ≈ 2 codimension-2 readout with the
  3-resolution caveat. One-liner used: real in the algebra, vanishing
  in the geometry.
- Both survivors as separate claims (E2 depth trend vs Hanin–Rolnick;
  E3 enrichment consistent-but-underpowered), pilot cited by DOI
  (10.5281/zenodo.22715062).
- The Citkin anchor (arXiv:2512.05633 Cor. 3.9) under the sentence he
  singled out, with the Z_n ≥ 6 clause and the nodeless/H1
  complementarity clause.
- The student overture answered with three scoped problems, each with
  deliverable and failure condition: (1) corridor conjecture across
  the Cover transition; (2) phantom mass under smooth activations;
  (3) error-enrichment in segmentation (the powered setting). A
  closing paragraph states the three are independent, run
  theory → generality → application, and are framed so a negative
  answer is reportable. No new requests; no repeated conemass.

Now waiting on his response. Past pattern: acknowledgment in 1–3
days, substantive engagement ~3 weeks. If a student takes a problem,
the deliverable/failure-condition framing above is the working spec
seed; each problem would get its own registered SPEC before any code
runs, same discipline as the pilots.

# Status 2026-09-13 (prediction study): K3 kill on incremental validity; quiet-criticality direction survives as registered secondary

Question: does the ego-aperture add predictive information about
future security advisories beyond cheap centralities (incremental
validity)? Registered `prediction-study/SPEC.md` (spec frozen before
any computation; crates.io at T0 = 2024-09-01, outcomes = OSV
advisories published after T0; case-control 514 cases / 10,000
controls; kills K1–K3).

- **Instrument v1 died by theorem before touching outcomes:** the
  registered fill order collected only nodes comparable to p, and
  the H3 necessary condition (ordinariness needs an incomparable
  witness) makes such ego-apertures identically zero. Recorded as
  Amendment 1; v2 adds sibling layers (co-users of p's dependencies,
  co-dependencies of p's dependents). A kill by proof, not data —
  outcomes were never loaded.
- **Phase 1 (v2) passed:** stability Spearman 0.761 (cap16 vs 12),
  0.841 (vs 20); non-degenerate (26.5% zeros, 112 distinct values on
  200 samples).
- **Phase 2: K3 fired as registered.** Mean held-out ΔAUC +0.0034 <
  0.005 kill line (baseline AUC 0.83–0.88; popularity proxies
  dominate, as the registered KTH prior predicted). The deployable
  claim — aperture improves advisory prediction — is dead.
- **Separable survivors, both registered in advance:** the LR test
  says the aperture term is real (p = 8.7×10⁻⁷) and *negative* —
  lower aperture, higher advisory odds, conditional on baselines.
  And E-P4, the quiet-criticality secondary (direction registered in
  `notes/aperture-is-generativity.md`): within the top conemass
  quartile, low-aperture packages carry OR = 2.85 [2.06, 3.93] for
  advisories vs. high-aperture ones. Heavy load + low
  distinction-visibility is the dangerous cell — the inverted
  hypothesis, now with a clean CI behind it.
- Honest status: same shape as phantom-study E2 — direction
  confirmed, deployable magnitude not, reported as separate claims.
  The quiet-criticality reading is now a hypothesis with evidence,
  not a claim. To become a claim it needs its own preregistered
  primary on untouched data (npm/PyPI, or later T0), with E-P4 as
  the primary endpoint. This study makes no such claim.

**Same-day continuation: the replication ran, and it killed.**
Registered before parsing (SPEC Replication section): RubyGems
(weekly dump, 209,605 gems, 3.2M runtime edges at the same T0; OSV
outcomes; 90 cases), quiet-criticality OR as the sole primary, pass
iff CI lower bound > 1. **K-R1 fired: OR = 1.11 [0.79, 1.56];**
supporting stats null without any cutting (aperture coefficient
−0.14, p = 0.455; ΔAUC −0.0003). Post-hoc diagnostic (labeled):
85.3% of high-reach gems have ego-aperture exactly 0 — the H1
theorem in the wild; RubyGems' quasi-universal base gems
(activesupport family) enter every heavy gem's ego-net as a
near-global minimum, forcing density, so the quantity the hypothesis
needed is structurally absent in this ecosystem. Honest summary, as
pre-written in the spec: **one ecosystem showed a direction; the
replication failed.** Quiet-criticality is an unreplicated
single-ecosystem secondary — crates OR 2.85 stands as recorded, the
RubyGems null stands beside it, and no public claim beyond that pair
of sentences is supportable. A possible successor hypothesis
(universal-base ecosystems are structurally invisible to cone-side
aperture, as H1 predicts) is noted, unregistered, unclaimed.

# Status 2026-09-12 (bridge study): dependency cones joined to the lattice spine

Question tested: do the kernel-checked invariants (ordinariness,
aperture, co-aperture) say anything about dependency cones that cone
size doesn't — i.e. is conemass connected to the spine by theorem or
only by theme. Registered spec `bridge-study/SPEC.md` (committed
before the run), pilot `bridge-study/01-downset-pilot.py`.

- Setup: a dependency graph induces a poset (dependencies below);
  down-sets form a canonical Heyting algebra; a package's dependency
  cone is a principal down-set, so the invariants apply verbatim.
- **No kill fired.** Ensemble (40 graphs, 480 cones): 77% of
  equal-size cone pairs separated by some invariant (floor 10%);
  Spearman(coaperture, size) = −0.67 (redundancy threshold 0.95);
  175/480 cones ordinary.
- **xz motif:** universal base makes every dependency cone dense
  (H1), yet aperture still separates positions — liblzma 21,
  libsystemd 21, libssl 15, base and all leaf apps 0. The only
  nonzero-aperture nodes are the quiet middle libraries. At equal
  cone size, liblzma vs. leaf app: coaperture 588 vs. 420, aperture
  21 vs. 0.
- **Lean (`Lattice/BridgeDownSets.lean`), kernel-checked:** H1 as a
  theorem on Mathlib's `LowerSet` (global lower bound ⇒ every lower
  set regular or dense; abstract half in any Heyting algebra), and
  all seven minimal-motif numbers by `decide` through the Div12
  exponent-lattice presentation — ↓p ordinary, aperture 1,
  coaperture 18; ↓b, ↓q regular, apertures 0, coapertures 12, 14.
  Pilot and kernel agree digit for digit across independent
  presentations.
- Recorded without interpretation: dependency-side invariants track
  quiet depended-upon nodes; dependents-side ordinariness selects
  different positions; which lens (or the pair) is the criticality
  lens is open.
- Honest limits: 6–7 node graphs; nuclei enumeration is exponential;
  no instrument claim at registry scale. Theorem-scale statement
  only.

Open next steps if pursued: general graph reading of
cone-ordinariness as a theorem (the two-condition characterization in
the spec's H3 note); whether aperture-at-a-blur survives on larger
motifs; any scalable surrogate for the invariants (closed forms exist
for chain products — real dependency posets are not chain products).

**Same-day continuation (Phases 2–3, both registered before
running).** Phase 2: every nucleus on a finite down-set algebra is a
sub-ecosystem observer j_S (classification is cited mathematics —
Simmons, Bezhanishvili–Harding; the explicit form and its
consequences verified exhaustively on all Phase-1 algebras). The
characterization theorem: aperture(↓p) = #{S ⊆ P : trace ↓p ∩ S
ordinary in D(S)} — purely graph-theoretic, with a polynomial
per-subset predicate (feasible to |P| ≈ 20–25, up from 7). Phase 3
(the depth test): split verdict. Novelty half passed decisively —
no standard centrality (betweenness, degree, cones, Katz, PageRank,
closeness, incomparables) reaches median |ρ| 0.51 against the
aperture ranking, two-sided separation witnesses exist, no
degeneracy; translation kill K7 missed. Load half **failed** as
registered: in scaled xz families (n = 12–14) aperture selects the
interface library over leaf apps but ranks deep-chain (liblzma
position) *below* apps — the n = 7 motif result does not survive
scaling. Honest status: the aperture of a dependency cone is a new,
real, kernel-checkable graph invariant whose practical meaning is
open; the criticality reading is not supported at scale. Lean of
the characterization (C1–C2) is the remaining rigor step.

**Same-day continuation (Lean of C1–C2/E5): the weld is
kernel-checked.** `Lattice/ObserverClassification.lean`, compiled
clean against the full project, first pass. C1 in full — `S ↦ j_S`
is a bijection `Set P ≃ {nuclei on D(P)}` for every finite poset,
with surjectivity proved directly (support-set recovery +
well-founded induction), so the Simmons / Bezhanishvili–Harding
classification is a corollary here rather than a citation. C2/E5 —
`Opens (j_S) k ⟺ trace k ∩ S ordinary in D(S)` — via pointwise
Kripke formulas for `⇨` on lower sets and trace-transfer lemmas.
Capstone `aperture_eq_card_ordinary_traces`: aperture(k) =
#{S ⊆ P : k ∩ S ordinary in D(S)} as a `Nat.card` equality through
an explicit equivalence. Consequence: the chain
four-cell theorem ↔ ordinariness ↔ trace characterization ↔
subset-counting formula (what the depth-test scripts compute) is
now kernel-checked at every link; the graph layer and the lattice
spine are the same mathematics by theorem, not by verified
coincidence. E6 (phantomMass = relative-down-set count) remains
computational-only; it is the next Lean target if graph-side
co-aperture is ever needed at theorem strength.

# Status 2026-09-11 (correspondence): Levin replied — substantive, collaborative

Reply received ~3 days after the Sept 8 letter. Contents:

- Confirms the convergence ("closely related problems ... different
  methods") and singles out the load-bearing claim: the threshold
  transition ↔ Heyting algebra connection, "especially the suggestion
  that what ends at the threshold may be Booleanness rather than
  logic — seems to me important and deserving of careful thought."
- Commits to "consider the mathematical argument and its
  formalization carefully."
- Proposes involving one of his doctoral students in "this shared
  line of inquiry" and developing "a more sustained collaboration."
  "The thread is indeed renewed, and I take its possibilities very
  seriously."

Consequences:

- The Sept 29 contingency (self-contained follow-up report) is
  superseded: the same content — co-aperture, the pilot's K1 answer
  to the letter's own second question, E2 — now goes in a direct
  reply. The existing contents checklist below still applies.
- The reply must answer the student overture concretely: scoped
  problems with checkable deliverables, drawn from the registered
  reopeners (corridor conjecture across the Cover transition;
  phantom mass under smooth activations, where the ReLU measure-zero
  argument doesn't apply; segmentation-setting E3).
- Before sending: mint the three Zenodo DOIs (deposit steps in chat
  2026-09-09) so the reply can cite the perceptron-bridge note and
  the updated aperture paper by DOI rather than by repo path.
  **Done 2026-09-11:** all three published — perceptron-bridge v1.0
  doi:10.5281/zenodo.22715062, aperture v0.4 doi:10.5281/zenodo.22715068,
  four-position-partition v1.1 doi:10.5281/zenodo.22715070. DOIs
  written into the papers' citation blocks and the preprints README.
  The reply to Levin is unblocked.

# Status 2026-09-09 (citable homes): the recent results now have deposit-ready preprints

The citation-gap audit (kernel-checked results vs. what has a citable
home with a DOI) is closed on the repo side. Done this session:

- **New preprint `preprints/perceptron-bridge/paper.md` (v1.0)** — the
  citable home for the perceptron bridge: units regular / composition
  ordinary / seam = {1} [K]; the co-aperture summary [K]; and the phantom
  pilot's registered negative result [R] with the codimension-2 mechanism,
  the E2 survivor, and the fjords-not-islands check (266–0). Cites Levin
  arXiv:2604.02476 (exact title verified) and Synthese 208:132.
- **Aperture paper → v0.4** — new §7 (co-aperture: confusion-class lemma,
  chain/product/divisor closed forms, independence both directions, all
  [K]), former §§7–9 renumbered §§8–10, abstract and grade table updated.
  Ready for a new Zenodo version over the superseded v0.2 DOI
  (10.5281/zenodo.22016585).
- **Four-position-partition paper → v1.1** — deposit metadata, how-to-cite
  block, and a companion-results postscript (non-degeneracy criterion,
  perceptron instance, aperture/co-aperture). No mathematical changes.
- **`preprints/README.md`** — aperture entry refreshed to v0.4 (was stale
  at v0.1), perceptron-bridge entry added, four-position entry bumped.

Remaining is the user-side deposit: Zenodo uploads (new version for
aperture; fresh deposits for perceptron-bridge and four-position-partition),
then drop the DOIs back into the papers' how-to-cite blocks. Steps given
in chat 2026-09-09.

# Status 2026-09-09 (correspondence): Levin thread reviewed

Full email thread (Mar 29 → present) reviewed in session. State:

- **The ~Sept 8 letter is sent and unanswered** (the one with
  the perceptron bridge, conemass/xz, four-cell partition, and three
  closing questions held "askable now, not answered").
- **Timeline for expectations:** past exchanges ran acknowledgment in
  1–3 days, substantive engagement in ~3+ weeks (Apr 6 preprint →
  Apr 30 careful reading); his Sept 4 note reopening the thread said
  "no need, of course, for a detailed response" to the May letter.
  A substantive reply, if it comes, is plausible late September;
  absence of a quick ack is not informative either way.
- **The follow-up has real content:** the letter's second open
  question — substantial double-negation remainder in real models —
  was answered by the phantom pilot the day after sending (K1,
  codimension-2 mechanism). Plan: ~3 weeks after sending (≈ Sept 29),
  if no reply, send a short self-contained report answering our own
  registered question.

**Contents checklist for the next letter (whether follow-up or reply):**

1. **Open the frame with his own Apr 7 words**: the two programs are
   "complementary halves" — the pilot is the first *measurement* taken
   at the seam between them.
2. **The new algebra since the Sept 8 letter**: the co-aperture — phantom mass
   `|Icc k (j k)|` as what an observer *manufactures* (confusion, not
   deletion), closed forms on chains/products/divisor lattices, and
   the independence of aperture and co-aperture in both directions,
   all kernel-checked (`CoApertureClosedForm.lean`). The sent letter
   only had the bridge; this is the dual ledger.
3. **The instrument**: morphological closing at resolution ε *is* a
   nucleus — so the empirical study applies his devices' own algebra
   to his devices, not an analogy. Include the registered honesty
   note: one one-parameter family of nuclei, not the full co-aperture.
4. **The answer (K1)**: 80 runs, registered spec and kill conditions
   written before code; phantom mass ≤ ~0.1% at data scale, α ≈ 2 —
   the codimension-2 readout: the remainder concentrates where
   polytope faces *meet*, not along faces (caveat: 3-resolution fit).
   One line: *the remainder is real in the algebra and vanishing in
   the geometry of trained ReLU nets.*
5. **The survivor that bears on his threshold account (E2)**: at fixed 64-neuron
   budget, depth increases phantom mass (ρ = 0.77, p < 10⁻⁴) where
   Hanin–Rolnick predicts flat — composition manufactures the
   remainder even as training crushes it. Mechanism confirmed,
   magnitude not: separate claims that came apart. This is his
   threshold transition seen from the algebra side.
6. **The two honest attenuators**: E3 consistent with error-enrichment
   (+37/+38pp at depth 8, distance-matched) but underpowered by the
   same K1 fact; 266 fjords / 0 islands — the registered
   falsifiability check passed, so the kill is believed.
7. **Links**: `phantom-study/SPEC.md` (registered spec with dated
   postscripts) and `lean/FalseWorkPapers/Lattice/CoApertureClosedForm.lean`.
8. **Style constraints**: ≤ one-third the length of the Sept 8 letter;
   don't repeat conemass; no new requests; hold the reopeners
   (non-piecewise-linear activations, segmentation) to one sentence,
   marked askable-not-answered, mirroring the sent letter's close.
9. **(Added 2026-09-13) The Citkin anchor for the Booleanness
   sentence**: Citkin, arXiv:2512.05633 (Dec 2025), Cor. 3.9 — a
   finitely generated *nodeless* Heyting algebra is Boolean iff it
   contains no ordinary elements. This is live, independent
   mathematics stating that the ordinary elements *are* the
   non-Booleanness (in the f.g. nodeless case): exactly the algebraic
   ground under "what ends at the threshold may be Booleanness rather
   than logic," which Levin singled out as the load-bearing claim.
   One sentence, one citation; note that ordinariness is also
   load-bearing in Citkin's own proof of the primitive-varieties
   criterion (ordinary element ⇒ cyclic subalgebra Z_n, n ≥ 6 — the
   six-element threshold the repo has kernel-checked). Complementary
   observation worth one clause: his nodeless hypothesis and our H1
   tile the space — a universal base makes the atom a nontrivial
   node (H1's route to classicality); nodeless worlds are classical
   iff ordinary-free (his route). Nuclei/aperture do not appear in
   his paper; the observer-counting layer remains ours.

---

# Status 2026-09-09 (later): phantom-mass pilot — K1, thread dead, mechanism confirmed

The AI-hallucination application of the co-aperture ran its registered
pilot (`phantom-study/SPEC.md`, spec + Phase 0 + Phase 1 postscripts
all dated; code `phantom-study/01-pilot.py`, numpy only). 80 runs:
ReLU MLPs at fixed 64-neuron budget, depths 1/2/4/8, two-moons and
two-spirals, accuracy-banded, 10 seeds, morphological-closing residual
over a 3-octave resolution sweep.

**Verdict: K1.** Phantom mass at data scale tops out at ~0.1% of
region mass (spirals depth 8) and the scaling exponent is α ≈ 1.5–2.25
everywhere against the registered α ≤ 0.5. The α ≈ 2 is a dimensional
readout, not just "fast": in 2D, codimension-c structure gives
residual fraction ~ ε^c, so the phantom concentrates at codimension 2
— where polytope faces *meet*, not along the faces (caveat: 3-point
scaling fit, no further). The confident-error-measure framing is dead
for ReLU nets of this class.

What survived: (1) **E2, spirals: mechanism confirmed, magnitude not
— separate claims that came apart.** p(ε*) rises with depth at fixed
64-neuron budget (ρ = 0.77, p < 10⁻⁴) where Hanin–Rolnick predicts
flat; phantom mass is not linear-region count, so no contradiction —
but a depth-scaling quantity nobody has measured is a positive finding
in its own right. (2) E3: consistent with error-enrichment (+37/+38pp
over distance-matched controls at depth 8) and underpowered to
establish it; the population is intrinsically tiny by the same K1
fact, so this design cannot strengthen it — segmentation is where the
cells are. (3) 266 fjords, 0 islands — the registered rasterization
check came back clean, so the kill is believed.

For the Levin letter: this replaces an analogy with a checked answer —
the remainder is real in the algebra (`composed_seam`, co-aperture
closed forms, all [K]) and vanishing in the geometry of trained ReLU
nets (K1, with the codimension-2 mechanism). Reopeners (registered,
not promised): non-piecewise-linear activations, or very deep
low-width regimes where the E2 slope might cross into signal.

---

# Status 2026-09-09: the co-aperture (`CoApertureClosedForm.lean`, kernel-checked)

The dual ledger the program lacked: the aperture counts observers under
which a kernel stays ordinary (what survives); the co-aperture measures
what each observer destroys. Registered spec with hand-computed
expectations committed *before* the Lean work
(`preprints/aperture/coaperture-spec.md`); everything verified same day,
no deviations.

Definition: a nucleus doesn't delete, it conflates — `Icc k (j k)` is
exactly the set of elements the observer `j` cannot distinguish from `k`
from above (`IsNucleus.le_apply_iff`, two lines, any `SemilatticeInf`).
Its size is the phantom mass of `k` under `j`;
`coaperture k = Σ over nuclei j of |Icc k (j k)|` is the total phantom
mass. The phantom framing matters: not a blind spot (absence) but
confident false presence — `composed_seam`'s wall, generalized from one
observer to the whole ledger.

Results, all [K] (`lean/FalseWorkPapers/Lattice/CoApertureClosedForm.lean`):
chain closed form `coaperture e + 2^e = 2^(m+1)` by double counting;
**exact multiplicativity on finite products** (`coaperture_pi`, any
finite semilattices with ⊤ — note the aperture needs
inclusion–exclusion, the destruction ledger just multiplies); divisor
lattice closed form `∏ᵢ(2^{aᵢ+1} − 2^{kᵢ})`; and the independence
witnesses in both directions — Div24 kernels 2, 4: same aperture (3),
co-apertures 42 vs 36; Div72 kernels 4, 6: same co-aperture (84),
apertures 9 vs 6. Neither invariant determines the other: survival and
destruction are independent coordinates on kernels.

Open [O]: the conservation question (is there an exact identity linking
the two ledgers through the total observer count?); the cost-functional
reading (phantom mass as the price of an observer, cf. the
latency/co-aperture thread); whether the co-aperture of the composed
perceptron region has the corridor behavior conjectured for real
manifolds. Next theorem for the Levin thread if wanted: phantom mass of
`composed` under specific nuclei on `Opens ℝ`.

---

# Status 2026-09-04: the Levin bridge (`PerceptronRegular.lean`, kernel-checked)

Ilya Levin sent his published Synthese paper ("From Symbols to Geometry: An
Indexical Epistemology of Generative AI," Synthese 208:132). He last saw
paper 1 v11.5–v11.7 (spring) — the five-position verbal derivation. He has
never seen the four-cell theorem, the ordinariness criterion, or the
aperture work, all of which postdate the exchange. His corpus (six 2026
papers, checked in full) never engages any non-classical logic: his foil is
Boolean throughout (career: threshold logic, circuit synthesis, Boolean
concepts learning), and when the symbolic mode ends at his threshold, logic
exits his account entirely.

The bridge, now [K] (`lean/FalseWorkPapers/Examples/PerceptronRegular.lean`,
builds against the existing `IsOrdinary` / `AllFourCellsInhabited`
machinery): threshold devices' decision regions are elements of `Opens ℝ`
(a frame), so the four-position theorems apply to them literally, no
analogy. Results: (1) `coe_hnot` / `coe_hnot_hnot` — Heyting negation in
`Opens X` is interior-of-complement, double negation is
interior-of-closure; (2) a single threshold unit (`Ioi θ` / `Iio θ`) is a
regular element — the perceptron is classical, no four-fold opens around
it (`unit_not_ordinary`); (3) the composed region `(0,1) ∪ (1,2)`, built
in-lattice from four units by `⊓`/`⊔`, is ordinary —
`composed_allFourCells` gives the non-degenerate partition; (4)
`composed_seam` — the `¬¬`-remainder is exactly the phantom wall `{1}`,
the algebraic form of Levin's manifold-membership undecidability
(hallucination locus). Open [O]: whether real learned manifolds have
substantial `¬¬`-remainder; the corridor conjecture (regular below the
Cover transition, dense above saturation, ordinary only in the corridor).

Reply to Levin drafted on this spine: conemass as an empirical instance of
his positional-vs-symbolic migration (liblzma5 #8 positional vs #173 fame),
the Battery v5 kill as the refusal mechanism his framework lacks, the
four-cell theorem + the bridge file as the payload. Sent [pending].

---

# Next session: write the aperture closed form into the paper (2026-08-12)

## State at end of 2026-08-11

The evening ended one step past where the draft currently sits. The paper
(`preprints/aperture/paper.md`) still presents the two-prime product law as
its §5 conjecture. That is now superseded: we have a **closed form for the
aperture of every element of every divisor lattice**, verified with zero
mismatches on all 164 elements of 15 lattices (`aperture-closed-form.mjs`),
including all 109 zero-aperture elements and every mixed kernel — and every
step of its derivation is elementary and provable.

**The formula.** For k in Div(n), n = ∏ p_c^{a_c}, with e_c the exponent
of p_c in k:

    |Ap(k)| = ∏ 2^{a_c}  −  ∏ D_c  −  ∏ R_c  +  ∏ DR_c

    D_c  = (2^{e_c} − 1)·2^{a_c − e_c} + 1    (chain worlds where j(e) is dense)
    R_c  = 2^{a_c − e_c} + 2^{e_c} − 1        (… regular)
    DR_c = 2^{e_c}                            (… both)

**The derivation (all three steps elementary — do not lose this):**

1. *Factorization lemma.* Nuclei on a finite product H = A × B factor
   componentwise. Proof: for any nucleus j, (a,b) = (a,⊤) ∧ (⊤,b); by
   meet-preservation j(a,b) = j(a,⊤) ∧ j(⊤,b); inflation forces
   j(a,⊤) = (j_A a, ⊤) and j(⊤,b) = (⊤, j_B b); so j = j_A × j_B, and
   j_A(a) := π_A j(a,⊤) inherits all three nucleus laws. (Conversely every
   product of nuclei is a nucleus.) This was believed an open lemma until
   the four-line proof surfaced; it is NOT open.
2. *Coordinate-locality.* Negation in a product (and in Fix(j) = ∏ Fix(j_c))
   is componentwise, so j(k) is dense in Fix(j) iff dense in every
   coordinate world, regular iff regular in every coordinate.
3. *Chain counts.* On the chain C_{a+1}, nuclei = subsets F ∋ ⊤ of the a
   non-top elements (2^a of them), j(e) = least member ≥ e. Dense ⟺
   min F < e or F = {⊤}; regular ⟺ j(e) ∈ {min F, ⊤}; both ⟺ j(e) = ⊤.
   Counting gives D, R, DR above. Ordinary = not dense and not regular,
   so inclusion-exclusion yields the formula.

**Corollaries (verified numerically, worth stating in the paper):** the
two-prime law (2^i−1)(2^{a−i}−1)(2^b−1) [algebra checks], the original
Div(2^a·3) product law, the latency characterization (all exponents
interior — CORRECTED 2026-08-24: valid only at exactly two primes; see
paper Result 6.3 and `latency-characterization-correction.mjs`), and the
latent aperture sizes previously reported as
"unfitted data" — the refusal to curve-fit was correct, and the derived
form then explained them.

**How we got here (for design-notes):** the cloud run's unregistered Div72
ambient apertures (9, 7, 9) suggested a third factor (2^b − 1); reviewer
pushback (correct) said the Div60 fit of the rival N(complement)−1 form
was a degenerate-point coincidence and demanded Div120/Div180 as the
discriminating test; the test favored N(complement)−1 on 4/4 points
(9,9,7,7 vs chain-form's 3,3,3,3); asking WHY the −1 (reviewer: "if
there's no story it's a fudge") produced the derivation, which subsumed
both candidate forms.

## Status update, 2026-08-12 (end of session)

Items 1, 3, 4, 5 below are done; item 2's cloud rerun is the one
remaining manual step.

- **Paper** rewritten: §5 closed form as theorem with derivation,
  Result 4.1 and Result 6.1 upgraded to [K], §8 table and §9 updated.
- **Lean** (`Lattice/NucleusFactorization.lean`,
  `Examples/ApertureAnchors.lean`): the factorization lemma is [K] in
  full generality (`nucleus_prod_iff`); Ap(2) = {identity} on Div12
  over all nuclei (`aperture_two_complete`) and Ap(6) = exactly
  {jLeft, jRight} on Div36 (`latent_ordinariness_witness`,
  `aperture_six_complete`) are [K]. Method: the brute-force decide
  over 6⁶ self-maps crashed the kernel; the factorization lemma
  collapses the search to componentwise pairs (108 for Div12 via the
  exponent iso C₃ × C₂ + transport lemmas, 729 for Div36), after
  which decide is instant. Axiom audit clean — no native_decide, no
  sorry. Full `lake build` green. Episode recorded in design-notes
  part 5.
- **Still open on the Lean track:** Steps 2–3 of Theorem 5.1
  (coordinate-locality of density/regularity in product worlds;
  the chain counts) — that is what makes the closed form itself [K].

## Status update, 2026-08-14

- **Lean track closed for the two-prime case.** Steps 2–3 of
  Theorem 5.1 are [K] in `Lattice/ApertureClosedForm.lean`:
  WorldDense/WorldRegular defined (Opens = neither, definitionally);
  coordinate-locality on products; nucleus factorization upgraded to
  a type equivalence; chain nuclei classified as top-sets
  (`nucleusEquivTopSets`); the four chain counts proved as powerset
  cardinalities on arbitrary finite bounded chains (D and R stated
  additively to avoid ℕ-subtraction); inclusion-exclusion assembly
  (`aperture_card_add_eq`) proved for any product of two finite
  Heyting algebras; `aperture_closed_form_two_chains` (abstract, over
  ℤ) and `aperture_closed_form_exponents` (Fin exponent lattices —
  Theorem 5.1 verbatim, two-prime case) proved; Div12 cross-check
  example `decide`s to 1, agreeing with `aperture_two_complete`.
  Axiom audit: propext, Classical.choice, Quot.sound only — no
  sorry, no native_decide. Paper §5/§6/§8/§9 and abstract updated:
  closed form now [K] on two-prime lattices, [computed] for r > 2.
- **Remaining Lean gap:** the r > 2 iteration of the binary
  assembly (fold `aperture_card_add_eq` across an r-fold product).
  Bookkeeping, not mathematics. (CLOSED 2026-08-24 — and not by
  folding: see the 2026-08-24 status update.)

## Status update, 2026-08-15

- **Literature placement added to paper §5 + §8.** The chain-nucleus
  classification (Step 3, structural half) is folklore in print:
  Erné, "Nuclear ranges in implicative semilattices" (Algebra
  Universalis 2022) states it for bounded chains; Bezhanishvili ×2,
  Carai, Gabelaia, Ghilardi, Jibladze (arXiv:2001.11060) classify
  nuclei on finite implicative semilattices via meet-prime subsets.
  Ordinary elements remain active vocabulary in intermediate logics
  (Citkin, "An Algebraic Proof of the Nishimura Theorem," Logics
  2024). No trace found of: ordinariness relativized to nucleus
  worlds, the aperture, latency, or the count. Novelty claims now
  explicitly located there; search-not-review caveat marked [O].
- **Due diligence before arXiv:** follow citation trails of the two
  papers above; search "nucleus" + dense/regular element variants;
  consider writing to Citkin directly.
- **Wolfram track: closed.** `aperture-scaling.wl` rerun in Wolfram
  Cloud 2026-08-12: enumerations match the pre-registered table,
  product law 15/15, latency 8/8 CONFIRMED, closed form EXACT on
  all 79 elements (56 zero-aperture cancellations included).
  Recorded in the README scaling section and closed-form bullet.

## Status update, 2026-08-16

- **New preprint drafted: `preprints/hearing/paper.md`** ("Hearing at
  a Blur") — the cognitive hypothesis paper. States Hypothesis H:
  settled auditory attention (metrical entrainment) acts on Div(n) as
  a nucleus, decomposed into three independently falsifiable axioms
  (H1 inflation / H2 idempotence / H3 meet-preservation as perceptual
  laws). Introduces grade **[H]** (falsifiable empirical hypothesis,
  untested) alongside the existing five. Transfers, conditional on H:
  finite hearing spaces (8 for Div12, 16 for Div36), fragility
  (Result 4.1), and latency as the strong prediction — organization
  in-principle closed to full attention, open to exactly two
  computable hearings. Locates H against Lerdahl–Jackendoff (1983),
  Jones–Large (1999), London (2004), Bregman (1990): components all
  known, the algebraic package unasked. §6 gives a pre-registrable
  latency-detection design (36-pulse material, entrainment-primed
  conditions, square-free 30-pulse structural control, predictions
  P1–P5) with failure semantics mapped to axioms. Stimulus
  construction (realizing the level-6 four-fold acoustically) flagged
  [O] as the hard step. Bach (hemiola, BWV 645, augmentation) used as
  illustration, graded [A], explicitly not evidence.
- **Companion tooling:** interactive worksheet canvas (Div12/Div36
  hearings, verdicts, closed-form panel) with click-layer
  sonification — one layer per registered grid, coarse low/loud,
  fine high/soft; doubles as the stimulus-generation spec for §6.
  Verified against the Lean anchors before embedding
  (`.scratch_worksheet_check.mjs`, brute-force nuclei from axioms +
  per-chain verdict cross-check, zero mismatches).

## Status update, 2026-08-18: arXiv declines Paper 2 v2; routing changed

arXiv moderation declined Paper 2's v2 submission (submit/7711078)
and gated the account (journal DOI required for future submissions;
reconsidered once a publication record exists). Full event note and
routing decision logged in `papers/INDEX.md` (Paper 2 entry +
next-revisions list). Consequences for this track: the **Algebra
Universalis extraction of the aperture paper** is promoted from
due-diligence item to the priority artifact — it is both the
strongest material and the account-rehabilitation path (theorem-proof
register, no framework vocabulary, Lean as supplementary material;
Erné's venue = right referees). The Citkin letter (already queued
2026-08-15) now also serves the submission. Zenodo deposit of the
current aperture preprint for a DOI'd timestamp is cheap and should
happen before the journal cycle starts.

## Status update, 2026-08-19: the ordinariness gate runs on Mathlib itself

First run of the four-position instrument on formalized mathematics
(`.scratch_mathlib_gate.mjs`, untracked scratch; Mathlib pinned at
1fb6b28816). Modeling choices pre-registered in the script header:
namespace-internal import graph, down(x) = x's transitive imports,
kernels = principal down-sets, pseudocomplement/double-negation in the
down-set algebra.

- **The geometry exists, and it is generic, not exceptional.**
  Mathlib.Order: 306 modules, 0 dense / 20 regular / 286 ordinary
  kernels. Mathlib.Topology: 658 modules, 0 dense / 11 regular / 647
  ordinary. This *inverts* the divisor-lattice picture (109/164 empty
  apertures): in wide sparse import posets ordinariness is the rule.
  Honest reading: the gate alone is not the discriminating instrument
  here; the cell-occupancy profile is.
- **The node-empty-cell filter is sharp: 647 → 4.** In Topology,
  exactly four ordinary kernels have a node-empty cell, and they are
  one cluster: `Mathlib.Topology.CWComplex.Classical.*`, each with
  Distribution = 0. Verified by hand: `CWComplex/Classical/Basic.lean`
  imports *nothing* from Mathlib.Topology (enters via Analysis) — a
  genuine island the instrument found mechanically. Nothing in the
  namespace both builds on CW complexes and touches the rest of
  Topology.
- **Pre-registrable prediction (first forward prediction from the
  instrument):** as Mathlib grows, the CWComplex cluster's
  Distribution cell fills (bridging modules to Homotopy etc.) or the
  cluster is re-founded on Topology-internal imports. Testable
  against any future Mathlib revision by rerunning the script.
- **Regular kernels = the classical shadow, as predicted:** the 20/11
  gate-failures are leaf or near-isolated modules (|foundation| ≤ 3)
  whose cone closure adds nothing — the Boolean-pocket picture
  holding in the wild.
- Caveats logged: namespace-internal restriction (paths leaving and
  re-entering via other namespaces are invisible; the island reading
  is relative to that choice); principal-kernel scope; single
  revision, no baseline yet. Next steps if pursued: full-Mathlib
  graph (declaration-level or module-level), aperture computation
  (needs nuclei on general down-set algebras — the r > 2 / general
  distributive lattice open problem, so this doubles as
  reconnaissance for it), and a historical-revision backtest of the
  gap prediction.

## Status update, 2026-08-19 (later): subspace nuclei crack the general case; latency found in the wild

Follow-up to the morning's gate run (`.scratch_subspace_nuclei.mjs`,
untracked scratch; pre-registered header). Three results, in
ascending order of importance:

- **The subspace-nucleus correspondence [computed, likely (C)].** For
  finite P, nuclei on Down(P) are exactly the subspace nuclei
  j_S(A) = {p : ↓p ∩ S ⊆ A}, one per S ⊆ P, so #nuclei = 2^|P| and
  Fix(j_S) ≅ Down(S). Verified from the axioms two independent ways
  (fix-set enumeration on 12 posets: chains, antichains, V, Λ,
  diamond, fence, unions, 5-pt mixed; raw enumeration of all
  inflationary maps on the small ones). This should be classical —
  finite frames have only spatial sublocales — so the grade target is
  [C] with citation (Johnstone / Picado–Pultr; find the exact
  statement before using it in print). Consequence, and it is large:
  **the aperture problem on ANY finite distributive lattice reduces
  to combinatorics on sub-posets**:
      Ap(a) = { S ⊆ P : a ∩ S ordinary in Down(S) }.
  The general closed form (the paper's named open problem) is now
  "count the S with a∩S ordinary" — Theorem 5.1's chain counts are
  the disjoint-union-of-chains special case.
- **Third-way anchor check.** Down(chain2⊔chain1) ≅ Div12,
  Down(chain2⊔chain2) ≅ Div36; aperture sizes computed by subset
  enumeration match the closed form on all 15 elements, Ap(2) =
  {identity} on Div12, and the Div36 latent pair comes out as
  S = {p1,p2,q2} and {p2,q1,q2} — exactly the even-grid and
  threes-grid hearings of the kernel-checked anchors. The closed form
  has now survived a representation it was not derived in.
- **Latency exists in formalized mathematics [computed].** Sub-poset:
  the 18-module foundation cone of Mathlib.Order.Antisymmetrization
  (pre-registered pick: largest foundation ≤ 18; Mathlib pinned
  1fb6b28816). All 2^18 = 262,144 worlds enumerated per kernel.
  11/18 principal kernels are LATENT: dense at identity (inside one
  cone every foundation shares the base, so ¬a = ∅ at full
  resolution) but ordinary in thousands of proper worlds (aperture
  fractions 0.1%–3%). Reading: within a dependency cone, four-position
  structure around a module exists only for observers who do NOT
  register the common foundations. One kernel is ordinary at identity:
  Defs.PartialOrder, with |Ap| = 32768 = 2^15 exactly — a suspiciously
  clean count (2^(|P|−3)) that smells like the first data point of the
  general counting theorem.

**Null model result (same day, `.scratch_latency_null.mjs`): the
latency finding SURVIVES, against the pre-registered expectation.**
Null = 60 degree-preserving double-edge-swap rewires of the real
Mathlib.Order DAG (forward edges wrt a fixed topological order, so
in/out-degree sequences exact), same pre-registered cone pick, same
analysis, seeded PRNG (20260819). The pre-registered expectation was
that latency is generic cone geometry and Mathlib would sit in the
null's central mass. Wrong, on every metric:

    latentFrac   null 5/50/95% = .167/.278/.556   observed .611  (above all 60)
    ordIdFrac    null 5/50/95% = .389/.556/.722   observed .056  (below all 60)
    meanApFrac   null 5/50/95% = .186/.292/.449   observed .016  (below all 60)
    maxApFrac    null 5/50/95% = .508/.702/.842   observed .125  (below all 60)

Reading: degree-matched random cones have COMMON full-resolution
ordinariness and WIDE apertures (structure robust, visible to many
observers). The real Mathlib cone is the opposite: full-resolution
structure is rare (foundations heavily shared, density generic),
latency is elevated, and apertures are ~18x narrower than random —
structure exists, but only for few, specific coarse-grainings. The
degree sequence does not explain this; real formalization practice
is doing something (consolidation through shared foundational
modules) that the aperture instrument detects. Caveats: one cone,
one namespace, 60 replicates (one-sided p ≈ 1/61 per metric,
metrics correlated); replicate across namespaces and cones before
this becomes a claim with a grade. The wrong pre-registered
expectation is part of the record — the instrument outran the
operator, which is what instruments are for.

**Replication study (same day, `.scratch_latency_replication.mjs`):
2 of 3 namespaces replicate; Algebra does not.** Pre-registered
design: namespaces Order/Topology/Algebra, top-5 cones (foundation
≤ 18) per graph, 30 degree-preserving rewires per namespace,
criterion = latentFrac ≥ null-95 AND meanApFrac ≤ null-5 on the
5-cone mean. Results, reported without reinterpretation:
  - Order: REPLICATES (latentFrac .611 above all rewires; other
    three metrics at 0th percentile). Caveat found in passing: the
    top-5 Order cones share nearly all content (overlapping
    foundations), so this is closer to one confirmation than five.
  - Topology: REPLICATES (latentFrac .756 at 100th pct, ordIdFrac
    .000 at 0th, meanApFrac at 3.3rd).
  - Algebra: does NOT replicate. Directionally consistent
    (percentiles 93.3 / 5.0 / 6.7 / 3.3 — all near the tails) but
    misses both cutoffs. Post-hoc observation (flagged as such): the
    five Algebra cones split into two regimes — three
    narrow-aperture consolidated cones like Order/Topology, and two
    cones (Homology.SpectralObject.HasSpectralSequence,
    Order.Monoid.Canonical.Defs) with latent = 0, ordId ≈ .85, wide
    apertures — i.e. cones that look like the RANDOM regime. The
    within-namespace heterogeneity is real signal for a follow-up
    with cone-level (not namespace-mean) statistics and
    non-overlapping cone selection.
Status of the claim: "real Mathlib dependency cones are
narrow-aperture vs degree-matched null" holds in Order and Topology,
is directionally supported but not established in Algebra, and the
next design must fix the two flaws this run exposed (overlapping
cones; namespace-mean masking a bimodal cone population).

**Deflation test 1 (same day, `.scratch_deflation_invariants.mjs`):
NOT deflated.** Threat tested: the narrow-aperture finding might be a
repackaged simple graph statistic. Four pre-registered invariants per
cone (mean pairwise foundation Jaccard J, normalized depth D, minimal
fraction M, mean foundation fraction F), 315 cones pooled (15 real +
300 from 20 rewires × 3 namespaces, seed 20260820). Results: all
Spearman correlations with aperture metrics weak (best |rho| = 0.389,
F vs meanApFrac; J — the honest-expectation favorite — essentially
zero). Matched comparison on F: 13/15 real cones below their
invariant-matched null median (criterion was ≥ 2/3). The two
exceptions are exactly the two flat Algebra cones already identified
(SpectralObject, Monoid.Canonical) — consistent with the two-regime
picture, not a new anomaly. Deduped for overlapping cones (Order and
Topology top-5s largely coincide): ~7/9 distinct cones below, still
passing. Caveat: this rules out these four invariants, not all
conceivable ones; a smarter statistic could still deflate, and we
should keep inviting candidates. Bridge status: correspondence 4
(aperture as static irreducibility signature, not reducible to depth
or overlap) survives its first serious challenge. Remaining deflation
tests, in order of danger: git-history flow (does flat material
consolidate? kills the developmental story if not), and the
generalized bimodality check (cone-level stats, non-overlapping
cones, more namespaces).

**Git-history flow test (same day, `.scratch_history_flow.mjs`;
snapshots in `.scratch_mathlib_hist/`, git-archive extracts at
2023-09/2024-03/2024-09/2025-03/2025-09 + HEAD pin):** verdict mixed
in an informative way — P1 pass, P2 split, P3 2/3 with a named
counterexample.

- **P1 (library flow): PASS.** All six pre-registered trends point
  the predicted way: latentFrac rises / meanApFrac falls over the
  six checkpoints in every namespace (Order +0.94/−0.89 Spearman,
  Topology +0.60/−0.43, Algebra +0.43/−0.31). The frontier-cone
  aperture profile of the library consolidates over three years.
  Caveat: n = 6 checkpoints, no significance claim; Order's sharp
  2025 narrowing may ride a specific refactor event.
- **P2 (cohort flow): SPLIT — the monotone-narrowing prediction is
  falsified for young cones and confirmed for old ones.** All five
  Order apexes (old modules) narrow with age (trends −0.43..−0.60).
  All three traceable young Topology apexes WIDEN (+1.00): born as
  thin chains (cone size 4–9, meanApFrac ≈ 0), they broaden while
  under construction. The life cycle is non-monotone: born
  thin-narrow → widen during construction → consolidate narrow.
  The pre-registered strict prediction dies; the refined life-cycle
  description is post-hoc and needs its own pre-registered test.
- **P3 (youth of flat cones): 2/3.** SpectralObject (HEAD only) and
  CWComplex (born 2025-03) are young as predicted.
  **Order.Monoid.Canonical.Defs is the counterexample:** present
  since 2023-09, and its cone has consistently WIDENED (ap 0.12 →
  0.44, latency 0 throughout). Post-hoc reading, flagged as such:
  the flat regime may track ROLE, not age — `Defs`-style
  definitional interface files stay wide-shallow by design while
  theorem-mass consolidates into narrow towers. If that holds under
  a pre-registered test (classify cones by apex role, compare
  profiles), the two regimes become: maintained reducible interfaces
  vs consolidating irreducible towers — which is a sharper bridge
  statement than the age story, not a weaker one.

Bridge status after three deflation-adjacent tests: the static
signature survived degree-matched and invariant-matched nulls; the
dynamics exists at library level (P1) with a non-monotone cohort
life cycle (P2) and a role-dependent persistent-flat class (P3).
Next pre-registerable design: role-classified cohort study (Defs vs
theorem apexes), plus more checkpoints to firm up P1.

**Role-classified cone study (same day, `.scratch_role_study.mjs`):
the role hypothesis FAILS; the age/life-cycle story stands.**
Pre-registered design: 126 deduped cones (size 10–18) across the
three namespaces at HEAD; role = cone-aggregate declaration mix
(defFrac ≥ 0.5 = interface), secondary name-based classifier
({Defs, Notation, Init} path component); age from the 2023-09 /
2024-03 snapshots. Results, reported without re-thresholding:
  - Primary classifier had zero dynamic range: NO cone reaches
    defFrac 0.5 (theorem-like declarations dominate every cone's
    aggregate). R1/R3 untestable as registered — a design failure,
    logged as such.
  - Continuous check (R2): Spearman(defFrac, meanApFrac) = +0.106,
    (defFrac, latentFrac) = −0.079 — negligible. Declaration mix
    carries no aperture signal.
  - Name-based secondary: name-interface cones are NOT wider
    (medAp 0.098 vs 0.122 — slightly narrower). Defs-named cones
    span both extremes (UniformSpace.Defs among the narrowest,
    Prime.Defs among the widest).
  - Age effect present in the same sample: old cones medAp 0.081 vs
    young 0.131 — young wider, consistent with the life-cycle
    account (born thin → widen under construction → consolidate).
Verdict: the post-hoc "maintained reducible interfaces" reading from
the history test is withdrawn. Canonical.Defs stays on the books as
an individual unexplained anomaly (old, flat, widening), not the tip
of a class. The bridge keeps: static narrow-aperture signature
(survived two nulls) + library-level consolidation arrow + a
non-monotone cohort life cycle. It does NOT get the designed-pockets
architecture — that reading lasted three hours, which is what
pre-registration is for.

**Citation hunt + novelty scan (same day): all three questions
resolved.**

1. *The subspace-nucleus correspondence is classical, precisely
   located.* Simmons, "Spaces with Boolean assemblies", Colloq.
   Math. 43 (1980), Thm 4.5: for a T0 space, the assembly N(ΩS) is
   Boolean iff S is scattered. Poset/Alexandroff form: Bezhanishvili
   et al., "The Frame of Nuclei of an Alexandroff Space", Order 37
   (2020), arXiv:1906.03640 — N(O S) Boolean iff S is noetherian.
   Finite posets are noetherian, so the assembly is Boolean on 2^|P|
   atoms = our subsets-of-P census; Beazer–Macnab (Colloq. Math. 41,
   1979) has the algebraic condition. Part A of script 02 regrades
   [C]; the aperture reduction Ap(a) = {S : a∩S ordinary in Down(S)}
   built on top appears unclaimed — the intersection (ordinariness
   relativized to worlds + counting) remains ours, consistent with
   the paper's earlier novelty scan.
2. *Nearest empirical neighbor exists and is brand-new:* "The
   Network Structure of Mathlib" (arXiv:2604.24797, 2026; Toronto/
   UCLA/UCL/Google/Rutgers; dataset MathNetwork/MathlibGraph on
   HuggingFace — 308k declarations, 8.4M edges, module + declaration
   + namespace layers, historical commit pinned). Pure network
   science: PageRank, betweenness, Louvain, DAG layers. Zero
   Heyting/locale/nucleus content (grepped). Our instrument is
   orthogonal (their toolkit cannot express "verdict inside a
   coarse-grained world"), their dataset is directly usable for a
   declaration-level rerun, and the authors are candidate empirical
   collaborators.
3. *Wolfram alignment is exact and the gap is real:* the Wolfram
   Institute's own 2026 survey (Wiles, "Computational Metaphysics")
   names "identifying reducible pockets in the ruliad" as a key open
   problem; observer theory (Wolfram 2023 essay, 2026 metaphysics
   essay) remains informal — no observer census, no computable
   pocket criterion anywhere in that ecosystem. Our offering maps
   1:1: complete finite observer census (Boolean assembly, [C]),
   computable pocket criterion (ordinariness inside the world, [K]
   bridge), closed form on chains ([K]), null-tested empirics on
   real computation records ([computed], mathlib-study/). No prior
   art found applying nuclei to dependency graphs (word-collisions
   only: a localic-measure-theory blueprint graph, a Varela/ECI
   self-reference project).

Collaboration artifact decision pending: a working paper pitched at
the Wolfram Institute framing mathlib-study as "a computable
observer census and pocket-of-reducibility criterion for static
computation records, demonstrated on Mathlib with pre-registered
nulls" — their named open problem, our instrument, no publication
gate required.

Next when this thread resumes: (1) restate the reduction as a lemma
with the Simmons/Bezhanishvili citations (done in mathlib-study
README; propagate to the aperture paper when it next opens);
(2) mine the Part C aperture counts (284, 1020×2, 3892, 4356, 5344,
5888, 5916, 6780, 7728, 2^15) for the shape of the general formula —
these are exact values on a real 18-point poset, ideal test data;
(3) consider whether the Algebra Universalis extraction should state
the subspace reduction (it strengthens the paper from "two-prime
closed form + open problem" toward "general reduction + solved
chain case"); (4) Lean-check the correspondence on small P via
`decide` if cheap.

## Status update, 2026-08-24: latency rule corrected; closed form [K] at every arity

Two events, same day, causally linked:

- **The latency characterization was wrong, and the instrument
  caught it.** Div180 element 30 (exponents (1,1,1), 5-exponent at
  its chain top) has aperture 4 by the paper's own closed form —
  refuting the "every exponent strictly interior" rule in the
  false-negative direction. The violation hunt then found the
  false-positive direction too: Div8 elements 2 and 4 are
  all-interior with aperture 0 (single chain, no second coordinate).
  All three witnesses were sitting, unread, in the published
  164-element verification set; the ten-algebra sweep confirmed the
  wrong rule 10/10 only because every sweep lattice was two-prime or
  square-free — exactly where wrong and right rules coincide.
  Corrected rule (paper Result 6.3): **Ap(d) ≠ ∅ iff some exponent
  strictly interior and some other chain below its top; latent iff
  additionally no exponent is zero.** Verified 164/164 vs
  enumeration + 252 formula-only points
  (`latency-characterization-correction.mjs`). Square-free and
  Div(2^a·3) impossibility results survive. Paper bumped to v0.3
  with the correction dated; original pre-registered headers kept
  with postscripts. Fourth time the instrument has overruled the
  operator.
- **The r > 2 Lean iteration closed the same day**
  (`Lattice/ApertureClosedFormPi.lean`) — pulled forward because the
  correction produced witnesses only a general-arity theorem could
  kernel-check. Not by folding the binary assembly: the Pi statement
  is proved directly (`nucleusPiEquiv` via `x = ⨅ i, update ⊤ i (x i)`;
  coordinatewise world predicates; `aperture_card_add_eq_pi`, whose
  two inclusion-exclusion events do not multiply with arity).
  `aperture_closed_form_pi` is Theorem 5.1 verbatim on
  `Π i : Fin r, Fin (aᵢ + 1)`, any r. `decide`d cross-checks:
  Div180/30 = 4, Div8/2 = Div8/4 = 0 (the correction witnesses,
  kernel-certified), Div12 = 1 (re-meeting `aperture_two_complete`).
  Axiom audit clean; full `lake build` green. **Theorem 5.1 is [K]
  on all divisor lattices.** What stays [computed]: the exhaustive
  sweeps and Result 6.3's general "iff" (its formula and witnesses
  are [K]). Design notes part 7 has the Lean decisions.

## Status update, 2026-08-25: Study 10 (Life causal cones) — protocol died twice, honestly

The Game of Life pilot (`ca-study/`) ran its full arc in one day:

- **v1.0 died by inspection, before any run.** The registered syntactic
  edge rule (every Moore pair, values never consulted) makes the causal
  DAG state-independent: conditions A–E produce isomorphic depth-d
  pyramids, N2 (rule randomization) is provably a no-op, and the budget
  forces depth 1 = the 9-antichain-under-a-top, whose kernels are all
  dense or regular. P1–P4 would have failed as theorems about the
  construction. v1.0 is committed unexecuted with the proof as its
  postscript. General diagnostic kept: *if a randomization cannot change
  your object, your object does not depend on what you randomized.*
- **v1.1 (counterfactual single-flip edges, all parameters pinned) was
  registered, committed at `0b1c40a`, and executed.** Anchors 8/8
  (Div12/Div36 kernel-checked values reproduced). Census: counterfactual
  cones around live structure grow fast (glider 9 → 27 → 57), so 21 of 29
  cones landed at depth 1. **P1 FAILED** (Mann–Whitney p = 0.738; stop
  rule applied, nulls not run). Postmortem: every depth-1 cone is a fan,
  and Down(fan) is a powerset with a dense top glued on — aperture
  identically 0 in every world, provable in two lines. The budget policy,
  not the invariant, decided the outcome; both pools were structural
  zeros. The v1.0 postscript had already named the pyramid as blind; the
  amendment changed which two-layer poset the budget buys, not the
  blindness of two-layer posets.
- **What the deep cones showed (descriptive only, cross-depth, not
  licensed as claims):** still lifes have the thinnest counterfactual
  margins and hence the deepest in-budget cones — beehive (n=15, d=3)
  14/15 latent, medAp 0.153; loaf (n=16, d=3) 15/16, 0.171 — an order of
  magnitude wider than depth-2 soups (0.004–0.016). Soup-20260825005 has
  the substrate's first ambient-ordinary kernels. Figure-against-quiet-
  ground is where the instrument's budget goes deepest, which is where
  the interpretive hypothesis lives — suggestive, unproved, unclaimed.
- **Named follow-up, not run:** v1.2 depth-matched design (fixed d = 2
  all conditions, all-kernel enumeration under a wide-mask engine or a
  budget raise to n ≤ 24). Requires a new pre-registration. Pending
  manual step: the WL twin (`ca-study/wl/ca-aperture.wl`) in Wolfram
  Cloud to confirm the Node-side P1 negative.
- Fifth instrument-overrules-operator event, second within this study.
  Lesson recorded: *a budget policy is part of the instrument, and it can
  be the part that goes blind.*

## Status update, 2026-08-25 (later): Study 10 v1.2 — the real answer, and it splits

Depth-matched redesign registered cold (`PREREGISTRATION-v1.2.md`,
calibration 106/108 committed with it at `c64ce3c`) and executed same day:

- **P1′ (structured-vs-soup) FAILS as a genuine measurement** (p = 0.263).
  With the fan artifact removed, every cone carries real apertures, and
  gliders/oscillators/spaceships are statistically indistinguishable from
  soup. The v1.1 negative is confirmed by clean design. Post-hoc reading,
  flagged: soup at T = 8 is ash — still lifes and blinkers — so the
  registered contrast compared zoo objects to a population of the same
  kinds of objects; the question, not the instrument, may be ill-posed at
  this horizon.
- **P6′ (figure-vs-ground) HOLDS**: still-life cones ~17× wider than soup
  at matched depth (0.0977 vs 0.0057, MW p = 0.044). Caveat recorded: the
  signal rides on beehive/loaf's n = 9 cones and aperture fractions covary
  with cone size — but thin counterfactual margins ARE the still-life
  phenomenon, so signal and confound are entangled. Size-controlled
  follow-up named, not run.
- **Narrowness does NOT transfer**: real cones sit at percentiles 6-88 of
  their own 100 degree-preserving rewirings. The Mathlib ≈18× is a fact
  about curated dependency structures — the anticipated §8 reading of the
  aperture paper's empirical scope, now measured.
- **Latency is generic on the CA substrate** (67-94% of kernels in every
  non-trivial cone; first ambient-ordinary kernels found in oscillator and
  soup cones). Cross-substrate picture: latency rare on divisor lattices,
  generic on Mathlib, generic on Life — full-resolution ordinariness is
  the exception in the wild.
- **N2**: random matched-density rules kill the pattern before T = 8 in
  45-60% of runs; where defined, apertures run 0-0.0018 vs Life's
  0.0037-0.0147 on the same seeds. Life makes wider-aperture causal
  structure than a random rule of equal table density [descriptive].
- Pending: WL cloud run (`ca-study/wl/ca-aperture.wl`) to confirm the
  Node-side primary cones; size-controlled P6′ follow-up as a fresh
  registration.

## Status update, 2026-08-25 (final): Study 10 v1.3 — the follow-up killed P6′; study closes negative

The size-controlled registration (`PREREGISTRATION-v1.3.md`, committed at
`e7252b2` with a sizes-only pre-check — no aperture computed before
registration, so the predictions stayed blind) ran the same day:

- **P7 (size-controlled figure-vs-ground) FAILED decisively** (stratified
  permutation test across matched strata n = 9/16/23, one-sided p = 0.364).
  Stratum medians B vs E: 0.09766/0.09766, 0.01559/0.01559,
  0.00743/0.00753 — essentially identical everywhere.
- **S1 resolved the failure as deflation (R3):** still-class vs
  active-class soup cones at n = 9 indistinguishable (p = 1.0). The v1.2
  ~17× was the size law read across strata (E-side medians
  0.098 → 0.016 → 0.0075 over n = 9 → 16 → 23).
- Sharpest fact in the raw output: **all ten n = 9 cones — beehive, loaf,
  pond, and every matched soup focus — share a single per-kernel aperture
  multiset.** One structural class. At the smallest matched size the
  "comparison" was between identical algebra objects.
- **The CA study closes fully negative on every differentiation claim**
  (P1, P1′, P7, S1). What stands: latency generic, narrowness scoped to
  curated corpora, the size law [descriptive]. Both briefs updated in the
  same commit — the still-life lead retracted at the prominence it was
  reported.
- Sixth instrument-overrules-operator event: the substrate's one positive
  lead, killed by its own registered follow-up within hours of being
  reported. The disclosed prior (block already sitting in the soup range
  at n = 23) pointed the right way.
- Any return to this substrate needs a construction that breaks
  size-dominance (deeper horizons, different edge relations, intensive
  invariants) — an open design question, not a scheduled study. Pending
  manual step unchanged: the WL cloud confirmation run.

## Status update, 2026-08-26: the consolidation arrow survives its nulls; the cell dictionary gets its first test

Two studies, both registered before running (scripts 08–12 in
`mathlib-study/`), both closing gaps the record had named:

- **Per-snapshot nulls for the consolidation arrow (08) — NP1: 6/6,
  SURVIVES.** 30 degree-preserving rewires per checkpoint × namespace,
  identical pipeline including the cone-pick rule. The sharper fact than
  the criterion: 2023-09 observed values sit *inside* their null envelopes
  (latency percentiles 10–47), 2025-09/2026-05 sit at the extremes (100 on
  latency, 0–3 on aperture, all three namespaces). Early Mathlib was
  statistically indistinguishable from its degree-random twin; mature
  Mathlib is not. The arrow is a departure from degree structure, not a
  growth artifact — exactly the confound class v1.3 caught on Life, tested
  and excluded here. NP2 (continuity with 03/04) holds. The program's
  flagship computational finding is now null-controlled end to end.
- **Cell-composition study (09–12) — the dictionary tested where ground
  truth is cheapest.** v1 (10) died by instrument saturation: shared-prefix
  *median* pinned at 2.00 everywhere, permutation null degenerate at
  [0,0] — the null-that-cannot-move diagnostic again; lesson recorded
  (blindness discipline does not excuse skipping a resolution check on the
  measure). v2 (12, resolution-checked k\*=3, pooled same-area statistic):
  **C1′ HOLDS decisively — Exploitation-cell modules occupy the kernel's
  named territory** (99th–100th pctile vs name-permutation null, all three
  namespaces): first corpus-level empirical support for a contentful cell
  reading, and for precisely the cell that exists only non-classically.
  C2′ fails (Distribution not intermediate); post-hoc and flagged: Refusal
  is name-*close* in Order/Topology — refusal happens on-territory.
  C0′ violated in Topology and explained (transitive foundations dilute
  I's proximity with deep roots).
- Outward documents updated in the same commits: the consolidation
  control-gap caveat resolved in both briefs; the cell-dictionary split
  verdict added; mathlib-study README carries scripts 08–12.
- Note for the record: the operator's stated prior after the CA deflation
  was that the consolidation arrow would likely die the same way. It
  didn't. The instrument cuts both directions.
- **Same day, later: the WL cloud confirmation ran (operator, manual).**
  Exact agreement on every exact-tier value — anchors, the four depth-1
  fans, the E d = 2 cone's sixteen per-kernel apertures, and all six v1.3
  still lifes including the single-class vectors. Two-implementation
  requirement closed for everything the CA study's verdict rests on
  (`ca-study/RESULTS.md`, confirmation section). No pending steps remain
  for Study 10.

## Status update, 2026-08-26 (later): the dictionary through full out-of-sample confirmation; Mathlib exhausted

The v2 postscript's two loose ends — the flagged post-hoc "refusal is
proximate" reading, and the never-established original D/R ordering —
were both taken to registration the same day (scripts 13–16), and the
corpus is now spent: all 21 Mathlib namespaces used.

- **G1 (14): Exploitation-on-territory replicates out-of-sample 13/13**
  (above the 95th null percentile in 11, zero reversals) across every
  held-out namespace ≥ 100 files. With the original three: **16/16
  registered, 20/21 including descriptive runs**. This is now the
  program's strongest corpus finding, full stop.
- **G2 (14): the corrected "refusal is proximate" reading is REFUTED**
  by significant reversal in 8 of 13 — Order/Topology were the outliers
  that generated it, not the rule. Seventh instrument-overrules-operator
  event, and the fastest: proposed, registered, and killed within a day.
- **G3 (16): the original "Distribution nearer than Refusal" ordering,
  scored on the final five fresh namespaces (sub-100-file), FAILS** —
  positive 2/5, significantly reversed in Logic and SetTheory, which
  pattern with Order and Topology. Final verdict for this corpus: the
  R/D geography is namespace-contingent in both directions; outward
  documents drop spatial language for those two cells (definitions [K]
  untouched — what died is geography, not algebra).
- Post-hoc, flagged, untestable here: the four refusal-proximate
  namespaces (Order, Topology, Logic, SetTheory) are Mathlib's
  foundational strata; the D-nearer namespaces are working mathematics.
  If R/D geography tracks foundational-vs-applied character, only a
  different corpus can say so.
- Outward documents updated per the pre-committed interpretation tables:
  both briefs, mathlib-study README.

## Status update, 2026-08-26 (evening): the AFP referendum — one graduation, one scoping

The referendum named after the Mathlib exhaustion ran the same day
(`afp-study/`, five scripts, blind pre-checks and registrations committed
before every run). Corpus: Archive of Formal Proofs, 1,014 entries,
topic-taxonomy ground truth, 22 years of history.

- **R1 HOLDS at the 100th percentile: Exploitation-on-territory is
  cross-ecosystem.** Full entry graph sED = +0.0334 vs null ±0.0055;
  descriptively 100th percentile in every stratum (Logic +0.385). Two
  assistants, two communities, two grains, two ground-truth instruments.
  This is now the program's flagship empirical claim, and it is earned.
- **R2 FAILS: the foundational-strata R/D reading does not replicate**
  (Logic sRD −0.032, percentile 20 — inside the null, wrong sign).
  R/D geography is dead on every corpus it has been scored on.
- **H1/H2: the consolidation arrow FAILS to transfer.** Latency rises
  (+0.83, as everywhere) but apertures WIDEN over 22 years (+0.64 vs
  required ≤ −0.6). Scoped to Mathlib in all outward mentions. Flagged
  post-hoc reading with testable content: maintained library vs frozen
  archive — consolidation may be what maintenance looks like. Candidate
  next corpus pair: a refactored codebase vs its package registry.
- Engineering note for the record: the pre-check's fixpoint closure hung
  on a JS signedness trap (`|` returns int32, Uint32Array reads
  unsigned); caught before any measurement, fix documented in-line.
- Outward documents updated per the fixed tables: referendum paragraphs
  added to both briefs; consolidation scoped; E-finding upgraded.

## Status update, 2026-08-26 (night): the growth-engine study — reversal, and a new division of labor

The dynamical extension of the E-finding ("residue-miners become
tomorrow's foundations") was registered and executed the same day
(afp-study 06/07: within-kernel, degree-matched E-vs-D contrasts over
six baselines 2012-2022, horizon 4 years, label-permutation null built
to kill preferential attachment).

- **GP1 FAILS by significant reversal** (G_ED = −0.33, pctile 0, null
  band ±0.03): at matched degree and neighborhood, DISTRIBUTION-cell
  members become load-bearing, not E-members. Eighth
  instrument-overrules-operator event. Died before reaching any outward
  document, as the fixed table required.
- **GP2 holds** (pctile 100): E outgrows R. Matched ordering: D > E > R.
- Post-hoc, flagged, unscored: the cell with no static geography (D —
  every spatial gloss dead) carries the dynamical signal; the cell with
  confirmed static geography (E) carries none. If "E owns geography,
  D owns dynamics" replicated on a fresh corpus (Mathlib history, with
  age matching — E-members run ~2 years older than matched D-siblings),
  the partition would be measuring two different arrows with two
  different cells. That registration is the natural next computational
  step.

## Status update, 2026-08-26 (late): the growth replication — opposite reversal, and the garden/museum axis sharpens

The AFP growth reversal was registered as the hypothesis on Mathlib's
history (mathlib-study 17/18: degree x exact-age matching, 38k matched
cells, label-permutation null).

- **MG1 FAILS by reversal in the OPPOSITE direction** (G_ED = +0.076,
  pctile 100, positive in all three namespaces): on Mathlib,
  EXPLOITATION-cell members become load-bearing; on AFP it was
  Distribution. Growth dynamics is corpus-contingent. The
  division-of-labor reading died one study after it was born. Ninth
  instrument-overrules-operator event.
- **MG2 holds** (E > R, pctile 100) — E > R is now the only dynamical
  statement confirmed on both corpora (twice, as registered secondary).
- Post-hoc, flagged, now the program's most interesting live pattern:
  the same two corpora split the same way on TWO independent
  measurements — consolidation direction (Mathlib narrows / AFP widens)
  and growth-cell identity (Mathlib: residue-miners grow / AFP: bridges
  grow). One axis: maintained garden vs frozen museum. The
  maintained-vs-archival software pair is now the most motivated unrun
  study in the program (would show all four quadrants under one
  registration).
- Per the fixed tables, nothing ships to outward documents from this;
  briefs untouched.

## Status update, 2026-08-26 (later): briefs updated; garden/museum protocol registered unrun

Decision taken in session: stop measuring, write. The growth double
reversal is now in both outward briefs — philosophers-brief §5 gains a
"growth studies" paragraph (both reversals, the axis as [H], scoped to
"a line through two points"); plain-brief gains "The growth question"
under the referendum section, in the walled-city vocabulary. Script
counts corrected (mathlib eighteen, afp seven).

And the software pair is handled the strong way: registered as an
unrun protocol, committed before any acquisition —
`software-study/PROTOCOL.md` v1.0. Pair fixed (Go stdlib garden /
crates.io museum, immutability platform-enforced on the museum side),
manipulation check gates scoring (MC1 3x rewiring ratio, MC2 kernel
evaluability), four-quadrant predictions with the thresholds and null
designs inherited from mathlib-study 08/18, failure semantics
including the diagonal case, prior stated honestly (registered
operator hypotheses 0-for-9). Both briefs point at it. Anyone can run
it; the paper gets its standing falsifiable prediction either way.
Next: the synthesis write-up.

## Status update, 2026-08-26 (evening): the synthesis exists

`preprints/field-deployments/paper.md` v0.1 — the account of record for
the 08-19..08-26 field campaign, written for a reader who wasn't
present. Structure: the instrument in five sentences (with the
Simmons/Bezhanishvili reduction as the enabling fact); corpora and the
uniform discipline; what survived (E-on-territory cross-ecosystem,
latency generic, E > R as the one dynamical statement); what was
scoped (narrowness to curated corpora, consolidation to maintained
ones); the graveyard at full prominence (all nine
instrument-overrules-operator events enumerated in order, the two
instrument deaths with their portable diagnostics, the Life clean
negative with the commitment-not-computation reading flagged [A]);
the garden/museum table and the armed protocol; not-claimed;
reproducibility. No new runs, no new claims — every number
cross-checked against the study READMEs before writing. Both forward
predictions (CWComplex island; software pair) are on its last pages.
Philosophers-brief pointers now lead with it.

The third companion is drafted next: **the four positions of the
temperament commitment, one work per cell, fully worked** — the
cultural wager alongside the mathematical (aperture) and perceptual
(hearing) papers. Suggested location: `preprints/positions-casework/`
(or `papers/` if it stays essay-register). It can now stand on
Bach-at-the-Kernel v0.3 §4 instead of rebuilding the aperture layer.

Structure agreed in session 2026-08-16:

1. **Kernel and dictionary, committed once.** Kernel = the 12-EDO
   temperament commitment; the work→element dictionary stated up
   front, [A], defended per case. The 4-cell theorem's exclusivity is
   the discipline: one cell per work *per committed reading*; arguing
   a different cell requires changing the reading and defending the
   change.
2. **Four case studies, one per cell, each with its falsification
   condition stated** (what would force a different cell under the
   same reading):
   - Infrastructure — *Well-Tempered Clavier* (load-bearing
     demonstration from inside the commitment);
   - Distribution — the common-practice modulation system /
     enharmonic pivot practice (the shakiest chair; say so);
   - Exploitation — *Giant Steps* (the major-third cycle as
     equal-temperament surplus; the symmetry exists only in 12-EDO —
     mining the residue), with blues intonation as the other corner;
   - Refusal — Partch (43-tone just intonation; nearly self-evident,
     say so), Johnston / La Monte Young as secondary witnesses.
3. **Fragility profiles — the new instrument.** For each work, not
   just "which cell" but "under which of the eight hearings does its
   cell survive": Refusal needs the dense half alive, Exploitation
   the regularity gap, so the four works have *different computable
   collapse profiles*. Wire to the actual Div12 aperture data
   (Ap(kernel) = {identity} [K] bounds everything: at full blur-depth
   all placements die together; the profiles differ in *how* they
   die — dense-side vs regular-side, per the worksheet verdicts).
4. **Honesty apparatus:** Tymoczko's standing skepticism (does the
   comma still actively matter on fixed-tuning instruments) logged in
   the paper, not smoothed; the resolution-dependence finding (Paper
   2 §3.7, 21% alignment) cited as measured cost; grades throughout
   ([K] the partition/aperture facts, [A] every placement, no
   quiet upgrades).
5. **Feed-forward:** the fragility profiles double as the epistemic
   paper's T2/T3 theses running on real cultural material — this
   study is evidence infrastructure for the epistemology, not a
   detour from it.

Also pending from this weekend, lower priority: the epistemic reading
paper (`preprints/epistemic/` — grain-of-description dictionary,
T1–T4, statistical-mechanics latency case study); the r > 2 Lean
iteration (DONE 2026-08-24); pre-arXiv due diligence (2026-08-15
entry).

## Status update, 2026-08-27: the software pair executed — the garden/museum axis dies; first operator hit

The registered protocol ran end to end in one day (`software-study/`,
scripts 01-04; results as dated postscripts in the scripts and
PROTOCOL.md). Sequence: acquisition (golang/go bare clone; crates
history recovered from crates.io-index-archive snapshot branches after
the live index proved squashed), blind census (one plumbing repair
logged: Go build-ignored generator files were creating a false SCC),
gates (MC1 rewiring ratio 3.13 >= 3, narrowly; MC2 6/6 checkpoints
both corpora), then the registered quadrants.

- **Q1-CONS FAILS by absence.** Go trends down (Spearman -0.71) but
  the mature checkpoint sits at pct 43 of its own degree-preserving
  nulls. The garden did not consolidate. SP1 fails on both corpora —
  latency FALLS on Go, flat on crates. The latency arrow is now
  scoped to proof libraries; the consolidation arrow to Mathlib alone.
- **Q2-CONS holds** (predicted absence — the weak half).
- **Q1-GROWTH HOLDS.** G_ED = +0.40, null ±0.06, pct 100. On Go,
  E-cell members out-grow degree- and age-matched D siblings. **The
  operator's first registered directional hit (record now 1-11).**
- **Q2-GROWTH FAILS BY REVERSAL.** crates.io grows through E at
  G_ED = +5.83 vs null ±0.59 — the largest effect ever measured in
  the program. The museum grows through its shadows too.

**Verdict: the garden/museum axis is dead on both rows.** What
replaces it: E out-grows D on Mathlib, Go, and crates.io — maintained
and archival, proofs and software — and reverses only on AFP. The
anomaly to explain is AFP (refereed-acceptance gate as first suspect,
post-hoc), not a maintenance regime. Docs updated same day: both
briefs, the synthesis paper (v0.2, §5 graveyard items 10-11, §6
rewritten), the piano essay's gardens-and-museums section.

## Status update, 2026-08-27 (late): Phase 1 — true forward registration live

`predictions/REGISTER.md` + frozen baselines + frozen scorer, committed
and pushed. Four bets, horizon 2028-07-01 (last commit on or before):

- P1 Go, P2 crates, P3 Mathlib (Order/Topology/Algebra): **G_ED > 0 at
  >= 97.5th pct** — "E is the growth engine" as genuine prediction.
- P4 AFP: **G_ED < 0 at <= 2.5th pct** — the referee bet (the reversal
  is institutional, so it persists).

Baseline cell memberships frozen at the 2026 checkpoints
(`frozen-2026.json.gz`, deterministic seed 20260827881: mathlib 450
kernels / 7,711 cells; go 355 / 5,384; crates 100 / 2,331; afp 511 /
4,626). Scorer `02-score-2028.mjs` frozen now (estimator, null, seed
20280701, MIN_CELLS=30 uninformative floor); plumbing smoke-tested
against baselines (all-zero gains, as constructed). Since no horizon
data exists, nothing in the freeze can leak — this is the program's
first registration where peeking is physically impossible.

Remaining spec phases (registered in chat, 2026-08-27): Phase 2 the
referee study (RF1 within-AFP library labels; RF2 Isabelle
distribution grows through E — the decisive one; RF3 a refereed
archive outside formal proof). Phase 3 Study 11 phase one (observer
kinematics on Div12..Div72; verify Simmons direction first; T3 stop
rule). Phase 4 the Wolfram Institute package, after P1-P4 are on
record. Music study stays parked until the formal arc closes.

## Status update, 2026-08-30: RF2 executed — the referee hypothesis dies

Phase 2 of the post-synthesis spec ran end to end (`isabelle-study/`,
scripts 01-03; registration committed before the run; blind census
first). The controlled contrast could not have been cleaner and the
answer could not have been more decisive:

- Corpus: the Isabelle DISTRIBUTION's theory-import graphs, eleven
  biennial checkpoints 2006-2026 (834 -> 1,843 theories, perfectly
  acyclic at every checkpoint). One plumbing repair logged: checkpoint
  resolution restricted to the first-parent line (the hg-converted
  history handed 2010 a grafted jEdit-only side commit).
- **RF2 FAILS BY REVERSAL**: G_ED = -0.0208, null [-0.0025, +0.0027],
  percentile 0 (9,675 kernels, 103,641 matched cells). The
  distribution grows through D, like AFP — same community, opposite
  institution, same regime. **The referee hypothesis is dead.**
- Secondary E > R holds (pct 100) — now on every corpus measured.
- Six-corpus record: E > D on Mathlib/Go/crates; D > E on
  AFP/Isabelle-dist. Dead axes: maintained/frozen, refereed/open,
  proofs/software, entry/file grain. The reversing pair uniquely
  shares the Isabelle ecosystem. No replacement hypothesis registered.
- P4's rationale postscripted in predictions/REGISTER.md (bet stands).
- RF1 (AFP library-label sidebar) still deferred; RF3 (RFC series)
  registered unrun in isabelle-study/README.md — note its prediction
  (D grows in refereed archives) was written before RF2 killed the
  referee mechanism; if executed, reframe first or expect it to score
  the Isabelle-ecosystem question instead.
- Operator's registered-directional record: 1 for 13.

## Status update, 2026-08-30 (later): the deflation control — E > R splits by domain

The program's last universal survivor was put on trial
(`deflation-control/`, lib + blind pre-check + registered run;
occupancy pre-check committed before the run, interpretation table
fixed in advance, operator prior on record leaning deflation). The
skeptic's compression of E > R — "connected periphery grows,
disconnected doesn't" — is a connectivity claim degree matching can't
touch, so the growth estimator was re-run with EXACT undirected
BFS distance to the kernel's down-set added to the matching key
(degree bin x first-seen x exact distance), on all five corpora with
history.

- Blind pre-check first: the confound is real (E masses at distance
  1-4; R spreads to 15+ with huge unreachable populations — AFP 205k,
  Isabelle 2.9M, crates 8.8M members) AND the matched comparison
  exists everywhere (420 .. 110,174 cells). Both facts structural,
  no gains read.
- **DC1 verdicts: mathlib NULL (obs 0.006, pct 79); AFP REVERSES
  (-0.103, pct 0.3); Isabelle-dist REVERSES (-0.113, pct 0);
  Go HOLDS (+2.42, null ±0.51); crates HOLDS (+15.68, null ±3.58).**
- Reading: in package ecosystems the cell predicts growth beyond
  degree, age, AND connectivity — the program's strongest surviving
  dynamical claim. In proof corpora E > R was connectivity in
  costume (Mathlib) or was masking an R advantage (both archives) —
  which retroactively dissolves the "AFP anomaly": proof archives
  favor the refusal side at matched distance, full stop.
- DC2 (descriptive): E-vs-D is NOT a distance artifact anywhere —
  Mathlib's E > D survives at pct 100 (99,231 cells); the software
  E > D holds; the Isabelle-ecosystem D > E persists. So the 2028
  bets (which score E-vs-D) are untouched and their contrast is now
  known to be distance-robust retrodictively (postscripted in
  predictions/REGISTER.md).
- Docs: postscript + README in deflation-control/; field-deployments
  paper to v0.3 (abstract, §3.3 rewritten, dated postscript); both
  briefs and the piano essay updated — the "seedbed" language is now
  scoped to software ecosystems at every occurrence.
- Operator's registered-directional record: 3 for 18 (two hits, two
  reversals, one null in this study's five verdicts).

## Status update, 2026-08-31: the baseline gauntlet — crates deflates, Go survives everything

Strategy session first: the gatekeeper question. The compelling
sentence, if it exists, is "an algebraically defined cell predicts
future dependency growth beyond every standard graph predictor,
pre-registered, including one corpus measured after the hypothesis was
fixed." Two studies stand between here and that sentence: the baseline
gauntlet (standard-predictor battery) and the sealed Debian rank bet.
The gauntlet ran today (`baseline-gauntlet/`, blind balance pre-check
committed first; caliper 0.5 fixed from blind output).

- Design: within kernel x EXACT distance, greedy nearest-neighbor
  E-R (and E-D) pairs on z-scored [log in-deg, log out-deg, age,
  log PageRank, k-core], caliper 0.5, balance gate maxSMD <= 0.10,
  within-pair sign-flip nulls. Declared exclusions: betweenness
  (infeasible at crates scale), clustering coefficient.
- Blind pre-check pass 1 showed distance was the imbalanced dimension
  in one z-space; revised (still blind) to exact-distance groups —
  balance then passed everywhere at 0.5.
- **BG1 (Go) HOLDS**: Delta_ER +0.2198, null ±0.088, pct 100,
  182 pairs. Descriptive E-D also holds: +0.1529, pct 100, 11,478
  pairs. Go's cell effect has now survived degree, age, exact
  distance, out-degree, PageRank, and k-core simultaneously.
- **BG2 (crates) NULL**: Delta_ER -0.0348, pct 44, 61,444 pairs
  (E-D nulls too: +0.017, pct 60). Diagnosis: the deflation control's
  +15.7 lived inside the coarse degree bins (top bin unbounded);
  matched on fine-grained popularity the crates cell carries nothing.
  Preferential attachment hiding in the bin widths — found in-house
  before any referee.
- Per the pre-registered interpretation table: PARTIAL — claim scopes
  to Go; the Debian registration must name itself the tiebreaker.
- Docs: postscripts in 02 + field-deployments paper; README; both
  briefs and the piano essay tempered (seedbed now "one relentlessly
  tested world" + the Debian bet).
- Record: 4 for 20 (BG1 hit, BG2 miss).
- NEXT, in order: (1) Debian extractor + blind census; (2) sealed
  Debian bet — registered rank/direction: Delta_ER > 0 under the FULL
  gauntlet design (not the coarse-bin one); (3) if it lands, write the
  empirical paper for an MSR/EMSE-shaped venue and the lattice paper
  for Order; if it dies, the growth chapter closes scoped to Go and
  the program leads with E-on-territory + latency + the theorems.

## Status update, 2026-08-31 (later): THE TIEBREAKER LANDS — Debian holds under the full gauntlet

Same day, the whole plan executed (`debian-study/`, three scripts):

- Extraction: ten stable releases 2007-2025 (etch..trixie),
  main/binary-amd64, all parsing choices fixed in the header before
  any analysis (Depends+Pre-Depends, first alternative, unresolved
  virtuals dropped and logged). 17.7k -> 68.8k packages, monotone.
- Blind census: near-acyclic at every checkpoint (largest SCC <= 44),
  survival 70-81% at +2, kernel evaluability 2,400/2,773, pair
  feasibility enormous (268k ER pairs at caliper 0.5, maxSMD 0.0093).
  Caliper 0.5 fixed from this. Registration committed before the run.
- **DB1 HOLDS: Delta_ER = +0.0979, null [-0.0149, +0.0136], pct
  100.0, 264,330 pairs, maxSMD 0.0097.** The sealed out-of-sample bet
  landed on the first try, on a corpus untouched until the same day.
- Descriptive secondary, unpredicted, reported at equal volume:
  Delta_ED = -0.1554, pct 0 — Debian's D cell out-grows its E cell at
  matched everything (D > E > R), like the Isabelle archives, unlike
  Go. So E-vs-R (battery-proof, two ecosystems) and E-vs-D
  (corpus-contingent) are INDEPENDENT axes. Note for 2028: P1-P3
  score E-vs-D, and that ordering is now known to be corpus-local.
- THE GATEKEEPER SENTENCE EXISTS: "membership in an algebraically
  defined cell predicts future dependency growth beyond degree,
  out-degree, age, exact graph distance, PageRank, and k-core,
  pre-registered, on Go and Debian — one of them measured after the
  hypothesis was fixed — with crates.io's deflation reported
  alongside as the method catching its own artifact."
- Record: 5 for 21. Docs: postscripts in 03 + field-deployments
  paper; README; both briefs + piano essay updated.
- NEXT: write the two papers — (1) the empirical growth paper shaped
  for MSR/EMSE referees (Go + Debian primary, crates deflation as the
  methods showcase, proof-corpus reversals as scope); (2) the lattice
  paper (aperture closed form + factorization lemma) for Order or
  Algebra Universalis. Then outreach; stop collecting corpora.

## Status update, 2026-09-01: accretion study Phase A — THE SELF-TEST FIRED

The middle track began (accretion-study/, SPEC committed 08-31 before
any code). Phase A was supposed to map which growth rules produce
which signatures. It did something more important instead: the
registered instrument self-test (feature-blind rules must come out
NULL) FAILED, and the follow-up calibration found a program-wide
statistical flaw. Full record in SPEC.md postscripts; short version:

- Feasibility: rootless growth models cannot host the partition at
  all (universal ancestor -> Refusal empty -> nothing evaluable).
  Fixed openly in Phase A (m in {0..4}; uniform platforms).
- Exploratory grid: U and PA (provably null generators) returned
  significant verdicts under the pair-level sign-flip null.
- Replicate-universe calibration (20 universes/rule): the point
  estimator is UNBIASED, but the sign-flip null understates true
  across-universe variance ~9-11x. Kernel-clustered flips do NOT fix
  it: the dependence is universe-level. No within-corpus resampling
  recovers generator-level uncertainty. (Mathematical point, not a
  bug.)
- Real Phase-A discovery: PC(0) cone-local growth has a REAL,
  20/20-replicated signature: R > E > D at matched battery — the
  OPPOSITE of registered C2. The conjecture set needs rebuilding.
- Consequences for the field claims, recorded in a postscript in the
  synthesis paper: every single-corpus percentile is conditional on
  the realized corpus; generator-level claims rest on cross-corpus
  sign replication + sealed direction. Battery-grade E>R: Go +0.22,
  Debian +0.098 (sealed, landed), crates null. Evidence with honest
  error bars (~1.6-4 sigma if synthetic universe noise transfers),
  not "percentile 100." The 2028 register gains importance: fresh
  time is the only fresh randomness a corpus provides.
- Phase B as specced (single-universe verdicts) is CANCELLED;
  confirmatory design must be replicate-based (R fresh universes,
  across-universe mean vs SD). New conjectures from the Phase A
  landscape, anchored on the PC family's R > E > D.
- QUEUED (not yet done): temper "percentile 100" language in
  plain-brief, philosophers-brief, piano essay; decide the reframed
  gatekeeper sentence; then Phase B-prime registration; then Phase C
  (prove unbiasedness + the sign of the PC effect analytically).

## Status update, 2026-09-01 (later): Phase B′ CONFIRMS 3/3; Phase C on paper; queue cleared

Everything queued above is done, same day.

- **Editorial repricing, done.** Dated audit paragraphs added to
  plain-brief, philosophers-brief, and the piano essay (which also
  lost its stale "one sealed bet pending" closing — Debian already
  ran). The reframed gatekeeper sentence, now in the philosophers'
  brief: the E-over-R claim's warrant was never a percentile — it was
  found in one ecosystem and landed as a sealed prediction in an
  unrelated one, and that is the only currency the audit left standing.
- **Phase B′ (02-confirm.mjs, registered before its single run; 100
  fresh-seed universes, 37 min): ALL THREE VERDICTS LANDED.**
  - B1 CONFIRMS-NULL: U (t_ER −0.89, t_ED −1.78) and PA (−1.22,
    −1.34) read zero on fresh seeds. The estimator is unbiased.
  - B2 CONFIRMS: PC(0) forces R > E > D generator-level — t_ER
    −10.2 (0/20 universes positive), t_ED +10.8 (20/20). First
    confirmed generator-level fact of the middle track.
  - B3 (descriptive): the contrasts DECOUPLE on one dial — R-over-E
    fades smoothly with β (−0.17 → −0.01); E-over-D flat positive
    through β = 0.75, dead at β = 1. Both die at β = 1, so every
    signature in the family is cone-locality's. The synthetic family
    reproduces the field's dissociation of the two axes for free.
- **Phase C (THEORY.md), done on paper.** U-null proved exactly;
  PA-null by exchangeability given in-degree; the two-level analysis
  of the sign-flip failure (within-kernel priceable, universe-level
  not); and the PC FLUX LAW: cone-local expected gain tracks truncated
  UP-SET SIZE — a quantity the battery does not carry. That is the
  constructive mechanism by which a cell can out-inform the reviewer's
  arsenal. Sign of the PC effect (why R over E) stated open, with the
  registered next measurable: baseline up-set size by cell at matched
  battery in PC(0) universes.
- **Next moves, in order of value:** (1) "battery v2" — add truncated
  transitive-dependent count to the field battery and re-run Go and
  Debian; the flux law says this is the sharpest remaining knife, and
  it either strengthens the two-ecosystem claim materially or catches
  artifact number three in-house. (2) The up-set-by-cell measurement in
  PC(0) universes (closes the sign problem). (3) The E>R generative
  search: which rule families force the *field* ordering — candidates:
  popularity-weighted platforms with cone-locality, territory-
  correlated platform choice, β between 0.75 and 1. Replicate-first
  from birth.

## Status update, 2026-09-01 (evening): BATTERY V2 — the theory's knife cuts one throat of two

The flux law went to the field the same day it was proved
(battery-v2/, blind pre-check first, registration committed before
the scored run). New sixth feature: log1p(truncated up-set size),
cap 200 — the confound the accretion theory derived.

- BLIND PRE-CHECK, the finding that rewrites Go: in the 182
  five-feature pairs behind Go's +0.22, E-members carried up-sets
  +0.69 standardized units LARGER than their R twins (the inflation
  direction, exactly per the flux law) — and it is UNREPAIRABLE
  (51 balanceable pairs at every caliper 0.25-0.5, SMD(upset) 0.113,
  still over the 0.10 gate). Registered in advance: Go E-vs-R scores
  nothing; reported descriptive.
- BV1 (Debian E-vs-R at the SIX-feature battery, PRIMARY): HOLDS.
  Delta +0.0834, conditional null ±0.012, 237,078 pairs, all six
  SMDs <= 0.0104. v1 was +0.098: moved -0.015, stayed 8 null-widths
  up. Debian is now certified beyond every standard predictor PLUS
  the theory-derived one.
- BV2 (Go E-vs-D): HOLDS, unchanged (+0.1524 vs v1 +0.1529). Go's
  E-over-D was never up-set flux.
- Descriptive: Go E-vs-R on the 51 near-balanced pairs: -1.00 —
  gone and INVERTED. Honest reclassification, at full volume: GO'S
  CELEBRATED E > R WAS MOST LIKELY UP-SET FLUX IN COSTUME. Third
  artifact caught in-house; FIRST caught by the program's own theory.
  Debian's D-over-E reversal is up-set-robust (-0.165): the two-axis
  picture stands.
- BOOKKEEPING CORRECTION (recorded in the study postscript): the
  registration header's "7 for 24" miscounted; correct record after
  BV1+BV2 is 8 FOR 24 — with three directional hits in a row
  (B2, BV1, BV2), the first bets ever called with mechanism in hand.
- Gatekeeper sentence v3 (no percentile anywhere in it): "In Debian,
  an algebraically defined cell predicts future dependency growth
  beyond in-degree, out-degree, age, exact distance, PageRank,
  k-core, and transitive-dependent count — the last confound supplied
  by the program's own generative theory — in a design whose original
  version landed as a sealed out-of-sample bet."
- Docs updated: synthesis paper postscript, both briefs, essay
  (including the closing scoreboard).
- NEXT, in order of value: (1) the up-set-by-cell measurement in
  PC(0) universes (closes the theory's open sign problem — why R
  above E there); (2) the generative search for rules that force the
  FIELD ordering E > R at matched battery v2 — candidate families:
  popularity-weighted platforms with cone-locality, territory-
  correlated platform choice; replicate-first from birth; (3) consider
  whether the empirical paper (Go+Debian) should now be drafted around
  the battery-v2 result with the Go reclassification as a centerpiece
  of method credibility.

## Status update, 2026-09-01 (night): Phase D — the conjecture dies, the search comes home empty, and both negatives are the finding

Two registered/committed-first runs closed the day.

- SIGN MEASUREMENT (03-sign.mjs, 10 fresh PC(0) universes,
  registered S1-S3): S1 CONFIRMS 10/10 — the flux law's core is true
  (corr(upset, gain) ≈ 0.23 in every universe). S2 INDETERMINATE —
  the up-set gap inside matched E-R pairs is ~10x too small to carry
  the effect. S3 RESIDUAL — with log1p(upset_200) ADDED to the
  battery, Delta_ER = -0.123 at t = -5.6. THEORY.md's sign
  conjecture is DEAD as the explanation: PC(0)'s R > E > D is not
  primarily up-set flux at cap 200. Live suspects: cap saturation
  (raise/exact counts), cone-weighting (1/|cone| flux weights).
  FIELD COROLLARY, on the record in THEORY.md: battery-v2
  certification means "beyond these six features," and the synthetic
  world now exhibits a cell beating all six — the partition keeps
  seeing what fixed batteries cannot. Deepest credential or warning;
  both readings recorded.
- PHASE D EXPLORATION (SPEC-D.md committed first; 04-explore-d.mjs,
  15 universes, battery v2): SIB (co-user rule) R > E > D at
  t = -10.9 — the prior was wrong, adopting-what-co-users-adopt
  rewards the REFUSAL cell. MIX(0.5) same sign (t = -4.6).
  FRONT(2000) null on both axes. NOTHING GRADUATES. Seven mechanism
  families on record (U, PA, PC(beta), SIB, FRONT, MIX — plus the
  degenerate popularity-platform variant), none produces the field's
  E > R. The graveyard is the product, per the spec's honesty clause.
- Standing theory picture, one line: cone-locality explains why cells
  CAN out-inform any fixed battery; nothing yet explains why the
  field's winner is E rather than R. The E > R generative problem is
  now the program's sharpest open question, with three named
  candidate channels (territory-anchored deepening, two-platform
  straddling, root-protected popularity platforms) queued for a
  future replicate-first tier.

## Status update, 2026-09-01 (late night): THE ORACLE TEST — first complete mechanism identification in program history

Registered before run (05-oracle.mjs, 10 fresh PC(0) universes,
seeds 950000+). The question: what structure does the cell see that
survives all six battery features?

- O1 CONFIRMS 10/10: the derived flux functional ORACLE(x) =
  sum over platforms u with x in cone_200(u) of 1/|cone_200(u)|
  out-predicts capped descendant count in every universe
  (corr ~0.44 vs ~0.23).
- O2 CONFIRMS — MECHANISM FULLY IDENTIFIED: with ORACLE in the
  battery, Delta_ER = -0.0044 at t = -0.25. The R > E inversion
  (-0.17 at v1, -0.12 at v2) VANISHES. Nothing left for feedback.
- O3 — the sharpest lesson: exact UNCAPPED descendant counts do NOT
  close it (t = -7.0). The missing structure was never volume of
  reach; it is CONCENTRATION of reach — being a large share of many
  small toolchains, harmonically weighted. No count feature can see
  it; the 1/|cone| weighting is essential.
- Answer to "what is the cell seeing, something deeper?": in the lab,
  YES, and it now has a closed form. The cells were reading harmonic
  cone-membership mass — a relational-flavored quantity no standard
  battery carries.
- NEXT, the obvious and high-stakes move: ORACLE is a pure graph
  feature, computable on any dependency snapshot with no reference
  to a growth rule. BATTERY V3 = v2 + ORACLE. Register the Debian
  (and Go E-vs-D) re-run behind a blind balance pre-check. If Debian
  survives v3: strongest certification this method can produce (the
  claim survives the very functional that fully explains the best
  synthetic counterexample). If it dissolves: complete mechanistic
  account of field growth (harmonic cone-mass flux) and the cells
  were its reader. Either branch publishes.

## Status update, 2026-09-01 (final): BATTERY V3 — Debian survives the perfect knife; Go exits the table

The oracle went to the field the hour it was identified (battery-v3/,
blind pre-check, sealed registration, single run).

- Pre-check (blind): the v2-certified Debian pairs were already
  nearly balanced on ORACLE (signed SMD -0.025, slightly AGAINST E);
  7-feature matching fully feasible (Debian ER 229,646 pairs at
  maxSMD 0.0114; Go ED 10,074).
- BV3-1 (Debian E-vs-R, PRIMARY): HOLDS. Delta +0.0898, pct 100,
  229,513 pairs, all seven SMDs <= 0.0116. ACROSS THREE BATTERY
  GENERATIONS THE ESTIMATE HAS NOT MOVED: +0.098 (v1) -> +0.083 (v2)
  -> +0.090 (v3). Debian is certified beyond every standard
  predictor, the first-order flux feature, and the complete
  mechanism of the strongest synthetic counterexample.
- BV3-2 (Go E-vs-D): NULL — DISSOLVED (+0.152 -> +0.018, pct 80.5).
  Registered miss, scored as a miss. GO EXITS THE CERTIFIED TABLE
  ENTIRELY per the pre-registered interpretation table: crates
  (v-gauntlet), Go E-over-R (v2), and Go E-over-D (v3) were all
  caught and explained in-house, the last two by same-day theory.
- Record: 9 for 26.
- THE GROWTH CHAPTER'S FINAL FORM, no percentile: one claim stands,
  the sealed-bet one. What grows Debian's shadow is (a) not any
  standard predictor, (b) not first-order flux, (c) not harmonic
  cone-mass, (d) not producible by any of seven mechanism families.
  The E > R generative problem is the program's central open
  question, now with the sharpest possible boundary around it.
- NEXT: (1) the empirical paper (Debian-centered, with the
  crates/Go deflations as the method's credibility spine and the
  oracle as its theoretical contribution); (2) the E > R generative
  search with the three named candidate channels; (3) consider
  ORACLE as a practical ranking signal (criticality-score
  comparison) — the "unmet needs map" pitch now has a validated
  ingredient and a maximally certified target.

## Status update, 2026-09-01 (close of day): THE PAPER EXISTS

preprints/seedbed/paper.md, v0.1 — "The Seedbed Claim: A
Pre-Registered Growth Effect in the Debian Archive, and the
Adversarial Program That Failed to Kill It." Structure: the claim in
full (S1) -> instrument + the audit's reading discipline (S2) ->
provenance sequence with the graveyard as evidence (S3) -> the
result-of-record table across three battery generations (S4) -> why
the kills are the method (S5) -> flux law + oracle + the generative
negative (S6) -> claimed/not-claimed/named next knives, with momentum
declared as battery v4's lead feature and an [H] commitment to run it
(S7) -> reproducibility chain (S8) -> coda. Pointer added to the
philosophers' brief. The paper claims exactly one thing at exactly
its earned grade and names its own falsifiers with clocks.

NEXT SESSION, in order: (1) battery v4 with momentum — the paper
commits to it; (2) the E > R generative search (three named
channels); (3) ORACLE-vs-criticality-score comparison (practical
pitch); (4) consider arXiv routing for the seedbed paper once
battery v4 has run (the [H] should be resolved before submission).

## Status update, 2026-09-01 (after review notes): BATTERY V4 — Debian survives momentum; the paper reaches v0.2

External-context review of the paper draft ordered priorities: momentum
first, everything else editing. Executed same evening.

**Battery v4 (battery-v4/).** Momentum = signed-log prior-interval
in-degree gain, baseline-measurable; baselines shift to 2009–2021 (2007
has no predecessor), with a 7-feature bridge on identical baselines to
separate feature effect from baseline change. Blind pre-check: momentum
already nearly balanced inside v3-battery pairs, signed SMD −0.024 —
*against* E, same conservative shape as the oracle pre-check; 8-feature
match fully feasible. Registered run: **BV4-1 HOLDS** — Delta_ER =
+0.0828 on 203,437 pairs, maxSMD 0.0117 over eight features; bridge
reads +0.0809, so momentum's marginal contribution is +0.002 (nothing).
Descriptive Delta_ED = −0.134 (D > E robust to momentum too). Four
battery generations: +0.098 → +0.083 → +0.090 → +0.083. **Record: 10
for 27.** The paper's [H] commitment is resolved to survival.

**Paper v0.2 (preprints/seedbed/paper.md).** All four review edits:
(1) retitled — "Seedbed" cut; now "A Pre-Registered Growth Effect in
the Debian Archive, and the Adversarial Program That Failed to Kill
It"; (2) abstract cut to claim → four-battery stability → kill record;
(3) §5 "to our knowledge, an unusual loop" replaced with a description
plus nearest-neighbor practices named (adversarial collaboration,
specification curves, placebo outcomes), letting the reader judge;
(4) §7 momentum admission replaced by the resolution; remaining named
knives are relational features and institutional covariates. §3 gains
step 9; §4 gains the v4 row + bridge note; §6 gains one line noting a
standalone methods paper is planned for the flux law/oracle/audit (the
one-paper-or-two decision: this paper stays Debian; the methods paper
is queued). Briefs and essay scoreboards updated to 10/27.

NEXT SESSION, in order: (1) arXiv routing for the paper — the [H] is
resolved, nothing blocks submission prep; (2) the standalone methods
paper (flux law + oracle + replicate-first audit) — reviewer judged it
strong enough to stand alone; (3) the E > R generative search (three
named channels); (4) ORACLE-vs-criticality-score comparison.

## Status update, 2026-09-01 (the end of the growth chapter): BATTERY V5 — FUNCTIONAL ROLE KILLS THE DEBIAN CLAIM

Review follow-up asked for two things before submission: the
functional-role check (the confound a Debian person raises immediately)
and a preemptive Ubuntu-is-not-independent-replication note. The first
one killed the paper's claim.

**Extraction.** debian-study/04-sections.mjs — supplementary Section
metadata for all ten releases (32–58 sections; libs/libdevel/devel
dominate), parsing fixed in-header.

**Battery v5 (battery-v5/).** Control = EXACT stratification: pairs must
agree on kernel, exact distance, AND Section, with the full v4
eight-feature caliper battery inside each stratum. Blind pre-check — and
for the first time in program history it leaned WITH the deflating
story: only 6% of v4-style pairs agreed on section, and the E side was
2.4x more library-flavored (libs+libdevel+devel 13.1% vs 5.4%).
Registered run: **BV5-1 REVERSES** — Delta_ER = −0.0764 on 79,822
same-section pairs, maxSMD 0.0095 (cleanest balance of any generation);
descriptive Delta_ED = +0.0025 NULL (the D-over-E axis dies in the same
run). Per-section: doc +0.015, javascript −0.531, devel −0.270,
libdevel −0.048, games −0.021. Both axes were functional role in
costume: four battery generations had matched everything about a
package except what kind of thing it is — a covariate that lives in the
archive's metadata, not its graph, which is exactly the blind spot the
synthetic audit could never see (it certifies against structural
confounds only). **Fourth in-house kill; the certified-claims table is
EMPTY; record 10 for 28.**

**Executed per the program's rules, same day, full volume:**
- Paper rewritten as v0.3 post-mortem: retitled "...and the Adversarial
  Program That Killed It"; abstract, §1, §3 (step 10), §4 (v5 row +
  per-section), §5 (four kills incl. the headline), §6 (generative
  question closes against the field), §7 (claimed = the method + theory;
  dead = both Debian axes; the role-control lesson; the Ubuntu
  derivative-replication note included as requested), §8 (v5 chain),
  §9 (the corpse coda).
- Briefs + essay: kill postscripts, endings rewritten (the essay's
  closing now reads the falsework metaphor honestly: the growth story
  was the falsework; theorems + instrument + discipline are the stones).
- predictions/REGISTER.md: postscript — bets stand frozen, expectations
  repriced; 2028 passes would be persistence, not mechanism.

**What survives untouched:** the [K] theorems (never rested on growth);
the estimator unbiasedness results; the ~10x variance audit; the flux
law + oracle mechanism identification; the method itself, now
demonstrated end-to-end including on its own headline.

NEXT SESSION, in order: (1) decide the seedbed post-mortem's venue —
it is now a methods-and-negative-results paper and arguably stronger
as one; (2) the standalone methods paper (flux law + oracle +
replicate-first audit) — unaffected by the kill and now the program's
strongest asset; (3) if any growth question is reopened, role controls
enter at battery v1, on any corpus, from day one; (4)
ORACLE-vs-criticality-score comparison (practical pitch, also
unaffected by the kill).

## Status update, 2026-09-02: the kill's anatomy; Beer; the succession pilot named

**Post-hoc decomposition (battery-v5/03-decompose.mjs, descriptive,
unscored).** External review asked for the reversal's anatomy. It is
heterogeneity, not uniformity: javascript −0.531 (11,109 pairs) and web
−0.504 carry it; doc +0.015 (29,931), java +0.674. Leave-one-out:
without doc −0.131; **without javascript −0.003 — zero.** Precise
obituary now in the paper (v0.4): the cross-role claim died of role
composition (verdict independent of the decomposition); the within-role
estimand is null-to-negative, its sign mostly Debian's atypical
javascript packaging. No reading leaves a positive effect. §1 now states
the estimand distinction explicitly (cross-role vs within-role — the
stratification changed the question as well as the answer); §4 carries
the anatomy; both-axes-collapse stated as the strongest sentence: the
entire dynamical content of the partition on Debian was functional role.

**Beer 1962 (intellectual context, recorded not actioned).** Stafford
Beer's "defies analysis; no test can be applied" is a 1962 anticipation
of computational irreducibility from steel-plant management — reached
through statistics because that's what 1962 had, where Wolfram derives
it from deterministic simple rules. The difference worth keeping:
Wolfram's irreducibility is epistemic (what's knowable); Beer's is an
engineering premise (regulation must be generated from within — VSM,
Cybersyn). Third independent convergence this week (Shannon, Wolfram,
Beer) on bounded-observer / coarse-graining / actionable pockets. The
program's novelty claim survives all three: none of them could COUNT
the pockets in a restricted setting. The thing to steal: Beer's
regulation-from-within as a sharper temporal-bridge question — does the
system's own structure induce which observer moves are available?
(Study 11 trajectories currently impose moves externally.)

## Status update, 2026-09-02 (later): THE ORACLE SCANNER — the flux functional finds work in the wild

The day after the growth claim died, its mathematical residue got a
job. New folder `oracle-scanner/`: ORACLE repurposed as a supply-chain
concentration metric, NO causal claim — a ranking judged only by what
it flags. Four descriptive studies, expectations written first, all
committed:

1. **xz retrodiction (01).** Debian bookworm 2023, the last release
   before CVE-2024-3094: liblzma5 ranks **#8 of 63,436 by ORACLE** vs
   #173 by in-degree (PageRank #36; capped transitive counts saturate
   and tie at #700). libgcrypt20 #49 vs #150, libexpat1 #38 vs #102;
   famous packages high on everything. The divergence list surfaces
   "gateway plumbing" (deg-1, huge cone membership: python3-minimal,
   libpam-modules-bin) — the exact topology of the xz attack.
2. **Cap sweep (02).** liblzma5 #8 at every cone cap 50→800; top-100
   overlap 0.92–0.99 across caps. Not a truncation artifact.
   (oracleMass gained an optional cap arg, default 200, battery runs
   untouched.)
3. **crates.io replication (03).** Starker, as predicted for an open
   registry: **unicode-ident ORACLE #2 of 84,439 vs in-degree #3,582**
   (six direct dependents; the canonical quiet single-maintainer crate
   inside every Rust build). Head = the macro toolchain (libc #1,
   proc-macro2 #3, quote #4, syn #5). Divergence list is a THREAT
   CLASS: deg-1 proc-macro companion crates (openssl-macros,
   wasm-bindgen-macro, ...) — arbitrary code execution at build time,
   one direct dependent, inside everything.
4. **Incumbent join (04).** OpenSSF criticality top-1000 (June-2022
   vintage, matches crates snapshot, pre-dates xz attack; official v2
   bucket is dead — billing disabled). Of crates ORACLE top-10, ONE
   present (libc #257). **serde absent, zlib absent**, threat class
   0/7, xz not-on-GitHub hence structurally invisible. Pike measures
   fame-and-activity; ORACLE measures load. Pitch with receipts: the
   incumbent's list contains kubernetes and misses zlib.

Status: strongest applied result the program has produced. Next
moves if pursued: npm/PyPI replication (bigger corpora, need
extraction); a short standalone paper or OpenSSF WG writeup; possible
tie-in as the applied section of the replicate-first methods paper.

**The succession pilot (named, not started).** The workable next
empirical line, superior to shopping for another tritone (which was
forced twice over — logic at six, arithmetic at twelve — and cannot be
shopped for): the claim that when a domain fixes a kernel, the four
cells become available at that moment and their ORDER OF OCCUPATION is
constrained (Bach worked three; the fourth waited 150 years for
Debussy). Cheapest honest test: temperament history — the succession
Pythagorean → meantone → well-temperament → equal is documented and
dated by others, the systems are formal objects, and "which position
did each occupy, in what order" is answerable without a new corpus.
If the framework cannot retrodict the sequence on the domain we know
best, looser domains (art movements etc.) are hopeless; if it can,
that's the method-plus-worked-case needed before any interpretive
corpus. Guardrails if any interpretive poset is ever used: build it
from someone else's published, dated account; the trichotomy theorem
still refuses (regular/dense kernels reject the reading in advance);
the empty-cell prediction is structure-generated, not chosen.

## Tomorrow, in order (original plan, 2026-08-11)

1. **Paper §5 rewrite** — replace the product-law conjecture with the
   closed form as a theorem-with-proof-sketch (the two paragraphs above).
   Grade honestly: derivation given in text, 164/164 [computed], Lean
   pending. State corollaries. Update §6 (latent sizes now *explained* —
   keep the narrative that we refused to fit them first), abstract and §1
   (fifteen lattices, closed form as companion headline to latency), §8
   grade table, §9 reproducibility (cite `aperture-closed-form.mjs`).
2. **Second implementation** — add the closed-form check to
   `aperture-scaling.wl` (formula vs measured apertures over its eight
   lattices) and rerun in Wolfram Cloud; record confirmation in README.
3. **README + design-notes** — update the scaling section (the "sizes fit
   no obvious product form" line is superseded), add the closed-form story
   to the part-4 addendum (predict → discriminate → derive sequence).
4. **Lean** — formalize the closed form per reviewer: the general
   statement, not the two-prime corollary. The factorization lemma proof
   above is the skeleton. This upgrades the paper's central result from
   [computed] to [K].
5. Housekeeping: `wolfram/product-law-two-prime.mjs` documents the
   intermediate discrimination step; fold its story into design-notes and
   decide whether to keep or delete it.

Uncommitted leftover scratch in repo root (`.scratch_aperture_check.mjs`
etc.) is intentionally untracked; ignore.
