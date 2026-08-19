// Subspace-nucleus correspondence + latency hunt on a real Mathlib sub-poset.
//
// PRE-REGISTRATION (written before first run, 2026-08-19):
//
// Claim under test (Part A): for a finite poset P, the nuclei on the down-set
// Heyting algebra Down(P) are exactly the subspace nuclei
//     j_S(A) = { p in P : down(p) /\ S <= A },   one per subset S <= P,
// distinct S giving distinct nuclei — so #nuclei = 2^|P| and Fix(j_S) ~ Down(S).
// (Expected from the theory of finite frames — every sublocale of a finite
// frame is spatial — but verified here from the axioms, two independent ways:
// fix-set enumeration for all test posets, and raw enumeration of ALL
// inflationary maps for the tiny ones.)
//
// Part B (anchor): Down(chain2 + chain1) = Div12 and Down(chain2 + chain2)
// = Div36. If Part A holds, aperture sizes computed by enumerating subsets S
// must reproduce the kernel-checked/closed-form values: on Div12 the only
// nonempty aperture is Ap(2) = {identity} (size 1, S = P); on Div36,
// |Ap(6)| = 2. Every element is compared against the closed form
//     |Ap| = prod 2^{a_c} - prod D_c - prod R_c + prod DR_c,
//     D_c = (2^{e_c}-1) 2^{a_c-e_c} + 1,  R_c = 2^{a_c-e_c} + 2^{e_c} - 1,
//     DR_c = 2^{e_c}.
// Any mismatch kills the correspondence claim.
//
// Part C (the hunt): on the Mathlib.Order internal import graph (same
// modeling choices as .scratch_mathlib_gate.mjs), take the module with the
// largest foundation of size <= 18 (ties: alphabetical) as sub-poset P.
// For each principal kernel a = down(x), enumerate all 2^|P| worlds S and
// classify a /\ S in Down(S). Report: aperture sizes, ordinariness at
// identity (S = P), and LATENT elements (not ordinary at identity, ordinary
// in some proper world). Honest expectation: unknown whether latency occurs
// or is generic; this is a measurement.

import { readdirSync, readFileSync, statSync } from "node:fs";
import { join } from "node:path";

// ---------------------------------------------------------------------------
// posets as bitmask structures: n points, down[i] = bitmask of {j : j <= i}
// ---------------------------------------------------------------------------
const mkPoset = (n, covers) => {
  const down = Array.from({ length: n }, (_, i) => 1 << i);
  let changed = true;
  while (changed) {
    changed = false;
    for (const [a, b] of covers) {
      const nd = down[b] | down[a];
      if (nd !== down[b]) { down[b] = nd; changed = true; }
    }
    for (let b = 0; b < n; b++) {
      for (let a = 0; a < n; a++) {
        if (a !== b && (down[b] & (1 << a)) && (down[b] | down[a]) !== down[b]) {
          down[b] |= down[a];
          changed = true;
        }
      }
    }
  }
  return { n, down };
};

const downsetsOf = ({ n, down }) => {
  const L = [];
  for (let A = 0; A < 1 << n; A++) {
    let ok = true;
    for (let p = 0; p < n && ok; p++) if (A & (1 << p)) ok = (down[p] & ~A) === 0;
    if (ok) L.push(A);
  }
  return L; // sorted ascending; L[0] = 0 (bottom), last = full (top)
};

// Heyting ops on Down(P), elements as point-bitmasks
const himp = ({ n, down }, A, B) => {
  let out = 0;
  for (let p = 0; p < n; p++) if ((down[p] & A & ~B) === 0) out |= 1 << p;
  return out;
};

// ---------------------------------------------------------------------------
// Part A
// ---------------------------------------------------------------------------
const isNucleus = (P, L, idx, jmap) => {
  for (const A of L) {
    const jA = jmap.get(A);
    if ((A & ~jA) !== 0) return false;                    // inflationary
    if (jmap.get(jA) !== jA) return false;                // idempotent
    for (const B of L) {
      if (jmap.get(A & B) !== (jmap.get(A) & jmap.get(B))) return false; // meet-pres
    }
  }
  return true;
};

