# Closure of the independent review

Closure pass on commit `b2c07013ecf8ebda3f7e72c6db12cba5e0d202cd`
("Resolve the independent review before any main-run data"), checked
against `REVIEW.md` (22 items) and the postscript "Resolutions of the
independent review", items A-I (`SPEC.md` lines 508-547). Files read:
`SPEC.md` postscript, `07-embed-zones.py`, `08-analysis.py`, `09-seeds.py`,
`tests/test_analysis.py`, `tests/test_checks.py`, and the `af366a5..b2c0701`
diff of `06-conditions.py`, `ipl/conditions.py`, `tests/test_batching.py`.
`out/crosscheck.json` was checked for the keys the new K-check
certification reads (`n_valid` 1000, `n_invalid` 1000, `agree_all` true,
`disagreements` []), so the certification will pass on the real file.
Nothing was modified except the creation of this file.

## Test runs

- `python tests/test_analysis.py`: 52 checks, 0 failures (run here).
- `python tests/test_checks.py`: 21 checks, 0 failures (run here; the
  commit message says 20).
- `tests/test_batching.py`: not run (loads a model); the authors record 0
  failures on 3 fresh formulas, cited as reported, not verified.

## Item-by-item

1. **CLOSED.** Postscript A makes K-H2 the only H2 decision rule.
   `08-analysis.py:294` (`fired = c1_point <= c4_ci[1]`), `:305`
   (`status` dead/survives), `:306-316` (overall: survives in both, dead
   in both, else embedding-dependent). The `passes` test is gone; the
   difference CI is `diff_ci95_descriptive` (`:304`). Tests: survives in
   both (`test_analysis.py:142-143`), dead in both (`:180`),
   embedding-dependent (`:205`).

2. **CLOSED.** Postscript A removes the pass/kill disagreement flag; the
   verdict dict at `08-analysis.py:315-316` has only `by_embedding`, `H2`,
   `K_H2_fired_by_embedding`. No disagreement state can arise because
   there is one test.

3. **CLOSED.** Postscript B. Gates on the main-run held-out set at
   `08-analysis.py:185-198` (K2 per embedding under both rules with the
   one-rule-only case recorded as rule-dependent; K-agree at primary,
   d = 16). `registered_verdicts` carries `K2_fired`, `K_agree_fired`
   (`:400`) and `H1_status` is "descriptive only (K-agree fired)" when
   K-agree fires (`:401`); `rule_dependent.K2` at `:419`. Tests:
   `test_analysis.py:152-153` (not fired), `:176` (K2 rule-dependent),
   `:204` (K-agree fires, H1 descriptive), `:215` (K2 fires). See new
   finding N1 for K2's consequence on the H1/H2 status fields.

4. **CLOSED.** `09-seeds.py` implements spec lines 195-196:
   `same_direction` (`09-seeds.py:29-33`), per-seed verdict agreement
   (`:51-53`), `claim_eligible` requiring three seeds, same direction and
   "survives" in every seed (`:83-88`). Tests: `test_analysis.py:224-235`
   (agree, one seed reversed, two seeds only, duplicate seeds refused).
   No postscript letter was needed since the rule was already registered.

5. **CLOSED.** Postscript C. `07-embed-zones.py:163-166` embeds every
   parsed C1 sample as `s["tokens"]`, stores `sampled_length` separately
   and sets `term_size` to null for invalid rows; `08-analysis.py:135,
   160-161, 173` accept the null. Tests: `test_checks.py:113-118`.

6. **CLOSED.** Postscript D. `08-analysis.py:266-278` accumulates cell
   fractions per prompt, `:289-290` averages within prompt, `:292-293`
   bootstraps over prompts with equal weight; prompts that satisfy the
   entry rule but share no tertile are counted at `:261, 301-302`. Test:
   `test_analysis.py:144-146`.

7. **CLOSED** by registration. Postscript E registers the adaptive cap
   `min(32, max(12, max C2 size + 2))`; code moved to
   `ipl/conditions.py:c4_size_cap`, used at `06-conditions.py:160`. See
   NOTE (b) below on E's justification sentence.

