# Architecture of the proven framework

> **Status (2026-05-24).** Snapshot view of the FalseWork Lean formalization with the Spencer-Brown anchor companion theorems and the canonization-closure layer added. The entire tree is `sorry`-free; the load-bearing theorems plus two anchor theorems (Boolean collapse at partition level, idempotent-monad bridge) plus the conditional recursive partition theorem (canonization closure) are kernel-checked. One framework-level conjecture (the *refusal bridge*) is carried as a named open item in the validation queue. The canonization-closure layer is *conditional*: its recursive partition theorem is kernel-checked given the data of a canonization-closure witness, but the load-bearing predicate identifying *which* idempotent monads count as canonization closures of a given morphism is open mathematical work.

This document is a single-page orientation for anyone — a new Lean contributor, a category-theory reviewer, the author six months on — who wants to see how the proven framework fits together without reading the source files first. It carries three views of the same artefact at three levels of abstraction:

1. **Proof dependency.** What proves what, file by file, from textbook citation up to the two load-bearing theorems.
2. **Cell geometry.** The four cells of the partition as regions in the Heyting algebra `Sub(D Y)`, with the Heyting identities that force pairwise disjointness named explicitly.
3. **Status ledger.** Proven / submitted / open, as of the latest commit.

The three views are reciprocal: the dependency view shows *how* the framework is constructed; the geometric view shows *what* the construction is talking about; the status ledger shows *where* the work sits in its broader trajectory (in-tree, upstream-submitted, framework-internal-open). All three were drafted together; if one drifts out of date the others will signal it.

For module-level (file-by-file) import graphs, the standard tooling is `lake exe graph` from `importGraph` (already a transitive dependency). For theorem-level dependencies in finer detail, `#check @theorem_name` and `#print axioms theorem_name` are the canonical Lean introspection commands. The diagrams below are kept by hand because no Lean tool produces them automatically at the level of abstraction a reader-onboarding document needs.

---

## 1. Proof dependency

```
THE PROVEN FRAMEWORK — proof dependency, 2026-05-20

         Mac Lane–Moerdijk, Sheaves in Geometry and Logic, IV.6 Prop 2
                                  │   (textbook construction; citation only)
                                  ▼
                    ┌──────────────────────────┐
                    │  residual P Q :=         │
                    │    Subobject.mk          │
                    │    (equalizer.ι (χ ⊓)    │
                    │                (χ P))    │
                    └────────────┬─────────────┘
                                 │
                ┌────────────────┴────────────────┐
                ▼                                 ▼
        Three intro lemmas                 Three elim lemmas
        I1 (refl)                          E1 (χ-equality)
        I2 (monotonicity)                  E2 (Beck-Chevalley)
        I3 (Beck-Chevalley + lift)         E3 (inf transport)
                │                                 │
                └────────────────┬────────────────┘
                                 ▼
                    ┌──────────────────────────┐
                    │  le_residual_iff_inf_le  │   ◀── load-bearing
                    │  R ≤ residual P Q ↔      │       Galois connection
                    │  R ⊓ P ≤ Q               │
                    └────────────┬─────────────┘
                                 │
                                 ▼
              ┌────────────────────────────────────────┐
              │  HeytingAlgebra (Subobject Y)          │   ★ Mathlib PR #39618
              │  for any elementary topos C            │     (opened 2026-05-20,
              │  (the gap that was missing in Mathlib) │      CI green, in review)
              └────────────────┬───────────────────────┘
                               │  provides ⊓ ⊔ ⊥ ⊤ ⇒ ¬ on every Sub Y
                               │  plus identities:   aᶜ ⊓ a = ⊥
                               │                     aᶜ ⊓ aᶜᶜ = ⊥
                               │                     a ≤ aᶜᶜ
                               ▼
              ┌────────────────────────────────────────┐
              │  Positions/Setup.lean                  │
              │   DistinctionStructure Δ:              │
              │     D : C ⥤ C   idempotent             │
              │     η : 𝟭 ⟶ D   marking unit           │
              │   kernelImage Δ Y := image.ι (η.app Y) │
              └────────────────┬───────────────────────┘
                               │
        ┌──────────────┬───────┴────────┬─────────────┐
        ▼              ▼                ▼             ▼
  Infrastructure  Distribution    Exploitation    Refusal
  img ≤           img ⊓ Im(η)≠⊥   img ≤ ¬¬Im(η)   img ≤
  Im(η)             ∧             ∧               ¬Im(η)
                  img ⊓¬Im(η)≠⊥   ¬(img ≤ Im(η))
        │              │                │             │
        └──────────────┴──────┬─────────┴─────────────┘
                              ▼
        ╔════════════════════════════════════════════════╗
        ║   four_position_partition                      ║
        ║   ──────────────────────                       ║
        ║   ∀ Δ.NonTrivial, ∀ f with non-trivial         ║
        ║   D-image:  exactly one cell holds             ║
        ║                                                ║
        ║   PROVEN.  #print axioms reports               ║
        ║     [propext, Classical.choice, Quot.sound]    ║
        ╚════════════════════════════════════════════════╝

  Independent branch (the asymptotic-residue claim):

              ┌────────────────────────────────────────┐
              │  Δ.HasIrregularKernel                  │   ◀── named hypothesis
              │  ∃ Y, kernelImage Δ Y ≠                │       (regulars framing)
              │       (kernelImage Δ Y)ᶜᶜ              │
              └────────────────┬───────────────────────┘
                               ▼
        ╔════════════════════════════════════════════════╗
        ║   refusal_residue                              ║
        ║   ───────────────                              ║
        ║   ∃ Y, kernelImage Δ Y                         ║
        ║          < (kernelImage Δ Y)ᶜᶜ                 ║
        ║                                                ║
        ║   PROVEN under HasIrregularKernel.             ║
        ║   #print axioms = standard three.              ║
        ╚════════════════════════════════════════════════╝

  Open framework conjecture (in validation queue):

         Δ.NonTrivial + NonBoolean C  ⟹?  Δ.HasIrregularKernel
                  (the refusal bridge — when does the
                   kernel escape the regular sub-algebra?)
              → ../validation/claims/refusal-bridge.md
```

