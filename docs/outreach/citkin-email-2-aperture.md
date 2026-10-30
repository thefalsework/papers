# Outreach draft — Second letter to Alex Citkin (nuclei on Zₙ that keep the generator ordinary)

**Status.** SEND-READY, 2026-10-30. Drafted 2026-10-28; updated after the unique-triple theorem for Z_{2m} was kernel-checked.
**Gate.** The June 2026 correspondence (`citkin-email.md`) was closed after three contacts with the note "no fifth email." This letter reopens it on a new question. Override: the question is new, precise, in his specialty, and now carries a kernel-checked answer for every even truncation Z_{2m}, not only a table through n = 14. Sending is the remaining step (this file cannot press send).
**Purpose.** Prior-art and framing, not verification. Three questions: whether the finite classification of generator-preserving nuclei on Zₙ is known; whether the infinite statement for the Rieger–Nishimura algebra is known or easy for him; and whether the stratification of nuclei by their bottom element has a standard name on the dual side.
**Prior-art check done before drafting (2026-10-28).** Nuclei on the down-set algebra of a finite poset ↔ subsets of the poset: Simmons; Bezhanishvili–Harding (nuclei on Alexandrov frames); in Esakia-dual terms, nuclei on a finite Heyting algebra ↔ subsets of its dual space. The trace reformulation and the pointwise criterion via minimal points are elementary and are not claimed as new; what is claimed is the specific answer for Zₙ and the fact that apertures are not order-convex. His arXiv:2512.05633 p. 13 asserts that Zₙ (n > 5) has a single ordinary element which generates the algebra; the letter builds on that sentence.
**Claim-to-theorem map (2026-10-30).** Nuclei ↔ subsets: `subNucleusEquiv` [K]. Trace: `opens_subNucleus_iff` [K]. Pointwise: `opens_subNucleus_iff_minimal` [K]. Witness triples: `opens_subNucleus_iff_witnessTriple`, `WitnessTriple.eq_of_subset_opens`, `exists_witnessTriple_subset` [K]. Unspoilable / union of cones: `WitnessTriple.unspoilable_iff`, `opens_iff_core_subset` [K]. Rigid ordinary: `rigid_aperture_iff` [K]. One-eighth on Z_{2m}: `Ladder.opens_g_iff_core_subset`, `triple_unique`, `genTriple_unspoilable` [K] (`RiegerNishimuraAperture.lean`). Odd truncations still [computed] n = 7,9,…,14. Fiber monotonicity: `opens_subNucleus_of_subset_of_bot_eq` [K]. Non-convexity: `aperture_not_convex_div180` [K]. Axiom audit: `propext`, `Classical.choice`, `Quot.sound`; no `sorry`.
**Tone.** Algebra only; no framework vocabulary; his paper first.

---

## Subject

> Nuclei on Z_n that keep the generator ordinary — a finite answer and a question about F(1)

## Body

Dear Dr. Citkin,

Thank you again for the June exchange; your remarks are cited as personal communication in the deposited note, as agreed. I am writing once more because a question has come up that sits in your territory, and I would rather ask you than guess at the literature.

Your December preprint (arXiv:2512.05633, p. 13) notes that for n > 5 the algebra Z_n contains a single ordinary element, which generates it. I have been looking at what happens to that element under nuclei. For a nucleus j on a Heyting algebra H, the fixed points Fix(j) form a Heyting algebra with bottom j(0), and one can ask whether j(g) is still ordinary *in Fix(j)*. Call such j generator-preserving.

For finite H = D(P), nuclei correspond to subsets S ⊆ P, with j_S(U) = {x : ↓x ∩ S ⊆ U}, and j_S(k) is ordinary in Fix(j_S) iff the trace k ∩ S is ordinary in D(S). Equivalently: j_S preserves k iff S contains a *witness triple* valid in S — a 2-chain c < x with c inside k and x outside, plus a point u outside k incomparable to both, with no spoiler in S. The coarsest preserving observers are exactly those triples, each seeing a copy of Z_6 with k as its generator. All of this is machine-checked (Lean 4 / Mathlib, standard axioms only).

On Z_{2m} (m ≥ 3), with P the first m rungs of the ladder of join-irreducibles (q₁, q₂ minimal; q₃ covering q₁; q_m covering q_{m−2} and q_{m−3}), and g = {q₁}: the generator has a unique unspoilable witness triple {q₁, q₂, q₃}. So the generator-preserving nuclei are exactly those with S ⊇ {q₁, q₂, q₃} — 2^{m−3} of them, one-eighth of all nuclei. This is now kernel-checked for every m, not only enumerated. Odd truncations Z_{2m+1} (adjoin a top) match the same count by enumeration through n = 14; a top cannot serve as u or as an x incomparable to q₂.

Two further facts may interest you. First, the set of preserving nuclei is in general not order-convex: on the 18-element algebra D({a<c} ⊔ {b<d} ⊔ {e}) with k = {a, b}, S₁ = {a, c, d} preserves k, S₁ ∪ {b} does not, and P does. Second, preservation is monotone under refinements that keep j(0) fixed. As a corollary of the triples: the identity is the unique preserving nucleus iff P itself is a witness triple — i.e. only on Z_6, with g the generator.

My questions: (a) Is the classification of generator-preserving nuclei on Z_n known, perhaps in the language of subalgebras or filters of the Rieger–Nishimura lattice? (b) For the free algebra F(1) itself, is the corresponding statement (the spatial nuclei preserving the generator are those whose dual subset contains {q₁, q₂, q₃}) known, or obvious to you by the quotient route you used in June? (c) Does the stratification of nuclei by their bottom element j(0) have a standard name on the dual side?

Files: `ApertureCriterion.lean` and `RiegerNishimuraAperture.lean` under https://github.com/thefalsework/papers/tree/main/lean/FalseWorkPapers/Lattice. As before, no reply is needed if this is of no interest, and I will not follow up.

With thanks,

Chris Brink
Independent researcher
`chris@falsework.dev`

---

## Pre-send checklist

- [x] Kernel-check unique unspoilable triple on Z_{2m} (`opens_g_iff_core_subset`).
- [x] Re-run `lake build FalseWorkPapers.Lattice.RiegerNishimuraAperture` and `#print axioms` on the named theorems; confirm the three-axiom set (`propext`, `Classical.choice`, `Quot.sound`; no `sorry`).
- [ ] Confirm the GitHub URL returns 200 from outside and that both Lean files are on `main`.
- [ ] Send from `chris@falsework.dev` to `acitkin@gmail.com` (same channel as June). Do not follow up if no reply.
