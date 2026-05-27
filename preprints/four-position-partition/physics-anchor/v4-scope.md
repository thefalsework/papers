# Physics-Anchor v4 Scope Memo

**Author:** Chris Brink
**Date:** May 2026 (pre-script scoping for v4, written after the v3 results in `v3-scope.md` §10).
**Status:** Scoping only; no script committed yet. Companion to:
- `physics-anchor/feasibility.md` (records v1 Route-B, v2 Route-A checkpoint, v3 cardinality-positive result),
- `physics-anchor/v3-scope.md` (pre-script design for v3; §10 records executed results and the structural-null finding for the exhaustive sweep),
- `wolfram/cores/heunen-landsman-spitters-2009.wl` (Bohrification structural core entry).

---

## 1. The question v4 is asking, and the framing shift from v3

v3 ran a *comparative* test: build `V_d(M_2(C) ⊕ C)` and a poset-isomorphic commutative control `V_d(C^7)`, run identical kernel candidates on both sides, look for a partition-cell divergence attributable to non-commutativity. The result was mixed (cardinality-positive on tight kernels, non-emptiness-negative everywhere), with a structural finding: at poset-isomorphic comparators, the only place a quantum signal can live is at kernels that reference daseinisation of a specific projection. Lattice-internal kernel choices (the exhaustive sweep) are blind to non-commutativity by construction.

v4 inherits the architectural question but **reframes the test**. Instead of asking "does the partition's behaviour at a poset-iso comparator differ between quantum and classical?", v4 asks:

> At the Kochen-Specker dimensionality threshold (`dim ≥ 3`), the poset-isomorphic commutative-control construction itself **fails** at any KS-blocking finite discretisation of `V(M_3(C))`. This failure has a precise structural signature: the global sections of the spectral presheaf `Σ` drop to zero on the quantum side, while *any* commutative `C^m` whose context category we try to match has `|GlobalSections(Σ_{V_d(C^m)})| ≥ m`. So no commutative `C^m` can give a structurally-matching restriction-map system. **The framework's machinery — operating on `Sub_cl(Σ)` — detects this failure as a lattice-internal feature**: the count of atomic-everywhere clopen subobjects (equivalently, `|GlobalSections(Σ)|`) drops to zero on the quantum side at KS-blocking configurations, while it cannot drop to zero on any commutative side.

**The break is the signal, not an obstacle.** Framing the v3-style comparative test as breaking down at `M_3(C)` would leave v4 with an ambiguous interpretive status (is the framework detecting something specific, or just detecting that the construction failed?). Framing the break itself as a detected structural feature gives v4 a clean inferential structure: the framework is detecting the Kochen-Specker phenomenon via the same structural feature that physicists use to characterise it (no global `{0,1}`-valuation on the projection lattice).

This is conceptually cleaner than v3 because:

1. The signal v4 is detecting is *already independently identified* by the physics-foundations literature as the canonical structural signature of quantum non-classicality (Kochen-Specker theorem, 1967; the topos-theoretic reformulation as "Σ has no global section" is the Isham-Butterfield-Döring lineage, 1998-2012).

2. The detection is *lattice-internal* to `Sub_cl(Σ)` — atomic-everywhere subobjects are a predicate intrinsic to the partition-machinery substrate, computable without leaving the framework's machinery.

3. The detection is *categorical* (count = 0 vs count ≥ `m`), not just quantitative. v3's positive signal was cardinality-only; v4 promotes the physics anchor to a categorical signal.

4. The v3 lattice-iso argument that closed out the exhaustive sweep (`v3-scope.md` §10.4) is *exactly* the argument that forces v4's break: lattice-iso preserves all intrinsic lattice predicates, including `|GlobalSections|`; KS forces `|GlobalSections(Σ_Q)| = 0`; any commutative replication has `|GlobalSections(Σ_C)| ≥ m`; therefore lattice-iso cannot hold. v4 is the dual claim to v3's structural-null finding: the same structural mechanism that *prevented* the exhaustive sweep from being informative in v3 *forces* a non-trivial signal at v4.

---

## 2. What v4 is *not* asking

