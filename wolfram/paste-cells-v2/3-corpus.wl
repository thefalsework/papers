(* ::Package:: *)

(* ================================================================
   CELL 3 / 7 - CORPUS
   Fetch the machine-fed corpus, revalidate every file inside WL,
   construct Core[...] objects, print the validation table.

   Requires cells 1 (falsework-algebra.wl) and 2 (corev2-loader.wl).

   The corpus URL is pinned to the commit that introduced the
   corpus files, so this run is reproducible regardless of later
   repository history. For a local run, replace corpusBase with
   the local path to wolfram/corpus-v2 (no trailing slash).
   ================================================================ *)

corpusBase =
  "https://raw.githubusercontent.com/thefalsework/papers/e238991e4c69d27938ee25cb293e11d0ad1499cd/wolfram/corpus-v2";

loadResults = LoadCoreV2Corpus[corpusBase];

If[loadResults === $Failed,
  Print["FATAL: could not fetch or parse index.json from ", corpusBase];
  loadResults = {},
  Print["Fetched ", Length[loadResults], " corpus entries from manifest."]
];

validationRows = Map[
  Function[r, Module[{c = r["Core"], ok},
    ok = c =!= $Failed && WellFormedCoreQ[c];
    {If[ok, "OK", "FAIL"],
     If[c =!= $Failed, field[c, "Title"], FileNameTake[r["Source"]]],
     If[c =!= $Failed, field[c, "Author"] /. _Missing -> "-", "-"],
     If[c =!= $Failed, field[c, "Domain"], "-"],
     If[c =!= $Failed, Length@field[c, "Mechanisms"], "-"],
     If[c =!= $Failed, Length@field[c, "Edges"], "-"],
     Length[r["SchemaErrors"]],
     Length[r["IntegrityErrors"]],
     Length[r["IntegrityWarnings"]]}
  ]], loadResults];

corpusV2 = Cases[loadResults,
  r_Association /; r["Core"] =!= $Failed && WellFormedCoreQ[r["Core"]] :>
    r["Core"]];
coresById = Association[(field[#, "Id"] -> #) & /@ corpusV2];

Print[Length[corpusV2], " of ", Length[loadResults],
  " cores constructed, revalidated in WL, and well-formed."];
If[Length[corpusV2] =!= Length[loadResults],
  Print["ATTENTION: some files failed validation; ",
    "inspect the table below before proceeding."]];

Grid[
  Prepend[validationRows,
    Style[#, Bold] & /@ {"Status", "Title", "Author", "Domain",
      "Nodes", "Edges", "SchemaErrs", "IntegErrs", "Warnings"}],
  Frame -> All, Alignment -> Left, BaseStyle -> "Text",
  Background -> {None, {LightGray, {None}}}]
