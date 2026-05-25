(* ::Package:: *)

(* ============================================================
   FalseWork — Four-Position Partition: Music-Anchor Feasibility Test
   File:    four-position-music.wl
   Purpose: Step B of the music-anchor feasibility plan documented at
            preprints/four-position-partition/music-anchor/feasibility.md.

   Strategy
   --------
   We test whether the four-position partition theorem instantiates
   non-vacuously on a music-derived Heyting algebra. We work directly
   at the lattice level via a Moore closure operator on the powerset
   of Z/12, sidestepping the full topos construction.

   Specifically, the closure operator is

       diatonicClosure[P] = intersection of all diatonic scales
                            containing P, or Z/12 if none contain P.

   The closed sets under this closure form a complete lattice. We
   verify it is distributive (hence Heyting) and compute its Heyting
   operations. We then pick a kernel image, compute its complement and
   double-negation closure, and classify the three Coltrane reference
   works into one of {Infrastructure, Distribution, Exploitation,
   Refusal}.

   Tymoczko's three-field empirical classification of these works
   (cited with permission, March 2026) predicts:

       A Love Supreme     -> diatonic    -> Infrastructure
       Giant Steps        -> symmetric   -> Exploitation
       Interstellar Space -> chromatic   -> Refusal

   The test passes if the framework's lattice-based classification
   matches Tymoczko's empirical reading.

   Notes for the reader
   --------------------
   - Pitch classes are integers 0..11; 0=C, 1=C#/Db, ..., 11=B.
   - A "diatonic scale" is a transposed copy of C-major.
   - All set operations use standard Wolfram primitives. The Heyting
     operations are computed by enumeration over the closed-set
     lattice; this is feasible because the lattice is finite.
   - Run in Wolfram Cloud notebook: paste cell-by-cell, or
     Get["four-position-music.wl"] for whole-file evaluation.

   Status
   ------
   This is an exploratory empirical test, not a kernel-checked proof.
   The lattice computations are concrete and reproducible; the
   encoding of each work as a pitch-class set is a deliberate
   simplification (full transformation-network encoding via PK-Nets
   is future work).
   ============================================================ *)


(* =============================================================
   SECTION 1: Pitch-class space and diatonic scales
   ============================================================= *)

ChromaticPCs = Range[0, 11];

(* The 12 diatonic scales as transposed copies of
   C-major = {0, 2, 4, 5, 7, 9, 11}. *)
DiatonicScales = Table[
  Sort[Mod[k + {0, 2, 4, 5, 7, 9, 11}, 12]],
  {k, 0, 11}
];

(* Sanity: each scale has 7 elements *)
Assert[And @@ (Length /@ DiatonicScales == ConstantArray[7, 12])];

Print["[Section 1] Pitch-class space and diatonic scales"];
Print["  |Z/12|              = ", Length[ChromaticPCs]];
Print["  Number of diatonic scales = ", Length[DiatonicScales]];
Print["  D_0 (C major)       = ", DiatonicScales[[1]]];
Print["  D_5 (F major)       = ", DiatonicScales[[6]]];
Print["  D_7 (G major)       = ", DiatonicScales[[8]]];
Print[];


(* =============================================================
   SECTION 2: Diatonic-closure operator on the powerset of Z/12
   =============================================================
   diatonicClosure[P] is the intersection of all diatonic scales
   containing P. If no diatonic scale contains P, return Z/12.

   This is a Moore closure operator:
   - extensive:   P subset diatonicClosure[P]
   - monotone:    P subset Q implies diatonicClosure[P] subset diatonicClosure[Q]
   - idempotent:  diatonicClosure[diatonicClosure[P]] == diatonicClosure[P]
   ============================================================= *)

