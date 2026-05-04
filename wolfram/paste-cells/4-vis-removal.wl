(* ::Package:: *)

(* ================================================================
   CELL 4 / 5 - VISUALISATION 6.2
   Tymoczko removal cascade. Self-contained.
   ================================================================ *)

deltaTymoczko = RemovalDelta[TymoczkoCore, "voice_leading_parsimony"];

Print["6.2  Removal cascade: voice_leading_parsimony out of Tymoczko"];

Module[{mIds, cIds, edges, vstyles},
  mIds = Keys[field[TymoczkoCore, "Mechanisms"]];
  cIds = Keys[field[TymoczkoCore, "Constraints"]];

  edges = Flatten @ Table[
    Module[{mech, deps},
      mech = field[TymoczkoCore, "Mechanisms"][m];
      deps = field[mech, "Compatibility"];
      If[!ListQ[deps], deps = {}];
      DirectedEdge[m, #] & /@ Intersection[deps, cIds]
    ],
    {m, mIds}
  ];

  vstyles = Join[
    {"voice_leading_parsimony" -> Directive[Red, EdgeForm[Black]]},
    Map[# -> Directive[Yellow, EdgeForm[Black]] &,
        deltaTymoczko["MechanismsDegraded"]],
    Map[# -> Directive[LightGreen, EdgeForm[Black]] &, cIds]
  ];

  Graph[
    Join[mIds, cIds],
    edges,
    VertexLabels -> Placed["Name", Tooltip],
    VertexStyle -> vstyles,
    VertexShapeFunction -> "Rectangle",
    ImageSize -> 720,
    PlotLabel -> Style[
      "Removal cascade: red = removed, yellow = degraded, " <>
      "green = surviving constraint",
      14, Bold
    ]
  ]
]
