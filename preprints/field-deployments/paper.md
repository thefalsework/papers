# The Instrument in the Field: What an Algebraic Invariant Found, and Failed to Find, in Five Real Corpora

**Author.** Chris Brink (independent)
**Version.** Draft v0.3, 2026-08-30. Synthesis of the field deployments of
2026-08-19 through 2026-08-30; primary sources are the study folders cited
per-claim (`mathlib-study/`, `afp-study/`, `ca-study/`, `software-study/`,
`isabelle-study/`, `deflation-control/`),
each of which carries its pre-registrations inline and its raw output
committed. v0.2 adds §6's executed verdict: the software-pair protocol,
registered unrun in v0.1, was run the next day. v0.3 adds the distance-matched
deflation control, which splits the E > R law by domain (§3.3, postscripts).
**Status discipline.** Every claim carries one of the program's grades:
**[K]** kernel-checked in Lean 4 against Mathlib4 (axiom audits: `propext`,
`Classical.choice`, `Quot.sound` only; no `sorry`); **[C]** classical
mathematics, cited; **[computed]** exhaustive or registered finite
computation — exact-tier results under two-implementation agreement;
**[A]** interpretive, argued not proved; **[H]** falsifiable and registered,
untested; **[O]** open. The grades are load-bearing. This paper contains no
new theorems and no new runs: it is the account of record for work already
committed, written so that a reader who was not present can audit the arc.

---

## Abstract

A prior paper of this program defined the **aperture** of a distinction — the
set of lawful coarse-grainings (nuclei) under which a distinguished element of
a Heyting algebra retains a non-degenerate four-position structure — proved
its central facts on divisor lattices in Lean **[K]**, and computed it
exhaustively on fifteen finite algebras **[computed]**. This paper reports
what happened when that invariant was used as a *measuring instrument* on
corpora the program does not control: the import structure of Mathlib
(twenty-one namespaces, ~7,900 modules, three years of history), the Archive
of Formal Proofs (1,014 entries, a different proof assistant and community,
twenty-two years of history), the counterfactual causal graphs of Conway's
Game of Life (the first substrate authored by no one), and — added in v0.2 —
a cross-domain software pair, the Go standard library and the crates.io
registry (a decade of history each). Every test was
pre-registered before its first run; thirty-eight scripts across the four
study folders, plus the Life study's four versioned protocol documents,
constitute the primary record. Two findings
survived everything thrown at them: **Exploitation-cell members occupy the
kernel's named territory** — a cross-ecosystem regularity, 16/16 registered
Mathlib namespaces and the whole AFP graph with every stratum at the 100th
percentile of placement-permutation nulls — and **latency is generic in the
wild** — most real kernels show no four-position structure at full resolution
and acquire it only under specific proper coarse-grainings, on every corpus
measured. Two findings were *scoped* by failed transfer: aperture narrowness
(≈18× vs degree-matched nulls on Mathlib; absent on Life cones) and the
consolidation arrow (null-controlled on Mathlib; reversed on AFP; absent on
both software corpora). The maintained-versus-archival axis suggested by the
two proof corpora was put to its registered cross-domain test and **died on
both rows**: the garden did not consolidate, and the museum grew through
Exploitation — the largest effect the instrument has ever measured, in the
predicted-opposite cell. The same run produced the program's first registered
directional hit: on the Go standard library, Exploitation-cell members
out-grow their degree- and age-matched Distribution siblings, as predicted.
The four-corpus growth record after that run read: Exploitation grows on
Mathlib, Go, and crates.io; AFP the anomaly. v0.3's registered
**deflation control** then subjected the one statement that had held
everywhere — Exploitation-cell members out-grow matched Refusal-cell
members — to its hardest confound, exact graph distance to the kernel, and
split it: in the software ecosystems the cell effect **survives loudly** at
matched connectivity (Go and crates.io, 100th percentile), while in all
three proof corpora it deflates or inverts — Mathlib's E > R was
connectivity in costume, and AFP and the Isabelle distribution actually
favor the *Refusal* side at matched distance. Registered directional
predictions stand at 3 for 18; the graveyard is reported at
the same prominence as the survivals, because the program regards the kill
record as its methodological contribution.