8. **PARTIAL.** Every decision rule now reaches every state in
   `tests/test_analysis.py`: K1m fired (`:163`), reversed (`:167`), length
   control not robust (`:171`), rule dependence True (`:175-176`), K-H2
   fired in both embeddings (`:180`), entry rule excluding prompts (`:184`),
   U4 vs C4_all distinct with the registered verdict from U4 (`:189-190`),
   H3 null (`:195`) and exterior enrichment (`:200`), K2 fired (`:215`),
   `n_heldout` vs B row count (`:261`), unknown label (`:268`), valid row
   without size (`:275`). Remaining gap, unchanged: the "prompts with many
   outputs don't dominate" property is still not exercised, because the
   synthetic corpus gives every prompt exactly two rows per arm
   (`test_analysis.py:72-83`). Not a decision rule; recorded as a test
   NOTE, not a fix.

9. **CLOSED.** Postscript F. `08-analysis.py:228-232`: K1m is null when
   K1 fired or undefined; otherwise fires if the CI straddles zero or is
   entirely negative, the latter flagged `reversed`. Tests:
   `test_analysis.py:159` (null), `:163` (fired, not reversed), `:167`
   (fired, reversed).

10. **CLOSED.** Postscript G records percentile CI, independent H1 vs
    paired H1m, 10,000 resamples. `08-analysis.py:464-465` refuses
    `--n-boot` for registered profiles (`REGISTERED_PROFILES = ("main",)`,
    `:76`); test `test_analysis.py:238-247`.

11. **CLOSED.** Postscript I. Per-band `n_C2_unique`, `n_C2_novel`,
    `n_C4_all`, `n_C4_novel` at `08-analysis.py:281-284`; tests
    `test_analysis.py:147, 190`.

12. **PARTIAL.** `07-embed-zones.py:176-195` (`run_record`: C3
    `restarts_on_cap`, `exhausted_root`, C4 shortfall by tertile, cap hits,
    C1 counts) is carried into the analysis at `08-analysis.py:441`;
    `heldout_novel_count` at `:442`; `temperature` at `:443`; `C2_all`
    added to kappa, zone fractions and Z_U (`:179, 381`); H3
    `crack_minus_exterior_enrichment` at `:350-351`. Still absent: a
    `C3_all` population (C3's non-novel valid completions have no kappa,
    zone-fraction or Z_U row), and the full nearest-distance distributions
    remain quantiles in the analysis file with the per-row values only in
    the zones file. Descriptive only; NOTE for the paper.

13. **CLOSED.** `rule_dependent.H1_length_control_robust` at
    `08-analysis.py:417`.

14. **CLOSED.** Postscript A defines the state: embedding-dependent means
    "neither survives nor dead"; `08-analysis.py:313-314`; test
    `test_analysis.py:205`.

15. **CLOSED.** Postscript H defines "narrowly" (0.02). `08-analysis.py:121-122`
    (`near`), `:421-436` (H1 lower bound, H1m either bound, K-H2 C4 upper
    vs C1 point, K2 crack fraction under each rule; `recommended` false on
    a 1,024-sample file, `is_rerun` true). `07-embed-zones.py:211, 271`
    add `--n-mc`; `08-analysis.py:455, 460` route the `-mc1024` file.
    Tests `test_analysis.py:219-221`.

16. **CLOSED** as recorded. Postscript G names the 20-step bisection;
    `07-embed-zones.py:291-292` writes the calibration description into
    the zones file. The E2 zero-LOO-distance remark stays data-dependent
    and descriptive; radii are reported per rule and d.

17. **CLOSED.** `ipl/conditions.py:assert_train_eta_long` (every stored
    training proof parses, checks against its formula, and equals its own
    eta-long form); called at `07-embed-zones.py:98`, certified as
    `train_eta_long_checked` and required by `08-analysis.py:151-152`.
    Tests `test_checks.py:137-150` (not a proof; valid but not eta-long),
    `test_analysis.py:266`.

18. **CLOSED.** Postscript G records linear-interpolation quantiles with
    `<=` edges.

