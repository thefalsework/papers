(* ::Package:: *)

(* ============================================================
   Route A computational checkpoint v2 -- P3 split-out
   ------------------------------------------------------------
   Companion to:
     preprints/four-position-partition/physics-anchor/feasibility.md sec. 4.4
     wolfram/physics-anchor/four-position-physics-v2.wl
       (full v2 script; P1 and P2 succeeded; P3 timed out in Cloud)
     wolfram/cores/heunen-landsman-spitters-2009.wl

   Why split: P3 has 7 contexts with spectrum sizes [1,2,2,4,2,2,4],
   giving 131072 candidate tuples in the unrestricted-product
   enumeration that the v2 main script uses. Filtering 131k tuples
   for subobject compatibility, then running O(|Sub|^2) four-cell
   analysis, exceeded the Wolfram Cloud cell time/output budget.
   This script uses direct subobject construction via the natural
   factoring of P3 as 'two diamonds joined at V_0', cutting the
   enumeration cost to ~2200 subobjects directly. Same generic
   machinery (with the liftProj identity-lift fix from v2).

   QUESTION (restated):
     For the P3 context category encoding non-commutativity via
     incomparability of two MASAs, does there exist S in
     Sub_cl(Sigma) such that
       (i)  S is Heyting non-regular  (NOT NOT S =/= S), AND
       (ii) NOT S =/= bottom-subobject?

   Expected (from the structural reasoning of v2 + P1 / P2 results):
     NON-VACUOUS. Each MASA-half of P3 is its own diamond (= P1),
     and the AB-half alone already supports a non-vacuous partition.
     P3 will confirm this on the larger context category.

   Reference: Doering 2012, arXiv:1202.2750, Props. 2 and 3.

   Execution: paste contents into a Wolfram Cloud cell and evaluate.
   No external dependencies. Expected output: ~30 lines.
   ============================================================ *)

ClearAll["Global`*"];


(* ============================================================
   GENERIC MACHINERY (copied from v2 with the liftProj fix)
   ============================================================ *)

