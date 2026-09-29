# Independent review: analysis code against the registered spec

Reviewed 2026-09-29 against `SPEC.md` at HEAD (registration `a04cb9e`;
`git diff a04cb9e -- SPEC.md` shows the body unchanged and two dated
postscripts appended, committed in `4be68e3` and `deb8e57`). Code
reviewed: `07-embed-zones.py`, `08-analysis.py`, `ipl/zones.py`,
`ipl/conditions.py`, `tests/test_analysis.py`, `tests/test_batching.py`,
with `06-conditions.py`, `ipl/features.py`, `ipl/model.py:proof_embedding`
and `02-corpus.py:68-72` read where a claim depended on them. Only
`tests/test_analysis.py` was executed (24/24 pass). Nothing was modified
except the creation of this file.

Severity: BLOCKER = the registered verdict block can emit a verdict the
spec does not derive, or a registered decision rule has no code path.
SHOULD-FIX = a choice the spec does not make, or a gap in reporting or
tests, that should be closed (by code or by dated postscript) before the
main analysis runs. NOTE = a choice worth recording, or a minor gap.

## Findings

1. **BLOCKER. H2's registered verdict is read from a criterion the spec
   does not register.** Spec lines 87-88 state H2; lines 294-295 give
   the statistic ("crack fraction of C1 valid novel outputs minus crack
   fraction of C4, computed within size tertiles, same bootstrap"); the
   only decision rule for H2 in the spec is K-H2 at line 320 ("C1 crack
   fraction not above C4's CI -> H2 dead"). Postscript item 8 (lines
   501-506) says H2 "passes" only if it passes in both embeddings but
   does not define "passes". `08-analysis.py:260` defines
   `passes = diff_ci[0] > 0` and `08-analysis.py:282-284` labels
   `verdict.H2` from that, while `K_H2` is labelled from
   `fired = c1_point <= c4_ci[1]` (`08-analysis.py:261`). These two
   tests are different (paired-difference CI vs. marginal C4 CI) and
   can disagree, giving two verdict states the spec does not define:
   (a) `passes=False, fired=False`: code reports `H2: "fail"`; under the
   spec H2 is simply not killed. (b) `passes=True, fired=True`: code
   reports `H2: "pass"` and `K_H2: "fired"` side by side, with no
   precedence; spec line 322-323 treats a kill as decisive. Before
   main-run data exists, a postscript must say which test is H2's test
   and that K-H2 takes precedence, and `registered_verdicts.H2` must
   then emit one resolved verdict.

2. **SHOULD-FIX. `pass_and_kill_disagree` lumps a contradiction with an
   inconclusive result** (the authors' known item; I agree).
   `08-analysis.py:281` sets `disagree = (pe[e] == fe[e])`, which is
   True both for (pass, fired) and for (fail, not fired). The two mean
   different things (see item 1). The tests check the flag only in the
   consistent case (`tests/test_analysis.py:113`) and in the
   embedding-dependent case where it is False in both embeddings
   (`tests/test_analysis.py:141-144`); neither True path is tested.
   Split into `contradiction` and `inconclusive` per embedding and test
   each.

3. **SHOULD-FIX. K2 and K-agree are not evaluated on the main-run
   held-out set, and K-agree does not gate the H1 verdict.** Spec lines
   316-317 list K2 and K-agree in the kill table without a phase
   restriction; line 317's consequence ("no H1 claim") is about the main
   result; lines 244-247 fix K-agree at the registered d under the
   primary rule. `07-embed-zones.py:183-187` recalibrates both radii on
   the main held-out set with the main model, so the main-run crack
   fraction and kappa are new numbers, not the feasibility ones.
   `08-analysis.py:323-339` computes `kappa["B_all"]` and
   `zone_fractions["B_all"]` (the inputs to both kills) but
   `registered_verdicts` (`08-analysis.py:370-388`) has no
   `K2_fired`, `K_agree_fired`, and `K1_fired`/`H1_diff` are emitted
   regardless of kappa. The alternative reading, that these are
   feasibility-only gates, is supported by spec lines 339 and 416-417
   ("feasibility gates"); if that reading is intended, a postscript
   should say so and the main-run values should still be reported
   against the thresholds as descriptives.

4. **SHOULD-FIX. The per-seed direction rule has no implementation.**
   Spec lines 195-196: "every main result is reported per seed. A claim
   requires the same direction in all three." `08-analysis.py` is
   single-seed (`08-analysis.py:402, 408`); there is no aggregation
   over `analysis-main-seed{0,1,2}.json`. With the reporting rule at
   lines 308-309 (every number from the results JSON), the three-seed
   verdict needs a JSON field.

5. **SHOULD-FIX. H3's population is embedded under two different
   representations.** Spec lines 94-97 and 297-299 define H3 over raw
   C1 samples that parse. `07-embed-zones.py:136-140` embeds valid C1
   samples as their eta-long normal form (`s["key"]`) and invalid ones
   as sampled (`s["tokens"]`). Training proofs are stored eta-long
   (`02-corpus.py:69-71`), so normalisation systematically moves valid
   samples toward the training representation and invalid ones are left
   where they fell; the zone label is then confounded with validity,
   which is exactly what H3 measures. The spec does not fix the
   representation, so this is a code choice; embed all H3 rows as
   sampled (or report both). Related: `07-embed-zones.py:139` stores
   `len(tokens)` in `term_size` for invalid rows, a different measure
   from `term_size(normal_form)` used everywhere else in the same field
   (unused by H3, but it feeds `tertile_of` at `08-analysis.py:156`).

6. **SHOULD-FIX. H2's unit of analysis is the (prompt, tertile) cell,
   not the prompt, and the entry rule is applied per cell.** Spec lines
   275-279: "The unit of analysis is the prompt ... so prompts with many
   outputs don't dominate. A prompt enters a contrast only if every arm
   in it has at least one unique valid novel output."
   `08-analysis.py:227-258` builds cells, intersects prompt sets per
   tertile (`08-analysis.py:233`) and pools cells with equal weight, so
   a prompt with novel outputs in three tertiles on both sides weighs
   three times a prompt with one cell. A prompt that satisfies the spec's
   entry rule but has no tertile in common between C1-novel and C4-novel
   contributes nothing, and that count is not reported. Either average
   cells within prompt first, or register the cell-level rule and
   report the dropped-prompt count.

7. **SHOULD-FIX. C4's enumeration size cap is adaptive, not 32.**
   Postscript item 3 (spec lines 469-472) states "size cap 32".
   `06-conditions.py:161` uses
   `min(32, max(12, max(c2_sizes) + 2))`, so the pool is enumerated only
   up to two above C2's largest output. The value used is recorded in
   the enumeration record (`max_size`), but the postscript describes a
   fixed cap. This shapes the open-ended top tertile's C4 pool. Fix the
   code or amend the postscript.

8. **SHOULD-FIX. Tests do not exercise the failure paths of most
   decision rules.** In `tests/test_analysis.py`: K1m only in its
   not-fired state (line 105); length control only `robust=True` (line
   106); `rule_dependent` only False, and by construction (labels are
   identical across rules, lines 69-70) it cannot be True (line 107);
   K-H2 firing with consistent embeddings (the clean H2 kill path) is
   never produced; the per-prompt entry rule is never exercised because
   every prompt receives two C2, two C3 and two C4 rows, all
   `novel=True` (lines 56-61), so the U2/U3/U4 filters are identities
   and `n_prompts == 300` (lines 104-105) is trivially true; `U4` and
   `C4_all` coincide, so the descriptive path is not distinguished (line
   114 compares the verdict to itself); H3 has no null case and no
   exterior-enrichment check; the "prompts with many outputs don't
   dominate" property is not tested. Halting assertions: five are
   tripped (lines 158-162); `n_heldout != B row count` and the
   unknown-label branch (`08-analysis.py:135, 153`) are not.

9. **SHOULD-FIX. K1m encoding.** `08-analysis.py:201`:
   `K1m_fired = (not k1) and ci23[0] <= 0`. (a) When H1 is dead the flag
   is `False`, which reads as "not fired" rather than "not applicable";
   `rule_dependent.K1m` (`08-analysis.py:385`) can then differ between
   rules only because K1 differed. Emit `None` when K1 fired. (b) Spec
   line 319 fires K1m when H1m's CI "includes zero"; the code also fires
   when the CI is entirely negative (guided less exterior than filtered
   on matched prompts), a distinct finding the spec does not name.
   Reasonable, but it is a choice made in code; record it.

10. **NOTE. Bootstrap choices not in the spec.** Percentile CI
    (`08-analysis.py:89-93`); independent two-sample bootstrap for H1
    (`08-analysis.py:180`) but a paired bootstrap for H1m
    (`08-analysis.py:194-195`) although spec lines 77 and 283 say "same
    test"/"same method"; fixed seed 20260928 with one shared RNG stream
    (`08-analysis.py:67, 157`); `--n-boot` override (`08-analysis.py:398`)
    permits a run at other than the registered 10,000 (spec line 282),
    recorded at `08-analysis.py:389`. All defensible; all should be in
    the postscript.

11. **NOTE. C4 is size-matched to C2-all but compared novel-vs-novel.**
    Matching uses every unique valid C2 output (`06-conditions.py:160,
    166`; spec lines 473-475, as registered) while H2's primary
    comparison restricts both sides to novel outputs (postscript item 8;
    `08-analysis.py:223, 229-230`). The size match is therefore not
    guaranteed for the compared populations, and C4's 400-proof cap in
    increasing size order (`06-conditions.py:42`;
    `ipl/conditions.py:436-438`) biases the pool small, where training
    reuse is likeliest, so C4-novel cells may thin out in the low
    tertiles. Bounded by the within-tertile design; report per-band
    C4-novel counts against C2 counts.

12. **NOTE. "Always reported" (spec lines 301-306) is only partly in the
    analysis JSON.** Nearest-training distances appear as four quantiles
    (`08-analysis.py:361-363`; the full per-row distributions are in the
    zones file only); kappa, zone fractions and Z_U for C2 and C3 are
    computed on the novel subsets only (`08-analysis.py:161-166`), with
    no C2-all/C3-all rows; C4 shortfalls and cap hits, C3
    `exhausted_root` and `restarts_on_cap` are not carried from the
    conditions file (`07-embed-zones.py:96-107` counts only
    `exhausted_root`, and `08-analysis.py` copies none of them); the
    held-out novelty count required by postscript line 421 is only
    implicit in `H1.n_B` vs `H1_B_all_descriptive.n_B`
    (`08-analysis.py:182`); H3's registered expectation (lines 92-93,
    exterior enrichment at least as strong as crack) has no comparison
    field.

13. **NOTE. Rule-dependence flag omits length-control robustness.**
    `08-analysis.py:383-387` flags K1, K1m, H2 and K_H2; robustness is
    reported under both rules (`08-analysis.py:374, 382`) but not
    compared, although spec lines 241-242 apply rule-dependence to any
    conclusion.

14. **NOTE. A further undefined verdict state: H2 and K_H2 both
    "embedding-dependent".** `08-analysis.py:274-278` returns that label
    when one embedding passes/fires and the other does not, per
    postscript item 8. In that state H2 is neither passed nor dead and
    the spec does not say what the postscript may claim.
    `tests/test_analysis.py:141-144` shows this is the expected output
    for a one-embedding effect.

15. **NOTE. The 1,024-sample rerun (spec lines 226-229) has no trigger or
    switch.** "Narrowly" is undefined; `N_MC = 256` is a constant
    (`ipl/zones.py:17`) and `07-embed-zones.py:182` exposes no `n_mc`
    option.

16. **NOTE. Calibration details not in the spec.** Primary rule: 20-step
    bisection with fresh Monte Carlo offsets on each evaluation, returning
    `hi`, so the held-out in-closing fraction is at or just above 50%
    (`ipl/zones.py:98-108`; spec lines 235-238). Alternative rule:
    leave-one-out 90th percentile (`ipl/zones.py:110-111`); training
    pairs that share a term and have identical formula features give
    zero LOO distance in E2, which can pull the E2 alternative radius
    down. Zone RNG seed is `ZONE_SEED + d` shared across calibration and
    labelling (`07-embed-zones.py:182`). All deterministic and
    recorded; record them in the postscript.

17. **NOTE. Novelty reference relies on training proofs being stored as
    eta-long token tuples.** `ipl/conditions.py:55-58` uses the raw
    stored tokens as the reference; `novelty_key` (lines 51-52)
    normalises the candidate. This holds (`02-corpus.py:69-71`) but is
    not asserted in `07-embed-zones.py`, which re-derives novelty for
    every arm (postscript item 5, lines 483-485) without checking the
    reference side is a fixed point of `normal_form`.

18. **NOTE. Tertile method not fixed by the spec.** `np.quantile` with
    linear interpolation and `<=` band edges
    (`ipl/conditions.py:452-459`; `08-analysis.py:106-107`; spec lines
    288-289). Integer sizes with heavy ties can give very unequal bands;
    the analysis does report per-band n, which is enough to see it.

19. **NOTE. Temperature 0.7 sensitivity run (spec lines 261, 263, 455)
    has no distinct output path.** `06-conditions.py:231` names the file
    by profile and seed only; a 0.7 run would overwrite the 1.0 run's
    conditions file, and `07`/`08` do not record temperature in their
    outputs.

20. **NOTE. K-check and minimum competence are not certified in the
    analysis chain.** `08-analysis.py:131-154` checks fingerprint,
    tertiles, budget and label consistency; nothing certifies that the
    Lean cross-check passed (spec line 315) or that the 20% valid-rate
    gate (lines 192-194) was met on test prompts. `07-embed-zones.py:117`
    re-checks recorded-valid rows but not that recorded-invalid parsed
    rows are in fact invalid (H3's population).

21. **NOTE. `tests/test_batching.py` scope.** It checks C1 and C3
    determinism across batch layout and prompt order but not C4's seeded
    matching (`06-conditions.py:165`) and, using an empty training set
    (line 77), does not touch the novelty path. None of
    `07-embed-zones.py`'s halting assertions have a test (they need a
    model).

22. **NOTE. Z_U implementation.** `08-analysis.py:357-359`: scipy U for
    the condition sample, z-scored without tie correction (fine for
    continuous distances), sign convention documented at line 46
    (negative = closer to training than B), computed for every d and
    against both B_novel and B_all. Consistent with Meehan et al. and
    with spec lines 303-306.

## Counts

BLOCKER 1 (item 1). SHOULD-FIX 8 (items 2-9). NOTE 13 (items 10-22).
