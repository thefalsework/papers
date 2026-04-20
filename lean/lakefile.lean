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
  -- No Lean files yet.
