(* ::Package:: *)

(* ============================================================
   FalseWork Algebra Prototype - Demonstration Script
   ------------------------------------------------------------
   This script loads the algebra and the four-work corpus, then
   executes each of the four queries Ellynne Dec specified, with
   formatted output. Run from a Mathematica or Wolfram Engine
   session inside the wolfram/ directory:

     SetDirectory[NotebookDirectory[]]
     Get["notebook-script.wl"]

   For an interactive notebook, copy each section block into a
   separate notebook cell and evaluate in order.

   Provenance: Brink, May 2026, in response to:
     - Stephen Wolfram, Jan 3, 2026 (three-question opener)
     - Ellynne Dec, May 3, 2026 (four-query specification)
   ============================================================ *)


(* ============================================================
   SECTION 0 - Load algebra, kernels, and cores
   ============================================================ *)

Print["----------------------------------------------------------------"];
Print["FalseWork Algebra Prototype - May 2026"];
Print["Reference: github.com/thefalsework/papers"];
Print["----------------------------------------------------------------"];
Print[""];

Get["falsework-algebra.wl"];
Get["kernels.wl"];
Get["cores/tymoczko.wl"];
Get["cores/cutting.wl"];
Get["cores/nks.wl"];
Get["cores/methodology.wl"];

corpus = {TymoczkoCore, CuttingCore, NKSCore, MethodologyCore};

Print[""];
Print["Corpus loaded: ", Length[corpus], " structural cores."];
Print[""];


(* ============================================================
   SECTION 1 - Display the corpus

   Show the four cores at a glance: title, domain, kernel,
   number of mechanisms, independent-corroboration anchor.
   ============================================================ *)

Print["================================================================"];
Print["1. CORPUS"];
Print["================================================================"];
Print[""];

