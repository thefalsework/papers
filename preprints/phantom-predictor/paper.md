# Phantom Mass: An Intrinsic Per-Element Measure of Abstract-Domain Conflation, with Registered Experiments on Exactly When It Predicts Analysis Error

**Chris Brink**
falsework.dev
**Version.** Draft v0.3, September 2026 — DOI [10.5281/zenodo.22802676](https://doi.org/10.5281/zenodo.22802676); not yet submitted to a venue. (v0.3, after a literature-positioning review: the note no longer claims the *count* as a contribution in any form — s(U) is verified here to coincide both with the CDG quasi-metric at (U, ρU) and with the model-counting false-positive measure of Zheng–Yao (arXiv 2606.21992, June 2026), and §1 now positions against the three existing measurement families — quasi-metric, pre-metric (Campion–Urban–Dalla Preda–Giacobazzi, SAS 2023), and model counting — reserving the claim to the *direction of use*: intrinsic and prior, with a theory of when the predictive channel exists and a proof of when it does not. v0.2, same day as v0.1, after referee-style review: the confusion-class lemma restated and kernel-checked at `ClosureOperator` generality, closing a prose-weld where the uco claim cited the nucleus lemma; the "not forced" status of Theorem 6.1 made kernel-grade via `step_not_meet_preserving`; the partition mechanism promoted to Proposition 4.1 with the abstract-side/concrete-side grades separated; all headline numbers to three decimals with the Phase 1 margin of 0.003 flagged as prominently as the Phase 2 margin of 0.006; abstract shortened, the map first.)
**Status discipline.** Every claim carries one of five grades: **[K]** kernel-checked in Lean 4 against Mathlib4 (no `sorry`, no `native_decide`, axiom audits at most `propext`, `Classical.choice`, `Quot.sound`); **[C]** classical mathematics, cited; **[R]** empirical result from a pre-registered protocol (spec and kill conditions committed before code, dated postscripts binding, amendments logged with their nature); **[A]** structural analogy, argued not proved; **[O]** open. The grades are load-bearing: nothing below claims more than its tag.

---

## Abstract

Does an abstract domain carry, at individual properties and with no program in sight, a number that predicts where run-level analysis error will accumulate? We test one candidate — the **phantom mass** of U under a closure operator ρ, the size of the conflation interval [U, ρU] — in three pre-registered protocols with kill conditions committed before code (31,040 exact runs on finite toy worlds). The answer is a map: **yes** for gap-filling closures — the interval domain predicts accumulated completeness error at pooled Spearman +0.503, robust to a world, seed, and boundary-convention change (+0.538, +0.629), with the input-only variant at +0.463 **[R]**; **no** for partition closures — four domains show |ρ| ≤ 0.117, with a four-line mechanism (the abstract run factors through the met-class profile and is blind to within-class cardinality; Proposition 4.1) and a registered kill that closed the side after the corrected functional also failed **[R]**; **attenuated** under widening — pooled +0.306 against a registered kill line of 0.300, reported at that margin, with a registered autopsy isolating the mechanism: near-full signal where widening is quiet (+0.457), swamped where it fires (+0.102), and a quarter of error-bearing loop runs carrying zero intrinsic phantom, per the pre-registered A-W anchor **[R]**. The instrument's license is a two-line confusion-class lemma at closure-operator generality — meet-preservation unused — kernel-checked as `ClosureOperator.le_apply_iff` **[K]**. The count itself is claimed by nobody here: s(U) = |ρU ∖ U| is exactly the counting-measure quasi-metric of Campion, Dalla Preda and Giacobazzi (POPL 2022) instantiated at (U, ρU), and coincides with the model-counting false-positive measure of Zheng and Yao (2026) at ρ = γ∘α **[C]**. What is claimed is the direction of use — intrinsic and prior rather than extrinsic and post-hoc — together with the map of when that direction works. One theorem accompanies the experiments: observers compatible with a single-edge order extension are closed under support union — reduced-product-style completeness preservation in a setting where the standard sufficient condition provably fails, the step being non-meet-preserving by a kernel-checked witness **[K]**. In one line: *the intrinsic conflation count predicts accumulated analysis error where the abstraction fills gaps, cannot where it forgets multiplicity, and degrades with a measured mechanism where the analysis manufactures its own imprecision.*

---

## 1. Introduction

Abstract interpretation has a graded theory of *how wrong* an analysis can be. Completeness — the case where abstraction loses nothing relative to the property observed — was characterized by Giacobazzi, Ranzato and Scozzari (JACM 2000) as a property of the abstract domain alone, refinable by domain transformers; Bruni, Giacobazzi, Gori and Ranzato (LICS 2021) localized it to derivations; Campion, Dalla Preda and Giacobazzi (POPL 2022) made it quantitative, bounding the *partial completeness* ε of a run under a supplied quasi-metric. In that framework the error is a property of a triple: program, input, domain.

This note asks a question one level below the run: does the domain itself, evaluated at individual properties with no program in sight, carry a number that *predicts* where run-level error will accumulate? The candidate number is the size of the conflation interval [U, ρU] — how much the closure manufactures at U — which we call phantom mass. It arose in a different setting (a program studying observer-relative structure in Heyting algebras; §6 gives the two-sentence version), and the confusion-class lemma that justifies the name needs only inflationarity, monotonicity and idempotence, so it applies to every standard abstract domain as-is: it is a closure-operator-level instrument, not a nucleus-level one **[K]**.

**Positioning, stated before the contribution.** Measuring abstract-interpretation imprecision quantitatively is occupied territory, and this note claims none of it. Three families exist. The quasi-metric family: Campion, Dalla Preda and Giacobazzi (POPL 2022) supply a distance on the abstract domain and bound the ε of a run. The pre-metric family: Campion, Urban, Dalla Preda and Giacobazzi (SAS 2023) relax the quasi-metric to a pre-metric on any pre-ordered domain, covering forward completeness and non-Galois abstractions, and are explicit that the distance can be designed to whatever level of approximation one wants measured. The model-counting family: Zheng and Yao (2026) count the false-positive concrete states |γ(α(φ)) ∖ φ| of an abstraction by model counting on logical encodings, giving a client-independent precision report for real domains (Interval, Zone, Octagon, KnownBits). The exponent this note works with is not new against any of them — s(U) = |ρU ∖ U| *is* the POPL 2022 counting quasi-metric instantiated at (U, ρU), and it *is* the Zheng–Yao false-positive count at ρ = γ∘α, a coincidence we state rather than bury. All three families, however, run in the same direction: given an analysis output or an abstraction of a known semantics, they measure the discrepancy that *has occurred*. Extrinsic, post-hoc.

Phantom mass is the same count pointed the other way: *intrinsic and prior* — a per-element structural coordinate of the closure, defined before any program exists, evaluated along states a program then actually visits. The question is whether that prior quantity *predicts* the realized discrepancy the other frameworks measure. If it predicted nothing, it would be a definition with good manners and no job. Whether it predicts is an empirical question, so we registered it as one — spec, thresholds, and kill conditions committed before code, in three phases, with the kill line written first: *if the intrinsic count and the run-level error decouple on the worked example, the instrument is a definition, not a predictor, and the bet ends there.* And where it cannot predict, the note aims for a proof rather than a scatter plot: the partition result (Proposition 4.1) is an information-channel impossibility — the abstract trajectory is a function of a profile that phantom mass varies independently of — which *predicted* the empirical null rather than explaining it afterward.

The three phases produced a map rather than a verdict, and the map is the contribution:

- **Where it works:** gap-filling closures (the interval domain), robustly across worlds, seeds, and boundary conventions — and even in input-only form, which needs no trajectory at all (§3).
- **Where it does not work, half by proof:** partition closures — the abstract run retains which classes are met and discards multiplicity, so cardinality-style phantom information has no channel through the abstract computation (Proposition 4.1); the absence of a concrete-side rescue is the registered empirical half (§4).
- **Where it degrades, and why:** loops under widening, where the analysis manufactures imprecision that no intrinsic quantity can see; the degradation is measured, its mechanism isolated by a registered autopsy, and the surviving signal localized to the widening-quiet region (§5).

Everything empirical here is on finite toy worlds, computed exactly. The distance from these worlds to a real analyzer is stated in §7 and not minimized. What the toys establish is the *existence and shape of the phenomenon*: the intrinsic/extrinsic gap is bridgeable for one large class of domains, unbridgeable for another, and the reason in both cases is structural, not statistical.

## 2. The instrument

**Setting [C].** A concrete domain C (here: the powerset of a finite state space Σ, ordered by inclusion). An abstract domain in the standard uco presentation is an upper closure operator ρ : C → C — monotone, inflationary (U ⊆ ρU), idempotent — whose fixpoints are the expressible properties (Cousot & Cousot 1977, 1979; the uco view of domains is standard since Giacobazzi–Ranzato–Scozzari 2000).

**Definition 2.1 (phantom mass) [K].** For a closure operator ρ and element U, the phantom mass of U under ρ is |[U, ρU]| — the cardinality of the interval between U and its closure.

**Lemma 2.2 (confusion class) [K] (`ClosureOperator.le_apply_iff`).** For U ≤ X: X ≤ ρU iff ρX = ρU. The interval [U, ρU] is exactly the set of properties ρ cannot distinguish from U from above. Two lines from inflationary + monotone + idempotent, kernel-checked over Mathlib's `ClosureOperator` on an arbitrary partial order — meet-preservation (the nucleus axiom) is not a hypothesis, which is what licenses applying the instrument to arbitrary ucos. (The nucleus-flavored statement this program originally used, `IsNucleus.le_apply_iff`, is the special case and sits beside it in the same file; the closure-operator form was added when a draft of this note was caught citing the nucleus lemma for the uco claim — the kind of prose-weld between artifacts this program's method exists to catch, recorded here rather than silently repaired.)

