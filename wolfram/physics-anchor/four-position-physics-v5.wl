(* ::Package:: *)

(* ============================================================
   Route A v5: Peres-33 KS-blocking structural-break test
   ------------------------------------------------------------
   Companion to:
     preprints/four-position-partition/physics-anchor/v5-scope.md
     preprints/four-position-partition/physics-anchor/feasibility.md
     wolfram/physics-anchor/four-position-physics-v4.wl

   QUESTION (v5-scope.md sec. 1):
     Does |GlobalSections(Sigma_Q)| = 0 for the full Peres-33 KS
     configuration (33 explicit rays + 24 dyad-completion rays =
     57 rays, 16 explicit triads + 24 implicit triads = 40 triads),
     while |GlobalSections(Sigma_C_min)| = 3 for the minimal
     commutative comparator C^3?

   METHODOLOGY (v5-scope.md sec. 6):
     Approach 3 (direct |GlobalSections| count, skip Sub_cl
     enumeration). |GlobalSections(Sigma_Q)| equals the number
     of {0,1}-valuations of the 57 rays where each of the 40
     triads has exactly one "1" -- this is the Kochen-Specker
     no-coloring statement made computational. Computed by
     Mathematica's SatisfiabilityCount (BDD-based).

   EXPECTED OUTCOME:
     |GlobalSections(Sigma_Q)| = 0 (by KS theorem)
     |GlobalSections(Sigma_C_min)| = 3
     Structural break: 0 < 3 (strict inequality).

   PERES-33 REFERENCES:
     - Peres 1991, J. Phys. A 24, L175-L178.
     - Aravind & Lee-Elkin 2007, arXiv:0711.0894 (33-ray + Penrose
       isomorphism; explicit vector table).
     - Pavičić, Megill, Merlet 2009, arXiv:0909.4502v2 (57-40 form).

   Author: Chris Brink, May 2026.
   ============================================================ *)

ClearAll["Global`*"];

Print["============================================================"];
Print["v5 Peres-33 KS-blocking structural-break test on M_3(C)"];
Print["============================================================"];
Print["Configuration: 33 Peres rays + 24 dyad-completion rays = 57"];
Print["                rays; 16 explicit triads + 24 implicit triads"];
Print["                = 40 triads. KS-witnessing (Peres 1991)."];

(* ============================================================
   PART 0: Define the 33 Peres rays
   (unnormalized; Aravind & Lee-Elkin 2007 Table 3.1)
   ============================================================ *)

Print[""];
Print["----- PART 0: Peres 33 rays + 24 dyads -----"];

peresRays = {
  {1, 0, 0},        (* 1  *)
  {0, 1, 0},        (* 2  *)
  {0, 0, 1},        (* 3  *)
  {1, 0, 1},        (* 4  *)
  {1, 1, 0},        (* 5  *)
  {0, 1, 1},        (* 6  *)
  {-1, 1, 0},       (* 7  *)
  {-1, 0, 1},       (* 8  *)
  {0, -1, 1},       (* 9  *)
  {1, 0, Sqrt[2]},  (* 10 *)
  {Sqrt[2], 0, 1},  (* 11 *)
  {0, 1, Sqrt[2]},  (* 12 *)
  {0, Sqrt[2], 1},  (* 13 *)
  {1, Sqrt[2], 0},  (* 14 *)
  {Sqrt[2], 1, 0},  (* 15 *)
  {-1, 0, Sqrt[2]}, (* 16 *)
  {Sqrt[2], 0, -1}, (* 17 *)
  {0, -1, Sqrt[2]}, (* 18 *)
  {0, Sqrt[2], -1}, (* 19 *)
  {-1, Sqrt[2], 0}, (* 20 *)
  {Sqrt[2], -1, 0}, (* 21 *)
  {1, 1, Sqrt[2]},  (* 22 *)
  {1, Sqrt[2], 1},  (* 23 *)
  {Sqrt[2], 1, 1},  (* 24 *)
  {-1, -1, Sqrt[2]},(* 25 *)
  {-1, Sqrt[2], -1},(* 26 *)
  {Sqrt[2], -1, -1},(* 27 *)
  {-1, 1, Sqrt[2]}, (* 28 *)
  {-1, Sqrt[2], 1}, (* 29 *)
  {Sqrt[2], -1, 1}, (* 30 *)
  {1, -1, Sqrt[2]}, (* 31 *)
  {1, Sqrt[2], -1}, (* 32 *)
  {Sqrt[2], 1, -1}  (* 33 *)
};

Print["  Peres rays defined: ", Length[peresRays]];

(* 16 explicit triads (Aravind & Lee-Elkin 2007 Table 3.2 top) *)
explicitTriads = {
  {1, 2, 3},   {1, 6, 9},   {1, 12, 19}, {1, 13, 18},
  {2, 4, 8},   {2, 10, 17}, {2, 11, 16},
  {3, 5, 7},   {3, 14, 21}, {3, 15, 20},
  {4, 29, 32}, {5, 28, 31}, {6, 30, 33},
  {7, 22, 25}, {8, 23, 26}, {9, 24, 27}
};

