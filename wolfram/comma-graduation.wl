(* ::Package:: *)

(* ============================================================
   Comma-Shape Graduation (email artifact 2, August 2026)
   ------------------------------------------------------------
   Derives comma shapes from machine-transduced dependency
   graphs, so that the algebra's comma-shape match fires on
   COMPUTED structure instead of hand-authored label equality.

   V1's own scope limit (wolfram/README.md): the Tymoczko <->
   Cutting comma match was planted in the data before the code
   found it - both kernels were hand-assigned the same
   IrreducibilityKind string. This file replaces assertion with
   derivation for machine cores: a comma is EARNED by a work's
   graph or the kernel stays "underived".

   Requires falsework-algebra.wl (MakeComma, CommaShapeMatchQ,
   field, CoreQ) and corev2-loader.wl (CascadeDelta) loaded
   first.

   ------------------------------------------------------------
   PRE-COMMITTED DEFINITIONS (fixed before any run; the numbers
   the run produces are reported, not tuned)
   ------------------------------------------------------------
   TENSION PAIR. An unordered pair {A, B} of nodes joined by at
   least one contradicts edge.

   COMMA WITNESS ("a distinction that fails to cancel"). A
   tension pair {A, B} such that:
     (w1) both poles are load-bearing: for each pole P, the
          fixpoint removal cascade seeded at P removes at least
          one other node, OR triggers at least one declared
          failure mode; and
     (w2) the tension is maintained, not resolved by dependence:
          neither pole lies in the other's removal cascade.

   DERIVED IRREDUCIBILITYKIND. For a witness {A, B}, a canonical
   string "tension_<coupling>_<symmetry>_<failure>" from three
   computed features:
     coupling : "coupled"  if the poles' transitive requires-
                ground intersects (the tension is internal to a
                shared substrate), else "disjoint"
     symmetry : "balanced" if both poles have (or both lack)
                requires-dependents, else "skewed"
     failure  : "constitutive" if removing either pole triggers
                a declared failure mode, else "unmarked"
   Eight possible kinds. All derived kinds carry the "tension_"
   prefix, so a derived comma can never accidentally shape-match
   a V1 hand-authored comma (disjoint namespaces).

   PRINCIPAL COMMA. A work may host several witnesses; the V1
   Kernel type carries one Comma. The principal witness is the
   one with the largest combined pole-cascade size; ties break
   lexicographically on the sorted pole ids. All witnesses are
   retained on the core ("CommaWitnesses") for inspection.

   EPISTEMIC GRADE. Derived commas carry
   "GroundKind" -> "computed": their FormalGround is machine-
   checked graph structure, not a classical theorem (V1's
   Pythagorean comma cites Baker 1966). CommaShape's
   "FormallyGrounded" flag is True for both, but the grades are
   different and the GroundKind field keeps them distinguishable.
   ============================================================ *)


ClearAll[TensionPairs, RequiresDown, CommaWitnessData, GraduateCore];


TensionPairs::usage =
  "TensionPairs[core] returns the deduplicated unordered pairs of " <>
  "nodes joined by contradicts edges in a machine core.";

