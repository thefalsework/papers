// Accretion study, Phase D — THE ORACLE TEST (registered before first
// run; the decisive lab experiment of THEORY.md §3's updated suspect
// list).
//
// THE QUESTION: what structure is the cell partition seeing in PC(0)
// universes that survives all six battery features (03-sign S3,
// t = -5.6)? In the lab we wrote the rule, so the true per-step gain
// functional is COMPUTABLE, not conjectural. For PC(0) a baseline
// node x gains, per future step, in proportion to
//
//   flux(x) = c1 + c2 * ORACLE(x),  ORACLE(x) = sum over platforms u
//             with x in cone_200(u) of 1/|cone_200(u)|
//
// (one term for being drawn as platform — uniform, common to all;
// one for being drawn out of a platform's truncated cone). ORACLE is
// computed here from the grower's exact structure: cones are FIFO
// BFS over the raw dependency lists, cap 200, excluding the platform,
// byte-matching sim-lib's coneOf. Approximation, named in advance:
// baseline cones only — cones of nodes born DURING the horizon also
// recruit, and gains feed back into cones. Whatever residual remains
// after matching ORACLE is the measure of that feedback.
//
// Also computed: EXACT (uncapped) up-set size via reverse-topological
// bitset DP — the intermediate rung between upset_200 and the oracle
// (is the 200-cap the whole story?).
//
// DESIGN: 10 fresh PC(0) universes (grow seeds 950000+r, estimator
// seeds 955000+r; disjoint from A/B'/03). Same pairing machinery as
// 03-sign (baselines 0..3, horizon +2, kernel cap 300, caliper 0.5).
// Three battery variants per universe:
//   A: 5 std features + log1p(exactUpset)          (cap suspect)
//   B: 5 std features + log1p(ORACLE)              (the oracle test)
//   C: 5 std + upset200 + exactUpset + ORACLE      (kitchen sink)
// Statistic: across-universe mean pair gain diff (E - R), t over 10.
//
// REGISTERED PREDICTIONS (thresholds fixed now):
//   O1: pooled corr(log1p(ORACLE), gain) > corr(log1p(upset200), gain)
//       in EVERY universe (10/10) — the oracle is the better predictor
//       or the derivation is wrong.
//   O2 (decisive): battery B across-universe mean Delta_ER at |t| < 2
//       = CONFIRMS (the cell's residual signal IS oracle flux; the
//       mechanism is fully identified). |t| >= 3 = RESIDUAL (feedback
//       or deeper structure; the relational hypothesis is promoted).
//       Between: INDETERMINATE.
//   O3: battery A at |t| >= 3 = the 200-cap was NOT the story
//       (exact counts do not close it either); |t| < 2 = the cap was
//       the whole story and THEORY.md's suspect (a) wins.
//   Descriptive: battery C, and per-universe corr values.
//
// Writes accretion-study/results-oracle.json.
//
// ---------------------------------------------------------------------
// POSTSCRIPT (2026-09-01, after the single registered run; 10 fresh
// universes, ~80k ER pairs per universe per battery)
//
// O1 CONFIRMS, 10/10: corr(ORACLE, gain) ~ 0.41-0.52 in every
// universe vs 0.20-0.29 for upset_200. The derived functional is the
// best single predictor of growth, everywhere, as the flux law says.
//
// O2 CONFIRMS — MECHANISM FULLY IDENTIFIED: with log1p(ORACLE) in the
// battery, the across-universe mean Delta_ER = -0.0044, t = -0.25.
// The R > E effect — which stood at -0.17 (t = -10) against battery
// v1 and -0.12 (t = -5.6) against battery v2 — VANISHES COMPLETELY
// when cone-weighted membership mass is matched. Nothing is left for
// feedback to explain. In PC(0) universes, "what the cell was seeing"
// now has a closed-form answer:
//
//     ORACLE(x) = sum over platforms u with x in cone(u) of 1/|cone(u)|
//
// — membership in many SMALL dependency footprints. You grow by being
// a large share of many toolchains, not by having many dependents.
//
// O3: CAP NOT THE STORY (t = -7.0): EXACT uncapped descendant counts
// leave the effect at -0.147 — barely better than capped. This is the
// sharpest lesson of the day: the missing structure was never volume
// of reach, it was CONCENTRATION of reach. Two nodes with identical
// descendant counts differ enormously in flux if one sits inside a
// few giant cones and the other inside many small ones. No count
// feature sees that; the harmonic weighting does.
//
// WHY THIS MATTERS BEYOND THE LAB: ORACLE(x) is computable on ANY
// dependency graph without knowing the growth rule — it is a pure
// graph feature (harmonic cone-membership mass). It is therefore
// admissible as a field battery feature. BATTERY V3 = v2 + ORACLE is
// now defined, and Debian's certified claim has exactly one more
// knife to survive. If it survives: the cell carries signal beyond
// the very functional that fully explains the best synthetic
// counterexample — the strongest certification this method can
// produce. If it dissolves: package-ecosystem growth is harmonic
// cone-mass flux, the cells were reading it, and the program has a
// complete mechanistic account of the field effect. Either branch is
// a result worth having; the field run should be registered next.
// ---------------------------------------------------------------------