## 1. What the instrument is, in five sentences

Fix a Heyting algebra and a distinguished element (the **kernel**). Every
element falls into exactly one of four positions relative to the kernel —
Infrastructure (inside it), Refusal (wholly outside), Exploitation (in the
double-negation residue: territory the kernel claims but does not settle), and
Distribution (straddling the boundary) — and the partition is non-degenerate
exactly when the kernel is **ordinary**: neither regular nor dense **[K]**
(`four_position_partition`, `partition_nondegenerate_iff_kernel_ordinary`).
A **nucleus** is a lawful coarse-graining — inflationary, idempotent,
meet-preserving — whose fix-set is the world at that resolution **[C]**. The
**aperture** of a kernel is the set of nuclei under which its image is
ordinary *inside their world*: the census of observers for whom the
four-position structure stays open. On finite algebras the aperture is
exhaustively computable, on divisor lattices it has a kernel-checked closed
form at every arity **[K]** (`aperture_closed_form_pi`), and on down-set
algebras of finite posets the classical classification of nuclei (Simmons
1980; Bezhanishvili et al., *Order* 2020) reduces it to sub-poset
combinatorics: Ap(a) = { S ⊆ P : a ∩ S is ordinary in Down(S) } **[C]/[computed]**
(`mathlib-study/02`).

That last reduction is what makes field work possible. Any corpus with an
inarguable dependency order — a compiler-enforced import graph, a registry's
declared dependencies, a causal DAG — yields a finite distributive lattice of
down-sets, principal down-sets as candidate kernels, and a complete finite
census of observers. The instrument needs two things from a corpus: a
dependency order nobody can argue with, and ground-truth labels made by people
who have never heard of this program. The three corpora below supply both.

## 2. The corpora and the discipline

**Mathlib** (`mathlib-study/`, eighteen scripts, 2026-08-19 and 2026-08-26).
The largest library of machine-checked mathematics; revision pinned
(`1fb6b28816`, 2026-05-19); namespace-internal import graphs; six historical
checkpoints 2023-09 → 2026-05 from the same clone. Ground truth: the human
conceptual taxonomy in module name paths. All twenty-one top-level namespaces
were eventually used, and are now spent for out-of-sample work.

**The Archive of Formal Proofs** (`afp-study/`, seven scripts, 2026-08-26).
1,014 refereed Isabelle entries, 10,371 theory files, pinned at
`1e072b5cc6b4`; entry-level import graph; biennial checkpoints 2006–2026 read
directly from git's object database. Ground truth: the archive's curated topic
taxonomy — a different instrument from name paths, chosen precisely because it
is different. AFP was staged as a **referendum**: every Mathlib-derived
finding faced a different assistant, community, grain, and label system, with
nothing from Mathlib's outcomes leaking into any input.

**Conway's Game of Life** (`ca-study/`, nine scripts plus an independent
Wolfram Language twin, 2026-08-24/25). Counterfactual causal DAGs (edge u → v
iff flipping u's state changes v's value), down-set algebras over past cones,
full 2^n observer census per kernel in the exhaustive tier. The first
substrate where nothing was authored, curated, or chosen by anyone. Four
protocol versions; the version history is itself a result (§5).

**The discipline, uniform across all three.** Every test pre-registered in
the script header before first run, with failure semantics fixed in advance;
blind pre-checks that touch only occupancy counts and instrument resolution,
never the quantity predicted; seeded PRNGs committed; raw per-kernel output
committed, not only summaries; two independent implementations (Node.js and
Wolfram Language, confirmed in Wolfram Cloud 2026-08-26 with exact agreement
on every exact-tier value) for all exhaustive aperture computation; deviations
logged as dated postscripts, never edits. Three families of null model, never
pooled: degree-preserving edge rewiring (structure-matched), placement/label
permutation (semantics-broken, structure intact), and rule randomization
(process-changed, reported as a separate comparison).

