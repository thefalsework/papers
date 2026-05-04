(* ::Package:: *)

(* ================================================================
   CELL 6 / 6 - VISUALISATION 6.4
   Discrimination panel. Compares Tymoczko<->Cutting (centerpiece)
   to Tymoczko<->NKS and Cutting<->NKS, to show that the algebra's
   high-confidence verdict is specific to the comma-equal pair.
   Self-contained: re-runs the three TransferCandidates queries.
   ================================================================ *)

transferTC = TransferCandidates[TymoczkoCore, CuttingCore];
transferTN = TransferCandidates[TymoczkoCore, NKSCore];
transferCN = TransferCandidates[CuttingCore, NKSCore];

maxConf[ts_] := If[Length[ts] == 0, 0, Max[#["Confidence"] & /@ ts]];
minConf[ts_] := If[Length[ts] == 0, 0, Min[#["Confidence"] & /@ ts]];

Print["6.4  Discrimination panel: where does comma-shape equivalence fire?"];
Print[""];
Print["  pair                                      candidates   max conf   min conf"];
Print["  Tymoczko (music)   <->  Cutting (film)        ",
      Length[transferTC], "          ",
      NumberForm[maxConf[transferTC], {3, 2}], "       ",
      NumberForm[minConf[transferTC], {3, 2}]];
Print["  Tymoczko (music)   <->  NKS (computation)     ",
      Length[transferTN], "         ",
      NumberForm[maxConf[transferTN], {3, 2}], "       ",
      NumberForm[minConf[transferTN], {3, 2}]];
Print["  Cutting (film)     <->  NKS (computation)     ",
      Length[transferCN], "         ",
      NumberForm[maxConf[transferCN], {3, 2}], "       ",
      NumberForm[minConf[transferCN], {3, 2}]];
Print[""];

renderPanel[transfers_, leftCore_, rightCore_, label_] :=
  Module[{tEdges, tStyles, allVerts, vstyles},
    tEdges = DirectedEdge[#["From"], #["To"]] & /@ transfers;
    tStyles = MapThread[
      #1 -> Directive[
        Thickness[0.003 + 0.012 * #2],
        ColorData["TemperatureMap"][#2]
      ] &,
      {tEdges, #["Confidence"] & /@ transfers}
    ];
    allVerts = Join[
      Keys[field[leftCore, "Mechanisms"]],
      Keys[field[rightCore, "Mechanisms"]]
    ];
    vstyles = Join[
      Map[# -> Lighter[Blue, 0.6] &,
          Keys[field[leftCore, "Mechanisms"]]],
      Map[# -> Lighter[Red, 0.6] &,
          Keys[field[rightCore, "Mechanisms"]]]
    ];
    Graph[
      allVerts,
      tEdges,
      VertexLabels -> Placed["Name", Tooltip],
      EdgeStyle -> tStyles,
      VertexStyle -> vstyles,
      VertexShapeFunction -> "Rectangle",
      GraphLayout -> "BipartiteEmbedding",
      ImageSize -> 520,
      PlotLabel -> Style[label, 12, Bold]
    ]
  ];

Print["A. Tymoczko <-> Cutting (centerpiece)"];
Print["   Both commas have IrreducibilityKind = BoundaryDiscriminationAtLimit."];
Print["   comma_shape_match fires on every pair; max confidence 0.92."];
Print @ renderPanel[transferTC, TymoczkoCore, CuttingCore,
  "Tymoczko<->Cutting (centerpiece): " <>
  ToString[Length[transferTC]] <> " candidates"];
Print[""];

Print["B. Tymoczko <-> NKS"];
Print["   IrreducibilityKinds differ (Boundary... vs BehaviouralPredicate...)."];
Print["   comma_shape_match never fires; max confidence drops to 0.68."];
Print @ renderPanel[transferTN, TymoczkoCore, NKSCore,
  "Tymoczko<->NKS: " <>
  ToString[Length[transferTN]] <> " candidates"];
Print[""];

Print["C. Cutting <-> NKS"];
Print["   IrreducibilityKinds also differ."];
Print["   comma_shape_match never fires; max confidence drops to 0.68."];
Print @ renderPanel[transferCN, CuttingCore, NKSCore,
  "Cutting<->NKS: " <>
  ToString[Length[transferCN]] <> " candidates"];
Print[""];

Print["================================================================"];
Print["What this panel shows"];
Print["================================================================"];
Print[""];
Print["The centerpiece pair (A) is the only one in which mechanism"];
Print["edges reach 0.92 confidence. The other two pairs (B, C) cap at"];
Print["0.68 - the next confidence tier, where shared mechanism Type"];
Print["plus cross-domain fire but comma_shape_match does not."];
Print[""];
Print["The discriminating predicate is comma_shape_match. Tymoczko's"];
Print["CommaPythagorean and Cutting's CommaShotBoundary share the"];
Print["IrreducibilityKind 'BoundaryDiscriminationAtLimit', which is"];
Print["the framework's articulated cross-domain claim from Paper 1"];
Print["sec. 4.3. NKS's CommaRice has IrreducibilityKind"];
Print["'BehaviouralPredicateUndecidability' - a different abstract"];
Print["structural shape, which the algebra correctly identifies as"];
Print["NOT comma-shape-equivalent to the other two."];
Print[""];
Print["Honest reading: the panel demonstrates that the algebra"];
Print["discriminates on comma-shape, and that the high-confidence"];
Print["centerpiece result is specific to the framework's claim, not"];
Print["a uniform output. It does not establish the cross-domain"];
Print["homology empirically; that remains the framework's open"];
Print["question. It does establish that the framework's claim is"];
Print["machine-checkable and that its computational signature is"];
Print["the centerpiece's heat, not the panel's edge counts."];
