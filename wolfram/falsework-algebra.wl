(* ::Package:: *)

(* ============================================================
   FalseWork Algebra
   ------------------------------------------------------------
   Operational instantiation of the kernel/comma framework
   (Paper 1 v11.6) as a typed symbolic algebra over structural
   cores. Implements the four queries specified by Ellynne Dec
   on behalf of the Wolfram Institute Computational Metaphysics
   group, May 3, 2026.

   Author:    Chris Brink (independent), 2026
   Reference: https://github.com/thefalsework/papers
   ============================================================ *)


(* ============================================================
   1. TYPE SYSTEM

   Six symbolic heads, each wrapping an Association. Pattern
   matching against the head gives us type-level dispatch;
   Association access gives us field-level introspection.

   The type discipline is kernel-anchored: every Mechanism
   carries a Kernel reference, every Comma carries a Kernel
   reference, every Core carries a Kernel reference. A schema
   without a kernel anchor is malformed.
   ============================================================ *)

ClearAll[Kernel, Comma, Mechanism, Constraint, FailureMode, Core,
         field, MakeKernel, MakeComma, MakeMechanism, MakeConstraint,
         MakeFailureMode, MakeCore,
         KernelQ, CommaQ, MechanismQ, ConstraintQ, FailureModeQ, CoreQ,
         WellFormedCoreQ];


(* --- Constructors ------------------------------------------ *)

(* Each constructor wraps an option sequence into an Association
   under its type head. *)

MakeKernel[opts___Rule]      := Kernel[Association[opts]];
MakeComma[opts___Rule]       := Comma[Association[opts]];
MakeMechanism[opts___Rule]   := Mechanism[Association[opts]];
MakeConstraint[opts___Rule]  := Constraint[Association[opts]];
MakeFailureMode[opts___Rule] := FailureMode[Association[opts]];
MakeCore[opts___Rule]        := Core[Association[opts]];


(* --- Universal accessor ------------------------------------ *)

(* field[obj, "Key"] looks up the named field in any of the six
   typed objects. Returns Missing[] if the field is absent. *)

field[(Kernel | Comma | Mechanism | Constraint | FailureMode | Core)[
        a_Association], k_String] := Lookup[a, k, Missing["KeyAbsent", k]];

field[obj_, k_String] := Missing["NotATypedObject", obj];


(* --- Predicates -------------------------------------------- *)

