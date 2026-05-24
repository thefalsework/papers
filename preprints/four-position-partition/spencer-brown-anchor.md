# Spencer-Brown Anchor

## Reading the Four-Position Partition Through *Laws of Form*

**Chris Brink**
falsework.dev
May 2026 — companion to [`paper.md`](paper.md).

---

## Abstract

The partition theorem of [`paper.md`](paper.md) is stated in the language of elementary topoi and Heyting algebras, but its intellectual ancestor is G. Spencer-Brown's *Laws of Form* (Spencer-Brown 1969). This companion document makes the lineage explicit. Spencer-Brown identifies two foundational axioms for a calculus of distinctions: the **calling axiom** (a mark next to itself equals a single mark) and the **crossing axiom** (a mark inside a mark equals nothing). Definition 3.1 of the paper categorifies the calling axiom — the idempotency component `D ⋙ D ≅ D` is precisely calling for an endofunctor-with-unit — while deliberately leaving the crossing axiom *unimposed*, since it would not hold in the ambient logic of subobjects in a non-Boolean topos. The four-position partition then reads as a natural decomposition of morphisms in a setting where calling holds but crossing fails: Infrastructure and Refusal are the two "classical" Spencer-Brown registers (under the mark and crossed out), Distribution is the boundary register, and **Exploitation is the structural register that exists precisely because crossing fails** — the closure-residue between a subobject and its double-negation. The Boolean collapse described in Remark 5.3 of the paper is exactly the collapse that recovers classical Spencer-Brown. This document develops these correspondences carefully and reads them through the 6-element non-Boolean Heyting algebra worked out in [`examples/phase-1-2-progress.md`](examples/phase-1-2-progress.md).

---

## 1. Introduction

Spencer-Brown's *Laws of Form* (Spencer-Brown 1969) develops a calculus whose primitive is the act of drawing a distinction. The notation is a single mark — typically a right-angle bracket — and the calculus is built on two axioms governing how marks combine. The work has been read in many registers: as a foundation for Boolean algebra, as a calculus of self-reference (von Foerster, Varela), as a knot-theoretic apparatus (Kauffman), and as a philosophical statement about the logical structure of observation.

The four-position partition theorem of [`paper.md`](paper.md) is, structurally, a category-theoretic reading of Spencer-Brown that takes the calling axiom seriously as a *categorical structure* and lets the crossing axiom *fail*. This single move — keep calling, drop crossing — turns out to produce exactly the four-position decomposition that the framework's empirical work has identified across domains. This document makes that mathematical correspondence explicit.

The reading is interpretive: Spencer-Brown himself is operating in a Boolean primary arithmetic, and the categorification proposed here is not present in *Laws of Form*. But the alignment between the formal apparatus of Definition 3.1 and the calling axiom is exact, and the appearance of Exploitation as a structural cell separate from Refusal has a clean Spencer-Brown reading: it is the cell that exists in the gap between single-cross (Heyting complement) and double-cross (double-negation closure), which is the gap between Spencer-Brown's primary arithmetic and any non-Boolean extension of it.

---

## 2. Spencer-Brown's Two Axioms

Spencer-Brown's primary arithmetic is built from a single distinction-marker — written here as a pair of brackets `⟨ ⟩` enclosing what is "inside" the mark — operating over two values: the **marked state** (denoted simply `⟨ ⟩`, an empty mark) and the **unmarked state** (denoted by absence). Forms are built by juxtaposition (placing marks side by side) and by nesting (placing marks inside other marks).

The two axioms of the primary arithmetic are:

**Axiom 1 (Calling, "the form of condensation").** A mark next to itself equals a single mark:

```
⟨ ⟩ ⟨ ⟩ = ⟨ ⟩
```

Equivalently: "the value of a call made again is the value of the call" (Spencer-Brown 1969, p. 3). Juxtaposition of identical marks is idempotent.

**Axiom 2 (Crossing, "the form of cancellation").** A mark inside a mark cancels:

```
⟨ ⟨ ⟩ ⟩ =
```

(where the right-hand side is the unmarked state, written as the absence of a mark). Equivalently: "the value of a crossing made again is not the value of the crossing." Nesting a mark inside itself returns the void.