**The working coordinate.** On a powerset carrier, |[U, ρU]| = 2^{s(U)} with s(U) = |ρU ∖ U|: the number of spurious concrete states the closure manufactures at U. s is the informative exponent and the additive form. As a functional it is not new twice over: it is exactly the counting-measure quasi-metric δ(U, ρU) of Campion–Dalla Preda–Giacobazzi instantiated at the pair (U, ρU), and it is exactly the false-positive count |γ(α(U)) ∖ U| that Zheng–Yao's MCAI computes by model counting when the closure is γ∘α. Both bridges are stated once and relied on throughout; what this note adds to the count is its semantics (Lemma 2.2: the interval [U, ρU] is the closure's confusion class at U, so s is a *local conflation* measure, not a distance-to-output) and its role (predictor evaluated on concrete trajectories, not report card on abstract results).

**The two run-level quantities (targets, not instruments).** For a program p = fₙ ∘ … ∘ f₁ executed abstractly by stepwise best correct approximations (a₀ = ρU, aₖ₊₁ = ρ(fₖ₊₁(aₖ)), the composition real analyzers use), against the concrete trajectory V₀ = U, Vₖ₊₁ = fₖ₊₁(Vₖ):

- **completeness error** ε(p, U, ρ) = |aₙ ∖ ρ(Vₙ)| — spurious mass beyond the best the domain could represent; the CDG-style target;
- **the intrinsic predictor** P(p, U, ρ) = Σₖ s(Vₖ) over the concrete trajectory — per-element counts at the states the program actually visits, no abstract run consulted. The input-only variant uses s(U) alone.

