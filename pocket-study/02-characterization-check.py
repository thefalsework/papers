# Post-hoc characterization check (written after 01 ran; labeled as
# such). Candidate law suggested by the minimal witness and the
# universal lattice closure:
#
#     S compatible with step (a, b)  <=>  b in S  or  S cap downset(a) = empty
#
# ("watch the future, or be blind to the past that is being rewired.")
# Tested against the full exhaustive survey; any mismatch is printed.
#
# Usage: python 02-characterization-check.py

import importlib.util
import os

HERE = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location(
    "oracle", os.path.join(HERE, "01-commutation-oracle.py"))
oracle = importlib.util.module_from_spec(spec)
import sys
_argv = sys.argv
sys.modules["oracle"] = oracle
# prevent main-block execution
oracle.__name__ = "oracle"
spec.loader.exec_module(oracle)

mismatches = 0
checked = 0
for n, down in oracle.all_posets_upto(5):
    full = (1 << n) - 1
    ds = oracle.downsets(n, down)
    for (a, b) in oracle.incomparable_pairs(n, down):
        down2 = oracle.add_edge(n, down, a, b)
        clp = oracle.make_clp(n, down, a, b)
        for S in range(1 << n):
            checked += 1
            actual = oracle.compatible(n, down, down2, clp, ds, S)
            predicted = ((S >> b) & 1 == 1) or (S & down[a] == 0)
            if actual != predicted:
                mismatches += 1
                if mismatches <= 5:
                    print(f"MISMATCH n={n} down={list(down)} edge=({a},{b}) "
                          f"S={S:b} actual={actual} predicted={predicted}")

print(f"\nchecked {checked} (step, S) pairs; mismatches: {mismatches}")
print("CHARACTERIZATION " + ("HOLDS EXACTLY" if mismatches == 0 else "FAILS"))
