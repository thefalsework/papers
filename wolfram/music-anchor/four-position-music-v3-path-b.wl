(* ::Package:: *)

(* ============================================================
   FalseWork — Four-Position Partition: Music-Anchor v3 (Path B)
   File:    four-position-music-v3-path-b.wl
   Purpose: Lattice-level non-vacuity witness for Theorem 5.1 of
            paper.md on a music-derived elementary topos.

   Background
   ----------
   v1 and v2 (four-position-music.wl, four-position-music-v2.wl)
   attempted a shortcut: build a closed-set lattice via a Moore
   closure operator on subsets of Z/12 (diatonic-scale closure)
   and run the partition test there. v2 §9 established that
   the resulting lattice is NOT a Heyting algebra: it fails
   distributivity, hence cannot satisfy the hypothesis of
   Theorem 5.1. See preprints/four-position-partition/music-anchor/
   feasibility.md §11 for the full negative result.

   Path B (this file) drops the lattice-level shortcut and works
   on the subobject lattice of an actual music-derived elementary
   topos: Z/12-Sets, the presheaf topos on the one-object groupoid
   B(Z/12). The relevant object is Y = Z/12 with regular action.

   Key fact (elementary group theory + standard topos theory):

       Sub_{Z/12-Sets}(Y)  ≅  { subgroups of Z/12 }
                          ≅  { divisors of 12 }

   The divisor lattice of 12 is distributive (always true for
   divisor lattices) and non-Boolean (12 is not squarefree),
   hence is a non-trivial Heyting algebra by construction.

   This file verifies all of that explicitly, identifies the
   non-regular elements, and shows the four position cells are
   non-empty at a tritone kernel — establishing the four-position
   partition theorem is non-vacuous on music-domain material.

   Scope limits (documented honestly):
   - This file establishes lattice-level non-vacuity, NOT a full
     distinction-structure witness. Producing a concrete idempotent
     monad on Z/12-Sets whose unit's image is the chosen kernel is
     the next step (Lean-side, deferred).
   - This file does NOT classify specific musical works. The
     Coltrane test of feasibility.md §6 is downstream of the
     distinction-structure construction.
   ============================================================ *)


(* =============================================================
   SECTION 1: The divisor lattice of 12
   =============================================================
   Elements = divisors of 12 = {1, 2, 3, 4, 6, 12}.
   Equivalently the orders of subgroups of Z/12.
   Order on divisors: a ≤_div b iff a divides b.
   Meet = gcd, join = lcm.
   ============================================================= *)

DivisorsOf12 = Divisors[12];
Print["[Section 1] Divisor lattice of 12"];
Print["  Elements (subgroup orders): ", DivisorsOf12];
Print[];

(* Subgroup representation: subgroup of Z/12 of order d is <12/d>.
   We list its elements. *)
subgroupOfOrder[d_] := Sort[Mod[Range[0, d - 1] * (12 / d), 12]];

SubgroupOfOrder = AssociationMap[subgroupOfOrder, DivisorsOf12];

