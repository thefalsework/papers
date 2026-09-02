# Published ORACLE rankings

Generated 2026-09-02 with `../oracle-rank.mjs` (cone cap 200; rankings
are insensitive to cap 50–800 on these corpora, see `../cap-sweep.json`).

| file | corpus | snapshot | nodes |
|---|---|---|---|
| `debian-trixie-2025-top1000.csv` | Debian main/binary-amd64 | trixie (2025) Packages | 68,750 |
| `crates-2022-top1000.csv` | crates.io | 2022 dependency snapshot | 84,439 |

**Columns.** `oracle_rank` — rank by concentration of reach (ORACLE =
Σ 1/|cone| over truncated dependency cones containing the package);
`oracle` — the raw value; `direct_dependents` — package-level in-degree;
`dependents_rank` — rank by that count. **The rows that matter for
supply-chain triage are those where `oracle_rank` is far ahead of
`dependents_rank`**: quiet packages carrying concentrated load
(the liblzma / unicode-ident profile — see
`preprints/quiet-criticality/paper.md` for validation, including the xz
retrodiction and the comparison against the OpenSSF criticality-score
top-1000).

**Run it on your own graph:**

```
node oracle-rank.mjs Cargo.lock --top 50
node oracle-rank.mjs your-edges.csv --top 100
```

Rust lockfiles are parsed directly; otherwise supply one
`dependent,dependency` pair per line or a JSON graph (see the header of
`oracle-rank.mjs`). No dependencies, one file, cycles handled,
Apache-2.0 (`../LICENSE`). A 100k-node registry takes seconds. Output
is deterministic: the same graph produces byte-identical CSV regardless
of input file ordering (traversal and float accumulation order are
canonicalized by package name).

**Caveats.** Descriptive rankings, not certified claims; one
retrodiction is one retrodiction; ORACLE's head is deliberately
library-heavy (libraries are the attack surface). Known limitation:
packages inside a dependency cycle share a score (SCC condensation).
Ties take the minimum rank; the study scripts behind the paper use
average rank, so tied positions differ between the two (unicode-ident's
dependent-count rank is 3,304 here and 3,582 in the paper — same six
direct dependents, thousands of crates tied at that count; its ORACLE
rank is #2 under both conventions).
