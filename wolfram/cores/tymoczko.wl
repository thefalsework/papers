(* ::Package:: *)

(* ============================================================
   Structural Core: Tymoczko, A Geometry of Music (2011)
   ------------------------------------------------------------
   Domain: music
   Kernel: KernelTheFifth
   Comma:  CommaPythagorean

   Independent corroboration: Tymoczko's voice-leading geometry
   maps a three-way scale-space discrimination onto the same
   distinctions FalseWork derives from Coltrane's three-way scale
   choice in "Giant Steps." Tymoczko's framework was developed
   without reference to FalseWork; the convergence is the
   substantive evidence.
   ============================================================ *)

TymoczkoCore = MakeCore[
  "Id"     -> "tymoczko-geometry-of-music",
  "Title"  -> "A Geometry of Music",
  "Author" -> "Dmitri Tymoczko",
  "Year"   -> 2011,
  "Domain" -> "music",
  "Kernel" -> KernelTheFifth,

  "Mechanisms" -> <|

    "voice_leading_parsimony" -> MakeMechanism[
      "Id"            -> "voice_leading_parsimony",
      "Kernel"        -> KernelTheFifth,
      "Type"          -> "DiscriminationOperation",
      "Domain"        -> "music",
      "Description"   ->
        "Voice-leading parsimony selects scale collections by " <>
        "minimising total displacement of voices between adjacent " <>
        "harmonies; this generates a discrete metric on chord-space " <>
        "that partitions it into kernel regions.",
      "Compatibility" -> {
        "bounded_parameter_space",
        "tonal_hierarchy",
        "iterated_fifth_generation"
      },
      "CompositionRules" -> <|
        "bounded_parameter_space" ->
          "EmergentProperty[three_way_scale_space_discrimination]",
        "tonal_hierarchy" ->
          "EmergentProperty[consonance_dissonance_gradient]"
      |>,
      "RemovalSignature" ->
        StandardRemovalSignature["voice_leading_parsimony"],
      "TransferConditions" -> StandardTransferConditions[],
      "FailureMode" -> MakeFailureMode[
        "Id"          -> "loss_of_three_way_discrimination",
        "TriggeredBy" -> {"removal_of_voice_leading_parsimony"},
        "Signature"   ->
          "scale_space_collapses_to_continuous_metric_with_no_kernel_regions"
      ]
    ],

    "iterated_fifth_generation" -> MakeMechanism[
      "Id"            -> "iterated_fifth_generation",
      "Kernel"        -> KernelTheFifth,
      "Type"          -> "GenerativeIteration",
      "Domain"        -> "music",
      "Description"   ->
        "Successive application of the perfect-fifth interval " <>
        "generates the diatonic-chromatic scaffold; the iteration " <>
        "fails to close, producing the Pythagorean comma.",
      "Compatibility" -> {
        "bounded_parameter_space",
        "voice_leading_parsimony"
      },
      "CompositionRules" -> <|
        "bounded_parameter_space" ->
          "EmergentProperty[twelve_tone_chromatic_scaffold]"
      |>,
      "RemovalSignature" ->
        StandardRemovalSignature["iterated_fifth_generation"],
      "TransferConditions" -> StandardTransferConditions[],
      "FailureMode" -> MakeFailureMode[
        "Id"          -> "loss_of_pythagorean_comma_as_organising_gap",
        "TriggeredBy" -> {"removal_of_iterated_fifth_generation"},
        "Signature"   ->
          "no_irreducibility_witness_remains_in_the_kernel"
      ]
    ],

    "tonal_hierarchy" -> MakeMechanism[
      "Id"            -> "tonal_hierarchy",
      "Kernel"        -> KernelTheFifth,
      "Type"          -> "HierarchyOperation",
      "Domain"        -> "music",
      "Description"   ->
        "Tonal hierarchy assigns priority weights to scale degrees; " <>
        "this enables the Coltrane three-way discrimination by " <>
        "constraining which scale choices are coherent at any given " <>
        "harmonic moment.",
      "Compatibility" -> {
        "voice_leading_parsimony",
        "bounded_parameter_space"
      },
      "CompositionRules" -> <||>,
      "RemovalSignature" -> StandardRemovalSignature["tonal_hierarchy"],
      "TransferConditions" -> StandardTransferConditions[],
      "FailureMode" -> MakeFailureMode[
        "Id"          -> "flattening_of_consonance_gradient",
        "TriggeredBy" -> {"removal_of_tonal_hierarchy"},
        "Signature"   ->
          "all_scale_degrees_equally_weighted; coltrane_discrimination_undefined"
      ]
    ]

  |>,

  "Constraints" -> <|

    "bounded_parameter_space" -> MakeConstraint[
      "Id"   -> "bounded_parameter_space",
      "Type" -> "DependencyStatement",
      "DependedOnBy" -> {
        "voice_leading_parsimony",
        "iterated_fifth_generation",
        "tonal_hierarchy"
      },
      "Description" ->
        "The twelve-tone equal-tempered universe is finite and " <>
        "bounded. All other mechanisms presuppose this bounding."
    ]

  |>,

  "FailureModes" -> {
    MakeFailureMode[
      "Id"          -> "even_temperament_eliminates_kernel_regions",
      "TriggeredBy" -> {"adoption_of_24-tet_or_continuous_microtonal_systems"},
      "Signature"   ->
        "the_three_way_scale_discrimination_loses_its_basis"
    ]
  },

  "GenerativePrinciple" ->
    "Iterated perfect fifths partition scale-space into kernel " <>
    "regions around an irreducible Pythagorean comma; voice-leading " <>
    "parsimony is the metric that makes the partitioning audible.",

  "IndependentCorroboration" -> {
    "Tymoczko_2011_geometry_of_music",
    "Coltrane_giant_steps_three_way_scale_choice_corpus",
    "Baker_1966_quantitative_bound_on_3^12_minus_2^19"
  }
];


(* Validation at load time *)
If[WellFormedCoreQ[TymoczkoCore],
  Print["Tymoczko core loaded: ",
        Length @ field[TymoczkoCore, "Mechanisms"], " mechanisms, ",
        Length @ field[TymoczkoCore, "Constraints"], " constraints."],
  Print["WARNING: Tymoczko core failed well-formedness check."]
];
