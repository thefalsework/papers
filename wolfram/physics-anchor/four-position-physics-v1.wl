(* ::Package:: *)

(* ============================================================
   Route B: finite physics Heyting-slice exploration
   ------------------------------------------------------------
   Companion to:
     preprints/four-position-partition/physics-anchor/feasibility.md
     wolfram/cores/heunen-landsman-spitters-2009.wl

   Question this script answers:
     Is there a finite, computationally-tractable, physics-
     interpretable Heyting algebra on which the four-position
     partition is non-vacuously inhabited at some kernel?

   Method: build several candidate lattices, each with an
   explicit physics reading, and tabulate (i) Heyting structure,
   (ii) regular vs. non-regular elements, (iii) for each kernel
   choice, whether the four-cell partition is non-vacuously
   populated.

   The candidates are deliberately small (<= 21 elements) so
   that enumeration over kernels and elements is exhaustive.

   Candidates:
     A. 1-qubit Bohr-context lattice (single-qubit MASA poset)
     B. Boolean-triple subalgebra poset (a single 2-qubit MUB)
     C. Two disjoint Boolean triples (cross-MUB context)
     D. 2-qubit full MUB context lattice (5 triples partition
        the 15 non-trivial Paulis)
     E. Two-commuting-trichotomies lattice (3-chain x 3-chain)
     F. Causal diamond down-set lattice (4-event causet)

   Output: per-candidate non-vacuity report, plus a bottom-line
   conclusion identifying which candidate (if any) is the most
   promising lattice-level slice for a Route-A physics anchor.

   Execution: in a Wolfram (or Mathematica) kernel, evaluate
   this file with Get["..."]. All Print statements emit to
   stdout. No external dependencies.
   ============================================================ *)

ClearAll["Global`*"];


(* ============================================================
   GENERIC: down-set lattice + Heyting structure from a poset
   ============================================================ *)

(* A poset is given as a pair {Elements, OrderRel}, where
   OrderRel is a function (a, b) -> Boolean returning True iff
   a <= b in the poset. We assume reflexivity (a <= a always). *)

downClosedQ[S_, P_, leq_] := AllTrue[S, Function[a,
  AllTrue[P, Function[b, !leq[b, a] || MemberQ[S, b]]]]];

