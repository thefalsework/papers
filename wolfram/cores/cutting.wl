(* ::Package:: *)

(* ============================================================
   Structural Core: Cutting, "Perceptual Processes in Film
   Viewing" / F1 Component Processes (2005)
   ------------------------------------------------------------
   Domain: film
   Kernel: KernelTheCut
   Comma:  CommaShotBoundary

   Independent corroboration: Cutting independently uses the
   word "primitive" for the kernel concept; three of four
   FalseWork kernel criteria are satisfied by his framework.
   The terminological convergence between two scholars working
   in different domains without communication is the substantive
   evidence.
   ============================================================ *)

CuttingCore = MakeCore[
  "Id"     -> "cutting-six-component-processes",
  "Title"  -> "Perceptual Processes in Film Viewing (Six Component Processes)",
  "Author" -> "James E. Cutting",
  "Year"   -> 2005,
  "Domain" -> "film",
  "Kernel" -> KernelTheCut,

  "Mechanisms" -> <|

    "cut_dissolve_discrimination" -> MakeMechanism[
      "Id"            -> "cut_dissolve_discrimination",
      "Kernel"        -> KernelTheCut,
      "Type"          -> "DiscriminationOperation",
      "Domain"        -> "film",
      "Description"   ->
        "The perceptual operation that distinguishes a hard cut " <>
        "from a dissolve from a continuous shot. Cutting names " <>
        "this construct a 'primitive': a perceptual atom not " <>
        "decomposable into the constituent shots it separates.",
      "Compatibility" -> {
        "bounded_temporal_window",
        "shot_continuity_hierarchy",
        "viewer_perceptual_threshold"
      },
      "CompositionRules" -> <|
        "bounded_temporal_window" ->
          "EmergentProperty[shot_boundary_three_way_classification]",
        "shot_continuity_hierarchy" ->
          "EmergentProperty[narrative_segmentation]"
      |>,
      "RemovalSignature" ->
        StandardRemovalSignature["cut_dissolve_discrimination"],
      "TransferConditions" -> StandardTransferConditions[],
      "FailureMode" -> MakeFailureMode[
        "Id"          -> "loss_of_perceptual_primitive_at_shot_boundary",
        "TriggeredBy" -> {"removal_of_cut_dissolve_discrimination"},
        "Signature"   ->
          "shot_boundaries_become_continuous_temporal_displacements"
      ]
    ],

    "shot_continuity_hierarchy" -> MakeMechanism[
      "Id"            -> "shot_continuity_hierarchy",
      "Kernel"        -> KernelTheCut,
      "Type"          -> "HierarchyOperation",
      "Domain"        -> "film",
      "Description"   ->
        "Continuity-of-action, continuity-of-space, and " <>
        "continuity-of-time arrange shot pairs in a hierarchy of " <>
        "perceived narrative coherence. This hierarchy is what " <>
        "makes some cuts feel jarring and others invisible.",
      "Compatibility" -> {
        "cut_dissolve_discrimination",
        "bounded_temporal_window"
      },
      "CompositionRules" -> <||>,
      "RemovalSignature" ->
        StandardRemovalSignature["shot_continuity_hierarchy"],
      "TransferConditions" -> StandardTransferConditions[],
      "FailureMode" -> MakeFailureMode[
        "Id"          -> "flattening_of_continuity_gradient",
        "TriggeredBy" -> {"removal_of_shot_continuity_hierarchy"},
        "Signature"   ->
          "all_shot_boundaries_perceived_as_equally_disruptive"
      ]
    ],

    "synchronous_temporal_segmentation" -> MakeMechanism[
      "Id"            -> "synchronous_temporal_segmentation",
      "Kernel"        -> KernelTheCut,
      "Type"          -> "GenerativeIteration",
      "Domain"        -> "film",
      "Description"   ->
        "Successive application of shot-boundary demarcation " <>
        "produces the temporal scaffold of a film. Each iteration " <>
        "generates a new perceptual primitive that the viewer must " <>
        "integrate; the iteration cannot reduce to a continuous " <>
        "function because the boundaries are categorical.",
      "Compatibility" -> {
        "cut_dissolve_discrimination",
        "bounded_temporal_window"
      },
      "CompositionRules" -> <|
        "bounded_temporal_window" ->
          "EmergentProperty[discrete_temporal_grammar]"
      |>,
      "RemovalSignature" ->
        StandardRemovalSignature["synchronous_temporal_segmentation"],
      "TransferConditions" -> StandardTransferConditions[],
      "FailureMode" -> MakeFailureMode[
        "Id"          -> "collapse_to_continuous_unedited_take",
        "TriggeredBy" -> {"removal_of_synchronous_temporal_segmentation"},
        "Signature"   ->
          "no_discrete_temporal_grammar_remains; the_long_take_limit"
      ]
    ]

  |>,

  "Constraints" -> <|

    "bounded_temporal_window" -> MakeConstraint[
      "Id"   -> "bounded_temporal_window",
      "Type" -> "DependencyStatement",
      "DependedOnBy" -> {
        "cut_dissolve_discrimination",
        "shot_continuity_hierarchy",
        "synchronous_temporal_segmentation"
      },
      "Description" ->
        "Film perception operates within a bounded temporal window " <>
        "(roughly 50 ms to several seconds for shot-level effects). " <>
        "All other mechanisms presuppose this bounding."
    ]

  |>,

  "FailureModes" -> {
    MakeFailureMode[
      "Id"          -> "long_take_aesthetics_eliminate_cut_primitive",
      "TriggeredBy" -> {"adoption_of_unbroken_long_take_as_organising_form"},
      "Signature"   ->
        "the_perceptual_primitive_at_the_shot_boundary_loses_its_basis"
    ]
  },

  "GenerativePrinciple" ->
    "Successive shot-boundary demarcations partition the film's " <>
    "temporal field into perceptual primitives around an irreducible " <>
    "discontinuity at each cut; the cut/dissolve discrimination is " <>
    "the operation that makes the primitive perceptually visible.",

  "IndependentCorroboration" -> {
    "Cutting_2005_perceptual_processes_in_film_viewing",
    "Cutting_terminological_convergence_on_primitive",
    "three_of_four_kernel_criteria_satisfied_independently"
  }
];


(* Validation at load time *)
If[WellFormedCoreQ[CuttingCore],
  Print["Cutting core loaded: ",
        Length @ field[CuttingCore, "Mechanisms"], " mechanisms, ",
        Length @ field[CuttingCore, "Constraints"], " constraints."],
  Print["WARNING: Cutting core failed well-formedness check."]
];