19. **CLOSED.** `ipl/conditions.py:conditions_name` gives
    `conditions-<profile>-seed<k>-T<temp>`; used by `06-conditions.py:230`,
    `07-embed-zones.py:219-223` (which also asserts the file's temperature
    matches `--temperature`), `08-analysis.py:461, 471`;
    `09-seeds.py:98, 103` take `--temperature`. Temperature is recorded in
    the zones (`07:288`) and analysis (`08:443`) files.

20. **CLOSED.** K-check certification from `out/crosscheck.json`
    (`07-embed-zones.py:79-84`: `agree_all`, 2,000 terms, no
    disagreements) and minimum competence on C1 test-prompt samples
    (`:86-91`, 20%); both required by `08-analysis.py:147-150`.
    Recorded-invalid parsed samples are re-checked to fail
    (`07-embed-zones.py:149-151`). Tests `test_checks.py:132-135, 172`,
    `test_analysis.py:264-265`.

21. **CLOSED** (batching part as reported). `tests/test_batching.py` now
    runs C3 against the real training-term set and checks novelty flags,
    and runs C4 enumeration plus seeded matching twice and in reverse
    prompt order (diff hunks at `+71-85`, `+98-116`). Authors report 0
    failures on 3 fresh formulas. `07`'s halting checks are factored into
    `check_conditions`/`build_rows` and tested without a model in
    `tests/test_checks.py` (21 checks, run here).

22. **CLOSED.** No change was required; Z_U unchanged at
    `08-analysis.py:386-388`, now also for `C2_all`.

## New finding

**N1. BLOCKER. K2's consequence is not applied to the status fields or to
claim eligibility.** Spec line 316 gives K2's consequence as "Zones
unmeasurable; stop"; postscript B evaluates K2 on the main run but states
a status consequence only for K-agree. In code, `K2_fired` is emitted
(`08-analysis.py:400`) but `H1_status` (`:401`) is gated on K-agree only
and the H2 verdict (`:406`) on nothing, so a run with `K2_fired: True`
still reads `H1_status: "survives"` and `H2: "survives"`.
`09-seeds.py:83-88` then sets `claim_eligible.H1`/`H2` true from those
fields without consulting `gates.K2_fired_by_seed` (`:79`), so three seeds
with K2 fired in every one would be reported claim-eligible. This is a
registered rule with no code path in the verdict block. Fix is small: gate
`H1_status` and the H2 overall verdict on `K2_fired` ("unmeasurable (K2)"),
and require `not K2_fired` in every seed in `claim_eligible`; add the K2
state to postscript B. Probability of the state is low after the
feasibility pass, but the block must not emit "survives" in it.

## Notes for the paper (not fixes)

(a) `H1_status` at `08-analysis.py:401` reads "survives" when `K1_fired`
is `None` (H1 has no data: no C3 novel output on any prompt). Every other
H1 field is null in that state, so no claim could be written from it, but
`None` would be the honest label.

(b) Postscript E's justification, "proofs larger than anything C2 produced
plus two, which tertile matching never selects", is not exact: the top
tertile is open-ended (size > hi), so larger enumerated proofs would be
eligible there and the cap does shape C4's top-band size distribution
(toward C2's sizes). The cap is now registered, so no change; the sentence
should be corrected when quoted.

(c) `09-seeds.py:86-87`: `claim_eligible.H2` requires verdict agreement
and "survives" in every seed but not `H2.same_direction`; spec lines
195-196 speak of direction. Since H2's difference is descriptive under
postscript A, this is consistent, but say so.

(d) `rule_dependent.K1m` (`08-analysis.py:416`) is True whenever the
alternative rule's K1 fired (K1m null) and the primary's did not, which
is K1's rule dependence, not K1m's.

(e) The Monte Carlo rerun trigger (postscript H) has no K-agree clause;
kappa near 0.2 is not a CI bound so H's wording excludes it, although the
Monte Carlo bias also moves kappa. Consistent with H as written.

(f) The two committed mechanics files predate the temperature suffix
(documented at `06-conditions.py:12-13`).

(g) Test coverage gap from item 8 (per-prompt weighting with unequal
output counts) remains.

## Counts

CLOSED 20 (items 1-7, 9-11, 13-22). PARTIAL 2 (items 8, 12). OPEN 0.
New BLOCKER: 1 (N1).
