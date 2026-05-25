(* ::Package:: *)

(* ============================================================
   FalseWork — Four-Position Partition: Music-Anchor v2
   File:    four-position-music-v2.wl
   Purpose: Computational exploration of the four-position partition
            on the diatonic-closure Heyting algebra on Z/12.

   Difference from v1
   ------------------
   v1 anchored the test against an external three-field
   classification (Tymoczko 2026). v2 strips that anchor and just
   runs the math: pick kernels on mathematical criteria, classify
   a range of pitch-class inputs, report what cells they land in.
   No pre-baked predictions about where things "should" go.

   The lattice and Heyting structure are identical to v1
   (see v1 for full justification of the construction).
   ============================================================ *)


(* =============================================================
   SECTION 1: Pitch-class space, diatonic scales, closure operator
   ============================================================= *)

ChromaticPCs = Range[0, 11];

DiatonicScales = Table[
  Sort[Mod[k + {0, 2, 4, 5, 7, 9, 11}, 12]],
  {k, 0, 11}
];

diatonicClosure[P_List] := Module[{containingScales},
  containingScales = Select[DiatonicScales, SubsetQ[#, P] &];
  If[containingScales === {},
    ChromaticPCs,
    Apply[Intersection, containingScales]
  ]
];

Print["[Section 1] Setup complete: 12 pitch classes, 12 diatonic scales."];
Print[];


(* =============================================================
   SECTION 2: Closed-set lattice
   ============================================================= *)

ClosedSets = DeleteDuplicates[diatonicClosure /@ Subsets[ChromaticPCs]];
ClosedSets = SortBy[ClosedSets, {Length[#], #} &];

Print["[Section 2] Closed-set lattice: ", Length[ClosedSets], " elements."];
Print["  Size distribution (size -> count):"];
Print["  ", Counts[Length /@ ClosedSets]];
Print[];


(* =============================================================
   SECTION 3: Heyting operations
   ============================================================= *)

latticeMeet[P_, Q_] := Intersection[P, Q];
latticeJoin[P_, Q_] := diatonicClosure[Union[P, Q]];
latticeBottom = First[ClosedSets];
latticeTop = Last[ClosedSets];

heytingImpl[P_, Q_] := Module[{candidates},
  candidates = Select[ClosedSets, SubsetQ[Q, latticeMeet[#, P]] &];
  If[candidates === {}, latticeBottom,
    First[SortBy[candidates, -Length[#] &]]]
];

heytingNot[P_] := heytingImpl[P, latticeBottom];
heytingDoubleNot[P_] := heytingNot[heytingNot[P]];

regularQ[P_] := heytingDoubleNot[P] === P;
nonRegularQ[P_] := !regularQ[P];

Print["[Section 3] Heyting operations defined."];
Print[];


(* =============================================================
   SECTION 4: Enumerate non-regular elements (Exploitation-eligible
              kernel candidates)
   =============================================================
   For Exploitation to be non-empty when a is chosen as kernel,
   a must be non-regular (i.e., ¬¬a strictly contains a).
   ============================================================= *)

NonRegularElements = Select[ClosedSets, nonRegularQ];
RegularElements = Select[ClosedSets, regularQ];

Print["[Section 4] Regular vs. non-regular elements"];
Print["  Regular (P = ¬¬P)        : ", Length[RegularElements]];
Print["  Non-regular (P ≠ ¬¬P)    : ", Length[NonRegularElements]];
Print["  Smallest non-regular     : ", NonRegularElements[[1]]];
Print["  Largest non-regular      : ", NonRegularElements[[-1]]];
Print[];


(* =============================================================
   SECTION 5: Define classifier and pick candidate kernels
   =============================================================
   Candidate kernels are picked on mathematical criteria:
   - small non-regular elements (so the kernel is a "minimal
     commitment" with non-trivial closure-residue),
   - representative across the non-regular layer.
   ============================================================= *)

classify[X_, a_] := Module[{aC, aCC},
  aC = heytingNot[a];
  aCC = heytingDoubleNot[a];
  Which[
    SubsetQ[a, X],
      "INFRASTRUCTURE",
    SubsetQ[aC, X],
      "REFUSAL",
    SubsetQ[aCC, X] && !SubsetQ[a, X],
      "EXPLOITATION",
    Intersection[X, a] =!= {} && Intersection[X, aC] =!= {},
      "DISTRIBUTION",
    True,
      "UNCLASSIFIED"
  ]
];

(* Pick candidate kernels — five small non-regular sets, varied. *)
CandidateKernels = {
  {0},                  (* tonic alone *)
  {0, 7},               (* perfect fifth (closed) *)
  {0, 2, 7},            (* sus2 *)
  {0, 4, 7},            (* major triad (verify closed) *)
  {3, 5, 8, 10}         (* ALS-motif as kernel — test what happens *)
};

(* Filter to ones that are actually closed and non-regular *)
ValidKernels = Select[
  Map[diatonicClosure, CandidateKernels],
  nonRegularQ
];
ValidKernels = DeleteDuplicates[ValidKernels];

Print["[Section 5] Candidate kernels"];
Print["  Original candidates : ", CandidateKernels];
Print["  After closure       : ", diatonicClosure /@ CandidateKernels];
Print["  Valid (non-regular) : ", ValidKernels];
Print[];


(* =============================================================
   SECTION 6: Per-kernel cell structure
   =============================================================
   For each valid candidate kernel, compute:
   - a, ¬a, ¬¬a, ¬¬a \ a
   - Cell occupancy across all 92 closed sets
   - A few example members of Exploitation (if non-empty)
   ============================================================= *)

reportKernel[a_] := Module[{aC, aCC, residue, cellCounts, exploitMembers},
  aC = heytingNot[a];
  aCC = heytingDoubleNot[a];
  residue = Complement[aCC, a];
  cellCounts = AssociationMap[
    Function[cell, Length[Select[ClosedSets, classify[#, a] === cell &]]],
    {"INFRASTRUCTURE", "REFUSAL", "EXPLOITATION", "DISTRIBUTION", "UNCLASSIFIED"}
  ];
  exploitMembers = Select[ClosedSets, classify[#, a] === "EXPLOITATION" &];
  Print["  -----------------------------------------------"];
  Print["  Kernel a            = ", a, "   (size ", Length[a], ")"];
  Print["    ¬a                = ", aC];
  Print["    ¬¬a               = ", aCC];
  Print["    ¬¬a \\ a (residue) = ", residue];
  Print["  Cell occupancy across 92 closed sets:"];
  KeyValueMap[Print["    ", StringPadRight[#1, 16], " : ", #2] &, cellCounts];
  If[Length[exploitMembers] > 0,
    Print["  Exploitation members (up to first 5):"];
    Scan[Print["    ", #] &, Take[exploitMembers, Min[5, Length[exploitMembers]]]],
    Print["  Exploitation: empty for this kernel"]
  ];
  Print[];
];

Print["[Section 6] Cell structure per candidate kernel"];
Print[];
Scan[reportKernel, ValidKernels];


(* =============================================================
   SECTION 7: Classify a range of pitch-class inputs
   =============================================================
   For each kernel, classify a set of pitch-class inputs.
   The inputs are music-relevant pitch-class sets, but we make
   no prediction about where they "should" land.
   ============================================================= *)

TestInputs = <|
  "C-major scale (D_0)"     -> DiatonicScales[[1]],
  "Eb-major scale (D_3)"    -> DiatonicScales[[4]],
  "G-major scale (D_7)"     -> DiatonicScales[[8]],
  "B-major scale (D_11)"    -> DiatonicScales[[12]],
  "F-Ab-Bb-Eb motif"        -> {3, 5, 8, 10},
  "Augmented triad Eb-G-B"  -> {3, 7, 11},
  "Augmented triad C-E-G#"  -> {0, 4, 8},
  "Diminished 7th C-Eb-Gb-A" -> {0, 3, 6, 9},
  "Chromatic dyad C-C#"     -> {0, 1},
  "Tritone C-F#"            -> {0, 6},
  "Whole-tone hexachord"    -> {0, 2, 4, 6, 8, 10},
  "Z/12 (full chromatic)"   -> ChromaticPCs
|>;

Print["[Section 7] Classification of pitch-class inputs across kernels"];
Print[];

reportInputs[a_] := Module[{},
  Print["  Kernel a = ", a];
  Print["  ---------------------------------------------------------------"];
  Print["  Input                          | Closure                          | Cell"];
  Print["  -------------------------------|----------------------------------|---------------"];
  KeyValueMap[
    Function[{name, input},
      Module[{closed},
        closed = diatonicClosure[input];
        Print["  ",
          StringPadRight[name, 30], " | ",
          StringPadRight[ToString[closed], 32], " | ",
          classify[closed, a]
        ]
      ]
    ],
    TestInputs
  ];
  Print[];
];

Scan[reportInputs, ValidKernels];


(* =============================================================
   SECTION 8: Summary statistics
   ============================================================= *)

Print["[Section 8] Summary"];
Print["  Closed-set lattice size:              ", Length[ClosedSets]];
Print["  Non-regular elements (kernel-eligible): ", Length[NonRegularElements]];
Print["  Valid candidate kernels tested:        ", Length[ValidKernels]];
Print["  Test inputs classified:                ", Length[TestInputs]];
Print[];

(* Cross-kernel cell occupancy: for each input, how many of the
   tested kernels place it in each cell? *)
crossClassification = AssociationMap[
  Function[name,
    AssociationMap[
      Function[cell,
        Count[
          Map[classify[diatonicClosure[TestInputs[name]], #] &, ValidKernels],
          cell
        ]
      ],
      {"INFRASTRUCTURE", "REFUSAL", "EXPLOITATION", "DISTRIBUTION"}
    ]
  ],
  Keys[TestInputs]
];

Print["[Section 8] Cross-kernel cell occupancy"];
Print["  (for each input, how many of the ", Length[ValidKernels],
       " kernels assign it to each cell)"];
Print["  -----------------------------------------------------------------------"];
Print["  Input                          | INF | REF | EXP | DIS"];
Print["  -------------------------------|-----|-----|-----|----"];
KeyValueMap[
  Function[{name, counts},
    Print["  ",
      StringPadRight[name, 30], " | ",
      StringPadRight[ToString[counts["INFRASTRUCTURE"]], 3], " | ",
      StringPadRight[ToString[counts["REFUSAL"]], 3], " | ",
      StringPadRight[ToString[counts["EXPLOITATION"]], 3], " | ",
      ToString[counts["DISTRIBUTION"]]
    ]
  ],
  crossClassification
];
Print[];


(* =============================================================
   SECTION 9: Diagnostic witnesses — is the lattice actually Heyting?
   =============================================================
   The four-position partition theorem requires Sub(D(Y)) to be a
   Heyting algebra. A complete lattice is Heyting iff it is
   distributive. The non-trivial UNCLASSIFIED counts above are
   structurally impossible in a Heyting lattice, so we check
   directly.

   Witness 1 (Heyting identity b ⊓ a = ⊥ ⟺ b ≤ aᶜ).
     Take a = {0}, X = B-major scale = D_11 = {1,3,4,6,8,10,11}.
     Compute X ⊓ a (intersection) and check X ⊆ ¬a (heytingNot).

   Witness 2 (distributivity P ⊓ (Q ⊔ R) = (P ⊓ Q) ⊔ (P ⊓ R)).
     Take P = {0,1,3,5,8,10}, Q = D_0 = C-major, R = D_3 = Eb-major.
     Compute both sides explicitly.
   ============================================================= *)

Print["[Section 9] Diagnostic witnesses for non-Heyting structure"];
Print[];

(* --- Witness 1: Heyting identity failure --- *)

w1a = {0};
w1X = {1, 3, 4, 6, 8, 10, 11};                 (* B-major scale, D_11 *)
w1meet = latticeMeet[w1X, w1a];                (* X ⊓ a *)
w1notA = heytingNot[w1a];                      (* ¬a *)
w1subset = SubsetQ[w1notA, w1X];               (* X ⊆ ¬a ? *)

Print["  Witness 1: Heyting identity b ⊓ a = ⊥ ⟺ b ≤ ¬a"];
Print["    a          = ", w1a];
Print["    X          = ", w1X, "  (B-major scale, D_11)"];
Print["    X ⊓ a      = ", w1meet, "  (= bottom: ", w1meet === latticeBottom, ")"];
Print["    ¬a         = ", w1notA, "  (D-major scale, D_2)"];
Print["    X ⊆ ¬a ?   = ", w1subset];
Print["    Heyting identity holds at (X, a)? = ",
       (w1meet === latticeBottom) === w1subset];
Print["    [If FALSE, the lattice is not Heyting at this pair.]"];
Print[];

(* --- Witness 2: Distributivity failure --- *)

w2P = {0, 1, 3, 5, 8, 10};      (* closure of {0,1} = D_1 ∩ D_8 *)
w2Q = DiatonicScales[[1]];      (* D_0 = C-major *)
w2R = DiatonicScales[[4]];      (* D_3 = Eb-major *)

w2QjoinR = latticeJoin[w2Q, w2R];
w2PmeetQR = latticeMeet[w2P, w2QjoinR];

w2PQ = latticeMeet[w2P, w2Q];
w2PR = latticeMeet[w2P, w2R];
w2PQjoinPR = latticeJoin[w2PQ, w2PR];

w2dist = w2PmeetQR === w2PQjoinPR;

Print["  Witness 2: Distributivity P ⊓ (Q ⊔ R) = (P ⊓ Q) ⊔ (P ⊓ R)"];
Print["    P              = ", w2P, "  (closure of {0,1})"];
Print["    Q              = ", w2Q, "  (D_0 = C-major)"];
Print["    R              = ", w2R, "  (D_3 = Eb-major)"];
Print["    Q ⊔ R          = ", w2QjoinR];
Print["    P ⊓ (Q ⊔ R)    = ", w2PmeetQR];
Print["    P ⊓ Q          = ", w2PQ];
Print["    P ⊓ R          = ", w2PR];
Print["    (P⊓Q) ⊔ (P⊓R)  = ", w2PQjoinPR];
Print["    Distributivity holds at (P, Q, R)? = ", w2dist];
Print["    [If FALSE, the lattice is non-distributive, hence non-Heyting.]"];
Print[];

Print["  Summary diagnosis:"];
heytingId = (w1meet === latticeBottom) === w1subset;
Print["    Heyting identity OK at witness 1: ", heytingId];
Print["    Distributivity OK at witness 2:   ", w2dist];
If[Not[heytingId] || Not[w2dist],
  Print["    -> The diatonic-closure Moore lattice on Z/12 is NOT a"];
  Print["       Heyting algebra. The four-position partition theorem"];
  Print["       does not apply to this lattice. The UNCLASSIFIED"];
  Print["       counts in Section 6 are the symptom."],
  Print["    -> Both diagnostics pass at these witnesses (further"];
  Print["       analysis required to rule out other failure modes)."]
];
Print[];


Print["============================================================"];
Print["END OF four-position-music-v2.wl"];
Print["============================================================"];