const nucleiViaFixsets = (P, L) => {
  const top = L[L.length - 1];
  const inL = new Set(L);
  const nonTop = L.filter((A) => A !== top);
  if (nonTop.length > 21) throw new Error("L too big for fix-set enumeration");
  const found = [];
  for (let mask = 0; mask < 1 << nonTop.length; mask++) {
    const F = [top];
    for (let i = 0; i < nonTop.length; i++) if (mask & (1 << i)) F.push(nonTop[i]);
    const inF = new Set(F);
    let ok = true;
    // meet-closed
    for (let i = 0; i < F.length && ok; i++)
      for (let k = i; k < F.length && ok; k++) if (!inF.has(F[i] & F[k])) ok = false;
    // implication-closed: a -> f in F for all a in L, f in F
    for (const a of L) {
      if (!ok) break;
      for (const f of F) { if (!inF.has(himp(P, a, f))) { ok = false; break; } }
    }
    if (!ok) continue;
    // j(A) = least element of F above A (meet of all such; F meet-closed)
    const jmap = new Map();
    for (const A of L) {
      let m = top;
      for (const f of F) if ((A & ~f) === 0) m &= f;
      jmap.set(A, m);
    }
    if (!inL.has(0) ) throw new Error("bottom missing");
    if (!isNucleus(P, L, null, jmap)) continue; // belt and braces: verify axioms
    found.push(jmap);
  }
  return found;
};

// fully independent check for tiny L: enumerate ALL inflationary maps
const nucleiRaw = (P, L) => {
  const ups = L.map((A) => L.filter((B) => (A & ~B) === 0));
  let count = 1;
  for (const u of ups) count *= u.length;
  if (count > 2_000_000) return null; // too many; skip
  const jvals = new Array(L.length);
  const out = [];
  const rec = (i) => {
    if (i === L.length) {
      const jmap = new Map(L.map((A, k) => [A, jvals[k]]));
      if (isNucleus(P, L, null, jmap)) out.push(jmap);
      return;
    }
    for (const B of ups[i]) { jvals[i] = B; rec(i + 1); }
  };
  rec(0);
  return out;
};

const subspaceNucleus = (P, L, S) => {
  const jmap = new Map();
  for (const A of L) {
    let out = 0;
    for (let p = 0; p < P.n; p++) if ((P.down[p] & S & ~A) === 0) out |= 1 << p;
    jmap.set(A, out);
  }
  return jmap;
};

const sig = (L, jmap) => L.map((A) => jmap.get(A)).join(",");

const testPosets = [
  ["chain2", mkPoset(2, [[0, 1]])],
  ["chain3", mkPoset(3, [[0, 1], [1, 2]])],
  ["antichain2", mkPoset(2, [])],
  ["antichain3", mkPoset(3, [])],
  ["antichain4", mkPoset(4, [])],
  ["V (2 bottoms, 1 top)", mkPoset(3, [[0, 2], [1, 2]])],
  ["Lambda (1 bottom, 2 tops)", mkPoset(3, [[0, 1], [0, 2]])],
  ["diamond", mkPoset(4, [[0, 1], [0, 2], [1, 3], [2, 3]])],
  ["chain2+chain1", mkPoset(3, [[0, 1]])],
  ["chain2+chain2", mkPoset(4, [[0, 1], [2, 3]])],
  ["fence x<y>z<w", mkPoset(4, [[0, 1], [2, 1], [2, 3]])],
  ["5pt: diamond + incomparable", mkPoset(5, [[0, 1], [0, 2], [1, 3], [2, 3]])],
];