liftProj[cc_, vBig_, vSub_, sub_] := If[vBig === vSub,
  sub,
  Module[{rest},
    rest = cc["restrict"][{vBig, vSub}];
    Select[cc["spectra"][vBig], MemberQ[sub, rest[#]] &]
  ]
];

bottomSub[cc_] := AssociationThread[
  cc["contexts"] -> ConstantArray[{}, Length[cc["contexts"]]]];
topSub[cc_] := AssociationThread[
  cc["contexts"] -> Map[cc["spectra"][#] &, cc["contexts"]]];
subEqQ[cc_, s_, t_] := AllTrue[cc["contexts"],
  Sort[s[#]] === Sort[t[#]] &];
leqSub[cc_, s_, t_] := AllTrue[cc["contexts"], SubsetQ[t[#], s[#]] &];
meetSub[cc_, s_, t_] := AssociationThread[
  cc["contexts"] -> Map[Intersection[s[#], t[#]] &, cc["contexts"]]];

heytingNot[cc_, s_] := Module[{contexts, result, mAt, lifted, v0, upperAny},
  contexts = cc["contexts"];
  v0 = cc["trivial"];
  result = Association[];
  Do[
    If[v === v0,
      result[v] = "PLACEHOLDER",
      mAt = cc["minimal"][v];
      lifted = If[mAt === {}, {},
        Union @@ Map[liftProj[cc, v, #, s[#]] &, mAt]];
      result[v] = Complement[cc["spectra"][v], lifted]
    ],
    {v, contexts}
  ];
  upperAny = AnyTrue[contexts, # =!= v0 && result[#] =!= {} &];
  result[v0] = If[upperAny, cc["spectra"][v0], {}];
  result
];

regularQ[cc_, s_] := subEqQ[cc, s, heytingNot[cc, heytingNot[cc, s]]];


(* ============================================================
   P3 CONTEXT CATEGORY
   ============================================================ *)

p3Contexts = {"V0",
  "Va", "Vb", "VtopAB",
  "Vc", "Vd", "VtopCD"};
p3Leq = Function[{a, b}, a === b ||
  (a === "V0") ||
  (a === "Va" && b === "VtopAB") ||
  (a === "Vb" && b === "VtopAB") ||
  (a === "Vc" && b === "VtopCD") ||
  (a === "Vd" && b === "VtopCD")];
p3Spectra = <|
  "V0"   -> {"*"},
  "Va"   -> {"0a", "1a"}, "Vb" -> {"0b", "1b"},
  "VtopAB" -> {"AB00", "AB01", "AB10", "AB11"},
  "Vc"   -> {"0c", "1c"}, "Vd" -> {"0d", "1d"},
  "VtopCD" -> {"CD00", "CD01", "CD10", "CD11"}
|>;
p3Restrict = <|
  {"Va", "V0"} -> Function[x, "*"], {"Vb", "V0"} -> Function[x, "*"],
  {"Vc", "V0"} -> Function[x, "*"], {"Vd", "V0"} -> Function[x, "*"],
  {"VtopAB", "V0"} -> Function[x, "*"],
  {"VtopCD", "V0"} -> Function[x, "*"],
  {"VtopAB", "Va"} -> Function[x, Switch[x, "AB00", "0a", "AB01", "0a",
                                            "AB10", "1a", "AB11", "1a"]],
  {"VtopAB", "Vb"} -> Function[x, Switch[x, "AB00", "0b", "AB01", "1b",
                                            "AB10", "0b", "AB11", "1b"]],
  {"VtopCD", "Vc"} -> Function[x, Switch[x, "CD00", "0c", "CD01", "0c",
                                            "CD10", "1c", "CD11", "1c"]],
  {"VtopCD", "Vd"} -> Function[x, Switch[x, "CD00", "0d", "CD01", "1d",
                                            "CD10", "0d", "CD11", "1d"]]
|>;
p3Minimal = <|
  "Va" -> {"Va"}, "Vb" -> {"Vb"},
  "VtopAB" -> {"Va", "Vb"},
  "Vc" -> {"Vc"}, "Vd" -> {"Vd"},
  "VtopCD" -> {"Vc", "Vd"}
|>;
cc3 = <|
  "contexts" -> p3Contexts, "trivial" -> "V0",
  "leq" -> p3Leq, "spectra" -> p3Spectra,
  "restrict" -> p3Restrict, "minimal" -> p3Minimal
|>;


(* ============================================================
   DIRECT SUBOBJECT CONSTRUCTION
   ------------------------------------------------------------
   P3 factors as two independent diamonds (AB and CD) joined at
   V_0. Each half-diamond contributes a triple (S_vA, S_vB, S_vTop).
   For each pair of half-diamond triples, the V_0 component is
   forced to {*} if either side has a non-empty upper component;
   otherwise V_0 can be either {} or {*}.

   This avoids the 131k-tuple blow-up of allCandidates[cc3].
   ============================================================ *)

(* Build all valid half-diamond triples (S_vA, S_vB, S_vTop). *)
buildHalfDiamond[cc_, vA_, vB_, vTop_] := Module[{out = {}, sA, sB, sTopMax, restrA, restrB},
  restrA = cc["restrict"][{vTop, vA}];
  restrB = cc["restrict"][{vTop, vB}];
  Do[
    Do[
      sTopMax = Select[cc["spectra"][vTop],
        MemberQ[sA, restrA[#]] && MemberQ[sB, restrB[#]] &];
      Do[
        AppendTo[out, <|vA -> sA, vB -> sB, vTop -> sTop|>],
        {sTop, Subsets[sTopMax]}
      ],
      {sB, Subsets[cc["spectra"][vB]]}
    ],
    {sA, Subsets[cc["spectra"][vA]]}
  ];
  out
];

(* Combine two half-diamonds into P3 subobjects with V_0. *)
buildP3Subobjects[cc_] := Module[{abList, cdList, result, anyAB, anyCD},
  abList = buildHalfDiamond[cc, "Va", "Vb", "VtopAB"];
  cdList = buildHalfDiamond[cc, "Vc", "Vd", "VtopCD"];
  Print["  half-diamond AB triples: ", Length[abList],
        "; half-diamond CD triples: ", Length[cdList]];
  result = Reap[
    Do[
      Do[
        anyAB = ab["Va"] =!= {} || ab["Vb"] =!= {} || ab["VtopAB"] =!= {};
        anyCD = cd["Vc"] =!= {} || cd["Vd"] =!= {} || cd["VtopCD"] =!= {};
        If[!anyAB && !anyCD,
          Sow[Join[ab, cd, <|"V0" -> {}|>]];
          Sow[Join[ab, cd, <|"V0" -> {"*"}|>]],
          Sow[Join[ab, cd, <|"V0" -> {"*"}|>]]
        ],
        {cd, cdList}
      ],
      {ab, abList}
    ]
  ][[2, 1]];
  result
];


(* ============================================================
   RUN
   ============================================================ *)

Print["============================================================"];
Print["CANDIDATE P3: two-MASA (incompatible commutative blocks)"];
Print["  Reading: Two MASAs sharing only V_0; e.g. Z-MASA and X-MASA"];
Print["           of M_2(C) viewed as abelian C^2's with refinements"];
Print["           -- the simplest finite-dim context category"];
Print["           encoding non-commutativity through INCOMPARABILITY"];
Print["           of maximal contexts."];
Print["  Contexts (7): ", cc3["contexts"]];
Print["  Spectrum sizes: ",
  AssociationThread[cc3["contexts"] -> Map[
    Length[cc3["spectra"][#]] &, cc3["contexts"]]]];

Print["  Building Sub_cl(Sigma) by direct construction..."];
allSub = buildP3Subobjects[cc3];
Print["  Number of clopen subobjects in Sub_cl(Sigma): ", Length[allSub]];

bot = bottomSub[cc3];

Print["  Classifying regularity..."];
nonReg = Select[allSub, !regularQ[cc3, #] &];
Print["  Non-regular subobjects: ", Length[nonReg], " of ", Length[allSub]];

nonRegNotBot = Select[nonReg, !subEqQ[cc3, heytingNot[cc3, #], bot] &];
Print["  Non-regular AND NOT(s) =/= bottom: ", Length[nonRegNotBot]];

Print["  Searching for kernels admitting all four cells (short-circuits on first hit)..."];

(* Short-circuit kernel search. *)
candKernels = Select[allSub, !subEqQ[cc3, #, bot] &];
witness = None;
witnessCounts = None;
Catch[
  Do[
    Module[{notA, notNotA, nonBot, infra, ref, expl, dist, ic, rc, ec, dc},
      notA = heytingNot[cc3, a];
      notNotA = heytingNot[cc3, notA];
      nonBot = Select[allSub, !subEqQ[cc3, #, bot] &];
      infra = Select[nonBot, leqSub[cc3, #, a] &];
      ref   = Select[nonBot, leqSub[cc3, #, notA] &];
      expl  = Select[nonBot, leqSub[cc3, #, notNotA] && !leqSub[cc3, #, a] &];
      dist  = Select[nonBot,
        !subEqQ[cc3, meetSub[cc3, #, a], bot] &&
        !subEqQ[cc3, meetSub[cc3, #, notA], bot] &];
      ic = Length[infra]; rc = Length[ref];
      ec = Length[expl];  dc = Length[dist];
      If[ic > 0 && rc > 0 && ec > 0 && dc > 0,
        witness = a;
        witnessCounts = {ic, rc, ec, dc};
        Throw[witness]
      ]
    ],
    {a, candKernels}
  ]
];

If[witness === None,
  Print["  Kernels with ALL FOUR cells inhabited: 0"];
  Print["  CANDIDATE P3 VERDICT: DEGENERATE"],

  Print["  Witness kernel a found."];
  Print["    kernel  a =     ", witness];
  Print["    NOT a       =   ", heytingNot[cc3, witness]];
  Print["    (i, r, e, d) =  ", witnessCounts];
  Print["    kernel regular? = ", regularQ[cc3, witness]];
  Print["  CANDIDATE P3 VERDICT: NON-VACUOUS"]
];

Print[];
Print["[End of P3 split-out check]"];
