# Witness triples and the aperture of a distinction

**Chris Brink**
github.com/thefalsework/papers
30 October 2026 — note, companion to *The Aperture of a Distinction* (v0.5).

**Status.** Algebra only. Grades: **[K]** kernel-checked in Lean 4 / Mathlib (axioms `propext`, `Classical.choice`, `Quot.sound`; no `sorry`); **[computed]** finite enumeration; **[O]** open.

---

## 1. The question

Let H be a finite Heyting algebra, equivalently D(P) for a finite poset P. Nuclei on D(P) are the operators j_S, S ⊆ P (`subNucleusEquiv` **[K]**). For k ∈ D(P), the *aperture* Ap(k) is the set of S such that j_S(k) is ordinary in Fix(j_S). The companion paper computes this on divisor lattices. Here the question is what kind of subset Ap(k) is.

It is not order-convex. The replacement is a certificate.

## 2. Witness triples

A *witness triple* for k is a 2-chain c < x with c ∈ k, x ∉ k, together with a point u ∉ k incomparable to both. The induced poset is the join-irreducibles of Div12 ≅ Z_6, and the trace of k is the tritone.

The triple is *valid in S* when {c, x, u} ⊆ S, no point of S ∩ k lies below u, and every point of S \ k below x is anchored by a point of S ∩ k.

> **Theorem [K]** (`opens_subNucleus_iff_witnessTriple`). j_S opens k iff S contains a witness triple valid in S. The coarsest opening observers are exactly the triples. Every opening observer contains a copy of Div12 with k as the tritone.

The aperture is the union of the cones {S | t is valid in S} (`opens_subNucleus_iff_mem_union` **[K]**). A triple is *unspoilable* when extra points never close it; then its cone is the principal up-set of its carrier (`WitnessTriple.unspoilable_iff`, `opens_iff_core_subset` **[K]**).

## 3. Two extremes

> **Rigid ordinary [K]** (`rigid_aperture_iff`). The identity is the unique opening observer iff P itself is a witness triple for k.

Up to isomorphism that is Div12 with k the tritone. Maximal fragility is a unique isomorphism type, not an example.

> **Latency [K]** (`latent_iff_all_triples_spoiled`). k is latent iff P contains triples and every one of them is spoiled at full resolution.

The smallest case is Div36 at 6, exactly two spoiled triples (`aperture_six_complete` **[K]**). Latency is not a unique isomorphism type: already at four join-irreducibles there are six latent pairs **[computed]**. What is unique is an infinite family containing Div36:

> **Two-chain family [K]** (`twoChain_latent`). The disjoint union of an `n`-chain and an `m`-chain, `n, m ≥ 2`, with kernel the two bottoms, is latently ordinary. Every triple is spoiled in `P` by the other bottom; the two triples on the first two rungs open it. Instantiating at `n = m = 2` is Div36's 6.

A census of all latent pairs is a list (105 of 766 pairs at five points). No cleaner complete criterion appeared; the family is the classification.

## 4. The one-eighth law on Z_{2m}

The join-irreducibles of Z_{2m} (m ≥ 3) are the first m rungs of the Rieger–Nishimura ladder: q₁, q₂ minimal; q₃ covers q₁; q_m covers q_{m−2} and q_{m−3} for m ≥ 4. The generator is g = {q₁}.

The only point not above q₁ is q₂. The only point above q₁ that is not above q₂ is q₃. So the only witness triple is (q₁, q₃, q₂). Nothing of g lies below q₂, and the only point of ↓q₃ \ g is q₃ itself, already above q₁, so the triple is unspoilable.

> **Theorem [K]** (`opens_g_iff_core_subset`). On Z_{2m}, j_S opens the generator iff {q₁, q₂, q₃} ⊆ S.

The opening observers are the supersets of a 3-set in an m-set: 2^{m−3} of them, one-eighth of the 2^m nuclei. Odd truncations Z_{2m+1} (adjoin a top) match the same count by enumeration through n = 14 **[computed]**; a top cannot be u or an x with q₂ ≰ x. The infinite ladder F(1), for spatial nuclei, is **[O]**.

## 5. Files

`lean/FalseWorkPapers/Lattice/ApertureCriterion.lean` (triples, unspoilable, rigid, fiber monotonicity, Div180 non-convexity); `lean/FalseWorkPapers/Lattice/RiegerNishimuraAperture.lean` (one-eighth on Z_{2m}); `lean/FalseWorkPapers/Lattice/LatentFamily.lean` (two-chain latent family); `wolfram/aperture-shape.mjs` (sweep through seven join-irreducibles); longer discussion in `aperture-shape-note.md`.
