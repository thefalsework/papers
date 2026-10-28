# The shape of an aperture in the nucleus lattice

**Companion note to** *The Aperture of a Distinction* (`paper.md`, same directory).
**Date.** 2026-10-28 (triple form stated 2026-10-27). **Status.** Repository note; results graded per the paper's discipline.
**Artifacts.** `lean/FalseWorkPapers/Lattice/ApertureCriterion.lean` (criterion, witness triples, fiber theorem, Div180 witness; axiom audit: `propext`, `Classical.choice`, `Quot.sound`, no `sorry`); `wolfram/aperture-shape.mjs` (sweep; question and anchors pre-registered in its header). The 2026-10-27 note that first stated the triple form had no reproduction scripts in the repository; the Lean file and this sweep are the record.

## 1. The question

The aperture Ap(k) is a set of nuclei. Nuclei on a Heyting algebra form a lattice (the lattice of subtoposes, or of sublocales), so one can ask what *kind* of subset Ap(k) is. The question was put to us in this form: since ordinariness is "not dense and not regular", is Ap(k) always the intersection of two order-convex families in the nucleus lattice, and is Ap(k) itself always order-convex? The prior evidence pointed that way: on the Rieger–Nishimura truncations Z₆–Z₁₄ the generator's aperture is a principal up-set (every observer above a three-point core), and principal up-sets are convex.

On the down-set algebra D(P) of a finite poset P, nuclei are the sub-ecosystem observers j_S for S ⊆ P (`subNucleusEquiv`, **[K]**), ordered by inclusion of S (S ⊆ T means j_T is finer: j_T ≤ j_S pointwise). The question is therefore finitely checkable on every finite Heyting algebra, since every one is some D(P).

## 2. The witness-triple theorem

**Definition.** For a down-set k of P, a *witness triple* is (c, x, u) with c ∈ k, x ∉ k, u ∉ k, c < x, c ≰ u, u ≰ x (`WitnessTriple`). Then u is incomparable to both c and x, so the induced poset on {c, x, u} is a 2-chain plus a point: the poset of join-irreducibles of Div12. Its world D({c, x, u}) is Div12, and the trace {c} is the kernel 2, the tritone.

A triple is *valid in S* (with {c, x, u} ⊆ S) if no point of S ∩ k lies below u, and every point of S \ k below x has a point of S ∩ k below it (`WitnessTriple.IsValidIn`).

> **Theorem [K]** (`opens_subNucleus_iff_witnessTriple`).
> 1. j_S opens k iff S contains a witness triple valid in S.
> 2. The coarsest observers that open k (the inclusion-minimal elements of Ap(k)) are exactly the witness triples (`WitnessTriple.eq_of_subset_opens`, `exists_witnessTriple_eq_carrier_of_minimal`). Each sees exactly a Div12 world, with k appearing as the tritone.

*Proof.* Equivalent to the pointwise criterion (`opens_subNucleus_iff_minimal`, **[K]**): with M = min S, j_S opens k iff (i) some point of M lies outside k and (ii) some s ∈ S outside k has every M-point below it inside k. That criterion is the trace characterization (`opens_subNucleus_iff`) unpacked on a finite poset: density of a down-set is a condition on the minimal points (`LowerSet.compl_eq_bot_iff_isMin_mem`), regularity likewise (`LowerSet.compl_compl_eq_self_iff_isMin`).

(⇒) From (ii), take an S-minimal c below s; it lies in k, and c < s since s ∉ k. From (i), an S-minimal m ∉ k cannot lie below s (else (ii) would put it in k). Then (c, s, m) is a witness triple, valid in S: nothing of S ∩ k lies below m because m is S-minimal and outside k, and every S-point outside k below s is anchored by an S-minimal point which (ii) places in k.

(⇐) Given a valid triple, an S-minimal point below u lies outside k (else a point of S ∩ k would lie below u), witnessing (i). For (ii), take s = x: an S-minimal m' below x that lay outside k would be a point of S \ k below x with nothing of S ∩ k below it (minimality), contradicting validity.

