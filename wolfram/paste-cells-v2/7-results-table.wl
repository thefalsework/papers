(* ::Package:: *)

(* ================================================================
   CELL 7 / 7 - RESULTS TABLE: MACHINE-FED RERUN VS V1 REFERENCE
   Requires cells 3-6 (corpusV2, q1Type, q1Results, allCands,
   q2MaxConf, commaFired, evaluated, contradicted, q4Rows).

   V1 reference numbers are from
   results/wolfram-cloud-run-2026-05-04-v1.5.nb (hardcoded here,
   labeled as such). V2 numbers are computed live from this run.
   ================================================================ *)

Print["Machine-fed rerun vs V1 reference run:"];

q4SelfTransferTotal = Total[q4Rows[[All, 2]]];
q4MaxCascade        = Max[q4Rows[[All, 5]]];

resultsRows = {
  {"Corpus",
   "5 cores, hand-authored by the analyst",
   ToString[Length[corpusV2]] <>
     " cores, machine-transduced from falsework.dev structural " <>
     "profiles; zero hand-authored"},
  {"Types",
   "curated vocabulary (DiscriminationOperation, ...)",
   "derived dependency-role signatures, computed from each graph"},
  {"Q1",
   "4 cores returned",
   ToString[Length[q1Results]] <> " of " <>
     ToString[Length[corpusV2]] <> " cores returned (type " <>
     q1Type <> " + constraint \"requires\")"},
  {"Q2",
   "9 candidates (centerpiece pair), max conf 0.92 - reachable " <>
     "only via the hand-planted comma match",
   ToString[Length[allCands]] <> " candidates over all " <>
     "cross-domain pairs, max conf " <> ToString[q2MaxConf] <>
     "; comma channel fired " <> ToString[Length[commaFired]] <>
     " times (kernels carry CommaStatus -> underived)"},
  {"Q3",
   "single-step removal on 1 core: 0 constraints dropped, " <>
     "2 degraded, 1 failure surfaced",
   "fixpoint cascade with per-node causes; corpus-wide audit: " <>
     ToString[evaluated] <> " failure conditions machine-evaluated, " <>
     ToString[Length[contradicted]] <>
     " survivor-claim contradictions"},
  {"Q4",
   "methodology self-core: 30 self-transfers, 5 load-bearing, " <>
     "5 latent failures",
   "all " <> ToString[Length[corpusV2]] <> " machine cores: " <>
     ToString[q4SelfTransferTotal] <>
     " self-transfers total, deepest cascade " <>
     ToString[q4MaxCascade] <> " nodes (per-core table in cell 6)"}
};

Print[Grid[
  Prepend[resultsRows,
    Style[#, Bold] & /@
      {"", "V1 (May 2026, hand corpus)", "V2 (Aug 2026, machine-fed)"}],
  Frame -> All, Alignment -> Left, BaseStyle -> "Text",
  Background -> {None, {LightGray, {None}}}]];

Print[""];
Print["Pathway step 2 exit test: all four queries executed on a ",
  "machine-fed corpus the analyst never hand-authored, with results ",
  "table against V1. The V2 limitation V1's README declared ",
  "(articulation over a hand-authored corpus) is removed; the comma ",
  "channel's measured silence is the target the comma-shape ",
  "graduation (email artifact 2) must beat."];
