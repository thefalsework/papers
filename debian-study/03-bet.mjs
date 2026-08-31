// Debian study — THE TIEBREAKER BET (registered before first run).
//
// PRE-REGISTRATION. Committed after 01 (extraction; choices fixed in
// its header) and 02 (blind census: structure, feasibility, balance —
// no gain computed anywhere). This is the study both prior controls
// pointed at:
//
//   - deflation-control (2026-08-30): E > R survives exact distance
//     matching on Go and crates, dies on the proof corpora;
//   - baseline-gauntlet (2026-08-31): under the full standard battery,
//     Go still holds; crates deflates to fine-grained popularity.
//
// The growth claim is therefore one corpus wide, and the gauntlet's
// registered interpretation table names THIS study the tiebreaker: a
// fresh corpus, never touched by any script in this repository until
// yesterday, measured under the strictest design the program has.
// If DB1 holds, the gatekeeper sentence exists: "an algebraically
// defined cell predicts future dependency growth beyond every standard
// graph predictor, pre-registered, on two unrelated ecosystems, one of
// them measured after the hypothesis was fixed." If DB1 fails, the
// growth chapter closes scoped to Go, and the program says so at full
// prominence.
//
// WHY DEBIAN QUALIFIES AS MAXIMUM-SELECTION GROUND (prior, on record):
// a Debian binary dependency is installed, executed code — the
// strongest reuse semantics available — and the biology-flavored
// selection-gradient reading (session 2026-08-30) therefore predicts
// the cell effect is REAL here. The operator's prior leans survival,
// for that reason and against the base rate (record: 4 for 20).
//
// DESIGN (identical to baseline-gauntlet/02, constants fixed from the
// blind census): ten biennial snapshots 2007-2025 (main/binary-amd64),
// baselines 2007..2021, horizon +2; 300 seeded kernels per baseline;
// candidates = singleton components, non-I, alive at horizon; grouped
// by cell x EXACT undirected distance to the kernel's down-set; sides
// capped at 300 per group (seeded); greedy nearest-neighbor matching
// without replacement in the z-space of [log1p in-degree, log1p
// out-degree, first-seen, log PageRank (alpha .85, depended-upon
// direction), k-core], CALIPER 0.5 (census: 268,559 ER pairs,
// maxSMD 0.0093). GATE: post-match max |SMD| <= 0.10 per contrast,
// else INFEASIBLE. Uninformative floor: 50 pairs. Gains = horizon
// in-degree minus baseline in-degree. Statistic: mean paired
// difference. Null: within-pair sign flips, 1000 draws, mulberry32
// seed 20260831777.
//
// REGISTERED PREDICTION:
//   DB1: Delta_ER > 0 at >= 97.5th percentile of its null.
//   Secondary, registered-descriptive (scores nothing): Delta_ED.
//
// INTERPRETATION TABLE (fixed in advance):
//   DB1 HOLDS    -> the two-ecosystem claim exists; write the
//                   empirical paper around Go + Debian with crates'
//                   deflation reported as the method catching its own
//                   artifact.
//   DB1 NULL     -> the growth claim is scoped to Go alone; the paper,
//                   if any, leads with E-on-territory and latency, and
//                   the growth section is a scoped observation.
//   DB1 REVERSES -> stronger: package ecosystems are NOT a regime;
//                   the cell-growth reading is dead outside Go and
//                   Go itself becomes the anomaly to explain.
//
// Writes debian-study/results-bet.json.
//
// ============================================================
// POSTSCRIPT (added after the single registered run, 2026-08-31)
//
//   DB1 (primary): **HOLDS.** Delta_ER = +0.0979, null band
//   [-0.0149, +0.0136], percentile 100.0, on 264,330 matched pairs,
//   maxSMD 0.0097 (gate 0.10 passed with a factor of ten to spare).
//   2,400 kernels across eight baselines, 2007-2021, horizons +4yr.
//
//   Descriptive secondary: Delta_ED = -0.1554, percentile 0.0 on
//   962,323 pairs — Debian's Distribution cell out-grows its
//   Exploitation cell at matched everything.
//
// WHAT THE HIT MEANS: the sealed out-of-sample bet landed, on the
// first try, on a corpus untouched by the program until yesterday.
// The gatekeeper sentence now exists in its two-ecosystem form:
// membership in the Exploitation cell predicts future dependency
// growth beyond degree, out-degree, age, exact graph distance,
// PageRank, and k-core, pre-registered, on Go and Debian — with
// crates.io's deflation reported alongside as the method catching
// its own artifact. Registered-directional record: 5 for 21.
//
// WHAT THE SECONDARY ADDS (new, unpredicted, honestly labeled): the
// E-vs-R effect and the E-vs-D ordering are INDEPENDENT axes. Debian
// grows its boundary-straddlers hardest (D > E > R at matched
// battery), like the Isabelle-ecosystem archives and unlike Go —
// yet its E > R cell effect is real and battery-proof. So "the
// shadow out-grows the outside" (E > R) is the claim with
// cross-ecosystem legs, while "the shadow is the single biggest
// growth engine" (E > D) remains corpus-contingent. The 2028
// forward bets score E-vs-D and are untouched; P1-P3's rationale
// should be read with this scoping in mind at horizon.
// ============================================================