**Two free facts, registered as anchors so the experiments could not discover them.** T0: if s(Vₖ) = 0 for all k, then ε = 0 (exact trajectory forces a complete run; proof: a₀ = ρU = U and aₖ₊₁ = ρ(fₖ₊₁(aₖ)) = ρ(Vₖ₊₁) = Vₖ₊₁ by induction). A1: phantom does *not* imply error — a class-respecting operation on a partition domain has ε = 0 at any phantom. Both are proved inline here and asserted as validation in every registered run **[R]**; neither is claimed as a finding. The statistical question lives strictly between these two poles.

## 3. Phase 1–1b: the gap-filling case, and its robustness

**Protocol (registered before code; `absint-dictionary/PHASE1-SPEC.md`, `PHASE1B-SPEC.md`) [R].** World A: Σ = {−8..8}, five ucos — Parity, Mod3, Sign, Sign×Parity (partition closures), Interval (ρU = [min U, max U]; the gap-filling closure) — 50 programs over a 10-operation alphabet (saturating arithmetic and guards), 48 inputs, 12,000 exact runs. Registered thresholds: within-domain pooled Spearman(P, ε) ≥ 0.5 with length-stratified median ≥ 0.3 (the stratification guard against the length confound: longer programs accumulate both phantom and error). Kill KP1: pooled < 0.3 in every domain.

