(* ::Package:: *)

(* ============================================================
   Route A v4: Bohrification on M_3(C), structural-break detection
   ------------------------------------------------------------
   Companion to:
     preprints/four-position-partition/physics-anchor/v4-scope.md
     preprints/four-position-partition/physics-anchor/v3-scope.md
     preprints/four-position-partition/physics-anchor/feasibility.md
     wolfram/cores/heunen-landsman-spitters-2009.wl
     wolfram/physics-anchor/four-position-physics-v3.wl

   QUESTION (v4-scope.md sec. 1):
     At the Kochen-Specker threshold (dim >= 3), does the FalseWork
     framework's machinery -- operating on Sub_cl(Sigma) -- detect a
     structural feature of M_3(C) that no commutative algebra can
     replicate? Specifically: does the count of atomic-everywhere
     clopen subobjects (equivalently, |GlobalSections(Sigma)|)
     differ between the quantum side and any commutative side?

   FRAMING (v4-scope.md sec. 1):
     The poset-iso commutative-control construction either succeeds
     (giving lattice-iso, matching |GlobalSections|) or fails (when
     the M_3(C) configuration is KS-blocking). The break IS the
     signal: KS forces |GlobalSections(Sigma_Q)| < |GlobalSections
     (Sigma_C)| for any minimal commutative C^m, with strict
     inequality at sufficiently rich discretisations.

   CONFIGURATION (v4-scope.md sec. 3):
     M_3(C) with 4 MASAs sharing atoms:
       T1 = <|0><0|, |1><1|, |2><2|>           (cardinal)
       T2 = <|+_01><+_01|, |-_01><-_01|, |2><2|>  (shares |2><2|)
       T3 = <|+_02><+_02|, |-_02><-_02|, |1><1|>  (shares |1><1|)
       T4 = <|+_12><+_12|, |-_12><-_12|, |0><0|>  (shares |0><0|)
     Sub-MASAs at shared atoms: V_{12} = <|2><2|, I-|2><2|>, etc.
     Total: 1 (trivial) + 3 (1-dim sub-MASAs) + 4 (MASAs) = 8 contexts.

   NOTE ON KS-BLOCKING:
     This 4-MASA configuration is not full KS-blocking; that requires
     ~10-16 MASAs (Penrose dodecahedron, Peres-33). v4 here is the
     instrumentation + first-dim-3 run with the architecture that
     a v5-full-KS-blocking script will inherit. The current config
     tests whether the lattice-iso construction holds at dim 3 with
     shared atoms, and provides a cardinality-baseline for v5.

   KERNEL CANDIDATES (v4-scope.md sec. 4):
     Primary: a* = join of atomic-everywhere clopen subobjects
              (the "global-section subobject")
     Secondary: 4.1' dasein(P), 4.5' dasein(P) ^ -dasein(-P)
                (v3-style trend data at dim 3)

   Execution: paste into Wolfram Cloud cell. No external deps.
   ============================================================ *)

ClearAll["Global`*"];


