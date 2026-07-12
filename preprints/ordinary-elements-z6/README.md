# The Unique Ordinary Element of a One-Generated Heyting Algebra, the Subgroup Lattice of ℤ/12ℤ, and a Characterization of n = p²q

- **Paper:** [`paper.md`](paper.md) (authoritative source) · [`paper.tex`](paper.tex) · [`paper.pdf`](paper.pdf)
- **Status:** preprint, July 2026, not yet submitted.
- **Lean formalization:** [`../../lean/FalseWorkPapers/Examples/`](../../lean/FalseWorkPapers/Examples/); theorem-by-theorem correspondence in §10 of the paper and in [`../../formalization.yaml`](../../formalization.yaml).

## Verifying the claims

The principal theorems are stated in Mathlib-only vocabulary in
[`../../lean/Challenge.lean`](../../lean/Challenge.lean) and can be verified with
[comparator](https://github.com/leanprover/comparator) without trusting any code
in this repository — read that one file, then run one command. Instructions:
[`../../lean/README.md`](../../lean/README.md), section *Verifying the
ordinary-elements results with comparator*. CI runs the check on every push
touching `lean/` ([workflow](../../.github/workflows/comparator.yml)).

## Scope of the audit claims

The paper's formalization claims — kernel-checked, no `sorry`, no
`native_decide`, axioms at most `propext` / `Classical.choice` / `Quot.sound` —
attach to the files cited in its §10 audit table (the `scope_files` list in
[`../../formalization.yaml`](../../formalization.yaml)). Two files elsewhere in
`lean/FalseWorkPapers/Examples/` — `MusicKernelZMod12Accum.lean` and
`PythagoreanCommaConvergents.lean` — belong to the music-kernel track of a
different paper and use `native_decide`; they are outside this paper's claims.

Two seams are flagged in the paper itself (§10): the minimality of the `H₈`
counterexample rests on script-level enumeration, and the general "divisor
lattice = product of chains" structure theorem is cited classically (the
n = 12 instance is kernel-checked).

## Provenance

AI-authored (Claude, in Cursor) under the direction and review of Chris Brink;
prior-art standing adjudicated by correspondence with Alex Citkin (June 2026,
cited with permission; record at
[`../../docs/outreach/citkin-email.md`](../../docs/outreach/citkin-email.md)).
