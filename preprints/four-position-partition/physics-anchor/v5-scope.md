# v5-scope: Peres-33 KS-blocking structural-break test on M_3(C)

**Author:** Chris Brink
**Date:** May 2026
**Status:** Pre-script design memo. Companion to `physics-anchor/feasibility.md` §4.8-§4.9 (v4 results) and `v4-scope.md` §11.6 (v5 target identified).

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