(* ============================================================
   PART A: GENERIC MACHINERY
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

(* validate a candidate subobject (assoc context -> subset of spectrum)
   for restriction compatibility: restrict(s_VBig) subset of s_VSub
   for all VSub <= VBig. *)
validSubQ[cc_, s_] := Module[{contexts, ok = True},
  contexts = cc["contexts"];
  Do[
    Do[
      If[v1 =!= v2 && cc["leq"][v2, v1] && v2 =!= v1,
        If[!SubsetQ[s[v2], Map[cc["restrict"][{v1, v2}], s[v1]]],
          ok = False; Break[]]
      ],
      {v2, contexts}
    ];
    If[!ok, Break[]],
    {v1, contexts}
  ];
  ok
];


(* ============================================================
   PART B: M_3(C) LINEAR-ALGEBRAIC PROJECTION ARITHMETIC
   ------------------------------------------------------------
   Elements of M_3(C) are 3x3 complex matrices. PSD via eigenvalues.
   ============================================================ *)

Id3 = IdentityMatrix[3];
M3zero = ConstantArray[0, {3, 3}];

psdTol = 10^-8;
psdM3[M_] := AllTrue[Eigenvalues[N[(M + ConjugateTranspose[M])/2]],
  Re[#] >= -psdTol &];

(* domination: P dominates Q iff P - Q is PSD *)
qDomM3[P_, Q_] := psdM3[P - Q];

(* rank-1 projection from a column vector v (will be normalized) *)
rank1Proj[v_] := Module[{vn},
  vn = v / Sqrt[v . Conjugate[v]];
  Outer[Times, vn, Conjugate[vn]]
];

(* Standard basis vectors of C^3 *)
e[1] = {1, 0, 0}; e[2] = {0, 1, 0}; e[3] = {0, 0, 1};

(* Cardinal-basis projections (atoms of T1) *)
P0 = rank1Proj[e[1]];  (* |0><0| *)
P1 = rank1Proj[e[2]];  (* |1><1| *)
P2 = rank1Proj[e[3]];  (* |2><2| *)

(* Hadamard-pair projections.  Convention:
   |+_{ij}> = (|i> + |j>)/sqrt(2),  |-_{ij}> = (|i> - |j>)/sqrt(2). *)
Pp01 = rank1Proj[(e[1] + e[2])/Sqrt[2]];
Pm01 = rank1Proj[(e[1] - e[2])/Sqrt[2]];
Pp02 = rank1Proj[(e[1] + e[3])/Sqrt[2]];
Pm02 = rank1Proj[(e[1] - e[3])/Sqrt[2]];
Pp12 = rank1Proj[(e[2] + e[3])/Sqrt[2]];
Pm12 = rank1Proj[(e[2] - e[3])/Sqrt[2]];

(* The four MASAs.  Each MASA is its set of 3 atoms.
   Shared atoms identified by reference equality below. *)
T1atoms = {P0, P1, P2};                (* cardinal *)
T2atoms = {Pp01, Pm01, P2};            (* shares P2 with T1 *)
T3atoms = {Pp02, Pm02, P1};            (* shares P1 with T1 *)
T4atoms = {Pp12, Pm12, P0};            (* shares P0 with T1 *)


(* ============================================================
   PART C: QUANTUM CONTEXT CATEGORY V_d(M_3(C))
   ------------------------------------------------------------
   Contexts:
     V0       = C.I                              (1 character)
     V12      = <P2, I-P2>                       (2 characters)
     V13      = <P1, I-P1>                       (2 characters)
     V14      = <P0, I-P0>                       (2 characters)
     T1, T2, T3, T4                              (3 characters each)
   Hasse covers:
     V0 < V12, V13, V14
     V12 < T1, T2
     V13 < T1, T3
     V14 < T1, T4
   ============================================================ *)

contextsQ = {"V0", "V12", "V13", "V14", "T1", "T2", "T3", "T4"};

leqQ = Function[{a, b}, Or[
  a === b,
  a === "V0",
  (a === "V12" && (b === "T1" || b === "T2")),
  (a === "V13" && (b === "T1" || b === "T3")),
  (a === "V14" && (b === "T1" || b === "T4"))
]];

(* Spectrum labels.  T1 has 3 atoms (P0, P1, P2) -> 3 characters
   c11, c12, c13 sending P0, P1, P2 (resp.) to 1.
   T2 atoms (Pp01, Pm01, P2) -> c21, c22, c23.
   V12 atoms (P2, I-P2) -> v12_in, v12_out (= P2->1, P2->0).
   Etc. *)
spectraQ = <|
  "V0"  -> {"*"},
  "V12" -> {"v12in", "v12out"},  (* in = "the P2 character" *)
  "V13" -> {"v13in", "v13out"},
  "V14" -> {"v14in", "v14out"},
  "T1"  -> {"c11", "c12", "c13"},  (* c11=P0->1, c12=P1->1, c13=P2->1 *)
  "T2"  -> {"c21", "c22", "c23"},  (* c21=Pp01->1, c22=Pm01->1, c23=P2->1 *)
  "T3"  -> {"c31", "c32", "c33"},  (* c31=Pp02->1, c32=Pm02->1, c33=P1->1 *)
  "T4"  -> {"c41", "c42", "c43"}   (* c41=Pp12->1, c42=Pm12->1, c43=P0->1 *)
|>;

(* Restriction maps. Derived from the convention "atom of V_big
   restricts to: 1 on shared sub-MASA atom if and only if the V_big
   atom IS that shared atom; 0 (= complement-atom) otherwise."
   
   V12 = <P2, I-P2>.  spectrum: v12in (P2->1), v12out (P2->0 i.e. I-P2->1).
   T1 -> V12: c11 (P0->1, others 0) -> P2 = 0 -> v12out.
                c12 (P1->1) -> P2 = 0 -> v12out.
                c13 (P2->1) -> P2 = 1 -> v12in.
   T2 -> V12: c21 (Pp01->1) -> P2 = <Pp01|P2|Pp01> = 0 -> v12out.
                c22 (Pm01->1) -> P2 = 0 -> v12out.
                c23 (P2->1) -> P2 = 1 -> v12in.
   etc. *)
restrictQ = <|
  {"V12", "V0"} -> Function[x, "*"],
  {"V13", "V0"} -> Function[x, "*"],
  {"V14", "V0"} -> Function[x, "*"],
  {"T1", "V0"}  -> Function[x, "*"],
  {"T2", "V0"}  -> Function[x, "*"],
  {"T3", "V0"}  -> Function[x, "*"],
  {"T4", "V0"}  -> Function[x, "*"],
  {"T1", "V12"} -> Function[x, Switch[x, "c11", "v12out", "c12", "v12out", "c13", "v12in"]],
  {"T1", "V13"} -> Function[x, Switch[x, "c11", "v13out", "c12", "v13in", "c13", "v13out"]],
  {"T1", "V14"} -> Function[x, Switch[x, "c11", "v14in", "c12", "v14out", "c13", "v14out"]],
  {"T2", "V12"} -> Function[x, Switch[x, "c21", "v12out", "c22", "v12out", "c23", "v12in"]],
  {"T3", "V13"} -> Function[x, Switch[x, "c31", "v13out", "c32", "v13out", "c33", "v13in"]],
  {"T4", "V14"} -> Function[x, Switch[x, "c41", "v14out", "c42", "v14out", "c43", "v14in"]]
|>;

minimalQ = <|
  "V12" -> {"V12"}, "V13" -> {"V13"}, "V14" -> {"V14"},
  "T1"  -> {"V12", "V13", "V14"},
  "T2"  -> {"V12"},
  "T3"  -> {"V13"},
  "T4"  -> {"V14"}
|>;

ccQ = <|
  "contexts" -> contextsQ, "trivial" -> "V0",
  "leq" -> leqQ, "spectra" -> spectraQ,
  "restrict" -> restrictQ, "minimal" -> minimalQ
|>;

(* Explicit projection sets per Q-context, for daseinisation.
   Each MASA has 8 projections (2^3 subset sums of atoms).
   Each 2-dim sub-MASA has 4 projections (2^2 subset sums of {P, I-P}). *)
allProjFromAtoms[atoms_] := Module[{n, subs},
  n = Length[atoms];
  subs = Subsets[Range[n]];
  Map[If[Length[#] === 0, M3zero, Total[atoms[[#]]]] &, subs]
];
qProjV0  = {M3zero, Id3};
qProjV12 = {M3zero, P2, Id3 - P2, Id3};
qProjV13 = {M3zero, P1, Id3 - P1, Id3};
qProjV14 = {M3zero, P0, Id3 - P0, Id3};
qProjT1  = allProjFromAtoms[T1atoms];
qProjT2  = allProjFromAtoms[T2atoms];
qProjT3  = allProjFromAtoms[T3atoms];
qProjT4  = allProjFromAtoms[T4atoms];
qProjections = <|
  "V0"  -> qProjV0, "V12" -> qProjV12, "V13" -> qProjV13, "V14" -> qProjV14,
  "T1"  -> qProjT1, "T2" -> qProjT2, "T3" -> qProjT3, "T4" -> qProjT4
|>;

(* Atoms (for daseinisation -> spectrum lookup).
   For context V with atoms (a1,...,ak), character i sends a_i to 1
   and all other a_j to 0. *)
qAtoms = <|
  "V0"  -> {Id3},
  "V12" -> {P2, Id3 - P2},      (* v12in = atom P2, v12out = atom I-P2 *)
  "V13" -> {P1, Id3 - P1},
  "V14" -> {P0, Id3 - P0},
  "T1"  -> {P0, P1, P2},          (* c11=P0->1, c12=P1->1, c13=P2->1 *)
  "T2"  -> {Pp01, Pm01, P2},
  "T3"  -> {Pp02, Pm02, P1},
  "T4"  -> {Pp12, Pm12, P0}
|>;


(* ============================================================
   PART D: CLASSICAL COMPARATORS
   ------------------------------------------------------------
   Two comparators:
     C^3 (minimal, 2 contexts): the "cleanest contrast" baseline.
     C^9 (best-effort Hasse-match, 8 contexts): the v3-discipline
          replication that demonstrates lattice-iso WORKS here
          (this 4-MASA config is not KS-blocking).
   ============================================================ *)

(* ---- Minimal comparator: C^3 ---- *)
contextsCmin = {"V0min", "Tmin"};
leqCmin = Function[{a, b}, a === b || a === "V0min"];
spectraCmin = <|
  "V0min" -> {"*"},
  "Tmin"  -> {"e1", "e2", "e3"}
|>;
restrictCmin = <|
  {"Tmin", "V0min"} -> Function[x, "*"]
|>;
minimalCmin = <|"Tmin" -> {"Tmin"}|>;
ccCmin = <|
  "contexts" -> contextsCmin, "trivial" -> "V0min",
  "leq" -> leqCmin, "spectra" -> spectraCmin,
  "restrict" -> restrictCmin, "minimal" -> minimalCmin
|>;

(* ---- Best-effort same-Hasse comparator: C^9 with sub-poset
        designed to match contextsQ Hasse + spectrum sizes. ---- *)
contextsC = {"V0c", "V12c", "V13c", "V14c", "T1c", "T2c", "T3c", "T4c"};
leqC = Function[{a, b}, Or[
  a === b,
  a === "V0c",
  (a === "V12c" && (b === "T1c" || b === "T2c")),
  (a === "V13c" && (b === "T1c" || b === "T3c")),
  (a === "V14c" && (b === "T1c" || b === "T4c"))
]];
spectraC = <|
  "V0c"  -> {"*"},
  "V12c" -> {"v12cin", "v12cout"},
  "V13c" -> {"v13cin", "v13cout"},
  "V14c" -> {"v14cin", "v14cout"},
  "T1c"  -> {"d11", "d12", "d13"},
  "T2c"  -> {"d21", "d22", "d23"},
  "T3c"  -> {"d31", "d32", "d33"},
  "T4c"  -> {"d41", "d42", "d43"}
|>;
restrictC = <|
  {"V12c", "V0c"} -> Function[x, "*"],
  {"V13c", "V0c"} -> Function[x, "*"],
  {"V14c", "V0c"} -> Function[x, "*"],
  {"T1c", "V0c"}  -> Function[x, "*"],
  {"T2c", "V0c"}  -> Function[x, "*"],
  {"T3c", "V0c"}  -> Function[x, "*"],
  {"T4c", "V0c"}  -> Function[x, "*"],
  {"T1c", "V12c"} -> Function[x, Switch[x, "d11", "v12cout", "d12", "v12cout", "d13", "v12cin"]],
  {"T1c", "V13c"} -> Function[x, Switch[x, "d11", "v13cout", "d12", "v13cin",  "d13", "v13cout"]],
  {"T1c", "V14c"} -> Function[x, Switch[x, "d11", "v14cin",  "d12", "v14cout", "d13", "v14cout"]],
  {"T2c", "V12c"} -> Function[x, Switch[x, "d21", "v12cout", "d22", "v12cout", "d23", "v12cin"]],
  {"T3c", "V13c"} -> Function[x, Switch[x, "d31", "v13cout", "d32", "v13cout", "d33", "v13cin"]],
  {"T4c", "V14c"} -> Function[x, Switch[x, "d41", "v14cout", "d42", "v14cout", "d43", "v14cin"]]
|>;
minimalC = <|
  "V12c" -> {"V12c"}, "V13c" -> {"V13c"}, "V14c" -> {"V14c"},
  "T1c"  -> {"V12c", "V13c", "V14c"},
  "T2c"  -> {"V12c"},
  "T3c"  -> {"V13c"},
  "T4c"  -> {"V14c"}
|>;
ccC = <|
  "contexts" -> contextsC, "trivial" -> "V0c",
  "leq" -> leqC, "spectra" -> spectraC,
  "restrict" -> restrictC, "minimal" -> minimalC
|>;

(* C^9 representation (for classical daseinisation analogues).
   T1c atoms (3-block partition of {1..9}):
     qT1a = unit{1,2,3} (analogue of P0)
     qT1b = unit{4,5,6} (analogue of P1)
     qT1c = unit{7,8,9} (analogue of P2)
   Each Tnc shares ONE atom with T1c (the analogue of the shared
   quantum atom), and has 2 other atoms partitioning the complement.

   T2c shares qT1c (analogue of |2><2|).  Other 2 atoms partition
   complement = unit{1..6}.  Pick qT2a = unit{1,4}, qT2b = unit{2,3,5,6}.

   T3c shares qT1b (analogue of |1><1|).  Other 2 atoms partition
   complement = unit{1,2,3,7,8,9}.  Pick qT3a = unit{1,7},
   qT3b = unit{2,3,8,9}.

   T4c shares qT1a (analogue of |0><0|).  Other 2 atoms partition
   complement = unit{4,5,6,7,8,9}.  Pick qT4a = unit{4,7},
   qT4b = unit{5,6,8,9}. *)
unitC9[i_] := ReplacePart[ConstantArray[0, 9], i -> 1];
qT1a = Total[Map[unitC9, {1, 2, 3}]];
qT1b = Total[Map[unitC9, {4, 5, 6}]];
qT1c = Total[Map[unitC9, {7, 8, 9}]];
qT2a = Total[Map[unitC9, {1, 4}]];
qT2b = Total[Map[unitC9, {2, 3, 5, 6}]];
qT3a = Total[Map[unitC9, {1, 7}]];
qT3b = Total[Map[unitC9, {2, 3, 8, 9}]];
qT4a = Total[Map[unitC9, {4, 7}]];
qT4b = Total[Map[unitC9, {5, 6, 8, 9}]];

cZeroV = ConstantArray[0, 9];
cOneV  = ConstantArray[1, 9];

cProjV0c  = {cZeroV, cOneV};
cProjV12c = {cZeroV, qT1c, cOneV - qT1c, cOneV};
cProjV13c = {cZeroV, qT1b, cOneV - qT1b, cOneV};
cProjV14c = {cZeroV, qT1a, cOneV - qT1a, cOneV};
cProjT1c  = allProjFromAtoms[{qT1a, qT1b, qT1c}];
cProjT2c  = allProjFromAtoms[{qT2a, qT2b, qT1c}];
cProjT3c  = allProjFromAtoms[{qT3a, qT3b, qT1b}];
cProjT4c  = allProjFromAtoms[{qT4a, qT4b, qT1a}];
cProjections = <|
  "V0c"  -> cProjV0c, "V12c" -> cProjV12c, "V13c" -> cProjV13c, "V14c" -> cProjV14c,
  "T1c"  -> cProjT1c, "T2c"  -> cProjT2c, "T3c"  -> cProjT3c, "T4c"  -> cProjT4c
|>;
cAtoms = <|
  "V0c"  -> {cOneV},
  "V12c" -> {qT1c, cOneV - qT1c},
  "V13c" -> {qT1b, cOneV - qT1b},
  "V14c" -> {qT1a, cOneV - qT1a},
  "T1c"  -> {qT1a, qT1b, qT1c},
  "T2c"  -> {qT2a, qT2b, qT1c},
  "T3c"  -> {qT3a, qT3b, qT1b},
  "T4c"  -> {qT4a, qT4b, qT1a}
|>;
(* Classical componentwise PSD = componentwise non-negativity *)
psdC9[v_] := AllTrue[v, # >= -psdTol &];
cDomC9[P_, Q_] := psdC9[P - Q];


(* ============================================================
   PART E: DASEINISATION PRIMITIVES
   ============================================================ *)

(* Outer daseinisation: smallest projection in V that dominates P.
   For M_3(C): use trace as size proxy. *)
daseinOQ[v_, P_] := Module[{candidates},
  candidates = Select[qProjections[v], qDomM3[#, P] &];
  If[candidates === {}, Id3,
    candidates[[Ordering[Map[Tr[#] &, candidates], 1][[1]]]]
  ]
];
daseinOC[v_, P_] := Module[{candidates},
  candidates = Select[cProjections[v], cDomC9[#, P] &];
  If[candidates === {}, cOneV,
    candidates[[Ordering[Map[Total[#] &, candidates], 1][[1]]]]
  ]
];

(* Characters of V at which the daseinisation projection d evaluates to 1.
   For atom-list (a1,...,ak), character i is "atom a_i -> 1, others -> 0".
   The character evaluates the larger projection d to 1 iff a_i lies
   in the range of d, equivalently d.a_i = a_i.
   Implementation note: map atom-by-atom to a per-atom test value, then
   find positions of "True"; this avoids Position iterating into the
   tensor structure of the atom matrices. *)
charactersWithValueQ[v_, d_] := Module[{atoms, spec, hits},
  atoms = qAtoms[v];
  spec = spectraQ[v];
  hits = Map[Function[a, Norm[d . a - a] < 10^-7], atoms];
  spec[[Flatten[Position[hits, True]]]]
];
charactersWithValueC[v_, d_] := Module[{atoms, spec, hits},
  atoms = cAtoms[v];
  spec = spectraC[v];
  hits = Map[Function[a,
    AllTrue[Range[Length[a]],
      (a[[#]] === 0) || (d[[#]] >= 1 - psdTol) &]], atoms];
  spec[[Flatten[Position[hits, True]]]]
];

(* Daseinisation as a clopen subobject of Sigma *)
daseinSubobjQ[P_] := AssociationThread[
  contextsQ -> Map[charactersWithValueQ[#, daseinOQ[#, P]] &, contextsQ]];
daseinSubobjC[P_] := AssociationThread[
  contextsC -> Map[charactersWithValueC[#, daseinOC[#, P]] &, contextsC]];


(* ============================================================
   PART F: SUBOBJECT ENUMERATION (DIRECT)
   ------------------------------------------------------------
   Build Sub_cl(Sigma) by direct construction: enumerate by component
   patterns at each context, filter by restriction compatibility.
   For 8-context, ~10^6-10^7 candidates -> filter to ~10^4 valid.
   Use top-down construction to minimize candidate count.
   ============================================================ *)

(* Top contexts: those with no strict super-context. *)
topContextsOf[cc_] := Select[cc["contexts"], 
  Function[c, Not[AnyTrue[cc["contexts"],
    cc["leq"][c, #] && # =!= c &]]]];

(* Generic builder: pick component subsets at top contexts, propagate
   constraints to mid contexts via restriction maps, validate. *)
buildSubobjects[cc_] := Module[{
  topCtx, midCtx, v0, candTop, validS, ghost
},
  v0 = cc["trivial"];
  topCtx = topContextsOf[cc];
  midCtx = Select[cc["contexts"], 
    # =!= v0 && !MemberQ[topCtx, #] &];

  candTop = Tuples[Map[Subsets[cc["spectra"][#]] &, topCtx]];

  validS = Reap[
    Do[
      Module[{topAssoc, midAssoc, sub, anyNonempty},
        topAssoc = AssociationThread[topCtx -> tup];
        midAssoc = Association[];
        Do[
          Module[{covered, restrictions},
            covered = Select[topCtx, cc["leq"][m, #] &];
            If[Length[covered] === 0,
              midAssoc[m] = cc["spectra"][m],
              restrictions = Map[
                Union[Map[cc["restrict"][{#, m}], topAssoc[#]]] &,
                covered];
              midAssoc[m] = Intersection @@ restrictions
            ]
          ],
          {m, midCtx}
        ];
        anyNonempty = AnyTrue[topCtx, topAssoc[#] =!= {} &] ||
                      AnyTrue[midCtx, midAssoc[#] =!= {} &];
        sub = Association[v0 -> If[anyNonempty, cc["spectra"][v0], {}]];
        Do[sub[m] = midAssoc[m], {m, midCtx}];
        Do[sub[c] = topAssoc[c], {c, topCtx}];
        If[validSubQ[cc, sub], Sow[sub]]
      ],
      {tup, candTop}
    ]
  ][[2]];
  validS = If[Length[validS] > 0, validS[[1]], {}];

  (* Ghost subobject: V0 = {*}, all others empty.  Add if missing. *)
  ghost = Association[v0 -> cc["spectra"][v0]];
  Do[ghost[c] = {}, {c, Join[midCtx, topCtx]}];
  If[!AnyTrue[validS, # === ghost &], AppendTo[validS, ghost]];
  validS
];

allSubQ = buildSubobjects[ccQ];
allSubC = buildSubobjects[ccC];
allSubCmin = buildSubobjects[ccCmin];


(* ============================================================
   PART G: GLOBAL SECTION COUNTS
   ------------------------------------------------------------
   |GlobalSections(Sigma)| = number of clopen subobjects S with
   |S_V| = 1 at EVERY context V.  This is the primary v4 signal.
   ============================================================ *)

atomicEverywhereQ[cc_, s_] := AllTrue[cc["contexts"], Length[s[#]] === 1 &];

globalSectionsQ = Select[allSubQ, atomicEverywhereQ[ccQ, #] &];
globalSectionsC = Select[allSubC, atomicEverywhereQ[ccC, #] &];
globalSectionsCmin = Select[allSubCmin, atomicEverywhereQ[ccCmin, #] &];


(* ============================================================
   PART H: KERNEL a* (JOIN OF ATOMIC-EVERYWHERE SUBOBJECTS)
   ------------------------------------------------------------
   The "global-section subobject": smallest clopen subobject
   containing every atomic-everywhere subobject.
   ============================================================ *)

joinAll[cc_, subList_] := Module[{base},
  If[subList === {}, bottomSub[cc],
    base = First[subList];
    Fold[joinSub[cc, #1, #2] &, base, Rest[subList]]
  ]
];

kernelAstarQ = joinAll[ccQ, globalSectionsQ];
kernelAstarC = joinAll[ccC, globalSectionsC];
kernelAstarCmin = joinAll[ccCmin, globalSectionsCmin];


(* ============================================================
   PART I: FOUR-CELL PARTITION
   ============================================================ *)

fourCells[cc_, subList_, a_] := Module[{neg, dneg, nonBot, infra, refusal, exploit, distrib},
  neg = heytingNot[cc, a];
  dneg = heytingNot[cc, neg];
  nonBot = Select[subList, !subEqQ[cc, #, bottomSub[cc]] &];
  infra    = Select[nonBot, leqSub[cc, #, a] &];
  refusal  = Select[nonBot, leqSub[cc, #, neg] &];
  exploit  = Select[nonBot, 
               leqSub[cc, #, dneg] && !leqSub[cc, #, a] &];
  distrib  = Select[nonBot, 
               !subEqQ[cc, meetSub[cc, #, a], bottomSub[cc]] &&
               !subEqQ[cc, meetSub[cc, #, neg], bottomSub[cc]] &];
  <|"i" -> Length[infra], "r" -> Length[refusal],
    "e" -> Length[exploit], "d" -> Length[distrib]|>
];

cellDivergent[c1_, c2_] := Or[
  (c1["i"] > 0) =!= (c2["i"] > 0),
  (c1["r"] > 0) =!= (c2["r"] > 0),
  (c1["e"] > 0) =!= (c2["e"] > 0),
  (c1["d"] > 0) =!= (c2["d"] > 0)];
cardDivergent[c1_, c2_] := {c1["i"], c1["r"], c1["e"], c1["d"]} =!=
                           {c2["i"], c2["r"], c2["e"], c2["d"]};


(* ============================================================
   PART J: V3-STYLE SECONDARY KERNEL CANDIDATES
   ------------------------------------------------------------
   For trend data: pick a Peres-style projection P and compute
   4.1' dasein(P) and 4.5' dasein(P) ^ -dasein(-P).
   ============================================================ *)

(* Pick P = rank-1 projection onto |0>+|1>+|2> direction (a
   non-MASA-aligned vector; Peres-style off-axis test projection) *)
Pdiag = rank1Proj[(e[1] + e[2] + e[3])/Sqrt[3]];
(* Classical analogue: a rank-3 idempotent in C^9, off the partition
   structure of any MASA in the comparator *)
Pdiagc = Total[Map[unitC9, {1, 4, 7}]];  (* pick one element from each T1c block *)

daseinPq = daseinSubobjQ[Pdiag];
daseinNotPq = daseinSubobjQ[Id3 - Pdiag];
daseinPc = daseinSubobjC[Pdiagc];
daseinNotPc = daseinSubobjC[cOneV - Pdiagc];


(* ============================================================
   PART K: EXECUTION REPORT
   ============================================================ *)

Print["============================================================"];
Print["v4 Bohrification on M_3(C): structural-break detection"];
Print["============================================================"];
Print["Configuration: 4 MASAs of M_3(C), each sharing one rank-1"];
Print["projection with the cardinal MASA T1.  8 contexts total."];
Print["NOT FULL KS-BLOCKING (research scope for v5)."];
Print[""];

Print["----- PART 0: poset and spectrum sanity -----"];
hasseQ = Length[Select[Tuples[contextsQ, 2],
  leqQ[#[[1]], #[[2]]] && #[[1]] =!= #[[2]] &]];
hasseC = Length[Select[Tuples[contextsC, 2],
  leqC[#[[1]], #[[2]]] && #[[1]] =!= #[[2]] &]];
specQ = Map[Length[spectraQ[#]] &, contextsQ];
specC = Map[Length[spectraC[#]] &, contextsC];
Print["|leq_q| = ", hasseQ, ";  |leq_c| = ", hasseC,
  "  match=", hasseQ === hasseC];
Print["spectrum sizes Q: ", specQ];
Print["spectrum sizes C: ", specC];
Print["sequence match (poset-iso requires): ", Sort[specQ] === Sort[specC]];

Print[""];
Print["----- PART 1: |Sub_cl(Sigma)| on both sides -----"];
Print["|Sub_cl(Q)| = ", Length[allSubQ]];
Print["|Sub_cl(C)| (best-effort same-Hasse, C^9) = ", Length[allSubC]];
Print["|Sub_cl(C_min)| (minimal C^3, 2 contexts) = ", Length[allSubCmin]];
Print["Sub_cl(Q) == Sub_cl(C) (best-effort)? ",
  Length[allSubQ] === Length[allSubC]];

Print[""];
Print["----- PART 2: |GlobalSections| -- THE STRUCTURAL SIGNAL -----"];
Print["|GlobalSections(Sigma_Q)| (atomic-everywhere subs, M_3(C)) = ",
  Length[globalSectionsQ]];
Print["|GlobalSections(Sigma_C)| (best-effort C^9) = ",
  Length[globalSectionsC]];
Print["|GlobalSections(Sigma_C_min)| (minimal C^3) = ",
  Length[globalSectionsCmin]];
Print[""];
Print["Quantum / classical (same Hasse) match? ",
  Length[globalSectionsQ] === Length[globalSectionsC]];
Print["Quantum / minimal C^3 match? ",
  Length[globalSectionsQ] === Length[globalSectionsCmin]];
Print[""];
Print["INTERPRETATION:"];
Print["- If Q == C-same-Hasse: the 4-MASA M_3(C) config is NOT"];
Print["  KS-blocking; lattice-iso holds, v3 structural-null finding"];
Print["  about |GlobalSections| matching also holds.  v5 will need"];
Print["  more MASAs to demonstrate the break."];
Print["- If Q < C-same-Hasse: the break IS visible at 4 MASAs;"];
Print["  v4 detects KS-flavour at minimal config (surprising)."];
Print["- Q vs C_min comparison shows the categorical-contrast"];
Print["  baseline (minimal C^3 always has 3 global sections)."];

Print[""];
Print["----- PART 3: kernel a* = join of atomic-everywhere subs -----"];
isBottomQ = subEqQ[ccQ, kernelAstarQ, bottomSub[ccQ]];
isBottomC = subEqQ[ccC, kernelAstarC, bottomSub[ccC]];
isBottomCmin = subEqQ[ccCmin, kernelAstarCmin, bottomSub[ccCmin]];
Print["kernel a* (Q) is bottom? ", isBottomQ];
Print["kernel a* (C, best-effort) is bottom? ", isBottomC];
Print["kernel a* (C_min) is bottom? ", isBottomCmin];
If[!isBottomQ,
  Print["a*_Q component sizes: ",
    AssociationThread[contextsQ -> Map[Length[kernelAstarQ[#]] &, contextsQ]]]];
If[!isBottomC,
  Print["a*_C component sizes: ",
    AssociationThread[contextsC -> Map[Length[kernelAstarC[#]] &, contextsC]]]];

If[!isBottomQ,
  Print[""];
  Print["----- PART 4: four-cell partition at a* (when a* != bottom) -----"];
  cellsAstarQ = fourCells[ccQ, allSubQ, kernelAstarQ];
  cellsAstarC = fourCells[ccC, allSubC, kernelAstarC];
  regAstarQ = regularQ[ccQ, kernelAstarQ];
  regAstarC = regularQ[ccC, kernelAstarC];
  Print["Q: regular?", regAstarQ, "  (i,r,e,d)=", 
    {cellsAstarQ["i"], cellsAstarQ["r"], cellsAstarQ["e"], cellsAstarQ["d"]}];
  Print["C: regular?", regAstarC, "  (i,r,e,d)=", 
    {cellsAstarC["i"], cellsAstarC["r"], cellsAstarC["e"], cellsAstarC["d"]}];
  Print["Cell-non-emptiness divergent? ", cellDivergent[cellsAstarQ, cellsAstarC]];
  Print["Cardinality divergent? ", cardDivergent[cellsAstarQ, cellsAstarC]];
];

Print[""];
Print["----- PART 5: v3-style cardinality-baseline kernels -----"];
Print["Test projection: rank-1 onto (|0>+|1>+|2>)/sqrt(3) (off-axis)"];
Print[""];
Print["dasein(P) quantum component sizes: ",
  AssociationThread[contextsQ -> Map[Length[daseinPq[#]] &, contextsQ]]];
Print["dasein(P) classical component sizes: ",
  AssociationThread[contextsC -> Map[Length[daseinPc[#]] &, contextsC]]];

Print[""];
Print["KERNEL 4.1': dasein(P)"];
cells41q = fourCells[ccQ, allSubQ, daseinPq];
cells41c = fourCells[ccC, allSubC, daseinPc];
reg41q = regularQ[ccQ, daseinPq];
reg41c = regularQ[ccC, daseinPc];
Print["Q: regular?", reg41q, "  (i,r,e,d)=",
  {cells41q["i"], cells41q["r"], cells41q["e"], cells41q["d"]}];
Print["C: regular?", reg41c, "  (i,r,e,d)=",
  {cells41c["i"], cells41c["r"], cells41c["e"], cells41c["d"]}];
Print["Cell-non-emptiness divergent? ", cellDivergent[cells41q, cells41c]];
Print["Cardinality divergent? ", cardDivergent[cells41q, cells41c]];

Print[""];
Print["KERNEL 4.5': dasein(P) ^ -dasein(-P)"];
kernel45q = meetSub[ccQ, daseinPq, heytingNot[ccQ, daseinNotPq]];
kernel45c = meetSub[ccC, daseinPc, heytingNot[ccC, daseinNotPc]];
cells45q = fourCells[ccQ, allSubQ, kernel45q];
cells45c = fourCells[ccC, allSubC, kernel45c];
reg45q = regularQ[ccQ, kernel45q];
reg45c = regularQ[ccC, kernel45c];
Print["Q: regular?", reg45q, "  (i,r,e,d)=",
  {cells45q["i"], cells45q["r"], cells45q["e"], cells45q["d"]}];
Print["C: regular?", reg45c, "  (i,r,e,d)=",
  {cells45c["i"], cells45c["r"], cells45c["e"], cells45c["d"]}];
Print["Cell-non-emptiness divergent? ", cellDivergent[cells45q, cells45c]];
Print["Cardinality divergent? ", cardDivergent[cells45q, cells45c]];

Print[""];
Print["============================================================"];
Print["v4 SUMMARY"];
Print["============================================================"];
Print["|Sub_cl(Q)| = ", Length[allSubQ], 
  "; |Sub_cl(C-best-effort)| = ", Length[allSubC],
  "; lattice-iso (size)? ", Length[allSubQ] === Length[allSubC]];
Print["|GlobalSections(Q)| = ", Length[globalSectionsQ], 
  "; |GlobalSections(C-best-effort)| = ", Length[globalSectionsC]];
Print["Structural break detected (Q < C)? ", 
  Length[globalSectionsQ] < Length[globalSectionsC]];
Print["Minimal-C^3 contrast: |GlobalSections(C_min)| = ", 
  Length[globalSectionsCmin], " (always >= 1 for any commutative)"];
Print[""];
Print["For full KS-blocking and a guaranteed Q < C signal, scale to"];
Print["v5 with Penrose-40 or Peres-33 configurations (~10-16 MASAs)."];
Print["============================================================"];
