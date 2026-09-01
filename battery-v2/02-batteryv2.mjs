// Battery v2 — THE REGISTERED RUN: does the surviving field claim
// survive the confound its own theory found?
//
// PRE-REGISTRATION (header written before first run; committed after
// the blind pre-check 01/01b, which touched matching feasibility and
// covariate balance only — no gain was computed anywhere).
//
// PROVENANCE OF THE KNIFE: this is the first field study whose confound
// was derived, not guessed. The accretion study's flux law
// (accretion-study/THEORY.md, 2026-09-01) proves that under cone-local
// growth, expected gain tracks truncated UP-SET SIZE (transitive
// dependents) — a quantity no feature of the standard battery carries —
// and PC(0) demonstrates a cell beating that battery at |t| > 10 purely
// through up-set flux. If real ecosystems have any cone-local
// component, up-set size is the cheap explanation the gauntlet and the
// Debian bet never excluded.
//
// WHAT THE BLIND PRE-CHECK FOUND (structure only, precheck.json):
//   - Go, E-vs-R, the old five-feature pairs: SIGNED SMD(upset) =
//     +0.69 — E-members carried massively larger up-sets than their R
//     twins, the inflation direction. And it is NOT REPAIRABLE: at
//     every caliper 0.25-0.5 the six-feature match yields the same 51
//     pairs at SMD(upset) 0.113 > 0.10; wider calipers make it worse.
//     Registered consequence, fixed now: Go E-vs-R CANNOT BE CERTIFIED
//     beyond up-set flux on this corpus — it is reported descriptively
//     (51 pairs, failed gate) and scores nothing, and the program's
//     language about Go E > R must change no matter what else happens.
//   - Go, E-vs-D: balances cleanly at 6 features (10,228 pairs, maxSMD
//     0.073, SMD(upset) 0.001). Scorable.
//   - Debian, both contrasts: balance is excellent at 6 features
//     (E-vs-R 239,587 pairs, maxSMD 0.010, SMD(upset) 0.0006; E-vs-D
//     898,051 pairs, maxSMD 0.023). Debian's OLD pairs were already
//     nearly balanced on up-set (SMD 0.048), so the prior leans
//     survival there.
//
// DESIGN: identical to baseline-gauntlet/02 (Go) and debian-study/03
// (Debian) in every constant — snapshots, baselines, horizon +2,
// kernel caps (Go: all evaluable; Debian: 300 seeded per baseline),
// SIDE_CAP 300, CALIPER 0.5, MIN_PAIRS 50, SMD gate 0.10, sign-flip
// null 1000 draws — except the match z-space gains f6 =
// log1p(upset_200) (battery-v2/lib.mjs) and the gate covers all six
// features. Seed 20260901555 (fresh).
//
// REGISTERED PREDICTIONS:
//   BV1 (Debian, E-vs-R, PRIMARY): Delta_ER > 0 at >= 97.5th
//     percentile of its sign-flip null. Post-audit reading discipline:
//     the percentile is a conditional (within-corpus) statement; the
//     registered content is the SIGN plus the conditional band.
//   BV2 (Go, E-vs-D): Delta_ED > 0 at >= 97.5th percentile.
//   Registered-descriptive (scores nothing): Go E-vs-R (failed gate,
//     51 pairs — point estimate reported with the gate failure
//     stated); Debian E-vs-D.
//
// OPERATOR PRIOR, ON THE RECORD: BV1 survival likely (old imbalance
// was only 0.048); BV2 genuinely uncertain — Go's D-side comparison
// was never probed on this axis and the E-D up-set gap in old pairs
// was 0.08. Registered-directional record going in: 7 for 24.
//
// INTERPRETATION TABLE (fixed in advance):
//   BV1 holds -> the Debian claim upgrades to "beyond every standard
//     predictor AND the flux-law confound"; the two-ecosystem sentence
//     is rewritten: Debian carries E-over-R at battery v2; Go's E-over-R
//     is reclassified as UNCERTIFIABLE (up-set-confounded, stated at
//     full volume) — the program's third artifact catch, this time by
//     its own theory.
//   BV1 null/reverses -> the deepest deflation available: even
//     Debian's E > R was up-set flux in costume. The growth chapter is
//     rewritten around the flux law as the discovery (the synthetic
//     model predicted the field's confound), and no battery-proof cell
//     growth claim survives anywhere.
//   BV2 holds -> Go retains a battery-v2-proof effect on the E-vs-D
//     axis (the axis Debian reverses on); the cross-corpus story stays
//     two-axis.
//   BV2 null/reverses -> Go exits the certified-claims table entirely.
//
// Writes battery-v2/results.json.
//
// ============================================================
// POSTSCRIPT (added after the single registered run, 2026-09-01)
//
//   BV1 (Debian E-vs-R, PRIMARY): **HOLDS.** Delta_ER = +0.0834,
//   null [-0.0120, +0.0127], pct 100, 237,078 pairs, maxSMD 0.0104
//   across all six features. The v1 estimate was +0.0979; adding the
//   flux-law confound moved it by -0.015 and left it eight null-widths
//   above zero. Debian's cell effect is now certified beyond every
//   standard predictor AND beyond truncated transitive-dependent
//   count — the one confound the program's own theory named.
//
//   BV2 (Go E-vs-D): **HOLDS.** Delta_ED = +0.1524, null
//   [-0.0589, +0.0597], pct 100, 10,243 pairs, maxSMD 0.0735.
//   Unchanged from v1 (+0.1529): Go's E-over-D was never up-set flux.
//
//   Descriptive, pre-declared gate-failed (scores nothing): Go E-vs-R
//   on the 51 balanceable pairs reads Delta_ER = -1.00 (pct 0 of its
//   own conditional null). Not certified (gate failed at SMD(upset)
//   0.113; 51 pairs; conditional null) — but the direction says the
//   obvious thing loudly: at even-approximately-matched up-set size,
//   Go's E-advantage over R is GONE, and then some. Combined with the
//   +0.69 signed imbalance in the old pairs and the flux law's
//   mechanism, the honest reclassification is: GO'S E > R WAS MOST
//   LIKELY UP-SET FLUX IN COSTUME — the program's third artifact
//   caught in-house, and the first caught by its own theory before
//   any referee could have named the variable.
//
//   Debian descriptive Delta_ED = -0.1646 (v1: -0.1554): the D > E
//   reversal is up-set-robust too; the two-axis picture stands.
//
// BOOKKEEPING CORRECTION: the header's "going in: 7 for 24" miscounted.
// Correct going-in record: 6 for 22 (5 for 21 after Debian; accretion
// B' added one directional bet, B2, which hit; its B1 verdicts
// predicted nulls and are not counted as directional bets). After
// BV1 + BV2 both land: **8 for 24** — three registered directional
// hits in a row (B2, BV1, BV2), all three called with mechanism in
// hand.
//
// THE GATEKEEPER SENTENCE, REWRITTEN (v3): "In the Debian archive —
// ten stable releases, 2007-2025 — membership in the Exploitation cell
// of an algebraically defined partition predicts future dependency
// growth beyond in-degree, out-degree, age, exact graph distance,
// PageRank, k-core, AND transitive-dependent count, in a design whose
// confound list was extended by the program's own generative theory
// and whose original version landed as a sealed out-of-sample bet.
// In Go, the same cell carries a battery-v2-proof E-over-D effect,
// while its celebrated E-over-R effect is reclassified as
// up-set-confounded — caught by the same theory." That sentence has
// no percentile in it and survives the audit's reading discipline.
// ============================================================