These two axioms, together with the rule that juxtaposition is commutative, generate the primary arithmetic. With variables, the primary algebra adds two initials — **Position** (`p p = p`, the variable form of Calling) and **Transposition** (`⟨⟨pq⟩⟨pr⟩⟩ = p ⟨⟨q⟩⟨r⟩⟩`, a distributivity-style law) — from which all theorems of the calculus are derived. The most important derived theorem for our purposes is

```
C1 (Reflection):    ⟨ ⟨ p ⟩ ⟩ = p
```

which is the variable form of Axiom 2: double-crossing is the identity on variables.

The primary arithmetic and primary algebra together constitute, in modern terms, a presentation of the two-element Boolean algebra (with the mark corresponding to negation, juxtaposition to disjunction, and the unmarked state to "true"). Spencer-Brown's contribution is the *typographical* and *philosophical* one of identifying a single primitive — the drawing of a distinction — from which Boolean algebra recovers as derived.

For our purposes the key observation is structural: **Axioms 1 and 2 play different roles**. Calling (Axiom 1) is an algebraic identity on the operation of marking. Crossing (Axiom 2 / C1) is an algebraic identity on the operation of *nested* marking, and in Heyting-algebraic terms it is precisely the law `¬¬p = p`, which is the Boolean condition. The first survives any extension; the second is what fails when we leave the Boolean setting.

---

## 3. The Categorical Lift of Calling

Definition 3.1 of [`paper.md`](paper.md) introduces a distinction structure on a category `C` as a triple `(D, η, ι)`:

- `D : C ⥤ C` is an endofunctor — the **marking operation**.
- `η : 1_C ⟹ D` is a natural transformation — the **unit of the distinction**, inserting each object `X` into its marked form `D(X)`.
- `ι : D ⋙ D ≅ D` is a natural isomorphism — the **idempotency** of marking.

with the coherence condition `η_{D(X)} ≫ ι.hom_X = 1_{D(X)}` for every `X`.

The correspondence with Spencer-Brown's calling axiom is exact:

| Spencer-Brown | Definition 3.1 |
|---|---|
| The mark `⟨ · ⟩` as primitive operation | Endofunctor `D` |
| The unmarked state preceding the mark | Identity `1_C` |
| Inclusion of the unmarked into the marked | Unit `η : 1_C ⟹ D` |
| Calling: `⟨ ⟩ ⟨ ⟩ = ⟨ ⟩` (juxtaposition of marks) | Idempotency: `D ⋙ D ≅ D` |
| Position: `p p = p` (variable form) | Naturality of `ι` over `C` |
| The mark-of-the-mark equals the mark | Coherence: `η_{D(X)} ≫ ι_X = 1_{D(X)}` |

The coherence condition deserves its own gloss. In Spencer-Brown, the calling axiom is stated for the empty mark, and the position law `p p = p` extends it to variables. In the categorical lift, the analogous extension is that the *unit of the marked form* applied after marking is the same as the *idempotency of marking* applied after marking — both are the identity on `D(X)`. This is what the coherence equation says: composing `η_{D(X)}` (a way to get from `D(X)` to `D(D(X))`) with `ι.hom_X` (the way to get back from `D(D(X))` to `D(X)`) returns the identity on `D(X)`. Each `D(X)` is "already called," and either way of confirming this — by re-marking or by collapsing — agrees.

What is *deliberately absent* from Definition 3.1 is any analogue of the crossing axiom. There is no requirement that "crossing twice returns the void," no involutive structure on `D`, no negation built into the apparatus. The reason is that **crossing is not an algebraic property of the marking operation in non-Boolean settings**. Crossing lives in the ambient logic of subobjects, which in an elementary topos is the Heyting algebra structure of `Sub(X)` (cf. paper §2). In a Boolean topos, `¬¬a = a` holds for all `a` and crossing is recovered; in a non-Boolean topos, `¬¬a` strictly contains `a` for some elements, and crossing fails. The categorical apparatus deliberately keeps these two layers separate: calling is structure on `D`, crossing is property of the ambient Heyting algebra.

This separation is the essential design choice that makes the partition theorem work. Spencer-Brown's primary arithmetic conflates calling and crossing because it is operating in a Boolean universe where both hold. The categorical lift respects the distinction between them, and the result is a finer-grained reading of what happens when only one of the two is forced.

