// AFP referendum, part 2: does the consolidation arrow transfer — and
// hold over twenty years?
//
// PRE-REGISTRATION (written before first run, 2026-08-26; committed with
// the blind extraction 04 and its edge lists, which contain structure
// only — no cones, no measures).
//
// ON MATHLIB (the finding under referendum): six pre-registered trends
// over 2023-2026, latency rising and apertures narrowing at the
// frontier-cone scale, surviving per-snapshot degree-preserving nulls
// 6/6, with the young library statistically indistinguishable from its
// degree-random twin and the mature library at the extremes. Three
// years, one corpus. AFP offers eleven biennial checkpoints, 2006-2026,
// on a different assistant and a different social object (refereed
// archive of contributions vs. one integrated library).
//
// INSTRUMENT (verbatim mathlib-study 06): per checkpoint, the top-5
// largest principal down-cones with size <= 18 on the entry graph
// (ties by node index after name sort); per cone, exact enumeration of
// all 2^n subspace nuclei per kernel; latentFrac (kernels not ordinary
// at identity with nonempty aperture) and meanApFrac, averaged over the
// five cones. Foundations computed with the cycle-tolerant fixpoint
// (some checkpoints may contain small import knots; preorder
// reflection, as parts 1-2).
//
// ELIGIBILITY, fixed in advance: a checkpoint is eligible iff it has
// >= 5 candidate cones of size >= 4 (early AFP is nearly edgeless:
// 2006 has one cross-entry edge). Trends are scored over eligible
// checkpoints in time order; if fewer than 6 are eligible the study is
// UNINFORMATIVE (reported, not scored).
//
// PREDICTIONS (the Mathlib arrow, transplanted):
//   H1 (latency arrow):  Spearman(time, latentFrac) >= +0.6.
//   H2 (aperture arrow): Spearman(time, meanApFrac) <= -0.6.
//
// INTERPRETATION, FIXED IN ADVANCE:
//   H1 and H2 both hold -> the consolidation arrow is a cross-corpus,
//     cross-decade regularity of collective formal work; outward
//     documents may say so. The per-snapshot null control (mathlib 08
//     style) is then REQUIRED before the sentence ships anywhere
//     outward, registered as script 06 — the arrow does not graduate on
//     trends alone (lesson of the CA size confound).
//   Either fails -> the arrow is Mathlib-specific or absent here;
//     every outward mention of consolidation names the scope.
//
// Output: afp-study/results-consolidation.json (raw, committed).

import { readFileSync, writeFileSync } from "node:fs";

const YEARS = [2006, 2008, 2010, 2012, 2014, 2016, 2018, 2020, 2022, 2024, 2026];
const CONES = 5;
const MAXCONE = 18;
const MINSIZE = 4;

// cycle-tolerant foundations over entry graph (indices)
const foundations = (n, adjIn) => {
  const found = Array.from({ length: n }, (_, i) => new Set([i]));
  let changed = true;
  while (changed) {
    changed = false;
    for (let i = 0; i < n; i++)
      for (const j of adjIn[i]) {
        for (const k of found[j])
          if (!found[i].has(k)) { found[i].add(k); changed = true; }
      }
  }
  return found;
};

// verbatim mathlib-study 06
const analyzeCone = (cone, found) => {
  const cn = cone.length;
  const localIdx = new Map(cone.map((g, i) => [g, i]));
  const down = cone.map((g) => {
    let m = 0;
    for (const k of found[g]) if (localIdx.has(k)) m |= 1 << localIdx.get(k);
    return m;
  });
  const full = (1 << cn) - 1;
  let latent = 0, ordId = 0;
  const fracs = [];
  for (let x = 0; x < cn; x++) {
    const B = down[x];
    let ap = 0;
    for (let S = 0; S <= full; S++) {
      const Bs = B & S;
      let notB = 0;
      for (let p = 0; p < cn; p++) if ((S & (1 << p)) && (down[p] & Bs) === 0) notB |= 1 << p;
      if (notB === 0) continue;
      let nnB = 0;
      for (let p = 0; p < cn; p++) if ((S & (1 << p)) && (down[p] & notB) === 0) nnB |= 1 << p;
      if (nnB !== Bs) ap++;
    }
    let notB = 0;
    for (let p = 0; p < cn; p++) if ((down[p] & B) === 0) notB |= 1 << p;
    let idOrd = false;
    if (notB !== 0) {
      let nnB = 0;
      for (let p = 0; p < cn; p++) if ((down[p] & notB) === 0) nnB |= 1 << p;
      idOrd = nnB !== B;
    }
    if (idOrd) ordId++;
    else if (ap > 0) latent++;
    fracs.push(ap / (full + 1));
  }
  return {
    size: cn,
    latentFrac: latent / cn,
    ordIdFrac: ordId / cn,
    meanApFrac: fracs.reduce((a, b) => a + b, 0) / cn,
  };
};

