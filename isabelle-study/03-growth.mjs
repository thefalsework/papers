// Referee study, RF2 — THE REGISTERED RUN: does the Isabelle
// DISTRIBUTION grow through Exploitation?
//
// PRE-REGISTRATION (header written before first run; committed with the
// blind census 02, which touched only occupancy counts, cycle structure,
// survival, and stratum feasibility — nothing that can leak the E-vs-D
// alignment predicted below).
//
// WHY THIS CORPUS DECIDES: the growth-cell record is E > D on Mathlib
// (mathlib-study/18), Go and crates.io (software-study/04), and D > E
// only on AFP (afp-study/07). The garden/museum axis is dead (frozen
// crates grows through E), so the live explanation of the AFP anomaly is
// the REFEREE HYPOTHESIS: an acceptance gate that admits only finished,
// self-contained work exports the corpus's E phase — leaving citation-
// style growth through interface entries (D). The Isabelle distribution
// is the controlled contrast: THE SAME COMMUNITY, the same logic, the
// same two decades — but continuously maintained, no per-entry freeze,
// no referee at the door. Institution varies; community, domain, and
// era are held fixed.
//
// DESIGN (inherited unchanged from mathlib-study/18 via software-
// study/04): baselines 2006..2022 biennial (nine), horizon +2
// checkpoints = 4 years (the AFP horizon); ALL evaluable principal
// kernels on the SCC condensation per baseline (census: graphs are
// perfectly acyclic, so components are theories); members classified
// I/R/E/D per kernel; outcome gain = in-degree(name, t+4y) − in-degree
// (name, t), members absent at horizon excluded (death; renames =
// death + birth); strata = degree bin (0 / 1-2 / 3-7 / 8+) × EXACT
// first-seen checkpoint index; statistic G_ED = weighted mean over
// (kernel × stratum) cells with both sides present of
// [meanGain(E) − meanGain(D)], weight min(nE, nD), pooled over all
// baselines; null = within-cell label permutation, 1000 draws, one
// seeded stream (mulberry32, seed 20260830517).
//
// REGISTERED PREDICTIONS:
//   RF2 (primary): G_ED > 0 at or above the 97.5th percentile of the
//     null — the distribution behaves like every non-refereed corpus.
//   Secondary (descriptive, MG2 convention): G_ER > 0 at >= 95th pct.
//     Color either way; scores nothing.
//
// INTERPRETATION TABLE (fixed in advance):
//   RF2 HOLDS  -> the within-community contrast lands: same people,
//     two institutions, two growth regimes. The referee hypothesis
//     survives its strongest available test and P4 (predictions/
//     REGISTER.md) stands on a mechanism, not a hunch.
//   RF2 FAILS BY REVERSAL (G_ED < 0 at <= 2.5th pct) -> the
//     distribution patterns with AFP: the Isabelle COMMUNITY, not the
//     acceptance gate, carries the reversal. Referee hypothesis dead;
//     report at full prominence.
//   RF2 NULL (inside band) -> uninformative on the contrast; the
//     hypothesis neither gains nor loses. Report as such.
//
// KNOWN APPROXIMATIONS (declared in 01/02, restated): import
// resolution is basename-based with ambiguity ~14% before 2018 and
// ~2.7% after (session-qualified imports became standard); ambiguous
// tokens are DROPPED, never guessed. The rate is reported per
// checkpoint in results-census.json and its step change is visible in
// the 2018 edge count; the growth design compares E vs D members
// WITHIN a baseline, so a uniform undercount at a checkpoint cannot
// favor either side.
//
// Writes isabelle-study/results-growth.json.
//
// ---------------------------------------------------------------------
// POSTSCRIPT (2026-08-30, after the single registered run).
//
//   kernels=9,675  cellsED=103,641  cellsER=99,588
//   G_ED = -0.0208  null[2.5,97.5] = [-0.0025, +0.0027]  percentile 0
//   G_ER = +0.2616  percentile 100
//
// RF2 FAILS BY REVERSAL. The Isabelle distribution grows through
// DISTRIBUTION, like AFP — at matched degree and age, ~8x outside the
// null band on the low side. Per the pre-registered interpretation
// table: **the referee hypothesis is dead.** Same community, same
// logic, same decades, OPPOSITE institutions (continuously-refactored
// garden vs refereed frozen archive) — and the SAME growth regime. The
// acceptance gate was never the mechanism.
//
// Secondary holds: E > R (pct 100), as on every corpus measured.
//
// What the six-corpus record now shows (post-hoc, flagged, untested):
// E > D on Mathlib, Go, crates.io; D > E on AFP and the Isabelle
// distribution. The split is not maintained/frozen (dead on the
// software pair), not refereed/open (dead here), not proof/software
// (both sides of it have proof corpora), and not grain (AFP is entry-
// grain, the distribution theory-grain — both reverse). What the two
// reversing corpora uniquely share is the ISABELLE ECOSYSTEM — its
// community and its dependency conventions. "What is strange about
// AFP?" has widened to "what is strange about Isabelle world?" and lost
// its best candidate answer. No replacement hypothesis is registered
// here; effect-size note for any future one: the reversal is tiny in
// absolute terms (-0.02 dependents/member over 4y vs AFP's -0.33)
// though statistically clean.
//
// Consequence for predictions/REGISTER.md P4: the BET stands unchanged
// (registered, frozen), but its stated rationale ("the mechanism is
// institutional") is now dead. If P4 holds in 2028 it confirms the
// reversal's persistence, not the referee mechanism.
//
// Operator's registered-directional record: 1 for 13.
// ---------------------------------------------------------------------

