// Resolution pre-check for the cell-composition study v2 (blind to cells).
//
// WHAT THIS COMPUTES AND WHY IT IS BLIND. v1 (script 10) saturated: the
// shared-prefix median is 2 for almost every pair, so the registered
// statistic had no dynamic range (see 10's postscript). This pre-check
// measures the dynamic range of the name-proximity measure over ALL
// ordered module pairs per namespace — it never constructs a kernel, a
// cell, or any import-derived quantity beyond the module list itself, so
// it cannot leak the alignment v2 predicts. It pins, per namespace, the
// threshold k* = smallest k >= 3 such that the fraction of pairs sharing
// >= k leading name components lies in (0.02, 0.50]; if no such k exists
// the namespace is reported non-evaluable for v2.
//
// Writes mathlib-study/results-cell-precheck2.json.

import { readdirSync, statSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const NAMESPACES = ["Order", "Topology", "Algebra"];
const HEADBASE = "lean/.lake/packages/mathlib/Mathlib";

const walkLean = (root) => {
  const files = [];
  const walk = (dir) => {
    for (const name of readdirSync(dir)) {
      const p = join(dir, name);
      if (statSync(p).isDirectory()) walk(p);
      else if (name.endsWith(".lean")) files.push(p);
    }
  };
  walk(root);
  files.sort();
  return files;
};
const modOf = (p) =>
  "Mathlib." + p.replaceAll("\\", "/").split("Mathlib/").pop().replace(/\.lean$/, "").replaceAll("/", ".");

const out = {};
for (const ns of NAMESPACES) {
  const comps = walkLean(join(HEADBASE, ns)).map((p) => modOf(p).split("."));
  const n = comps.length;
  const maxDepth = Math.max(...comps.map((c) => c.length));
  const countAtLeast = new Array(maxDepth + 2).fill(0);
  let pairs = 0;
  for (let i = 0; i < n; i++)
    for (let j = 0; j < n; j++) {
      if (i === j) continue;
      pairs++;
      let s = 0;
      const L = Math.min(comps[i].length, comps[j].length);
      while (s < L && comps[i][s] === comps[j][s]) s++;
      for (let k = 0; k <= s; k++) countAtLeast[k]++;
    }
  const frac = countAtLeast.map((c) => c / pairs);
  let kStar = null;
  for (let k = 3; k <= maxDepth; k++)
    if (frac[k] > 0.02 && frac[k] <= 0.5) { kStar = k; break; }
  out[ns] = { modules: n, fracAtLeast: frac.slice(0, maxDepth + 1), kStar };
  console.log(
    `${ns}: ${n} modules; frac of pairs sharing >=k components: ` +
    frac.slice(2, Math.min(7, maxDepth + 1)).map((f, i) => `k=${i + 2}: ${f.toFixed(3)}`).join("  ") +
    `  -> k* = ${kStar ?? "NONE (non-evaluable)"}`
  );
}

writeFileSync("mathlib-study/results-cell-precheck2.json", JSON.stringify(out, null, 1));
console.log("\nwritten: mathlib-study/results-cell-precheck2.json (pair-level name statistics only; no cells, no kernels)");