---

## 4. The Heyting Setting and the Failure of Crossing

For any object `Y` in an elementary topos `C`, the subobject lattice `Sub(D(Y))` is a Heyting algebra (Mac Lane and Moerdijk 1992, IV.6 Proposition 2). The kernel image `a_Y := Im(η_Y) ∈ Sub(D(Y))` is one specific element of this lattice. The partition theorem decomposes morphisms `f : X → Y` according to how `Im(D.map f)` sits relative to `a_Y` in this Heyting algebra.

The Heyting structure provides four lattice positions relative to `a_Y` — and these are exactly the four positions of the partition theorem, with the *fourth* being the one that disappears in the Boolean case.

To see this, recall that in a Heyting algebra `H` an element `p` is called **regular** if `¬¬p = p`. The regular elements form a Boolean sub-algebra `H_reg ⊆ H`, with meet inherited and join given by `¬¬(p ∨ q)`. The non-regular elements satisfy `p ⊊ ¬¬p`, with the strict inclusion measuring the **closure-residue** at `p`.

Now Spencer-Brown's crossing axiom, restated for elements of `H`, is the assertion `¬¬p = p` — i.e., that every element of `H` is regular. This holds iff `H` is Boolean. In any non-Boolean `H`, some elements are non-regular, and the closure-residue between `p` and `¬¬p` is non-trivial.

The four-position partition reads in this register as follows. Given the kernel image `a_Y ∈ Sub(D(Y))`:

- **`a_Y`** itself defines what is "under the mark."
- **`a_Yᶜ`** is what is "crossed out": the Heyting complement, the largest subobject disjoint from `a_Y`.
- **`a_Yᶜᶜ`** is the double-cross of `a_Y`: in a Boolean setting this would equal `a_Y`, but in general `a_Y ≤ a_Yᶜᶜ` with strict inequality possible.
- The interval `[a_Y, a_Yᶜᶜ]` — between the mark and its double-cross — is the **closure-residue** at `a_Y`. In the Boolean case it collapses to the point `a_Y`. In the non-Boolean case it can host structure.

These four lattice features — `a_Y`, `a_Yᶜ`, `a_Yᶜᶜ`, and the residue between `a_Y` and `a_Yᶜᶜ` — are exactly what the four position predicates of Section 4 of the paper test for in `Im(D.map f)`. The next section reads each cell through this lens.

---

## 5. The Four Positions as Spencer-Brown Registers

Recall the four position predicates from Definition 4.1 of the paper. Writing `img := Im(D.map f)` and reading each predicate in Spencer-Brown vocabulary:

### Infrastructure: under the mark

```
IsInfrastructure(f) := img ≤ a_Y
```

The image of `f` under `D` is contained in the kernel image — the form lies *under the mark*. In Spencer-Brown terms: the form is fully inside the called region. The distinction operation, applied to `f`, lands strictly within the territory that the unit reaches at `Y`.

This is the cleanest Spencer-Brown position: the form has been called, and the call has succeeded in capturing it entirely.

### Refusal: crossed out

```
IsRefusal(f) := img ≤ a_Yᶜ
```

The image of `f` under `D` lies in the Heyting complement of the kernel image — the form lies *outside the mark*, in the region that the crossing operation would identify. In Spencer-Brown terms: the form is crossed out relative to the call. The distinction operation, applied to `f`, lands entirely outside what the unit reaches.

This is the dual of Infrastructure. In a Boolean topos these two cells would exhaust the typology along with their straddling combinations. In any topos satisfying both Spencer-Brown axioms (i.e., any Boolean topos), Refusal *is* the entire region outside the mark, full stop.

### Distribution: straddling the mark

```
IsDistribution(f) := (img ⊓ a_Y ≠ ⊥) ∧ (img ⊓ a_Yᶜ ≠ ⊥)
```

The image of `f` under `D` meets both the kernel image and its complement non-trivially — the form *straddles* the mark. Some of `img` is inside the called region; some is outside. In Spencer-Brown terms: the form is partially called and partially crossed.

This cell exists in any topos (Boolean or not) and represents the boundary between the two foundational positions. It is the categorical analogue of a form that contains both `p` and `⟨ p ⟩` as substructures.

