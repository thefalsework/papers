// Study 10, script 08 — structural pre-check for v1.3 (sizes only).
//
// BLINDNESS DISCIPLINE: this script computes d=2 counterfactual cone SIZES
// and quiescence classifications only. It never constructs a down-set
// algebra and never computes an aperture, so the v1.3 registration can cite
// its output while every prediction stays blind to outcomes.
//
// What it does:
//   1. For each of the 20 committed v1.1 soup histories, enumerate every
//      live cell at t=T (row-major), build its d=2 counterfactual cone,
//      record n and the focus's local quiescence class.
//   2. For the four new v1.3 still lifes (seeds-v13.json), standard focus
//      rule, d=2 cone size.
//   3. Report the size distribution and matched-stratum feasibility.
// Writes results/sizematch-precheck.json.

import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { join } from "node:path";
import {
  STUDY_DIR, SEEDS, buildRuns, pastCone, pickFocus, placeCentered, runCA,
  lifeRule, quiescenceClass,
} from "./ca-lib.mjs";

const V13 = JSON.parse(readFileSync(join(STUDY_DIR, "seeds-v13.json"), "utf8"));
const { H, W } = SEEDS.grid;
const T = SEEDS.T;

const runs = buildRuns();
const soups = runs.filter((r) => r.cond === "E");

const soupFoci = [];
for (const run of soups) {
  const g = run.hist[T];
  for (let r = 0; r < H; r++)
    for (let c = 0; c < W; c++) {
      if (!g[r][c]) continue;
      const cone = pastCone(run.hist, lifeRule, [r, c, T], 2);
      soupFoci.push({
        soup: run.name, r, c, n: cone.nodes.size,
        quiescence: quiescenceClass(run.hist, r, c, T),
      });
    }
}

const newStills = [];
for (const seed of V13.stillLifes) {
  const hist = runCA(placeCentered(seed.cells, H, W), T, lifeRule);
  const focus = pickFocus(hist, T);
  const cone = pastCone(hist, lifeRule, focus, 2);
  newStills.push({
    name: seed.name, focus, n: cone.nodes.size,
    quiescence: quiescenceClass(hist, focus[0], focus[1], T),
  });
}

// Size histogram of soup foci
const hist = new Map();
for (const f of soupFoci) hist.set(f.n, (hist.get(f.n) ?? 0) + 1);
const sizes = [...hist.keys()].sort((a, b) => a - b);
console.log(`soup foci enumerated: ${soupFoci.length} across ${soups.length} soups`);
console.log("n : count (still/p2/active)");
for (const n of sizes) {
  const fs = soupFoci.filter((f) => f.n === n);
  const q = (cl) => fs.filter((f) => f.quiescence === cl).length;
  console.log(`${String(n).padStart(2)} : ${String(fs.length).padStart(3)}  (${q("still")}/${q("p2")}/${q("active")})`);
}

console.log("\nnew still lifes at d=2:");
for (const s of newStills)
  console.log(`  ${s.name.padEnd(6)} n=${s.n}  quiescence=${s.quiescence}`);

// Matched-stratum feasibility: distinct soups offering a focus at each
// candidate stratum size (one focus per soup per stratum, first row-major).
console.log("\nmatched-stratum feasibility (distinct soups with >=1 focus at n):");
const bSizes = [...new Set([9, 23, ...newStills.map((s) => s.n)])].sort((a, b) => a - b);
const feasibility = {};
for (const n of bSizes) {
  const soupsWith = new Set(soupFoci.filter((f) => f.n === n).map((f) => f.soup));
  feasibility[n] = soupsWith.size;
  console.log(`  n=${String(n).padStart(2)} : ${soupsWith.size} soups`);
}

mkdirSync(join(STUDY_DIR, "results"), { recursive: true });
writeFileSync(join(STUDY_DIR, "results", "sizematch-precheck.json"),
  JSON.stringify({ soupFoci, newStills, feasibility }, null, 1));
console.log("\nwritten: results/sizematch-precheck.json (sizes and classes only; no apertures computed)");
