# The Aperture of a Distinction: Observer-Relative Ordinariness in Heyting Algebras

**Author.** Chris Brink (independent)
**Version.** Draft v0.3, August 2026 — not yet posted. v0.3 (2026-08-24) corrects
the latency characterization of Result 6.2 and Corollary 5.3: the "every exponent
strictly interior" rule is valid only for exactly-two-prime lattices; it fails in
both directions outside them (Div8 elements 2, 4: all-interior yet empty aperture;
Div180 element 30: exponent at a chain top yet aperture 4). Both counterexamples
were present, unread, in this paper's own 164-element verification set; the closed
form and the enumeration were never wrong — the prose summary of them was. See
Result 6.3. The v0.2 text (with the error) is preserved in the DOI'd release
2026.08 snapshot (10.5281/zenodo.22016585); this correction supersedes it.
v0.3 also completes the closed form's formalization: Theorem 5.1 is now
kernel-checked at every arity (`aperture_closed_form_pi`), with both
correction counterexamples certified as instances.
**Target.** arXiv cs.AI (endorsement channel open); math.LO cross-list candidate
**Status discipline.** Every claim in this paper carries one of four grades: **[K]** kernel-checked in Lean 4 against Mathlib4; **[C]** classical mathematics, cited; **[computed]** exhaustive finite computation, verified by two independent implementations but not yet kernel-checked; **[A]** structural analogy, argued not proved; **[O]** open. The grades are load-bearing: nothing below claims more than its tag.

---

## Abstract

An element of a Heyting algebra is *ordinary* (Citkin) when it is neither regular (¬¬k = k) nor dense (¬k = ⊥). A prior kernel-checked result of this program shows that a four-position partition of structural positions around a distinguished element — the *kernel* of a distinction — is non-degenerate exactly when that element is ordinary **[K]**. This paper relativizes ordinariness to a nucleus. For a nucleus j on a Heyting algebra H, the fix-set Fix(j) is a Heyting algebra with bottom j(⊥) and inherited implication **[C]**; we define the **aperture** of an element k as the set of nuclei j under which j(k) is ordinary *inside Fix(j)*, and compute it exhaustively across fifteen finite algebras under a two-implementation agreement discipline. Two results are central. First, the existence and characterization of **latently ordinary** elements: elements that are not ordinary in H — the four-position partition around them is degenerate — but whose image is ordinary in Fix(j) for suitable proper nuclei j. On Div36 the element 6 is dense, yet exactly two proper nuclei open a four-fold around it that the identity cannot see — both the existence of the witnesses and the exactness ("exactly two") are kernel-checked in Lean **[K]**. Latency is characterized on divisor lattices — an element is latent iff no exponent is zero, some exponent is strictly interior, and some *other* prime's exponent lies below its chain top **[computed]**; this corrects (v0.3) an earlier "every exponent strictly interior" rule that a ten-algebra sweep had confirmed only because every lattice in the sweep was two-prime or square-free, exactly the shapes where the two rules coincide — at three or more primes a coarse world can truncate or drop a chain entirely, and Div180's element 30 (exponents (1,1,1), aperture 4) is latent in exactly that way. The corrected rule agrees with exhaustive enumeration on all 164 elements of the fifteen lattices and with the closed form on 252 further formula-only points; the predicted *impossibility* of latency across the family Div(2^a·3) and all square-free lattices survives the correction intact. Second, a **closed form for the aperture size of every element of every divisor lattice**: nuclei on finite products factor componentwise (an elementary lemma proved in §5), density and regularity in a product world are coordinate-local, and inclusion-exclusion over per-chain counts yields |Ap(k)| = ∏N_c − ∏D_c − ∏R_c + ∏DR_c, exact on all 164 elements of the fifteen lattices tested, including the 109 elements where the formula must cancel to zero **[computed]**. All three steps of the derivation are kernel-checked in Lean — the factorization lemma in full generality, coordinate-locality, and the per-chain counts on arbitrary finite bounded chains — and the assembled formula is itself a kernel-checked theorem on **every divisor lattice, for any number of primes and every kernel including mixed ones [K]** (`aperture_closed_form_pi`): nuclei on finite products factor componentwise at any arity, and the inclusion-exclusion does not grow with the number of chains. Both counterexamples of the v0.3 correction are kernel-checked instances of the formula (Div180's element 30: aperture 4; Div8's all-interior elements: aperture 0). The closed form subsumes the latency characterization, the product law |Ap(2^k)| = (2^k − 1)(2^(a−k) − 1) observed on Div(2^a·3), and the latent aperture sizes that an earlier draft had deliberately declined to curve-fit. A structural analogy to observer theories of coarse-graining in computational frameworks is stated as an analogy **[A]**, with its disanalogy — nuclei model static resolution, computational irreducibility models temporal cost — stated as an open problem, not a result **[O]**.

## 1. Introduction

Fix a Heyting algebra H and an element k. Citkin calls k **ordinary** when it is neither regular (¬¬k = k) nor dense (¬k = ⊥); a prior kernel-checked theorem of this program (§2) shows that a four-position partition of positions relative to k is non-degenerate exactly when k is ordinary. Ordinariness is thus the precise condition under which a distinction supports a full position space.

