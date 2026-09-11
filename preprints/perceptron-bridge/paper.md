# The Perceptron Is a Classical Element: Threshold Decision Regions in the Heyting Algebra of Open Sets, with a Registered Negative Result on Phantom Mass in Trained Networks

**Chris Brink**
falsework.dev
**Version.** Preprint v1.0, September 2026 — not yet submitted.
**Status discipline.** Every claim carries one of five grades: **[K]** kernel-checked in Lean 4 against Mathlib4 (no `sorry`, no `native_decide`, axiom audits at most `propext`, `Classical.choice`, `Quot.sound`); **[C]** classical mathematics, cited; **[R]** empirical result from a pre-registered protocol (spec and kill conditions committed before code, dated postscripts binding); **[A]** structural analogy, argued not proved; **[O]** open. The grades are load-bearing: nothing below claims more than its tag.

---

## Abstract

The decision region of a threshold unit is an open set, and the open sets of a topological space form a Heyting algebra, so threshold devices are literally elements of the algebras in which the regular/dense/ordinary trichotomy (Citkin) and the four-position partition theorem of this program are stated — no analogy is involved. We compute where they sit. **(1)** In the frame Opens X, Heyting negation is interior-of-complement and double negation is interior-of-closure **[K]**. **(2)** A single threshold unit on ℝ is a *regular* element (¬¬U = U); by the four-position non-degeneracy theorem, no four-fold position structure opens around a lone perceptron — the unit lives in the Boolean pocket, and its classicality is derived rather than assumed **[K]**. **(3)** A two-layer threshold circuit built inside the lattice from four units — the composed region (0,1) ∪ (1,2) — is *ordinary*: neither regular nor dense, and the four-position partition around it is non-degenerate. Composition is the operation that first manufactures non-classicality out of classical parts **[K]**. **(4)** The double-negation remainder of the composed region is exactly the phantom wall: ¬¬U ∖ U = {1}, a locus the region treats as interior which no classical reduction can see **[K]**. **(5)** The remainder is measurable in aggregate: defining the *phantom mass* of k under a nucleus j as |[k, j k]| — justified by a two-line confusion-class lemma — the total over all nuclei (the *co-aperture*) has closed forms on chains and divisor lattices, is exactly multiplicative on finite products, and is independent of the aperture invariant in both directions **[K]**. **(6)** We then report a pre-registered pilot on the question these theorems raise: do trained ReLU networks carry substantial phantom mass? Answer: **no** — the registered kill condition K1 triggered. Across 80 trained networks (fixed 64-neuron budget, depths 1–8, two synthetic tasks, 10 seeds), phantom mass at data scale never exceeded ≈0.1% of region mass, and the registered scaling discipline shows why: the fitted exponent α ≈ 1.5–2.25 against a registered threshold α ≤ 0.5 is, in a 2D rasterization, the signature of codimension-2 structure — the phantom concentrates where polytope faces meet, not along the faces **[R]**. Two findings survived the kill: at fixed neuron budget, phantom mass increases with depth (Spearman ρ = 0.77, permutation p < 10⁻⁴ on spirals) where the Hanin–Rolnick account of region counting predicts flatness — the composition mechanism is confirmed while its magnitude is not, and those are separate claims that came apart; and the registered fjord/island falsifiability check returned 266 fjords, 0 islands, so the negative result is believed **[R]**. The upshot in one line: *the remainder is real in the algebra and vanishing in the geometry of trained piecewise-linear networks.*

---

## 1. Introduction

Levin (2026a, 2026b) identifies a phase transition in the epistemic character of the threshold element: in low dimension the perceptron is a logical device, decided exactly by linear programming; in high dimension — past the Cover (1965) transition, in a space saturated with potential separations — it becomes a navigational, indexical instrument. On Levin's account the symbolic mode ends at this threshold and a geometric mode takes over; the philosophical treatment (Levin 2026b) develops what replaces symbols but leaves open what, if anything, replaces the *logic*.

This note supplies an exact algebraic counterpart to the transition, at the level of the devices themselves. The observation that makes it possible is trivial to state: a threshold unit's decision region {x : w·x > θ} is an open set, and the open sets of any topological space form a complete Heyting algebra (a frame) **[C]**. Threshold devices are therefore *elements* of the structures in which intuitionistic logic is interpreted, and questions about their logical character become computations, checkable in a proof kernel, rather than readings.

