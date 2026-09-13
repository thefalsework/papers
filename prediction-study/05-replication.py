"""RubyGems replication (SPEC.md Replication section, frozen).

Gates E-R0a/E-R0b (stability, degeneracy; no outcomes touched), then
the primary endpoint E-R1: quiet-criticality odds ratio within the
top conemass quartile, pass iff 95% CI lower bound > 1 (K-R1
otherwise). Supporting, non-gating: full-model aperture coefficient
(sign, LR p) and held-out delta-AUC.
"""

import json
import math
import os
import time
import zipfile
from collections import Counter, defaultdict, deque

import numpy as np

from aperture_lib import ego_aperture, aperture_bruteforce_check

SEED = 20260913
T0 = "2024-09-01"
N_CONTROLS = 10000
CAP = 16
GRAPH = "data/graph-t0-rubygems.npz"
OSV_ZIP = "data/osv-rubygems.zip"
ECOSYSTEM = "RubyGems"


def spearman(a, b):
    def rank(v):
        v = np.asarray(v, dtype=float)
        order = np.argsort(v, kind="stable")
        ranks = np.empty(len(v))
        ranks[order] = np.arange(len(v), dtype=float)
        for val in np.unique(v):
            m = v == val
            ranks[m] = ranks[m].mean()
        return ranks
    ra, rb = rank(a), rank(b)
    ra -= ra.mean()
    rb -= rb.mean()
    d = np.sqrt((ra ** 2).sum() * (rb ** 2).sum())
    return float((ra * rb).sum() / d) if d > 0 else float("nan")


def transitive_size(start, adj):
    seen = {start}
    q = deque([start])
    while q:
        u = q.popleft()
        for w in adj.get(u, ()):
            if w not in seen:
                seen.add(w)
                q.append(w)
    return len(seen) - 1


def pagerank(n, src, dst, d=0.85, iters=100, tol=1e-12):
    outdeg = np.zeros(n)
    np.add.at(outdeg, src, 1.0)
    pr = np.full(n, 1.0 / n)
    dangling = outdeg == 0
    for _ in range(iters):
        share = np.where(dangling, 0.0, pr / np.maximum(outdeg, 1))
        nxt = np.zeros(n)
        np.add.at(nxt, dst, share[src])
        nxt = (1 - d) / n + d * (nxt + pr[dangling].sum() / n)
        if np.abs(nxt - pr).sum() < tol:
            pr = nxt
            break
        pr = nxt
    return pr


def fit_logistic(X, y, l2=1.0, iters=100):
    n, k = X.shape
    Xb = np.hstack([np.ones((n, 1)), X])
    beta = np.zeros(k + 1)
    lam = np.full(k + 1, l2)
    lam[0] = 0.0
    for _ in range(iters):
        eta = np.clip(Xb @ beta, -30, 30)
        mu = 1 / (1 + np.exp(-eta))
        W = mu * (1 - mu)
        grad = Xb.T @ (y - mu) - lam * beta
        H = (Xb * W[:, None]).T @ Xb + np.diag(lam)
        step = np.linalg.solve(H, grad)
        beta += step
        if np.abs(step).max() < 1e-10:
            break
    eta = np.clip(Xb @ beta, -30, 30)
    ll = float(np.sum(y * eta - np.log1p(np.exp(eta))))
    return beta, ll


def predict(beta, X):
    Xb = np.hstack([np.ones((len(X), 1)), X])
    return 1 / (1 + np.exp(-np.clip(Xb @ beta, -30, 30)))


def auc(y, score):
    order = np.argsort(score, kind="stable")
    ranks = np.empty(len(score))
    ranks[order] = np.arange(1, len(score) + 1, dtype=float)
    for val in np.unique(score):
        m = score == val
        ranks[m] = ranks[m].mean()
    n1 = int(y.sum())
    n0 = len(y) - n1
    if n1 == 0 or n0 == 0:
        return float("nan")
    return float((ranks[y == 1].sum() - n1 * (n1 + 1) / 2) / (n1 * n0))


def chi2_sf_1dof(x):
    return math.erfc(math.sqrt(max(x, 0.0) / 2))


def stratified_folds(y, k, rng):
    folds = np.zeros(len(y), dtype=int)
    for cls in (0, 1):
        idx = np.flatnonzero(y == cls)
        rng.shuffle(idx)
        folds[idx] = np.arange(len(idx)) % k
    return folds


