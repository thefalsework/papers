(* ::Package:: *)

(* ============================================================
   Structural Core: Heunen-Landsman-Spitters (2009)
                     "A Topos for Algebraic Quantum Theory"
   ------------------------------------------------------------
   Domain: physics
   Kernel: TheWaveFunction (not yet bound in kernels.wl; stubbed
           locally with note for future promotion)
   Comma:  CommaMeasurementContext (stubbed locally; the
           measurement-context gap is the physics-side analog
           of the Pythagorean comma in music)

   Independent corroboration for the FalseWork four-position
   partition's projected physics anchor. The HLS 2009 paper
   (and the broader Doering-Isham-Heunen-Landsman-Spitters-
   Caspers lineage of topos quantum mechanics) constructs a
   non-Boolean Heyting algebra from a quantum-mechanical
   substrate via the Bohrification procedure, and identifies
   the non-commutativity of the observable algebra as exactly
   what produces the non-Boolean subobject classifier. This is
   the physics-side counterpart of the music-side Tymoczko
   2026 corroboration in `tymoczko-2026.wl`.

   Two parallels do the substantive evidential work:

   (1) Bohrification as a topos-realisation of the non-Boolean
       Heyting-algebra slice. For any unital C*-algebra A, the
       Bohrification construction produces a presheaf topos
       T(A) = [C(A), Set] on the context category C(A) of
       commutative *-subalgebras of A. The subobject lattice of
       the spectral presheaf Sigma in T(A) is a complete
       Heyting algebra, non-Boolean whenever A is non-
       commutative. The proposition lattice of quantum
       mechanics, in this reformulation, is Heyting rather
       than orthomodular. This is the physics-side structural
       counterpart of FalseWork's Sub(D Y) at the Heyting-
       algebra level.

   (2) Non-commutativity as the precondition for the comma.
       The HLS construction collapses to a Boolean topos
       precisely when A is commutative (when classical
       mechanics is recoverable as a special case of
       Bohrification). In FalseWork terms: the non-Boolean
       Heyting structure exists exactly when the underlying
       algebra forces a 'something refuses to commute'
       precondition. This is structurally identical to the
       music-side condition that Sub(D Y) be non-Boolean at
       the kernel image (which requires a non-regular kernel
       image, i.e. the failure of a == aCC). Two distinct
       formalisms; convergent identification of the comma as
       arising from a precise algebraic precondition.

   One observation the HLS lineage makes that FalseWork has
   NOT engaged with formally is the constructive-vs-classical
   topos distinction. HLS work in constructive mathematics
   internal to T(A); FalseWork's Lean kernel-checked Layer-L
   theorem is classical Heyting algebra at the meta-level.
   The two registers are compatible but distinct, and the
   relationship between them is a candidate research direction
   recorded in CrossDomainDualitySignal below.

   Note on Higgs VEV explanatory debt: this core does NOT
   discharge the Paper 4 Section 6.3 explanatory debt
   (validation/claims/paper4-higgs-vev-debt.md). The HLS
   construction gives a topos-theoretic foundation for quantum
   logic; it does not derive Standard-Model parameters. The
   physics-anchor work this core supports is at the kernel-
   comma structural level (does the framework's machinery have
   a physics instance at all?), not at the parameter-derivation
   level.
   ============================================================ *)


(* ============================================================
   LOCAL KERNEL STUB

   Paper 1 v11.6 sec. 3.2 lists The Wave Function as the
   physics kernel. It is not yet bound in `wolfram/kernels.wl`
   (which currently carries only the four prototype kernels:
   TheFifth, TheCut, TheConditionalBranch, TheMethodology).
   Stubbed here so this core file is self-contained; a future
   promotion to `kernels.wl` would replace the local binding.

   The two commas of the physics kernel (per Paper 1 sec. 3.2):
   (a) Spectral-gap undecidability (Cubitt-Perez-Garcia-Wolf
       2015) -- a proven comma in the Goedel sense.
   (b) Measurement-context discontinuity -- the gap between
       Schroedinger evolution and measurement outcome.
   This core foregrounds (b), since HLS Bohrification is the
   topos-theoretic formalisation of measurement-context
   structure. A separate core for Cubitt-Perez-Garcia-Wolf
   2015 would foreground (a) and is not committed in this
   round.
   ============================================================ *)