### Exploitation: the failure-of-crossing residue

```
IsExploitation(f) := (img ≤ a_Yᶜᶜ) ∧ ¬(img ≤ a_Y)
```

The image of `f` under `D` lies in the double-cross of the kernel image but not in the kernel image itself. In Spencer-Brown terms applied naively: the form lies "inside the double-cross of the call but not inside the call." If crossing axiom held — if `a_Yᶜᶜ = a_Y` — this cell would be impossible: nothing can be inside `a_Y` while *not* inside `a_Y`. But in a non-Boolean topos, where `a_Yᶜᶜ` can strictly contain `a_Y`, the cell is inhabitable, and it consists precisely of forms that *would* re-emerge under double-cross as inside the call, but in fact sit in the gap between the call and its double-cross.

This is the structural register that Spencer-Brown's primary arithmetic cannot see. In *Laws of Form*, the double-cross of any form equals that form (`⟨ ⟨ p ⟩ ⟩ = p`), so the gap is empty. The categorical lift preserves this collapse in the Boolean case (cf. Remark 5.3 of the paper) and exposes the gap as a structural cell in the non-Boolean case.

The naming is deliberate. *Exploitation* in the framework's empirical typology designates practitioners whose work pulls back into a domain through the asymmetric residue — Coltrane's geometry doing exactly this in sheets-of-sound, Reinhardt's cruciform doing exactly this in monochrome painting. The mathematical content of Exploitation as a category-theoretic position is: forms that fall in the closure-residue, exploiting the failure of double-cross involution to constitute a separate structural territory.

### Summary table

| Position | Heyting condition | Spencer-Brown reading |
|---|---|---|
| Infrastructure | `img ≤ a_Y` | form under the mark |
| Distribution | `img ⊓ a_Y ≠ ⊥` and `img ⊓ a_Yᶜ ≠ ⊥` | form straddling the mark |
| Exploitation | `img ≤ a_Yᶜᶜ` and `¬(img ≤ a_Y)` | form in the failure-of-crossing residue |
| Refusal | `img ≤ a_Yᶜ` | form crossed out (outside the mark) |

In a Boolean topos, where `a_Yᶜᶜ = a_Y`, Exploitation becomes unsatisfiable, the four-fold partition collapses into a three-fold one (Infrastructure / Distribution / Refusal), and Spencer-Brown's two-axiom calculus is recovered cleanly. The four-position structure is the *categorical signature* of a setting where calling holds but crossing fails.

---

## 6. Worked Example: the 6-Element M-Set Heyting Algebra

[`examples/phase-1-2-progress.md`](examples/phase-1-2-progress.md) constructs a concrete 4-element M-set `X = {a, b, c, p}` over a 3-element idempotent monoid `M = {1, e, f}` in the topos M-Set, and verifies by hand that `Sub(X)` is a 6-element non-Boolean Heyting algebra. We read this example through the Spencer-Brown lens.

The six subobjects of `X` are `∅`, `{c}`, `{a, b}`, `{c, p}`, `{a, b, c}`, and `X`. Their Heyting complements and double-negation closures are summarized in §5 of the progress report:

| Subobject `S` | `Sᶜ` | `Sᶜᶜ` | Regular? |
|---|---|---|---|
| `∅` | `⊤ = X` | `∅` | yes |
| `{c}` | `{a, b}` | `{c, p}` | **no** |
| `{a, b}` | `{c, p}` | `{a, b}` | yes |
| `{c, p}` | `{a, b}` | `{c, p}` | yes |
| `{a, b, c}` | `∅` | `⊤ = X` | **no** |
| `⊤ = X` | `∅` | `⊤ = X` | yes |

In Spencer-Brown vocabulary: the regular elements `∅, {a, b}, {c, p}, ⊤` are the forms that "satisfy crossing" — for each, double-crossing returns the form itself. The non-regular elements `{c}` and `{a, b, c}` are the forms where crossing fails: each strictly grows under double-cross.

Now place the kernel image at the non-regular element `a_Y := {c}`. Spencer-Brown reads this as: the call reaches the form `{c}` — a minimal form, a single element insulated under both `λ_e` and `λ_f`. The four registers around this call:

- **Under the mark** (`Infrastructure`): `img ≤ {c}`. The only non-zero option is `img = {c}` itself.
- **Crossed out** (`Refusal`): `img ≤ {a, b}`. The only non-zero option is `img = {a, b}`.
- **In the failure-of-crossing residue** (`Exploitation`): `img ≤ {c, p}` and `img ≰ {c}`. The only option is `img = {c, p}` — the form that lies "in the double-cross of `{c}`" but not "in `{c}`."
- **Straddling** (`Distribution`): `img ⊓ {c} ≠ ⊥` and `img ⊓ {a, b} ≠ ⊥`. The options are `{a, b, c}` and `⊤`.

The non-regularity of `{c}` is *the entire reason Exploitation is inhabited here*. If `{c}` were regular (i.e., if `{c}ᶜᶜ = {c}`), then `a_Yᶜᶜ` would equal `a_Y` and Exploitation would be empty by the same Boolean-collapse argument as Remark 5.3 of the paper.

The Spencer-Brown reading of this concrete example is therefore: the M-Set `X` contains a single "non-Boolean point" — the form `{c}` — and choosing the kernel image at this point produces a partition in which the failure-of-crossing residue is inhabited by exactly one subobject, the form `{c, p}` that sits in the double-cross of `{c}` but outside `{c}` itself. The form `{c, p}` is what Spencer-Brown's primary arithmetic, operating Boolean-ly, cannot see; the categorical lift sees it.

The two regular elements of the same height (`{a, b}` and `{c, p}`) occupy the two "classical" complementary positions of Spencer-Brown's two-element calculus: under the mark in dual form (`{c, p}` as Exploitation when `a_Y = {c}`) and crossed out (`{a, b}` as Refusal). The two non-regular elements (`{c}` and `{a, b, c}`) are the two "non-Boolean points" of the lattice; placing `a_Y` at one or the other inhabits Exploitation in different ways.

This is the simplest non-trivial Spencer-Brown reading the framework currently has a concrete handle on. The full distinction-structure construction `(D, η, ι)` that would realize `a_Y = {c}` as the actual image of a unit is still open (cf. progress report §7); but the lattice-level reading is verified and concrete.

---

## 7. Connection to Extensions of Spencer-Brown

Several lines of work extend Spencer-Brown beyond the Boolean primary arithmetic. Three are worth situating relative to this anchor.

**Varela's calculus of self-reference (1975).** Francisco Varela extended Spencer-Brown's calculus by introducing a third value — *autonomy*, denoted self-referentially — to handle forms that re-enter themselves. The motivation was systems-theoretic and biological: a calculus that supports self-reference cannot remain in a two-valued setting. Varela's calculus is three-valued (marked, unmarked, autonomous) and gives up some of Spencer-Brown's axioms to accommodate the third value.

The categorical lift of this paper takes a different route: instead of adding a third value to the calculus, it lifts the calculus to operate on objects of an arbitrary elementary topos, where the ambient Heyting logic naturally provides as many "values" as `Sub(X)` has elements. The Exploitation cell, in this reading, is what Varela's autonomous value gestures at categorically — forms that are "neither marked nor unmarked" but that sit in the closure-residue between mark and double-cross.

This is not a claim that Varela's calculus and the partition theorem coincide. They are different mathematical objects. The structural impulse is similar: extend Spencer-Brown beyond the Boolean case to capture forms that the binary mark/unmark cannot see.

**Kauffman's topological readings.** Louis Kauffman has developed Spencer-Brown's calculus in directions that connect to knot theory, the imaginary value (the "i" of Bricken-Kauffman re-entry), and the dynamics of marks-that-refer-to-themselves. Kauffman's work treats the mark as a topological object with non-trivial entanglement structure.

The categorical lift here is orthogonal to Kauffman's topological direction: it works at the level of `Hom`-sets and subobject lattices in an elementary topos, not at the level of marks-as-tangles. The Exploitation cell is not Kauffman's imaginary value either; it is the closure-residue of a Heyting algebra, which is a specific algebraic phenomenon. The two extensions diverge.

