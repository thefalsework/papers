# Phantom-mass pilot (Phase 1). Registered spec: SPEC.md in this folder.
#
# Trains fixed-budget ReLU MLPs (64 hidden neurons total; depths 1,2,4,8)
# on two-moons and two-spirals, rasterizes both class decision regions
# across a resolution sweep, and measures the morphological-closing
# residual (the phantom at resolution eps):
#
#   phantom(U, eps) = closing(U) \ U,   closing = erode(dilate(U, 3x3), 3x3)
#
# Registered quantities: p(eps) curves, scaling exponent alpha over the
# two finest octaves, grid-offset stability at eps*, depth trend (E2,
# fixed neuron budget per the Phase 0 amendment), distance-matched error
# enrichment (E3), fjord-vs-island decomposition of phantom components.
#
# Modes:
#   python 01-pilot.py calibrate   # spirals accuracy-band calibration only
#   python 01-pilot.py run         # full pilot (writes out/)
#   python 01-pilot.py smoke       # 2 seeds, moons only, for plumbing checks

import json
import os
import sys
import numpy as np

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "out")

DEPTH_CONFIGS = {1: [64], 2: [32, 32], 4: [16, 16, 16, 16], 8: [8] * 8}
N_TRAIN, N_VAL = 2000, 1000
MOONS_NOISE = 0.20
SPIRALS_NOISE = 0.15
MOONS_BAND = (0.945, 0.975)          # registered: 96% +/- 1.5
MAX_EPOCHS = 4000
RESOLUTION_FACTORS = [4.0, 2.0, 1.0, 0.5, 0.25, 0.125]
FINE_FACTORS = [0.5, 0.25, 0.125]    # alpha fit window (two finest octaves)
E1_MASS_FLOOR = 0.001                # p(eps*) >= 0.1% of region mass
E1_ALPHA_MAX = 0.5
E3_MARGIN_PP = 5.0
N_SEEDS = 10
N_OFFSETS = 4

# ---------------- data ----------------

def moons_curves(n=4000):
    t = np.linspace(0, np.pi, n)
    c0 = np.stack([np.cos(t), np.sin(t)], 1)
    c1 = np.stack([1 - np.cos(t), 0.5 - np.sin(t)], 1)
    return c0, c1

def spirals_curves(n=4000):
    t = np.sqrt(np.linspace(0.05, 1, n)) * 3 * np.pi
    r = t / (3 * np.pi) * 2.0 + 0.15
    c0 = np.stack([r * np.cos(t), r * np.sin(t)], 1)
    c1 = -c0
    return c0, c1

def sample_from_curves(curves, n, noise, rng):
    half = n // 2
    xs, ys = [], []
    for label, c in enumerate(curves):
        idx = rng.integers(0, len(c), half)
        pts = c[idx] + rng.normal(0, noise, (half, 2))
        xs.append(pts)
        ys.append(np.full(half, label))
    x = np.concatenate(xs); y = np.concatenate(ys)
    perm = rng.permutation(len(x))
    return x[perm], y[perm]

def truth_fn(curves):
    # Bayes-optimal under equal isotropic noise: nearer generating curve.
    c0, c1 = curves
    def f(pts, chunk=20000):
        out = np.empty(len(pts), dtype=np.int64)
        for i in range(0, len(pts), chunk):
            p = pts[i:i + chunk]
            d0 = np.min(np.sum((p[:, None, :] - c0[None, ::4, :]) ** 2, 2), 1)
            d1 = np.min(np.sum((p[:, None, :] - c1[None, ::4, :]) ** 2, 2), 1)
            out[i:i + chunk] = (d1 < d0).astype(np.int64)
        return out
    return f

DATASETS = {
    "moons": (moons_curves(), MOONS_NOISE),
    "spirals": (spirals_curves(), SPIRALS_NOISE),
}

# ---------------- tiny MLP (numpy, Adam) ----------------