CommaMeasurementContext = MakeComma[
  "Slug"               -> "measurement-context-comma",
  "Type"               -> "AlgebraicNonCommutativity",
  "IrreducibilityKind" -> "BoundaryDiscriminationAtLimit",
  "FormalGround" -> {
    "Heunen_Landsman_Spitters_2009_topos_for_algebraic_quantum_theory",
    "Doering_Isham_2007_topos_foundation_for_theories_of_physics_I_IV",
    "Bohr_1949_discussion_with_einstein_classical_apparatus_irreducibility"
  },
  "ParaphrasedClaim" ->
    "Quantum observables in a non-commutative C*-algebra A " <>
    "admit no single classical context that resolves all of " <>
    "them simultaneously. The Bohrification topos T(A) makes " <>
    "this precise: Sub(Sigma) in T(A) is a non-Boolean " <>
    "Heyting algebra exactly when A is non-commutative. The " <>
    "measurement-context gap is the topos-theoretic record " <>
    "of this irreducibility. (Distinct from the spectral-gap " <>
    "comma of Cubitt-Perez-Garcia-Wolf 2015, which is a " <>
    "Goedel-style undecidability of a specific many-body " <>
    "property; this comma is the algebraic-structural " <>
    "precondition for the quantum-logical apparatus itself.)"
];

KernelTheWaveFunction = MakeKernel[
  "Slug"      -> "the-wave-function",
  "Domain"    -> "physics",
  "Operation" -> "linear_superposition_under_unitary_evolution",
  "Comma"     -> CommaMeasurementContext,
  "FormalGround" -> {
    "Bohr_1928_quantum_postulate",
    "Heunen_Landsman_Spitters_2009",
    "Doering_Isham_2007_I_IV",
    "Cubitt_PerezGarcia_Wolf_2015_undecidability_spectral_gap"
  },
  "FieldTopology" ->
    {"Substrate", "Distribution", "Exploitation",
     "Commitment", "Refusal"},
  "PaperReference" -> "Paper 1 v11.6 sec. 3.2 (physics kernel)"
];


(* ============================================================
   THE HLS 2009 CORE
   ============================================================ *)