**Reading guide.**

* The vertical axis is proof dependency: lower theorems depend on higher ones. Cited textbook results are at the top; the two load-bearing theorems are at the bottom of their respective branches.
* The Heyting-algebra construction at the centre is the upstream artefact. The Mathlib PR is that artefact, lifted out of the FalseWork tree and translated into Mathlib's module conventions. Until merged, the construction is consumed locally in the FalseWork tree; after merge it becomes a Mathlib import and the local copy is retired.
* The four cell predicates fan out from `Setup.lean` and converge in `Partition.lean`. The partition theorem's case-split is a Heyting-algebra trichotomy on `(img(D.map f), kernelImage Δ Y)` plus six pairwise-disjointness lemmas.
* `refusal_residue` is on an independent branch — it does not feed `four_position_partition`, and the partition's correctness does not depend on whether the residue is non-empty. The two theorems are co-existing on the same `Sub(D Y)` substrate but address different questions.

---

## 2. Cell geometry

The Heyting algebra `Subobject (D.obj Y)` is the ambient lattice. `Im(η)` (the kernel image) is a distinguished element. Each morphism `f : X ⟶ Y` produces `img(D.map f) ∈ Sub(D.obj Y)`, and the cell `f` falls into is determined by where that image sits relative to `Im(η)` and its Heyting derivatives `¬Im(η)` and `¬¬Im(η)`.