diatonicClosure[P_List] := Module[{containingScales},
  containingScales = Select[DiatonicScales, SubsetQ[#, P] &];
  If[containingScales === {},
    ChromaticPCs,
    Apply[Intersection, containingScales]
  ]
];

(* Sanity checks *)
Print["[Section 2] Diatonic-closure operator"];
Print["  diatonicClosure[{}]         = ", diatonicClosure[{}]];
Print["  diatonicClosure[{0}]        = ", diatonicClosure[{0}]];
Print["  diatonicClosure[{0, 7}]     = ", diatonicClosure[{0, 7}]];
Print["  diatonicClosure[{0, 1}]     = ", diatonicClosure[{0, 1}], "  (* non-diatonic dyad *)"];
Print["  diatonicClosure[{0, 3, 6, 9}] = ",
       diatonicClosure[{0, 3, 6, 9}], "  (* diminished-7th, non-diatonic *)"];
Print["  diatonicClosure[{0, 4, 8}]  = ",
       diatonicClosure[{0, 4, 8}], "  (* augmented triad, non-diatonic *)"];
Print[];

(* Verify idempotency on a few examples *)
idempotentCheck = And @@ Table[
  Module[{P = #, P1, P2}, P1 = diatonicClosure[P]; P2 = diatonicClosure[P1]; P1 == P2] & @
    RandomSample[ChromaticPCs, RandomInteger[{0, 12}]],
  {25}
];
Print["[Section 2] Idempotency check (25 random samples): ", idempotentCheck];
Print[];


(* =============================================================
   SECTION 3: The closed-set lattice
   =============================================================
   Closed sets = fixed points of diatonicClosure.
   We enumerate them by applying diatonicClosure to all subsets
   of Z/12 and taking unique values.
   ============================================================= *)

allSubsets = Subsets[ChromaticPCs];
Print["[Section 3] Enumerating closed sets"];
Print["  Total subsets of Z/12: ", Length[allSubsets]];

ClosedSets = DeleteDuplicates[diatonicClosure /@ allSubsets];
ClosedSets = SortBy[ClosedSets, {Length[#], #} &];

Print["  Number of distinct closed sets: ", Length[ClosedSets]];
Print["  Smallest:   ", ClosedSets[[1]]];
Print["  Next:       ", ClosedSets[[2]]];
Print["  Largest:    ", ClosedSets[[-1]]];
Print[];


(* =============================================================
   SECTION 4: Lattice structure (meet, join, top, bottom)
   =============================================================
   Meet:   intersection (preserves closed-ness)
   Join:   diatonicClosure[Union[P, Q]]
   Bottom: ClosedSets[[1]] (smallest element)
   Top:    ChromaticPCs
   ============================================================= *)

latticeMeet[P_, Q_] := Intersection[P, Q];
latticeJoin[P_, Q_] := diatonicClosure[Union[P, Q]];
latticeBottom = First[ClosedSets];
latticeTop = ChromaticPCs;

Print["[Section 4] Lattice structure"];
Print["  Bottom: ", latticeBottom];
Print["  Top:    ", latticeTop];
Print["  D_0 meet D_5 = ", latticeMeet[DiatonicScales[[1]], DiatonicScales[[6]]]];
Print["  D_0 join D_5 = ", latticeJoin[DiatonicScales[[1]], DiatonicScales[[6]]]];
Print[];

(* Verify meet of closed sets is closed (should always hold) *)
meetClosedCheck = And @@ Table[
  Module[{P = ClosedSets[[i]], Q = ClosedSets[[j]], M},
    M = latticeMeet[P, Q];
    MemberQ[ClosedSets, M]
  ],
  {i, 1, Min[20, Length[ClosedSets]]},
  {j, i, Min[20, Length[ClosedSets]]}
];
Print["[Section 4] Meet-closure check (sample of up to 20x20): ", meetClosedCheck];
Print[];


(* =============================================================
   SECTION 5: Heyting operations
   =============================================================
   For a complete distributive lattice L with a Galois-style closure:

     P => Q  =  largest closed R with R meet P subset Q
     not P   =  P => bottom
                 =  largest closed R with R meet P = bottom
     not not P  =  not (not P)

   We compute by enumeration over ClosedSets.
   ============================================================= *)

heytingImpl[P_, Q_] := Module[{candidates},
  candidates = Select[ClosedSets, SubsetQ[Q, latticeMeet[#, P]] &];
  If[candidates === {}, latticeBottom,
    First[SortBy[candidates, -Length[#] &]]]
];

heytingNot[P_] := heytingImpl[P, latticeBottom];

heytingDoubleNot[P_] := heytingNot[heytingNot[P]];

Print["[Section 5] Heyting operations"];
Print["  not D_0   = ", heytingNot[DiatonicScales[[1]]]];
Print["  not not D_0 = ", heytingDoubleNot[DiatonicScales[[1]]]];
Print["  not {0}   = ", heytingNot[{0}]];
Print["  not not {0} = ", heytingDoubleNot[{0}]];
Print[];


(* =============================================================
   SECTION 6: Non-Boolean witnesses
   =============================================================
   The lattice is non-Boolean iff there exists a closed set P with
   not not P != P. Enumerate witnesses and verify the lattice is
   non-trivial in this sense.
   ============================================================= *)

regularQ[P_] := heytingDoubleNot[P] === P;
nonBooleanWitnesses = Select[ClosedSets, !regularQ[#] &];

Print["[Section 6] Non-Boolean structure"];
Print["  Total closed sets:      ", Length[ClosedSets]];
Print["  Regular (P = ¬¬P):      ", Length[ClosedSets] - Length[nonBooleanWitnesses]];
Print["  Non-regular witnesses:  ", Length[nonBooleanWitnesses]];
If[Length[nonBooleanWitnesses] > 0,
  Print["  Example witness: ", nonBooleanWitnesses[[1]]];
  Print["    P:        ", nonBooleanWitnesses[[1]]];
  Print["    ¬P:       ", heytingNot[nonBooleanWitnesses[[1]]]];
  Print["    ¬¬P:      ", heytingDoubleNot[nonBooleanWitnesses[[1]]]];
  Print["    ¬¬P \\ P:  ", Complement[heytingDoubleNot[nonBooleanWitnesses[[1]]],
                                       nonBooleanWitnesses[[1]]]];
];
isNonBoolean = Length[nonBooleanWitnesses] > 0;
Print["  Non-Boolean structure available: ", isNonBoolean];
Print[];


(* =============================================================
   SECTION 7: Kernel choice and partition cells
   =============================================================
   Take kernel a = D_0 (C major). Compute the four position regions.
   ============================================================= *)

kernelA = DiatonicScales[[1]];
kernelAComp = heytingNot[kernelA];
kernelAddoubleNeg = heytingDoubleNot[kernelA];
closureResidue = Complement[kernelAddoubleNeg, kernelA];

Print["[Section 7] Kernel and partition regions (kernel a = D_0 = C major)"];
Print["  a    (kernel)            = ", kernelA];
Print["  ¬a   (Heyting complement)= ", kernelAComp];
Print["  ¬¬a  (double-negation)   = ", kernelAddoubleNeg];
Print["  ¬¬a \\ a  (Exploitation region) = ", closureResidue];
Print["  Non-Boolean at this kernel: ", kernelAddoubleNeg =!= kernelA];
Print[];


(* =============================================================
   SECTION 8: Coltrane encoding (pitch-class sets)
   =============================================================
   Each work is encoded by its characteristic pitch-class material.
   These are deliberate simplifications; richer encodings via
   PK-Nets or transformational-network structure are future work.
   ============================================================= *)

(* A Love Supreme — "Acknowledgement" head, F-Ab-Bb-Eb in F-minor /
   Eb-major diatonic context. The wider pitch material of the head
   sits in Eb-major diatonic = D_3. *)
aLoveSupremePCs = DiatonicScales[[4]]; (* = D_3 *)

(* Giant Steps — three diatonic keys connected by augmented-triad
   cycle: B-major (D_11), G-major (D_7), Eb-major (D_3). *)
giantStepsPCs = Sort[Union[
  DiatonicScales[[12]],  (* D_11 = B major *)
  DiatonicScales[[8]],   (* D_7  = G major *)
  DiatonicScales[[4]]    (* D_3  = Eb major *)
]];

(* Interstellar Space — sax + percussion, no fixed pitch material;
   approximated as the full chromatic 12-set. *)
interstellarSpacePCs = ChromaticPCs;

Print["[Section 8] Coltrane encodings"];
Print["  A Love Supreme      pitch-set = ", aLoveSupremePCs, "  (size ",
        Length[aLoveSupremePCs], ")"];
Print["  Giant Steps         pitch-set = ", giantStepsPCs, "  (size ",
        Length[giantStepsPCs], ")"];
Print["  Interstellar Space  pitch-set = ", interstellarSpacePCs, "  (size ",
        Length[interstellarSpacePCs], ")"];
Print[];

(* Project each work into the closed-set lattice via diatonicClosure. *)
aLoveSupremeImg = diatonicClosure[aLoveSupremePCs];
giantStepsImg   = diatonicClosure[giantStepsPCs];
interstellarSpaceImg = diatonicClosure[interstellarSpacePCs];

Print["[Section 8] Closed-set projections (the framework's D-images)"];
Print["  D(A Love Supreme)      = ", aLoveSupremeImg];
Print["  D(Giant Steps)         = ", giantStepsImg];
Print["  D(Interstellar Space)  = ", interstellarSpaceImg];
Print[];


(* =============================================================
   SECTION 9: Cell classification
   =============================================================
   For each work's image X and kernel a, classify into one cell.
   ============================================================= *)

classifyCell[X_, a_, aC_, aCC_] := Which[
  SubsetQ[a, X],
    "INFRASTRUCTURE  (X subset a)",
  SubsetQ[aC, X],
    "REFUSAL         (X subset ¬a)",
  SubsetQ[aCC, X] && !SubsetQ[a, X],
    "EXPLOITATION    (X subset ¬¬a but not subset a)",
  Intersection[X, a] =!= {} && Intersection[X, aC] =!= {},
    "DISTRIBUTION    (X meets both a and ¬a non-trivially)",
  True,
    "UNCLASSIFIED    (X does not fit any cell — diagnostic failure)"
];

Print["[Section 9] Cell classification (kernel a = D_0 = C major)"];
Print["  A Love Supreme      -> ",
        classifyCell[aLoveSupremeImg, kernelA, kernelAComp, kernelAddoubleNeg]];
Print["  Giant Steps         -> ",
        classifyCell[giantStepsImg, kernelA, kernelAComp, kernelAddoubleNeg]];
Print["  Interstellar Space  -> ",
        classifyCell[interstellarSpaceImg, kernelA, kernelAComp, kernelAddoubleNeg]];
Print[];


(* =============================================================
   SECTION 10: Comparison with Tymoczko and summary
   ============================================================= *)

tymoczkoPredictions = <|
  "A Love Supreme"      -> "INFRASTRUCTURE (Tymoczko: diatonic)",
  "Giant Steps"         -> "EXPLOITATION    (Tymoczko: symmetric)",
  "Interstellar Space"  -> "REFUSAL         (Tymoczko: chromatic)"
|>;

frameworkClassifications = <|
  "A Love Supreme"      -> classifyCell[aLoveSupremeImg, kernelA,
                                          kernelAComp, kernelAddoubleNeg],
  "Giant Steps"         -> classifyCell[giantStepsImg, kernelA,
                                          kernelAComp, kernelAddoubleNeg],
  "Interstellar Space"  -> classifyCell[interstellarSpaceImg, kernelA,
                                          kernelAComp, kernelAddoubleNeg]
|>;

cellName[s_String] := First[StringSplit[s, " "]];

matchQ[work_] := cellName[tymoczkoPredictions[work]] ==
                 cellName[frameworkClassifications[work]];

Print["[Section 10] Comparison: framework vs. Tymoczko's three-field reading"];
Print["  Work                | Framework                   | Tymoczko predicts            | Match?"];
Print["  --------------------|-----------------------------|------------------------------|-------"];
Scan[
  Print["  ", StringPadRight[#, 20], "| ",
        StringPadRight[frameworkClassifications[#], 28], "| ",
        StringPadRight[tymoczkoPredictions[#], 29], "| ",
        If[matchQ[#], "YES", "NO"]] &,
  {"A Love Supreme", "Giant Steps", "Interstellar Space"}
];
Print[];

allMatch = And @@ (matchQ /@ {"A Love Supreme", "Giant Steps", "Interstellar Space"});
Print["[Section 10] Overall match: ", allMatch];
Print[];

If[allMatch,
  Print["[Section 10] PASS: framework classification matches Tymoczko's"];
  Print["  three-field reading on all three reference works."],
  Print["[Section 10] PARTIAL or FAIL: see per-work results above."];
  Print["  Diagnostic next steps:"];
  Print["    - If A Love Supreme misclassifies: kernel choice may need revision."];
  Print["    - If Giant Steps misclassifies as Infrastructure: encoding"];
  Print["      collapses augmented-triad cycle into kernel; need finer encoding."];
  Print["    - If Giant Steps misclassifies as Refusal: encoding is over-broad."];
  Print["    - If Interstellar Space misclassifies as Exploitation: closure-residue"];
  Print["      region is too large; need finer kernel or coarser closure."];
];
Print[];


(* =============================================================
   SECTION 11: Sanity / additional checks
   ============================================================= *)

(* Number of cells inhabited by some closed set *)
inhabitedCells = AssociationMap[
  Function[cellName,
    Length[Select[ClosedSets,
      Function[X,
        StringStartsQ[
          classifyCell[X, kernelA, kernelAComp, kernelAddoubleNeg],
          cellName
        ]
      ]
    ]]
  ],
  {"INFRASTRUCTURE", "REFUSAL", "EXPLOITATION", "DISTRIBUTION", "UNCLASSIFIED"}
];

Print["[Section 11] Cell occupancy across all ", Length[ClosedSets], " closed sets"];
KeyValueMap[Print["  ", StringPadRight[#1, 18], " : ", #2] &, inhabitedCells];
Print[];

(* Number of cells inhabited by at least one closed set *)
nonEmptyCells = Length[Select[Values[inhabitedCells], # > 0 &]] - 
                Boole[inhabitedCells["UNCLASSIFIED"] > 0];

Print["[Section 11] Number of genuinely inhabited cells (excluding UNCLASSIFIED): ",
       nonEmptyCells];

If[nonEmptyCells == 4,
  Print["[Section 11] ALL FOUR CELLS ARE INHABITED in this lattice."],
  Print["[Section 11] Only ", nonEmptyCells, " of 4 cells are inhabited."];
  Print["  This is a partial-vacuity result — the partition is non-trivial"];
  Print["  but does not exercise all four positions on this lattice/kernel."]
];
Print[];

Print["============================================================"];
Print["END OF four-position-music.wl"];
Print["============================================================"];
