# Physics-Anchor Feasibility Memo

**Author:** Chris Brink
**Date:** May 2026 (initial scoping, Route B exploration + Route A architectural framing + Route A computational checkpoint executed).
**Status:** Route B exploration executed (`wolfram/physics-anchor/four-position-physics-v1.wl`, all five candidates DEGENERATE); Route A scoping recorded below; **Route A computational checkpoint executed** (`wolfram/physics-anchor/four-position-physics-v2.wl` for candidates P1 and P2, `wolfram/physics-anchor/four-position-physics-v2-p3.wl` for candidate P3, all three NON-VACUOUS). Structural finding (§4.5): non-vacuity in `Sub_cl(Σ)` is driven by context-category shape (presence of non-trivial joins or incompatible maximal contexts), not by quantum non-commutativity per se. No physics Layer-L theorem kernel-checked in this round; no topos-level construction committed. Companion to the kernel-checked mathematical core (`preprints/four-position-partition/paper.md`) and to the music anchor (`preprints/four-position-partition/music-anchor/feasibility.md`), which together establish the framework's first formalised domain instance.

---

## 1. Purpose and scope

This memo scopes a concrete feasibility test for instantiating the four-position partition theorem (`paper.md`) in the physics domain, building on the kernel-checked mathematical core and the worked music anchor (Layer L kernel-checked in Lean; Layer T2 computationally verified; Layer D candidate space finitely enumerated).

The music anchor is the framework's first formalised domain instance. The cross-domain thesis of the broader project (Brink 2026a, *Kernels and Commas*, §2.1) commits to at least six kernels across distinct domains. With music carrying the load, the next-priority question is whether the apparatus extends to physics in a structurally comparable way — and if so, which physics structure carries the analog of the music anchor's divisor-lattice slice.

This memo does *not* commit to a physics Layer-L theorem. It records:

- **Route B** (this round): a computational exploration of several small physics-interpretable `O(P)`-style lattices, asking whether any of them hosts a non-vacuous four-cell partition without further theoretical commitment.
- **Route A architectural scoping**: the most plausible physics-anchor target — topos quantum mechanics, in the Isham/Döring/Heunen/Landsman/Spitters lineage — with explicit identification of what would be required for a future Lean Layer-L theorem and what remains deferred.
- **Route A computational checkpoint** (this round): a Wolfram-level enumeration of `Sub_{cl}(Σ)` over small finite context categories of the shape Bohrification produces (rather than the `O(P)`-style truncation Route B tested), with the stagewise Heyting structure of Døring 2012, asking whether the four-position partition is non-vacuous at the topos-quantum-mechanics level.

The intended audience is mathematical physicists and quantum-foundations researchers; the test target is a Heunen/Landsman-style "Bohrification" construction or a comparable non-Boolean Heyting-algebra slice of a quantum-mechanical context category.

---

## 2. What music established (and what it left open)

The music anchor (`music-anchor/feasibility.md`) demonstrates:

- A finite, concrete, non-Boolean Heyting algebra (the divisor lattice of 12, equivalently the subgroup lattice of `Z/12`) carries the four-position partition non-vacuously at a kernel of independent music-theoretic significance (the tritone).
- The lattice arises as `Sub_T(1)` for a recognisable elementary topos `T` (the presheaf topos on the join-irreducible poset `P = {2, 3, 4}` with `2 < 4`). Birkhoff duality verified computationally.
- A small candidate space of distinction structures lifting the lattice slice to a full Theorem-5.1 instance has been enumerated (5 substantive Moore families; 4 tritone-closing).
- An independent formalism (Tymoczko 2026 *Journal of Music Theory*, groupoid/vertex-group reformulation of transformational theory) identifies the same kernel-comma structural fact via algebraic-topology machinery rather than Heyting-algebra machinery; both formalisms converge on the same load-bearing structural phenomenon in two distinct mathematical categories.

What music leaves open is the question of *generality*: the framework's central thesis is cross-domain. A single worked instance demonstrates that the apparatus *can* be instantiated; it does not demonstrate that it *extends* to a structurally different domain. The physics anchor's purpose is to test the latter.

---

## 3. Route B: finite physics Heyting-slice exploration

The Route B Wolfram script (`wolfram/physics-anchor/four-position-physics-v1.wl`) tests six small physics-interpretable lattices for non-vacuous four-cell partition at any kernel choice. The candidates and their physics readings:

| ID | Lattice                          | Physics reading                                                    |
|----|----------------------------------|--------------------------------------------------------------------|
| A  | 1-qubit Bohr-context lattice     | Bohr context poset for `M_2(C)` restricted to `{C·I, ⟨X⟩, ⟨Y⟩, ⟨Z⟩}` |
| B  | Boolean-triple subalgebra poset  | One MUB triple on 2 qubits (e.g. `{ZI, IZ, ZZ}`), 3 atoms + 1 max |
| C  | Two disjoint Boolean triples     | Two MUB triples sharing only the trivial subalgebra               |
| D  | 2-qubit full MUB context lattice | Full Bohr context poset, 5 MUB triples partition 15 Paulis        |
| E  | 3-chain × 3-chain                | Two commuting observables, each with 3 refinement levels          |
| F  | Causal-diamond 4-event causet    | Sorkin-style causet down-set lattice                              |

### 3.1 Run verdict (executed 2026-05-25, v1.1)

All five candidates DEGENERATE. Final summary table from the v1.1 run:

| candidate                                              | max cells / 4 | verdict     |
|--------------------------------------------------------|---------------|-------------|
| A: 1-qubit Bohr-context lattice                        | 2             | DEGENERATE  |
| B: Boolean-triple subalgebra poset                     | 3             | DEGENERATE  |
| C: Two disjoint Boolean triples                        | 2             | DEGENERATE  |
| D: 2-qubit full MUB context lattice                    | (skipped)     | structural skip |
| E: 3-chain × 3-chain (commuting trichotomies)          | 2             | DEGENERATE  |
| F: Causal diamond (4-event causet)                     | 3             | DEGENERATE  |

No surveyed small finite physics-interpretable down-set-of-poset lattice hosts a non-vacuous four-cell partition.

**Note on candidate E (correction to v1.0/v1.1 physics reading).** The script's candidate E was built as the down-set lattice of the 3×3 grid poset `P = {0, 1, 2} × {0, 1, 2}` under componentwise order, which has 20 down-sets. This is *not* the same lattice as the product of two 3-chains viewed as a distributive lattice (which has 9 elements and is isomorphic to the divisor lattice of `p²q²` for distinct primes `p, q`). The physics reading "two commuting observables, each with 3 refinement levels" properly corresponds to the 9-element product lattice, not the 20-element down-set-of-grid lattice. By hand analysis, the 9-element product lattice *is* non-vacuous at kernels with non-regular elements in both components (e.g. `a = (1, 0)`), but it is isomorphic to a relabelled instance of the music divisor lattice; treating it as a physics anchor would be re-labelling, not a native physics finding. The script's E result (20-element down-set-of-grid degenerate) is the genuine structural finding; the candidate-G amendment would not add anchor evidence and is not executed.

### 3.2 Structural diagnosis

The degeneracy across all five candidates reduces to a single structural fact: **none of the surveyed lattices contains a non-regular element whose Heyting complement is non-bottom**. The music divisor lattice does have this property at the tritone — `a = 2` is non-regular (`¬¬2 = ¬3 = 4 ≠ 2`), and its Heyting complement `¬a = 3` is non-trivial (`3 ≠ 1 = ⊥`); the elements `6` and `12` straddle `a` and `¬a` non-trivially, so Distribution fills as well. The five physics candidates lack this property in two distinct modes:

- **A, C, E: common-minimum obstacle.** When the underlying poset has a single global minimum, every non-empty down-set in `O(P)` contains that minimum, so every non-trivial element has Heyting complement `⊥`. Refusal and Distribution collapse simultaneously at every kernel; max cells = 2. This is the same obstacle the music exploration met in v1 and v2 (diatonic-closure-over-`Z/12`) before pivoting to the divisor-lattice slice in v3-path-b: down-set-of-poset constructions with a global bottom are not the right form for the partition. The join-irreducible poset of the music divisor lattice (`P_jirr = {2, 3, 4}` with `2 < 4` and `3` incomparable to either) escapes this obstacle precisely because it has *no* global minimum — `2` and `3` are both minimal, incomparable to each other.

- **B, F: "Boolean except at one node" obstacle.** The lattice has at least one non-regular element, but every non-regular element has its Heyting complement equal to `⊥`, while every element with a non-trivial Heyting complement is regular (so `¬¬a = a` and the closure-residue is empty). Either way, the kernel cannot simultaneously satisfy "non-regular" *and* "has non-bottom Heyting complement"; the degeneracy is again forced, with max cells = 3 rather than 4 because at least one of {Exploitation, Refusal+Distribution} always collapses depending on whether the kernel is regular.

