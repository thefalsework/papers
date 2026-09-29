"""Embeddings reduction and zone assignment (SPEC.md, "Embeddings and
zones").

U  = union of r-balls around training points (reduced space).
C  = closing of U by an r-ball = erosion by r of the 2r-dilation of the
     training set. p ∈ C iff every point of B(p, r) is within 2r of a
     training point. Tested by Monte Carlo: p plus N_MC points uniform in
     B(p, r), each a nearest-neighbour query. Errs one way only (a missed
     gap puts p in C).
Zones: inside = d_NN(p) ≤ r; crack = in C, not inside; exterior = not in C.
"""
from __future__ import annotations

import numpy as np
from scipy.spatial import cKDTree

N_MC = 256
INSIDE, CRACK, EXTERIOR = 0, 1, 2
ZONE_NAMES = ["inside", "crack", "exterior"]


class Reducer:
    """Standardise then PCA, both fitted on the training set only."""

    def __init__(self, X_train: np.ndarray, d: int):
        self.mu = X_train.mean(axis=0)
        sd = X_train.std(axis=0)
        sd[sd == 0] = 1.0
        self.sd = sd
        Z = (X_train - self.mu) / self.sd
        # SVD-based PCA; components sorted by variance
        U, S, Vt = np.linalg.svd(Z - Z.mean(axis=0), full_matrices=False)
        self.d = min(d, Vt.shape[0])
        self.components = Vt[: self.d]
        self.center = Z.mean(axis=0)
        var = S ** 2 / max(1, Z.shape[0] - 1)
        self.explained = float(var[: self.d].sum() / var.sum()) if var.sum() > 0 else 0.0

    def transform(self, X: np.ndarray) -> np.ndarray:
        Z = (X - self.mu) / self.sd - self.center
        return Z @ self.components.T


def uniform_ball(rng: np.random.Generator, n: int, d: int, r: float) -> np.ndarray:
    g = rng.standard_normal((n, d))
    g /= np.linalg.norm(g, axis=1, keepdims=True)
    radii = r * rng.random(n) ** (1.0 / d)
    return g * radii[:, None]


class ZoneModel:
    def __init__(self, train_reduced: np.ndarray, seed: int, n_mc: int = N_MC):
        self.train = train_reduced
        self.tree = cKDTree(train_reduced)
        self.rng = np.random.default_rng(seed)
        self.n_mc = n_mc
        self.d = train_reduced.shape[1]

    def nn_dist(self, P: np.ndarray) -> np.ndarray:
        return self.tree.query(P, k=1)[0]

    def train_nn_dist_loo(self) -> np.ndarray:
        """Leave-one-out nearest-neighbour distance within the training set."""
        return self.tree.query(self.train, k=2)[0][:, 1]

    # Relative tolerance on the 2r test. A point within r of a training point
    # has every point of its r-ball within 2r by the triangle inequality, but
    # floating-point rounding can put a boundary sample at 2r(1 + 1e-16); the
    # tolerance keeps the mathematical nesting inside <= closing exact.
    REL_TOL = 1e-9

    def in_closing(self, P: np.ndarray, r: float) -> np.ndarray:
        """Boolean per point: all MC samples in B(p, r) within 2r of training."""
        n = P.shape[0]
        offsets = uniform_ball(self.rng, n * self.n_mc, self.d, r).reshape(n, self.n_mc, self.d)
        samples = P[:, None, :] + offsets
        d_center = self.nn_dist(P)
        d_samples = self.nn_dist(samples.reshape(-1, self.d)).reshape(n, self.n_mc)
        lim = 2 * r * (1 + self.REL_TOL)
        return (d_center <= lim) & (d_samples <= lim).all(axis=1)

    def zones(self, P: np.ndarray, r: float) -> np.ndarray:
        inside = self.nn_dist(P) <= r
        inC = self.in_closing(P, r)
        # Halting assertion (spec "Zones": closing is extensive, zones nest).
        if not bool(inC[inside].all()):
            raise AssertionError(
                f"inside not contained in closing: {int((~inC[inside]).sum())} of {int(inside.sum())} "
                f"inside points failed the closing test at r={r}")
        z = np.full(P.shape[0], EXTERIOR, dtype=int)
        z[inC] = CRACK
        z[inside] = INSIDE
        return z

    def fraction_in_closing(self, P: np.ndarray, r: float) -> float:
        return float(self.in_closing(P, r).mean())

    def calibrate_primary(self, heldout: np.ndarray, target: float = 0.5, iters: int = 20) -> float:
        """Smallest r (by bisection) with ≥ target fraction of held-out in C."""
        d_held = self.nn_dist(heldout)
        lo, hi = 0.0, float(np.max(d_held)) * 1.5 + 1e-9
        for _ in range(iters):
            mid = 0.5 * (lo + hi)
            if self.fraction_in_closing(heldout, mid) >= target:
                hi = mid
            else:
                lo = mid
        return hi

    def calibrate_alternative(self, q: float = 0.9) -> float:
        return float(np.quantile(self.train_nn_dist_loo(), q))


def zone_fractions(z: np.ndarray) -> dict:
    n = max(1, len(z))
    return {name: float((z == k).sum() / n) for k, name in enumerate(ZONE_NAMES)}


def cohen_kappa(a: np.ndarray, b: np.ndarray, k: int = 3) -> float:
    n = len(a)
    if n == 0:
        return float("nan")
    po = float((a == b).mean())
    pe = sum(float((a == c).mean()) * float((b == c).mean()) for c in range(k))
    return (po - pe) / (1 - pe) if pe < 1 else 1.0