## 3. What survived everything

### 3.1 Exploitation is on-territory — the flagship [computed]

The four cells' *names* are an [A]-graded dictionary. Formal corpora are the
one place the dictionary is cheaply testable, and one entry passed every test
it was given: **modules and entries in the Exploitation cell — the
double-negation residue, territory the kernel claims but does not settle —
really do occupy the kernel's named territory**, closer to the apex in the
human labeling system than chance placement allows.

The finding's path, in order: discovered on three Mathlib namespaces at the
99th–100th percentile of name-permutation nulls (`12`); sent as a registered
prediction into thirteen held-out namespaces and confirmed 13/13 with zero
reversals (`14`); descriptively positive on four of the final five small
namespaces (`16`) — 16/16 registered, 20/21 overall; then replicated on AFP
under a *different* ground-truth instrument (topic sharing, not name paths) at
the 100th percentile of the whole-graph null and, descriptively, the 100th
percentile inside every stratum (`afp-study/03`; sED = +0.0334 against a null
band of ±0.0055; Logic stratum +0.385). Two assistants, two communities, two
grains, two label systems, zero significant reversals anywhere.

This is the program's strongest corpus finding, and it attaches to exactly the
cell that cannot exist classically: in a Boolean algebra the double-negation
residue is empty. The one structurally non-classical position is the one whose
occupants are empirically distinctive.

### 3.2 Latency is generic in the wild [computed]

On divisor lattices, latent ordinariness — no four-position structure at full
resolution, structure under specific proper coarse-grainings — is the
*exception* (109 of 164 measured elements have empty apertures) **[K]/[computed]**.
In the field it is the *rule*. On the pre-registered Mathlib cone, 11 of 18
principal kernels are latent, with all 262,144 worlds enumerated per kernel
(`mathlib-study/02`). On Life's causal cones, 67–94% of kernels in every
non-trivial cone are latent (`ca-study/`, v1.2). The "just look closer"
instinct — if structure exists, the finest resolution will show it — fails
almost everywhere the instrument has been pointed: full-resolution
ordinariness is rare, and structure-visible-to-*some*-lawful-observer is
common. This is the cross-substrate constant of the entire field campaign.

### 3.3 One dynamical statement [computed] — split by its own control (v0.3)

Registered as a secondary on both historical corpora, it held everywhere it
was measured — five corpora by 2026-08-30: **Exploitation-cell members
outgrow Refusal-cell members** in future load-bearing degree, at matched
degree (and where history permits, matched age). It had an obvious skeptic's
compression — *connected periphery grows, disconnected periphery doesn't*;
E-members are by construction downward-connected to the kernel and R-members
are not, and degree matching cannot dispose of a global property — so the
program ran the control (`deflation-control/`, blind occupancy pre-check
committed first, interpretation table fixed in advance): the same estimator
with **exact undirected graph distance to the kernel's down-set** added to
the matching key. The law split by domain. On the software ecosystems it
survives loudly — Go G_ER = +2.42 against a null half-width of ±0.51,
crates.io +15.68 against ±3.58, both at the 100th percentile: at identical
degree, age, *and* connectivity, the cell still predicts growth. On all
three proof corpora it deflates or inverts: Mathlib collapses to null
(percentile 79 on 26,937 matched cells) — its E > R *was* connectivity in
costume — and AFP (percentile 0.3) and the Isabelle distribution
(percentile 0.0) reverse: among equally-distant members, the *Refusal* side
grows more. The unmatched E > R both archives showed was proximity masking
an R advantage, which retro-dissolves the "AFP anomaly": proof archives were
never anomalous, their regime was hidden under a connectivity confound.
One further survival from the same run: Mathlib's E > D growth ordering is
**not** a distance artifact (100th percentile at matched distance on 99,231
cells), so the partition retains dynamical content on proof corpora — it
just isn't the E-over-R content previously claimed.

## 4. What was scoped by failed transfer

Scoping is not dying. Both findings below are real, null-controlled, and
replicated where they hold; what failed was the tacit universality claim.

