(* ::Package:: *)

(* ================================================================
   CELL 4 / 7 - QUERIES 1 AND 2, MACHINE-FED
   Requires cell 3 (corpusV2, coresById).

   Q1 runs over DERIVED types (dependency-role signatures computed
   from each graph; design decision 2) - the machine corpus has no
   curated type vocabulary, and none is invented for it.

   Q2 runs over every ordered cross-domain pair. The comma channel
   is expected to be silent (machine kernels carry
   CommaStatus -> "underived"; design decision 1), which caps the
   confidence at 0.68. V1's 0.92 ceiling was reachable only through
   the hand-planted Tymoczko-Cutting comma match. The silence is
   measured and printed, not assumed.
   ================================================================ *)

(* ---------------- Q1: mechanism type + constraint type ---------- *)

typeDomainPairs = Flatten[
  Map[Function[c,
    ({field[#, "Type"], field[c, "Domain"]}) & /@
      Values@field[c, "Mechanisms"]], corpusV2], 1];

typeCounts      = Counts[First /@ typeDomainPairs];
typeDomainCount = Map[Length@*Union, GroupBy[typeDomainPairs, First -> Last]];
crossDomainTypes = Keys@Select[typeDomainCount, # >= 2 &];

q1Type = If[crossDomainTypes =!= {},
  First@MaximalBy[crossDomainTypes, typeCounts],
  (Print["NOTE: no derived type spans >= 2 domains; ",
     "falling back to the most frequent type overall."];
   First@Keys@ReverseSort[typeCounts])];

q1Results = FindWorksByType[corpusV2, q1Type, "requires"];

Print["Q1 - FindWorksByType[corpus, \"", q1Type, "\", \"requires\"]"];
Print["     mechanism type = most frequent cross-domain derived signature"];
Print["     constraint type = edge kind \"requires\""];
Print["     -> ", Length[q1Results], " of ", Length[corpusV2],
  " cores match:"];
Scan[
  Print["        ", field[#, "Title"], "  [", field[#, "Domain"], "]"] &,
  q1Results];

(* ---------------- Q2: transfer candidates, all cross-domain pairs *)

crossPairs = Select[Tuples[corpusV2, 2],
  field[#[[1]], "Id"] =!= field[#[[2]], "Id"] &&
  field[#[[1]], "Domain"] =!= field[#[[2]], "Domain"] &];

Print[""];
Print["Q2 - TransferCandidates over ", Length[crossPairs],
  " ordered cross-domain pairs..."];

allCands = Flatten[
  Map[Function[p, Module[{cands = TransferCandidates[p[[1]], p[[2]]]},
    Map[Join[#, <|"FromCore" -> field[p[[1]], "Id"],
                  "ToCore"   -> field[p[[2]], "Id"]|>] &, cands]]],
    crossPairs], 1];

q2MaxConf  = If[allCands === {}, 0, Max[#["Confidence"] & /@ allCands]];
commaFired = Select[allCands,
  AnyTrue[#["Basis"], StringStartsQ[#, "comma_shape_match"] &] &];

Print["     candidates: ", Length[allCands],
  ";  max confidence: ", q2MaxConf];
Print["     comma_shape_match fired in ", Length[commaFired],
  " candidates (expected 0: machine kernels carry no derived comma)"];
Print["     V1 ceiling was 0.92, reachable only through the ",
  "hand-planted comma channel; this measured ceiling is the honest ",
  "baseline the comma-shape graduation must beat."];

topCands = Take[ReverseSortBy[allCands, #["Confidence"] &], UpTo[15]];

Grid[
  Prepend[
    Map[{#["FromCore"] <> " : " <> #["From"],
         #["ToCore"] <> " : " <> #["To"],
         #["FromDomain"] <> " -> " <> #["ToDomain"],
         NumberForm[#["Confidence"], {3, 2}],
         StringRiffle[#["Basis"], "; "]} &, topCands],
    Style[#, Bold] & /@ {"From", "To", "Domains", "Conf.", "Basis"}],
  Frame -> All, Alignment -> Left, BaseStyle -> "Text",
  Background -> {None, {LightGray, {None}}}]
