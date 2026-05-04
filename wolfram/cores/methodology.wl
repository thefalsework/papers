(* ::Package:: *)

(* ============================================================
   Structural Core: The FalseWork Methodology Itself
   ------------------------------------------------------------
   Domain: self_referential_analysis
   Kernel: KernelOfMethodology
   Comma:  CommaMethodologySelfReference

   This core represents the methodology as a corpus item, in the
   same schema as Tymoczko, Cutting, and NKS. The reduction is
   the abstraction-to-domain-neutral-language operation Brink
   used in January 2026 to force genuine self-application of the
   pipeline. Without that abstraction, the system pattern-matches
   the title and re-analyses the original object instead of the
   methodology.

   The interesting query 4 result is that the algebra, run on
   this core via the same operations it uses on the other three,
   re-derives the failure modes that were originally surfaced
   interpretively in the Jan 4, 2026 reply to Stephen Wolfram:
     - variety_in_uniformity
     - transparency_as_opacity
     - methodology_blind_spot

   The recursive self-application is not a special-case operation;
   it is the same algebra applied to the methodology's own core.
   ============================================================ *)

MethodologyCore = MakeCore[
  "Id"     -> "falsework-methodology-self-core",
  "Title"  -> "FalseWork Methodology (self-applied core)",
  "Author" -> "Chris Brink",
  "Year"   -> 2026,
  "Domain" -> "self_referential_analysis",
  "Kernel" -> KernelOfMethodology,

  "Mechanisms" -> <|

    "staged_sequential_processing" -> MakeMechanism[
      "Id"            -> "staged_sequential_processing",
      "Kernel"        -> KernelOfMethodology,
      "Type"          -> "GenerativeIteration",
      "Domain"        -> "self_referential_analysis",
      "Description"   ->
        "Seven-stage sequential pipeline that decomposes any input " <>
        "work into structural fields, mechanisms, constraints, " <>
        "failure modes, and a generative principle. The staging is " <>
        "fixed: every analysis follows the same seven steps in the " <>
        "same order regardless of domain.",
      "Compatibility" -> {
        "procedural_isomorphism",
        "prompt_output_pairing",
        "complete_documentation"
      },
      "CompositionRules" -> <|
        "procedural_isomorphism" ->
          "EmergentProperty[uniform_output_shape_across_all_domains]"
      |>,
      "RemovalSignature" ->
        StandardRemovalSignature["staged_sequential_processing"],
      "TransferConditions" -> StandardTransferConditions[],
      "FailureMode" -> MakeFailureMode[
        "Id"          -> "loss_of_pipeline_coherence",
        "TriggeredBy" -> {"removal_of_staged_sequential_processing"},
        "Signature"   ->
          "no_consistent_output_schema_remains; analyses_diverge_in_form"
      ]
    ],

    "procedural_isomorphism" -> MakeMechanism[
      "Id"            -> "procedural_isomorphism",
      "Kernel"        -> KernelOfMethodology,
      "Type"          -> "HierarchyOperation",
      "Domain"        -> "self_referential_analysis",
      "Description"   ->
        "Every output follows the same procedural shape: same field " <>
        "names, same prompt-template structure, same staged " <>
        "sequence. This is what makes structural cores comparable " <>
        "across domains; it is also what enforces the methodology's " <>
        "characteristic uniformity in spite of nominal variation.",
      "Compatibility" -> {
        "staged_sequential_processing",
        "complete_documentation",
        "temperature_graduation"
      },
      "CompositionRules" -> <|
        "temperature_graduation" ->
          "EmergentProperty[variety_within_uniformity_paradox]"
      |>,
      "RemovalSignature" ->
        StandardRemovalSignature["procedural_isomorphism"],
      "TransferConditions" -> StandardTransferConditions[],
      "FailureMode" -> MakeFailureMode[
        "Id"          -> "variety_in_uniformity",
        "TriggeredBy" -> {
          "co_presence_with_temperature_graduation",
          "removal_of_procedural_isomorphism"
        },
        "Signature"   ->
          "outputs_perform_variety_within_suffocating_uniformity; the_temperature_parameter_promises_creative_freedom_that_the_isomorphic_shape_cannot_deliver"
      ]
    ],

    "prompt_output_pairing" -> MakeMechanism[
      "Id"            -> "prompt_output_pairing",
      "Kernel"        -> KernelOfMethodology,
      "Type"          -> "DiscriminationOperation",
      "Domain"        -> "self_referential_analysis",
      "Description"   ->
        "Each stage is a rigid prompt-output pairing: one prompt " <>
        "produces one output of one shape. The discrimination is " <>
        "between in-scope and out-of-scope content; out-of-scope " <>
        "content is silently discarded.",
      "Compatibility" -> {
        "staged_sequential_processing",
        "procedural_isomorphism"
      },
      "CompositionRules" -> <||>,
      "RemovalSignature" ->
        StandardRemovalSignature["prompt_output_pairing"],
      "TransferConditions" -> StandardTransferConditions[],
      "FailureMode" -> MakeFailureMode[
        "Id"          -> "loss_of_input_output_discipline",
        "TriggeredBy" -> {"removal_of_prompt_output_pairing"},
        "Signature"   ->
          "outputs_become_unbounded; pipeline_loses_termination_property"
      ]
    ],

    "temperature_graduation" -> MakeMechanism[
      "Id"            -> "temperature_graduation",
      "Kernel"        -> KernelOfMethodology,
      "Type"          -> "GenerativeIteration",
      "Domain"        -> "self_referential_analysis",
      "Description"   ->
        "Stage-wise variation of the LLM temperature parameter, " <>
        "promising increasing creative latitude across the pipeline. " <>
        "Operates within the constraints of procedural isomorphism: " <>
        "the variation is real but bounded by the fixed output shape.",
      "Compatibility" -> {
        "procedural_isomorphism",
        "staged_sequential_processing"
      },
      "CompositionRules" -> <|
        "procedural_isomorphism" ->
          "EmergentProperty[bounded_creative_latitude_within_fixed_shape]"
      |>,
      "RemovalSignature" ->
        StandardRemovalSignature["temperature_graduation"],
      "TransferConditions" -> StandardTransferConditions[],
      "FailureMode" -> MakeFailureMode[
        "Id"          -> "variety_in_uniformity",
        "TriggeredBy" -> {
          "co_presence_with_procedural_isomorphism",
          "removal_of_temperature_graduation"
        },
        "Signature"   ->
          "either_no_variation_at_all_or_the_compositional_paradox_with_isomorphism"
      ]
    ],

    "complete_documentation" -> MakeMechanism[
      "Id"            -> "complete_documentation",
      "Kernel"        -> KernelOfMethodology,
      "Type"          -> "VisualEvidentiaryOperation",
      "Domain"        -> "self_referential_analysis",
      "Description"   ->
        "Every stage's prompt, output, and intermediate state is " <>
        "logged and surfaced. Procedural transparency is the " <>
        "design value; the resulting apparatus is dense.",
      "Compatibility" -> {
        "procedural_isomorphism",
        "staged_sequential_processing"
      },
      "CompositionRules" -> <|
        "procedural_isomorphism" ->
          "EmergentProperty[transparency_as_opacity_paradox]"
      |>,
      "RemovalSignature" ->
        StandardRemovalSignature["complete_documentation"],
      "TransferConditions" -> StandardTransferConditions[],
      "FailureMode" -> MakeFailureMode[
        "Id"          -> "transparency_as_opacity",
        "TriggeredBy" -> {
          "co_presence_with_procedural_isomorphism",
          "saturation_of_procedural_documentation"
        },
        "Signature"   ->
          "complete_documentation_creates_such_dense_procedural_apparatus_that_the_original_analysed_work_disappears_beneath_layers_of_meta_commentary"
      ]
    ],

    "external_only_analysis" -> MakeMechanism[
      "Id"            -> "external_only_analysis",
      "Kernel"        -> KernelOfMethodology,
      "Type"          -> "DiscriminationOperation",
      "Domain"        -> "self_referential_analysis",
      "Description"   ->
        "The methodology analyses works external to itself; it does " <>
        "not natively analyse its own structural techniques. " <>
        "Without abstraction to domain-neutral language, the " <>
        "system pattern-matches the title and re-analyses the " <>
        "original object instead of the methodology.",
      "Compatibility" -> {
        "staged_sequential_processing",
        "prompt_output_pairing"
      },
      "CompositionRules" -> <||>,
      "RemovalSignature" ->
        StandardRemovalSignature["external_only_analysis"],
      "TransferConditions" -> StandardTransferConditions[],
      "FailureMode" -> MakeFailureMode[
        "Id"          -> "methodology_blind_spot",
        "TriggeredBy" -> {
          "naive_self_application_without_domain_neutral_abstraction"
        },
        "Signature"   ->
          "the_methodology_analyses_structural_techniques_in_other_works_while_treating_its_own_seven_stage_architecture_as_neutral_rather_than_rhetorical"
      ]
    ]

  |>,

  "Constraints" -> <|

    "bounded_pipeline_depth" -> MakeConstraint[
      "Id"   -> "bounded_pipeline_depth",
      "Type" -> "DependencyStatement",
      "DependedOnBy" -> {
        "staged_sequential_processing",
        "procedural_isomorphism",
        "complete_documentation"
      },
      "Description" ->
        "The pipeline has a fixed maximum depth of seven stages. " <>
        "All other mechanisms presuppose this bounding; without it, " <>
        "the procedural isomorphism would have nothing to enforce."
    ]

  |>,

  "FailureModes" -> {
    (* The compositional failure modes Chris originally surfaced
       interpretively in Jan 4, 2026 are pre-declared here so that
       query 4's output can be checked against the hand-derived
       claims. The interesting demonstration is that the algebra
       re-surfaces them via removal projections, not just by
       retrieving them from this list. *)
    MakeFailureMode[
      "Id"          -> "naive_recursion_pattern_matches_the_title",
      "TriggeredBy" -> {"feeding_a_FalseWork_analysis_back_in_naively"},
      "Signature"   ->
        "the_methodology_treats_the_analysis_as_pointing_to_the_original_object_and_re_analyses_that_object_instead_of_itself"
    ]
  },

  "GenerativePrinciple" ->
    "Staged structural extraction over a bounded pipeline, with " <>
    "procedural isomorphism enforcing comparability across domains. " <>
    "The comma is the methodology's inability to non-trivially " <>
    "self-apply without domain-neutral abstraction; the kernel is " <>
    "the seven-stage operation that is irreducible at its own limit.",

  "IndependentCorroboration" -> {
    "Brink_2026_jan_4_recursive_self_analysis_under_abstraction",
    "agreement_with_Stephen_Wolframs_AI_style_missing_the_point_observation"
  }
];


(* Validation at load time *)
If[WellFormedCoreQ[MethodologyCore],
  Print["Methodology core loaded: ",
        Length @ field[MethodologyCore, "Mechanisms"], " mechanisms, ",
        Length @ field[MethodologyCore, "Constraints"], " constraints."],
  Print["WARNING: Methodology core failed well-formedness check."]
];