```
THE FOUR CELLS — geometric view in Subobject (D Y)

                                  ⊤
                                  │
                                  │
                      ╔═══════════╪═══════════╗
                      ║                       ║
                      ║   ┌─────────┐         ║
                      ║   │  Im(η)  │         ║         IM region
                      ║   │         │         ║         (the kernel
                      ║   │ INFRA.  │         ║          image itself)
                      ║   │ img ≤   │         ║
                      ║   │ Im(η)   │         ║
                      ║   └─────────┘         ║
                      ║      ↑ ↓              ║
                      ║   ┌─────────┐         ║         RESIDUE region
                      ║   │EXPLOIT. │         ║         (in the closure
                      ║   │ img ≤   │         ║          but not the
                      ║   │ ¬¬Im(η) │         ║          image —
                      ║   │ ∧ not   │         ║          asymptotic
                      ║   │ ≤ Im(η) │         ║          target of
                      ║   └─────────┘         ║          Refusal-acts)
                      ║                       ║
                      ║      ¬¬Im(η)          ║         the closure
                      ║                       ║         (Heyting double
                      ╚═══════════════════════╝         pseudo-complement)



                          DISTRIBUTION                  STRADDLE region
                          img has parts in              (cells that touch
                          BOTH Im(η) and ¬Im(η)         both Im(η) and
                                                        its complement)
                          img ⊓ Im(η) ≠ ⊥
                          img ⊓ ¬Im(η) ≠ ⊥



                      ╔═══════════════════════╗
                      ║                       ║
                      ║   ┌─────────┐         ║         NEG region
                      ║   │ ¬Im(η)  │         ║         (the pseudo-
                      ║   │         │         ║          complement
                      ║   │ REFUSAL │         ║          of the kernel
                      ║   │ img ≤   │         ║          image)
                      ║   │ ¬Im(η)  │         ║
                      ║   └─────────┘         ║
                      ║                       ║
                      ╚═══════════════════════╝
                                  │
                                  │
                                  ⊥


  Disjointness — each pair forced by ONE Heyting identity:
    Infra ⊓ Refusal      : Im(η) ⊓ ¬Im(η) = ⊥
    Infra ⊓ Exploit      : exploitation requires ¬(img ≤ Im(η))
    Infra ⊓ Distribution : if img ≤ Im(η), img ⊓ ¬Im(η) = ⊥
    Refusal ⊓ Exploit    : ¬Im(η) ⊓ ¬¬Im(η) = ⊥           ←  load-bearing
    Refusal ⊓ Distribution : if img ≤ ¬Im(η), img ⊓ Im(η) = ⊥
    Distribution ⊓ Exploit : closure-residue is in ¬¬Im(η),
                             contradicting img ⊓ ¬Im(η) ≠ ⊥

  Exhaustiveness:  Heyting case-split on the relationship between
                   img and Im(η).  All four cases land in a cell.

  In Boolean topoi (Set):  Im(η) = ¬¬Im(η).  The RESIDUE region
                           collapses; Exploitation is empty.
                           The theorem still partitions, but only
                           three cells have inhabitants.

  In non-Boolean topoi:    The RESIDUE region is potentially
                           non-empty.  Whether it actually is non-
                           empty for a given Δ is what `refusal_residue`
                           (under HasIrregularKernel) asserts.
```

**Reading guide.**

* The diagram is a schematic of `Sub(D.obj Y)`, not a literal Hasse diagram. The framing `⊥`/`⊤` boxes locate top and bottom; the inner regions are not lattice cells but *predicate regions* that classify where the image of a particular morphism `f` lands.
* `Im(η)` and `¬Im(η)` are disjoint by the Heyting identity `a ⊓ aᶜ = ⊥` (always). `Im(η) ≤ ¬¬Im(η)` is also always true (`a ≤ aᶜᶜ`). The interesting structural fact is whether the inequality `Im(η) ≤ ¬¬Im(η)` is strict, which is what `refusal_residue` addresses.
* The Distribution cell is the one that doesn't fit "inside" any of `Im(η)`, `¬Im(η)`, or `¬¬Im(η)` — its image straddles the kernel boundary. There is no single "region" drawn for it because it is precisely the *complement* of the union of the other three (modulo the trivial-image edge case where every cell holds vacuously).

---

## 3. Status ledger