def load_osv():
    pub = defaultdict(list)
    with zipfile.ZipFile(OSV_ZIP) as zf:
        for entry in zf.namelist():
            if not entry.endswith(".json"):
                continue
            rec = json.loads(zf.read(entry))
            if rec.get("withdrawn"):
                continue
            published = rec.get("published")
            if not published:
                continue
            seen = set()
            for aff in rec.get("affected", []):
                pkg = aff.get("package", {})
                if pkg.get("ecosystem") == ECOSYSTEM:
                    name = pkg.get("name")
                    if name and name not in seen:
                        seen.add(name)
                        pub[name].append(published)
    return {k: sorted(v) for k, v in pub.items()}


def main():
    assert aperture_bruteforce_check()
    t_start = time.time()

    z = np.load(GRAPH, allow_pickle=False)
    names_arr = z["names"]
    src, dst = z["edge_src"], z["edge_dst"]
    first_ver, n_versions = z["first_ver"], z["n_versions"]
    n = len(names_arr)
    name_of = {i: str(names_arr[i]) for i in range(n)}
    idx_of = {str(names_arr[i]): i for i in range(n)}

    deps = defaultdict(list)
    rdeps = defaultdict(list)
    for a, b in zip(src.tolist(), dst.tolist()):
        deps[a].append(b)
        rdeps[b].append(a)
    dependents_count = np.zeros(n, dtype=np.int64)
    np.add.at(dependents_count, dst, 1)
    dependencies_count = np.zeros(n, dtype=np.int64)
    np.add.at(dependencies_count, src, 1)
    indeg = {i: int(dependents_count[i]) for i in range(n)}

    population = np.flatnonzero(dependents_count >= 1)
    print(f"population (>=1 dependent at T0): {len(population)}", flush=True)

    # ---- gates: no outcomes touched ----
    rng = np.random.default_rng(SEED)
    gate_sample = rng.choice(population, size=200, replace=False)
    g16, g12 = [], []
    for p in gate_sample.tolist():
        g16.append(ego_aperture(p, deps, rdeps, indeg, name_of, 16))
        g12.append(ego_aperture(p, deps, rdeps, indeg, name_of, 12))
    rho = spearman(g16, g12)
    top_val, top_n = Counter(g16).most_common(1)[0]
    share = top_n / len(g16)
    er0a = rho >= 0.7
    er0b = share <= 0.9
    print(f"E-R0a stability: rho = {rho:.3f} -> "
          f"{'PASS' if er0a else 'FAIL (gate)'}")
    print(f"E-R0b degeneracy: top value {top_val} share {share:.1%} -> "
          f"{'PASS' if er0b else 'FAIL (gate)'}")
    gates = {"rho_16_12": rho, "top_value": int(top_val),
             "top_share": share, "E_R0a": bool(er0a), "E_R0b": bool(er0b)}
    if not (er0a and er0b):
        os.makedirs("out", exist_ok=True)
        with open("out/replication.json", "w") as f:
            json.dump({"gates": gates, "verdict": "GATE FAIL"}, f, indent=1)
        print("gates failed; replication ends as registered")
        return

    # ---- outcomes ----
    osv = load_osv()
    outcome = np.zeros(n, dtype=np.int8)
    prior_adv = np.zeros(n, dtype=np.int32)
    for cname, dates in osv.items():
        i = idx_of.get(cname)
        if i is None:
            continue
        prior_adv[i] = sum(1 for d in dates if d[:10] < T0)
        if any(d[:10] >= T0 for d in dates):
            outcome[i] = 1
    cases = np.array([i for i in population.tolist() if outcome[i] == 1])
    negatives = np.array([i for i in population.tolist() if outcome[i] == 0])
    print(f"cases {len(cases)}, negatives {len(negatives)}", flush=True)

    controls = rng.choice(negatives, size=min(N_CONTROLS, len(negatives)),
                          replace=False)
    sample = np.concatenate([cases, controls])
    y = np.concatenate([np.ones(len(cases)), np.zeros(len(controls))])

    pr = pagerank(n, src, dst)
    feats, apertures = [], []
    for k_i, p in enumerate(sample.tolist()):
        tdept = transitive_size(p, rdeps)
        tdep = transitive_size(p, deps)
        age_days = (np.datetime64(T0) - np.datetime64(str(first_ver[p])[:10])
                    ) / np.timedelta64(1, "D")
        ap = ego_aperture(p, deps, rdeps, indeg, name_of, CAP)
        apertures.append(ap)
        feats.append([
            math.log1p(dependents_count[p]),
            math.log1p(dependencies_count[p]),
            math.log1p(tdept),
            math.log1p(tdep),
            math.log1p(pr[p] * n),
            float(age_days),
            math.log1p(n_versions[p]),
            float(prior_adv[p]),
        ])
        if (k_i + 1) % 1000 == 0:
            print(f"  features {k_i + 1}/{len(sample)} "
                  f"({time.time() - t_start:.0f}s)", flush=True)

    X_base = np.array(feats)
    ap_arr = np.array(apertures, dtype=float)
    X_full = np.hstack([X_base, np.log1p(ap_arr)[:, None]])

    # ---- PRIMARY: E-R1 quiet-criticality OR ----
    conemass = X_base[:, 2]
    q3 = np.quantile(conemass, 0.75)
    stratum = conemass >= q3
    ap_s, y_s = ap_arr[stratum], y[stratum]
    lo_q, hi_q = np.quantile(ap_s, 0.25), np.quantile(ap_s, 0.75)
    low, high = ap_s <= lo_q, ap_s >= hi_q
    a = y_s[low].sum() + 0.5
    b = (low.sum() - y_s[low].sum()) + 0.5
    c = y_s[high].sum() + 0.5
    d = (high.sum() - y_s[high].sum()) + 0.5
    or_ = (a / b) / (c / d)
    se = math.sqrt(1 / a + 1 / b + 1 / c + 1 / d)
    ci = (math.exp(math.log(or_) - 1.96 * se),
          math.exp(math.log(or_) + 1.96 * se))
    er1 = ci[0] > 1.0
    print(f"\nE-R1 PRIMARY: stratum n={int(stratum.sum())}, "
          f"low-aperture n={int(low.sum())} ({int(y_s[low].sum())} cases), "
          f"high-aperture n={int(high.sum())} ({int(y_s[high].sum())} cases)")
    print(f"quiet-criticality OR = {or_:.2f} [{ci[0]:.2f}, {ci[1]:.2f}]")
    verdict = "E-R1 PASS (replicated)" if er1 else "K-R1 KILL"
    print(f"verdict: {verdict}")

    # ---- supporting, non-gating ----
    def standardize(train, *others):
        mu, sd = train.mean(0), train.std(0)
        sd[sd == 0] = 1.0
        return [(m - mu) / sd for m in (train,) + others]

    folds = stratified_folds(y, 5, np.random.default_rng(SEED))
    d_aucs = []
    for f in range(5):
        tr, te = folds != f, folds == f
        Xb_tr, Xb_te = standardize(X_base[tr], X_base[te])
        Xf_tr, Xf_te = standardize(X_full[tr], X_full[te])
        bb, _ = fit_logistic(Xb_tr, y[tr])
        bf, _ = fit_logistic(Xf_tr, y[tr])
        d_aucs.append(auc(y[te], predict(bf, Xf_te))
                      - auc(y[te], predict(bb, Xb_te)))
    Xb_all, = standardize(X_base)
    Xf_all, = standardize(X_full)
    _, ll_b = fit_logistic(Xb_all, y, l2=0.0)
    bf_all, ll_f = fit_logistic(Xf_all, y, l2=0.0)
    lr_stat = 2 * (ll_f - ll_b)
    p_lr = chi2_sf_1dof(lr_stat)
    print(f"supporting: aperture coef {bf_all[-1]:+.4f}, LR p = {p_lr:.2e}, "
          f"mean dAUC {float(np.mean(d_aucs)):+.4f}")

    os.makedirs("out", exist_ok=True)
    with open("out/replication.json", "w") as f:
        json.dump({
            "gates": gates, "cases": int(len(cases)),
            "controls": int(len(controls)),
            "primary": {"stratum_n": int(stratum.sum()),
                        "low_n": int(low.sum()),
                        "low_cases": int(y_s[low].sum()),
                        "high_n": int(high.sum()),
                        "high_cases": int(y_s[high].sum()),
                        "odds_ratio": or_, "ci95": ci, "pass": bool(er1)},
            "supporting": {"aperture_coef_std": float(bf_all[-1]),
                           "lr_stat": lr_stat, "p_lr": p_lr,
                           "d_aucs": d_aucs,
                           "mean_delta_auc": float(np.mean(d_aucs))},
            "verdict": verdict,
        }, f, indent=1)
    print(f"wrote out/replication.json ({time.time() - t_start:.0f}s total)")


if __name__ == "__main__":
    main()
