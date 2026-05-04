(* ::Package:: *)

(* ============================================================
   FalseWork Kernels and Commas
   ------------------------------------------------------------
   The four kernels and their commas used by the prototype
   corpus. Each kernel is anchored in a specific domain with a
   specific irreducibility witness drawn from independent
   scholarly material.

   References:
     The Fifth        - Pythagorean comma; Baker 1966; Tymoczko 2011
     The Cut          - Shot-boundary undecidability; Cutting 2005
     The Conditional  - Rice 1953; computational irreducibility
       Branch
     The Methodology  - Self-application paradox; Brink 2026 (this
                        prototype)
   ============================================================ *)


(* ============================================================
   COMMAS

   Each comma has a Slug, a Kernel reference, an
   IrreducibilityKind (the structural signature used by
   CommaShape), and a FormalGround.
   ============================================================ *)

CommaPythagorean = MakeComma[
  "Slug"               -> "pythagorean-comma",
  "Type"               -> "ArithmeticIncompleteness",
  "IrreducibilityKind" -> "BoundaryDiscriminationAtLimit",
  "FormalGround" -> {
    "fundamental_theorem_of_arithmetic",
    "Baker_1966_linear_forms_in_logarithms_of_algebraic_numbers",
    "3^12_does_not_equal_2^19"
  },
  "ParaphrasedClaim" ->
    "Twelve perfect fifths fail to close to seven octaves; the gap " <>
    "is mathematically precise (3^12 / 2^19) and quantitatively " <>
    "bounded by Baker's theorem. No tuning system eliminates it; " <>
    "every tuning system is a decision about where to place it."
];


CommaShotBoundary = MakeComma[
  "Slug"               -> "shot-boundary-comma",
  "Type"               -> "PerceptualDiscontinuity",
  "IrreducibilityKind" -> "BoundaryDiscriminationAtLimit",
  "FormalGround" -> {
    "Cutting_2005_six_component_processes",
    "Cutting_perceptual_primitive_three_of_four_kernel_criteria"
  },
  "ParaphrasedClaim" ->
    "The cut/dissolve discrimination defines a perceptual primitive " <>
    "that cannot be reduced to either of its constituent shots. " <>
    "Independent corroboration: Cutting names this same construct " <>
    "'primitive' without reference to FalseWork; three of four " <>
    "kernel criteria are met by his framework."
];


CommaRice = MakeComma[
  "Slug"               -> "rice-theorem-comma",
  "Type"               -> "ComputationalUndecidability",
  "IrreducibilityKind" -> "BehaviouralPredicateUndecidability",
  "FormalGround" -> {
    "Rice_1953_classes_of_recursively_enumerable_sets_undecidable",
    "Wolfram_principle_of_computational_equivalence"
  },
  "ParaphrasedClaim" ->
    "No non-trivial behavioural property of programs is decidable " <>
    "by inspection of source. Rule-to-behaviour mapping requires " <>
    "execution; no shortcut exists. Computational irreducibility " <>
    "is the same comma at the level of dynamics."
];


(* The methodology comma's IrreducibilityKind is its own structural
   shape, not "BoundaryDiscriminationAtLimit". The methodology's
   irreducibility is the gap that opens when a procedural pipeline is
   asked to non-trivially analyse itself: naive recursion pattern-
   matches the title and re-analyses the original object rather than
   the procedure. That is a self-reference gap, not a boundary
   phenomenon at a generative field's limit. Keeping it distinct
   prevents the methodology from spuriously cluster-matching the
   Tymoczko/Cutting shape under cross-domain transfer queries. *)
CommaMethodologySelfReference = MakeComma[
  "Slug"               -> "methodology-self-reference-comma",
  "Type"               -> "RecursiveSelfApplicationGap",
  "IrreducibilityKind" -> "RecursiveSelfApplicationGap",
  "FormalGround" -> {
    "Brink_2026_recursive_self_analysis_jan_4",
    "abstraction_to_domain_neutral_language_required"
  },
  "ParaphrasedClaim" ->
    "The methodology's seven-stage architecture cannot non-trivially " <>
    "analyse itself without abstraction to domain-neutral language. " <>
    "The naive recursion pattern-matches the title and re-analyses " <>
    "the original object instead of the methodology. The gap " <>
    "between self-description and self-application is the comma."
];


(* ============================================================
   KERNELS

   Each kernel carries a reference to its Comma. The Comma is
   the irreducibility witness that makes the kernel substantive
   rather than merely descriptive.
   ============================================================ *)

KernelTheFifth = MakeKernel[
  "Slug"      -> "the-fifth",
  "Domain"    -> "music",
  "Operation" -> "iterated_perfect_fifth_generation",
  "Comma"     -> CommaPythagorean,
  "FormalGround" -> {
    "fundamental_theorem_of_arithmetic",
    "Baker_1966"
  },
  "FieldTopology" ->
    {"Substrate", "Distribution", "Exploitation",
     "Commitment", "Refusal"},
  "PaperReference" -> "Paper 1 v11.6 sec. 3.1"
];


KernelTheCut = MakeKernel[
  "Slug"      -> "the-cut",
  "Domain"    -> "film",
  "Operation" -> "shot_boundary_demarcation",
  "Comma"     -> CommaShotBoundary,
  "FormalGround" -> {
    "Cutting_2005_perceptual_processes_in_film_viewing"
  },
  "FieldTopology" ->
    {"Substrate", "Distribution", "Exploitation",
     "Commitment", "Refusal"},
  "PaperReference" -> "Paper 1 v11.6 sec. 3.3"
];


KernelTheConditionalBranch = MakeKernel[
  "Slug"      -> "the-conditional-branch",
  "Domain"    -> "computational_science",
  "Operation" -> "rule_to_behaviour_mapping",
  "Comma"     -> CommaRice,
  "FormalGround" -> {
    "Rice_1953",
    "Wolfram_principle_of_computational_equivalence"
  },
  "FieldTopology" ->
    {"Substrate", "Distribution", "Exploitation",
     "Commitment", "Refusal"},
  "PaperReference" -> "Paper 1 v11.6 sec. 3.4"
];


KernelOfMethodology = MakeKernel[
  "Slug"      -> "the-methodology",
  "Domain"    -> "self_referential_analysis",
  "Operation" -> "staged_structural_extraction",
  "Comma"     -> CommaMethodologySelfReference,
  "FormalGround" -> {
    "Brink_2026_jan_4_recursive_self_analysis_under_abstraction"
  },
  "FieldTopology" ->
    {"Substrate", "Distribution", "Exploitation",
     "Commitment", "Refusal"},
  "PaperReference" -> "(meta-kernel; not in Paper 1; this prototype)"
];


(* ============================================================
   QUICK SANITY CHECKS

   At load time, validate each kernel and comma.
   ============================================================ *)

Module[{kernels, commas, allValid},
  kernels = {KernelTheFifth, KernelTheCut, KernelTheConditionalBranch,
             KernelOfMethodology};
  commas = {CommaPythagorean, CommaShotBoundary, CommaRice,
            CommaMethodologySelfReference};

  allValid = AllTrue[kernels, KernelQ] && AllTrue[commas, CommaQ];
  If[allValid,
    Print["Kernels and commas loaded: ", Length[kernels], " kernels, ",
          Length[commas], " commas. All well-formed."],
    Print["WARNING: kernel or comma validation failed at load time."]
  ]
];