**Topos-theoretic reformulations.** Less directly, there is a tradition of reading Spencer-Brown through topos theory and intuitionistic logic (cf. broader work in categorical logic surveyed in Awodey 2010, Johnstone 2002a). The reading proposed here is part of that tradition: it takes the calling axiom seriously as categorical idempotency, lets the crossing axiom fail wherever the Heyting algebra is non-Boolean, and reads the result. The specific four-position decomposition that emerges does not appear in the standard literature the author has surveyed, but the move — categorify calling, let crossing be a property of the ambient logic — is in the spirit of how categorical logic has historically read foundational calculi.

---

## 8. Concluding Remarks

The four-position partition of [`paper.md`](paper.md) reads, through this anchor, as a categorical decomposition of morphisms in any elementary topos with a non-trivial distinction structure, in which **calling holds and crossing fails**. The two foundational Spencer-Brown axioms separate into two layers of the apparatus: calling is built into Definition 3.1 as the idempotency `D ⋙ D ≅ D` plus coherence; crossing is a property of the ambient Heyting algebra of subobjects, holding iff the topos is Boolean. In Boolean topoi the partition collapses to three classes, recovering a classical Spencer-Brown reading. In non-Boolean topoi the partition is genuinely four-fold, and the fourth cell — Exploitation — is structurally identified as the closure-residue between a subobject and its double-negation.

The framework's empirical claim is that across creative and intellectual domains, practitioners distribute into four structural positions relative to the generative operations of their domains. The mathematical content of this companion document is that, *if* a domain's structure can be encoded as a non-trivial distinction structure on an appropriate elementary topos, then the four positions arise as a necessary and exhaustive partition — and they read cleanly through Spencer-Brown's vocabulary as four registers around the act of marking, three of which are visible to the two-axiom primary arithmetic and one of which is visible only after the lift to a non-Boolean ambient logic.

This identifies the framework's intellectual lineage. The four-position theorem is not a novel topology of practice asserted ex nihilo; it is the categorical reading of what Spencer-Brown's calculus *would have looked like* if the calling axiom had been carried to its categorical idempotent form and the crossing axiom had been allowed to fail. The result is a partition of practice into the four structural positions that the framework's empirical work has independently identified.

Whether any specific domain — music, cinema, painting, literature, software, physics — instantiates this categorical structure is an empirical question that this document does not address. The framework's specialist correspondence (Tymoczko on music, Cutting on cinema, ongoing with Levin) attests to the four positions having empirical traction in those domains. The categorical formalization given here establishes that *when* such a structure exists, the four positions are forced; the Spencer-Brown anchor establishes that the mathematical content is a category-theoretic completion of the calculus of distinctions, not a separate apparatus that happens to produce four cells.

---

## References

- Awodey, S. (2010). *Category Theory* (2nd ed.). Oxford Logic Guides, Oxford University Press.
- Brink, C. (2026). *FalseWork Papers*. [github.com/thefalsework/papers](https://github.com/thefalsework/papers).
- Johnstone, P. T. (2002a). *Sketches of an Elephant: A Topos Theory Compendium, Volume 1*. Oxford Logic Guides, Oxford University Press.
- Kauffman, L. H. (2001). The mathematics of Charles Sanders Peirce. *Cybernetics & Human Knowing*, 8(1–2), 79–110. (And related works on Laws of Form and knot theory.)
- Mac Lane, S., and Moerdijk, I. (1992). *Sheaves in Geometry and Logic: A First Introduction to Topos Theory*. Universitext, Springer-Verlag.
- Spencer-Brown, G. (1969). *Laws of Form*. Allen and Unwin.
- Varela, F. J. (1975). A calculus for self-reference. *International Journal of General Systems*, 2(1), 5–24.

---

## Provenance

Drafted 2026-05-24 in conversation with Anthropic Claude (Cursor IDE), per the project's documented validation architecture. The categorical correspondence in §3 (Spencer-Brown axioms to Definition 3.1) is the author's framing and follows from the structure of Definition 3.1; the failure-of-crossing reading of Exploitation in §5 is interpretive and is not a separate mathematical theorem beyond what Remark 5.3 of the paper already states. The worked example in §6 uses the M-Set construction independently verified by hand in [`examples/phase-1-2-progress.md`](examples/phase-1-2-progress.md). The references to Varela and Kauffman in §7 are pointers to relevant traditions and are not claims of direct mathematical equivalence.