import { writeFileSync } from "node:fs";
import { grow, toSnaps, mulberry } from "./sim-lib.mjs";
import { firstSeenOf, makeGate, makeDistancer } from "../deflation-control/lib.mjs";
import { pagerank, coreNumbers, zStats, greedyMatch } from "../baseline-gauntlet/gauntlet-lib.mjs";

const N = 30000;
const SCHEDULE = [5000, 10000, 15000, 20000, 25000, 30000];
const BASELINES = [0, 1, 2, 3], HORIZON = 2, KERNEL_CAP = 300;
const CALIPER = 0.5, SIDE_CAP = 300, CONE_CAP = 200;
const R = 10;

// deps lists for nodes < T, in the grower's insertion order
const depsAt = (grown, T) => {
  const deps = Array.from({ length: T }, () => []);
  const nEdges = grown.edgeCountAt.get(T);
  for (let i = 0; i < nEdges; i++) {
    const [a, b] = grown.edges[i];
    deps[a].push(b);
  }
  return deps;
};

// ORACLE(x) = sum over u of 1/|cone_200(u)| for x in cone_200(u),
// cones FIFO-BFS over deps, cap 200, excluding u (sim-lib's coneOf).
const oracleOf = (deps) => {
  const T = deps.length;
  const orc = new Float64Array(T);
  const seen = new Int32Array(T).fill(-1);
  for (let u = 0; u < T; u++) {
    const cone = [];
    seen[u] = u;
    const q = [u];
    while (q.length && cone.length < CONE_CAP) {
      const v = q.shift();
      for (const w of deps[v]) {
        if (seen[w] === u) continue;
        seen[w] = u;
        cone.push(w);
        if (cone.length >= CONE_CAP) break;
        q.push(w);
      }
    }
    if (!cone.length) continue;
    const credit = 1 / cone.length;
    for (const x of cone) orc[x] += credit;
  }
  return orc;
};

// exact up-set sizes via bitset DP in reverse birth order (dependents
// of x are always born after x, so descending index is topological)
const exactUpsetOf = (deps) => {
  const T = deps.length;
  const words = (T + 31) >> 5;
  const dependents = Array.from({ length: T }, () => []);
  for (let a = 0; a < T; a++) for (const b of deps[a]) dependents[b].push(a);
  const bits = new Array(T);
  const sizes = new Int32Array(T);
  for (let x = T - 1; x >= 0; x--) {
    const mine = new Uint32Array(words);
    for (const y of dependents[x]) {
      mine[y >> 5] |= 1 << (y & 31);
      const by = bits[y];
      for (let w = 0; w < words; w++) mine[w] |= by[w];
    }
    bits[x] = mine;
    let cnt = 0;
    for (let w = 0; w < words; w++) {
      let v = mine[w];
      v = v - ((v >>> 1) & 0x55555555);
      v = (v & 0x33333333) + ((v >>> 2) & 0x33333333);
      cnt += (((v + (v >>> 4)) & 0x0f0f0f0f) * 0x01010101) >>> 24;
    }
    sizes[x] = cnt;
  }
  return sizes;
};

