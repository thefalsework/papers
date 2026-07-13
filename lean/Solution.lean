import FalseWorkPapers.Examples.ChallengeBridge

/-!
# Solution: ordinary elements of one-generated Heyting algebras

Companion to `Challenge.lean` (same directory). The challenge file imports
**Mathlib only** and states the six principal theorems of the
ordinary-elements preprint with `sorry`; this file imports the project code
that proves them.

The proofs live in `FalseWorkPapers/Examples/ChallengeBridge.lean`, which
redeclares the challenge definitions verbatim and derives the six theorems
from the `FalseWork.Lattice` library:

- `four_regions_iff_ordinary`
- `nishimura_normal_form`
- `unique_ordinary_element`
- `ordinary_forces_card_ge_six`
- `ordinary_gives_z6_embedding`
- `twelve_unique_kernel`

To check that this project proves exactly the challenge statements, using
only the axioms `propext`, `Classical.choice`, `Quot.sound`, run
[comparator](https://github.com/leanprover/comparator) against `config.json`
in this directory (see the repository `README.md`, "Verifying with
comparator"). CI does this on every push.
-/
