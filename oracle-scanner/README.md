# Oracle scanner — concentration-of-reach as a supply-chain metric

**Idea.** ORACLE(x) = Σ 1/|cone(u)| over truncated dependency cones
containing x — the flux-law functional from `accretion-study/THEORY.md`,
repurposed with no causal claim attached: not "predicts growth" (that
died; see `preprints/seedbed/paper.md`) but "measures how many small
toolchains a package is a large share of." Volume metrics (dependents,
downloads, PageRank, criticality scores) under-price the quiet
load-bearing profile; harmonic concentration is built to see it.

**Pilot verdict (xz retrodiction, Debian bookworm 2023 — the last
release before CVE-2024-3094): pulse.** liblzma5 ranks **#8 of 63,436
by ORACLE** vs #173 by in-degree (PageRank #36; capped transitive
counts saturate and tie at #700). libgcrypt20: #49 vs #150. libexpat1:
#38 vs #102. Famous packages rank high on everything (zlib1g #4 on
both) — the metrics diverge precisely on the under-recognized. The
divergence list surfaces "gateway plumbing" (in-degree 1, enormous
cone membership: python3-minimal, libpam-modules-bin, libc-dev-bin) —
the exact topology the xz attack exploited via the systemd gateway —
mixed with doc/data noise a product would filter.

**Honest limits.** Descriptive, unscored, one corpus, one retrodiction;
global rank correlation with volume metrics is high (0.95–0.97) — the
new information lives at the head of the ranking, which is where
prioritization decisions are made. Named next measurables: cap
sensitivity; join against actual OpenSSF criticality scores; npm/PyPI
replication.

**Files.**
- `01-xz-retrodiction.mjs` / `xz-retrodiction.json` — the pilot; expectations in header, verdict in postscript.
