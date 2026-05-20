# Mathlib PR draft — `HeytingAlgebra (Subobject X)` for elementary topoi

> **Status (2026-05-19): DRAFT — not yet opened.**
> This file is Phase 4 prep for the upstream contribution.  Per the
> framework's working plan, the PR is to sit a day, get re-read in the
> morning, and only then be opened.  When opening, use this file's
> content as the PR body (with the explicit edits checklisted in
> § "Pre-submission checklist" below).

---

## PR title

```
feat(CategoryTheory/Subobject): Heyting algebra structure on Subobject in elementary topoi
```

(Mathlib convention: `<type>(<scope>): <subject>`; imperative, present
tense; subject not capitalized after the colon and no trailing period.
See [the commit conventions](https://leanprover-community.github.io/contribute/commit.html).)

## PR body

```markdown
This PR provides the canonical `HeytingAlgebra (Subobject X)` instance
for any category `C` satisfying the elementary-topos hypothesis bundle.
Closes a long-standing gap in `Mathlib.CategoryTheory.Subobject.Lattice`:
the `SemilatticeInf`, `SemilatticeSup`, `OrderTop`, `OrderBot`, and
`Lattice` instances on `Subobject X` were already in place, but the
Heyting (i.e. cartesian-closed) structure that elementary topoi force
on the subobject lattice was missing.

The construction follows Mac Lane and Moerdijk, *Sheaves in Geometry
and Logic*, IV.6 Proposition 2: implication is the residual defined
by an equalizer of characteristic morphisms, and the Galois connection
`R ≤ residual P Q ↔ R ⊓ P ≤ Q` is the load-bearing identity that drives
the `HeytingAlgebra` typeclass.

### What this PR adds

A single new file `Mathlib/CategoryTheory/Subobject/Heyting.lean`
containing:

* `CategoryTheory.Subobject.residual : Subobject X → Subobject X → Subobject X`
  — the Heyting implication, defined as
  `Subobject.mk (equalizer.ι (χ (P ⊓ Q).arrow) (χ P.arrow))`.

* `CategoryTheory.Subobject.le_residual_iff_inf_le` —
  the Galois connection `R ≤ residual P Q ↔ R ⊓ P ≤ Q`.

* `CategoryTheory.Subobject.heytingAlgebra` —
  the `HeytingAlgebra (Subobject X)` instance, with
  `himp := residual`, `compl P := residual P ⊥`,
  `le_himp_iff := le_residual_iff_inf_le`, and `himp_bot := rfl`.

Six private lemmas (`residual_E1`, `residual_E2`, `residual_E3` for the
elimination half of the Galois connection; `residual_I1`, `residual_I2`,
`residual_I3` for the introduction half) carry the proof; they are
file-local and do not enter the public API.

### Hypothesis bundle

```
[HasSubobjectClassifier C] [HasPullbacks C] [HasEqualizers C]
[HasInitial C] [HasImages C] [HasBinaryCoproducts C] [InitialMonoClass C]
```

These together are entailed by `C` being an elementary topos.  The
breakdown of which lemma needs which hypothesis is given in the file's
module docstring.

### Connection to existing API

`Mathlib/CategoryTheory/Subobject/Lattice.lean` already exhibits the
`SemilatticeInf, SemilatticeSup, OrderTop, OrderBot, Lattice` instances
on `Subobject X` under the corresponding limit/colimit hypotheses.
This PR extends that chain to `HeytingAlgebra` using the new
`HasSubobjectClassifier` typeclass introduced in
`Mathlib/CategoryTheory/Subobject/Classifier/Defs.lean`
(Charlie Conneen, Pablo Donato, Klaus Gy, 2024) and the equalizer
infrastructure in `Mathlib/CategoryTheory/Limits/Shapes/Equalizers.lean`.

The construction is upstream-compatible with the presheaf-topos
classifier instance in `Mathlib.CategoryTheory.Topos.Sheaf`
(`HasSubobjectClassifier (Cᵒᵖ ⥤ Type w)` for `EssentiallySmall.{w} C`),
giving the Heyting structure on any presheaf-topos subobject lattice
for free.

### Use of AI

Per [Mathlib's AI-use policy](https://leanprover-community.github.io/contribute/index.html#use-of-ai),
disclosing: the initial proof skeleton and the six bridging lemmas
were drafted with the assistance of [Cursor](https://www.cursor.com/)
running [Anthropic Claude](https://www.anthropic.com/claude) as the
underlying model, during a multi-session co-working pass on a private
formalization project.  The author re-read every proof and every
docstring, debugged a substantive instance-diamond issue surfaced
during downstream consumption (forcing an architectural reshape of
the consuming layer), and stands behind the entire content of the PR.

The author has been formalizing in Lean 4 / Mathlib since 2024 and is
the maintainer of the
[FalseWork Papers project](https://github.com/cmbrink/falsework-papers),
where this instance has been consumed by application-level theorems
(`four_position_partition` and three other position-theory results)
since Phase 3 of that project — providing a real downstream test of
the construction.

### Testing

* The instance resolves at the abstract level (an `inferInstance` smoke
  test under the topos hypothesis bundle exhibits this).
* `le_himp_iff` and `himp_bot` discharge via `rfl` / direct equation —
  no additional simp set required.
* Downstream:  in the FalseWork Papers project, the instance carries
  four position-theory theorems whose proofs are
  `LE.le.disjoint_compl_right`-style consequences of the Heyting
  structure.  Those proofs broke (instance diamond, see below) before
  this construction was wired in and discharge cleanly after.

### Note on instance diamonds

The Phase 3 downstream consumer initially carried an abstract
`[∀ Y : C, HeytingAlgebra (Subobject Y)]` binder as a stopgap before
this instance existed.  When the construction was wired in but the
binder retained, an instance diamond materialized:
`HeytingAlgebra.toGeneralizedHeytingAlgebra.toSemilatticeInf.toPartialOrder`
versus the native `instPartialOrderSubobject` resolved to syntactically
distinct `PartialOrder` instances on `Subobject Y`, blocking unification
between the theorem hypotheses (typed against native) and the Heyting
lemmas (typed against the binder chain).

Resolution was to drop the abstract binder entirely and let the
universal instance fire via typeclass search.  The lesson for upstream:
this instance is *the* Heyting structure on `Subobject X` — any
abstract `[HeytingAlgebra (Subobject X)]` binder is a smell, and the
construction here resolves the underlying gap that motivated such
binders.

### References

* [MM92] S. Mac Lane and I. Moerdijk, *Sheaves in Geometry and Logic*,
  Springer, 1992.  Chapter IV § 6, Proposition 2 (the residual
  construction) and Theorem 8 (subobject lattice is a Heyting
  algebra).
```

---

## File diff (preview)

The PR adds a single new file:

* `Mathlib/CategoryTheory/Subobject/Heyting.lean` (~270 lines including
  module doc and proof commentary)

Plus one line in `Mathlib.lean` (auto-generated by
`lake exe mk_all`) to register the new file as part of the library.

No existing Mathlib file is modified.

---

## Namespace and module-path adjustments before submission

The Lean source file currently sits at
`lean/FalseWorkPapers/Heyting/SubobjectInstance.lean` under the
namespace `FalseWork.Heyting` (this is the in-repo home, so that
existing FalseWork cell files can resolve `FalseWork.Heyting.heytingAlgebra`
without import churn during PR review).  Before opening the PR, copy
the file content into a Mathlib clone with these mechanical edits:

* **Module path.**
  `lean/FalseWorkPapers/Heyting/SubobjectInstance.lean`
  →
  `Mathlib/CategoryTheory/Subobject/Heyting.lean`.

* **Namespace.**
  `namespace FalseWork.Heyting … end FalseWork.Heyting`
  →
  `namespace CategoryTheory.Subobject … end CategoryTheory.Subobject`.

* **Imports.**
  Drop the `FalseWorkPapers.*` imports (there are none) and add the
  `@[expose] public section` marker if Mathlib's `module` style is
  required for the file (check the immediate neighbours under
  `Mathlib/CategoryTheory/Subobject/`).

* **License header.**
  The file already carries the Apache 2.0 wording and a
  `Authors: Chris Brink` line; nothing else needs editing.

* **Header note.**
  Delete the parenthetical Phase-4-note block at the top of the file
  (`(Phase 4 note. …)`).  That paragraph is internal scaffolding for
  the FalseWork project, not relevant to the upstream review.

* **Top docstring marker.**
  Replace `/-! … -/` style with whatever the immediate Mathlib
  neighbours use (most likely also `/-! … -/`).  Verify.

* **`@[simp]` audit.**
  None of the public lemmas are currently `@[simp]`-tagged.  Audit
  whether `le_residual_iff_inf_le` would benefit from being a simp
  lemma — probably not, since it has the `Iff` shape that simp will
  decompose into two `←`-rewrites of dubious convergence behaviour.
  Leave un-tagged.

* **Instance priority.**
  The instance is currently `instance heytingAlgebra` with default
  priority.  For Mathlib, this is correct — Heyting structure is part
  of the canonical chain on `Subobject X`, so default priority
  matches the existing `Subobject.semilatticeInf` etc.

* **Smoke-test file.**
  `lean/FalseWorkPapers/Examples/HeytingTypeInstance.lean` is the
  in-repo smoke test.  For Mathlib it has no natural home (Mathlib
  reserves `MathlibTest/` for tactic tests, not instance smoke
  checks), so its content goes into the PR description as an
  example block, not as a file.

---

## Pre-submission checklist

Before clicking "Create PR", verify in order:

* [ ] PR title matches the convention exactly.
* [ ] PR body is the markdown block above, with date and any
      review-stream comments filled in.
* [ ] File is at `Mathlib/CategoryTheory/Subobject/Heyting.lean`.
* [ ] Namespace is `CategoryTheory.Subobject` throughout.
* [ ] `lake exe mk_all` has been run; `Mathlib.lean` includes the new
      file.
* [ ] `lake build` is green on a clean checkout.
* [ ] AI-use disclosure paragraph is present.
* [ ] If maintainer expects `LLM-generated` label, add it.
* [ ] Reviewer suggestions are ready (see below).

---

## Suggested reviewers

Drawing from the immediate file-history of the surrounding code:

* **Charlie Conneen** (`@b-mehta` on GitHub; main author of
  `Subobject/Classifier/Defs.lean`).
* **Pablo Donato** (co-author of the classifier file).
* **Klaus Gy** (co-author of the classifier file).
* **Bhavik Mehta** (co-author of `Subobject/Lattice.lean`; runs the
  `b-mehta/topos` Lean 3 project referenced in the classifier file).
* **Kim Morrison** (`@semorrison`; co-author of `Subobject/Lattice.lean`).
* **Joël Riou** (broad category-theory reviewer).

Suggested approach: before opening the PR, post a short message in
the [#mathlib4 channel](https://leanprover.zulipchat.com/#narrow/channel/287929-mathlib4/)
or the [PR reviews channel](https://leanprover.zulipchat.com/#narrow/channel/144837-PR-reviews/)
introducing the contribution, with a link to this draft.  This is
Mathlib's preferred mode (per the
[contribution guide](https://leanprover-community.github.io/contribute/index.html)):
"come to the Zulip, introduce yourself, and mention your new PR."

---

## Things to re-read in the morning

Before opening the PR, re-check each of these for tone, accuracy, and
appropriateness:

1. The "Use of AI" paragraph.  Mathlib's maintainers have stated
   strong views; the disclosure must be both candid and substantive.
   The current paragraph should pass on both counts but re-read it
   cold.

2. The "Note on instance diamonds" paragraph.  This is a substantive
   contribution to the PR's value (it documents an architectural
   lesson surfaced during downstream use), but it could read as
   defensive or as scope creep.  Verify it lands as the former.

3. The reviewer list.  Re-check that all suggested reviewers are
   active in late 2025 / early 2026 (someone may have stepped back).

4. The hypothesis bundle.  Walk through each member and verify it is
   genuinely needed by some specific clause of some specific lemma.
   If any one of them is redundant, drop it before submission — this
   is the kind of thing Mathlib reviewers will catch fast.

5. The proof of `residual_E2` and `residual_I3` — the two `set 𝒞`
   blocks.  These are functional but a touch awkward; a reviewer
   might suggest a cleaner formulation against the typeclass-bound
   `HasSubobjectClassifier.χ` rather than the chosen-classifier
   `𝒞.χ`.  Be prepared to either defend the current form (the
   `pullback_χ_obj_mk_truth` lemma's statement forces this shape)
   or rewrite to the typeclass form if a cleaner path exists.

6. Whether to mark `residual` as `protected def` or just `def`.
   Currently `def` (and the namespace `CategoryTheory.Subobject`
   would make the full name `Subobject.residual`, which is unlikely
   to collide).  Probably fine but verify.
