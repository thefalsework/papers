# Registered spec: the second-law package for phantom mass

Date: 2026-09-13. Registered before any Lean is written. Companion to
`coaperture-spec.md` (2026-09-09) and its verified file
`lean/FalseWorkPapers/Lattice/CoApertureClosedForm.lean`.

## The question

The thermodynamic reading of the ledger (ordinariness as free energy,
log co-aperture as entropy, Booleanness as the dead state) is so far a
description of existing theorems, not a generator of new ones. This
spec registers the cheapest law the reading predicts, so the frame is
tested rather than admired: **does phantom mass behave like entropy
production under coarsening of the observer?**

Observers (nuclei) are pointwise ordered: `j ≤ j'` iff `j x ≤ j' x`
for all `x`. The reading predicts a second-law shape:

- coarser observation never manufactures less phantom (monotone),
- strictly coarser observation manufactures strictly more somewhere
  (no free coarsening),
- the identity observer is the global floor and manufactures nothing,
- zero manufacture at a state characterizes equilibrium there (the
  state is a fixed point of the observer).

If any clause fails as stated, the thermodynamic reading loses its
central law and the failure is recorded; the frame reverts to
decoration. That is the kill.

## Setting

`H` a `SemilatticeInf` with `LocallyFiniteOrder` (what `phantomMass`
is defined over). `phantomMass j k = (Finset.Icc k (j k)).card`, which
counts `k` itself, so the floor is 1, not 0; "manufactures nothing"
means mass exactly 1.

## Registered statements

- **S1 (monotonicity; the second law).** If `j`, `j'` are nuclei with
  `j ≤ j'` pointwise, then `phantomMass j k ≤ phantomMass j' k` for
  every `k`.

- **S2 (the reversible observer).** `id` is a nucleus;
  `phantomMass id k = 1` for every `k`; every nucleus dominates `id`
  pointwise (inflationarity), hence by S1 every observer's mass is
  ≥ 1 everywhere. The identity is the unique zero-production floor of
  the observer order.

- **S3 (strictness; no free coarsening).** If `j ≤ j'` pointwise,
  both nuclei, and `j ≠ j'`, then there exists `k` with
  `phantomMass j k < phantomMass j' k`. (Expected witness: any `x`
  with `j x ≠ j' x`; then `j x < j' x` and the interval grows
  strictly at `k = x`.)

- **S4 (equilibrium characterization).** For a nucleus `j`:
  `phantomMass j k = 1 ↔ j k = k`. Zero manufacture at `k` iff `k`
  is a fixed point of the observer — production vanishes exactly at
  equilibrium states, which are the opens of `j`.

## Honesty notes, registered in advance

1. **S1 is order-trivial** (interval inclusion plus card
   monotonicity, expected ≤ 3 lines). The package's claim is not that
   any proof is hard; it is that the second-law *shape* — monotone,
   strict off-diagonal, unique zero, equilibrium characterization —
   holds as theorem, all four clauses together, with no extra
   hypotheses smuggled in. A law being cheap does not make it false;
   but if the cheapness turns out to require weakening a clause
   (e.g. strictness failing without finiteness), that gets recorded
   in the postscript.
2. **What this does not establish.** No temperature analogue (the
   resolution/exponent reading from the phantom pilot stays
   empirical), no work theorem (what ordinariness buys remains
   unproved), no dynamics. One law is one law.
3. S3 uses finiteness (`LocallyFiniteOrder` and, if needed,
   `Fintype`). If it holds only with `Fintype`, that restriction is
   reported, not hidden.

## Deliverable

`lean/FalseWorkPapers/Lattice/SecondLaw.lean`, building against the
existing `CoApertureClosedForm.lean` definitions, all four statements
kernel-checked or the failure documented in a dated postscript here.