A **nucleus** j on H — equivalently the subobject trace of a Lawvere–Tierney topology, equivalently a sheafification **[C]** — is an inflationary, idempotent, binary-meet-preserving operator, and its fix-set Fix(j) is again a Heyting algebra, with bottom j(⊥) and implication inherited **[C]**. This paper asks the relativized question: *for which nuclei j is j(k) ordinary in Fix(j)?* We call that set of nuclei the **aperture** of k. On finite algebras it is exhaustively enumerable, and this paper enumerates it.

The mathematical payoff is twofold. First, a phenomenon the ambient theory cannot express: **latently ordinary** elements — elements not ordinary in H whose images become ordinary in the world of a proper nucleus. A dense element has no complementary structure to push against at full resolution; the right coarse-graining raises the bottom, and against the new bottom the element acquires a nontrivial negation and a full four-fold opens. We exhibit the smallest case — with the witness and its exactness kernel-checked in Lean — and characterize exactly where latency occurs on divisor lattices (a first characterization was stated before the confirming sweep and later corrected when its sweep proved too narrow to expose it; the corrected rule and both counterexamples are Result 6.3). Second, the aperture on divisor lattices is not merely enumerable but **computable in closed form**: §5 derives, from an elementary factorization lemma and per-chain counting, a formula for |Ap(k)| that is exact on every element of every lattice tested — 164 elements, zero mismatches — and from which the latency characterization and all observed scaling laws follow as corollaries.

The motivating reading — nuclei as observers, Fix(j) as the world at an observer's resolution, the aperture as *which observers see a distinction's position space open* — is stated in §7, as an analogy and after the mathematics. The theorems and computations stand without it.

This paper defines the invariant, computes it exhaustively on fifteen finite algebras, and reports what the computation says, with every claim graded.