import { readFileSync, writeFileSync } from "node:fs";
import { buildSnap, makeGate, makeDistancer, firstSeenOf } from "../deflation-control/lib.mjs";
import { pagerank, coreNumbers, zStats, greedyMatch } from "../baseline-gauntlet/gauntlet-lib.mjs";

const YEARS = [2007, 2009, 2011, 2013, 2015, 2017, 2019, 2021, 2023, 2025];
const BASELINES = [0, 1, 2, 3, 4, 5, 6, 7];
const HORIZON = 2;
const KERNEL_CAP = 300;
const SIDE_CAP = 300;
const CALIPER = 0.5;
const PERMS = 1000;
const MIN_PAIRS = 50;
const SMD_GATE = 0.10;
const FEATS = ["logIn", "logOut", "age", "logPR", "core"];

const SEED = 20260831777;
let rngState = SEED;
const rand = () => {
  rngState |= 0; rngState = (rngState + 0x6d2b79f5) | 0;
  let t = Math.imul(rngState ^ (rngState >>> 15), 1 | rngState);
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};

const snaps = YEARS.map((y) => {
  const raw = JSON.parse(readFileSync(`debian-study/history/${y}.json`, "utf8"));
  return buildSnap(raw.nodes, raw.edges);
});
const fsMap = firstSeenOf(snaps);

const out = { ER: { diffs: [], sumE: FEATS.map(() => 0), sumB: FEATS.map(() => 0) },
              ED: { diffs: [], sumE: FEATS.map(() => 0), sumB: FEATS.map(() => 0) } };
