(* ============================================================
   Route A v6a: Heyting-collapse verification ONLY (no SAT count)
   ------------------------------------------------------------
   Cloud-friendly fast version of v6. Stops after PART 5
   (NOTNOT(delta) = top sanity check). Does NOT compute |Sub_cl|
   or |down delta(P_1)|, which require SAT counting on 187 vars
   and may be slow on Wolfram Cloud.

   Use this script to confirm the Heyting-collapse theorem
   (v6-scope.md sec. 2) is verified at the Peres-33 scale.
   Then run four-position-physics-v6.wl (full version) for the
   cardinality measurements |I| and |E|.

   Companion to:
     preprints/four-position-partition/physics-anchor/v6-scope.md
     wolfram/physics-anchor/four-position-physics-v6.wl
   Author: Chris Brink, May 2026.
   ============================================================ *)

Print["[v6a] script loading..."];

ClearAll["Global`*"];
$HistoryLength = 0;

Print["============================================================"];
Print["v6a Heyting-collapse verification (no SAT count)"];
Print["============================================================"];
Print["Configuration: truncated Peres-33 substrate on M_3(C)"];
Print["Kernel:        a = delta(P_1) on Peres ray 1"];
Print["Goal:          verify NOT(a) = bottom componentwise"];

(* ============================================================
   PART 0: Peres-33 ray and triad data (from v5.wl)
   ============================================================ *)

Print[""];
Print["----- PART 0: Peres-33 rays and triads -----"];

peresRays = {
  {1, 0, 0}, {0, 1, 0}, {0, 0, 1},
  {1, 0, 1}, {1, 1, 0}, {0, 1, 1},
  {-1, 1, 0}, {-1, 0, 1}, {0, -1, 1},
  {1, 0, Sqrt[2]}, {Sqrt[2], 0, 1},
  {0, 1, Sqrt[2]}, {0, Sqrt[2], 1},
  {1, Sqrt[2], 0}, {Sqrt[2], 1, 0},
  {-1, 0, Sqrt[2]}, {Sqrt[2], 0, -1},
  {0, -1, Sqrt[2]}, {0, Sqrt[2], -1},
  {-1, Sqrt[2], 0}, {Sqrt[2], -1, 0},
  {1, 1, Sqrt[2]}, {1, Sqrt[2], 1}, {Sqrt[2], 1, 1},
  {-1, -1, Sqrt[2]}, {-1, Sqrt[2], -1}, {Sqrt[2], -1, -1},
  {-1, 1, Sqrt[2]}, {-1, Sqrt[2], 1}, {Sqrt[2], -1, 1},
  {1, -1, Sqrt[2]}, {1, Sqrt[2], -1}, {Sqrt[2], 1, -1}
};

explicitTriads = {
  {1, 2, 3}, {1, 6, 9}, {1, 12, 19}, {1, 13, 18},
  {2, 4, 8}, {2, 10, 17}, {2, 11, 16},
  {3, 5, 7}, {3, 14, 21}, {3, 15, 20},
  {4, 29, 32}, {5, 28, 31}, {6, 30, 33},
  {7, 22, 25}, {8, 23, 26}, {9, 24, 27}
};

dyads = {
  {10, 27}, {10, 33}, {11, 25}, {11, 28}, {12, 26}, {12, 32},
  {13, 25}, {13, 31}, {14, 27}, {14, 30}, {15, 26}, {15, 29},
  {16, 24}, {16, 30}, {17, 22}, {17, 31}, {18, 23}, {18, 29},
  {19, 22}, {19, 28}, {20, 24}, {20, 33}, {21, 23}, {21, 32}
};

crossR3[{a_, b_, c_}, {d_, e_, f_}] := {b f - c e, c d - a f, a e - b d};

