(* ::Package:: *)

(* ============================================================
   Aperture Prototype (email artifact 3, August 2026)
   ------------------------------------------------------------
   THE INVARIANT. A nucleus j on a Heyting algebra H is a
   coarse-graining operator: inflationary, idempotent, and
   binary-meet-preserving (the subobject trace of a Lawvere-
   Tierney topology; equivalently a sheafification). Its fix-set
   L_j = { x : j x = x } is the world as seen by the observer j,
   with bottom_j = j(bot) and Heyting implication inherited from
   H. An element k is ORDINARY in a world (Citkin) when it is
   neither regular (neg neg k = k) nor dense (neg k = bot) -
   and by the kernel-checked bridge
   (lean/FalseWorkPapers/Positions/OrdinaryKernel.lean,
   allFourCellsInhabited_iff) the four-position partition around
   a kernel opens exactly when the kernel is ordinary.

   APERTURE(k) = the set of nuclei j on H such that j(k) is
   ordinary in L_j (with neg_j x = x => j(bot) computed in H;
   the result lands in L_j). In words: which observers see the
   kernel's four-fold open. Finite and enumerable on finite H.

   NOTE ON THE LEAN FILE'S CLAIM. DivisorLattice12Nucleus.lean
   proves tritoneNucleus(bot) is non-regular IN THE AMBIENT
   algebra. The aperture asks a different question: ordinariness
   INSIDE the observer's world L_j, where the tritone has become
   that world's own bottom - and a bottom is regular. Both
   statements are true; the aperture is the observer-relative
   one, which is the reading the roadmap and pathway specify
   ("its fixed-point algebra is the world at that resolution").

   ------------------------------------------------------------
   ALGORITHM (chosen to differ from the reference implementation)
   ------------------------------------------------------------
   The Node.js reference enumerates all |H|^|H| functions and
   filters by the three nucleus laws. This file instead
   enumerates meet-closed subsets containing top (every nucleus
   fix-set is one: top <= j top; j(a meet b) = j a meet j b),
   induces j(a) = least member of the subset above a, and keeps
   exactly the candidates satisfying the three laws. Sound and
   exhaustive without trusting any deeper characterization
   theorem. Two independent algorithms, one answer required.

   ------------------------------------------------------------
   PRE-REGISTERED EXPECTATIONS (Node reference, fixed before
   this file was run; see wolfram/README.md)
   ------------------------------------------------------------
   Div12  : 8 nuclei; aperture(2) = 1 = {identity}; all other
            apertures empty. The tritone kernel's four-fold is
            visible to the full-resolution observer alone.
   Div6   : 4 nuclei; every aperture empty (Boolean world).
   Chain4 : 8 nuclei; every aperture empty (linear world).
   Div24  : 16 nuclei; aperture(2) = 3 and aperture(4) = 3,
            all others empty. The 3 include genuinely coarse
            observers: fix-set {1,3,4,8,12,24} maps the kernel
            2 |-> 4 and it STAYS ordinary in the coarser world;
            fix-set {2,4,6,8,12,24} coarsens the bottom itself
            (j bot = 2) and 4 stays ordinary.
   Lean anchors (machine-checked ground truth, [K]):
     - tritoneNucleus {1->2,2->2,3->6,4->4,6->6,12->12} MUST
       appear in the Div12 enumeration (it is a nucleus:
       tritoneNucleus_isNucleus);
     - tritoneClosure {1->2,2->2,3->12,4->12,6->12,12->12} MUST
       NOT appear (tritoneClosure_not_nucleus);
     - neither tritoneNucleus, nor double negation (the fully
       Boolean observer), nor const-top (the blind observer) is
       in aperture(2) on Div12.

   Author:    Chris Brink (independent), 2026
   Reference: https://github.com/thefalsework/papers
   ============================================================ *)


ClearAll[MakeFiniteHeyting, EnumerateNuclei, NucleusFixSet,
  InApertureQ, Aperture, ApertureReport, NucleiInclusionGraph];


(* ---------- finite Heyting algebra from (elements, leq) ---------- *)