CorpusSummary[corpus_] :=
  Grid[
    Prepend[
      {field[#, "Title"],
       field[#, "Domain"],
       field[field[#, "Kernel"], "Slug"],
       Length @ field[#, "Mechanisms"],
       Length @ field[field[#, "Kernel"], "FormalGround"]} & /@ corpus,
      Style[#, Bold] & /@ {"Title", "Domain", "Kernel", "#Mech", "#Refs"}
    ],
    Frame -> All,
    Alignment -> {{Left, Left, Left, Center, Center}},
    BaseStyle -> "Text",
    Background -> {None, {LightGray, {None}}}
  ];

Print[CorpusSummary[corpus]];
Print[""];


(* ============================================================
   SECTION 2 - Query 1: Mechanism + constraint match

   Find all cores in the corpus whose mechanism set contains a
   DiscriminationOperation AND whose constraint set contains a
   DependencyStatement. This is type-level (not id-level)
   matching, which is what makes cross-domain results possible.
   ============================================================ *)

Print["================================================================"];
Print["2. QUERY 1 - mechanism + constraint match"];
Print["================================================================"];
Print[""];
Print["Finding cores with at least one DiscriminationOperation"];
Print["mechanism AND a DependencyStatement constraint..."];
Print[""];

q1Results = FindWorksByType[corpus,
  "DiscriminationOperation", "DependencyStatement"];

Print["Returned ", Length[q1Results], " cores:"];
Do[
  Print["  - ", field[c, "Title"], "  (", field[c, "Domain"], ")"],
  {c, q1Results}
];
Print[""];
Print["Note: Methodology core is also returned because "];
Print["external_only_analysis is a DiscriminationOperation."];
Print["This is expected: the methodology has discrimination"];
Print["structure even at the meta-level."];
Print[""];


(* ============================================================
   SECTION 3 - Query 2 (CENTERPIECE): Tymoczko <-> Cutting

   The transfer query is the load-bearing demonstration of the
   prototype. It shows, computationally and on grounds the
   algebra can articulate, that voice-leading parsimony in
   Tymoczko's framework and cut/dissolve discrimination in
   Cutting's framework are kernel-shape-equivalent.

   Two scholars, two domains, two independent vocabularies, one
   underlying algebraic shape - surfaced by code, not prose.
   ============================================================ *)

Print["================================================================"];
Print["3. QUERY 2 - transfer candidates [CENTERPIECE]"];
Print["================================================================"];
Print[""];
Print["Tymoczko (music) <-> Cutting (film)"];
Print[""];
Print["Computing TransferCandidates[TymoczkoCore, CuttingCore]..."];
Print[""];

transferTC = TransferCandidates[TymoczkoCore, CuttingCore];

Print["Returned ", Length[transferTC], " candidates:"];
Print[""];

Do[
  Print["  ", c["From"], "  ->  ", c["To"]];
  Print["    domains:    ", c["FromDomain"], " -> ", c["ToDomain"]];
  Print["    kernels:    ", c["FromKernel"], " -> ", c["ToKernel"]];
  Print["    confidence: ", NumberForm[c["Confidence"], {3, 2}]];
  Print["    basis:      ", StringRiffle[c["Basis"], " | "]];
  Print[""],
  {c, transferTC}
];

Print["----------------------------------------------------------------"];
Print["KEY RESULT - what the algebra produced, and what that means"];
Print["----------------------------------------------------------------"];
Print[""];
Print["The algebra surfaces voice_leading_parsimony (Tymoczko) and"];
Print["cut_dissolve_discrimination (Cutting) as transfer candidates"];
Print["on the basis the script can articulate:"];
Print[""];
Print["  - shared mechanism Type:    DiscriminationOperation"];
Print["  - cross-domain transfer:    music -> film"];
Print["  - comma-shape match:        BoundaryDiscriminationAtLimit"];
Print[""];
Print["What this is. A coherence demonstration. The framework asserts"];
Print["in Paper 1 sec. 4.3 that 'both are instances of the same"];
Print["abstract structure: a sub-symmetry made available by a closed"];
Print["generative field at its boundary.' That claim is encoded in"];
Print["the comma's IrreducibilityKind field. The algebra confirms"];
Print["the claim is internally consistent and machine-checkable: when"];
Print["operationalized, the framework's stated cross-domain shape"];
Print["does fire on the Tymoczko-Cutting pair on three independent"];
Print["grounds the schema can articulate."];
Print[""];
Print["What this is not. An empirical proof of cross-domain comma"];
Print["equivalence. Paper 1 sec. 4.3 itself names this as 'the open"];
Print["empirical question the proxy feature program is designed to"];
Print["test.' Paper 3 sec. 8.1 cites Cubitt et al. 2015 (spectral gap"];
Print["undecidability) as one independently established cross-domain"];
Print["formal equivalence; the general homology claim is otherwise"];
Print["structural argument awaiting RG-style or category-theoretic"];
Print["formalization. The 0.92 confidence reports schema coherence,"];
Print["not empirical validation."];
Print[""];
Print["Independent corroboration of the two cores themselves:"];
Print[""];
Print["  Tymoczko:  voice_leading geometry, three-way scale-space"];
Print["             discrimination, Coltrane Giant Steps corpus"];
Print["  Cutting:   perceptual primitive, terminological convergence"];
Print["             on 'primitive' without reference to FalseWork,"];
Print["             three of four kernel criteria satisfied"];
Print[""];

(* Auxiliary: also run on cross-pairs *)
Print["Auxiliary cross-domain pairs:"];
Print[""];
Print["  Tymoczko -> NKS:        ",
  Length @ TransferCandidates[TymoczkoCore, NKSCore], " candidates"];
Print["  Cutting -> NKS:         ",
  Length @ TransferCandidates[CuttingCore, NKSCore], " candidates"];
Print["  NKS -> Tymoczko:        ",
  Length @ TransferCandidates[NKSCore, TymoczkoCore], " candidates"];
Print[""];
Print["The presence of cross-domain candidates between three distinct"];
Print["domains (music, film, computational science) shows the algebra"];
Print["is not merely identifying within-domain structural similarity."];
Print[""];


(* ============================================================
   SECTION 4 - Query 3: Computational removal test

   Remove voice_leading_parsimony from Tymoczko's core. The
   algebra should predict that:
     - the bounded_parameter_space constraint stays (depended
       on by other mechanisms)
     - mechanisms whose composition rules referenced
       voice_leading_parsimony are marked Degraded
     - the loss_of_three_way_discrimination failure mode
       surfaces

   This is Tymoczko predicting his own framework's collapse,
   computed by the algebra rather than asserted in prose.
   ============================================================ *)

Print["================================================================"];
Print["4. QUERY 3 - computational removal test"];
Print["================================================================"];
Print[""];
Print["RemoveAndProject[TymoczkoCore, voice_leading_parsimony]"];
Print[""];

deltaTymoczko = RemovalDelta[TymoczkoCore, "voice_leading_parsimony"];

Print["  Constraints dropped: ",
  If[Length[deltaTymoczko["ConstraintsDropped"]] == 0, "(none)",
     StringRiffle[deltaTymoczko["ConstraintsDropped"], ", "]]];
Print["  Mechanisms degraded: ",
  If[Length[deltaTymoczko["MechanismsDegraded"]] == 0, "(none)",
     StringRiffle[deltaTymoczko["MechanismsDegraded"], ", "]]];
Print["  Failure modes surfaced: ",
  If[Length[deltaTymoczko["FailureModesSurfaced"]] == 0, "(none)",
     StringRiffle[deltaTymoczko["FailureModesSurfaced"], ", "]]];
Print[""];
Print["Interpretation: removing voice_leading_parsimony degrades"];
Print["the mechanisms whose composition rules referenced it"];
Print["(iterated_fifth_generation, tonal_hierarchy) and surfaces"];
Print["the predicted scale-space collapse. The constraint"];
Print["bounded_parameter_space remains because other mechanisms"];
Print["still depend on it."];
Print[""];

Print["RemoveAndProject[CuttingCore, cut_dissolve_discrimination]"];
Print[""];

deltaCutting = RemovalDelta[CuttingCore, "cut_dissolve_discrimination"];

Print["  Constraints dropped: ",
  If[Length[deltaCutting["ConstraintsDropped"]] == 0, "(none)",
     StringRiffle[deltaCutting["ConstraintsDropped"], ", "]]];
Print["  Mechanisms degraded: ",
  If[Length[deltaCutting["MechanismsDegraded"]] == 0, "(none)",
     StringRiffle[deltaCutting["MechanismsDegraded"], ", "]]];
Print["  Failure modes surfaced: ",
  If[Length[deltaCutting["FailureModesSurfaced"]] == 0, "(none)",
     StringRiffle[deltaCutting["FailureModesSurfaced"], ", "]]];
Print[""];
Print["Interpretation: same shape of result in a different domain."];
Print["The removal is a rewrite, not a deletion: predictable"];
Print["downstream effects propagate via the schema."];
Print[""];


(* ============================================================
   SECTION 5 - Query 4: Recursive self-application

   Run the algebra on the methodology's own core. The same
   queries used on Tymoczko, Cutting, and NKS now apply to the
   pipeline that produced their cores.

   Expected outputs:
     - selfTransfers reveal procedural isomorphism: many
       mechanisms in the methodology are kernel-shape-equivalent
       to other mechanisms in the methodology, computationally
       confirming that the pipeline's nominal variation conceals
       structural uniformity.
     - removalProfiles distinguish load-bearing mechanisms
       from ornamental ones.
     - latentFailures re-derive the failure modes Brink
       originally surfaced interpretively in Jan 4, 2026:
         variety_in_uniformity
         transparency_as_opacity
         methodology_blind_spot
   ============================================================ *)

Print["================================================================"];
Print["5. QUERY 4 - recursive self-application"];
Print["================================================================"];
Print[""];
Print["RecursiveAnalysis[MethodologyCore]"];
Print[""];

recursiveResult = RecursiveAnalysis[MethodologyCore];

Print["----------------------------------------------------------------"];
Print["A. Self-transfers (procedural isomorphism, computed)"];
Print["----------------------------------------------------------------"];
Print[""];
Print[Length[recursiveResult["SelfTransfers"]],
  " non-trivial self-transfer candidates in the methodology core."];
Print[""];
Print["A high count here is the algebraic signature of procedural"];
Print["isomorphism: many mechanisms in the methodology pass the"];
Print["transfer-compatibility predicate against many other"];
Print["mechanisms in the same methodology. Translated: the pipeline"];
Print["has internal symmetry that an outside reader does not get"];
Print["from inspecting the prompts alone."];
Print[""];

Print["Top self-transfer candidates by confidence:"];
Print[""];

Do[
  Print["  ", c["From"], "  ~  ", c["To"],
        "    (conf ", NumberForm[c["Confidence"], {3, 2}], ")"];
  Print["    basis: ", StringRiffle[c["Basis"], " | "]],
  {c, Take[recursiveResult["SelfTransfers"],
           Min[6, Length @ recursiveResult["SelfTransfers"]]]}
];
Print[""];

Print["----------------------------------------------------------------"];
Print["B. Load-bearing mechanisms"];
Print["----------------------------------------------------------------"];
Print[""];
Print["Mechanisms whose removal causes constraint collapse or"];
Print["mechanism degradation:"];
Print[""];
Do[
  Print["  - ", m],
  {m, recursiveResult["LoadBearingMechanisms"]}
];
Print[""];
Print["Mechanisms not in this list are ornamental at the algebraic"];
Print["level: they could be removed without further structural"];
Print["disturbance under the schema."];
Print[""];

Print["----------------------------------------------------------------"];
Print["C. Latent failure modes (computationally re-derived)"];
Print["----------------------------------------------------------------"];
Print[""];
Print["Failure modes surfaced by removal projections that were"];
Print["NOT pre-declared in the core's top-level FailureModes:"];
Print[""];
Do[
  Print["  - ", f],
  {f, recursiveResult["LatentFailures"]}
];
Print[""];
Print["These are the same failure modes Brink surfaced interpretively"];
Print["in the Jan 4, 2026 reply to Stephen Wolfram:"];
Print[""];
Print["  variety_in_uniformity    : the temperature parameter"];
Print["                             promises increasing creative"];
Print["                             freedom that the isomorphic"];
Print["                             output shape cannot deliver"];
Print["  transparency_as_opacity  : complete documentation creates"];
Print["                             such dense procedural apparatus"];
Print["                             that the original analysed work"];
Print["                             disappears beneath layers of"];
Print["                             meta-commentary"];
Print["  methodology_blind_spot   : the methodology analyses"];
Print["                             structural techniques in other"];
Print["                             works while treating its own"];
Print["                             seven-stage architecture as"];
Print["                             neutral rather than rhetorical"];
Print[""];
Print["Originally these were prose findings. They are now algebraic"];
Print["consequences of the same operations the prototype runs on"];
Print["Tymoczko, Cutting, and NKS. Recursion has moved from"];
Print["self-description to self-computation."];
Print[""];


(* ============================================================
   SECTION 6 - Visualizations

   Three Graph renderings of the query outputs above. The
   framework's structure is graph-shaped: mechanisms link via
   composition rules, transfers traverse cores, removals
   cascade through dependencies. Wolfram Language renders
   these natively; the diagrams are the same data the queries
   above already returned, in the form best read visually.
   ============================================================ *)

Print["================================================================"];
Print["6. VISUALIZATIONS"];
Print["================================================================"];
Print[""];

(* ---- 6.1  Tymoczko <-> Cutting transfer network ----------- *)

Print["6.1  Transfer network (Q2): Tymoczko (music) <-> Cutting (film)"];
Print[""];

Module[{tEdges, tStyles, allVerts, vstyles},
  tEdges = DirectedEdge[#["From"], #["To"]] & /@ transferTC;
  tStyles = MapThread[
    #1 -> Directive[
      Thickness[0.003 + 0.012 * #2],
      ColorData["TemperatureMap"][#2]
    ] &,
    {tEdges, #["Confidence"] & /@ transferTC}
  ];
  allVerts = Join[
    Keys[field[TymoczkoCore, "Mechanisms"]],
    Keys[field[CuttingCore, "Mechanisms"]]
  ];
  vstyles = Join[
    Map[# -> Lighter[Blue, 0.6] &,
        Keys[field[TymoczkoCore, "Mechanisms"]]],
    Map[# -> Lighter[Red, 0.6] &,
        Keys[field[CuttingCore, "Mechanisms"]]]
  ];
  Print @ Graph[
    allVerts,
    tEdges,
    VertexLabels -> Placed["Name", Tooltip],
    EdgeStyle -> tStyles,
    VertexStyle -> vstyles,
    VertexShapeFunction -> "Rectangle",
    GraphLayout -> "BipartiteEmbedding",
    ImageSize -> 720,
    PlotLabel -> Style[
      "Transfer candidates: edge thickness/colour = confidence",
      14, Bold
    ]
  ]
];
Print[""];
Print["Cool/thin edges  : confidence 0.62  matches where comma-shape"];
Print["                   and cross-domain fire but mechanism Type"];
Print["                   does not align."];
Print["Hot/thick edges  : confidence 0.92  matches where mechanism"];
Print["                   Type also aligns. Comma_shape_match fires"];
Print["                   on BoundaryDiscriminationAtLimit on every"];
Print["                   pair, because both Tymoczko's and Cutting's"];
Print["                   commas share that abstract structural shape."];
Print[""];


(* ---- 6.2  Removal cascade in Tymoczko --------------------- *)

Print["6.2  Removal cascade (Q3): voice_leading_parsimony out of Tymoczko"];
Print[""];

Module[{mIds, cIds, edges, vstyles},
  mIds = Keys[field[TymoczkoCore, "Mechanisms"]];
  cIds = Keys[field[TymoczkoCore, "Constraints"]];

  (* Edges: mechanism -> the constraint(s) it depends on *)
  edges = Flatten @ Table[
    Module[{mech, deps},
      mech = field[TymoczkoCore, "Mechanisms"][m];
      deps = field[mech, "Compatibility"];
      If[!ListQ[deps], deps = {}];
      DirectedEdge[m, #] & /@ Intersection[deps, cIds]
    ],
    {m, mIds}
  ];

  (* Post-removal status colours: red = removed, yellow = degraded,
     green = surviving constraint, default = surviving mechanism. *)
  vstyles = Join[
    {"voice_leading_parsimony" -> Directive[Red, EdgeForm[Black]]},
    Map[# -> Directive[Yellow, EdgeForm[Black]] &,
        deltaTymoczko["MechanismsDegraded"]],
    Map[# -> Directive[LightGreen, EdgeForm[Black]] &, cIds]
  ];

  Print @ Graph[
    Join[mIds, cIds],
    edges,
    VertexLabels -> Placed["Name", Tooltip],
    VertexStyle -> vstyles,
    VertexShapeFunction -> "Rectangle",
    ImageSize -> 720,
    PlotLabel -> Style[
      "Removal cascade: red = removed, yellow = degraded, " <>
      "green = surviving constraint",
      14, Bold
    ]
  ]
];
Print[""];
Print["The constraint bounded_parameter_space (green) survives the"];
Print["removal because two other mechanisms still depend on it."];
Print["The two yellow mechanisms are marked degraded because their"];
Print["composition rules referenced the removed mechanism."];
Print[""];


(* ---- 6.3  Methodology self-transfer graph ----------------- *)

Print["6.3  Methodology self-transfer graph (Q4): procedural isomorphism"];
Print[""];

Module[{stEdges, stStyles, methodMechs},
  methodMechs = Keys[field[MethodologyCore, "Mechanisms"]];
  stEdges = DirectedEdge[#["From"], #["To"]] & /@
    recursiveResult["SelfTransfers"];
  stStyles = MapThread[
    #1 -> Directive[
      Thickness[0.002 + 0.008 * #2],
      ColorData["TemperatureMap"][#2]
    ] &,
    {stEdges, #["Confidence"] & /@ recursiveResult["SelfTransfers"]}
  ];

  Print @ Graph[
    methodMechs,
    stEdges,
    VertexLabels -> Placed["Name", Tooltip],
    EdgeStyle -> stStyles,
    VertexStyle -> Lighter[Orange, 0.5],
    VertexShapeFunction -> "Rectangle",
    GraphLayout -> "CircularEmbedding",
    ImageSize -> 720,
    PlotLabel -> Style[
      "Methodology self-transfers (" <>
      ToString[Length[stEdges]] <>
      " edges) - internal symmetry of the pipeline",
      14, Bold
    ]
  ]
];
Print[""];
Print["Density of edges between methodology mechanisms is the"];
Print["algebraic signature of procedural isomorphism: most pairs of"];
Print["mechanisms pass the transfer-compatibility predicate against"];
Print["each other. The pipeline has internal symmetry that prompt"];
Print["inspection alone does not surface."];
Print[""];


(* ---- 6.4  Discrimination panel: cross-pair comparison ---- *)

Print["6.4  Discrimination panel (Q2 across all cross-pairs):"];
Print["     where does comma-shape equivalence fire?"];
Print[""];

Module[{transferTN, transferCN, maxConf, minConf, renderPanel},
  transferTN = TransferCandidates[TymoczkoCore, NKSCore];
  transferCN = TransferCandidates[CuttingCore, NKSCore];

  maxConf[ts_] :=
    If[Length[ts] == 0, 0, Max[#["Confidence"] & /@ ts]];
  minConf[ts_] :=
    If[Length[ts] == 0, 0, Min[#["Confidence"] & /@ ts]];

  Print["  pair                                  cand   max     min"];
  Print["  Tymoczko (music)  <->  Cutting (film)     ",
        Length[transferTC], "    ",
        NumberForm[maxConf[transferTC], {3, 2}], "    ",
        NumberForm[minConf[transferTC], {3, 2}]];
  Print["  Tymoczko (music)  <->  NKS (compute)      ",
        Length[transferTN], "   ",
        NumberForm[maxConf[transferTN], {3, 2}], "    ",
        NumberForm[minConf[transferTN], {3, 2}]];
  Print["  Cutting (film)    <->  NKS (compute)      ",
        Length[transferCN], "   ",
        NumberForm[maxConf[transferCN], {3, 2}], "    ",
        NumberForm[minConf[transferCN], {3, 2}]];
  Print[""];

  renderPanel[transfers_, leftCore_, rightCore_, label_] :=
    Module[{tEdges, tStyles, allVerts, vstyles},
      tEdges = DirectedEdge[#["From"], #["To"]] & /@ transfers;
      tStyles = MapThread[
        #1 -> Directive[
          Thickness[0.003 + 0.012 * #2],
          ColorData["TemperatureMap"][#2]
        ] &,
        {tEdges, #["Confidence"] & /@ transfers}
      ];
      allVerts = Join[
        Keys[field[leftCore, "Mechanisms"]],
        Keys[field[rightCore, "Mechanisms"]]
      ];
      vstyles = Join[
        Map[# -> Lighter[Blue, 0.6] &,
            Keys[field[leftCore, "Mechanisms"]]],
        Map[# -> Lighter[Red, 0.6] &,
            Keys[field[rightCore, "Mechanisms"]]]
      ];
      Graph[
        allVerts,
        tEdges,
        VertexLabels -> Placed["Name", Tooltip],
        EdgeStyle -> tStyles,
        VertexStyle -> vstyles,
        VertexShapeFunction -> "Rectangle",
        GraphLayout -> "BipartiteEmbedding",
        ImageSize -> 520,
        PlotLabel -> Style[label, 12, Bold]
      ]
    ];

  Print["A. Tymoczko <-> Cutting (centerpiece): comma matches"];
  Print @ renderPanel[transferTC, TymoczkoCore, CuttingCore,
    "Tymoczko<->Cutting: " <>
    ToString[Length[transferTC]] <> " candidates"];

  Print["B. Tymoczko <-> NKS: comma does NOT match"];
  Print @ renderPanel[transferTN, TymoczkoCore, NKSCore,
    "Tymoczko<->NKS: " <>
    ToString[Length[transferTN]] <> " candidates"];

  Print["C. Cutting <-> NKS: comma does NOT match"];
  Print @ renderPanel[transferCN, CuttingCore, NKSCore,
    "Cutting<->NKS: " <>
    ToString[Length[transferCN]] <> " candidates"];
];

Print[""];
Print["The centerpiece (A) is the only pair where edges reach 0.92."];
Print["Off-pairs (B, C) cap at 0.68: shared Type plus cross-domain"];
Print["fire, but comma_shape_match does not. The discriminating"];
Print["predicate is comma_shape_match - the framework's articulated"];
Print["cross-domain claim, machine-checkable, NOT firing uniformly."];
Print[""];


(* ============================================================
   SECTION 7 - Beyond V1: schema mutation

   The deeper question Ellynne pressed: can recursion ALTER the
   method, improve the schema, or produce new formal distinctions
   that affect subsequent analyses?

   The V1 architecture is V2-capable. Demonstrating actual schema
   mutation under recursion is research, not prototype - flagged
   here as the natural next direction.
   ============================================================ *)

Print["================================================================"];
Print["7. BEYOND V1 - schema mutation under recursion"];
Print["================================================================"];
Print[""];
Print["The V1 prototype demonstrates failure-mode detection under"];
Print["recursion (Query 4). The deeper version - V2 - would"];
Print["demonstrate schema mutation: when run on itself, the algebra"];
Print["produces NEW mechanism types or NEW compatibility relations"];
Print["that become available for subsequent analyses."];
Print[""];
Print["A V2 sketch (deferred):"];
Print[""];
Print["  RecursiveSchemaUpdate[methodologyCore, currentTypeSystem]"];
Print["    1. surfaceUntypedMechanisms(methodologyCore)"];
Print["    2. promoteToType(novelties)"];
Print["    3. extendTypeSystem(currentTypeSystem, promoted)"];
Print[""];
Print["This is research, not prototype. The V1 architecture is"];
Print["V2-capable: the type system is implemented as data (six"];
Print["symbolic heads with Association payloads), so extending it"];
Print["under recursion is a manipulation of values, not of code."];
Print[""];


(* ============================================================
   SECTION 8 - Closing
   ============================================================ *)

Print["================================================================"];
Print["8. SUMMARY"];
Print["================================================================"];
Print[""];
Print["Four queries demonstrated, plus visualisations:"];
Print[""];
Print["  1. mechanism + constraint match            - Section 2"];
Print["  2. transfer candidates (centerpiece)       - Section 3"];
Print["  3. computational removal test              - Section 4"];
Print["  4. recursive self-application failure      - Section 5"];
Print["     mode detection"];
Print["  +  four Graph renderings:                  - Section 6"];
Print["       6.1 transfer network (Q2)"];
Print["       6.2 removal cascade (Q3)"];
Print["       6.3 methodology self-transfer (Q4)"];
Print["       6.4 discrimination panel (Q2 across cross-pairs)"];
Print[""];
Print["Centerpiece result:"];
Print[""];
Print["  The framework's articulated cross-domain claim from Paper 1"];
Print["  sec. 4.3 (voice_leading_parsimony in Tymoczko's music"];
Print["  geometry and cut_dissolve_discrimination in Cutting's film"];
Print["  framework as instances of the same boundary-discrimination"];
Print["  shape) is operationalized as a typed predicate firing on"];
Print["  three independent grounds. This demonstrates schema"];
Print["  coherence. The cross-domain claim itself remains the"];
Print["  framework's open empirical question."];
Print[""];
Print["Recursion result:"];
Print[""];
Print["  The methodology's failure modes, originally surfaced"];
Print["  interpretively in Jan 2026, are now derived"];
Print["  computationally as consequences of the same operations"];
Print["  the prototype runs on every other corpus item. Recursion"];
Print["  has moved from self-description to self-computation."];
Print[""];
Print["What this prototype is:"];
Print[""];
Print["  - A typed symbolic algebra over structural cores"];
Print["  - The operational instantiation of the kernel/comma"];
Print["    framework documented in Paper 1 v11.6"];
Print["  - A response to the four-query specification from"];
Print["    Ellynne Dec on behalf of the Wolfram Institute"];
Print["    Computational Metaphysics group, May 3, 2026"];
Print[""];
Print["What this prototype is not:"];
Print[""];
Print["  - A proof of the kernel framework's correctness"];
Print["  - A validation of any specific empirical claim"];
Print["  - A complete query language; many further queries are"];
Print["    enabled by the schema and deferred to V2"];
Print[""];
Print["----------------------------------------------------------------"];
Print["END OF DEMONSTRATION"];
Print["----------------------------------------------------------------"];
