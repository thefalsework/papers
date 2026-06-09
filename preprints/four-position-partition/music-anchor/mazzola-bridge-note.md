# A Kernel-Checked Music Instance of the Four-Position Partition, and One Question for Categorical Music Theory

**Author:** Chris Brink (FalseWork)
**Date:** June 2026
**Status:** Self-contained technical note. The Lean results below are kernel-checked against Mathlib4 (Lean `v4.30.0-rc2`). The bridge is realized: the music lattice is the subobject lattice of a concrete presheaf topos (§5, Birkhoff, kernel-checked) and the distinction operator has a Lawvere–Tierney realization on it. The remaining open item (§5) is one of *canonicity*, not existence — the intended object of specialist correspondence.
**Audience:** A categorical music theorist (Mazzola's denotator/topos framework; Tymoczko's groupoid framework). It assumes elementary topos theory and pitch-class set theory but nothing about the surrounding FalseWork program.

---

## 0. One-paragraph summary

There is a theorem — *the four-position partition* — that says: in any elementary topos with a non-trivial distinction structure `(D, η, ι)`, the morphisms into a fixed object `Y` fall into exactly four cells determined by where `Im(D f)` sits in the Heyting algebra `Sub(D Y)` relative to the kernel image `Im(η_Y)`. The cells are empty-or-not in a way that is controlled entirely by Heyting non-regularity. This note reports that the theorem instantiates **non-vacuously and kernel-checked** on a small, entirely standard piece of music mathematics — the subgroup lattice of `ℤ/12`, i.e. the lattice of transposition-symmetric pitch-class sets — with the four cells landing on musically named objects (tritone, augmented triad, diminished-seventh, whole-tone/chromatic).

Two features make this more than an illustration. First, the kernel is **not a free parameter**: the tritone `⟨6⟩` is not chosen and then shown to have four cells around it — it is the kernel image `Im(η)` of a concrete idempotent closure operator (`tritoneClosure`, §4), so the four-cell witness is a *consequence of the operator* rather than a construction built around a stipulated kernel. Second, the tritone is the **unique** kernel in this lattice at which all four cells are non-vacuous: an exhaustive check over all six possible kernels shows every other choice degenerates. So this is not "here is one instantiation" but "here is the only instantiation the lattice admits, and its kernel is forced by an operator." Everything is finite and machine-verified.

