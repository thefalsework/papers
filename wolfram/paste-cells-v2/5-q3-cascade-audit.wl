(* ::Package:: *)

(* ================================================================
   CELL 5 / 7 - QUERY 3 (FIXPOINT CASCADE) + THE AUDIT
   Requires cell 3 (corpusV2, coresById).

   Part A: fixpoint removal cascade on one core, seeded at the
   element whose removal produces the largest cascade closure
   (computed, not chosen by hand), with every cascade step's
   cause recorded.
   V1's single-step semantics are shown beside it. Note: on
   machine cores, V1's constraint-drop and Compatibility-degrade
   channels are structurally inert (edges bind two endpoints;
   Compatibility is namespaced by design decision 4), so V1
   single-step reduces to bare removal - which is precisely why
   the roadmap (sec. 5.2) mandates the fixpoint upgrade.

   Part B: the corpus-wide machine-checkable claim audit. Every
   declared failure condition with a removal seed is evaluated
   under its own seed; every collapses_to survival claim is
   checked against the computed closure. Contradictions - the
   transduction's own claims inconsistent with its own graph -
   are reported, not smoothed.

   Part C: the prose-assertion audit for the chosen core -
   asserted removal tests (prose) beside computed cascades, for
   human adjudication. Prose is never string-matched.
   ================================================================ *)

(* ---------------- Part A: cascade on one core ------------------- *)

(* Seed selection is computed, corpus-wide: the element node whose
   removal produces the largest cascade closure anywhere in the
   corpus. No hand-picking. *)

q3Candidates = Flatten[
  Map[Function[c,
    Map[Function[nid,
      {field[c, "Id"], nid,
       Length[CascadeDelta[c, {nid}]["RemovedClosure"]]}],
      Select[Keys@field[c, "Mechanisms"],
        field[field[c, "Mechanisms"][#], "NodeKind"] === "element" &]]],
    corpusV2], 1];

{q3CoreId, q3Seed, q3Size} = First@MaximalBy[q3Candidates, Last];
q3Core  = coresById[q3CoreId];
q3Edges = field[q3Core, "Edges"];
q3Mechs = field[q3Core, "Mechanisms"];

Print["Q3 - fixpoint removal cascade"];
Print["     core: ", q3CoreId, "  (", field[q3Core, "Title"], ")"];
Print["     seed: ", q3Seed,
  "  (largest element-seeded cascade in the corpus: closure ",
  q3Size, ")"];

q3 = CascadeDelta[q3Core, {q3Seed}];

Print["     removed closure (", Length[q3["RemovedClosure"]], " nodes):"];
KeyValueMap[Print["        ", #1, "   <-   ", #2] &, q3["CascadeVia"]];
Print["     degraded survivors:"];
If[q3["Degraded"] === <||>, Print["        (none)"],
  KeyValueMap[
    Print["        ", #1, "   <-   ", StringRiffle[#2, "; "]] &,
    q3["Degraded"]]];
Print["     edges dropped: ", Length[q3["ConstraintsDropped"]]];
Print["     failure statuses: ", q3["FailureStatuses"]];
Print["     survivor-claim contradictions: ",
  If[q3["SurvivorClaimContradictions"] === <||>, "none",
    q3["SurvivorClaimContradictions"]]];

v1Proj    = StandardRemovalSignature[q3Seed][q3Core];
v1Dropped = Complement[Keys@field[q3Core, "Constraints"],
  Keys@field[v1Proj, "Constraints"]];
v1Degraded = Select[Keys@field[v1Proj, "Mechanisms"],
  TrueQ[field[field[v1Proj, "Mechanisms"][#], "Degraded"]] &];
v1Surfaced = Length[field[v1Proj, "FailureModes"]] -
  Length[field[q3Core, "FailureModes"]];

Print[""];
Print["     V1 single-step vs V2 fixpoint, same seed:"];
Print[Grid[{
  {Style["", Bold], Style["V1 single-step", Bold],
   Style["V2 fixpoint", Bold]},
  {"nodes removed", 1, Length[q3["RemovedClosure"]]},
  {"edges/constraints dropped", Length[v1Dropped],
   Length[q3["ConstraintsDropped"]]},
  {"survivors marked", Length[v1Degraded], Length[Keys@q3["Degraded"]]},
  {"failure modes surfaced", v1Surfaced, Length[q3["TriggeredFailures"]]}
}, Frame -> All, Alignment -> Left, BaseStyle -> "Text"]];

(* ---------------- Part B: corpus-wide claim audit ---------------- *)

Print[""];
Print["Corpus-wide machine-checkable claim audit ",
  "(first end-to-end pass of the roadmap sec. 5.2 audit):"];

auditRows = Flatten[
  Map[Function[c, Module[{raws = field[c, "FailureModesRaw"]},
    Map[Function[fm, Module[
      {rem = Lookup[Lookup[fm, "condition", <||>], "removed", {}], d},
      If[rem === {}, Nothing,
        d = CascadeDelta[c, rem];
        <|"Core" -> field[c, "Id"], "Failure" -> fm["id"],
          "Status" -> d["FailureStatuses"][fm["id"]],
          "Contradictions" ->
            Lookup[d["SurvivorClaimContradictions"], fm["id"], {}]|>]]],
      raws]]], corpusV2], 1];

evaluated    = Length[auditRows];
contradicted = Select[auditRows, #["Contradictions"] =!= {} &];

Print["     declared failure conditions with removal seeds, ",
  "evaluated under their own seeds: ", evaluated];
Print["     survivor-claim contradictions found: ", Length[contradicted]];
If[contradicted === {},
  Print["     (none - every collapses_to claim is consistent with ",
    "its own graph's cascade)"],
  Print[Grid[
    Prepend[
      Map[{#["Core"], #["Failure"],
           StringRiffle[#["Contradictions"], ", "]} &, contradicted],
      Style[#, Bold] & /@
        {"Core", "Failure", "Claimed survivor removed by cascade"}],
    Frame -> All, Alignment -> Left, BaseStyle -> "Text"]]];

(* ---------------- Part C: prose-assertion audit ------------------ *)

Print[""];
Print["Prose-assertion audit for ", q3CoreId,
  " (asserted prose beside computed cascade; human adjudication):"];

q3Audit = RemovalAssertionAudit[q3Core];

Grid[
  Prepend[
    KeyValueMap[
      Function[{mid, rec},
        {mid,
         rec["Asserted"] /. _Missing -> "-",
         If[rec["ComputedCascade"] === {}, "(no cascade)",
           StringRiffle[rec["ComputedCascade"], ", "]],
         If[rec["TriggeredFailures"] === {}, "-",
           StringRiffle[rec["TriggeredFailures"], ", "]]}],
      q3Audit],
    Style[#, Bold] & /@
      {"Mechanism", "Asserted removal test (prose)",
       "Computed cascade", "Failures triggered"}],
  Frame -> All, Alignment -> Left, BaseStyle -> "Text",
  Background -> {None, {LightGray, {None}}}]