completionRays = Map[
  Simplify[crossR3[peresRays[[#[[1]]]], peresRays[[#[[2]]]]]] &,
  dyads
];

allRays = Join[peresRays, completionRays];

implicitTriads = MapIndexed[
  Function[{d, idx}, {d[[1]], d[[2]], 33 + idx[[1]]}],
  dyads
];

allTriads = Join[explicitTriads, implicitTriads];

Print["  Peres rays:     ", Length[peresRays]];
Print["  Completion rays: ", Length[completionRays]];
Print["  All rays:       ", Length[allRays], " (expect 57)"];
Print["  All triads:     ", Length[allTriads], " (expect 40)"];

(* ============================================================
   PART 1: Truncated context category (74 contexts)
   ============================================================ *)

Print[""];
Print["----- PART 1: Truncated context category -----"];

trivialCtx = "V0";
subMASAs = Table["V_" <> ToString[k], {k, 1, 33}];
maxMASAs = Table["T_" <> ToString[a], {a, 1, 40}];
contexts = Join[{trivialCtx}, subMASAs, maxMASAs];

Print["  Contexts: ", Length[contexts], " (expect 74)"];

specs = Association[];
specs[trivialCtx] = {"trivial"};
Do[
  specs["V_" <> ToString[k]] = {{"V", k, "+"}, {"V", k, "-"}},
  {k, 1, 33}
];
Do[
  specs["T_" <> ToString[a]] = Map[{"T", a, #} &, allTriads[[a]]],
  {a, 1, 40}
];

subInTriad[k_, a_] := k <= 33 && MemberQ[allTriads[[a]], k];

minimalCtxs = Association[];
minimalCtxs[trivialCtx] = {};
Do[minimalCtxs["V_" <> ToString[k]] = {trivialCtx}, {k, 1, 33}];
Do[
  minimalCtxs["T_" <> ToString[a]] =
    Map["V_" <> ToString[#] &, Select[allTriads[[a]], # <= 33 &]],
  {a, 1, 40}
];

restrict[vBig_, vSub_, char_] := Which[
  vBig === vSub, char,
  vSub === trivialCtx, "trivial",
  StringStartsQ[vBig, "T_"] && StringStartsQ[vSub, "V_"],
    Module[{k, j},
      k = ToExpression[StringDrop[vSub, 2]];
      j = char[[3]];
      If[j === k, {"V", k, "+"}, {"V", k, "-"}]
    ],
  True, $Failed
];

cc = <|
  "contexts" -> contexts,
  "trivial" -> trivialCtx,
  "spectra" -> specs,
  "minimal" -> minimalCtxs,
  "restrict" -> (Function[char, restrict[#[[1]], #[[2]], char]] &)
|>;

Print["  Truncated category cc constructed."];
Print["  Restrict sanity (T_1 -> V_1):"];
Do[
  Print["    ", char, "  ->  ", restrict["T_1", "V_1", char]],
  {char, specs["T_1"]}
];

(* ============================================================
   PART 2: M_3(C) projection arithmetic
   ============================================================ *)

Print[""];
Print["----- PART 2: M_3(C) projection arithmetic -----"];

Id3 = IdentityMatrix[3];
projOfRay[v_] := Outer[Times, v, v] / (v . v);
P1 = projOfRay[{1, 0, 0}];
e0 = {1, 0, 0};
Print["  P1 idempotent? ", Simplify[P1 . P1 - P1] === ConstantArray[0, {3, 3}]];

(* ============================================================
   PART 3: Compute delta(P_1) at each context
   ============================================================ *)

Print[""];
Print["----- PART 3: Compute delta(P_1) componentwise -----"];

projAtomsAtCtx[ctx_] := Which[
  ctx === trivialCtx, {Id3},
  StringStartsQ[ctx, "V_"],
    Module[{k = ToExpression[StringDrop[ctx, 2]], Pk},
      Pk = projOfRay[peresRays[[k]]];
      {Pk, Id3 - Pk}
    ],
  StringStartsQ[ctx, "T_"],
    Module[{a = ToExpression[StringDrop[ctx, 2]]},
      Map[projOfRay[allRays[[#]]] &, allTriads[[a]]]
    ]
];

daseinChars[ctx_, supportVec_] := Module[{atoms, charsList, selected},
  atoms = projAtomsAtCtx[ctx];
  charsList = specs[ctx];
  selected = Map[
    Simplify[# . supportVec] =!= ConstantArray[0, Length[supportVec]] &,
    atoms
  ];
  Pick[charsList, selected]
];

deltaP1 = Association[];
Do[deltaP1[v] = daseinChars[v, e0], {v, contexts}];

Print["  delta(P1) at V_0:  ", deltaP1[trivialCtx]];
Print["  delta(P1) at V_1:  ", deltaP1["V_1"]];
Print["  delta(P1) at V_2:  ", deltaP1["V_2"]];
Print["  delta(P1) at V_4:  ", deltaP1["V_4"]];
Print["  delta(P1) at T_1:  ", deltaP1["T_1"]];

deltaSizes = Map[Length[deltaP1[#]] &, contexts];
deltaSizeCounts = Sort[Tally[deltaSizes]];
Print["  delta(P1) size histogram: ", deltaSizeCounts];

fullCount = Length[Select[contexts, deltaP1[#] === specs[#] &]];
emptyCount = Length[Select[contexts, deltaP1[#] === {} &]];
Print["  FULL at:    ", fullCount, " contexts"];
Print["  empty at:   ", emptyCount, " contexts"];
Print["  partial at: ", Length[contexts] - fullCount - emptyCount, " contexts"];

(* ============================================================
   PART 4: NOT(delta(P_1)) -- the Heyting-collapse witness
   ============================================================ *)

Print[""];
Print["----- PART 4: NOT(delta(P_1)) -----"];

liftProj[ccx_, vBig_, vSub_, sub_] := If[vBig === vSub,
  sub,
  Module[{rest},
    rest = ccx["restrict"][{vBig, vSub}];
    Select[ccx["spectra"][vBig], MemberQ[sub, rest[#]] &]
  ]
];

topSub[ccx_] := AssociationThread[
  ccx["contexts"] -> Map[ccx["spectra"][#] &, ccx["contexts"]]];

subEqQ[ccx_, s_, t_] := AllTrue[ccx["contexts"],
  Sort[s[#]] === Sort[t[#]] &];

heytingNot[ccx_, s_] := Module[{contexts0, result, mAt, lifted, v0, upperAny},
  contexts0 = ccx["contexts"];
  v0 = ccx["trivial"];
  result = Association[];
  Do[
    If[v === v0,
      result[v] = "PLACEHOLDER",
      mAt = ccx["minimal"][v];
      lifted = If[mAt === {}, {},
        Union @@ Map[liftProj[ccx, v, #, s[#]] &, mAt]];
      result[v] = Complement[ccx["spectra"][v], lifted]
    ],
    {v, contexts0}
  ];
  upperAny = AnyTrue[contexts0, # =!= v0 && result[#] =!= {} &];
  result[v0] = If[upperAny, ccx["spectra"][v0], {}];
  result
];

t0 = AbsoluteTime[];
notDelta = heytingNot[cc, deltaP1];
elapsed1 = AbsoluteTime[] - t0;
Print["  Elapsed: ", NumberForm[elapsed1, {6, 3}], " seconds"];

notDeltaIsBottom = AllTrue[contexts, notDelta[#] === {} &];
Print["  NOT(delta(P_1))_V = empty at EVERY context? ", notDeltaIsBottom];

Print["  Sample NOT(delta(P_1)) components:"];
Do[
  Print["    ", v, ":  ", notDelta[v]],
  {v, {trivialCtx, "V_1", "V_2", "V_4", "T_1", "T_5"}}
];

(* ============================================================
   PART 5: NOTNOT(delta(P_1)) = top
   ============================================================ *)

Print[""];
Print["----- PART 5: NOTNOT(delta(P_1)) check -----"];

t0 = AbsoluteTime[];
notNotDelta = heytingNot[cc, notDelta];
elapsed2 = AbsoluteTime[] - t0;
Print["  Elapsed: ", NumberForm[elapsed2, {6, 3}], " seconds"];

topAtCC = topSub[cc];
notNotDeltaIsTop = subEqQ[cc, notNotDelta, topAtCC];
Print["  NOTNOT(delta(P_1)) = top?         ", notNotDeltaIsTop];

deltaEqualsNotNotDelta = subEqQ[cc, deltaP1, notNotDelta];
Print["  delta(P_1) = NOTNOT(delta(P_1))? ", deltaEqualsNotNotDelta,
      "  (expect False)"];

(* ============================================================
   SUMMARY
   ============================================================ *)

Print[""];
Print["============================================================"];
Print["v6a SUMMARY"];
Print["============================================================"];
Print["  NOT(a) = bottom?           ", notDeltaIsBottom];
Print["  NOTNOT(a) = top?           ", notNotDeltaIsTop];
Print["  a Heyting-non-regular?    ", !deltaEqualsNotNotDelta];

If[notDeltaIsBottom && notNotDeltaIsTop && !deltaEqualsNotNotDelta,
  (
    Print[""];
    Print["  HEYTING-COLLAPSE THEOREM VERIFIED at the Peres-33 scale."];
    Print["  In the truncated category V'(M_3(C)) on Peres-33,"];
    Print["  delta(P_1) is non-bottom but NOT(delta(P_1)) = bottom."];
    Print["  By the v6-scope.md sec. 2 theorem, every non-bottom S"];
    Print["  satisfies NOT(S) = bottom, so the four-cell partition"];
    Print["  collapses to a two-cell (I, E) partition at any"];
    Print["  non-trivial kernel. Run v6.wl for |I|, |E| numbers."]
  ),
  (
    Print[""];
    Print["  UNEXPECTED RESULT. Re-examine v6-scope.md sec. 2."]
  )
];

Print["============================================================"];
