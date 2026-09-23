// Oracle scanner — DRIFT: conemass rank trajectories across ten dated
// Debian stable releases (2007-2025). Registered before running.
//
// PROMPT. The Socket outreach email (2026-09-22) named drift as the
// product-shaped version of conemass: "run it on dated snapshots and
// flag packages climbing the concentration ranking fast, which is the
// xz insertion pattern as a monitorable signal." That sentence is
// currently a hypothesis. The ten dated snapshots it needs are already
// extracted (debian-study/history/2007..2025.json, the corpora of the
// growth studies and Result 1). This study measures whether drift is
// (a) a leading indicator for the xz case specifically, (b) a
// monitorable signal at realistic alert volumes, (c) human-legible.
//
// QUESTIONS AND EXPECTATIONS, WRITTEN BEFORE RUNNING:
//
//   E1 (liblzma timing — the honest one). The xz takeover ran ~2021
//       (first Jia Tan patches) to 2024 (backdoor). But the mechanism
//       that made liblzma reachable from sshd — distros linking sshd
//       against libsystemd, which links liblzma — entered Debian with
//       the systemd transition (jessie, 2015). The attacker chose a
//       package whose load already existed; they did not create the
//       load. REGISTERED GUESS: liblzma5's conemass rank was already
//       top-20 by 2019 at the latest, and shows NO takeover-window
//       climb (no >= 2x rank improvement 2019 -> 2023). If that holds,
//       drift is NOT a leading indicator for the xz case; the leading
//       indicator was static concentration, visible years ahead, and
//       the email's drift framing must be corrected to Socket if the
//       thread continues. If liblzma DID climb 2019->2023, drift is a
//       second retrodiction from a different angle. Either way the
//       result gets reported; the guess is the first one.
//   E2 (monitorability — the product cell). Between adjacent releases,
//       count top-100 new entrants (packages not in the previous
//       release's top-100), split by previous position (climbed from
//       101-250 / 251-1000 / >1000 or absent). REGISTERED THRESHOLDS:
//       median new entrants per release <= 15 -> alert volume is
//       monitorable; >= 30 -> drift alerts are too noisy as a product
//       and the drift pitch dies as stated. Guess: 10-25, moderate
//       churn dominated by genuine platform transitions.
//   E3 (legibility). Read the fast climbers by hand. They should be
//       recognizable infrastructure transitions (systemd plumbing,
//       python3 migration, gcc/rust toolchain, ICU/ssl version walks).
//       If they read as noise, a drift alert cannot be triaged by a
//       human and E2's threshold is moot.
//
// Method notes, fixed in advance: conemass via oracleMass (cap 200,
// as everywhere); ranks are min-tie over package names present that
// year; name changes across releases are a known hazard (libssl0.9.8
// -> libssl1.1 -> libssl3), so watchlist rows are also reported under
// prefix families (liblzma*, libssl*, libsystemd*). Writes
// oracle-scanner/drift.json.
//
// ============================================================
// POSTSCRIPT (after the run, 2026-09-23)
//
// E1 — REGISTERED GUESS CONFIRMED, more strongly than guessed.
// liblzma's trajectory: absent 2007-2009, then #8 ON ARRIVAL
// (liblzma2, squeeze 2011, when dpkg adopted xz compression), and
// pinned at 6-10 for FOURTEEN YEARS: 8, 8, 6, 8, 10, 8 across
// 2013-2023. No takeover-window climb (2019: 8 -> 2021: 10 -> 2023:
// 8). Drift is NOT a leading indicator for the xz case. The leading
// indicator was static concentration, visible from the package's
// FIRST release in the archive — thirteen years before the backdoor.
// The Socket email's framing ("drift ... is the xz insertion pattern
// as a monitorable signal") is wrong as stated and must be corrected
// if the thread continues: the xz-shaped alert is not "rank climbing"
// but "new package arrives directly into the top ranks" — which the
// churn data DOES capture (liblzma2 appears in the 2009->2011
// fast-climber list as a new entrant; liblzma5 in 2011->2013).
// Maximal lead time, fired at load-arrival.
//
// Post-attack coda the metric records: liblzma5 drops 8 -> 19 in
// trixie 2025 — the ecosystem's de-concentration after the backdoor
// (sshd/systemd unlinking) is visible as the only large watchlist
// move in the whole table. The instrument sees the remediation too.
//
// E2 — GREY ZONE, as registered: median 23 top-100 entrants per
// release (thresholds: <=15 monitorable, >=30 dead). Neither verdict
// fires. Observation (unregistered, for any follow-up): the entrant
// lists are dominated by mechanical version successions (gcc-N-base,
// libicuNN, perl-modules-5.NN, pythonN.NN, the 2025 t64 ABI renames)
// which a successor-detection filter would remove; genuinely novel
// arrivals are ~5-8 per release. A registered rerun with a
// name-succession filter is the obvious next cell if drift is ever
// productized.
//
// E3 — LEGIBLE, confirmed. Every fast-climber list reads as a named
// platform transition: the krb5 stack arriving (2011), systemd
// plumbing (2013-2017), python2->3 (2019), t64 ABI (2025). The
// security-relevant class is visible too: every compression library
// walked into the head on arrival — liblzma2 (2011), liblz4-1 (2017,
// from 1482), libzstd1 (2019, from 1243) — and libkeyutils1 (the
// sharpest PageRank-miss in study 06) entered the top-100 from 989 in
// 2009. The xz-class alert ("small library arrives at high
// concentration") would have fired on all of them, years before any
// of them mattered to an attacker.
//
// VERDICT: drift-as-climbing is dead for the xz case (registered
// guess confirmed); arrival-into-the-head is the live signal, with
// 14 years of lead time on the consensus catastrophe, and the churn
// volume sits in the grey zone pending a succession filter. Report
// before correcting the email framing; do not re-pitch drift as
// takeover detection.
// ============================================================