Both modes fail the same underlying requirement: existence of a non-regular element whose Heyting complement is non-bottom. Growing A's three Pauli atoms into C's six (two MUB triples) just compounds the common-minimum obstacle. Going to D's full 2-qubit MUB context lattice (21 poset elements, 59,050 down-sets) would compound it further; this is why the explicit skip is correct rather than premature.

**Correction to an earlier framing.** A working note in the immediately-prior round used the phrase "paired non-regularity" to describe this requirement (a non-regular element whose Heyting complement is itself non-regular). That phrasing was wrong, and the property it described is mathematically impossible in any Heyting algebra: the identity `¬¬¬x = ¬x` makes `¬x` always equal to `¬¬(¬x)`, so `¬x` is always regular regardless of whether `x` is. The correct diagnosis — and the one the partition theorem actually requires at the kernel — is the simpler condition above: existence of a non-regular element with non-bottom Heyting complement. Verification on the music divisor lattice: `¬2 = 3` (non-bottom; `3 ≠ 1`), and `¬¬3 = ¬4 = 3` so `3` is regular, as it must be.

### 3.3 What this tightens

The Route-A scoping in §4 was originally framed as *"Bohrification is the most plausible target; small finite truncations might also work."* The Route-B finding upgrades this framing:

**No small finite `O(P)` down-set-of-poset-with-global-minimum lattice rescues the partition. But the full Bohrification construction `Sub_{T(A)}(Σ)` is *not* of this form, so the obstacle that defeats Route B does not transfer to Route A.**

This is the crucial structural point. The Route-B candidates are all of the form `O(P)` for some poset `P` with a global minimum (the trivial subalgebra, the bottom causet event, etc.), and the Heyting structure on `O(P)` is given by "largest down-set disjoint from the input." In any such lattice, the global-minimum constraint forces `¬(non-empty) = ⊥`. The full Bohrification target `Sub_{T(A)}(Σ)` is not a down-set lattice of the context category; it is the lattice of (clopen) subobjects of the spectral presheaf, with a much richer Heyting structure given stagewise by `P_{(¬S)_V} = 1 - ⋁_{V' ∈ m_V} P_{S_{V'}}` (Döring 2012, Prop. 2). This formula does *not* inherit the global-minimum obstacle of the underlying context poset `V(A)`; the Heyting complement of a non-empty subobject can be (and generically is) far from `⊥`.

Combined with three established structural facts from the topos-quantum-mechanics literature:

1. `Sub_{T(A)}(Σ)` is non-Boolean whenever `A` is non-commutative (HLS 2009).
2. Tight clopen subobjects — including all daseinisations of quantum projections — are Heyting-regular (Døring 2012, Prop. 5 + Cor. 2). The non-tight clopen subobjects are where the non-regular elements live.
3. Hence non-regular elements of `Sub_{cl}(Σ)` exist generically.

— the open structural question for Route A reduces to: **for some small finite-dim `A`, does there exist a non-regular `S ∈ Sub_{cl}(Σ)` with `¬S ≠ ⊥`?** Døring 2012 does not state this as a theorem, but the formula-level structure (Prop. 2 above) suggests the answer is generically yes, and a small-`A` explicit computation can settle it directly.

So the Route-B exhaustion narrows the search space rather than supplementing it: small finite truncations of the context category do not approximate the partition-relevant structure of the full topos. But the path through `Sub_{T(A)}(Σ)` for non-trivial finite-dim `A` remains tractable as a Wolfram-level computation — substantially more tractable than the prior round's "Route A is multi-month formalisation work" framing suggested. The next concrete step is the Route-A computational checkpoint in §4.4 below, which has now been executed; §4.5 records the structural finding it produced.

---

## 4. Route A: topos quantum mechanics as the architectural target

The most plausible physics analog of the music anchor's layered (L/T/D) structure is the Bohrification programme of Isham, Döring, Heunen, Landsman, Spitters, Caspers, and their collaborators (2002–present). The cleanest reference points are Heunen-Landsman-Spitters 2009 ("A topos for algebraic quantum theory," *Communications in Mathematical Physics* 291:63–110), Döring-Isham 2007 ("A topos foundation for theories of physics," I–IV, *Journal of Mathematical Physics* 49:053515–8), and Heunen-Landsman-Spitters 2011 ("Bohrification," in *Deep Beauty*, ed. Halvorson, Cambridge).

### 4.1 What Bohrification constructs

Given a unital C*-algebra `A` (the algebra of bounded observables of a quantum system), Bohrification constructs:

1. The **context category** `C(A)`: the poset of unital *commutative* C*-subalgebras of `A`, ordered by inclusion. Each object of `C(A)` is a "Bohr-classical context" — a maximal set of mutually compatible observables that can be measured simultaneously.

