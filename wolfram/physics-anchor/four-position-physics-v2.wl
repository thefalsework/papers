(* ::Package:: *)

(* ============================================================
   Route A computational checkpoint v2 -- Sub_cl(Sigma) enumeration
   ------------------------------------------------------------
   Companion to:
     preprints/four-position-partition/physics-anchor/feasibility.md sec. 4.4
     wolfram/cores/heunen-landsman-spitters-2009.wl
       (mechanisms bi_heyting_structure_on_clopen_subobjects and
                   non_regular_witness_with_non_bottom_complement)
     wolfram/physics-anchor/four-position-physics-v1.wl
       (the Route-B exploration; this script is the natural
        successor at one structural level deeper)

   QUESTION (feasibility sec. 4.4):
     For some small finite context category modelling a piece of
     V(A) for a finite-dim C*-algebra A, does there exist S in
     Sub_cl(Sigma) such that
       (i)  S is Heyting non-regular  (NOT NOT S =/= S), AND
       (ii) NOT S =/= bottom-subobject  (NOT S has a non-empty
            stagewise component at some context)?
     A positive answer at any candidate licenses a non-vacuous
     four-position partition at the topos-quantum-mechanics level.

   STRUCTURAL INSIGHT FROM ROUTE B:
     The Route-B candidates all failed because their context
     posets were antichains of minimal contexts above the trivial
     bottom, with no contexts containing multiple distinct
     minimal sub-contexts. Without such a non-trivial 'join,'
     the Doering stagewise NOT formula
        P_{(NOT S)_V} = 1 - JOIN_{V' in m_V} P_{S_{V'}}
     collapses to ordinary Boolean negation at each context
     separately; non-regularity never arises. v2 explicitly tests
     context categories whose maximal element(s) DO have multiple
     distinct minimal sub-contexts. That is the structural
     prerequisite for non-trivial Doering-Heyting NOT.

   REFERENCE:
     Doering 2012, arXiv:1202.2750, especially
       Prop. 2 (stagewise Heyting NOT) and
       Prop. 3 (Heyting-regularity characterisation).

   Execution: load into a Wolfram (or Mathematica) kernel via Get.
   No external dependencies. Output is compact -- a few lines per
   candidate plus a final summary.
   ============================================================ *)

ClearAll["Global`*"];