console.log("=== PART A: subspace-nucleus correspondence, from the axioms ===");
let allPass = true;
for (const [name, P] of testPosets) {
  const L = downsetsOf(P);
  if (L.length - 1 > 21) { console.log(`${name}: |L|=${L.length} too big, skipped`); continue; }
  const brute = nucleiViaFixsets(P, L);
  const bruteSigs = new Set(brute.map((j) => sig(L, j)));
  const subSigs = new Set();
  let subAllNuclei = true;
  for (let S = 0; S < 1 << P.n; S++) {
    const j = subspaceNucleus(P, L, S);
    if (!isNucleus(P, L, null, j)) subAllNuclei = false;
    subSigs.add(sig(L, j));
  }
  const equalSets = bruteSigs.size === subSigs.size && [...bruteSigs].every((s) => subSigs.has(s));
  const injective = subSigs.size === (1 << P.n);
  const raw = nucleiRaw(P, L);
  const rawOK = raw === null ? "skipped" : (raw.length === bruteSigs.size &&
    new Set(raw.map((j) => sig(L, j))).size === bruteSigs.size &&
    raw.every((j) => bruteSigs.has(sig(L, j)))) ? "agrees" : "DISAGREES";
  const pass = equalSets && injective && subAllNuclei && rawOK !== "DISAGREES";
  allPass &&= pass;
  console.log(
    `${name}: |P|=${P.n} |L|=${L.length}  nuclei(fixsets)=${bruteSigs.size}  2^|P|=${1 << P.n}` +
    `  subspace-all-nuclei=${subAllNuclei}  injective=${injective}  sets-equal=${equalSets}  raw-enum=${rawOK}` +
    (pass ? "" : "  *** FAIL ***")
  );
}
console.log(allPass ? "PART A: PASS — nuclei on Down(P) are exactly the 2^|P| subspace nuclei (on these posets)\n"
                    : "PART A: FAIL — correspondence does not hold; stop here\n");
if (!allPass) process.exit(1);

// ---------------------------------------------------------------------------
// Part B: anchors against Div12/Div36 kernel-checked results + closed form
// ---------------------------------------------------------------------------
// world verdict of kernel B' = B & S inside Down(S), all via point-bitmasks
const worldVerdict = (P, S, B) => {
  const Bs = B & S;
  let notB = 0;
  for (let p = 0; p < P.n; p++) if ((S & (1 << p)) && (P.down[p] & Bs) === 0) notB |= 1 << p;
  const dense = notB === 0;
  let nnB = 0;
  for (let p = 0; p < P.n; p++) if ((S & (1 << p)) && (P.down[p] & notB) === 0) nnB |= 1 << p;
  const regular = nnB === Bs;
  return { dense, regular, ordinary: !dense && !regular };
};

const apertureViaSubsets = (P, B) => {
  const ap = [];
  for (let S = 0; S < 1 << P.n; S++) if (worldVerdict(P, S, B).ordinary) ap.push(S);
  return ap;
};

const closedForm = (chains, exps) => {
  // chains = [a_c], exps = [e_c]
  let N = 1, D = 1, R = 1, DR = 1;
  chains.forEach((a, c) => {
    const e = exps[c];
    N *= 2 ** a;
    D *= (2 ** e - 1) * 2 ** (a - e) + 1;
    R *= 2 ** (a - e) + 2 ** e - 1;
    DR *= 2 ** e;
  });
  return N - D - R + DR;
};

console.log("=== PART B: anchors — Down(chains) vs kernel-checked Div12/Div36 ===");
const anchor = (name, chains, primes) => {
  // build P = disjoint union of chains of lengths a_c
  const covers = [];
  const chainStart = [];
  let idx = 0;
  for (const a of chains) {
    chainStart.push(idx);
    for (let i = 0; i < a - 1; i++) covers.push([idx + i, idx + i + 1]);
    idx += a;
  }
  const P = mkPoset(idx, covers);
  const L = downsetsOf(P);
  let allOK = true;
  console.log(`${name}: |P|=${P.n}, |L|=${L.length}, worlds=${1 << P.n}`);
  for (const B of L) {
    const exps = chains.map((a, c) => {
      let e = 0;
      for (let i = 0; i < a; i++) if (B & (1 << (chainStart[c] + i))) e++;
      return e;
    });
    const div = exps.reduce((acc, e, c) => acc * primes[c] ** e, 1);
    const ap = apertureViaSubsets(P, B);
    const cf = closedForm(chains, exps);
    const idOrdinary = worldVerdict(P, (1 << P.n) - 1, B).ordinary;
    const ok = ap.length === cf;
    allOK &&= ok;
    const note = ap.length > 0 && !idOrdinary ? "  LATENT" : "";
    console.log(
      `  k=${div}  |Ap|=${ap.length}  closed-form=${cf}  ${ok ? "ok" : "*** MISMATCH ***"}` +
      `  ordinary@identity=${idOrdinary}${note}` +
      (ap.length > 0 && ap.length <= 3
        ? "  S: " + ap.map((S) => "{" + [...Array(P.n).keys()].filter((p) => S & (1 << p)).join(",") + "}").join(" ")
        : "")
    );
  }
  console.log(allOK ? `${name}: all elements match the closed form` : `${name}: FAILURES above`);
  return allOK;
};
const b1 = anchor("Div12 = Down(chain2 + chain1)", [2, 1], [2, 3]);
const b2 = anchor("Div36 = Down(chain2 + chain2)", [2, 2], [2, 3]);
if (!(b1 && b2)) process.exit(1);
console.log("");

