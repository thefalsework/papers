# The Aperture of a Distinction: Observer-Relative Ordinariness in Heyting Algebras

**Author.** Chris Brink (independent)
**Version.** Draft v0.1, August 2026 — not yet posted
**Target.** arXiv cs.AI (endorsement channel open); math.LO cross-list candidate
**Status discipline.** Every claim in this paper carries one of four grades: **[K]** kernel-checked in Lean 4 against Mathlib4; **[C]** classical mathematics, cited; **[computed]** exhaustive finite computation, verified by two independent implementations but not yet kernel-checked; **[A]** structural analogy, argued not proved; **[O]** open. The grades are load-bearing: nothing below claims more than its tag.

---

## Abstract

An element of a Heyting algebra is *ordinary* (Citkin) when it is neither regular (¬¬k = k) nor dense (¬k = ⊥). A prior kernel-checked result of this program shows that a four-position partition of structural positions around a distinguished element — the *kernel* of a distinction — is non-degenerate exactly when that element is ordinary **[K]**. This paper relativizes ordinariness to a nucleus. For a nucleus j on a Heyting algebra H, the fix-set Fix(j) is a Heyting algebra with bottom j(⊥) and inherited implication **[C]**; we define the **aperture** of an element k as the set of nuclei j under which j(k) is ordinary *inside Fix(j)*, and compute it exhaustively across thirteen finite algebras under a two-implementation agreement discipline. The central result is the existence and characterization of **latently ordinary** elements: elements that are not ordinary in H — the four-position partition around them is degenerate — but whose image is ordinary in Fix(j) for suitable proper nuclei j. On Div36 the element 6 is dense, yet exactly two proper nuclei open a four-fold around it that the identity cannot see. Latency is then characterized on divisor lattices — an element is latent iff every prime exponent is strictly interior — with the characterization stated in advance and confirmed on ten of ten algebras, including its predicted *impossibility* across the entire family Div(2^a·3) **[computed]**. Secondary results: on Div12, the minimal kernel-bearing algebra **[K]**, the aperture of the unique ordinary element is the identity alone **[computed]**; and across Div(2^a·3), a = 2..6, apertures obey |Ap(2^k)| = (2^k − 1)(2^(a−k) − 1) — one structural fact about nuclei on chain products observed at fifteen resolutions, conjectured a theorem and left open **[O]**. A structural analogy to observer theories of coarse-graining in computational frameworks is stated as an analogy **[A]**, with its disanalogy — nuclei model static resolution, computational irreducibility models temporal cost — stated as an open problem, not a result **[O]**.

## 1. Introduction

Fix a Heyting algebra H and an element k. Citkin calls k **ordinary** when it is neither regular (¬¬k = k) nor dense (¬k = ⊥); a prior kernel-checked theorem of this program (§2) shows that a four-position partition of positions relative to k is non-degenerate exactly when k is ordinary. Ordinariness is thus the precise condition under which a distinction supports a full position space.

A **nucleus** j on H — equivalently the subobject trace of a Lawvere–Tierney topology, equivalently a sheafification **[C]** — is an inflationary, idempotent, binary-meet-preserving operator, and its fix-set Fix(j) is again a Heyting algebra, with bottom j(⊥) and implication inherited **[C]**. This paper asks the relativized question: *for which nuclei j is j(k) ordinary in Fix(j)?* We call that set of nuclei the **aperture** of k. On finite algebras it is exhaustively enumerable, and this paper enumerates it.

The mathematical payoff is a phenomenon the ambient theory cannot express: **latently ordinary** elements — elements not ordinary in H whose images become ordinary in the world of a proper nucleus. A dense element has no complementary structure to push against at full resolution; the right coarse-graining raises the bottom, and against the new bottom the element acquires a nontrivial negation and a full four-fold opens. We exhibit the smallest case, characterize exactly where latency occurs on divisor lattices (prediction stated before the confirming sweep), and record what remains open.

The motivating reading — nuclei as observers, Fix(j) as the world at an observer's resolution, the aperture as *which observers see a distinction's position space open* — is stated in §7, as an analogy and after the mathematics. The theorems and computations stand without it.

This paper defines the invariant, computes it exhaustively on thirteen finite algebras, and reports what the computation says, with every claim graded.

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