import { readFileSync, writeFileSync } from "node:fs";

const YEARS = [2006, 2008, 2010, 2012, 2014, 2016, 2018, 2020, 2022, 2024, 2026];
const BASELINES = [0, 1, 2, 3, 4, 5, 6, 7, 8];
const HORIZON = 2;
const BIN = (d) => (d === 0 ? 0 : d <= 2 ? 1 : d <= 7 ? 2 : 3);
const PERMS = 1000;
const SEED = 20260830517;

let rngState = SEED;
const rand = () => {
  rngState |= 0; rngState = (rngState + 0x6d2b79f5) | 0;
  let t = Math.imul(rngState ^ (rngState >>> 15), 1 | rngState);
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};

// ---- Tarjan SCC / snapshot / gate (verbatim from 02-census.mjs) ----
const sccOf = (n, adjOut) => {
  const idx = new Int32Array(n).fill(-1), low = new Int32Array(n),
    onStk = new Uint8Array(n), comp = new Int32Array(n).fill(-1);
  let counter = 0, nComp = 0;
  const stk = [];
  for (let s = 0; s < n; s++) {
    if (idx[s] !== -1) continue;
    const call = [[s, 0]];
    while (call.length) {
      const fr = call[call.length - 1], v = fr[0];
      if (fr[1] === 0) { idx[v] = low[v] = counter++; stk.push(v); onStk[v] = 1; }
      let advanced = false;
      const nbrs = adjOut[v];
      while (fr[1] < nbrs.length) {
        const u = nbrs[fr[1]++];
        if (idx[u] === -1) { call.push([u, 0]); advanced = true; break; }
        if (onStk[u]) low[v] = Math.min(low[v], idx[u]);
      }
      if (advanced) continue;
      if (low[v] === idx[v]) {
        for (;;) { const u = stk.pop(); onStk[u] = 0; comp[u] = nComp; if (u === v) break; }
        nComp++;
      }
      call.pop();
      if (call.length) { const p = call[call.length - 1][0]; low[p] = Math.min(low[p], low[v]); }
    }
  }
  return { comp, nComp };
};

const buildSnap = (names, edges) => {
  const n = names.length;
  const adjOut = Array.from({ length: n }, () => []);
  const inDeg = new Map(names.map((nm) => [nm, 0]));
  for (const [a, b] of edges) {
    adjOut[a].push(b);
    inDeg.set(names[b], inDeg.get(names[b]) + 1);
  }
  const { comp, nComp } = sccOf(n, adjOut);
  const compMembers = Array.from({ length: nComp }, () => []);
  for (let i = 0; i < n; i++) compMembers[comp[i]].push(i);
  const eSet = new Set();
  for (const [a, b] of edges) if (comp[a] !== comp[b]) eSet.add(comp[a] * 2000000 + comp[b]);
  const cIn = Array.from({ length: nComp }, () => []);
  const cOut = Array.from({ length: nComp }, () => []);
  for (const x of eSet) {
    const a = Math.floor(x / 2000000), b = x % 2000000;
    cIn[a].push(b); cOut[b].push(a);
  }
  return { names, n, inDeg, nComp, cIn, cOut, compMembers };
};

const makeGate = (snap) => {
  const { nComp, cIn, cOut } = snap;
  const mDown = new Int32Array(nComp).fill(-1);
  const mUp1 = new Int32Array(nComp).fill(-1);
  const mUp2 = new Int32Array(nComp).fill(-1);
  const q = new Int32Array(nComp);
  const closure = (seeds, adj, mark, st) => {
    let head = 0, tail = 0;
    for (const s of seeds) if (mark[s] !== st) { mark[s] = st; q[tail++] = s; }
    while (head < tail) {
      const v = q[head++];
      for (const u of adj[v]) if (mark[u] !== st) { mark[u] = st; q[tail++] = u; }
    }
  };
  let stamp = 0;
  return (a) => {
    const st = stamp++;
    closure([a], cIn, mDown, st);
    const downMembers = [];
    for (let i = 0; i < nComp; i++) if (mDown[i] === st) downMembers.push(i);
    closure(downMembers, cOut, mUp1, st);
    const Nmembers = [];
    for (let i = 0; i < nComp; i++) if (mUp1[i] !== st) Nmembers.push(i);
    if (Nmembers.length === 0) return null;
    closure(Nmembers, cOut, mUp2, st);
    let hasE = false, hasD = false;
    for (let i = 0; i < nComp && !(hasE && hasD); i++) {
      if (mDown[i] === st || mUp1[i] !== st) continue;
      if (mUp2[i] !== st) hasE = true; else hasD = true;
    }
    if (!hasE || !hasD) return null;
    return {
      cellOf: (i) => {
        if (mDown[i] === st) return "I";
        if (mUp1[i] !== st) return "R";
        return mUp2[i] !== st ? "E" : "D";
      },
    };
  };
};

