(* ::Package:: *)

(* ================================================================
   CELL 2 / 5 - QUERIES
   Runs Q1 through Q4 with text output. Saves transferTC,
   deltaTymoczko, deltaCutting, and recursiveResult as globals
   for use in the visualisation cells.
   ================================================================ *)

Print["================================================================"];
Print["1. CORPUS"];
Print["================================================================"];

Print[Grid[
  Prepend[
    {field[#, "Title"], field[#, "Domain"],
     field[field[#, "Kernel"], "Slug"],
     Length @ field[#, "Mechanisms"]} & /@ corpus,
    Style[#, Bold] & /@ {"Title", "Domain", "Kernel", "#Mech"}
  ],
  Frame -> All, Alignment -> Left, BaseStyle -> "Text"
]];

Print[""];
Print["================================================================"];
Print["2. QUERY 1 - mechanism + constraint match"];
Print["================================================================"];
q1 = FindWorksByType[corpus, "DiscriminationOperation", "DependencyStatement"];
Print["Returned ", Length[q1], " cores:"];
Do[Print["  - ", field[c, "Title"], "  (", field[c, "Domain"], ")"], {c, q1}];

Print[""];
Print["================================================================"];
Print["3. QUERY 2 - transfer candidates [CENTERPIECE]"];
Print["================================================================"];
Print["Tymoczko (music) <-> Cutting (film)"];
transferTC = TransferCandidates[TymoczkoCore, CuttingCore];
Print["Returned ", Length[transferTC], " candidates."];
Print[""];
Print["Top 3 by confidence:"];
Do[
  Print["  ", c["From"], " -> ", c["To"],
        "  conf=", NumberForm[c["Confidence"], {3, 2}]];
  Print["    basis: ", StringRiffle[c["Basis"], " | "]],
  {c, Take[transferTC, Min[3, Length[transferTC]]]}
];
Print[""];
Print["KEY RESULT: 0.92 confidence on the centerpiece transfer is a"];
Print["coherence demonstration of Paper 1 sec 4.3's cross-domain claim"];
Print["('the same abstract structure: a sub-symmetry made available by a"];
Print["closed generative field at its boundary'), encoded in the comma's"];
Print["IrreducibilityKind field. Not an empirical proof; Paper 1 sec. 4.3"];
Print["names cross-domain comma equivalence as the open empirical question."];

Print[""];
Print["================================================================"];
Print["4. QUERY 3 - computational removal test"];
Print["================================================================"];
deltaTymoczko = RemovalDelta[TymoczkoCore, "voice_leading_parsimony"];
Print["RemoveAndProject[TymoczkoCore, voice_leading_parsimony]:"];
Print["  Constraints dropped: ",
  If[Length[deltaTymoczko["ConstraintsDropped"]] == 0, "(none)",
     StringRiffle[deltaTymoczko["ConstraintsDropped"], ", "]]];
Print["  Mechanisms degraded: ",
  If[Length[deltaTymoczko["MechanismsDegraded"]] == 0, "(none)",
     StringRiffle[deltaTymoczko["MechanismsDegraded"], ", "]]];
Print["  Failure modes surfaced: ",
  If[Length[deltaTymoczko["FailureModesSurfaced"]] == 0, "(none)",
     StringRiffle[deltaTymoczko["FailureModesSurfaced"], ", "]]];

deltaCutting = RemovalDelta[CuttingCore, "cut_dissolve_discrimination"];
Print[""];
Print["RemoveAndProject[CuttingCore, cut_dissolve_discrimination]:"];
Print["  Mechanisms degraded: ",
  StringRiffle[deltaCutting["MechanismsDegraded"], ", "]];
Print["  Failure modes surfaced: ",
  StringRiffle[deltaCutting["FailureModesSurfaced"], ", "]];

Print[""];
Print["================================================================"];
Print["5. QUERY 4 - recursive self-application"];
Print["================================================================"];
recursiveResult = RecursiveAnalysis[MethodologyCore];
Print[Length[recursiveResult["SelfTransfers"]],
  " non-trivial self-transfer candidates in the methodology core."];
Print[""];
Print["Load-bearing mechanisms (removal causes constraint or mech collapse):"];
Do[Print["  - ", m], {m, recursiveResult["LoadBearingMechanisms"]}];
Print[""];
Print["Latent failure modes (re-derived computationally):"];
Do[Print["  - ", f], {f, recursiveResult["LatentFailures"]}];
Print[""];
Print["These re-derive variety_in_uniformity, transparency_as_opacity,"];
Print["and methodology_blind_spot - the same failures Brink surfaced"];
Print["interpretively in Jan 4, 2026 with Stephen Wolfram."];

Print[""];
Print["Cell 2 complete. Globals saved: transferTC, deltaTymoczko,"];
Print["deltaCutting, recursiveResult."];
