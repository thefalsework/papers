// Study 10, script 09 — the size-controlled study (v1.3 §2–§4).
//
// Gate: 01-anchors.mjs must PASS at run start (v1.3 §5); run it first.
//
// B side: seven still lifes (block, beehive, loaf + tub, pond, boat, ship),
// standard focus rule, d = 2, all re-measured under the v1.3 stream.
// E side: per committed soup, per stratum n* in {9, 16, 23}, the first
// row-major live focus at t = T whose d = 2 cone has exactly n* nodes.
// Estimator matched within stratum: exact for n <= 18, sampled 2^18
// (mulberry32 seed 20260825301, one stream in registered cone order) for
// n = 23. P7: stratified rank permutation test, one-sided B > E, 100,000
// permutations, seed 20260825302, alpha = 0.05. S1 (if P7 fails): n = 9
// still-class vs active-class soup foci, exact, Mann-Whitney at 0.05.
// Writes results/sizematch-v13.json.

import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { join } from "node:path";
import {
  STUDY_DIR, SEEDS, buildRuns, pastCone, pickFocus, placeCentered, runCA,
  conePoset, coneStudyMixed, lifeRule, mulberry32, mannWhitney, median,
  quiescenceClass,
} from "./ca-lib.mjs";

const V13 = JSON.parse(readFileSync(join(STUDY_DIR, "seeds-v13.json"), "utf8"));
const { H, W } = SEEDS.grid;
const T = SEEDS.T;
const STRATA = [9, 16, 23];
const SAMPLES = V13.sampledTier.samples;
const rng = mulberry32(V13.sampledTier.prngSeed);

// ---------------------------------------------------------------------------
// Assemble the registered cone list, in measurement order (v1.3 §2):
// B cones first (registered seed order), then E matched cones by stratum
// ascending, soups in committed seed order, then S1 extras at n = 9.
// ---------------------------------------------------------------------------
const cones = []; // { side, name, stratum, focus, hist, quiescence }

// B side: v1.1 still lifes in seeds.json order, then v1.3 additions.
const bSeeds = [...SEEDS.conditions.B, ...V13.stillLifes];
for (const seed of bSeeds) {
  const hist = runCA(placeCentered(seed.cells, H, W), T, lifeRule);
  const focus = pickFocus(hist, T);
  const n = pastCone(hist, lifeRule, focus, 2).nodes.size;
  cones.push({
    side: "B", name: seed.name, stratum: STRATA.includes(n) ? n : null,
    n, focus, hist, quiescence: quiescenceClass(hist, focus[0], focus[1], T),
  });
}

// E side: enumerate row-major foci per soup; first per stratum, plus first
// still-class and first active-class at n = 9 (S1).
const soups = buildRuns().filter((r) => r.cond === "E");
const eSelected = new Map(); // key soup|r|c -> cone record (dedup)
const s1Picks = { still: [], active: [] };
for (const nStar of STRATA) {
  for (const run of soups) {
    const g = run.hist[T];
    outer: for (let r = 0; r < H; r++)
      for (let c = 0; c < W; c++) {
        if (!g[r][c]) continue;
        const n = pastCone(run.hist, lifeRule, [r, c, T], 2).nodes.size;
        if (n !== nStar) continue;
        const key = `${run.name}|${r}|${c}`;
        if (!eSelected.has(key)) {
          const rec = {
            side: "E", name: `${run.name}@${r},${c}`, stratum: nStar, n,
            focus: [r, c, T], hist: run.hist,
            quiescence: quiescenceClass(run.hist, r, c, T),
          };
          eSelected.set(key, rec);
          cones.push(rec);
        }
        break outer;
      }
  }
}
// S1 selection at n = 9 (first still-class, first active-class per soup)
for (const cls of ["still", "active"]) {
  for (const run of soups) {
    const g = run.hist[T];
    outer: for (let r = 0; r < H; r++)
      for (let c = 0; c < W; c++) {
        if (!g[r][c]) continue;
        if (quiescenceClass(run.hist, r, c, T) !== cls) continue;
        const n = pastCone(run.hist, lifeRule, [r, c, T], 2).nodes.size;
        if (n !== 9) continue;
        const key = `${run.name}|${r}|${c}`;
        let rec = eSelected.get(key);
        if (!rec) {
          rec = {
            side: "E-S1", name: `${run.name}@${r},${c}`, stratum: 9, n,
            focus: [r, c, T], hist: run.hist, quiescence: cls,
          };
          eSelected.set(key, rec);
          cones.push(rec);
        }
        s1Picks[cls].push(rec);
        break outer;
      }
  }
}

// ---------------------------------------------------------------------------
// Measure every cone, one shared rng stream in list order.
// ---------------------------------------------------------------------------
for (const cone of cones) {
  const P = conePoset(pastCone(cone.hist, lifeRule, cone.focus, 2));
  const st = coneStudyMixed(P, 18, SAMPLES, rng);
  cone.result = st;
  delete cone.hist;
  console.log(
    `${cone.side.padEnd(4)} ${cone.name.padEnd(24)} n=${st.n} [${st.estimator}] ` +
    `q=${cone.quiescence.padEnd(6)} medAp=${st.medianApFraction.toFixed(5)} ` +
    `maxAp=${st.maxApFraction.toFixed(5)} latent=${st.latentCount}/${st.n} ord=${st.ordinaryAtIdCount}`
  );
}

