# Physics-Anchor Feasibility Memo

**Author:** Chris Brink
**Date:** May 2026 (initial scoping, Route B exploration + Route A architectural framing).
**Status:** Route B exploration scripted (`wolfram/physics-anchor/four-position-physics-v1.wl`); Route A scoping recorded below. No physics Layer-L theorem kernel-checked in this round; no topos-level construction committed. Companion to the kernel-checked mathematical core (`preprints/four-position-partition/paper.md`) and to the music anchor (`preprints/four-position-partition/music-anchor/feasibility.md`), which together establish the framework's first formalised domain instance.

---

## 1. Purpose and scope

This memo scopes a concrete feasibility test for instantiating the four-position partition theorem (`paper.md`) in the physics domain, building on the kernel-checked mathematical core and the worked music anchor (Layer L kernel-checked in Lean; Layer T2 computationally verified; Layer D candidate space finitely enumerated).

The music anchor is the framework's first formalised domain instance. The cross-domain thesis of the broader project (Brink 2026a, *Kernels and Commas*, §2.1) commits to at least six kernels across distinct domains. With music carrying the load, the next-priority question is whether the apparatus extends to physics in a structurally comparable way — and if so, which physics structure carries the analog of the music anchor's divisor-lattice slice.

This memo does *not* commit to a physics Layer-L theorem. It records:

- **Route B** (this round): a computational exploration of several small physics-interpretable lattices, asking whether any of them hosts a non-vacuous four-cell partition without further theoretical commitment.
- **Route A** (architectural scoping): the most plausible physics-anchor target — topos quantum mechanics, in the Isham/Döring/Heunen/Landsman/Spitters lineage — with explicit identification of what would be required for a future Lean Layer-L theorem and what remains deferred.

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

So the Route-B exhaustion narrows the search space rather than supplementing it: small finite truncations of the context category do not approximate the partition-relevant structure of the full topos. But the path through `Sub_{T(A)}(Σ)` for non-trivial finite-dim `A` remains tractable as a Wolfram-level computation — substantially more tractable than the prior round's "Route A is multi-month formalisation work" framing suggested. The next concrete step is §4.4 below.

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

**Deferred (Route A formal anchor) — now indicated rather than optional, and more tractable than previously framed:** a finite-dimensional Bohr-topos worked example with the four-position partition computed on `Sub_{cl}(Σ)`. Provisionally targeted at `A = M_2(C) ⊕ C` (a minimal non-trivial non-commutative finite-dim C*-algebra) or `A = M_3(C)` (smallest dimension at which Kochen-Specker bites; richer `Sub_{cl}(Σ)` structure). See §4.4 for the explicit computational checkpoint.

### 4.4 Computational checkpoint for Route A

A focused Wolfram-level checkpoint is now scoped sharply. The question to settle is concrete:

> **For some small finite-dim non-commutative C*-algebra `A`, does there exist `S ∈ Sub_{cl}(Σ_A)` such that `S` is non-regular (`¬¬S ≠ S`) and `¬S` is non-bottom (`¬S ≠ ⊥`)?**

A positive answer establishes that the four-position partition has a non-vacuous instance at the topos-quantum-mechanics level and licenses a Wolfram-level Layer-L analog for physics, paralleling the music anchor's divisor-lattice slice. A negative answer (every non-regular `S` has `¬S = ⊥`) would be a strong structural finding, telling us that `Sub_{cl}(Σ)` has a global flatness that the framework does not currently anticipate.

Concrete computational plan:

1. **Target algebras** (in order of increasing structural richness):
   - `A_1 = M_2(C) ⊕ C` — minimal non-commutative finite-dim C*-algebra with non-trivial direct-sum structure. The context category `V(A_1)` has a finite discrete part (Boolean subalgebras of `C^3`) plus the `M_2(C)` part which carries the Bloch-sphere continuum of MASAs.
   - `A_2 = M_2(C) ⊕ M_2(C)` — two-qubit-like; richer context structure.
   - `A_3 = M_3(C)` — smallest matrix algebra at which Kochen-Specker theorem applies (`dim ≥ 3`). Context category is a continuum of MASAs over `C·1`; explicit computation requires discretising to a "stabilizer-type" sub-poset.

