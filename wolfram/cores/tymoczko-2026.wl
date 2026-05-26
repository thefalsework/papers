(* ::Package:: *)

(* ============================================================
   Structural Core: Tymoczko, "The Concept of Musical Space" (2026)
   ------------------------------------------------------------
   Domain: music
   Kernel: KernelTheFifth
   Comma:  CommaPythagorean

   Independent corroboration (2026 paper, separate from the 2011
   book core in `tymoczko.wl`). The 2026 paper is Tymoczko's
   groupoid-categorical reformulation of transformational music
   theory; it formalises the same kernel-comma structure FalseWork
   identifies, but in a different mathematical category.

   Two parallels are doing the substantive evidential work here:

   (1) Pythagorean comma as winding-number / fundamental-group
       phenomenon. Tymoczko derives the comma from the topology of
       pitch-class space: the fundamental group of the pitch-class
       circle is Z, and the iterated-fifth path C->G->D->...->F# vs.
       C->E->B->...->F# realise different winding numbers, giving
       the same arrow two structurally non-identifiable paths. The
       vertex group Z at every point of his Tonnetz groupoid is the
       algebraic record of that irresolvability. This is the
       topology-side counterpart of FalseWork's Heyting-side
       statement Im(eta) < Im(eta)^cc (the closure-residue is
       strictly larger than the kernel image). Same kernel-comma
       structure; two distinct formalisms; convergent identification
       of the comma as the load-bearing structural fact.

   (2) Four Tonnetzes with same underlying graph and four genuinely
       distinct vertex groups (trivial / Z_3 / Z_7 / Z_21). Same
       morphism substrate, four different distinction structures,
       four different "what counts as a non-trivial loop" claims.
       This is a clean empirical instance of FalseWork's
       architectural claim that the underlying category under-
       determines the partition: the choice of distinction structure
       (which arrows count as equivalent) is the Commitment that
       determines what counts as a Refusal. Tymoczko's enharmonic-
       seam argument (spelling meaningful on scalar Tonnetz, not on
       Cohnian) makes the position-dependence empirically operative.

   One observation Tymoczko makes that FalseWork has NOT engaged
   with formally is the symmetry/interval duality (his Sect. 1 and
   Sect. 7): symmetries act on elements while intervals act on
   attributes, and the same duality recurs as active/passive (in
   physics), action by lifting / action by deck transformations
   (in algebraic topology), left/right actions (in group theory),
   and de dicto/de se (in philosophy of mind). Tymoczko explicitly
   notes the cross-domain parallel but does not theorise it. This
   is recorded here as an open candidate cross-domain invariant
   (see the `cross_domain_duality_signal` field below); it is not
   formalised in the framework and there is no commitment that it
   will be.

   Note on Coltrane: this 2026 paper does NOT itself classify
   Coltrane's three albums against any four-cell partition. The
   prior Coltrane corroboration via Tymoczko's three-way scale-
   space discrimination is recorded against the 2011 book in
   `tymoczko.wl`. The four-position partition's Coltrane test
   remains deferred (see `preprints/four-position-partition/
   music-anchor/feasibility.md` Section 6).
   ============================================================ *)

