(* Study 10 — independent Wolfram Language implementation (v1.1 §9).
   Written against PREREGISTRATION-v1.1.md and seeds.json only, without
   reference to the Node code. Verifies, per the discipline: the Div12/Div36
   anchors, then the per-kernel aperture counts of the five PRIMARY cones
   (A glider, B block, C blinker, D lwss, E soup-20260825001) at their
   exhaustive-tier depths as reported by the Node census. Every per-kernel
   |Ap| printed here must equal the Node reference exactly; any mismatch
   stops the study.
   Single self-contained cell; paste into Wolfram Cloud and evaluate. *)

(* ---- PRNG: mulberry32, bit-exact with the pinned Node generator ---- *)
mulberry[seed_Integer] := Module[{a = Mod[seed, 2^32]},
  Function[Module[{t},
    a = Mod[a + 16^^6d2b79f5, 2^32];
    t = Mod[BitXor[a, BitShiftRight[a, 15]]*BitOr[a, 1], 2^32];
    t = Mod[BitXor[Mod[t + Mod[BitXor[t, BitShiftRight[t, 7]]*BitOr[t, 61], 2^32], 2^32], t], 2^32];
    N[BitXor[t, BitShiftRight[t, 14]]/2^32]]]];

(* ---- Life on a bounded grid, dead boundary ---- *)
kern = {{1, 1, 1}, {1, 0, 1}, {1, 1, 1}};
lifeVal[s_, k_] := If[s == 1, If[k == 2 || k == 3, 1, 0], If[k == 3, 1, 0]];
step[g_] := MapThread[lifeVal, {g, ListConvolve[kern, g, {2, 2}, 0]}, 2];
run[g0_, T_] := NestList[step, g0, T];

(* ---- seeds (transcribed from seeds.json; 1-indexed placement) ---- *)
H = 40; W = 40; T = 8;
place[cells_] := Module[{g = ConstantArray[0, {H, W}], mr, mc, or, oc},
  mr = Max[cells[[All, 1]]]; mc = Max[cells[[All, 2]]];
  or = Floor[(H - mr - 1)/2]; oc = Floor[(W - mc - 1)/2];
  Do[g[[c[[1]] + or + 1, c[[2]] + oc + 1]] = 1, {c, cells}]; g];
soup[seed_] := Module[{g = ConstantArray[0, {H, W}], rng = mulberry[seed], or, oc},
  or = Floor[(H - 12)/2]; oc = Floor[(W - 12)/2];
  Do[If[rng[] < 0.30, g[[r + or, c + oc]] = 1], {r, 1, 12}, {c, 1, 12}]; g];
seeds = <|
  "A/glider" -> place[{{0,1},{1,2},{2,0},{2,1},{2,2}}],
  "B/block" -> place[{{0,0},{0,1},{1,0},{1,1}}],
  "C/blinker" -> place[{{0,0},{0,1},{0,2}}],
  "D/lwss" -> place[{{0,1},{0,4},{1,0},{2,0},{2,4},{3,0},{3,1},{3,2},{3,3}}],
  "E/soup-20260825001" -> soup[20260825001]|>;

(* ---- counterfactual parents of update (r,c,t), 1-indexed grids ---- *)
nbrCount[g_, r_, c_] := Sum[If[{dr, dc} != {0, 0} && 1 <= r + dr <= H && 1 <= c + dc <= W,
    g[[r + dr, c + dc]], 0], {dr, -1, 1}, {dc, -1, 1}];
cfParents[hist_, r_, c_, t_] := Module[{g = hist[[t]], s, k, v, out = {}},
  (* hist[[t]] is the grid at time t-1: hist = {g0, g1, ..., gT}, 1-indexed *)
  s = g[[r, c]]; k = nbrCount[g, r, c]; v = lifeVal[s, k];
  Do[Module[{rr = r + dr, cc = c + dc, v2},
     If[1 <= rr <= H && 1 <= cc <= W,
      v2 = If[dr == 0 && dc == 0, lifeVal[1 - s, k],
        lifeVal[s, k + If[g[[rr, cc]] == 1, -1, 1]]];
      If[v2 != v, AppendTo[out, {rr, cc}]]]],
    {dr, -1, 1}, {dc, -1, 1}];
  out];

