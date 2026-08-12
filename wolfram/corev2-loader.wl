(* ::Package:: *)

(* ============================================================
   CoreV2 Loader - machine-fed corpus bridge (V2, August 2026)
   ------------------------------------------------------------
   Loads CoreV2 JSON files (typed dependency graphs transduced
   from falsework.dev structural profiles; specification:
   papers/computable-criticism-roadmap.md sec. 5.1 in the papers
   repository) into the FalseWork algebra's Core[...] type,
   revalidates the CoreV2 contract inside Wolfram Language, and
   supplies the fixpoint removal executor (roadmap sec. 5.2)
   plus the machine-checkable assertion audit.

   Requires falsework-algebra.wl to be loaded first (uses
   MakeKernel, MakeComma-free kernels, MakeMechanism,
   MakeConstraint, MakeFailureMode, MakeCore, field,
   StandardTransferConditions, CoreQ).

   Author:    Chris Brink (independent), 2026
   Reference: https://github.com/thefalsework/papers

   ------------------------------------------------------------
   MAPPING: CoreV2 JSON -> Core[...]
   ------------------------------------------------------------
   | CoreV2 field            | Destination                                   |
   |-------------------------|-----------------------------------------------|
   | schema ("v2")           | Core "SchemaVersion"                          |
   | work.title              | Core "Title"                                  |
   | work.creator            | Core "Author"                                 |
   | work.domain             | Core "Domain", Kernel "Domain"                |
   | work.practice           | Core "Practice"                               |
   | principle               | Kernel "Operation", Core "GenerativePrinciple"|
   | nodes (both kinds)      | Core "Mechanisms" (id -> Mechanism, with      |
   |                         |   "NodeKind" preserving mechanism/element)    |
   | node.label/description/ | Mechanism "Label"/"Description"/              |
   |   confidence/evidence   |   "Confidence"/"Evidence"                     |
   | node.rules /            | Mechanism "Rules" / "RuleViolations"          |
   |   rule_violations       |                                               |
   | edges                   | Core "Edges" (raw, canonical for executor)    |
   |                         |   + Core "Constraints" (one Constraint per    |
   |                         |   edge, for V1 query compatibility)           |
   | failure_modes           | Core "DeclaredFailureModes" (id -> FailureMode|
   |                         |   objects with machine conditions);           |
   |                         |   Core "FailureModes" starts EMPTY (it is the |
   |                         |   manifest container that removal populates,  |
   |                         |   per V1 surfacing semantics)                 |
   | asserted_removal_tests  | Core "AssertedRemovalTests" + per-node        |
   |                         |   Mechanism "AssertedRemovalTest"             |
   | provenance              | Core "Provenance", Kernel "Provenance"        |

   ------------------------------------------------------------
   FOUR DESIGN DECISIONS (full statements in wolfram/README.md
   and design-notes.md)
   ------------------------------------------------------------
   1. NO FABRICATED COMMA. Machine work-kernels carry
      "CommaStatus" -> "underived" and NO "Comma" field. The
      transduction has not derived an irreducibility witness,
      so none is asserted. Consequence: CommaShapeMatchQ never
      fires on machine cores and the Q2 confidence ceiling is
      0.68 (type+cross-domain), not 0.92. That measured silence
      is a finding, and it is exactly what the comma-shape
      graduation (email artifact 2) is for.
   2. DERIVED STRUCTURAL TYPES. Machine mechanisms carry no
      curated type taxonomy. Mechanism "Type" is computed from
      the graph: the sorted sets of edge kinds the node
      participates in, outgoing and incoming
      ("Sig[out:...|in:...]"). Two nodes share a Type iff they
      occupy the same dependency-role profile. Crude, but
      derived rather than hand-planted - the opposite failure
      mode from V1's curated vocabulary.
   3. FIXPOINT EXECUTOR. V1's StandardRemovalSignature is
      single-step. The roadmap (sec. 5.2) mandates cascade to
      fixpoint. Edge-kind semantics under removal of node A:
        - X requires A   : X joins the removed set (cascades)
        - A amplifies X  : X survives, marked Degraded
                           ("amplifier_removed:A")
        - A certifies X  : X survives, marked Degraded
                           ("certifier_removed:A")
        - A contradicts X (either direction): X survives,
                           marked Degraded ("tension_released:A")
      Edges with a removed endpoint are dropped. A declared
      failure mode is Triggered when its condition's removed
      set is contained in the computed closure and it names no
      violated rules; PartiallySatisfied when its removed part
      is contained but it also names violated rules (rule
      violation is not evaluable under removal semantics -
      stated, not fudged); NotEvaluableUnderRemoval when it
      names only violated rules.
   4. AUDIT SPLIT. collapses_to claims are machine-checked: a
      node the failure mode claims survives but the cascade
      removes is a contradiction, reported. asserted_removal_
      tests are prose; they are presented beside the computed
      cascade for human adjudication, never string-matched.
      Namespacing note: Mechanism "Compatibility" entries are
      prefixed with the core slug so that V1's predicate-2
      (compatibility intersection) can never fire spuriously
      across works that share local node ids like "M1"; within
      a single core (self-transfer) shared dependencies still
      intersect meaningfully.
   ============================================================ *)