KernelQ[expr_]      := MatchQ[expr, Kernel[_Association]] &&
                       AllTrue[{"Slug", "Domain", "Operation"},
                               KeyExistsQ[First @ expr, #] &];

(* Note: commas don't carry a back-reference to their kernel.
   The kernel->comma relationship is one-way to avoid circular
   construction. A comma's kernel is identified by which kernel
   references it via its "Comma" field. *)
CommaQ[expr_]       := MatchQ[expr, Comma[_Association]] &&
                       AllTrue[{"Slug", "Type",
                                "IrreducibilityKind", "FormalGround"},
                               KeyExistsQ[First @ expr, #] &];

MechanismQ[expr_]   := MatchQ[expr, Mechanism[_Association]] &&
                       AllTrue[{"Id", "Kernel", "Type"},
                               KeyExistsQ[First @ expr, #] &];

ConstraintQ[expr_]  := MatchQ[expr, Constraint[_Association]] &&
                       KeyExistsQ[First @ expr, "Id"];

FailureModeQ[expr_] := MatchQ[expr, FailureMode[_Association]] &&
                       KeyExistsQ[First @ expr, "Id"];

CoreQ[expr_]        := MatchQ[expr, Core[_Association]] &&
                       AllTrue[{"Id", "Kernel", "Mechanisms"},
                               KeyExistsQ[First @ expr, #] &];

WellFormedCoreQ[c_] :=
  CoreQ[c] &&
  KernelQ[field[c, "Kernel"]] &&
  AllTrue[Values[field[c, "Mechanisms"]], MechanismQ];


(* ============================================================
   2. KERNEL-LEVEL HELPERS

   The kernel layer is what makes the algebra non-arbitrary.
   These helpers encode the comma-shape match that determines
   when two kernels can host transferable mechanisms.
   ============================================================ *)

CommaShape::usage =
  "CommaShape[c] returns a structural signature for a Comma that " <>
  "abstracts away domain-specific content while preserving its " <>
  "irreducibility shape. Two commas with the same shape can host " <>
  "transferable mechanisms.\n\n" <>
  "The signature uses IrreducibilityKind, not Type. Type carries " <>
  "the domain-specific characterization of the incommensurability " <>
  "(\"ArithmeticIncompleteness\", \"PerceptualDiscontinuity\", " <>
  "\"ComputationalUndecidability\", \"RecursiveSelfApplicationGap\"). " <>
  "IrreducibilityKind carries the abstract cross-domain structural " <>
  "shape (e.g. \"BoundaryDiscriminationAtLimit\") that the framework " <>
  "claims is shared across domains in Paper 1 sec. 4.3: \"both are " <>
  "instances of the same abstract structure: a sub-symmetry made " <>
  "available by a closed generative field at its boundary.\" The " <>
  "framework treats this cross-domain abstract-structural claim as " <>
  "the open empirical question; the algebra encodes it but does not " <>
  "prove it.";

CommaShape[c_?CommaQ] :=
  <|
    "IrreducibilityKind" -> field[c, "IrreducibilityKind"],
    "FormallyGrounded"   -> (!MissingQ[field[c, "FormalGround"]] &&
                             ListQ[field[c, "FormalGround"]] &&
                             Length[field[c, "FormalGround"]] > 0)
  |>;

CommaShapeMatchQ[c1_?CommaQ, c2_?CommaQ] :=
  CommaShape[c1] === CommaShape[c2];


KernelShapeMatchQ[k1_?KernelQ, k2_?KernelQ] :=
  !MissingQ[field[k1, "Operation"]] &&
  !MissingQ[field[k2, "Operation"]] &&
  field[k1, "Domain"] =!= field[k2, "Domain"] &&
  CommaShapeMatchQ[field[k1, "Comma"], field[k2, "Comma"]];


(* ============================================================
   3. STANDARD MECHANISM BEHAVIOURS

   Generic implementations of removal-signature and
   transfer-conditions that most mechanisms can inherit. Specific
   mechanisms can override by passing their own functions in their
   constructor.
   ============================================================ *)

StandardRemovalSignature::usage =
  "StandardRemovalSignature[mechId][core] returns the core with " <>
  "the named mechanism removed and downstream effects propagated: " <>
  "constraints that depended only on it are dropped, mechanisms " <>
  "whose composition rules referenced it are degraded, and any " <>
  "FailureMode declared by the removed mechanism is surfaced.";

StandardRemovalSignature[mechId_String][c_?CoreQ] :=
  Module[{a, mechs, constraints, mech, fm, fmList, degraded},

    a = First @ c;
    mech = a["Mechanisms"][mechId];
    If[MissingQ[mech], Return[c]];

    (* Remove the mechanism *)
    mechs = KeyDrop[a["Mechanisms"], mechId];

    (* For each constraint: strip the removed mechanism from its
       DependedOnBy list. If the resulting list is empty, the
       constraint has nothing left to bind and is dropped. *)
    constraints = If[KeyExistsQ[a, "Constraints"],
      Association @ KeyValueMap[
        Function[{cid, cobj},
          Module[{deps, newDeps},
            deps = field[cobj, "DependedOnBy"];
            If[!ListQ[deps],
              cid -> cobj,
              newDeps = DeleteCases[deps, mechId];
              If[Length[newDeps] == 0,
                Nothing,
                cid -> Constraint[
                  Append[First @ cobj, "DependedOnBy" -> newDeps]
                ]
              ]
            ]
          ]
        ],
        a["Constraints"]
      ],
      <||>
    ];

    (* Surface the failure mode that the removed mechanism declared *)
    fm = field[mech, "FailureMode"];
    fmList = Lookup[a, "FailureModes", {}];
    If[FailureModeQ[fm], AppendTo[fmList, fm]];

    (* Degrade mechanisms that depended on the removed one, either
       by explicit composition rule or by listing it as a
       compatibility partner. Marked, not dropped. *)
    degraded = Association @ KeyValueMap[
      Function[{mid, mobj},
        Module[{rules, compat, refs},
          rules  = field[mobj, "CompositionRules"];
          compat = field[mobj, "Compatibility"];
          refs = Join[
            If[!MissingQ[rules] &&
                (ListQ[rules] || AssociationQ[rules]),
              Cases[rules, mechId, Infinity], {}],
            If[!MissingQ[compat] && ListQ[compat],
              Cases[compat, mechId], {}]
          ];
          mid -> If[Length[refs] > 0,
            Mechanism[Append[First @ mobj, "Degraded" -> True]],
            mobj
          ]
        ]
      ],
      mechs
    ];

    Core[<|
      a,
      "Mechanisms"   -> degraded,
      "Constraints"  -> constraints,
      "FailureModes" -> DeleteDuplicates[fmList]
    |>]
  ];


StandardTransferConditions::usage =
  "StandardTransferConditions[][sourceMech, targetCore] returns True " <>
  "if the source mechanism could be transferred to the target core " <>
  "on grounds of (a) shared mechanism Type with at least one target " <>
  "mechanism, OR (b) comma-shape match between source kernel's comma " <>
  "and target kernel's comma.";

StandardTransferConditions[][srcMech_?MechanismQ, tgtCore_?CoreQ] :=
  Module[{srcType, tgtMechs, tgtKernel, srcComma, tgtComma},

    srcType   = field[srcMech, "Type"];
    tgtMechs  = Values @ field[tgtCore, "Mechanisms"];
    tgtKernel = field[tgtCore, "Kernel"];

    (* (a) at least one target mechanism shares the source type *)
    If[AnyTrue[tgtMechs, field[#, "Type"] === srcType &],
      Return[True]
    ];

    (* (b) the source kernel's comma is shape-compatible with the
       target kernel's comma *)
    srcComma = field[field[srcMech, "Kernel"], "Comma"];
    tgtComma = field[tgtKernel, "Comma"];
    If[CommaQ[srcComma] && CommaQ[tgtComma],
      Return[CommaShapeMatchQ[srcComma, tgtComma]]
    ];

    False
  ];


(* ============================================================
   4. QUERY 1 — Mechanism + constraint match

   Find works in a corpus whose cores contain a given mechanism
   type AND a given constraint type.

   Cross-domain by design: type-level matching, not id-level.
   ============================================================ *)

FindWorksByType::usage =
  "FindWorksByType[corpus, mechType, constType] returns the cores " <>
  "in the corpus whose Mechanisms include at least one of the given " <>
  "Type AND whose Constraints include at least one of the given Type.";

FindWorksByType[corpus_List, mechType_String, constType_String] :=
  Select[corpus,
    With[{
      mechs = Values @ field[#, "Mechanisms"],
      consts = Values @ Lookup[First @ #, "Constraints", <||>]
    },
      AnyTrue[mechs, field[#1, "Type"] === mechType &] &&
      AnyTrue[consts, field[#1, "Type"] === constType &]
    ] &
  ];


FindWorksByMechanismId[corpus_List, mechId_String] :=
  Select[corpus, KeyExistsQ[field[#, "Mechanisms"], mechId] &];


(* ============================================================
   5. QUERY 2 — Transfer candidate identification

   Given two cores, return mechanism pairs (m_A in A, m_B in B)
   where the algebra judges m_A transferable to B's host kernel.

   The compatibility basis is made explicit in each candidate so
   that the reader can inspect why the algebra surfaced it.
   ============================================================ *)

TransferCandidates::usage =
  "TransferCandidates[coreA, coreB] returns an Association of " <>
  "candidate cross-domain mechanism transfers from coreA into the " <>
  "host of coreB. Each candidate carries a 'Basis' field naming " <>
  "the predicates that succeeded.";

TransferCandidates[coreA_?CoreQ, coreB_?CoreQ] :=
  Module[{candidates = {}, mechsA, mechsB},

    mechsA = field[coreA, "Mechanisms"];
    mechsB = field[coreB, "Mechanisms"];

    KeyValueMap[
      Function[{idA, mA},
        KeyValueMap[
          Function[{idB, mB},
            With[{basis = TransferBasis[mA, mB, coreB]},
              If[basis =!= None,
                AppendTo[candidates, <|
                  "From"        -> idA,
                  "To"          -> idB,
                  "FromKernel"  -> field[field[mA, "Kernel"], "Slug"],
                  "ToKernel"    -> field[field[mB, "Kernel"], "Slug"],
                  "FromDomain"  -> field[coreA, "Domain"],
                  "ToDomain"    -> field[coreB, "Domain"],
                  "Basis"       -> basis,
                  "Confidence"  -> TransferConfidence[basis]
                |>]
              ]
            ]
          ],
          mechsB
        ]
      ],
      mechsA
    ];

    SortBy[candidates, -#["Confidence"] &]
  ];


TransferBasis::usage =
  "TransferBasis[mA, mB, coreB] returns either None or a list of " <>
  "predicates that succeeded between the source mechanism mA and " <>
  "the candidate target mechanism mB in the host coreB.";

TransferBasis[mA_?MechanismQ, mB_?MechanismQ, coreB_?CoreQ] :=
  Module[{basis = {}, srcKernel, tgtKernel, srcComma, tgtComma,
          mACompat, mBCompat, sharedCompat, runtime},

    (* (1) Same Mechanism Type *)
    If[field[mA, "Type"] === field[mB, "Type"],
      AppendTo[basis, "shared_mechanism_type"]
    ];

    (* (2) Compatibility set intersection non-empty *)
    mACompat = field[mA, "Compatibility"];
    mBCompat = field[mB, "Compatibility"];
    sharedCompat = If[ListQ[mACompat] && ListQ[mBCompat],
      Intersection[mACompat, mBCompat],
      {}
    ];
    If[Length[sharedCompat] > 0,
      AppendTo[basis, "compatibility_intersection:" <>
                       StringRiffle[sharedCompat, ","]]
    ];

    (* (3) Comma-shape match between hosting kernels *)
    srcKernel = field[mA, "Kernel"];
    tgtKernel = field[mB, "Kernel"];
    srcComma = field[srcKernel, "Comma"];
    tgtComma = field[tgtKernel, "Comma"];
    If[CommaQ[srcComma] && CommaQ[tgtComma] &&
       CommaShapeMatchQ[srcComma, tgtComma],
      AppendTo[basis, "comma_shape_match:" <>
                       field[srcComma, "IrreducibilityKind"]]
    ];

    (* (4) Cross-domain (the interesting case) *)
    If[field[srcKernel, "Domain"] =!= field[tgtKernel, "Domain"],
      AppendTo[basis, "cross_domain:" <>
                       field[srcKernel, "Domain"] <> "->" <>
                       field[tgtKernel, "Domain"]]
    ];

    (* (5) Runtime transfer-conditions predicate (mechanism-supplied) *)
    runtime = field[mA, "TransferConditions"];
    If[!MissingQ[runtime] && TrueQ[runtime[mB, coreB]],
      AppendTo[basis, "runtime_predicate"]
    ];

    If[Length[basis] >= 2, basis, None]
  ];


TransferConfidence[basis_List] :=
  Module[{n = Length[basis], hasComma, hasCross, hasType},
    hasType  = AnyTrue[basis, StringStartsQ[#, "shared_mechanism_type"] &];
    hasComma = AnyTrue[basis, StringStartsQ[#, "comma_shape_match"] &];
    hasCross = AnyTrue[basis, StringStartsQ[#, "cross_domain"] &];

    (* Comma-shape match plus shared type plus cross-domain is the
       strongest configuration; that's the kernel-shape-equivalence
       case. *)
    Which[
      hasType && hasComma && hasCross, 0.92,
      hasType && hasComma,             0.81,
      hasType && hasCross,             0.68,
      hasComma && hasCross,            0.62,
      hasType,                         0.45,
      hasComma,                        0.40,
      True,                            0.20 + 0.05 * n
    ]
  ];


(* ============================================================
   6. QUERY 3 — Computational removal test

   Given a core and a mechanism id, return the predicted core
   after removing the mechanism and propagating downstream
   effects through constraints, compositions, and failure modes.
   ============================================================ *)

RemoveAndProject::usage =
  "RemoveAndProject[core, mechId] returns the projected core after " <>
  "removing the named mechanism. Removal is a rewrite, not a " <>
  "deletion: dependent constraints collapse, composing mechanisms " <>
  "are marked degraded, and induced failure modes are surfaced.";

RemoveAndProject[c_?CoreQ, mechId_String] :=
  Module[{mech, removalFn},
    mech = Lookup[field[c, "Mechanisms"], mechId, Missing[]];
    If[MissingQ[mech], Return[$Failed]];

    removalFn = field[mech, "RemovalSignature"];
    If[MissingQ[removalFn],
      removalFn = StandardRemovalSignature[mechId]
    ];

    removalFn[c]
  ];


RemovalDelta::usage =
  "RemovalDelta[core, mechId] returns a summary Association " <>
  "describing what changed when the mechanism was removed: which " <>
  "constraints were dropped, which mechanisms were degraded, which " <>
  "failure modes were surfaced.";

RemovalDelta[c_?CoreQ, mechId_String] :=
  Module[{projected, before, after},
    projected = RemoveAndProject[c, mechId];
    If[projected === $Failed, Return[$Failed]];

    before = First @ c;
    after  = First @ projected;

    <|
      "Removed"           -> mechId,
      "ConstraintsDropped" ->
        Complement[Keys[before["Constraints"]],
                   Keys[Lookup[after, "Constraints", <||>]]],
      "MechanismsDegraded" ->
        Select[Keys[Lookup[after, "Mechanisms", <||>]],
               TrueQ[field[Lookup[after, "Mechanisms"][#], "Degraded"]] &],
      "FailureModesSurfaced" ->
        Complement[
          field[#, "Id"] & /@ Lookup[after, "FailureModes", {}],
          field[#, "Id"] & /@ Lookup[before, "FailureModes", {}]
        ]
    |>
  ];


(* ============================================================
   7. QUERY 4 — Recursive self-application failure-mode detection

   The methodology is a corpus item. Run the same algebra on it
   and see what surfaces.

   The interesting outputs are:
     - selfTransfers:   places where the methodology is internally
                        self-similar (kernel-shape matches with
                        itself across distinct mechanisms)
     - removalProfiles: which mechanisms are load-bearing vs
                        ornamental, computationally
     - latentFailures:  failure modes the methodology contains but
                        does not name in its own self-description
   ============================================================ *)

RecursiveAnalysis::usage =
  "RecursiveAnalysis[methodologyCore] runs all three substantive " <>
  "queries on the methodology's own structural core and returns an " <>
  "Association summarising what the algebra surfaces about itself.";

RecursiveAnalysis[c_?CoreQ] :=
  Module[{selfTransfers, removalProfiles, latentFailures, mechIds},

    mechIds = Keys @ field[c, "Mechanisms"];

    (* Self-transfers: places where mechanisms in the methodology
       match other mechanisms in the methodology. Filter out the
       trivial diagonal (m matches itself). *)
    selfTransfers = DeleteCases[
      TransferCandidates[c, c],
      kv_Association /; kv["From"] === kv["To"]
    ];

    (* Removal profiles: for each mechanism, what does the algebra
       predict happens when it is removed? *)
    removalProfiles = Association @ Map[
      # -> RemovalDelta[c, #] &,
      mechIds
    ];

    (* Latent failures: failure modes that are surfaced by removals
       but were not declared in the core's own FailureModes list. *)
    latentFailures = DeleteDuplicates @ Flatten @ Map[
      Lookup[#, "FailureModesSurfaced", {}] &,
      Values @ removalProfiles
    ];

    <|
      "SelfTransfers"       -> selfTransfers,
      "RemovalProfiles"     -> removalProfiles,
      "LatentFailures"      -> latentFailures,
      "LoadBearingMechanisms" ->
        Select[mechIds,
          Length[Lookup[removalProfiles[#], "ConstraintsDropped", {}]] +
          Length[Lookup[removalProfiles[#], "MechanismsDegraded", {}]] >= 1 &
        ]
    |>
  ];


(* ============================================================
   8. PRETTY-PRINTING

   Helpers for rendering query output in a human-readable form
   in a notebook session.
   ============================================================ *)

FormatTransferCandidates[candidates_List] :=
  Grid[
    Prepend[
      {#["From"], "->", #["To"],
       field[#, "FromDomain"] <> " -> " <> field[#, "ToDomain"],
       NumberForm[field[#, "Confidence"], {3, 2}],
       Row[{StringRiffle[field[#, "Basis"], "; "]}]} & /@ candidates,
      Style[#, Bold] & /@ {"From", "", "To", "Domains", "Conf.", "Basis"}
    ],
    Frame -> All,
    Alignment -> Left,
    Background -> {None, {LightGray, {None}}},
    BaseStyle -> "Text"
  ];


FormatRemovalDelta[delta_Association] :=
  Column[{
    Style["Removal: " <> delta["Removed"], Bold, 14],
    Row[{"Constraints dropped: ",
         If[Length[delta["ConstraintsDropped"]] == 0,
           Style["(none)", Gray],
           StringRiffle[delta["ConstraintsDropped"], ", "]]}],
    Row[{"Mechanisms degraded: ",
         If[Length[delta["MechanismsDegraded"]] == 0,
           Style["(none)", Gray],
           StringRiffle[delta["MechanismsDegraded"], ", "]]}],
    Row[{"Failure modes surfaced: ",
         If[Length[delta["FailureModesSurfaced"]] == 0,
           Style["(none)", Gray],
           StringRiffle[delta["FailureModesSurfaced"], ", "]]}]
  }, Spacings -> 0.5];


(* ============================================================
   END OF PACKAGE
   ============================================================ *)

Print["FalseWork algebra loaded. Types defined: Kernel, Comma, ",
      "Mechanism, Constraint, FailureMode, Core. ",
      "Queries available: FindWorksByType, TransferCandidates, ",
      "RemoveAndProject, RecursiveAnalysis."];