const spearman = (xs, ys) => {
  const rank = (a) => {
    const idx = [...a.keys()].sort((i, j) => a[i] - a[j]);
    const r = new Array(a.length);
    idx.forEach((i, k) => (r[i] = k));
    return r;
  };
  const rx = rank(xs), ry = rank(ys);
  const m = (rx.length - 1) / 2;
  let num = 0, dx = 0, dy = 0;
  for (let i = 0; i < rx.length; i++) {
    num += (rx[i] - m) * (ry[i] - m);
    dx += (rx[i] - m) ** 2; dy += (ry[i] - m) ** 2;
  }
  return num / Math.sqrt(dx * dy);
};

const rows = [];
for (const year of YEARS) {
  const { rev, entries, edges } = JSON.parse(readFileSync(`afp-study/history/${year}.json`, "utf8"));
  const idx = new Map(entries.map((e, i) => [e, i]));
  const n = entries.length;
  const adjIn = Array.from({ length: n }, () => new Set());
  for (const pair of edges) {
    const [a, b] = pair.split(">");
    adjIn[idx.get(a)].add(idx.get(b));
  }
  const found = foundations(n, adjIn);
  const cands = [];
  for (let i = 0; i < n; i++)
    if (found[i].size <= MAXCONE && found[i].size >= MINSIZE) cands.push(i);
  cands.sort((a, b) => found[b].size - found[a].size || a - b);
  const eligible = cands.length >= CONES;
  if (!eligible) {
    rows.push({ year, rev: rev.slice(0, 12), n, candidates: cands.length, eligible });
    console.log(`${year}: n=${n} candidates=${cands.length} -> INELIGIBLE`);
    continue;
  }
  const res = cands.slice(0, CONES).map((x) => analyzeCone([...found[x]].sort((a, b) => a - b), found));
  const mean = (k) => res.reduce((s, r) => s + r[k], 0) / res.length;
  const row = {
    year, rev: rev.slice(0, 12), n, candidates: cands.length, eligible,
    coneSizes: res.map((r) => r.size),
    latentFrac: mean("latentFrac"), ordIdFrac: mean("ordIdFrac"), meanApFrac: mean("meanApFrac"),
  };
  rows.push(row);
  console.log(
    `${year}: n=${n} cones=[${row.coneSizes}] latentFrac=${row.latentFrac.toFixed(3)} ` +
    `ordIdFrac=${row.ordIdFrac.toFixed(3)} meanApFrac=${row.meanApFrac.toFixed(4)}`
  );
}

const el = rows.filter((r) => r.eligible);
let verdict;
if (el.length < 6) {
  verdict = { informative: false, eligible: el.length };
  console.log(`\nFewer than 6 eligible checkpoints (${el.length}) -> UNINFORMATIVE`);
} else {
  const t = el.map((_, i) => i);
  const rhoLat = spearman(t, el.map((r) => r.latentFrac));
  const rhoAp = spearman(t, el.map((r) => r.meanApFrac));
  const h1 = rhoLat >= 0.6, h2 = rhoAp <= -0.6;
  verdict = { informative: true, eligible: el.length, rhoLat, rhoAp, H1: h1, H2: h2, holds: h1 && h2 };
  console.log(
    `\nEligible checkpoints: ${el.length}` +
    `\nH1 (latency arrow):  Spearman=${rhoLat.toFixed(2)} (need >= +0.6)  -> ${h1 ? "holds" : "fails"}` +
    `\nH2 (aperture arrow): Spearman=${rhoAp.toFixed(2)} (need <= -0.6)  -> ${h2 ? "holds" : "fails"}` +
    `\nConsolidation arrow on AFP: ${verdict.holds ? "HOLDS (null control required before shipping)" : "FAILS"}`
  );
}

writeFileSync("afp-study/results-consolidation.json", JSON.stringify({ rows, verdict }, null, 1));
console.log("\nwritten: afp-study/results-consolidation.json");
