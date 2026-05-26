(* ::Package:: *)

(* ============================================================
   Route A v3: Bohrification-native kernel candidates
   ------------------------------------------------------------
   Companion to:
     preprints/four-position-partition/physics-anchor/v3-scope.md
     preprints/four-position-partition/physics-anchor/feasibility.md
     wolfram/cores/heunen-landsman-spitters-2009.wl
     wolfram/physics-anchor/four-position-physics-v2.wl
     wolfram/physics-anchor/four-position-physics-v2-p3.wl

   QUESTION (v3-scope.md sec. 1):
     For poset-isomorphic context categories over a non-commutative
     algebra (M_2(C) (+) C) and a commutative algebra (C^7), do
     Bohrification-native kernel candidates (daseinisation-derived,
     Heyting-derived) produce four-cell partition patterns that
     differ between the two sides? A positive result requires
     cell-NON-EMPTINESS divergence traceable to daseinisation
     lifts at non-containing contexts.

   DIMENSIONALITY CAVEAT (v3-scope.md sec. 3.4):
     M_2(C) has dim 2, below the Kochen-Specker threshold of 3.
     So the KS gap is not expected to surface in this discretisation;
     a negative or mixed cell-non-emptiness result is expected.
     v3 on M_2(C) (+) C is a sanity-check + cell-cardinality-baseline
     run; v4 on M_3(C) is the structural next step.

   KERNEL CANDIDATES (v3-scope.md sec. 4):
     4.1  dasein(P)
     4.2  dasein(P) v dasein(-P)
     4.3  dasein(P) ^ dasein(-P)
     4.4  anti-daseinisation (inner-daseinisation-derived)
     4.5  dasein(P) ^ -dasein(-P)
     4.6  -(dasein(P) v dasein(-P))   -- the KS-gap kernel
     4.7  Exhaustive sweep over non-regular subobjects
     4.8  dasein(P) -> dasein(-P)     -- Heyting implication

   Execution: paste contents into Wolfram Cloud cell and evaluate.
   No external dependencies. Output: ~80-150 lines.
   ============================================================ *)

ClearAll["Global`*"];


