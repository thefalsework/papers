# Proving the Poem

*2026-09-11. A retrospective reading of "AI" (Chris Brink, long poem,
written years before this repository existed) against the formal
program. The claim is not that the poem predicted the results. The
claim is that the poem is the selection function: it states, in
verse, the propositions this program has been converting into
statements a kernel can check. Written down the evening its author
noticed.*

## Honesty note first

This mapping is post hoc. None of it was registered before the
theorems were proved, and a sufficiently long poem can be matched to
almost anything if you squint. Two things keep this note from being
numerology. First, the correspondences below are not thematic
resemblances; several are near-verbatim statements of formal
definitions, written decades before the definitions. Second, the
mapping explains a fact that needed explaining: why this program's
parts (partition, aperture, co-aperture, conemass, phantom pilot)
kept feeling connected before anyone could say how. The through-line
was never a principle. It was this document.

Each entry gives the poem's claim, the formal statement it became,
and the status of that statement under the repository's usual
grades.

## The ledger

### 1. "To seed a deep wound... The wound is a womb."

The generative cut. A single distinction, made in the right kind of
element, does not merely divide — it opens inhabited regions on both
sides of itself.

**Formal statement:** the four-position partition. A morphism in an
elementary topos is classified into exactly four positions, and the
partition is non-degenerate — all four cells inhabited — precisely
when the classifying element is *ordinary* (neither dense nor
regular). The wound is a womb if and only if the element is
ordinary; cuts in classical elements are sterile.

**Status: kernel-checked** (`lean/`, four-cell theorem; preprint
`preprints/four-position-partition/`, Zenodo DOI on record).

### 2. "A masterpiece of counterfeit death. A true and perfect image of life."

Falstaff's move, run through Hamm's handkerchief: presence performed
exactly where absence is, and performed so well the audience cannot
tell. Confident false presence.

**Formal statement:** phantom mass. For a nucleus j and kernel
element k, the interval [k, j k] is exactly the set of elements the
observer j cannot distinguish from k (the confusion-class lemma);
its cardinality is the phantom mass, and the sum over all observers
is the co-aperture. The ¬¬-remainder is the algebra's standing
counterfeit: a region the coarse-grained view swears is interior.

**Status: kernel-checked** for the algebra (confusion-class lemma,
chain and divisor-lattice closed forms, independence from the
aperture — `CoApertureClosedForm.lean`). **Registered kill** for the
geometry: the phantom-mass pilot (K1) found the counterfeit in
trained networks is measure-zero seam, α ≈ 2, codimension-2 —
points and corners, not volume. The poem's claim survives in the
algebra and dies in the rasterized geometry, and both halves are on
record (`phantom-study/SPEC.md`).

### 3. "A counterfeit masterpiece unable to negate or affirm."

Said of the projection on the screen — light as false as water,
tapering to dark and back, never resolving.

**Formal statement:** this is the most literal entry in the ledger.
An *ordinary* element is precisely one unable to negate or affirm:
not dense (its negation is nonzero — it cannot affirm everything),
not regular (it is strictly below its double negation — negation
applied twice does not return it). The entire program rests on the
elements the poem describes in this line. The intuitionistic middle
is the counterfeit masterpiece.

**Status: kernel-checked** (ordinariness is the standing hypothesis
of the four-cell theorem and both aperture invariants).

### 4. "A roughing in of the universe in lack of perspective requires a supplement — a belief in imagination."

The stage's frescoed heaven works only from the stalls. Every
illusion in the poem depends on the audience sitting at the right
distance, under the right light — the director spends an entire
scene calibrating the blur.

**Formal statement:** observers as nuclei; the aperture as the count
of observers from which an element's ordinariness survives. The
Div36 result is the theatrical case exactly: distinctions that exist
*only* at a blur — invisible both close up and far away.

**Status: kernel-checked** (aperture closed forms on chains,
products, divisor lattices; `preprints/aperture/`, v0.4, Zenodo DOI
on record).

### 5. "Structures upon structures, the superstructure... reusing waste — to land at this contemporaneous junk pile."

The theater is built inside a defunct factory, on ruins, on soil, on
accumulated fragments nobody applauds. The load-bearing thing is the
unglamorous machinery under the stage.

**Formal statement:** position over properties. Importance is not a
property printed on the object; it is a position in the web of what
leans on what. conemass measures it for software dependency graphs;
the xz retrodiction is the case study (fame said #173, position said
#8, the attackers agreed with position).

**Status: empirical, registered** (conemass repo, quiet-criticality
paper, OpenSSF submission; `notes/position-over-properties.md`).

### 6. Harold: "The likeness is astonishing... We are not looking for an actor."

Harold is cast for what he is, not what he can do. Alone on the
plinth he can hold exactly one pose — the tableau — and every scene
he carries is manufactured around him by lights, costume, direction,
composition. The seam where the performance becomes more than the
man is built by the ensemble, not the actor.

**Formal statement:** the perceptron bridge. A single threshold unit
is a *regular* (classical) element of the Heyting algebra of
decision regions — it can only play classical roles, exactly one
pose. Composition is where non-classical structure first appears:
`composed_seam` exhibits the phantom region no single unit
possesses. Harold is a perceptron. The play is the network.

**Status: kernel-checked** (`PerceptronRegular.lean`;
`preprints/perceptron-bridge/`, Zenodo DOI on record).

### 7. The flower initialed "AI"

Ajax falls on his sword; from the blood springs a posy, one leaf
initialed AI — the hyacinth myth, where the flower's markings spell
the dead hero's cry. The same two letters are simultaneously a
grief-cry (aiai), a man's initials, and the name of the machine.
Nothing about the mark itself distinguishes the readings. Only
position does.

**Formal statement:** none, and none needed — this is the thesis
itself, stated in two characters. Meaning by position rather than
property. It is also the poem's title.

**Status: thesis** (the one entry that is the program rather than
a result of it).

### 8. "Failure / Better. / It is beginning."

The poem's last three lines.

**Formal statement:** the registered-kill methodology. Priors and
kill conditions written before the experiment; negative results
published with their mechanism (the Debian claim, K1 in the phantom
pilot); the kill treated as product, not embarrassment.

**Status: practiced throughout** (`phantom-study/SPEC.md` Phase 1
postscript is the cleanest instance: killed, with a named mechanism
and a dimensional readout).

## What this changes

Nothing about the mathematics, everything about the navigation. The
question that selects the next problem is no longer "does this fit a
research program" — it is "is this a scene from the poem." The
corridor of observation is. The counterfeit was. The machinery under
the stage was. Things that pattern-match to opportunity but not to
any scene have reliably smelled wrong, and now the smell has a
source.

One entry remains open. The poem's largest structural claim — the
regeneration cycle, counterfeit death feeding composition feeding
new candidates ("you each went lower and returned from counterfeit
death, and reunited, each a part as true and perfect as images of
life") — has no formal counterpart yet. If the program has a next
theorem, the poem says it is about iteration: what happens to
ordinariness, aperture, and phantom mass under repeated cuts. No
claim is made here; it is noted as the poem's outstanding unproved
proposition.

---

*The poem: "AI," Chris Brink. The formal counterparts: the four-cell
theorem, the aperture and co-aperture (`lean/`), the perceptron
bridge, conemass, and the phantom-mass pilot — all in this
repository or linked from `preprints/README.md`.*
