// Oracle scanner — THE INCUMBENT TEST. Descriptive, unscored.
//
// Incumbent: the OpenSSF criticality score (Pike algorithm), as
// actually consumed — the "1000 critical projects" list used by the
// Securing Critical Projects WG. Artifact:
// oracle-scanner/ossf-top1000.csv, fetched 2026-09-02 from
// naveensrinivasan/scorecard-1000-critical-projects (the official GCS
// bucket's billing is disabled; the list is June-2022 vintage, which
// ALIGNS with our crates-2022 snapshot and PRE-DATES the xz backdoor
// by ~21 months — no post-event attention contaminates the join).
//
// QUESTION. The scanner's claim is that concentration-of-reach flags
// quiet load-bearing packages that volume-based scoring under-ranks.
// The incumbent's inputs are volume and activity signals (stars,
// contributors, mentions, dependent counts). Join: for the watchlist
// and for the ORACLE head of each ecosystem, is the package's repo in
// the incumbent's top-1000 at all, and at what rank?
//
// EXPECTATIONS, WRITTEN FIRST:
//   E1: famous packages (serde, openssl, zlib) present in the top-1000;
//       the quiet load-bearing rows (unicode-ident, the deg-1
//       proc-macro companions) absent or deep — that's the gap the
//       scanner fills. xz's repo was not even ON GitHub in 2022 (it
//       lived at git.tukaani.org), so the GitHub-only incumbent
//       pipeline was STRUCTURALLY blind to the single most consequential
//       supply-chain package of the decade; report this plainly.
//   E2: of our crates ORACLE top-10, expect a minority in the
//       incumbent's 1000; of the deg-1 proc-macro divergence list,
//       expect ~zero.
//
// Repo mappings are hand-curated in-script (crate/package -> GitHub
// repo at 2022); "unmapped" is reported honestly. Writes
// oracle-scanner/incumbent.json.
//
// ============================================================
// POSTSCRIPT (after the run, 2026-09-02)
//
// MORE ONE-SIDED THAN THE EXPECTATION. E1 predicted the famous rows
// present and the quiet rows absent. Actual: of the crates ORACLE
// top-10, ONE is in the incumbent's top-1000 (libc, #257). Not just
// unicode-ident/syn/proc-macro2 absent — **serde is absent. zlib is
// absent.** The most embedded compression library on earth and the
// de-facto Rust serialization standard do not appear in the
// incumbent's 1000 most critical projects, while the list's head is
// linux/git/node/kubernetes — big, famous, active APPLICATIONS. The
// deg-1 proc-macro threat class: 0 of 7 present (E2 confirmed). xz:
// not on GitHub in 2022, hence STRUCTURALLY invisible to the
// GitHub-only pipeline — the single most consequential supply-chain
// package of the decade could not have appeared at any rank.
//
// READING: the Pike score weights activity, contributors, stars,
// mentions — social visibility and busyness. Quiet finished
// infrastructure (zlib: one maintainer, low commit frequency, done)
// scores near zero on every input; that is precisely the xz profile
// the post-mortems flagged, and precisely what harmonic concentration
// measures instead. The two metrics are not rivals on one axis; they
// measure fame-and-activity vs load. The scanner's pitch sentence,
// now with receipts: the incumbent's top-1000 contains kubernetes
// and misses zlib; ORACLE's top-10 IS zlib's profile, ecosystem by
// ecosystem.
//
// CAVEATS, honestly: June-2022 v1-era list (mention-count heavy,
// deps.dev integration partial); the v2 all.csv would be the fairer
// join and its bucket is currently dead (billing disabled); mappings
// hand-curated; one-directional test (ORACLE head vs incumbent
// membership — cross-ecosystem rank comparison is not meaningful).
// ============================================================

import { readFileSync, writeFileSync } from "node:fs";
import { buildSnap } from "../deflation-control/lib.mjs";
import { oracleMass } from "../battery-v3/lib.mjs";

// --- incumbent list ---
const csv = readFileSync("oracle-scanner/ossf-top1000.csv", "utf8").split("\n").filter((l) => l.trim());
const header = csv[0].split(",");
const urlCol = header.indexOf("repo.url"), scoreCol = header.indexOf("original_pike_score");
const incumbent = new Map(); // "owner/repo" (lowercase) -> { rank, score }
for (let i = 1; i < csv.length; i++) {
  const cells = csv[i].split(",");
  const m = cells[urlCol]?.match(/github\.com\/([^,\s]+)/i);
  if (!m) continue;
  incumbent.set(m[1].toLowerCase(), { rank: i, score: +cells[scoreCol] });
}
console.log(`incumbent list: ${incumbent.size} repos`);