const snaps = YEARS.map((y) => {
  const raw = JSON.parse(readFileSync(`isabelle-study/history/${y}.json`, "utf8"));
  return buildSnap(raw.nodes, raw.edges);
});
const firstSeen = new Map();
snaps.forEach((snap, yi) => {
  for (const nm of snap.names) if (!firstSeen.has(nm)) firstSeen.set(nm, yi);
});

// ---- collect matched cells ----
const cellsED = [], cellsER = [];
let kernelsUsed = 0;
for (const ti of BASELINES) {
  const snap = snaps[ti];
  const fut = snaps[ti + HORIZON];
  const gate = makeGate(snap);
  const { nComp, compMembers, names, inDeg } = snap;
  for (let a = 0; a < nComp; a++) {
    const g = gate(a);
    if (!g) continue;
    kernelsUsed++;
    const strata = new Map();
    for (let c = 0; c < nComp; c++) {
      const cell = g.cellOf(c);
      if (cell === "I") continue;
      const members = compMembers[c];
      if (members.length > 1) continue;
      const nm = names[members[0]];
      if (!fut.inDeg.has(nm)) continue;
      const d0 = inDeg.get(nm) ?? 0;
      const key = `${BIN(d0)}|${firstSeen.get(nm)}`;
      if (!strata.has(key)) strata.set(key, { E: [], D: [], R: [] });
      strata.get(key)[cell].push((fut.inDeg.get(nm) ?? 0) - d0);
    }
    for (const [, s] of strata) {
      if (s.E.length && s.D.length)
        cellsED.push({ gains: Float64Array.from([...s.E, ...s.D]), nA: s.E.length });
      if (s.E.length && s.R.length)
        cellsER.push({ gains: Float64Array.from([...s.E, ...s.R]), nA: s.E.length });
    }
  }
}
console.log(`kernels=${kernelsUsed} cellsED=${cellsED.length} cellsER=${cellsER.length}`);

// ---- statistic and permutation (frozen estimator) ----
const statIdentity = (cells) => {
  let num = 0, den = 0;
  for (const c of cells) {
    const m = c.gains.length, nA = c.nA, nB = m - nA;
    const wgt = Math.min(nA, nB);
    let sA = 0;
    for (let i = 0; i < nA; i++) sA += c.gains[i];
    let sT = sA;
    for (let i = nA; i < m; i++) sT += c.gains[i];
    num += wgt * (sA / nA - (sT - sA) / nB);
    den += wgt;
  }
  return num / den;
};
const statPermuted = (cells) => {
  let num = 0, den = 0;
  for (const c of cells) {
    const m = c.gains.length, nA = c.nA, nB = m - nA;
    const wgt = Math.min(nA, nB);
    const idx = c.scratch ?? (c.scratch = Uint32Array.from({ length: m }, (_, i) => i));
    for (let i = 0; i < nA; i++) {
      const j = i + Math.floor(rand() * (m - i));
      const t = idx[i]; idx[i] = idx[j]; idx[j] = t;
    }
    let sA = 0;
    for (let i = 0; i < nA; i++) sA += c.gains[idx[i]];
    let sT = 0;
    for (let i = 0; i < m; i++) sT += c.gains[i];
    num += wgt * (sA / nA - (sT - sA) / nB);
    den += wgt;
  }
  return num / den;
};

const scoreSet = (cells, label) => {
  const obs = statIdentity(cells);
  const nulls = [];
  for (let p = 0; p < PERMS; p++) nulls.push(statPermuted(cells));
  nulls.sort((a, b) => a - b);
  let below = 0;
  for (const v of nulls) if (v < obs) below++;
  const pct = (100 * below) / PERMS;
  const lo = nulls[Math.floor(0.025 * PERMS)], hi = nulls[Math.floor(0.975 * PERMS)];
  console.log(`${label}: obs=${obs.toFixed(4)} null[2.5,97.5]=[${lo.toFixed(4)},${hi.toFixed(4)}] pct=${pct.toFixed(1)}`);
  return { obs, lo, hi, pct };
};

const ed = scoreSet(cellsED, "G_ED");
const er = scoreSet(cellsER, "G_ER");

const rf2 = ed.obs > 0 && ed.pct >= 97.5 ? "HOLDS"
  : ed.obs < 0 && ed.pct <= 2.5 ? "FAILS BY REVERSAL" : "NULL (uninformative)";
const verdicts = {
  "RF2 (distribution grows through E)": rf2,
  "secondary E>R (descriptive)": er.obs > 0 && er.pct >= 95 ? "holds" : "fails",
};
writeFileSync("isabelle-study/results-growth.json", JSON.stringify({
  kernels: kernelsUsed, cellsED: cellsED.length, cellsER: cellsER.length,
  G_ED: ed, G_ER: er, verdicts,
}, null, 1));
console.log(JSON.stringify(verdicts, null, 1));
