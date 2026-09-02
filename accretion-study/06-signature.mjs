// Accretion study, Phase E — THE DISCRIMINATOR EXPERIMENT (registered).
//
// QUESTION. conemass/ORACLE rankings of real ecosystems show a
// distinctive head signature: packages whose concentration rank is far
// ahead of their dependent-count rank (liblzma5: ORACLE #8, in-degree
// #173; unicode-ident: #2 vs #3,304). Is that signature a fingerprint
// of specific growth mechanisms, or a generic byproduct of any grown
// graph? If it discriminates, it doubles as a validity check for
// synthetic dependency corpora and gives a mechanistic account of WHY
// concentration sees what volume metrics miss.
//
// DESIGN. Run the SHIPPED tool (conemass.mjs, the exact file published
// at github.com/thefalsework/conemass) on:
//   REAL:      Debian bookworm 2023, Debian trixie 2025 (not
//              independent of each other — same lineage; counted as
//              one-and-a-half corpora, stated here in advance),
//              crates.io 2022.
//   SYNTHETIC: the seven mechanism families on record, N = 30,000,
//              3 replicates each, fresh seeds 970000+ (disjoint from
//              A/B'/03/05): U, PA, PC(0), PC(0.5), PC(1), SIB,
//              FRONT(2000), MIX(0.5).
//
// STATISTICS, fixed before any run, computed identically everywhere:
//   QUIET50  = # rows in the ORACLE top-50 with dependents_rank > 100
//              (the quiet-load-bearing head count; threshold fixed
//              across corpora — all corpora here are 30k-84k nodes,
//              within one order of magnitude)
//   MAXGAP50 = max(dependents_rank - oracle_rank) over the top-50
//   RHO      = Pearson correlation of the two rank columns over the
//              full graph (Spearman with min-rank ties; descriptive)
//
// REGISTERED PREDICTIONS:
//   E1 (real signature):   QUIET50 >= 5 for ALL real corpora.
//   E2 (null generators):  mean QUIET50 <= 2 for U and for PA.
//   E3 (cone-local shows): mean QUIET50 >= 5 for PC(0).
//   E4 (descriptive, unscored): QUIET50 declines monotonically in
//      beta across PC(0), PC(0.5), PC(1); SIB/FRONT/MIX reported.
//
// INTERPRETATION, fixed in advance:
//   E1+E2+E3 all land -> the signature DISCRIMINATES and cone-local
//     accretion is a sufficient mechanism; validity-metric use is live;
//     reconnects the flux law to the applied tool.
//   E1 lands, E2 fails (nulls show the signature too) -> generic
//     byproduct of accretion; the validity-metric idea is DEAD; say so.
//   E1 fails -> the operationalization (QUIET50 @ threshold 100) does
//     not capture what the case studies show; STOP, report, do not
//     tune thresholds post hoc.
//   E3 fails with E1+E2 landing -> real signature exists, no known
//     mechanism produces it — same shape as Phase D's honest negative.
//
// Depends on: sim-lib.mjs growers; C:/dev/conemass/conemass.mjs (the
// shipped CLI, pinned by commit in the postscript).

import { grow } from "./sim-lib.mjs";
import { writeFileSync, readFileSync, rmSync } from "node:fs";
import { execFileSync } from "node:child_process";

const CONEMASS = "C:/dev/conemass/conemass.mjs";
const N = 30000, REPS = 3, SEED0 = 970000;
const RULES = [
  ["U", "U"], ["PA", "PA"],
  ["PC(0)", 0], ["PC(0.5)", 0.5], ["PC(1)", 1],
  ["SIB", { type: "SIB" }],
  ["FRONT(2000)", { type: "FRONT", K: 2000 }],
  ["MIX(0.5)", { type: "MIX", p: 0.5 }],
];
const REAL = [
  ["debian-2023", "debian-study/history/2023.json"],
  ["debian-2025", "debian-study/history/2025.json"],
  ["crates-2022", "software-study/history/crates-2022.json"],
];

const TMP = "accretion-study/tmp-sig.json";

const signature = (jsonPath) => {
  const csv = execFileSync("node", [CONEMASS, jsonPath], { maxBuffer: 1 << 28, encoding: "utf8" });
  const rows = csv.trim().split("\n").slice(1).map((l) => {
    const p = l.split(",");
    return { or: +p[0], name: p[1], deg: +p[3], dr: +p[4] };
  });
  const head = rows.slice(0, 50);
  const quiet50 = head.filter((r) => r.dr > 100).length;
  const maxgap50 = Math.max(...head.map((r) => r.dr - r.or));
  // full-graph rank correlation (Pearson on min-rank columns)
  let sx = 0, sy = 0, sxx = 0, syy = 0, sxy = 0;
  const n = rows.length;
  for (const r of rows) { sx += r.or; sy += r.dr; sxx += r.or * r.or; syy += r.dr * r.dr; sxy += r.or * r.dr; }
  const rho = (n * sxy - sx * sy) / Math.sqrt((n * sxx - sx * sx) * (n * syy - sy * sy));
  const exemplars = head.filter((r) => r.dr > 100).slice(0, 5)
    .map((r) => `${r.name}(o#${r.or},d#${r.dr})`);
  return { n, quiet50, maxgap50, rho: +rho.toFixed(4), exemplars };
};

const out = { real: {}, synthetic: {} };

for (const [label, path] of REAL) {
  out.real[label] = signature(path);
  const s = out.real[label];
  console.log(`REAL ${label}: n=${s.n} QUIET50=${s.quiet50} MAXGAP50=${s.maxgap50} rho=${s.rho}`);
  console.log(`  quiet head: ${s.exemplars.join(" ")}`);
}

let seedIdx = 0;
for (const [label, rule] of RULES) {
  const reps = [];
  for (let r = 0; r < REPS; r++) {
    const seed = SEED0 + seedIdx++;
    const grown = grow(rule, N, [N], seed);
    const nodes = Array.from({ length: N }, (_, i) => "n" + i);
    writeFileSync(TMP, JSON.stringify({ nodes, edges: grown.edges }));
    reps.push({ seed, ...signature(TMP) });
  }
  const mean = (f) => +(reps.reduce((s, x) => s + f(x), 0) / reps.length).toFixed(2);
  out.synthetic[label] = { reps, meanQuiet50: mean((x) => x.quiet50), meanRho: mean((x) => x.rho) };
  console.log(`SYN ${label}: QUIET50=${reps.map((x) => x.quiet50).join(",")} (mean ${out.synthetic[label].meanQuiet50}) rho=${reps.map((x) => x.rho).join(",")}`);
}
rmSync(TMP, { force: true });

// verdicts against the registered predictions
const e1 = Object.values(out.real).every((s) => s.quiet50 >= 5);
const e2 = out.synthetic["U"].meanQuiet50 <= 2 && out.synthetic["PA"].meanQuiet50 <= 2;
const e3 = out.synthetic["PC(0)"].meanQuiet50 >= 5;
const q = (l) => out.synthetic[l].meanQuiet50;
const e4 = q("PC(0)") >= q("PC(0.5)") && q("PC(0.5)") >= q("PC(1)");
out.verdicts = {
  E1: e1 ? "LANDS" : "FAILS",
  E2: e2 ? "LANDS" : "FAILS",
  E3: e3 ? "LANDS" : "FAILS",
  E4_descriptive: e4 ? "monotone" : "non-monotone",
};
console.log("\nVERDICTS:", JSON.stringify(out.verdicts));

writeFileSync("accretion-study/results-signature.json", JSON.stringify(out, null, 1));
console.log("wrote accretion-study/results-signature.json");