// --- crate/package -> repo mapping (2022-era homes), hand-curated ---
const REPO = {
  // crates
  "libc": "rust-lang/libc", "unicode-ident": "dtolnay/unicode-ident",
  "proc-macro2": "dtolnay/proc-macro2", "quote": "dtolnay/quote",
  "syn": "dtolnay/syn", "cfg-if": "alexcrichton/cfg-if",
  "serde": "serde-rs/serde", "serde_derive": "serde-rs/serde",
  "lazy_static": "rust-lang-nursery/lazy-static.rs",
  "rand": "rust-random/rand", "memchr": "BurntSushi/memchr",
  "once_cell": "matklad/once_cell", "autocfg": "cuviper/autocfg",
  "version_check": "SergioBenitez/version_check",
  "bitflags": "bitflags/bitflags", "log": "rust-lang/log",
  "itoa": "dtolnay/itoa", "ryu": "dtolnay/ryu",
  "getrandom": "rust-random/getrandom", "num-traits": "rust-num/num-traits",
  "hashbrown": "rust-lang/hashbrown", "indexmap": "bluss/indexmap",
  "smallvec": "servo/rust-smallvec", "rand_core": "rust-random/rand",
  "scopeguard": "bluss/scopeguard", "either": "bluss/either",
  "wasm-bindgen-macro": "rustwasm/wasm-bindgen",
  "openssl-macros": "sfackler/rust-openssl",
  "pin-project-internal": "taiki-e/pin-project",
  "minimal-lexical": "Alexhuszagh/minimal-lexical",
  "proc-macro-error-attr": "TedDriggs/proc-macro-error",
  "want": "seanmonstar/want", "darling_macro": "TedDriggs/darling",
  // debian
  "liblzma5": null, "xz-utils": null, // git.tukaani.org in 2022 — not on GitHub
  "zlib1g": "madler/zlib", "libssl3": "openssl/openssl",
  "libexpat1": "libexpat/libexpat", "libxml2": "GNOME/libxml2",
  "libgcrypt20": null, // git.gnupg.org — not on GitHub
};
const lookup = (pkg) => {
  const repo = REPO[pkg];
  if (repo === null) return { repo: "NOT ON GITHUB", inTop1000: false, structurallyInvisible: true };
  if (!repo) return { repo: "unmapped", inTop1000: null };
  const hit = incumbent.get(repo.toLowerCase());
  return hit ? { repo, inTop1000: true, incumbentRank: hit.rank, pike: hit.score }
             : { repo, inTop1000: false };
};

// --- crates ORACLE head (recomputed, same as 03) ---
const raw = JSON.parse(readFileSync("software-study/history/crates-2022.json", "utf8"));
const snap = buildSnap(raw.nodes, raw.edges);
const { nComp, compMembers, names, inDeg } = snap;
const orc = oracleMass(snap);
const pkgs = [];
for (let c = 0; c < nComp; c++)
  for (const m of compMembers[c]) pkgs.push({ name: names[m], inDeg: inDeg.get(names[m]) ?? 0, oracle: orc[c] });
pkgs.sort((a, b) => b.oracle - a.oracle);
const oracleTop10 = pkgs.slice(0, 10).map((p, i) => ({ oracleRank: i + 1, name: p.name, inDeg: p.inDeg, ...lookup(p.name) }));

const WATCH_CRATES = ["unicode-ident", "proc-macro2", "syn", "cfg-if", "memchr", "once_cell", "serde", "libc"];
const THREAT = ["minimal-lexical", "proc-macro-error-attr", "wasm-bindgen-macro", "want", "darling_macro", "openssl-macros", "pin-project-internal"];
const WATCH_DEBIAN = ["liblzma5", "xz-utils", "zlib1g", "libssl3", "libexpat1", "libxml2", "libgcrypt20"];

const report = (label, rows) => {
  console.log(`\n${label}:`);
  for (const r of rows) {
    const inc = r.structurallyInvisible ? "NOT ON GITHUB (structurally invisible to incumbent)"
      : r.inTop1000 === null ? "unmapped"
      : r.inTop1000 ? `incumbent #${r.incumbentRank} (pike ${r.pike})` : "ABSENT from top-1000";
    console.log(`  ${r.name ?? r.pkg}${r.oracleRank ? ` (oracle #${r.oracleRank})` : ""} -> ${r.repo}: ${inc}`);
  }
};

const watchCrates = WATCH_CRATES.map((p) => ({ pkg: p, name: p, ...lookup(p) }));
const threatRows = THREAT.map((p) => ({ pkg: p, name: p, ...lookup(p) }));
const watchDebian = WATCH_DEBIAN.map((p) => ({ pkg: p, name: p, ...lookup(p) }));

report("crates ORACLE top-10 vs incumbent top-1000", oracleTop10);
report("crates watchlist", watchCrates);
report("deg-1 proc-macro threat class", threatRows);
report("debian watchlist", watchDebian);

writeFileSync("oracle-scanner/incumbent.json",
  JSON.stringify({ incumbentSize: incumbent.size, oracleTop10, watchCrates, threatRows, watchDebian }, null, 1));
console.log("\nwrote oracle-scanner/incumbent.json");
