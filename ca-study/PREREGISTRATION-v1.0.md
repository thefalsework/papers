# Study 10 — Aperture on Cellular Automaton Causal Graphs

**Pre-registration. Written before any run. Version 1.0, 2026-08-24.**

*Status discipline as elsewhere in this program: [K] kernel-checked in Lean;
[C] classical, cited; [computed] exhaustive finite computation under
two-implementation agreement; [A] interpretive; [O] open. This document is a
protocol, not a result. Every prediction below is recorded before first
execution; the file is committed unchanged and any deviation is logged as a
dated postscript rather than an edit.*

---

## 1. Motivation and the claim under test

Prior work measured the aperture invariant on divisor lattices (finite, closed
form, [K]) and on Mathlib's import structure (a compiler-enforced dependency
record, [computed]). Both substrates are mathematical. This study moves the
instrument to a **computational** substrate — the causal structure of a running
cellular automaton — and asks whether the phenomena found in the mathematical
corpora recur where nothing was authored, curated, or chosen by a human.

Two prior findings are at stake:

- **Latency** — kernels with no four-position structure at full resolution that
  acquire one under specific proper coarse-grainings. Proved on divisor
  lattices [K]; observed on 11 of 18 principal kernels in a pre-registered
  Mathlib cone [computed].
- **Narrow aperture** — real dependency cones admit far fewer structure-preserving
  observers than degree-matched randomizations (≈18× on Mathlib) [computed].

The interpretive hypothesis this study probes [A]: *structure at a level is
constituted by what that level treats as indistinguishable* — figure requires
ground, and the finest grain has no ground. In Life, a glider is a glider
relative to a quiescent background; at the level of individual cell-updates
there is no background. If the hypothesis has content beyond the algebra, a
glider's causal cone should be **latent**: closed at the identity observer,
open under a narrow set of coarse-grainings that manufacture a floor.

This study does not test the hypothesis. It tests whether the invariant
distinguishes structured from unstructured computational history at all, which
is the precondition for any interpretive claim.

---

## 2. Construction (fixed before any run)

### 2.1 The poset

Run Conway's Life on a bounded grid from a specified seed for T steps.

- **Nodes.** One node per *cell-update*: the pair (cell c, time t) for
  1 ≤ t ≤ T. Nodes are updates, not cells, and not states.
- **Edges.** A directed edge u → v when u = (c′, t−1), v = (c, t), and c′ lies
  in the Moore neighborhood of c (including c itself). This is the causal
  dependency enforced by the rule: v's value is a function of exactly the nine
  updates at t−1 in its neighborhood.
- **Order.** The transitive closure of those edges, a strict partial order (no
  cycles: edges strictly decrease t).

**Rationale for updates-over-cells.** The rule determines this relation
completely; no modeling choice enters. It is the direct analogue of "A precedes
B is enforced by the compiler."

**Recorded design decision.** Edges are included regardless of whether the
neighbor's value influenced the outcome — the causal cone is *syntactic*, not
counterfactual. A counterfactual variant (edge only when flipping u changes v)
is a named extension in §8, not part of this study. This is a deliberate choice
and it is the most likely thing a critic will press.

### 2.2 The algebra

Elements are **down-sets** of the poset (sets closed downward under the causal
order). Down-sets of any poset form a complete Heyting algebra [C], with
∧ = ∩, ∨ = ∪, and ¬a = the largest down-set disjoint from a — computed as
{ y : ↓y ∩ a = ∅ }.

**Explicitly rejected alternative.** The power set of a configuration window is
Boolean, and Boolean algebras contain no ordinary elements [C]. That
construction is dead on arrival and is recorded here so it is not tried later
in the belief it is new.

### 2.3 Kernels

For a cone, the candidate kernels are the **principal down-sets** ↓x, one per
node x. Aperture is computed per kernel, exactly as in the Mathlib study.

### 2.4 Cones

A cone is the past cone of a chosen "focus" update, truncated to depth d:
all nodes reachable backward from the focus in ≤ d steps.

Depth is chosen per condition so that cone size stays within the exhaustive
budget (§4).

---

## 3. Conditions

Six seed classes, each a distinct kind of Life behaviour. All seeds are
specified in `seeds.json` and committed with this document.

