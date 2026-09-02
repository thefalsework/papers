# The Seedbed Claim: A Pre-Registered Growth Effect in the Debian Archive, and the Adversarial Program That Failed to Kill It

**Author.** Chris Brink (independent)
**Version.** Draft v0.1, 2026-09-01. Written the day the result reached its
final form. Primary sources are the study folders cited per-claim
(`software-study/`, `deflation-control/`, `baseline-gauntlet/`,
`debian-study/`, `accretion-study/`, `battery-v2/`, `battery-v3/`), each
carrying its pre-registrations inline — committed before first run — and its
raw output. This paper contains no new runs: it is the account of record.
**Status discipline.** Every claim carries one of the program's grades:
**[K]** kernel-checked in Lean 4 against Mathlib4 (axiom audits: `propext`,
`Classical.choice`, `Quot.sound` only; no `sorry`); **[C]** classical
mathematics, cited; **[computed]** registered finite computation, single
scored run per registration; **[A]** interpretive, argued not proved;
**[H]** falsifiable and registered, untested; **[O]** open. The grades are
load-bearing.

---

## Abstract

We report one empirical claim and the record of every attempt to destroy it.
**The claim [computed]:** in the Debian archive (ten stable releases,
2007–2025, main/binary-amd64; a dependency is installed, executed code),
membership in the *Exploitation cell* of an algebraically defined partition —
the territory a commitment claims but does not settle, computed from the
dependency graph alone — predicts future dependency growth beyond in-degree,
out-degree, age, exact undirected graph distance, PageRank, k-core,
truncated transitive-dependent count, and harmonic cone-membership mass.
The effect was **sealed as an out-of-sample directional bet before the
corpus was ever measured** and landed on the first try; across three
generations of successively sharper matching batteries its point estimate
did not move (+0.098 → +0.083 → +0.090 mean excess dependents per matched
pair, final form on 229,513 pairs balanced to max |SMD| = 0.0116 over seven
features). **The record:** the same instrument run by the same program
produced three comparable effects in other corpora — crates.io, and two on
the Go standard library — and the program killed all three itself, the
last two with confounds *derived from its own generative theory* rather
than guessed: a replicate-universe audit exposed a program-wide ~10×
variance understatement in within-corpus permutation nulls; a flux law
proved on synthetic accretion models identified truncated
transitive-dependent count and then harmonic cone-mass as the quantities
standard batteries cannot see; each was added to the battery in a sealed
re-run; each killed a Go effect and left Debian unmoved. The registered
directional record across the program is 9 for 26, every miss reported at
the prominence of a hit. Seven mechanism families of synthetic growth were
tested; none produces the Debian ordering, and the one complete synthetic
counterexample is fully explained by a closed-form functional that fails
to explain Debian. What grows Debian's claimed-but-unsettled territory is,
at present, structure no feature we can derive expresses and no rule we
can write produces. We state exactly what would kill the claim, and when.

## 1. The claim, in full