(* ============================================================
   GENERIC MACHINERY
   ------------------------------------------------------------
   A 'context category' is encoded as an Association
     <| "contexts" -> {V_0, V_1, ...},
        "trivial"  -> V_0,
        "leq"      -> Function[{a, b}, ...] (a leq b iff a is a
                       sub-context of b in V(A); leq is reflexive),
        "spectra"  -> <| V -> list_of_spectrum_points, ... |>,
        "restrict" -> <| {vBig, vSub} -> Function[..], ... |>
                       (vSub leq vBig; maps Sigma_{vBig} ->
                        Sigma_{vSub}, the Gelfand-spectrum
                        restriction),
        "minimal"  -> <| V -> list_of_minimal_subcontexts, ... |>
                       (these are the V' in Doering's m_V: minimal
                        NON-TRIVIAL sub-contexts of V. For V
                        itself minimal, m_V = {V}; for V = V_0
                        the trivial context, m_V is not defined
                        and Heyting NOT is not computed there
                        -- the V_0 component of any subobject is
                        forced by the upper components.) |>.

   Projections in V correspond bijectively to clopen subsets of
   Sigma_V via Gelfand duality. We represent projections as
   subsets throughout. Operations:
     ZERO    = {}            (the zero projection)
     ONE     = Sigma_V       (the identity projection)
     P AND Q = Intersection
     P OR Q  = Union
     1 - P   = Complement against Sigma_V

   Lifting a projection from a sub-context V' to a bigger context
   V (with V' leq V) is done by pulling back via the restriction
   map: P^liftedFromV' = { lambda in Sigma_V : restrict(lambda)
                           in Sigma_{V'} is in P }.
   ============================================================ *)

(* lift a subset of Sigma_{vSub} up to a subset of Sigma_{vBig}.
   The vBig === vSub case must be the identity lift (sub itself);
   handling this explicitly because the "restrict" association is
   only populated for proper inclusions vSub strictly below vBig.
   Without this guard, liftProj returns {} for the V leq V case,
   which then corrupts Doering Prop. 2 at minimal contexts (the
   NOT becomes the full spectrum instead of the Boolean complement
   of the local component) and corrupts double-negation downstream. *)
liftProj[cc_, vBig_, vSub_, sub_] := If[vBig === vSub,
  sub,
  Module[{rest},
    rest = cc["restrict"][{vBig, vSub}];
    Select[cc["spectra"][vBig], MemberQ[sub, rest[#]] &]
  ]
];

(* candidate tuples in the product of PowerSet[Sigma_V] over V *)
allCandidates[cc_] := Module[{contexts, choices},
  contexts = cc["contexts"];
  choices = Map[Subsets[cc["spectra"][#]] &, contexts];
  Map[AssociationThread[contexts -> #] &, Tuples[choices]]
];

(* subobject compatibility: for every vSub leq vBig (with
   vSub =/= vBig), restrict(S_{vBig}) is a subset of S_{vSub}. *)
subobjectQ[cc_, s_] := Module[{contexts, pairs},
  contexts = cc["contexts"];
  pairs = Select[Tuples[{contexts, contexts}],
    cc["leq"][#[[2]], #[[1]]] && #[[1]] =!= #[[2]] &];
  AllTrue[pairs, Function[{p},
    Module[{vBig, vSub, rest},
      vBig = p[[1]]; vSub = p[[2]];
      rest = cc["restrict"][{vBig, vSub}];
      SubsetQ[s[vSub], rest /@ s[vBig]]
    ]
  ]]
];

(* enumerate Sub_cl(Sigma) for the finite cc *)
subobjectsOf[cc_] := Select[allCandidates[cc], subobjectQ[cc, #] &];

(* the bottom and top subobjects *)
bottomSub[cc_] := AssociationThread[
  cc["contexts"] -> ConstantArray[{}, Length[cc["contexts"]]]];
topSub[cc_] := AssociationThread[
  cc["contexts"] -> Map[cc["spectra"][#] &, cc["contexts"]]];

(* equality of subobjects (component-wise, ignoring list order) *)
subEqQ[cc_, s_, t_] := AllTrue[cc["contexts"],
  Sort[s[#]] === Sort[t[#]] &];

(* subobject inclusion *)
leqSub[cc_, s_, t_] := AllTrue[cc["contexts"], SubsetQ[t[#], s[#]] &];

(* pointwise meet of subobjects *)
meetSub[cc_, s_, t_] := AssociationThread[
  cc["contexts"] -> Map[Intersection[s[#], t[#]] &, cc["contexts"]]];

(* Doering Prop. 2 stagewise Heyting NOT. Computes (NOT s)_V
   for each non-trivial V via the formula
     (NOT s)_V = Sigma_V \ Union_{V' in m_V} liftProj(V, V', s_{V'}).
   For the trivial context V_0, the result component is forced
   by subobject compatibility: empty if all upper components are
   empty, else full Sigma_{V_0}. *)
heytingNot[cc_, s_] := Module[{contexts, result, mAt, lifted, v0, upperAny},
  contexts = cc["contexts"];
  v0 = cc["trivial"];
  result = Association[];
  Do[
    If[v === v0,
      (* placeholder; fill in after the upper components *)
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

(* Heyting-regularity: S = NOT NOT S *)
regularQ[cc_, s_] := subEqQ[cc, s, heytingNot[cc, heytingNot[cc, s]]];

(* four-cell partition at kernel a (a subobject in Sub_cl) *)
fourCellSummary[cc_, allSub_, a_] := Module[{
    notA, notNotA, nonBot, infra, ref, expl, dist, bot},
  bot = bottomSub[cc];
  notA = heytingNot[cc, a];
  notNotA = heytingNot[cc, notA];
  nonBot = Select[allSub, !subEqQ[cc, #, bot] &];
  infra = Select[nonBot, leqSub[cc, #, a] &];
  ref   = Select[nonBot, leqSub[cc, #, notA] &];
  expl  = Select[nonBot,
    leqSub[cc, #, notNotA] && !leqSub[cc, #, a] &];
  dist  = Select[nonBot,
    !subEqQ[cc, meetSub[cc, #, a], bot] &&
    !subEqQ[cc, meetSub[cc, #, notA], bot] &];
  <|
    "kernel"         -> a,
    "kernelRegular?" -> regularQ[cc, a],
    "notA_isBottom?" -> subEqQ[cc, notA, bot],
    "i" -> Length[infra], "r" -> Length[ref],
    "e" -> Length[expl],  "d" -> Length[dist],
    "all4" -> (Length[infra] > 0 && Length[ref] > 0 &&
               Length[expl] > 0 && Length[dist] > 0)
  |>
];

(* compact subobject pretty-printer for witness output *)
ppSub[cc_, s_] := Row[{"<",
  Sequence @@ Riffle[
    Map[Row[{#, "=", s[#]}] &, cc["contexts"]],
    "; "],
  ">"}];


(* main per-candidate report *)
runCandidate[name_, physicsReading_, cc_] := Module[{
    allSub, nonReg, nonRegNotBot, kernelRows, anyNV,
    witnessSub, witnessNot, bestRow, maxCells, candKernels, bot},
  bot = bottomSub[cc];
  Print["============================================================"];
  Print["CANDIDATE ", name];
  Print["  Reading: ", physicsReading];
  Print["  Contexts (", Length[cc["contexts"]], "): ", cc["contexts"]];
  Print["  Spectrum sizes: ",
    AssociationThread[cc["contexts"] -> Map[
      Length[cc["spectra"][#]] &, cc["contexts"]]]];

  allSub = subobjectsOf[cc];
  Print["  Number of clopen subobjects in Sub_cl(Sigma): ", Length[allSub]];

  nonReg = Select[allSub, !regularQ[cc, #] &];
  Print["  Non-regular subobjects: ", Length[nonReg], " of ", Length[allSub]];

  nonRegNotBot = Select[nonReg,
    !subEqQ[cc, heytingNot[cc, #], bot] &];
  Print["  Non-regular AND NOT(s) =/= bottom: ", Length[nonRegNotBot]];

  (* Look for non-vacuous four-cell partition at any kernel. *)
  candKernels = Select[allSub, !subEqQ[cc, #, bot] &];
  kernelRows = Map[fourCellSummary[cc, allSub, #] &, candKernels];
  anyNV = Select[kernelRows, #["all4"] &];
  If[Length[anyNV] > 0,
    Print["  Kernels with ALL FOUR cells inhabited: ", Length[anyNV],
          " (of ", Length[candKernels], " non-bottom kernel choices)"];
    witnessSub = First[anyNV]["kernel"];
    witnessNot = heytingNot[cc, witnessSub];
    Print["  Witness kernel a = ", ppSub[cc, witnessSub]];
    Print["    NOT a          = ", ppSub[cc, witnessNot]];
    Print["    (i, r, e, d)   = (",
      First[anyNV]["i"], ", ", First[anyNV]["r"], ", ",
      First[anyNV]["e"], ", ", First[anyNV]["d"], ")"];
    Print["    kernel regular? = ", First[anyNV]["kernelRegular?"]];
    Print["  CANDIDATE ", name, " VERDICT: NON-VACUOUS"];
    maxCells = 4,

    (* else: report max cells achieved at any single kernel *)
    bestRow = First[SortBy[kernelRows,
      -({#["i"], #["r"], #["e"], #["d"]} /. n_Integer :> If[n > 0, 1, 0])
        /. l_List :> Total[l]]];
    maxCells = Count[{bestRow["i"], bestRow["r"], bestRow["e"], bestRow["d"]},
      n_ /; n > 0];
    Print["  Kernels with ALL FOUR cells inhabited: 0"];
    Print["  Max cells inhabited at any single kernel: ", maxCells];
    Print["    e.g. kernel = ", ppSub[cc, bestRow["kernel"]],
          "   (i, r, e, d) = (",
      bestRow["i"], ", ", bestRow["r"], ", ",
      bestRow["e"], ", ", bestRow["d"], ")"];
    Print["  CANDIDATE ", name, " VERDICT: DEGENERATE"]
  ];
  Print[];
  {Length[anyNV] > 0, maxCells, Length[allSub], Length[nonReg],
   Length[nonRegNotBot]}
];


(* ============================================================
   CANDIDATE P1: 'Diamond' -- minimal context category with a
   non-trivial join.
   ------------------------------------------------------------
   Contexts:  V_0  <  V_a, V_b  <  V_top
   Spectra:
     Sigma(V_0)   = {*}
     Sigma(V_a)   = {0_a, 1_a}    (2-point, V_a = span(1, P_a))
     Sigma(V_b)   = {0_b, 1_b}    (V_b = span(1, P_b))
     Sigma(V_top) = {00, 01, 10, 11}
       (product of Sigma(V_a) and Sigma(V_b); V_top = span(1, P_a, P_b)
        when P_a P_b = P_b P_a, e.g. an abelian C^4)
   Physics reading: two commuting binary measurements (e.g. ZI
   and IZ in a 2-qubit system, restricted to one Boolean 4-element
   MASA viewed as having two distinguished generating projections).
   This is the smallest context category with m_{V_top} non-
   singleton (m_{V_top} = {V_a, V_b}); it is exactly the case
   excluded by Route B. The underlying algebra is COMMUTATIVE
   (C^4), so a positive verdict here would tell us non-vacuity
   is achievable without quantum non-commutativity -- a structural
   fact about Sub_cl, not a quantum-physics witness in itself.
   ============================================================ *)

p1Contexts = {"V0", "Va", "Vb", "Vtop"};
p1Leq = Function[{a, b}, a === b ||
  (a === "V0") ||
  (a === "Va" && b === "Vtop") ||
  (a === "Vb" && b === "Vtop")];
p1Spectra = <|
  "V0"   -> {"*"},
  "Va"   -> {"0a", "1a"},
  "Vb"   -> {"0b", "1b"},
  "Vtop" -> {"00", "01", "10", "11"}
|>;
p1Restrict = <|
  {"Va", "V0"}   -> Function[x, "*"],
  {"Vb", "V0"}   -> Function[x, "*"],
  {"Vtop", "V0"} -> Function[x, "*"],
  {"Vtop", "Va"} -> Function[x, Switch[x, "00", "0a", "01", "0a",
                                          "10", "1a", "11", "1a"]],
  {"Vtop", "Vb"} -> Function[x, Switch[x, "00", "0b", "01", "1b",
                                          "10", "0b", "11", "1b"]]
|>;
p1Minimal = <|
  "Va"   -> {"Va"},
  "Vb"   -> {"Vb"},
  "Vtop" -> {"Va", "Vb"}
|>;
cc1 = <|
  "contexts" -> p1Contexts, "trivial"  -> "V0",
  "leq" -> p1Leq, "spectra" -> p1Spectra,
  "restrict" -> p1Restrict, "minimal" -> p1Minimal
|>;

{anyP1, maxP1, nSubP1, nNonRegP1, nNRGoodP1} =
  runCandidate["P1: diamond",
    "Two commuting binary measurements; V_top = abelian C^4 with two distinguished generating projections",
    cc1];


(* ============================================================
   CANDIDATE P2: 'Triple-join' -- V(C^3), the full sub-MASA
   poset of the abelian 3-dimensional algebra.
   ------------------------------------------------------------
   Contexts:  V_0 < V_1, V_2, V_3 < V_top = C^3
   Spectra:
     Sigma(V_0)   = {*}
     Sigma(V_i)   = {0_i, 1_i}     (V_i = span(1, e_i))
     Sigma(V_top) = {L1, L2, L3}    (lambda_j: e_k -> delta_{jk})
   m_{V_top} = {V_1, V_2, V_3}
   Physics reading: a single triadic Boolean classical observable
   with three orthogonal events and three pairwise sub-Boolean
   refinements (each refinement "is the j-th event the outcome?").
   ============================================================ *)

p2Contexts = {"V0", "V1", "V2", "V3", "Vtop"};
p2Leq = Function[{a, b}, a === b ||
  (a === "V0") ||
  (MemberQ[{"V1", "V2", "V3"}, a] && b === "Vtop")];
p2Spectra = <|
  "V0"   -> {"*"},
  "V1"   -> {"01", "11"},  "V2" -> {"02", "12"},  "V3" -> {"03", "13"},
  "Vtop" -> {"L1", "L2", "L3"}
|>;
(* restriction maps: lambda_j in Sigma(Vtop) restricts via e_k to
   "0k" if j != k and "1k" if j == k. *)
p2RestTopToVi[i_][lambda_] := Module[{j},
  j = ToExpression[StringDrop[lambda, 1]];   (* "L1" -> 1, etc. *)
  If[j === i, "1" <> ToString[i], "0" <> ToString[i]]
];
p2Restrict = <|
  {"V1", "V0"} -> Function[x, "*"],
  {"V2", "V0"} -> Function[x, "*"],
  {"V3", "V0"} -> Function[x, "*"],
  {"Vtop", "V0"} -> Function[x, "*"],
  {"Vtop", "V1"} -> p2RestTopToVi[1],
  {"Vtop", "V2"} -> p2RestTopToVi[2],
  {"Vtop", "V3"} -> p2RestTopToVi[3]
|>;
p2Minimal = <|
  "V1" -> {"V1"}, "V2" -> {"V2"}, "V3" -> {"V3"},
  "Vtop" -> {"V1", "V2", "V3"}
|>;
cc2 = <|
  "contexts" -> p2Contexts, "trivial" -> "V0",
  "leq" -> p2Leq, "spectra" -> p2Spectra,
  "restrict" -> p2Restrict, "minimal" -> p2Minimal
|>;

{anyP2, maxP2, nSubP2, nNonRegP2, nNRGoodP2} =
  runCandidate["P2: triple-join (V(C^3) sub-MASA poset)",
    "Three orthogonal classical events; V_top = abelian C^3",
    cc2];


(* ============================================================
   CANDIDATE P3: 'Two-MASA' -- the smallest finite-dim context
   pattern where two MAXIMAL contexts share only the trivial.
   ------------------------------------------------------------
   Contexts:  V_0 < V_a, V_b
              V_0 < V_c, V_d
              V_a, V_b < V_topAB
              V_c, V_d < V_topCD
   No relation between {V_a, V_b, V_topAB} and {V_c, V_d, V_topCD}
   other than that they share V_0. Spectra are isomorphic between
   the two MASAs but the MASAs are NOT comparable as sub-contexts
   of any single bigger context.
   Physics reading: two non-commuting MASAs in M_2(C) (e.g. the
   Z-MASA and the X-MASA, viewed as abelian C^2 subalgebras with
   their own discrete refinements). The 'non-commutativity' is
   encoded by V_topAB and V_topCD being incomparable; there is
   NO single classical context containing both. This is the
   feature Route B's candidates lacked at the MASA-pair level.
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

{anyP3, maxP3, nSubP3, nNonRegP3, nNRGoodP3} =
  runCandidate["P3: two-MASA (incompatible commutative blocks)",
    "Two MASAs sharing only V_0; e.g. Z-MASA and X-MASA of M_2(C) viewed as abelian C^2's with refinements -- the simplest finite-dim context category encoding non-commutativity through INCOMPARABILITY of maximal contexts",
    cc3];


(* ============================================================
   FINAL SUMMARY
   ============================================================ *)

Print["============================================================"];
Print["FINAL SUMMARY"];
Print["============================================================"];
Print[];
Print[StringPadRight["candidate", 50],
  StringPadRight["|Sub_cl|", 10],
  StringPadRight["non-reg", 9],
  StringPadRight["nr+notBot", 11],
  StringPadRight["max cells", 11],
  "verdict"];
Print[StringPadRight["----------", 50],
  StringPadRight["--------", 10],
  StringPadRight["-------", 9],
  StringPadRight["---------", 11],
  StringPadRight["---------", 11],
  "-------"];
fmt[name_, nSub_, nNR_, nNRGood_, maxC_, any_] := Print[
  StringPadRight[name, 50],
  StringPadRight[ToString[nSub], 10],
  StringPadRight[ToString[nNR], 9],
  StringPadRight[ToString[nNRGood], 11],
  StringPadRight[ToString[maxC], 11],
  If[any, "NON-VACUOUS", "DEGENERATE"]];
fmt["P1: diamond (V_top = C^4 with 2 generators)",
  nSubP1, nNonRegP1, nNRGoodP1, maxP1, anyP1];
fmt["P2: triple-join (V(C^3))",
  nSubP2, nNonRegP2, nNRGoodP2, maxP2, anyP2];
fmt["P3: two-MASA (incompatible blocks)",
  nSubP3, nNonRegP3, nNRGoodP3, maxP3, anyP3];
Print[];
Print["Reading the table:"];
Print["  |Sub_cl|   = number of clopen subobjects (i.e. valid sub-presheaves)"];
Print["  non-reg    = number of Heyting non-regular subobjects (NOT NOT S =/= S)"];
Print["  nr+notBot  = number of non-regular S with NOT S =/= bottom (the"];
Print["               feasibility.md sec. 4.4 'structural prerequisite' for"];
Print["               a non-vacuous four-position partition at kernel S)"];
Print["  max cells  = max cells (out of 4: Infrastructure / Refusal /"];
Print["               Exploitation / Distribution) inhabited at any single"];
Print["               non-bottom kernel choice"];
Print["  verdict    = NON-VACUOUS if some kernel inhabits all 4 cells,"];
Print["               DEGENERATE otherwise"];
Print[];
Print["Structural notes:"];
Print["  - P1, P2, P3 all have at least one context with m_V non-singleton"];
Print["    (V_top in P1/P2; V_topAB and V_topCD in P3). This is the"];
Print["    structural prerequisite Route B's candidates lacked."];
Print["  - P1 and P2 underlying algebras are COMMUTATIVE (C^4, C^3); P3"];
Print["    is the first to encode non-commutativity, via the incomparability"];
Print["    of V_topAB and V_topCD."];
Print["  - If P1 or P2 verdicts non-vacuous: structural prerequisite alone"];
Print["    suffices, independently of quantum non-commutativity. This"];
Print["    means the partition theorem at Sub_cl(Sigma) does NOT distinguish"];
Print["    commutative-and-richly-structured contexts from non-commutative"];
Print["    ones; the framework's contribution is at a different level."];
Print["  - If P3 verdicts non-vacuous and P1, P2 do not: non-commutativity"];
Print["    is genuinely load-bearing for non-vacuity in Sub_cl(Sigma)."];
Print["  - If none verdict non-vacuous: structural prerequisite is not"];
Print["    sufficient, and the obstacle lies deeper than the antichain"];
Print["    structure of Route B."];
Print[];
Print["[End of physics-anchor Route-A checkpoint v2]"];
