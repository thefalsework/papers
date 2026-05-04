(* ::Package:: *)

(* ================================================================
   CELL 5 / 5 - VISUALISATION 6.3
   Methodology self-transfer graph. Self-contained.
   ================================================================ *)

recursiveResult = RecursiveAnalysis[MethodologyCore];

Print["6.3  Methodology self-transfer graph: procedural isomorphism"];

Module[{stEdges, stStyles, methodMechs},
  methodMechs = Keys[field[MethodologyCore, "Mechanisms"]];
  stEdges = DirectedEdge[#["From"], #["To"]] & /@
    recursiveResult["SelfTransfers"];
  stStyles = MapThread[
    #1 -> Directive[
      Thickness[0.002 + 0.008 * #2],
      ColorData["TemperatureMap"][#2]
    ] &,
    {stEdges, #["Confidence"] & /@ recursiveResult["SelfTransfers"]}
  ];

  Graph[
    methodMechs,
    stEdges,
    VertexLabels -> Placed["Name", Tooltip],
    EdgeStyle -> stStyles,
    VertexStyle -> Lighter[Orange, 0.5],
    VertexShapeFunction -> "Rectangle",
    GraphLayout -> "CircularEmbedding",
    ImageSize -> 720,
    PlotLabel -> Style[
      "Methodology self-transfers (" <>
      ToString[Length[stEdges]] <>
      " edges) - internal symmetry",
      14, Bold
    ]
  ]
]