// ---------------------------------------------------------------------------
// P7: stratified rank permutation test (one-sided, B > E)
// ---------------------------------------------------------------------------
function ranksWithTies(vals) {
  const order = vals.map((v, i) => [v, i]).sort((a, b) => a[0] - b[0]);
  const ranks = new Array(vals.length);
  let i = 0;
  while (i < order.length) {
    let j = i;
    while (j < order.length && order[j][0] === order[i][0]) j++;
    const r = (i + j + 1) / 2;
    for (let k = i; k < j; k++) ranks[order[k][1]] = r;
    i = j;
  }
  return ranks;
}

const strata = STRATA.map((nStar) => {
  const B = cones.filter((c) => c.side === "B" && c.stratum === nStar);
  const E = cones.filter((c) => c.side === "E" && c.stratum === nStar);
  const vals = [...B, ...E].map((c) => c.result.medianApFraction);
  return { nStar, bCount: B.length, eCount: E.length,
           B: B.map((c) => c.name), E: E.map((c) => c.name),
           ranks: ranksWithTies(vals), vals };
});

const tObs = strata.reduce(
  (s, st) => s + st.ranks.slice(0, st.bCount).reduce((a, b) => a + b, 0), 0);

const ITERS = 100000;
const permRng = mulberry32(20260825302);
let geq = 0;
for (let it = 0; it < ITERS; it++) {
  let t = 0;
  for (const st of strata) {
    // partial Fisher-Yates: draw bCount distinct indices from 0..len-1
    const len = st.ranks.length;
    const idx = Array.from({ length: len }, (_, i) => i);
    for (let k = 0; k < st.bCount; k++) {
      const j = k + Math.floor(permRng() * (len - k));
      [idx[k], idx[j]] = [idx[j], idx[k]];
      t += st.ranks[idx[k]];
    }
  }
  if (t >= tObs) geq++;
}
const pP7 = (1 + geq) / (1 + ITERS);
const p7Holds = pP7 < 0.05;

console.log("\n=== P7 (size-controlled figure-vs-ground) ===");
for (const st of strata) {
  const bMed = median(st.vals.slice(0, st.bCount));
  const eMed = median(st.vals.slice(st.bCount));
  console.log(`stratum n=${st.nStar}: B(${st.bCount}) med=${bMed.toFixed(5)}  E(${st.eCount}) med=${eMed.toFixed(5)}`);
}
console.log(`T_obs=${tObs.toFixed(1)}  one-sided p=${pP7.toFixed(5)} (${ITERS} permutations)  -> P7 ${p7Holds ? "HOLDS" : "FAILS"}`);

// ---------------------------------------------------------------------------
// S1 (evaluated only if P7 fails; counts always disclosed)
// ---------------------------------------------------------------------------
let s1 = null;
if (!p7Holds) {
  const stillVals = s1Picks.still.map((c) => c.result.medianApFraction);
  const activeVals = s1Picks.active.map((c) => c.result.medianApFraction);
  const mw = mannWhitney(stillVals, activeVals);
  s1 = {
    still: s1Picks.still.map((c) => ({ name: c.name, medAp: c.result.medianApFraction })),
    active: s1Picks.active.map((c) => ({ name: c.name, medAp: c.result.medianApFraction })),
    stillMed: median(stillVals), activeMed: median(activeVals), ...mw,
  };
  console.log("\n=== S1 (quiescence disambiguation, n = 9 soup foci) ===");
  console.log(`still-class  (${stillVals.length}): med=${s1.stillMed.toFixed(5)}  [${stillVals.map((v) => v.toFixed(5)).join(", ")}]`);
  console.log(`active-class (${activeVals.length}): med=${s1.activeMed.toFixed(5)}  [${activeVals.map((v) => v.toFixed(5)).join(", ")}]`);
  console.log(`Mann-Whitney U=${mw.U1} z=${mw.z.toFixed(3)} p=${mw.p.toFixed(5)}`);
  console.log(`reading: ${mw.p < 0.05 && s1.stillMed > s1.activeMed ? "R2 (relocation: quiescent figure carries signal)" : "R3-leaning (no quiescence effect at matched size)"}`);
} else {
  console.log("\nS1: not evaluated (P7 holds).");
}

// ---------------------------------------------------------------------------
// S2 (new still lifes, descriptive) and S3 (size effect on E side)
// ---------------------------------------------------------------------------
console.log("\n=== S2 (still-life profiles, descriptive) ===");
for (const c of cones.filter((c) => c.side === "B"))
  console.log(`${c.name.padEnd(8)} n=${c.n} medAp=${c.result.medianApFraction.toFixed(5)} latent=${c.result.latentCount}/${c.n}`);

console.log("\n=== S3 (E-side size effect, descriptive) ===");
for (const st of strata)
  console.log(`E stratum n=${st.nStar}: median of medAp = ${median(st.vals.slice(st.bCount)).toFixed(5)} (${st.eCount} cones)`);

mkdirSync(join(STUDY_DIR, "results"), { recursive: true });
writeFileSync(join(STUDY_DIR, "results", "sizematch-v13.json"), JSON.stringify({
  cones: cones.map(({ hist, ...c }) => c),
  P7: { tObs, iters: ITERS, p: pP7, holds: p7Holds,
        strata: strata.map(({ ranks, vals, ...s }) => ({ ...s,
          bMed: median(vals.slice(0, s.bCount)), eMed: median(vals.slice(s.bCount)) })) },
  S1: s1,
}, null, 1));
console.log("\nwritten: results/sizematch-v13.json");