const measure = (r) => {
  const grown = grow(0, N, SCHEDULE, 950000 + r);
  const snaps = toSnaps(grown, SCHEDULE);
  const fsMap = firstSeenOf(snaps);
  const rand = mulberry(955000 + r);
  const acc = {};
  for (const key of ["A", "B", "C"]) acc[key] = { ER: [], ED: [] };
  const corrStats = { oracle: { n: 0, sx: 0, sy: 0, sxx: 0, syy: 0, sxy: 0 },
                      up200: { n: 0, sx: 0, sy: 0, sxx: 0, syy: 0, sxy: 0 } };
  for (const ti of BASELINES) {
    const snap = snaps[ti];
    const fut = snaps[ti + HORIZON];
    const T = SCHEDULE[ti];
    const deps = depsAt(grown, T);
    const orcRaw = oracleOf(deps);
    const exRaw = exactUpsetOf(deps);
    // capped up-set for the correlation comparison (from cOut on snap
    // would equal battery-v2's upsetSizes; recompute rawly for parity)
    const up200Raw = new Int32Array(T);
    {
      const dependents = Array.from({ length: T }, () => []);
      for (let a = 0; a < T; a++) for (const b of deps[a]) dependents[b].push(a);
      const seen = new Int32Array(T).fill(-1);
      for (let x = 0; x < T; x++) {
        let cnt = 0;
        seen[x] = x;
        const q = [x];
        while (q.length && cnt < 200) {
          const v = q.shift();
          for (const w of dependents[v]) {
            if (seen[w] === x) continue;
            seen[w] = x;
            cnt++;
            if (cnt >= 200) break;
            q.push(w);
          }
        }
        up200Raw[x] = cnt;
      }
    }
    const gate = makeGate(snap);
    const distancer = makeDistancer(snap);
    const { nComp, compMembers, names, inDeg } = snap;
    const pr = pagerank(snap);
    const core = coreNumbers(snap);
    const globalRows = [];
    for (let c = 0; c < nComp; c++) {
      if (compMembers[c].length > 1) continue;
      if (!fut.inDeg.has(names[compMembers[c][0]])) continue;
      globalRows.push(c);
    }
    const rawOf = (c) => parseInt(names[compMembers[c][0]].slice(1), 10);
    const gIn = zStats(globalRows.map((c) => Math.log1p(inDeg.get(names[compMembers[c][0]]) ?? 0)));
    const gOut = zStats(globalRows.map((c) => Math.log1p(snap.cIn[c].length)));
    const gAge = zStats(globalRows.map((c) => fsMap.get(names[compMembers[c][0]])));
    const gPR = zStats(globalRows.map((c) => Math.log(pr[c])));
    const gCore = zStats(globalRows.map((c) => core[c]));
    const gU2 = zStats(globalRows.map((c) => Math.log1p(up200Raw[rawOf(c)])));
    const gEx = zStats(globalRows.map((c) => Math.log1p(exRaw[rawOf(c)])));
    const gOr = zStats(globalRows.map((c) => Math.log1p(orcRaw[rawOf(c)])));
    const featOf = (c) => {
      const nm = names[compMembers[c][0]];
      const raw = rawOf(c);
      return [
        (Math.log1p(inDeg.get(nm) ?? 0) - gIn.mu) / gIn.sd,
        (Math.log1p(snap.cIn[c].length) - gOut.mu) / gOut.sd,
        (fsMap.get(nm) - gAge.mu) / gAge.sd,
        (Math.log(pr[c]) - gPR.mu) / gPR.sd,
        (core[c] - gCore.mu) / gCore.sd,
        (Math.log1p(up200Raw[raw]) - gU2.mu) / gU2.sd,
        (Math.log1p(exRaw[raw]) - gEx.mu) / gEx.sd,
        (Math.log1p(orcRaw[raw]) - gOr.mu) / gOr.sd,
      ];
    };
    // battery variants as index lists into the 8-feature vector
    const VARIANTS = { A: [0, 1, 2, 3, 4, 6], B: [0, 1, 2, 3, 4, 7], C: [0, 1, 2, 3, 4, 5, 6, 7] };
    const gainOf = (c) => {
      const nm = names[compMembers[c][0]];
      return (fut.inDeg.get(nm) ?? 0) - (inDeg.get(nm) ?? 0);
    };
    for (const c of globalRows) {
      const y = gainOf(c), raw = rawOf(c);
      for (const [key, x] of [["oracle", Math.log1p(orcRaw[raw])], ["up200", Math.log1p(up200Raw[raw])]]) {
        const s = corrStats[key];
        s.n++; s.sx += x; s.sy += y; s.sxx += x * x; s.syy += y * y; s.sxy += x * y;
      }
    }
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
      used++;
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
      for (const [side, bSide] of [["ER", "R"], ["ED", "D"]]) {
        for (const [d, eMembers] of groups.E) {
          const bMembers = groups[bSide].get(d);
          if (!bMembers) continue;
          const eCap = cap([...eMembers]), bCap = cap([...bMembers]);
          const fE = eCap.map(featOf), fB = bCap.map(featOf);
          for (const [vKey, idx] of Object.entries(VARIANTS)) {
            const pairs = greedyMatch(fE.map((f) => idx.map((i) => f[i])), fB.map((f) => idx.map((i) => f[i])), CALIPER, rand);
            for (const [ei, bi] of pairs) acc[vKey][side].push(gainOf(eCap[ei]) - gainOf(bCap[bi]));
          }
        }
      }
    }
  }
  const mean = (xs) => (xs.length ? xs.reduce((s, v) => s + v, 0) / xs.length : null);
  const corrOf = (s) => (s.sxy / s.n - (s.sx / s.n) * (s.sy / s.n)) /
    (Math.sqrt(s.sxx / s.n - (s.sx / s.n) ** 2) * Math.sqrt(s.syy / s.n - (s.sy / s.n) ** 2));
  const res = { corrOracle: +corrOf(corrStats.oracle).toFixed(4), corrUp200: +corrOf(corrStats.up200).toFixed(4) };
  for (const key of ["A", "B", "C"]) {
    res[key] = { ER: +mean(acc[key].ER)?.toFixed(4), pairsER: acc[key].ER.length, ED: +mean(acc[key].ED)?.toFixed(4) };
  }
  return res;
};