2. The **Bohr topos** `T(A) = [C(A), Set]` (covariant presheaves on `C(A)`). This is an elementary (in fact Grothendieck) topos. Its internal logic is intuitionistic, not Boolean; its subobject classifier `Ω_{T(A)}` is non-Boolean whenever `A` is non-commutative.

3. The **spectral presheaf** `Σ` ∈ `T(A)`: assigns to each context `C ∈ C(A)` the Gelfand spectrum `Σ(C)` of that commutative subalgebra. The spectral presheaf plays the role of "phase space" inside the topos.

4. The **subobject lattice** `Sub_{T(A)}(Σ)`: a complete Heyting algebra whose elements are interpreted as propositions about the quantum system. This is the lattice on which Bohrification's logical apparatus lives.

`Sub_{T(A)}(Σ)` is a non-Boolean Heyting algebra by construction whenever `A` is non-commutative. This is the structural feature the framework's partition theorem requires.

### 4.2 Mapping to the framework's layered architecture

| Framework layer | Music anchor                       | Physics anchor (Route A target)              |
|-----------------|------------------------------------|----------------------------------------------|
| **L (lattice)** | Divisor lattice of 12 (6 elements) | `Sub_{T(A)}(Σ)` for some finite-dim `A`      |
| **T (topos)**   | `Sh(L)` or `Set^{P^op}` (presheaf on join-irreducibles) | `T(A) = [C(A), Set]` (Bohr topos)           |
| **D (distinction)** | Idempotent monad on `T` with kernel image at tritone | Idempotent monad on `T(A)` with kernel image at a non-regular element of `Sub_{T(A)}(Σ)` |

The structural correspondence is tight: both are presheaf topoi on small posets, both have non-Boolean subobject lattices, both admit closure-operator distinction structures. The differences are in size, in physical content, and in the existing formalisation depth.

### 4.3 What is achievable in this round

**Not Lean Layer L.** The Bohrification construction is not formalised in Mathlib. There is no `BohrTopos` typeclass, no `SpectralPresheaf` definition, no formalised C*-subalgebra context category. Formalising even the finite-dimensional case from scratch is a multi-month project on a tight estimate. This is not in scope for this round.

**Not a Wolfram L-instance for full `M_2(C)`.** The discrete-MASA sub-poset of `C(M_2(C))` is exactly what Route B candidate A tested, and the run confirmed it degenerate (§3.1). Computing `Sub_{T(M_2(C))}(Σ)` over the full continuum of MASAs requires sheaf-theoretic machinery beyond a Wolfram-level exploration, and the Route-B finding now indicates that this richer construction is *required* rather than optional (§3.3): the discrete truncation does not approximate the partition-relevant structure of the full topos.

**Achievable now (Route A artefact):** a structural core entry in `wolfram/cores/` for Heunen-Landsman-Spitters 2009, modelling the Bohrification construction the same way `wolfram/cores/tymoczko-2026.wl` models Tymoczko's groupoid reformulation — as an independent corroborator that identifies the same kernel-comma structural phenomenon in a different mathematical category. This is committed (see `wolfram/cores/heunen-landsman-spitters-2009.wl`).

**Achieved now (Route B artefact):** the finite-physics-lattice exploration described in §3, executed v1.1, all five candidates DEGENERATE, structural diagnosis recorded.

**Achieved now (Route A computational checkpoint):** the `Sub_{cl}(Σ)` enumeration described in §4.4, executed v2 + v2-p3, three of three tested context categories (P1, P2, P3) NON-VACUOUS, with the shape-driven structural finding in §4.5.

**Deferred (Route A formal anchor):** a finite-dimensional Bohr-topos worked example with the four-position partition computed on `Sub_{cl}(Σ)` *and* a kernel choice that witnesses quantum non-classicality specifically. Provisionally targeted at `A = M_2(C) ⊕ C` (a minimal non-trivial non-commutative finite-dim C*-algebra) or `A = M_3(C)` (smallest dimension at which Kochen-Specker bites; richer `Sub_{cl}(Σ)` structure). The §4.4 checkpoint established shape-driven non-vacuity; the deferred work is the kernel-choice question of §4.5.

### 4.4 Computational checkpoint for Route A (executed)

A focused Wolfram-level checkpoint was scoped, executed (2026-05-26), and committed: `wolfram/physics-anchor/four-position-physics-v2.wl` (candidates P1 and P2) and `wolfram/physics-anchor/four-position-physics-v2-p3.wl` (candidate P3, split out for tractability in the Wolfram Cloud environment). The question to settle was concrete:

