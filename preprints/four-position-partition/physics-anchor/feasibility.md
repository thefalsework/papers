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

### 3.1 Anticipated structural finding

Hand analysis (prior to running the script) predicts:

- **A, B, C, F: degenerate** (no kernel admits a non-vacuous four-cell partition).
  The structural obstacle is the same in all four: the poset has a *common trivial bottom* below an antichain (or above an antichain in the case of F), and every non-empty down-set therefore contains that bottom. The Heyting complement of any non-trivial down-set is the empty set, which collapses Refusal and Distribution simultaneously. This is the same "single-spike" obstacle the music exploration encountered in `four-position-music.wl` and `four-position-music-v2.wl` before pivoting to the divisor-lattice slice (`v3-path-b.wl`).
- **D: likely degenerate, but possibly skipped by size guard.** The full 2-qubit MUB context lattice has 21 poset elements; its down-set lattice can be in the thousands. The script guards on size and falls back to a regularity census rather than a full per-kernel enumeration when the lattice exceeds 1024 elements.
- **E: non-vacuous** at non-regular kernels with non-trivial complements (e.g., `a = (1, 0)`). This is the structural fact that the music anchor's divisor lattice exploits, in its physics-flavoured (product-of-trichotomies) guise.

These predictions are recorded for falsifiability: if the Wolfram run disagrees with any of them, the disagreement is the finding to record.

### 3.2 What a positive Route B result would mean

If E (or any candidate) is non-vacuous, the framework's machinery transfers to a physics-flavoured finite lattice. This is a *necessary* condition for the cross-domain thesis, not a sufficient one: a positive Route B result says only that the partition theorem has a lattice-level instance in the physics-adjacent finite world. It does *not* say that this instance is physically meaningful in the way the divisor lattice is musically meaningful (where subgroups of `Z/12` are independently recognised symmetric pitch-class sets).

The interpretive question Route B leaves open: a 3-chain × 3-chain lattice is *generic* — it appears in any system with two commuting trichotomous observables. To anchor it as physics specifically (rather than as one example among many), one would need a published physics structure that *natively* presents itself as a non-Boolean Heyting algebra and whose elements have independent physical significance the way the tritone has independent music-theoretic significance. That is what Route A is for.

### 3.3 What a negative Route B result would mean

If all candidates including E are degenerate, the framework's lattice-level machinery fails to transfer to *any* of the surveyed small physics lattices. This is itself a structural finding with concrete implications:

- The Bohrification approach (A–D) does not produce a non-vacuous slice at its smallest discrete instances; the genuine physics-anchor lattice must live at a richer construction (full topos `[C(A)^op, Set]` for non-trivial `A`, not its discrete sub-poset).
- The product-of-chains structure (E) does not provide a non-vacuous slice either; the music-anchor strategy of leaning on a number-theoretic distributive lattice does not have a direct physics analog.
- The route to a physics anchor lies elsewhere: either causal-set theory at higher event counts, or topos quantum mechanics at the full sheaf-theoretic level, or a different finite physics structure not covered by this survey (e.g., Spekkens toy models, modular tensor categories, finite gauge theories).

Either positive or negative Route B is informative. The script is designed to produce a clean verdict per candidate; the bottom-line summary in the script's final section makes the verdict structure explicit.

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

**Not a Wolfram L-instance for full `M_2(C)`.** The discrete-MASA sub-poset of `C(M_2(C))` is what Route B candidate A tests, and (anticipated finding) it is too spike-like to host the partition. Computing `Sub_{T(M_2(C))}(Σ)` over the full continuum of MASAs requires sheaf-theoretic machinery that is not in scope for a Wolfram-level exploration.

**Achievable now (Route A artefact):** a structural core entry in `wolfram/cores/` for Heunen-Landsman-Spitters 2009, modelling the Bohrification construction the same way `wolfram/cores/tymoczko-2026.wl` models Tymoczko's groupoid reformulation — as an independent corroborator that identifies the same kernel-comma structural phenomenon in a different mathematical category. This is committed (see `wolfram/cores/heunen-landsman-spitters-2009.wl`).

**Achievable now (Route B artefact):** the finite-physics-lattice exploration described in §3, with its predicted outcome on record.

**Deferred (Route A formal anchor):** a finite-dimensional Bohr-topos worked example with the four-position partition computed on `Sub_{T(A)}(Σ)`. Provisionally targeted at `A = M_2(C) ⊕ C` (a non-trivial non-commutative finite-dim C*-algebra) or `A = M_2(C) ⊕ M_2(C)` (two-qubit-like with explicit context structure). The construction is mathematically routine in the Bohrification literature; the Wolfram-level enumeration of `Sub_{T(A)}(Σ)` requires writing the spectral presheaf computation by hand. Estimate: several days of focused Wolfram work, if Route B yields a positive direction. Not committed in this round.

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
| **Route B (this round)** | Finite physics-interpretable lattices either host or do not host a non-vacuous four-cell partition; structural fact one way or the other | **Wolfram script committed** (`four-position-physics-v1.wl`); execution / verdict tabulation **pending user run**. Hand-analysis predictions on record in §3.1 above. |
| **Route A architectural scoping** | The Bohrification (Heunen-Landsman-Spitters / Döring-Isham) programme is the physics-side architectural target; the layered L/T/D framework maps onto it cleanly | **Recorded in this memo + structural core entry committed** (`wolfram/cores/heunen-landsman-spitters-2009.wl`). |
| **Physics Layer L (theorem)** | A finite-dim Bohr-topos worked example with the four-position partition computed on `Sub_{T(A)}(Σ)` | **Deferred.** Provisionally targeted at `A = M_2(C) ⊕ M_2(C)` or similar; not in scope for this round. |
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
