"""Adversarial test: can a FIXED, content-independent relabeling manufacture a
tonal kernel from scale-free cellular-automaton order?

THE THREAT THIS TEST POSES TO THE LENS
--------------------------------------
The four-position lens claims raw CA output is "pre-kernel ordered noise": it has
order (Wolfram's whole point) but no tonal home, so it correctly fails to
classify.  The first experiment (wolframtones-classification-experiment.py) found
that CA order did not read as tonal -- but under ONE arbitrary pitch mapping.

If a *fair* relabeling -- fixed in advance, identical for every field, not
peeking at the field's content -- can make scale-free CA output read as strongly
tonal as scale-CONSTRAINED output, then "kernel-presence" is a property of the
analyst's ENCODING, not of the material.  That would mean the lens over-reads:
it reports "pre-kernel" only because of an encoding choice, and a different fair
encoding finds a kernel in the same ordered noise.  That breaks the claim.

THE PRINCIPLED FAMILY OF FAIR RELABELINGS
-----------------------------------------
The structure-preserving relabelings of pitch-class space are the automorphisms
of Z/12: multiply every pitch class by a unit m in {1, 5, 7, 11}.

  m = 1  : identity (chromatic)
  m = 5  : circle of fourths
  m = 7  : circle of fifths   <-- the adversary's weapon
  m = 11 : inversion

Why m=7 is the weapon: CA output has SPATIAL RUNS (adjacent cells correlate --
that is its order).  Under m=1 adjacent cells are adjacent semitones (chromatic
clusters; key-finders read these as atonal).  Under m=7 adjacent cells become
FIFTHS apart (stacked fifths; key-finders read these as maximally tonal).  So m=7
is engineered to convert CA's defining order straight into tonal structure with
NO scale imposed.

(Structural note: the tritone, interval 6, is the fixed point of m=7 --
6*7 = 42 = 6 mod 12 -- so the kernel interval is exactly the one the fifths
relabeling cannot move.)

THE DISCRIMINATOR
-----------------
  fifths-boost(condition) = clarity(condition, m=7) - clarity(condition, m=1)

  * If fifths-boost(ca-chromatic) >> fifths-boost(random-chromatic), and
    clarity(ca-chromatic, m=7) approaches clarity(ca-diatonic): the adversary
    WINS -- raw CA order was convertible to a kernel by a fair relabeling, so the
    lens over-reads "pre-kernel".
  * If the fifths boost is about the same for CA and random: m=7 just inflates
    everything; the mapping, not the material, carries it -- no real kernel in CA
    order, and the lens survives an attack built to break it.

THE CHEAT CONTROL (admissibility boundary)
------------------------------------------
A content-DEPENDENT relabeling that sorts each field's own pitch-class
distribution onto the tonal profile manufactures a near-maximal center from
ANYTHING, including random noise.  We run it to show it scores random noise as
"maximally tonal" -- proving content-dependent mappings are inadmissible (they
would let literally any field classify).  This fixes the line between a fair test
and a rigged one.

Pure standard library.  Reproducible.
"""

from __future__ import annotations
import math
import random
from collections import Counter

# --- CA + mapping + key-finding (shared with the first experiment) ----------

def elementary_ca(rule: int, width: int, steps: int, seed: int) -> list[list[int]]:
    rng = random.Random(seed)
    row = [rng.randint(0, 1) for _ in range(width)]
    grid = [row]
    table = [(rule >> i) & 1 for i in range(8)]
    for _ in range(steps - 1):
        nxt = []
        for x in range(width):
            left = row[(x - 1) % width]
            mid = row[x]
            right = row[(x + 1) % width]
            nxt.append(table[(left << 2) | (mid << 1) | right])
        row = nxt
        grid.append(row)
    return grid


MAJOR_SCALE = [0, 2, 4, 5, 7, 9, 11]


def ca_to_pc_counts(grid, mode, tonic=0):
    counts: Counter = Counter()
    if mode == "chromatic":
        for row in grid:
            for i in range(12):
                if row[i % len(row)]:
                    counts[(tonic + i) % 12] += 1
    elif mode == "diatonic":
        for row in grid:
            for i in range(7):
                if row[i % len(row)]:
                    counts[(tonic + MAJOR_SCALE[i]) % 12] += 1
    return counts


def random_chromatic_pc_counts(n_notes, seed):
    rng = random.Random(seed)
    counts: Counter = Counter()
    for _ in range(n_notes):
        counts[rng.randint(0, 11)] += 1
    return counts


KS_MAJOR = [6.35, 2.23, 3.48, 2.33, 4.38, 4.09, 2.52, 5.19, 2.39, 3.66, 2.29, 2.88]
KS_MINOR = [6.33, 2.68, 3.52, 5.38, 2.60, 3.53, 2.54, 4.75, 3.98, 2.69, 3.34, 3.17]


def _pearson(x, y):
    n = len(x)
    mx, my = sum(x) / n, sum(y) / n
    num = sum((a - mx) * (b - my) for a, b in zip(x, y))
    dx = math.sqrt(sum((a - mx) ** 2 for a in x))
    dy = math.sqrt(sum((b - my) ** 2 for b in y))
    return num / (dx * dy) if dx and dy else 0.0


def key_clarity(counts):
    dist = [float(counts.get(pc, 0)) for pc in range(12)]
    if sum(dist) == 0:
        return 0.0
    best = -1.0
    for root in range(12):
        pm = [KS_MAJOR[(i - root) % 12] for i in range(12)]
        pn = [KS_MINOR[(i - root) % 12] for i in range(12)]
        best = max(best, _pearson(dist, pm), _pearson(dist, pn))
    return best


