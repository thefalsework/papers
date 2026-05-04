(* ::Package:: *)

(* ============================================================
   Structural Core: Wolfram, A New Kind of Science (2002)
   ------------------------------------------------------------
   Domain: computational_science
   Kernel: KernelTheConditionalBranch
   Comma:  CommaRice

   Refined analysis: this core treats visual and diagrammatic
   presentation as primary evidentiary substance, not as
   illustration of an already-complete verbal argument. The
   space-time diagrams in NKS are not ancillary to the claims;
   they are the claims, in the form the claims must take given
   computational irreducibility. (This responds to Ellynne Dec's
   May 3, 2026 feedback.)
   ============================================================ *)

NKSCore = MakeCore[
  "Id"     -> "wolfram-new-kind-of-science",
  "Title"  -> "A New Kind of Science",
  "Author" -> "Stephen Wolfram",
  "Year"   -> 2002,
  "Domain" -> "computational_science",
  "Kernel" -> KernelTheConditionalBranch,

  "Mechanisms" -> <|

    "systematic_rule_enumeration" -> MakeMechanism[
      "Id"            -> "systematic_rule_enumeration",
      "Kernel"        -> KernelTheConditionalBranch,
      "Type"          -> "GenerativeIteration",
      "Domain"        -> "computational_science",
      "Description"   ->
        "Exhaustive enumeration of simple rules within a bounded " <>
        "parameter space (e.g., the 256 elementary cellular automata, " <>
        "the 2-state 3-symbol Turing machines, etc.). The enumeration " <>
        "is generative, not illustrative: it surfaces classes of " <>
        "behaviour that no analytic shortcut would reach.",
      "Compatibility" -> {
        "bounded_parameter_space",
        "rule_to_behaviour_mapping",
        "spacetime_diagram_as_primary_evidence"
      },
      "CompositionRules" -> <|
        "bounded_parameter_space" ->
          "EmergentProperty[four_class_behaviour_taxonomy]",
        "rule_to_behaviour_mapping" ->
          "EmergentProperty[principle_of_computational_equivalence]"
      |>,
      "RemovalSignature" ->
        StandardRemovalSignature["systematic_rule_enumeration"],
      "TransferConditions" -> StandardTransferConditions[],
      "FailureMode" -> MakeFailureMode[
        "Id"          -> "loss_of_emergent_class_taxonomy",
        "TriggeredBy" -> {"removal_of_systematic_rule_enumeration"},
        "Signature"   ->
          "behaviour_classes_become_invisible; only_individual_results_remain"
      ]
    ],

    "rule_to_behaviour_mapping" -> MakeMechanism[
      "Id"            -> "rule_to_behaviour_mapping",
      "Kernel"        -> KernelTheConditionalBranch,
      "Type"          -> "DiscriminationOperation",
      "Domain"        -> "computational_science",
      "Description"   ->
        "The operation that distinguishes rule-classes (Class 1 " <>
        "fixed-point, Class 2 periodic, Class 3 chaotic, Class 4 " <>
        "complex) by inspection of their computational dynamics. " <>
        "This discrimination is irreducible: there is no analytic " <>
        "shortcut from rule to class; execution is required.",
      "Compatibility" -> {
        "bounded_parameter_space",
        "spacetime_diagram_as_primary_evidence",
        "systematic_rule_enumeration"
      },
      "CompositionRules" -> <|
        "spacetime_diagram_as_primary_evidence" ->
          "EmergentProperty[behaviour_class_visible_only_in_diagram]"
      |>,
      "RemovalSignature" ->
        StandardRemovalSignature["rule_to_behaviour_mapping"],
      "TransferConditions" -> StandardTransferConditions[],
      "FailureMode" -> MakeFailureMode[
        "Id"          -> "collapse_of_four_class_discrimination",
        "TriggeredBy" -> {"removal_of_rule_to_behaviour_mapping"},
        "Signature"   ->
          "rules_become_indistinguishable_at_the_inspection_level"
      ]
    ],

    "spacetime_diagram_as_primary_evidence" -> MakeMechanism[
      "Id"            -> "spacetime_diagram_as_primary_evidence",
      "Kernel"        -> KernelTheConditionalBranch,
      "Type"          -> "VisualEvidentiaryOperation",
      "Domain"        -> "computational_science",
      "Description"   ->
        "The space-time diagram is not an illustration of a verbal " <>
        "argument; it is the argument's primary evidentiary form. " <>
        "Because rule-class membership is computationally irreducible, " <>
        "the diagram is the only practical access to the underlying " <>
        "claim. Removing the diagrams does not weaken the verbal " <>
        "argument; it eliminates the argument entirely.",
      "Compatibility" -> {
        "rule_to_behaviour_mapping",
        "synchronous_time_stepping",
        "systematic_rule_enumeration"
      },
      "CompositionRules" -> <||>,
      "RemovalSignature" ->
        StandardRemovalSignature["spacetime_diagram_as_primary_evidence"],
      "TransferConditions" -> StandardTransferConditions[],
      "FailureMode" -> MakeFailureMode[
        "Id"          -> "argument_loses_evidentiary_substrate",
        "TriggeredBy" -> {"removal_of_spacetime_diagram_as_primary_evidence"},
        "Signature"   ->
          "verbal_claims_become_unsupportable; the_book_collapses_to_assertions"
      ]
    ],

    "synchronous_time_stepping" -> MakeMechanism[
      "Id"            -> "synchronous_time_stepping",
      "Kernel"        -> KernelTheConditionalBranch,
      "Type"          -> "GenerativeIteration",
      "Domain"        -> "computational_science",
      "Description"   ->
        "All cells of a cellular automaton update simultaneously at " <>
        "each time step. This synchrony is what makes the space-time " <>
        "diagram coherent and what enforces the discrete dynamical " <>
        "regime within which class membership is defined.",
      "Compatibility" -> {
        "bounded_parameter_space",
        "spacetime_diagram_as_primary_evidence"
      },
      "CompositionRules" -> <||>,
      "RemovalSignature" ->
        StandardRemovalSignature["synchronous_time_stepping"],
      "TransferConditions" -> StandardTransferConditions[],
      "FailureMode" -> MakeFailureMode[
        "Id"          -> "loss_of_discrete_dynamical_regime",
        "TriggeredBy" -> {"removal_of_synchronous_time_stepping"},
        "Signature"   ->
          "asynchronous_or_continuous_dynamics_invalidate_class_taxonomy"
      ]
    ]

  |>,

  "Constraints" -> <|

    "bounded_parameter_space" -> MakeConstraint[
      "Id"   -> "bounded_parameter_space",
      "Type" -> "DependencyStatement",
      "DependedOnBy" -> {
        "systematic_rule_enumeration",
        "rule_to_behaviour_mapping",
        "synchronous_time_stepping"
      },
      "Description" ->
        "The rule-space (e.g., the 256 elementary CAs) is finite " <>
        "and bounded. All other mechanisms presuppose this " <>
        "bounding to make exhaustive enumeration tractable."
    ]

  |>,

  "FailureModes" -> {
    MakeFailureMode[
      "Id"          -> "infinite_rule_spaces_make_enumeration_meaningless",
      "TriggeredBy" -> {"unbounded_parameter_space"},
      "Signature"   ->
        "exhaustive_enumeration_loses_evidentiary_force"
    ],
    MakeFailureMode[
      "Id"          -> "ai_style_text_centric_summary_misses_the_evidence",
      "TriggeredBy" -> {"reading_NKS_as_a_verbal_argument_with_supporting_images"},
      "Signature"   ->
        "the_book_appears_to_say_less_than_it_says; the_diagrams_carry_what_words_cannot"
    ]
  },

  "GenerativePrinciple" ->
    "Exhaustive enumeration over a bounded rule-space, executed " <>
    "synchronously and visualised as space-time diagrams, surfaces " <>
    "behavioural classes that are not analytically reducible. The " <>
    "diagrams are the primary evidence for the principle of " <>
    "computational equivalence; the verbal argument summarises " <>
    "what the diagrams show, not the other way around.",

  "IndependentCorroboration" -> {
    "Wolfram_2002_NKS_full_corpus",
    "Rice_1953_undecidability_of_non_trivial_program_properties",
    "principle_of_computational_equivalence_as_organising_claim"
  }
];


(* Validation at load time *)
If[WellFormedCoreQ[NKSCore],
  Print["NKS core loaded: ",
        Length @ field[NKSCore, "Mechanisms"], " mechanisms, ",
        Length @ field[NKSCore, "Constraints"], " constraints."],
  Print["WARNING: NKS core failed well-formedness check."]
];
