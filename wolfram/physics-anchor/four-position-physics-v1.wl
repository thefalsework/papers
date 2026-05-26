(* ::Package:: *)

(* ============================================================
   Route B: finite physics Heyting-slice exploration (v1.1)
   ------------------------------------------------------------
   Companion to:
     preprints/four-position-partition/physics-anchor/feasibility.md
     wolfram/cores/heunen-landsman-spitters-2009.wl

   Question: is there a finite, computationally-tractable, physics-
   interpretable Heyting algebra on which the four-position partition
   is non-vacuously inhabited at some kernel?

   v1.1 changes from v1: compact one-line-per-kernel output; full
   down-set / regularity listings replaced by counts and summaries;
   candidate D (2-qubit full MUB context, 21-element poset, ~59000
   down-sets) explicitly skipped with a structural note rather than
   enumerated (the v1 version exceeded the cell output buffer at
   candidate C; D would have compounded that). The skipped D is
   still discussed in the feasibility document (§3.1).

   Candidates: A, B, C, E, F (see feasibility.md §3 for full
   physics readings).

   Execution: in a Wolfram (or Mathematica) kernel, evaluate this
   file with Get["..."]. All Print statements emit to stdout. No
   external dependencies.
   ============================================================ *)

ClearAll["Global`*"];


(* ============================================================
   GENERIC machinery: down-set lattice + Heyting structure
   ============================================================ *)

downClosedQ[S_, P_, leq_] := AllTrue[S, Function[a,
  AllTrue[P, Function[b, !leq[b, a] || MemberQ[S, b]]]]];

