// Oracle scanner — HEAD OVERLAP vs PageRank. Descriptive, registered.
//
// PROMPT. 2026-09-23: a registered conemass run on the Mathlib
// declaration graph (308K nodes) found near-coincidence with PageRank
// (Spearman 0.960, top-40 overlap 21/40 but all plumbing), and a
// post-hoc check on the Prove2Me proof graph found 33/40. The paper's
// package-corpus results report per-package ranks (liblzma5: cm 8 /
// PR 36 / deg 173) but never the head-overlap statistic itself. This
// script computes it on the paper's own two corpora, same helpers,
// same graph construction as 01/03.
//
// QUESTION. Top-40 and top-100 overlap between conemass and PageRank
// (and in-degree, for reference) on Debian bookworm 2023 and crates.io
// 2022. Plus: the divergent rows — conemass head entries PageRank's
// head misses — read by hand.
//
// EXPECTATIONS, WRITTEN BEFORE RUNNING:
//   E1: overlap will be substantially below the proof-graph values
//       (33/40, and 21-but-plumbing) — the ecosystem-graph shape
//       (shallow, many roots, heterogeneous cone sizes) is where the
//       harmonic functional separates from diffusion. Guess: 15-25/40
//       on both corpora.
//   E2 (the salability cell): the conemass-not-PageRank head rows
//       should contain quiet-profile packages (the liblzma/
//       unicode-ident class), not just plumbing variants. If instead
//       the divergent rows are noise or the overlap is >= 30/40, the
//       paper's "complementary at the head" claim weakens to
//       "complementary to fame-based scoring only" and must be
//       restated before anyone else runs this check.
//   E3: liblzma5 itself sits at PR 36 — inside PageRank's top 40 — so
//       the xz case specifically is one PageRank ALSO catches at the
//       head (at 36 vs 8; dependent count at 173 misses entirely).
//       The paper must say this plainly rather than let a reader
//       discover it.
//
// Writes oracle-scanner/head-overlap.json.
//
// ============================================================
// POSTSCRIPT (after the run, 2026-09-23)
//
// E1 — HALF WRONG, and the wrong half is the important result.
// Debian: top-40 overlap with PageRank 22/40 (top-100: 63/100) —
// within the guess. crates: **35/40** (75/100) — far above the
// guessed 15-25, and nearly identical to the Prove2Me proof graph
// (33/40). The "ecosystem graphs separate / proof graphs coincide"
// boundary sketched earlier today is falsified by crates: the
// separation is NOT a package-vs-proof distinction. Measured map so
// far: Debian 22/40, crates 35/40, Prove2Me 33/40, Mathlib 21/40-
// but-all-plumbing (Spearman 0.96). Debian is the outlier where
// conemass finds a head PageRank misses, not the rule. Mechanism
// unmapped; plausibly Debian's layered base-system topology (deep
// shared runtime chains under every leaf) vs the flatter macro-
// toolchain topology of crates.
//
// Against in-degree (dependent count) the head separation is strong
// and consistent everywhere: Debian 12/40 (35/100), crates 19/40
// (47/100). The paper's claims against the incumbent and against
// dependent count stand unchanged.
//
// E2 — split verdict, corpus by corpus. On Debian the divergent rows
// are exactly the quiet class: the Kerberos gateway chain
// (libkrb5support0 PR 263, libk5crypto3 PR 345, libkeyutils1 PR 981,
// libcom-err2 PR 251, all conemass top-30), libgdbm-compat4 (PR 143,
// deg-rank 3,836), libmd0 (PR 47, deg-rank 1,718). libkeyutils1 at
// PageRank 981 and conemass 30 is the single sharpest PageRank-miss
// in the program's record. On crates the divergent rows are 5 mild
// entries (clap_lex PR 59, os_str_bytes PR 65); the "complementary
// at the head vs PageRank" claim is dead on crates and must not be
// implied. vs dependent count it is alive on both corpora.
//
// E3 — CONFIRMED AND SHARPER THAN EXPECTED. liblzma5: PageRank 36
// (inside top-40, vs conemass 8). unicode-ident on crates: PageRank
// **#1** — PageRank sees the paper's headline crates row MORE
// prominently than conemass does (cm 2). The honest sentence for the
// paper: against dependent count the headline rows are invisible
// (173; 3,582); against PageRank they are visible at the head on
// both corpora, and the differentiation vs PageRank is (a) Debian's
// gateway-chain class, (b) determinism/zero parameters/enumerable
// credits, (c) the unlock-mass exactness on AND-graphs — not
// discovery of rows PageRank cannot see.
// ============================================================

