# Phantom Mass: An Intrinsic Per-Element Measure of Abstract-Domain Conflation, with Registered Experiments on Exactly When It Predicts Analysis Error

**Chris Brink**
falsework.dev
**Version.** Draft v0.1, September 2026 — not yet deposited, not yet submitted.
**Status discipline.** Every claim carries one of five grades: **[K]** kernel-checked in Lean 4 against Mathlib4 (no `sorry`, no `native_decide`, axiom audits at most `propext`, `Classical.choice`, `Quot.sound`); **[C]** classical mathematics, cited; **[R]** empirical result from a pre-registered protocol (spec and kill conditions committed before code, dated postscripts binding, amendments logged with their nature); **[A]** structural analogy, argued not proved; **[O]** open. The grades are load-bearing: nothing below claims more than its tag.

---

## Abstract

An upper closure operator ρ on a concrete domain conflates each property U with everything in the interval [U, ρU]; a two-line confusion-class lemma shows this interval is exactly the set of properties ρ cannot distinguish from U from above **[K]**. We call its size the **phantom mass** of U under ρ — on a powerset carrier it is 2^{s(U)} where s(U) = |ρU ∖ U| counts the spurious concrete states manufactured at U, and s(U) is precisely the counting-measure quasi-metric from U to ρU, which places the quantity inside the partial-completeness framework of Campion, Dalla Preda and Giacobazzi (POPL 2022) while differing from it in kind: their ε is a per-run bound (program, input, supplied metric); phantom mass is a per-element, metric-free count available before any program exists **[C/K]**. The question this note registers and answers experimentally is whether the intrinsic count *predicts* the run-level completeness error that their theory bounds — whether phantom mass is an instrument or merely a definition. The answer, from three pre-registered protocols with kill conditions committed before code (12,000 + 15,200 + 3,840 exact runs on finite toy worlds): **it depends on the shape of the closure, and the boundary is now mapped. (1)** For the interval domain — a gap-filling closure — trajectory phantom predicts accumulated completeness error at pooled Spearman +0.50, robust to a world change, a seed change, and a boundary-convention change (+0.54 saturating, +0.63 wrap-around), with even the input-only variant (no trajectory) at +0.46 **[R]**. **(2)** For partition domains (sign, parity, congruence) the correlation is null (|ρ| ≤ 0.12 across four domains), and the mechanism is a proof, not a failure: a partition-domain analysis remembers *which* classes are met and never how much of a class is missing, so no cardinality-style functional of the phantom can carry information; the corrected candidate (counting partially-met classes) also failed its registered threshold in all four domains, and the registered closure rule stopped functional-shopping at two **[R]**. **(3)** Under widening the predictor survives attenuated — pooled +0.31 against a registered kill line of 0.30, reported at exactly that margin — and the registered autopsy isolates the mechanism: where widening stays quiet the intrinsic signal holds near straight-line strength (+0.46); where widening fires, analysis-manufactured imprecision dominates (+0.10), and a quarter of all error-bearing loop runs have *zero* intrinsic phantom anywhere on their trajectory, error made entirely by the widening jump — a hand anchor registered before the run **[R]**. Alongside the experiments, one theorem: on Alexandrov carriers, observers compatible with a single-step order extension are closed under support union (pointwise meet of nuclei) — a reduced-product-style closure result in a setting where general completeness theory predicts no such closure, kernel-checked **[K]**. The upshot in one line: *the intrinsic conflation count predicts accumulated analysis error where the abstraction fills gaps, provably cannot where the abstraction forgets multiplicity, and degrades gracefully — with a measured mechanism — where the analysis manufactures its own imprecision.*

---

## 1. Introduction

Abstract interpretation has a graded theory of *how wrong* an analysis can be. Completeness — the case where abstraction loses nothing relative to the property observed — was characterized by Giacobazzi, Ranzato and Scozzari (JACM 2000) as a property of the abstract domain alone, refinable by domain transformers; Bruni, Giacobazzi, Gori and Ranzato (LICS 2021) localized it to derivations; Campion, Dalla Preda and Giacobazzi (POPL 2022) made it quantitative, bounding the *partial completeness* ε of a run under a supplied quasi-metric. In that framework the error is a property of a triple: program, input, domain.

