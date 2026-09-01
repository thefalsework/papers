// Battery v2 shared machinery: the sixth feature.
// upset_200(x) = number of distinct transitive dependents of x reachable
// by BFS over the dependents direction (cOut), excluding x, capped at
// 200 — the same truncation constant as the accretion study's cones.
// Feature form: log1p(upset_200), z-scored per snapshot like f0-f2/f4-f5.

export const UPSET_CAP = 200;

export const upsetSizes = (snap) => {
  const { nComp, cOut } = snap;
  const sizes = new Int32Array(nComp);
  const mark = new Int32Array(nComp).fill(-1);
  const q = new Int32Array(Math.min(nComp, UPSET_CAP + 1));
  for (let s = 0; s < nComp; s++) {
    mark[s] = s;
    let head = 0, tail = 0, count = 0;
    q[tail++] = s;
    while (head < tail && count < UPSET_CAP) {
      const v = q[head++];
      for (const u of cOut[v]) {
        if (mark[u] === s) continue;
        mark[u] = s;
        count++;
        if (count >= UPSET_CAP) break;
        if (tail < q.length) q[tail++] = u;
      }
    }
    sizes[s] = count;
  }
  return sizes;
};