The two algorithms agree on all algebras where both are feasible (Div12, Div6, the 4-chain, Div24) **[computed]**. The production enumerator alone handles the larger algebras, and is itself implemented twice — Node.js and Wolfram Language, written independently — with the Wolfram implementation run in Wolfram Cloud against pre-registered expectations. Both Lean anchors from §2 are reproduced: the tritone nucleus appears in the Div12 enumeration; the tritone closure is rejected. Source: `wolfram/aperture-prototype.wl` and `wolfram/aperture-scaling.wl` in the repository, each a self-contained Wolfram Cloud cell with the expected outputs pre-registered in its header; the Node.js reference is described in the repository's design notes. A cloud-evaluated notebook is archived at `wolfram/results/wolfram-cloud-run-2026-08-11-v2.1.nb`. The latency sweep is `wolfram/latency-sweep.mjs` (Node), with its prediction stated in the file header before the run; Div72 and the latency characterization check were pre-registered in `aperture-scaling.wl` and **confirmed in Wolfram Cloud 2026-08-11** (all eight latency checks CONFIRMED, Div72 latent {6, 12} with apertures 6 and 4 as predicted). The three largest algebras (Div144, Div216, Div60) are Node-computed only, marked as such below.

**Results, first family [computed].**

| algebra | elements | nuclei | ambient ordinary | apertures |
|---|---|---|---|---|
| Div12 | 6 | 8 | {2} | Ap(2) = 1 — identity alone |
| Div6 (Boolean 2×2) | 4 | 4 | ∅ | all empty |
| 4-chain (linear) | 4 | 8 | ∅ | all empty |
| Div24 | 8 | 16 | {2, 4} | Ap(2) = 3, Ap(4) = 3 |

**Result 4.1 (maximal fragility at the threshold) [computed].** On Div12 — the minimal kernel-bearing algebra, forced into the ambient lattice by any ordinary element (Theorem 2.3) — the aperture of the unique ordinary element is the identity alone. Every proper coarse-graining closes the four-fold. At the threshold of possibility, the four-fold is visible only at full resolution.

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

## 5. The product law

**Conjecture 5.1 [O].** In Div(2^a·3), for 1 ≤ k ≤ a−1,

  |Ap(2^k)| = (2^k − 1)(2^(a−k) − 1).

All fifteen (a, k) pairs with 2 ≤ a ≤ 6 satisfy the law exactly **[computed]**. But the fifteen points should not be over-read: Div(2^a·3) is the chain product C_(a+1) × C_2, one family with two free parameters, so the agreement is *one structural fact observed at fifteen resolutions*, not fifteen independent confirmations. The value of the formula is that it has the shape of a theorem, not the weight of its data.

**Mechanism sketch [O].** The observed nucleus counts multiply over chain-product factors: 2^(a+1) for the sequence (a chain with m elements has 2^(m−1) nuclei — every subset containing ⊤ is a nucleus fix-set on a chain, verified computationally on the 4-chain), 4 × 4 = 16 for Div36 = C_3 × C_3, and 2³ = 8 for the Boolean cube Div30. If nuclei on finite products decompose as products of factor nuclei, the product law should reduce to counting which factor-pairs keep the kernel's coordinates strictly interior — and (2^k − 1) is just the count of nonempty proper down-set choices below the kernel in a chain. The factorization reading: the aperture is *(blur available below the kernel) × (blur available above it)*. We have not proved either step; proving the law — plausibly a short argument about nuclei on chain products, and a candidate for Lean formalization — is the named next hardening step.

## 6. Latent ordinariness

**Result 6.1 (existence) [computed].** On Div36, the element 6 is not ordinary at full resolution (¬6 = ⊥: it is dense). Yet Ap(6) = 2: the nuclei with fix-sets {2,4,6,12,18,36} and {3,6,9,12,18,36} each make 6 ordinary in their worlds (in the first, ⊥ⱼ = 2, ¬ⱼ6 = 4, ¬ⱼ4 = 18 ≠ 6). Two proper coarse-grainings open a four-fold around a distinction that the identity observer cannot see.

This breaks the inclusion one would default to. The natural reading of an aperture is monotone degradation — the four-fold is there at full resolution and survives some amount of blur, so the aperture would measure *robustness*. Result 6.1 refutes that reading: the aperture is not a restriction of ambient ordinariness, and ordinariness-under-j is genuinely a property of the pair (element, nucleus), not a property of the element that nuclei variously fail to see. The mechanism is exact: at full resolution a dense element has no complement to push against (¬6 = ⊥); the right nucleus raises the bottom, and against the new bottom the element acquires a nontrivial negation. The slogan form, earned by the computation: **some distinctions exist only at a blur.**

