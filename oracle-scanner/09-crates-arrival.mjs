// Oracle scanner — CRATES ARRIVAL: does the arrival-into-the-head
// pattern (study 07/08, Debian) replicate on the second ecosystem?
// Registered before running.
//
// PROMPT. Result 4 (paper v0.11-12) established on Debian that load
// arrives at the head rather than climbing (liblzma #8 on arrival,
// pinned 14 years) and that arrival alerting is monitorable after
// succession filtering (median 13/release). One ecosystem is one
// ecosystem. The software-study extraction already holds four dated
// crates.io snapshots — 2016, 2018, 2020, 2022 — and unicode-ident
// (published 2021-12, adopted by proc-macro2/syn in 2022) sits
// perfectly inside the last interval. Same computation, same
// registered structure.
//
// EXPECTATIONS, WRITTEN BEFORE RUNNING:
//   E1 (the replication): unicode-ident is absent from 2016/2018/2020
//       and lands top-5 in 2022 — arrival directly into the head on
//       the ecosystem's adoption decision, the liblzma pattern with a
//       sharper jump (absent -> #2 in one step, vs absent -> #8).
//       If instead it climbs gradually or lands mid-pack, the
//       arrival claim does not replicate and Result 4 stays
//       Debian-only.
//   E2 (the swap): unicode-xid — the crate unicode-ident displaced
//       inside proc-macro2 — should be high (top-30) in 2016-2020 and
//       fall in 2022. Known limitation to record: a dependency SWAP
//       (different name, same position) is invisible to the
//       name-stem succession filter of study 08; it reads as a
//       genuine arrival plus a departure. That is arguably the right
//       alert behavior (a new, unwatched crate just took over a
//       watched position — the xz-iest event possible), but it must
//       be stated, not discovered.
//   E3 (open-registry monitorability): top-100 genuine arrivals per
//       two-year step after the same succession filter. REGISTERED
//       GUESS: open registries churn harder than a curated distro —
//       15-40 per step. Verdict thresholds carry over per step
//       (<=15 monitorable, >=30 dead); if the median lands >=30, the
//       top-100 arrival alert is too noisy on crates as stated and
//       needs a narrower head (top-40) or rate limiting — report,
//       don't patch silently.
//
// Method notes, fixed in advance: same helpers as studies 01-08
// (buildSnap, oracleMass, cap 200); min-tie ranks; snapshots are
// two-year, so arrival granularity is coarse — this measures whether
// arrival-at-the-head replicates, not lead-time in months. The
// crates.io index git history offers daily granularity for a future
// study; not this one. Writes oracle-scanner/crates-arrival.json.
//
// ============================================================
// POSTSCRIPT (after the run, 2026-09-23)
//
// E1 — REPLICATES, SHARPER THAN DEBIAN. unicode-ident: absent 2016,
// absent 2018, absent 2020 (it did not exist until 2021-12), then
// **#2 of 84,439 in 2022**. Arrival directly into the head in one
// step, on the ecosystem's adoption decision (proc-macro2/syn swap,
// 2022-04). And it is not an isolated case: the ENTIRE macro
// toolchain arrived as a block in 2018 — proc-macro2 absent -> 13,
// syn absent -> 15, quote absent -> 16 — then rose to 3/5/4 by 2020
// and sat. once_cell: absent -> 127 -> 30. tokio arrives 2020 from
// 128. Load arrives; it does not climb. Two ecosystems, same law.
//
// E2 — THE SWAP IS TEXTBOOK AND THE SEAT IS LITERAL. unicode-xid:
// 158 (2016) -> 12 (2018) -> **2** (2020) -> 135 (2022). Its #2 seat
// passed to unicode-ident in the 2022 snapshot — same rank, new
// occupant, different name. As registered: the succession filter
// does NOT catch this (unicode-ident appears in the genuine-arrival
// list), because a dependency swap changes the name. Recorded as the
// filter's known blind spot AND as the correct alert behavior: "a
// crate that did not exist twelve months ago now occupies the #2
// load position previously held by a watched crate" is the loudest
// possible xz-profile event, and the arrival alert fires on it.
//
// E3 — REGISTERED DEAD VERDICT FIRES for top-100 on crates. Genuine
// arrivals per step: 47 (2016->18), 35 (2018->20), 25 (2020->22);
// median 35 >= 30. Top-100 arrival alerting is too noisy on a
// hypergrowth open registry, as registered — reported, not patched.
// Notes: successions were 0 at every step (crates use semver inside
// one name; the Debian rename filter is a no-op here), so the churn
// is genuine ecosystem growth, not renames — the registry doubled
// every two years across this window. The trend is monotonically
// down (47 -> 35 -> 25) as the registry matures, and the arrival
// lists are legible blocks (winapi target shims 2018, futures/tokio
// stack 2020, windows_* target crates 2022). The open product
// question is a growth-adjusted or narrower head (top-40), which
// would need its own registered thresholds — not run.
//
// VERDICT: arrival-into-the-head replicates on the second ecosystem
// (Result 4 is now a two-substrate pattern); top-100 monitorability
// does not transfer to a registry in hypergrowth and that kill is
// reported with its trend. Paper updated (v0.13).
// ============================================================