**Result.** The kill did not fire, and the registered universal claim failed — the split *is* the finding:

| domain | pooled ρ(P, ε) | length-stratified median | input-only ρ(s(U), ε) |
|---|---|---|---|
| Parity | +0.029 | −0.231 | −0.166 |
| Mod3 | −0.003 | −0.273 | −0.178 |
| Sign | +0.117 | +0.043 | +0.015 |
| Sign×Parity | +0.050 | +0.107 | +0.042 |
| **Interval** | **+0.503** | **+0.508** | **+0.463** |

**The margin, stated before the celebration:** the Interval pooled value is +0.503 against a registered floor of 0.500 — it cleared by 0.003, and a different seed could plausibly have missed. This is the same razor margin the loops result carries (§5), and it gets the same treatment: the Phase 1 pass, taken alone, established nothing beyond "worth retesting." What the claim actually rests on is Phase 1b, where the fresh worlds passed with real margin. The stratified median (+0.508) and input-only variant (+0.463) cleared their 0.300 floors comfortably in all three worlds.

T0 held on all 1,479 exact-trajectory runs. One registered hand anchor was *wrong* and the validation gate caught it before any survey result was read: "increment respects parity classes" is false under saturating arithmetic (inc(8) = 8 stays even), a logged amendment that also surfaced an incidental mechanism — boundary saturation converts phantom into error.

**Robustness (Phase 1b) [R].** Retested under a registered kill (K-R: pooled < 0.300 in the fresh world ends the predictor claim). World B (Σ = {−12..12}, fresh seed, fresh programs and inputs, saturation): pooled **+0.538**, stratified median +0.522 — passes the unchanged thresholds, this time with margin. World C (same but wrap-around arithmetic, registered as *adversarial* because wrapping shatters interval hulls): pooled **+0.629**, stratified median +0.618 — stronger, in the world expected to hurt. Pre-registered reading: the pass is a property of the closure's shape, not of op–hull alignment. (Logged without weight: wrap produces more error and more spread, which mechanically flatters rank correlations; the conclusion does not depend on +0.629 exceeding +0.538.)

## 4. The partition side: a null with a proof

The four partition domains show no signal, and half of the reason is a proposition, not a statistic.

**Proposition 4.1 (the abstract run is blind to within-class cardinality).** *Let ρ_π be the closure of a partition π (ρ_π U = the union of the classes U meets), and let M(U) = {C ∈ π : U ∩ C ≠ ∅} be the met-class profile. Then the entire stepwise-bca abstract trajectory from input U, and hence its output aₙ, is a function of M(U) and the operation sequence alone; and s(U) is not a function of M(U) — any profile containing a partially-met class C is realized by inputs of every deficiency 1 ≤ |ρU ∖ U| ∩ C ≤ |C| − 1 in that class.*

*Proof.* a₀ = ρ_π U = ⋃M(U) is determined by M(U); each subsequent aₖ₊₁ = ρ_π(fₖ₊₁(aₖ)) is a function of aₖ. For the second half, fix the profile and vary how many elements of a partially-met class are present. ∎

The proposition delimits exactly what it delimits — it is an *information-channel impossibility result for this particular predictor*, not the familiar observation that partitions correspond to equivalence relations: cardinality-style phantom information has *no channel through the abstract computation*. It does not by itself forbid a correlation arriving through the concrete side — ε = |aₙ ∖ ρ(Vₙ)| also depends on where the concrete trajectory lands — so whether any concrete-side channel exists is an empirical question, and that is the question the registered experiments answered: none does. Pooled correlations −0.003 to +0.117 across the four domains **[R]**, and the corrected candidate — c(V) = the number of partially-met classes, which unlike s *is* a profile-adjacent functional and was the coarsest one that could have mattered — was tested in Phase 1b with its own thresholds (≥ 0.300 pooled in ≥ 3 of 4 domains) and its own closure rule (K-P: all four below 0.200 closes the partition side, functional-shopping stops at two). **K-P fired**: pooled −0.069 (Parity), −0.099 (Mod3), +0.055 (Sign), +0.008 (Sign×Parity) **[R]**.

