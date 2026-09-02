# Accretion study

**Question.** Which graph growth rules force which growth signatures
(E-vs-R, E-vs-D at matched battery)? Run the program's own Debian-grade
estimator on synthetic universes grown from known rules — partly to map
the generative landscape, partly as the instrument's own audit: on a
rule that is provably blind to the cells, the estimator had better say
nothing.

**What happened, in order.**

1. **Phase A feasibility** (`01-explore.mjs`): the first synthetic
   universes were degenerate — with dependency count m drawn from
   {1..4}, node 0 is a universal ancestor, Refusal is empty for every
   kernel, nothing is evaluable. Fixed by allowing m = 0 (root nodes,
   as in every real corpus) and by making PC's platform choice uniform
   rather than popularity-weighted (which had recreated the universal
   ancestor through primordial hubs). Both fixes documented in
   `SPEC.md`'s first postscript and `sim-lib.mjs` comments.
2. **The audit finding** (`01b-calibrate.mjs`, `01c-validate-clustered-null.mjs`):
   replicate-universe calibration showed the point estimator is
   *unbiased* on null generators, but the within-corpus sign-flip null
   — the machinery behind every "percentile" in the program's field
   studies — understates true across-universe variance ≈ 10×, and
   kernel-clustered flips do not repair it (the dependence is
   universe-level). Consequences for the field results are spelled out
   in `SPEC.md` postscript 1 §4 and in dated postscripts across the
   briefs and the synthesis paper: single-corpus percentiles are
   conditional statements; generator-level warrant comes only from
   cross-corpus replication and sealed out-of-sample bets.
3. **Phase B′ confirmation** (`02-confirm.mjs`, registered before its
   one run, fresh seeds): **all three registered verdicts landed.**
   B1 CONFIRMS-NULL — U and PA read zero on both contrasts (|t| ≤ 1.8,
   20 universes each). B2 CONFIRMS — PC(0) forces **R > E > D** at
   matched battery, t_ER = −10.2 (0/20 positive), t_ED = +10.8 (20/20
   positive). B3 (descriptive β gradient): R-over-E fades smoothly with
   footprint breadth; E-over-D is flat positive through β = 0.75 and
   dead at β = 1 — the two contrasts decouple from a single dial,
   reproducing the field's dissociation of the two axes.
4. **Phase C theory** (`THEORY.md`): exact unbiasedness proof for U,
   exchangeability argument for PA, the two-level analysis of the
   sign-flip failure, and the **PC flux law**: expected gain under
   cone-local accretion tracks truncated up-set size (transitive
   dependents), a quantity absent from the matching battery — the
   constructive explanation of how a cell can legitimately out-inform
   the reviewer's arsenal. The sign of the PC(0) effect is stated open,
   with a registered next measurable.

**What this study does *not* say.** PC produces the inverse of the
Go/Debian field ordering (R > E, not E > R), so no rule in this family
models package-ecosystem growth. The open generative question: which
rule families force E > R.

**Queued methods improvement ("battery v2").** Per the flux law, add
truncated transitive-dependent count to the field matching battery and
re-run Go/Debian: if E-over-R survives, the claim strengthens
materially; if it dissolves, that's the third artifact caught in-house.

**Phase D (2026-09-01, evening): the sign problem measured, the search
begun — two honest negatives.**

- The registered sign measurement (`03-sign.mjs`, 10 fresh PC(0)
  universes): S1 CONFIRMS — up-set size predicts gain in 10/10
  universes; the flux law's core is true. But S2/S3 killed the
  conjectured *explanation*: the up-set gap in matched pairs is ~10×
  too small, and adding up-set to the battery leaves Δ_ER = −0.123 at
  t = −5.6. PC(0)'s inversion is not primarily up-set flux at cap 200.
  Live candidates: truncation saturation, cone-weighting (`THEORY.md`
  §3, updated in place).
- The exploratory search for the field's ordering (`SPEC-D.md`,
  `04-explore-d.mjs`, 15 universes, battery v2): SIB (co-user rule)
  and MIX(0.5) force R > E > D strongly; FRONT(2000) is null on both
  axes. **Nothing graduates.** Seven mechanism families now on record,
  none produces E > R. The field ordering remains unexplained — which
  is the finding.

**Phase E (2026-09-02): the discriminator experiment — registered kill,
with an inversion worth keeping.** Is the quiet-load-bearing head
signature (high concentration rank, low dependent-count rank — the
liblzma5/unicode-ident profile conemass surfaces) a mechanism
fingerprint or a generic byproduct? Registered QUIET50 statistic, one
run (`06-signature.mjs`). E1 lands (all real corpora show it, 20-33 of
the top 50); E2 fails (U and PA show it too); E3 fails **inverted**
(PC(0), PC(0.5), FRONT — the cone-local family — produce exactly zero).
Verdict per the pre-fixed table: generic byproduct; the
"conemass-as-validity-check-for-synthetic-corpora" idea is dead. The
descriptive inversion: cone-local draws weld concentration rank to
volume rank at the head; global draws open the gap. The retrodictive
facts about real corpora are untouched.

**Files.**
- `SPEC.md` — registered spec + two dated postscripts (audit; B′/C).
- `sim-lib.mjs` — growers (U, PA, PC(β)) + the shared Debian-grade estimator.
- `01-explore.mjs` / `results-explore.json` — exploratory grid (single-universe; superseded by replicate designs).
- `01b-calibrate.mjs` / `results-calibrate.json` — the replicate calibration that found the null failure.
- `01c-validate-clustered-null.mjs` — kernel-clustered flips tested and found insufficient.
- `02-confirm.mjs` / `results-confirm.json` — registered Phase B′; verdicts in the postscript.
- `THEORY.md` — Phase C (flux law; sign conjecture now marked dead by measurement).
- `SPEC-D.md` — Phase D spec (candidate rules, honesty clauses).
- `03-sign.mjs` / `results-sign.json` — registered sign measurement (S1 confirms, S2/S3 kill the conjecture).
- `04-explore-d.mjs` / `results-explore-d.json` — exploratory search; nothing graduates.
- `06-signature.mjs` / `results-signature.json` — Phase E discriminator: registered kill (generic byproduct) + the cone-local inversion.
- `05-oracle.mjs` / `results-oracle.json` — the oracle test: **mechanism fully identified.** The cell's battery-transcending signal in PC(0) is harmonic cone-membership mass, ORACLE(x) = Σ 1/|cone(u)| over cones containing x (O2: with ORACLE matched, Δ_ER = −0.004, t = −0.25). Exact uncapped descendant counts do *not* close it (O3, t = −7.0): the structure is concentration of reach, not volume. ORACLE is a pure graph feature → battery v3 is defined for the field.