TensionPairs[c_?CoreQ] := Module[{edges},
  edges = Lookup[First@c, "Edges", {}];
  DeleteDuplicates[
    Sort[{Lookup[#, "from"], Lookup[#, "to"]}] & /@
      Select[edges, Lookup[#, "kind"] === "contradicts" &]]
];


RequiresDown::usage =
  "RequiresDown[core, node] returns the transitive requires-ground " <>
  "of node: every node it reaches by following requires edges " <>
  "forward (what it stands on), excluding itself. Cycle-safe.";

RequiresDown[c_?CoreQ, p_String] := Module[{edges, reach, frontier, next},
  edges = Select[Lookup[First@c, "Edges", {}],
    Lookup[#, "kind"] === "requires" &];
  reach = <||>;
  frontier = {p};
  While[frontier =!= {},
    next = Flatten[
      Function[n, Lookup[#, "to"] & /@
        Select[edges, Lookup[#, "from"] === n &]] /@ frontier];
    next = Select[DeleteDuplicates[next],
      !KeyExistsQ[reach, #] && # =!= p &];
    Scan[AssociateTo[reach, # -> True] &, next];
    frontier = next
  ];
  Sort@Keys[reach]
];


CommaWitnessData::usage =
  "CommaWitnessData[core, {a, b}] evaluates one tension pair " <>
  "against the pre-committed witness and feature definitions. " <>
  "Returns poles, witness status, derived kind, cascade sizes, " <>
  "triggered failures, and shared requires-ground.";

CommaWitnessData[c_?CoreQ, {a_String, b_String}] := Module[
  {dA, dB, cascA, cascB, trigA, trigB, loadA, loadB, mutual,
   downA, downB, shared, coupling, symmetry, failure},

  dA = CascadeDelta[c, {a}];
  dB = CascadeDelta[c, {b}];
  cascA = Complement[dA["RemovedClosure"], {a}];
  cascB = Complement[dB["RemovedClosure"], {b}];
  trigA = dA["TriggeredFailures"];
  trigB = dB["TriggeredFailures"];

  loadA  = Length[cascA] >= 1 || trigA =!= {};
  loadB  = Length[cascB] >= 1 || trigB =!= {};
  mutual = MemberQ[dA["RemovedClosure"], b] ||
           MemberQ[dB["RemovedClosure"], a];

  downA  = RequiresDown[c, a];
  downB  = RequiresDown[c, b];
  shared = Intersection[downA, downB];

  coupling = If[shared =!= {}, "coupled", "disjoint"];
  symmetry = If[(Length[cascA] >= 1) === (Length[cascB] >= 1),
    "balanced", "skewed"];
  failure  = If[Union[trigA, trigB] =!= {}, "constitutive", "unmarked"];

  <|
    "Poles"             -> Sort[{a, b}],
    "Witness"           -> (loadA && loadB && !mutual),
    "Kind"              -> "tension_" <> coupling <> "_" <>
                             symmetry <> "_" <> failure,
    "CascadeSizes"      -> <|a -> Length[cascA], b -> Length[cascB]|>,
    "TriggeredFailures" -> Union[trigA, trigB],
    "SharedGround"      -> shared
  |>
];


GraduateCore::usage =
  "GraduateCore[core] evaluates every tension pair, and if at " <>
  "least one comma witness exists, returns a copy of the core " <>
  "whose kernel (and every mechanism's kernel reference) carries " <>
  "the derived principal comma with CommaStatus -> \"derived\". " <>
  "Cores with no witness are returned unchanged (underived). " <>
  "V1 cores (no Edges field) pass through unchanged.";

GraduateCore[c_?CoreQ] := Module[
  {a, coreId, pairs, wits, principal, evid, comma, kernel2, mechs2},

  a      = First@c;
  coreId = Lookup[a, "Id"];
  pairs  = TensionPairs[c];
  wits   = Select[CommaWitnessData[c, #] & /@ pairs, #["Witness"] &];
  If[wits === {}, Return[c]];

  wits = SortBy[wits,
    {-Total[Values[#["CascadeSizes"]]] &, #["Poles"] &}];
  principal = First[wits];

  evid = Join[
    {"computed:poles=" <> StringRiffle[principal["Poles"], "~"],
     "computed:pole_cascades=" <>
       StringRiffle[ToString /@ Values[principal["CascadeSizes"]], ","]},
    If[principal["TriggeredFailures"] =!= {},
      {"computed:triggered_failures=" <>
         StringRiffle[principal["TriggeredFailures"], ","]}, {}],
    If[principal["SharedGround"] =!= {},
      {"computed:shared_requires_ground=" <>
         StringRiffle[principal["SharedGround"], ","]}, {}]];

  comma = MakeComma[
    "Slug" -> "comma:" <> coreId <> ":" <>
      StringRiffle[principal["Poles"], "~"],
    "Type"               -> "StructuralTension",
    "IrreducibilityKind" -> principal["Kind"],
    "FormalGround"       -> evid,
    "GroundKind"         -> "computed",
    "Poles"              -> principal["Poles"]
  ];

  kernel2 = Kernel[Join[First@Lookup[a, "Kernel"],
    <|"Comma" -> comma, "CommaStatus" -> "derived",
      "WitnessCount" -> Length[wits]|>]];

  (* TransferBasis reads the comma off each MECHANISM's kernel
     reference, so every mechanism is rebuilt with the graduated
     kernel; removal-signature closures are untouched (they bind
     node ids, not kernel state). *)
  mechs2 = Map[Mechanism[Join[First@#, <|"Kernel" -> kernel2|>]] &,
    Lookup[a, "Mechanisms", <||>]];

  Core[Join[a, <|
    "Kernel"         -> kernel2,
    "Mechanisms"     -> mechs2,
    "CommaWitnesses" -> wits
  |>]]
];


Print["Comma graduation ready. Functions: TensionPairs, ",
      "RequiresDown, CommaWitnessData, GraduateCore."];
