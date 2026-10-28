# Outreach draft — Second letter to Alex Citkin (nuclei on Zₙ that keep the generator ordinary)

**Status.** DRAFT, not sent. Drafted 2026-10-28.
**Gate.** The June 2026 correspondence (`citkin-email.md`) was closed after three contacts with the note "no fifth email." This letter would reopen it four months later on a new question. It is written so that the decision to send is a one-line yes/no; the default, absent a reason to override the June record, is not to send. Reasons that would justify sending: the question is new, precise, in his specialty (the Rieger–Nishimura algebra and its quotients, the Lindenbaum–Tarski method), carries a kernel-checked finite answer and a conjecture for the infinite object, and asks nothing he must look up.
**Purpose.** Prior-art and framing, not verification. Three questions: whether the finite classification of "generator-preserving" nuclei on Zₙ is known; whether the infinite statement for the Rieger–Nishimura algebra is known or easy for him; and whether the stratification of nuclei by their bottom element has a standard name on the dual side.
**Prior-art check done before drafting (2026-10-28).** Nuclei on the down-set algebra of a finite poset ↔ subsets of the poset: Simmons; Bezhanishvili–Harding (nuclei on Alexandrov frames); in Esakia-dual terms, nuclei on a finite Heyting algebra ↔ subsets of its dual space. The trace reformulation (`k ∩ S` ordinary in D(S)) and the pointwise criterion via minimal points are elementary and are not claimed as new; what is claimed is the specific answer for Zₙ and the fact that apertures are not order-convex. His arXiv:2512.05633 p. 13 asserts that Zₙ (n > 5) has a single ordinary element which generates the algebra; the letter builds on that sentence.
**Claim-to-theorem map (verify against repo before send).** Nuclei ↔ subsets: `subNucleusEquiv` (`ObserverClassification.lean`) [K]. Trace characterization: `opens_subNucleus_iff` [K]. Pointwise criterion: `opens_subNucleus_iff_minimal` (`ApertureCriterion.lean`) [K]. Witness-triple theorem: `opens_subNucleus_iff_witnessTriple`, coarsest observers `WitnessTriple.eq_of_subset_opens`, every opening observer contains a Div12 `exists_witnessTriple_subset` [K]. Fiber monotonicity: `opens_subNucleus_of_subset_of_bot_eq` [K]. Non-convexity on Div180: `aperture_not_convex_div180` [K]. Three-point core on Zₙ and the count 2^{|P|−3}: argued from the criterion in `preprints/aperture/aperture-shape-note.md` C4, [computed] for n = 6..14 (`wolfram/aperture-shape.mjs`); **not formalized for general n** — the letter says so. Axiom audit on all [K] items: `propext`, `Classical.choice`, `Quot.sound`; no `sorry`.
**Length.** Body is ~480 words including signature; the June letter was ~350. Trim the two-facts paragraph if a shorter letter is wanted; the questions and the Z_n statement should stay. **Tone.** Algebra only; no framework vocabulary; his paper first.

---

## Subject

> Nuclei on Z_n that keep the generator ordinary — a finite answer and a question about F(1)

## Body

Dear Dr. Citkin,

Thank you again for the June exchange; your remarks are cited as personal communication in the deposited note, as agreed. I am writing once more because a question has come up that sits squarely in your territory, and I would rather ask you than guess at the literature.

Your December preprint (arXiv:2512.05633, p. 13) notes that for n > 5 the algebra Z_n contains a single ordinary element, which generates it. I have been looking at what happens to that element under nuclei. For a nucleus j on a Heyting algebra H, the fixed points Fix(j) form a Heyting algebra with bottom j(0), and one can ask whether j(g) is still ordinary *in Fix(j)*. Call such j generator-preserving.

For finite H = D(P) (down-sets of a finite poset), nuclei correspond to subsets S ⊆ P, with j_S(U) = {x : ↓x ∩ S ⊆ U}, and j_S(k) is ordinary in Fix(j_S) iff the trace k ∩ S is ordinary in D(S). Written out with M = min S, this says: j_S preserves k iff (i) some point of M is outside k and (ii) some point of S outside k has all its M-predecessors inside k. All of this is machine-checked (Lean 4 / Mathlib, standard axioms only).

Equivalently (and this is the form I have kernel-checked): j_S preserves k iff S contains a *witness triple* valid in S — a 2-chain c < x with c inside k and x outside, plus a point u outside k incomparable to both, with no spoiler in S. The coarsest preserving observers are exactly those triples, each seeing a copy of the six-element algebra Z_6 with k as its generator. Applied to Z_n, with P the ladder of join-irreducibles q₁, q₂ (minimal), q₃ (over q₁ only), q₄, …, and g = {q₁}: the generator has exactly one unspoilable witness triple {q₁, q₂, q₃}, so the generator-preserving nuclei are **exactly those with S ⊇ {q₁, q₂, q₃}**, hence 2^{|P|−3} of them, one-eighth of all nuclei, for every n ≥ 6. I have verified the count by enumeration for n = 6..14 and have not yet formalized uniqueness-and-unspoilability for general n.

Two further facts may interest you. First, the set of preserving nuclei is in general not order-convex in the lattice of nuclei: on the 18-element algebra D({a<c} ⊔ {b<d} ⊔ {e}) with k = {a, b}, S₁ = {a, c, d} preserves k, S₁ ∪ {b} does not, and P does. Second, what is true is that preservation is monotone under refinements that keep j(0) fixed, i.e. that do not add a point below an existing minimal point of S.

My questions: (a) Is the classification of generator-preserving nuclei on Z_n known, perhaps in the language of subalgebras or filters of the Rieger–Nishimura lattice? (b) For the free algebra F(1) itself, is the corresponding statement (the nuclei preserving the generator are those whose dual subset contains the three bottom points of the ladder) known, or obvious to you by the quotient route you used in June? (c) Does the stratification of nuclei by their bottom element j(0) have a standard name on the dual side?

Files: `ApertureCriterion.lean` and `ObserverClassification.lean` under https://github.com/thefalsework/papers/tree/main/lean/FalseWorkPapers/Lattice. As before, no reply is needed if this is of no interest, and I will not follow up.

With thanks,

Chris Brink
Independent researcher
`chris@falsework.dev`

---

## Pre-send checklist

- [ ] Re-run `lake build FalseWorkPapers.Lattice.ApertureCriterion` and `#print axioms` on the four named theorems; confirm the three-axiom set.
- [ ] Confirm the GitHub URL returns 200 from outside and that `ApertureCriterion.lean` is on `main`.
- [ ] Decide whether to formalize the general-n three-point core first (a short file over the ladder poset would turn "verified for n = 6..14" into [K] and remove the only hedge in the letter).
- [ ] Decide, against the June "no fifth email" record, whether to send at all. Record the decision here either way.
