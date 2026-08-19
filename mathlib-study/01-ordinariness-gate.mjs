// The ordinariness gate on a real Mathlib import graph.
//
// PRE-REGISTRATION (written before first run, 2026-08-19):
//
// Question: does any principal down-set in the down-set Heyting algebra of a
// Mathlib namespace's import poset pass the ordinariness gate (neither dense
// nor regular)? By the four-cell theorem [K], ordinary kernels are exactly
// those around which the full four-position partition is non-degenerate.
//
// Modeling choices (fixed in advance):
//   1. Corpus: Mathlib.Order (306 modules in the local checkout,
//      lean/.lake/packages/mathlib @ whatever rev the project pins).
//   2. Poset: namespace-internal import graph only. Edges from `import
//      Mathlib.Order.*` lines in Mathlib/Order/**. Paths that leave the
//      namespace and re-enter through other namespaces are NOT tracked —
//      a stated approximation, not an oversight.
//   3. Direction: y <= x iff x (transitively) imports y. So down(x) = x's
//      foundation: itself plus everything it rests on, within the namespace.
//   4. Kernel candidates: principal down-sets down(x) only (one per module).
//      Ordinariness is a property of arbitrary down-sets; principal ones are
//      the interpretable candidates (a module's foundation). Scope choice.
//
// Algebra facts used (all standard / kernel-checked upstream):
//   Down(P) is a Heyting algebra. For a down-set a:
//     not(a)  = { y : down(y) /\ a = empty }   (largest down-set disjoint from a)
//     dense   iff not(a) = empty
//     regular iff not(not(a)) = a
//     ordinary iff neither.
//
// Outcome readings (pre-registered):
//   YES (some ordinary kernel): the four-position geometry exists in
//     formalized mathematics; proceed to cell occupancy and gap analysis.
//   NO (every candidate dense or regular): Mathlib.Order's internal import
//     structure is tower-like (no genuine outside with leftover slack) —
//     itself a finding about how formal libraries grow.
//   Honest expectation: unknown. Dense kernels are expected to be common
//   (foundations containing the namespace's root modules intersect every
//   cone). The live question is whether non-dense candidates are all regular.
//
// Node-cell occupancy (only computed for ordinary kernels):
//   down(y) <= a                    -> Infrastructure
//   down(y) <= not(a)               -> Refusal
//   down(y) <= notnot(a), not <= a  -> Exploitation (the gap cell)
//   otherwise                       -> Distribution
//   A cell can be algebra-inhabited but node-empty; node-empty cells at
//   ordinary kernels are the "structural gap" candidates.

import { readdirSync, readFileSync, statSync } from "node:fs";
import { join } from "node:path";

const NS = process.argv[2] ?? "Order";
const ROOT = `lean/.lake/packages/mathlib/Mathlib/${NS}`;
const PREFIX = `Mathlib.${NS}.`;
console.log(`namespace: Mathlib.${NS}`);

// ---- collect modules ----
const files = [];
const walk = (dir) => {
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    if (statSync(p).isDirectory()) walk(p);
    else if (name.endsWith(".lean")) files.push(p);
  }
};
walk(ROOT);

const modOf = (p) => {
  const rel = p.replaceAll("\\", "/").split("Mathlib/")[1].replace(/\.lean$/, "");
  return "Mathlib." + rel.replaceAll("/", ".");
};
const mods = files.map(modOf);
const idx = new Map(mods.map((m, i) => [m, i]));
const n = mods.length;
console.log(`modules: ${n}`);

// ---- parse namespace-internal imports ----
const edges = []; // edges[i] = direct imports (indices) of module i
for (let i = 0; i < n; i++) edges.push([]);
// This Mathlib checkout uses the module system: `public import X`, `meta import X`, etc.
const importRe = /^(?:(?:public|private|meta)\s+)*import\s+([\w.]+)/gm;
files.forEach((p, i) => {
  const src = readFileSync(p, "utf8");
  for (const m of src.matchAll(importRe)) {
    const target = m[1];
    if (target.startsWith(PREFIX) || target === "Mathlib.Order") {
      const j = idx.get(target);
      if (j !== undefined && j !== i) edges[i].push(j);
    }
  }
});
const edgeCount = edges.reduce((s, e) => s + e.length, 0);
console.log(`internal import edges: ${edgeCount}`);

// ---- reachability (down-sets) via memoized DFS; imports are acyclic ----
const W = Math.ceil(n / 32);
const down = Array.from({ length: n }, () => new Uint32Array(W));
const state = new Uint8Array(n); // 0 unvisited, 1 in progress, 2 done
const dfs = (i) => {
  if (state[i] === 2) return;
  if (state[i] === 1) throw new Error("cycle at " + mods[i]);
  state[i] = 1;
  down[i][i >> 5] |= 1 << (i & 31);
  for (const j of edges[i]) {
    dfs(j);
    for (let w = 0; w < W; w++) down[i][w] |= down[j][w];
  }
  state[i] = 2;
};
for (let i = 0; i < n; i++) dfs(i);

