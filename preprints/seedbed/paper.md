# A Pre-Registered Growth Effect in the Debian Archive, and the Adversarial Program That Killed It

**Author.** Chris Brink (independent)
**Version.** Draft v0.3, 2026-09-01. v0.1 was written the day the result
reached battery-v3 form and committed to running the momentum control
before submission; v0.2 reported that run (battery v4, sealed, HOLDS) and
retitled; v0.3 reports battery v5 — functional role, the confound any
Debian developer would name first — under which the headline claim
**reversed and died**. The paper's title, abstract, and conclusions are
rewritten accordingly, per the program's standing rule that kills are
reported at the volume of wins, the same day. Primary sources are the
study folders cited per-claim (`software-study/`, `deflation-control/`,
`baseline-gauntlet/`, `debian-study/`, `accretion-study/`, `battery-v2/`
through `battery-v5/`), each carrying its pre-registrations inline —
committed before first run — and its raw output. This paper contains no
new runs: it is the account of record.
**Status discipline.** Every claim carries one of the program's grades:
**[K]** kernel-checked in Lean 4 against Mathlib4 (axiom audits: `propext`,
`Classical.choice`, `Quot.sound` only; no `sorry`); **[C]** classical
mathematics, cited; **[computed]** registered finite computation, single
scored run per registration; **[A]** interpretive, argued not proved;
**[H]** falsifiable and registered, untested; **[O]** open. The grades are
load-bearing.

---

## Abstract

