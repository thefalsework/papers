# Arrangement check: is the Cover seam open?

*Registered spec, 2026-09-15, before any computation beyond the hand
calculations recorded here. Context: the bridge to Levin's
threshold/Cover material runs through hyperplane arrangements — the
one object both programs touch. Cover's counting theorem lives on
the arrangement's regions; this program's invariants live on
lattices. The caution (recorded from external notes, agreed):
the arrangement's *face lattice* is geometric, hence complemented,
hence every element regular — if that were the object, aperture has
nothing to grip and the seam is closed. The check: build the object
this program would actually use and see whether anything is
ordinary.*

## The object

Three lines in general position in the plane (concretely x = 0,
y = 0, x + y = 1). Faces = nonempty sign-vector strata in
{−, 0, +}³: 3 vertices, 9 edges, 7 open cells — 19 faces. Face
order: F ≤ G iff F ⊆ cl(G), equivalently (covector order) F_i ∈
{0, G_i} for all i.

The algebra is **not** the face lattice and **not** the intersection
lattice (both complemented by construction; the caution applies to
them and is conceded in advance). It is the open-set algebra of the
finite stratified space: **opens = up-sets of the face poset**, a
Heyting algebra with ¬U = {F : ↑F ∩ U = ∅}. This is the same
down-set/up-set construction used throughout the program (bridge
study, perturbation study), pointed at geometry instead of
dependency.

Decision-relevant elements, named now:

- **half-plane(i, s)** = {F : F_i = s} for line i, sign s — the
  decision region of a single threshold unit, as an element of this
  algebra.
- **cell** = a single open region (what Cover counts; 7 of them).
- **phantom pair** = two cells adjacent across an edge e, *without*
  e — the composed-threshold region with its seam, the
  PerceptronRegular.lean object in arrangement clothes.

## Hand expectations (registered; oracle must confirm or the
corresponding claim dies)

- **E1 (single units are classical).** Every half-plane(i, s) is
  regular, with ¬ = the opposite open half-plane. Matches the
  kernel-checked perceptron bridge; a mismatch here is an engine
  bug or a theory contradiction, and stops everything.
- **E2 (cells are classical).** Every single open cell is regular.
  Cover's objects, one at a time, carry no four-fold.
- **E3 (the phantom pair is ordinary).** For adjacent cells c₁, c₂
  with shared edge e: ¬¬{c₁, c₂} = {c₁, c₂, e} ≠ {c₁, c₂}, and
  ¬{c₁, c₂} ≠ ∅. Hand argument: ↑e = {e, c₁, c₂} misses ¬U, so e
  enters the double negation; far cells witness non-density.
- **E4 (the census).** Full classification of every open of the
  algebra: counts of dense / regular / ordinary. No registered
  number — this is the map the seam question needs, recorded
  whatever it says.

## Kill

- **K1 (the seam is closed).** If no open of this algebra is
  ordinary, the machinery has nothing to grip on arrangements
  even in its own preferred presentation; Problem 1 in the Levin
  letter (the corridor conjecture) needs restating before any
  further use, and this file records that first.

## Non-claims

No aperture census is registered (2^19 observers per element is
computable but the seam question doesn't need it; at most spot
values for the named elements, reported descriptively). No claim
about n lines, higher dimensions, or trained networks. No letter
content — if the seam is open this informs a *future* exchange,
after the current one resolves.

---

## Postscript (2026-09-15, same day): the seam is open

Oracle: `01-arrangement-oracle.py`, one run, no code changes after
first execution. Exact rational arithmetic; 19 faces recovered as
expected (3 + 9 + 7).

- **E1 PASS.** All six half-planes regular, and ¬(half-plane) is
  exactly the opposite open half-plane, all six times. The
  kernel-checked perceptron result reappears inside the arrangement
  algebra untouched.
- **E2 PASS.** All seven cells regular. Cover's objects, taken one
  at a time, are classical.
- **E3 PASS, 9 of 9.** Every phantom pair is ordinary, and ¬¬ adds
  *exactly* the shared edge — the double-negation remainder is the
  seam, nothing more, in every case.
- **E4 census.** 2,171 opens: 621 dense, **1,423 ordinary (65.5%)**,
  127 regular. The classical skeleton of the arrangement algebra is
  thin; the bulk of the algebra is exactly the mid-tone the program
  studies. Unregistered observation, recorded as data: the regular
  elements are a 127-element minority containing the objects
  classical treatments (Cover counting included) can see.
- **K1 does not fire.** The seam is open. Problem 1 in the Levin
  letter (the corridor conjecture) does **not** need restating: the
  caution about complemented face lattices was correct but applies
  to an object this program never uses; the finite-space open-set
  algebra has abundant ordinary structure.
- Descriptive spot apertures (unregistered): half-plane 179,168 of
  2^19; single cell 115,705; phantom pair 282,427. Nonzero and
  large; the four-fold survives most observers here.

**One-line summary.** In the one object where Cover's counting and
this program's algebra meet, single threshold units and single
regions are classical, every composed region carries its seam as
ordinary structure, and the non-classical part is not a fringe —
it is 65% of the algebra. The bridge to the threshold/Cover
material has a floor.