The computations land as follows. A single unit is a **regular** element — its double negation is itself — and regular elements are exactly the ones around which this program's four-position partition is degenerate (§2). The lone perceptron is classical, and this is now a theorem with a mechanism: the unit's only undecidable locus is its own decision boundary, and double negation is precisely the operator that erases boundaries. Composing units changes the answer. The region (0,1) ∪ (1,2) — two same-class cells built from four units with lattice meets and joins, glued along an excluded wall — is **ordinary** in Citkin's sense: neither regular nor dense. Around it the four-position partition is non-degenerate, and its double-negation remainder is exactly the wall {1}: a set the healed region treats as interior, invisible to every classical (Boolean) reduction of the algebra. What ends at Levin's threshold, on this reading, is not logic but *Booleanness*; the logic of what remains is the intuitionistic logic of open regions, where excluded middle fails exactly at boundaries.

The remainder invites a quantitative question. Sections 5–6 develop the measure — phantom mass under one observer, the co-aperture as the total over all observers, with closed forms and an independence theorem, all kernel-checked — and §7 reports a pre-registered empirical pilot on the question the theorems raise but cannot answer: whether *trained* networks carry substantial phantom mass at scales that matter. The answer is negative, by the registered kill condition, with a mechanism (the phantom of trained ReLU nets concentrates at codimension-2 corners of the linear-region complex) and two surviving positive findings. We consider the negative result, obtained under a registered protocol with the case against written first, to be the most useful contribution of the note: it replaces an open speculation — flagged as open in the correspondence that motivated this work — with a checked answer.

**Relation to prior work of this program.** The four-position partition theorem and the ordinariness criterion are developed in companion preprints (Brink 2026a, 2026b, 2026c); the aperture invariant and its closed form in Brink (2026d). This note is the bridge from that machinery to threshold devices, plus the co-aperture and the pilot. It is self-contained at the statement level; proofs that are one rewrite long are given inline, and everything else is cited to the kernel-checked source files (§9).

## 2. Preliminaries

**Heyting algebras; regular, dense, ordinary.** A Heyting algebra is a bounded lattice with relative pseudocomplement ⇨; negation is ¬a = a ⇨ ⊥. Following Citkin (2024): a is *regular* if ¬¬a = a, *dense* if ¬a = ⊥, and **ordinary** if neither. Boolean algebras have only regular elements.

**The four-position partition [K].** Relative to a fixed element a, every non-bottom x of a Heyting algebra lies in exactly one of four regions — below a (*Infrastructure*), below ¬a (*Refusal*), below ¬¬a but not below a (*Exploitation*), meeting both a and ¬a (*Distribution*) — and all four regions are simultaneously inhabited iff a is ordinary. Kernel-checked as `lattice_four_position_partition` and `allFourCellsInhabited_iff` / `isOrdinary_iff_allFourCells`; see Brink (2026b) for the lattice development and Brink (2026a) for the topos-level statement. The partition is degenerate at every regular element (Exploitation empties) and at every dense element (Refusal empties).

**Opens X as a frame [C].** For a topological space X, Opens X — the open sets ordered by inclusion — is a complete Heyting algebra: meet is intersection, join is union, and U ⇨ V is the largest open whose intersection with U lies in V. (Mac Lane–Moerdijk 1992; the Mathlib instance is `Opens.instHeytingAlgebra` territory via the frame structure.)

**Nuclei [C].** A nucleus on a Heyting (or meet-semi)lattice is an inflationary, idempotent, binary-meet-preserving operator j; its fix-set is again a Heyting algebra with bottom j(⊥). Nuclei are the algebraic form of Lawvere–Tierney topologies and, in the reading of Brink (2026d), of observers' coarse-grainings.

## 3. Negation in Opens X: boundaries are what double negation erases

**Theorem 3.1 [K] (`coe_hnot`).** In Opens X, the Heyting negation of U is the interior of the set-complement: ¬U = int(Uᶜ).

**Theorem 3.2 [K] (`coe_hnot_hnot`).** Double negation is interior-of-closure: ¬¬U = int(cl U) — the regularization operator of pointless topology.

*Proof of 3.2 from 3.1.* ¬¬U = int((int Uᶜ)ᶜ) = int(cl U), by cl U = (int Uᶜ)ᶜ. ∎

These are classical facts; they are proved here for the `Opens` frame so that the program's `IsOrdinary` predicate and partition theorem apply to decision regions *verbatim*, with no transport step left informal.

## 4. A single threshold unit is regular: the perceptron is classical

