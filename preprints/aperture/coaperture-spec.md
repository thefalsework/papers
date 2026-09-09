# The co-aperture: a registered spec (written before the Lean work)

**Date registered: 2026-09-09.** This file is committed before
`Lattice/CoApertureClosedForm.lean` exists. Everything below is [H]
until the kernel accepts it; the hand-computed numbers are the
falsifiable expectations. Deviations at execution time will be logged
in a dated postscript, per house rules.

## Motivation

The aperture counts the observers (nuclei) under which a kernel
element remains ordinary — the distinctions that *survive*. Nobody has
the dual ledger: what each observer *destroys*. The critique of record
(2026-09-09 conversation) put it as: "Your closed form counts openers;
there's no dual formula for what each nucleus kills."

The object is not a blind spot but a phantom: a nucleus j does not
delete elements, it manufactures confusion — j(k) ⊇ k and the observer
cannot tell the halo from the thing. The correct picture is
`composed_seam` (PerceptronRegular.lean), where the ¬¬-remainder of a
composed decision region is exactly the phantom wall {1}: confident
false presence, not absence. The co-aperture is that seam generalized
from one observer to the whole ledger.

## Definition

For a nucleus j on a finite lattice and an element k:

    phantomMass j k := card (Icc k (j k))

justified by the **confusion-class lemma** (expected to be a two-line
consequence of monotone + idempotent + inflationary):

    E0. For any nucleus j: Icc k (j k) = { x | k ≤ x and j x = j k }.

The interval above k up to j k is exactly the set of elements the
observer j cannot distinguish from k from above. Note phantomMass ≥ 1
always (k itself); the *proper* halo is phantomMass − 1, and
phantomMass = 1 iff j fixes k (k is in the observer's world exactly).

    coaperture k := Σ over all nuclei j of phantomMass j k

Total phantom mass at k: over all ways of observing the lattice, how
many (observer, element) pairs conflate that element with k. The same
shape as a conemass sum — one summand per observer, weighted by the
size of the structure it casts over k — which is a rhyme, not a
theorem, and is recorded here as such.

## Expected results

All on the same machinery as the aperture closed form
(`ApertureClosedForm.lean`, `ApertureClosedFormPi.lean`): nuclei on a
finite bounded chain are the top-sets; nuclei on finite products
factor componentwise (`nucleusPiEquiv`); `Pi.card_Icc` makes interval
cardinalities multiply.

**E1 (chain closed form).** On the chain `Fin (m+1)` with kernel
exponent e:

    coaperture e = 2^(m+1) − 2^e

Hand derivation: double count pairs (F, x) with e ≤ x ≤ j_F e. For
fixed x ≥ e, the condition is F ∩ Ico e x = ∅; the top-sets avoiding
that interval number 2^(m − (x − e)). Summing over x = e..m gives
2^m + 2^(m−1) + ... + 2^e = 2^(m+1) − 2^e. Sanity: e = ⊤ gives
2^m·2 − 2^m = 2^m (every nucleus fixes ⊤, phantomMass ≡ 1, and there
are 2^m nuclei) — consistent. e = ⊥ gives 2^(m+1) − 1.

**E2 (Pi multiplicativity).** On a finite product of chains, because
nuclei factor componentwise and Icc cardinality is a product:

    coaperture k = ∏ᵢ (per-chain coaperture of kᵢ)

**E3 (closed form on divisor lattices).** On the exponent lattice
`Π i : Fin r, Fin (aᵢ + 1)` of Div(p₁^{a₁} ⋯ p_r^{a_r}), kernel
k = (k₁, …, k_r):

    coaperture k = ∏ᵢ (2^(aᵢ+1) − 2^(kᵢ))

**E4 (independence, both directions — the point of the exercise).**
Neither invariant determines the other. Hand-computed witnesses, to be
kernel-checked:

- *Aperture does not determine co-aperture.* Div24 = 2³·3,
  a = (3,1), N = 2⁴ = 16. Kernel 2 = (1,0): aperture
  16 − 5·1 − 5·2 + 2 = **3**, coaperture (2⁴−2)(2²−1) = **42**.
  Kernel 4 = (2,0): aperture 16 − 7·1 − 5·2 + 4 = **3**, coaperture
  (2⁴−4)(2²−1) = **36**. Same aperture, different co-apertures — and
  the apertures are nonzero, so this is not the degenerate case.

- *Co-aperture does not determine aperture.* Div72 = 2³·3²,
  a = (3,2), N = 2⁵ = 32. Kernel 4 = (2,0): aperture
  32 − 7·1 − 5·4 + 4 = **9**, coaperture (2⁴−4)(2³−1) = 12·7 = **84**.
  Kernel 6 = (1,1): aperture 32 − 5·3 − 5·3 + 4 = **6**, coaperture
  (2⁴−2)(2³−2) = 14·6 = **84**. Same co-aperture, different apertures.

If E4 verifies, the co-aperture is genuinely new information relative
to the aperture — the survival count and the destruction ledger are
independent coordinates on kernels. If it fails, the postscript will
say which hand computation was wrong or whether the dependence is
real, and a real dependence (co-aperture a function of aperture) would
itself be the reportable result.

**E5 (structural remark, expected free).** The co-aperture depends
only on 2^{Σkᵢ} and the co-heights aᵢ − kᵢ... stated more carefully:
∏(2^(aᵢ+1) − 2^kᵢ) = 2^{Σkᵢ} · ∏(2^(aᵢ−kᵢ+1) − 1). The second factor
depends only on the co-exponents aᵢ − kᵢ. Recorded as an observation
on the formula, not a separate theorem.

## Postscript (2026-09-09, same day, after execution)

`lean/FalseWorkPapers/Lattice/CoApertureClosedForm.lean` builds clean;
every expectation above is now [K]:

- **E0** = `IsNucleus.le_apply_iff`, proved on any `SemilatticeInf` —
  two lines from inflationary + monotone + idempotent, as expected.
- **E1** = `coaperture_chain_add`, stated additively
  (`coaperture e + 2^e = 2^(m+1)`) to stay in ℕ. The proof is the
  registered double count: transfer the sum to top-sets, count
  (observer, conflated element) pairs the other way, geometric series.
- **E2** = `coaperture_pi`, proved at full generality (any finite
  family of finite semilattices with ⊤, not just chains). One
  structural surprise worth recording: the aperture needs
  inclusion–exclusion to assemble across coordinates; the co-aperture
  is *exactly multiplicative* — `Pi.card_Icc` turns the phantom
  interval of a product into a product of intervals and the sum
  factors. The destruction ledger composes more simply than the
  survival count.
- **E3** = `coaperture_closed_form_pi`: ∏ᵢ(2^{aᵢ+1} − 2^{kᵢ}), over ℤ,
  exactly as registered.
- **E4**: all four hand-computed witnesses verified by `decide`
  through the closed forms. Div24 kernels (1,0) and (2,0): apertures
  3 and 3, co-apertures 42 and 36. Div72 kernels (2,0) and (1,1):
  co-apertures 84 and 84, apertures 9 and 6. No hand computation was
  wrong; independence holds in both directions.

Deviations from spec: none in content. One presentational deviation:
E1 is stated additively rather than with ℕ-subtraction, matching the
house convention of the aperture files (`card_worldDense_add` etc.);
the subtraction form appears in E3 over ℤ.

## What this is not

No empirical claim, no application, no connection to conemass beyond
the recorded rhyme. It is a laboratory result about finite Heyting
algebras, offered to the same standard as the aperture closed form:
the kernel accepts it or it does not exist.