The honest statement of the null, with its two grades kept separate: the abstract-side blindness is proved (Proposition 4.1); the absence of a concrete-side rescue is registered empirical fact on this toy **[R]**. For partition closures, error is governed by *op–class alignment* — whether the program's operations respect the partition — which is a property of the dynamics, not of the elements. Prediction there requires op-awareness, and an intrinsic per-element instrument is the wrong tool. We regard this as the second-most useful result in the note: it says which abstractions can in principle be audited statically by conflation counting (gap-filling ones) and which can only be profiled by running them (partition ones).

## 5. Phase 2: loops and widening

Real interval analysis loses its precision in loops, through widening, so the reviewer's question was registered and run before any write-up (`PHASE2-SPEC.md`): toy language extended with `while` loops over five guards, concrete collecting semantics computed exactly as a finite fixpoint, abstract semantics by the standard widening iteration (unstable bounds jump to the world bounds; no narrowing — its absence makes the world harder for the *analysis*, not for the claim).

**The structural threat, hand-witnessed before the run [R].** Widening manufactures imprecision that is not intrinsic to the states, so T0 is *provably false* on loops. Registered anchor A-W: `while (x < 3) inc` on input {0} — every set the computation touches is an exact interval, intrinsic phantom P = 0, yet the widened invariant jumps to [0, 8] and ε = 5. Error at zero phantom, by construction. At scale the mechanism is common: 286 of 2,400 loop runs (a quarter of all error-bearing runs) have ε > 0 with P = 0.

**Result [R].** Loop corpus (50 programs, half the items loops, 2,400 runs, ε > 0 in 49.5% — more than double the straight-line rate): pooled Spearman(P, ε) = **+0.306** against a registered kill line of 0.300. The registered verdict band calls this *survives attenuated*; we report the margin at full strength — 0.006 of Spearman, a different seed could plausibly have fired the kill. The registered autopsy is what makes the number a mechanism rather than an ambiguity. Widening jump mass W (an analysis-side meter, registered as descriptive) predicts error at +0.491 — better than the intrinsic count. Conditioning on W: within the widening-quiet tercile, ρ(P, ε) = **+0.457**, near straight-line strength; within the widening-heavy tercile, **+0.102** — swamped. The pooled figure is just this mixture.

One amendment, logged before any loop-corpus number was read: the continuity gate (loop-free control must reproduce the Phase 1 result) fired at +0.470 against a registered 0.500 — the same statistic that sat at +0.503 and +0.538 in the two earlier corpora, i.e. a quantity living *near* the threshold, hard-gated on a smaller fresh-seed corpus; an exact cross-engine check — the identical 1,440 loop-free runs through the Phase 1 engine and the new harness — returned zero mismatches in both ε and P, so the gate had mistaken sampling variation for harness error and was replaced by the strictly stronger equality check. Loop-corpus thresholds were not touched.

**The qualified claim after Phase 2.** Intrinsic phantom predicts interval-analysis error on straight-line code and on loop code where widening does not fire; where widening fires, the analysis's own manufactured imprecision dominates, and the quantity that predicts *that* (W) requires running the analysis — which is exactly what an intrinsic instrument exists to avoid. The qualifier is permanent absent a narrowing study **[O]**.

## 6. One theorem, and the program this came from

