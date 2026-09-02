# Battery v4 — momentum, the reviewer's first question

**Question.** The seedbed paper declared momentum (a node's own
prior-interval in-degree gain — the standard autoregressive control in
growth prediction) as its lead unmatched feature and committed to running
it before submission. This folder resolves that commitment.

**Verdict: HOLDS.** Δ_ER = +0.083 on 203,437 pairs, all eight SMDs
≤ 0.0117. The seven-feature bridge on identical baselines reads +0.081,
so momentum's marginal effect on the estimate is +0.002 — nothing. The
blind pre-check had found momentum nearly balanced in the prior pairs and
slightly *against* E (signed SMD −0.024). Four battery generations:
+0.098 → +0.083 → +0.090 → +0.083. Record after this study: 10 for 27.

**Design note.** Baselines shift to 2009–2021 (2007 has no predecessor
snapshot); momentum is baseline-measurable only; the bridge column
separates "momentum moved it" from "dropping 2007 moved it" (it was the
latter, and barely).

**Files.**
- `01-precheck.mjs` / `precheck.json` — blind balance/feasibility + momentum imbalance audit.
- `02-batteryv4.mjs` / `results.json` — the registered run; verdict in postscript.
