(* ::Package:: *)

(* ================================================================
   CELL 3 / 5 - VISUALISATION 6.1
   Tymoczko <-> Cutting transfer network. Self-contained: re-runs
   TransferCandidates so this cell works regardless of whether
   cell 2 truncated.
   ================================================================ *)

transferTC = TransferCandidates[TymoczkoCore, CuttingCore];

Print["6.1  Transfer network: Tymoczko (music) <-> Cutting (film)"];

Module[{tEdges, tStyles, allVerts, vstyles},
  tEdges = DirectedEdge[#["From"], #["To"]] & /@ transferTC;
  tStyles = MapThread[
    #1 -> Directive[
      Thickness[0.003 + 0.012 * #2],
      ColorData["TemperatureMap"][#2]
    ] &,
    {tEdges, #["Confidence"] & /@ transferTC}
  ];
  allVerts = Join[
    Keys[field[TymoczkoCore, "Mechanisms"]],
    Keys[field[CuttingCore, "Mechanisms"]]
  ];
  vstyles = Join[
    Map[# -> Lighter[Blue, 0.6] &,
        Keys[field[TymoczkoCore, "Mechanisms"]]],
    Map[# -> Lighter[Red, 0.6] &,
        Keys[field[CuttingCore, "Mechanisms"]]]
  ];
  Graph[
    allVerts,
    tEdges,
    VertexLabels -> Placed["Name", Tooltip],
    EdgeStyle -> tStyles,
    VertexStyle -> vstyles,
    VertexShapeFunction -> "Rectangle",
    GraphLayout -> "BipartiteEmbedding",
    ImageSize -> 720,
    PlotLabel -> Style[
      "Transfer candidates: edge thickness/colour = confidence",
      14, Bold
    ]
  ]
]
