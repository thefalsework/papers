// Shared engine for Study 10 (ca-study, pre-registration v1.1).
//
// REUSE LOG (v1.1 §9): worldVerdict / occupancy / aperture enumeration
// reproduce mathlib-study/02-subspace-nuclei.mjs Part B and
// mathlib-study/01-ordinariness-gate.mjs cell classification, so shared-bug
// risk with the Mathlib study is on the record. The Life engine and the
// counterfactual DAG are new to this study. All Node scripts share THIS
// file; the independent second implementation is wl/ca-aperture.wl.

import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

export const STUDY_DIR = dirname(fileURLToPath(import.meta.url));
export const SEEDS = JSON.parse(readFileSync(join(STUDY_DIR, "seeds.json"), "utf8"));

// ---------------------------------------------------------------------------
// PRNG (mulberry32, as pinned in seeds.json)
// ---------------------------------------------------------------------------
export function mulberry32(seed) {
  let a = seed >>> 0;
  return function () {
    a |= 0; a = (a + 0x6d2b79f5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

// ---------------------------------------------------------------------------
// CA engine: bounded grid, dead boundary
// ---------------------------------------------------------------------------
export const lifeRule = (s, k) => (s ? (k === 2 || k === 3 ? 1 : 0) : (k === 3 ? 1 : 0));

export const totalisticRule = (B, S) => {
  const b = new Set(B), sv = new Set(S);
  return (s, k) => (s ? (sv.has(k) ? 1 : 0) : (b.has(k) ? 1 : 0));
};

export function emptyGrid(H, W) {
  return Array.from({ length: H }, () => new Array(W).fill(0));
}

export function placeCentered(cells, H, W) {
  const g = emptyGrid(H, W);
  const maxR = Math.max(...cells.map((c) => c[0]));
  const maxC = Math.max(...cells.map((c) => c[1]));
  const offR = Math.floor((H - (maxR + 1)) / 2);
  const offC = Math.floor((W - (maxC + 1)) / 2);
  for (const [r, c] of cells) g[r + offR][c + offC] = 1;
  return g;
}

export function soupGrid(prngSeed, H, W, region, density) {
  const g = emptyGrid(H, W);
  const rng = mulberry32(prngSeed);
  const offR = Math.floor((H - region) / 2);
  const offC = Math.floor((W - region) / 2);
  for (let r = 0; r < region; r++)
    for (let c = 0; c < region; c++)
      if (rng() < density) g[r + offR][c + offC] = 1;
  return g;
}

export function neighborCount(g, r, c) {
  const H = g.length, W = g[0].length;
  let k = 0;
  for (let dr = -1; dr <= 1; dr++)
    for (let dc = -1; dc <= 1; dc++) {
      if (!dr && !dc) continue;
      const rr = r + dr, cc = c + dc;
      if (rr >= 0 && rr < H && cc >= 0 && cc < W) k += g[rr][cc];
    }
  return k;
}

export function evolve(g, rule) {
  const H = g.length, W = g[0].length;
  const out = emptyGrid(H, W);
  for (let r = 0; r < H; r++)
    for (let c = 0; c < W; c++)
      out[r][c] = rule(g[r][c], neighborCount(g, r, c));
  return out;
}

export function runCA(seedGrid, T, rule) {
  const hist = [seedGrid];
  for (let t = 1; t <= T; t++) hist.push(evolve(hist[t - 1], rule));
  return hist; // hist[t] = grid at time t
}

// Focus rule (v1.1 §3, unified): among live cells at t = T, lowest row then
// lowest column; returns null if no live cells (logged as undefined cone).
export function pickFocus(hist, T) {
  const g = hist[T];
  for (let r = 0; r < g.length; r++)
    for (let c = 0; c < g[0].length; c++)
      if (g[r][c]) return [r, c, T];
  return null;
}

// ---------------------------------------------------------------------------
// Counterfactual DAG (v1.1 §2.1): u=(c',t-1) -> v=(c,t) iff single-flip of
// u's state, others held fixed, changes v's value under the rule.
// ---------------------------------------------------------------------------
export function cfParents(hist, rule, r, c, t) {
  const g = hist[t - 1];
  const H = g.length, W = g[0].length;
  const s = g[r][c];
  const k = neighborCount(g, r, c);
  const v = rule(s, k);
  const out = [];
  for (let dr = -1; dr <= 1; dr++)
    for (let dc = -1; dc <= 1; dc++) {
      const rr = r + dr, cc = c + dc;
      if (rr < 0 || rr >= H || cc < 0 || cc >= W) continue;
      const v2 = (!dr && !dc)
        ? rule(1 - s, k)
        : rule(s, k + (g[rr][cc] ? -1 : 1));
      if (v2 !== v) out.push([rr, cc]);
    }
  return out;
}

// Past cone of focus [fr,fc,T] truncated to depth d (nodes at t >= max(1,T-d)
// with a directed path to the focus). Returns node map, per-node direct
// parents within the cone, and the focus key.
export function pastCone(hist, rule, focus, depth) {
  const H = hist[0].length, W = hist[0][0].length;
  const [fr, fc, T] = focus;
  const key = (r, c, t) => (t * H + r) * W + c;
  const nodes = new Map();
  const parentsOf = new Map();
  let frontier = [[fr, fc, T]];
  nodes.set(key(fr, fc, T), { r: fr, c: fc, t: T });
  for (let step = 0; step < depth; step++) {
    const next = [];
    for (const [r, c, t] of frontier) {
      if (t - 1 < 1) { parentsOf.set(key(r, c, t), []); continue; }
      const plist = [];
      for (const [rr, cc] of cfParents(hist, rule, r, c, t)) {
        const pk = key(rr, cc, t - 1);
        plist.push(pk);
        if (!nodes.has(pk)) {
          nodes.set(pk, { r: rr, c: cc, t: t - 1 });
          next.push([rr, cc, t - 1]);
        }
      }
      parentsOf.set(key(r, c, t), plist);
    }
    frontier = next;
  }
  for (const [r, c, t] of frontier) parentsOf.set(key(r, c, t), []); // truncated layer
  return { nodes, parentsOf, focusKey: key(fr, fc, T) };
}

// Bitmask poset from a cone: order = transitive closure of direct edges,
// computed by DP over ascending t (parents always precede children).
export function conePoset(cone) {
  const list = [...cone.nodes.entries()].map(([k, v]) => ({ key: k, ...v }));
  list.sort((a, b) => a.t - b.t || a.r - b.r || a.c - b.c);
  const n = list.length;
  if (n > 30) throw new Error("cone too large for 32-bit bitmask poset: n=" + n);
  const idx = new Map(list.map((x, i) => [x.key, i]));
  const down = new Array(n);
  for (let i = 0; i < n; i++) {
    let m = 1 << i;
    for (const pk of cone.parentsOf.get(list[i].key) ?? []) m |= down[idx.get(pk)];
    down[i] = m;
  }
  // direct edges (for N1 rewiring), as index pairs parent -> child
  const edges = [];
  for (let i = 0; i < n; i++)
    for (const pk of cone.parentsOf.get(list[i].key) ?? [])
      edges.push([idx.get(pk), i]);
  return { n, down, list, edges, focusIdx: idx.get(cone.focusKey) };
}

// Rebuild down-masks from an edge list on the same (t-sorted) node list.
export function posetFromEdges(n, list, edges) {
  const parents = Array.from({ length: n }, () => []);
  for (const [p, ch] of edges) parents[ch].push(p);
  const down = new Array(n);
  for (let i = 0; i < n; i++) { // list is t-ascending; parents have lower t, hence lower index
    let m = 1 << i;
    for (const p of parents[i]) m |= down[p];
    down[i] = m;
  }
  return { n, down, list, edges };
}

// ---------------------------------------------------------------------------
// Down-set algebra verdicts (verbatim logic of mathlib-study/02)
// ---------------------------------------------------------------------------
export function worldVerdict(P, S, B) {
  const Bs = B & S;
  let notB = 0;
  for (let p = 0; p < P.n; p++)
    if ((S & (1 << p)) && (P.down[p] & Bs) === 0) notB |= 1 << p;
  const dense = notB === 0;
  let nnB = 0;
  for (let p = 0; p < P.n; p++)
    if ((S & (1 << p)) && (P.down[p] & notB) === 0) nnB |= 1 << p;
  const regular = nnB === Bs;
  return { dense, regular, ordinary: !dense && !regular };
}

// Cell occupancy inside world S (classification of mathlib-study/01):
// down_S(y) <= a -> I; <= not a -> R; <= notnot a -> E; else D.
export function occupancy(P, S, B) {
  const Bs = B & S;
  let notB = 0;
  for (let p = 0; p < P.n; p++)
    if ((S & (1 << p)) && (P.down[p] & Bs) === 0) notB |= 1 << p;
  let nnB = 0;
  for (let p = 0; p < P.n; p++)
    if ((S & (1 << p)) && (P.down[p] & notB) === 0) nnB |= 1 << p;
  let I = 0, R = 0, E = 0, D = 0;
  for (let p = 0; p < P.n; p++) {
    if (!(S & (1 << p))) continue;
    const dp = P.down[p] & S;
    if ((dp & ~Bs) === 0) I++;
    else if ((dp & ~notB) === 0) R++;
    else if ((dp & ~nnB) === 0) E++;
    else D++;
  }
  return { I, R, E, D };
}

// Exhaustive aperture of kernel B over all 2^n worlds.
export function apertureExhaustive(P, B, sampleLimit = 3) {
  const full = (1 << P.n) - 1;
  let apSize = 0;
  const openingSamples = [];
  for (let S = 0; S <= full; S++) {
    if (worldVerdict(P, S, B).ordinary) {
      apSize++;
      if (S !== full && openingSamples.length < sampleLimit) openingSamples.push(S);
    }
  }
  const idV = worldVerdict(P, full, B);
  return {
    apSize,
    apFraction: apSize / (full + 1),
    idOrdinary: idV.ordinary,
    idVerdict: idV.ordinary ? "ordinary" : idV.dense ? "dense" : "regular",
    latent: !idV.ordinary && apSize > 0,
    openingSamples,
  };
}

// Sampled aperture (secondary tier): uniform worlds with replacement.
// Poset masks are 32-bit ints, so this supports 19 <= n <= 30; cones with
// n in 31..40 would need a wide-mask engine and are reported as skipped.
export function apertureSampled(P, B, samples, rng) {
  const size = Math.pow(2, P.n);
  let hits = 0;
  for (let i = 0; i < samples; i++) {
    const S = Math.floor(rng() * size);
    if (worldVerdict(P, S, B).ordinary) hits++;
  }
  const p = hits / samples;
  const ci = 1.96 * Math.sqrt((p * (1 - p)) / samples);
  return { hits, samples, fraction: p, ci95: ci };
}

// All-kernel summary for a cone poset.
export function coneStudy(P) {
  const kernels = [];
  for (let x = 0; x < P.n; x++) {
    const B = P.down[x];
    const st = apertureExhaustive(P, B);
    const node = P.list ? P.list[x] : null;
    const occId = occupancy(P, (1 << P.n) - 1, B);
    const occOpen = st.openingSamples.map((S) => ({ S, occ: occupancy(P, S, B) }));
    kernels.push({ x, node: node ? { r: node.r, c: node.c, t: node.t } : null, ...st, occId, occOpen });
  }
  const fr = kernels.map((k) => k.apFraction).sort((a, b) => a - b);
  const med = fr.length % 2 ? fr[(fr.length - 1) / 2] : (fr[fr.length / 2 - 1] + fr[fr.length / 2]) / 2;
  return {
    n: P.n,
    kernels,
    latentCount: kernels.filter((k) => k.latent).length,
    latentFraction: kernels.filter((k) => k.latent).length / P.n,
    ordinaryAtIdCount: kernels.filter((k) => k.idOrdinary).length,
    medianApFraction: med,
    maxApFraction: fr[fr.length - 1],
  };
}

// ---------------------------------------------------------------------------
// Chain-union posets for the anchors (Div12 = C2+C1, Div36 = C2+C2)
// ---------------------------------------------------------------------------
export function chainUnionPoset(lengths) {
  let n = 0;
  const down = [];
  for (const a of lengths) {
    for (let i = 0; i < a; i++) {
      let m = 0;
      for (let j = 0; j <= i; j++) m |= 1 << (n + j);
      down.push(m);
    }
    n += a;
  }
  return { n, down };
}

export function downsetsOf(P) {
  const L = [];
  for (let A = 0; A < 1 << P.n; A++) {
    let ok = true;
    for (let p = 0; p < P.n && ok; p++) if (A & (1 << p)) ok = (P.down[p] & ~A) === 0;
    if (ok) L.push(A);
  }
  return L;
}

export function closedForm(chains, exps) {
  let N = 1, D = 1, R = 1, DR = 1;
  chains.forEach((a, c) => {
    const e = exps[c];
    N *= 2 ** a;
    D *= (2 ** e - 1) * 2 ** (a - e) + 1;
    R *= 2 ** (a - e) + 2 ** e - 1;
    DR *= 2 ** e;
  });
  return N - D - R + DR;
}

// ---------------------------------------------------------------------------
// Statistics
// ---------------------------------------------------------------------------
export function median(xs) {
  const s = [...xs].sort((a, b) => a - b);
  if (!s.length) return NaN;
  return s.length % 2 ? s[(s.length - 1) / 2] : (s[s.length / 2 - 1] + s[s.length / 2]) / 2;
}

function normCdf(z) {
  // Abramowitz-Stegun 7.1.26 erf approximation
  const t = 1 / (1 + 0.3275911 * Math.abs(z) / Math.SQRT2);
  const erf = 1 - (((((1.061405429 * t - 1.453152027) * t) + 1.421413741) * t - 0.284496736) * t + 0.254829592) * t * Math.exp(-(z * z) / 2);
  return z >= 0 ? 0.5 * (1 + erf) : 0.5 * (1 - erf);
}

// Two-sided Mann-Whitney U, normal approximation with tie correction (v1.1 §7 P1).
export function mannWhitney(xs, ys) {
  const all = [...xs.map((v) => [v, 0]), ...ys.map((v) => [v, 1])].sort((a, b) => a[0] - b[0]);
  const N = all.length;
  const ranks = new Array(N);
  const tieGroups = [];
  let i = 0;
  while (i < N) {
    let j = i;
    while (j < N && all[j][0] === all[i][0]) j++;
    const r = (i + j + 1) / 2;
    for (let k = i; k < j; k++) ranks[k] = r;
    tieGroups.push(j - i);
    i = j;
  }
  let R1 = 0;
  all.forEach((v, k) => { if (v[1] === 0) R1 += ranks[k]; });
  const n1 = xs.length, n2 = ys.length;
  const U1 = R1 - (n1 * (n1 + 1)) / 2;
  const mu = (n1 * n2) / 2;
  const tieSum = tieGroups.reduce((s, t) => s + t * t * t - t, 0);
  const sigma2 = (n1 * n2 / 12) * (N + 1 - tieSum / (N * (N - 1)));
  const z = sigma2 <= 0 ? 0 : (U1 - mu) / Math.sqrt(sigma2);
  const p = sigma2 <= 0 ? 1 : 2 * (1 - normCdf(Math.abs(z)));
  return { U1, z, p, n1, n2 };
}

// ---------------------------------------------------------------------------
// Condition runner: build every cone of a condition per seeds.json
// ---------------------------------------------------------------------------
export function buildRuns(rule = lifeRule) {
  const { H, W } = SEEDS.grid;
  const runs = [];
  for (const cond of ["A", "B", "C", "D"]) {
    for (const seed of SEEDS.conditions[cond]) {
      runs.push({ cond, name: seed.name, grid: placeCentered(seed.cells, H, W), T: SEEDS.T });
    }
  }
  for (const s of SEEDS.conditions.E.seeds) {
    runs.push({
      cond: "E", name: `soup-${s}`,
      grid: soupGrid(s, H, W, SEEDS.conditions.E.region, SEEDS.conditions.E.density),
      T: SEEDS.T,
    });
  }
  for (const seed of SEEDS.conditions.F) {
    runs.push({ cond: "F", name: seed.name, grid: placeCentered(seed.cells, H, W), T: SEEDS.T_F });
  }
  return runs.map((r) => ({ ...r, hist: runCA(r.grid, r.T, rule) }));
}

// F focus special case (v1.1 §3): the seed cell's update at t=1.
export function focusFor(run) {
  if (run.cond === "F") {
    for (let r = 0; r < run.grid.length; r++)
      for (let c = 0; c < run.grid[0].length; c++)
        if (run.grid[r][c]) return [r, c, 1];
    return null;
  }
  return pickFocus(run.hist, run.T);
}

// Census policy (v1.1 §4): largest depth with n <= 18 (exhaustive tier),
// largest depth with n <= 40 (sampled tier, if beyond exhaustive depth).
export function censusFor(run, rule = lifeRule) {
  const focus = focusFor(run);
  if (!focus) return { defined: false };
  const sizes = [];
  let dEx = 0, dSam = 0;
  for (let d = 1; d <= run.T; d++) {
    const cone = pastCone(run.hist, rule, focus, d);
    const n = cone.nodes.size;
    sizes.push(n);
    if (n <= 18) dEx = d;
    if (n <= 40) dSam = d;
    if (n > 40) break;
  }
  return { defined: true, focus, sizes, exhaustiveDepth: dEx, sampledDepth: dSam > dEx ? dSam : null };
}
