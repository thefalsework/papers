(* ::Package:: *)

(* ================================================================
   CELL 8 - COMMA-SHAPE GRADUATION
   Requires: cell 3 (corpusV2, coresById) and the contents of
   ../comma-graduation.wl pasted and evaluated as the cell before
   this one (call it cell 7.5: TensionPairs, CommaWitnessData,
   GraduateCore).

   Derives comma shapes from the machine graphs per the
   pre-committed definitions in comma-graduation.wl, graduates
   the kernels that earn one, and reports:
   - per-core graduation table (status, principal poles, kind)
   - derived-kind distribution
   - the two replicate checks (same work, independent
     transductions - does the derivation agree with itself?)
   ================================================================ *)

corpusV2G  = GraduateCore /@ corpusV2;
coresByIdG = Association[(field[#, "Id"] -> #) & /@ corpusV2G];

gradRows = Map[
  Function[c, Module[{k = field[c, "Kernel"], status, comma},
    status = field[k, "CommaStatus"];
    comma  = field[k, "Comma"];
    {field[c, "Id"],
     Length@TensionPairs[c],
     If[status === "derived", field[k, "WitnessCount"], 0],
     status,
     If[status === "derived", field[comma, "IrreducibilityKind"], "-"],
     If[status === "derived",
       StringRiffle[field[comma, "Poles"], ", "], "-"]}]],
  corpusV2G];

Print["Comma-shape graduation over the machine corpus:"];
Print[Grid[
  Prepend[gradRows,
    Style[#, Bold] & /@
      {"Core", "Tension pairs", "Witnesses", "CommaStatus",
       "Derived kind", "Principal poles"}],
  Frame -> All, Alignment -> Left, BaseStyle -> "Text",
  Background -> {None, {LightGray, {None}}}]];

derivedCores = Select[corpusV2G,
  field[field[#, "Kernel"], "CommaStatus"] === "derived" &];
kindTally = Counts[
  field[field[field[#, "Kernel"], "Comma"], "IrreducibilityKind"] & /@
    derivedCores];

Print[""];
Print["derived: ", Length[derivedCores], " of ", Length[corpusV2G],
  " cores (the witness gate is the selectivity mechanism)"];
Print["kind distribution: ", kindTally];
Print["  NOTE: kind diversity is the derivation's measured weakness -"];
Print["  if most derived commas share one kind, selectivity comes from"];
Print["  the witness gate, not from the kind vocabulary."];

(* --- replicate checks: same work, independent transductions --- *)

replicateCheck[idA_String, idB_String] := Module[
  {kA, kB, sA, sB, vA, vB},
  kA = field[coresByIdG[idA], "Kernel"];
  kB = field[coresByIdG[idB], "Kernel"];
  sA = field[kA, "CommaStatus"]; sB = field[kB, "CommaStatus"];
  vA = If[sA === "derived",
    field[field[kA, "Comma"], "IrreducibilityKind"], "underived"];
  vB = If[sB === "derived",
    field[field[kB, "Comma"], "IrreducibilityKind"], "underived"];
  Print["  ", idA, "  vs  ", idB];
  Print["    ", vA, "  vs  ", vB, "  ->  ",
    Which[
      vA === vB && vA =!= "underived", "MATCH",
      vA === vB, "both underived",
      True, "MISMATCH (derivation unstable under re-transduction)"]];
];

Print[""];
Print["Replicate stability (the free reliability probe):"];
replicateCheck[
  SelectFirst[Keys[coresByIdG], StringStartsQ[#, "the-red-book-8c596e2f"] &],
  SelectFirst[Keys[coresByIdG], StringStartsQ[#, "the-red-book-9181ad6f"] &]];
replicateCheck[
  SelectFirst[Keys[coresByIdG], StringStartsQ[#, "seven-samurai-16b09742"] &],
  SelectFirst[Keys[coresByIdG], StringStartsQ[#, "seven-samurai-18591654"] &]];
