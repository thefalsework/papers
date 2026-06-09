/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# The mathematics floor: the diagonal as Level-0 comma (math anchor, Phase 1)

This is the math-anchor analogue of `FalseWork.Diophantine.shared_diophantine_floor`
(the music anchor's floor).  Where the music floor is the multiplicative
independence of distinct primes (the Pythagorean comma), the mathematics
floor is **the diagonal argument**: the residue an enumeration generates
but cannot contain.

* **The residue** (`diagonal_escapes`).  For any `f : α → Set α` and any
  `a : α`, the diagonal set `{x | x ∉ f x}` differs from `f a`.  The
  diagonal set is "what the indexing generates but cannot index" — the
  Level-0 comma in set-theoretic form.

* **The floor** (`cantor_no_surjection`).  No `f : α → Set α` is
  surjective.  This is `Function.cantor_surjective`, already in Mathlib,
  audited; the math floor is *free* the same way the music floor's
  `irrational_sqrt_two` was handed over by the library.

* **The unification** (`lawvere_fixedPoint`).  Cantor, Russell, Tarski,
  and Gödel are one theorem: a self-referential surjection forces a fixed
  point, so a *fixed-point-free* operator forbids the surjection.  Cantor
  is the instance `B = Bool`, `f = not` (`cantor_bool_via_lawvere`);
  Russell is `diagonal_escapes`; Tarski (truth) and Gödel (provability)
  are the instances where `B` carries a truth / provability predicate.

## Structural reading (prose, NOT theorem)

The identification "diagonal escape = comma" is a *structural*
identification, exactly as "Pythagorean near-miss = comma" was in the
music floor.  The theorems below are `[K]`; the reading that they
instantiate the FalseWork comma is `[A]`-adjacent and lives in the prose,
not the kernel.  This mirrors the discipline of `DiophantineFloor.lean`:
the kernel checks the obstruction; it does not check the interpretation.

Lawvere's theorem makes the *unification* claim of Paper 4 §10 ("the same
diagonal recurs across Cantor/Russell/Tarski/Gödel") rigorous-adjacent:
the common core is genuinely one lemma.  But Tarski and Gödel proper
require a formalized truth / provability predicate (the
`FormalizedFormalLogic` Foundation project, an *external* dependency that
the anchor's core deliberately avoids).  So the Cantor and Russell
instances are `[K]` here; the Tarski/Gödel instances are `[O]`, named but
not imported.

## Scope honesty (read before reusing this as "the mathematics anchor")

This file is the **floor only** (Phase 1).  Two caveats bound what any
later phases can claim, and they are pre-registered here so the result
cannot drift into an over-claim:

1. **This is not "mathematics", it is intuitionistic propositional logic.**
   The substrate of Phases 2–4 (the Rieger–Nishimura lattice = the free
   Heyting algebra on one generator) encodes *intuitionistic* logic on
   *one* atom.  Both adjectives are choices a classical mathematician may
   reject.  There is no "encoding gap eliminated" here; the gap moves to
   "why intuitionistic Heyting on one generator = mathematics."  Any anchor
   built on this substrate is about intuitionistic propositional logic,
   stated as such — not "mathematics" in general.

2. **One generator is *simplest*, not *forced*.**  `F(1)` is
   Rieger–Nishimura; `F(2)`, `F(ω)` are different lattices.  The choice of
   one generator is justified by simplicity, not by the domain forcing it
   the way 12-tone temperament forced `ℤ/12` on the music anchor.

## Phase 2–4 pre-registration (success and failure fixed in advance)

Before any enumeration runs, the acceptable outcomes of the forced-kernel
experiment on the (infinite) Rieger–Nishimura lattice — run on finite
truncations `RN n` since `decide` cannot exhaust an infinite type — are:

* **(A) Unique forced kernel, stable across truncations.**  Some element
  is the unique kernel making all four cells non-vacuous, and it does not
  change as `n` grows.  → the math anchor gets its "tritone"; novel small
  result.
* **(B) Multiple kernels work, stably.**  The anchor is real but less
  rigid than music; report the asymmetry as-is.
* **(C) No kernel works on any truncation.**  Negative result; a genuine
  constraint on the cross-domain claim.  Keep it.
* **(D) The forced kernel is truncation-DEPENDENT** — it changes with `n`
  and does not stabilize.  → there is no canonical kernel; the "free
  object" selling point fails even though every individual `decide`
  passes.  This is the most likely failure mode and is a real result.

The kernel decides among (A)–(D); the prose does not.  A finite truncation
is itself a choice, so (A)/(B) are only claimable if they are *stable*
in the truncation index — non-stability is outcome (D), not a bug to patch.
-/
import Mathlib.Logic.Function.Basic
import Mathlib.Data.Set.Basic

namespace FalseWork.MathFloor

/-! ## The diagonal as residue (Russell / Cantor in set form) -/

/-- **The diagonal residue.**  For any indexing `f : α → Set α` and any
index `a`, the diagonal set `{x | x ∉ f x}` is *not* `f a`.  The diagonal
set is the residue: the subset the indexing generates (by self-reference)
but cannot itself contain.  Self-contained; this is the Russell instance
of `lawvere_fixedPoint`. -/
theorem diagonal_escapes {α : Type*} (f : α → Set α) (a : α) :
    f a ≠ {x | x ∉ f x} := by
  intro h
  have hmem : a ∈ {x | x ∉ f x} ↔ a ∉ f a := Iff.rfl
  rw [← h] at hmem
  exact iff_not_self hmem

/-! ## The floor: Cantor (handed over by Mathlib) -/

/-- **The mathematics floor.**  No `f : α → Set α` is surjective — the
power set always escapes the type.  This is `Function.cantor_surjective`,
already in Mathlib; the math anchor's floor is free, the way
`irrational_sqrt_two` gave the music floor its rank-1 obstruction. -/
theorem cantor_no_surjection {α : Type*} (f : α → Set α) :
    ¬ Function.Surjective f :=
  Function.cantor_surjective f

/-! ## The unification: Lawvere's fixed-point theorem -/

/-- **Lawvere's fixed-point theorem.**  If `e : A → (A → B)` is surjective
(`A` "point-surjects" onto its own function space into `B`), then every
`f : B → B` has a fixed point.

This is the common core of Cantor, Russell, Tarski, and Gödel: each is the
contrapositive instance where `B` carries a *fixed-point-free* operator
(`not` on `Bool`; negation on `Prop`; the liar/provability predicate),
which then forbids the self-referential surjection. -/
theorem lawvere_fixedPoint {A B : Type*} {e : A → A → B}
    (he : Function.Surjective e) (f : B → B) : ∃ b, f b = b := by
  obtain ⟨a, ha⟩ := he (fun x => f (e x x))
  exact ⟨e a a, (congrFun ha a).symm⟩

/-- `not : Bool → Bool` is fixed-point-free. -/
theorem not_no_fixedPoint : ¬ ∃ b : Bool, not b = b := by
  rintro ⟨b, hb⟩; cases b <;> simp at hb

/-- **Cantor via Lawvere (Bool form).**  No `e : α → (α → Bool)` is
surjective: a surjection would, by `lawvere_fixedPoint`, give `not` a
fixed point, which `not_no_fixedPoint` forbids.  This exhibits Cantor as
a Lawvere instance, self-contained. -/
theorem cantor_bool_via_lawvere {α : Type*} (e : α → α → Bool) :
    ¬ Function.Surjective e := by
  intro he
  exact not_no_fixedPoint (lawvere_fixedPoint he not)

/-! ## The bundled floor -/

/-- **The mathematics floor (bundled).**  The diagonal residue
(`diagonal_escapes`), the non-surjectivity it forces (`cantor_no_surjection`),
and the Lawvere unification witnessing Cantor as a fixed-point obstruction
(`cantor_bool_via_lawvere`) — the math-anchor analogue of
`shared_diophantine_floor`.  The structural identification with the
FalseWork comma is prose, not part of this statement. -/
theorem mathematics_floor {α : Type*} :
    (∀ (f : α → Set α) (a : α), f a ≠ {x | x ∉ f x}) ∧
    (∀ f : α → Set α, ¬ Function.Surjective f) ∧
    (∀ e : α → α → Bool, ¬ Function.Surjective e) :=
  ⟨diagonal_escapes, cantor_no_surjection, cantor_bool_via_lawvere⟩

end FalseWork.MathFloor