import { readFileSync, writeFileSync } from "node:fs";
import { CORPORA, buildSnap, firstSeenOf, makeGate, makeDistancer } from "../deflation-control/lib.mjs";
import { pagerank, coreNumbers, zStats, greedyMatch } from "../baseline-gauntlet/gauntlet-lib.mjs";
import { upsetSizes } from "./lib.mjs";

const CALIPER = 0.5, SIDE_CAP = 300, PERMS = 1000, MIN_PAIRS = 50, SMD_GATE = 0.10;
const FEATS = ["logIn", "logOut", "age", "logPR", "core", "logUpset"];
const SEED = 20260901555;
let rngState = SEED;
const rand = () => {
  rngState |= 0; rngState = (rngState + 0x6d2b79f5) | 0;
  let t = Math.imul(rngState ^ (rngState >>> 15), 1 | rngState);
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};

const loadDebian = () => {
  const YEARS = [2007, 2009, 2011, 2013, 2015, 2017, 2019, 2021, 2023, 2025];
  const snaps = YEARS.map((y) => {
    const raw = JSON.parse(readFileSync(`debian-study/history/${y}.json`, "utf8"));
    return buildSnap(raw.nodes, raw.edges);
  });
  return { snaps, baselines: [0, 1, 2, 3, 4, 5, 6, 7], horizon: 2, kernelCap: 300 };
};
const loadGo = () => {
  const { subs, baselines, horizon } = CORPORA.go();
  return { snaps: subs[0], baselines, horizon, kernelCap: Infinity };
};

