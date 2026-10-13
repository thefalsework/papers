/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE-CODE.
Authors: Chris Brink
SPDX-License-Identifier: Apache-2.0
-/
import Challenge

/-!
# Challenge checks

Kernel-checked sanity lemmas supporting the statement-matches-paper review
of `Challenge.lean`. These are not challenge theorems and are not in
`config.json`; they exist so that the equivalences the human review leans
on are themselves checked, in CI, rather than asserted in prose.

Built by `.github/workflows/comparator.yml` (`lake build ChallengeChecks`)
and recorded in `formalization.yaml` under `verification.statement_checks`.
Imports `Challenge` only, which imports Mathlib only.

AI-authored (Claude, in Cursor), directed and reviewed by Chris Brink.
-/

variable {H : Type*} [HeytingAlgebra H]

/-- Check A: every ladder value lies in the generated subalgebra. Together
with `nishimura_normal_form` this makes the challenge statement a two-sided
characterization: generated set = {⊤} ∪ range (rnLadder g). Any indexing
dispute is therefore immaterial to the claim. -/
theorem rnLadder_generated (g : H) : ∀ n, HeytingGeneratedBy g (rnLadder g n)
  | 0 => .bot
  | 1 => .compl .gen
  | 2 => .gen
  | 3 => .compl (.compl .gen)
  | 4 => .sup (.compl .gen) .gen
  | (n + 5) => by
      rw [rnLadder]
      split
      · exact .himp (rnLadder_generated g (n + 3)) (rnLadder_generated g (n + 2))
      · exact .sup (rnLadder_generated g (n + 2)) (rnLadder_generated g (n + 3))

/-- Check B: the two-clause `OrdinaryElement` is equivalent to the paper's
three-clause form (§2.1): a ≠ ⊥ ∧ ¬a ≠ ⊥ ∧ ¬¬a ≠ a. -/
theorem ordinaryElement_iff_three_clause (a : H) :
    OrdinaryElement a ↔ (a ≠ ⊥ ∧ aᶜ ≠ ⊥ ∧ aᶜᶜ ≠ a) := by
  constructor
  · rintro ⟨hreg, hdense⟩
    refine ⟨?_, hdense, hreg⟩
    rintro rfl
    exact hreg (by simp)
  · rintro ⟨_, hdense, hreg⟩
    exact ⟨hreg, hdense⟩

/-- Check C: the `compl` constructor of `HeytingGeneratedBy` is redundant
given `himp` and `bot`, as the docstring claims. -/
theorem heytingGeneratedBy_compl_of_himp (g x : H) (h : HeytingGeneratedBy g x) :
    HeytingGeneratedBy g xᶜ := by
  rw [← himp_bot]
  exact .himp h .bot

/-- Check D: the E-region existential in `FourRegionsInhabited` forces its
witness non-⊥ automatically, so the missing `x ≠ ⊥` guard there is sound. -/
theorem ne_bot_of_not_le (a x : H) (h : ¬ x ≤ a) : x ≠ ⊥ := fun hx => h (hx ▸ bot_le)

/-- Check D': likewise the D-region existential (x ⊓ a ≠ ⊥ forces x ≠ ⊥). -/
theorem ne_bot_of_inf_ne_bot (a x : H) (h : x ⊓ a ≠ ⊥) : x ≠ ⊥ :=
  fun hx => h (by simp [hx])

/-- Check E: the literal `(1, 0)` in `twelve_unique_kernel` denotes the point
with numeric coordinates (1, 0) — i.e. 2-adic valuation 1, 3-adic 0 — the
divisor 2, not some wrapped-around `OfNat` artifact. -/
theorem twelve_kernel_point_coords :
    ((1, 0) : Fin 3 × Fin 2).1.val = 1 ∧ ((1, 0) : Fin 3 × Fin 2).2.val = 0 := by
  decide

/-- Check F: `z6Landmarks g` sends the six points of `Fin 3 × Fin 2` to the
paper's six landmarks in the stated order (`⊥, g, ¬g, ¬¬g, g ∨ ¬g, ⊤` at
divisors 1, 2, 3, 4, 6, 12), so `ordinary_gives_z6_embedding` is about the
paper's explicit map and not merely some embedding. -/
theorem z6Landmarks_values (g : H) :
    z6Landmarks g (0, 0) = ⊥ ∧ z6Landmarks g (1, 0) = g ∧ z6Landmarks g (0, 1) = gᶜ ∧
    z6Landmarks g (2, 0) = gᶜᶜ ∧ z6Landmarks g (1, 1) = g ⊔ gᶜ ∧ z6Landmarks g (2, 1) = ⊤ :=
  ⟨rfl, rfl, rfl, rfl, rfl, rfl⟩

/-- Check G: order preservation and reflection, as stated in
`ordinary_gives_z6_embedding`, yields injectivity (the six landmarks are
pairwise distinct) and an honest `OrderEmbedding`; so the strengthened
statement implies the earlier existential form. -/
theorem z6_embedding_of_le_iff (g : H)
    (h : ∀ p q : Fin 3 × Fin 2, z6Landmarks g p ≤ z6Landmarks g q ↔ p ≤ q) :
    Function.Injective (z6Landmarks g) ∧ Nonempty ((Fin 3 × Fin 2) ↪o H) :=
  ⟨(OrderEmbedding.ofMapLEIff (z6Landmarks g) h).injective,
    ⟨OrderEmbedding.ofMapLEIff (z6Landmarks g) h⟩⟩