Model a one-dimensional threshold unit as its decision region: `unitAbove θ` = (θ, ∞) or `unitBelow θ` = (−∞, θ), both open.

**Theorem 4.1 [K] (`unitAbove_regular`, `unitBelow_regular`).** For every θ, the unit is a regular element of Opens ℝ: ¬¬(θ, ∞) = (θ, ∞), and dually.

*Proof.* By 3.2, ¬¬(θ,∞) = int(cl(θ,∞)) = int[θ,∞) = (θ,∞). ∎

**Corollary 4.2 [K] (`unit_not_ordinary`).** A single threshold unit is not ordinary; by the non-degeneracy theorem, **no four-position structure opens around a lone perceptron**.

The content is the mechanism, not the computation: the unit's only undecidable locus is its decision boundary {θ}, a set with empty interior, and double negation — interior-of-closure — erases exactly such boundary-type defects. The perceptron is classical *because* everything it cannot decide is boundary, and classical logic is blind to boundaries. This derives, rather than describes, the "logical device" half of Levin's phase transition.

The statement is one-dimensional for legibility; the proof mechanism (closure adds only the boundary hyperplane, interior removes it) is dimension-free for half-spaces, and nothing below depends on the ambient dimension.

## 5. Composition manufactures the four-fold, and the remainder is the wall

**Definition 5.1 [K] (`composed`).** The composed region is the two-layer threshold circuit built inside the lattice from four units:

> composed = (unitAbove 0 ⊓ unitBelow 1) ⊔ (unitAbove 1 ⊓ unitBelow 2),

i.e. (0,1) ∪ (1,2): two same-class cells glued along an excluded wall at x = 1.

**Theorem 5.2 [K] (`composed_not_regular`, `composed_not_dense`, `composed_ordinary`).** The composed region is **ordinary**: ¬¬(composed) = (0,2) strictly exceeds it, and ¬(composed) ⊇ (2,∞) ∪ (−∞,0) is non-bottom.

**Corollary 5.3 [K] (`composed_allFourCells`).** The four-position partition around the composed region is non-degenerate: all four cells are inhabited. *A position space opens exactly where the device stops being classical.*

**Theorem 5.4 [K] (`composed_seam`).** The double-negation remainder of the composed region is exactly the wall:

> ¬¬(composed) ∖ composed = {1}.

Theorem 5.4 is the seam made exact. The point 1 is not in the region, but the region's regularization confidently includes it; it is undecidable from inside (any neighborhood of 1 meets both the region and its boundary structure) and invisible to every Boolean reduction (the regular elements of Opens ℝ, which form the classical shadow of the algebra, cannot separate composed from its healing). In Levin's vocabulary this is the algebraic form of manifold-membership undecidability — the hallucination locus — now located, for one worked device, at a specific point by a kernel-checked computation. We flag the interpretive step with its own grade: the identification of the ¬¬-remainder with Levin's hallucination mechanism is **[A]**; the geometry and algebra above it are **[K]**.

## 6. The destruction ledger: phantom mass and the co-aperture

The seam of §5 is one observer's blind spot at one element. The aggregate measure, developed to closed form in the companion aperture paper (Brink 2026d, §7 of the current version) and summarized here because §7 depends on it:

**Definition 6.1 [K].** For a nucleus j and element k, the **phantom mass** of k under j is |Icc k (j k)| — the size of the interval [k, j k].

**Lemma 6.2 (confusion class) [K] (`IsNucleus.le_apply_iff`).** For k ≤ x: x ≤ j k iff j x = j k. The interval [k, j k] is exactly the set of elements the observer j cannot distinguish from k from above; phantom mass counts a confusion class, which is what licenses the name. (Two lines from inflationary + monotone + idempotent, on any meet-semilattice.)

**Definition 6.3 [K].** The **co-aperture** of k is Σⱼ phantomMass j k, over all nuclei.

**Theorem 6.4 (closed forms and independence) [K] (`CoApertureClosedForm.lean`).**
1. On the chain Fin(m+1) with kernel exponent e: coaperture(e) + 2ᵉ = 2^{m+1}.
2. On any finite product of finite semilattices-with-top, the co-aperture is **exactly multiplicative**: coaperture(k) = ∏ᵢ coaperture(kᵢ). (Contrast: the aperture of Brink 2026d needs inclusion–exclusion to cross coordinates; the destruction ledger composes more simply than the survival ledger.)
3. On the divisor lattice of ∏ pᵢ^{aᵢ}: coaperture(k) = ∏ᵢ (2^{aᵢ+1} − 2^{kᵢ}), over ℤ.
4. **Independence, both directions:** on Div24, kernels 2 and 4 have equal apertures (3, 3) and unequal co-apertures (42, 36); on Div72, kernels 4 and 6 have equal co-apertures (84, 84) and unequal apertures (9, 6). All four witnesses decided through the closed forms. Neither invariant determines the other: what survives observation and what observation destroys are independent coordinates on kernels.