class MLP:
    def __init__(self, sizes, rng):
        self.W, self.b = [], []
        dims = [2] + sizes + [1]
        for a, c in zip(dims[:-1], dims[1:]):
            self.W.append(rng.normal(0, np.sqrt(2.0 / a), (a, c)))
            self.b.append(np.zeros(c))
        self.m = [np.zeros_like(w) for w in self.W + self.b]
        self.v = [np.zeros_like(w) for w in self.W + self.b]
        self.t = 0

    def forward(self, x):
        acts = [x]
        h = x
        for i, (w, b) in enumerate(zip(self.W, self.b)):
            h = h @ w + b
            if i < len(self.W) - 1:
                h = np.maximum(h, 0)
            acts.append(h)
        return h[:, 0], acts

    def predict(self, x, chunk=200000):
        out = np.empty(len(x), dtype=bool)
        for i in range(0, len(x), chunk):
            z, _ = self.forward(x[i:i + chunk])
            out[i:i + chunk] = z > 0
        return out

    def train_step(self, x, y, lr=3e-3):
        z, acts = self.forward(x)
        p = 1 / (1 + np.exp(-z))
        dz = (p - y)[:, None] / len(x)
        grads_W, grads_b = [], []
        delta = dz
        for i in range(len(self.W) - 1, -1, -1):
            a_in = acts[i]
            gW = a_in.T @ delta
            gb = delta.sum(0)
            grads_W.insert(0, gW); grads_b.insert(0, gb)
            if i > 0:
                delta = (delta @ self.W[i].T) * (acts[i] > 0)
        self.t += 1
        params = self.W + self.b
        grads = grads_W + grads_b
        b1, b2, eps = 0.9, 0.999, 1e-8
        for j, (prm, g) in enumerate(zip(params, grads)):
            self.m[j] = b1 * self.m[j] + (1 - b1) * g
            self.v[j] = b2 * self.v[j] + (1 - b2) * g * g
            mh = self.m[j] / (1 - b1 ** self.t)
            vh = self.v[j] / (1 - b2 ** self.t)
            prm -= lr * mh / (np.sqrt(vh) + eps)

def train_to_band(depth, xtr, ytr, xva, yva, band, rng):
    # Registered procedure: full-batch Adam; stop at the first epoch whose
    # val accuracy lands inside the band; exclusion if never reached.
    net = MLP(DEPTH_CONFIGS[depth], rng)
    for epoch in range(MAX_EPOCHS):
        net.train_step(xtr, ytr)
        if epoch % 5 == 0:
            acc = np.mean(net.predict(xva) == (yva == 1))
            if band[0] <= acc <= band[1]:
                return net, float(acc), epoch
    acc = np.mean(net.predict(xva) == (yva == 1))
    return None, float(acc), MAX_EPOCHS

# ---------------- morphology (3x3, 8-connectivity) ----------------

def dilate(u):
    p = np.pad(u, 1, constant_values=False)
    out = np.zeros_like(u)
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            out |= p[1 + dy:p.shape[0] - 1 + dy, 1 + dx:p.shape[1] - 1 + dx]
    return out

def erode(u):
    p = np.pad(u, 1, constant_values=True)
    out = np.ones_like(u)
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            out &= p[1 + dy:p.shape[0] - 1 + dy, 1 + dx:p.shape[1] - 1 + dx]
    return out

def closing_residual(u):
    return erode(dilate(u)) & ~u

# ---------------- grid machinery ----------------

def grid_centers(bbox, eps, offset=(0.0, 0.0)):
    (x0, x1), (y0, y1) = bbox
    xs = np.arange(x0 + (0.5 + offset[0]) * eps, x1, eps)
    ys = np.arange(y0 + (0.5 + offset[1]) * eps, y1, eps)
    gx, gy = np.meshgrid(xs, ys)
    return np.stack([gx.ravel(), gy.ravel()], 1), (len(ys), len(xs))

def rasterize(net, bbox, eps, offset=(0.0, 0.0)):
    pts, shape = grid_centers(bbox, eps, offset)
    pred = net.predict(pts).reshape(shape)
    return pred, pts.reshape(shape + (2,))

def median_nn_dist(x, rng, sample=500):
    idx = rng.choice(len(x), min(sample, len(x)), replace=False)
    s = x[idx]
    d = np.sqrt(np.sum((s[:, None, :] - x[None, :, :]) ** 2, 2))
    d[d == 0] = np.inf
    return float(np.median(d.min(1)))

