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

---

## Postscript (2026-09-12, same day, after the run)

Engine: `01-downset-pilot.py`, output in `out/pilot-results.json`.

**E0 passed exactly.** The brute-force engine reproduces the
kernel-checked 4-chain facts (8 nuclei; coaperture 15, 14, 12, 8 =
2^4 − 2^e) and the fix-set enumeration agrees with exhaustive
enumeration of all self-maps on every algebra small enough to allow
it. H1, H2, H3 all confirmed computationally, including the H3 hand
values digit for digit.

**No kill fired. E2 passed with margin.** Ensemble (40 graphs, 480
principal cones, zero skips): pooled Spearman between coaperture and
cone size is −0.67, nowhere near the 0.95 redundancy threshold, and
77% of equal-size cone pairs are separated by at least one invariant
— against a registered floor of 10%. 175 of 480 cones are ordinary,
so K2 (degeneracy) fails too. The invariants are not cone size in
disguise. (The *negative* sign of the correlation has a mechanical
reason worth recording: coaperture sums the room above k that
observers can inflate into, and large cones sit near ⊤ where that
room shrinks; ⊤ itself always has coaperture = #nuclei, the
minimum.)

**E3 confirmed in the registered direction, and more sharply than
registered.** On the xz motif, dependency side, the universal base
(glibc) makes every cone dense per H1 — and yet the *aperture* still
separates the positions: liblzma 21, libsystemd 21, libssl 15,
and glibc, sshd, app2, app3 all exactly 0. The three quiet middle
libraries — the xz-position class — are the only nodes some
observers' worlds render ordinary; the base and every leaf app are
classical from every viewpoint. This is the Div36 phenomenon
(distinctions existing only at a blur) appearing unprompted in a
dependency graph. At equal cone size (2), liblzma vs. app3:
coaperture 588 vs. 420, aperture 21 vs. 0. Both invariants separate
the infrastructure node from the fame node, in the registered
direction.

**One asymmetry, recorded without interpretation.** Ordinariness of
the *global* element selects different positions per side: on the
dependency side (H3, and xz aperture) it tracks quiet depended-upon
nodes; on the dependents side of the xz motif the ordinary cones are
libsystemd, sshd, app2 while liblzma is regular. Which side is the
right criticality lens — or whether the pair is the point, as with
aperture/co-aperture independence — is not settled by this pilot and
is not claimed.

**Honest limits.** Graphs of 6–7 nodes; nuclei enumeration is
exponential and dies far below ecosystem scale (a real registry has
10^5 nodes). The distance from "true on motifs" to "usable as an
instrument" is the distance the Debian claim died crossing, and no
instrument claim is made. What this pilot establishes is the
theorem-scale statement: principal dependency cones are elements of
a canonical Heyting algebra on which the program's invariants are
non-trivial, non-redundant with cone size, and select the
infrastructure position in the motifs where "infrastructure" has an
unambiguous meaning.

**Status of the bridge: bone at motif scale.** Next step, per the
spec, is Lean, not more computation — H1 first (one line), then the
H3 motif as a `decide`-checked example, then, if wanted, the general
graph reading of cone-ordinariness as a theorem.

## Postscript 2 (same day, after Lean)

`lean/FalseWorkPapers/Lattice/BridgeDownSets.lean`, kernel-checked:

- **H1 is now a theorem** (`LowerSet.regular_or_dense_of_min`): on
  Mathlib's `LowerSet P` with a global lower bound, every lower set
  is regular or dense. The abstract half
  (`compl_eq_bot_of_meets_all`) holds in any Heyting algebra.
- **All seven H3 numbers are kernel-checked** through the second
  presentation (D(P) = 3-chain × 2-chain = Div12's exponent
  lattice, via the existing closed forms): ↓p ordinary with
  aperture 1 and coaperture 18; ↓b, ↓q regular with aperture 0 and
  coapertures 12, 14. The pilot's brute-force enumeration and the
  kernel agree digit for digit across independent presentations —
  which also functions as an E0-grade validation of the pilot
  engine after the fact.