We report the complete life and death of a pre-registered empirical claim,
as a demonstration of an adversarial self-testing method. In the Debian
archive (ten stable releases, 2007–2025), membership in the *Exploitation
cell* of an algebraically defined partition — territory a commitment
claims but does not settle, computed from the dependency graph alone —
appeared to predict future dependency growth beyond in-degree, out-degree,
age, exact graph distance, PageRank, k-core, transitive-dependent count,
harmonic cone-membership mass, and the node's own prior growth [computed].
The direction was sealed as an out-of-sample bet before the corpus was
first measured, landed on the first try, and held through four generations
of successively sharper matching batteries (+0.098 → +0.083 → +0.090 →
+0.083 excess dependents per matched pair). The fifth battery killed it:
stratifying pairs by the archive's own functional-role taxonomy (Section:
libs, devel, doc, …) — metadata no graph feature carries — the effect
**reversed** (−0.076, 79,822 same-section pairs, the cleanest covariate
balance of any generation) [computed]. Blind pre-check had already located
the engine: Exploitation members were 2.4× more library-flavored than
their matched Refusal twins; four batteries had matched everything about a
package except what kind of thing it is. This was the program's fourth
in-house kill — after crates.io (fine-grained popularity) and two Go
effects (confounds derived from the program's own generative theory) — and
it empties the certified-claims table. The registered directional record
is 10 for 28, every miss reported at the prominence of a hit. What
survives is the method: sealed provenance, theory-derived knives, and an
instrument audit that caught a ~10× variance understatement in standard
permutation nulls. We publish the corpse with the same care we would have
published the claim.

## 1. The claim as it stood, and how it died

Fix a snapshot of the Debian dependency graph and a *kernel*: a package
whose down-set (transitive dependencies) makes the four-position partition
non-degenerate under the evaluability gate of §2. Relative to that kernel,
every other package occupies exactly one cell: **Infrastructure** (inside
the kernel's down-set), **Refusal** (no dependency path touching it),
**Exploitation** (in the double-negation residue: reachable-relevant
territory the kernel claims but does not contain), or **Distribution**
(straddling the boundary). The cells are computed from the baseline graph
alone; no future information enters.

**The claim as certified through battery v4 [computed]:** pair each
Exploitation-cell package with a Refusal-cell package under the same
kernel at *identical* exact undirected graph distance to the kernel's
down-set, matched greedily without replacement within a 0.5-caliper ball
in the z-space of eight features — log1p in-degree, log1p out-degree,
first-seen index, log PageRank (α = 0.85, depended-upon direction), k-core
number, log1p truncated transitive-dependent count (cap 200), log1p
harmonic cone-membership mass (§6), and signed-log momentum (the package's
own prior-interval in-degree gain) — with a pre-registered balance gate of
max |SMD| ≤ 0.10 per feature. Over 2,100 kernels across seven biennial
baselines (2009–2021, horizon two releases ≈ four years), the Exploitation
member gained, on average, **+0.083 more dependents** than its matched
Refusal twin (203,437 pairs; post-match max |SMD| = 0.0117;
`battery-v4/`). The original run was a sealed out-of-sample bet registered
before the corpus was first scored (`debian-study/03-bet.mjs`).

**The death [computed].** Battery v5 (`battery-v5/`) added the one
covariate no graph feature expresses: **functional role**, the archive's
own Section taxonomy, as an exact stratum — a pair must agree on kernel,
exact distance, *and* Section, with the full eight-feature caliper battery
inside each stratum. The blind pre-check (structure only, committed before
the run) found the confound live: only 6% of the v4 pairs agreed on
section, and the Exploitation side was 2.4× more library-flavored
(libs+libdevel+devel share 13.1% vs 5.4%) — the first battery generation
whose pre-check leaned *with* the deflating story rather than against it.
The sealed verdict: **Δ_ER = −0.076** on 79,822 same-section pairs
(conditional band ±0.012; max |SMD| = 0.0095, the cleanest balance of any
generation). Within functional role, Refusal out-grows Exploitation. The
registered-descriptive secondary died with it: Debian's D-over-E ordering
(−0.13 to −0.16 across four generations) collapsed to NULL at role. Both
axes were functional role in costume. Per the interpretation table fixed
in the registration before the run, the claim is dead and the
certified-claims table is empty.

## 2. The instrument

The partition is the aperture program's four-position structure
(`preprints/aperture/paper.md`; partition non-degeneracy iff the kernel is
ordinary **[K]**), computed here on the SCC condensation of each snapshot.
The **evaluability gate** [computed] requires each scored kernel to have
non-empty Exploitation, Refusal, and comparison cells among candidate
members (singleton components alive at horizon); kernels are sampled at
300 per baseline, seeded. **Exact distance stratification:** candidates
are grouped by cell × exact undirected BFS distance to the kernel's
down-set (unreachable is its own stratum), and matching happens only
within a stratum — the skeptic's compression "connected periphery grows"
is matched away exactly, not approximately. Cells, distances, and all
features are functions of the baseline snapshot.

Two facts about the instrument itself, established in the program's
synthetic laboratory (`accretion-study/`) and load-bearing for how to read
this record: **(a) the point estimator is unbiased** — on generators
provably blind to the cells (uniform and preferential attachment), its
across-universe mean is zero, proved for uniform attachment and
proved-given-exact-degree for preferential attachment (`THEORY.md`
Props. 1–2 **[C]**-style argument), and confirmed on fresh seeds at 20
universes per rule [computed]; **(b) within-corpus permutation percentiles
understate uncertainty ~10×** — matched pairs sharing a realized history
are correlated at kernel and universe level; no within-corpus resampling
recovers generator-level variance [computed]. Consequently this paper's
percentiles are reported only as *conditional* statements. Note what the
audit could and could not do: it certified the estimator against
*graph-structural* confounds; it could not see covariates that live
outside the graph, which is exactly where the fatal one lived.

## 3. Provenance: the sequence, with its dead

The record's credibility is the kill record — now including the headline.
In order [all computed, each registration committed before its single
scored run]:

1. **Growth studies (2026-08-26/27).** First signals that
   Exploitation-cell members out-grow degree- and age-matched siblings, on
   Mathlib, Go, and crates.io; AFP reversed. Registered record at the
   time: 1 directional hit in 11.
2. **Deflation control (2026-08-30).** Exact-distance matching added.
   The proof-corpora effects deflated or inverted (Mathlib's E > R was
   connectivity in costume); Go and crates survived loudly.
3. **Baseline gauntlet (2026-08-31).** Full standard battery (fine
   log-degree, out-degree, age, PageRank, k-core). **Crates died** —
   its effect, the largest the instrument ever measured (+15.7 in
   bin-matched form), was fine-grained popularity hiding in coarse degree
   bins. Go survived both contrasts. The registered interpretation table
   named a fresh corpus the tiebreaker.
4. **The Debian bet (2026-08-31).** Extraction choices fixed first;
   blind census; direction sealed; single run. **DB1 landed**: +0.098,
   264,330 pairs. Secondary surprise, reported same day: Debian's D-cell
   out-grows E (the two axes decouple).
5. **The audit (2026-09-01).** The synthetic self-test: on provably
   cell-blind generators the estimator's *point value* is unbiased but
   its sign-flip percentiles are confidently wrong (~10× variance
   understatement; kernel-clustered flips insufficient; the dependence is
   universe-level). Every percentile in the program was reclassified as
   conditional; the reading discipline of §2(b) was adopted; the briefs
   and the synthesis paper were repriced the same day.
6. **Battery v2 (2026-09-01).** The program's flux law (§6) named
   truncated transitive-dependent count as the quantity no standard
   battery carries. Blind pre-check: in the 182 pairs behind Go's
   celebrated E-over-R (+0.22), the E-side carried up-sets **+0.69
   standardized units larger** — the inflation direction — and the
   imbalance is unrepairable at any caliper (51 balanceable pairs, still
   over gate). Sealed outcomes: **Debian held** (+0.083, barely moved);
   **Go's E-over-R was reclassified as up-set-confounded** — on the 51
   near-balanced pairs it reads −1.00, gone and inverted. Go's E-over-D
   survived v2 unchanged (+0.152).
7. **The oracle (2026-09-01).** The lab identified the *complete*
   mechanism of its strongest synthetic counterexample (§6): harmonic
   cone-membership mass. Registered outcomes O1–O3: the functional
   out-predicts capped counts in 10/10 universes; matching it away
   leaves the synthetic effect at t = −0.25 (fully explained); exact
   *uncapped* descendant counts leave t = −7.0 (volume is not the
   structure; concentration is).
8. **Battery v3 (2026-09-01).** The oracle functional — a pure graph
   feature — added to the field battery under sealed registration.
   **Debian held, unmoved** (+0.090; seven SMDs ≤ 0.0116). **Go's
   E-over-D dissolved** (+0.152 → +0.018, NULL; a registered miss,
   scored). Per the pre-registered table, Go exited the certified-claims
   table entirely.
9. **Battery v4 (2026-09-01).** Momentum — the standard autoregressive
   control, and this paper's own declared lead vulnerability in v0.1 —
   added under sealed registration (baselines shift to 2009–2021; a
   seven-feature bridge on identical baselines separates the feature's
   effect from the baseline change). Blind pre-check: momentum nearly
   balanced in the prior pairs, slightly *against* E (signed SMD
   −0.024). **Debian held** (+0.083 vs bridge +0.081: momentum's
   marginal contribution is +0.002).
10. **Battery v5 (2026-09-01).** Functional role, via a supplementary
    extraction of Section metadata with parsing fixed in-header
    (`debian-study/04-sections.mjs`), applied as an exact stratum. Blind
    pre-check: the confound live, leaning with the deflating story
    (E-side 2.4× more library-flavored; 6% section agreement in the v4
    pairs). Sealed verdict: **REVERSES** (−0.076, 79,822 pairs, max
    |SMD| = 0.0095); the descriptive D-over-E axis nulls simultaneously.
    **The Debian claim is dead**, by the program's own hand, under the
    interpretation table committed before the run.

Registered directional record across the program after step 10: **10 for
28**. The graveyard is not overhead; under §2(b)'s reading discipline it
is most of the evidence — and it now holds every effect the program ever
certified.

## 4. The result of record: five batteries, then the floor

| Battery | Features matched (plus exact distance, within kernel) | Pairs | max SMD | Δ_ER | Conditional band |
|---|---|---|---|---|---|
| v1 (sealed bet) | in, out, age, PageRank, core | 264,330 | 0.0097 | **+0.098** | ±0.015 |
| v2 (+ up-set) | + transitive dependents (cap 200) | 237,078 | 0.0104 | **+0.083** | ±0.012 |
| v3 (+ oracle) | + harmonic cone-mass | 229,513 | 0.0116 | **+0.090** | ±0.009 |
| v4 (+ momentum) | + prior-interval gain (baselines 2009–2021) | 203,437 | 0.0117 | **+0.083** | ±0.011 |
| **v5 (+ role)** | **+ exact Section stratum** | **79,822** | **0.0095** | **−0.076** | **±0.012** |

v1–v3: eight baselines 2007–2021, 2,400 evaluable kernels; v4–v5: seven
baselines 2009–2021, 2,100 kernels. Horizon two releases; gains = horizon
in-degree minus baseline in-degree at the package level. The v5 population
is the same-section subpopulation (dominated by doc, javascript, devel,
libdevel, games); per-section estimates, registered-descriptive: doc
+0.015, javascript −0.531, devel −0.270, libdevel −0.048, games −0.021 —
the reversal is broad-based outside doc. The four-generation stability now
reads as what it was: five graph-structural knives and one autoregressive
knife, none of which could see the covariate that mattered, because it is
not a function of the graph. The stability of an estimate under controls
is evidence only about the controls you have.

## 5. What killed the others (and why that is the method)

Four effects — including the headline — died under the program's own
knives, each caught before any external referee:

- **crates.io** (+15.7 bin-matched): fine-grained popularity inside
  coarse degree bins. Killed by battery v1 at fine grain.
- **Go E-over-R** (+0.22, the program's first directional hit): up-set
  flux — its matched pairs concealed a +0.69 SMD imbalance in
  transitive dependents, unrepairable at any caliper. Killed by the blind
  pre-check of battery v2; reclassified, not merely nulled.
- **Go E-over-D** (+0.152, twice certified): harmonic cone-mass. Killed
  by battery v3 with the pairs agreeing on the oracle pointwise.
- **Debian E-over-R** (+0.083, four-battery-robust, sealed-bet
  provenance): functional role. Killed by battery v5 with pairs agreeing
  on kernel, distance, and Section exactly.

The pattern deserves emphasis: **the second and third knives were derived,
not guessed** — the program built generative models, proved what they
reward, extracted the reward functional in closed form, and aimed it at
its own certified results, twice, the same day each functional was
identified. The fourth knife came from outside the graph entirely, which
is its own lesson (§7). We simply describe the loop — generative theory
and institutional metadata manufactured into controls aimed at the
theory's own best empirical support — and let the reader judge its
relation to existing practice (adversarial collaboration,
specification-curve analysis, placebo-outcome designs are the nearest
neighbors we know; none, as far as we can tell, derives its confounds
from a mechanistic model built for the purpose).

## 6. The theory contribution: the flux law and the oracle functional

The synthetic laboratory (`accretion-study/`, spec-first throughout)
yields, beyond the audit of §2(b), a mechanism result of independent
interest [computed, with derivations in `THEORY.md`] — untouched by the
death of the field claim:

**Flux law.** Under cone-local accretion — newcomers pick a platform and
draw dependencies from its truncated down-set (cone) — a node's expected
gain per step is affine in
**ORACLE(x) = Σ_{u : x ∈ cone₂₀₀(u)} 1/|cone₂₀₀(u)|**:
harmonic cone-membership mass, "being a large share of many small
toolchains."

**Mechanism identification.** In PC(0) universes the cell partition beats
the full six-feature battery (Δ_ER ≈ −0.12, |t| = 5.6) — a constructive
proof that an algebraic cell can carry growth signal beyond any standard
battery. Registered tests: ORACLE out-predicts capped descendant count in
10/10 universes (r ≈ 0.44 vs 0.23); with ORACLE matched, the cell effect
is exactly zero (t = −0.25); with exact *uncapped* counts matched instead,
it persists at t = −7.0. The operative structure is **concentration of
reach, not volume** — invisible to every count-style predictor including
PageRank, expressible only with the harmonic weighting.

(The flux law, the oracle functional, and the replicate-first audit
methodology are summarized here at the depth this paper needs; a
standalone methods paper is planned, since a network-science reader
should not have to find these results inside a Debian post-mortem.)

**The generative question closes differently now.** Seven mechanism
families (uniform, preferential, cone-local at five mixing levels,
co-user, frontier, mixed) were run replicate-first; every rule with any
cone component orders the cells **R > E > D** and every diffuse rule
orders nothing. The program spent a day asking what accretion process
could produce Debian's E > R ordering; battery v5 answered it from the
other side — no process needed to, because the ordering was functional
role, not accretion structure. The synthetic negative and the field kill
agree, which is the record resolving the program's central open question
against itself, cleanly.

## 7. What is claimed, what is not, and what died

**Claimed.** (a) The method: sealed provenance, blind pre-checks,
single-run registrations with interpretation tables fixed in advance,
theory-derived confounds, and instrument audits — demonstrated end to end,
including on the program's own headline. (b) The instrument facts of
§2(b) [computed]. (c) The flux law and oracle identification of §6
[computed]. (d) The kill mechanisms of §5, each with its registered
evidence.

**Not claimed — and dead.** The Debian E-over-R growth effect, at any
grade. It survived every graph-structural control the program and its
theory could derive, and reversed under the archive's own role taxonomy.
The E-versus-D ordering died in the same run.

**The lesson, stated plainly [A].** The cells are computed from the graph;
the fatal covariate was not. A package's Section encodes what kind of
artifact it is — and kinds have growth trajectories for institutional
reasons no graph feature expresses. Any future cell-based growth claim,
in any corpus, must carry a functional-role control from its first
battery, not its fifth. The program's synthetic audit certified the
estimator against structural confounds and was silent about
extra-structural ones; that silence was the hole, and it is now a named,
priced item in the method.

**On replication and derivatives.** Had the claim survived, replication
on Ubuntu or any other Debian derivative would **not** have constituted
independent evidence: derivatives import the Debian archive — packages,
dependency structure, and section assignments — nearly wholesale, so a
derivative "replication" is largely the same draw read twice. The same
caution applies in reverse to any future revival attempt: a cell effect
resurfacing in a Debian derivative is the original observation, not a
second one. Independent evidence requires an unrelated ecosystem, and it
now also requires surviving a role control on arrival.

**Standing falsifiers with clocks.** The 2028 forward register
(`predictions/REGISTER.md`) remains sealed and will be scored as written;
after battery v5 the program's own expectation for its Debian prediction
is a miss, and it will be reported as one if so. The register is
immutable; expectations are not.

## 8. Reproducibility

Every scored run in this record executed exactly once, from a registration
committed beforehand; all seeds are constants in the scripts; all raw
outputs are committed beside them. No Lean installation is required for
any result in this paper. The full chain for the headline history is:
`debian-study/01-extract.mjs` (parsing choices fixed in-header) →
`02-census.mjs` (blind) → `03-bet.mjs` (sealed, v1) →
`battery-v2/01-precheck.mjs` (blind) → `02-batteryv2.mjs` (sealed, v2) →
`battery-v3/01-precheck.mjs` (blind) → `02-batteryv3.mjs` (sealed, v3) →
`battery-v4/01-precheck.mjs` (blind) → `02-batteryv4.mjs` (sealed, v4) →
`debian-study/04-sections.mjs` (supplementary extraction, parsing fixed
in-header) → `battery-v5/01-precheck.mjs` (blind) → `02-batteryv5.mjs`
(sealed, v5, the kill); the theory chain is `accretion-study/SPEC.md` →
`01…05` → `THEORY.md`. Repository: github.com/thefalsework/papers.

## 9. Coda: why the corpse is worth a paper

An estimate that sat still through four generations of controls was
either real structure or a confound none of those controls could
express. The program kept sharpening until it found out, and the answer
was the second thing — delivered by a blind pre-check that flagged the
danger before the run, a registration that fixed the kill condition
before the verdict, and a single sealed execution. Nothing about the
sequence changes if you rerun it; everything is committed in order.
After twenty-eight sealed bets, eighteen overrules reported at full
volume, four effects killed in-house including the headline on the eve
of its own submission, one program-wide statistical audit, and a method
that repeatedly manufactured the weapons aimed at its own results, the
surviving sentence is short: **the instrument works, the discipline
works, and the seedbed effect was never real — it was what kind of
package you are, wearing algebra.** A program that can only publish
survivors will publish costumes; this one publishes the unmasking, at
the same volume, the same day.

**Disclosure.** Drafting was AI-assisted under direction, per the
program's validation architecture; the grades are the author's warrant.