- v4 is not asking whether Kochen-Specker holds for `M_3(C)`. It does (KS 1967; this is established background). v4's role is to demonstrate that the FalseWork framework's `Sub_cl(Σ)`-based machinery *detects* KS as a count-zero of a specific subobject class, traceable to a lattice-internal predicate.

- v4 is not running a v3-style comparative test against a poset-iso commutative control. **The whole point of v4 is that this construction fails at `M_3(C)` KS-configurations.** v4 sets up the failure explicitly and detects it.

- v4 is not enumerating all of `Sub_cl(Σ)` for any KS-blocking discretisation. Computational tractability rules this out (see §6 below). v4 computes `|GlobalSections(Σ)|` directly, plus a small number of named kernel candidates connecting global-section counts to the four-cell partition.

- v4 is not building the full Bohrification topos `T(M_3(C)) = [V(M_3(C)), Set]`. v4 restricts to a finite KS-blocking sub-poset `V_d ⊂ V(M_3(C))`, chosen for tractability.

- v4 is not formally proving KS in Lean. The KS-blocking property of the chosen `V_d` is verified *computationally* in the Wolfram script. Lean formalisation of KS for `M_3(C)` is a substantial separate effort and is out of scope.

---

## 3. The discretised context category for v4

### 3.1 What KS-blocking requires

For a finite discretisation `V_d ⊂ V(M_3(C))` to be *KS-blocking*, the underlying set of 1-dim projections (atoms across all MASAs in `V_d`) must admit no consistent `{0, 1}`-valuation respecting (a) each MASA assigns exactly one atom the value 1, and (b) atoms shared across MASAs receive the same value.

Equivalently: `|GlobalSections(Σ_{V_d})| = 0`.

The smallest known KS-blocking projection sets in dim 3 are:
- **Cabello-Estebaranz-García-Alcaine (1996), 18 vectors** in dim 4 (not applicable here).
- **Kochen-Specker (1967), 117 vectors** (original, dim 3) — way too large.
- **Peres (1991), 33 vectors** — large but manageable in count, dim 3.
- **Bub (1996), 33 vectors** — dim 3.
- **Conway-Kochen ("31 lines" configuration)** — dim 3, intermediate size.

A finite-MASA discretisation embedding these projection sets requires choosing MASAs that contain each projection. Minimum number of MASAs varies by configuration; typically `~15-20` MASAs for the Peres or Bub set.

### 3.2 Concrete discretisation proposal: Peres 33-vector reduction

The Peres-1991 33-vector KS proof uses 33 specific 1-dim projections in `C^3`, organised as 16 orthonormal triples (each triple is a MASA of `M_3(C)`).

For v4, we propose using:
- **Atoms**: the 33 Peres projections, each a 1-dim projection in `M_3(C)`.
- **MASAs**: the 16 Peres MASAs (each is an orthonormal triple).
- **Sub-MASAs**: 1-dim sub-MASAs `⟨P, 1-P⟩` for each atom `P` that lies in at least two MASAs (this gives the "context overlap" structure).

The Hasse poset has structure:
- `V_0 = C·I` at the bottom (1 context).
- `V_P = ⟨P, 1-P⟩` for each Peres atom `P` that's shared between two or more MASAs (some number `k_1` of contexts; needs counting).
- `V_{ijk}` for each Peres triple (16 contexts).

Estimated total: `1 + k_1 + 16` contexts, with `k_1` somewhere in the range 10-30 depending on the sharing structure.

If this is computationally intractable for `|Sub_cl|`, we can fall back to a *partial* Peres configuration (subset of the 16 MASAs that still includes the KS-blocking structure when restricted to specific projections; this would be a research scope for a v4-lite variant).

Alternative: use a smaller KS-blocking configuration. **Question for the user**: prefer Peres-33 (well-known, more MASAs, more confidence in KS-blocking), or simpler-but-larger configurations (KS-blocking with fewer MASAs but more projections per MASA)? The trade-off is between number-of-contexts (more contexts = harder enumeration) and number-of-atoms-per-context (more atoms = harder per-context computation).

### 3.3 The atomic-everywhere question

A clopen subobject `S` of `Σ_{V_d}` is *atomic-everywhere* if `|S_V| = 1` at every context `V` in `V_d`.

