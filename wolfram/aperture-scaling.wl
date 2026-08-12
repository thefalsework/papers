(* ::Package:: *)

(* ============================================================
   Aperture Scaling (companion cell to aperture-prototype.wl)
   ------------------------------------------------------------
   Extends the aperture computation from two data points to a
   pattern, across three probe families:

   1. THE 2-POWER SEQUENCE Div(2^a * 3), a = 2..6 (Div12, Div24,
      Div48, Div96, Div192). These lattices are chain products
      C_{a+1} x C_2.
   2. THE FAMILY BREAK Div36 = 2^2 * 3^2 (chain product C_3 x C_3).
   3. THE BOOLEAN CONTROL Div30 = 2 * 3 * 5 (square-free, so the
      divisor lattice is the Boolean cube C_2^3).

   Definitions identical to aperture-prototype.wl (nucleus =
   inflationary + idempotent + meet-preserving; aperture(k) = the
   set of nuclei j under which j(k) is ordinary - neither regular
   nor dense - inside the observer world Fix(j) with bottom j(bot)
   and inherited implication). Enumeration via meet-closed families
   containing top, induced operator checked against the three
   nucleus laws directly.

   ------------------------------------------------------------
   PRE-REGISTERED EXPECTATIONS (Node reference, 2026-08-11, fixed
   before this file was run; see wolfram/README.md)
   ------------------------------------------------------------
   | algebra | nuclei | ambient ordinary | apertures            |
   |---------|--------|------------------|----------------------|
   | Div12   |      8 | {2}              | 1                    |
   | Div24   |     16 | {2,4}            | 3, 3                 |
   | Div48   |     32 | {2,4,8}          | 7, 9, 7              |
   | Div96   |     64 | {2,4,8,16}       | 15, 21, 21, 15       |
   | Div192  |    128 | {2,4,8,16,32}    | 31, 45, 49, 45, 31   |
   | Div36   |     16 | {2,3}            | 3, 3, and 2 for 6(!) |
   | Div30   |      8 | {} (Boolean)     | all empty            |

   THE PRODUCT LAW (conjecture, [O]; all 15 sequence data points):
     aperture(2^k in Div(2^a * 3)) = (2^k - 1) * (2^(a-k) - 1)
   The aperture factors as (blur available below the kernel) x
   (blur available above it). Plausible mechanism: these lattices
   are chain products and nuclei counts multiply over the factors
   (8, 16, 32, 64, 128 = 2^(a+1); Div36's 16 = 4 x 4; Div30's
   8 = 2^3).

   LATENT ORDINARINESS (Div36): element 6 is NOT ordinary at full
   resolution, yet aperture(6) = 2 - two proper coarse-grainings
   open a four-fold that identity cannot see. The aperture is not
   a restriction of ambient ordinariness; some distinctions exist
   only at a blur.

   Author:    Chris Brink (independent), 2026
   Reference: https://github.com/thefalsework/papers
   ============================================================ *)


ClearAll[SMakeHeyting, SNuclei, SInApertureQ, SOrdinaryQ, SReport];


SMakeHeyting[n_Integer] := Module[{elems, leq, meet, imp},
  elems = Divisors[n];
  leq = Function[{a, b}, Divisible[b, a]];
  meet = GCD;
  imp = Function[{a, b}, Max[Select[elems, Divisible[b, GCD[a, #]] &]]];
  <|"N" -> n, "Elements" -> elems, "Leq" -> leq, "Meet" -> meet,
    "Imp" -> imp, "Bot" -> 1, "Top" -> n|>
];


SNuclei[H_Association] := Module[
  {elems = H["Elements"], meet = H["Meet"], leq = H["Leq"],
   candidates, induce, lawsQ},
  candidates = Select[Subsets[elems],
    Function[F, MemberQ[F, H["Top"]] &&
      AllTrue[Tuples[F, 2], MemberQ[F, meet[#[[1]], #[[2]]]] &]]];
  induce[F_] := Association @ Map[
    Function[a, a -> Min[Select[F, leq[a, #] &]]], elems];
  lawsQ[j_] :=
    AllTrue[elems, leq[#, j[#]] && j[j[#]] === j[#] &] &&
    AllTrue[Tuples[elems, 2],
      j[meet[#[[1]], #[[2]]]] === meet[j[#[[1]]], j[#[[2]]]] &];
  Select[induce /@ candidates, lawsQ]
];


SInApertureQ[H_Association, j_Association, k_Integer] := Module[
  {botJ = j[H["Bot"]], kJ = j[k], negJ, n1},
  negJ[x_] := H["Imp"][x, botJ];
  n1 = negJ[kJ];
  n1 =!= botJ && negJ[n1] =!= kJ
];

SOrdinaryQ[H_Association, k_Integer] := Module[{neg},
  neg[x_] := H["Imp"][x, H["Bot"]];
  neg[k] =!= H["Bot"] && neg[neg[k]] =!= k
];


SReport[n_Integer] := Module[{H = SMakeHeyting[n], nucs, ord, aps},
  nucs = SNuclei[H];
  ord = Select[H["Elements"], SOrdinaryQ[H, #] &];
  aps = Association @ Map[
    # -> Count[nucs, j_ /; SInApertureQ[H, j, #]] &, H["Elements"]];
  Print["Div", n, ": ", Length[H["Elements"]], " elements, ",
    Length[nucs], " nuclei, ambient ordinary ", ord];
  Scan[If[aps[#] > 0 || MemberQ[ord, #],
    Print["   aperture(", #, ") = ", aps[#],
      If[!MemberQ[ord, #] && aps[#] > 0,
        "   <-- LATENT: not ordinary at full resolution", ""]]] &,
    H["Elements"]];
  aps
];

Print["Aperture scaling run (expectations pre-registered in header):"];
Print[""];
apsAll = Association @ Map[# -> SReport[#] &, {12, 24, 48, 96, 192, 36, 30}];

(* ---------- product-law check over the 2-power sequence ---------- *)
Print[""];
Print["Product-law check: aperture(2^k in Div(2^a*3)) = (2^k-1)(2^(a-k)-1)"];
productLawResults = Flatten[Map[
  Function[a, Map[
    Function[k, With[
      {measured = apsAll[2^a * 3][2^k],
       predicted = (2^k - 1) (2^(a - k) - 1)},
      {2^a * 3, 2^k, measured, predicted, measured === predicted}]],
    Range[1, a - 1]]],
  Range[2, 6]], 1];
Print[Grid[
  Prepend[productLawResults, Style[#, Bold] & /@
    {"Div n", "kernel", "measured", "predicted", "match"}],
  Frame -> All, Alignment -> Left, BaseStyle -> "Text",
  Background -> {None, {LightGray, {None}}}]];
Print["all points match: ",
  AllTrue[productLawResults, #[[5]] === True &]];