HeunenLandsmanSpitters2009Core = MakeCore[
  "Id"     -> "heunen-landsman-spitters-topos-for-algebraic-quantum-theory-2009",
  "Title"  -> "A Topos for Algebraic Quantum Theory",
  "Author" -> "Chris Heunen and Nicolaas P. Landsman and Bas Spitters",
  "Year"   -> 2009,
  "Venue"  -> "Communications in Mathematical Physics 291: 63-110",
  "Domain" -> "physics",
  "Kernel" -> KernelTheWaveFunction,

  "Mechanisms" -> <|

    "bohrification_topos_construction" -> MakeMechanism[
      "Id"            -> "bohrification_topos_construction",
      "Kernel"        -> KernelTheWaveFunction,
      "Type"          -> "ToposRealisation",
      "Domain"        -> "physics",
      "Description"   ->
        "Given a unital C*-algebra A (the algebra of bounded " <>
        "observables of a quantum system), define the context " <>
        "category C(A) as the poset of unital commutative *- " <>
        "subalgebras of A, ordered by inclusion. The Bohr " <>
        "topos T(A) = [C(A), Set] is the topos of covariant " <>
        "presheaves on C(A). T(A) is an elementary (in fact " <>
        "Grothendieck) topos. Its subobject classifier " <>
        "Omega_{T(A)} is non-Boolean whenever A is non- " <>
        "commutative; its internal logic is intuitionistic. " <>
        "FalseWork's parallel construction is the presheaf " <>
        "topos Set^{P^op} on the join-irreducible poset P = " <>
        "{2, 3, 4} of the music-anchor divisor lattice; both " <>
        "are presheaf topoi on small posets that realise non- " <>
        "Boolean subobject lattices.",
      "Compatibility" -> {
        "spectral_presheaf_as_phase_space",
        "kochen_specker_obstruction_internalised"
      },
      "CompositionRules" -> <|
        "spectral_presheaf_as_phase_space" ->
          "EmergentProperty[non_boolean_subobject_lattice_at_spectral_presheaf]"
      |>,
      "RemovalSignature" ->
        StandardRemovalSignature["bohrification_topos_construction"],
      "TransferConditions" -> StandardTransferConditions[],
      "FailureMode" -> MakeFailureMode[
        "Id"          -> "commutative_algebra_collapses_to_boolean_topos",
        "TriggeredBy" -> {"removal_of_bohrification_topos_construction"},
        "Signature"   ->
          "T(A) reduces to Set (for A = C) or to a Boolean topos " <>
          "(for A commutative); the non-Boolean subobject " <>
          "classifier disappears; the framework's comma loses " <>
          "its lattice-theoretic witness."
      ]
    ],

    "spectral_presheaf_as_phase_space" -> MakeMechanism[
      "Id"            -> "spectral_presheaf_as_phase_space",
      "Kernel"        -> KernelTheWaveFunction,
      "Type"          -> "GeometricRepresentation",
      "Domain"        -> "physics",
      "Description"   ->
        "Within T(A), the spectral presheaf Sigma in T(A) " <>
        "assigns to each context C in C(A) the Gelfand " <>
        "spectrum Sigma(C) of that commutative subalgebra. " <>
        "Sigma plays the role of phase space inside the Bohr " <>
        "topos. The subobject lattice Sub_{T(A)}(Sigma) is a " <>
        "complete Heyting algebra; its elements are " <>
        "interpreted as propositions about the quantum " <>
        "system. The Kochen-Specker theorem internalises as " <>
        "the statement that Sigma has no global sections " <>
        "(no global classical valuation). FalseWork's " <>
        "analogue is the kernel image Im(eta_Y) in " <>
        "Sub(D Y): a distinguished sub-Heyting-algebra " <>
        "element relative to which the four-position " <>
        "partition is computed.",
      "Compatibility" -> {
        "bohrification_topos_construction",
        "kochen_specker_obstruction_internalised"
      },
      "CompositionRules" -> <|
        "kochen_specker_obstruction_internalised" ->
          "EmergentProperty[no_global_classical_valuation]"
      |>,
      "RemovalSignature" ->
        StandardRemovalSignature["spectral_presheaf_as_phase_space"],
      "TransferConditions" -> StandardTransferConditions[],
      "FailureMode" -> MakeFailureMode[
        "Id"          -> "no_phase_space_no_proposition_lattice",
        "TriggeredBy" -> {"removal_of_spectral_presheaf_as_phase_space"},
        "Signature"   ->
          "without_a_designated_object_to_take_subobjects_of, " <>
          "the_proposition_lattice_is_undefined; analogue: " <>
          "FalseWork without a chosen generic Y has no " <>
          "Sub(D Y) and no four-cell partition."
      ]
    ],

    "kochen_specker_obstruction_internalised" -> MakeMechanism[
      "Id"            -> "kochen_specker_obstruction_internalised",
      "Kernel"        -> KernelTheWaveFunction,
      "Type"          -> "AlgebraicTopologyInvariant",
      "Domain"        -> "physics",
      "Description"   ->
        "The Kochen-Specker theorem (1967) states that for " <>
        "dim(H) >= 3 there is no consistent value assignment " <>
        "from quantum observables to real numbers. In the " <>
        "HLS / Doering-Isham formalism this internalises as: " <>
        "the spectral presheaf Sigma in T(A) has no global " <>
        "section. This is the topos-theoretic record of the " <>
        "non-classicality of A. Structurally analogous to " <>
        "Tymoczko 2026's vertex group as the algebraic record " <>
        "of the non-triviality of pi_1 of the music space, " <>
        "and to FalseWork's closure-residue (Im(eta))cc minus " <>
        "Im(eta) as the Heyting record of non-regularity at " <>
        "the kernel image. Three independent formalisms " <>
        "(topology, lattice, topos-quantum-mechanics) " <>
        "identify the same load-bearing structural " <>
        "phenomenon: something refuses to admit a global " <>
        "trivialisation, and the algebraic record of that " <>
        "refusal is the comma.",
      "Compatibility" -> {
        "bohrification_topos_construction",
        "spectral_presheaf_as_phase_space"
      },
      "CompositionRules" -> <||>,
      "RemovalSignature" ->
        StandardRemovalSignature["kochen_specker_obstruction_internalised"],
      "TransferConditions" -> StandardTransferConditions[],
      "FailureMode" -> MakeFailureMode[
        "Id"          -> "trivialisation_of_spectral_presheaf_collapses_quantum_logic",
        "TriggeredBy" -> {"removal_of_kochen_specker_obstruction_internalised"},
        "Signature"   ->
          "spectral_presheaf_admits_global_section; quantum_logic " <>
          "becomes_locally_classical_everywhere; comma_loses_its_" <>
          "topos_theoretic_witness; structurally_equivalent_to_" <>
          "the_Heyting_algebra_being_Boolean_at_the_kernel_image."
      ]
    ],

    "bi_heyting_structure_on_clopen_subobjects" -> MakeMechanism[
      "Id"            -> "bi_heyting_structure_on_clopen_subobjects",
      "Kernel"        -> KernelTheWaveFunction,
      "Type"          -> "LatticeStructureFact",
      "Domain"        -> "physics",
      "Description"   ->
        "Doering (2012, arXiv:1202.2750) establishes the " <>
        "lattice-theoretic structure of Sub_{cl}(Sigma), the " <>
        "complete bi-Heyting algebra of clopen subobjects of " <>
        "the spectral presheaf, in three facts that bear " <>
        "directly on the FalseWork four-position partition: " <>
        "(i) The Heyting NOT has a stagewise formula: at each " <>
        "context V, P_{(NOT S)_V} = 1 - JOIN_{V' minimal in V} " <>
        "P_{S_{V'}} (Prop. 2). This formula is NOT the 'largest " <>
        "down-set disjoint from S' Heyting operation that " <>
        "obtains on O(P) for the context poset P = V(A) itself. " <>
        "Sub_{cl}(Sigma) is not isomorphic to O(V(A)). " <>
        "(ii) An element S is Heyting-regular (NOT NOT S = S) iff " <>
        "for all contexts V, P_{S_V} = MEET_{V' minimal in V} " <>
        "P_{S_{V'}} (Prop. 3). " <>
        "(iii) Every 'tight' clopen subobject -- including " <>
        "every outer-daseinisation delta^o(P-hat) of a quantum " <>
        "projection P-hat in P(N) -- is Heyting-regular " <>
        "(Prop. 5, Cor. 2). Tight subobjects are a strict " <>
        "subset of regular subobjects (Doering remarks " <>
        "explicitly that regular need not be tight). " <>
        "Structural implication for FalseWork: the non-regular " <>
        "elements of Sub_{cl}(Sigma), where the four-position " <>
        "partition's Exploitation cell lives, are exactly the " <>
        "non-tight clopen subobjects -- the ones NOT arising " <>
        "from quantum projections via daseinisation. Their " <>
        "physical interpretation is open; their existence is " <>
        "guaranteed by non-commutativity of A.",
      "Compatibility" -> {
        "spectral_presheaf_as_phase_space",
        "bohrification_topos_construction"
      },
      "CompositionRules" -> <|
        "spectral_presheaf_as_phase_space" ->
          "Sub_{cl}(Sigma) inherits its bi-Heyting structure from Sigma's role as phase space"
      |>,
      "RemovalSignature" ->
        StandardRemovalSignature["bi_heyting_structure_on_clopen_subobjects"],
      "TransferConditions" -> StandardTransferConditions[],
      "FailureMode" -> MakeFailureMode[
        "Id"          -> "boolean_collapse_at_commutative_algebra",
        "TriggeredBy" -> {"abelianisation_of_A"},
        "Signature"   ->
          "for commutative A, every clopen subobject is tight, " <>
          "hence Heyting-regular; Sub_{cl}(Sigma) becomes Boolean; " <>
          "the four-position Exploitation cell becomes globally empty."
      ]
    ],

    "non_regular_witness_with_non_bottom_complement" -> MakeMechanism[
      "Id"            -> "non_regular_witness_with_non_bottom_complement",
      "Kernel"        -> KernelTheWaveFunction,
      "Type"          -> "OpenStructuralQuestion",
      "Domain"        -> "physics",
      "Description"   ->
        "The structural prerequisite for a non-vacuous four-" <>
        "position partition at a kernel a, in any Heyting " <>
        "algebra H, is: a is non-regular (NOT NOT a > a strictly, " <>
        "so the closure-residue is non-empty) AND NOT a is " <>
        "non-bottom (so the Refusal cell can be populated). " <>
        "Both conditions are required; absent either, the " <>
        "partition collapses to <=3 cells. The music divisor " <>
        "lattice has this at the tritone (a = 2, NOT a = 3, NOT " <>
        "NOT a = 4); the five physics candidates in " <>
        "wolfram/physics-anchor/four-position-physics-v1.wl " <>
        "(v1.1) lack it generically because they are O(P) for " <>
        "P with a global minimum (which forces NOT(non-empty) " <>
        "= bottom). The same prerequisite for Sub_{cl}(Sigma) " <>
        "is the open structural question for Route A: does " <>
        "there exist a non-regular S in Sub_{cl}(Sigma) with " <>
        "NOT S =/= bottom-subobject? The Doering 2012 stagewise " <>
        "formula (Prop. 2 of the prior mechanism) does NOT " <>
        "inherit the O(P) global-minimum obstacle; the question " <>
        "is genuinely open at the lattice level and resolves " <>
        "by explicit small-A computation. " <>
        "(Note on impossibility: the question is sometimes " <>
        "phrased as 'paired non-regularity' -- a non-regular S " <>
        "whose Heyting complement is also non-regular. That " <>
        "phrasing is mathematically impossible: in any Heyting " <>
        "algebra NOT NOT NOT x = NOT x, so NOT x is always " <>
        "regular. The correct phrasing is 'non-regular S with " <>
        "non-bottom Heyting complement', and the music anchor " <>
        "instantiates the correct phrasing, not the impossible " <>
        "one.)",
      "Compatibility" -> {
        "bi_heyting_structure_on_clopen_subobjects",
        "spectral_presheaf_as_phase_space"
      },
      "CompositionRules" -> <||>,
      "RemovalSignature" ->
        StandardRemovalSignature["non_regular_witness_with_non_bottom_complement"],
      "TransferConditions" -> StandardTransferConditions[],
      "FailureMode" -> MakeFailureMode[
        "Id"          -> "global_complement_flatness_collapses_partition",
        "TriggeredBy" -> {"every_non_regular_S_has_NOT_S_equal_bottom"},
        "Signature"   ->
          "if Sub_{cl}(Sigma) is structurally flat in the sense " <>
          "that every non-regular S has NOT S = bottom, then no " <>
          "kernel admits a non-vacuous partition and physics " <>
          "anchoring requires either a different topos " <>
          "construction or framework-level modifications. This " <>
          "is the negative-checkpoint outcome the small-A " <>
          "Wolfram computation (feasibility.md sec. 4.4) is " <>
          "designed to detect."
      ]
    ]

  |>,

  "Constraints" -> <|

    "non_commutativity_precondition" -> MakeConstraint[
      "Id"   -> "non_commutativity_precondition",
      "Type" -> "DependencyStatement",
      "DependedOnBy" -> {
        "bohrification_topos_construction",
        "spectral_presheaf_as_phase_space",
        "kochen_specker_obstruction_internalised"
      },
      "Description" ->
        "All three mechanisms of HLS Bohrification are non- " <>
        "trivial only when A is non-commutative. For A " <>
        "commutative (classical mechanics), T(A) reduces to " <>
        "the topos of sheaves on Spec(A) and Sub(Sigma) is " <>
        "Boolean. FalseWork's parallel constraint: the " <>
        "closure-residue is non-trivial only in non-Boolean " <>
        "topoi. Tymoczko 2026's parallel constraint: vertex " <>
        "groups are non-trivial only when pi_1 of the " <>
        "underlying space is non-trivial. All three are " <>
        "'something must refuse to collapse' preconditions on " <>
        "the substrate."
    ],

    "size_constraint_finite_dim_for_first_anchor" -> MakeConstraint[
      "Id"   -> "size_constraint_finite_dim_for_first_anchor",
      "Type" -> "ComputationalTractability",
      "DependedOnBy" -> {
        "bohrification_topos_construction"
      },
      "Description" ->
        "For an explicit FalseWork physics-anchor instance, A " <>
        "should be finite-dimensional (e.g. M_n(C) or a " <>
        "finite direct sum thereof). For A = M_2(C) the " <>
        "context category has a continuum of MASAs (the " <>
        "manifold of orthonormal bases up to phase), but " <>
        "discrete sub-posets exist that are computationally " <>
        "tractable; the Route-B Wolfram exploration tests " <>
        "several of these (wolfram/physics-anchor/" <>
        "four-position-physics-v1.wl). Full continuous " <>
        "spectral-presheaf computation is deferred."
    ]

  |>,

  "FailureModes" -> {
    MakeFailureMode[
      "Id"          -> "abelian_quotient_loses_all_comma_structure",
      "TriggeredBy" -> {"abelianisation_of_A; restriction_to_classical_observables"},
      "Signature"   ->
        "T(A) collapses to a Boolean topos; Sub(Sigma) becomes " <>
        "Boolean; the measurement-context comma disappears as " <>
        "an artefact of having quotiented away the non- " <>
        "commutativity that produced it."
    ],
    MakeFailureMode[
      "Id"          -> "infinite_dim_obstacle_to_explicit_computation",
      "TriggeredBy" -> {"choice_of_A_with_continuous_spectrum_or_infinite_dim"},
      "Signature"   ->
        "Sub(Sigma) becomes too large for direct enumeration; " <>
        "must work at the level of internal language of T(A) " <>
        "rather than explicit Heyting-algebra slice; Lean " <>
        "formalisation correspondingly harder."
    ]
  },

  "GenerativePrinciple" ->
    "The Bohrification programme formalises 'no single " <>
    "classical context resolves all quantum observables' " <>
    "via the topos-theoretic theorem: Sub_{T(A)}(Sigma) is a " <>
    "non-Boolean Heyting algebra exactly when A is non- " <>
    "commutative. This is a structural characterisation of " <>
    "the quantum comma, parallel to but distinct from " <>
    "FalseWork's Heyting characterisation (closure-residue " <>
    "non-empty exactly when Sub(D Y) is non-Boolean at the " <>
    "kernel image) and Tymoczko 2026's groupoid " <>
    "characterisation (vertex group non-trivial exactly " <>
    "when pi_1 of the music space is non-trivial). The " <>
    "convergence of three independent formalisms on the " <>
    "same kernel-comma structural fact is the evidential " <>
    "payload; whether this convergence can be made " <>
    "categorically formal (via a unifying locale-or-stack " <>
    "bridge) is open research and not currently committed.",

  "IndependentCorroboration" -> {
    "doering_isham_2007_topos_foundation_for_theories_of_physics_I_IV",
    "doering_2009_topos_perspective_on_quantum_logic",
    "doering_2012_topos_based_logic_for_quantum_systems_and_bi_heyting_algebras",
    "caspers_heunen_2009_constructively_complete_finite_dim_cstar_algebras",
    "nuiten_2011_bohrification_of_local_nets_of_observables",
    "flori_2013_first_course_in_topos_quantum_theory",
    "cubitt_perezgarcia_wolf_2015_undecidability_spectral_gap"
  },

  "RelatedFrameworkArtefacts" -> {
    "preprints/four-position-partition/paper.md",
    "preprints/four-position-partition/physics-anchor/feasibility.md",
    "wolfram/physics-anchor/four-position-physics-v1.wl",
    "wolfram/cores/tymoczko-2026.wl",
    "papers/paper4-mathematics-as-comma/paper4.md (Section 6.3)",
    "validation/claims/paper4-higgs-vev-debt.md"
  },

  "CrossDomainDualitySignal" -> <|
    "Description" ->
      "Three formalisms now identify the same kernel-comma " <>
      "structure: FalseWork's Heyting algebra Sub(D Y), " <>
      "Tymoczko 2026's vertex groups in a groupoid, and HLS " <>
      "2009's Sub_{T(A)}(Sigma) in the Bohrification topos. " <>
      "All three are non-Boolean exactly when their " <>
      "underlying substrate refuses a global trivialisation " <>
      "(non-regular kernel image / non-trivial pi_1 / non- " <>
      "commutative A respectively). A unifying categorical " <>
      "bridge -- some kind of locale-or-stack construction " <>
      "that recovers all three as instances of a single " <>
      "abstract pattern -- is a candidate cross-domain " <>
      "structural invariant. Recorded as a possible Paper 4 " <>
      "or Paper 5 follow-up direction, not a current " <>
      "commitment. (Note: HLS work in constructive " <>
      "mathematics internal to T(A); FalseWork's Lean Layer-L " <>
      "theorem is classical Heyting algebra at the meta- " <>
      "level. The two registers are compatible but distinct, " <>
      "and the precise relationship between them is part of " <>
      "the open direction.)",
    "Status" -> "open_research_direction_not_currently_formalised",
    "PaperReference" -> "HLS 2009 + Doering-Isham 2007 + Tymoczko 2026"
  |>,

  "Provenance" ->
    "Core entry drafted May 2026 following review of the topos " <>
    "quantum mechanics literature (Doering-Isham 2007 I-IV, " <>
    "Heunen-Landsman-Spitters 2009, Caspers-Heunen 2009, " <>
    "Nuiten 2011, Flori 2013), in the context of scoping a " <>
    "physics anchor for the four-position partition framework. " <>
    "HLS 2009 is selected as the primary reference because it " <>
    "is the cleanest single-paper statement of the " <>
    "Bohrification programme in its mature form; the Doering- " <>
    "Isham 2007 four-paper series is the foundational " <>
    "alternative. Doering 2012 (arXiv:1202.2750) was read " <>
    "after the initial draft to extract the bi-Heyting / " <>
    "regularity structure of Sub_{cl}(Sigma), which is " <>
    "captured in the mechanisms bi_heyting_structure_on_" <>
    "clopen_subobjects and non_regular_witness_with_non_" <>
    "bottom_complement above and which corrects a working " <>
    "diagnosis from the immediately-prior physics feasibility " <>
    "round (the 'paired non-regularity' phrasing, which is " <>
    "Heyting-algebraically impossible; the correct phrasing " <>
    "is 'non-regular element with non-bottom Heyting " <>
    "complement', and the music anchor instantiates the " <>
    "correct phrasing). This core's evidential weight is at " <>
    "the kernel-comma structural level via the topos- " <>
    "theoretic formalism of quantum logic, not at the " <>
    "Standard-Model-parameter level (the Higgs VEV " <>
    "explanatory debt of Paper 4 sec. 6.3 remains open). No " <>
    "FalseWork physics Layer-L theorem is kernel-checked at " <>
    "the time of this entry; see preprints/four-position-" <>
    "partition/physics-anchor/feasibility.md sec. 4.4 for the " <>
    "next computational checkpoint and wolfram/physics-" <>
    "anchor/four-position-physics-v1.wl for the completed " <>
    "Route-B exploration."
];


(* Validation at load time *)
If[WellFormedCoreQ[HeunenLandsmanSpitters2009Core],
  Print["HLS 2009 core loaded: ",
        Length @ field[HeunenLandsmanSpitters2009Core, "Mechanisms"], " mechanisms, ",
        Length @ field[HeunenLandsmanSpitters2009Core, "Constraints"], " constraints."],
  Print["WARNING: HLS 2009 core failed well-formedness check."]
];