This note asks a question one level below the run: does the domain itself, evaluated at individual properties with no program in sight, carry a number that *predicts* where run-level error will accumulate? The candidate number is the size of the conflation interval [U, ρU] — how much the closure manufactures at U — which we call phantom mass. It arose in a different setting (a program studying observer-relative structure in Heyting algebras; §6 gives the two-sentence version), and the confusion-class lemma that justifies the name needs only inflationarity, monotonicity and idempotence, so it applies to every standard abstract domain as-is: it is a closure-operator-level instrument, not a nucleus-level one **[K]**.

The distinction that keeps this from being absorbed by the POPL 2022 theory is the direction of the quantity. Their ε is *extrinsic and post-hoc*: it needs the program, the input, and a metric, and it bounds one run. Phantom mass is *intrinsic and prior*: it is a per-element count determined by the domain alone. If the intrinsic count predicted nothing about run-level error, it would be a definition with good manners and no job. Whether it predicts is an empirical question, so we registered it as one — spec, thresholds, and kill conditions committed before code, in three phases, with the kill line written first: *if the intrinsic count and the run-level error decouple on the worked example, the instrument is a definition, not a predictor, and the bet ends there.*

The three phases produced a map rather than a verdict, and the map is the contribution:

- **Where it works:** gap-filling closures (the interval domain), robustly across worlds, seeds, and boundary conventions — and even in input-only form, which needs no trajectory at all (§3).
- **Where it provably cannot work:** partition closures, with a mechanism — the abstract run retains which classes are met and discards multiplicity, so cardinality-style information in the phantom has nowhere to enter the analysis (§4).
- **Where it degrades, and why:** loops under widening, where the analysis manufactures imprecision that no intrinsic quantity can see; the degradation is measured, its mechanism isolated by a registered autopsy, and the surviving signal localized to the widening-quiet region (§5).

Everything empirical here is on finite toy worlds, computed exactly. The distance from these worlds to a real analyzer is stated in §7 and not minimized. What the toys establish is the *existence and shape of the phenomenon*: the intrinsic/extrinsic gap is bridgeable for one large class of domains, unbridgeable for another, and the reason in both cases is structural, not statistical.

## 2. The instrument

**Setting [C].** A concrete domain C (here: the powerset of a finite state space Σ, ordered by inclusion). An abstract domain in the standard uco presentation is an upper closure operator ρ : C → C — monotone, inflationary (U ⊆ ρU), idempotent — whose fixpoints are the expressible properties (Cousot & Cousot 1977, 1979; the uco view of domains is standard since Giacobazzi–Ranzato–Scozzari 2000).

**Definition 2.1 (phantom mass) [K].** For a closure operator ρ and element U, the phantom mass of U under ρ is |[U, ρU]| — the cardinality of the interval between U and its closure.

**Lemma 2.2 (confusion class) [K] (`IsNucleus.le_apply_iff`).** For U ≤ X: X ≤ ρU iff ρX = ρU. The interval [U, ρU] is exactly the set of properties ρ cannot distinguish from U from above. Two lines from inflationary + monotone + idempotent, on any meet-semilattice; meet-preservation (the nucleus axiom) is *not used*, which is what licenses applying the instrument to arbitrary ucos.

**The working coordinate.** On a powerset carrier, |[U, ρU]| = 2^{s(U)} with s(U) = |ρU ∖ U|: the number of spurious concrete states the closure manufactures at U. s is the informative exponent and the additive form, and it is exactly the counting-measure quasi-metric δ(U, ρU) of Campion–Dalla Preda–Giacobazzi instantiated at the pair (U, ρU) — the precise formal bridge between this instrument and their framework, stated once and relied on throughout.

**The two run-level quantities (targets, not instruments).** For a program p = fₙ ∘ … ∘ f₁ executed abstractly by stepwise best correct approximations (a₀ = ρU, aₖ₊₁ = ρ(fₖ₊₁(aₖ)), the composition real analyzers use), against the concrete trajectory V₀ = U, Vₖ₊₁ = fₖ₊₁(Vₖ):

- **completeness error** ε(p, U, ρ) = |aₙ ∖ ρ(Vₙ)| — spurious mass beyond the best the domain could represent; the CDG-style target;
- **the intrinsic predictor** P(p, U, ρ) = Σₖ s(Vₖ) over the concrete trajectory — per-element counts at the states the program actually visits, no abstract run consulted. The input-only variant uses s(U) alone.

**Two free facts, registered as anchors so the experiments could not discover them [K-adjacent, asserted in every run].** T0: if s(Vₖ) = 0 for all k, then ε = 0 (exact trajectory forces a complete run; two-line induction). A1: phantom does *not* imply error — a class-respecting operation on a partition domain has ε = 0 at any phantom. The statistical question lives strictly between these two poles.

