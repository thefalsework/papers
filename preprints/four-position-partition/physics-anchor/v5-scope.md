# v5-scope: Peres-33 KS-blocking structural-break test on M_3(C)

**Author:** Chris Brink
**Date:** May 2026
**Status:** Pre-script design memo. Companion to `physics-anchor/feasibility.md` §0 (level hierarchy: this memo is **quaternary-level / Layer-L** work), §4.8-§4.9 (v4 results), and `v4-scope.md` §11.6 (v5 target identified).

---

## 0. Level positioning (added 2026-05-27)

v5 is **quaternary-level (Layer-L)** work per `feasibility.md` §0. It tests whether the framework's mathematical apparatus instantiated on the Bohrification substrate can faithfully witness the Kochen-Specker theorem as a finite computation. It does **not** speak to the framework's primary classification claim — that physics-interpretation works (Copenhagen, Decoherence, Quantum computing, Pilot wave, Many-Worlds, …) map to the five positions. That primary claim sits at the classifier + corpus level and stands independently of whether v5 succeeds, fails, or is never run. v5's result — `|GlobalSections(Σ_Q)| = 0 < 3` — is a clean Layer-L finding about the formal substrate, useful as rigor infrastructure under the partition theorem, and useful as a categorical contrast between quantum and commutative substrates at the Layer-L level. It is not the framework's primary evidence for the cross-domain claim.

---

## 1. Goal

v4 established that the 4-MASA shared-atom configuration of `M_3(C)` is *not* KS-blocking: `|GlobalSections(Σ_Q)| = |GlobalSections(Σ_C-best-effort)| = 12`, the primary structural-break signal did not fire. The v5 target is the **categorical KS-induced break**:

> Construct a context category over `M_3(C)` from a state-independent KS configuration. Verify computationally that `|GlobalSections(Σ_Q)| = 0` (the KS theorem made executable), and that this is strictly less than `|GlobalSections(Σ_C_min)| = 3` for any minimal commutative comparator. The strict inequality is the framework's categorical witness to quantum non-classicality.

This is the headline structural signal scoped in `v4-scope.md` §4.1, finally fired at the configuration that actually blocks classical valuations.

## 2. Choice of configuration

The natural candidate is the smallest published dim-3 state-independent KS proof. The leading options:

| Configuration | Rays | Triads | Notes |
|--------------|------|--------|-------|
| Kochen-Specker 1967 | 117 | many | Original, far too large |
| Conway-Kochen | 31 | ~17 | Smallest dim-3, but MASA structure not cleanly published |
| **Peres 1991 (full 57-40)** | 57 | 40 | 33 explicit + 24 implicit dyad-completions; clean cuboctahedral geometry; well-documented |
| Penrose dodecahedral | 40 | 10 | 10 triads but each ray appears in many triads; richer sub-MASA structure |

**Decision: Peres 1991 (full 57-ray, 40-triad form).** Reasoning:

- Vectors are explicit in published literature (Peres 1991 J. Phys. A 24, L175; Aravind & Lee-Elkin 2007 arXiv:0711.0894; Pavičić et al. 2009 arXiv:0909.4502v2).
- Cuboctahedral symmetry makes the geometry transparent: 3 axis rays, 6 face-diagonal rays (cube-edge midpoints), 12 "(2,1,1)-type" rays, 12 "(√2,1,1)-type" rays.
- Each of the 24 dyads `{r, s}` in Peres's table corresponds to a third ray `t = r × s/|r × s|` (the joint complement), giving 24 implicit completion rays. Total: 33 + 24 = 57 rays. The 24 dyads become 24 implicit triads, joining the 16 explicit triads → 40 triads.
- KS-witnessing is established by the Peres no-coloring proof (16 triads + 24 dyads → 40 triads after completion → no consistent coloring).

The Penrose dodecahedral alternative has cleaner symmetry (10 triads, dodecahedral) but the exact MASA-sharing structure requires careful derivation from Majorana vectors of complex spin-1 states. Peres is more direct.

## 3. The context category for v5

Given the 57 rays and 40 triads:

