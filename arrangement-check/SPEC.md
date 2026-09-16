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

---

## Amendment (2026-09-15, evening): independent reproduction,
## convention pinned, scaling phase registered

**Independent reproduction.** An external recount from a separate
construction (LP feasibility for faces, brute force over all 2^19
subsets, no shared code) reproduced every structural claim exactly:
19 faces, 2,171 opens, six half-planes regular, seven cells regular,
nine phantom pairs ordinary with ¬¬ adding exactly the seam.

**Convention, stated once.** ⊤ is the unique element that is both
dense (¬⊤ = ⊥) and regular (¬¬⊤ = ⊤); in any Heyting algebra the
overlap of the two classes is exactly {⊤} (dense ∧ regular ⟹
U = ¬¬U = ¬⊥ = ⊤). The census classifier is **dense-first**, so ⊤
is reported under dense: 621 dense / 127 regular / 1,423 ordinary.
A regular-inclusive recount gets 128 regular; identical algebra,
identical ordinary count.

**Registered before script 02 runs:**

- **E5 (enumerator validation).** For n = 4 and n = 5 generic lines,
  the face construction must reproduce the closed-form counts:
  C(n,2) vertices, n² edges, 1 + n + C(n,2) cells (33 faces at
  n = 4, 51 at n = 5). Any mismatch stops the scaling run — this is
  the off-by-one insurance the external notes demanded.
- **E6 (scaling census).** Census of the open-set algebra at n = 4
  (exact enumeration if the algebra size permits; the script must
  say which). At n = 5, exact total and dense counts via the
  stratum decomposition; ordinary fraction derived only if E7
  holds. The question a referee asks: is the 65% an n = 3 artifact
  or stable in n? No expectation registered on the direction.