`|GlobalSections(Σ_{V_d})|` = number of atomic-everywhere clopen subobjects.

For `V_d` KS-blocking: this count is `0`. v4's quantum-side test is to compute this count and verify it's zero.

For a commutative comparator: any commutative `C^m`'s context category has `m` atomic-everywhere clopen subobjects (one per atom of `C^m`). So even the *minimum-`m`* commutative comparator gives count `≥ 1` at any non-empty sub-poset.

---

## 4. The v4 test design

### 4.1 Primary signal: `|GlobalSections(Σ_Q)| = 0`

Compute `|GlobalSections(Σ_{V_d(M_3(C))})|` for the chosen KS-blocking `V_d`. The expected value is `0` if `V_d` is KS-blocking.

Verification: this directly detects KS by computation on the framework's machinery. The framework "sees" KS as `|count of atomic-everywhere clopen subobjects in Sub_cl(Σ)| = 0`.

Computational method: iterate over tuples `(λ_1, ..., λ_k) ∈ ∏_i Σ(V_i)` where `V_1, ..., V_k` are the top contexts (Peres MASAs), and select those tuples that extend coherently to characters at all sub-contexts. Equivalently: iterate over candidate characters and check compatibility across shared sub-MASAs.

Cost: `|Σ(V_1)| × ... × |Σ(V_k)|` candidate tuples = `3^k`. For `k = 16` Peres MASAs, that's `3^16 ≈ 4.3 × 10^7`. Tractable. (For larger `k`, can be made more efficient with short-circuit checks.)

### 4.2 Connection to the four-cell partition

The four-cell partition framework can detect this signal at a specific kernel:

**Kernel `a* := join of all atomic-everywhere clopen subobjects`** (the "global-section subobject"). This is the *smallest* clopen subobject containing every atomic-everywhere subobject.

- For commutative `A`: `a*` is the join of the `m` atomic-everywhere subs, equal to `⊤` at every "shared" context but possibly less at "split" contexts. Concretely: `a*` is a non-trivial subobject of `Σ`, and `¬a*` is also non-trivial.
- For KS-quantum `A`: there are no atomic-everywhere subs, so `a* = ⊥` (the bottom subobject, join of an empty set).

At `a* = ⊥`, the four-cell partition collapses: `Infrastructure(⊥) = {⊥}`, all other cells empty. The kernel is trivial.

So this kernel produces a *trivial partition* on the quantum side (kernel-is-bottom) and a *non-trivial partition* on the commutative side (kernel-is-non-bottom). This is a categorical divergence at the four-cell-partition level, traceable to KS via the global-section count.

**Dual kernel `a** := meet of all "co-atomic-everywhere" subobjects`** (where co-atomic-everywhere = `|S_V| = |Σ(V)| - 1` at every V; complement of atomic-everywhere). This is the "co-global-section subobject" and is dual to `a*`.

- Both kernels combined give a cleaner partition-cell-divergence picture.

### 4.3 Secondary signal: kernel candidates with KS-relevant daseinisations

v4 can also include kernel candidates analogous to v3's named list, but evaluated on the KS-configured `V_d(M_3(C))`:

- `4.1' δ(P)` where `P` is a Peres-style projection.
- `4.3' δ(P) ∧ δ(¬P)`.
- `4.5' δ(P) ∧ ¬δ(¬P)`.
- etc.

Expected behaviour: cardinality patterns may differ from v3 because the `M_3(C)` discretisation has more off-direction contexts. Cell-non-emptiness may finally show divergence at *some* kernel because the KS structure of `V_d` allows non-regular subobjects of types not possible in v3.

But the **primary v4 signal is `|GlobalSections|`**, not these kernel candidates. The candidates are secondary instrumentation.

### 4.4 Commutative comparator (for sanity-checking the framing)

To make the break visible, v4 also computes `|GlobalSections|` for a *minimal* commutative comparator:

- Take `A_classical = C^m` for some small `m` (3 ≤ `m` ≤ Bell(33) or so).
- Choose a sub-poset of `V(C^m)` that has the same Hasse structure as our chosen `V_d(M_3(C))`.
- Compute `|GlobalSections(Σ_{V_d(C^m)})|`.

