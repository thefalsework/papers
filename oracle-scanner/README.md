# Oracle scanner — concentration-of-reach as a supply-chain metric

**Use it now:** `node oracle-rank.mjs <your-graph> --top 100` — a
self-contained, zero-dependency CLI that ranks any dependency graph
(edge-list CSV or JSON; cycles handled) in seconds. Published dated
rankings for Debian trixie (2025) and crates.io (2022) are in
`rankings/`. The writeup for a security audience is
`preprints/quiet-criticality/paper.md`.

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

**Cap sweep: robust.** liblzma5 is #8 at every cone cap from 50 to 800;
top-100 overlap 0.92–0.99 between adjacent caps. The headline is not a
truncation artifact.

**Second ecosystem (crates.io 2022): replicates, starker.**
**unicode-ident — ORACLE #2 of 84,439, in-degree #3,582** (six direct
dependents): the canonical quiet single-maintainer crate inside every
Rust build, invisible to volume metrics. Head of ranking = the macro
toolchain nobody types (libc #1, proc-macro2 #3, quote #4, syn #5). The
divergence list is a threat class, not noise: deg-1 proc-macro companion
crates (openssl-macros, wasm-bindgen-macro, …) — arbitrary code
execution at build time, one direct dependent, inside everything,
unseen by dependent-count scoring.

**The incumbent test: one-sided.** Joined against the OpenSSF
criticality-score top-1000 (June-2022 vintage — matches the crates
snapshot, pre-dates the xz backdoor). Of the crates ORACLE top-10,
**one** appears in the incumbent's 1000 (libc, #257): serde absent,
zlib absent, syn/proc-macro2/quote/unicode-ident absent, the deg-1
proc-macro threat class 0-for-7. xz itself was not on GitHub in 2022 —
structurally invisible to the GitHub-only pipeline at any rank. The
Pike score measures fame-and-activity; ORACLE measures load. The pitch
with receipts: the incumbent's list contains kubernetes and misses
zlib.

**Honest limits.** Descriptive, unscored; global rank correlation with
volume metrics is high (0.95–0.99) — the new information lives at the
head of the ranking, which is where prioritization decisions are made.
The incumbent join uses the v1-era list (the v2 all.csv bucket is dead:
billing disabled); mappings hand-curated; one-directional test.

**Files.**
- `01-xz-retrodiction.mjs` / `xz-retrodiction.json` — the pilot; expectations in header, verdict in postscript.
- `02-cap-sweep.mjs` / `cap-sweep.json` — truncation robustness.
- `03-crates.mjs` / `crates.json` — open-registry replication; verdict in postscript.
- `04-incumbent.mjs` / `incumbent.json` / `ossf-top1000.csv` — the incumbent join; verdict in postscript.
- `oracle-rank.mjs` — the standalone CLI (usage in file header).
- `rankings/` — published dated top-1000 rankings (Debian 2025, crates 2022).