### 4.1 Narrowness: a fact about curated libraries [computed]

On Mathlib, real dependency cones are narrow-aperture: structure around a
module, where it exists at all, is visible under ≈18× fewer coarse-grainings
than in degree-preserving rewirings of the same graph (`03`; registered
expectation was the opposite — that the finding would dissolve). Replicated
in Order and Topology; directional but sub-threshold in Algebra, whose cones
are bimodal (`04`). Not explained by four pre-registered graph invariants
(best |ρ| = 0.39; matched on the best invariant, 13/15 real cones remain
below their matched-null median; `05`).

On Life, the same construction produces cones that sit *inside* their own
degree-matched null distributions (`ca-study/` v1.2, P3). The ≈18× is
therefore not a property of dependency DAGs as such. It is a property of
*curated* dependency structures — something human formalization practice does
(consolidation through shared foundations) that neither degree structure nor
an unauthored causal process reproduces.

### 4.2 Consolidation: a fact about maintained corpora [computed]

Over six Mathlib checkpoints (2023-09 → 2026-05), all six registered trends
point one way: latency rising, apertures narrowing (`06`; Order strongest at
ρ = +0.94/−0.89). The control gap named at discovery was closed with the
outcome registered in advance (`08`): the arrow survives per-snapshot
degree-preserving nulls 6/6, with the sharper fact that **the 2023 library sat
inside its own null envelope (percentiles 10–47) while the 2025/2026 library
sits at the extremes (100th percentile latency, 0–3rd aperture, all three
namespaces)**. Early Mathlib was statistically indistinguishable from its
degree-random twin; mature Mathlib is nothing like it. Consolidation is a
measured departure from degree structure, not a byproduct of growth.

On AFP, over eight biennial checkpoints spanning two decades, the latency half
transfers (Spearman +0.83) and the aperture half **reverses**: apertures widen
(+0.64 where the registered prediction required ≤ −0.6; `afp-study/05`). The
consolidation arrow is scoped to Mathlib wherever it is cited. The candidate
explanation for *why* — the maintenance regime — was put to its registered
cross-domain test and died; §6 has the verdict.

## 5. The graveyard, at full prominence

Twelve directional operator hypotheses have been registered and executed;
eleven died, one landed (§6). The program
treats this ledger as a feature — an interpretive apparatus that can be
applied to anything can be wrong about nothing — and reports it at the same
prominence as §3.

### 5.1 The deaths, in order

1. **"Latency will dissolve under degree-preserving nulls"** (registered
   expectation, `mathlib-study/03`, 2026-08-19) — wrong on every metric;
   the finding survived at the 0th/100th percentiles. The instrument's first
   positive result was its operator's first overruled prediction.
2. **"Cohort apertures narrow monotonically"** (`06`) — falsified for young
   cones; the life cycle is born-thin → widen-under-construction →
   consolidate-narrow.
3. **"Flat cones are definitional interfaces"** (`07`) — the role classifier
   had zero dynamic range; the age effect was present in the same sample; the
   role story was withdrawn the day it was proposed.
4. **The published latency characterization** (aperture paper v0.2,
   corrected 2026-08-24) — the "every exponent strictly interior" rule failed
   in both directions at three-plus primes and on single chains
   (Div180's 30: aperture 4; Div8's 2 and 4: aperture 0). All three witnesses
   sat unread in the paper's own published verification set. Corrected as
   Result 6.3; the corrected rule and both counterexamples are now
   kernel-checked instances of the closed form **[K]**.
5. **The Life v1.1 budget policy** — the registered depth policy silently
   forced 21 of 29 cones into depth-1 fans, which are provably aperture-blind;
   P1's failure was an artifact of the instrument's own budget. Lesson kept:
   *a budget policy is part of the instrument, and it can be the part that
   goes blind.*