def boundary_distance(pred):
    # multi-source BFS (8-conn, unit steps) from cells adjacent to the
    # other class; distance in cells
    h, w = pred.shape
    diff = np.zeros_like(pred, dtype=bool)
    diff[:-1, :] |= pred[:-1, :] != pred[1:, :]
    diff[1:, :] |= pred[1:, :] != pred[:-1, :]
    diff[:, :-1] |= pred[:, :-1] != pred[:, 1:]
    diff[:, 1:] |= pred[:, 1:] != pred[:, :-1]
    dist = np.full((h, w), np.iinfo(np.int32).max, dtype=np.int32)
    dist[diff] = 0
    frontier = diff
    d = 0
    while frontier.any():
        d += 1
        nxt = dilate(frontier) & (dist > d)
        nxt &= dist == np.iinfo(np.int32).max
        dist[nxt] = d
        frontier = nxt
    return dist

def components(mask):
    # iterative 8-conn flood fill; returns label array (0 = background)
    lab = np.zeros(mask.shape, dtype=np.int32)
    cur = 0
    todo = mask.copy()
    while todo.any():
        cur += 1
        seed = np.zeros_like(mask)
        yx = np.argwhere(todo)
        seed[yx[0][0], yx[0][1]] = True
        while True:
            grown = dilate(seed) & mask
            if (grown == seed).all():
                break
            seed = grown
        lab[seed] = cur
        todo &= ~seed
    return lab, cur

# ---------------- per-run measurement ----------------

def measure_run(net, xtr, eps_star, bbox, truthf, rng):
    rows = []       # (factor, cls, p)
    detail = {}
    for f in RESOLUTION_FACTORS:
        eps = eps_star * f
        pred, _ = rasterize(net, bbox, eps)
        for cls in (0, 1):
            u = pred if cls == 1 else ~pred
            res = closing_residual(u)
            p = res.sum() / max(u.sum(), 1)
            rows.append((f, cls, float(p)))
            if f == 1.0:
                detail[cls] = dict(pred=pred, u=u, res=res, eps=eps)
    # alpha fit over the fine window, mean over classes
    alphas = []
    for cls in (0, 1):
        ps = [p for (f, c, p) in rows if c == cls and f in FINE_FACTORS]
        es = [eps_star * f for f in FINE_FACTORS]
        if any(p <= 0 for p in ps):
            alphas.append(float("inf"))
        else:
            A = np.polyfit(np.log(es), np.log(ps), 1)
            alphas.append(float(A[0]))
    # offset stability at eps*
    base_pts = []
    for cls in (0, 1):
        d = detail[cls]
        _, centers = rasterize(net, bbox, d["eps"])  # same grid as base
        base_pts.append(centers[d["res"]])
    base = np.concatenate(base_pts) if sum(len(b) for b in base_pts) else np.zeros((0, 2))
    stable_votes = 0
    if len(base):
        for _ in range(N_OFFSETS):
            off = rng.uniform(0, 1, 2)
            predo, centerso = rasterize(net, bbox, eps_star, tuple(off))
            reso = closing_residual(predo) | closing_residual(~predo)
            opts = centerso[reso]
            if len(opts) == 0:
                continue
            recur = 0
            for i in range(0, len(base), 2000):
                b = base[i:i + 2000]
                dmin = np.sqrt(
                    np.min(np.sum((b[:, None, :] - opts[None, :, :]) ** 2, 2), 1))
                recur += int((dmin <= eps_star).sum())
            if recur / len(base) >= 0.5:
                stable_votes += 1
    # fjord vs island, per class at eps*
    fjords = islands = 0
    for cls in (0, 1):
        d = detail[cls]
        rival = ~d["u"] & ~d["res"]   # rival-class cells not claimed by healing
        lab, n = components(d["res"])
        for k in range(1, n + 1):
            comp = lab == k
            if (dilate(comp) & rival).any():
                fjords += 1
            else:
                islands += 1
    # E3 ingredients at eps*: pooled over both class regions
    e3 = []
    for cls in (0, 1):
        d = detail[cls]
        pred = d["pred"]
        dist = boundary_distance(pred)
        _, centers = rasterize(net, bbox, d["eps"])
        phant = d["res"]                       # cells predicted rival class
        cand = ~d["u"] & ~phant                # same prediction, not flipped
        if phant.sum() == 0:
            continue
        deciles = np.quantile(dist[~d["u"]], np.linspace(0, 1, 11))
        def decile_of(v):
            return np.clip(np.searchsorted(deciles, v, side="right") - 1, 0, 9)
        ph_dec = decile_of(dist[phant])
        ca_dec = decile_of(dist[cand])
        ph_pts = centers[phant]
        # cells outside the cls region carry the rival class prediction
        pred_label = 0 if cls == 1 else 1
        ph_err = truthf(ph_pts) != pred_label
        ca_pts = centers[cand]
        ca_err = truthf(ca_pts) != pred_label
        for dec in range(10):
            pm = ph_dec == dec
            cm = ca_dec == dec
            if pm.sum() == 0 or cm.sum() == 0:
                continue
            e3.append(dict(cls=cls, decile=dec,
                           n_ph=int(pm.sum()), err_ph=float(ph_err[pm].mean()),
                           n_ct=int(cm.sum()), err_ct=float(ca_err[cm].mean())))
    return rows, alphas, stable_votes, (fjords, islands), e3