(* ============================================================
   PART A: GENERIC MACHINERY (from v2 with liftProj fix + new ops)
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

(* Join is pointwise union: in a presheaf topos, the pointwise
   union of valid subobjects is automatically a valid subobject
   (restrict(S_V cup T_V) = restrict(S_V) cup restrict(T_V),
   each piece is contained in the V'-component, union still
   contained in S_V' cup T_V'). No additional closure needed. *)
joinSub[cc_, s_, t_] := AssociationThread[
  cc["contexts"] -> Map[Union[s[#], t[#]] &, cc["contexts"]]];

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

(* Heyting implication: largest x with x ^ s leq t.
   In a complete Heyting algebra of subobjects we can compute it
   by enumeration if Sub is small: pick the union of all S in Sub
   with S ^ s leq t. *)
heytingImpl[cc_, allSub_, s_, t_] := Module[{eligible, bigOne},
  eligible = Select[allSub, leqSub[cc, meetSub[cc, #, s], t] &];
  If[Length[eligible] === 0,
    bottomSub[cc],
    (* take the join of all eligible *)
    Fold[joinSub[cc, #1, #2] &, First[eligible], Rest[eligible]]
  ]
];


(* ============================================================
   PART B: LINEAR-ALGEBRAIC PROJECTION ARITHMETIC
   ------------------------------------------------------------
   Quantum algebra A_q = M_2(C) (+) C, represented as pairs
   {M, s} where M is a 2x2 complex matrix and s is a scalar.
   Classical algebra A_c = C^7, represented as 7-component lists.
   ============================================================ *)

(* Pauli matrices and standard projections *)
IdM = IdentityMatrix[2];
Pz = {{1, 0}, {0, 0}};       (* |0><0| *)
Px = {{1/2, 1/2}, {1/2, 1/2}}; (* |+><+| *)
Py = {{1/2, -I/2}, {I/2, 1/2}}; (* |+i><+i| *)

(* Element wrappers *)
qElem[M_, s_] := {M, s};
qZero = qElem[ConstantArray[0, {2, 2}], 0];
qOne  = qElem[IdM, 1];

(* Q-side: is P - Q positive semidefinite? *)
(* Standard tolerance for floating-point. *)
psdTol = 10^-8;
psdQ[M_] := Module[{eigs},
  eigs = Eigenvalues[N[(M + ConjugateTranspose[M])/2]];
  AllTrue[eigs, Re[#] >= -psdTol &]
];
qDom[P_, Q_] := psdQ[P[[1]] - Q[[1]]] && Re[P[[2]] - Q[[2]]] >= -psdTol;

(* C-side: componentwise dominance *)
cDom[P_, Q_] := AllTrue[Range[Length[P]], P[[#]] >= Q[[#]] - psdTol &];


(* ============================================================
   PART C: CONTEXT CATEGORIES (quantum + classical)
   ============================================================ *)

(* ---- Quantum: cc_q for V_d(M_2(C) (+) C), 8 contexts ---- *)

contextsQ = {"V0", "VZ", "VX", "VY", "VC",
             "VtopZ", "VtopX", "VtopY"};

leqQ = Function[{a, b}, a === b ||
  a === "V0" ||
  (a === "VZ" && b === "VtopZ") ||
  (a === "VX" && b === "VtopX") ||
  (a === "VY" && b === "VtopY") ||
  (a === "VC" && (b === "VtopZ" || b === "VtopX" || b === "VtopY"))];

spectraQ = <|
  "V0"   -> {"*"},
  "VZ"   -> {"0z", "1z"}, "VX" -> {"0x", "1x"}, "VY" -> {"0y", "1y"},
  "VC"   -> {"0c", "1c"},
  "VtopZ"-> {"lz1", "lz2", "lz3"},
  "VtopX"-> {"mx1", "mx2", "mx3"},
  "VtopY"-> {"ny1", "ny2", "ny3"}
|>;

(* Restriction maps: each derived from character restriction.
   Restrictions are functions of spectrum points. *)
restrictQ = <|
  {"VZ", "V0"} -> Function[x, "*"],
  {"VX", "V0"} -> Function[x, "*"],
  {"VY", "V0"} -> Function[x, "*"],
  {"VC", "V0"} -> Function[x, "*"],
  {"VtopZ", "V0"} -> Function[x, "*"],
  {"VtopX", "V0"} -> Function[x, "*"],
  {"VtopY", "V0"} -> Function[x, "*"],
  (* V_top_Z atoms: a1=(I-P_Z, 0), a2=(P_Z, 0), a3=(0, 1).
     Character lz1: a1=1 -> evaluates (P_Z, 0) to 0, evaluates (0,1) to 0.
     Character lz2: a2=1 -> evaluates (P_Z, 0) to 1, evaluates (0,1) to 0.
     Character lz3: a3=1 -> evaluates (P_Z, 0) to 0, evaluates (0,1) to 1.
     V_Z characters: 0z sends (P_Z, 0) -> 0; 1z sends (P_Z, 0) -> 1.
     So lz1 -> 0z, lz2 -> 1z, lz3 -> 0z. *)
  {"VtopZ", "VZ"} -> Function[x, Switch[x, "lz1", "0z", "lz2", "1z", "lz3", "0z"]],
  (* V_C characters: 0c sends (0,1) -> 0, hence (I,0) -> 1; 1c sends (0,1) -> 1.
     lz1 -> 0c, lz2 -> 0c, lz3 -> 1c. *)
  {"VtopZ", "VC"} -> Function[x, Switch[x, "lz1", "0c", "lz2", "0c", "lz3", "1c"]],
  (* V_top_X atoms: a1=(I-P_X, 0), a2=(P_X, 0), a3=(0, 1). Similarly. *)
  {"VtopX", "VX"} -> Function[x, Switch[x, "mx1", "0x", "mx2", "1x", "mx3", "0x"]],
  {"VtopX", "VC"} -> Function[x, Switch[x, "mx1", "0c", "mx2", "0c", "mx3", "1c"]],
  {"VtopY", "VY"} -> Function[x, Switch[x, "ny1", "0y", "ny2", "1y", "ny3", "0y"]],
  {"VtopY", "VC"} -> Function[x, Switch[x, "ny1", "0c", "ny2", "0c", "ny3", "1c"]]
|>;

minimalQ = <|
  "VZ" -> {"VZ"}, "VX" -> {"VX"}, "VY" -> {"VY"}, "VC" -> {"VC"},
  "VtopZ" -> {"VZ", "VC"},
  "VtopX" -> {"VX", "VC"},
  "VtopY" -> {"VY", "VC"}
|>;

ccQ = <|
  "contexts" -> contextsQ, "trivial" -> "V0",
  "leq" -> leqQ, "spectra" -> spectraQ,
  "restrict" -> restrictQ, "minimal" -> minimalQ
|>;

(* Projection lists per context, as Q-elements.
   Used by daseinisation to find smallest dominator. *)
qProjV0 = {qZero, qOne};
qProjVZ = {qZero, qElem[Pz, 0], qElem[IdM - Pz, 1], qOne};
qProjVX = {qZero, qElem[Px, 0], qElem[IdM - Px, 1], qOne};
qProjVY = {qZero, qElem[Py, 0], qElem[IdM - Py, 1], qOne};
qProjVC = {qZero, qElem[ConstantArray[0, {2, 2}], 1],
           qElem[IdM, 0], qOne};
(* V_top_Z atoms: {a1, a2, a3} = {(I-P_Z, 0), (P_Z, 0), (0, 1)} *)
qAtomsVtopZ = {qElem[IdM - Pz, 0], qElem[Pz, 0],
               qElem[ConstantArray[0, {2, 2}], 1]};
qAtomsVtopX = {qElem[IdM - Px, 0], qElem[Px, 0],
               qElem[ConstantArray[0, {2, 2}], 1]};
qAtomsVtopY = {qElem[IdM - Py, 0], qElem[Py, 0],
               qElem[ConstantArray[0, {2, 2}], 1]};
(* Build projections of a 3-atom MASA as all 2^3=8 sums of subsets *)
sumAtoms[atoms_, subset_] := Module[{m, s},
  If[Length[subset] === 0, Return[qZero]];
  m = Total[Map[#[[1]] &, atoms[[subset]]]];
  s = Total[Map[#[[2]] &, atoms[[subset]]]];
  {m, s}
];
projectionsFromAtoms[atoms_] := Map[sumAtoms[atoms, #] &,
  Subsets[Range[Length[atoms]]]];
qProjVtopZ = projectionsFromAtoms[qAtomsVtopZ];
qProjVtopX = projectionsFromAtoms[qAtomsVtopX];
qProjVtopY = projectionsFromAtoms[qAtomsVtopY];

qProjections = <|
  "V0" -> qProjV0, "VZ" -> qProjVZ, "VX" -> qProjVX, "VY" -> qProjVY,
  "VC" -> qProjVC,
  "VtopZ" -> qProjVtopZ, "VtopX" -> qProjVtopX, "VtopY" -> qProjVtopY
|>;

(* Atoms (= minimal non-zero projections) per context, ordered to
   match the spectrum-character indexing. For a context with atoms
   (a1, a2, ..., ak), character i corresponds to "the character
   sending a_i to 1 and all other a_j to 0." *)
qAtoms = <|
  "V0" -> {qOne},
  "VZ" -> {qElem[IdM - Pz, 1], qElem[Pz, 0]},   (* 0z atom1=(I-P_Z,1), 1z atom2=(P_Z,0) *)
  "VX" -> {qElem[IdM - Px, 1], qElem[Px, 0]},
  "VY" -> {qElem[IdM - Py, 1], qElem[Py, 0]},
  "VC" -> {qElem[IdM, 0], qElem[ConstantArray[0, {2, 2}], 1]}, (* 0c atom=(I,0), 1c atom=(0,1) *)
  "VtopZ" -> qAtomsVtopZ,
  "VtopX" -> qAtomsVtopX,
  "VtopY" -> qAtomsVtopY
|>;


(* ---- Classical: cc_c for V_d(C^7), 8 contexts, poset-iso to ccQ ---- *)

contextsC = {"V0c", "VZc", "VXc", "VYc", "VCc",
             "VtopZc", "VtopXc", "VtopYc"};
leqC = Function[{a, b}, a === b ||
  a === "V0c" ||
  (a === "VZc" && b === "VtopZc") ||
  (a === "VXc" && b === "VtopXc") ||
  (a === "VYc" && b === "VtopYc") ||
  (a === "VCc" && (b === "VtopZc" || b === "VtopXc" || b === "VtopYc"))];

spectraC = <|
  "V0c"   -> {"*"},
  "VZc"   -> {"0zc", "1zc"}, "VXc" -> {"0xc", "1xc"}, "VYc" -> {"0yc", "1yc"},
  "VCc"   -> {"0cc", "1cc"},
  "VtopZc"-> {"lz1c", "lz2c", "lz3c"},
  "VtopXc"-> {"mx1c", "mx2c", "mx3c"},
  "VtopYc"-> {"ny1c", "ny2c", "ny3c"}
|>;
restrictC = <|
  {"VZc", "V0c"} -> Function[x, "*"],
  {"VXc", "V0c"} -> Function[x, "*"],
  {"VYc", "V0c"} -> Function[x, "*"],
  {"VCc", "V0c"} -> Function[x, "*"],
  {"VtopZc", "V0c"} -> Function[x, "*"],
  {"VtopXc", "V0c"} -> Function[x, "*"],
  {"VtopYc", "V0c"} -> Function[x, "*"],
  {"VtopZc", "VZc"} -> Function[x, Switch[x, "lz1c", "0zc", "lz2c", "1zc", "lz3c", "0zc"]],
  {"VtopZc", "VCc"} -> Function[x, Switch[x, "lz1c", "0cc", "lz2c", "0cc", "lz3c", "1cc"]],
  {"VtopXc", "VXc"} -> Function[x, Switch[x, "mx1c", "0xc", "mx2c", "1xc", "mx3c", "0xc"]],
  {"VtopXc", "VCc"} -> Function[x, Switch[x, "mx1c", "0cc", "mx2c", "0cc", "mx3c", "1cc"]],
  {"VtopYc", "VYc"} -> Function[x, Switch[x, "ny1c", "0yc", "ny2c", "1yc", "ny3c", "0yc"]],
  {"VtopYc", "VCc"} -> Function[x, Switch[x, "ny1c", "0cc", "ny2c", "0cc", "ny3c", "1cc"]]
|>;
minimalC = <|
  "VZc" -> {"VZc"}, "VXc" -> {"VXc"}, "VYc" -> {"VYc"}, "VCc" -> {"VCc"},
  "VtopZc" -> {"VZc", "VCc"},
  "VtopXc" -> {"VXc", "VCc"},
  "VtopYc" -> {"VYc", "VCc"}
|>;
ccC = <|
  "contexts" -> contextsC, "trivial" -> "V0c",
  "leq" -> leqC, "spectra" -> spectraC,
  "restrict" -> restrictC, "minimal" -> minimalC
|>;

(* C^7 representation: vectors of length 7.
   p_i = unit vector e_i.  qZc = p1+p2,  qXc = p3+p4,
   qYc = p5+p6,  qCc = p7. *)
cZero = ConstantArray[0, 7];
cOne  = ConstantArray[1, 7];
unitC[i_] := ReplacePart[cZero, i -> 1];
qZc = unitC[1] + unitC[2];
qXc = unitC[3] + unitC[4];
qYc = unitC[5] + unitC[6];
qCc = unitC[7];

(* Projections per context, as C-elements *)
cProjV0c = {cZero, cOne};
cProjVZc = {cZero, qZc, cOne - qZc, cOne};
cProjVXc = {cZero, qXc, cOne - qXc, cOne};
cProjVYc = {cZero, qYc, cOne - qYc, cOne};
cProjVCc = {cZero, qCc, cOne - qCc, cOne};
(* V_topZ_c atoms: a1 = 1 - qZc - qCc, a2 = qZc, a3 = qCc *)
cAtomsVtopZ = {cOne - qZc - qCc, qZc, qCc};
cAtomsVtopX = {cOne - qXc - qCc, qXc, qCc};
cAtomsVtopY = {cOne - qYc - qCc, qYc, qCc};
projectionsFromAtomsC[atoms_] := Map[
  If[# === {}, cZero, Total[atoms[[#]]]] &,
  Subsets[Range[Length[atoms]]]];
cProjVtopZc = projectionsFromAtomsC[cAtomsVtopZ];
cProjVtopXc = projectionsFromAtomsC[cAtomsVtopX];
cProjVtopYc = projectionsFromAtomsC[cAtomsVtopY];

cProjections = <|
  "V0c" -> cProjV0c, "VZc" -> cProjVZc, "VXc" -> cProjVXc,
  "VYc" -> cProjVYc, "VCc" -> cProjVCc,
  "VtopZc" -> cProjVtopZc, "VtopXc" -> cProjVtopXc,
  "VtopYc" -> cProjVtopYc
|>;

cAtoms = <|
  "V0c" -> {cOne},
  "VZc" -> {cOne - qZc, qZc}, "VXc" -> {cOne - qXc, qXc},
  "VYc" -> {cOne - qYc, qYc}, "VCc" -> {cOne - qCc, qCc},
  "VtopZc" -> cAtomsVtopZ,
  "VtopXc" -> cAtomsVtopX,
  "VtopYc" -> cAtomsVtopY
|>;


(* ============================================================
   PART D: DASEINISATION PRIMITIVE
   ------------------------------------------------------------
   Given a projection P in the ambient algebra and a context V,
   the outer daseinisation dasein_V^o(P) is the smallest projection
   in V dominating P.
   ============================================================ *)

(* For quantum *)
daseinOQ[v_, P_] := Module[{candidates, dominators, sizes},
  candidates = qProjections[v];
  dominators = Select[candidates, qDom[#, P] &];
  If[Length[dominators] === 0, Return[qOne]];
  sizes = Map[(Tr[Re[#[[1]]]] + Re[#[[2]]]) &, dominators];
  dominators[[Position[sizes, Min[sizes]][[1, 1]]]]
];

(* For classical *)
daseinOC[v_, P_] := Module[{candidates, dominators, sizes},
  candidates = cProjections[v];
  dominators = Select[candidates, cDom[#, P] &];
  If[Length[dominators] === 0, Return[cOne]];
  sizes = Map[Total, dominators];
  dominators[[Position[sizes, Min[sizes]][[1, 1]]]]
];

(* Convert a projection (Q or C) in context V into the subset
   of Sigma(V) that evaluates the projection to 1.
   Char at index i in atomList sends atom_i to 1, others to 0.
   For element X = sum_i c_i atom_i (with c_i in {0,1}), char_i(X) = c_i. *)
qElemEq[a_, b_] := Norm[N[a[[1]] - b[[1]]]] < psdTol && Abs[N[a[[2]] - b[[2]]]] < psdTol;
cElemEq[a_, b_] := Norm[N[a - b]] < psdTol;

charactersWithValueQ[v_, P_] := Module[{atoms, spec, present},
  atoms = qAtoms[v]; spec = spectraQ[v];
  present = Table[
    (* Does atom_i appear in P (with coefficient 1)? Check if
       atom_i 'fits inside' P, i.e., P - atom_i is PSD.
       This assumes P is a sum of distinct atoms. *)
    qDom[P, atoms[[i]]],
    {i, Length[atoms]}];
  Pick[spec, present]
];

charactersWithValueC[v_, P_] := Module[{atoms, spec, present},
  atoms = cAtoms[v]; spec = spectraC[v];
  present = Table[cDom[P, atoms[[i]]], {i, Length[atoms]}];
  Pick[spec, present]
];

(* Build daseinisation as clopen subobject *)
daseinSubobjQ[P_] := AssociationThread[
  contextsQ -> Map[charactersWithValueQ[#, daseinOQ[#, P]] &, contextsQ]];
daseinSubobjC[P_] := AssociationThread[
  contextsC -> Map[charactersWithValueC[#, daseinOC[#, P]] &, contextsC]];


(* ============================================================
   PART E: SUBOBJECT ENUMERATION
   ------------------------------------------------------------
   For both quantum and classical sides, build Sub_cl(Sigma) by
   direct construction. The 8-context category factors into three
   "triangles" (VZ+VC -> VtopZ, VX+VC -> VtopX, VY+VC -> VtopY)
   sharing VC and V0. We enumerate by choosing components in a
   topological order with compatibility constraints at each step.
   ============================================================ *)

buildSubobjects[cc_] := Module[{ctxs, sV0, sVZ, sVX, sVY, sVC,
    sVtopZ, sVtopX, sVtopY, vZ, vX, vY, vC, vTZ, vTX, vTY, v0,
    result, restrTZtoZ, restrTZtoC, restrTXtoX, restrTXtoC,
    restrTYtoY, restrTYtoC, specVtopZ, specVtopX, specVtopY,
    upperAny, validZ, validX, validY},
  ctxs = cc["contexts"];
  v0 = ctxs[[1]]; vZ = ctxs[[2]]; vX = ctxs[[3]]; vY = ctxs[[4]];
  vC = ctxs[[5]]; vTZ = ctxs[[6]]; vTX = ctxs[[7]]; vTY = ctxs[[8]];
  restrTZtoZ = cc["restrict"][{vTZ, vZ}];
  restrTZtoC = cc["restrict"][{vTZ, vC}];
  restrTXtoX = cc["restrict"][{vTX, vX}];
  restrTXtoC = cc["restrict"][{vTX, vC}];
  restrTYtoY = cc["restrict"][{vTY, vY}];
  restrTYtoC = cc["restrict"][{vTY, vC}];
  specVtopZ = cc["spectra"][vTZ];
  specVtopX = cc["spectra"][vTX];
  specVtopY = cc["spectra"][vTY];
  result = Reap[
    Do[Do[Do[Do[
      (* Constraint VtopZ -> VZ: restrict(S_{VtopZ}) subset S_{VZ}.
         Equivalently, S_{VtopZ} subset preimage(S_{VZ}). *)
      validZ = Select[specVtopZ,
        MemberQ[sVZ, restrTZtoZ[#]] && MemberQ[sVC, restrTZtoC[#]] &];
      validX = Select[specVtopX,
        MemberQ[sVX, restrTXtoX[#]] && MemberQ[sVC, restrTXtoC[#]] &];
      validY = Select[specVtopY,
        MemberQ[sVY, restrTYtoY[#]] && MemberQ[sVC, restrTYtoC[#]] &];
      Do[Do[Do[
        upperAny = sVZ =!= {} || sVX =!= {} || sVY =!= {} ||
                   sVC =!= {} || sVtopZ =!= {} || sVtopX =!= {} ||
                   sVtopY =!= {};
        If[!upperAny,
          (* V_0 can be empty (bottom) or full (ghost). *)
          Sow[<|v0 -> {}, vZ -> sVZ, vX -> sVX, vY -> sVY, vC -> sVC,
                vTZ -> sVtopZ, vTX -> sVtopX, vTY -> sVtopY|>];
          Sow[<|v0 -> cc["spectra"][v0], vZ -> sVZ, vX -> sVX,
                vY -> sVY, vC -> sVC, vTZ -> sVtopZ, vTX -> sVtopX,
                vTY -> sVtopY|>],
          Sow[<|v0 -> cc["spectra"][v0], vZ -> sVZ, vX -> sVX,
                vY -> sVY, vC -> sVC, vTZ -> sVtopZ, vTX -> sVtopX,
                vTY -> sVtopY|>]
        ],
        {sVtopY, Subsets[validY]}],
       {sVtopX, Subsets[validX]}],
      {sVtopZ, Subsets[validZ]}],
     {sVC, Subsets[cc["spectra"][vC]]}],
    {sVY, Subsets[cc["spectra"][vY]]}],
   {sVX, Subsets[cc["spectra"][vX]]}],
  {sVZ, Subsets[cc["spectra"][vZ]]}]
  ][[2, 1]];
  result
];


(* ============================================================
   PART F: FOUR-CELL PARTITION COMPUTATIONS
   ============================================================ *)

fourCells[cc_, allSub_, a_] := Module[{
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
  <|"i" -> Length[infra], "r" -> Length[ref],
    "e" -> Length[expl], "d" -> Length[dist],
    "all4" -> (Length[infra] > 0 && Length[ref] > 0 &&
               Length[expl] > 0 && Length[dist] > 0),
    "regular?" -> subEqQ[cc, a, notNotA]|>
];

(* Compact subobject printer *)
ppSub[cc_, s_] := Module[{parts},
  parts = Map[ToString[#] <> "=" <>
    If[Length[s[#]] === 0, "{}",
       If[Sort[s[#]] === Sort[cc["spectra"][#]], "FULL",
          ToString[s[#]]]] &, cc["contexts"]];
  StringJoin["<", StringRiffle[parts, "; "], ">"]
];


(* ============================================================
   PART G: HASSE-ISOMORPHISM CHECK
   ============================================================ *)

Print["============================================================"];
Print["PART 0: Hasse-isomorphism check (sanity check)"];
hasseQ = SortBy[Select[Tuples[{contextsQ, contextsQ}],
  leqQ[#[[1]], #[[2]]] &], ToString];
hasseC = SortBy[Select[Tuples[{contextsC, contextsC}],
  leqC[#[[1]], #[[2]]] &], ToString];
Print["  |leq_q| = ", Length[hasseQ], "; |leq_c| = ", Length[hasseC]];
Print["  Hasse cardinalities match: ", Length[hasseQ] === Length[hasseC]];
specSizesQ = Map[Length[spectraQ[#]] &, contextsQ];
specSizesC = Map[Length[spectraC[#]] &, contextsC];
Print["  Spectrum-size sequence (Q): ", specSizesQ];
Print["  Spectrum-size sequence (C): ", specSizesC];
Print["  Spectrum sizes match (poset-isomorphism): ",
  specSizesQ === specSizesC];
Print[];


(* ============================================================
   PART H: BUILD Sub_cl(Sigma) FOR BOTH SIDES
   ============================================================ *)

Print["============================================================"];
Print["PART 1: Build Sub_cl(Sigma) (both sides)"];
subsQ = buildSubobjects[ccQ];
subsC = buildSubobjects[ccC];
Print["  |Sub_cl(Sigma)| (quantum, M_2(C) (+) C):     ", Length[subsQ]];
Print["  |Sub_cl(Sigma)| (classical, C^7):            ", Length[subsC]];
Print["  Sizes match (as poset-iso requires):         ",
  Length[subsQ] === Length[subsC]];
Print[];


(* ============================================================
   PART I: DASEINISATIONS OF P AND -P
   ============================================================ *)

Print["============================================================"];
Print["PART 2: Daseinisations of P and -P"];
Print["  Quantum: P  = (P_Z, 0),  -P = (I - P_Z, 1)"];
Print["  Classical: P' = qZc = e1+e2,  -P' = e3+e4+e5+e6+e7"];

Pq = qElem[Pz, 0];
notPq = qElem[IdM - Pz, 1];
Pc = qZc;
notPc = cOne - qZc;

dPq = daseinSubobjQ[Pq];
dNotPq = daseinSubobjQ[notPq];
dPc = daseinSubobjC[Pc];
dNotPc = daseinSubobjC[notPc];

Print[];
Print["  dasein(P)  quantum:    ", ppSub[ccQ, dPq]];
Print["  dasein(P') classical:  ", ppSub[ccC, dPc]];
Print[];
Print["  dasein(-P)  quantum:   ", ppSub[ccQ, dNotPq]];
Print["  dasein(-P') classical: ", ppSub[ccC, dNotPc]];
Print[];


(* ============================================================
   PART J: KERNEL CANDIDATES
   ============================================================ *)

compareKernel[name_, kQ_, kC_] := Module[{cellsQ, cellsC, divergent},
  cellsQ = fourCells[ccQ, subsQ, kQ];
  cellsC = fourCells[ccC, subsC, kC];
  Print["----------------------------------------------"];
  Print["  KERNEL: ", name];
  Print["    kernel_q:    ", ppSub[ccQ, kQ]];
  Print["    kernel_c:    ", ppSub[ccC, kC]];
  Print["    Q: regular? ", cellsQ["regular?"],
    "   (i, r, e, d) = (", cellsQ["i"], ", ", cellsQ["r"],
    ", ", cellsQ["e"], ", ", cellsQ["d"], ")",
    If[cellsQ["all4"], "  ALL-4", ""]];
  Print["    C: regular? ", cellsC["regular?"],
    "   (i, r, e, d) = (", cellsC["i"], ", ", cellsC["r"],
    ", ", cellsC["e"], ", ", cellsC["d"], ")",
    If[cellsC["all4"], "  ALL-4", ""]];
  divergent = (cellsQ["all4"] =!= cellsC["all4"]) ||
    ({cellsQ["i"] > 0, cellsQ["r"] > 0, cellsQ["e"] > 0, cellsQ["d"] > 0} =!=
     {cellsC["i"] > 0, cellsC["r"] > 0, cellsC["e"] > 0, cellsC["d"] > 0});
  Print["    Cell-non-emptiness divergent? ", divergent];
  Print["    Cardinality divergent?        ",
    {cellsQ["i"], cellsQ["r"], cellsQ["e"], cellsQ["d"]} =!=
    {cellsC["i"], cellsC["r"], cellsC["e"], cellsC["d"]}];
  {name, cellsQ, cellsC, divergent}
];

Print["============================================================"];
Print["PART 3: Bohrification-native kernel candidates (sec. 4.1-4.6, 4.8)"];

(* 4.1: single daseinisation *)
res41 = compareKernel["4.1  dasein(P)", dPq, dPc];

(* 4.2: join *)
joinQ42 = joinSub[ccQ, dPq, dNotPq];
joinC42 = joinSub[ccC, dPc, dNotPc];
res42 = compareKernel["4.2  dasein(P) v dasein(-P)", joinQ42, joinC42];

(* 4.3: meet *)
meetQ43 = meetSub[ccQ, dPq, dNotPq];
meetC43 = meetSub[ccC, dPc, dNotPc];
res43 = compareKernel["4.3  dasein(P) ^ dasein(-P)", meetQ43, meetC43];

(* 4.4: anti-daseinisation via inner daseinisation = 1 - dasein(1 - P).
   For a single projection P, anti-dasein(P) = 1 - dasein(1 - P)
   evaluated stagewise. Implement as the complement-subobject built
   from the inner daseinisation. *)
daseinIQ[v_, P_] := Module[{candidates, dominated, sizes},
  candidates = qProjections[v];
  dominated = Select[candidates, qDom[P, #] &];
  If[Length[dominated] === 0, Return[qZero]];
  sizes = Map[-(Tr[Re[#[[1]]]] + Re[#[[2]]]) &, dominated];
  dominated[[Position[sizes, Min[sizes]][[1, 1]]]]
];
daseinIC[v_, P_] := Module[{candidates, dominated, sizes},
  candidates = cProjections[v];
  dominated = Select[candidates, cDom[P, #] &];
  If[Length[dominated] === 0, Return[cZero]];
  sizes = Map[-Total[#] &, dominated];
  dominated[[Position[sizes, Min[sizes]][[1, 1]]]]
];
antiDaseinQ[P_] := AssociationThread[
  contextsQ -> Map[charactersWithValueQ[#, daseinIQ[#, P]] &, contextsQ]];
antiDaseinC[P_] := AssociationThread[
  contextsC -> Map[charactersWithValueC[#, daseinIC[#, P]] &, contextsC]];

antiQ44 = antiDaseinQ[Pq];
antiC44 = antiDaseinC[Pc];
res44 = compareKernel["4.4  anti-dasein(P)", antiQ44, antiC44];

(* 4.5: dasein(P) ^ -dasein(-P) *)
notDNotPq = heytingNot[ccQ, dNotPq];
notDNotPc = heytingNot[ccC, dNotPc];
fiveQ = meetSub[ccQ, dPq, notDNotPq];
fiveC = meetSub[ccC, dPc, notDNotPc];
res45 = compareKernel["4.5  dasein(P) ^ NOT dasein(-P)", fiveQ, fiveC];

(* 4.6: -(dasein(P) v dasein(-P)) *)
ksQ = heytingNot[ccQ, joinQ42];
ksC = heytingNot[ccC, joinC42];
Print[""];
Print["  Note 4.6: KS-gap kernel; if join = top then this is bottom."];
Print["    KS_q is bottom: ", subEqQ[ccQ, ksQ, bottomSub[ccQ]]];
Print["    KS_c is bottom: ", subEqQ[ccC, ksC, bottomSub[ccC]]];
If[!subEqQ[ccQ, ksQ, bottomSub[ccQ]] || !subEqQ[ccC, ksC, bottomSub[ccC]],
  res46 = compareKernel["4.6  -(dasein(P) v dasein(-P))", ksQ, ksC],
  res46 = {"4.6", <|"i"->0,"r"->0,"e"->0,"d"->0,"all4"->False|>,
                  <|"i"->0,"r"->0,"e"->0,"d"->0,"all4"->False|>, False};
  Print["  Both KS-gap kernels are bottom; kernel is trivial; skipped."]
];

(* 4.8: Heyting implication dasein(P) -> dasein(-P) *)
Print[""];
Print["  Note 4.8: Heyting implication; this is the most expensive"];
Print["    operation in the script (O(|Sub|) per implication evaluated"];
Print["    via the largest-witness method); may take a moment."];
implQ48 = heytingImpl[ccQ, subsQ, dPq, dNotPq];
implC48 = heytingImpl[ccC, subsC, dPc, dNotPc];
res48 = compareKernel["4.8  dasein(P) -> dasein(-P)", implQ48, implC48];


(* ============================================================
   PART K: EXHAUSTIVE NON-REGULAR SWEEP (sec. 4.7)
   ============================================================ *)

Print[""];
Print["============================================================"];
Print["PART 4: Exhaustive sweep over non-regular subobjects (sec. 4.7)"];

nonRegQ = Select[subsQ, !regularQ[ccQ, #] &];
nonRegC = Select[subsC, !regularQ[ccC, #] &];
Print["  Non-regular subobjects (Q): ", Length[nonRegQ], " of ", Length[subsQ]];
Print["  Non-regular subobjects (C): ", Length[nonRegC], " of ", Length[subsC]];
Print["  Non-regular count match:    ", Length[nonRegQ] === Length[nonRegC]];

(* For exhaustive sweep, we look for any non-regular kernel a in Q
   that admits ALL FOUR cells. If found, identify if the
   shape-isomorphic counterpart in C also admits all four. The
   exhaustive sweep is the v2-style search: it tells us shape-driven
   non-vacuity counts on both sides and whether the patterns differ. *)

(* All-4 kernel counts: only non-regular kernels can have all 4
   cells (regular kernels have Exploitation = empty structurally). *)
botQ = bottomSub[ccQ]; botC = bottomSub[ccC];
candQ = Select[nonRegQ, !subEqQ[ccQ, #, botQ] &];
candC = Select[nonRegC, !subEqQ[ccC, #, botC] &];
Print[""];
Print["  Candidate kernels (non-regular, non-bottom):"];
Print["    Q: ", Length[candQ]];
Print["    C: ", Length[candC]];

Print["  Counting all-4-cell kernels (this is the slow step)..."];
all4Q = Length[Select[candQ, fourCells[ccQ, subsQ, #]["all4"] &]];
Print["    Q done: ", all4Q, " all-4 kernels"];
all4C = Length[Select[candC, fourCells[ccC, subsC, #]["all4"] &]];
Print["    C done: ", all4C, " all-4 kernels"];
Print[""];
Print["  Kernels admitting ALL FOUR cells:"];
Print["    Q (quantum):    ", all4Q, " of ", Length[candQ], " non-regular, non-bottom"];
Print["    C (classical):  ", all4C, " of ", Length[candC], " non-regular, non-bottom"];
Print["    Counts match?   ", all4Q === all4C];


(* ============================================================
   PART L: SUMMARY
   ============================================================ *)

Print[""];
Print["============================================================"];
Print["FINAL SUMMARY"];
Print["============================================================"];

resultsTable = {res41, res42, res43, res44, res45, res46, res48};
Print[StringPadRight["candidate", 38],
  StringPadRight["Q (i,r,e,d)", 18],
  StringPadRight["C (i,r,e,d)", 18],
  "non-empty divergent?"];
Print[StringPadRight["----------", 38],
  StringPadRight["-----------", 18],
  StringPadRight["-----------", 18],
  "-----"];
Do[
  Print[StringPadRight[r[[1]], 38],
    StringPadRight[ToString[{r[[2]]["i"], r[[2]]["r"], r[[2]]["e"], r[[2]]["d"]}], 18],
    StringPadRight[ToString[{r[[3]]["i"], r[[3]]["r"], r[[3]]["e"], r[[3]]["d"]}], 18],
    r[[4]]],
  {r, resultsTable}
];

Print[""];
Print["Exhaustive sweep (sec. 4.7):"];
Print["  Q all-4 kernel count: ", all4Q];
Print["  C all-4 kernel count: ", all4C];
Print["  Match?                ", all4Q === all4C];

Print[""];
Print["Verdict guide:"];
Print["  - Any 'non-empty divergent? True' row above is a positive"];
Print["    cell-non-emptiness signal for that kernel candidate."];
Print["  - All 'False' + Q all-4 count =/= C all-4 count means"];
Print["    cell-cardinality divergence (mixed result)."];
Print["  - All 'False' + counts match: negative v3 result for this"];
Print["    discretisation. v4 on M_3(C) is the structural next step."];
Print[""];
Print["[End of physics-anchor v3 run]"];
