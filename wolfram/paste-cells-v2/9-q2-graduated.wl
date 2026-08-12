(* ::Package:: *)

(* ================================================================
   CELL 9 - Q2 RERUN OVER THE GRADUATED CORPUS
   Requires: cell 4 (baseline allCands, q2MaxConf) and cell 8
   (corpusV2G).

   Same query, same predicates, same confidence rubric as the
   baseline in cell 4 - the only change is that kernels which
   EARNED a derived comma now carry one, so predicate 3
   (comma-shape match between hosting kernels) can fire on
   computed structure. Every difference from cell 4's numbers is
   attributable to the graduation and nothing else.
   ================================================================ *)

crossPairsG = Select[Tuples[corpusV2G, 2],
  field[#[[1]], "Id"] =!= field[#[[2]], "Id"] &&
  field[#[[1]], "Domain"] =!= field[#[[2]], "Domain"] &];

Print["Q2 (graduated) - TransferCandidates over ", Length[crossPairsG],
  " ordered cross-domain pairs..."];

allCandsG = Flatten[
  Map[Function[p, Module[{cands = TransferCandidates[p[[1]], p[[2]]]},
    Map[Join[#, <|"FromCore" -> field[p[[1]], "Id"],
                  "ToCore"   -> field[p[[2]], "Id"]|>] &, cands]]],
    crossPairsG], 1];

q2gMaxConf  = If[allCandsG === {}, 0, Max[#["Confidence"] & /@ allCandsG]];
commaFiredG = Select[allCandsG,
  AnyTrue[#["Basis"], StringStartsQ[#, "comma_shape_match"] &] &];
tierTallyG  = ReverseSort@Counts[#["Confidence"] & /@ allCandsG];
commaCorePairsG = Union[
  Sort[{#["FromCore"], #["ToCore"]}] & /@ commaFiredG];

Print["     candidates: ", Length[allCandsG],
  "  (baseline: ", Length[allCands], ")"];
Print["     max confidence: ", q2gMaxConf,
  "  (baseline: ", q2MaxConf, ")"];
Print["     comma_shape_match fired in ", Length[commaFiredG],
  " candidates  (baseline: 0)"];
Print["     confidence tiers: ", tierTallyG];
Print["     cross-domain core pairs where the comma channel fires: ",
  Length[commaCorePairsG]];
Scan[Print["        ", #[[1]], "   <->   ", #[[2]]] &, commaCorePairsG];

topG = Take[
  ReverseSortBy[Select[allCandsG, #["Confidence"] >= 0.92 &],
    #["Confidence"] &],
  UpTo[15]];

Print[""];
Print["Top tier (0.92: type + derived comma + cross-domain), first ",
  Length[topG], " of ",
  Length[Select[allCandsG, #["Confidence"] >= 0.92 &]], ":"];

Print[Grid[
  Prepend[
    Map[{#["FromCore"] <> " : " <> #["From"],
         #["ToCore"] <> " : " <> #["To"],
         #["FromDomain"] <> " -> " <> #["ToDomain"],
         SelectFirst[#["Basis"],
           StringStartsQ[#, "comma_shape_match"] &]} &, topG],
    Style[#, Bold] & /@ {"From", "To", "Domains", "Comma basis"}],
  Frame -> All, Alignment -> Left, BaseStyle -> "Text",
  Background -> {None, {LightGray, {None}}}]];

Print[""];
Print["Reading: in V1 the 0.92 tier existed only because the ",
  "Tymoczko-Cutting comma match was hand-planted. Here every ",
  "comma_shape_match is computed from the work's own dependency ",
  "graph under pre-committed definitions. The channel's grade has ",
  "changed from articulation to measurement - including the ",
  "measured weaknesses reported in cell 8."];