// ---------------------------------------------------------------------------
// Part C: latency hunt on a real Mathlib.Order sub-poset
// ---------------------------------------------------------------------------
console.log("=== PART C: latency hunt on Mathlib.Order ===");
const ROOT = "lean/.lake/packages/mathlib/Mathlib/Order";
const PREFIX = "Mathlib.Order.";
const files = [];
const walk = (dir) => {
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    if (statSync(p).isDirectory()) walk(p);
    else if (name.endsWith(".lean")) files.push(p);
  }
};
walk(ROOT);
const modOf = (p) =>
  "Mathlib." + p.replaceAll("\\", "/").split("Mathlib/")[1].replace(/\.lean$/, "").replaceAll("/", ".");
const mods = files.map(modOf);
const midx = new Map(mods.map((m, i) => [m, i]));
const n = mods.length;
const edges = Array.from({ length: n }, () => []);
const importRe = /^(?:(?:public|private|meta)\s+)*import\s+([\w.]+)/gm;
files.forEach((p, i) => {
  const src = readFileSync(p, "utf8");
  for (const m of src.matchAll(importRe)) {
    const j = midx.get(m[1]);
    if (j !== undefined && j !== i) edges[i].push(j);
  }
});
// transitive foundations as Sets
const found = new Array(n);
const state = new Uint8Array(n);
const dfs = (i) => {
  if (state[i] === 2) return;
  if (state[i] === 1) throw new Error("cycle");
  state[i] = 1;
  const s = new Set([i]);
  for (const j of edges[i]) { dfs(j); for (const k of found[j]) s.add(k); }
  found[i] = s;
  state[i] = 2;
};
for (let i = 0; i < n; i++) dfs(i);

// pre-registered pick: largest foundation of size <= 18, ties alphabetical
let pick = -1;
for (let i = 0; i < n; i++) {
  if (found[i].size <= 18) {
    if (pick === -1 || found[i].size > found[pick].size ||
        (found[i].size === found[pick].size && mods[i] < mods[pick])) pick = i;
  }
}
const cone = [...found[pick]].sort((a, b) => (mods[a] < mods[b] ? -1 : 1));
const cn = cone.length;
console.log(`sub-poset: foundation cone of ${mods[pick]}  (|P| = ${cn}, worlds = ${1 << cn})`);
const localIdx = new Map(cone.map((g, i) => [g, i]));
const CP = { n: cn, down: cone.map((g) => {
  let m = 0;
  for (const k of found[g]) if (localIdx.has(k)) m |= 1 << localIdx.get(k);
  return m;
}) };
for (let i = 0; i < cn; i++) console.log(`  [${i}] ${mods[cone[i]]}  |down|=${popcount32(CP.down[i])}`);
function popcount32(v) { v = v - ((v >>> 1) & 0x55555555); v = (v & 0x33333333) + ((v >>> 2) & 0x33333333); return (((v + (v >>> 4)) & 0x0f0f0f0f) * 0x01010101) >>> 24; }

console.log(`\nprincipal kernels: aperture size, identity verdict, latency`);
let latentCount = 0;
for (let x = 0; x < cn; x++) {
  const B = CP.down[x];
  let apSize = 0;
  let sample = [];
  for (let S = 0; S < 1 << cn; S++) {
    if (worldVerdict(CP, S, B).ordinary) {
      apSize++;
      if (sample.length < 2 && S !== (1 << cn) - 1) sample.push(S);
    }
  }
  const idV = worldVerdict(CP, (1 << cn) - 1, B);
  const latent = !idV.ordinary && apSize > 0;
  if (latent) latentCount++;
  const idDesc = idV.ordinary ? "ordinary" : idV.dense ? "dense" : "regular";
  console.log(
    `  [${x}] ${mods[cone[x]].replace("Mathlib.Order.", "")}  |Ap|=${apSize}/${1 << cn}  @identity=${idDesc}` +
    (latent ? "  LATENT" : "")
  );
}
console.log(`\nlatent principal kernels: ${latentCount}/${cn}`);