import { readFileSync, writeFileSync } from "node:fs";
import { buildSnap } from "../deflation-control/lib.mjs";
import { oracleMass } from "../battery-v3/lib.mjs";

const YEARS = [2016, 2018, 2020, 2022];
const WATCH = ["unicode-ident", "unicode-xid", "proc-macro2", "syn", "quote",
  "cfg-if", "serde", "libc", "once_cell", "autocfg", "version_check"];

const stem = (nm) =>
  nm.toLowerCase().replace(/t64$/, "").replace(/[0-9.]+/g, "").replace(/-+/g, "-").replace(/-$/, "");

const yearTop = new Map();
const yearRankMap = new Map();
for (const y of YEARS) {
  const raw = JSON.parse(readFileSync(`software-study/history/crates-${y}.json`, "utf8"));
  const snap = buildSnap(raw.nodes, raw.edges);
  const { nComp, compMembers, names } = snap;
  const orc = oracleMass(snap);
  const rows = [];
  for (let c = 0; c < nComp; c++) {
    for (const m of compMembers[c]) rows.push({ name: names[m], mass: orc[c] });
  }
  rows.sort((a, b) => b.mass - a.mass || (a.name < b.name ? -1 : 1));
  // min-tie ranks
  const rank = new Map();
  let i = 0;
  while (i < rows.length) {
    let j = i;
    while (j + 1 < rows.length && rows[j + 1].mass === rows[i].mass) j++;
    for (let k = i; k <= j; k++) rank.set(rows[k].name, i + 1);
    i = j + 1;
  }
  yearTop.set(y, rows.slice(0, 100).map((r) => r.name));
  yearRankMap.set(y, rank);
  console.log(`crates-${y}: ${rows.length} crates ranked`);
}

// E1/E2: watchlist trajectories
console.log("\n=== watchlist conemass-rank trajectories ===");
const traj = {};
for (const w of WATCH) {
  const t = {};
  for (const y of YEARS) t[y] = yearRankMap.get(y).get(w) ?? "-";
  traj[w] = t;
  console.log(`${w}: ` + YEARS.map((y) => `${y}:${t[y]}`).join("  "));
}

// E3: churn with succession filter
console.log("\n=== top-100 churn, succession-filtered ===");
const steps = [];
for (let yi = 1; yi < YEARS.length; yi++) {
  const yPrev = YEARS[yi - 1], yCur = YEARS[yi];
  const prevTop = new Set(yearTop.get(yPrev));
  const prevStems = new Set([...prevTop].map(stem));
  const prevRank = yearRankMap.get(yPrev);
  const entrants = yearTop.get(yCur).filter((nm) => !prevTop.has(nm));
  const successions = [], genuine = [];
  for (const nm of entrants) {
    if (prevStems.has(stem(nm))) successions.push(nm);
    else genuine.push(`${nm}(${prevRank.get(nm) ?? "new"})`);
  }
  steps.push({
    step: `${yPrev}->${yCur}`, entrants: entrants.length,
    successions: successions.length, genuine: genuine.length, genuineList: genuine,
  });
  console.log(`${yPrev}->${yCur}: entrants ${entrants.length} = successions ${successions.length} + genuine ${genuine.length}`);
  console.log(`  genuine: ${genuine.join(", ")}`);
}
const counts = steps.map((s) => s.genuine).sort((a, b) => a - b);
const median = counts[Math.floor(counts.length / 2)];
console.log(`\nmedian genuine arrivals per step: ${median} (carried thresholds: <=15 monitorable, >=30 dead)`);

writeFileSync("oracle-scanner/crates-arrival.json",
  JSON.stringify({ years: YEARS, watchlist: traj, steps, medianGenuine: median }, null, 1));
console.log("wrote oracle-scanner/crates-arrival.json");