let kernels = 0;
for (const ti of BASELINES) {
  const snap = snaps[ti];
  const fut = snaps[ti + HORIZON];
  const gate = makeGate(snap);
  const distancer = makeDistancer(snap);
  const { nComp, compMembers, names, inDeg } = snap;
  const pr = pagerank(snap);
  const core = coreNumbers(snap);
  const globalRows = [];
  for (let c = 0; c < nComp; c++) {
    const members = compMembers[c];
    if (members.length > 1) continue;
    if (!fut.inDeg.has(names[members[0]])) continue;
    globalRows.push(c);
  }
  const gIn = zStats(globalRows.map((c) => Math.log1p(inDeg.get(names[compMembers[c][0]]) ?? 0)));
  const gOut = zStats(globalRows.map((c) => Math.log1p(snap.cIn[c].length)));
  const gAge = zStats(globalRows.map((c) => fsMap.get(names[compMembers[c][0]])));
  const gPR = zStats(globalRows.map((c) => Math.log(pr[c])));
  const gCore = zStats(globalRows.map((c) => core[c]));
  const order = Array.from({ length: nComp }, (_, i) => i);
  for (let i = 0; i < nComp; i++) {
    const j = i + Math.floor(rand() * (nComp - i));
    const t = order[i]; order[i] = order[j]; order[j] = t;
  }
  let used = 0;
  for (const a of order) {
    if (used >= KERNEL_CAP) break;
    const g = gate(a);
    if (!g) continue;
    used++; kernels++;
    const dOf = distancer(g.downMembers);
    const groups = { E: new Map(), D: new Map(), R: new Map() };
    for (const c of globalRows) {
      const cell = g.cellOf(c);
      if (cell === "I") continue;
      const d = dOf(c);
      if (!groups[cell].has(d)) groups[cell].set(d, []);
      groups[cell].get(d).push(c);
    }
    const featOf = (c) => {
      const nm = names[compMembers[c][0]];
      return [
        (Math.log1p(inDeg.get(nm) ?? 0) - gIn.mu) / gIn.sd,
        (Math.log1p(snap.cIn[c].length) - gOut.mu) / gOut.sd,
        (fsMap.get(nm) - gAge.mu) / gAge.sd,
        (Math.log(pr[c]) - gPR.mu) / gPR.sd,
        (core[c] - gCore.mu) / gCore.sd,
      ];
    };
    const gainOf = (c) => {
      const nm = names[compMembers[c][0]];
      return (fut.inDeg.get(nm) ?? 0) - (inDeg.get(nm) ?? 0);
    };
    const cap = (arr) => {
      if (arr.length <= SIDE_CAP) return arr;
      for (let i = 0; i < SIDE_CAP; i++) {
        const j = i + Math.floor(rand() * (arr.length - i));
        const t = arr[i]; arr[i] = arr[j]; arr[j] = t;
      }
      return arr.slice(0, SIDE_CAP);
    };
    for (const [contrast, bSide] of [["ER", "R"], ["ED", "D"]]) {
      for (const [d, eMembers] of groups.E) {
        const bMembers = groups[bSide].get(d);
        if (!bMembers) continue;
        const eCap = cap([...eMembers]), bCap = cap([...bMembers]);
        const fE = eCap.map(featOf), fB = bCap.map(featOf);
        const pairs = greedyMatch(fE, fB, CALIPER, rand);
        const acc = out[contrast];
        for (const [ei, bi] of pairs) {
          acc.diffs.push(gainOf(eCap[ei]) - gainOf(bCap[bi]));
          for (let k = 0; k < FEATS.length; k++) {
            acc.sumE[k] += fE[ei][k];
            acc.sumB[k] += fB[bi][k];
          }
        }
      }
    }
  }
}

const results = { kernels };
console.log(`debian: kernels=${kernels}`);
for (const contrast of ["ER", "ED"]) {
  const { diffs, sumE, sumB } = out[contrast];
  const n = diffs.length;
  const smd = FEATS.map((f, k) => (n ? Math.abs(sumE[k] - sumB[k]) / n : null));
  const maxSmd = n ? Math.max(...smd) : null;
  const label = contrast === "ER" ? "DB1 PRIMARY Delta_ER" : "descriptive Delta_ED";
  if (!n || n < MIN_PAIRS) {
    console.log(`  ${label}: UNINFORMATIVE (${n} pairs)`);
    results[contrast] = { pairs: n, verdict: "UNINFORMATIVE" };
    continue;
  }
  if (maxSmd > SMD_GATE) {
    console.log(`  ${label}: INFEASIBLE — balance gate failed (maxSMD ${maxSmd.toFixed(4)})`);
    results[contrast] = { pairs: n, maxSmd, verdict: "INFEASIBLE" };
    continue;
  }
  let obs = 0;
  for (const d of diffs) obs += d;
  obs /= n;
  const nulls = [];
  for (let p = 0; p < PERMS; p++) {
    let s = 0;
    for (const d of diffs) s += rand() < 0.5 ? d : -d;
    nulls.push(s / n);
  }
  nulls.sort((a, b) => a - b);
  let below = 0;
  for (const v of nulls) if (v < obs) below++;
  const pct = (100 * below) / PERMS;
  const lo = nulls[Math.floor(0.025 * PERMS)], hi = nulls[Math.floor(0.975 * PERMS)];
  const verdict = obs > 0 && pct >= 97.5 ? "HOLDS" : obs < 0 && pct <= 2.5 ? "REVERSES" : "NULL";
  console.log(`  ${label}: pairs=${n} maxSMD=${maxSmd.toFixed(4)} obs=${obs.toFixed(4)} null=[${lo.toFixed(4)},${hi.toFixed(4)}] pct=${pct.toFixed(1)} -> ${verdict}`);
  results[contrast] = {
    pairs: n, maxSmd, obs, lo, hi, pct, verdict,
    smd: Object.fromEntries(FEATS.map((f, k) => [f, +smd[k].toFixed(4)])),
  };
}
writeFileSync("debian-study/results-bet.json", JSON.stringify(results, null, 1));
console.log(JSON.stringify({ DB1: results.ER.verdict }));