Tymoczko2026Core = MakeCore[
  "Id"     -> "tymoczko-concept-of-musical-space-2026",
  "Title"  -> "The Concept of Musical Space",
  "Author" -> "Dmitri Tymoczko",
  "Year"   -> 2026,
  "Venue"  -> "Journal of Music Theory 70(1)",
  "Domain" -> "music",
  "Kernel" -> KernelTheFifth,

  "Mechanisms" -> <|

    "groupoid_event_structure" -> MakeMechanism[
      "Id"            -> "groupoid_event_structure",
      "Kernel"        -> KernelTheFifth,
      "Type"          -> "EquivalenceClassConstruction",
      "Domain"        -> "music",
      "Description"   ->
        "Musical events are equivalence classes of paths (arrows) " <>
        "in a groupoid, not paths themselves. The same arrow X->Y " <>
        "can be realised by many distinct paths that compose to it; " <>
        "the comma is precisely the structural irreducibility of " <>
        "those paths under the groupoid's compositional algebra. " <>
        "The Pythagorean comma is the canonical case: C->F# via six " <>
        "clockwise fifths and C->Gb via six counterclockwise fifths " <>
        "compose to different elements of the vertex group at C, " <>
        "and the 24-cent gap is the algebraic record.",
      "Compatibility" -> {
        "vertex_group_as_comma_record",
        "position_dependent_tonnetz"
      },
      "CompositionRules" -> <|
        "vertex_group_as_comma_record" ->
          "EmergentProperty[winding_number_index_of_iterated_fifth]"
      |>,
      "RemovalSignature" ->
        StandardRemovalSignature["groupoid_event_structure"],
      "TransferConditions" -> StandardTransferConditions[],
      "FailureMode" -> MakeFailureMode[
        "Id"          -> "paths_identified_with_events_collapses_the_comma",
        "TriggeredBy" -> {"removal_of_groupoid_event_structure"},
        "Signature"   ->
          "iterated_fifth_paths_become_indistinguishable_from_their_endpoints; " <>
          "comma_disappears_as_artefact_of_too_coarse_an_identification"
      ]
    ],

    "vertex_group_as_comma_record" -> MakeMechanism[
      "Id"            -> "vertex_group_as_comma_record",
      "Kernel"        -> KernelTheFifth,
      "Type"          -> "AlgebraicTopologyInvariant",
      "Domain"        -> "music",
      "Description"   ->
        "The vertex group at each point of a music-theoretic " <>
        "groupoid is the fundamental group of the underlying space " <>
        "at that point; it records 'what loops fail to be trivial.' " <>
        "Non-trivial vertex group <=> non-contractible loops <=> " <>
        "compositional algebra of arrows refuses to reduce to a " <>
        "function over points. This is the homotopy-theoretic " <>
        "characterisation of comma-presence: a space has a non- " <>
        "trivial comma exactly when its arrow algebra is strictly " <>
        "richer than its point algebra. FalseWork's parallel " <>
        "statement is at the Heyting-algebra level: the closure- " <>
        "residue (Im(eta)^cc) Im(eta)) is non-empty exactly when " <>
        "Sub(D Y) is non-Boolean at the kernel image. The two " <>
        "characterisations live in different mathematical " <>
        "categories (topology vs. lattice) but identify the same " <>
        "structural phenomenon. A locale/topology bridge exists in " <>
        "principle (for Sh(X), Sub(1) = Omega(X), and pi_1(X) " <>
        "lives in the etale homotopy of the topos); the bridge is " <>
        "not constructed in FalseWork as of this entry's date.",
      "Compatibility" -> {
        "groupoid_event_structure",
        "position_dependent_tonnetz"
      },
      "CompositionRules" -> <|
        "groupoid_event_structure" ->
          "EmergentProperty[characteristic_class_of_iteration_failure]"
      |>,
      "RemovalSignature" ->
        StandardRemovalSignature["vertex_group_as_comma_record"],
      "TransferConditions" -> StandardTransferConditions[],
      "FailureMode" -> MakeFailureMode[
        "Id"          -> "trivial_vertex_group_collapses_to_Boolean_subalgebra",
        "TriggeredBy" -> {"removal_of_vertex_group_as_comma_record"},
        "Signature"   ->
          "fundamental_group_becomes_trivial; comma_loses_its_algebraic_witness; " <>
          "structurally_equivalent_to_Heyting_algebra_being_Boolean_at_kernel"
      ]
    ],

    "position_dependent_tonnetz" -> MakeMechanism[
      "Id"            -> "position_dependent_tonnetz",
      "Kernel"        -> KernelTheFifth,
      "Type"          -> "DistinctionStructureChoice",
      "Domain"        -> "music",
      "Description"   ->
        "The same underlying graph (vertices = pitches or scales, " <>
        "edges = chosen voice-leading or transformational " <>
        "relations) supports four genuinely distinct groupoid " <>
        "spaces in Tymoczko's Section 3: harmonic Tonnetz (trivial " <>
        "vertex group), Cohnian Tonnetz (Z_3 vertex group), scalar " <>
        "Tonnetz (Z_7 vertex group), Weber Tonnetz (Z_21 vertex " <>
        "group). Each Tonnetz fixes a different equivalence class " <>
        "of paths and therefore a different comma structure on the " <>
        "same surface. Theorists conflate them. In FalseWork " <>
        "architecture, this is the choice of distinction structure " <>
        "(D, eta, iota) on a fixed underlying category C: same C, " <>
        "different Delta, different kernelImage Delta Y, different " <>
        "four-position partition. The enharmonic-seam argument " <>
        "(spelling meaningful on scalar Tonnetz but not Cohnian) " <>
        "is the empirical signature of which choice has been made.",
      "Compatibility" -> {
        "groupoid_event_structure",
        "vertex_group_as_comma_record"
      },
      "CompositionRules" -> <||>,
      "RemovalSignature" ->
        StandardRemovalSignature["position_dependent_tonnetz"],
      "TransferConditions" -> StandardTransferConditions[],
      "FailureMode" -> MakeFailureMode[
        "Id"          -> "tonnetz_conflation_erases_partition_choice",
        "TriggeredBy" -> {"removal_of_position_dependent_tonnetz"},
        "Signature"   ->
          "four_distinct_groupoid_spaces_treated_as_one; " <>
          "framework_correlate: distinction_structures_treated_as_unique_when_multiple_exist"
      ]
    ]

  |>,

  "Constraints" -> <|

    "non_boolean_substrate" -> MakeConstraint[
      "Id"   -> "non_boolean_substrate",
      "Type" -> "DependencyStatement",
      "DependedOnBy" -> {
        "vertex_group_as_comma_record",
        "position_dependent_tonnetz"
      },
      "Description" ->
        "Tymoczko's vertex-group machinery is non-trivial only " <>
        "when the underlying groupoid has non-contractible loops; " <>
        "equivalently when the pitch-class space has non-trivial " <>
        "fundamental group. FalseWork's parallel constraint: the " <>
        "closure-residue is non-trivial only in non-Boolean " <>
        "topoi. Both are 'something must refuse to collapse' " <>
        "preconditions on the substrate."
    ]

  |>,

  "FailureModes" -> {
    MakeFailureMode[
      "Id"          -> "groupoid_reduced_to_set_loses_all_comma_structure",
      "TriggeredBy" -> {"quotient_by_all_loops; replacement_of_arrows_with_endpoint_pairs"},
      "Signature"   ->
        "musical_events_become_indistinguishable_from_their_endpoints; " <>
        "Pythagorean_comma_unrecoverable_from_the_quotient"
    ]
  },

  "GenerativePrinciple" ->
    "The groupoid framework formalises 'paths matter beyond their " <>
    "endpoints' via the algebraic-topology theorem: commas exist " <>
    "exactly when the fundamental group is non-trivial. This is a " <>
    "structural characterisation of the comma, parallel to but " <>
    "distinct from FalseWork's Heyting characterisation " <>
    "(closure-residue non-empty exactly when Sub(D Y) is non-" <>
    "Boolean at the kernel). The convergence of two independent " <>
    "formalisms on the same kernel-comma structure is the " <>
    "evidential payload.",

  "IndependentCorroboration" -> {
    "tymoczko-geometry-of-music-2011",
    "lewin_1987_generalized_musical_intervals",
    "messiaen_1944_modes_of_limited_transposition",
    "forte_1973_structure_of_atonal_music"
  },

  "RelatedFrameworkArtefacts" -> {
    "FalseWork.Lattice.lattice_four_position_partition",
    "FalseWork.Lattice.Examples.Div12.heytingAlgebra",
    "FalseWork.Lattice.Examples.Div12.tritone_non_regular",
    "FalseWork.Lattice.Examples.Div12.music_anchor_witness",
    "papers/comma-formal-structure-note.md",
    "preprints/four-position-partition/music-anchor/feasibility.md Section 12 / Section 13"
  },

  "CrossDomainDualitySignal" -> <|
    "Description" ->
      "Tymoczko's Section 1 and Section 7 catalogue a structural " <>
      "duality (symmetries act on elements; intervals act on " <>
      "attributes) that recurs across domains: active/passive in " <>
      "physics, action by lifting / action by deck transformations " <>
      "in algebraic topology, left/right actions in group theory, " <>
      "perspectival/nonperspectival (de se / de dicto) in " <>
      "philosophy of mind. Tymoczko notes the parallel and " <>
      "declines to theorise it (his Section 7 explicitly says he " <>
      "knows of no prior description of the general structure " <>
      "accessible to music theorists). This is a candidate cross-" <>
      "domain structural invariant that FalseWork has NOT engaged " <>
      "with formally; the symmetry/interval duality is not part " <>
      "of the four-position partition machinery or the Commitment " <>
      "gate. Recorded here as a possible Paper 4 / Paper 5 / Paper " <>
      "7 follow-up direction, not a current commitment.",
    "Status" -> "open_research_direction_not_currently_formalised",
    "PaperReference" -> "Tymoczko 2026 JMT Sections 1 and 7"
  |>,

  "Provenance" ->
    "Core entry drafted following review of Tymoczko (2026) JMT " <>
    "in May 2026, in the context of the FalseWork music-anchor " <>
    "Layer-L formalisation (Lean: FalseWorkPapers/Lattice/* and " <>
    "Examples/DivisorLattice12.lean; computational companion: " <>
    "wolfram/music-anchor/four-position-music-v3-path-b.wl). The " <>
    "2026 paper is a separate work from Tymoczko (2011) and " <>
    "deserves its own corroboration record; the 2011 book is " <>
    "cataloged in `tymoczko.wl` and remains the primary corroborator " <>
    "for the music-kernel cluster. The 2026 paper's new evidential " <>
    "weight is at the kernel-comma structural level via the " <>
    "groupoid/fundamental-group formalism, not at the partition-" <>
    "instantiation level (the four-cell test on specific works " <>
    "remains deferred)."
];


(* Validation at load time *)
If[WellFormedCoreQ[Tymoczko2026Core],
  Print["Tymoczko 2026 core loaded: ",
        Length @ field[Tymoczko2026Core, "Mechanisms"], " mechanisms, ",
        Length @ field[Tymoczko2026Core, "Constraints"], " constraints."],
  Print["WARNING: Tymoczko 2026 core failed well-formedness check."]
];