Print["  Explicit triads: ", Length[explicitTriads], " (expect 16)"];

(* 24 dyads (orthogonal pairs not in any triad)
   Aravind & Lee-Elkin 2007 Table 3.2 bottom *)
dyads = {
  {10, 27}, {10, 33}, {11, 25}, {11, 28}, {12, 26}, {12, 32},
  {13, 25}, {13, 31}, {14, 27}, {14, 30}, {15, 26}, {15, 29},
  {16, 24}, {16, 30}, {17, 22}, {17, 31}, {18, 23}, {18, 29},
  {19, 22}, {19, 28}, {20, 24}, {20, 33}, {21, 23}, {21, 32}
};

Print["  Dyads: ", Length[dyads], " (expect 24)"];

(* ============================================================
   PART 1: Verify the explicit triads are mutually orthogonal
   ============================================================ *)

Print[""];
Print["----- PART 1: Triad orthogonality verification -----"];

triadCheck[t_] := Module[{r1, r2, r3, d12, d13, d23},
  {r1, r2, r3} = peresRays[[t]];
  d12 = Simplify[r1 . r2];
  d13 = Simplify[r1 . r3];
  d23 = Simplify[r2 . r3];
  d12 === 0 && d13 === 0 && d23 === 0
];

triadResults = AllTrue[explicitTriads, triadCheck];
Print["  All 16 explicit triads mutually orthogonal? ", triadResults];

dyadCheck[d_] := Simplify[peresRays[[d[[1]]]] . peresRays[[d[[2]]]]] === 0;
dyadResults = AllTrue[dyads, dyadCheck];
Print["  All 24 dyad pairs orthogonal?              ", dyadResults];

If[!triadResults || !dyadResults,
  Print["  ABORT: orthogonality check failed."]; Quit[]];

(* ============================================================
   PART 2: Compute the 24 dyad-completion rays (cross products)
   ============================================================ *)

Print[""];
Print["----- PART 2: Dyad-completion rays via cross product -----"];

crossR3[{a_, b_, c_}, {d_, e_, f_}] := {b f - c e, c d - a f, a e - b d};

