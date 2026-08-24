(* ::Package:: *)

(* ============================================================
   Aperture Scaling (companion cell to aperture-prototype.wl)
   ------------------------------------------------------------
   Extends the aperture computation from two data points to a
   pattern, across four probe families:

   1. THE 2-POWER SEQUENCE Div(2^a * 3), a = 2..6 (Div12, Div24,
      Div48, Div96, Div192). These lattices are chain products
      C_{a+1} x C_2.
   2. THE FAMILY BREAK Div36 = 2^2 * 3^2 (chain product C_3 x C_3).
   3. THE LATENCY CONFIRMATION Div72 = 2^3 * 3^2 (C_4 x C_3):
      predicted latent {6, 12} before any run of this file.
   4. THE BOOLEAN CONTROL Div30 = 2 * 3 * 5 (square-free, so the
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
   | Div72   |     32 | {2,3,4}          | + latent 6:ap6, 12:ap4 |
   | Div30   |      8 | {} (Boolean)     | all empty            |

   THE PRODUCT LAW (conjecture, [O]):
     aperture(2^k in Div(2^a * 3)) = (2^k - 1) * (2^(a-k) - 1)
   Exact on all 15 (a,k) points - but these lattices are chain
   products C_{a+1} x C_2 and nuclei counts multiply over factors
   (8, 16, 32, 64, 128 = 2^(a+1); Div36's 16 = 4 x 4; Div30's
   8 = 2^3), so the 15 points are ONE structural fact observed at
   fifteen resolutions, not fifteen confirmations. The formula's
   value is that it looks provable (likely a short argument about
   nuclei on chain products); proving it is the named next step.

   LATENT ORDINARINESS - the headline. Element 6 of Div36 is NOT
   ordinary at full resolution (it is dense), yet aperture(6) = 2:
   two proper coarse-grainings open a four-fold that identity
   cannot see. Some distinctions exist only at a blur. This also
   removes the circularity worry about Div12 (where the aperture
   just recovered ambient ordinariness): on Div36 identity sees
   nothing and coarse observers see the four-fold, so the
   invariant provably detects something identity cannot.

   THE CLOSED FORM (derived 2026-08-11 from the componentwise
   nucleus factorization lemma; Node reference exact on all 164
   elements of 15 lattices including 109 zero-aperture
   cancellations - see aperture-closed-form.mjs):
     |Ap(k)| = prod N_c - prod D_c - prod R_c + prod DR_c
     N = 2^a, D = (2^e-1)2^(a-e)+1, R = 2^(a-e)+2^e-1, DR = 2^e
   per prime chain (height a, kernel exponent e). Pre-registered
   expectation for this cell's closed-form check: EXACT on every
   element of all eight lattices enumerated here.

   CHARACTERIZATION (stated before the sweep, confirmed 10/10):
   on a divisor lattice, an element is LATENT iff every prime
   exponent is strictly interior (0 < e_i < a_i for all i).
   [POSTSCRIPT 2026-08-24, pre-registered text above unchanged:
   this rule is valid ONLY for exactly-two-prime lattices, which
   is all this sweep contains besides square-free ones. It fails
   both ways elsewhere: Div8 elements 2,4 (all-interior, aperture
   0) and Div180 element 30 (5-exponent at chain top, aperture 4).
   Corrected rule: nonempty aperture iff some exponent strictly
   interior AND some other chain below its top; latent iff also
   no exponent zero. See latency-characterization-correction.mjs
   and paper Result 6.3. The checks below still pass as written
   because their lattices sit inside the old rule's valid domain.]
   Componentwise negation on chain products gives: ordinary iff
   some exponent is 0 and some is interior; dense iff all are
   > 0. Consequences, all confirmed by the Node sweep
   (2026-08-11): no latency anywhere in Div(2^a*3) (the C_2
   factor has no interior); latent {6} in Div36; {6,12} in
   Div72; {6,12,24} in Div144; {6,12,18,36} in Div216; none in
   square-free Div30/Div60. Latent aperture SIZES fit no obvious
   product form (72: 6,4; 144: 14,12,8; 216: 18,12,12,6) and are
   reported as data, not fitted.

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
apsAll = Association @ Map[# -> SReport[#] &, {12, 24, 48, 96, 192, 36, 72, 30}];

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

(* ---------- latency characterization check ---------- *)
(* Latent iff every prime exponent strictly interior. Pre-registered:
   Div36 latent {6} (ap 2); Div72 latent {6, 12} (ap 6, 4); no
   latency in the 2-power sequence. *)
Print[""];
Print["Latency characterization check (latent = nonempty aperture, ",
  "not ambient-ordinary; predicted = all prime exponents interior):"];
latencyCheck[n_Integer] := Module[
  {H = SMakeHeyting[n], aps = apsAll[n], ord, latent, predicted, fn},
  ord = Select[H["Elements"], SOrdinaryQ[H, #] &];
  latent = Select[H["Elements"], !MemberQ[ord, #] && aps[#] > 0 &];
  fn = FactorInteger[n];
  predicted = Select[H["Elements"],
    Function[d, AllTrue[fn,
      1 <= IntegerExponent[d, #[[1]]] <= #[[2]] - 1 &]]];
  Print["  Div", n, ": latent ", latent, "  predicted ", predicted,
    "  -> ", If[latent === predicted, "CONFIRMED", "FAILED"]];
];
Scan[latencyCheck, {12, 24, 48, 96, 192, 36, 72, 30}];

(* ---------- closed-form check (Theorem 5.1 of the aperture note) ----------
   |Ap(k)| = prod N_c - prod D_c - prod R_c + prod DR_c over prime chains,
   N = 2^a, D = (2^e-1)2^(a-e)+1, R = 2^(a-e)+2^e-1, DR = 2^e.
   Derived from the componentwise nucleus factorization lemma; Node
   reference verified it on all 164 elements of 15 lattices (2026-08-11).
   This check compares the formula against the enumerated apertures for
   EVERY element of the eight lattices above - second implementation. *)
Print[""];
Print["Closed-form check: |Ap(k)| = N - D - R + DR (per-prime-chain products):"];
SClosedForm[n_Integer, k_Integer] := Module[{fn = FactorInteger[n], e},
  Times @@ (2^#[[2]] & /@ fn) -
  Times @@ ((e = IntegerExponent[k, #[[1]]];
    (2^e - 1) 2^(#[[2]] - e) + 1) & /@ fn) -
  Times @@ ((e = IntegerExponent[k, #[[1]]];
    2^(#[[2]] - e) + 2^e - 1) & /@ fn) +
  Times @@ (2^IntegerExponent[k, #[[1]]] & /@ fn)
];
closedFormResults = Map[
  Function[n, Module[{H = SMakeHeyting[n], aps = apsAll[n], bad},
    bad = Select[H["Elements"], aps[#] =!= SClosedForm[n, #] &];
    {n, Length[H["Elements"]], Count[H["Elements"], e_ /; aps[e] === 0],
     If[bad === {}, "EXACT", Row[{"FAILURES: ", bad}]]}]],
  {12, 24, 48, 96, 192, 36, 72, 30}];
Print[Grid[
  Prepend[closedFormResults, Style[#, Bold] & /@
    {"Div n", "elements", "zero-aperture", "closed form"}],
  Frame -> All, Alignment -> Left, BaseStyle -> "Text",
  Background -> {None, {LightGray, {None}}}]];
Print["closed form exact on all elements of all lattices: ",
  AllTrue[closedFormResults, #[[4]] === "EXACT" &]];