The Hasse-matching may not be straightforward (because of the KS-blocking constraint discussed in §1), but a "best-effort partial match" can still be built — it'll diverge from `V_d(M_3(C))` *at some specific context or restriction map*, and that divergence itself is the "where the lattice-iso fails" diagnostic.

For the v4 script: a minimal commutative comparator using `C^3` (the natural choice — same Gelfand spectrum size as `M_3(C)` itself) with sub-poset `{C·1, V_topZ', V_topX', V_topY'}` where `V_topZ' = V_topX' = V_topY' = C^3`. This gives `|GlobalSections| = 3` (three atoms of `C^3` give three global sections). Compare to the KS-blocking quantum side's `|GlobalSections| = 0`.

This is the cleanest contrast: 0 vs 3, traceable to KS, at a minimal commutative setup that's not even attempting a full Hasse match.

---

## 5. Comparison criteria

A *positive v4 result* (categorical signal detected) requires:

1. **Verified KS-blocking**: `|GlobalSections(Σ_{V_d(M_3(C))})| = 0` for the chosen `V_d`. This is a computation; the value should come out zero by KS (already established mathematically, but verified here on the chosen discretisation).

2. **Verified commutative non-blocking**: `|GlobalSections(Σ_{V_d(C^m)})| ≥ 1` for any commutative comparator (in fact `≥ m` for natural sub-posets of `V(C^m)`).

3. **Four-cell partition at kernel `a*` collapses on quantum side, doesn't on classical side.** This is the framework-internal detection.

A *negative v4 result* would be: `|GlobalSections(Σ_{V_d(M_3(C))})| > 0` — meaning our chosen `V_d` isn't actually KS-blocking. This would be a diagnostic about the discretisation, not about the framework. Fix: enlarge `V_d` until KS-blocking holds, then retry.

A *mixed v4 result* is essentially not possible at the primary signal level: either `|GlobalSections| = 0` (KS-blocking, positive signal) or `> 0` (not KS-blocking, diagnostic).

---

## 6. Computational tractability

The hard part of v4 is *not* the global-section count (`O(3^k)` for `k` MASAs, tractable up to `k ~ 20`). The hard part is the *enumeration of `Sub_cl(Σ)`* if we want to verify the kernel `a*`'s four-cell structure rigorously.

Approach 1 (most rigorous, may be infeasible): enumerate all of `Sub_cl(Σ)` and compute the four-cell partition at `a*`. Tractable only for small `V_d`; the Peres-16-MASA configuration may exceed Wolfram Cloud's enumeration budget.

Approach 2 (intermediate): enumerate atomic-everywhere subobjects only (which is `O(3^k)`), compute their join `a*`, then enumerate subobjects ≤ `a*` and ≤ `¬a*` separately. This avoids enumerating all of `Sub_cl(Σ)`.

Approach 3 (minimal): compute only `|GlobalSections|` on quantum and classical sides. Skip the four-cell partition entirely. Report the count divergence as the v4 signal, and connect it to the partition framework only by argument (not by enumeration).

**Recommendation: Approach 3 for the first v4 run.** It's the lowest-cost route to the headline result (`|GlobalSections(Σ_Q)| = 0 ≠ m = |GlobalSections(Σ_C)|`), and if it lands cleanly, Approach 2 can be attempted as a follow-up patch to ground the four-cell-partition connection more concretely.

---

## 7. Script architecture

`wolfram/physics-anchor/four-position-physics-v4.wl`. Sections (proposed):

1. **Generic machinery**: copied from v3 (`liftProj`, `subEqQ`, `leqSub`, `bottomSub`, `topSub`, `meetSub`, `joinSub`, `heytingNot`, `regularQ`). May not all be needed for Approach 3 but keep them available.

2. **Linear-algebraic primitive for `M_3(C)`**: 3×3 complex matrices, PSD check, projection-domination check. Then the Peres-33 projection list (or whichever KS configuration is chosen at the decision-gate).

3. **MASA construction**: build the 16 Peres MASAs (or chosen alternative), each as an orthonormal triple. Compute sub-MASAs (1-dim projections shared between MASAs).

4. **Context-category assembly**: build `V_d(M_3(C))` Hasse structure, spectra, restriction maps.

