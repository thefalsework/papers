# Mathlib PR draft — `HeytingAlgebra (Subobject X)` for elementary topoi

> **Status (2026-05-20): DRAFT, post-morning-reread, ready for opening sequence.**
> The morning-reread pass landed on 2026-05-20; outcomes are summarised
> at § "Morning re-read — outcomes (2026-05-20)" below.  Use the PR
> body block as written; apply the namespace and module-path
> adjustments from § "Namespace and module-path adjustments before
> submission" when copying the Lean file into a Mathlib clone.

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
Closes a gap in `Mathlib.CategoryTheory.Subobject.Lattice`:
the `SemilatticeInf`, `SemilatticeSup`, `OrderTop`, `OrderBot`, and
`Lattice` instances on `Subobject X` were already in place, but the
Heyting-algebra structure that elementary topoi induce on the subobject
lattice was missing.

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

These together are entailed by `C` being an elementary topos.  Of these,
`HasSubobjectClassifier` and `HasEqualizers` are the genuinely new
requirements for the residual construction itself; the remainder enter
via the existing `SemilatticeInf`, `SemilatticeSup`, `OrderTop`, and
`OrderBot` instances on `Subobject X` that `HeytingAlgebra` extends.
The per-lemma breakdown is given in the file's module docstring.

### Connection to existing API

`Mathlib/CategoryTheory/Subobject/Lattice.lean` (Bhavik Mehta, Kim
Morrison) already exhibits the `SemilatticeInf, SemilatticeSup,
OrderTop, OrderBot, Lattice` instances on `Subobject X` under the
corresponding limit/colimit hypotheses.  This PR extends that chain
to `HeytingAlgebra` using the new `HasSubobjectClassifier` typeclass
introduced in `Mathlib/CategoryTheory/Subobject/Classifier/Defs.lean`
(Charlie Conneen, Pablo Donato, Klaus Gy, 2024) and the equalizer
infrastructure in `Mathlib/CategoryTheory/Limits/Shapes/Equalizers.lean`.

Combined with the presheaf-topos classifier instance in
`Mathlib.CategoryTheory.Topos.Sheaf` (`HasSubobjectClassifier (Cᵒᵖ ⥤ Type w)`
for `EssentiallySmall.{w} C`), this gives the Heyting structure on any
presheaf-topos subobject lattice automatically.

### Use of AI

Per [Mathlib's AI-use policy](https://leanprover-community.github.io/contribute/index.html#use-of-ai),
disclosing: the initial proof skeleton and the six bridging lemmas
were drafted with the assistance of [Cursor](https://www.cursor.com/)
running [Anthropic Claude](https://www.anthropic.com/claude) as the
underlying model, during a multi-session co-working pass on a private
formalization project.

The author is the maintainer of the
[FalseWork Papers project](https://github.com/thefalsework/papers),
where this instance has been consumed by application-level theorems
(`four_position_partition` and three other position-theory results)
since Phase 3 of that project — providing a real downstream test of
the construction.

### Testing

* The instance resolves at the abstract level (an `inferInstance` smoke
  test under the topos hypothesis bundle exhibits this).
* `himp_bot` discharges via `rfl` (the pseudo-complement is definitionally
  `residual P ⊥`); `le_himp_iff` is the Galois connection theorem assembled
  from the six bridging lemmas.
* Downstream: in the FalseWork Papers project, the instance carries four
  position-theory theorems whose proofs are
  `LE.le.disjoint_compl_right`-style consequences of the Heyting
  structure, kernel-checked with `#print axioms` reporting only
  `[propext, Classical.choice, Quot.sound]`.
* Users should depend on this instance via typeclass search rather than
  parameterizing over `[HeytingAlgebra (Subobject Y)]`, which can produce
  instance diamonds against the native `Subobject` order structure.

### Acknowledgments

Thanks to **Edward van de Meent** and **Fernando Chu** for confirming
the gap and discussing the construction's shape in
[a #maths Zulip thread](https://leanprover.zulipchat.com/#narrow/channel/116395-maths/topic/HeytingAlgebra.20.28Subobject.20Y.29.20for.20elementary.20topoi/with/595655972)
(2026-05).

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

* **Module / import style** (required, verified against
  `Subobject/Lattice.lean`).  The new file must use Mathlib's
  module-system style:
  - First non-comment line is `module`.
  - Each `import` becomes `public import`.
  - After the module docstring, add `@[expose] public section`.

  Verify no `FalseWorkPapers.*` imports remain (there should be none).

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

* **Charlie Conneen** (main author of
  `Subobject/Classifier/Defs.lean`; GitHub handle to be looked up before opening).
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

## Morning re-read — outcomes (2026-05-20)

Re-read pass completed.  Changes landed in this draft:

* Opening paragraph: tightened "long-standing gap" → "gap"; "cartesian-
  closed structure ... force" → "Heyting-algebra structure ... induce."
* Hypothesis bundle: added one-sentence note distinguishing the genuinely
  new requirements (`HasSubobjectClassifier`, `HasEqualizers`) from those
  inherited via existing `Lattice + BoundedOrder` instances.
* Connection to existing API: tightened presheaf-compatibility sentence.
* Use of AI: dropped the "stands behind every proof" sentence and the
  self-attested experience claim; verifiable artifact link (FalseWork
  Papers project) retained as the substantive disclosure; URL corrected
  to `github.com/thefalsework/papers`.
* Testing: corrected the "`rfl`" claim (only `himp_bot` is `rfl`,
  `le_himp_iff` is the assembled Galois connection); added the
  kernel-axiom-audit fact (`#print axioms` reports only the three
  standard axioms); added a one-sentence guidance-to-users bullet
  about typeclass search vs. abstract binder.
* Instance-diamond section: removed from PR body (kept in
  `lean/HEYTING-DIAMOND.md` as historical record).  Replaced by the
  single guidance bullet at the end of Testing.
* Reviewer list: removed mis-attribution of `@b-mehta` to Charlie
  Conneen (that handle belongs to Bhavik Mehta).  Charlie Conneen's
  actual handle to be looked up before opening the PR.
* Pre-submission / namespace checklist: strengthened the module-style
  bullet from "if required" to "required, verified against
  Subobject/Lattice.lean", with the three concrete edits enumerated.
* Citation audit pass: added Mehta/Morrison credit for `Subobject/Lattice.lean`
  inline (parallel to the Conneen/Donato/Gy credit for the classifier
  file).  Added a new `### Acknowledgments` section between Testing and
  References, crediting Edward van de Meent and Fernando Chu for the
  Zulip discussion that surfaced the gap, with the canonical thread URL.

Items deferred to the Mathlib clone (not changeable from here):

* **The two `set 𝒞` proof blocks in `residual_E2` and `residual_I3`.**
  Decision: leave as-is.  The `pullback_χ_obj_mk_truth` lemma is stated
  for a specific `Subobject.Classifier C`, which forces this shape.  If
  a reviewer prefers a typeclass-bound formulation, address in review.
* **`protected def residual` vs. `def residual`.**  Decision: `def` is
  fine.  Within `CategoryTheory.Subobject`, the full name
  `Subobject.residual` is unlikely to collide.
