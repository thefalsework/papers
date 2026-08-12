(* ::Package:: *)

(* ================================================================
   CELL 6 / 7 - QUERY 4, MACHINE-FED
   Requires cell 3 (corpusV2).

   RecursiveAnalysis runs unchanged on every machine core:
   self-transfers (structural self-similarity within one work),
   load-bearing mechanisms (V1 definition: removal drops
   constraints or degrades survivors), plus the cascade-depth
   ranking the fixpoint executor makes possible.

   Two scope notes, stated rather than implied:
   - The methodology self-core remains the V1 hand-authored one;
     transducing the methodology's own structural profile is
     flagged future work, so corpus-level self-application here
     means every machine core analysed by the same algebra that
     analyses every other.
   - V1's latent-failure channel (failure modes surfaced by
     removal but undeclared in the core's own list) is
     definitionally empty on machine cores: every declared
     failure mode carries a machine condition and the executor
     surfaces only declared conditions. The cell-5 audit
     supersedes that channel.
   ================================================================ *)

Print["Q4 - recursive self-application across the machine corpus"];

q4Rows = Map[
  Function[c, Module[{ra = RecursiveAnalysis[c], mechIds, deepest, depth},
    mechIds = Keys@field[c, "Mechanisms"];
    deepest = First@MaximalBy[mechIds,
      Function[nid, Length[CascadeDelta[c, {nid}]["RemovedClosure"]]]];
    depth = Length[CascadeDelta[c, {deepest}]["RemovedClosure"]] - 1;
    {field[c, "Id"],
     Length[ra["SelfTransfers"]],
     Length[ra["LoadBearingMechanisms"]],
     deepest,
     depth}]],
  corpusV2];

Print["     per-core summary (self-transfers exclude the diagonal; ",
  "cascade size excludes the seed itself):"];

Grid[
  Prepend[q4Rows,
    Style[#, Bold] & /@
      {"Core", "Self-transfers", "Load-bearing (V1 def)",
       "Deepest cascade seed", "Cascade size"}],
  Frame -> All, Alignment -> Left, BaseStyle -> "Text",
  Background -> {None, {LightGray, {None}}}]