allDownSets[P_, leq_] :=
  Select[Subsets[P], downClosedQ[#, P, leq] &];

downSetCompl[S_, allDs_] := Module[{disj},
  disj = Select[allDs, Intersection[#, S] === {} &];
  If[disj === {}, {}, Last[SortBy[disj, Length]]]
];

fourCells[allDs_, a_] := Module[{aC, aCC, infra, ref, expl, dist, nonBot},
  aC = downSetCompl[a, allDs];
  aCC = downSetCompl[aC, allDs];
  nonBot = Select[allDs, # =!= {} &];
  infra = Select[nonBot, SubsetQ[a, #] &];
  ref   = Select[nonBot, SubsetQ[aC, #] &];
  expl  = Select[nonBot, SubsetQ[aCC, #] && !SubsetQ[a, #] &];
  dist  = Select[nonBot,
    Intersection[#, a] =!= {} && Intersection[#, aC] =!= {} &];
  <|"Infrastructure" -> infra,
    "Refusal"        -> ref,
    "Exploitation"   -> expl,
    "Distribution"   -> dist,
    "aC"             -> aC,
    "aCC"            -> aCC,
    "regular?"       -> (a === aCC)|>
];

(* Compact per-candidate report.
   Outputs:
     <header line>
     <one line of structural facts>
     <one line summary of non-regular elements>
     "kernels with all-four-cells inhabited: <count>"
     If count > 0: list each such kernel with counts.
     If count = 0: report the maximum number of cells inhabited
       at any kernel, and a representative kernel achieving it.
     Final per-candidate verdict line.
   Returns a triple: {anyNonVacuous, maxCellsInhabited, ladderInfo}. *)

compactReport[name_, physicsReading_, P_, leq_] := Module[
  {allDs, nonReg, kernelRows, anyNV, maxCells, bestRow, fourCount, summary},
  allDs = allDownSets[P, leq];
  Print["============================================================"];
  Print["CANDIDATE ", name];
  Print["  Physics reading: ", physicsReading];
  Print["  Poset size = ", Length[P], "; down-set lattice size = ", Length[allDs]];
  nonReg = Select[allDs, # =!= downSetCompl[downSetCompl[#, allDs], allDs] &];
  Print["  Non-regular elements: ", Length[nonReg], " of ", Length[allDs],
        "  (Exploitation requires kernel a with a != aCC)"];
  kernelRows = Map[Function[a,
    Module[{r, ic, rc, ec, dc},
      r = fourCells[allDs, a];
      ic = Length[r["Infrastructure"]]; rc = Length[r["Refusal"]];
      ec = Length[r["Exploitation"]]; dc = Length[r["Distribution"]];
      <|"kernel" -> a, "i" -> ic, "r" -> rc, "e" -> ec, "d" -> dc,
        "cells" -> Count[{ic, rc, ec, dc}, n_ /; n > 0],
        "all4" -> (ic > 0 && rc > 0 && ec > 0 && dc > 0),
        "reg" -> r["regular?"]|>
    ]],
    Select[allDs, # =!= {} &]];
  anyNV = Count[kernelRows, _?(#["all4"] &)];
  Print["  Kernels with all FOUR cells inhabited: ", anyNV];
  If[anyNV > 0,
    Do[
      If[row["all4"],
        Print["    kernel = ", row["kernel"],
              "   (i,r,e,d) = (", row["i"], ",", row["r"], ",", row["e"], ",", row["d"], ")",
              "   reg? = ", row["reg"]]
      ],
      {row, kernelRows}
    ];
    Print["  CANDIDATE ", name, " VERDICT: NON-VACUOUS"];
    maxCells = 4; bestRow = First[Select[kernelRows, #["all4"] &]],
    (* else: count max cells achieved *)
    maxCells = Max[Through[kernelRows["cells"]]];
    bestRow = First[Select[kernelRows, #["cells"] === maxCells &]];
    fourCount = Count[Through[kernelRows["cells"]], 3];
    Print["  Max cells inhabited at any single kernel: ", maxCells];
    Print["    e.g. kernel = ", bestRow["kernel"],
          "   (i,r,e,d) = (", bestRow["i"], ",", bestRow["r"], ",",
          bestRow["e"], ",", bestRow["d"], ")",
          "   reg? = ", bestRow["reg"]];
    Print["  Kernels achieving 3-of-4 cells: ", fourCount,
          "  (none achieve all 4)"];
    Print["  CANDIDATE ", name, " VERDICT: DEGENERATE"]
  ];
  Print[];
  {anyNV > 0, maxCells, anyNV}
];


(* ============================================================
   CANDIDATE A: 1-qubit Bohr-context lattice
   ============================================================ *)
posetA = {"trivial", "ctxX", "ctxY", "ctxZ"};
leqA[a_, b_] := (a === b) || (a === "trivial");

{anyA, maxA, allA} = compactReport["A: 1-qubit Bohr-context lattice",
  "M_2(C) restricted to {C.I, <X>, <Y>, <Z>}: shared trivial bottom + 3-atom antichain",
  posetA, leqA];


(* ============================================================
   CANDIDATE B: Boolean-triple subalgebra poset
   ============================================================ *)
posetB = {"a1", "a2", "a3", "T"};
leqB[a_, b_] := (a === b) || (b === "T");

{anyB, maxB, allB} = compactReport["B: Boolean-triple subalgebra poset",
  "One MUB triple on 2 qubits: 3 atoms below 1 maximal Boolean subalgebra",
  posetB, leqB];


(* ============================================================
   CANDIDATE C: Two disjoint Boolean triples
   ============================================================ *)
posetC = {"bot",
  "a1", "a2", "a3", "T1",
  "b1", "b2", "b3", "T2"};
leqC[a_, b_] := Which[
  a === b, True,
  a === "bot", True,
  MemberQ[{"a1", "a2", "a3"}, a] && b === "T1", True,
  MemberQ[{"b1", "b2", "b3"}, a] && b === "T2", True,
  True, False
];

{anyC, maxC, allC} = compactReport["C: Two disjoint Boolean triples",
  "Two MUB triples on 2 qubits sharing only the trivial subalgebra",
  posetC, leqC];


(* ============================================================
   CANDIDATE D (skipped explicitly, with structural note)
   ------------------------------------------------------------
   The 2-qubit full MUB context poset has 1 + 15 + 5 = 21 elements
   (bottom, 15 atomic Pauli subalgebras, 5 maximal Boolean
   subalgebras). Each of 5 triples contributes a factor of 9 to
   the down-set count, so the down-set lattice has 9^5 + 1 = 59050
   elements. Computing this via Subsets on a 21-element set
   filters 2^21 = 2.1M candidates; per-kernel enumeration would
   then run 59049 reports. This is computationally feasible but
   uninformative if A, B, and C are all degenerate via the same
   structural obstacle (common trivial bottom + atom antichain
   over it): the obstacle compounds, it does not dissolve, when
   the antichain grows.

   The feasibility document §3.1 records this skip and the
   structural reasoning. The candidate is not enumerated here.
   ============================================================ *)
Print["============================================================"];
Print["CANDIDATE D: 2-qubit full MUB context lattice  --  SKIPPED"];
Print["  Poset size = 21; predicted down-set lattice size = 59050"];
Print["  Skipped because (i) the down-set count makes per-kernel"];
Print["  enumeration heavy, and (ii) if A, B, C are all degenerate"];
Print["  via the same 'common trivial bottom' obstacle, growing"];
Print["  the antichain does not dissolve the obstacle."];
{anyD, maxD, allD} = {False, "skipped", 0};
Print[];


(* ============================================================
   CANDIDATE E: 3-chain x 3-chain (two commuting trichotomies)
   ============================================================ *)
posetE = Flatten[Table[{i, j}, {i, 0, 2}, {j, 0, 2}], 1];
leqE[a_, b_] := (a[[1]] <= b[[1]]) && (a[[2]] <= b[[2]]);

{anyE, maxE, allE} = compactReport[
  "E: 3-chain x 3-chain (two commuting trichotomies)",
  "Two commuting observables, each with 3 refinement levels; product of 3-chains",
  posetE, leqE];


(* ============================================================
   CANDIDATE F: causal diamond (4-event causet)
   ============================================================ *)
posetF = {"a", "b", "c", "d"};
leqF[x_, y_] := Which[
  x === y, True,
  x === "a" && MemberQ[{"c", "d"}, y], True,
  x === "b" && MemberQ[{"c", "d"}, y], True,
  x === "c" && y === "d", True,
  True, False
];

{anyF, maxF, allF} = compactReport["F: causal diamond (4-event causet)",
  "4-event causet: a, b spacelike; c in future of both; d in future of c",
  posetF, leqF];


(* ============================================================
   FINAL SUMMARY TABLE
   ============================================================ *)
Print["============================================================"];
Print["FINAL SUMMARY"];
Print["============================================================"];
Print[];
Print[StringPadRight["candidate", 50],
      StringPadRight["max cells / 4", 16],
      "verdict"];
Print[StringPadRight["----------", 50],
      StringPadRight["-------------", 16],
      "-------"];
formatRow[name_, maxN_, anyNV_] := Print[
  StringPadRight[name, 50],
  StringPadRight[ToString[maxN], 16],
  If[anyNV, "NON-VACUOUS", "DEGENERATE"]];
formatRow["A: 1-qubit Bohr-context lattice", maxA, anyA];
formatRow["B: Boolean-triple subalgebra poset", maxB, anyB];
formatRow["C: Two disjoint Boolean triples", maxC, anyC];
Print[StringPadRight["D: 2-qubit full MUB context lattice", 50],
      StringPadRight["skipped", 16], "(see note above)"];
formatRow["E: 3-chain x 3-chain (commuting trichotomies)", maxE, anyE];
formatRow["F: causal diamond (4-event causet)", maxF, anyF];
Print[];
Print["Interpretation guide (feasibility.md §3.1 records the"];
Print["pre-run hand-analysis predictions for comparison):"];
Print[];
Print["  - A, B, C degenerate -> 'common trivial bottom' obstacle"];
Print["    is structural: single-MASA-style context lattices over"];
Print["    a shared bottom cannot host a non-vacuous partition."];
Print[];
Print["  - E non-vacuous -> the framework's machinery transfers to"];
Print["    a finite physics-flavoured product-of-chains lattice."];
Print["    The lattice has two-direction non-regularity (kernel and"];
Print["    complement both have non-trivial NOT), which the single-"];
Print["    bottom candidates do not."];
Print[];
Print["  - F result tests whether a different physics-substrate"];
Print["    (Sorkin causets) clears the obstacle. Anticipated"];
Print["    degenerate at this size; richer causets would need"];
Print["    a separate exploration."];
Print[];
Print["[End of physics-anchor Route-B exploration v1.1]"];
