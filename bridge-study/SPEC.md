# Bridge study: dependency cones as Heyting-algebra elements

*Registered spec, 2026-09-12, before any computation beyond the hand
calculations recorded here. Question: is the conemass limb connected
to the lattice spine by bone rather than tendon — do the program's
kernel-checked invariants (ordinariness, aperture, co-aperture) say
anything about dependency cones that cone size does not already say?*

## Setup and conventions

A dependency graph G has edge p → q meaning "p depends on q". Define
the poset P (assume G acyclic; collapse cycles to points otherwise):

    q ≤ p  iff  p transitively depends on q, or p = q.

Dependencies sit *below*; base libraries are minimal, leaf apps
maximal.

Two Heyting algebras, both canonical:

- **Dependency side** A↓ = D(P), the down-sets of P under inclusion.
  The principal down-set ↓p = {p} ∪ deps(p) is p's dependency cone.
- **Dependents side** A↑ = D(P^op) = up-sets of P. The principal
  element ↑p = {p} ∪ dependents(p) is the cone conemass measures.

In D(P): meet = ∩, join = ∪, U ⇨ V = {x : ↓x ∩ U ⊆ V} (itself a
down-set), ¬U = {x : ↓x ∩ U = ∅}.

All invariants are the kernel-checked definitions used verbatim:

- ordinary(a) := a^¬¬ ≠ a ∧ a^¬ ≠ ⊥            (`OrdinaryElement`)
- nucleus := inflationary, idempotent, ∧-preserving  (`IsNucleus`)
- Opens j k := (jk ⇨ j⊥) ≠ j⊥ ∧ ((jk ⇨ j⊥) ⇨ j⊥) ≠ jk
- aperture(k) := #{ j nucleus | Opens j k }
- phantomMass(j,k) := #Icc(k, jk); coaperture(k) := Σ_j phantomMass

Nuclei are enumerated by their fix-sets: S ⊆ A with ⊤ ∈ S, closed
under ∧ and under (a ⇨ ·) for every a ∈ A; j(x) = least s ∈ S with
x ≤ s. (E0 cross-checks this characterization against brute-force
enumeration of all maps on algebras small enough to allow it.)

## E0 — validation against the kernel

The engine must reproduce, exactly:

1. On the 3-element chain poset (D(P) = 4-chain): nuclei count
   2^3 = 8; coaperture of the element at height e is 2^4 − 2^e,
   i.e. (⊥,·,·,⊤) = (15, 14, 12, 8). [Kernel-checked:
   `coaperture_chain_add`, `nucleusEquivTopSets`.]
2. Fix-set enumeration agrees with brute-force enumeration of all
   self-maps satisfying the nucleus axioms, on every algebra with
   ≤ 6 elements appearing below.

Any mismatch stops the study.

## Hand-computed structural facts (registered as expectations)

**H1 (universal base kills the dependency side).** If P has a minimum
m (a package everything depends on, e.g. libc inside one distro),
then for any nonempty down-set U, every ↓x contains m ∈ U, so
¬U = ∅: *every nonempty element of A↓ is dense and none is
ordinary.* One-line theorem; the pilot confirms it on the
shared-base motif. Consequence: inside a base-rooted ecosystem the
dependency side is intuitionistically degenerate; structure, if any,
must live on the dependents side or appear after deleting the base.

**H2 (no dependencies, no structure).** D(P) is Boolean iff P is an
antichain. Chains also carry no ordinary elements (interior elements
are dense, endpoints regular). So ordinariness of cones requires
*branching entanglement* — neither isolation nor a single line.

**H3 (minimal ordinary motif — hand-computed, the pilot must
reproduce it exactly).** P = {p < b, q isolated} (b depends on p; q
a bystander). D(P) = {∅, {p}, {q}, {p,q}, {p,b}, ⊤}, six elements.
Then:

- ↓p = {p}: ¬ = {q} ≠ ∅, ¬¬ = {p,b} ≠ {p} → **ordinary**
- ↓b = {p,b}: ¬ = {q}, ¬¬ = {p,b} → regular
- ↓q = {q}: ¬ = {p,b}, ¬¬ = {q} → regular

The unique ordinary principal cone belongs to **p — the quiet
depended-upon node**. The dependent (the "app") and the bystander
are classical. Dually, on the dependents side of the same motif the
unique ordinary cone is ↑b. Graph reading of ordinariness of ↓p:
someone is dependency-disjoint from p (non-dense) *and* someone
outside p's cone is entangled with it (non-regular) — a
position-not-property predicate.

## E-claims for the pilot

**E1.** H1–H3 confirmed computationally (these are checks of the
engine as much as of the theory).

**E2 (the real question — information beyond cone size).** On an
ensemble of ecosystem-like DAGs, the spine invariants of principal
cones (ordinary flag, aperture, coaperture, on both sides) are *not*
functions of cone size. Operationally: among principal cones of
equal size within the same algebra, the invariants take more than
one value somewhere in the ensemble, and Spearman |ρ| between
coaperture and cone size across the ensemble is bounded away from 1
(registered threshold: |ρ| ≤ 0.95 pooled, and ≥ 10% of equal-size
pairs separated by some invariant).

**E3 (xz motif, exploratory — direction registered, no numbers).**
On the xz-shaped motif (deep quiet lib under a chain of dependents,
famous leaf apps on a common base at equal or larger cone size), the
liblzma-position node differs algebraically from the fame-position
node. Expected direction, from H3: the infrastructure node's cone is
ordinary or has strictly larger coaperture-per-cone-size than the
leaf's.

## Kill conditions

**K1 (redundancy kill).** If across the ensemble every invariant is
(rank-)determined by cone size — equal-size cones never separated,
|ρ| > 0.95 — the bridge is redundant: the algebra restates counting,
and conemass owes it nothing. The limb stays tendon.

**K2 (degeneracy kill).** If on realistic motifs (base-rooted or
not) no principal cone is ever ordinary on *either* side, the
ordinariness layer is vacuous for dependency graphs and only the
counting invariants (coaperture) survive; the four-cell/aperture
half of the bridge dies even if K1 fails.

**K3 (engine kill).** Any E0 mismatch: stop, fix or abandon.

## Procedure

Brute force in Python (numpy-free, bitmask down-sets), one script
`01-downset-pilot.py`:

1. E0 validation.
2. Motifs: 3-chain; 2-antichain; V (shared base); Λ (shared
   dependent); H3 minimal motif; xz motif (7 nodes: glibc base;
   liblzma → glibc; libsystemd → liblzma, glibc; sshd → libsystemd,
   glibc; app2, app3 → glibc; app2 → libssl → glibc). Both sides
   each.
3. Ensemble: 40 random layered DAGs, 6 nodes, lower-triangular edge
   probability 0.35, seed 20260912; skip graphs whose algebra
   exceeds 64 elements or 20 000 nuclei (log skips). Per principal
   cone record: side, cone size, dense/regular/ordinary flags,
   aperture, coaperture.
4. Apply E2/K1/K2 thresholds as registered above. Report.

## What each outcome means

- **K1 fires:** conemass stays mathematically orphaned; the honest
  statement is "the thesis connects them, no theorem does," and the
  program stops claiming otherwise.
- **K2 fires but K1 doesn't:** the connection is real but only
  counting survives; the bridge is co-aperture-only.
- **E2 and E3 pass:** dependency cones carry algebraic structure
  invisible to cone size, the ordinariness detector selects
  infrastructure positions in at least the minimal motif and the xz
  motif, and the last edge of the program's graph is bone. Next step
  would then be the Lean statement (H1 is already one line), not
  more computation.
