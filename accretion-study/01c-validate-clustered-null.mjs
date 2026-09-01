// Accretion study, Phase A addendum 2 — does the KERNEL-CLUSTERED
// sign-flip null recover the honest (across-universe) variance?
//
// From 01b: across-universe SD of Delta_ER on U-universes is ~0.055
// (honest half-band ~0.11); the pair-level sign-flip half-band is
// ~0.010 (11x too narrow). If flipping all pairs of a kernel together
// yields half-bands near the honest one, the clustered null is the
// corrected standard and the field studies get re-scored with it.
// If it still falls short (members recur across kernels too), the
// shortfall is measured here and reported alongside.
//
// Exploratory tier; 5 U-universes and 5 PA-universes, both null modes.

import { grow, toSnaps, runEstimator } from "./sim-lib.mjs";

const N = 30000;
const SCHEDULE = [5000, 10000, 15000, 20000, 25000, 30000];
const OPTS = { baselines: [0, 1, 2, 3], horizon: 2, kernelCap: 300 };

for (const [label, rule] of [["U", "U"], ["PA", "PA"]]) {
  console.log(`${label}: honest half-band target from 01b: ER ~${label === "U" ? 0.109 : 0.121}, ED ~${label === "U" ? 0.055 : 0.066}`);
  for (let r = 0; r < 5; r++) {
    const grown = grow(rule, N, SCHEDULE, 905000 + 100 * r + (label === "U" ? 1 : 2)); // same universes as 01b replicates 0-4
    const snaps = toSnaps(grown, SCHEDULE);
    const pair = runEstimator(snaps, { ...OPTS, seed: 905999 + r, nullMode: "pair" });
    const kern = runEstimator(snaps, { ...OPTS, seed: 905999 + r, nullMode: "kernel" });
    const hb = (x) => x.obs === undefined ? "n/a" : ((x.hi - x.lo) / 2).toFixed(4);
    console.log(`  u${r}: ER obs=${pair.ER.obs} band pair=${hb(pair.ER)} kernel=${hb(kern.ER)} | ED obs=${pair.ED.obs} band pair=${hb(pair.ED)} kernel=${hb(kern.ED)}`);
  }
}