The lattice instance is **realized as the subobject lattice of a concrete presheaf topos** — `Set^{Pᵒᵖ}` for `P` the poset of the three symmetric pitch-class generators (Birkhoff's theorem, §5, kernel-checked) — and the distinction operator has a genuine Lawvere–Tierney (sheaf-theoretic) realization on that topos. So the bridge does not depend on outside validation: the partition instantiates on a music-derived topos built directly from `ℤ/12`. The one remaining question (§5) is **canonicity** — whether this topos is *the* music topos, or embeds as a natural slice of a richer one (a denotator topos, a Tonnetz-groupoid presheaf topos). That is a question about which construction is canonical, not whether the bridge exists. If it embeds canonically, the four-cell classification is a structural consequence of the music topos rather than a framework that happens to agree with it.

---

## 1. The theorem being instantiated

Let `T` be an elementary topos. A **distinction structure** on `T` is an endofunctor `D : T ⥤ T`, a unit `η : 𝟭 ⟶ D`, and an idempotency iso `ι : D ⋙ D ≅ D` satisfying a coherence law (Spencer-Brown's "calling": marking twice equals marking once). It is **non-trivial** when `η` is not a natural iso. For a morphism `f : X ⟶ Y`, write `img := Im(D f) ∈ Sub(D Y)` and `a := Im(η_Y) ∈ Sub(D Y)` (the *kernel image*). The Heyting algebra `Sub(D Y)` then partitions `f` (for `img ≠ ⊥`) into exactly one of:

| Cell | Condition on `img` |
|------|--------------------|
| Infrastructure | `img ≤ a` |
| Refusal | `img ≤ aᶜ` |
| Exploitation | `img ≤ aᶜᶜ` and `img ⊄ a` |
| Distribution | `img ⊓ a ≠ ⊥` and `img ⊓ aᶜ ≠ ⊥` |

The Exploitation cell is empty exactly when `Sub(D Y)` is Boolean at `a` (`aᶜᶜ = a`); it is the cell that exists *only* because intuitionistic double negation can be strict.

This is `four_position_partition`, kernel-checked in Lean (audit: depends only on `propext`, `Classical.choice`, `Quot.sound`; no `sorry`). The Heyting core is isolated as `lattice_four_position_partition`: for any Heyting algebra `H`, any `a : H`, and any `x ≠ ⊥`, exactly one of the four conditions holds. The full statement and proof are in the partition paper (`paper.md`).

The bridge from "an idempotent operation" to "a distinction structure" is also kernel-checked: `DistinctionStructure.ofIdempotentMonad` (Remark 5.5 of the paper) turns any idempotent monad — equivalently any reflective subcategory, equivalently (at the subobject level) any closure operator on `Sub(D Y)` — into a distinction structure. This is the hinge the music instance hangs on.

## 2. The substrate: the subgroup lattice of `ℤ/12`

Take the six subgroups of `ℤ/12`. Ordered by inclusion they form the divisor lattice of 12:

```
              ℤ/12               (full chromatic)
             /     \
          ⟨2⟩       ⟨3⟩
        (whole-tone) (dim 7th)
          |   \     /
          |    \   /
         ⟨6⟩    ⟨4⟩
       (tritone) (aug triad)
             \   /
             ⟨0⟩                  (trivial)
```

Each subgroup *is* a transposition-symmetric pitch-class set: `⟨6⟩ = {0,6}` (tritone), `⟨4⟩ = {0,4,8}` (augmented triad), `⟨3⟩ = {0,3,6,9}` (diminished seventh), `⟨2⟩ = {0,2,4,6,8,10}` (whole-tone hexachord). These are Messiaen's modes of limited transposition / the symmetric sets of pitch-class set theory — they predate and are independent of any specific categorical framework (Tymoczko's, Mazzola's, Lewin's).

Two facts make this the right toy substrate:

1. **It is a non-Boolean Heyting algebra.** Divisor lattices are distributive (hence Heyting); `12 = 2²·3` is not squarefree, so the lattice is not Boolean. Concretely the tritone is **non-regular**: `⟨6⟩ᶜᶜ = ⟨3⟩ ≠ ⟨6⟩`. Kernel-checked: `Div12.tritone_non_regular`.
2. **The literal pitch-class realization is now machine-checked, not asserted.** The map `pcset : Div12 → Finset (ℤ/12)` sending each lattice element to its actual pitch-class set is proved injective, valued in additive subgroups (closed under `0`, `+`, negation), order-reflecting (lattice order = subgroup inclusion), and meet-preserving (`pcset (a ⊓ b) = pcset a ∩ pcset b`). Bundled as `Div12.pcset_realizes_subgroup_lattice`.

## 3. The four cells, instantiated and named

**The tritone is the unique kernel that works.** Before fixing it: an exhaustive check over all six possible kernels in this lattice (computational companion, `wolfram/music-anchor/layer-t-d-checks.wl` §5) shows the tritone `⟨6⟩` is the *only* kernel at which all four cells are non-vacuously inhabited. Every other choice degenerates — the other non-regular element (whole-tone `⟨2⟩`) has `⟨2⟩ᶜ = ⊥`, collapsing Refusal and Distribution; the four regular elements collapse further. So the kernel below is not one choice among six but the forced one, a structural fact about the lattice rather than a tuning of the example.

Fix the kernel `a = ⟨6⟩` (tritone). Then `aᶜ = ⟨4⟩` (augmented triad) and `aᶜᶜ = ⟨3⟩` (diminished seventh). The partition reads off the lattice as:

| Cell | Inhabited by | Pitch-class object |
|------|--------------|--------------------|
| Infrastructure (`x ≤ a`) | `⟨6⟩` | tritone (the kernel itself) |
| Refusal (`x ≤ aᶜ`) | `⟨4⟩` | augmented triad |
| Exploitation (`x ≤ aᶜᶜ`, `x ⊄ a`) | `⟨3⟩` | diminished seventh (the closure-residue) |
| Distribution (straddle) | `⟨2⟩`, `ℤ/12` | whole-tone hexachord, full chromatic |

All four cells inhabited, kernel-checked as `Div12.music_anchor_witness` (uniqueness of this kernel stated at the top of the section).

**A correction worth stating up front**, because it is the obvious first guess and it is wrong: one is tempted to map Tymoczko's three harmonic fields — diatonic, symmetric, chromatic — onto Infrastructure/Exploitation/Refusal via a *diatonic-closure* distinction operator (close a pitch-class set to the smallest diatonic scale containing it). We tried exactly this (memo §11). The diatonic-closure Moore lattice on `ℤ/12` (92 closed sets) is **not distributive**, hence not Heyting, with two explicit counterexamples to the Heyting identity. So the partition theorem does not apply to that construction at all. The working instance is the subgroup lattice with the **tritone** as kernel, above — a different and cleaner object. Any bridge that routes through diatonic closure inherits the §11 obstruction; the subgroup route avoids it.

## 4. The distinction operator (this note's new content)

The witness in §3 takes `a = ⟨6⟩` as *given*. The new result here is that this kernel is **not a free parameter**: it is the kernel image of a concrete idempotent operation.

Define the closure operator `tritoneClosure : Div12 → Div12` whose closed (fixed) points are the Moore family `{⟨6⟩, ℤ/12}` — i.e. the closure of `x` is the least closed element `≥ x`:

```
⊥ ↦ ⟨6⟩,  ⟨6⟩ ↦ ⟨6⟩,  ⟨4⟩ ↦ ℤ/12,  ⟨3⟩ ↦ ℤ/12,  ⟨2⟩ ↦ ℤ/12,  ℤ/12 ↦ ℤ/12.
```

Kernel-checked facts (`Div12.tritoneClosure_is_distinction_slice`):

- **extensive** `x ≤ tritoneClosure x`, **monotone**, **idempotent** — a bona fide closure operator;
- its fixed-point set is exactly `{⟨6⟩, ℤ/12}` (`tritoneClosure_fixedPoints`), meet-closed (a Moore family);
- **`tritoneClosure ⊥ = ⟨6⟩`** (`tritoneClosure_bot`): the closure of the bottom element is the tritone;
- `(tritoneClosure ⊥)ᶜᶜ ≠ tritoneClosure ⊥` (`tritoneClosure_bot_non_regular`): the kernel image is non-regular, which is *precisely* the condition that the Exploitation cell is non-empty.

In the topos shadow this is the picture: a closure operator on `Sub(T)(1)` is what an idempotent monad's unit cuts out, and `Im(η)` corresponds to the closure of the initial object `⊥`. So `tritoneClosure ⊥ = ⟨6⟩` is the lattice-level statement that **`Im(η)` lands on the tritone**, making `a = ⟨6⟩` the kernel image of a genuine distinction operation rather than a stipulation. This is candidate `{2,12}` — the minimal tritone-closing Moore family — from the enumerated Layer-D candidate space (memo §12.6; there are exactly four tritone-closing families).

This closes the lattice-level (Layer-L + Layer-D-slice) story end to end: a non-Boolean music-derived Heyting algebra, a concrete idempotent distinction operator on it whose kernel image is non-regular, and the four cells inhabited at that kernel image — all kernel-checked.

`tritoneClosure` is the *reflective* realization of the kernel (its topos lift is a general idempotent monad). It is **not** the *geometric* (sheaf-theoretic) realization — that is a different, maximal operator `tritoneNucleus`, introduced in §5, which is a genuine Lawvere–Tierney topology with the same tritone kernel. The two share the kernel `tritoneClosure ⊥ = tritoneNucleus ⊥ = ⟨6⟩` but differ in kind; see the correction record in §5.

## 5. The topos realization (now kernel-checked), and the one remaining question (canonicity)

The lattice instance of §3–§4 lifts to a concrete presheaf topos, with the lattice content kernel-checked and no appeal to any specific music-theoretic framework.

**The substrate is the subobject lattice of a natural presheaf topos.** By Birkhoff's representation theorem, every finite distributive lattice is the lattice of down-sets of its poset of join-irreducibles. For the divisor lattice of `ℤ/12` the join-irreducibles are exactly the three fundamental symmetric pitch-class generators — the tritone `⟨6⟩`, the diminished seventh `⟨3⟩`, the augmented triad `⟨4⟩` — with the inclusion order `⟨6⟩ < ⟨3⟩` and `⟨4⟩` incomparable. (This poset `P` is not chosen for convenience: it is the natural generating structure of the symmetric sets, the generators of Messiaen's modes of limited transposition.) Kernel-checked as `Div12.birkhoff_representation`: the map `a ↦ {join-irreducibles ≤ a}` is an injective, bounded, meet- and join-preserving order embedding of `Div12` *onto* the down-sets of `P`. Since the down-sets of `P` are exactly `Sub_{Set^{Pᵒᵖ}}(1)` (general topos theory), this says:

