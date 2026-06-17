/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# Accumulation operator `D₁₂` on `ℤ/12` — kernel-05 operation (A)

Paper 3 § 4 and `music-kernel-05-z12z-cycle.md` distinguish **translation**
`T₁₂(Y) = Y + 7` (operation B, kernel-checked in `MusicKernelZMod12.lean`)
from **accumulation** `D₁₂(Y) = Y ∪ (Y + 7)` (operation A).  The LLM draft
erroneously claimed `D₁₂^12 = id`; the corrected claim is that `D₁₂` *saturates*
non-empty sets to all of `ℤ/12`, with fixed points exactly `∅` and `ℤ/12`.

Finite statements on `Finset (ZMod 12)` are discharged by `native_decide`.
-/
import Mathlib.Data.ZMod.Basic
import Mathlib.Data.Finset.Basic
import FalseWorkPapers.Examples.MusicKernelZMod12

namespace FalseWork.MusicKernel

open Finset

/-- **Accumulation** along the circle of fifths: `D₁₂(S) = S ∪ (S + 7)`. -/
def D12 (S : Finset (ZMod 12)) : Finset (ZMod 12) :=
  S ∪ S.image (· + (7 : ZMod 12))

theorem D12_empty : D12 (∅ : Finset (ZMod 12)) = ∅ := by
  simp [D12]

theorem D12_univ : D12 (Finset.univ : Finset (ZMod 12)) = Finset.univ := by
  simp [D12]

/-- Iterating `D₁₂` twelve times on `{0}` saturates to the whole group. -/
theorem D12_twelve_singleton_zero :
    D12^[12] ({0} : Finset (ZMod 12)) = Finset.univ := by
  native_decide

/-- **`D₁₂^12 ≠ id` on `{0}`** — the corrected refutation of the LLM draft. -/
theorem D12_twelve_not_id_on_singleton :
    D12^[12] ({0} : Finset (ZMod 12)) ≠ ({0} : Finset (ZMod 12)) := by
  native_decide

/-- Fixed points of `D₁₂` are exactly `∅` and `ℤ/12`. -/
theorem D12_fix_forward :
    ∀ S : Finset (ZMod 12), D12 S = S → S = ∅ ∨ S = Finset.univ := by
  native_decide

theorem D12_fix_backward :
    ∀ S : Finset (ZMod 12), S = ∅ ∨ S = Finset.univ → D12 S = S := by
  intro S h
  rcases h with rfl | rfl
  · exact D12_empty
  · exact D12_univ

/-- **`Fix(D₁₂) = {∅, ℤ/12}`** (bundled). -/
theorem D12_fix_eq :
    (∀ S : Finset (ZMod 12), D12 S = S ↔ S = ∅ ∨ S = Finset.univ) ∧
    D12^[12] ({0} : Finset (ZMod 12)) = Finset.univ ∧
    D12^[12] ({0} : Finset (ZMod 12)) ≠ ({0} : Finset (ZMod 12)) := by
  refine ⟨fun S => ⟨D12_fix_forward S, D12_fix_backward S⟩, ?_⟩
  exact ⟨D12_twelve_singleton_zero, D12_twelve_not_id_on_singleton⟩

end FalseWork.MusicKernel