6. **The still-life lead** (Life v1.2 → v1.3) — the one apparent positive on
   the unauthored substrate (still-life cones ~17× wider than soup, p = 0.044)
   was killed by its own registered size-controlled follow-up within hours:
   at matched cone size, indistinguishable (p = 0.364); every smallest-stratum
   cone in the study is a single structural class; quiescence carries nothing
   (p = 1.0). The signal was a size law (median aperture fraction
   0.098 → 0.016 → 0.0075 across n = 9 → 16 → 23), now the substrate's one
   clean descriptive fact.
7. **"Refusal is proximate"** (the corrected R/D gloss, `14`) — proposed
   post hoc on Order/Topology, registered out-of-sample, refuted by
   significant reversal in 8 of 13 held-out namespaces. Proposed, registered,
   and killed within one day. With `16` (the original ordering failing on the
   final five fresh namespaces) and AFP's R2, **no spatial gloss of Refusal or
   Distribution survives in either direction on any corpus**. The proved cell
   definitions are untouched; the geography is dead.
8. **The growth engine** (`afp-study/07`) — "Exploitation-cell members become
   load-bearing" failed by significant reversal: at matched degree,
   *Distribution*-cell members grow (G_ED = −0.33, percentile 0;
   ordering D > E > R).
9. **The division of labor** (`mathlib-study/18`) — the AFP reversal,
   registered as the hypothesis on Mathlib's history with age matched exactly,
   reversed in the *opposite* direction: on Mathlib, *Exploitation* grows
   (G_ED = +0.076, percentile 100; E > D > R). "E owns the geography, D owns
   the dynamics" died one study after it was born.
10. **The garden consolidates** (`software-study/03`) — Go's aperture trend
    clears the registered slope (−0.71) but its mature checkpoint sits at the
    43rd percentile of its own degree-preserving nulls: failure by absence,
    not reversal. The latency arrow, generic on proof corpora, falls on Go
    and is flat on crates — scoped to proof libraries.
11. **The museum grows through Distribution** (`software-study/04`) — failed
    by reversal at the largest effect ever measured in the program: crates.io
    grows through *Exploitation* (G_ED = +5.83 against a null half-width of
    ~0.59, percentile 100). With 10, the garden/museum axis is dead on both
    rows (§6). The same run's Go quadrant is the operator's first registered
    directional hit and is reported in §6, not here.

### 5.2 The instrument deaths

Two failures were of the measuring apparatus rather than the hypothesis, and
each produced a portable diagnostic:

- **The saturated statistic** (`mathlib-study/10`): the shared-prefix median
  had no dynamic range on the corpus — every cell pinned at the same value,
  the permutation null degenerate at [0, 0]. A null that cannot move is a
  diagnostic that the measure never touched the data. Its successor
  (`11`/`12`) added a mandatory blind resolution pre-check, now house rule.
- **The no-op null** (Life v1.0, killed by inspection before any run): the
  registered syntactic edge relation was provably state-independent, so the
  rule-randomization null was *identical* to the treatment. Kept as a general
  lesson: *if a randomization cannot change your object, your object does not
  depend on what you randomized.* The unexecuted protocol is committed with
  its impossibility proof as a postscript.

### 5.3 The clean negative

The Life study closed **fully negative on every differentiation claim**: the
invariant does not distinguish a glider from soup, a still life from debris,
coherent from random computational history — at matched cone size it measures
size and isomorphism class, nothing about what the pattern is. Stated at the
prominence a positive would have received. The reading this licenses is
narrow but real: on every corpus where the instrument found differential
structure, the substrate was built by agents making commitments; on the one
substrate with no author it found none. The instrument detects *commitment*,
not *computation* **[A]** — an interpretation, flagged as such, whose next
test is §6.

## 6. The garden/museum axis: registered, executed, dead — and what it left behind

The two historical corpora separate along a single axis on two measurements
that share no code and no design:

| | Mathlib (maintained) | AFP (archival) |
|---|---|---|
| Aperture arrow over history | narrows (−, null-controlled) | widens (+0.64) |
| Growth cell at matched degree/age | Exploitation (E > D > R) | Distribution (D > E > R) |