> The divisor lattice of `ℤ/12` **is** the subobject lattice of the terminal object of the presheaf topos `Set^{Pᵒᵖ}` — the **T2 construction** — a topos built directly from the symmetric pitch-class generators of `ℤ/12`, not bespoke for this purpose.

So a complete `four_position_partition` instance lives on a music-derived topos: the tritone is the forced (unique) non-regular kernel and all four cells are inhabited, on a substrate that is Birkhoff's canonical presheaf realization of `ℤ/12`'s symmetric lattice.

**The distinction operator has a Lawvere–Tierney (sheaf-theoretic) realization.** A nucleus — an inflationary, idempotent, *meet-preserving* operator — is the subobject-level trace of a Lawvere–Tierney topology, i.e. of a sheafification. Kernel-checked (`Div12.tritone_kernel_has_lawvere_tierney_realization`): the maximal tritone-closing closure operator `tritoneNucleus` (Moore family `{⟨6⟩, ⟨3⟩, ⟨2⟩, ℤ/12}`) **is** a nucleus, and its kernel image is still the tritone, still non-regular. So there is a Lawvere–Tierney topology on `Set^{Pᵒᵖ}` whose induced distinction structure has the tritone as its non-regular kernel — the music kernel has a genuine *geometric* realization, a sheaf subtopos, not merely a reflective one.