All statements were registered with hand-computed expectations before the Lean work (`preprints/aperture/coaperture-spec.md`, dated 2026-09-09) and verified the same day with no deviations of content.

## 7. The registered pilot: phantom mass in trained networks is vanishing, with a mechanism

§5 proves composition *must* manufacture a remainder; §6 proves the remainder is measurable. Neither says whether trained networks carry a substantial amount of it. That question — if real decision regions had substantial phantom mass, one could measure a network's confident-error zone from decision geometry alone, with no test set — was registered as open, and the pilot below was run under a binding pre-registered protocol (`phantom-study/SPEC.md`: spec, priors, kill conditions K0–K3, and amendments all committed before the pilot code existed; dated postscripts record execution). All results this section: **[R]**.

**Instrument, with its honesty note registered up front.** At grid resolution ε, interior-of-closure is morphological closing (dilate then erode, 3×3); the closing residual C_ε(U) ∖ U is the phantom at that resolution. Closing at resolution ε *is* a nucleus — the study applies the devices' own algebra to the devices — but the resolution sweep samples a one-parameter family out of an infinite lattice of observers, chosen for computability. A negative result therefore means *this family sees nothing*, not that no observer does.

**The registered case against (priors, written first).** ReLU networks partition input space into convex polytopes glued along shared faces, so the theory predicts phantom structure of **measure zero** — the continuum-limit phantom of a piecewise-linear decision region is plausibly always zero, and only thin positive-width structure at data-relevant scales could rescue the measurement. The named external prior: Goodfellow, Shlens & Szegedy (2014) — adversarial examples occupy broad contiguous subspaces near tilted boundaries; "space is not full of pockets" — with the boundary-tilting account (Tanay & Griffin 2016) concurring. Phase 0 literature checks (persistent homology of decision boundaries: Ramamurthy et al. 2019; linear-region counting: Montúfar et al. 2014, Hanin & Rolnick 2019; connectivity of decision regions: Nguyen et al. 2018, Fawzi et al. 2018; morphology-side search: closing used routinely as *cleanup* on classifier maps in segmentation practice, never measured as a diagnostic; nearest shape-analysis relatives — convexity of decision regions, boundary thickness (Yang et al. 2020), boundary-piece counting (Piwek et al. 2023) — all measure different objects) found no existing measurement and no foreclosing theorem: slits and fjords are invisible to homology (a disk minus a slit is still simply connected) while closing sees exactly them. Registered prior on full survival: ~30%, "probably generous."

