import Challenge

/-!
Kernel-checked sanity lemmas for the statement-matches-paper review of
`Challenge.lean` (not part of the library; scratch file).
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
example (g x : H) (h : HeytingGeneratedBy g x) : HeytingGeneratedBy g xᶜ := by
  rw [← himp_bot]
  exact .himp h .bot

/-- Check D: the E-region existential in `FourRegionsInhabited` forces its
witness non-⊥ automatically, so the missing `x ≠ ⊥` guard there is sound. -/
example (a x : H) (h : ¬ x ≤ a) : x ≠ ⊥ := fun hx => h (hx ▸ bot_le)

/-- Check D': likewise the D-region existential (x ⊓ a ≠ ⊥ forces x ≠ ⊥). -/
example (a x : H) (h : x ⊓ a ≠ ⊥) : x ≠ ⊥ := fun hx => h (by simp [hx])

/-- Check E: the literal `(1, 0)` in `twelve_unique_kernel` denotes the point
with numeric coordinates (1, 0) — i.e. 2-adic valuation 1, 3-adic 0 — the
divisor 2, not some wrapped-around `OfNat` artifact. -/
example : ((1, 0) : Fin 3 × Fin 2).1.val = 1 ∧ ((1, 0) : Fin 3 × Fin 2).2.val = 0 := by
  decide