| # | Condition | Seed | Expected Life behaviour |
|---|---|---|---|
| A | Glider | standard 5-cell glider | translates diagonally, period 4 |
| B | Still life | block, beehive, loaf (3 seeds) | static |
| C | Oscillator | blinker (p2), toad (p2), pulsar (p3) | periodic, no translation |
| D | Spaceship | LWSS | translates orthogonally, period 4 |
| E | Random soup | 20 seeds, density 0.30, fixed RNG seeds | chaotic, mostly decaying |
| F | Empty-adjacent | single live cell, dies at t=1 | trivial |

Condition F is a degenerate control: its causal cone is nearly trivial and
should show nothing. If F shows structure, the pipeline is broken.

**Focus selection.** For A–D, the focus is a live cell-update at t = T inside
the pattern. For E, the focus is a live cell-update at t = T selected by fixed
rule (lowest row, then lowest column). For F, the single update. Focus rule is
fixed here so it cannot be tuned post hoc.

---

## 4. Computational budget and enumeration policy

**This is the constraint that shapes everything.** The nucleus census on a
down-set algebra over an n-node poset has 2^n members [C]. The Mathlib study
enumerated 2^18 = 262,144 worlds per kernel. That is the budget here too.

- **Exhaustive tier (primary).** Cones with n ≤ 18 nodes. Full enumeration of
  all 2^n observers per kernel. All primary claims come from this tier.
- **Sampled tier (secondary, exploratory).** Cones with 19 ≤ n ≤ 40. Uniform
  random sample of 2^18 observers per kernel, fixed RNG seed, reported
  explicitly as a sample with binomial confidence intervals on aperture
  fraction. **No primary claim rests on this tier.**
- **Excluded.** n > 40. Not attempted.

Depth d is chosen per condition as the largest depth with n ≤ 18; if depth 1
already exceeds 18 nodes, the cone is spatially truncated to the focus's
immediate causal neighborhood and this is logged.

**Pre-registered statement:** a Life causal cone grows fast (up to 9× per
step), so most cones will be depth 2 or 3. The exhaustive tier is a complete
census of a small object, not a sample of a large one — the same claim shape as
the Mathlib latency bullet.

---

## 5. Measures

Per kernel:

1. **Ambient ordinariness** — is ↓x ordinary at the identity observer?
2. **Aperture size** |Ap(↓x)| — count of observers under which the image is
   ordinary in Fix(j).
3. **Aperture fraction** — |Ap| / 2^n.
4. **Latency flag** — not ambient-ordinary, but |Ap| > 0.
5. **Cell occupancy** — which of the four positions are inhabited at the
   identity, and under each opening observer.

Per cone: distribution of the above across all kernels; count and fraction of
latent kernels; median and max aperture fraction.

---

## 6. Nulls

Two, kept distinct and never pooled.

**N1 — degree-preserving rewiring.** Randomize the causal DAG preserving each
node's in-degree and out-degree and the temporal layering (edges only from
t−1 to t). 100 rewirings per cone, fixed RNG seed. This is the matched null and
the direct analogue of the Mathlib study's control.

**N2 — rule randomization.** Replace Life's birth/survival rule with a random
totalistic rule of matched mean density, rerun from the same seed, build the
cone the same way. 20 rules, fixed RNG seed. This is *not* a matched
structural null — it changes the generating process — and is reported as a
separate comparison, labelled as such.

---

## 7. Predictions (pre-registered, before any run)

Stated so that each can fail individually. P1–P3 are the primary claims.

**P1 (differentiation — the load-bearing prediction).** Aperture profiles
differ significantly between structured conditions (A–D) and random soup (E).
Operationally: median aperture fraction across kernels differs between the
pooled A–D cones and the E cones, by a Mann–Whitney U test at α = 0.01.
*If P1 fails, the invariant does not distinguish structured from unstructured
computational history, and P2–P5 are uninterpretable. Report and stop.*

**P2 (latency in coherent structures).** At least one of conditions A–D
exhibits latent kernels — kernels closed at the identity, open under proper
observers — at a rate exceeding condition E.

**P3 (narrowness).** For conditions A–D, aperture fractions are smaller than in
the N1 degree-preserving nulls. Direction predicted; magnitude not predicted
(the Mathlib 18× figure is not a prediction for this substrate).

**P4 (motion discriminates).** Translating patterns (A, D) show a different
aperture profile from static/periodic ones (B, C). This is the cheap
discriminator: if gliders and still lifes are indistinguishable, the invariant
is not tracking coherent motion.