# ---------------- driver ----------------

def run(mode):
    os.makedirs(OUT, exist_ok=True)
    seeds = range(2 if mode == "smoke" else N_SEEDS)
    datasets = ["moons"] if mode == "smoke" else ["moons", "spirals"]
    bands = {"moons": MOONS_BAND}
    if "spirals" in datasets:
        cal_path = os.path.join(OUT, "spirals-band.json")
        if os.path.exists(cal_path):
            bands["spirals"] = tuple(json.load(open(cal_path))["band"])
        else:
            print("calibrating spirals band...")
            accs = []
            for depth in DEPTH_CONFIGS:
                rng = np.random.default_rng(7000 + depth)
                curves, noise = DATASETS["spirals"]
                xtr, ytr = sample_from_curves(curves, N_TRAIN, noise, rng)
                xva, yva = sample_from_curves(curves, N_VAL, noise, rng)
                net = MLP(DEPTH_CONFIGS[depth], rng)
                best = 0.0
                for ep in range(MAX_EPOCHS):
                    net.train_step(xtr, ytr)
                    if ep % 20 == 0:
                        best = max(best, float(np.mean(net.predict(xva) == (yva == 1))))
                accs.append(best)
                print(f"  depth {depth}: best val acc {best:.4f}")
            lo = min(accs)
            band = (round(lo - 0.03, 3), round(lo, 3))
            bands["spirals"] = band
            json.dump({"accs": accs, "band": band}, open(cal_path, "w"))
            print(f"spirals band set (logged): {band}")
    all_rows, summaries = [], []
    for ds in datasets:
        curves, noise = DATASETS[ds]
        truthf = truth_fn(curves)
        for depth in DEPTH_CONFIGS:
            for seed in seeds:
                rng = np.random.default_rng(1000 * depth + seed + (0 if ds == "moons" else 500000))
                xtr, ytr = sample_from_curves(curves, N_TRAIN, noise, rng)
                xva, yva = sample_from_curves(curves, N_VAL, noise, rng)
                net, acc, ep = train_to_band(depth, xtr, ytr, xva, yva, bands[ds], rng)
                if net is None:
                    summaries.append(dict(ds=ds, depth=depth, seed=seed,
                                          excluded=True, val_acc=acc))
                    print(f"{ds} d{depth} s{seed}: EXCLUDED (acc {acc:.3f})")
                    continue
                pad = 0.5
                bbox = ((xtr[:, 0].min() - pad, xtr[:, 0].max() + pad),
                        (xtr[:, 1].min() - pad, xtr[:, 1].max() + pad))
                eps_star = median_nn_dist(xtr, rng)
                rows, alphas, stable, fi, e3 = measure_run(
                    net, xtr, eps_star, bbox, truthf, rng)
                p_star = np.mean([p for (f, c, p) in rows if f == 1.0])
                for (f, c, p) in rows:
                    all_rows.append(dict(ds=ds, depth=depth, seed=seed,
                                         factor=f, cls=c, p=p))
                summaries.append(dict(ds=ds, depth=depth, seed=seed,
                                      excluded=False, val_acc=acc, epoch=ep,
                                      eps_star=eps_star, p_star=float(p_star),
                                      alpha0=alphas[0], alpha1=alphas[1],
                                      stable_votes=stable,
                                      fjords=fi[0], islands=fi[1], e3=e3))
                print(f"{ds} d{depth} s{seed}: acc {acc:.3f} ep {ep} "
                      f"p* {p_star:.5f} alpha {alphas[0]:.2f}/{alphas[1]:.2f} "
                      f"stable {stable}/4 fjords {fi[0]} islands {fi[1]}")
    with open(os.path.join(OUT, f"pilot-rows-{mode}.csv"), "w") as fh:
        fh.write("dataset,depth,seed,factor,cls,p\n")
        for r in all_rows:
            fh.write(f"{r['ds']},{r['depth']},{r['seed']},{r['factor']},{r['cls']},{r['p']:.6g}\n")
    json.dump(summaries, open(os.path.join(OUT, f"pilot-summary-{mode}.json"), "w"), indent=1)
    # ---- verdicts (full run only) ----
    if mode != "run":
        return
    for ds in datasets:
        S = [s for s in summaries if s["ds"] == ds and not s.get("excluded")]
        if not S:
            continue
        print(f"\n=== {ds} ===")
        # E1'
        by_depth = {}
        for s in S:
            by_depth.setdefault(s["depth"], []).append(s)
        e1_pass_depths = []
        for depth, ss in sorted(by_depth.items()):
            pm = float(np.mean([s["p_star"] for s in ss]))
            am = [min(s["alpha0"], s["alpha1"]) for s in ss]
            afin = [a for a in am if np.isfinite(a)]
            amed = float(np.median(afin)) if afin else float("inf")
            ok = pm >= E1_MASS_FLOOR and amed <= E1_ALPHA_MAX
            if ok:
                e1_pass_depths.append(depth)
            print(f"depth {depth}: mean p* {pm:.5f}  median alpha {amed:.2f}  E1'{'PASS' if ok else 'fail'}")
        # K2 stability
        stab = [s["stable_votes"] >= 3 for s in S if s["p_star"] > 0]
        print(f"stability: {sum(stab)}/{len(stab)} runs pass (>=3/4 offsets)")
        # E2 Spearman + permutation
        depths = np.array([s["depth"] for s in S], dtype=float)
        pstars = np.array([s["p_star"] for s in S])
        def spearman(a, b):
            ra = np.argsort(np.argsort(a)); rb = np.argsort(np.argsort(b))
            ra = ra - ra.mean(); rb = rb - rb.mean()
            den = np.sqrt((ra ** 2).sum() * (rb ** 2).sum())
            return float((ra * rb).sum() / den) if den else 0.0
        rho = spearman(depths, pstars)
        rng = np.random.default_rng(99)
        perm = [spearman(rng.permutation(depths), pstars) for _ in range(10000)]
        pval = float(np.mean([abs(x) >= abs(rho) for x in perm]))
        print(f"E2: Spearman(depth, p*) = {rho:.3f}, permutation p = {pval:.4f} "
              f"-> {'PASS' if rho > 0 and pval < 0.05 else 'fail'}")
        # E3 pooled per depth, matched deciles
        for depth, ss in sorted(by_depth.items()):
            nph = nct = eph = ect = 0
            for s in ss:
                for row in s["e3"]:
                    nph += row["n_ph"]; eph += row["err_ph"] * row["n_ph"]
                    nct += row["n_ct"]; ect += row["err_ct"] * row["n_ct"]
            if nph == 0:
                print(f"E3 depth {depth}: no phantom cells")
                continue
            r_ph = eph / nph; r_ct = ect / max(nct, 1)
            marg = (r_ph - r_ct) * 100
            print(f"E3 depth {depth}: phantom err {r_ph:.3f} (n={nph}) "
                  f"vs matched {r_ct:.3f} (n={nct})  margin {marg:+.1f}pp "
                  f"-> {'PASS' if marg >= E3_MARGIN_PP else 'fail'}")
        # fjord/island
        fj = sum(s["fjords"] for s in S); il = sum(s["islands"] for s in S)
        print(f"phantom components: {fj} fjords, {il} islands")

if __name__ == "__main__":
    run(sys.argv[1] if len(sys.argv) > 1 else "run")