**Objects:**
- `V_0` (the trivial subalgebra `C·I`)
- For each ray `r` that appears in 2+ triads: a sub-MASA `V_r = ⟨P_r, I - P_r⟩` (where `P_r = |r⟩⟨r|/|r|²` is the rank-1 projection onto the ray)
- For each of the 40 triads `T = {r_1, r_2, r_3}`: a maximal MASA `V_T = ⟨P_{r_1}, P_{r_2}, P_{r_3}⟩`

**Hasse (covers):**
- `V_0 ≤ V_r` for every sub-MASA `V_r`
- `V_r ≤ V_T` whenever ray `r` is in triad `T`

Ray-incidence counts in the 40-triad structure:
- Original 33 Peres rays: each appears in 2 to 4 triads (mix of explicit + implicit). All become sub-MASAs.
- 24 implicit completion rays: each appears in exactly 1 triad. These do NOT become sub-MASAs in the categorical sense (no sharing across MASAs); they exist only as atoms inside their single MASA.

Therefore the context category has:
- 1 trivial context (`V_0`)
- 33 sub-MASA contexts (one per Peres ray, since every Peres ray appears in 2+ triads in the full 40-triad set)
- 40 maximal MASA contexts (one per triad)
- Total: **74 contexts**.

## 4. Spectra and the global-section count

**Spectrum sizes:** `V_0` has size 1, each sub-MASA `V_r` has size 2, each MASA `V_T` has size 3. Spectrum sequence: `{1, 2^33, 3^40}` → multiset `{1, 2, 2, ..., 2, 3, 3, ..., 3}`.

**Global sections.** An atomic-everywhere clopen subobject of `Σ_Q` picks one character per context, with restriction-consistency:

- One atom per MASA `V_T` (3 choices per MASA, with one ray of `T` selected as "1").
- At each sub-MASA `V_r`, the picked atom of every MASA containing `r` must agree on whether `r` is "1" or "0".

This is equivalent (per the standard topos-QM construction) to a `{0, 1}`-valuation `v : Rays → {0, 1}` such that for every triad `T = {r_1, r_2, r_3}`, exactly one of `v(r_1), v(r_2), v(r_3)` equals 1.

**`|GlobalSections(Σ_Q)|` = number of such valuations.**

By the Peres-Kochen-Specker theorem, this number is **0** for the full 40-triad set on `M_3(C)`. The KS proof IS the theorem that this number is zero; we are making it computational.

**Comparator: minimal `C^3`.** The minimal commutative comparator is the abelian C*-algebra `C^3` itself, with context category `V_0 ≤ V_C = C^3` (2 contexts, spectrum sizes 1 and 3). It has `|GlobalSections(Σ_{C^3})| = 3` (one global section per atom of `C^3`).

**Structural break:** `|GlobalSections(Σ_Q)| = 0` vs `|GlobalSections(Σ_{C^3})| = 3`. Strict inequality.

## 5. Best-effort same-Hasse comparator (deferred to v5.1)

A best-effort poset-isomorphic commutative comparator `C^N` would mirror the 40-triad-16-sub-MASA structure of the quantum side using a commutative algebra. The construction is non-trivial: we would need a commutative C*-algebra with 40 maximal subalgebras sharing 33 rank-1 projections in the Peres-orthogonality pattern.

By the KS theorem itself, no such commutative algebra exists with the EXACT same Hasse structure that supports a "selecting" global section: if it did, the Peres no-coloring argument would apply, giving 0 global sections, but every commutative algebra has at least one character (= at least one global section). The construction must therefore "break" at some point during attempted poset-iso construction.

Documenting the break-point of the best-effort `C^N` construction (e.g., "the maximal subalgebra structure forces an algebra dimension contradicting commutativity") is itself a witness to KS. This is interesting but secondary to the primary `|GlobalSections|` count. **v5.1 may address this; v5 focuses on the primary signal.**

## 6. Implementation methodology (Approach 3)

The full `Sub_cl(Σ_Q)` enumeration is computationally infeasible at 74 contexts (lattice size easily exceeds `10^9`). v5 skips it entirely and computes `|GlobalSections|` directly via constraint satisfaction:

**Variables:** 57 boolean variables `v_1, ..., v_57`, one per ray.

**Constraints:** 40 "exactly-one-of-three" predicates, one per triad.

**Method:** Mathematica's `SatisfiabilityCount[expr, vars]` (BDD-based).

Expected runtime: seconds. The search space is `2^57 ≈ 1.4 × 10^17` but the 40 constraints heavily prune it; modern BDD-based counting handles this trivially.

