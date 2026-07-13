import Lake
open Lake DSL

/-!
# FalseWork Papers — Lean 4 formalization

Placeholder Lake project for the FalseWork Papers repository.

The primary target is the music-kernel endofunctor formalization from
Paper 3 § 4 (see `README.md` in this directory). As of the initial
scaffold there are no Lean files yet; this project exists to give
contributors a frictionless starting point.

To start contributing, add your Lean files under `FalseWorkPapers/`
and run `lake build`.
-/

package «falsework-papers» where
  -- Additional package configuration goes here.

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git"

@[default_target]
lean_lib «FalseWorkPapers» where
  -- Additional library configuration goes here.

/-- Mathlib-only statements of the ordinary-elements preprint's principal
theorems, for verification with `leanprover/comparator` (see `config.json`
and the "Verifying with comparator" section of `README.md`). -/
lean_lib «Challenge» where
  -- Single root module `Challenge.lean`.

/-- The solution side of the comparator pair: imports the project code
(via `FalseWorkPapers/Examples/ChallengeBridge.lean`) that proves the
exact statements of `Challenge.lean`. -/
lean_lib «Solution» where
  -- Single root module `Solution.lean`.