# --- the adversarial relabelings --------------------------------------------

def automorphism_relabel(counts: Counter, m: int) -> Counter:
    """Fixed, content-independent relabel: pitch class p -> (m*p) mod 12."""
    out: Counter = Counter()
    for pc, c in counts.items():
        out[(m * pc) % 12] += c
    return out


def cheat_relabel(counts: Counter) -> Counter:
    """Content-DEPENDENT cheat: assign the field's pitch classes, in order of
    their own frequency, onto the tonal hierarchy's rank order, maximizing the
    correlation. Manufactures a near-maximal center from any input."""
    # profile positions sorted by KS-major weight (tonic first, etc.)
    prof_rank = sorted(range(12), key=lambda i: KS_MAJOR[i], reverse=True)
    # field pitch classes sorted by their own count
    pc_rank = sorted(range(12), key=lambda pc: counts.get(pc, 0), reverse=True)
    relabel = {pc_rank[k]: prof_rank[k] for k in range(12)}
    out: Counter = Counter()
    for pc, c in counts.items():
        out[relabel[pc]] += c
    return out


# --- run --------------------------------------------------------------------

def mean(xs):
    return sum(xs) / len(xs) if xs else 0.0


def run():
    RULES = [30, 90, 110, 150, 184, 250, 54, 60, 62, 102]
    WIDTH, STEPS, SEEDS = 24, 64, list(range(20))
    AUTOS = [1, 5, 7, 11]

    clif = {c: {m: [] for m in AUTOS} for c in
            ("random-chromatic", "ca-chromatic", "ca-diatonic")}
    cheat = {"random-chromatic": [], "ca-chromatic": [], "ca-diatonic": []}

    for rule in RULES:
        for seed in SEEDS:
            grid = elementary_ca(rule, WIDTH, STEPS, seed)
            n_notes = sum(sum(r) for r in grid)
            fields = {
                "random-chromatic": random_chromatic_pc_counts(n_notes, seed * 7919 + rule),
                "ca-chromatic": ca_to_pc_counts(grid, "chromatic"),
                "ca-diatonic": ca_to_pc_counts(grid, "diatonic"),
            }
            for cond, counts in fields.items():
                for m in AUTOS:
                    clif[cond][m].append(key_clarity(automorphism_relabel(counts, m)))
                cheat[cond].append(key_clarity(cheat_relabel(counts)))

    print("=" * 76)
    print("Adversarial relabeling test")
    print(f"rules={RULES}  trials/cell={len(RULES) * len(SEEDS)}")
    print("=" * 76)
    print()
    print("KEY CLARITY under each fair (content-independent) automorphism of Z/12:")
    print(f"  m=1 identity   m=5 fourths   m=7 FIFTHS(weapon)   m=11 inversion")
    print()
    print(f"  {'condition':<20}{'m=1':>9}{'m=5':>9}{'m=7':>9}{'m=11':>9}")
    for cond in ("random-chromatic", "ca-chromatic", "ca-diatonic"):
        row = "".join(f"{mean(clif[cond][m]):>9.3f}" for m in AUTOS)
        print(f"  {cond:<20}{row}")
    print()

    boost_ca = mean(clif["ca-chromatic"][7]) - mean(clif["ca-chromatic"][1])
    boost_rand = mean(clif["random-chromatic"][7]) - mean(clif["random-chromatic"][1])
    ca7 = mean(clif["ca-chromatic"][7])
    diat = max(mean(clif["ca-diatonic"][m]) for m in AUTOS)

    print("THE DISCRIMINATOR (does the fifths map turn CA ORDER into a kernel?):")
    print(f"  fifths-boost(ca-chromatic)     = {boost_ca:+.3f}")
    print(f"  fifths-boost(random-chromatic) = {boost_rand:+.3f}")
    print(f"  differential (CA gets more than random) = {boost_ca - boost_rand:+.3f}")
    print(f"  ca-chromatic@fifths = {ca7:.3f}   vs   best ca-diatonic = {diat:.3f}")
    print()
    print("  Verdict:")
    if boost_ca - boost_rand > 0.10 and ca7 >= diat - 0.05:
        print("  -> ADVERSARY WINS. A fair fifths-relabeling converts raw CA order")
        print("     into a center as strong as an imposed scale. 'Kernel-presence'")
        print("     is encoding-relative; the lens over-reads scale-free CA output.")
    elif boost_ca - boost_rand > 0.10:
        print("  -> PARTIAL. The fifths map converts SOME CA order into tonality")
        print("     (more than it does for random), but not to scale-imposed levels.")
        print("     The 'pre-kernel' claim is softened, not broken: order carries a")
        print("     little latent kernel that a fifths-encoding can surface.")
    else:
        print("  -> LENS SURVIVES. The fifths map does not lift CA order more than it")
        print("     lifts random noise; the boost is the mapping, not the material.")
        print("     Scale-free CA order has no kernel that a fair relabeling reveals.")
    print()
    print("-" * 76)
    print("CHEAT CONTROL (content-DEPENDENT sort-to-profile; inadmissible):")
    for cond in ("random-chromatic", "ca-chromatic", "ca-diatonic"):
        print(f"  {cond:<20}{mean(cheat[cond]):>9.3f}")
    print("  -> If random noise scores ~maximal here, content-dependent mappings")
    print("     manufacture kernels from nothing and must be barred from any fair")
    print("     test. This is the admissibility line.")
    print("=" * 76)


if __name__ == "__main__":
    run()