## 7. Script architecture

```
PART 0: Define Peres-33 vectors (Table 3.1 of Aravind & Lee-Elkin 2007).
PART 1: Define 16 explicit triads (Peres Table 3.2 top).
PART 2: Define 24 dyads (Peres Table 3.2 bottom).
PART 3: Compute 24 dyad-completion rays via cross products. Verify orthogonality.
PART 4: Combine into 57 rays + 40 triads. Sanity-check ray uniqueness modulo proportionality.
PART 5: Define the 57 boolean variables and 40 "exactly-one-of-three" constraints.
        Compute |GlobalSections(Σ_Q)| via SatisfiabilityCount. EXPECT: 0.
PART 6: Compute |GlobalSections(Σ_{C^3})| analytically. RESULT: 3.
PART 7: Verdict: structural break detected iff |GlobalSections(Q)| < |GlobalSections(C_min)|.
```

The script will be `wolfram/physics-anchor/four-position-physics-v5.wl`, written self-contained (no dependency on v2/v3/v4 machinery) since we are bypassing `Sub_cl(Σ)` enumeration.

## 8. What v5 will and will not establish

**Will establish (primary signal):**
- `|GlobalSections(Σ_Q)| = 0` for `M_3(C)` with the Peres-33 (57-40) context category. This is the Kochen-Specker theorem rendered as a computation in the framework's machinery.
- `|GlobalSections(Σ_{C^3})| = 3`. Strict inequality. **The categorical structural-break signal fires.**
- The framework's machinery (operating on `Σ` and counting global sections) is *categorically sensitive* to quantum non-classicality at the KS threshold.

**Will not establish:**
- A Lean Layer-L theorem. The Bohrification construction is not formalised in Mathlib; v5 is a Wolfram-level computational witness, not a kernel-checked proof.
- A four-cell partition with non-vacuous cells at a quantum-specific kernel. At `|GlobalSections| = 0`, the natural kernel `a* = ⋁ GlobalSections = ⊥`, and the partition at `⊥` is trivial (everything is in `(b ∧ a) = ⊥` so Distribution = full; cells degenerate). v5 reframes the signal as the global-section count itself, not the four-cell partition at a specific kernel.
- Any claim about which physics phenomena the cells correspond to. v5 establishes the *categorical structural break*, not its interpretive cell-by-cell reading.

The interpretive reading remains future work (a v6 follow-up could attempt to define a non-trivial kernel even at `|GlobalSections| = 0`, e.g., the "outer presheaf" `O_P` of a specific KS-witnessing projection, and compute its four-cell partition).

## 9. Connection to the four-position partition theorem

The four-position partition (`paper.md` Theorem 5.1) requires a Heyting kernel `a` and computes cells relative to `a`. v5's signal `|GlobalSections|` is not directly a kernel choice; it is a *cardinality invariant* of the spectral presheaf. The connection:

- If `|GlobalSections(Σ_Q)| = 0`, then the "global-section subobject" `a* = ⋁ atomic-everywhere subs = ⊥`, and the four-cell partition at `a*` collapses: `Infrastructure = {⊥}`, `Refusal = ∅`, `Exploitation = ∅`, `Distribution = Sub_cl(Σ) \ {⊥}`. Trivial cells.
- The signal `|GlobalSections(Σ_Q)| < |GlobalSections(Σ_C)|` is therefore a *pre-partition* witness — it detects the structural feature (KS-blocking) without committing to a specific kernel-derived partition.

This is appropriate for a *feasibility* result: v5 demonstrates that the framework's machinery hosts the KS witness as a finite computation. A future v6/v7 would build the four-cell partition at a non-trivial kernel of physical significance (e.g., the daseinisation of a specific Peres-KS projection), giving the interpretive reading.

## 10. Expected outcome and committal

Per the KS theorem, `|GlobalSections(Σ_Q)| = 0` is *theoretically guaranteed* for the full 40-triad Peres set on `M_3(C)`. v5's role is to *verify this computationally* in the framework's machinery, not to discover it. The committal:

- If v5 returns `|GlobalSections(Σ_Q)| = 0`: confirms the framework's machinery faithfully computes the KS witness. **Physics anchor structural break established.**
- If v5 returns `|GlobalSections(Σ_Q)| > 0`: indicates a bug in the script's encoding of the Peres rays, triads, or constraint logic. Debug and re-run. (The mathematical result is not in question; the computation must match it.)
- The classical side `|GlobalSections(Σ_{C^3})| = 3` is trivial; any deviation indicates a script bug.

After v5 executes successfully, the physics anchor's `Status` line in `physics-anchor/feasibility.md` will be updated to record: **categorical structural-break signal established at dim 3 with Peres-33 (57-40) configuration; framework's machinery faithfully witnesses Kochen-Specker theorem as a finite-dimensional computation.**

This is the milestone that v1, v2, v3, v4 were collectively scoping. v5 fires it.

---

## 11. Results from the run (2026-05-26)

The v5 script executed against Wolfram Cloud on 2026-05-26. Every check passed; the structural-break signal fired as predicted.

### 11.1 Pre-SAT verification (Parts 0–4)

| Check | Result |
|-------|--------|
| Peres rays defined | 33 (expect 33) ✓ |
| Explicit triads defined | 16 (expect 16) ✓ |
| Dyads defined | 24 (expect 24) ✓ |
| All 16 explicit triads mutually orthogonal? | True ✓ |
| All 24 dyads orthogonal? | True ✓ |
| Sample dyad-completion ray (`{10, 27} →`) | `(√2, 3, -1)` ✓ (matches independent hand calculation) |
| All completion rays orthogonal to their dyad? | True ✓ |
| Total rays | 57 (expect 57) ✓ |
| Total triads | 40 (expect 40) ✓ |
| All 40 triads mutually orthogonal? | True ✓ |
| Ray-incidence histogram | `{1→24, 2→6, 3→24, 4→3}` (33 Peres rays appear 2–4 times each; 24 completion rays appear 1 time each, as predicted) |
| Total contexts | 1 + 33 + 40 = 74 ✓ |

The ray-incidence histogram is itself worth noting: among the 33 explicit Peres rays, 3 appear in 4 triads each (these are rays 1, 2, 3 — the three coordinate axes), 24 appear in 3 triads each (the "(2,1,1)-type" and "(√2,1,1)-type" rays), and 6 appear in 2 triads each (the "face-diagonal" rays 4–9). Sum: 3·4 + 24·3 + 6·2 = 12 + 72 + 12 = 96 = number of ray-slots in 32 triads (16 explicit + 16 dyad-converted-to-triad). Plus the 24 completion-ray-slots (one per implicit triad). Total ray-slots: 96 + 24 = 120 = 40 triads × 3 slots ✓.

### 11.2 The SAT count (Part 5): **0**

```
|GlobalSections(Σ_Q on M_3(C))|  =  0
elapsed:                              0.024 seconds
```

`SatisfiabilityCount` returned **0** with 57 boolean variables and 40 exactly-one-of-three constraints, in **24 milliseconds**. This is the Kochen-Specker theorem rendered as a finite computation in the framework's machinery.

### 11.3 The classical comparator (Part 6)

```
|GlobalSections(Σ_C_min on C^3)|  =  3
```

The minimal commutative comparator `C^3` has exactly 3 atomic-everywhere clopen subobjects (one per atom of `C^3`), as predicted analytically.

### 11.4 Verdict

```
Strict inequality |Sections(Q)| < |Sections(C)|?  True

STRUCTURAL BREAK DETECTED.
```

`0 < 3` strictly. The categorical structural-break signal fires.

### 11.5 What this establishes

1. **The framework's machinery faithfully witnesses Kochen-Specker.** The Bohrification construction (Heunen-Landsman-Spitters 2009) + Døring's stagewise Heyting NOT (Døring 2012) produce a spectral presheaf `Σ_Q` whose global-section count equals exactly the number of consistent valuations of the Peres-33 configuration — and at the full 40-triad set, that number is zero by KS. v5 computes this in 24 ms.