const summarize = (xs) => {
  const n = xs.length;
  const mu = xs.reduce((s, v) => s + v, 0) / n;
  const sd = Math.sqrt(xs.reduce((s, v) => s + (v - mu) * (v - mu), 0) / (n - 1));
  return { mu: +mu.toFixed(4), sd: +sd.toFixed(4), t: +(mu / (sd / Math.sqrt(n))).toFixed(2) };
};

const universes = [];
for (let r = 0; r < R; r++) {
  const res = measure(r);
  universes.push(res);
  console.log(`u${r}: corrOracle=${res.corrOracle} corrUp200=${res.corrUp200} | A.ER=${res.A.ER} B.ER=${res.B.ER} C.ER=${res.C.ER} (pairs ~${res.B.pairsER})`);
}

const out = { universes };
out.O1 = { wins: universes.filter((u) => u.corrOracle > u.corrUp200).length,
           verdict: universes.every((u) => u.corrOracle > u.corrUp200) ? "CONFIRMS" : "FAILS" };
const sB = summarize(universes.map((u) => u.B.ER));
out.O2 = { ...sB, verdict: Math.abs(sB.t) < 2 ? "CONFIRMS (mechanism fully identified)" : Math.abs(sB.t) >= 3 ? "RESIDUAL (feedback or deeper structure)" : "INDETERMINATE" };
const sA = summarize(universes.map((u) => u.A.ER));
out.O3 = { ...sA, verdict: Math.abs(sA.t) >= 3 ? "CAP NOT THE STORY" : Math.abs(sA.t) < 2 ? "CAP WAS THE STORY" : "INDETERMINATE" };
out.C_ER = summarize(universes.map((u) => u.C.ER));
console.log(JSON.stringify({ O1: out.O1, O2: out.O2, O3: out.O3, C: out.C_ER }, null, 1));
writeFileSync("accretion-study/results-oracle.json", JSON.stringify(out, null, 1));
console.log("wrote accretion-study/results-oracle.json");