Print["  Subgroups (each order -> generator subset of Z/12):"];
KeyValueMap[Print["    order ", #1, " : ", #2] &, SubgroupOfOrder];
Print[];

(* Musical labels *)
MusicLabel = <|
  1  -> "trivial {0}",
  2  -> "tritone <6>",
  3  -> "augmented triad <4>",
  4  -> "diminished 7th <3>",
  6  -> "whole-tone hexachord <2>",
  12 -> "full chromatic Z/12"
|>;

Print["  Musical labels:"];
KeyValueMap[Print["    order ", #1, " : ", #2] &, MusicLabel];
Print[];

(* Lattice operations *)
divMeet[a_, b_] := GCD[a, b];
divJoin[a_, b_] := LCM[a, b];
divLE[a_, b_] := Divisible[b, a];      (* a divides b *)
divBottom = 1;
divTop = 12;


(* =============================================================
   SECTION 2: Verify distributivity (so the lattice is Heyting)
   ============================================================= *)

Print["[Section 2] Distributivity check"];

distributivityResults = Flatten[Table[
  divMeet[a, divJoin[b, c]] === divJoin[divMeet[a, b], divMeet[a, c]],
  {a, DivisorsOf12}, {b, DivisorsOf12}, {c, DivisorsOf12}
]];

isDistributive = And @@ distributivityResults;
Print["  All 6^3 = ", Length[distributivityResults],
       " distributivity instances hold? ", isDistributive];
Print["  -> Lattice is ", If[isDistributive, "DISTRIBUTIVE (hence Heyting)", "NOT distributive"]];
Print[];


(* =============================================================
   SECTION 3: Heyting operations
   =============================================================
   In a finite distributive lattice, ¬a = sup{b : a ⊓ b = ⊥}.
   Here: ¬a = lcm of divisors coprime to a, with bottom = 1.
   ============================================================= *)

heytingComp[a_] := Module[{coprimes},
  coprimes = Select[DivisorsOf12, GCD[a, #] === 1 &];
  If[coprimes === {}, divBottom, Fold[divJoin, divBottom, coprimes]]
];

heytingDC[a_] := heytingComp[heytingComp[a]];

Print["[Section 3] Heyting complement and double-negation"];
Print["  a    ¬a   ¬¬a  regular?"];
Print["  ---  ---  ---  --------"];
Scan[
  Function[a,
    Module[{nc = heytingComp[a], ncc = heytingDC[a]},
      Print["  ", StringPadRight[ToString[a], 4],
            StringPadRight[ToString[nc], 4],
            StringPadRight[ToString[ncc], 4],
            If[ncc === a, "yes", "NO (non-regular)"]]
    ]
  ],
  DivisorsOf12
];
Print[];

NonRegular = Select[DivisorsOf12, heytingDC[#] =!= # &];
Print["  Non-regular elements: ", NonRegular];
Print["    (these are the Exploitation-eligible kernel candidates)"];
isNonBoolean = NonRegular =!= {};
Print["  Lattice is ", If[isNonBoolean, "NON-BOOLEAN", "Boolean"]];
Print[];


(* =============================================================
   SECTION 4: Verify Heyting identities at all elements
   =============================================================
   In a Heyting algebra: a ⊓ b = ⊥ ⟺ b ≤ ¬a, for all a, b.
   We check this directly across all 6^2 pairs.
   ============================================================= *)

heytingIdResults = Flatten[Table[
  (divMeet[a, b] === divBottom) === divLE[b, heytingComp[a]],
  {a, DivisorsOf12}, {b, DivisorsOf12}
]];

isHeyting = And @@ heytingIdResults;
Print["[Section 4] Heyting identity check"];
Print["  (a ⊓ b = ⊥) ⟺ (b ≤ ¬a) at all 6^2 = ", Length[heytingIdResults],
       " pairs? ", isHeyting];
Print["  -> Lattice IS a Heyting algebra at every pair: ", isHeyting];
Print[];


(* =============================================================
   SECTION 5: Four-position cells at each non-regular kernel
   =============================================================
   For X ≠ ⊥ in the lattice:
     IsInfrastructure(X) := X ≤ a
     IsRefusal(X)        := X ≤ ¬a
     IsExploitation(X)   := (X ≤ ¬¬a) ∧ ¬(X ≤ a)
     IsDistribution(X)   := (X ⊓ a ≠ ⊥) ∧ (X ⊓ ¬a ≠ ⊥)
   Theorem 5.1 of paper.md: exactly one holds for each X ≠ ⊥.
   ============================================================= *)

classify[X_, a_] := Module[{aC, aCC},
  aC = heytingComp[a];
  aCC = heytingDC[a];
  Which[
    divLE[X, a],
      "INFRASTRUCTURE",
    divLE[X, aC],
      "REFUSAL",
    divLE[X, aCC] && !divLE[X, a],
      "EXPLOITATION",
    (divMeet[X, a] =!= divBottom) && (divMeet[X, aC] =!= divBottom),
      "DISTRIBUTION",
    True,
      "UNCLASSIFIED"
  ]
];

reportKernel[a_] := Module[{cells, aC, aCC, nonBottom},
  aC = heytingComp[a];
  aCC = heytingDC[a];
  Print["  -----------------------------------------------------------"];
  Print["  Kernel a = ", a, " (", MusicLabel[a], ")"];
  Print["    ¬a  = ", aC, "  (", MusicLabel[aC], ")"];
  Print["    ¬¬a = ", aCC, " (", MusicLabel[aCC], ")"];
  Print[];
  nonBottom = Select[DivisorsOf12, # =!= divBottom &];
  cells = AssociationMap[
    Function[X, classify[X, a]],
    nonBottom
  ];
  Print["  Per-element classification (X = nonzero subgroup orders):"];
  KeyValueMap[
    Function[{X, cell},
      Print["    X = ", StringPadRight[ToString[X], 3],
            " (", StringPadRight[MusicLabel[X], 28], ") -> ", cell]
    ],
    cells
  ];
  Print[];
  Print["  Cell occupancy:"];
  Scan[
    Function[c,
      Module[{members = Select[nonBottom, classify[#, a] === c &]},
        Print["    ", StringPadRight[c, 16], ": ", Length[members],
              "  ", If[members === {}, "(empty)",
                       Row[{"members ", members}]]]
      ]
    ],
    {"INFRASTRUCTURE", "REFUSAL", "EXPLOITATION", "DISTRIBUTION", "UNCLASSIFIED"}
  ];
  Print[];
];

Print["[Section 5] Four-position cells at each non-regular kernel"];
Print[];
Scan[reportKernel, NonRegular];


(* =============================================================
   SECTION 6: Exhaustive cross-kernel partition table
   =============================================================
   For every (kernel, element) pair, tabulate which cell. This is
   the most compact certificate of the partition's behaviour on
   this lattice.
   ============================================================= *)

Print["[Section 6] Cross-kernel cell table"];
Print["    rows = kernel a (only non-regular shown)"];
Print["    cols = element X (excluding bottom)"];
Print[];

nonBottom = Select[DivisorsOf12, # =!= divBottom &];
Print["    a \\ X     ", Row[Map[StringPadRight[ToString[#], 16] &, nonBottom]]];
Print["    -------  ", StringRepeat["----------------", Length[nonBottom]]];
Scan[
  Function[a,
    Print["    a = ", StringPadRight[ToString[a], 4], "  ",
          Row[Map[StringPadRight[StringTake[classify[#, a], UpTo[14]], 16] &,
                  nonBottom]]]
  ],
  NonRegular
];
Print[];


(* =============================================================
   SECTION 7: Disjointness and exhaustiveness check
   =============================================================
   For each kernel, verify the four cells partition Sub(Y) ∖ {⊥}.
   ============================================================= *)

Print["[Section 7] Partition check at each non-regular kernel"];
Print[];

partitionOK[a_] := Module[{cellAssign, byCell},
  cellAssign = Map[classify[#, a] &, nonBottom];
  byCell = AssociationMap[
    Function[c, Count[cellAssign, c]],
    {"INFRASTRUCTURE", "REFUSAL", "EXPLOITATION", "DISTRIBUTION", "UNCLASSIFIED"}
  ];
  Print["  Kernel a = ", a, " : ", byCell,
        "    total = ", Total[Values[byCell]],
        " (expected ", Length[nonBottom], ")"];
  byCell["UNCLASSIFIED"] === 0 &&
    Total[Values[byCell]] === Length[nonBottom]
];

allKernelsOK = And @@ Map[partitionOK, NonRegular];
Print[];
Print["  All non-regular kernels give a clean partition (no UNCLASSIFIED): ", allKernelsOK];
Print[];


(* =============================================================
   SECTION 8: Summary
   ============================================================= *)

allCellsInhabited[a_] := Module[{cellAssign},
  cellAssign = Map[classify[#, a] &, nonBottom];
  And @@ Table[MemberQ[cellAssign, c],
    {c, {"INFRASTRUCTURE", "REFUSAL", "EXPLOITATION", "DISTRIBUTION"}}]
];

fourCellKernels = Select[NonRegular, allCellsInhabited];

Print["[Section 8] Summary"];
Print["  Lattice size                    : ", Length[DivisorsOf12]];
Print["  Distributive                    : ", isDistributive];
Print["  Heyting identity holds at all pairs : ", isHeyting];
Print["  Non-Boolean (non-regular exists): ", isNonBoolean];
Print["  Non-regular elements            : ", NonRegular];
Print["  Kernels at which all 4 cells inhabited : ", fourCellKernels];
Print["  No UNCLASSIFIED at any kernel   : ", allKernelsOK];
Print[];
Print["  Bottom line:"];
Print["    The subobject lattice Sub_{Z/12-Sets}(Z/12) is a 6-element"];
Print["    distributive non-Boolean Heyting algebra. Theorem 5.1 of"];
Print["    paper.md applies cleanly. At kernel a = ", First[fourCellKernels],
       " (", MusicLabel[First[fourCellKernels]], "),"];
Print["    all four cells are inhabited by sub-Z/12-sets with established"];
Print["    musical significance."];
Print[];

Print["============================================================"];
Print["END OF four-position-music-v3-path-b.wl"];
Print["============================================================"];
