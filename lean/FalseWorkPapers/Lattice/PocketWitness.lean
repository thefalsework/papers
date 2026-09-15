/-
Copyright (c) 2026 Chris Brink. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Brink

# Dynamical pockets: the minimal commuting pair

Registered spec: `pocket-study/SPEC.md` (committed 2026-09-15 before
the oracle ran).  A *time step* on a poset is a single added relation;
its action on worlds is the forward closure map cl′.  An observer j_S
is **dynamically compatible** with the step when squint-then-evolve
equals evolve-then-squint: cl′ ∘ j_S = j′_S ∘ cl′.  Yesterday's
`timeStep_not_observer` proved time and observation are different
operations; this file kernel-checks the two facts that make their
*interaction* nontrivial, on the minimal example (the 2-antichain
{a, b} gaining its only edge a < b):

* **P1 (`futureWatcher_commutes`).**  The observer that resolves only
  `b` — the state about to gain a past — commutes with the step.
  Nontrivial dynamical compatibility exists.  (Oracle: every one of
  5,984 surveyed steps admits a nontrivial compatible observer.)

* **P2 (`pastWatcher_not_commutes`).**  The observer that resolves
  only `a` — the state whose futures are being rewired — does not
  commute.  Compatibility is a proper subclass.

Both observers are honest nuclei (`futureWatcher_isNucleus`,
`pastWatcher_isNucleus`), so this is a statement about the classified
observer layer, not about ad-hoc maps.  The maps below are the
general formulas j_S(U) = {x : ↓x ∩ S ⊆ U} and cl′(U) = U ∪ (↓a if
U meets ↑b), specialized by hand to the 2-antichain and recorded in
the docstrings; `decide` checks every case.

Oracle status for the surrounding questions (pocket-study
postscript): the compatible supports formed a lattice (closed under
∪ and ∩) on every surveyed step — conjecture, not yet a theorem; a
candidate closed-form characterization was tested post-hoc and
**failed** (13,863 / 131,320 mismatches), so the characterization is
open.  Nothing in this file depends on either.
-/
import FalseWorkPapers.Lattice.EdgePerturbation

set_option linter.unusedSectionVars false

namespace FalseWork.Lattice

section PocketWitness

attribute [local instance] piDecidableLE

local instance (n : ℕ) : BiheytingAlgebra (Fin (n + 1)) :=
  LinearOrder.toBiheytingAlgebra (Fin (n + 1))

/-- The step map cl′ : D(2-antichain) → D(2-antichain), image in the
chain's down-sets.  General formula cl′(U) = U ∪ (↓a if U ∩ ↑b ≠ ∅);
here ↑b = {b}, ↓a = {a}, so the a-coordinate absorbs the
b-coordinate: cl′(U) = (U_a ⊔ U_b, U_b). -/
def stepMap (U : DAnti) : DAnti := ![U 0 ⊔ U 1, U 1]

/-- j_{b} on D(2-antichain): the observer resolving only `b`.
General formula j_S(U) = {x : ↓x ∩ S ⊆ U}; on the antichain
↓x = {x}, so a is always confused in and b is kept:
j_{b}(U) = (⊤, U_b). -/
def futureWatcher (U : DAnti) : DAnti := ![1, U 1]

/-- j′_{b} on the chain's down-sets: ↓′a = {a} misses S = {b} and
↓′b ∩ S = {b}, so the formula is *the same*: (⊤, V_b). -/
def futureWatcher' (V : DAnti) : DAnti := ![1, V 1]

/-- j_{a} on D(2-antichain): the observer resolving only `a`;
b is always confused in: j_{a}(U) = (U_a, ⊤). -/
def pastWatcher (U : DAnti) : DAnti := ![U 0, 1]

/-- j′_{a} on the chain's down-sets: now ↓′b ∩ {a} = {a}, so both
coordinates ask whether a ∈ V: j′_{a}(V) = (V_a, V_a). -/
def pastWatcher' (V : DAnti) : DAnti := ![V 0, V 0]

/-- Sanity: the step map lands in the chain's down-sets
(`chainFix`), and fixes exactly them. -/
theorem stepMap_lands_in_chain :
    (∀ U : DAnti, chainFix (stepMap U)) ∧
    (∀ U : DAnti, chainFix U → stepMap U = U) := by
  constructor <;> decide

/-- The future-watcher is an honest nucleus (classified observer,
support {b}). -/
theorem futureWatcher_isNucleus : IsNucleus futureWatcher := by
  refine ⟨?_, ?_, ?_⟩ <;> decide

/-- The past-watcher is an honest nucleus (classified observer,
support {a}). -/
theorem pastWatcher_isNucleus : IsNucleus pastWatcher := by
  refine ⟨?_, ?_, ?_⟩ <;> decide

/-- **P1.**  The future-watcher commutes with the time step:
cl′ ∘ j_{b} = j′_{b} ∘ cl′ on every world.  Nontrivial dynamical
compatibility exists — a genuine pocket-of-reducibility condition,
satisfied by a coarse observer on a genuine step. -/
theorem futureWatcher_commutes :
    ∀ U : DAnti, stepMap (futureWatcher U) = futureWatcher' (stepMap U) := by
  decide

/-- **P2.**  The past-watcher does not commute with the time step:
at U = ⊥, squint-then-evolve glues `a` in (the observer confuses ⊥
with {b}, and the step then drags ↓a along), while evolve-then-squint
keeps ⊥.  Compatibility is a proper subclass of observers. -/
theorem pastWatcher_not_commutes :
    ¬ ∀ U : DAnti, stepMap (pastWatcher U) = pastWatcher' (stepMap U) := by
  decide

end PocketWitness

end FalseWork.Lattice
