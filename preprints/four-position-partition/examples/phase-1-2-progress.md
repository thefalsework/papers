# Tier 1 / Phase 1.2 — Progress Report

**Status.** Partial. Lattice-level four-cell inhabitability verified by hand on a specific 4-element object in an M-Set topos; a complete distinction-structure construction (D, η, ι) satisfying Definition 3.1 with the required `a_Y` has not been produced. The obstruction is precisely characterized in §5 below.
**Author.** Chris Brink (with AI collaboration per the project's validation architecture).
**Companion to.** [`paper.md`](../paper.md), [`construction-choice.md`](construction-choice.md).
**Date.** 2026-05-24 (Phase 1.2 partial progress; not yet complete).

---

## 1. What this document contains

Phase 1.1 ([`construction-choice.md`](construction-choice.md)) established that the Sierpinski topos Set^→ is too small to host a non-vacuous four-cell partition and recommended escalating to a richer base topos. This document carries out the first substantive step of that escalation: a hand-verified computation on a 4-element object X in the topos M-Set for a specific 3-element idempotent monoid M, showing that Sub(X) carries a 6-element non-Boolean Heyting algebra with a non-regular middle element, and that **all four cells of the partition would be inhabited at the lattice level** if X could be realized as D(Y) with `a_Y` placed at that non-regular middle element.

The remaining task — constructing (D, η, ι) on M-Set such that some Y has D(Y) = X and `Im(η_Y) = {c}` — is not completed here. The obstruction encountered is structural: standard reflections on M-Set produce *epi units*, which force `a_Y = ⊤` (full subobject of D(Y)) and collapse Refusal and Distribution. A non-vacuous construction requires either (a) a non-reflective distinction structure exploiting the gap between Definition 3.1 and "idempotent monad" identified in Remark 5.5 of the paper, or (b) a further escalation to a topos with reflective subcategories admitting non-epi units (e.g., sheaves on a topological space with enough "missing generic points" to make sheafification non-epi).

This is therefore Phase 1.2 *progress*, not Phase 1.2 *completion*. The lattice-level finding is verified by hand; the (D, η, ι) construction is not.

## 2. The base topos: M-Set for M = {1, e, f}

Define the 3-element monoid M = {1, e, f} with multiplication:

| · | 1 | e | f |
|---|---|---|---|
| **1** | 1 | e | f |
| **e** | e | e | e |
| **f** | f | f | f |

That is: 1 is the identity, e and f are right-absorbing idempotents (e·x = e for x ∈ {1, e, f}, f·x = f for x ∈ {1, e, f}). Associativity: routine verification.

The category M-Set of left M-sets is presheaves on the one-object category corresponding to M; it is an elementary topos. A left M-set is a set X equipped with an action `λ_m: X → X` for each m ∈ M, satisfying `λ_1 = id_X` and `λ_{mn} = λ_m ∘ λ_n`.

For our M, this gives constraints:
- `λ_e ∘ λ_e = λ_e` (idempotent)
- `λ_f ∘ λ_f = λ_f` (idempotent)
- `λ_e ∘ λ_f = λ_e` (e absorbs f from the left)
- `λ_f ∘ λ_e = λ_f` (f absorbs e from the left)

## 3. The 4-element M-set X

Take X = {a, b, c, p} with actions:

- `λ_e`: a↦a, b↦a, c↦c, p↦c
- `λ_f`: a↦b, b↦b, c↦c, p↦c

**Verification of axioms.**

- `λ_e ∘ λ_e`: a→a→a, b→a→a, c→c→c, p→c→c. Equals `λ_e`. ✓
- `λ_f ∘ λ_f`: a→b→b, b→b→b, c→c→c, p→c→c. Equals `λ_f`. ✓
- `λ_e ∘ λ_f`: a→b→a, b→b→a, c→c→c, p→c→c. Equals `λ_e`. ✓
- `λ_f ∘ λ_e`: a→a→b, b→a→b, c→c→c, p→c→c. Equals `λ_f`. ✓

X is a valid M-set.

## 4. The subobject lattice Sub(X)

Subobjects of an M-set are subsets closed under all M-actions, i.e., closed under both `λ_e` and `λ_f`.

Enumerating: among the 16 subsets of X, the M-stable ones are exactly:

```
∅ ⊂ {c} ⊂ {c, p} ⊂ {a, b, c, p}
∅ ⊂ {a, b} ⊂ {a, b, c} ⊂ {a, b, c, p}
{c} ⊂ {a, b, c}
{a, b} ⊂ {a, b, c, p} (via {a, b, c})
{c, p} ⊂ {a, b, c, p}
```

Verification of each:
- `{c}`: `λ_e(c) = c ✓, λ_f(c) = c ✓`. Stable.
- `{a, b}`: `λ_e({a, b}) = {a, a} = {a} ⊆ {a, b}` ✓; `λ_f({a, b}) = {b, b} = {b} ⊆ {a, b}` ✓. Stable.
- `{c, p}`: `λ_e({c, p}) = {c, c} = {c} ⊆ {c, p}` ✓; `λ_f({c, p}) = {c, c} = {c} ⊆ {c, p}` ✓. Stable.
- `{a, b, c}`: union of `{a, b}` and `{c}`, both stable. Stable.
- `{a, b, c, p}` = X: trivially stable.
- Counterexamples (unstable, hence excluded): `{a}` fails (`λ_f(a) = b ∉ {a}`); `{b}` fails (`λ_e(b) = a ∉ {b}`); `{p}` fails (`λ_e(p) = c ∉ {p}`); `{a, c}` fails (`λ_f(a) = b ∉`); etc.

So Sub(X) has exactly six elements. The Hasse diagram:

```
              {a, b, c, p}
              /           \
       {a, b, c}         {c, p}
        /    \           /
    {a, b}    {c} ──────┘
        \    /
         \  /
          ∅
```

This is a 6-element bounded lattice. It is *not* Boolean (we verify by computing complements below).

## 5. The Heyting structure on Sub(X)

For S, T ∈ Sub(X), the Heyting implication in M-Set is:

`(S ⇒ T) = {x ∈ X : for all m ∈ M, m·x ∈ S implies m·x ∈ T}`

For our M with elements 1, e, f, this evaluates at each x by checking three conditions.

**Complement of {a, b}.**

For each x, check whether `1·x ∉ S` and `e·x ∉ S` and `f·x ∉ S` with S = {a, b}:

- x = a: 1·a = a ∈ S. Excluded.
- x = b: 1·b = b ∈ S. Excluded.
- x = c: 1·c = c ∉ S, e·c = c ∉ S, f·c = c ∉ S. Included.
- x = p: 1·p = p ∉ S, e·p = c ∉ S, f·p = c ∉ S. Included.

`{a, b}ᶜ = {c, p}`.

**Complement of {c, p}.**

- x = a: 1·a = a ∉ S, e·a = a ∉ S, f·a = b ∉ S. Included.
- x = b: 1·b = b ∉ S, e·b = a ∉ S, f·b = b ∉ S. Included.
- x = c: 1·c = c ∈ S. Excluded.
- x = p: 1·p = p ∈ S. Excluded.

`{c, p}ᶜ = {a, b}`.

Hence `{a, b}ᶜᶜ = {a, b}` — **{a, b} is regular**.
And `{c, p}ᶜᶜ = {c, p}` — **{c, p} is regular**.

**Complement of {c}.**

- x = a: 1·a = a ∉ S, e·a = a ∉ S, f·a = b ∉ S. Included.
- x = b: 1·b = b ∉ S, e·b = a ∉ S, f·b = b ∉ S. Included.
- x = c: 1·c = c ∈ S. Excluded.
- x = p: 1·p = p ∉ S, e·p = c ∈ S. Excluded.

`{c}ᶜ = {a, b}`.

`{c}ᶜᶜ = {a, b}ᶜ = {c, p}`.

Since `{c} ⊊ {c, p} = {c}ᶜᶜ`, **{c} is non-regular**. Its closure-residue (the "gap" between {c} and its double-negation closure) is structurally the single-element-larger subobject {c, p}.

**Complement of {a, b, c}.**

- x = a: 1·a = a ∈ S. Excluded.
- x = b: 1·b = b ∈ S. Excluded.
- x = c: 1·c = c ∈ S. Excluded.
- x = p: 1·p = p ∉ S, e·p = c ∈ S. Excluded.

`{a, b, c}ᶜ = ∅`.

`{a, b, c}ᶜᶜ = ∅ᶜ = X = ⊤`.

Since `{a, b, c} ⊊ X`, **{a, b, c} is also non-regular**, with the larger closure-residue going all the way to ⊤.

**Summary table.**

| S | Sᶜ | Sᶜᶜ | Regular? | Closure-residue |
|---|---|---|---|---|
| ∅ | ⊤ | ∅ | yes | n/a |
| {c} | {a, b} | {c, p} | **no** | {c, p} ∖ {c} = "{p}" |
| {a, b} | {c, p} | {a, b} | yes | n/a |
| {c, p} | {a, b} | {c, p} | yes | n/a |
| {a, b, c} | ∅ | ⊤ | **no** | ⊤ ∖ {a, b, c} = "{p}" |
| ⊤ | ∅ | ⊤ | yes | n/a |

The lattice has two non-regular elements (`{c}` and `{a, b, c}`) and four regular elements. The non-Boolean character is entirely concentrated in these two non-regular elements.

## 6. Lattice-level four-cell inhabitability

Take `a_Y := {c}` ∈ Sub(X) as the hypothetical kernel image. Then:

- `a_Y = {c}`
- `a_Yᶜ = {a, b}`
- `a_Yᶜᶜ = {c, p}`
- Closure-residue (between `a_Y` and `a_Yᶜᶜ` in the lattice): the single subobject `{c, p}` strictly above `{c}`.

The four cell predicates from Definition 4.1 of the paper, with `img := Im(D.map f) ∈ Sub(X)`:

**Infrastructure.** `img ≤ a_Y = {c}` and `img ≠ ⊥`. The non-zero subobjects of `{c}` in Sub(X) are: `{c}` itself. So **Infrastructure cell at this `a_Y` contains exactly the subobject `img = {c}`**.

**Refusal.** `img ≤ a_Yᶜ = {a, b}` and `img ≠ ⊥`. The non-zero subobjects of `{a, b}` are: `{a, b}` itself. So **Refusal cell contains exactly `img = {a, b}`**.

**Exploitation.** `img ≤ a_Yᶜᶜ = {c, p}` and `¬(img ≤ a_Y = {c})`. The subobjects of `{c, p}` are `∅, {c}, {c, p}`. Of these, the ones not contained in `{c}` are `{c, p}` itself. So **Exploitation cell contains exactly `img = {c, p}`**.

**Distribution.** `img ⊓ a_Y ≠ ⊥` AND `img ⊓ a_Yᶜ ≠ ⊥`. Computing meets in Sub(X) (which are intersections):

- `img ⊓ {c}`: non-zero iff `c ∈ img` (since `{c}` is a one-element-up-to-orbit subobject).
- `img ⊓ {a, b}`: non-zero iff `img` contains at least one of `a, b`.

So Distribution requires `img` to contain `c` AND at least one of `a, b`. Among the six subobjects of X, the ones satisfying both: `{a, b, c}` and `{a, b, c, p}` (= ⊤). So **Distribution cell contains `{a, b, c}` and ⊤**.

**Lattice-level result.** All four cells of the partition are inhabited at `a_Y = {c}`:

| Cell | Inhabitants (subobjects of X) |
|---|---|
| Infrastructure | `{c}` |
| Distribution | `{a, b, c}`, `⊤` |
| Exploitation | `{c, p}` |
| Refusal | `{a, b}` |

And by the partition theorem (Theorem 5.1), these cells are pairwise disjoint and exhaustive over morphisms with non-zero D-image. The hand computation confirms this: each non-zero subobject of X appears in exactly one cell.

This establishes that **the four-cell partition is genuinely non-vacuous for the M-Set X if `a_Y` can be placed at `{c}`**.

## 7. The remaining obstruction: constructing (D, η, ι) with `a_Y = {c}`

The remaining Phase 1.2 task is to construct an endofunctor D: M-Set → M-Set, a natural transformation η: 1 ⇒ D, and a natural isomorphism ι: D ⋙ D ≅ D satisfying the coherence condition of Definition 3.1, such that for some Y, D(Y) = X and `Im(η_Y) = {c}` as a subobject of X.

**Why this is structurally hard.** Three independent attempts were carried out and all fail for the same structural reason:

**Attempt 7.1: D = const X.** Define D(Y) = X for all Y, D(f) = id_X for all morphisms f. Then D ⋙ D = const X = D on the nose; ι_Y = id_X for all Y. Coherence requires `η_{D(Y)} ≫ ι_Y = 1_{D(Y)}`, i.e., `η_X = id_X` (since `ι_Y = id_X`). But η must be natural; at any object Z, `η_Z: Z → D(Z) = X` must be an M-set morphism, and naturality of η at any map `f: Z → Z'` requires `η_{Z'} ∘ f = D(f) ∘ η_Z = id_X ∘ η_Z = η_Z`. Setting Z' = X, this gives `η_X ∘ f = η_Z` for any `f: Z → X`. If `η_X = id_X`, this gives `η_Z = f` for any `f: Z → X` — but `η_Z` is a single fixed map, not all of them. So `η_X = id_X` is incompatible with naturality unless every Z has a unique map to X, which is false (X is not a separator). **Coherence fails.**

**Attempt 7.2: D = orbit-quotient reflection.** Define D(Y) = Y / ~ where y ~ y' if `M·y ∩ M·y' ≠ ∅`, the orbit quotient. D(Y) is a set with trivial M-action. This is a genuine reflection (left adjoint to inclusion Set ↪ M-Set, treating sets as trivially-actioned M-sets). Idempotency and coherence are automatic. But for any Y, η_Y: Y → D(Y) is the quotient map, which is *epi*. Therefore `a_Y = Im(η_Y) = D(Y) = ⊤` in Sub(D(Y)). **`a_Y = ⊤` collapses Refusal and Distribution; the four-cell partition is empty in the constructed instance.**

**Attempt 7.3: D = "mono-factor" reflection.** Define D(Y) for an M-set with action `λ_m` by quotienting by the relation `y ~ y'` iff `λ_m(y) = λ_m(y')` for all m. This factors the action through its image. D is a reflection onto the subcategory of "M-faithful" M-sets. Same calculation: η_Y is a quotient map, epi, so `a_Y = ⊤`. Same collapse.

**The structural reason.** A reflection onto a reflective subcategory D ⊆ C produces a unit η that is *universal* for maps from Y to objects of D. Universal usually means *epi* in the relevant sense (every map Y → Z ∈ D factors through η_Y → D(Y) → Z). When η is epi, its image is the full D(Y), so `a_Y = ⊤`.

For the partition theorem to be non-vacuous, we need `a_Y` to be a *proper* subobject of D(Y), which requires η_Y to be *non-epi*. Standard reflections in M-Set (orbit quotient, action-faithful quotient, all the variants tried) produce epi units. The non-vacuous construction must come from somewhere else.

## 8. Three forward paths

Three candidate paths for closing the construction. None has been verified; all require further mathematical work beyond what was completed in this session.

**Path A: Exploit the Def 3.1 vs. idempotent-monad gap (Remark 5.5).** Definition 3.1 of the paper is strictly weaker than "idempotent monad" — it imposes the left unit law and idempotency but not the right unit law or associativity. There may be (D, η, ι) satisfying Definition 3.1 that do *not* arise from a reflection, and these could have non-epi units. The Zulip question drafted in the prior conversation turn (is Def 3.1 ≡ idempotent monad?) is relevant here: if a topos theorist confirms the strict-weakness claim, the search space for D opens up substantially.

**Path B: Escalate to a topos where some reflective subcategory has non-epi unit.** Sheaves on a topological space with "missing generic points" can have non-epi sheafification: for a presheaf F, the sheafification F^# can have elements at non-open points that aren't in the image of F → F^#. Concrete candidates: Sh(R) with classical topology, Sh(Sierpinski space) with some non-canonical topology, or a topos of sheaves on a poset with "gaps." This direction requires careful identification of a topos where sheafification is non-epi at some object whose subobject lattice matches the structure of Sub(X) in §4.

**Path C: Reformulate Definition 3.1 to allow comonadic distinction structures.** The natural M-Set reflections produce epi units, but the *coreflections* (right adjoints to inclusions) produce mono units. Coreflections give *comonads*, not monads. A version of the partition theorem with `D` as a comonad and `ε: D → 1` (counit) instead of `η: 1 → D` (unit), with `Im(ε_Y) ≤ Y` as the "kernel image" living inside Y rather than inside D(Y), would naturally have non-epi component morphisms. This would require rewriting Theorem 5.1 in dual form — a substantial paper revision but potentially the most natural categorical home for the framework.

## 9. Cost and recommendation

Each of the three paths above is a 2–6 week piece of focused mathematical work, requiring topos-theory background that goes beyond elementary topos manipulation. Continuing Phase 1.2 to verified completion is therefore not tractable in a chat-session register. The honest recommendation:

1. **Land the lattice-level finding in §§3–6 of this document as a substantive intermediate Phase 1.2 result.** It establishes that the partition's non-vacuity is supported by a concrete 6-element subobject lattice in a concrete M-Set object, even though the full (D, η, ι) construction is incomplete. This is non-trivial mathematical content.
2. **Refer Path A to the Zulip question on the prior thread** (Definition 3.1 vs. idempotent monad). A topos theorist confirming or refuting the strict-weakness claim sharpens Path A directly.
3. **Treat Paths B and C as long-form research questions** that would naturally engage a topos-theory collaborator, not solo work in a chat session.

The four-cell inhabitability at the lattice level (§6) is sufficient to confirm that the partition theorem is not vacuous as a *combinatorial* statement about Heyting algebras. The remaining work is to lift that combinatorial fact to an actual distinction structure on M-Set or a related topos.

## 10. Provenance

Phase 1.2 partial work conducted on 2026-05-24 in conversation with Anthropic Claude (Cursor IDE), per the project's documented validation architecture. All computations in §§3–6 (the monoid axioms, the M-set axiom checks, the 6-element subobject lattice, the Heyting complement table, the four-cell inhabitability) are hand computations. They have been double-checked once by direct evaluation but have not been independently verified or mechanically checked. The Lean mechanization is deferred until at least one of Paths A, B, C produces a verified (D, η, ι) to mechanize.

The candidate-attempt obstructions in §7 are presented in good faith as failed attempts; if one of them turns out on closer reading to admit a fix I missed, the §6 lattice-level finding remains valid and the construction can be completed using the fix.
