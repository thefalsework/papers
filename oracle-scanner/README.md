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

**Honest limits.** Descriptive, unscored; global rank correlation with
volume metrics is high (0.95–0.99) — the new information lives at the
head of the ranking, which is where prioritization decisions are made.
Remaining named measurable: join against published OpenSSF criticality
scores (the direct incumbent test).

**Files.**
- `01-xz-retrodiction.mjs` / `xz-retrodiction.json` — the pilot; expectations in header, verdict in postscript.
- `02-cap-sweep.mjs` / `cap-sweep.json` — truncation robustness.
- `03-crates.mjs` / `crates.json` — open-registry replication; verdict in postscript.
