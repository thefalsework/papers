// Baseline gauntlet: shared feature battery over the deflation-control
// loaders. The question this folder exists to answer: does E-cell
// membership carry growth signal beyond the STANDARD graph predictors —
// the reviewer's arsenal — not just beyond the program's own confounds
// (degree, age, distance), which deflation-control already matched?
//
// Battery (all computed at the baseline snapshot, condensation level):
//   f0 log1p(in-degree)         — preferential attachment's variable
//   f1 log1p(out-degree)        — breadth of own dependencies
//   f2 first-seen index          — age
//   f3 undirected distance to the kernel's down-set (per kernel;
//      unreachable mapped to maxFinite+2 so the caliper prices it)
//   f4 log(PageRank)             — global prestige on the "is depended
//      on by" direction (edge x->y for "x depends on y", alpha 0.85)
//   f5 k-core number             — undirected degeneracy shell
//
// Declared exclusions: betweenness (O(VE), infeasible on the 285k-comp
// crates condensation) and clustering coefficient (triangle counting on
// a heavy-tailed graph; also not a standard growth predictor). Both are
// named in the registration so the scope of "the battery" is explicit.
//
// Features f0-f2 and f4-f5 are z-scored per snapshot over all singleton
// components; f3 is z-scored per kernel over that kernel's candidate
// members (it has no meaning across kernels).

export const pagerank = (snap) => {
  const { nComp, cIn } = snap; // cIn[x] = deps of x; rank flows x -> dep
  const ALPHA = 0.85, ITERS = 50;
  let pr = new Float64Array(nComp).fill(1 / nComp);
  let nxt = new Float64Array(nComp);
  const outDeg = new Float64Array(nComp);
  for (let x = 0; x < nComp; x++) outDeg[x] = cIn[x].length;
  for (let it = 0; it < ITERS; it++) {
    nxt.fill(0);
    let dangling = 0;
    for (let x = 0; x < nComp; x++) {
      if (outDeg[x] === 0) { dangling += pr[x]; continue; }
      const share = pr[x] / outDeg[x];
      for (const y of cIn[x]) nxt[y] += share;
    }
    const base = (1 - ALPHA) / nComp + (ALPHA * dangling) / nComp;
    for (let y = 0; y < nComp; y++) nxt[y] = base + ALPHA * nxt[y];
    const t = pr; pr = nxt; nxt = t;
  }
  return pr;
};

export const coreNumbers = (snap) => {
  const { nComp, und } = snap;
  const deg = new Int32Array(nComp);
  let maxDeg = 0;
  for (let v = 0; v < nComp; v++) { deg[v] = und[v].length; if (deg[v] > maxDeg) maxDeg = deg[v]; }
  // bucket peeling (Batagelj-Zaversnik)
  const bin = new Int32Array(maxDeg + 2);
  for (let v = 0; v < nComp; v++) bin[deg[v]]++;
  let start = 0;
  for (let d = 0; d <= maxDeg; d++) { const c = bin[d]; bin[d] = start; start += c; }
  const pos = new Int32Array(nComp), vert = new Int32Array(nComp);
  for (let v = 0; v < nComp; v++) { pos[v] = bin[deg[v]]; vert[pos[v]] = v; bin[deg[v]]++; }
  for (let d = maxDeg; d > 0; d--) bin[d] = bin[d - 1];
  bin[0] = 0;
  const core = new Int32Array(nComp);
  for (let i = 0; i < nComp; i++) {
    const v = vert[i];
    core[v] = deg[v];
    for (const u of und[v]) {
      if (deg[u] > deg[v]) {
        const du = deg[u], pu = pos[u], pw = bin[du], w = vert[pw];
        if (u !== w) { pos[u] = pw; vert[pu] = w; pos[w] = pu; vert[pw] = u; }
        bin[du]++; deg[u]--;
      }
    }
  }
  return core;
};

// z-score helpers
export const zStats = (vals) => {
  let s = 0; for (const v of vals) s += v;
  const mu = s / vals.length;
  let ss = 0; for (const v of vals) ss += (v - mu) * (v - mu);
  const sd = Math.sqrt(ss / vals.length) || 1;
  return { mu, sd };
};

// greedy nearest-neighbor matching without replacement in z-space.
// Returns array of [ei, ri] index pairs with distance <= caliper.
export const greedyMatch = (E, R, caliper, rand) => {
  // E, R: arrays of feature vectors (same length k)
  const order = Array.from({ length: E.length }, (_, i) => i);
  for (let i = 0; i < order.length; i++) {
    const j = i + Math.floor(rand() * (order.length - i));
    const t = order[i]; order[i] = order[j]; order[j] = t;
  }
  const usedR = new Uint8Array(R.length);
  const cal2 = caliper * caliper;
  const pairs = [];
  for (const ei of order) {
    const fe = E[ei];
    let best = -1, bestD = cal2;
    for (let ri = 0; ri < R.length; ri++) {
      if (usedR[ri]) continue;
      const fr = R[ri];
      let d = 0;
      for (let k = 0; k < fe.length; k++) { const x = fe[k] - fr[k]; d += x * x; if (d > bestD) break; }
      if (d <= bestD) { bestD = d; best = ri; }
    }
    if (best !== -1) { usedR[best] = 1; pairs.push([ei, best]); }
  }
  return pairs;
};