2. **Computational approach**: enumerate the discrete part of `V(A_i)`, build the presheaf `Σ` over this discrete context category, compute clopen subobjects pointwise, identify non-regular ones via Døring's Prop. 3 (`P_{S_V} = ⋀_{V' ∈ m_V} P_{S_{V'}}`), check Heyting complements via Døring's Prop. 2.

3. **Output**: either a small witness `(A_i, S)` exhibiting `S` non-regular with `¬S ≠ ⊥` (positive Route-A checkpoint; promotes physics anchor from "indicated" to "feasible"), or a structural finding that the discrete-context truncation of `Sub_{cl}(Σ)` inherits some not-yet-identified flatness (negative checkpoint; tells us either that the truncation is too coarse or that the framework needs modification at the topos level).

This is a Wolfram-level script comparable in scope to `four-position-physics-v1.wl` plus the new Heyting-stagewise machinery from Døring 2012. Estimate: a few days of focused work, not a multi-month formalisation. It is the natural successor to Route B and the right next step if physics is to be the second anchor. **Not committed in this round**, but scoped here so the prioritisation is concrete.

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
| **Route A architectural scoping** | The Bohrification (Heunen-Landsman-Spitters / Döring-Isham) programme is the physics-side architectural target; the layered L/T/D framework maps onto it cleanly | **Recorded in this memo + structural core entry committed** (`wolfram/cores/heunen-landsman-spitters-2009.wl`). Route B finding upgrades this from "most plausible target" to "indicated path" (§3.3, §4.3). Importantly, `Sub_{cl}(Σ)` is not an `O(P)`-style construction and so does not inherit the Route-B obstacle. |
| **Route A computational checkpoint (next step)** | For some small finite-dim `A`, does `Sub_{cl}(Σ)` contain a non-regular `S` with `¬S ≠ ⊥`? | **Scoped in §4.4, not committed in this round.** Concrete Wolfram-level script targeting `A = M_2(C) ⊕ C` or `M_3(C)`. Estimate: a few days. Positive answer promotes physics anchor from "indicated" to "feasible." |
| **Physics Layer L (theorem)** | A finite-dim Bohr-topos worked example with the four-position partition computed on `Sub_{cl}(Σ)` | **Deferred.** Provisionally targeted at `A = M_2(C) ⊕ C`, `M_2(C) ⊕ M_2(C)`, or `M_3(C)`; not in scope for this round. The §4.4 computational checkpoint is the gating prerequisite. |
| **Physics Layer T (realisation)** | The Bohr topos `T(A)` realises the lattice slice as `Sub_{T(A)}(Σ)` | **Cited from Bohrification literature** (Heunen-Landsman-Spitters 2009; Döring-Isham 2007). |
| **Physics Layer D (distinction)** | A distinction structure on `T(A)` lifting the lattice slice to a Theorem-5.1 instance | **Architectural template recorded** (§4.2); concrete construction deferred. |

---

## 7. Scope honesty

This memo is exploratory at the same register as the music anchor's pre-Path-B status. It records *that* a physics anchor is the framework's next-priority extension target, *that* the topos-quantum-mechanics lineage is the most plausible architectural locus, and *that* a small computational exploration has been scripted to test whether the apparatus transfers to small finite physics-interpretable lattices.

It does *not* claim:

- a physics Layer-L theorem (kernel-checked or otherwise);
- that the Bohrification programme is itself novel or contributed by FalseWork (it is not; it is forty-plus years of joint work by the topos quantum mechanics community);
- that the four-position-partition readings of cells in `Sub_{T(A)}(Σ)` have been validated against any physics-foundations literature (they have not);
- that any specific physics test analogous to the music anchor's Coltrane test is currently feasible.

The single concrete commitment is the Wolfram exploration script and the structural core entry. The rest is scoping with explicit deferral.

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