(2) A triple is valid in itself (`WitnessTriple.valid_in_self`): c ≰ u, and the only point of the triple outside k below x is x itself, which c anchors. By (1) every member of Ap(k) contains a triple (`exists_witnessTriple_subset`). No proper subset of a triple opens k, since a witness triple has three distinct points (x has k below it, u does not, and c is in k). ∎

The triple form was stated 2026-10-27; the argument above is the one given there, transported across the minimal-point criterion.

## 3. Corollaries

**C1. Positivity, in general [K]** (`exists_opens_iff_exists_witnessTriple`). Ap(k) ≠ ∅ iff P contains a witness triple. On divisor lattices this is Corollary 5.3 of the aperture paper: x must sit in a chain where k's exponent is strictly interior, and u in a different chain below its top. This upgrades the general "iff" the aperture paper leaves at computed grade (Result 6.3) to proved, and extends it from divisor lattices to every finite Heyting algebra.

**C2. Latency explained [K]** (`latent_iff_all_triples_spoiled`). k is latent (not ordinary, yet Ap(k) ≠ ∅) iff P contains witness triples but none is valid in P: every Div12 skeleton is spoiled at full resolution, either by a point of k below u or by an unanchored outside point below x. An observer that stops seeing the spoilers opens k. Div36's element 6 has exactly two triples, both spoiled in P, so Ap(6) is exactly those two observers — reproducing `aperture_six_complete` **[K]** by a different route.

**C3. Div12, relativized [K]** (`exists_witnessTriple_subset`). Theorem 2.3 of the aperture paper (**[K]**: ordinary k forces Div12) is the S = P case. The theorem says more: every observer that keeps any distinction generative contains a sub-observer seeing exactly the tritone lattice, with that distinction as its tritone.

**C4. The one-eighth law for Zₙ [computed, n = 6–14; argued from the criterion].** The free generator of Zₙ has exactly one witness triple — q₁ ∈ g, q₃ covering q₁, q₂ the other minimal point — and nothing in P ever spoils it. So Ap(g) is every superset of that triple: 2^{|P|−3} observers, one-eighth of all of them. Proving "unique and unspoilable" for every n needs the Rieger–Nishimura ladder's structure **[O]**. The argument passes unchanged to the full ladder as a statement about spatial nuclei.

**C5. Why apertures are not convex [K on the witness; computed on the rate].** Spoiling explains it. Seeing more can introduce a spoiler (a point of k below u, or an unanchored outside point below x) and close the four-fold; seeing more again can add a fresh unspoiled triple and reopen it. The Div180 witness (`aperture_not_convex_div180`, **[K]**): P = {0<3} ⊔ {1<4} ⊔ {2}, k = {0,1} the kernel 6. Observer S₁ = {0,3,4} opens k via the triple (0, 3, 4). Adding 1 puts a point of k below u = 4, spoils that triple, and S₂ = {0,1,3,4} closes k. Adding the isolated point 2 supplies a fresh u, and S₃ = P opens k again. The closing step is the one that lowers the observer's bottom (`bot_S₁_ne_bot_S₂`).

## 4. The mechanism: a fibration by bottoms

Triples say *which* observers open k. The fiber theorem says *when refinement can close it*.

The bottom of an observer is determined by the minimal points it sees: x ∈ j_S(⊥) iff no point of S lies below x (`mem_subNucleus_bot_iff`), so j_S(⊥) = P ∖ ↑M with M = min S, and two observers have the same bottom iff they have the same minimal set (`minimal_mem_iff_of_subNucleus_bot_eq`). An observer that sees only its own atoms (S = M) opens nothing: a triple needs a non-minimal x.

> **Fiber monotonicity [K]** (`opens_subNucleus_of_subset_of_bot_eq`). If S ⊆ T and j_S(⊥) = j_T(⊥), then j_S opens k implies j_T opens k. Within each fiber of the bottom map, Ap(k) is an up-set.

So **refinement that keeps the bottom never closes a four-fold; only refinement that lowers the bottom — revealing a point beneath something the coarser observer took as ground — can.** In triple language: a spoiler can only enter below u or below x, and those are exactly the bottom-lowering steps. Every convexity failure is of that form.