Fix a snapshot of the Debian dependency graph and a *kernel*: a package
whose down-set (transitive dependencies) makes the four-position partition
non-degenerate under the evaluability gate of §2. Relative to that kernel,
every other package occupies exactly one cell: **Infrastructure** (inside
the kernel's down-set), **Refusal** (no dependency path touching it),
**Exploitation** (in the double-negation residue: reachable-relevant
territory the kernel claims but does not contain), or **Distribution**
(straddling the boundary). The cells are computed from the baseline graph
alone; no future information enters.

**Claim [computed]:** pair each Exploitation-cell package with a
Refusal-cell package under the same kernel at *identical* exact undirected
graph distance to the kernel's down-set, matched greedily without
replacement within a 0.5-caliper ball in the z-space of seven features —
log1p in-degree, log1p out-degree, first-seen index, log PageRank
(α = 0.85, depended-upon direction), k-core number, log1p truncated
transitive-dependent count (cap 200), log1p harmonic cone-membership mass
(§6) — with a pre-registered balance gate of max |SMD| ≤ 0.10 per feature.
Over 2,400 kernels across eight biennial baselines (2007–2021, horizon two
releases ≈ four years), the Exploitation member gains, on average, **+0.090
more dependents** than its matched Refusal twin (229,513 pairs; post-match
max |SMD| = 0.0116; conditional sign-flip band ±0.009; `battery-v3/`).
Under the six-feature battery the estimate was +0.083 (237,078 pairs);
under the original five-feature battery, +0.098 (264,330 pairs); the
original run was a sealed out-of-sample bet registered before the corpus
was first scored (`debian-study/03-bet.mjs`). The registered-descriptive
secondary, reported at equal volume: Debian's Distribution cell out-grows
its Exploitation cell at matched everything (−0.158 at v3) — the E-over-R
and E-versus-D axes are independent, and only the first is claimed.

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
§1: **(a) the point estimator is unbiased** — on generators provably blind
to the cells (uniform and preferential attachment), its across-universe
mean is zero, proved for uniform attachment and proved-given-exact-degree
for preferential attachment (`THEORY.md` Props. 1–2 **[C]**-style argument),
and confirmed on fresh seeds at 20 universes per rule [computed];
**(b) within-corpus permutation percentiles understate uncertainty ~10×**
— matched pairs sharing a realized history are correlated at kernel and
universe level; no within-corpus resampling recovers generator-level
variance [computed]. Consequently this paper's percentiles are reported
only as *conditional* statements, and the claim's warrant is provenance:
a sealed directional bet on an untouched corpus, followed by three
generations of sealed re-runs under successively sharper batteries. That
is the strongest form of evidence this method can produce, and the paper
claims no stronger form.

## 3. Provenance: the sequence, with its dead

The claim's credibility is the kill record around it. In order
[all computed, each registration committed before its single scored run]:

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
   table entirely: every Go and crates effect the program ever
   celebrated was caught and explained in-house, the last two by
   same-day theory.

Registered directional record across the program after step 8: **9 for
26**. The graveyard is not overhead; under §2(b)'s reading discipline it
is most of the evidence.

## 4. The result of record

| Battery | Features matched (plus exact distance, within kernel) | Pairs | max SMD | Δ_ER | Conditional band |
|---|---|---|---|---|---|
| v1 (sealed bet) | in, out, age, PageRank, core | 264,330 | 0.0097 | **+0.098** | ±0.015 |
| v2 (+ up-set) | + transitive dependents (cap 200) | 237,078 | 0.0104 | **+0.083** | ±0.012 |
| v3 (+ oracle) | + harmonic cone-mass | 229,513 | 0.0116 | **+0.090** | ±0.009 |

Eight baselines, 2007–2021; horizon two releases; 2,400 evaluable kernels;
gains = horizon in-degree minus baseline in-degree at the package level.
The stability is the finding: each battery generation was added *because
it had just killed another corpus's effect*, and Debian's estimate moved
within noise each time. Secondary, registered-descriptive throughout:
Δ_ED ≈ −0.16 at every battery — in Debian the boundary-straddlers grow
hardest of all, so the certified claim is specifically *shadow-over-
outside*, not *shadow-over-everything*.

## 5. What killed the others (and why that is the method)

Three effects of comparable or larger size died under the same knives that
Debian survived, each caught by the program before any external referee:

- **crates.io** (+15.7 bin-matched): fine-grained popularity inside
  coarse degree bins. Killed by battery v1 at fine grain.
- **Go E-over-R** (+0.22, the program's first directional hit): up-set
  flux — its matched pairs concealed a +0.69 SMD imbalance in
  transitive dependents, unrepairable at any caliper. Killed by the blind
  pre-check of battery v2; reclassified, not merely nulled.
- **Go E-over-D** (+0.152, twice certified): harmonic cone-mass. Killed
  by battery v3 with the pairs agreeing on the oracle pointwise.

The pattern deserves emphasis: **the second and third knives were derived,
not guessed.** The program built generative models, proved what they
reward, extracted the reward functional in closed form, and aimed it at
its own certified results. This is, to our knowledge, an unusual loop:
theory manufactured specifically to assassinate the theory's own best
empirical support — with the survivor earning its standing from the
quality of the assassins.

## 6. The theory contribution: the flux law and the oracle functional

The synthetic laboratory (`accretion-study/`, spec-first throughout)
yields, beyond the audit of §2(b), a mechanism result of independent
interest [computed, with derivations in `THEORY.md`]:

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

**The negative that frames the field result.** Seven mechanism families
(uniform, preferential, cone-local at five mixing levels, co-user,
frontier, mixed) were run replicate-first; every rule with any cone
component orders the cells **R > E > D** — the *inverse* of Debian — and
every diffuse rule orders nothing. No rule yet written produces the field
ordering. The generative problem "what accretion process rewards
claimed-but-unsettled territory?" is, after today, the program's central
open question **[O]**, with three named candidate channels registered for
a future replicate-first tier (territory-anchored deepening, two-platform
straddling, root-protected popularity platforms).

## 7. What is claimed, what is not, and what would kill it

**Claimed.** The §1 statement, at its stated grade: a pre-registered,
sealed-provenance, battery-v3-robust conditional association in one
corpus, with an unbiased estimator and honestly-priced uncertainty.

**Not claimed.** (a) Any percentile as a generator-level probability
(§2b). (b) Any mechanism for Debian — none is known (§6). (c) Transfer
beyond Debian: Go and crates are explained deflations; the proof-corpora
deflate or invert at distance grain; Debian stands alone, and one corpus
is one corpus. (d) The E-versus-D ordering — it reverses in Debian.
(e) Any humanities interpretation of the cells; this paper is
graph-theoretic throughout.

**Declared unmatched features (the next knives, named in advance).**
(i) **Momentum**: the node's own prior-interval gain — the classic
autoregressive control — has never been in any battery generation;
battery v4 should lead with it. (ii) **Relational features**: overlap of
a candidate's up-set with the kernel's territory; region-level recent
growth. (iii) Debian-specific institutional covariates (section/priority
metadata, maintainer counts). A battery-v4 run that dissolves Debian's
effect under any of these kills the claim, and the program commits to
running (i) and reporting the outcome whichever way it falls **[H]**.

**Standing falsifiers with clocks.** The 2028 forward register
(`predictions/REGISTER.md`) scores sealed cell-level growth predictions
on corpus states that do not yet exist — the only fresh randomness a real
corpus provides (§2b). Misses there are misses of this paper's worldview
and will be reported as such.

## 8. Reproducibility

Every scored run in this record executed exactly once, from a registration
committed beforehand; all seeds are constants in the scripts; all raw
outputs are committed beside them. No Lean installation is required for
any result in this paper. The full chain for the headline number is:
`debian-study/01-extract.mjs` (parsing choices fixed in-header) →
`02-census.mjs` (blind) → `03-bet.mjs` (sealed, v1) →
`battery-v2/01-precheck.mjs` (blind) → `02-batteryv2.mjs` (sealed, v2) →
`battery-v3/01-precheck.mjs` (blind) → `02-batteryv3.mjs` (sealed, v3);
the theory chain is `accretion-study/SPEC.md` → `01…05` → `THEORY.md`.
Repository: github.com/thefalsework/papers.

## 9. Coda: why one number sitting still is the story

A matched-pair estimate that holds its value while its matching battery
absorbs, one by one, the exact quantities that destroyed every comparable
result — including a functional that provably and completely explains the
best synthetic counterexample — is behaving the way real structure
behaves. It may still die; §7 names how. But after twenty-six sealed bets,
seventeen self-inflicted kills, one program-wide statistical audit, and a
day in which the theory twice built the weapon and twice fired it at its
own trophies, the surviving sentence is short: **in the one ecosystem bet
on blind, the territory a commitment claims but cannot settle is where
the future grows, and nothing we can derive explains it away.**

**Disclosure.** Drafting was AI-assisted under direction, per the
program's validation architecture; the grades are the author's warrant.