(* All down-closed subsets of P under leq. *)
allDownSets[P_, leq_] :=
  Select[Subsets[P], downClosedQ[#, P, leq] &];

(* Lattice operations on down-sets: meet = intersection, join = union.
   Heyting NOT(S) = largest down-set disjoint from S. *)
downSetMeet[A_, B_] := Intersection[A, B];
downSetJoin[A_, B_] := Union[A, B];

downSetCompl[S_, allDs_] := Module[{disj},
  disj = Select[allDs, Intersection[#, S] === {} &];
  If[disj === {}, {}, Last[SortBy[disj, Length]]]
];

(* For Heyting implication on a finite distributive lattice:
   A => B = largest C with A meet C subset of B. *)
downSetHImp[A_, B_, allDs_] := Module[{cands},
  cands = Select[allDs, SubsetQ[B, Intersection[A, #]] &];
  If[cands === {}, {}, Last[SortBy[cands, Length]]]
];


(* ============================================================
   GENERIC: four-cell classification on a down-set lattice
   ============================================================ *)

(* Given the full lattice (list of down-sets, with intersection /
   union / Heyting-NOT computed against it), classify each
   non-bottom element X relative to a kernel a:
     Infrastructure: X subset of a
     Refusal:        X subset of (NOT a)
     Exploitation:   X subset of (NOT (NOT a)) and X NOT subset of a
     Distribution:   X meet a non-empty AND X meet (NOT a) non-empty
   Returns a four-tuple of element lists. *)

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

reportCandidate[name_, P_, leq_, label_: None] := Module[
  {allDs, nonRegular, kernelReports, anyNonVacuous, summary},
  allDs = allDownSets[P, leq];
  Print["============================================================"];
  Print["CANDIDATE ", name];
  If[label =!= None, Print["  Physics reading: ", label]];
  Print["  Poset size = ", Length[P],
        "; down-set lattice size = ", Length[allDs]];
  Print["  Down-sets (sorted by size):"];
  Do[Print["    ", S], {S, SortBy[allDs, Length]}];
  Print[];
  (* Heyting structure: regular vs non-regular elements *)
  Print["  Heyting structure (NOT and double-NOT):"];
  Print["    ", StringPadRight["element", 32], StringPadRight["NOT(a)", 32],
        StringPadRight["NOTNOT(a)", 32], "regular?"];
  Do[
    Module[{aC, aCC, reg},
      aC = downSetCompl[S, allDs];
      aCC = downSetCompl[aC, allDs];
      reg = (S === aCC);
      Print["    ", StringPadRight[ToString[S], 32],
            StringPadRight[ToString[aC], 32],
            StringPadRight[ToString[aCC], 32], reg]
    ],
    {S, SortBy[allDs, Length]}
  ];
  Print[];
  nonRegular = Select[allDs, # =!= downSetCompl[downSetCompl[#, allDs], allDs] &];
  Print["  Non-regular elements (Exploitation-supporting kernels):"];
  Do[Print["    ", S], {S, nonRegular}];
  Print[];
  (* Per-kernel four-cell tabulation *)
  Print["  Per-kernel four-cell partition (excluding bottom kernel):"];
  kernelReports = {};
  Do[
    Module[{report, infraN, refN, explN, distN, allFour},
      report = fourCells[allDs, a];
      infraN = Length[report["Infrastructure"]];
      refN   = Length[report["Refusal"]];
      explN  = Length[report["Exploitation"]];
      distN  = Length[report["Distribution"]];
      allFour = (infraN > 0 && refN > 0 && explN > 0 && distN > 0);
      kernelReports = Append[kernelReports, <|
        "kernel" -> a, "infra" -> infraN, "ref" -> refN,
        "expl" -> explN, "dist" -> distN, "allFour" -> allFour|>];
      Print["    kernel a = ", a, "  (regular? = ", report["regular?"], ")"];
      Print["      NOT a   = ", report["aC"]];
      Print["      NOTNOT a = ", report["aCC"]];
      Print["      counts: Infra=", infraN, " Refusal=", refN,
            " Exploit=", explN, " Distrib=", distN];
      Print["      ALL FOUR CELLS NON-VACUOUS? = ", allFour];
    ],
    {a, Select[allDs, # =!= {} &]}
  ];
  anyNonVacuous = AnyTrue[kernelReports, #["allFour"] &];
  Print[];
  Print["  CANDIDATE ", name, " VERDICT:"];
  Print["    Has any non-vacuous kernel? = ", anyNonVacuous];
  If[anyNonVacuous,
    Print["    Non-vacuous kernels:"];
    Do[
      If[r["allFour"], Print["      a = ", r["kernel"]]],
      {r, kernelReports}
    ],
    Print["    No kernel admits a non-vacuous four-cell partition on this lattice."]
  ];
  Print[];
  anyNonVacuous
];


(* ============================================================
   CANDIDATE A: 1-qubit Bohr-context lattice
   ------------------------------------------------------------
   Physics reading: the Bohr poset C(M_2(C)) restricted to its
   discrete Pauli-MASA subalgebras. Objects:
     trivial (C * I), context_X, context_Y, context_Z,
   with trivial below each of the three Pauli contexts and the
   three Pauli contexts mutually incomparable. This is the
   single-qubit slice of the Doering-Isham / Heunen-Landsman-
   Spitters Bohrification construction (restricted to a finite
   subposet to keep it computable).
   ============================================================ *)

posetA = {"trivial", "ctxX", "ctxY", "ctxZ"};
leqA[a_, b_] := (a === b) || (a === "trivial");

anyA = reportCandidate["A: 1-qubit Bohr-context lattice", posetA, leqA,
  "Bohr-style context poset for M_2(C) restricted to {C.I, <X>, <Y>, <Z>}"];


(* ============================================================
   CANDIDATE B: Boolean-triple subalgebra poset
   ------------------------------------------------------------
   Physics reading: one MUB triple from the 2-qubit Pauli group
   (e.g. {ZI, IZ, ZZ}), with three atomic subalgebras and one
   maximal Boolean subalgebra containing them. This is a single
   stabilizer-state context, considered as a poset of its own
   subalgebras.
   ============================================================ *)

posetB = {"a1", "a2", "a3", "T"};
leqB[a_, b_] := (a === b) || (b === "T");

anyB = reportCandidate["B: Boolean-triple subalgebra poset", posetB, leqB,
  "One MUB triple on 2 qubits, e.g. <ZI, IZ, ZZ>: 3 atoms + 1 max Boolean subalgebra"];


(* ============================================================
   CANDIDATE C: Two disjoint Boolean triples (cross-MUB)
   ------------------------------------------------------------
   Physics reading: two MUB triples from the 2-qubit Pauli group
   sharing only the trivial subalgebra (e.g. {ZI, IZ, ZZ} and
   {XI, IX, XX}). 6 atomic subalgebras + 2 maximal Boolean
   subalgebras, all above a common bottom. Models "two
   incompatible Bohr-classical contexts."
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

anyC = reportCandidate["C: Two disjoint Boolean triples", posetC, leqC,
  "Two MUB triples on 2 qubits sharing only trivial subalgebra"];


(* ============================================================
   CANDIDATE D: 2-qubit full MUB context lattice
   ------------------------------------------------------------
   Physics reading: the discrete Bohr context poset for the full
   2-qubit Pauli algebra. 5 MUB triples partition the 15 non-
   trivial 2-qubit Paulis. Each triple generates one maximal
   Boolean subalgebra. Hasse diagram:
     bottom (trivial)
       below: 15 atomic Pauli subalgebras
         each below: exactly one of 5 maximal Boolean subalgebras
   Atomic subalgebras within one triple share their maximal
   subalgebra; atomic subalgebras from different triples are
   incomparable.
   ============================================================ *)

(* 5 triples each with 3 atoms; we label atoms by (triple, slot)
   and tops by triple. *)
triples = {1, 2, 3, 4, 5};
atomsD = Flatten[Table[{"a", t, s}, {t, triples}, {s, 1, 3}], 1];
topsD = Table[{"T", t}, {t, triples}];
posetD = Join[{"bot"}, atomsD, topsD];
leqD[a_, b_] := Which[
  a === b, True,
  a === "bot", True,
  Head[a] === List && a[[1]] === "a" && Head[b] === List && b[[1]] === "T"
    && a[[2]] === b[[2]], True,
  True, False
];

(* WARNING: this poset has 1 + 15 + 5 = 21 elements; the down-set
   lattice can be very large. We compute it and report size first,
   skipping the full per-kernel report if size > 1024 (so the
   script remains responsive). *)
Print["============================================================"];
Print["CANDIDATE D (preview): 2-qubit full MUB context lattice"];
Print["  Poset size = ", Length[posetD]];
allDsD = allDownSets[posetD, leqD];
Print["  Down-set lattice size = ", Length[allDsD]];
If[Length[allDsD] > 1024,
  Print["  SIZE GUARD: down-set lattice too large for full per-kernel"];
  Print["  enumeration in this round. Skipping full report; recording"];
  Print["  structural facts only (regularity census)."];
  Print[];
  nonRegD = Select[allDsD, # =!= downSetCompl[downSetCompl[#, allDsD], allDsD] &];
  Print["  Non-regular elements (count): ", Length[nonRegD]],
  anyD = reportCandidate["D: 2-qubit full MUB context lattice", posetD, leqD,
    "Bohr context poset for full 2-qubit Pauli algebra (5 MUB triples)"]
];
Print[];


(* ============================================================
   CANDIDATE E: Two-commuting-trichotomies lattice
   ------------------------------------------------------------
   Physics reading: two commuting observables A, B on a quantum
   system, each with 3 distinguishable refinement levels (e.g.
   coarse / medium / fine partitions of the spectrum). The
   lattice of joint refinement levels is the product of two
   3-chains.

   Structurally: this is isomorphic to the divisor lattice of
   p^2 * q^2 for distinct primes p, q. The music lattice (divisor
   lattice of 12 = 2^2 * 3) is the closely-related divisor
   lattice of p^2 * q. We use the symmetric 3x3 case here.

   This is a "physics-flavoured" but not specifically physics-
   theoretic lattice. It tests whether the four-position
   partition can be made non-vacuous on a product-of-chains
   structure that any two-commuting-observable system would
   naturally produce.
   ============================================================ *)

(* Poset: pairs (i, j) with i, j in {0, 1, 2}; (i1, j1) <= (i2, j2)
   iff i1 <= i2 and j1 <= j2 componentwise. *)
posetE = Flatten[Table[{i, j}, {i, 0, 2}, {j, 0, 2}], 1];
leqE[a_, b_] := (a[[1]] <= b[[1]]) && (a[[2]] <= b[[2]]);

anyE = reportCandidate["E: 3-chain x 3-chain (two commuting trichotomies)",
  posetE, leqE,
  "Two commuting observables, each with 3 refinement levels; product of two 3-chains"];


(* ============================================================
   CANDIDATE F: causal diamond down-set lattice
   ------------------------------------------------------------
   Physics reading: a small causal set (causet) representing
   a causal diamond. 4 events {a, b, c, d}; a and b are
   spacelike-separated initial events; c is in the future of
   both; d is in the future of c. So the order is:
     a <= c, b <= c, c <= d.
   The down-set lattice of this causet is the lattice of
   "causal pasts" / regions, which is a Heyting algebra in
   causal-set theory (Sorkin's programme).
   ============================================================ *)

posetF = {"a", "b", "c", "d"};
leqF[x_, y_] := Module[{},
  Which[
    x === y, True,
    x === "a" && MemberQ[{"c", "d"}, y], True,
    x === "b" && MemberQ[{"c", "d"}, y], True,
    x === "c" && y === "d", True,
    True, False
  ]
];

anyF = reportCandidate["F: causal diamond (4-event causet)", posetF, leqF,
  "4-event causet: a, b spacelike; c in future of both; d in future of c"];


(* ============================================================
   BOTTOM-LINE SUMMARY
   ============================================================ *)
Print["============================================================"];
Print["BOTTOM-LINE SUMMARY"];
Print["============================================================"];
Print[];
Print["Per-candidate non-vacuity verdict:"];
Print["  A. 1-qubit Bohr-context lattice                : ",
      If[anyA, "NON-VACUOUS", "DEGENERATE"]];
Print["  B. Boolean-triple subalgebra poset              : ",
      If[anyB, "NON-VACUOUS", "DEGENERATE"]];
Print["  C. Two disjoint Boolean triples                 : ",
      If[anyC, "NON-VACUOUS", "DEGENERATE"]];
Print["  D. 2-qubit full MUB context lattice             : ",
      If[Length[allDsD] > 1024, "SKIPPED (too large for full enum)", If[TrueQ[anyD], "NON-VACUOUS", "DEGENERATE"]]];
Print["  E. 3-chain x 3-chain (two commuting trichotomies): ",
      If[anyE, "NON-VACUOUS", "DEGENERATE"]];
Print["  F. Causal diamond (4-event causet)              : ",
      If[anyF, "NON-VACUOUS", "DEGENERATE"]];
Print[];
Print["Interpretation guide:"];
Print["  - A and B are the smallest physics-recognisable Bohr-style"];
Print["    context lattices. If both are DEGENERATE, that is a"];
Print["    structural finding: single-MASA-style physics contexts"];
Print["    over a common trivial bottom do not host a non-vacuous"];
Print["    four-cell partition, and the genuine physics anchor must"];
Print["    live in a richer construction (full Bohrification topos,"];
Print["    or a causal/process-theoretic substrate)."];
Print[];
Print["  - E is the closest physics-flavoured analog of the music"];
Print["    anchor's divisor-lattice slice. If E is NON-VACUOUS, the"];
Print["    framework's machinery transfers to product-of-chains"];
Print["    structures, which any two-commuting-observable system"];
Print["    naturally produces."];
Print[];
Print["  - F tests whether causal-set partial orders host the"];
Print["    partition; this is a separate physics route (Sorkin's"];
Print["    causet programme) from Bohrification."];
Print[];
Print["  - C and D probe whether enlarging the Bohr context poset"];
Print["    rescues non-vacuity, or whether the structural obstacle"];
Print["    is intrinsic to the 'common trivial bottom + atom"];
Print["    antichain + max contexts' shape."];
Print[];
Print["This script is intentionally a survey, not a commitment to"];
Print["any specific physics anchor. The Route-A feasibility document"];
Print["(preprints/four-position-partition/physics-anchor/feasibility.md)"];
Print["interprets these findings and identifies the most promising"];
Print["lattice for an eventual physics analog of the music Layer-L"];
Print["theorem."];
Print[];
Print["[End of physics-anchor Route-B exploration]"];