Mathlib is a *garden* — its existing dependency structure is continuously
rewired by thousands of maintainers. AFP is a *museum* — entries are frozen at
acceptance and never rewired. The hypothesis this suggested **[H]**: *the
maintenance regime determines both the direction of consolidation and the
identity of the growth cell.* Gardens go opaque and grow through their
residue; museums stay loose and grow through their boundary-straddlers.

Two corpora are a line through two points, both from one domain, and §5's
base rate for readings at this stage of support was zero for nine. So the
hypothesis was not asserted; it was *armed*: `software-study/PROTOCOL.md`
(v1.0, committed 2026-08-26, before any data acquisition) fixed a
cross-domain pair — the Go standard library as garden, the crates.io registry
as museum, immutability platform-enforced on the museum side — with a
manipulation check gating all scoring, four-quadrant predictions with
thresholds inherited from the null designs above, and failure semantics
including the diagonal case. Preregistration in its strongest form: before
acquisition, not merely before analysis.

**It was executed the next day (2026-08-27, `software-study/`, four scripts),
and the axis died on both rows [computed].** Both manipulation-check gates
passed first (edge-rewiring ratio 3.13× garden over museum; ≥ 3 evaluable
kernels at every checkpoint on both corpora), so the scoring was licensed.
Then:

| | Go (garden) | crates.io (museum) |
|---|---|---|
| Consolidation quadrant | **fails by absence** — trend −0.71 but the mature checkpoint sits at pct 43 of its own degree-preserving nulls | holds (predicted absence: −0.20, pct 97) |
| Growth quadrant | **holds** — G_ED +0.40, null ±0.06, pct 100 | **fails by reversal** — G_ED +5.83, null ±0.59, pct 100: the museum grows through E |

The latency arrow, which rose on both proof corpora, *falls* on Go and is
flat on crates — scoping it to proof libraries. The maintained/frozen reading
was a two-corpus coincidence, exactly as the protocol's stated prior
expected.

Two things survive the wreck, and they are better than what died. First, the
garden growth quadrant is **the program's first registered directional
prediction to land** (operator 1 for 11): on Go, Exploitation-cell members
out-grow their degree- and age-matched Distribution siblings at the 100th
percentile of the label-permutation null. Second, the four-corpus record now
reads: **E out-grows D on Mathlib, Go, and crates.io — maintained and
archival, proofs and software — and reverses only on AFP.** The residue cell,
claimed-but-unsettled territory, looks like the generic growth engine of
dependency-structured corpora, and the question worth a future protocol is no
longer "what do gardens do?" but "what is different about AFP?" **[O]** —
with its refereed-acceptance gate (entries enter whole, already pointed at
the boundary) the natural first suspect, noted here as post-hoc reading, not
prediction.

The program's standing forward bets now live in one registered place:
`predictions/REGISTER.md` (committed 2026-08-27, with the 2026 baseline
cell memberships frozen and the scorer frozen alongside). Four predictions,
horizon 2028-07-01: E out-grows matched D on Go, crates.io, and Mathlib;
and the AFP reversal *persists* — the referee bet. These are the program's
first true forward predictions (everything above was blinded retrodiction);
the git history is the timestamp **[H]**. A fifth remains on the books from
the first field day: the `Topology.CWComplex.Classical` cluster's empty
Distribution cell — a genuine import island — either fills with bridging
modules or the cluster is re-founded, testable against any future Mathlib
revision by rerunning `mathlib-study/01` **[H]**.

## 7. What is not claimed

- **No universality.** The narrowness and consolidation findings are scoped
  claims (§4), and the paper's own record shows what happens to unscoped ones.
- **No semantics for the cells beyond what was tested.** One dictionary entry
  (Exploitation's geography) has cross-ecosystem support; the R/D spatial
  glosses are dead; the proved content of the partition — exhaustiveness,
  exclusivity, the ordinariness gate — is [K] and was never at stake in the
  field.
- **No claim that the aperture measures meaning, value, or computation.** On
  the one unauthored substrate it measures cone size. The commitment reading
  of §5.3 is [A].
- **No dynamics.** The growth studies measure who becomes load-bearing, not
  why; the garden/museum axis is dead (§6), the "E is the generic growth
  engine" reading that replaced it is dead in proof corpora (§3.3, the
  deflation control), and the surviving software-ecosystem cell effect is a
  regularity, not a mechanism.