## 3. Phase 1–1b: the gap-filling case, and its robustness

**Protocol (registered before code; `absint-dictionary/PHASE1-SPEC.md`, `PHASE1B-SPEC.md`) [R].** World A: Σ = {−8..8}, five ucos — Parity, Mod3, Sign, Sign×Parity (partition closures), Interval (ρU = [min U, max U]; the gap-filling closure) — 50 programs over a 10-operation alphabet (saturating arithmetic and guards), 48 inputs, 12,000 exact runs. Registered thresholds: within-domain pooled Spearman(P, ε) ≥ 0.5 with length-stratified median ≥ 0.3 (the stratification guard against the length confound: longer programs accumulate both phantom and error). Kill KP1: pooled < 0.3 in every domain.

**Result.** The kill did not fire, and the registered universal claim failed — the split *is* the finding:

| domain | pooled ρ(P, ε) | length-stratified median | input-only ρ(s(U), ε) |
|---|---|---|---|
| Parity | +0.03 | −0.23 | −0.17 |
| Mod3 | −0.00 | −0.27 | −0.18 |
| Sign | +0.12 | +0.04 | +0.02 |
| Sign×Parity | +0.05 | +0.11 | +0.04 |
| **Interval** | **+0.50** | **+0.51** | **+0.46** |

T0 held on all 1,479 exact-trajectory runs. One registered hand anchor was *wrong* and the validation gate caught it before any survey result was read: "increment respects parity classes" is false under saturating arithmetic (inc(8) = 8 stays even), a logged amendment that also surfaced an incidental mechanism — boundary saturation converts phantom into error.

**Robustness (Phase 1b) [R].** The one pass could have been world/seed luck, so it was retested under a registered kill (K-R: pooled < 0.3 in the fresh world ends the predictor claim). World B (Σ = {−12..12}, fresh seed, fresh programs and inputs, saturation): pooled **+0.54**, stratified median +0.52 — passes the unchanged thresholds. World C (same but wrap-around arithmetic, registered as *adversarial* because wrapping shatters interval hulls): pooled **+0.63** — stronger, in the world expected to hurt. Pre-registered reading: the pass is a property of the closure's shape, not of op–hull alignment. (Logged without weight: wrap produces more error and more spread, which mechanically flatters rank correlations; the conclusion does not depend on +0.63 exceeding +0.54.)

## 4. The partition side: a null with a proof

The four partition domains show no signal, and the reason is structural. A partition-domain abstract state is a union of met classes; the abstract transfer of any operation depends only on *which* classes are met. The magnitude s(V) — how many elements of the met classes are missing from V — has no channel into the abstract run at all. Cardinality-style phantom information is not weakly predictive for partition domains; it is *unrepresented*.

The registered corrected candidate — c(V) = the number of partially-met classes, the coarsest functional that could matter — was tested in Phase 1b with its own thresholds (≥ 0.3 pooled in ≥ 3 of 4 domains) and its own closure rule (K-P: all four below 0.2 closes the partition side, functional-shopping stops at two). **K-P fired**: pooled −0.07 (Parity), −0.10 (Mod3), +0.06 (Sign), +0.01 (Sign×Parity) **[R]**.

The honest statement of the null: for partition closures, error is governed by *op–class alignment* — whether the program's operations respect the partition — which is a property of the dynamics, not of the elements. Prediction there requires op-awareness, and an intrinsic per-element instrument is intrinsically the wrong tool. We regard this as the second-most useful result in the note: it says which abstractions can in principle be audited statically by conflation counting (gap-filling ones) and which can only be profiled by running them (partition ones).

## 5. Phase 2: loops and widening

Real interval analysis loses its precision in loops, through widening, so the reviewer's question was registered and run before any write-up (`PHASE2-SPEC.md`): toy language extended with `while` loops over five guards, concrete collecting semantics computed exactly as a finite fixpoint, abstract semantics by the standard widening iteration (unstable bounds jump to the world bounds; no narrowing — its absence makes the world harder for the *analysis*, not for the claim).

**The structural threat, hand-witnessed before the run [R].** Widening manufactures imprecision that is not intrinsic to the states, so T0 is *provably false* on loops. Registered anchor A-W: `while (x < 3) inc` on input {0} — every set the computation touches is an exact interval, intrinsic phantom P = 0, yet the widened invariant jumps to [0, 8] and ε = 5. Error at zero phantom, by construction. At scale the mechanism is common: 286 of 2,400 loop runs (a quarter of all error-bearing runs) have ε > 0 with P = 0.