Result 6.1 also discharges a circularity worry about §4. On Div12 the aperture merely recovers ambient ordinariness (the only opened element is the ambient-ordinary one, and only under identity), which could suggest the invariant is ambient ordinariness in disguise. Div36 proves it is not: there, identity sees nothing at 6 and two proper coarse-grainings see the four-fold.

**Result 6.2 (characterization on divisor lattices; predicted, then confirmed) [computed].** Call k **latent** if k is not ordinary in H but Ap(k) ≠ ∅. On Div(n) with n = ∏ p_i^{a_i}, write e_i(d) for the exponent of p_i in d. The following characterization was stated *before* the confirming sweep was run, derived from componentwise negation on products of chains (on a chain, ¬x = ⊥ for x > ⊥):

- d is **ordinary** in Div(n) iff some e_i(d) = 0 and some e_j(d) is strictly interior (0 < e_j(d) < a_j);
- d is **latent** iff *every* exponent is strictly interior: 0 < e_i(d) < a_i for all i.

Confirmed on ten of ten algebras (Div12, Div24, Div48, Div96, Div36, Div72, Div144, Div216, Div30, Div60), including three consequences that could each have failed:

1. Latency is *impossible* in the entire Div(2^a·3) family — the C_2 factor has no interior — confirmed absent through a = 6.
2. Latency is impossible in every square-free lattice (Div30, Div60: no exponent can be interior) — confirmed.
3. The latent sets are exactly {6} in Div36, {6, 12} in Div72, {6, 12, 24} in Div144, {6, 12, 18, 36} in Div216 — confirmed, elementwise.

Div36 is therefore not an anomaly but the smallest case of a characterized phenomenon: latency requires every prime to contribute a chain with interior, and 2²·3² is the least n that does.

**What remains open [O].** The latent aperture *sizes* (Div72: 6, 4; Div144: 14, 12, 8; Div216: 18, 12, 12, 6) fit no product form we are willing to fit; they are reported as data. The characterization is confirmed exhaustively on the ten lattices above and derived from a mechanism (componentwise negation) that should make it a theorem about finite products of chains, but it is not yet proved, and its extension beyond products of chains — general finite distributive lattices, then general Heyting algebras — is untouched.

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
| product law |Ap(2^k)| = (2^k−1)(2^(a−k)−1) in Div(2^a·3) | [O] as theorem; exact on all 15 points [computed], read as one fact at fifteen resolutions |
| nucleus counts multiply over chain-product factors (observed); general decomposition | [O] |
| latent ordinariness exists (Div36, element 6) | [computed] |
| latency characterization on divisor lattices (all exponents interior) | predicted then confirmed 10/10 [computed]; as theorem [O] |
| latent aperture sizes | data only, no law fitted [O] |
| nuclei-as-observers mapping | [A] |
| bridge from aperture to dynamical/temporal irreducibility | [O], explicitly untouched |

Lean-checking the enumeration itself (a `decide`-style finite verification that the eight Div12 nuclei are exactly the nuclei, and that Ap(2) = {id}) is the natural next hardening step and is open; the two-implementation discipline is the current guarantee.

## 9. Reproducibility

Everything reported is reproducible from the public repository (github.com/thefalsework/papers): `wolfram/aperture-prototype.wl` (first four algebras, Lean-anchor checks printed as PASS/FAIL, the two-panel figure) and `wolfram/aperture-scaling.wl` (the scaling table, the product-law check, and the latency characterization check), each a single self-contained Wolfram Cloud cell with expected outputs pre-registered in its header; `wolfram/latency-sweep.mjs` (the ten-algebra Node sweep with the prediction in its header); `lean/FalseWorkPapers/Positions/OrdinaryKernel.lean` and `lean/FalseWorkPapers/Examples/DivisorLattice12Nucleus.lean` for the [K] anchors; an evaluated cloud notebook under `wolfram/results/`.

**Disclosure.** Drafting was AI-assisted under direction, per the project's validation architecture and its framework for epistemic dependency (Paper 2); all computations were executed and cross-checked as described, and the grade table in §8 is the author's warrant, not the assistant's.