ClearAll[CoreV2SchemaErrors, CoreV2IntegrityReport, CoreV2NodeSignature,
         CoreV2Slug, CoreV2ToCore, cascadeCompute, CascadeDelta,
         CascadeProject, RemovalAssertionAudit, LoadCoreV2,
         LoadCoreV2Corpus];

$CoreV2NodeKinds        = {"mechanism", "element"};
$CoreV2EdgeKinds        = {"requires", "amplifies", "certifies", "contradicts"};
$CoreV2ConfidenceLevels = {"high", "medium", "low"};


(* ============================================================
   1. SCHEMA REVALIDATION (in-WL mirror of lib/corev2/schema.ts)

   The TypeScript validator ran at transduction time; nothing
   about that survives the trip through a JSON file and a
   network fetch. Everything is re-checked here. Length bounds
   that exist purely to shape LLM generation (e.g. label <= 120
   chars) are not re-enforced; structural requirements are.
   ============================================================ *)

CoreV2SchemaErrors[a_Association] := Module[
  {errs = {}, work, nodes, edges, fms, tests, prov},

  If[Lookup[a, "schema"] =!= "v2",
    AppendTo[errs, "schema: must be exactly \"v2\""]];

  work = Lookup[a, "work"];
  If[!AssociationQ[work],
    AppendTo[errs, "work: missing or not an object"],
    If[!StringQ[Lookup[work, "title"]] || Lookup[work, "title"] === "",
      AppendTo[errs, "work.title: nonempty string required"]];
    If[!StringQ[Lookup[work, "domain"]] || Lookup[work, "domain"] === "",
      AppendTo[errs, "work.domain: nonempty string required"]];
  ];

  If[!StringQ[Lookup[a, "principle"]] ||
     StringLength[Lookup[a, "principle", ""]] < 12,
    AppendTo[errs, "principle: string of at least 12 characters required"]];

  nodes = Lookup[a, "nodes"];
  Which[
    !ListQ[nodes],
      AppendTo[errs, "nodes: list required"],
    Length[nodes] < 3,
      AppendTo[errs, "nodes: at least 3 required"],
    True,
      Do[
        Module[{n = nodes[[i]], tag = "nodes[[" <> ToString[i] <> "]]"},
          If[!AssociationQ[n],
            AppendTo[errs, tag <> ": not an object"],
            If[!StringQ[Lookup[n, "id"]] ||
               !StringMatchQ[Lookup[n, "id", ""],
                 RegularExpression["[A-Za-z][A-Za-z0-9_]{0,63}"]],
              AppendTo[errs, tag <> ".id: malformed"]];
            If[!MemberQ[$CoreV2NodeKinds, Lookup[n, "kind"]],
              AppendTo[errs, tag <> ".kind: must be mechanism|element"]];
            If[!StringQ[Lookup[n, "label"]] || Lookup[n, "label"] === "",
              AppendTo[errs, tag <> ".label: nonempty string required"]];
            If[!StringQ[Lookup[n, "description"]] ||
               StringLength[Lookup[n, "description", ""]] < 10,
              AppendTo[errs, tag <> ".description: string of >= 10 chars required"]];
            If[!MemberQ[$CoreV2ConfidenceLevels, Lookup[n, "confidence"]],
              AppendTo[errs, tag <> ".confidence: must be high|medium|low"]];
            If[!MatchQ[Lookup[n, "evidence", {}], {___String}],
              AppendTo[errs, tag <> ".evidence: list of strings required"]];
            If[!MatchQ[Lookup[n, "rules", {}], {___String}],
              AppendTo[errs, tag <> ".rules: list of strings required"]];
            If[!MatchQ[Lookup[n, "rule_violations", {}], {___String}],
              AppendTo[errs, tag <> ".rule_violations: list of strings required"]];
          ]
        ], {i, Length[nodes]}]
  ];

  edges = Lookup[a, "edges"];
  Which[
    !ListQ[edges],
      AppendTo[errs, "edges: list required"],
    Length[edges] < 2,
      AppendTo[errs, "edges: at least 2 required"],
    True,
      Do[
        Module[{e = edges[[i]], tag = "edges[[" <> ToString[i] <> "]]"},
          If[!AssociationQ[e],
            AppendTo[errs, tag <> ": not an object"],
            If[!StringQ[Lookup[e, "from"]],
              AppendTo[errs, tag <> ".from: string required"]];
            If[!StringQ[Lookup[e, "to"]],
              AppendTo[errs, tag <> ".to: string required"]];
            If[!MemberQ[$CoreV2EdgeKinds, Lookup[e, "kind"]],
              AppendTo[errs, tag <> ".kind: must be requires|amplifies|certifies|contradicts"]];
            If[!StringQ[Lookup[e, "rationale"]] ||
               StringLength[Lookup[e, "rationale", ""]] < 8,
              AppendTo[errs, tag <> ".rationale: string of >= 8 chars required"]];
          ]
        ], {i, Length[edges]}]
  ];

  fms = Lookup[a, "failure_modes"];
  Which[
    !ListQ[fms],
      AppendTo[errs, "failure_modes: list required"],
    Length[fms] < 1,
      AppendTo[errs, "failure_modes: at least 1 required"],
    True,
      Do[
        Module[{fm = fms[[i]], tag = "failure_modes[[" <> ToString[i] <> "]]",
                cond, rem, viol, coll},
          If[!AssociationQ[fm],
            AppendTo[errs, tag <> ": not an object"],
            If[!StringQ[Lookup[fm, "id"]] ||
               !StringMatchQ[Lookup[fm, "id", ""], RegularExpression["F\\d+"]],
              AppendTo[errs, tag <> ".id: must match F<number>"]];
            cond = Lookup[fm, "condition"];
            If[!AssociationQ[cond],
              AppendTo[errs, tag <> ".condition: object required"],
              rem  = Lookup[cond, "removed", {}];
              viol = Lookup[cond, "violated", {}];
              If[!MatchQ[rem, {___String}],
                AppendTo[errs, tag <> ".condition.removed: list of strings required"]];
              If[!MatchQ[viol, {___String}],
                AppendTo[errs, tag <> ".condition.violated: list of strings required"]];
              If[rem === {} && viol === {},
                AppendTo[errs, tag <> ".condition: must name at least one removed node or violated rule"]];
            ];
            If[!StringQ[Lookup[fm, "consequence"]] ||
               StringLength[Lookup[fm, "consequence", ""]] < 8,
              AppendTo[errs, tag <> ".consequence: string of >= 8 chars required"]];
            coll = Lookup[fm, "collapses_to", Missing["NotStated"]];
            If[!MissingQ[coll] && coll =!= "nothing" && !MatchQ[coll, {___String}],
              AppendTo[errs, tag <> ".collapses_to: must be \"nothing\" or a list of node ids"]];
          ]
        ], {i, Length[fms]}]
  ];

  tests = Lookup[a, "asserted_removal_tests"];
  If[!AssociationQ[tests],
    AppendTo[errs, "asserted_removal_tests: object required"],
    If[!AllTrue[Values[tests], StringQ],
      AppendTo[errs, "asserted_removal_tests: all values must be strings"]]
  ];

  prov = Lookup[a, "provenance"];
  If[!AssociationQ[prov],
    AppendTo[errs, "provenance: object required"],
    Scan[
      If[!StringQ[Lookup[prov, #]] || Lookup[prov, #] === "",
        AppendTo[errs, "provenance." <> # <> ": nonempty string required"]] &,
      {"model", "prompt_version", "generated_at"}]
  ];

  errs
];


(* ============================================================
   2. INTEGRITY REVALIDATION (in-WL mirror of
      validateCoreV2Integrity in lib/corev2/schema.ts)

   Errors make the graph unusable for computation; warnings are
   suspicious but tolerable properties, surfaced for review.
   Call only on associations that pass CoreV2SchemaErrors.
   ============================================================ *)

CoreV2IntegrityReport[a_Association] := Module[
  {errs = {}, warns = {}, nodes, edges, fms, ids, idQ, mechIds, dupes,
   seenEdges, tests, ruleUniverse, connected, adj, start, seen, queue,
   cur, unreached},

  nodes = Lookup[a, "nodes", {}];
  edges = Lookup[a, "edges", {}];
  fms   = Lookup[a, "failure_modes", {}];
  tests = Lookup[a, "asserted_removal_tests", <||>];

  ids   = Lookup[#, "id"] & /@ nodes;
  dupes = Keys@Select[Counts[ids], # > 1 &];
  Scan[AppendTo[errs, "duplicate node id: " <> #] &, dupes];
  idQ = Association[(# -> True) & /@ DeleteDuplicates[ids]];

  mechIds = Lookup[#, "id"] & /@ Select[nodes, Lookup[#, "kind"] === "mechanism" &];
  If[mechIds === {}, AppendTo[errs, "graph has no mechanism nodes"]];

  seenEdges = <||>;
  Do[
    Module[{f = Lookup[e, "from"], t = Lookup[e, "to"], k = Lookup[e, "kind"], key},
      If[!KeyExistsQ[idQ, f],
        AppendTo[errs, "edge references missing node: " <> f <> " (" <> k <> " -> " <> t <> ")"]];
      If[!KeyExistsQ[idQ, t],
        AppendTo[errs, "edge references missing node: " <> t <> " (" <> f <> " " <> k <> " ->)"]];
      If[f === t, AppendTo[errs, "self-loop edge on node: " <> f]];
      key = f <> "|" <> k <> "|" <> t;
      If[KeyExistsQ[seenEdges, key],
        AppendTo[errs, "duplicate edge: " <> f <> " " <> k <> " " <> t]];
      AssociateTo[seenEdges, key -> True];
    ], {e, edges}];

  Do[
    Module[{cond = Lookup[fm, "condition", <||>], coll},
      Scan[
        If[!KeyExistsQ[idQ, #],
          AppendTo[errs, "failure " <> Lookup[fm, "id", "?"] <>
            " condition references missing node: " <> #]] &,
        Lookup[cond, "removed", {}]];
      coll = Lookup[fm, "collapses_to", Missing["NotStated"]];
      If[ListQ[coll],
        Scan[
          If[!KeyExistsQ[idQ, #],
            AppendTo[errs, "failure " <> Lookup[fm, "id", "?"] <>
              " collapses_to references missing node: " <> #]] &,
          coll]];
    ], {fm, fms}];

  Scan[
    If[!KeyExistsQ[idQ, #],
      AppendTo[errs, "asserted_removal_tests keys missing node: " <> #]] &,
    Keys[tests]];

  (* --- Warnings --- *)

  ruleUniverse = DeleteDuplicates@Flatten[
    {Lookup[#, "rules", {}], Lookup[#, "rule_violations", {}]} & /@ nodes];
  Do[
    Scan[
      If[!MemberQ[ruleUniverse, #],
        AppendTo[warns, "failure " <> Lookup[fm, "id", "?"] <>
          " cites violated rule not declared on any node: \"" <> # <> "\""]] &,
      Lookup[Lookup[fm, "condition", <||>], "violated", {}]],
    {fm, fms}];

  Scan[
    If[!KeyExistsQ[tests, #],
      AppendTo[warns, "mechanism " <> # <>
        " has no asserted removal test (audit will have nothing to compare)"]] &,
    mechIds];

  connected = DeleteDuplicates@Flatten[{Lookup[#, "from"], Lookup[#, "to"]} & /@ edges];
  Scan[
    If[!MemberQ[connected, #], AppendTo[warns, "isolated node (no edges): " <> #]] &,
    Keys[idQ]];

  If[Length[nodes] > 0 && Length[edges] > 0,
    adj = <||>;
    Do[
      Module[{f = Lookup[e, "from"], t = Lookup[e, "to"]},
        If[KeyExistsQ[idQ, f] && KeyExistsQ[idQ, t],
          AssociateTo[adj, f -> Append[Lookup[adj, f, {}], t]];
          AssociateTo[adj, t -> Append[Lookup[adj, t, {}], f]];
        ]
      ], {e, edges}];
    start = First[ids];
    seen  = <|start -> True|>;
    queue = {start};
    While[queue =!= {},
      cur   = First[queue];
      queue = Rest[queue];
      Scan[
        If[!KeyExistsQ[seen, #],
          AssociateTo[seen, # -> True]; AppendTo[queue, #]] &,
        Lookup[adj, cur, {}]]
    ];
    unreached = Select[Keys[idQ], !KeyExistsQ[seen, #] &];
    If[unreached =!= {},
      AppendTo[warns, "graph is not weakly connected; unreached from " <>
        start <> ": " <> StringRiffle[unreached, ", "]]]
  ];

  <|"Errors" -> errs, "Warnings" -> warns|>
];


(* ============================================================
   3. DERIVED STRUCTURAL TYPE (design decision 2)
   ============================================================ *)

CoreV2NodeSignature::usage =
  "CoreV2NodeSignature[nodeId, edges] returns the node's derived " <>
  "structural type: the sorted sets of edge kinds it participates " <>
  "in, outgoing and incoming. Computed from the graph, never " <>
  "asserted by the LLM.";

CoreV2NodeSignature[nodeId_String, edges_List] := Module[{out, in},
  out = Union[Lookup[#, "kind"] & /@ Select[edges, Lookup[#, "from"] === nodeId &]];
  in  = Union[Lookup[#, "kind"] & /@ Select[edges, Lookup[#, "to"] === nodeId &]];
  "Sig[out:" <> If[out === {}, "-", StringRiffle[out, ","]] <>
    "|in:" <> If[in === {}, "-", StringRiffle[in, ","]] <> "]"
];


(* ============================================================
   4. CONSTRUCTION: CoreV2 JSON association -> Core[...]
   ============================================================ *)

CoreV2Slug[a_Association] := Module[{t, pid},
  t = ToLowerCase[Lookup[Lookup[a, "work", <||>], "title", "untitled"]];
  t = StringReplace[t, Except[LetterCharacter | DigitCharacter] -> "-"];
  t = StringReplace[t, "-" .. -> "-"];
  t = StringTrim[t, "-" ..];
  pid = Lookup[Lookup[a, "provenance", <||>], "source_profile_id", Missing["NotRecorded"]];
  If[StringQ[pid] && StringLength[pid] >= 8, t <> "-" <> StringTake[pid, 8], t]
];

CoreV2ToCore::usage =
  "CoreV2ToCore[assoc] constructs a Core[...] from a validated " <>
  "CoreV2 JSON association, per the mapping table in this file's " <>
  "header. Call only after CoreV2SchemaErrors and " <>
  "CoreV2IntegrityReport return no errors.";

CoreV2ToCore[a_Association] := Module[
  {slug, work, edges, nodes, tests, kernel, requiresOf, certifiersOf,
   fmObjs, declaredAssoc, singleNodeFmFor, mechs, constraints},

  work  = a["work"];
  edges = a["edges"];
  nodes = a["nodes"];
  tests = Lookup[a, "asserted_removal_tests", <||>];
  slug  = CoreV2Slug[a];

  (* Work-level kernel. NO Comma field: design decision 1. *)
  kernel = MakeKernel[
    "Slug"        -> "work-kernel:" <> slug,
    "Level"       -> "work",
    "Domain"      -> work["domain"],
    "Operation"   -> a["principle"],
    "CommaStatus" -> "underived",
    "Provenance"  -> Lookup[a, "provenance", <||>]
  ];

  requiresOf[n_String] := Union[
    Lookup[#, "to"] & /@
      Select[edges, Lookup[#, "from"] === n && Lookup[#, "kind"] === "requires" &]];
  certifiersOf[n_String] := Union[
    Lookup[#, "from"] & /@
      Select[edges, Lookup[#, "to"] === n && Lookup[#, "kind"] === "certifies" &]];

  fmObjs = Map[
    Function[fm, MakeFailureMode[
      "Id" -> fm["id"],
      "TriggeredBy" -> Join[
        ("removal_of_" <> #) & /@ Lookup[Lookup[fm, "condition", <||>], "removed", {}],
        ("violation_of_" <> #) & /@ Lookup[Lookup[fm, "condition", <||>], "violated", {}]],
      "Signature"   -> fm["consequence"],
      "Condition"   -> Lookup[fm, "condition", <||>],
      "CollapsesTo" -> Lookup[fm, "collapses_to", Missing["NotStated"]]
    ]], a["failure_modes"]];
  declaredAssoc = Association[(field[#, "Id"] -> #) & /@ fmObjs];

  (* A mechanism-attached FailureMode (V1 introspection channel) only
     when the declared condition is exactly this node's removal. The
     executor is the canonical evaluation path for every condition. *)
  singleNodeFmFor[n_String] := SelectFirst[a["failure_modes"],
    (Lookup[Lookup[#, "condition", <||>], "removed", {}] === {n} &&
     Lookup[Lookup[#, "condition", <||>], "violated", {}] === {}) &];

  mechs = Association@Map[
    Function[node, node["id"] -> Module[{fm = singleNodeFmFor[node["id"]], base},
      base = {
        "Id"          -> node["id"],
        "Kernel"      -> kernel,
        "Type"        -> CoreV2NodeSignature[node["id"], edges],
        "NodeKind"    -> node["kind"],
        "Label"       -> node["label"],
        "Domain"      -> work["domain"],
        "Description" -> node["description"],
        "Confidence"  -> node["confidence"],
        "Evidence"    -> Lookup[node, "evidence", {}],
        "Rules"       -> Lookup[node, "rules", {}],
        "RuleViolations" -> Lookup[node, "rule_violations", {}],
        (* Namespaced: see design decision 4 (namespacing note). *)
        "Compatibility" ->
          ((slug <> ":" <> #) & /@ Union[requiresOf[node["id"]], certifiersOf[node["id"]]]),
        "RemovalSignature" ->
          With[{nid = node["id"]}, CascadeProject[#, {nid}] &],
        "TransferConditions" -> StandardTransferConditions[],
        "AssertedRemovalTest" -> Lookup[tests, node["id"], Missing["NotAsserted"]]
      };
      If[!MissingQ[fm],
        AppendTo[base, "FailureMode" -> declaredAssoc[fm["id"]]]];
      MakeMechanism @@ base
    ]], nodes];

  constraints = Association@MapIndexed[
    Function[{e, idx}, With[{cid = "edge" <> ToString[First@idx]},
      cid -> MakeConstraint[
        "Id"           -> cid,
        "Type"         -> e["kind"],
        "From"         -> e["from"],
        "To"           -> e["to"],
        "DependedOnBy" -> {e["from"], e["to"]},
        "Rationale"    -> e["rationale"]
      ]]], edges];

  MakeCore[
    "Id"                   -> slug,
    "SchemaVersion"        -> "v2",
    "Title"                -> work["title"],
    "Author"               -> Lookup[work, "creator", Missing["NotRecorded"]],
    "Domain"               -> work["domain"],
    "Practice"             -> Lookup[work, "practice", Missing["NotRecorded"]],
    "Kernel"               -> kernel,
    "Mechanisms"           -> mechs,
    "Constraints"          -> constraints,
    "Edges"                -> edges,
    "FailureModes"         -> {},
    "DeclaredFailureModes" -> declaredAssoc,
    "FailureModesRaw"      -> a["failure_modes"],
    "AssertedRemovalTests" -> tests,
    "GenerativePrinciple"  -> a["principle"],
    "Provenance"           -> Lookup[a, "provenance", <||>]
  ]
];


(* ============================================================
   5. FIXPOINT REMOVAL EXECUTOR (roadmap sec. 5.2; design
      decision 3)
   ============================================================ *)

cascadeCompute[c_?CoreQ, seed_List] := Module[
  {a, edges, mechs, nodeIds, invalid, removedVia, changed, r,
   degradeBasis, addBasis, rawFms, statuses, triggered, claimAudit,
   survivors, keptEdges, keptConstraints, newMechs, declared,
   surfacedObjs},

  a       = First@c;
  edges   = Lookup[a, "Edges", {}];
  mechs   = Lookup[a, "Mechanisms", <||>];
  nodeIds = Keys[mechs];

  invalid = Complement[seed, nodeIds];
  If[invalid =!= {}, Return[$Failed]];

  (* Fixpoint: X joins the removed set when X requires a removed node.
     Each cascade entry records the edge that caused it. *)
  removedVia = Association[(# -> "seed") & /@ seed];
  changed = True;
  While[changed,
    changed = False;
    Do[
      If[Lookup[e, "kind"] === "requires" &&
         KeyExistsQ[removedVia, Lookup[e, "to"]] &&
         !KeyExistsQ[removedVia, Lookup[e, "from"]],
        AssociateTo[removedVia,
          Lookup[e, "from"] -> ("requires " <> Lookup[e, "to"] <> " (removed)")];
        changed = True
      ], {e, edges}]
  ];
  r = Sort@Keys[removedVia];

  (* Survivor markings per edge-kind semantics. *)
  degradeBasis = <||>;
  addBasis[node_String, reason_String] :=
    AssociateTo[degradeBasis, node -> Append[Lookup[degradeBasis, node, {}], reason]];
  Do[
    Module[{f = Lookup[e, "from"], t = Lookup[e, "to"], k = Lookup[e, "kind"]},
      Which[
        k === "amplifies" && KeyExistsQ[removedVia, f] && !KeyExistsQ[removedVia, t],
          addBasis[t, "amplifier_removed:" <> f],
        k === "certifies" && KeyExistsQ[removedVia, f] && !KeyExistsQ[removedVia, t],
          addBasis[t, "certifier_removed:" <> f],
        k === "contradicts" && KeyExistsQ[removedVia, f] && !KeyExistsQ[removedVia, t],
          addBasis[t, "tension_released:" <> f],
        k === "contradicts" && KeyExistsQ[removedVia, t] && !KeyExistsQ[removedVia, f],
          addBasis[f, "tension_released:" <> t]
      ]
    ], {e, edges}];

  (* Declared failure conditions, evaluated against the closure. *)
  rawFms = Lookup[a, "FailureModesRaw", {}];
  statuses = Association@Map[
    Function[fm, Module[{cond, rem, viol},
      cond = Lookup[fm, "condition", <||>];
      rem  = Lookup[cond, "removed", {}];
      viol = Lookup[cond, "violated", {}];
      Lookup[fm, "id"] -> Which[
        rem =!= {} && SubsetQ[r, rem] && viol === {},  "Triggered",
        rem =!= {} && SubsetQ[r, rem] && viol =!= {},  "PartiallySatisfied",
        rem === {},                                    "NotEvaluableUnderRemoval",
        True,                                          "NotTriggered"
      ]
    ]], rawFms];
  triggered = Sort@Keys@Select[statuses, # === "Triggered" &];

  (* Machine-checkable claim audit: a collapses_to entry the cascade
     removes contradicts the failure mode's own survival claim. *)
  claimAudit = Association@Map[
    Function[fm, Lookup[fm, "id"] -> Intersection[Lookup[fm, "collapses_to"], r]],
    Select[rawFms,
      MemberQ[triggered, Lookup[#, "id"]] &&
      ListQ[Lookup[#, "collapses_to", Missing["NotStated"]]] &]];

  survivors = Complement[nodeIds, r];
  keptEdges = Select[edges,
    !KeyExistsQ[removedVia, Lookup[#, "from"]] &&
    !KeyExistsQ[removedVia, Lookup[#, "to"]] &];
  keptConstraints = Association@KeyValueMap[
    Function[{cid, cobj},
      If[KeyExistsQ[removedVia, field[cobj, "From"]] ||
         KeyExistsQ[removedVia, field[cobj, "To"]],
        Nothing, cid -> cobj]],
    Lookup[a, "Constraints", <||>]];

  newMechs = Association@KeyValueMap[
    Function[{mid, mobj},
      Which[
        KeyExistsQ[removedVia, mid], Nothing,
        KeyExistsQ[degradeBasis, mid],
          mid -> Mechanism[Join[First@mobj,
            <|"Degraded" -> True, "DegradationBasis" -> degradeBasis[mid]|>]],
        True, mid -> mobj
      ]], mechs];

  declared     = Lookup[a, "DeclaredFailureModes", <||>];
  surfacedObjs = (declared[#]) & /@ triggered;

  <|
    "Seed"             -> Sort[seed],
    "RemovedClosure"   -> r,
    "CascadeVia"       -> removedVia,
    "Degraded"         -> degradeBasis,
    "Survivors"        -> Sort[survivors],
    "ConstraintsDropped" ->
      Sort@Complement[Keys@Lookup[a, "Constraints", <||>], Keys[keptConstraints]],
    "FailureStatuses"  -> statuses,
    "TriggeredFailures" -> triggered,
    "PartiallySatisfiedFailures" ->
      Sort@Keys@Select[statuses, # === "PartiallySatisfied" &],
    "NotEvaluableFailures" ->
      Sort@Keys@Select[statuses, # === "NotEvaluableUnderRemoval" &],
    "SurvivorClaimContradictions" -> Select[claimAudit, # =!= {} &],
    "ProjectedCore" -> Core[<|a,
      "Mechanisms"   -> newMechs,
      "Constraints"  -> keptConstraints,
      "Edges"        -> keptEdges,
      "FailureModes" ->
        DeleteDuplicates@Join[Lookup[a, "FailureModes", {}], surfacedObjs]
    |>]
  |>
];

CascadeDelta::usage =
  "CascadeDelta[core, seed] removes the seed node(s), cascades " <>
  "requires-dependencies to fixpoint, and returns the full report: " <>
  "removed closure with per-node causes, degraded survivors with " <>
  "bases, dropped edges, failure-condition statuses, and " <>
  "survivor-claim contradictions.";

CascadeDelta[c_?CoreQ, seed_List]   := cascadeCompute[c, seed];
CascadeDelta[c_?CoreQ, seed_String] := cascadeCompute[c, {seed}];

CascadeProject::usage =
  "CascadeProject[core, seed] returns the projected core after " <>
  "fixpoint removal of the seed node(s). This function is attached " <>
  "as every machine mechanism's RemovalSignature, so the V1 query " <>
  "RemoveAndProject dispatches to it automatically on machine cores.";

CascadeProject[c_?CoreQ, seed_List] :=
  With[{res = cascadeCompute[c, seed]},
    If[AssociationQ[res], res["ProjectedCore"], $Failed]];
CascadeProject[c_?CoreQ, seed_String] := CascadeProject[c, {seed}];


(* ============================================================
   6. ASSERTION AUDIT (design decision 4)
   ============================================================ *)

RemovalAssertionAudit::usage =
  "RemovalAssertionAudit[core] runs the fixpoint cascade for every " <>
  "mechanism-kind node and returns, per node: the transduction's " <>
  "asserted removal test (prose, for human adjudication - never " <>
  "string-matched), the computed cascade, degraded survivors, " <>
  "triggered failures, and any survivor-claim contradictions " <>
  "(machine-checked).";

RemovalAssertionAudit[c_?CoreQ] := Module[{a, mechs, mechNodes},
  a = First@c;
  mechs = Lookup[a, "Mechanisms", <||>];
  mechNodes = Select[Keys[mechs],
    field[mechs[#], "NodeKind"] === "mechanism" &];
  Association@Map[
    Function[mid, mid -> Module[{d = cascadeCompute[c, {mid}]},
      <|
        "Asserted"          -> field[mechs[mid], "AssertedRemovalTest"],
        "ComputedCascade"   -> Complement[d["RemovedClosure"], {mid}],
        "Degraded"          -> Sort@Keys[d["Degraded"]],
        "TriggeredFailures" -> d["TriggeredFailures"],
        "SurvivorClaimContradictions" -> d["SurvivorClaimContradictions"]
      |>]],
    mechNodes]
];


(* ============================================================
   7. CORPUS LOADING
   ============================================================ *)

LoadCoreV2::usage =
  "LoadCoreV2[source] imports one CoreV2 JSON file (URL or local " <>
  "path), revalidates schema and integrity inside WL, and returns " <>
  "an association with Source, Raw, SchemaErrors, IntegrityErrors, " <>
  "IntegrityWarnings, and Core ($Failed unless everything passes).";

LoadCoreV2[src_String] := Module[{raw, schemaErrs, integ, core},
  raw = Quiet@Import[src, "RawJSON"];
  If[raw === $Failed || !AssociationQ[raw],
    Return[<|"Source" -> src, "Raw" -> Missing["ImportFailed"],
             "SchemaErrors" -> {"import failed or not a JSON object"},
             "IntegrityErrors" -> {}, "IntegrityWarnings" -> {},
             "Core" -> $Failed|>]];
  schemaErrs = CoreV2SchemaErrors[raw];
  integ = If[schemaErrs === {},
    CoreV2IntegrityReport[raw],
    <|"Errors" -> {}, "Warnings" -> {}|>];
  core = If[schemaErrs === {} && integ["Errors"] === {},
    CoreV2ToCore[raw], $Failed];
  <|"Source" -> src, "Raw" -> raw, "SchemaErrors" -> schemaErrs,
    "IntegrityErrors" -> integ["Errors"],
    "IntegrityWarnings" -> integ["Warnings"],
    "Core" -> core|>
];

LoadCoreV2Corpus::usage =
  "LoadCoreV2Corpus[base] reads index.json under base (URL or local " <>
  "directory, no trailing slash) and loads every listed CoreV2 file. " <>
  "Returns the list of LoadCoreV2 result associations.";

LoadCoreV2Corpus[base_String] := Module[{b, manifest, files},
  b = If[StringEndsQ[base, "/"], StringDrop[base, -1], base];
  manifest = Quiet@Import[b <> "/index.json", "RawJSON"];
  If[manifest === $Failed || !AssociationQ[manifest], Return[$Failed]];
  files = Lookup[#, "file"] & /@ Lookup[manifest, "entries", {}];
  LoadCoreV2[b <> "/" <> #] & /@ files
];


Print["CoreV2 loader ready. Functions: LoadCoreV2Corpus, LoadCoreV2, ",
      "CoreV2SchemaErrors, CoreV2IntegrityReport, CoreV2ToCore, ",
      "CascadeDelta, CascadeProject, RemovalAssertionAudit."];
