// Battery v3 shared machinery: the seventh feature — harmonic
// cone-membership mass, the functional the oracle test identified as
// the complete mechanism of the strongest synthetic counterexample
// (accretion-study/05-oracle.mjs, O2 CONFIRMS).
//
//   ORACLE(x) = sum over nodes u with x in cone_200(u) of 1/|cone_200(u)|
//
// where cone_200(u) is the FIFO-BFS truncated down-set of u over the
// dependency direction (cIn), cap 200, excluding u — the same
// truncation as battery v2's upset_200 and the accretion cones. A pure
// graph feature: no growth rule, no cells, no outcome anywhere in it.
// Feature form: log1p(ORACLE), z-scored per snapshot like the others.
//
// Interpretation: "being a large share of many small toolchains."
// Counts (in-degree, up-set size, even exact transitive dependents)
// weight every containment equally; the harmonic weighting is what
// carried the entire synthetic residual (05-oracle O3: exact counts
// leave t = -7.0; ORACLE leaves t = -0.25).

const CONE_CAP = 200;

// cap parametrized for the oracle-scanner sensitivity sweep; default 200
// keeps every battery run byte-identical.
export const oracleMass = (snap, cap = CONE_CAP) => {
  const { nComp, cIn } = snap;
  const orc = new Float64Array(nComp);
  const seen = new Int32Array(nComp).fill(-1);
  for (let u = 0; u < nComp; u++) {
    const cone = [];
    seen[u] = u;
    const q = [u];
    while (q.length && cone.length < cap) {
      const v = q.shift();
      for (const w of cIn[v]) {
        if (seen[w] === u) continue;
        seen[w] = u;
        cone.push(w);
        if (cone.length >= cap) break;
        q.push(w);
      }
    }
    if (!cone.length) continue;
    const credit = 1 / cone.length;
    for (const x of cone) orc[x] += credit;
  }
  return orc;
};