(* ---- past cone, poset, aperture ---- *)
cone[hist_, {fr_, fc_, ft_}, depth_] := Module[
  {nodes = <|{fr, fc, ft} -> True|>, parents = <||>, frontier = {{fr, fc, ft}}, next},
  Do[next = {};
    Do[Module[{r = f[[1]], c = f[[2]], t = f[[3]], ps},
      If[t - 1 < 1, parents[f] = {},
       ps = ({#[[1]], #[[2]], t - 1}) & /@ cfParents[hist, r, c, t];
       parents[f] = ps;
       Do[If[! KeyExistsQ[nodes, p], nodes[p] = True; AppendTo[next, p]], {p, ps}]]],
     {f, frontier}];
    frontier = next, {depth}];
  Do[parents[f] = {}, {f, frontier}];
  {Keys[nodes], parents}];

poset[{ns_, parents_}] := Module[{list, idx, down},
  list = SortBy[ns, {#[[3]] &, #[[1]] &, #[[2]] &}];
  idx = AssociationThread[list -> Range[Length[list]]];
  down = ConstantArray[0, Length[list]];
  Do[down[[idx[f]]] = BitOr @@ Prepend[down[[idx /@ parents[f]]], 2^(idx[f] - 1)],
   {f, list}];
  {Length[list], down, list}];

apCount = Compile[{{downs, _Integer, 1}, {bmask, _Integer}, {n, _Integer}},
   Module[{count = 0, Bs, notB, nnB, ok},
    Do[Bs = BitAnd[bmask, S]; notB = 0;
     Do[If[BitAnd[S, 2^(p - 1)] > 0 && BitAnd[downs[[p]], Bs] == 0,
        notB = BitOr[notB, 2^(p - 1)]], {p, n}];
     If[notB > 0,
      nnB = 0;
      Do[If[BitAnd[S, 2^(p - 1)] > 0 && BitAnd[downs[[p]], notB] == 0,
         nnB = BitOr[nnB, 2^(p - 1)]], {p, n}];
      If[nnB != Bs, count++]],
     {S, 0, 2^n - 1}];
    count], CompilationTarget -> "WVM"];

verdict[downs_, n_, S_, B_] := Module[{Bs = BitAnd[B, S], notB = 0, nnB = 0},
  Do[If[BitAnd[S, 2^(p - 1)] > 0 && BitAnd[downs[[p]], Bs] == 0,
     notB = BitOr[notB, 2^(p - 1)]], {p, n}];
  If[notB == 0, "dense",
   Do[If[BitAnd[S, 2^(p - 1)] > 0 && BitAnd[downs[[p]], notB] == 0,
      nnB = BitOr[nnB, 2^(p - 1)]], {p, n}];
   If[nnB == BitAnd[B, S], "regular", "ordinary"]]];

(* ---- anchors: Div12 = Down(C2+C1), Div36 = Down(C2+C2) ---- *)
chainUnion[lens_] := Module[{down = {}, off = 0},
  Do[Do[AppendTo[down, Total[2^(off + Range[i] - 1)]], {i, 1, a}]; off += a, {a, lens}];
  {Length[down], down}];
Print["=== anchors ==="];
Module[{n, down}, {n, down} = chainUnion[{2, 1}];
 Print["Div12 Ap(2) = ", apCount[down, down[[1]], n], "  (must be 1)"]];
Module[{n, down}, {n, down} = chainUnion[{2, 2}];
 Print["Div36 Ap(6) = ", apCount[down, BitOr[down[[1]], down[[3]]], n], "  (must be 2)"]];

(* ---- primary cones ---- *)
(* Focus rule (v1.1 §3): among live cells at t=T, lowest row then lowest
   column. Depths: use the exhaustive-tier depth from the Node census
   (results/census.json); set below after the census is committed. *)
depths = <|"A/glider" -> 1, "B/block" -> 1, "C/blinker" -> 1,
   "D/lwss" -> 1, "E/soup-20260825001" -> 2|>; (* filled from results/census.json, 2026-08-25 *)

Do[Module[{hist, gT, pos, focus, cn, ps, n, down, list, d},
   d = depths[k];
   If[d === Null, Print[k, ": depth not set — fill from results/census.json"]; Continue[]];
   hist = run[seeds[k], T];
   gT = hist[[T + 1]];
   pos = FirstPosition[gT, 1];
   If[MissingQ[pos], Print[k, ": UNDEFINED (no live cells at T)"]; Continue[]];
   focus = {pos[[1]], pos[[2]], T};
   cn = cone[hist, focus, d];
   {n, down, list} = poset[cn];
   Print[k, "  n=", n, " d=", d];
   Do[Module[{ap = apCount[down, down[[x]], n], idv = verdict[down, n, 2^n - 1, down[[x]]]},
     Print["  kernel ", x - 1, " node(r,c,t)=", list[[x]] - {1, 1, 0}, "  |Ap|=", ap,
      "  @id=", idv, If[idv =!= "ordinary" && ap > 0, "  LATENT", ""]]],
    {x, n}]],
  {k, Keys[seeds]}];

(* ---- v1.3 exact-tier still lifes (added 2026-08-26, after the Node v1.3
   run; cells transcribed from seeds.json / seeds-v13.json, depth = 2 per
   PREREGISTRATION-v1.3.md §2). These are the cones the v1.3 verdict rests
   on; every per-kernel |Ap| must match wl/EXPECTED.md exactly. Block
   (n = 23) is omitted: its Node values are sampled-tier estimates, so an
   exact enumeration here would have no exact reference to match. ---- *)
stillSeeds = <|
  "B/beehive" -> place[{{0,1},{0,2},{1,0},{1,3},{2,1},{2,2}}],
  "B/loaf" -> place[{{0,1},{0,2},{1,0},{1,3},{2,1},{2,3},{3,2}}],
  "B/tub" -> place[{{0,1},{1,0},{1,2},{2,1}}],
  "B/pond" -> place[{{0,1},{0,2},{1,0},{1,3},{2,0},{2,3},{3,1},{3,2}}],
  "B/boat" -> place[{{0,0},{0,1},{1,0},{1,2},{2,1}}],
  "B/ship" -> place[{{0,0},{0,1},{1,0},{1,2},{2,1},{2,2}}]|>;
Print["=== v1.3 still lifes, d=2 (exact tier) ==="];
Do[Module[{hist, gT, pos, focus, cn, n, down, list},
   hist = run[stillSeeds[k], T];
   gT = hist[[T + 1]];
   pos = FirstPosition[gT, 1];
   focus = {pos[[1]], pos[[2]], T};
   cn = cone[hist, focus, 2];
   {n, down, list} = poset[cn];
   Print[k, "  n=", n, " d=2"];
   Do[Module[{ap = apCount[down, down[[x]], n], idv = verdict[down, n, 2^n - 1, down[[x]]]},
     Print["  kernel ", x - 1, " node(r,c,t)=", list[[x]] - {1, 1, 0}, "  |Ap|=", ap,
      "  @id=", idv, If[idv =!= "ordinary" && ap > 0, "  LATENT", ""]]],
    {x, n}]],
  {k, Keys[stillSeeds]}];