import { readFileSync, writeFileSync } from "node:fs";
import { buildSnap } from "../deflation-control/lib.mjs";
import { pagerank } from "../baseline-gauntlet/gauntlet-lib.mjs";
import { oracleMass } from "../battery-v3/lib.mjs";

function study(label, file) {
  const raw = JSON.parse(readFileSync(file, "utf8"));
  const snap = buildSnap(raw.nodes, raw.edges);
  const { nComp, compMembers, names, inDeg } = snap;
  const pr = pagerank(snap);
  const orc = oracleMass(snap);

  const pkgs = [];
  for (let c = 0; c < nComp; c++) {
    for (const m of compMembers[c]) {
      const nm = names[m];
      pkgs.push({ name: nm, inDeg: inDeg.get(nm) ?? 0, pr: pr[c], oracle: orc[c] });
    }
  }
  const n = pkgs.length;
  console.log(`\n===== ${label}: ${n} packages =====`);

  const orderOf = (key) =>
    Array.from({ length: n }, (_, i) => i).sort(
      (a, b) => pkgs[b][key] - pkgs[a][key] || (pkgs[a].name < pkgs[b].name ? -1 : 1));
  const oOr = orderOf("oracle");
  const oPr = orderOf("pr");
  const oIn = orderOf("inDeg");

  const overlap = (a, b, k) => {
    const sa = new Set(a.slice(0, k).map((i) => pkgs[i].name));
    return b.slice(0, k).filter((i) => sa.has(pkgs[i].name)).length;
  };
  const res = {
    corpus: label, n,
    top40_pr: overlap(oOr, oPr, 40), top100_pr: overlap(oOr, oPr, 100),
    top40_in: overlap(oOr, oIn, 40), top100_in: overlap(oOr, oIn, 100),
  };
  console.log(`top-40 overlap conemass vs PageRank:  ${res.top40_pr}/40   top-100: ${res.top100_pr}/100`);
  console.log(`top-40 overlap conemass vs in-degree: ${res.top40_in}/40   top-100: ${res.top100_in}/100`);

  // divergent head rows: conemass top-40 not in PageRank top-40
  const prRank = new Map();
  oPr.forEach((i, k) => prRank.set(pkgs[i].name, k + 1));
  const inRank = new Map();
  oIn.forEach((i, k) => inRank.set(pkgs[i].name, k + 1));
  const prTop = new Set(oPr.slice(0, 40).map((i) => pkgs[i].name));
  const divergent = [];
  console.log(`\nconemass top-40 rows outside PageRank top-40 (${label}):`);
  oOr.slice(0, 40).forEach((i, k) => {
    const nm = pkgs[i].name;
    if (!prTop.has(nm)) {
      divergent.push({ name: nm, cm: k + 1, pr: prRank.get(nm), inDeg: inRank.get(nm) });
      console.log(`  cm ${k + 1} | pr ${prRank.get(nm)} | deg-rank ${inRank.get(nm)} | ${nm}`);
    }
  });
  res.divergent = divergent;
  return res;
}

const out = {
  debian2023: study("Debian bookworm 2023", "debian-study/history/2023.json"),
  crates2022: study("crates.io 2022", "software-study/history/crates-2022.json"),
};
writeFileSync("oracle-scanner/head-overlap.json", JSON.stringify(out, null, 1));
console.log("\nwrote oracle-scanner/head-overlap.json");