```
PROVEN / SUBMITTED / OPEN — snapshot 2026-05-20 (post-second-pass)

  ┌─────────────────────────────────────────────────────────────────┐
  │ KERNEL-CHECKED (axioms: propext, Classical.choice, Quot.sound)  │
  ├─────────────────────────────────────────────────────────────────┤
  │  ✓ FalseWork.Heyting.heytingAlgebra                             │
  │  ✓ FalseWork.Heyting.le_residual_iff_inf_le                     │
  │                                                                 │
  │  ✓ FalseWork.Positions.four_position_partition          ★       │
  │  ✓ FalseWork.Positions.isRefusal_iff_image_le_compl             │
  │  ✓ FalseWork.Positions.isDistribution_implies_neither_polar     │
  │  ✓ FalseWork.Positions.exploitation_refusal_disjoint            │
  │  ✓ FalseWork.Positions.trivialized_implies_isInfrastructure     │
  │  ✓ FalseWork.Positions.refusal_residue                  ★       │
  │                                                                 │
  │  Spencer-Brown anchor (companion to                             │
  │  preprints/four-position-partition/spencer-brown-anchor.md):    │
  │  ✓ FalseWork.Positions.boolean_partition_three_cells            │
  │  ✓ FalseWork.Positions.DistinctionStructure.ofIdempotentMonad   │
  │                                                                 │
  │  Canonization closure (companion to                             │
  │  preprints/four-position-partition/closure-canonization.md):    │
  │  ✓ FalseWork.Positions.recursive_partition     (conditional)    │
  │                                                                 │
  │  Tree is sorry-free.  Audit at Examples/HeytingTypeInstance.lean│
  └─────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────┐
  │ SUBMITTED UPSTREAM                                              │
  ├─────────────────────────────────────────────────────────────────┤
  │  • Mathlib PR #39618 — HeytingAlgebra (Subobject Y) on          │
  │    elementary topoi.  CI green, awaiting review.                │
  │    247 additions / 0 deletions.  Labels: t-category-theory,     │
  │    new-contributor.                                             │
  └─────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────┐
  │ OPEN AT THE FRAMEWORK LEVEL                                     │
  ├─────────────────────────────────────────────────────────────────┤
  │  ? The refusal bridge                                           │
  │    Δ.NonTrivial + NonBoolean C ⟹? Δ.HasIrregularKernel          │
  │    ../validation/claims/refusal-bridge.md                       │
  │                                                                 │
  │  ? Commitment-gate per-cell iteration content                   │
  │    (schema uniform; content open in four independent files)    │
  │                                                                 │
  │  ? Continuous iteration of D                                    │
  │  ? Level structure for Deep Infrastructure                      │
  │  ? Categorical specification of Moment                          │
  │  ? Balance condition for Distribution                           │
  └─────────────────────────────────────────────────────────────────┘
```

**Reading guide.**

* The proven theorems are the ones whose Lean source compiles to a `.olean` that the kernel accepts. The audit cell at `Examples/HeytingTypeInstance.lean` calls `#print axioms` on each one; the standard-three-axioms result is the only acceptable output.
* "Submitted upstream" means a Mathlib PR is open, not that anything has been accepted. The framework consumes its local copy of the construction either way; an upstream merge replaces the local copy with a Mathlib import without changing the proof.
* "Open at the framework level" items are genuine open problems — neither blocked on tooling nor on Mathlib gaps. The refusal bridge is the only one of these whose resolution materially affects how broadly an already-proven theorem applies; the others are about features of the framework that are not yet specified at the level of mathematical content.

---

## Cross-references

* [`README.md`](README.md) — the formalization's home page, including the *Sketch in flight* historical record and the per-file directory.
* [`HEYTING-GAP.md`](HEYTING-GAP.md) — the upstream-dependency history (gap diagnosed 2026-05-17, closed locally 2026-05-19, PR opened 2026-05-20).
* [`HEYTING-DIAMOND.md`](HEYTING-DIAMOND.md) — the instance-diamond triage that retired the abstract `[∀ Y, HeytingAlgebra (Subobject Y)]` binder.
* [`PHASE-0-DECISIONS.md`](PHASE-0-DECISIONS.md) — the original architectural decisions and the supersession record for Decision 2.
* [`MATHLIB-PR-DRAFT.md`](MATHLIB-PR-DRAFT.md) — the PR body as submitted, including the AI-use disclosure paragraph and the reviewer suggestions.
* [`../validation/claims/five-position-derivation-formalization.md`](../validation/claims/five-position-derivation-formalization.md) — the umbrella validation claim.
* [`../validation/claims/refusal-bridge.md`](../validation/claims/refusal-bridge.md) — the named open conjecture.
* [`../docs/observations/validation-architecture-outcomes.md`](../docs/observations/validation-architecture-outcomes.md) — the per-engagement record (Mathlib PR opening at 2026-05-20; second-pass closure at 2026-05-20 second pass).

## Maintenance

This document is hand-kept because no Lean tool produces it. When any of the following changes, this file should be refreshed:

* A new theorem joins the kernel-checked set, or one leaves it.
* The Mathlib PR's status changes (merged, requested changes, closed).
* The refusal bridge resolves (positive, negative, or qualified).
* A new framework-level open item is added to the queue, or one resolves.

The diagrams are ASCII so the file is `git diff`-friendly and renders identically in any reader. If a Mermaid or Graphviz rendering of the same content becomes useful at a later milestone, the ASCII version stays as the source of truth and the rendered version is generated alongside.
