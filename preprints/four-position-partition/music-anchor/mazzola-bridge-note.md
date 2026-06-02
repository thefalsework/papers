# A Kernel-Checked Music Instance of the Four-Position Partition, and One Question for Categorical Music Theory

**Author:** Chris Brink (FalseWork)
**Date:** June 2026
**Status:** Self-contained technical note. The Lean results below are kernel-checked against Mathlib4 (Lean `v4.30.0-rc2`); the single open item (§5) is the intended object of specialist correspondence.
**Audience:** A categorical music theorist (Mazzola's denotator/topos framework; Tymoczko's groupoid framework). It assumes elementary topos theory and pitch-class set theory but nothing about the surrounding FalseWork program.

---

## 0. One-paragraph summary

There is a theorem — *the four-position partition* — that says: in any elementary topos with a non-trivial distinction structure `(D, η, ι)`, the morphisms into a fixed object `Y` fall into exactly four cells determined by where `Im(D f)` sits in the Heyting algebra `Sub(D Y)` relative to the kernel image `Im(η_Y)`. The cells are empty-or-not in a way that is controlled entirely by Heyting non-regularity. This note reports that the theorem instantiates **non-vacuously and kernel-checked** on a small, entirely standard piece of music mathematics — the subgroup lattice of `ℤ/12`, i.e. the lattice of transposition-symmetric pitch-class sets — with the four cells landing on musically named objects (tritone, augmented triad, diminished-seventh, whole-tone/chromatic).

Two features make this more than an illustration. First, the kernel is **not a free parameter**: the tritone `⟨6⟩` is not chosen and then shown to have four cells around it — it is the kernel image `Im(η)` of a concrete idempotent closure operator (`tritoneClosure`, §4), so the four-cell witness is a *consequence of the operator* rather than a construction built around a stipulated kernel. Second, the tritone is the **unique** kernel in this lattice at which all four cells are non-vacuous: an exhaustive check over all six possible kernels shows every other choice degenerates. So this is not "here is one instantiation" but "here is the only instantiation the lattice admits, and its kernel is forced by an operator." Everything is finite and machine-verified.

The one thing that is **not** done — and the reason for writing to a specialist — is whether this finite instance is a *slice of a canonical music topos* (a denotator topos, a presheaf topos on a Tonnetz groupoid) rather than a bespoke construction. That is §5. If it is, the four-cell classification is a structural consequence of the music topos rather than a framework that happens to agree with it.

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

## 5. The one open question (where a specialist is needed)

What is **not** done is the topos-level lift, and it is the only thing standing between this and a complete `four_position_partition` instance on a *music topos*:

> Is there a canonical elementary topos `T` from categorical music theory — a denotator topos in your framework, or a presheaf topos on a Tonnetz/pitch-class groupoid — such that `Sub_T(1)` (or `Sub_T(Y)` for a natural `Y`) is the subgroup lattice of `ℤ/12`, and such that `tritoneClosure` is the subobject-level trace of an idempotent monad on `T` (a sheafification, a reflection onto a sub-topos, a symmetrization)?

Two existence answers are already in hand from general topos theory, but both are *generic*, with no music content beyond what the lattice carries: (T1) `Sh(L)` for the lattice `L` as a locale; (T2) `Set^{Pᵒᵖ}` for `P` the 3-element poset of join-irreducibles `{⟨6⟩ < ⟨3⟩, ⟨4⟩}` (Birkhoff), whose lattice slice is computationally verified. Neither tells us whether the *music* topos you would actually build realizes this lattice and this closure operator.

That is the specialist question. Three concrete sub-questions:

1. **Realization.** Does the denotator/local-composition topos (or a presheaf topos on the dihedral pitch-class groupoid `D₁₂`) contain an object `Y` with `Sub_T(Y) ≅` the subgroup lattice of `ℤ/12`? The subobject lattice of a representable presheaf on a groupoid is the lattice of sub-`Aut`-sets; for `ℤ/12` acting on itself this is close, but the precise object needs your eye.
2. **The operator.** Is `tritoneClosure` the subobject-level trace of a natural idempotent monad on `T` — e.g. a symmetrization (orbit under a chosen symmetry subgroup), or a sheafification for a Lawvere–Tierney topology corresponding to "tritone coverage"? Idempotency you can read off; whether it is the *intended* distinction operation is a question about your framework's semantics, not just its mathematics.
3. **Better `D`.** If `tritoneClosure` is the wrong operator, is there a better one — your global-composition / denotator-limit construction, say — whose kernel image still lands non-regular, giving a non-empty Exploitation cell with a different (perhaps richer) musical reading?

If the answer to (1)+(2) is yes, then the four-cell classification is not an empirical framework that *agrees* with the categorical apparatus — it is a structural consequence of it, obtained through the partition theorem. If (2) needs (3), that is itself informative about which distinction operation is canonical for music.

## 6. Scope honesty (what this note does not claim)

- It does **not** claim a topos-level instance. §3–§4 are lattice-level (Layer L and the Layer-D *slice*); the topos lift of §5 is open.
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
Examples/DivisorLattice12Distinction.lean (this note's results)
    tritoneClosure_is_distinction_slice
    pcset_realizes_subgroup_lattice
    pcset_tritoneClosure_bot
```

Axiom audit (`Examples/HeytingTypeInstance.lean`, via `#print axioms`): every theorem above depends only on `propext`, `Classical.choice`, `Quot.sound` — several on strictly fewer — and none on `sorryAx`.

---

### References

- Brink, C. (2026). *A Four-Position Partition of Morphisms in Elementary Topoi with Distinction Structure.* Preprint, `paper.md` (this repo).
- Mazzola, G. (2002). *The Topos of Music.* Birkhäuser.
- Messiaen, O. (1944). *Technique de mon langage musical.*
- Tymoczko, D. (2011). *A Geometry of Music.* OUP. — (2026). The concept of musical space. *Journal of Music Theory* 70(1).
- Music-anchor feasibility memo: `music-anchor/feasibility.md` (§11 diatonic-closure negative result; §12 subgroup route and layered status; §13 Tymoczko correspondence).