The aperture is not "robustness to blur": it is not monotone under refinement in either direction, and it is not even convex. The right picture is this fibration. The observer-reading in §8 of the paper should be stated this way: what an observer can and cannot see of a distinction's four-fold is governed first by *what it takes to be bottom*, and only then by how finely it resolves above that.

## 5. Sweep

**[computed].** All posets on 1–7 points up to isomorphism (1, 2, 5, 16, 63, 318, 2045; A000112), hence all finite Heyting algebras whose join-irreducibles number at most seven; every nucleus on each (2^|P|, generated by subsets and re-checked against the three nucleus laws; on every algebra with at most 12 elements the count was also cross-checked against brute force over meet-closed families containing ⊤); every kernel k ∈ D(P). 54,723 (algebra, kernel) pairs. The paper's anchors are reproduced exactly (Div12: Ap(2) = {identity}, coAp = 18; Div36: Ap(6) is the two named nuclei; Div24: 3, 3), as is the Z₆–Z₁₄ table (apertures 1, 2, 2, 4, 4, 8, 8, 16, 16; co-apertures 18, 38, 42, 86, 90, 182, 186, 374, 378). The criterion, the bottom formula, and fiber monotonicity recorded zero failures (`criterionFail: 0`, `bottomMismatch: 0`, `fiberNotUp: 0`).

- Of 31,910 non-empty apertures, **12,355 are not order-convex** (39%). The first failures are at |P| = 5.
- Neither factor family is convex. The not-world-dense family fails on Div12 itself; the not-world-regular family first fails at four points.
- Of the non-empty apertures, 1,927 of 2,730 through six points are not up-sets and 2,730 − 173 are not principal up-sets. The Zₙ pattern is special.
- Latency is generic off products of chains: 18,685 of 54,723 pairs have non-empty aperture without the kernel being ambiently ordinary.

The 2026-10-27 enumeration (101,658 labelled (P, k) pairs through 6 points, 219/2,030 non-convex through 5) is the same phenomenon under labelled rather than isomorphism-class weighting; its scripts (`sweep.py`, `triple.py`) are not in the repository.

## 6. Grades

| claim | grade |
|---|---|
| witness-triple theorem (opens iff valid triple; coarsest observers are the triples) | [K] `opens_subNucleus_iff_witnessTriple`, `WitnessTriple.eq_of_subset_opens` |
| every opening observer contains a Div12 (C3) | [K] `exists_witnessTriple_subset` |
| positivity: Ap(k) ≠ ∅ iff a witness triple exists (C1) | [K] `exists_opens_iff_exists_witnessTriple` |
| latency iff all triples spoiled at full resolution (C2) | [K] `latent_iff_all_triples_spoiled` |
| aperture criterion (pointwise, via minimal elements) | [K] `opens_subNucleus_iff_minimal` |
| density/regularity of down-sets are conditions on minimal points | [K] `LowerSet.compl_eq_bot_iff_isMin_mem`, `LowerSet.compl_compl_eq_self_iff_isMin` |
| bottom = complement of up-closure; same bottom ⟺ same minimal set | [K] `mem_subNucleus_bot_iff`, `minimal_mem_iff_of_subNucleus_bot_eq` |
| fiber monotonicity | [K] `opens_subNucleus_of_subset_of_bot_eq` |
| apertures are not order-convex (Div180, kernel 6) | [K] `aperture_not_convex_div180`, `bot_S₁_ne_bot_S₂` |
| convexity fails in 39% of non-empty apertures through seven points; neither factor family convex | [computed] `wolfram/aperture-shape.mjs` |
| three-point core and \|Ap(g)\| = 2^{\|P\|−3} on Zₙ (C4) | argued from the criterion in text; [computed] n = 6..14; general-n formalization open |
| Z₆–Z₁₄ aperture and co-aperture table; co-aperture recursion c(2m+1) = 2c(2m)+2, c(2m+2) = c(2m+1)+4 | [computed]; recursion unexplained, [O] |
| extension to the full Rieger–Nishimura ladder (spatial nuclei) | [O] |
| novelty of the triple form vs. the duality / nuclear-ranges literature (Bezhanishvili et al.; Erné) | [O]; literature check before any priority claim |