**P5 (degenerate control).** Condition F shows no ordinary kernels and no
latency. A failure here indicates a pipeline bug, not a finding.

**Explicitly not predicted.** Which specific observers open a glider's kernel;
whether the opening observers correspond to anything recognizable as
"background"; any quantitative aperture law. The interpretive hypothesis of §1
is not tested by this study and no result here confirms it.

---

## 8. Failure semantics

- **P1 fails** → the invariant does not discriminate on this substrate. Report
  as a negative result. This is the outcome that most constrains the program
  and it is the one to publish fastest.
- **P1 holds, P2 fails** → latency is a feature of mathematical corpora, not of
  computational history. Narrows the scope claim; still publishable.
- **P3 fails** (apertures wider than null) → the narrowness result does not
  transfer; the Mathlib 18× becomes a fact about curated libraries specifically.
- **P4 fails** → the invariant tracks something other than coherent structure.
  Investigate what, before any further interpretive work.
- **P5 fails** → bug. Fix before reporting anything else.

---

## 9. Implementation and verification discipline

- Two independent implementations of the nucleus enumeration and the
  four-cell test (Node.js and Wolfram Language), written without reference to
  each other, must agree exactly on every cone in the exhaustive tier.
- The existing Mathlib pipeline's enumeration code is reused where it applies;
  reuse is logged so shared-bug risk is on the record.
- Anchor test: the pipeline is run against a small hand-computed poset with
  known aperture before any Life cone is processed.
- All RNG seeds fixed and committed.
- Raw per-kernel output committed, not only summary statistics.

---

## 10. Scope and what this cannot show [O]

This study concerns one CA rule, one grid topology, bounded windows, small
cones, and a syntactic causal relation. It cannot establish that latency is
general to computation, cannot connect the aperture to computational cost or
irreducibility (the static/temporal disanalogy stands, untouched), and cannot
license the interpretive hypothesis of §1 whatever the outcome.

What it can establish: whether an invariant proved on divisor lattices and
measured on a proof library also discriminates structure in the best-studied
discrete universe available. A negative answer is as informative as a positive
one and will be reported with equal prominence.

---

*Committed unchanged before first execution. Deviations logged as dated
postscripts below this line.*

---

**POSTSCRIPT (2026-08-25, before any execution — protocol dead on arrival,
caught by inspection).** Nothing in this document was ever run. Review prior
to first execution (by the assisting agent, 2026-08-25) proved the §2.1
syntactic construction degenerate a priori:

1. **The edge relation is state-independent.** Life is synchronous — every
   cell, live or dead, updates every step — and the Moore template does not
   consult values. The poset is therefore a function of grid geometry, T, and
   focus position only; no measure in §5 reads the automaton's state after the
   DAG is built.
2. **Conditions A–E are poset-isomorphic.** For any interior focus, the
   depth-d cone is the same pyramid (1, 9, 25, … nodes per layer). A glider's
   cone and a soup's cone are the same object; P1, P2, and P4 would have
   failed as theorems about the construction, not as facts about the
   invariant.
3. **The depth arithmetic forces the degenerate tier.** Depth 1 = 10 nodes,
   depth 2 = 35 > 18, so every exhaustive-tier cone is the 9-antichain-under-
   a-top, where the focus kernel is ⊤ (dense) and every atom kernel is
   regular. Nothing to measure. §4's "most cones will be depth 2 or 3" was
   unreachable under its own budget.
4. **N2 is a no-op under this construction.** A random totalistic rule has
   the same Moore template, so the "rule-randomized" DAG is literally
   identical. A null that provably cannot differ from the treatment is a
   diagnostic that the treatment never touched the substrate — kept as a
   general lesson: *if a randomization cannot change your object, your object
   does not depend on what you randomized.*

The §2.1 "recorded design decision" flagged the syntactic choice as the thing
a critic would press; flagging a weakness is not the same as checking whether
it is disqualifying, and the check was not done before writing v1.0.

**Disposition.** v1.0 is committed for the record, unexecuted, with this
postscript. The study proceeds under **v1.1** (registered alongside in the
same commit, before any run), which promotes the counterfactual edge relation
to the primary construction. No pre-registration cost was incurred: the record
shows a dead protocol caught by inspection rather than by a wasted run.