> **For some small finite-dim context category modelling a piece of `V(A)`, does there exist `S ∈ Sub_{cl}(Σ)` such that `S` is non-regular (`¬¬S ≠ S`) and `¬S` is non-bottom (`¬S ≠ ⊥`), and does some non-bottom kernel admit a non-vacuous four-cell partition?**

The script computes `Sub_{cl}(Σ)` exhaustively for each finite context category, applies Døring's Prop. 2 stagewise Heyting NOT pointwise, and tabulates the four cells at every non-bottom kernel.

**Candidate context categories tested.** Each is a finite poset of contexts with explicit Gelfand spectra and restriction maps; the underlying algebra is named for orientation but not used directly in the computation. The categories are chosen to exhibit increasingly rich structural features the Route-B candidates lacked:

| ID | Context category                            | Underlying algebra              | Structural feature                                                                                          |
|----|---------------------------------------------|---------------------------------|-------------------------------------------------------------------------------------------------------------|
| P1 | "Diamond" `V_0 < V_a, V_b < V_top`          | Abelian `C^4` (commutative)     | Smallest context category with `m_{V_top}` non-singleton (`{V_a, V_b}`). Smallest non-trivial join. |
| P2 | "Triple-join" `V(C^3)` full sub-MASA poset  | Abelian `C^3` (commutative)     | `V_top` has three distinct minimal sub-contexts (`m_{V_top} = {V_1, V_2, V_3}`).                            |
| P3 | "Two-MASA" `{V_0 < V_a, V_b < V_topAB}` and `{V_0 < V_c, V_d < V_topCD}` joined at `V_0`, with `V_topAB` and `V_topCD` incomparable | Models e.g. Z-MASA and X-MASA of `M_2(C)` viewed as abelian `C^2`'s with refinements | Smallest finite-dim context category encoding non-commutativity through INCOMPARABILITY of maximal contexts. |

**Results (executed v2 + v2-p3, 2026-05-26):**

| Candidate | `|Sub_cl(Σ)|` | non-reg | non-reg ∧ `¬s ≠ ⊥` | kernels with all 4 cells | verdict |
|-----------|---------------|---------|--------------------|--------------------------|---------|
| P1: diamond                                | 48   | 32   | 17   | 16 of 47    | **NON-VACUOUS** |
| P2: triple-join (V(C³) sub-MASA poset)     | 96   | 32   | 25   | 24 of 95    | **NON-VACUOUS** |
| P3: two-MASA (incompatible maximal contexts) | 2210 | 1954 | 1699 | ≥1 of 2209  | **NON-VACUOUS** |

P3 used a short-circuit witness search (stops at first kernel with all four cells inhabited) rather than full kernel enumeration, so its count of all-4-cell kernels is reported as a lower bound. Sample witness kernels exhibit `(infrastructure, refusal, exploitation, distribution)` counts of `(4, 5, 1, 47)` for P1, `(8, 8, 1, 95)` for P2, and `(4, 235, 1, 2209)` for P3.

The literal answer to the §4.4 question is therefore **positive on three of three tested candidates**. The four-position partition has non-vacuous instances at the topos-quantum-mechanics level, and a Wolfram-level Layer-L analog for physics is feasible at this register. The non-vacuity does not depend on any of the tested candidates' specific identifications with quantum algebras — it follows from the topos-internal structure of `Sub_{cl}(Σ)` for context categories of these shapes.

### 4.5 Structural finding from §4.4: non-vacuity is shape-driven

The numerical results sharpen the structural picture in a way worth recording explicitly before any narrative about "physics anchor established" gets attached to them.

**The shape-driven finding.** Candidates P1 and P2 use *commutative* underlying algebras (`C^4` and `C^3`). Their non-vacuous verdicts therefore demonstrate that non-vacuity in `Sub_{cl}(Σ)` does *not* require the underlying C*-algebra `A` to be non-commutative. What it requires is the *context category* `V(A)` (or a finite truncation thereof) to have at least one context `V` with `m_V` non-singleton — i.e. with multiple distinct minimal sub-contexts. This is what the Route-B candidates uniformly lacked: A, B, C, E, F were all `O(P)`-style down-set lattices over posets with a single global minimum, where every non-bottom element down-closes onto the global minimum and the stagewise Heyting NOT degenerates pointwise to Boolean complementation.