const popcount = (bs) => {
  let c = 0;
  for (let w = 0; w < W; w++) {
    let v = bs[w];
    v = v - ((v >>> 1) & 0x55555555);
    v = (v & 0x33333333) + ((v >>> 2) & 0x33333333);
    c += (((v + (v >>> 4)) & 0x0f0f0f0f) * 0x01010101) >>> 24;
  }
  return c;
};
const intersects = (a, b) => {
  for (let w = 0; w < W; w++) if (a[w] & b[w]) return true;
  return false;
};
const equal = (a, b) => {
  for (let w = 0; w < W; w++) if (a[w] !== b[w]) return false;
  return true;
};
const subset = (a, b) => {
  for (let w = 0; w < W; w++) if (a[w] & ~b[w]) return false;
  return true;
};
const isEmpty = (a) => {
  for (let w = 0; w < W; w++) if (a[w]) return false;
  return true;
};

// pseudocomplement of down-set a (as node bitset): { y : down(y) disjoint a }
const pseudo = (a) => {
  const out = new Uint32Array(W);
  for (let y = 0; y < n; y++) {
    if (!intersects(down[y], a)) out[y >> 5] |= 1 << (y & 31);
  }
  return out;
};

// ---- the gate ----
let dense = 0, regular = 0, both = 0, ordinary = 0, trivialTop = 0;
const ordinaryKernels = [];
const regularKernels = [];
for (let x = 0; x < n; x++) {
  const a = down[x];
  const na = pseudo(a);
  const isDense = isEmpty(na);
  const nna = isDense ? null : pseudo(na);
  const isRegular = isDense ? false : equal(nna, a);
  if (isDense) dense++;
  else if (isRegular) { regular++; regularKernels.push(x); }
  if (isDense && isRegular) both++;
  if (!isDense && !isRegular) {
    ordinary++;
    ordinaryKernels.push({ x, a, na, nna });
  }
}
console.log(`\nGATE RESULTS (candidates = ${n} principal down-sets)`);
console.log(`  dense    : ${dense}`);
console.log(`  regular  : ${regular} (non-dense regulars)`);
console.log(`  ordinary : ${ordinary}`);
if (regularKernels.length) {
  console.log(`\nREGULAR kernels (fail the gate; foundation = its own double negation):`);
  for (const x of regularKernels.slice(0, 25)) {
    console.log(`  ${mods[x]}  |foundation|=${popcount(down[x])}`);
  }
  if (regularKernels.length > 25) console.log(`  ... and ${regularKernels.length - 25} more`);
}

// ---- cell occupancy for ordinary kernels ----
if (ordinary > 0) {
  console.log(`\nORDINARY KERNELS (four-position geometry exists). Node-cell occupancy:`);
  // sort by foundation size for readability
  ordinaryKernels.sort((p, q) => popcount(q.a) - popcount(p.a));
  for (const { x, a, na, nna } of ordinaryKernels.slice(0, 15)) {
    let infra = 0, refusal = 0, exploit = 0, distrib = 0;
    const exploitNames = [], refusalSample = [];
    for (let y = 0; y < n; y++) {
      const dy = down[y];
      if (subset(dy, a)) infra++;
      else if (subset(dy, na)) { refusal++; if (refusalSample.length < 2) refusalSample.push(mods[y]); }
      else if (subset(dy, nna)) { exploit++; if (exploitNames.length < 3) exploitNames.push(mods[y]); }
      else distrib++;
    }
    const gaps = [];
    if (infra === 0) gaps.push("Infrastructure");
    if (refusal === 0) gaps.push("Refusal");
    if (exploit === 0) gaps.push("Exploitation");
    if (distrib === 0) gaps.push("Distribution");
    console.log(
      `  ${mods[x]}  |foundation|=${popcount(a)}  cells I/R/E/D = ${infra}/${refusal}/${exploit}/${distrib}` +
      (gaps.length ? `  NODE-EMPTY: ${gaps.join(",")}` : "") +
      (exploitNames.length ? `\n      E sample: ${exploitNames.join(", ")}` : "") +
      (refusalSample.length ? `\n      R sample: ${refusalSample.join(", ")}` : "")
    );
  }
  if (ordinaryKernels.length > 15) console.log(`  ... and ${ordinaryKernels.length - 15} more ordinary kernels`);

  // summary: how many ordinary kernels have at least one node-empty cell
  let withGaps = 0;
  const gapList = [];
  for (const { x, a, na, nna } of ordinaryKernels) {
    let infra = 0, refusal = 0, exploit = 0, distrib = 0;
    for (let y = 0; y < n; y++) {
      const dy = down[y];
      if (subset(dy, a)) infra++;
      else if (subset(dy, na)) refusal++;
      else if (subset(dy, nna)) exploit++;
      else distrib++;
    }
    if (!infra || !refusal || !exploit || !distrib) {
      withGaps++;
      const empty = [];
      if (!infra) empty.push("Infrastructure");
      if (!refusal) empty.push("Refusal");
      if (!exploit) empty.push("Exploitation");
      if (!distrib) empty.push("Distribution");
      gapList.push({ x, infra, refusal, exploit, distrib, empty });
    }
  }
  console.log(`\nordinary kernels with >=1 node-empty cell (structural gap candidates): ${withGaps}/${ordinaryKernels.length}`);
  for (const g of gapList) {
    console.log(
      `  GAP ${mods[g.x]}  |foundation|=${popcount(down[g.x])}  cells I/R/E/D = ${g.infra}/${g.refusal}/${g.exploit}/${g.distrib}  empty: ${g.empty.join(",")}`
    );
  }
} else {
  console.log(`\nNO ordinary kernels: Mathlib.Order's internal import structure is tower-like at principal kernels.`);
}