The instrument arrived here from a program studying observer-relative structure in Heyting algebras — which distinctions survive coarse-graining (the *aperture* of an element: under how many nuclei it remains *ordinary* in Citkin's sense) and what coarse-graining destroys (the *co-aperture*: total phantom mass over all observers; closed forms on chains and divisor lattices, exact multiplicativity on products, and independence from the aperture in both directions, all kernel-checked — Brink 2026d, 2026f). Phase 0 of the present study was a literature confrontation, recorded in the spec with a dated retraction where needed: the program's *dynamical compatibility* notion (observers commuting with a time step) decomposes exactly as backward ∧ forward completeness in the GRS sense — a hand proof re-checked by exhaustive oracle over 131,320 (step, observer) pairs with zero mismatches — so that layer is absorbed by existing completeness theory and is claimed by no one here **[C/R]**.

What survived the confrontation is one closure theorem apparently outside the existing theory's predictions:

**Theorem 6.1 (meet-half of the lattice conjecture) [K] (`compatible_union`, `PocketMeetHalf.lean`).** On the down-set algebra of a finite poset, with observers the sub-ecosystem nuclei j_S and the time step a single-edge order extension: if S and T are both compatible with the step (equivalently, both backward- and forward-complete for it), then S ∪ T is compatible. Since j_{S∪T} is the pointwise meet of j_S and j_T — the reduced product of the two domains — this is a *completeness-preservation result for the reduced product of tied domains*. To forestall an over-reading: the reduced product and the completeness theory of domain combinations are classical (Cousot–Cousot 1979; Giacobazzi–Ranzato and successors); what is claimed is a new theorem in this specific algebraic setting — these observers, this step — not a new reduced-product principle.

**Why the theorem is not forced [K] (`step_not_meet_preserving`).** There is a general route by which such closures come for free: if the step preserved binary meets, meet-closure of the compatibles would follow formally. That route is provably unavailable here. The step fails binary meet-preservation, with a kernel-checked two-element witness: for incomparable a, b, take U = ↓a and V = ↓b; the element a lies in step(U) ∩ step(V) — the step adds ↓a to V because V reaches b — but not in step(U ∩ V), which never reaches b. (This is the kernel form of the universal witness recorded in the pocket-study spec, Amendment 3.) The proof of `compatible_union` accordingly cannot and does not factor through any preservation property of the dynamics; its mixed case — b visible to one observer's image but not the other's — is closed by the key lemma `mem_obs_of_le_a`: compatibility forces the whole cone ↓a into any image that reaches b. The trajectory corollary (compatibility with each step composes over the whole trajectory, `survival_composes`) sits in the same file.

Whether Theorem 6.1's mechanism extends beyond Alexandrov carriers and single-edge steps is open **[O]** and is the one theoretical thread this note leaves deliberately hanging.

## 7. What this note claims, and what it does not

**Claimed.** The instrument and its confusion-class semantics at closure-operator generality **[K]**; the exact bridge s = δ(U, ρU) to the partial-completeness framework **[C]**; the three registered experimental results with their kill lines — the gap-filling pass with three-world robustness, the partition null (Proposition 4.1 for the abstract-side blindness, registered experiment for the absence of a concrete-side rescue), the widening attenuation with its measured margin and autopsy **[R]**; the meet-half theorem, together with the kernel-checked witness that it is not forced by any meet-preservation property of the step **[K]**.

**Not claimed.** The count, as a functional — it is the POPL 2022 quasi-metric at (U, ρU) and the MCAI false-positive count at ρ = γ∘α, and this note would be mispositioned as "a new measure of imprecision"; the territory of measuring realized imprecision is occupied by the quasi-metric, pre-metric, and model-counting families cited in §1, and what is claimed is the *prior, predictive* direction with its map. That any of this holds on infinite carriers, relational domains (octagons, polyhedra), or real analyzers — the worlds here are finite toys computed exactly, and the distance to practice is the note's largest caveat, stated without decoration. That phantom mass improves on ε-partial completeness at its own job (it does a different job: prior and per-element rather than post-hoc and per-run; the two are complementary by construction). That the four-position/ordinariness layer of the source program transfers to abstract domains — that requires non-Boolean carriers (Giacobazzi–Scozzari's Heyting completion is the established route) and is untouched here **[O]**. That the widening result generalizes to narrowing regimes **[O]**.