const collect = (loader) => {
  const { snaps, baselines, horizon, kernelCap } = loader();
  const fsMap = firstSeenOf(snaps);
  const out = { ER: { diffs: [], sumE: FEATS.map(() => 0), sumB: FEATS.map(() => 0) },
                ED: { diffs: [], sumE: FEATS.map(() => 0), sumB: FEATS.map(() => 0) } };
  let kernels = 0;
  for (const ti of baselines) {
    const snap = snaps[ti];
    const fut = snaps[ti + horizon];
    const gate = makeGate(snap);
    const distancer = makeDistancer(snap);
    const { nComp, compMembers, names, inDeg } = snap;
    const pr = pagerank(snap);
    const core = coreNumbers(snap);
    const upset = upsetSizes(snap);
    const globalRows = [];
    for (let c = 0; c < nComp; c++) {
      if (compMembers[c].length > 1) continue;
      if (!fut.inDeg.has(names[compMembers[c][0]])) continue;
      globalRows.push(c);
    }
    const gIn = zStats(globalRows.map((c) => Math.log1p(inDeg.get(names[compMembers[c][0]]) ?? 0)));
    const gOut = zStats(globalRows.map((c) => Math.log1p(snap.cIn[c].length)));
    const gAge = zStats(globalRows.map((c) => fsMap.get(names[compMembers[c][0]])));
    const gPR = zStats(globalRows.map((c) => Math.log(pr[c])));
    const gCore = zStats(globalRows.map((c) => core[c]));
    const gUp = zStats(globalRows.map((c) => Math.log1p(upset[c])));
    const featOf = (c) => {
      const nm = names[compMembers[c][0]];
      return [
        (Math.log1p(inDeg.get(nm) ?? 0) - gIn.mu) / gIn.sd,
        (Math.log1p(snap.cIn[c].length) - gOut.mu) / gOut.sd,
        (fsMap.get(nm) - gAge.mu) / gAge.sd,
        (Math.log(pr[c]) - gPR.mu) / gPR.sd,
        (core[c] - gCore.mu) / gCore.sd,
        (Math.log1p(upset[c]) - gUp.mu) / gUp.sd,
      ];
    };
    const gainOf = (c) => {
      const nm = names[compMembers[c][0]];
      return (fut.inDeg.get(nm) ?? 0) - (inDeg.get(nm) ?? 0);
    };
    const order = Array.from({ length: nComp }, (_, i) => i);
    for (let i = 0; i < nComp; i++) {
      const j = i + Math.floor(rand() * (nComp - i));
      const t = order[i]; order[i] = order[j]; order[j] = t;
    }
    let used = 0;
    for (const a of order) {
      if (used >= kernelCap) break;
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
  return { kernels, out };
};

const score = (contrastOut, label) => {
  const { diffs, sumE, sumB } = contrastOut;
  const n = diffs.length;
  const smd = FEATS.map((f, k) => (n ? Math.abs(sumE[k] - sumB[k]) / n : null));
  const maxSmd = n ? Math.max(...smd) : null;
  if (!n || n < MIN_PAIRS) { console.log(`  ${label}: UNINFORMATIVE (${n} pairs)`); return { pairs: n, verdict: "UNINFORMATIVE" }; }
  let obs = 0;
  for (const d of diffs) obs += d;
  obs /= n;
  const gateFailed = maxSmd > SMD_GATE;
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
  const verdict = gateFailed ? "GATE-FAILED (descriptive only)"
    : obs > 0 && pct >= 97.5 ? "HOLDS" : obs < 0 && pct <= 2.5 ? "REVERSES" : "NULL";
  console.log(`  ${label}: pairs=${n} maxSMD=${maxSmd.toFixed(4)} obs=${obs.toFixed(4)} null=[${lo.toFixed(4)},${hi.toFixed(4)}] pct=${pct.toFixed(1)} -> ${verdict}`);
  return { pairs: n, maxSmd: +maxSmd.toFixed(4), obs: +obs.toFixed(4), lo: +lo.toFixed(4), hi: +hi.toFixed(4), pct, verdict,
           smd: Object.fromEntries(FEATS.map((f, k) => [f, +smd[k].toFixed(4)])) };
};

const results = {};
for (const [corpus, loader] of [["go", loadGo], ["debian", loadDebian]]) {
  const { kernels, out } = collect(loader);
  console.log(`${corpus}: kernels=${kernels}`);
  results[corpus] = {
    kernels,
    ER: score(out.ER, corpus === "debian" ? "BV1 PRIMARY Delta_ER" : "descriptive (pre-declared gate-failed) Delta_ER"),
    ED: score(out.ED, corpus === "go" ? "BV2 Delta_ED" : "descriptive Delta_ED"),
  };
}
writeFileSync("battery-v2/results.json", JSON.stringify(results, null, 1));
console.log(JSON.stringify({ BV1: results.debian.ER.verdict, BV2: results.go.ED.verdict }));