5. **Commutative comparator setup**: build `V_d(C^3)` (or `C^m` for chosen `m`) with sub-poset structure aimed at "best-effort Hasse match" (acknowledging the match won't be exact at KS-blocking).

6. **Global-section enumeration**: iterate over `∏_i Σ(V_top_i)` tuples, check compatibility at sub-contexts, count atomic-everywhere clopen subobjects.

7. **Headline report**: `|GlobalSections(Σ_Q)|` and `|GlobalSections(Σ_C)|` side by side. Signal verdict.

8. **Optional Part 8 (Approach 2)**: enumerate subobjects ≤ `a*` and ≤ `¬a*`, report four-cell partition counts.

Output target: ~50-80 lines for the primary report; an additional 30-50 if Approach 2 is included.

---

## 8. Scope and time estimate

Honest estimate: roughly v3-scale effort (a few days of focused work). The conceptual setup is more substantial than v3 because the Peres configuration requires more care; the runtime estimate for the Wolfram Cloud cell is ~10-30 minutes for Approach 3, possibly much longer for Approach 2.

Risks:

- The Peres configuration may turn out to require more MASAs than convenient. Mitigation: pre-script verify KS-blocking on a *subset* of the Peres atoms before committing to the full configuration. Fall back to known smaller KS-blocking configurations if available.

- The "minimal commutative comparator" choice (`C^3` with trivial sub-poset) is conceptually clean but may not feel like a fair comparator. Mitigation: in §4.4 of this scope memo, document explicitly that the comparator is *intentionally minimal* to make the break visible; a more careful sub-poset match is research scope for a v4.1 patch.

- The v4 signal is technically not novel at the physics level (KS has been known since 1967). The novelty is in the *framework-detection* claim: the FalseWork four-cell partition machinery on `Sub_cl(Σ)` detects KS as a structural feature, not as an externally imposed result. Mitigation: §1 of this memo makes the framework-detection framing explicit.

---

## 9. What to do with results

### Positive v4 result (`|GlobalSections(Σ_Q)| = 0` verified, `|GlobalSections(Σ_C)| ≥ 1` verified)

- Update `physics-anchor/feasibility.md` with a §4.8 v4 checkpoint section: KS is detected by the framework's `Sub_cl(Σ)` machinery as a count-zero of atomic-everywhere clopen subobjects, traceable to lattice-internal structure.
- Promote the physics anchor status: from "feasible at cardinality level on `M_2(C) ⊕ C`" (v3) to "categorical signal detected on `M_3(C)` via KS-blocking".
- The physics-anchor claim becomes: "the FalseWork framework's partition machinery, operating on `Sub_cl(Σ)` for a Bohrification topos on a non-commutative C*-algebra, detects the Kochen-Specker phenomenon as a count-zero of atomic-everywhere clopen subobjects; no commutative C*-algebra can replicate this count-zero at any sub-poset of its context category."
- Next step: connect this detection to the four-cell partition more carefully (Approach 2 follow-up), and/or to a Lean Layer-L theorem (substantial effort).

### Negative v4 result (`|GlobalSections(Σ_Q)| > 0`)

- This means the chosen `V_d` is not KS-blocking, not that KS fails.
- Update `physics-anchor/feasibility.md` to record the diagnostic: which `V_d` was tried, why it failed to block, what was learned about discretisation choice for v4.1.
- Iterate on the discretisation choice (add more Peres MASAs, add more shared atoms, etc.) until KS-blocking is achieved.

### "Computational infeasibility" result

- If even Approach 3 turns out to be too slow on Wolfram Cloud for the chosen `V_d`: fall back to a smaller `V_d` that's not full Peres-blocking but still meaningful. Document the smaller signal honestly.

---

## 10. Decision-gate resolved (2026-05-26)

User instruction: "the richest choices but best choices" and "stop planning, do what you see is best." The decision-gate is resolved without separate confirmation as follows:

1. **KS configuration**: Start with a **4-MASA shared-atom configuration** of `M_3(C)` — not the full Peres-33, but richer than v3's poset-only test:
   - `T_1` (cardinal): atoms `|0⟩⟨0|, |1⟩⟨1|, |2⟩⟨2|`.
   - `T_2`: atoms `|+_{01}⟩⟨+_{01}|, |-_{01}⟩⟨-_{01}|, |2⟩⟨2|` (shares `|2⟩⟨2|` with `T_1`).
   - `T_3`: atoms `|+_{02}⟩⟨+_{02}|, |-_{02}⟩⟨-_{02}|, |1⟩⟨1|` (shares `|1⟩⟨1|`).
   - `T_4`: atoms `|+_{12}⟩⟨+_{12}|, |-_{12}⟩⟨-_{12}|, |0⟩⟨0|` (shares `|0⟩⟨0|`).
   - Plus three 1-dim sub-MASAs (one per shared atom) and the trivial context: 8 contexts total, matching v3's context count.
   
   This is *not* full KS-blocking — that requires roughly 10-16 MASAs (Penrose dodecahedron, Peres-33). v4 here is the architectural extension to dim 3 with shared atoms. **If `|GlobalSections(Σ_Q)|` is already strictly less than its commutative-best-effort counterpart at 4 MASAs, that is a stronger result than expected; if equal, v4 establishes the dim-3 instrumentation and v5 scales to a Penrose/Peres KS-blocking config.**

2. **Commutative comparator**: **Both**. The minimal `C^3` (2 contexts, `|GlobalSections| = 3` trivially) provides the cleanest categorical-contrast baseline; a best-effort same-Hasse `C^9` sub-poset (8 contexts, designed to be poset-iso to the quantum side) provides the v3-discipline replication check. Reporting both lets us read off: (a) the minimum count any commutative side gives, and (b) whether the best-effort lattice-iso construction survives at this dim-3 configuration.

3. **Computational approach**: **Both Approach 3 and Approach 2**. Since the 4-MASA config has `|Sub_cl(Σ)| ~ 10^3-10^4` (similar to v3's 4385), full enumeration is tractable. So v4 computes:
   - `|GlobalSections|` counts on all three sides (quantum, minimal `C^3`, best-effort `C^9`).
   - The kernel `a*` = join of atomic-everywhere subobjects, and its four-cell partition on quantum and best-effort `C^9` sides.

4. **Secondary kernels**: **Minimal set** (4.1' `δ(P)` and 4.5' `δ(P) ∧ ¬δ(¬P)`) — the two most informative from v3 — for cardinality-baseline trend data at dim 3. The off-axis test projection is `P = |+++⟩⟨+++|` where `|+++⟩ = (|0⟩+|1⟩+|2⟩)/√3` (Peres-style off-axis vector).

This decision-gate produces the v4 script at `wolfram/physics-anchor/four-position-physics-v4.wl`. Run it; fold results into `physics-anchor/feasibility.md` §4.8 (next checkpoint).

---

## References

- Kochen, S., Specker, E. P. (1967). The problem of hidden variables in quantum mechanics. *Journal of Mathematics and Mechanics* 17: 59–87. (The original Kochen-Specker theorem.)
- Peres, A. (1991). Two simple proofs of the Kochen-Specker theorem. *Journal of Physics A: Mathematical and General* 24(4): L175. (Peres-33 KS configuration in dim 3.)
- Cabello, A., Estebaranz, J. M., García-Alcaine, G. (1996). Bell-Kochen-Specker theorem: a proof with 18 vectors. *Physics Letters A* 212(4): 183–187. (Smallest known KS proof, dim 4.)
- Isham, C. J., Butterfield, J. (1998). A topos perspective on the Kochen-Specker theorem: I. Quantum states as generalized valuations. *International Journal of Theoretical Physics* 37(11): 2669–2733. (Topos-theoretic reformulation of KS as "Σ has no global sections".)
- Heunen, C., Landsman, N. P., Spitters, B. (2009). A topos for algebraic quantum theory. *Communications in Mathematical Physics* 291: 63–110. (The Bohrification construction; `Sub_cl(Σ)` lattice.)
- Døring, A. (2012). Topos-based logic for quantum systems and bi-Heyting algebras. *arXiv:1202.2750*. (Sub_cl(Σ) as bi-Heyting algebra; daseinisation; stagewise Heyting NOT.)

---

*End of v4 scope memo. Pre-script decision gate is §10. No script written yet; this memo is the artefact of the design phase.*
