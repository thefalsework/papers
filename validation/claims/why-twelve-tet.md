# Claim: "why 12" — the arithmetic side of the music–logic weld

**Status:** **Kernel-checked in-repo 2026-06-09** (Lean 4 / Mathlib4 `v4.30.0-rc2`; `Examples/WhyTwelve.lean`; axiom audit standard axioms only, no `sorry`). Not externally validated.

**Papers / notes:** companion to the weld (`validation/claims/math-anchor-cantor-floor.md`, Phase 2–4 results and the all-n kernel law) and to `papers/connecting-the-spine.md` §3.4 / ledger row 21. Reported in the Pythagorean paper as the second, independent forcing of twelve (`papers/pythagorean-shared-floor/pythagorean.md` §7.6, v1.4) — note the scope riders there (≤ 2 prime divisors; least, not only; lattice structure, not acoustics).

**Date opened:** 2026-06-09.

---

## What is being claimed (and at what strength)

The weld (`Div12 ≅ Z_6`) says *where* music landed: on the 6-element truncation of the free Heyting algebra on one generator. This claim answers the complementary question — *why 12-tone equal temperament is the system that lands there* — by running the kernel trichotomy (`allFourCellsInhabited_iff` — equivalently: by locating the **ordinary** elements, in Citkin 2024 §2.1's standard sense of neither regular nor dense) on the subgroup lattices of all cyclic groups `ℤ/n`, modelled as their divisor lattices (products of chains, one chain per prime, length = exponent + 1).

### Kernel-checked — strength [K]

1. **Chains never carry a kernel** (`total_no_kernel`, axioms `propext` only): in any totally-ordered Heyting algebra, every non-`⊥` element has `⊥` complement, so Refusal is uninhabitable. Covers **every prime-power temperament `p^k`, all `k`, abstractly** — no enumeration.
2. **Kernels of a product of two chains** (`prod_kernel_iff`): in `α × β` (both factors non-trivial bounded chains) the four-position kernels are exactly the pairs with one coordinate `⊥` and the other strictly internal. Proved from the trichotomy lemma, which predates this question.
3. **Existence law** (`chainProd_kernel_exists_iff`, abstract for all exponents `a, b ≥ 1`): the divisor lattice of `p^a q^b` carries a kernel **iff some exponent is ≥ 2** — squarefree `pq` temperaments (6, 10, 15, …) are degenerate.
4. **Uniqueness law** (`chainProd_kernel_unique_iff`, abstract for all exponents): the kernel is **unique iff the exponents are `{2,1}`, i.e. iff `n = p²q`**. Least instance: **12**.
5. **Boundary failures, kernel-checked**: `24 = 2³·3` has two kernels (`twentyfour_kernel_two`), `36 = 2²·3²` has two (`thirtysix_kernel_two`), `60 = 2²·3·5` has three (`sixty_kernel_three`). The uniqueness shape really is `p²q`, not an artifact.
6. **The kernel at 12 is the tritone**: `div12OrderIsoChains : Div12 ≃o Fin 3 × Fin 2` is an explicit order isomorphism, preserving `⇨` and `ᶜ` (`toChains_himp`, `toChains_compl`), carrying the tritone `two` to `(1,0)` — the unique kernel of `C₃ × C₂` (`twelve_kernel_unique`). Headline bundle: `why_twelve`.

### The two-sided forcing this completes

* **Logic side** (all-n kernel law): `Z_6` is the *first* one-generated Heyting algebra where the partition is non-degenerate; unique kernel = the free generator. [K] — fully unconditional since 2026-06-17, the Nishimura enumeration now kernel-checked (`generatedBy_isLadderValue`), no longer [C].
* **Arithmetic side** (this claim): `12` is the *first* equal temperament whose subgroup lattice carries a kernel, and — `12 = 2²·3` being the uniqueness shape `p²q` — that kernel is unique. [K], with the seams below.
* The two firsts are the **same six-element algebra with the same kernel** (`Z_6 ≅ Div12 ≅ C₃ × C₂`; free generator = tritone = `(1,0)`). Neither selection was available to choose: logic forces the algebra, arithmetic forces the temperament, and they agree.

### Seams — strength [C] / prose

* **"Divisor lattice of `n` = product of chains"** is the standard structure theorem for subgroup lattices of cyclic groups **[C]**; it is kernel-anchored at `n = 12` (`pcset_realizes_subgroup_lattice`, `div12OrderIsoChains`) but cited, not re-proved, for general `n`.
* **"Every `n < 12` is `1`, `p^k`, or `pq`"** is elementary arithmetic stated in prose, not formalized. The Lean theorems cover each *shape* abstractly; the assignment of the eleven numbers to shapes is the unformalized (trivial) step.
* **"`n`-tone equal temperament = `ℤ/n`"** inherits the framework's standing identification (forced for 12 by the music anchor; conventional for other `n`).
* **18 and 20 are also `p²q`**: they too have unique kernels — the *same* lattice. 12 is privileged as the **least**, not the only, exactly as `Z_6` is the least non-degenerate truncation, not the only one. Any retelling that drops "least" has started overclaiming.
* The `≥ 3`-prime behavior ("kernels multiply with each extra prime") is kernel-checked at the sample `p²qr = 60` only; the general `k`-prime law is not formalized.

### Prior art — independent precedent, distinct object

Erkki Kurenniemi, *Chords, scales, and divisor lattices* (2004, unpublished Mathematica notebook, DIMI) independently treats **divisor lattices as a model of musical structure** — but of a *different* object, by a *different* route, which is exactly why it is corroboration and not precedence on the load-bearing result.

* **Different lattice.** Kurenniemi works in 5-limit just intonation: the divisor lattice of a *large* number (`60 = 2²·3·5`, `8640`, `345600`) as a geometric "brick" of prime-exponent points, with `gcd` = meet, `lcm` = join. He stops at the distributive lattice plus its geometric embedding — **no Heyting structure, no relative pseudocomplement, no one-generation, no ordinary element**. The free-Heyting-algebra layer that carries `Div12 ≅ Z_6` and this claim's `p²q` characterization is untouched, so the central [K] results are clear of this prior art. (Note the near-collision: his machinery aimed at `12` instead of `60` would land on the same underlying poset `C₃ × C₂` — but he never aims it there, because his interesting numbers are large and just-intoned, not `ℤ/12`.)
* **The comma, read oppositely — [A].** He frames `2¹⁹ ≈ 3¹²` (the Pythagorean comma) as a number-theoretic *coincidence* that "justifies the false statement" that the circle of fifths closes, concluding that "all the curious tonal structures result from number-theoretic coincidences." This is the same arithmetic the ratio track (`validation/claims/optimal-ntet-continued-fraction.md`, C1/C2) formalizes as best-approximation of `log₂(3/2)` — read by him as **lucky accident**, in the framework as **structural obstruction**. Same object, opposite ontology. Cite as independent informal precedent for the why-12 near-coincidence, with the contrast stated rather than elided: the framework's added value is not "the comma matters" (long known) but the optimality formalization and the necessity reading.
* **Major/minor as a lattice half-split — converging method, distinct theorem — [A].** His M-index over `[−1, +1]` (major = upper half, minor = lower half of the divisor lattice; inversion-symmetric chords score `0`) is a *partition-of-a-lattice* account of a quality usually taken as primitive — methodologically kin to the four-cell partition, but a *different* partition (geometric symmetry half-split of a JI brick, not the Heyting four-cell partition relative to a kernel). Encouraging independent convergence on "quality = position in a partitioned lattice"; not a result that subsumes or is subsumed. The rhyme must not inflate into a shared theorem.
* **Status.** [C]-citable for the divisor-lattice formalism and the M-index construction; the perceptual `gcd`/`lcm` "tuning forks in the brain" hypothesis is explicitly speculative (his own flag) and is [A]/[O] at best.

## What's asked of a validator

- Confirm the Lean theorems are what they say (`Examples/WhyTwelve.lean`; audit lines in `Examples/HeytingTypeInstance.lean`).
- Check the seams: the chain-product modeling [C], the prose arithmetic for `n < 12`, and whether "least, not only" survives in all downstream summaries.
