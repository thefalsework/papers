// Accretion study: growers and the shared estimator.
// Everything here implements accretion-study/SPEC.md sections 2-4
// exactly; the SPEC is the contract, this file is plumbing.
//
// Growers return { edges, edgeCountAt } for a target size and snapshot
// schedule; snapshots are free because edges only point backwards.
// The estimator is the Debian-grade pair-matched battery design,
// lifted from debian-study/03-bet.mjs and parametrized so Phase A and
// Phase B run byte-identical scoring code.

import { buildSnap, makeGate, makeDistancer, firstSeenOf } from "../deflation-control/lib.mjs";
import { pagerank, coreNumbers, zStats, greedyMatch } from "../baseline-gauntlet/gauntlet-lib.mjs";

export const mulberry = (seed) => {
  let s = seed;
  return () => {
    s |= 0; s = (s + 0x6d2b79f5) | 0;
    let t = Math.imul(s ^ (s >>> 15), 1 | s);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
};

const CONE_CAP = 200; // SPEC 3: truncated BFS cap for platform cones

// rule: "U" | "PA" | number beta in [0,1] for PC(beta)
export const grow = (rule, N, schedule, seed) => {
  const rand = mulberry(seed);
  const edges = [];
  const depsOf = []; // per node, its dependency list (for cone BFS)
  const bag = [];    // PA bag: node appears (inDeg + 1) times
  const edgeCountAt = new Map();
  let schedIdx = 0;
  for (let t = 0; t < N; t++) {
    while (schedIdx < schedule.length && schedule[schedIdx] === t) {
      edgeCountAt.set(schedule[schedIdx], edges.length);
      schedIdx++;
    }
    const myDeps = new Set();
    // m uniform {0..4}: the zero mass makes some nodes dependency ROOTS.
    // Without roots every chain terminates at node 0, a universal
    // ancestor sits in every down-set, Refusal is empty for every
    // kernel, and nothing is evaluable (Phase A census finding,
    // 2026-09-01; see SPEC postscript). Real corpora are full of roots.
    if (t > 0) {
      const m = Math.floor(rand() * 5);
      if (rule === "U") {
        for (let k = 0; k < m; k++) myDeps.add(Math.floor(rand() * t));
      } else if (rule === "PA") {
        for (let k = 0; k < m; k++) myDeps.add(bag[Math.floor(rand() * bag.length)]);
      } else {
        // PC(beta): UNIFORM platform, then cone/global mix. Platform
        // choice was PA-weighted in the first draft; that funnels every
        // cone through a few primordial hubs, a universal ancestor ends
        // up in every down-set, and the partition degenerates globally
        // (Phase A census finding, 2026-09-01; see SPEC postscript).
        // Uniform platforms keep the mechanism under test (cone
        // locality) and lose only the popularity confound, which the
        // estimator matches away anyway.
        const beta = rule;
        if (m >= 1) {
        const u = Math.floor(rand() * t);
        myDeps.add(u);
        // truncated BFS cone of u (excluding u)
        let cone = null;
        for (let k = 1; k < m; k++) {
          if (rand() < beta) {
            myDeps.add(Math.floor(rand() * t));
          } else {
            if (cone === null) {
              cone = [];
              const seen = new Set([u]);
              const q = [u];
              while (q.length && cone.length < CONE_CAP) {
                const v = q.shift();
                for (const w of depsOf[v]) {
                  if (seen.has(w)) continue;
                  seen.add(w);
                  cone.push(w);
                  if (cone.length >= CONE_CAP) break;
                  q.push(w);
                }
              }
            }
            if (cone.length === 0) myDeps.add(Math.floor(rand() * t)); // sterile platform: fall back
            else myDeps.add(cone[Math.floor(rand() * cone.length)]);
          }
        }
        }
      }
    }
    const list = [...myDeps];
    depsOf.push(list);
    for (const d of list) { edges.push([t, d]); bag.push(d); }
    bag.push(t); // birth weight
  }
  while (schedIdx < schedule.length) { edgeCountAt.set(schedule[schedIdx], edges.length); schedIdx++; }
  return { edges, edgeCountAt };
};

export const toSnaps = (grown, schedule) => {
  return schedule.map((T) => {
    const names = Array.from({ length: T }, (_, i) => "n" + i);
    const edges = grown.edges.slice(0, grown.edgeCountAt.get(T));
    return buildSnap(names, edges);
  });
};

// The Debian-grade estimator (SPEC 4). Returns per-contrast results.
// nullMode: "pair" (the original within-pair sign flip; understates
// variance under cross-pair dependence — see 01b calibration) or
// "kernel" (flips all pairs of one kernel together; the clustered
// null adopted after the audit).
export const runEstimator = (snaps, { baselines, horizon, kernelCap, seed, nullMode = "pair" }) => {
  const CALIPER = 0.5, SIDE_CAP = 300, PERMS = 1000, MIN_PAIRS = 50, SMD_GATE = 0.10;
  const FEATS = ["logIn", "logOut", "age", "logPR", "core"];
  const rand = mulberry(seed);
  const fsMap = firstSeenOf(snaps);
  const out = { ER: { diffs: [], kernelOf: [], sumE: FEATS.map(() => 0), sumB: FEATS.map(() => 0) },
                ED: { diffs: [], kernelOf: [], sumE: FEATS.map(() => 0), sumB: FEATS.map(() => 0) } };
  let kernels = 0, candE = 0, candR = 0, candD = 0;
  for (const ti of baselines) {
    const snap = snaps[ti];
    const fut = snaps[ti + horizon];
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
      candE += [...groups.E.values()].reduce((s, v) => s + v.length, 0);
      candR += [...groups.R.values()].reduce((s, v) => s + v.length, 0);
      candD += [...groups.D.values()].reduce((s, v) => s + v.length, 0);
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
            acc.kernelOf.push(kernels - 1);
            for (let k = 0; k < FEATS.length; k++) {
              acc.sumE[k] += fE[ei][k];
              acc.sumB[k] += fB[bi][k];
            }
          }
        }
      }
    }
  }
  const results = { kernels, candE, candR, candD };
  for (const contrast of ["ER", "ED"]) {
    const { diffs, kernelOf, sumE, sumB } = out[contrast];
    const n = diffs.length;
    const smd = FEATS.map((f, k) => (n ? Math.abs(sumE[k] - sumB[k]) / n : null));
    const maxSmd = n ? Math.max(...smd) : null;
    if (!n || n < MIN_PAIRS) { results[contrast] = { pairs: n, verdict: "UNINFORMATIVE" }; continue; }
    if (maxSmd > SMD_GATE) { results[contrast] = { pairs: n, maxSmd, verdict: "INFEASIBLE" }; continue; }
    let obs = 0;
    for (const d of diffs) obs += d;
    obs /= n;
    // per-kernel diff sums for clustered flips
    const kSum = new Map();
    for (let i = 0; i < n; i++) kSum.set(kernelOf[i], (kSum.get(kernelOf[i]) ?? 0) + diffs[i]);
    const kVals = [...kSum.values()];
    const nulls = [];
    for (let p = 0; p < PERMS; p++) {
      let s = 0;
      if (nullMode === "kernel") {
        for (const v of kVals) s += rand() < 0.5 ? v : -v;
      } else {
        for (const d of diffs) s += rand() < 0.5 ? d : -d;
      }
      nulls.push(s / n);
    }
    nulls.sort((a, b) => a - b);
    let below = 0;
    for (const v of nulls) if (v < obs) below++;
    const pct = (100 * below) / PERMS;
    const lo = nulls[Math.floor(0.025 * PERMS)], hi = nulls[Math.floor(0.975 * PERMS)];
    const verdict = obs > 0 && pct >= 97.5 ? "HOLDS" : obs < 0 && pct <= 2.5 ? "REVERSES" : "NULL";
    results[contrast] = { pairs: n, maxSmd: +maxSmd.toFixed(4), obs: +obs.toFixed(4), lo: +lo.toFixed(4), hi: +hi.toFixed(4), pct, verdict };
  }
  return results;
};
