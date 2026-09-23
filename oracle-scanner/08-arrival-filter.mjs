// Oracle scanner — ARRIVAL FILTER: the succession-filtered rerun of
// study 07's churn cell. Registered before running.
//
// PROMPT. Study 07 (drift) found median 23 top-100 entrants per Debian
// release — the registered grey zone (<=15 monitorable, >=30 dead) —
// and observed that the entrant lists are dominated by mechanical
// version successions (gcc-4.3-base -> gcc-4.4-base, libicu57 ->
// libicu63, python3.7 -> python3.9, the 2025 t64 ABI renames). This
// study applies a name-succession filter and re-counts. The thresholds
// CARRY OVER from 07 unchanged, now applied to the filtered count.
//
// FILTER, FIXED BEFORE RUNNING: normalize a package name by (a)
// stripping a trailing "t64", (b) deleting all digits and dots, (c)
// collapsing the hyphens this leaves behind. An entrant to the top-100
// is a SUCCESSION if its normalized stem matches the normalized stem
// of any package in the previous release's top-100; otherwise it is a
// GENUINE ARRIVAL. (So libssl3 succeeds libssl1.1; liblzma5 succeeds
// liblzma2; but liblzma2 in 2011 is genuine — no liblzma* stem was in
// the 2009 top-100.)
//
// EXPECTATIONS, WRITTEN BEFORE RUNNING:
//   E1: median GENUINE arrivals per release lands at 5-8. Verdict by
//       carried-over thresholds: <=15 -> arrival alerting is
//       monitorable and the product cell closes affirmatively;
//       >=30 -> the filter does not rescue it, drift/arrival dies as
//       a product.
//   E2: the genuine-arrival lists should contain the known cases with
//       correct dates — liblzma2 (2011), liblz4-1 (2017), libzstd1
//       (2019), libkeyutils1 (2009), the krb5 stack (2011) — and
//       should read as legible infrastructure arrivals, not filter
//       leakage. Spot-check every liblzma/lz4/zstd/keyutils row.
//   E3 (filter honesty): report what the filter removed, sampled, so
//       over-aggressive normalization is visible (risk: distinct
//       packages sharing a stem being wrongly merged, e.g. libgcc-s1
//       vs libgcc1 — acceptable; python2 vs python3 merging — also a
//       succession in the relevant sense; note anything that looks
//       wrong).
//
// Writes oracle-scanner/arrival-filter.json.
//
// ============================================================
// POSTSCRIPT (after the run, 2026-09-23)
//
// E1 — VERDICT FIRES: MONITORABLE. Median 13 genuine arrivals per
// release (range 8-19 across nine steps), under the carried-over
// <=15 threshold. The 5-8 guess was too optimistic; the registered
// verdict cell is what matters and it closes affirmatively. For a
// whole OS distribution on a two-year cadence, ~13 rows per release
// (~6-7 per year) is a triage queue one person clears in an
// afternoon.
//
// E2 — ALL KNOWN CASES CONFIRMED AT THEIR DATES. liblzma2 genuine in
// 2011 (with xz-utils); liblzma5 correctly absorbed as its
// succession in 2013 (arrival credited once); liblz4-1 genuine 2017
// (from 1,482); libzstd1 genuine 2019 (from 1,243); libkeyutils1
// genuine 2009 (from 994 — study 07 printed 989 under min-tie
// ranking, this script uses first-occurrence position; same package,
// tie convention); krb5 stack genuine 2011, and the filter even
// catches the libkrb53 -> libkrb5-3 rename as a succession, which is
// exactly the hard case it was built for.
//
// E3 — filter honesty: succession samples all read as true version
// walks; no wrong merges spotted. Two soft notes: (a) re-entries
// count as arrivals (libgomp1 appears twice after dropping out of
// the top-100) — defensible, an operator would want the re-alert;
// (b) the genuine lists still carry payload-implausible rows (doc
// and font packages: openjdk-7-doc, ttf-dejavu) — the
// payload-plausibility filter remains a product question, flagged
// since study 01, not a metric question.
//
// VERDICT: the arrival-alert product cell is closed and affirmative.
// Alert = new stem enters the conemass top-100. Volume ~13/release.
// The alert would have fired on the entire compression class and the
// Kerberos stack years before any incident. Paper Result 4 updated
// with the measured number (v0.12).
// ============================================================

import { readFileSync, writeFileSync } from "node:fs";
import { buildSnap } from "../deflation-control/lib.mjs";
import { oracleMass } from "../battery-v3/lib.mjs";

const YEARS = [2007, 2009, 2011, 2013, 2015, 2017, 2019, 2021, 2023, 2025];

const stem = (nm) =>
  nm.toLowerCase()
    .replace(/t64$/, "")
    .replace(/[0-9.]+/g, "")
    .replace(/-+/g, "-")
    .replace(/-$/, "");

// per year: ordered top-100 names + full rank map
const yearTop = new Map();
const yearRankMap = new Map();
for (const y of YEARS) {
  const raw = JSON.parse(readFileSync(`debian-study/history/${y}.json`, "utf8"));
  const snap = buildSnap(raw.nodes, raw.edges);
  const { nComp, compMembers, names } = snap;
  const orc = oracleMass(snap);
  const rows = [];
  for (let c = 0; c < nComp; c++) {
    for (const m of compMembers[c]) rows.push({ name: names[m], mass: orc[c] });
  }
  rows.sort((a, b) => b.mass - a.mass || (a.name < b.name ? -1 : 1));
  yearTop.set(y, rows.slice(0, 100).map((r) => r.name));
  const rank = new Map();
  rows.forEach((r, i) => { if (!rank.has(r.name)) rank.set(r.name, i + 1); });
  yearRankMap.set(y, rank);
  console.log(`${y}: ranked ${rows.length}`);
}

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
    step: `${yPrev}->${yCur}`,
    entrants: entrants.length,
    successions: successions.length,
    genuine: genuine.length,
    genuineList: genuine,
    successionSample: successions.slice(0, 8),
  });
  console.log(`\n${yPrev}->${yCur}: entrants ${entrants.length} = successions ${successions.length} + genuine ${genuine.length}`);
  console.log(`  genuine: ${genuine.join(", ") || "(none)"}`);
  console.log(`  succession sample: ${successions.slice(0, 8).join(", ")}`);
}

const counts = steps.map((s) => s.genuine).sort((a, b) => a - b);
const median = counts[Math.floor(counts.length / 2)];
console.log(`\nmedian GENUINE arrivals per release: ${median}`);
console.log(`carried-over thresholds: <=15 monitorable, >=30 dead`);

writeFileSync("oracle-scanner/arrival-filter.json",
  JSON.stringify({ steps, medianGenuine: median }, null, 1));
console.log("wrote oracle-scanner/arrival-filter.json");