2. **The categorical signal is established at dim 3.** All previous checkpoints (v2 shape-driven non-vacuity, v3 cell-cardinality at dim 2, v4 non-regular daseinisation at sub-KS-blocking dim 3 *in the framework's truncated context category*) were *quantitative* sensitivity findings. v5 is *categorical*: the quantum count is structurally distinct (= 0) from any commutative count (≥ 1). The strict inequality is the signature.

3. **The physics anchor's structural-feasibility claim is now established.** This is the milestone analogous to the music anchor's tritone non-vacuous four-cell partition. The framework's apparatus extends to physics in the structurally-required sense: there exists a finite, computable witness in `Sub_{cl}(Σ)` for a published quantum-foundations theorem (KS), realised via the framework's own machinery.

4. **The categorical signal is robust to the §3.5 truncation choice.** Unlike v4's substructural non-regular daseinisation finding (which is conditional on the framework's truncation of `V(M_3(C))` and disappears in Døring's full `V(M_3(C))` — see `feasibility.md` §3.5 and §8.7), the v5 categorical signal holds in *both* the framework's truncated context category and Døring's full `V(M_3(C))`. The Kochen-Specker no-coloring statement applies to the 16 maximal MASAs alone; unshared sub-MASAs (whether truncated away or included as in Døring's full `V(N)`) add no global-section constraints, since the consistency requirement at a sub-MASA below a single maximal MASA is automatic. This robustness is what makes v5's headline distinct in status from v4's substructural finding.

### 11.6 What this does not establish (preserved scope honesty)

- **No Lean Layer-L theorem.** Bohrification is not in Mathlib; v5 is a Wolfram-level witness, not a kernel-checked proof. (The same gap exists for the music anchor's Layer-L beyond the divisor-lattice slice itself: the higher topos machinery is Wolfram-only there too.)
- **No four-cell partition at `a*`.** With `|GlobalSections(Σ_Q)| = 0`, the "global-section subobject" `a* = ⋁ GlobalSections = ⊥`, and the four-cell partition at `⊥` is trivial (all of `Sub_cl \ {⊥}` falls in Distribution; the other three cells are empty or singleton). v5 reframes the signal as the cardinality invariant of `Σ`, not as cells of the four-position partition.
- **The interpretive cell-by-cell physics reading is deferred to v6+.** A future v6 would attempt to define a non-trivial kernel — e.g., the daseinisation of one of the Peres-KS projections, or the "outer presheaf" complement-pair — and compute its four-cell partition for interpretive content.

### 11.7 Where this leaves the physics anchor

The physics anchor crosses the structural-feasibility threshold at the categorical level. Status (mirroring the music anchor's threshold-crossing at v3-path-b's non-vacuous tritone partition):

| Anchor | Threshold-crossing artefact | Threshold-crossing finding |
|--------|------------------------------|----------------------------|
| Music  | `wolfram/music-anchor/four-position-music-v3-path-b.wl` | Divisor lattice of 12 non-vacuous at tritone kernel; partition matches Tymoczko's transformational structure |
| Physics | `wolfram/physics-anchor/four-position-physics-v5.wl` | `Sub_{cl}(Σ_{M_3(C)})` with Peres-33 context category has `0` global sections; strictly less than minimal commutative comparator's 3 |

The cross-domain commitment (Brink 2026a *Kernels and Commas* §2.1, requiring at least six kernels across distinct domains) now has its first *cross-anchor* corroboration: two domain instances, two structurally distinct mathematical substrates (number-theoretic divisor lattice + Lewinian transformational groupoid for music; C*-algebraic Bohr topos + Kochen-Specker no-coloring for physics), one underlying framework apparatus producing a finite, computable structural-typology witness in each.

### 11.8 Open follow-ups (not gating)

- **v5.1 (best-effort same-Hasse comparator)**: construct a commutative `C^N` with a poset-iso context category to the quantum side and verify that *its* global-section count is `≥ 1` (it must be, since every commutative algebra has characters). Documents the precise structural mechanism by which the KS theorem blocks the commutative replication.
- **v6 (interpretive kernel)**: define a non-trivial kernel `a` from a physically motivated source (e.g., `δ(P)` for a Peres-KS projection `P`, or a Heyting-derived kernel that doesn't trivialise), compute the four-cell partition, attempt an interpretive cell-by-cell reading parallel to the music anchor's tritone-cell mapping.
- **Lean formalisation**: long-term, a Bohrification typeclass in Mathlib (or a successor formalisation library) would lift the v5 witness from Wolfram computation to kernel-checked theorem. Multi-month scope as recorded in `feasibility.md` §4.3.

None of these is gating for the physics-anchor structural-feasibility claim. v5 has fired that.