**Result [R].** Loop corpus (50 programs, half the items loops, 2,400 runs, ε > 0 in 49.5% — more than double the straight-line rate): pooled Spearman(P, ε) = **+0.306** against a registered kill line of 0.30. The registered verdict band calls this *survives attenuated*; we report the margin at full strength — 0.006 of Spearman, a different seed could plausibly have fired the kill. The registered autopsy is what makes the number a mechanism rather than an ambiguity. Widening jump mass W (an analysis-side meter, registered as descriptive) predicts error at +0.49 — better than the intrinsic count. Conditioning on W: within the widening-quiet tercile, ρ(P, ε) = **+0.46**, near straight-line strength; within the widening-heavy tercile, **+0.10** — swamped. The pooled figure is just this mixture.

One amendment, logged before any loop-corpus number was read: the continuity gate (loop-free control must reproduce the Phase 1 result) fired at +0.47 against a registered 0.50; an exact cross-engine check — the identical 1,440 loop-free runs through the Phase 1 engine and the new harness — returned zero mismatches in both ε and P, so the gate had mistaken sampling variation near the threshold for harness error and was replaced by the strictly stronger equality check. Loop-corpus thresholds were not touched.

**The qualified claim after Phase 2.** Intrinsic phantom predicts interval-analysis error on straight-line code and on loop code where widening does not fire; where widening fires, the analysis's own manufactured imprecision dominates, and the quantity that predicts *that* (W) requires running the analysis — which is exactly what an intrinsic instrument exists to avoid. The qualifier is permanent absent a narrowing study **[O]**.

## 6. One theorem, and the program this came from

The instrument arrived here from a program studying observer-relative structure in Heyting algebras — which distinctions survive coarse-graining (the *aperture* of an element: under how many nuclei it remains *ordinary* in Citkin's sense) and what coarse-graining destroys (the *co-aperture*: total phantom mass over all observers; closed forms on chains and divisor lattices, exact multiplicativity on products, and independence from the aperture in both directions, all kernel-checked — Brink 2026d, 2026f). Phase 0 of the present study was a literature confrontation, recorded in the spec with a dated retraction where needed: the program's *dynamical compatibility* notion (observers commuting with a time step) decomposes exactly as backward ∧ forward completeness in the GRS sense — a hand proof re-checked by exhaustive oracle over 131,320 (step, observer) pairs with zero mismatches — so that layer is absorbed by existing completeness theory and is claimed by no one here **[C/R]**.

What survived the confrontation is one closure theorem apparently outside the existing theory's predictions:

**Theorem 6.1 (meet-half of the lattice conjecture) [K] (`compatible_union`, `PocketMeetHalf.lean`).** On the down-set algebra of a finite poset, with observers the sub-ecosystem nuclei j_S and the time step a single-edge order extension: if S and T are both compatible with the step (equivalently, both backward- and forward-complete for it), then S ∪ T is compatible. Since j_{S∪T} is the pointwise meet of j_S and j_T — the reduced product of the two domains — this is a *completeness-preservation result for the reduced product of tied domains*, in a setting where general theory predicts no such closure (completeness is not, in general, preserved by domain combination). Kernel-checked, with the key lemma (`mem_obs_of_le_a`) and the trajectory corollary (compatibility with each step composes over the whole trajectory, `survival_composes`) in the same file.

Whether Theorem 6.1's mechanism extends beyond Alexandrov carriers and single-edge steps is open **[O]** and is the one theoretical thread this note leaves deliberately hanging.

## 7. What this note claims, and what it does not

**Claimed.** The instrument and its confusion-class semantics at closure-operator generality **[K]**; the exact bridge s = δ(U, ρU) to the partial-completeness framework **[C]**; the three registered experimental results with their kill lines — the gap-filling pass with three-world robustness, the partition null with its mechanism and registered closure, the widening attenuation with its measured margin and autopsy **[R]**; the meet-half theorem **[K]**.

**Not claimed.** That any of this holds on infinite carriers, relational domains (octagons, polyhedra), or real analyzers — the worlds here are finite toys computed exactly, and the distance to practice is the note's largest caveat, stated without decoration. That phantom mass improves on ε-partial completeness at its own job (it does a different job: prior and per-element rather than post-hoc and per-run; the two are complementary by construction). That the four-position/ordinariness layer of the source program transfers to abstract domains — that requires non-Boolean carriers (Giacobazzi–Scozzari's Heyting completion is the established route) and is untouched here **[O]**. That the widening result generalizes to narrowing regimes **[O]**.

