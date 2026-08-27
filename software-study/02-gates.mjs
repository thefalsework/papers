// Software pair (garden/museum), phase 2: the manipulation-check gates.
//
// Protocol: software-study/PROTOCOL.md v1.0 §3. NOTHING REGISTERED IS
// SCORED IF EITHER GATE FAILS. This script reads only the census artifacts
// (checkpoint node/edge lists and evaluability counts) — no cells beyond
// the census counts, no names/categories, no apertures, no trends. It
// cannot leak any of the four quadrant predictions.
//
// MC1 (regime contrast is real): among nodes present at consecutive
// checkpoints (matched by name), the fraction whose OUT-edge set changed
// must be >= 3x higher in the Go stdlib than in crates.io. Scored pooled
// across the five consecutive pairs (total changed / total surviving);
// per-pair rates reported descriptively. Rationale (protocol §3): a
// published crate version's dep set is immutable — its out-edges change
// only via a NEW published version, so the museum's surviving-node
// rewiring should be low unless it is secretly gardened by rapid
// re-publication; the garden's packages are refactored in place.
//
// MC2 (the instrument can grip): each corpus must yield >= 3 evaluable
// kernels (ordinary; R, E, D all nonempty; computed on the SCC
// condensation) at >= 4 of the 6 checkpoints. Counts come from the census
// gate (exact where the condensation is small, seeded 2000-sample
// otherwise — a sample showing >= 3 witnesses the corpus has >= 3).
//
// Verdict semantics (fixed by the protocol): both gates pass -> proceed
// to phase 3 (scripts 03-04). Either fails -> the study is UNINFORMATIVE;
// report, register a replacement pair, stop. No quadrant prediction is
// evaluated in that branch.
//
// Writes software-study/results-gates.json.

import { readFileSync, writeFileSync } from "node:fs";

const YEARS = [2016, 2018, 2020, 2022, 2024, 2026];

const load = (corpus, year) =>
  JSON.parse(readFileSync(`software-study/history/${corpus}-${year}.json`, "utf8"));

const outEdgeMap = (snap) => {
  // name -> sorted dep-name list (joined) for cheap set equality
  const deps = new Map(snap.nodes.map((n) => [n, []]));
  for (const [a, b] of snap.edges) deps.get(snap.nodes[a]).push(snap.nodes[b]);
  const m = new Map();
  for (const [n, ds] of deps) m.set(n, ds.sort().join("|"));
  return m;
};

const rewiring = (corpus) => {
  const pairs = [];
  let survivedTotal = 0, changedTotal = 0;
  for (let i = 0; i + 1 < YEARS.length; i++) {
    const a = outEdgeMap(load(corpus, YEARS[i]));
    const b = outEdgeMap(load(corpus, YEARS[i + 1]));
    let survived = 0, changed = 0;
    for (const [name, sig] of a) {
      const sig2 = b.get(name);
      if (sig2 === undefined) continue;
      survived++;
      if (sig2 !== sig) changed++;
    }
    survivedTotal += survived; changedTotal += changed;
    pairs.push({
      from: YEARS[i], to: YEARS[i + 1], survived, changed,
      rate: survived ? +(changed / survived).toFixed(4) : null,
    });
  }
  return { pairs, survivedTotal, changedTotal, pooledRate: changedTotal / survivedTotal };
};

const census = JSON.parse(readFileSync("software-study/results-census.json", "utf8"));

const go = rewiring("go");
const crates = rewiring("crates");
const ratio = go.pooledRate / crates.pooledRate;
const mc1Pass = ratio >= 3;

const mc2 = {};
for (const corpus of ["go", "crates"]) {
  const perYear = YEARS.map((y) => ({
    year: y,
    evaluable: census[corpus][y].graph.gate.evaluable,
    method: census[corpus][y].graph.gate.method,
  }));
  const okYears = perYear.filter((p) => p.evaluable >= 3).length;
  mc2[corpus] = { perYear, checkpointsWithGE3: okYears, pass: okYears >= 4 };
}
const mc2Pass = mc2.go.pass && mc2.crates.pass;

const out = {
  protocol: "software-study/PROTOCOL.md v1.0 §3",
  ranAt: new Date().toISOString(),
  mc1: {
    go: { pooledRate: +go.pooledRate.toFixed(4), pairs: go.pairs },
    crates: { pooledRate: +crates.pooledRate.toFixed(4), pairs: crates.pairs },
    ratio: +ratio.toFixed(2), threshold: 3, pass: mc1Pass,
  },
  mc2,
  verdict: mc1Pass && mc2Pass
    ? "GATES PASS - proceed to phase 3 (registered quadrants)"
    : "GATE FAILURE - study uninformative per protocol §3; stop, register replacement pair",
};
writeFileSync("software-study/results-gates.json", JSON.stringify(out, null, 1));
console.log(JSON.stringify(out, null, 1));