Candidate P3 adds the non-commutativity-flavoured feature of incomparable maximal contexts (the Z-MASA and X-MASA of `M_2(C)` have no common refinement). It is non-vacuous, but it is non-vacuous through the same mechanism: each maximal context `V_topAB`, `V_topCD` has `m_V` non-singleton. The witness kernel sits entirely on one MASA-half (the CD-side: `V_c = {0_c}, V_d = {0_d}`, all other components empty), with the AB-side and `V_top`-components empty on both sides — exactly the structure that would work on a single diamond. The CD-incomparability of `V_topAB` and `V_topCD` adds nothing to the witness; it just enlarges `|Sub_{cl}(Σ)|`.

**What this means for the physics-anchor claim.** Non-vacuity of the four-position partition on `Sub_{cl}(Σ)` is therefore **necessary but not sufficient** for a claim that the framework witnesses quantum non-classicality. A claim of that strength would require additionally that the kernel `a`, or the distinction structure `D` generating it, is itself meaningfully physics-coupled — for example, that `a` is the daseinisation of a specific quantum projection corresponding to a Kochen-Specker-relevant proposition, and that `a`'s non-regularity comes out as a witness to a non-commutativity-driven feature rather than just to context-category shape.

The Route-A computational checkpoint as scoped in the previous version of §4.4 did *not* commit to this stronger claim. It asked the necessary-condition question ("does any non-regular `S` with `¬S ≠ ⊥` exist?") and got a positive answer. The sufficient-condition question ("does the partition tell us something specifically quantum?") remains open and is the natural next step.

**What this does and does not change in the architectural picture.**

- It does *not* invalidate the layered L/T/D mapping in §4.2: `Sub_{cl}(Σ)` is genuinely the right Layer-L target, the four-position partition does apply non-vacuously, and the structural-correspondence story with the music anchor (presheaf topos on a small poset, non-Boolean subobject lattice, closure-operator distinction structures) holds.
- It does *not* change the topos-quantum-mechanics literature's status as corroborator: HLS 2009 + Døring 2012 + the Bohrification programme remain the established machinery on which a physics Layer-L theorem would build.
- It *does* mean that the next round of physics work has to confront the question of *which kernel* in `Sub_{cl}(Σ)` carries the physics, not merely *that some kernel* yields a non-vacuous partition. The four-position cells are well-defined regardless of kernel choice; the question is which kernel makes the cells *do something specifically quantum* rather than purely structural.
- It *does* mean that the present round's positive verdict promotes the physics anchor from "indicated path with unsettled computational tractability" to "feasible at the shape-driven level, with the question of physics-specific kernel choice as the next gating step." The strength of the promotion is real but more measured than a naive reading of "three of three NON-VACUOUS" would suggest.

The §6 status table below reflects this calibrated reading.

**Open question for the next round.** What is the natural kernel `a ∈ Sub_{cl}(Σ_A)` for a non-commutative `A` such that `a`'s non-regularity comes out as a witness to non-commutativity, not to shape? Candidates worth investigating include (a) the daseinisation `δ(P)` of a projection `P ∈ A` that is itself non-classical (e.g. a Kochen-Specker projection in `M_3(C)` or larger), where Døring 2012 Prop. 5 says `δ(P)` is tight and therefore Heyting-regular but its complement structure may carry the relevant information; (b) the "outer presheaf" `O_P` complement-pair `(δ(P), δ(¬P))` whose joint behaviour in `Sub_{cl}(Σ)` Døring discusses; (c) a kernel determined by a distinction structure on `T(A)` rather than by a single Sub_cl element. This is research scope for a successor memo, not in scope here.

---

## 5. Independent corroboration: the topos-quantum-mechanics lineage

The Heunen-Landsman-Spitters / Döring-Isham programme plays for the physics anchor the role Tymoczko (2011, 2026) plays for the music anchor: an independent formalism that arrives at a structurally adjacent claim via different mathematical machinery.

### 5.1 What the lineage establishes (independently of FalseWork)

- Quantum mechanics admits a topos-theoretic reformulation in which logical structure is intuitionistic rather than Boolean.
- The non-commutativity of the observable algebra is captured at the level of the subobject classifier of the Bohr topos: `Ω_{T(A)}` is non-Boolean iff `A` is non-commutative.
- "Quantum propositions" in this reformulation are elements of a Heyting algebra (not the orthomodular Birkhoff-von Neumann projection lattice), and they admit a natural closure-operator structure.
- The construction is functorial: a morphism of C*-algebras induces a (suitably directed) morphism of Bohr topoi.

These are established results. The framework does not contribute to them; it observes that they put a non-trivial Heyting algebra in the same structural position as the divisor lattice of 12 in the music anchor. The four-position partition theorem (`paper.md`) then applies to this Heyting algebra by the same general apparatus that applies to any non-Boolean `Sub(D Y)` in any elementary topos with non-trivial distinction structure.