**The methodological claim we stand behind.** Every experiment was registered with thresholds and kill conditions before its code existed; two registered expectations were wrong (a hand anchor falsified by the world's own boundary convention; a continuity gate that mistook sampling variation for harness error) and both amendments are dated, logged with their nature, and were made before the gated results were read; one kill fired (K-P) and closed its side of the study permanently; one result survived by 0.006 and is reported at that margin. A quantitative claim gains more from a mechanism that can refuse than from a threshold it happens to clear.

## 8. Formalization and artifacts

All formal results in Lean 4 against Mathlib4; no `sorry`, no `native_decide`; axiom audits at most `propext`, `Classical.choice`, `Quot.sound`.

| Result | Lean theorem | File |
|---|---|---|
| Confusion class (2.2) | `IsNucleus.le_apply_iff` | `Lattice/CoApertureClosedForm.lean` |
| Meet-half theorem (6.1) | `compatible_union` | `Lattice/PocketMeetHalf.lean` |
| Key lemma for 6.1 | `mem_obs_of_le_a` | ibid. |
| Trajectory composition | `survival_composes` | ibid. |
| Co-aperture closed forms, multiplicativity, independence | `CoApertureClosedForm.lean` | ibid. |
| Alexandrov Booleanization (context for §6) | `card_regular_eq_two_pow` | `Lattice/AlexandrovBoolean.lean` |

Empirical artifacts, all with dated registered specs, amendments, and postscripts: `absint-dictionary/SPEC.md` (Phase 0 literature confrontation, including the recorded retraction), `PHASE1-SPEC.md`, `PHASE1B-SPEC.md`, `PHASE2-SPEC.md`, scripts `01-worked-example.py`, `02-phase1b.py`, `03-phase2-loops.py`, raw outputs under `absint-dictionary/out/`. Oracle re-check of the decomposition and reduced-product hand proofs: `pocket-study/06-decomposition-check.py`. Source: github.com/thefalsework/papers.

**Disclosure.** Drafting and formalization were AI-assisted under direction, per the project's validation architecture and its framework for epistemic dependency (Brink 2026e); the grade table above is the author's warrant.

## How to cite

> Brink, C. (2026). *Phantom mass: an intrinsic per-element measure of abstract-domain conflation, with registered experiments on exactly when it predicts analysis error.* Draft v0.1, September 2026. (Zenodo DOI to be assigned on deposit.)

---

## References

- Brink, C. (2026d). The aperture of a distinction: observer-relative ordinariness in Heyting algebras. Preprint v0.4. Zenodo. doi:10.5281/zenodo.22715068.
- Brink, C. (2026e). Epistemic dependency as structural condition. Preprint, github.com/thefalsework/papers, `papers/paper2-epistemic-dependency/`.
- Brink, C. (2026f). The perceptron is a classical element. Preprint v1.1. Zenodo. doi:10.5281/zenodo.22779865.
- Bruni, R., Giacobazzi, R., Gori, R., & Ranzato, F. (2021). A logic for locally complete abstract interpretations. *LICS 2021*.
- Campion, M., Dalla Preda, M., & Giacobazzi, R. (2022). Partial (in)completeness in abstract interpretation: limiting the imprecision in program analysis. *POPL 2022 (PACMPL 6)*.
- Citkin, A. (2024). An algebraic proof of the Nishimura theorem. *Logics*, 2(4), 148–157.
- Cousot, P., & Cousot, R. (1977). Abstract interpretation: a unified lattice model for static analysis of programs by construction or approximation of fixpoints. *POPL 1977*.
- Cousot, P., & Cousot, R. (1979). Systematic design of program analysis frameworks. *POPL 1979*.
- Giacobazzi, R., Ranzato, F., & Scozzari, F. (2000). Making abstract interpretations complete. *Journal of the ACM*, 47(2), 361–416.
- Giacobazzi, R., & Scozzari, F. (1998). A logical model for relational abstract domains. *ACM TOPLAS*, 20(5), 1067–1109. (Heyting completion.)
- Mathlib Community (2026). Mathlib4. github.com/leanprover-community/mathlib4.