**Correction record (vs. the previously circulated draft).** This matters enough to state in the open rather than swap silently, since an earlier version of this note has circulated.

- **What the earlier draft said.** §5 listed, as open specialist sub-question (2), whether the operator of §4 — `tritoneClosure`, the *minimal* tritone-closing operator — is "the subobject-level trace of an idempotent monad … a sheafification for a Lawvere–Tierney topology." The implicit expectation was that `tritoneClosure` itself would be that sheafification.
- **What is now proven.** That expectation is **wrong, kernel-checked.** `tritoneClosure` is *not* a nucleus: it fails meet-preservation, with explicit witness `j(⟨4⟩ ⊓ ⟨3⟩) = ⟨6⟩ ≠ ℤ/12 = j⟨4⟩ ⊓ j⟨3⟩` (`Div12.tritoneClosure_not_nucleus`). So `tritoneClosure`'s topos lift is a general (non-left-exact) idempotent monad via `DistinctionStructure.ofIdempotentMonad`, **not** a Lawvere–Tierney topology / sheafification.
- **The corrected operator.** The sheafification reading is salvaged by a *different* operator: the **maximal** tritone-closing operator `tritoneNucleus` (Moore family `{⟨6⟩, ⟨3⟩, ⟨2⟩, ℤ/12}`) **is** a nucleus (`Div12.tritone_kernel_has_lawvere_tierney_realization`), with the *same* tritone kernel, still non-regular. So the geometric realization exists — just not via the operator originally proposed for it.

Net: the *reflective* realization of the tritone kernel is `tritoneClosure` (§4, unchanged); the *geometric* (sheaf-theoretic) realization is `tritoneNucleus` (new). Both are kernel-checked; only the latter is a sheafification. If you are checking against the earlier draft, this is the one identification that changed.