### 5.2 What the framework would add (if a physics Layer L is later constructed)

The four-position partition would provide a *typological* reading of regions of `Sub_{T(A)}(Σ)`:

- **Infrastructure:** propositions strictly inside the kernel image (the framework's analog of "definitely classical / definitely measurable in the chosen context").
- **Refusal:** propositions strictly in the Heyting complement of the kernel image (the framework's analog of "definitely outside the chosen classical context").
- **Exploitation:** propositions in the closure-residue (the framework's analog of "in the double-negation closure of the classical context but not in the context itself" — structurally analogous to the music anchor's diminished-7th-as-closure-of-tritone).
- **Distribution:** propositions straddling kernel and complement (the framework's analog of "neither fully classical nor fully non-classical in the chosen context").

These readings are *proposed* — the same way the music anchor's cell readings (tritone-as-Infrastructure, augmented-triad-as-Refusal, etc.) are proposed. The mathematics determines the partition; the readings are interpretive. They would constitute the framework's contribution if and when a physics Layer-L theorem lands.

### 5.3 Other physics-side corroborator candidates

Beyond the Bohrification lineage:

- **Causal-set theory** (Sorkin, Bombelli, Henson, Surya): causets are posets, and the down-set lattice of a causet is a Heyting algebra by general topological-locale reasoning. Route B candidate F probes the smallest version. A non-trivial causet anchor would belong to a different topos than Bohrification (`Sh(L)` for the down-set lattice `L`, not `[C(A), Set]`), but the lattice-level slice would be in the same framework register.

- **Spekkens toy models** (Spekkens 2005, 2007; Schmid-Selby-Spekkens 2021): finite hidden-variable models that reproduce qubit phenomenology. They have finite ontic state spaces and finite context structure; the operational logic is known to be sub-classical (analogous to topos-internal intuitionistic logic). A Spekkens-toy Layer-L slice would be smaller than Bohrification and possibly more directly computable.

- **Topos approaches to gauge theory and quantum gravity** (Flori 2013; Nuiten 2011): the same Bohrification machinery extended to algebras of local observables in QFT and to the holonomy algebras of loop quantum gravity. These are too heavy for a first physics anchor but mark the eventual extent of the apparatus.

These are recorded as alternative anchor candidates, not committed targets. The framework does not propose to write its physics anchor in any of them in this round.

---

## 6. Status summary

| Layer | Claim                                                          | Status                                                          |
|-------|----------------------------------------------------------------|-----------------------------------------------------------------|
| **Route B (this round)** | Finite physics-interpretable down-set-of-poset lattices either host or do not host a non-vacuous four-cell partition; structural fact one way or the other | **Executed v1.1 2026-05-25; all five tested candidates DEGENERATE.** Structural diagnosis in §3.2: the framework's machinery requires a non-regular element with non-bottom Heyting complement, which `O(P)`-style lattices over posets with a global minimum cannot supply. |
| **Route A architectural scoping** | The Bohrification (Heunen-Landsman-Spitters / Döring-Isham) programme is the physics-side architectural target; the layered L/T/D framework maps onto it cleanly | **Recorded in this memo + structural core entry committed** (`wolfram/cores/heunen-landsman-spitters-2009.wl`). Route B finding upgraded this from "most plausible target" to "indicated path" (§3.3, §4.3); Route A checkpoint result (next row) upgrades it further to "feasible at the shape-driven level". `Sub_{cl}(Σ)` is not an `O(P)`-style construction and does not inherit the Route-B obstacle. |
| **Route A computational checkpoint (this round)** | For some small finite-dim context category, does `Sub_{cl}(Σ)` contain a non-regular `S` with `¬S ≠ ⊥`, and does some kernel admit a non-vacuous four-cell partition? | **Executed v2 + v2-p3 2026-05-26; all three tested candidates (P1 diamond, P2 V(C³), P3 two-MASA) NON-VACUOUS.** Numerical results recorded in §4.4. Structural finding (§4.5): non-vacuity is driven by context-category shape (non-trivial joins; incomparable maximal contexts), *not* by quantum non-commutativity of the underlying algebra — P1 and P2 use commutative `C^4` and `C^3`. Physics-anchor promotion is "feasible at shape-driven level"; the kernel-choice question (does some specific kernel witness quantum non-classicality rather than mere shape?) is the next gating step. |
| **Physics Layer L (theorem)** | A finite-dim Bohr-topos worked example with the four-position partition computed on `Sub_{cl}(Σ)` *and* a kernel choice that witnesses quantum non-classicality | **Deferred.** Provisionally targeted at `A = M_2(C) ⊕ C`, `M_2(C) ⊕ M_2(C)`, or `M_3(C)` with the kernel chosen as a daseinisation of a Kochen-Specker-relevant projection. The shape-driven non-vacuity is now established (§4.4); the gating step is now the kernel-choice question (§4.5 open question) rather than the existence question. |
| **Physics Layer T (realisation)** | The Bohr topos `T(A)` realises the lattice slice as `Sub_{T(A)}(Σ)` | **Cited from Bohrification literature** (Heunen-Landsman-Spitters 2009; Döring-Isham 2007). |
| **Physics Layer D (distinction)** | A distinction structure on `T(A)` lifting the lattice slice to a Theorem-5.1 instance | **Architectural template recorded** (§4.2); concrete construction deferred. The §4.5 open question (which kernel witnesses quantum non-classicality?) is the structural prerequisite for picking the right distinction structure. |

---

## 7. Scope honesty

This memo records: *that* a physics anchor is the framework's next-priority extension target; *that* the topos-quantum-mechanics lineage is the architectural locus; *that* small finite `O(P)`-style physics-interpretable lattices uniformly fail to host a non-vacuous partition (Route B); and *that* small finite context categories with non-trivial joins do host non-vacuous partitions in `Sub_{cl}(Σ)` (Route A checkpoint, §4.4), with the structural caveat that this non-vacuity is shape-driven rather than non-commutativity-driven (§4.5).

It does *not* claim:

- a physics Layer-L theorem (kernel-checked or otherwise);
- that the Bohrification programme is itself novel or contributed by FalseWork (it is not; it is forty-plus years of joint work by the topos quantum mechanics community);
- that the four-position-partition readings of cells in `Sub_{T(A)}(Σ)` have been validated against any physics-foundations literature (they have not);
- that any specific physics test analogous to the music anchor's Coltrane test is currently feasible;
- that the §4.4 non-vacuity results constitute a witness to quantum non-classicality. They are a *necessary-condition* result for any future physics anchor; the *sufficient-condition* question — whether some kernel in `Sub_{cl}(Σ)` makes the partition track quantum non-classicality rather than mere context-category shape — is the §4.5 open question and is research scope for the next round.

The concrete commitments this round are the Wolfram exploration scripts (`v1.wl`, `v2.wl`, `v2-p3.wl`), the structural core entry (`heunen-landsman-spitters-2009.wl`), and this memo's scoping. The rest is scoping with explicit deferral.

---

## References

- Caspers, M., Heunen, C. (2009). Constructively complete finite-dimensional C*-algebras. (Used in the Bohrification programme.)
- Döring, A. (2012). Topos-based logic for quantum systems and bi-Heyting algebras. *arXiv:1202.2750*. (Load-bearing reference for the Heyting and co-Heyting structure on `Sub_{cl}(Σ)`, the regularity characterisations cited in §3.2 and §3.3, and the stagewise complement formula `P_{(¬S)_V} = 1 - ⋁_{V' ∈ m_V} P_{S_{V'}}` referenced in §4.4.)
- Döring, A., Isham, C. J. (2007). A topos foundation for theories of physics. I–IV. *Journal of Mathematical Physics* 49: 053515–053518.
- Flori, C. (2013). *A First Course in Topos Quantum Theory*. Springer Lecture Notes in Physics 868.
- Halvorson, H. (ed.) (2011). *Deep Beauty: Understanding the Quantum World through Mathematical Innovation*. Cambridge University Press. (Contains Heunen-Landsman-Spitters "Bohrification" chapter.)
- Heunen, C., Landsman, N. P., Spitters, B. (2009). A topos for algebraic quantum theory. *Communications in Mathematical Physics* 291: 63–110.
- Heunen, C., Landsman, N. P., Spitters, B. (2011). Bohrification. In Halvorson (ed.), *Deep Beauty*, Cambridge University Press.
- Isham, C. J. (1997). Topos theory and consistent histories: the internal logic of the set of all consistent sets. *International Journal of Theoretical Physics* 36: 785–814.
- Mac Lane, S., Moerdijk, I. (1992). *Sheaves in Geometry and Logic*. Springer.
- Nuiten, J. (2011). Bohrification of local nets of observables. *Master's thesis*, Utrecht University.
- Sorkin, R. D. (1991). Spacetime and causal sets. In *Relativity and Gravitation: Classical and Quantum*, World Scientific.
- Spekkens, R. W. (2007). Evidence for the epistemic view of quantum states: a toy theory. *Physical Review A* 75: 032110.