**Protocol.** Fully-connected ReLU MLPs at **fixed total hidden-neuron budget 64** (64×1, 32×2, 16×4, 8×8 — the fixed budget is a Phase 0 amendment making the depth sweep a discriminator against Hanin–Rolnick's neuron-count account), trained to a registered validation-accuracy band on two-moons (0.945–0.975) and two-spirals (calibrated and logged before measurement: 0.951–0.981), 10 seeds per depth, 80 runs, zero exclusions. Both class regions rasterized over a ≥3-octave resolution sweep around the registered data scale ε* (median nearest-neighbor distance); measured quantity p(ε) = residual cells / region cells; registered pass condition E1′: p(ε*) ≥ 0.1% at some depth **and** fitted exponent α ≤ 0.5 over the finest octaves, plus a grid-offset stability control. Error test E3 registered as *distance-matched*: phantom cells compared to non-phantom cells in the same distance-to-boundary decile. Code: `phantom-study/01-pilot.py` (numpy only); raw outputs committed.

**Result: K1 — the kill condition triggered.** Mean p(ε*) ranged from 0.004% (shallow) to 0.096% (spirals, depth 8) — everything under the registered floor. The scaling discipline is what makes the kill a mechanism rather than a threshold dispute: median fitted α ≈ 1.5–2.25 at every depth on both datasets, against the registered α ≤ 0.5. In a 2D rasterization the residual *fraction* of structure of codimension c scales as ε^c: α ≈ 1 is the signature of face-like seams, α ≈ 2 of points and corners. The dimensional readout says the phantom of trained ReLU nets concentrates **where polytope faces meet, not along the faces** — grid cells straddling vertices of the linear-region complex. (Caveat, binding: this rests on a scaling fit over three resolutions and is not to be pushed further.) Registered prior #1 is thereby confirmed with a mechanism attached. The confident-error-measure framing is dead for ReLU MLPs of this class, and this note does not use it.

**What survived, reported as findings in their own right.**

- **E2: the mechanism is confirmed and the magnitude is not — separate claims that came apart.** At fixed 64-neuron budget, per-seed p(ε*) increases with depth: Spearman ρ = 0.767, permutation p < 10⁻⁴ on spirals (moons marginal: ρ = 0.32, p = 0.058). Under Hanin & Rolnick (2019), linear-region count at fixed budget is approximately depth-flat; phantom mass is not linear-region count, so there is no contradiction — but a depth-scaling quantity that region counting does not predict is a measurement nobody had made. Composition manufactures the remainder, exactly as §5 says it must; training crushes it to three orders of magnitude below relevance.
- **E3: consistent with error-enrichment and underpowered to establish it.** At depth 8, phantom cells' generative-truth error exceeded distance-matched controls by +37.0pp (moons, n = 106 cells) and +38.1pp (spirals, n = 230); depth 4 spirals +27.2pp; shallower, no signal. The population is intrinsically tiny by the same fact that killed E1′, so this design cannot strengthen the claim; dense per-pixel decision settings (segmentation) are where the cells are, noted as a reopener and not pursued.
- **The falsifiability check passed.** The registered prediction — from the Goodfellow prior jointly with the connectivity literature — was that any phantom found would be *attached* thin structure (fjords into the rival class), never isolated islands, and that islands would indict the rasterization rather than the theory. Across all 80 runs: **266 fjords, 0 islands.** The kill is believed.

**Registered reopeners (not promised).** Non-piecewise-linear decision surfaces (the measure-zero argument is ReLU-specific); very deep low-width regimes, where the E2 slope might cross into signal; segmentation for E3. **[O]**

## 8. What this note claims, and what it does not

Claimed: the bridge (threshold devices are Heyting elements; single units regular; composition ordinary; remainder = wall) **[K]**; the destruction ledger with closed forms and independence **[K]**; the registered negative result with its codimension-2 mechanism and the two survivors **[R]**.

Not claimed: that the ¬¬-remainder *is* Levin's hallucination mechanism (graded **[A]**, an interpretive identification); that any observer family beyond morphological closing sees nothing in trained nets (the honesty note); the corridor conjecture — that realizable regions are regular below the Cover transition, saturate toward density above it, and are ordinary exactly in between — which remains **[O]** and untouched; and any transfer of the pilot's negative result beyond ReLU MLPs of the tested class.

The methodological claim we do stand behind: every load-bearing formal statement here is kernel-checked, the empirical protocol was registered with its kill conditions before code existed, the kill triggered, and the write-up records the kill in the abstract. An interpretive framework gains a great deal from a mechanism that can refuse.

## 9. Formalization

All formal results are in Lean 4 against Mathlib4; no `sorry`, no `native_decide`; axiom audits at most `propext`, `Classical.choice`, `Quot.sound`.

| Result | Lean theorem | File |
|---|---|---|
| ¬ = interior-of-complement (3.1) | `coe_hnot` | `Examples/PerceptronRegular.lean` |
| ¬¬ = interior-of-closure (3.2) | `coe_hnot_hnot` | ibid. |
| Units regular (4.1) | `unitAbove_regular`, `unitBelow_regular` | ibid. |
| No four-fold at a unit (4.2) | `unit_not_ordinary` | ibid. |
| Composed ordinary (5.2) | `composed_not_regular`, `composed_not_dense`, `composed_ordinary` | ibid. |
| Four-fold at composed (5.3) | `composed_allFourCells` | ibid. |
| Remainder = wall (5.4) | `composed_seam` | ibid. |
| Confusion class (6.2) | `IsNucleus.le_apply_iff` | `Lattice/CoApertureClosedForm.lean` |
| Chain closed form (6.4.1) | `coaperture_chain_add` | ibid. |
| Exact multiplicativity (6.4.2) | `coaperture_pi` | ibid. |
| Divisor closed form (6.4.3) | `coaperture_closed_form_pi` | ibid. |
| Independence witnesses (6.4.4) | four `example` blocks, `decide` through closed forms | ibid. |
| Partition + non-degeneracy (§2) | `lattice_four_position_partition`, `isOrdinary_iff_allFourCells` | `Lattice/FourPositionLattice.lean`, `Examples/NishimuraKernelLaw.lean` |

Empirical artifacts: `phantom-study/SPEC.md` (registered spec, Phase 0 and Phase 1 postscripts, all dated), `phantom-study/01-pilot.py`, raw outputs under `phantom-study/out/`. Source: github.com/thefalsework/papers.

**Disclosure.** Drafting and formalization were AI-assisted under direction, per the project's validation architecture and its framework for epistemic dependency (Brink 2026e); the grade table above is the author's warrant.

## How to cite

> Brink, C. (2026). *The perceptron is a classical element: threshold decision regions in the Heyting algebra of open sets, with a registered negative result on phantom mass in trained networks.* Preprint v1.0, September 2026. Zenodo. doi:10.5281/zenodo.22715062.

The Lean formalization and the registered empirical artifacts are part of the citable object: `lean/FalseWorkPapers/Examples/PerceptronRegular.lean`, `lean/FalseWorkPapers/Lattice/CoApertureClosedForm.lean`, and `phantom-study/` at github.com/thefalsework/papers.

---

## References

- Brink, C. (2026a). A four-position partition of morphisms in elementary topoi with distinction structure. Preprint v1.1. Zenodo. doi:10.5281/zenodo.22715070.
- Brink, C. (2026b). The unique ordinary element of a one-generated Heyting algebra, the subgroup lattice of ℤ/12ℤ, and a characterization of n = p²q. Preprint, ibid., `preprints/ordinary-elements-z6/`.
- Brink, C. (2026c). The opened square: Aristotle, Spencer-Brown, and the kernel-checked foundation of the four-position lens. Preprint, ibid., `preprints/opposition-figure/`.
- Brink, C. (2026d). The aperture of a distinction: observer-relative ordinariness in Heyting algebras. Preprint v0.4. Zenodo. doi:10.5281/zenodo.22715068. (Earlier v0.2 text inside the repository snapshot DOI 10.5281/zenodo.22016585.)
- Brink, C. (2026e). Epistemic dependency as structural condition. Preprint, ibid., `papers/paper2-epistemic-dependency/`.
- Citkin, A. (2024). An algebraic proof of the Nishimura theorem. *Logics*, 2(4), 148–157.
- Cover, T. M. (1965). Geometrical and statistical properties of systems of linear inequalities with applications in pattern recognition. *IEEE Transactions on Electronic Computers*, EC-14(3), 326–334.
- Fawzi, A., Moosavi-Dezfooli, S.-M., Frossard, P., & Soatto, S. (2018). Empirical study of the topology and geometry of deep networks. *CVPR 2018*.
- Goodfellow, I., Shlens, J., & Szegedy, C. (2014). Explaining and harnessing adversarial examples. arXiv:1412.6572.
- Hanin, B., & Rolnick, D. (2019). Deep ReLU networks have surprisingly few activation patterns. *NeurIPS 2019*.
- Levin, I. (2026a). Understanding the nature of generative AI as threshold logic in high-dimensional space. arXiv:2604.02476.
- Levin, I. (2026b). From symbols to geometry: an indexical epistemology of generative AI. *Synthese*, 208:132. doi:10.1007/s11229-026-05778-5.
- Mac Lane, S., & Moerdijk, I. (1992). *Sheaves in Geometry and Logic.* Springer.
- Mathlib Community (2026). Mathlib4. github.com/leanprover-community/mathlib4.
- Montúfar, G., Pascanu, R., Cho, K., & Bengio, Y. (2014). On the number of linear regions of deep neural networks. *NeurIPS 2014*.
- Nguyen, Q., Mukkamala, M. C., & Hein, M. (2018). Neural networks should be wide enough to learn disconnected decision regions. *ICML 2018*.
- Piwek, P., et al. (2023). Exact count of boundary pieces of ReLU classifiers: towards the proper complexity measure for classification. *UAI 2023 (PMLR 216)*.
- Ramamurthy, K. N., Varshney, K. R., & Mody, K. (2019). Topological data analysis of decision boundaries with application to model selection. *ICML 2019*.
- Szegedy, C., et al. (2013). Intriguing properties of neural networks. arXiv:1312.6199.
- Tanay, T., & Griffin, L. (2016). A boundary tilting perspective on the phenomenon of adversarial examples. arXiv:1608.07690.
- Yang, Y., et al. (2020). Boundary thickness and robustness in learning models. *NeurIPS 2020*.
