# v6 Scope: Heyting-collapse theorem on Peres-33 — two-cell partition at every non-trivial kernel

**Author:** Chris Brink
**Date:** 2026-05-26 (pre-script; revised post-analytical-discovery); 2026-05-27 (v6a results filled in)
**Status:** Heyting-collapse theorem **VERIFIED** at the Peres-33 scale by `four-position-physics-v6a.wl` and `four-position-physics-v6.wl` PARTS 0–5 (74 contexts; `¬δ(P_1) = ⊥`, `¬¬δ(P_1) = ⊤`, `δ(P_1)` Heyting-non-regular, all confirmed). SAT-count cardinalities (`|Sub_cl|`, `|↓δ(P_1)|`) **deferred — Wolfram Cloud `memlimit` aborted the 187-variable SatisfiabilityCount at ~50 s**. The categorical signal is fully established analytically and computationally; only the specific `|I|` and `|E|` magnitudes await a non-cloud measurement.
**Predecessor:** `v5-scope.md` (categorical structural-break signal FIRED, robust to truncation).
**Companion:** `feasibility.md` §0 (level hierarchy: this memo is **quaternary-level (Layer-L)** work), §3.5 (truncation choice), §4.10–§4.11 (v5 results), §4.12 (v6 results), §8.1 (Heyting-collapse theorem, **upgraded by v6 from a kernel-conditional candidate to the verified global statement**), §8.7 (Døring reconciliation).

---

## 0. Where v6 sits in the framework (added 2026-05-27)

v6 is **quaternary-level (Layer-L) work** per `feasibility.md` §0. It builds rigor infrastructure under the partition theorem's mathematical apparatus instantiated on the Bohrification substrate. It does **not** speak to the framework's primary classification claim — that physics-interpretation works (Copenhagen → Infrastructure, Decoherence → Distribution, Quantum computing → Exploitation, Pilot wave → Commitment, Many-Worlds → Refusal, plus the long tail) map to the five positions. That claim sits at the classifier + corpus level and is independent of what v6 finds about the Layer-L substrate.

What v6 *does* speak to: how the four-position partition theorem's machinery behaves when instantiated on the framework's truncated Bohrification context category. The finding — that the truncated category Heyting-collapses, forcing a two-cell partition — is a precise structural theorem about *that specific Layer-L substrate*, useful as Lean-formalisation target (§8.8 of `feasibility.md`) and as a substrate-dependent contrast with the music anchor's four-cell partition. It is not, and cannot be, a refutation or confirmation of any specific classification of any specific physics-interpretation work.

The two-cell vs four-cell asymmetry between physics and music at the Layer-L level is a finding *about the substrates*, not about the cross-domain classification claim. Per the manifesto §5, the five positions are properties of how *works* engage their kernel; they are not derived from the lattice structure of any specific formal substrate. The framework's universal-classification claim therefore stands independently of whether the Layer-L substrate for a given domain produces a four-cell, two-cell, or any other partition magnitude.

---

## 1. Goal (revised post-analytical-discovery)

v5 fired the categorical structural-break signal (`|GlobalSections(Σ_Q)| = 0 < |GlobalSections(Σ_C_min)| = 3` at the Peres-33 KS-blocking configuration on `M_3(C)`, robust to the §3.5 truncation). The physics anchor has its categorical threshold-crossing artefact. v5 leaves explicitly open:

- **No four-cell partition at `a*`.** With `|GlobalSections(Σ_Q)| = 0`, the "global-section subobject" `a* = ⊥`, and the partition at `⊥` is trivial.
- **No interpretive content at the cell level.** The categorical signal is the cardinality invariant `|GlobalSections|`, not cells of the four-position partition theorem (`paper.md` Thm 5.1).

**Original v6 question:** does a non-trivial kernel at the Peres-33 configuration produce a four-cell partition with all four cells inhabited, paralleling the music anchor's tritone partition?