**What remains.** Essentially one specialist question. The Lean topos-object plumbing and the explicit `Subobject`-API iso are now closed and kernel-checked, and the one route that does *not* lift (the kernel as a topos endofunctor's unit-image) is now a precise kernel-checked obstruction (item 1). None of this is the existence of the bridge:

1. **Lean plumbing — closed (2026-06).** `Set^{Pᵒᵖ}` *is* now instantiated as an actual `CategoryTheory` object in Lean — `MusicTopos := Pᵒᵖ ⥤ Type` for `P` the join-irreducible poset (`Examples/MusicTopos.lean`) — and the full elementary-topos hypothesis bundle resolves for it (`musicTopos_isElementaryTopos`). Consequently `Sub_{Set^{Pᵒᵖ}}(1)` is a Heyting algebra on the concrete topos, and the abstract `four_position_partition` typechecks against it (`four_position_partition_musicTopos`). The earlier blocker was the absence of a presheaf subobject classifier in Mathlib; that was supplied in Mathlib `v4.30` (`CategoryTheory.Presheaf.classifier`), and the gap closed at once. The two finer-grained items flagged here are now both resolved:

   - **(i) Explicit `Subobject (⊤_ MusicTopos) ≅ Div12` — closed, kernel-checked** (`Examples/MusicToposSub.lean`, `subobjectTerminalEquivDiv12`). Birkhoff is upgraded from the down-set level (`Div12 ≅ O(P)`) to an order iso of Mathlib's actual `Subobject` type of the terminal presheaf, via `Subfunctor.orderIsoSubobject` (Mathlib `v4.30`) and the hand-built down-set correspondence. The topos's own `Sub(1)` cells now map onto the named pitch-class objects of `Div12`.
   - **(ii) Non-trivial *topos* endofunctor — comes apart from the tritone at `1`** (`Examples/MusicToposTrace.lean`). The four-position kernel is `kernelImage Δ Y = Im(η_Y)` (image of the marking unit), and any iso unit forces it to `⊤` (`kernelImage_eq_top_of_isIso_unit`). The terminal presheaf is a sheaf for *every* topology, so every sheafification monad has iso unit at `1`, giving `kernelImage Δ 1 = ⊤` while the tritone value is `⟨6⟩ ≠ ⊤`. So the sheafification-at-`1` route degenerates exactly like the trivial distinction; **the lattice nucleus (a closure operator on `Sub(1)`) is not the `Im(η)` kernel of any reflector at `1`.** The non-degenerate, musically-loaded partition therefore stays the *lattice-level* theorem (`lattice_four_position_partition`, `music_anchor_witness`) — now bridged to the topos by (i), since that lattice *is* `Sub(1)`. Realizing the tritone as `kernelImage Δ Y` for a *non-terminal* witness via a bespoke (non-sheafification) endofunctor remains genuinely open.

   So the topos-object bridge is welded for the lattice and the operator; the only thing that does *not* lift is the encoding of the kernel as a topos endofunctor's unit-image, and that is now a precise, kernel-checked obstruction rather than an open mechanization.

2. **Canonicity (the specialist question).** Is `Set^{Pᵒᵖ}` *the* music topos, or does it embed as a natural slice of a richer one? Concretely:

   - **Embedding.** Does the denotator / local-composition topos, or a presheaf topos on the dihedral pitch-class groupoid `D₁₂`, contain `Set^{Pᵒᵖ}` (equivalently, an object `Y` with `Sub_T(Y) ≅` the subgroup lattice of `ℤ/12`) as a natural subtopos or slice? The subobject lattice of a representable presheaf on a groupoid is the lattice of sub-`Aut`-sets; for `ℤ/12` acting on itself this is close, but the precise comparison needs your framework's eye.
   - **The operator's status.** Is `tritoneNucleus`'s Lawvere–Tierney topology one your framework already names — a symmetrization, a "tritone-coverage" Grothendieck topology — or does your canonical distinction operation differ, and if so does *its* kernel image still land non-regular (a different, perhaps richer, Exploitation reading)?

   The bridge does not depend on the answer. The question is whether the road we built is *the* road to this place or *a* road — whether the music topos with the deepest foundations realizes this same lattice, this same kernel, and this same sheaf-theoretic distinction operation. If it does, the four-cell classification is not an empirical framework that *agrees* with the categorical apparatus; it is a structural consequence of the music topos itself.

## 6. Scope honesty (what this note does not claim)

- It claims a topos-level instance **at the level of the subobject lattice and the distinction operator** (§5): the music lattice is kernel-checked to be `Sub_{Set^{Pᵒᵖ}}(1)` for a concrete presheaf topos — now including an explicit `Subobject (⊤_ MusicTopos) ≅ Div12` in Mathlib's `Subobject` API (`subobjectTerminalEquivDiv12`) — and a Lawvere–Tierney topology on that topos has the tritone as its non-regular kernel. As of 2026-06 `Set^{Pᵒᵖ}` **is** also instantiated as an elementary-topos object in Lean (§5.1, `musicTopos_isElementaryTopos`; the earlier Mathlib presheaf-instance gap closed in `v4.30`). What it does **not** claim is a *non-degenerate* partition at the **topos-object** level: the kernel `kernelImage Δ Y = Im(η_Y)` collapses to `⊤` at the terminal for every reflector (the terminal is a sheaf), so the tritone is not realized as the marking-image of a sheafification monad (§5.1 item (ii), `kernelImage_eq_top_of_isIso_unit`); the non-degenerate four-cell instance is the *lattice-level* `music_anchor_witness`, identified with the topos's `Sub(1)` by the iso above. And it does **not** claim this topos is canonical for music (§5.2, the open question).
- It does **not** claim the diatonic/symmetric/chromatic tripartition maps onto the cells. The naive (diatonic-closure) form of that map fails at the Heyting-distributivity step (§3, memo §11); any correct version must be reconstructed on the subgroup substrate and is not established here.
- It does **not** claim a formal identity between the tritone's Heyting non-regularity and the Pythagorean comma's irrationality `(3/2)^p ≠ 2^q`. The two are recorded as a **structural identification** (memo §13.1) — same load-bearing role, "comma as the obstruction to closure" — not a constructed isomorphism. A locale/`π₁` bridge connecting the lattice-of-subobjects picture to a topology-of-arrows picture is plausible but unbuilt.
- The pitch-class objects used are elementary group theory of `ℤ/12` (Messiaen, Forte, Rahn), not a contribution of any recent categorical author. The instrument is borrowed; only the partition reading of its cells is the framework's.

## 7. Reproducing the kernel-checked claims

All results live in the public repository (`thefalsework/papers`, `lean/` directory), Lean `v4.30.0-rc2` against Mathlib4, in namespaces `FalseWork.Positions` and `FalseWork.Lattice` (the witnesses in `FalseWork.Lattice.Examples.Div12`). By file:

```
Positions/Partition.lean
    four_position_partition           (the topos-level theorem)
Positions/SpencerBrown.lean
    DistinctionStructure.ofIdempotentMonad   (Remark 5.5 bridge)
Lattice/FourPositionLattice.lean
    lattice_four_position_partition          (the Heyting core)
Examples/DivisorLattice12.lean            (Layer-L witness)
    tritone_non_regular
    music_anchor_witness
Examples/DivisorLattice12Distinction.lean (the distinction operator)
    tritoneClosure_is_distinction_slice
    pcset_realizes_subgroup_lattice
    pcset_tritoneClosure_bot
Examples/DivisorLattice12Birkhoff.lean      (§5: the T2 realization)
    birkhoff_representation        (Div12 ≅ Sub_{Set^{Pᵒᵖ}}(1))
    birkhoff_tritoneKernel         (kernel = principal down-set of the tritone)
Examples/DivisorLattice12Nucleus.lean       (§5: the LT-topology)
    tritone_kernel_has_lawvere_tierney_realization
    tritoneClosure_not_nucleus     (the reflective-vs-geometric correction)
```

Axiom audit (`Examples/HeytingTypeInstance.lean`, via `#print axioms`): every theorem above depends only on `propext`, `Classical.choice`, `Quot.sound` — several on strictly fewer — and none on `sorryAx`.

---

### References

- Brink, C. (2026). *A Four-Position Partition of Morphisms in Elementary Topoi with Distinction Structure.* Preprint, `paper.md` (this repo).
- Mazzola, G. (2002). *The Topos of Music.* Birkhäuser.
- Messiaen, O. (1944). *Technique de mon langage musical.*
- Tymoczko, D. (2011). *A Geometry of Music.* OUP. — (2026). The concept of musical space. *Journal of Music Theory* 70(1).
- Music-anchor feasibility memo: `music-anchor/feasibility.md` (§11 diatonic-closure negative result; §12 subgroup route and layered status; §13 Tymoczko correspondence).
