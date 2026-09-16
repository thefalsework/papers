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

---

## Postscript (2026-09-16, same day): results

Oracle: `01-joint-census.py`. One formatting repair after first
execution (Spearman is undefined at n = 2 where aperture is
identically zero; the print crashed — no logic change). J0 passed on
all seven recorded values; the E6 cross-check (direct |Icc| against
relative down-set counts) matched on all 404 kernels at n ≤ 4. Survey:
406 exhaustive posets (n ≤ 5) + 100 sampled (n = 6); 7,485 kernels.
F1/F4 sanity assertions held. **No kill fired. One registered
expectation missed; logged below.**

**J1 — the miss.** Both fiber directions together appear in 28.6% of
n = 5 posets, not the registered majority. The registered expectation
was wrong at n = 5; the quantity is strongly size-dependent (0% at
n ≤ 4, 28.6% at n = 5, 51.0% at n = 6) and the majority arrives one
size later than guessed. K2 (< 5%, witness exoticism) did not fire —
E4-in-the-wild is not exotic, but at these scales it is *emerging*,
not generic. A direction asymmetry the spec did not anticipate:
same-aperture-different-co-aperture appears earlier and more often
than the converse (9 posets at n = 4 already have it; the converse
first appears at n = 5). At small scale the co-aperture is the finer
coordinate — it separates kernels the aperture cannot.

**J2 — held.** Spearman by stratum: +0.29 (n=3), +0.43 (n=4),
+0.52 (n=5), +0.47 (n=6) — all under the registered 0.7. Within-poset:
median +0.56, range [+0.25, +0.76] over 427 posets, and **zero** posets
at |ρ| ≥ 0.95. K1 (statistical redundancy) does not fire. The two
invariants are moderately positively associated in bulk and nowhere
near redundant.

**J3 — the open half of F4, answered.** Positive aperture is not an
ordinary-only phenomenon: 22.7% of dense and 23.3% of regular kernels
carry aperture > 0 (kernels classically invisible in D(P) that some
sub-ecosystem still sees as generative). Ordinary kernels: 100%
(forced, F4), mean aperture 9.18 versus ≈ 0.8 for the other classes.
Mean co-aperture orders the classes ordinary (135.9) > regular
(114.8) > dense (70.0).

**J4 — descriptive.** Max-aperture kernels are principal cones at
58.0% against a 34.3% base rate (×1.7 enrichment); the
minimum-co-aperture positive-aperture kernels are principal at only
25.9% (below base). Read plainly: survival concentrates at positions
(cones); low destruction concentrates at non-positions. Recorded,
uninterpreted beyond this sentence.

**One-line summary.** The survival count and the destruction ledger
are confirmed as genuinely independent coordinates in the wild
(no redundancy anywhere, fibers in both directions), with the
independence *growing* with scale rather than present from the start —
and the census's registered guess about how fast was wrong by one
size, which is recorded.
