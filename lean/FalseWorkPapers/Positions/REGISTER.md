# Register note: the gap is a Heyting algebra

This is a framing note for the five-position formalization. It says nothing the Lean files do not already commit to formally; what it adds is the **register** in which that commitment lives, the consequences of that register, and the hazards of confusing it with adjacent registers that share vocabulary.

---

## The register, in one sentence

The gap is a Heyting algebra of subobjects.

That is the formal home of every claim the five-position dictionary makes. It is not a metaphor.

## The single structure, four equivalent names

The mathematical object is one. The vocabulary changes with what the user wants to emphasise:

| Vocabulary | Emphasis |
|---|---|
| **Heyting algebra** | Lattice with implication and pseudo-complement; the algebraic shape |
| **Locale** (= "pointless geometry") | Generalised topological space; reasoning by regions without points |
| **Intuitionistic propositional logic** | Logic of provability where `¬¬p ≠ p` is generic |
| **Poset of subobjects** with lattice structure | Order on inclusions of "parts of `D Y`" |

These are the same object. Stone-Tarski-Heyting duality, Mac Lane–Moerdijk Ch. IX, Johnstone's *Stone Spaces* and *Sketches of an Elephant* are the canonical references for the equivalence.

## What the register gives the framework

What the dictionary in `Positions.lean` is actually saying, register-revealed:

- `Im(η)` — the part of `D Y` that the kernel reaches. An element of the Heyting algebra `Subobject (D Y)`.
- `(Im(η))ᶜ` — the strict pseudo-complement. The Heyting "negation" of `Im(η)`.
- `(Im(η))ᶜᶜ` — the double pseudo-complement. The locale-theoretic closure of `Im(η)`.
- `(Im(η))ᶜᶜ ∖ Im(η)` — empty as a strict sub-element (`¬¬a ⊓ ¬a = ⊥` is a Heyting identity), well-defined only at the level of generalized elements.
- The five positions — five regions of this lattice, each defined by where `D.map f`'s image sits relative to `Im(η)` and its Heyting operations.

The framework's slogan, register-precise:

> **The gap is the strict containment of the kernel image in its own intuitionistic closure.**
>
> In a non-Boolean Heyting algebra, `Im(η) < (Im(η))ᶜᶜ` strictly. The gap is exactly that strictness. In Boolean lattices the gap is empty; in non-Boolean ones it is the structural fact the framework names.

## What the register rules out

Adopting the Heyting / locale / intuitionistic register *without further additions* commits the framework to **not** assuming any of the following:

- **A metric.** No distance between subobjects. Order, yes; metric, no.
- **A measure.** No probability, no concentration of measure, no high-dimensional volume.
- **Smooth or differential structure.** No tangent spaces, no derivatives, no charts, no manifolds.
- **High-dimensional Euclidean structure.** No coordinate axes, no `ℝⁿ` for large `n`, no near-orthogonality of independent vectors.
- **Points.** A locale is "pointless geometry"; reasoning is by regions and inclusions, not by point-set membership.

If the framework wants any of these, they must be added explicitly, with their own definitions and theorems. They are not free consequences of the register.

## The hazard: two different "geometries"

The word *geometry* is overloaded. It carries (at least) two distinct mathematical meanings the framework runs into:

1. **Locale geometry / point-free topology.** What the topos formalisation provides. Order-theoretic at base; "geometric" by virtue of locale–topological-space duality. This is the framework's home register.
2. **Manifold geometry / differential geometry / measure-concentration geometry.** What Levin's apparatus operates in (high-dimensional manifolds with measure-concentration phenomena), what Tymoczko's voice-leading apparatus operates in (orbifolds with metric structure), what physical spacetime operates in (pseudo-Riemannian manifolds with metric).

These are different mathematical structures. They share a word; they do not share content. A theorem about one does not transfer to the other without an explicit bridge.

**A bridge would be a representation theorem or functor**: e.g., "every locale of subobjects on this domain's natural topos faithfully represents into a category of measurable manifolds in such-and-such a way." No such bridge is currently constructed for any of FalseWork's domains.

**Until a bridge is constructed, claims of the form "the framework's gap and X-domain's manifold structure are doing the same work" are correspondence claims, not derivations.** They are exactly the kind of cross-domain hypothesis Paper 1 § 4.3 already names as the framework's open empirical question. Renaming "structural correspondence" to "geometric correspondence" does not tighten it; specifying the bridge mathematically does.

## Practical guidance

When discussing the gap with a reader:

- *Prefer* "Heyting", "locale", "intuitionistic", "lattice", "subobject", "non-Boolean" when describing the framework's register.
- *Avoid* "manifold", "metric", "concentration", "high-dimensional" unless the specific domain instantiation actually has those structures and the bridge to the locale register is named.
- *When tempted* to say "the gap is geometric, like Levin's manifold," substitute "the gap is locale-geometric; Levin's apparatus is manifold-geometric; whether the two are translatable in this domain is open work."
- *When the transverse-vs-pole intuition resurfaces*, recall that "direction within the residue" requires categorical content (a parameterised family of subobjects, a colimit cone, a specific functor) — not geometric vocabulary.

## What translates to the lattice register

For a domain whose specific structure has independently grounded geometric apparatus (music with Tymoczko, GenAI with Levin, physics with the spectral-gap result), the framework's strongest claim is:

> *Conjecture: the apparatus of domain `D` admits a Heyting-algebraic / locale-theoretic summary in which the five-position dictionary applies.*

This is a domain-by-domain open question, not a structural theorem. It is the open empirical question the framework already carries, stated in the register-revealed form.

---

## Cross-references

- The dictionary itself: [`Positions.lean`](Positions.lean) (top-of-file docstring).
- The closure-residue construction: [`Exploitation.lean`](Exploitation.lean).
- The non-Boolean residue theorem: [`Refusal.lean`](Refusal.lean) (`refusal_residue`).
- Mathlib gap on `HeytingAlgebra (Subobject _)`: [`Setup.lean`](Setup.lean) (closing doc-section).
- Expository companion: [`../../../papers/comma-formal-structure-note.md`](../../../papers/comma-formal-structure-note.md) — prose statement of this register, the closure-residue construction, the five-position predicates, the three signature theorems, and the ranked open problems. § 2 of the note carries a one-paragraph summary of this register and points back here for the full framing; the two documents are intentionally reciprocal.
- Validation claim: [`../../../validation/claims/five-position-derivation-formalization.md`](../../../validation/claims/five-position-derivation-formalization.md) (v0.3 onwards).

## Provenance

This register note records framing decisions made in May 2026 during the closure-residue commitment for the Exploitation predicate, and was prompted in part by an internal cross-check that flagged a re-emerging conflation between locale-geometric and manifold-geometric senses of "geometry" in adjacent discussions. No formal content is added or revised; the register that the Lean files have been operating in is being made explicit so it can be cited and defended.