- **E7 (the Glivenko bridge).** Conjecture, from 127 + 1 = 2^7:
  the regular elements (regular-inclusive convention) are in
  bijection with subsets of cells — i.e. the Booleanization of the
  arrangement algebra is exactly the power set of Cover's regions.
  Supporting hand argument, recorded now: ¬V depends only on
  V ∩ cells (any face of ↑F ∩ V forces a cell of ↑F into V because
  V is an up-set), so ¬¬U is determined by U's cells. To check:
  count of regulars = 2^{#cells} and injectivity of U ↦ U ∩ cells
  on regulars, at n = 3 and n = 4. If it holds, the regular count
  at any n is 2^{#cells} and Cover's object *is* the classical
  skeleton, by theorem-shaped identity rather than atmosphere.
- **E3′ (seam exactness at scale).** All n² adjacent-cell pairs at
  n = 4 and n = 5: ordinary, with ¬¬ adding exactly the seam.
  Registered expectation: n²-for-n², continuing the 9-for-9.

**Kill for the scaling phase: K2.** If the ordinary fraction at
n = 4 drops below 1/3 (i.e. the mid-tone thins as n grows toward
the regime Cover's theorem concerns), the "65% floor" language is
retired and Problem 1 keeps only the seam result (E3/E3′) as its
floor. The seam result is the load-bearing claim either way; the
census is context.

---

## Postscript (2026-09-15, evening): scaling run complete

`02-scaling-census.py`, one run, no code changes after first
execution. Exact rational arithmetic throughout; n = 3 recomputed
from scratch as a control and matched script 01 digit for digit.

- **E5 PASS at n = 3, 4, 5.** Face construction reproduces the
  closed forms exactly (19 = 3+9+7, 33 = 6+16+11, 51 = 10+25+16).
  The enumerator is validated before any census it produced was
  trusted.
- **E3′ PASS, 50 for 50.** Every adjacent-cell pair at every n is
  ordinary with ¬¬ adding exactly the seam: 9/9, 16/16, 25/25.
  Seam recovery is exact at every scale tested, not a small-n
  accident. All half-planes and all single cells regular at every
  n (E1/E2 analogues).
- **E6: the mid-tone thickens.** Ordinary fraction 65.5% (n = 3,
  exact, 2,171 opens) → **78.8%** (n = 4, exact, 469,535 opens) →
  **86.2%** (n = 5, derived, 475,331,561 opens). **K2 does not
  fire**; the direction is the opposite of the artifact worry. The
  classical (regular) part collapses proportionally: 5.9% → 0.44%
  → 0.014% of the algebra.
- **E7 HOLDS exactly at n = 3 and n = 4** (the two sizes where full
  enumeration was affordable): regulars including ⊤ number exactly
  2^{#cells} (128, 2048) and the map U ↦ U ∩ cells is injective on
  them. **The Booleanization of the arrangement algebra is the
  power set of Cover's regions** — his counting object is
  identically the classical skeleton of this algebra, Glivenko
  landing on the seam. The n = 5 census line is derived through E7
  and labeled as such; E7 itself is verified only at n ≤ 4 and is
  the natural Lean target (the hand argument — ¬V depends only on
  V ∩ cells because up-sets propagate any witness to a cell — is
  recorded in the amendment above).

**One-line summary.** Validated enumerator, seam exact at every
scale (50/50), Cover's object identified as the Boolean skeleton by
exact count at two sizes, and the ordinary mid-tone *growing*
toward dominance with n. Problem 1's floor is no longer one census
at one size; it is a trend, an identity, and an exact recovery
statement.

*(Superseded in part by Amendment 2 below: the identity and the
seam exactness are corollaries of a two-line general fact, not
arrangement discoveries.)*

---

## Amendment 2 (2026-09-15, evening): the census was forced — retraction and reduction

External review (independent recount confirming every number,
including 469,535 opens and 2048 = 2^11 regulars at n = 4) supplied
the fact that generates the whole survey. Recorded here as the
governing result, with proof, because it retracts one claim and
reclassifies three others.

**The theorem (any finite poset, opens = up-sets; two lines).**
Every element sits below a maximal one, and U is an up-set, so
↑x meets U iff some maximal element above x lies in U. Hence
¬U = {x : no maximal above x is in U} depends only on U ∩ Max, and

> ¬¬U = {x : every maximal face above x lies in U}.

For maximal m: m ∈ ¬¬U ⟺ m ∈ U. Consequences, all general:

1. **Regulars = 2^{#Max}, exactly, at every size.** T ⊆ Max ↦
   {x : all maximals above x in T} is a bijection onto the regular
   elements, inverse U ↦ U ∩ Max. E7 was never a conjecture needing
   verification at two sizes; it is a paragraph about Alexandrov
   algebras. The Booleanization of *any* finite Alexandrov algebra
   is the power set of its maximal elements.
2. **Dense ⟺ U ⊇ Max.** So the dense count is exactly the number
   of up-sets of the boundary poset P∖Max (621 at n = 3 — matches
   script 01). The entire four-class census of any such algebra
   reduces to **two numbers: |U(P)| and |U(P∖Max)|**; ordinary is
   the remainder.
3. **E3/E3′ (seam exactness, 50 for 50) is forced.** For two cells
   sharing exactly one edge, ¬¬{c₁, c₂} = faces all of whose upper
   cells lie in {c₁, c₂} = the two cells plus that edge. It could
   not have come out 49/50.
4. **K2 was not a genuine kill.** Regulars were pinned at 2^{#cells}
   in advance, and the mid-tone could thin only if boundary up-sets
   came to dominate total up-sets — which the growth of face posets
   rules out in practice. A kill that cannot fire is conceded as
   not having been one. (One precision against over-deflation:
   "ordinary → 1" is *not* forced by the formula alone — an
   antichain has everything regular and nothing ordinary — it needs
   the boundary layer to outgrow the cells, which is face-poset
   combinatorics. Caveat on the mechanism, not a rescue of K2.)

**Retraction.** The sentence "Cover's object is the Boolean
skeleton of the arrangement algebra" is withdrawn in its bridge
form. It reduces to: regions are the maximal faces, and
Booleanization is always the power set of maximal elements — a
fact about Alexandrov algebras with no arrangement content. It
must not be sent to Levin as a bridge between his counting theorem
and this machinery; a locale theorist dismisses it in one
sentence.

**What survives as arrangement-specific.** Exactly the two numbers
the theorem does not determine: |U(P)| = 2,171 / 469,535 /
475,331,561 and |U(P∖Max)| = 621 / …, i.e. the up-set counts of
the face poset and its boundary, and their growth rate. Those are
real combinatorics of the arrangement (oriented matroid territory,
partially known) and are where any Levin-relevant content lives.
E1/E2 (half-planes and cells regular) also survive but are likewise
derivable from the formula.

**Process note, fourth instance.** Expensive empirical machinery
confirming what a short proof settles (Citkin's capacity threshold;
the pocket study's forced future-watcher; now E7 and E3′). Rule
adopted going forward: **derive the closed form for ¬¬ in the
ambient algebra before registering any census expectation on it**;
the formula tells you which surveys are worth running. The Lean
target shifts from E7-at-n to the general theorem above (queued,
low urgency — it needs a paragraph before it needs a kernel).

---

## Postscript to Amendment 2 (2026-09-16): the general theorem is kernel-checked

`lean/FalseWorkPapers/Lattice/AlexandrovBoolean.lean`, builds clean,
stated in the repository's down-set convention (minimal elements play
the cells' role; order-dual to the up-set presentation above), and
proved for any `WellFoundedLT` order — strictly more general than the
finite case this amendment rests on:

- `LowerSet.mem_compl_compl_iff` — the forced formula (¬¬U = points
  all of whose minimal predecessors lie in U).
- `LowerSet.compl_eq_bot_iff_min` — dense ⟺ contains the whole
  minimal layer (consequence 2).
- `regularEquivMinSets` — the Booleanization bijection
  (consequence 1), with `minReg_regular` certifying the inverse.
- `card_regular_eq_two_pow` — regulars = 2^{#minimals} for every
  finite poset at once (the 128 = 2⁷ and 2048 = 2¹¹ of script 02,
  as one theorem).

The paragraph now has a kernel. Nothing in the retraction changes;
this closes the loop the process note left open.