## Phase 2 (registered 2026-09-12, after Postscript 2, before any
## Phase-2 computation): the observer classification and the
## characterization theorem

Trigger: every algebra measured in Phase 1 — all six motifs and all
80 ensemble sides, 86 algebras — has exactly 2^|P| nuclei. The
observer count ignores the edges entirely.

**Literature (checked before registration, honest split).** This is
a known theorem, not ours: for a finite poset the assembly N(D(P))
is Boolean (Simmons: N(OS) Boolean iff S scattered; finite posets
are noetherian, hence scattered) and spatial (Bezhanishvili–Harding,
"The Frame of Nuclei of an Alexandroff Space", arXiv:1906.03640:
spatial iff the infinite binary tree does not embed), so
N(D(P)) ≅ 2^P with the points of the assembly corresponding to the
points of P. What is *not* in the literature is what this does to
the aperture and co-aperture of dependency cones — those invariants
are this program's. The classification is cited; the
characterization below is claimed.

**C1 (explicit form of every observer).** For S ⊆ P define

    j_S(U) = { x : ↓x ∩ S ⊆ U }.

Claim: each j_S is a nucleus, S ↦ j_S is injective, and *every*
nucleus on D(P) is j_S for exactly one S. Injectivity, hand proof:
for x ∈ S △ S', take U = ↓x ∖ {x} (a down-set, by antisymmetry);
then x ∈ j_S(U) iff x ∉ S, so j_S ≠ j_{S'}. Surjectivity then
follows from injectivity plus the cited count 2^|P| — or, per
instance, from the pilot's exhaustive enumeration. Reading: an
observer of a dependency ecosystem is exactly a *sub-ecosystem* — a
set S of packages through which everything is seen; j_S(U) asks
"which packages' dependencies, insofar as they run through S, are
already accounted for by U."

**C2 (the characterization — the new content).** j_S(U) depends
only on U ∩ S, and Fix(j_S) ≅ D(S) (down-sets of the induced
subposet) via U ↦ U ∩ S, inverse T ↦ {x : ↓x ∩ S ⊆ T}, with world
bottom j_S(⊥) ↦ ∅. Claim: Opens j_S k ⟺ the trace k ∩ S is
ordinary in D(S). Hence

    aperture(↓p) = #{ S ⊆ P : ↓p ∩ S is ordinary in D(S) }

— *the number of sub-ecosystems in which p's dependency shadow is
non-classical*. A purely graph-theoretic statement; no lattice
theory left in it.

Hand check on the H3 motif (registered): ↓p = {p}. If p ∉ S the
trace is ⊥ (regular). Non-dense forces q ∈ S; S = {p, q} gives a
Boolean D(S) (regular); S = {p, q, b} = P is the Phase-1
computation (ordinary). So exactly one qualifying S, matching
aperture(↓p) = 1 from both the pilot and the kernel.

**C3 (phantom structure).** For U ∈ D(P), the interval
[U, j_S(U)] is isomorphic to the lattice of relative down-sets of
the induced poset on j_S(U) ∖ U, so

    phantomMass(j_S, U) = #D( j_S(U) ∖ U ),
    coaperture(↓p) = Σ_{S ⊆ P} #D( j_S(↓p) ∖ ↓p ).

**E-claims.** E4: on every Phase-1 algebra (all 86), the enumerated
nuclei coincide exactly with { j_S : S ⊆ P }, bijectively. E5: on
every principal cone and every S, Opens j_S k ⟺ trace-ordinariness
in D(S). E6: on every principal cone and every S, phantomMass
equals the relative-down-set count.

**Kills.** K4: any nucleus not of the form j_S, or a collision in
S ↦ j_S. K5: any Opens/trace-ordinariness mismatch. K6: any
phantom-mass mismatch. Any kill stops the phase; the theorem as
stated is then false and the failure mode gets recorded.

**If all pass:** the Lean statement of C1–C2 (injectivity is
elementary; surjectivity by Fintype card against the cited count or
by direct argument; C2 by the fix-set isomorphism), and then the
depth test: compare the aperture ranking, now computable
combinatorially, against standard centralities on separating
families.