import { readFileSync, writeFileSync } from "node:fs";
import { buildSnap } from "../deflation-control/lib.mjs";
import { oracleMass } from "../battery-v3/lib.mjs";

const YEARS = [2007, 2009, 2011, 2013, 2015, 2017, 2019, 2021, 2023, 2025];
const RELEASE = {
  2007: "etch", 2009: "lenny", 2011: "squeeze", 2013: "wheezy",
  2015: "jessie", 2017: "stretch", 2019: "buster", 2021: "bullseye",
  2023: "bookworm", 2025: "trixie",
};
const WATCH_EXACT = ["liblzma5", "libgcrypt20", "libexpat1", "zlib1g", "xz-utils"];
const WATCH_PREFIX = ["liblzma", "libssl", "libsystemd"];

// per year: Map name -> { rank (min-tie, conemass desc), mass }
const yearRank = new Map();
const yearN = new Map();

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
  const rank = new Map();
  let i = 0;
  while (i < rows.length) {
    let j = i;
    while (j + 1 < rows.length && rows[j + 1].mass === rows[i].mass) j++;
    for (let k = i; k <= j; k++) rank.set(rows[k].name, { rank: i + 1, mass: rows[k].mass });
    i = j + 1;
  }
  yearRank.set(y, rank);
  yearN.set(y, rows.length);
  console.log(`${y} (${RELEASE[y]}): ${rows.length} packages ranked`);
}

// ---- E1: watchlist trajectories ----
console.log("\n=== E1: watchlist conemass-rank trajectories ===");
const traj = {};
const trajRow = (label, matcher) => {
  const t = {};
  for (const y of YEARS) {
    const rank = yearRank.get(y);
    let best = null;
    for (const [nm, r] of rank) {
      if (matcher(nm) && (best === null || r.rank < best.rank)) best = { name: nm, rank: r.rank };
    }
    t[y] = best ? `${best.rank}${best.name !== label ? ` (${best.name})` : ""}` : "-";
  }
  traj[label] = t;
  console.log(`${label}: ` + YEARS.map((y) => `${y}:${t[y]}`).join("  "));
};
for (const w of WATCH_EXACT) trajRow(w, (nm) => nm === w);
for (const p of WATCH_PREFIX) trajRow(p + "*", (nm) => nm.startsWith(p));

// ---- E2: top-100 churn between adjacent releases ----
console.log("\n=== E2: top-100 churn ===");
const churn = [];
for (let yi = 1; yi < YEARS.length; yi++) {
  const yPrev = YEARS[yi - 1], yCur = YEARS[yi];
  const prev = yearRank.get(yPrev), cur = yearRank.get(yCur);
  const top = (rank, k) => {
    const s = [];
    for (const [nm, r] of rank) if (r.rank <= k) s.push(nm);
    return new Set(s);
  };
  const curTop = top(cur, 100);
  const prevTop = top(prev, 100);
  const entrants = [...curTop].filter((nm) => !prevTop.has(nm));
  const buckets = { from101_250: [], from251_1000: [], from1000plus_or_new: [] };
  for (const nm of entrants) {
    const pr = prev.get(nm)?.rank;
    if (pr !== undefined && pr <= 250) buckets.from101_250.push(`${nm}(${pr})`);
    else if (pr !== undefined && pr <= 1000) buckets.from251_1000.push(`${nm}(${pr})`);
    else buckets.from1000plus_or_new.push(`${nm}(${pr ?? "new"})`);
  }
  churn.push({
    step: `${yPrev}->${yCur}`,
    overlap: 100 - entrants.length,
    entrants: entrants.length,
    ...Object.fromEntries(Object.entries(buckets).map(([k, v]) => [k, v.length])),
    fastClimbers: [...buckets.from251_1000, ...buckets.from1000plus_or_new],
  });
  console.log(`${yPrev}->${yCur}: overlap ${100 - entrants.length}/100, entrants ${entrants.length} ` +
    `(101-250: ${buckets.from101_250.length}, 251-1000: ${buckets.from251_1000.length}, >1000/new: ${buckets.from1000plus_or_new.length})`);
}
const entrantCounts = churn.map((c) => c.entrants).sort((a, b) => a - b);
const median = entrantCounts[Math.floor(entrantCounts.length / 2)];
console.log(`median top-100 entrants per release: ${median} (registered: <=15 monitorable, >=30 dead)`);

// ---- E3: fast climbers, by hand ----
console.log("\n=== E3: fast climbers (entered top-100 from >250 or absent) ===");
for (const c of churn) {
  if (c.fastClimbers.length) console.log(`${c.step}: ${c.fastClimbers.join(", ")}`);
}

writeFileSync("oracle-scanner/drift.json", JSON.stringify({
  years: YEARS, releases: RELEASE, nPerYear: Object.fromEntries(yearN),
  watchlist: traj, churn, medianEntrants: median,
}, null, 1));
console.log("\nwrote oracle-scanner/drift.json");