Terminological note: "kernel" throughout means the distinguished element of the algebra around which the partition is taken (this program's usage), not the congruence kernel of the nucleus. Where the two could collide we write j(⊥) for the latter's bottom.

## 2. Preliminaries

Throughout, H is a Heyting algebra with bottom ⊥, top ⊤, meet ∧, join ∨, implication ⇒, and negation ¬x = x ⇒ ⊥.

**Definition 2.1 (Citkin).** An element k ∈ H is **regular** if ¬¬k = k, **dense** if ¬k = ⊥, and **ordinary** if it is neither.

**Theorem 2.2 (the bridge, [K]).** The four-position partition around a kernel is non-degenerate — all four cells inhabited — if and only if the kernel is ordinary. Kernel-checked as `isOrdinary_iff_allFourCells` and, at the morphism level, `partition_nondegenerate_iff_kernel_ordinary` (`lean/FalseWorkPapers/Positions/OrdinaryKernel.lean`); axiom audit: standard Mathlib axioms only, no `sorry`.

**Theorem 2.3 (the threshold, [K]).** Any Heyting algebra containing an ordinary element has at least six elements and order-embeds the divisor lattice of 12 (`ordinary_kernel_div12_embedding`, ibid.; the structure theory is developed in the companion preprint `ordinary-elements-z6/`). Div12 is therefore the *minimal kernel-bearing algebra*: the smallest world in which a four-fold can open at all.

**Definition 2.4.** A **nucleus** on H is a function j : H → H that is inflationary (x ≤ j x), idempotent (j(j x) = j x), and binary-meet-preserving (j(x ∧ y) = j x ∧ j y). **[C]** Nuclei are exactly the subobject traces of Lawvere–Tierney topologies on the corresponding topos; their fix-sets Fix(j) = { x : j x = x } are Heyting algebras with bottom j(⊥), meets inherited, joins j(x ∨ y), and **implication inherited** — for x, y ∈ Fix(j), x ⇒ y already lies in Fix(j). (Johnstone, *Stone Spaces* / *Sketches of an Elephant*; Mac Lane–Moerdijk.) The double-negation operator x ↦ ¬¬x is always a nucleus and its fix-set is Boolean **[C]** (Glivenko).

**Prior kernel-checked instance [K].** On Div12 the *maximal* tritone-closing closure operator (Moore family {2, 4, 6, 12}) is a nucleus, and the *minimal* one (Moore family {2, 12}) is not (`tritoneNucleus_isNucleus`, `tritoneClosure_not_nucleus`, `lean/FalseWorkPapers/Examples/DivisorLattice12Nucleus.lean`). These two theorems serve below as ground-truth anchors that any correct enumeration must reproduce.

## 3. The aperture

**Definition 3.1.** Let k ∈ H and let j be a nucleus on H. Write ⊥ⱼ = j(⊥) and, for x ∈ Fix(j), ¬ⱼx = x ⇒ ⊥ⱼ (the negation of the world Fix(j); the value lies in Fix(j) by Definition 2.4). Say **j opens k** if j(k) is ordinary in Fix(j):

  ¬ⱼ(j k) ≠ ⊥ⱼ  (non-dense in the world)  and  ¬ⱼ¬ⱼ(j k) ≠ j k  (non-regular in the world).

**Definition 3.2.** The **aperture** of k is Ap(k) = { j a nucleus on H : j opens k }. By Theorem 2.2, Ap(k) is exactly the set of observers whose world exhibits a non-degenerate four-fold around the image of k. On finite H, Ap(k) is finite and exhaustively enumerable.

**Remark 3.3 (ambient vs. observer-relative — the two claims are different and both true).** The Lean file cited in §2 proves that the tritone nucleus's kernel image is non-regular *in the ambient algebra* **[K]**. Definition 3.1 asks a different question: ordinariness *inside the observer's world*. For the tritone nucleus these answers differ — in its own world the tritone has become the bottom ⊥ⱼ, and a bottom is regular, so the tritone nucleus does *not* open the tritone. The aperture is deliberately the observer-relative reading: "its fixed-point algebra is the world at that resolution" is the semantics the invariant is built to capture. Stating this explicitly prevents an apparent (nonexistent) conflict with the Lean result.

**Remark 3.4 (identity and extremes).** The identity is a nucleus and opens k iff k is ordinary ambiently. The constant-⊤ nucleus (the blind observer, one-point world) opens nothing. The double-negation nucleus opens nothing either — its world is Boolean, and Boolean worlds have no ordinary elements **[C]**. The four-fold lives strictly outside the fully reduced pocket.

## 4. Computation

**Method.** Two independent implementations, written before either was run against the other's output, must agree exactly:

1. A brute-force reference: enumerate all |H|^|H| functions, filter by the three nucleus laws (feasible to |H| = 8).
2. The production enumerator: enumerate meet-closed subsets containing ⊤, induce j(a) = least member of the subset above a, keep exactly the candidates satisfying the three laws. This is sound and exhaustive *without* trusting any characterization theorem: the elementary direction (every nucleus fix-set is meet-closed and contains ⊤) suffices for candidate generation, and the laws are checked directly.

The two algorithms agree on all algebras where both are feasible (Div12, Div6, the 4-chain, Div24) **[computed]**. The production enumerator alone handles the larger algebras, and is itself implemented twice — Node.js and Wolfram Language, written independently — with the Wolfram implementation run in Wolfram Cloud against pre-registered expectations. Both Lean anchors from §2 are reproduced: the tritone nucleus appears in the Div12 enumeration; the tritone closure is rejected. Source: `wolfram/aperture-prototype.wl` and `wolfram/aperture-scaling.wl` in the repository, each a self-contained Wolfram Cloud cell with the expected outputs pre-registered in its header; the Node.js reference is described in the repository's design notes. Cloud-evaluated notebooks are archived at `wolfram/results/wolfram-cloud-run-2026-08-11-v2.1.nb` and `wolfram/results/wolfram-cloud-run-2026-08-12-v2.2.nb` (the latter includes the closed-form check). The latency sweep is `wolfram/latency-sweep.mjs` (Node), with its prediction stated in the file header before the run; Div72 and the latency characterization check were pre-registered in `aperture-scaling.wl` and **confirmed in Wolfram Cloud 2026-08-11** (all eight latency checks CONFIRMED, Div72 latent {6, 12} with apertures 6 and 4 as predicted). The closed-form verification (§5) is `wolfram/aperture-closed-form.mjs`, covering all fifteen divisor lattices (Div6, Div8, Div12, Div24, Div48, Div96, Div192, Div36, Div72, Div144, Div216, Div30, Div60, Div120, Div180); the five largest (Div144, Div216, Div60, Div120, Div180) are Node-computed only, marked as such below.

**Results, first family [computed].**

| algebra | elements | nuclei | ambient ordinary | apertures |
|---|---|---|---|---|
| Div12 | 6 | 8 | {2} | Ap(2) = 1 — identity alone |
| Div6 (Boolean 2×2) | 4 | 4 | ∅ | all empty |
| 4-chain (linear) | 4 | 8 | ∅ | all empty |
| Div24 | 8 | 16 | {2, 4} | Ap(2) = 3, Ap(4) = 3 |

**Result 4.1 (maximal fragility at the threshold) [K].** On Div12 — the minimal kernel-bearing algebra, forced into the ambient lattice by any ordinary element (Theorem 2.3) — the aperture of the unique ordinary element is the identity alone. Every proper coarse-graining closes the four-fold. At the threshold of possibility, the four-fold is visible only at full resolution. Kernel-checked as `aperture_two_complete` (`lean/FalseWorkPapers/Examples/ApertureAnchors.lean`), quantified over *all* nuclei on Div12, not only the eight enumerated ones: the factorization lemma of §5 Step 1 collapses the search to componentwise pairs on the exponent lattice C₃ × C₂, `decide` sweeps the 108 remaining pairs, and the result transports back across the exponent isomorphism (each structure-preservation fact itself decided).

**Result 4.2 (the invariant grades) [computed].** On Div24 the apertures have size 3 and include genuinely coarse observers: the nucleus with fix-set {1,3,4,8,12,24} maps the kernel 2 ↦ 4 and 4 stays ordinary in the coarser world; the nucleus with fix-set {2,4,6,8,12,24} coarsens the bottom itself (⊥ⱼ = 2) and 4 stays ordinary above it. Div12's fragility is a fact about Div12, not about the definition.

**Results, scaling family [computed].**

| algebra | nuclei | ambient ordinary | apertures (in order) |
|---|---|---|---|
| Div12 (a=2) | 8 | {2} | 1 |
| Div24 (a=3) | 16 | {2,4} | 3, 3 |
| Div48 (a=4) | 32 | {2,4,8} | 7, 9, 7 |
| Div96 (a=5) | 64 | {2,4,8,16} | 15, 21, 21, 15 |
| Div192 (a=6) | 128 | {2,4,8,16,32} | 31, 45, 49, 45, 31 |
| Div36 = 2²·3² | 16 | {2,3} | 3, 3 — and Ap(6) = 2 with 6 *not* ordinary |
| Div30 = 2·3·5 | 8 | ∅ (Boolean cube) | all empty |

**Results, latency sweep [computed].** (Node sweep 2026-08-11; Div72 pre-registered in the Wolfram cell and cloud-confirmed the same day; Div144, Div216, Div60 Node-computed.)

| algebra | nuclei | ambient ordinary | latent elements (aperture sizes) |
|---|---|---|---|
| Div72 = 2³·3² | 32 | {2,3,4} | 6 (6), 12 (4) |
| Div144 = 2⁴·3² | 64 | {2,3,4,8} | 6 (14), 12 (12), 24 (8) |
| Div216 = 2³·3³ | 64 | {2,3,4,9} | 6 (18), 12 (12), 18 (12), 36 (6) |
| Div60 = 2²·3·5 | 16 | {2,6,10} | none |

## 5. The closed form

The scaling data of §4 first suggested a product law for the Div(2^a·3) family — |Ap(2^k)| = (2^k − 1)(2^(a−k) − 1), exact on all fifteen (a, k) points. Those fifteen points are one chain-product family with two free parameters — one structural fact observed at fifteen resolutions, not fifteen confirmations — so rather than fit extensions of the formula to further data (two candidate third factors were discriminated at Div120 and Div180, where they disagree non-degenerately; see the repository's design notes for that episode), we derived the general answer. It covers every element, prime power or mixed, of every divisor lattice.

**Theorem 5.1 (aperture closed form; derivation below, exhaustive verification [computed]; Steps 1–3 each kernel-checked [K]; the assembled formula is [K] on all divisor lattices, any number of primes — `aperture_closed_form_pi`).** Let n = ∏_c p_c^{a_c} and let k ∈ Div(n) have exponent vector (e_c). Then

  |Ap(k)| = ∏_c N_c − ∏_c D_c − ∏_c R_c + ∏_c DR_c,

where, per prime chain,

  N_c = 2^{a_c},  D_c = (2^{e_c} − 1)·2^{a_c − e_c} + 1,  R_c = 2^{a_c − e_c} + 2^{e_c} − 1,  DR_c = 2^{e_c}.

Verified exact on all 164 elements of the fifteen divisor lattices listed in §4 — including all 109 zero-aperture elements, where the inclusion-exclusion must cancel exactly, and every mixed kernel such as 6 = 2·3 in Div60 (`wolfram/aperture-closed-form.mjs`). Independently confirmed in Wolfram Cloud (2026-08-12) by the closed-form check in `wolfram/aperture-scaling.wl`: exact on all 79 elements of its eight lattices against the independently written Wolfram enumerator, with the expectation pre-registered in the cell header.

**Derivation.** Three steps, each elementary.

*Step 1 (factorization lemma).* Nuclei on a finite product H = A × B are exactly the componentwise pairs j_A × j_B. Products of nuclei are clearly nuclei. Conversely, let j be a nucleus on A × B. Since (a, b) = (a, ⊤) ∧ (⊤, b) and j preserves binary meets, j(a, b) = j(a, ⊤) ∧ j(⊤, b). Inflation forces the second coordinate of j(a, ⊤) and the first coordinate of j(⊤, b) to be ⊤, so j(a, ⊤) = (j_A a, ⊤) and j(⊤, b) = (⊤, j_B b) where j_A(a) := π_A j(a, ⊤) and symmetrically. Hence j(a, b) = (j_A a, j_B b), and j_A, j_B inherit inflation, idempotence, and meet-preservation coordinatewise. Consequently Fix(j) = Fix(j_A) × Fix(j_B) as Heyting algebras, and nucleus counts multiply — as observed on every lattice in §4 (8 = 4·2, 16 = 4·4, 32 = 8·2·2, ...).

*Step 2 (coordinate-locality of density and regularity).* Implication, bottom, and hence negation in a product Heyting algebra — and in the product world Fix(j_A) × Fix(j_B) — are componentwise. So j(k) is dense in Fix(j) iff each coordinate j_c(k_c) is dense in its world Fix(j_c), and regular iff each coordinate is regular. Since ordinary = neither dense nor regular, inclusion-exclusion gives

  |Ap(k)| = #nuclei − #(all coordinates dense) − #(all coordinates regular) + #(all coordinates both),

and by Step 1 each count on the right is a product of per-chain counts.

*Step 3 (chain counts).* On the chain C_{a+1} = {0 < 1 < … < a}, the nuclei are induced by exactly the 2^a subsets F ∋ ⊤, with j(e) = the least member of F above e, and world bottom ⊥′ = min F. In a chain world, ¬′u = ⊥′ iff u > ⊥′ or the world is trivial, so j(e) is *dense* iff min F < e or F = {⊤}: that is D(e) = (2^e − 1)·2^{a−e} + 1 subsets. j(e) is *regular* iff j(e) ∈ {⊥′, ⊤}, i.e. F has no member in [e, a) or no member below e: R(e) = 2^{a−e} + 2^e − 1. Both hold iff j(e) = ⊤: DR(e) = 2^e. Substituting into Step 2 yields the theorem. ∎

The only step with any content is Step 1, and its proof is four lines; this had been assumed to require a nontrivial decomposition theorem, and does not. Step 1 is kernel-checked in full generality — `nucleus_prod_iff` (`lean/FalseWorkPapers/Lattice/NucleusFactorization.lean`): on any product of meet-semilattices with top, the nuclei are exactly the componentwise pairs.

Steps 2–3 are now kernel-checked as well (`lean/FalseWorkPapers/Lattice/ApertureClosedForm.lean`). Step 2: density and regularity in the world of a componentwise nucleus are coordinatewise (`worldDense_prodMap_iff`, `worldRegular_prodMap_iff`), and the factorization upgrades to an equivalence of nucleus types (`nucleusProdEquiv`). Step 3: on any finite bounded chain, the nuclei are exactly the subsets containing ⊤ (`nucleusEquivTopSets` — the classification, with `chainNucleus` sending each element to the least member of the fix-set above it), and the four counts come out as powerset cardinalities: N = 2^n (`card_nuclei_chain`), D and R in subtraction-free additive form (`card_worldDense_add`, `card_worldRegular_add`), DR = 2^b (`card_worldDenseRegular`) — proved for arbitrary finite bounded chains, not just concrete `Fin` types. The inclusion-exclusion assembly (`aperture_card_add_eq`) is proved for a product of *any* two finite Heyting algebras, chains or not. Instantiated at the exponent lattices, `aperture_closed_form_exponents` states Theorem 5.1 verbatim on Fin(a+1) × Fin(b+1) — every two-prime divisor lattice, every kernel, mixed kernels included — over ℤ, and a `decide`d cross-check confirms the formula returns exactly 1 on Div12's kernel 2, in agreement with the independently proved completeness `aperture_two_complete`. Axiom audit clean on the entire chain (`propext`, `Classical.choice`, `Quot.sound` only; no `sorry`, no `native_decide`).

The iteration to any number of primes is done as well (`lean/FalseWorkPapers/Lattice/ApertureClosedFormPi.lean`, added at v0.3, the day of the Result 6.3 correction). Rather than folding the binary argument r − 1 times, the file proves the Pi-indexed statements directly: nuclei on `Π i, α i` over any finite index are exactly the componentwise families (`nucleusPiEquiv`, via `x = ⨅ i, update ⊤ i (x i)` and finite-meet preservation), the world predicates are coordinatewise (`worldDense_piMap_iff`, `worldRegular_piMap_iff`), and the inclusion-exclusion — whose two events, "all coordinates dense" and "all coordinates regular", do not multiply with arity — assembles to |Ap(k)| + ∏D + ∏R = ∏N + ∏DR on any finite product of finite Heyting algebras (`aperture_card_add_eq_pi`). Instantiated at `Π i : Fin r, Fin (aᵢ + 1)`, `aperture_closed_form_pi` states Theorem 5.1 verbatim for every divisor lattice, every number of primes, every kernel, over ℤ. **Theorem 5.1 is therefore [K] with no arity restriction.** Kernel-checked cross-checks include both v0.3 correction witnesses — Div180's element 30 evaluates to 4, Div8's elements 2 and 4 to 0 — and the Div12 anchor (1, matching `aperture_two_complete`). Axiom audit clean (`propext`, `Classical.choice`, `Quot.sound` only).

**Relation to existing literature.** The objects of the derivation are classical, and the structural half of Step 3 is in print: that the nuclei on a bounded chain are exactly the operators induced by the subsets containing ⊤ is stated, in closure-range form, by Erné, *Nuclear ranges in implicative semilattices*, Algebra Universalis (2022), doi:10.1007/s00012-022-00768-3; the general classification of nuclei on finite implicative semilattices by subsets of meet-prime elements is Bezhanishvili–Bezhanishvili–Carai–Gabelaia–Ghilardi–Jibladze, *Diego's theorem for nuclear implicative semilattices*, arXiv:2001.11060. Step 3's classification should therefore be regarded as folklore that our development formalizes (it is not in Mathlib) rather than discovers. Ordinary elements are likewise an active notion in the intermediate-logics literature — beyond the originating work, see Citkin, *An Algebraic Proof of the Nishimura Theorem*, Logics 2(4) (2024), where the regular/dense/ordinary trichotomy is used as standard vocabulary. What we have found nowhere in either literature: the relativization of ordinariness to the world of a nucleus, the aperture as a named invariant, the latency phenomenon (Result 6.1), or the counting formula of Theorem 5.1. The paper's novelty claims are located exactly there — a new question asked of old objects, at the unvisited intersection of the nuclei literature (which does not ask about ordinariness) and the ordinary-elements literature (which does not relativize to nuclei). **[O]** on the completeness of this placement: it rests on a literature search, not a systematic review, and correction is welcome.

**Corollary 5.2 (the product laws).** For k = p^i pure in Div(p^a·q^b), the theorem's sum telescopes to |Ap(p^i)| = (2^i − 1)(2^{a−i} − 1)(2^b − 1) — the two-prime law, exact on the 13 measured two-prime points — and with b = 1 to the original Div(2^a·3) law (2^i − 1)(2^{a−i} − 1), exact on its 15 points. The "third factor" that the Div120/Div180 discrimination selected, N(complement) − 1, is likewise the theorem's specialization: for a kernel at exponent 0 in every other prime, the complement contributes ∏ 2^{a_q} − ∏ 1 = N(L′) − 1 through the inclusion-exclusion.

**Corollary 5.3 (positivity; corrected at v0.3).** Ap(k) ≠ ∅ iff the formula is positive, and positivity holds exactly when **some e_c is strictly interior (0 < e_c < a_c) and some other chain c′ ≠ c has e_{c′} < a_{c′}**. The reason the second witness must be a *different* coordinate is the structural heart of the invariant: in a chain-world every element is dense or regular (a chain has no ordinary elements at any resolution), so one coordinate must supply non-regularity (possible only at a strictly interior exponent) and a different coordinate must supply non-density (possible whenever that exponent sits below its chain top, including at zero). An earlier version of this corollary asserted a different equivalence — positivity iff (some e = 0 and some interior) or (all interior) — and dismissed its derivation as "routine but not written out." Writing it out was the correction: the asserted equivalence is false at three points of this paper's own 164-element verification set (Div8 elements 2 and 4, all-interior on a single chain, aperture 0; Div180 element 30, aperture 4 with the 5-exponent at its top). The corrected equivalence agrees with enumeration on all 164 elements and with the formula on 252 further points across Div360–Div44100 **[computed]** (`wolfram/latency-characterization-correction.mjs`); as a general symbolic equivalence it remains at computed grade, but the formula it reads off is now [K] at every arity, and both refuting witnesses are kernel-checked instances (§5). The latent aperture sizes an earlier draft declined to curve-fit (Div72: 6, 4; Div144: 14, 12, 8; Div216: 18, 12, 12, 6) remain instances of Theorem 5.1.

**Scope [O].** The theorem as derived covers finite products of finite chains — equivalently divisor lattices. Extension to general finite distributive lattices (where the factorization lemma still applies to any product decomposition, but the factors need not be chains and Step 3's counts change) and to general finite Heyting algebras is open.

## 6. Latent ordinariness

**Result 6.1 (existence and exactness) [K].** On Div36, the element 6 is not ordinary at full resolution (¬6 = ⊥: it is dense). Yet Ap(6) = 2: the nuclei with fix-sets {2,4,6,12,18,36} and {3,6,9,12,18,36} each make 6 ordinary in their worlds (in the first, ⊥ⱼ = 2, ¬ⱼ6 = 4, ¬ⱼ4 = 18 ≠ 6). Two proper coarse-grainings open a four-fold around a distinction that the identity observer cannot see. Both halves are kernel-checked on the exponent lattice C₃ × C₃ (`lean/FalseWorkPapers/Examples/ApertureAnchors.lean`): `latent_ordinariness_witness` (6 is not ambient-ordinary; two named proper nuclei open it) and `aperture_six_complete` (those two are the *only* nuclei that open it — quantified over all nuclei via the factorization lemma, with `decide` over the 729 componentwise pairs).

This breaks the inclusion one would default to. The natural reading of an aperture is monotone degradation — the four-fold is there at full resolution and survives some amount of blur, so the aperture would measure *robustness*. Result 6.1 refutes that reading: the aperture is not a restriction of ambient ordinariness, and ordinariness-under-j is genuinely a property of the pair (element, nucleus), not a property of the element that nuclei variously fail to see. The mechanism is exact: at full resolution a dense element has no complement to push against (¬6 = ⊥); the right nucleus raises the bottom, and against the new bottom the element acquires a nontrivial negation. The slogan form, earned by the computation: **some distinctions exist only at a blur.**

Result 6.1 also discharges a circularity worry about §4. On Div12 the aperture merely recovers ambient ordinariness (the only opened element is the ambient-ordinary one, and only under identity), which could suggest the invariant is ambient ordinariness in disguise. Div36 proves it is not: there, identity sees nothing at 6 and two proper coarse-grainings see the four-fold.

**Result 6.2 (characterization on divisor lattices; predicted, confirmed, then corrected — see 6.3) [computed].** Call k **latent** if k is not ordinary in H but Ap(k) ≠ ∅. On Div(n) with n = ∏ p_i^{a_i}, write e_i(d) for the exponent of p_i in d. The following characterization was stated *before* the confirming sweep was run, derived from componentwise negation on products of chains (on a chain, ¬x = ⊥ for x > ⊥):

- d is **ordinary** in Div(n) iff some e_i(d) = 0 and some e_j(d) is strictly interior (0 < e_j(d) < a_j);
- d is **latent** iff *every* exponent is strictly interior: 0 < e_i(d) < a_i for all i. *(Corrected at v0.3: valid only for exactly-two-prime lattices; see Result 6.3.)*

Confirmed on ten of ten algebras (Div12, Div24, Div48, Div96, Div36, Div72, Div144, Div216, Div30, Div60), including three consequences that could each have failed:

1. Latency is *impossible* in the entire Div(2^a·3) family — the C_2 factor has no interior — confirmed absent through a = 6.
2. Latency is impossible in every square-free lattice (Div30, Div60: no exponent can be interior) — confirmed.
3. The latent sets are exactly {6} in Div36, {6, 12} in Div72, {6, 12, 24} in Div144, {6, 12, 18, 36} in Div216 — confirmed, elementwise.

**Result 6.3 (correction, 2026-08-24) [computed].** The Result 6.2 latency rule is **wrong outside two-prime lattices, in both directions**, and the ten-algebra sweep could not have caught it: every lattice in the sweep is two-prime or square-free, and on exactly those shapes the wrong rule and the right one coincide. The corrected characterization, derived by writing out the positivity of Theorem 5.1 (Corollary 5.3):

- **Ap(d) ≠ ∅ iff some e_c is strictly interior and some other chain c′ ≠ c has e_{c′}(d) < a_{c′}**;
- d is **latent** iff additionally no exponent is zero (zero exponents with an interior witness are the ambient-ordinary case).

The two counterexamples to the old rule, both sitting unread in the paper's own 164-element verification data: **Div8, elements 2 and 4** — every exponent strictly interior, yet aperture 0, because a single chain has no second coordinate to break density with (chains have no ordinary elements at any resolution); and **Div180, element 30** — exponents (1,1,1) with the 5-exponent at its chain top, so not all-interior, yet aperture 4. The mechanism the old rule missed exists only at three or more primes: a coarse world may **truncate a chain from below or drop it entirely**, handing the image a zero-like coordinate next to an interior one — world-ordinary by Result 6.2's own (correct) first bullet. The four worlds opening 30 in Div180 are exactly these: fix-sets with bottoms raised to 2, 3, 10, and 15, each deleting the bottom of one chain. Verification: the corrected rule agrees with exhaustive nucleus enumeration on all 164 elements of the fifteen lattices (zero disagreements; the old rule fails at the three points named) and with closed-form positivity on 252 further elements of Div360, Div900, Div1260, Div2520, Div4500, Div44100 (`wolfram/latency-characterization-correction.mjs`, pre-registered header).

Div36 therefore remains the smallest latent case, for the corrected reason: latency needs one chain with interior room *and a second chain not at its top* — with two primes that forces both interior, and 2²·3² is the least n admitting it. But the phenomenon is broader than the old rule allowed: at three primes an element can be latent while flush against one chain's ceiling, and Div180's 30 = 2·3·5 — every prime present, none squared away from its limit except where it counts — is the smallest witness of that broader shape.

**Note on the latent aperture sizes.** An earlier draft of this paper reported the latent aperture sizes (Div72: 6, 4; Div144: 14, 12, 8; Div216: 18, 12, 12, 6) as data fitting "no product form we are willing to fit." That refusal was correct in method and wrong in prognosis: the sizes are not a product form, they are the inclusion-exclusion of Theorem 5.1, and the derived formula — not a fit — reproduces every one of them. The sequence is worth recording because it is the methodological point of this section: declining to curve-fit left the pattern intact for the derivation to explain.

**What remains open [O].** The extension of Theorem 5.1 and the latency characterization beyond finite products of chains — general finite distributive lattices, then general Heyting algebras — is untouched. The formalization gap the v0.2 text named here is closed: the r > 2 iteration was completed the day of the v0.3 correction, and the assembled formula is now [K] on all divisor lattices (§5, §8; `aperture_closed_form_pi`), with both correction witnesses kernel-checked. What the correction episode leaves open at computed grade is the corrected characterization itself (Result 6.3) as a general symbolic equivalence — its formula is [K], its witnesses are [K], but the "iff" over all exponent vectors is verified, not derived in the kernel. The episode remains a live demonstration that on this terrain prose summaries fail exactly where kernel-checking refuses to.

## 7. The observer bridge, stated as an analogy

The mapping that motivated this invariant **[A]**: a nucleus is an observer's coarse-graining; Fix(j) is the world at that observer's resolution; the double-negation quotient is the fully reduced, Boolean pocket of the world — the region where an observer's compression is total; ordinariness is the boundary condition between reducible and irreducible; the aperture of a kernel measures which observers a founding distinction survives — and Result 6.1 adds: which observers it *needs*.

The disanalogy, stated with equal weight **[O]**: nuclei model *static* resolution — a fixed policy of merging — while computational irreducibility in observer-centric computation theories is a claim about *temporal cost*: no shortcut computes the future faster than running it. Nothing in this paper connects the aperture to time, dynamics, or cost. Whether a formal bridge exists (e.g., nuclei induced by the equivalences a bounded observer can afford to compute along a trajectory) is open and untouched here. The analogy is a map for intuition; the theorems and computations above stand without it.

## 8. Epistemic status of every claim

| claim | grade |
|---|---|
| four-fold non-degenerate ⟺ kernel ordinary | [K] (`OrdinaryKernel.lean`) |
| ordinary element forces ≥ 6 elements, Div12 embedding | [K] (ibid.; `ordinary-elements-z6/`) |
| tritone nucleus is a nucleus; tritone closure is not | [K] (`DivisorLattice12Nucleus.lean`) |
| nuclei = Lawvere–Tierney traces; Fix(j) Heyting with ⊥ⱼ = j(⊥), implication inherited | [C] |
| double-negation fix-set Boolean; Boolean worlds have no ordinary elements | [C] |
| all aperture tables in §4; two-algorithm agreement; Lean-anchor reproduction | [computed] |
| nuclei on finite products factor componentwise (Theorem 5.1, Step 1) | [K] (`nucleus_prod_iff`, `NucleusFactorization.lean`; general, any product) |
| aperture closed form (Theorem 5.1) | derived in text; exact on 164/164 elements incl. 109 zero-cancellations [computed]; Steps 1–3 each [K]; assembled formula [K] on **all divisor lattices, any number of primes** (`aperture_closed_form_pi`, `ApertureClosedFormPi.lean`; two-prime face `aperture_closed_form_exponents`, `ApertureClosedForm.lean`) |
| chain-nucleus classification and the four chain counts (Step 3) | [K] (`nucleusEquivTopSets`, `card_nuclei_chain`, `card_worldDense_add`, `card_worldRegular_add`, `card_worldDenseRegular`; arbitrary finite bounded chains); classification itself is folklore (Erné 2022; Bezhanishvili et al., arXiv:2001.11060) — the formalization and the four world-relative counts are the contribution |
| coordinate-locality of world density/regularity (Step 2) | [K] (`worldDense_prodMap_iff`, `worldRegular_prodMap_iff`, `nucleusProdEquiv`) |
| inclusion-exclusion assembly on a product of two finite Heyting algebras | [K] (`aperture_card_add_eq`; more general than chains) |
| Pi factorization, Pi coordinate-locality, Pi assembly (any finite index) | [K] (`nucleusPiEquiv`, `worldDense_piMap_iff`, `worldRegular_piMap_iff`, `aperture_card_add_eq_pi`, `ApertureClosedFormPi.lean`; any finite family of finite Heyting algebras) |
| two-prime and Div(2^a·3) product laws | corollaries of Theorem 5.1; exact on all measured points [computed] |
| Ap(2) = {identity} on Div12, over all nuclei (Result 4.1) | [K] (`aperture_two_complete`, `ApertureAnchors.lean`) |
| latent ordinariness exists (Div36, element 6) | [K] (`latent_ordinariness_witness`, `ApertureAnchors.lean`) |
| Ap(6) = exactly the two named nuclei on Div36 (Result 6.1) | [K] (`aperture_six_complete`, ibid.) |
| latency characterization on divisor lattices | corrected at v0.3 (Result 6.3): interior witness + second chain below top; old all-interior rule valid only at exactly two primes, refuted by Div8 (2, 4) and Div180 (30) from the paper's own data [computed]; corrected rule 164/164 vs enumeration, 252/252 vs formula; all three refuting witnesses kernel-checked instances of the [K] closed form (`ApertureClosedFormPi.lean`) |
| latent aperture sizes | instances of Theorem 5.1 (previously reported unfitted; never curve-fit) |
| Theorem 5.1 beyond products of chains | [O] |
| nuclei-as-observers mapping | [A] |
| bridge from aperture to dynamical/temporal irreducibility | [O], explicitly untouched |

The factorization lemma, the Div12 completeness, the Div36 completeness-plus-witness, and the full derivation of Theorem 5.1 through its instantiation at every arity are kernel-checked (axiom audit: `propext`, `Classical.choice`, `Quot.sound` only — no `native_decide`, no `sorry`). The hardening step the v0.2 text named here — the r > 2 iteration that makes the closed form [K] on all divisor lattices — is done (`ApertureClosedFormPi.lean`, v0.3). The remaining computed-grade claims are the exhaustive sweeps themselves and the corrected characterization's general "iff" (Result 6.3), whose formula and witnesses are [K].

## 9. Reproducibility

Everything reported is reproducible from the public repository (github.com/thefalsework/papers): `wolfram/aperture-prototype.wl` (first four algebras, Lean-anchor checks printed as PASS/FAIL, the two-panel figure) and `wolfram/aperture-scaling.wl` (the scaling table, the product-law check, the latency characterization check, and the closed-form check), each a single self-contained Wolfram Cloud cell with expected outputs pre-registered in its header; `wolfram/latency-sweep.mjs` (the ten-algebra Node sweep with the prediction in its header); `wolfram/aperture-closed-form.mjs` (Theorem 5.1 against every element of all fifteen lattices, with the derivation in its header); `lean/FalseWorkPapers/Positions/OrdinaryKernel.lean` and `lean/FalseWorkPapers/Examples/DivisorLattice12Nucleus.lean` for the [K] anchors; `lean/FalseWorkPapers/Lattice/NucleusFactorization.lean` (the general factorization lemma `nucleus_prod_iff`, the `Opens` predicate, and the transport lemmas), `lean/FalseWorkPapers/Lattice/ApertureClosedForm.lean` (Steps 2–3 and the assembled Theorem 5.1: chain-nucleus classification, the four chain counts, the inclusion-exclusion `aperture_card_add_eq`, and the two-prime closed form `aperture_closed_form_exponents` with its Div12 cross-check), `lean/FalseWorkPapers/Lattice/ApertureClosedFormPi.lean` (the any-arity iteration: `nucleusPiEquiv`, the Pi world-predicate locality, `aperture_card_add_eq_pi`, the general closed form `aperture_closed_form_pi`, and the `decide`d Div180/Div8/Div12 cross-checks), and `lean/FalseWorkPapers/Examples/ApertureAnchors.lean` (the Div12 anchors, `aperture_two_complete`, `latent_ordinariness_witness`, `aperture_six_complete`) for the [K] aperture results; an evaluated cloud notebook under `wolfram/results/`.

**Disclosure.** Drafting was AI-assisted under direction, per the project's validation architecture and its framework for epistemic dependency (Paper 2); all computations were executed and cross-checked as described, and the grade table in §8 is the author's warrant, not the assistant's.