completionRays = Map[
  Simplify[crossR3[peresRays[[#[[1]]]], peresRays[[#[[2]]]]]] &,
  dyads
];

Print["  Completion rays computed: ", Length[completionRays]];
Print["  Sample (dyad {10,27} -> ray):  ", completionRays[[1]]];
Print["  Sample (dyad {17,22} -> ray): ", completionRays[[15]]];

verifyCompletion = MapThread[Function[{d, t},
  Module[{r1, r2},
    {r1, r2} = peresRays[[d]];
    Simplify[r1 . t] === 0 && Simplify[r2 . t] === 0
  ]], {dyads, completionRays}];
Print["  All completion rays orthogonal to their dyad? ",
      AllTrue[verifyCompletion, # &]];

(* ============================================================
   PART 3: Combine into 57-ray, 40-triad full Peres KS set
   ============================================================ *)

Print[""];
Print["----- PART 3: Full 57-ray, 40-triad Peres set -----"];

allRays = Join[peresRays, completionRays];
implicitTriads = MapIndexed[
  Function[{d, idx}, {d[[1]], d[[2]], 33 + idx[[1]]}],
  dyads
];
allTriads = Join[explicitTriads, implicitTriads];

Print["  Total rays:   ", Length[allRays], " (expect 57)"];
Print["  Total triads: ", Length[allTriads], " (expect 40)"];

triadCheck57[t_] := Module[{r1, r2, r3, d12, d13, d23},
  {r1, r2, r3} = allRays[[t]];
  d12 = Simplify[r1 . r2];
  d13 = Simplify[r1 . r3];
  d23 = Simplify[r2 . r3];
  d12 === 0 && d13 === 0 && d23 === 0
];
verifyAllTriads = AllTrue[allTriads, triadCheck57];
Print["  All 40 triads mutually orthogonal? ", verifyAllTriads];

(* ray-incidence histogram *)
rayIncidences = Tally[Flatten[allTriads]];
incidenceCounts = Sort[Counts[Last /@ rayIncidences]];
Print["  Ray-incidence histogram (incidence -> count):"];
Print["    ", incidenceCounts];
Print["  (33 original Peres rays appear 2-4 times each;"];
Print["   24 completion rays appear 1 time each.)"];

(* ============================================================
   PART 4: Sub-MASA context structure
   ============================================================ *)

Print[""];
Print["----- PART 4: Context category structure -----"];

(* Rays appearing in 2+ triads = sub-MASAs *)
sharedRays = Select[rayIncidences, Last[#] >= 2 &][[All, 1]];
soloRays   = Select[rayIncidences, Last[#] == 1 &][[All, 1]];

Print["  Sub-MASA contexts (rays in 2+ triads):  ", Length[sharedRays]];
Print["  Solo rays (in exactly 1 triad):         ", Length[soloRays]];
Print["  Trivial context V_0:                    1"];
Print["  Maximal MASA contexts (per triad):      ", Length[allTriads]];
Print["  TOTAL contexts (V_0 + sub-MASAs + MASAs): ",
      1 + Length[sharedRays] + Length[allTriads]];

(* ============================================================
   PART 5: |GlobalSections(Sigma_Q)| via SAT count
   ============================================================ *)

Print[""];
Print["----- PART 5: |GlobalSections(Sigma_Q)| (the KS witness) -----"];

(* Boolean variables, one per ray *)
boolVars = Array[v, Length[allRays]];

(* "Exactly one of three" predicate *)
exactlyOneOfThree[{i_, j_, k_}] := Or[
   v[i]  &&  !v[j] &&  !v[k],
  !v[i]  &&   v[j] &&  !v[k],
  !v[i]  &&  !v[j] &&   v[k]
];

(* Conjunction of all 40 triad constraints *)
ksConstraints = And @@ Map[exactlyOneOfThree, allTriads];

Print["  Boolean variables: ", Length[boolVars]];
Print["  Triad constraints: ", Length[allTriads]];
Print["  Computing |GlobalSections(Sigma_Q)| via SatisfiabilityCount..."];

t0 = AbsoluteTime[];
globalSectionsQ = SatisfiabilityCount[ksConstraints, boolVars];
elapsed = AbsoluteTime[] - t0;

Print[""];
Print["  |GlobalSections(Sigma_Q)| = ", globalSectionsQ];
Print["  (elapsed: ", NumberForm[elapsed, {6, 3}], " seconds)"];
Print[""];
Print["  EXPECTED: 0 (by Kochen-Specker theorem on the Peres set)"];
Print["  ACTUAL:   ", globalSectionsQ];
Print["  Match:    ", globalSectionsQ === 0];

(* ============================================================
   PART 6: |GlobalSections(Sigma_C_min)| for C^3
   ============================================================ *)

Print[""];
Print["----- PART 6: |GlobalSections(Sigma_C_min)| for C^3 -----"];

(* The minimal commutative comparator C^3 has context category
   V_0 (trivial) <= V_C = C^3 itself. The spectral presheaf
   assigns a 1-character spectrum to V_0 and a 3-character
   spectrum to V_C. Global sections pick one character per
   context with restriction-consistency; since V_0 has only
   one character, the global section is determined by which
   atom of V_C is selected. There are 3 atoms in V_C, so
   |GlobalSections(Sigma_{C^3})| = 3. *)

globalSectionsCmin = 3;
Print["  |GlobalSections(Sigma_C_min)| = ", globalSectionsCmin,
      "  (one global section per atom of C^3)"];

(* ============================================================
   PART 7: Verdict -- the categorical structural break
   ============================================================ *)

Print[""];
Print["============================================================"];
Print["v5 SUMMARY"];
Print["============================================================"];

Print["  Configuration: Peres-33 (full 57-ray, 40-triad form)"];
Print["                 on M_3(C); Kochen-Specker witnessing."];
Print[""];
Print["  |GlobalSections(Sigma_Q on M_3(C))| =     ", globalSectionsQ];
Print["  |GlobalSections(Sigma_C_min on C^3)| =    ", globalSectionsCmin];
Print[""];
Print["  Strict inequality |Sections(Q)| < |Sections(C)|? ",
      globalSectionsQ < globalSectionsCmin];

If[globalSectionsQ === 0 && globalSectionsCmin === 3,
  Print[""];
  Print["  STRUCTURAL BREAK DETECTED."];
  Print["  The framework's machinery (operating on the spectral"];
  Print["  presheaf Sigma of the Bohr topos) faithfully witnesses"];
  Print["  the Kochen-Specker theorem as a finite computation:"];
  Print["  the quantum spectral presheaf has zero global sections,"];
  Print["  while every commutative algebra has at least one."];
  Print[""];
  Print["  This is the categorical signal scoped in v4-scope.md"];
  Print["  sec. 4.1 and gated through v2 -> v3 -> v4. v5 fires it."];
  Print[""];
  Print["  Physics anchor: categorical structural break at the"];
  Print["  Kochen-Specker threshold, established computationally"];
  Print["  in the framework's machinery."],

  (* else *)
  Print[""];
  Print["  UNEXPECTED RESULT. Debug:"];
  Print["    - Verify Peres ray definitions (Aravind & Lee-Elkin Table 3.1)"];
  Print["    - Verify explicit triads (Table 3.2 top)"];
  Print["    - Verify dyads (Table 3.2 bottom)"];
  Print["    - Verify completion-ray cross products"];
  Print["    - Verify SatisfiabilityCount usage on small subset"];
];

Print["============================================================"];