**The methodological claim we stand behind.** Every experiment was registered with thresholds and kill conditions before its code existed; two registered expectations were wrong (a hand anchor falsified by the world's own boundary convention; a continuity gate that mistook sampling variation for harness error) and both amendments are dated, logged with their nature, and were made before the gated results were read; one kill fired (K-P) and closed its side of the study permanently; one result survived by 0.006 and is reported at that margin. A quantitative claim gains more from a mechanism that can refuse than from a threshold it happens to clear.

## 8. Formalization and artifacts

All formal results in Lean 4 against Mathlib4; no `sorry`, no `native_decide`; axiom audits at most `propext`, `Classical.choice`, `Quot.sound`.

| Result | Lean theorem | File |
|---|---|---|
| Confusion class at uco generality (2.2) | `ClosureOperator.le_apply_iff` | `Lattice/CoApertureClosedForm.lean` |
| Confusion class, nucleus form (special case) | `IsNucleus.le_apply_iff` | ibid. |
| Meet-half theorem (6.1) | `compatible_union` | `Lattice/PocketMeetHalf.lean` |
| 6.1 not forced: step fails meet-preservation | `step_not_meet_preserving` | ibid. |
| Key lemma for 6.1 | `mem_obs_of_le_a` | ibid. |
| Trajectory composition | `survival_composes` | ibid. |
| Co-aperture closed forms, multiplicativity, independence | `CoApertureClosedForm.lean` | `Lattice/CoApertureClosedForm.lean` |
| Alexandrov Booleanization (context for §6) | `card_regular_eq_two_pow` | `Lattice/AlexandrovBoolean.lean` |

Proposition 4.1 is proved inline in §4 (four lines) and is not kernel-checked; it carries no [K] tag.

Empirical artifacts, all with dated registered specs, amendments, and postscripts: `absint-dictionary/SPEC.md` (Phase 0 literature confrontation, including the recorded retraction), `PHASE1-SPEC.md`, `PHASE1B-SPEC.md`, `PHASE2-SPEC.md`, scripts `01-worked-example.py`, `02-phase1b.py`, `03-phase2-loops.py`, raw outputs under `absint-dictionary/out/`. Oracle re-check of the decomposition and reduced-product hand proofs: `pocket-study/06-decomposition-check.py`. Source: github.com/thefalsework/papers.

**Disclosure.** Drafting and formalization were AI-assisted under direction, per the project's validation architecture and its framework for epistemic dependency (Brink 2026e); the grade table above is the author's warrant.

## How to cite

> Brink, C. (2026). *Phantom mass: an intrinsic per-element measure of abstract-domain conflation, with registered experiments on exactly when it predicts analysis error.* Draft v0.3, September 2026. Zenodo. doi:10.5281/zenodo.22802676.

---

## References

- Brink, C. (2026d). The aperture of a distinction: observer-relative ordinariness in Heyting algebras. Preprint v0.4. Zenodo. doi:10.5281/zenodo.22715068.
- Brink, C. (2026e). Epistemic dependency as structural condition. Preprint, github.com/thefalsework/papers, `papers/paper2-epistemic-dependency/`.
- Brink, C. (2026f). The perceptron is a classical element. Preprint v1.1. Zenodo. doi:10.5281/zenodo.22779865.
- Bruni, R., Giacobazzi, R., Gori, R., & Ranzato, F. (2021). A logic for locally complete abstract interpretations. *LICS 2021*.
- Campion, M., Dalla Preda, M., & Giacobazzi, R. (2022). Partial (in)completeness in abstract interpretation: limiting the imprecision in program analysis. *POPL 2022 (PACMPL 6)*.
- Campion, M., Urban, C., Dalla Preda, M., & Giacobazzi, R. (2023). A formal framework to measure the incompleteness of abstract interpretations. *SAS 2023*, LNCS 14284, 114–138.
- Citkin, A. (2024). An algebraic proof of the Nishimura theorem. *Logics*, 2(4), 148–157.
- Cousot, P., & Cousot, R. (1977). Abstract interpretation: a unified lattice model for static analysis of programs by construction or approximation of fixpoints. *POPL 1977*.
- Cousot, P., & Cousot, R. (1979). Systematic design of program analysis frameworks. *POPL 1979*.
- Giacobazzi, R., Ranzato, F., & Scozzari, F. (2000). Making abstract interpretations complete. *Journal of the ACM*, 47(2), 361–416.
- Giacobazzi, R., & Scozzari, F. (1998). A logical model for relational abstract domains. *ACM TOPLAS*, 20(5), 1067–1109. (Heyting completion.)
- Mathlib Community (2026). Mathlib4. github.com/leanprover-community/mathlib4.
- Zheng, J., & Yao, P. (2026). Analyzing the analyzers: model counting meets abstract interpretation. arXiv:2606.21992.
