// Deflation control, blind pre-check.
//
// BLINDNESS DISCIPLINE: this script computes STRUCTURAL occupancy only —
// per corpus, how many (kernel x stratum) cells contain both an E and an
// R member once EXACT undirected distance-to-kernel is added to the
// stratum key (degree bin x first-seen x distance), and the distance
// distributions of E and R members. It never reads a horizon snapshot's
// in-degrees as outcomes: no gain is computed anywhere. It cannot leak
// the alignment that 02 predicts.
//
// WHY THE DISTANCE DISTRIBUTIONS ARE REPORTED: the skeptic's compression
// of E > R is "connected periphery grows, disconnected doesn't." If E
// and R occupy disjoint distance ranges, the matched comparison barely
// exists — which would itself be a finding (the cells ARE distance
// classes at this grain), distinct from either survival or deflation.
// The pre-check measures whether the question is askable before 02 asks
// it.
//
// Writes deflation-control/results-precheck.json.

import { writeFileSync } from "node:fs";
import { BIN, CORPORA, firstSeenOf, makeGate, makeDistancer, CRATES_KERNELS } from "./lib.mjs";

const SEED = 20260830101;
let rngState = SEED;
const rand = () => {
  rngState |= 0; rngState = (rngState + 0x6d2b79f5) | 0;
  let t = Math.imul(rngState ^ (rngState >>> 15), 1 | rngState);
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};

const out = {};
for (const corpus of ["mathlib", "afp", "isabelle", "go", "crates"]) {
  const { subs, baselines, horizon } = CORPORA[corpus]();
  let kernels = 0;
  let erCellsNoDist = 0, erCellsDist = 0, erWeightDist = 0;
  let edCellsDist = 0, edWeightDist = 0;
  const distCount = { E: new Map(), R: new Map(), D: new Map() };
  for (const snaps of subs) {
    const fsMap = firstSeenOf(snaps);
    for (const ti of baselines) {
      const snap = snaps[ti];
      const fut = snaps[ti + horizon];
      const gate = makeGate(snap);
      const distancer = makeDistancer(snap);
      const { nComp, compMembers, names, inDeg } = snap;
      let order = Array.from({ length: nComp }, (_, i) => i);
      if (corpus === "crates") {
        for (let i = 0; i < nComp; i++) {
          const j = i + Math.floor(rand() * (nComp - i));
          const t = order[i]; order[i] = order[j]; order[j] = t;
        }
      }
      let used = 0;
      for (const a of order) {
        if (corpus === "crates" && used >= CRATES_KERNELS) break;
        const g = gate(a);
        if (!g) continue;
        used++; kernels++;
        const dOf = distancer(g.downMembers);
        const noDist = new Map(), withDist = new Map();
        for (let c = 0; c < nComp; c++) {
          const cell = g.cellOf(c);
          if (cell === "I") continue;
          const members = compMembers[c];
          if (members.length > 1) continue;
          const nm = names[members[0]];
          if (!fut.inDeg.has(nm)) continue; // survival filter only; no outcome read
          const d = dOf(c);
          const dKey = d === -1 ? "inf" : String(d);
          distCount[cell].set(dKey, (distCount[cell].get(dKey) ?? 0) + 1);
          const k0 = `${BIN(inDeg.get(nm) ?? 0)}|${fsMap.get(nm)}`;
          const k1 = `${k0}|${dKey}`;
          if (!noDist.has(k0)) noDist.set(k0, { E: 0, D: 0, R: 0 });
          noDist.get(k0)[cell]++;
          if (!withDist.has(k1)) withDist.set(k1, { E: 0, D: 0, R: 0 });
          withDist.get(k1)[cell]++;
        }
        for (const [, s] of noDist) if (s.E && s.R) erCellsNoDist++;
        for (const [, s] of withDist) {
          if (s.E && s.R) { erCellsDist++; erWeightDist += Math.min(s.E, s.R); }
          if (s.E && s.D) { edCellsDist++; edWeightDist += Math.min(s.E, s.D); }
        }
      }
    }
  }
  const distTable = {};
  for (const cell of ["E", "D", "R"]) {
    distTable[cell] = Object.fromEntries(
      [...distCount[cell].entries()].sort((x, y) =>
        (x[0] === "inf" ? 1e9 : +x[0]) - (y[0] === "inf" ? 1e9 : +y[0])),
    );
  }
  out[corpus] = {
    kernels, erCellsNoDist, erCellsDist, erWeightDist, edCellsDist, edWeightDist, distTable,
  };
  console.log(
    `${corpus}: kernels=${kernels} ER cells ${erCellsNoDist} -> ${erCellsDist} with distance ` +
    `(matched weight ${erWeightDist}); ED cells with distance ${edCellsDist} (w ${edWeightDist})`,
  );
  console.log(`  dist E: ${JSON.stringify(distTable.E)}`);
  console.log(`  dist R: ${JSON.stringify(distTable.R)}`);
}
writeFileSync("deflation-control/results-precheck.json", JSON.stringify(out, null, 1));
console.log("wrote deflation-control/results-precheck.json");