- **No priority beyond a search.** The classification of nuclei on finite
  down-set algebras is classical (Simmons 1980; Bezhanishvili et al. 2020)
  **[C]**; the aperture invariant, latency, the closed form, and the field
  methodology appear new on a deliberate search **[O]**. Correction welcome.

## 8. Reproducibility

Everything runs from the repository with Node ≥ 18 and git; no Lean install
is needed for the field studies, no npm packages are used, and every corpus
is fetched by pinned revision (commands in each study's README). The Lean
spine builds with `lake build` (axiom audits in the aperture paper). The
Wolfram Language twins are self-contained cloud cells with expected outputs
pre-registered (`ca-study/wl/`, `wolfram/`). Primary sources: `mathlib-study/`
(eighteen scripts), `afp-study/` (seven), `ca-study/` (nine plus four
protocol documents and `RESULTS.md`), `software-study/` (four scripts plus
`PROTOCOL.md`, executed with results as dated postscripts), and the session
log `wolfram/next-session.md`. Citable snapshot of the
program at the aperture paper's release: DOI 10.5281/zenodo.22016585.

**Disclosure.** Drafting and execution were AI-assisted under direction, per
the program's validation architecture; the grades are the author's warrant.

---

*v0.1, 2026-08-26; v0.2, 2026-08-27 (adds the executed software-pair verdict
to §6 and the abstract); v0.3, 2026-08-30 (adds the deflation control to
§3.3 and the abstract). This synthesis reports work committed between
2026-08-19 and 2026-08-30. Corrections and postscripts appear below this
line, dated, never as silent edits.*

---

**POSTSCRIPT (2026-08-30).** §6's closing suspect — AFP's
refereed-acceptance gate as the explanation for its growth reversal — was
promoted to a registered hypothesis and killed the same day
(`isabelle-study/`, three scripts, blind census first). The controlled
contrast: the Isabelle *distribution*, maintained by the same community
with no per-entry freeze and no referee, grows through **Distribution**
exactly like AFP (G_ED = −0.021, percentile 0 of the label-permutation
null; RF2 failed by reversal). The six-corpus growth record now reads
E > D on Mathlib, Go, and crates.io; D > E on both Isabelle-ecosystem
corpora — and every simple axis offered so far (maintained/frozen,
refereed/open, proofs/software, entry/file grain) is dead. E > R held
again, on every corpus measured. The 2028 bets (`predictions/REGISTER.md`)
are unchanged; P4's rationale note is postscripted there. Operator's
registered-directional record: 1 for 13.

**POSTSCRIPT (2026-08-30, later).** The E > R law itself — §3.3's "only
statement about time to survive everything," by then five-for-five across
corpora — was sent to its deflation control: the same estimator with exact
undirected graph distance to the kernel's down-set added to the matching
key (`deflation-control/`, blind occupancy pre-check committed before the
registered run, interpretation table fixed in advance, operator prior on
record leaning deflation). Verdict, per corpus: Mathlib **NULL** (its
E > R was connectivity in costume); AFP and the Isabelle distribution
**REVERSE** (at matched distance the *Refusal* side grows more — the
archives' unmatched E > R was proximity masking an R advantage, so the
"AFP anomaly" dissolves: it was the proof-archive regime showing through);
Go and crates.io **HOLD** at the 100th percentile (G_ER +2.42 and +15.68
against null half-widths ±0.51 and ±3.58) — in package ecosystems the
cell predicts growth beyond degree, age, and connectivity. Descriptively,
Mathlib's E > D ordering survives distance matching (100th percentile,
99,231 cells): the partition keeps dynamical content on proof corpora,
but not the content §3.3 claimed before this control. §3.3 rewritten in
v0.3; briefs updated. Registered-directional record: 3 for 18.
