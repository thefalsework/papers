# The joint aperture/co-aperture census: registered spec

*Registered 2026-09-16, committed before any census code exists.
Context: the two invariants' independence is already kernel-grade at
four witness points (`CoApertureClosedForm.lean` E4: Div24 kernels
(1,0)/(2,0) share aperture 3 with co-apertures 42/36; Div72 kernels
(2,0)/(1,1) share co-aperture 84 with apertures 9/6). What does not
exist is the systematic table: the joint distribution of
(aperture, co-aperture) over a whole family of algebras, treating the
survival count and the destruction ledger as independent coordinates.
This is the "maximum leverage from what exists" pure study of the
2026-09-16 plan — no new machinery, no new definitions, one table.*

## Setup

Machinery is the perturbation-study core, verbatim (`perturbation-
study/01-edge-oracle.py`): all labeled posets on n = 2..5 (deduped on
the closed down-tuple), ≥ 100 sampled on n = 6 (seeded). For each
poset P, **kernels are all elements of D(P)** (every down-set, not
only principal cones; principal cones flagged as a sub-population,
since positions in the program are cones). For each kernel K:

- class of K in D(P) (dense / regular / ordinary),
- aperture(K) = #{S ⊆ P : K ∩ S ordinary in D(S)} — the
  kernel-checked characterization
  (`aperture_eq_card_ordinary_traces`),
- coaperture(K) = Σ_{S ⊆ P} |Icc(K, j_S K)|, phantom mass computed
  by the verified E6 identity (relative down-set count on
  j_S K ∖ K).

## Forced anchors (hand-derived before registration, per the process rule of 2026-09-15)

The arrangement deflation's rule was: derive what the ambient algebra
forces *before* registering expectations, so the census cannot
"discover" it. Forced here, two-line proofs each:

- **F1.** aperture(⊥) = aperture(⊤) = 0 for every P: the trace of ⊥
  is ∅, always regular in D(S); the trace of ⊤ is S, always dense.
  The two co-aperture extremes both sit at aperture zero, so the
  joint relationship is **non-monotone by construction**.
- **F2.** coaperture(⊤) = 2^n exactly (every observer fixes ⊤,
  phantom mass ≡ 1, one summand per S ⊆ P), and this is the global
  minimum of co-aperture.
- **F3.** The blind observer j_∅ ≡ ⊤ contributes |[K, ⊤]| to every
  kernel, so coaperture(K) ≥ (2^n − 1) + |[K, ⊤]|; co-aperture is
  floor-inflated for low kernels regardless of structure.
- **F4.** K ordinary in D(P) ⟹ aperture(K) ≥ 1 (the trace at S = P
  is K itself). The converse direction — can a regular or dense
  kernel have positive aperture? — is *not* forced either way and is
  a census question (J3).

Any census output that merely restates F1–F4 is not a finding.

## Validation gate

**J0.** The census code path must reproduce, exactly:

1. The four E4 witnesses through the chain-sum posets:
   D(chain₃ ⊔ chain₁) ≅ Div24, kernels (1,0) and (2,0) → apertures
   3, 3 and co-apertures 42, 36; D(chain₃ ⊔ chain₂) ≅ Div72,
   kernels (2,0) and (1,1) → apertures 9, 6 and co-apertures 84, 84.
2. The perturbation study's recorded H3-motif values (p: ordinary,
   aperture 1, co-aperture 18; b: regular, 0, 12; q: regular, 0, 14).

Any mismatch stops the study (K0).

## Questions

**J1 (fibers in the wild).** Within each poset, count aperture-fibers
containing ≥ 2 distinct co-aperture values, and co-aperture-fibers
containing ≥ 2 distinct apertures — restricted to kernels with
aperture > 0, so F1's forced zero-fiber does not pad the count.
Registered expectation, moderate confidence: **both fiber directions
are generic, not exotic** — at n = 5, a majority of posets exhibit
both. This is E4-in-the-wild.

**J2 (bulk redundancy).** Spearman rank correlation between aperture
and co-aperture across kernels, stratified by n, and the
distribution of within-poset correlations (posets with ≥ 3 distinct
values on each coordinate). Registered expectation, low confidence:
|ρ| < 0.7 in every stratum — the F1 anchors force non-monotonicity
at the ends, and the E4 witnesses show slack in the middle.

**J3 (class × coordinates).** Distribution of (aperture, co-aperture)
within each class (dense / regular / ordinary). The open half of F4:
how often do regular or dense kernels carry positive aperture?
Registered expectation, low confidence: positive-aperture regulars
exist at n ≥ 4 (the perturbation survey's L2 flips suggest traces go
ordinary before the kernel does) — but frequency unregistered,
descriptive.

**J4 (extremal profiles).** Descriptive, no kill: the kernels at
maximal aperture per poset, and at minimal co-aperture among
positive-aperture kernels — height, principality, cover count. This
is the input the four-position reading needs to say *where* the
generative positions sit; recorded as a table, interpreted only in
the postscript.

## Kills

- **K0**: J0 mismatch. Stop, fix, rerun from scratch.
- **K1 (statistical redundancy)**: |Spearman ρ| ≥ 0.95 in every
  stratum of J2. The "independent coordinates" framing is then
  downgraded to "formally independent, statistically redundant" in
  every document that uses it, and the redundancy becomes the
  reportable result.
- **K2 (witness exoticism)**: fewer than 5% of n = 5 posets exhibit
  both J1 fiber directions. Then E4's witnesses are special points,
  not generic behavior, and the census must say "independent at
  special points" instead.

## Non-claims

No dynamics (no edge steps), no application, no Levin-facing content.
One run; deviations logged in a dated postscript, per house rules.