**v6 analytical pre-finding (worked out 2026-05-26 before writing the script; full derivation in §2 below):** **NO**, for a sharper structural reason than originally anticipated. The framework's truncated context category `V'(M_3(C))` is **Heyting-collapsed**: for every non-bottom clopen subobject `S ∈ Sub_{cl}(Σ_{V'(M_3(C))})`, `¬S = ⊥`. Consequently `¬¬S = ⊤` for every non-bottom `S`, and the four-position partition at any non-trivial kernel `a` collapses to a *two-cell* partition with `|R(a)| = 0` and `|D(a)| = 0`, while `|I(a)| = |↓a| - 1` and `|E(a)| = |Sub_{cl}| - |↓a|`.

This is not a failure of the framework; it is the framework correctly characterising a structural feature of the truncated topos. v6's revised goal is therefore:

1. **Verify the Heyting-collapse computationally at the Peres-33 scale** (74 contexts, 187 (V, χ) pairs): compute `¬δ(P_1)` and confirm it equals `⊥` numerically.
2. **Measure `|I(δ(P_1))|` and `|E(δ(P_1))|`** by SAT-counting `|↓δ(P_1)|` and `|Sub_{cl}(Σ_{V'(M_3(C))})|`.
3. **Document the two-cell partition as the structural signature of the truncated category** (paralleling music's four-cell partition at the tritone, with the asymmetry characterising the structural difference between the two substrates).

The §8 candidate theorem upgrades from "non-regular ⟺ FULL sub-context component, for daseinisations" to the cleaner global statement: *in the framework's truncated category `V'(A)` where `m_{V_k} = {V_0}` for every sub-MASA `V_k`, every non-bottom `S ∈ Sub_{cl}(Σ_{V'(A)})` satisfies `¬S = ⊥`*. This is stronger because it characterises the entire truncated category rather than a property of specific kernels.

---

## 2. The Heyting-collapse pre-finding (analytical derivation)

Before writing the script, the following structural fact was worked out by direct calculation on the truncated category. The script in §6 below verifies it computationally; the documentation in §11 (post-run) records the numerical confirmation.

**Heyting-collapse theorem (candidate, framework-scoped to the truncated category).** Let `A` be a finite-dim C*-algebra (in v6's instance, `A = M_3(C)`), and let `V'(A) ⊆ V(A)` be the framework's truncated context category (§3.5 of `feasibility.md`): one trivial context `V_0`, finitely many maximal MASAs, and sub-MASAs included only when shared between maximal MASAs. Assume the truncation is sufficiently sparse that `m_{V_k} = {V_0}` for every sub-MASA `V_k` (i.e., V_0 is the only context strictly below `V_k` in the truncated Hasse). Then:

> For every clopen subobject `S ∈ Sub_{cl}(Σ_{V'(A)})` with `S ≠ ⊥`, `¬S = ⊥` (the Heyting complement is bottom). Consequently `¬¬S = ⊤` for every non-bottom `S`, and every non-bottom `S` is Heyting-non-regular.

**Proof (sketch).** Let `S ∈ Sub_{cl}(Σ_{V'(A)})` with `S ≠ ⊥`. Since `|Σ(V_0)| = 1`, restriction validity forces `S_{V_0} = Σ(V_0) = {trivial}` whenever `S_V ≠ ∅` at any non-trivial context `V`.

At each sub-MASA `V_k`: the stagewise Heyting NOT formula (Døring 2012 Prop. 2) gives
`(¬S)_{V_k} = Σ(V_k) \ ⋃_{V' ∈ m_{V_k}} liftProj[V_k, V', S_{V'}] = Σ(V_k) \ liftProj[V_k, V_0, {trivial}]`.

The lift `liftProj[V_k, V_0, {trivial}] = {χ ∈ Σ(V_k) : χ|_{V_0} ∈ {trivial}}`. Since every character of `V_k` restricts to the unique character `trivial` of `V_0`, this lift covers all of `Σ(V_k)`. Hence `(¬S)_{V_k} = Σ(V_k) \ Σ(V_k) = ∅`.

At each maximal MASA `T_a`: the formula gives `(¬S)_{T_a} = Σ(T_a) \ ⋃_{V_k ∈ minimal(T_a)} liftProj[T_a, V_k, S_{V_k}]`. By the validity-of-result requirement (`Sub_{cl}(Σ)` is closed under Heyting operations), the restrictions of `(¬S)_{T_a}` to its sub-MASAs `V_k ∈ minimal(T_a)` must lie in `(¬S)_{V_k} = ∅`. Hence `(¬S)_{T_a} = ∅`.

So `(¬S)_V = ∅` at every `V ≠ V_0`. The v4 `heytingNot` correction at `V_0` (`result[V_0] = ∅` when all upper contexts are empty) then gives `(¬S)_{V_0} = ∅`. Therefore `¬S = ⊥`. ∎

**Consequences for the four-position partition.** For any non-bottom kernel `a ∈ Sub_{cl}(Σ_{V'(A)})`:

- `¬a = ⊥`, hence `¬¬a = ¬⊥ = ⊤`.
- **Infrastructure** `I(a) = {x ∈ Sub_{cl} \ {⊥} : x ≤ a} = ↓a \ {⊥}`. Size `|↓a| - 1`.
- **Refusal** `R(a) = {x ∈ Sub_{cl} \ {⊥} : x ≤ ¬a} = {x ≠ ⊥ : x ≤ ⊥} = ∅`. Size `0`.
- **Exploitation** `E(a) = {x ∈ Sub_{cl} \ {⊥} : x ≤ ¬¬a ∧ x ⋠ a} = {x ≠ ⊥ : x ⋠ a} = (Sub_{cl} \ ↓a)`. Size `|Sub_{cl}| - |↓a|`.
- **Distribution** `D(a) = {x : x ⊓ a ≠ ⊥ ∧ x ⊓ ¬a ≠ ⊥} = {x : x ⊓ a ≠ ⊥ ∧ x ⊓ ⊥ ≠ ⊥} = ∅`. Size `0`.

The four-cell partition collapses to a **two-cell (Infrastructure, Exploitation)** partition for *every* non-bottom kernel in the truncated category.

**Contrast with Døring's full `V(A)`.** In Døring's full context category, the self-generated minimal sub-MASAs `V_Q` for every projection `Q ∈ P(A)` are included in `m_V`. The lift from `V_Q` to `V` does not transparently cover `Σ(V)` (it covers only the characters where `Q` evaluates to 1), so the Heyting-collapse argument above fails. By Døring 2012 Prop. 5 + Cor. 2, daseinisations are Heyting-regular in the full `V(A)`, and the partition behaviour at a daseinisation kernel is correspondingly different (`R(δ(P)) ≠ ∅` is structurally possible).

The Heyting-collapse is therefore a *precise* statement about what the framework's truncation does to the topos-internal logic — distinguishing it cleanly from Døring's full construction.

## 3. Choice of kernel for verification

**Selected: `a := δ(P_1)`**, the outer daseinisation of `P_1 = |0⟩⟨0|` (the rank-1 projection onto Peres ray 1, the cardinal X-axis).

The Heyting-collapse theorem above is universal — it applies to any non-bottom kernel. Choosing `δ(P_1)` for the v6 verification is for concreteness and parallel with v4's daseinisation kernel:

1. **Parallel with v4.** v4 used `δ(P)` for an off-axis `P` and got `(i, r, e, d) = (8, 0, 128, 0)` — the same `(I, 0, E, 0)` pattern the Heyting-collapse theorem predicts at any non-bottom kernel. v6 confirms this is *not specific to v4's off-axis projection*; it is a property of the truncated category.

2. **Physically meaningful.** `δ(P_1)` is the topos-internal proposition "the system is in state P_1". Concrete and interpretable.

3. **Computationally illustrative.** `δ(P_1)` has a mix of FULL, single-character, and multi-character components across the 74 contexts (§5 below), demonstrating that the Heyting-collapse is not a feature of an atypically-structured kernel.

**Why not the alternatives.**

- *Outer-presheaf complement pair `(O^{P_1}, O^{¬P_1})`*: requires bi-Heyting structure on `Sub_{cl}(Σ)` (Døring 2012 §3), not implemented in v2-v5. Deferred.
- *Distinction-structure-determined kernel*: requires implementing a distinction structure on `T(M_3(C))`, multi-month scope. Deferred.
- *Different ray (e.g., a non-cardinal Peres ray)*: would change `|↓δ(P_k)|` but not the Heyting-collapse outcome. Tested via §11 if desired.

---

## 4. Computational verification programme

The Heyting-collapse theorem (§2) is established analytically. v6's computational role is to **verify the theorem at the Peres-33 scale** and **measure the actual two-cell sizes**. The Peres-33 truncated context category has 74 contexts (1 trivial + 33 sub-MASAs + 40 maximal MASAs) and 187 (V, χ) pairs (1 + 33·2 + 40·3 = 187).

**Three verification tasks:**

1. **Compute `δ(P_1)` at each context** via outer daseinisation on `M_3(C)`. Reuse v4.wl's projection arithmetic.
2. **Verify `¬δ(P_1) = ⊥`** by direct stagewise Heyting NOT computation. (The theorem predicts this; v6 confirms numerically.)
3. **Verify `¬¬δ(P_1) = ⊤`** by a second application of the stagewise NOT. (Follows from `¬⊥ = ⊤`; sanity check.)

**Two cardinality measurements** via SAT counting:

- `|Sub_{cl}(Σ_{V'(M_3(C))})| = SatisfiabilityCount[clopen-constraints, all 187 vars]`
- `|↓δ(P_1)| = SatisfiabilityCount[clopen-constraints ∧ below-δ(P_1), all 187 vars]`

(`|↓¬δ(P_1)| = 1` and `|↓¬¬δ(P_1)| = |Sub_{cl}|` are determined by the theorem; v6 can sanity-check by SAT count but they are not free measurements.)

**Cell sizes derived algebraically** (under the Heyting-collapse: `¬a = ⊥`, `¬¬a = ⊤`):

- `|I(δ(P_1))| = |↓δ(P_1)| - 1`
- `|R(δ(P_1))| = 0` (Heyting-collapse)
- `|E(δ(P_1))| = |Sub_{cl}| - |↓δ(P_1)|`
- `|D(δ(P_1))| = 0` (Heyting-collapse)

Check: `|I| + |R| + |E| + |D| = (|↓δ(P_1)| - 1) + 0 + (|Sub_{cl}| - |↓δ(P_1)|) + 0 = |Sub_{cl}| - 1` ✓ (matches partition theorem: all non-bottom subobjects classified).

**SAT-counting encoding (Approach 3, as v5).** Encode `s ∈ Sub_{cl}(Σ)` as 187 boolean variables `x[V, χ]` meaning "χ ∈ s_V". Clopen-subobject restriction-consistency is encoded as ~426 implications between variables across the 153 Hasse-cover edges (33 from V_0 to V_k; 120 from V_k to T_a for k ∈ triad_a ∩ [1..33]). "Below-a" constraints fix variables to 0 at (V, χ) where χ ∉ a_V.

**Expected runtime: seconds to a few minutes.** v5's SAT count (57 vars, 40 KS constraints, zero satisfying assignments) ran in 24 ms. v6's counts have more variables (187), more constraints (426), and non-zero answers, so longer — but BDD-based SAT counters scale gracefully.

---

## 5. The structure of `δ(P_1)` (analytical preview)

Ray 1 is the cardinal X-axis, `P_1 = |0⟩⟨0|`. The 33 Peres rays decompose into:

- **8 rays orthogonal to P_1**: rays 2, 3, 6, 9, 12, 13, 18, 19 (every ray with `e_1`-component = 0, i.e., starting with `{0, ...}`). These are exactly the rays sharing a triad with ray 1: triads {1,2,3}, {1,6,9}, {1,12,19}, {1,13,18} list them in pairs.
- **24 rays non-orthogonal to P_1**: the remaining Peres rays. None of their sub-MASAs distinguish `P_1` from `I - P_1` (the smallest sub-MASA projection dominating `P_1` is `I`).

Component-wise:

| Context type | Count | `δ(P_1)_V` |
|--------------|-------|-----------|
| `V_0` (trivial) | 1 | FULL (size 1) |
| `V_1` (ray 1's sub-MASA) | 1 | `{atom-P_1}` (size 1) |
| `V_k` for k ∈ {2,3,6,9,12,13,18,19} (P_k ⊥ P_1) | 8 | `{atom-(I - P_k)}` (size 1) |
| `V_k` for k ∈ 24 non-orthogonal rays | 24 | FULL (size 2) |
| Triads containing ray 1: {1,2,3}, {1,6,9}, {1,12,19}, {1,13,18} | 4 | `{atom-P_1}` (size 1) |
| Triads with exactly one ray ⊥ P_1 (e.g., {2,4,8}, {3,5,7}) | varying | `{atom-(I - P_k)-side}` (size 2) |
| Triads with no rays ⊥ P_1 | varying | FULL (size 3) |

The detailed split of the 36 triads not containing ray 1 will be computed by the script. Note: the Heyting-collapse theorem (§2) does not depend on this detail — it holds for any non-bottom `S`, regardless of the specific component pattern. The component-pattern data is for documentation and for computing the analytical-vs-numerical cross-check.

---

## 6. Script architecture (`wolfram/physics-anchor/four-position-physics-v6.wl`)

```
PART 0: Peres-33 ray data (33 explicit rays + 24 dyad-completion rays)
        — reused verbatim from v5.wl
PART 1: Context category truncated to v5 sub-MASA structure
        — 74 contexts: V_0 + 33 V_k sub-MASAs + 40 T_a maximal MASAs
        — Hasse covers: V_0 < V_k (33 edges); V_k < T_a iff k ∈ triad_a and k ≤ 33 (96 edges)
        — Total Hasse covers: 129 (33 + 96 = 16 explicit triads × 3 + 24 implicit triads × 2)
        — Spectra: V_0 size 1; V_k size 2; T_a size 3
        — Restrict maps: T_a → V_k for k ∈ triad_a (k ≤ 33); V_k → V_0
PART 2: M_3(C) projection arithmetic for daseinisation
        — Reused from v4.wl
PART 3: Compute δ(P_1) at each context
        — Outer daseinisation δ^o_V(P_1) at each of 74 contexts
        — Tabulate component sizes; cross-check against §5 analytical preview
PART 4: Compute ¬δ(P_1) via stagewise Heyting NOT (Døring 2012 Prop. 2)
        — Reuse v4.wl heytingNot function
        — VERIFY: ¬δ(P_1) = ⊥ (the Heyting-collapse, §2)
PART 5: Compute ¬¬δ(P_1) by second application
        — VERIFY: ¬¬δ(P_1) = ⊤
        — Confirm δ(P_1) ≠ ¬¬δ(P_1), i.e., δ(P_1) is Heyting-non-regular
PART 6: SAT encoding
        — 187 boolean variables x[V, χ]
        — 354 clopen-subobject implications across 129 Hasse-cover edges
          (= 33 V_0→V_k × 2 chars + 96 V_k→T_a × 3 chars)
PART 7: Compute |Sub_cl(Σ)| via SatisfiabilityCount
PART 8: Compute |↓δ(P_1)| via SatisfiabilityCount with below-δ(P_1) constraints
PART 9: Derive two-cell partition sizes:
        |I(δ(P_1))| = |↓δ(P_1)| - 1
        |R(δ(P_1))| = 0
        |E(δ(P_1))| = |Sub_cl| - |↓δ(P_1)|
        |D(δ(P_1))| = 0
        Sanity check: |I| + |E| = |Sub_cl| - 1
PART 10: Verdict — two-cell partition confirmed; Heyting-collapse verified numerically
```

---

## 7. Interpretive reading

Under the Heyting-collapse, the partition at `a = δ(P_1)` reads:

| Cell | Lattice condition | Topos-QM reading | Inhabited? |
|------|-------------------|------------------|------------|
| **Infrastructure** | `x ≤ δ(P_1)` | Clopen subobjects everywhere committed to ray 1 — propositions whose every contextual component lies inside the ray-1-aligned assignments. | **Yes** (`|↓δ(P_1)| - 1`) |
| **Refusal** | `x ≤ ¬δ(P_1) = ⊥` | Empty by Heyting-collapse: in the truncated topos, no non-bottom proposition is everywhere disjoint from `δ(P_1)`. **The Heyting structure cannot witness "denial" of a non-trivial commitment in this category.** | **No** (= 0) |
| **Exploitation** | `x ≤ ¬¬δ(P_1) = ⊤ ∧ x ⋠ δ(P_1)` | Clopen subobjects not below `δ(P_1)` but everywhere dominated by ⊤. Since `¬¬δ(P_1) = ⊤`, this is *all* non-bottom subobjects not in Infrastructure. **In the Heyting-collapse regime, Exploitation absorbs both "fringe" and "orthogonal" propositions that would normally split between E and D.** | **Yes** (`|Sub_{cl}| - |↓δ(P_1)|`) |
| **Distribution** | `x ⊓ δ(P_1) ≠ ⊥ ∧ x ⊓ ¬δ(P_1) ≠ ⊥` | Empty because `¬δ(P_1) = ⊥`, so the second conjunct is never satisfied. **The Heyting structure cannot witness "straddling" in this category either.** | **No** (= 0) |

**Cross-anchor reading.** The physics anchor's two-cell partition at any non-trivial kernel in the truncated Peres-33 substrate contrasts cleanly with the music anchor's four-cell partition at the tritone kernel on the divisor lattice of 12. The asymmetry is a *structural finding about how the two substrates differ*, not a failure of the framework:

- **Music** (divisor lattice of 12, tritone kernel): the lattice has *paired non-regularity* — non-trivial elements have non-trivial Heyting complements. All four cells inhabit at the tritone kernel.
- **Physics** (truncated Peres-33 substrate, any non-trivial kernel): the truncated topos has *Heyting-collapse* — every non-trivial element has `¬S = ⊥`. Two cells inhabit (Infrastructure, Exploitation); the other two are structurally empty.

The framework's partition machinery, applied uniformly to both substrates, correctly characterises each substrate's structural profile. The cross-domain commitment is realised: same apparatus, structurally interpretable but substrate-dependent findings.

---

## 8. What v6 will and will not establish

**Will establish:**

- Computational verification of the Heyting-collapse theorem at the Peres-33 scale: `¬δ(P_1) = ⊥` confirmed numerically across all 74 contexts.
- Measured `|Sub_{cl}(Σ_{V'(M_3(C))})|` and `|↓δ(P_1)|` at the Peres-33 scale.
- Derived two-cell partition sizes `(|I|, 0, |E|, 0)` at the `δ(P_1)` kernel.
- The §8 candidate theorem in `feasibility.md` upgrades from a kernel-conditional statement (v4 form: "non-regular if no sub-MASA atom dominates the kernel projection") to the global statement: *every non-bottom `S ∈ Sub_{cl}(Σ_{V'(A)})` has `¬S = ⊥` in any truncated category where `m_{V_k} = {V_0}` for every sub-MASA*. Stronger because it characterises the entire truncated topos, not just one kernel choice.
- A clean cross-anchor characterisation: physics produces two cells, music four; both findings are exact, both are computationally verifiable, both characterise their substrates precisely.

**Will not establish:**

- A four-cell partition with all four cells inhabited at any kernel in the truncated category. The Heyting-collapse is universal; no kernel choice in this truncation produces `|R| > 0`.
- The partition behaviour over Døring's full `V(M_3(C))`. There, daseinisations are Heyting-regular (Døring 2012 Prop. 5 + Cor. 2), and the partition at `δ(P_1)` would be quite different. `feasibility.md` §3.5 and §8.7 record this contrast.
- A Lean kernel-checked Layer-L theorem for physics. v6 is a Wolfram-level witness; the Lean formalisation requires a Bohrification typeclass in Mathlib (deferred — multi-month scope).
- A "best-effort same-Hasse classical comparator" computation (deferred to v6.1 if useful). The classical comparator would also exhibit Heyting-collapse since the truncation shape is the same; v6.1 would measure quantitative cell-size differences if any.

---

## 9. Connection to the four-position partition theorem (`paper.md`)

`paper.md` Theorem 5.1 states the four-cell partition holds in any elementary topos `C` with non-trivial distinction structure `(D, η, ι)`, applied to `Sub(D(Y))`. For v6 in the truncated category:

- `C = Sets^{V'(M_3(C))^op}` (the truncated Bohr presheaf topos)
- `D(Σ) = Σ` (using the trivial distinction structure: `D = Id`, `η = id`)
- `Sub(D(Σ)) = Sub_{cl}(Σ_{V'(M_3(C))})` (the lattice of clopen subobjects)
- `a := δ(P_1) ∈ Sub_{cl}(Σ)` (the kernel)
- `f := the inclusion x ↪ Σ for each clopen subobject x` (the morphism whose image is `x` itself)

The partition theorem says each `x ≠ ⊥` falls into exactly one of `IsInfrastructure(x), IsRefusal(x), IsExploitation(x), IsDistribution(x)`. v6 confirms this exact-one classification holds in the truncated topos, with `R` and `D` cells *structurally empty* (no `x ≠ ⊥` satisfies their conditions) but the *disjoint-and-exhaustive* property still holding. The theorem applies; the truncated topos happens to populate only two of the four cells.

(The "trivial distinction structure" choice is the simplest valid one and matches the music anchor's setup at the Layer-L worked example `FalseWork.Lattice.Examples.Div12`.)

---

## 10. Expected outcome

**Analytically predicted (§2 Heyting-collapse theorem):**

- `¬δ(P_1) = ⊥` (verified componentwise by v6 PART 4).
- `¬¬δ(P_1) = ⊤` (verified componentwise by v6 PART 5).
- `δ(P_1)` is Heyting-non-regular: `δ(P_1) ≠ ⊤ = ¬¬δ(P_1)`.
- `|R| = 0`, `|D| = 0` (Heyting-collapse).
- `|I| = |↓δ(P_1)| - 1` and `|E| = |Sub_{cl}| - |↓δ(P_1)|` (measured by v6 PARTS 7-9).

**The Heyting-collapse theorem stands or falls on the PART 4 verification.** If the script confirms `¬δ(P_1) = ⊥` at every context, the theorem is verified; if any component is non-empty, the theorem's hypotheses (or the v4 heytingNot implementation) need re-examination. The analytical derivation in §2 leaves little room for the latter, but the verification is the standard discipline.

**Measured numbers** (`|Sub_{cl}|`, `|↓δ(P_1)|`, hence `|I|` and `|E|`) are open — they depend on the specific structure of the truncated Peres-33 substrate and the chosen kernel. v6 produces them.

---

## 11. Results from the run

Two scripts were run: `four-position-physics-v6a.wl` (fast, no SAT) confirmed the Heyting-collapse verification (PARTS 0–5); `four-position-physics-v6.wl` (full, with SAT counts) re-ran the same verification and additionally measured `|Sub_cl|` and `|↓δ(P_1)|` (PARTS 6–9). All numbers below are from the Wolfram Cloud runs on 2026-05-27.

### 11.1 Pre-SAT verification (sanity checks)

- Context category: 74 contexts (1 trivial `V_0` + 33 `V_k` sub-MASAs + 40 `T_a` maximal MASAs).
- Spectra: `|Σ(V_0)| = 1`, `|Σ(V_k)| = 2`, `|Σ(T_a)| = 3`. Total `(V, χ)` pairs: **187**.
- Hasse-cover edges: **129** (33 `V_0→V_k` + 96 `V_k→T_a`).
- Restrict map (`T_1` → `V_1` sanity check):  `{T,1,1} → {V,1,+}`, `{T,1,2} → {V,1,-}`, `{T,1,3} → {V,1,-}`. Matches the analytical prediction in §5.
- `P_1 = projOfRay({1,0,0})`: idempotent verified, `Tr(P_1) = 1` verified.

### 11.2 `δ(P_1)` components (PART 3 output)

Spot-checks all match the §5 analytical preview:

| Context | `δ(P_1)` | Size | Match? |
|---|---|---|---|
| `V_0` | `{trivial}` | 1 (= FULL) | ✓ |
| `V_1` (ray-1 own sub-MASA) | `{{V,1,+}}` | 1 | ✓ |
| `V_2` (ray-2 ⊥ ray-1) | `{{V,2,-}}` | 1 | ✓ |
| `V_4` (ray-4 ≢ ⊥ ray-1) | `{{V,4,+}, {V,4,-}}` | 2 (= FULL) | ✓ |
| `T_1` = triad {1,2,3} | `{{T,1,1}}` | 1 | ✓ |
| `T_5` = triad {2,4,8} | `{{T,5,4}, {T,5,8}}` | 2 | ✓ |

**Component-size histogram** (size → count): `{1: 14, 2: 40, 3: 20}` (total 74 ✓).

**FULL / empty / partial distribution**:

- FULL: **45 contexts** (`V_0` + 24 `V_k`-FULL + 20 `T_a`-FULL).
- empty: **0 contexts**.
- partial: **29 contexts** (9 `V_k` partial + 20 `T_a` partial).

The non-empty support at every context confirms `δ(P_1) ≠ ⊥`, the hypothesis for the Heyting-collapse theorem (§2).

### 11.3 Heyting NOT computation (PART 4)

`heytingNot(cc, δ(P_1))` evaluated in 0.009 seconds on 74 contexts.

Sample components (all printed components are empty):

```
V_0:  {}     V_1: {}     V_2: {}     V_4: {}
T_1:  {}     T_2: {}     T_5: {}     T_11: {}
```

### 11.4 Heyting-collapse verification

> `NOT(δ(P_1))_V = ∅ at EVERY context? **True**`

The Heyting-collapse theorem (§2) is **computationally verified at the Peres-33 scale**: `¬δ(P_1) = ⊥` at every one of the 74 contexts. This is the headline finding for v6.

### 11.5 Double-NOT computation (PART 5)

`heytingNot(cc, ¬δ(P_1))` evaluated in 0.009 seconds.

- `¬¬δ(P_1) = ⊤? `**True** (matches `topSub(cc)`).
- `δ(P_1) = ¬¬δ(P_1)?` **False** (as predicted: `δ(P_1) ≠ ⊤` since `δ(P_1)` is empty at none of 74 contexts but `δ(P_1) ≠ Σ` because it has 29 partial components).

So `δ(P_1)` is non-bottom, non-top, and Heyting-non-regular, while its Heyting complement is `⊥`. Exactly the Heyting-collapse profile.

### 11.6 SAT-count cardinalities — **unmeasured (cloud memory limit)**

PART 6 set-up confirmed: 187 boolean variables, 354 clopen-subobject implications across 129 Hasse-cover edges. PARTS 7–8 SAT counts wrapped in 300-second `TimeConstrained`.

PART 7 ran for **50.087 seconds** and was aborted by Wolfram Cloud with:

```
Cloud::memlimit: This computation has exceeded the memory limit for your plan.
Out[]= $Aborted
```

PART 8 was likewise aborted (memory limit again, ran for 0.003 s before abort).

| Measurement | Value | Status |
|---|---|---|
| `\|Sub_cl(Σ_{V'(M_3(C))})\|` | **unmeasured** | Cloud memlimit at 50 s |
| `\|↓δ(P_1)\|` | **unmeasured** | Cloud memlimit |

The categorical signal does *not* depend on these cardinalities — the Heyting-collapse theorem (§2 / §11.4) is the structural finding, and it is fully verified. The cardinalities would refine the verdict by giving concrete `|I|`, `|E|` numbers; deferred to a non-cloud SAT engine, a local Mathematica run with more RAM, or a structural reformulation (e.g., direct downset enumeration of the implication DAG; or analytic combinatorics for the Peres-33 truncated category).

### 11.7 Two-cell partition sizes (PART 9) — **analytic shape established; cardinalities deferred**

The Heyting-collapse theorem (§2 / §11.4) entails:

- `|I(δ(P_1))| = |↓δ(P_1)| - 1` (unmeasured numerically; *positive* since `δ(P_1) ≠ ⊥` ⇒ `↓δ(P_1) ⊇ {δ(P_1)}`, so `|↓δ(P_1)| ≥ 2` and `|I| ≥ 1`).
- `|R(δ(P_1))| = 0` (established by §11.4: `¬δ(P_1) = ⊥`).
- `|E(δ(P_1))| = |Sub_cl| - |↓δ(P_1)|` (unmeasured numerically; *positive* since `δ(P_1) ≠ ⊤` — `δ(P_1)` is empty at 0 contexts but partial at 29).
- `|D(δ(P_1))| = 0` (established by §11.4).

Sanity (analytic): `|I| + 0 + |E| + 0 = |Sub_cl| - 1`. The two-cell partition shape `(>0, 0, >0, 0)` is established; the specific magnitudes await cardinality measurement.

### 11.8 Verdict

The Heyting-collapse theorem (§2) is verified at the Peres-33 scale. The four-cell partition collapses to a two-cell `(Infrastructure, Exploitation)` partition at `δ(P_1)` — and, by the global statement of the theorem, at every non-bottom kernel in the truncated category. The categorical structural finding is established; the cardinality refinement is deferred (cloud memlimit on the 187-variable SAT count).

### 11.9 Cross-anchor positioning

| Anchor | Substrate | Kernel | Heyting structure | Partition pattern |
|---|---|---|---|---|
| **Music** | Divisor lattice of 12 | Tritone (`a = {1,2,6}` / index 6) | Paired non-regularity | `(I, R, E, D)` all > 0 (four-cell, all inhabited) |
| **Physics** | Truncated Peres-33 on `M_3(C)` | `δ(P_1)` (and any non-bottom) | Heyting-collapse: `¬S = ⊥` for every non-bottom S | `(I, 0, E, 0)` (two-cell) |

Both findings are exact, both are computationally verifiable, both characterise their substrate precisely. The framework's partition machinery, applied uniformly, produces structurally interpretable but substrate-dependent results — the asymmetry between the two anchors is itself a finding about how the two substrates differ.

---

## References

- `preprints/four-position-partition/paper.md` — Theorem 5.1 (four-position partition) and Section 4 (cell predicates).
- `preprints/four-position-partition/physics-anchor/feasibility.md` — §3.5 (truncation choice), §4.10–§4.11 (v5 results), §4.12 (v6 results), §8.1 (Heyting-collapse theorem), §8.7 (Døring reconciliation).
- `preprints/four-position-partition/physics-anchor/v5-scope.md` — Approach 3 (SAT counting) and Peres-33 configuration.
- `preprints/four-position-partition/physics-anchor/v4-scope.md` — §11.4 (`δ(P)` Heyting-non-regularity mechanism in the truncated category).
- `preprints/four-position-partition/music-anchor/feasibility.md` — v3-path-b non-vacuous tritone partition (analogous milestone for music).
- Peres, A. (1991). Two simple proofs of the Kochen-Specker theorem. *J. Phys. A* 24, L175–L178.
- Döring, A. (2012). Topos-based logic for quantum systems and bi-Heyting algebras. *arXiv:1202.2750*.
- Heunen, C., Landsman, N. P., Spitters, B. (2009). A topos for algebraic quantum theory. *Commun. Math. Phys.* 291: 63–110.