MakeFiniteHeyting[elems_List, leq_] := Module[
  {meet, imp, bot, top, lower},
  lower[a_, b_] := Select[elems, leq[#, a] && leq[#, b] &];
  meet[a_, b_] := With[{lb = lower[a, b]},
    SelectFirst[lb, Function[m, AllTrue[lb, leq[#, m] &]]]];
  imp[a_, b_] := With[
    {cs = Select[elems, leq[meet[a, #], b] &]},
    SelectFirst[cs, Function[m, AllTrue[cs, leq[#, m] &]]]];
  bot = SelectFirst[elems, Function[x, AllTrue[elems, leq[x, #] &]]];
  top = SelectFirst[elems, Function[x, AllTrue[elems, leq[#, x] &]]];
  <|"Elements" -> elems, "Leq" -> leq, "Meet" -> meet,
    "Imp" -> imp, "Bot" -> bot, "Top" -> top|>
];


(* ---------- nucleus enumeration via meet-closed families ---------- *)

EnumerateNuclei[H_Association] := Module[
  {elems, leq, meet, candidates, induce, lawsQ},
  elems = H["Elements"]; leq = H["Leq"]; meet = H["Meet"];

  candidates = Select[Subsets[elems],
    Function[F, MemberQ[F, H["Top"]] &&
      AllTrue[Tuples[F, 2], MemberQ[F, meet[#[[1]], #[[2]]]] &]]];

  induce[F_] := Association @ Map[
    Function[a, With[{ups = Select[F, leq[a, #] &]},
      a -> SelectFirst[ups, Function[m, AllTrue[ups, leq[m, #] &]]]]],
    elems];

  lawsQ[j_] :=
    AllTrue[elems, leq[#, j[#]] && j[j[#]] === j[#] &] &&
    AllTrue[Tuples[elems, 2],
      j[meet[#[[1]], #[[2]]]] === meet[j[#[[1]]], j[#[[2]]]] &];

  Select[induce /@ candidates, lawsQ]
];

NucleusFixSet[H_Association, j_Association] :=
  Select[H["Elements"], j[#] === # &];


(* ---------- the aperture ---------- *)

InApertureQ[H_Association, j_Association, k_] := Module[
  {botJ = j[H["Bot"]], kJ = j[k], negJ, n1},
  negJ[x_] := H["Imp"][x, botJ];
  n1 = negJ[kJ];
  n1 =!= botJ && negJ[n1] =!= kJ    (* non-dense and non-regular *)
];

Aperture[H_Association, nucs_List, k_] :=
  Select[nucs, InApertureQ[H, #, k] &];


(* ---------- reporting ---------- *)

ApertureReport[name_String, H_Association, kernel_] := Module[
  {nucs = EnumerateNuclei[H], rows},
  Print[""];
  Print["=== ", name, " ==="];
  Print["elements: ", H["Elements"], "   nuclei found: ", Length[nucs]];
  rows = Map[
    Function[k, With[{ap = Aperture[H, nucs, k]},
      {k, Length[ap],
       If[Length[ap] > 0,
         StringRiffle[
           ("{" <> StringRiffle[ToString /@ NucleusFixSet[H, #], ","] <>
              "}  j(" <> ToString[k] <> ")=" <> ToString[#[k]] <>
              "  j(bot)=" <> ToString[#[H["Bot"]]]) & /@ ap, " ; "],
         "-"],
       If[k === kernel, "<-- kernel", ""]}]],
    H["Elements"]];
  Print[Grid[
    Prepend[rows, Style[#, Bold] & /@
      {"Element", "Aperture size", "Members (fix-set, image, bottom)", ""}],
    Frame -> All, Alignment -> Left, BaseStyle -> "Text",
    Background -> {None, {LightGray, {None}}}]];
  <|"Nuclei" -> nucs, "H" -> H|>
];


(* ---------- the four algebras ---------- *)

divLeq = Function[{a, b}, Divisible[b, a]];

div12  = MakeFiniteHeyting[{1, 2, 3, 4, 6, 12}, divLeq];
div6   = MakeFiniteHeyting[{1, 2, 3, 6}, divLeq];
chain4 = MakeFiniteHeyting[{0, 1, 2, 3}, LessEqual];
div24  = MakeFiniteHeyting[{1, 2, 3, 4, 6, 8, 12, 24}, divLeq];

r12 = ApertureReport["Div12 (tritone kernel = 2)", div12, 2];
r6  = ApertureReport["Div6 (Boolean 2x2 contrast)", div6, None];
rC  = ApertureReport["4-chain (linear contrast)", chain4, None];
r24 = ApertureReport["Div24 (robustness probe; ordinary: 2 and 4)",
        div24, 2];


(* ---------- Lean anchor checks ---------- *)

sameMapQ[j_Association, spec_Association] :=
  AllTrue[Keys[spec], j[#] === spec[#] &];

tritoneNucleusMap = <|1 -> 2, 2 -> 2, 3 -> 6, 4 -> 4, 6 -> 6, 12 -> 12|>;
tritoneClosureMap = <|1 -> 2, 2 -> 2, 3 -> 12, 4 -> 12, 6 -> 12, 12 -> 12|>;
identityMap  = <|1 -> 1, 2 -> 2, 3 -> 3, 4 -> 4, 6 -> 6, 12 -> 12|>;
dblNegMap    = Association @ Map[
  # -> div12["Imp"][div12["Imp"][#, 1], 1] &, div12["Elements"]];
constTopMap  = <|1 -> 12, 2 -> 12, 3 -> 12, 4 -> 12, 6 -> 12, 12 -> 12|>;

ap2 = Aperture[div12, r12["Nuclei"], 2];

anchor[label_String, got_, expected_] :=
  Print["  ", If[got === expected, "PASS", "FAIL"], "  ", label,
    "   (got ", got, ", expected ", expected, ")"];

Print[""];
Print["Lean anchors (DivisorLattice12Nucleus.lean, machine-checked):"];
anchor["tritoneNucleus enumerated as a nucleus",
  AnyTrue[r12["Nuclei"], sameMapQ[#, tritoneNucleusMap] &], True];
anchor["tritoneClosure rejected (not a nucleus)",
  AnyTrue[r12["Nuclei"], sameMapQ[#, tritoneClosureMap] &], False];
anchor["identity in aperture(2)",
  AnyTrue[ap2, sameMapQ[#, identityMap] &], True];
anchor["tritoneNucleus NOT in aperture(2) (kernel becomes its world's bottom)",
  AnyTrue[ap2, sameMapQ[#, tritoneNucleusMap] &], False];
anchor["double negation NOT in aperture(2) (Boolean observer sees no four-fold)",
  AnyTrue[ap2, sameMapQ[#, dblNegMap] &], False];
anchor["const-top NOT in aperture(2) (blind observer)",
  AnyTrue[ap2, sameMapQ[#, constTopMap] &], False];
Print["  double-negation nucleus map on Div12: ", Normal[dblNegMap]];


(* ---------- the figure ---------- *)
(* Each algebra's nuclei ordered by fix-set inclusion (finer observer
   below, coarser above); kernel-aperture members highlighted. Div12
   shows maximal fragility (identity alone); Div24 shows a graded
   aperture with genuinely coarse members. *)

NucleiInclusionGraph[result_Association, kernel_, title_String] := Module[
  {H = result["H"], nucs = result["Nuclei"], fs, vlabels, edges, inAp},
  fs = NucleusFixSet[H, #] & /@ nucs;
  vlabels = ("{" <> StringRiffle[ToString /@ #, ","] <> "}") & /@ fs;
  (* covering relation of reverse inclusion of fix-sets:
     finer observer (larger fix-set) -> coarser (smaller) *)
  edges = Flatten @ Table[
    If[i =!= k && SubsetQ[fs[[i]], fs[[k]]] &&
       !AnyTrue[Range[Length[fs]],
         Function[m, m =!= i && m =!= k &&
           SubsetQ[fs[[i]], fs[[m]]] && SubsetQ[fs[[m]], fs[[k]]]]],
      vlabels[[i]] -> vlabels[[k]], Nothing],
    {i, Length[fs]}, {k, Length[fs]}];
  inAp = InApertureQ[H, #, kernel] & /@ nucs;
  Graph[vlabels, edges,
    VertexLabels -> "Name",
    VertexSize -> 0.4,
    VertexStyle -> MapThread[
      #1 -> If[#2, RGBColor[0.85, 0.33, 0.1], LightGray] &,
      {vlabels, inAp}],
    GraphLayout -> "LayeredDigraphEmbedding",
    PlotLabel -> title, ImageSize -> 420]
];

apertureFigure = GraphicsRow[{
  NucleiInclusionGraph[r12, 2,
    "Div12: nuclei by fix-set inclusion\naperture(2) highlighted (identity only)"],
  NucleiInclusionGraph[r24, 2,
    "Div24: nuclei by fix-set inclusion\naperture(2) highlighted (3 observers)"]},
  ImageSize -> 900];

Print[apertureFigure];

Print[""];
Print["Reading: the aperture makes 'which observers see the four-fold ",
  "open' a computed set, not a metaphor. On Div12 - the minimal ",
  "kernel-bearing algebra, forced into the subobject lattice by any ",
  "ordinary kernel (ordinary_kernel_div12_embedding) - the answer is ",
  "maximally fragile: identity alone. On Div24 the invariant grades: ",
  "three observers, two of them genuinely coarse. Boolean and linear ",
  "worlds have empty apertures everywhere: no observer, at any ",
  "resolution, ever sees a four-fold there."];
