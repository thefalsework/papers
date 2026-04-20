# `pythagorean-explanatory-debts` — Three open questions from Paper 5 § 7.5

**Status:** OPEN
**Paper:** Paper 5 (Pythagorean) § 7.5 (v1.1)
**Domain:** Number theory; foundations / philosophy of mathematics
**Time estimate:** variable; each debt is independent

---

## Background

Paper 5 § 7.5 names three explanatory debts the paper *does not close* and invites external engagement on each. This claim file tracks all three. A contribution addressing any one is a complete and useful response.

---

## Debt 1 — A uniform framework unifying rank-1 and rank-≥2 Diophantine cases

### The question

The paper argues that the irrationality of √2 (a rank-1 Diophantine obstruction) and the Pythagorean comma (a rank-2 obstruction) share a qualitative floor via the fundamental theorem of arithmetic (FTA), and that Baker's 1966 theorem extends the quantitative floor to rank ≥ 2. But the *argument structure* for rank 1 vs. rank ≥ 2 differs: FTA alone settles rank 1; Baker is needed for rank ≥ 2.

Is there a uniform Diophantine framework in which both sit as instances of a single theorem or a single categorical pattern?

### What a resolution would look like

- A known-to-specialists framework (e.g., Subspace Theorem of Schmidt, Schmidt-Wüstholz, `p`-adic approaches) that subsumes both cases under one statement, with the paper's rank-1 and rank-2 cases as instances.
- Or a negative result: the rank-1 and rank-≥2 cases are genuinely different in a structural sense that cannot be subsumed; the paper should treat the "shared floor" as two distinct but adjacent phenomena.

### Why it matters

The paper currently presents FTA + Baker as a tiered shared floor. A unifying framework would strengthen this from "two related phenomena" to "one underlying mathematical fact." A negative result would require the paper to be more careful about what "shared" means.

---

## Debt 2 — Typology mapping for foundations-of-mathematics schools

### The question

Paper 5 § 6 proposes that historical schools in the foundations of mathematics (Kronecker, Dedekind, Cantor, Hankel, Brouwer, Lakatos) can be mapped onto the five-position typology (Infrastructure, Distribution, Exploitation, Commitment, Refusal). The paper notes these assignments are "defensible but not obvious." For example:

- Kronecker (rejection of irrational and transcendental numbers) as **Refusal**?
- Dedekind (construction of ℝ via cuts; formal absorption of the comma) as **Infrastructure**?
- Cantor (invention of transfinite cardinals to push past the obstructions) as **Exploitation**?
- Brouwer (intuitionism; refusal of excluded middle; finite constructive content) as a second kind of **Refusal**?
- Lakatos (proofs and refutations; mathematics as quasi-empirical) as **Commitment**?

Is this mapping historically and philosophically defensible, or does it misrepresent the schools' actual relationships to Diophantine / foundational obstructions?

### What a resolution would look like

A critical response from a philosopher of mathematics or a mathematical historian addressing whether:
- The five-position structure fits the foundational landscape at all.
- Specific assignments should be revised.
- Some schools do not fit any position and should be treated as outside the typology.

### Why it matters

If the typology-mapping is unsound, Paper 5 § 6 should be rewritten as a looser "structural resonance" rather than "five schools as five positions." If it is sound, it becomes a genuine contribution to the philosophy of mathematics — a structural account of the Grundlagenstreit.

---

## Debt 3 — Specific cents-level effective bound from Baker's theorem

### The question

Baker's 1966 theorem gives an *effective* lower bound on `|12 log 3 − 19 log 2|`. The paper claims this bound exists but does not compute or cite a specific numerical value. What is the best-known effective lower bound (in cents) for the Pythagorean comma derivable from Baker-type methods?

### What a resolution would look like

- A citation to a reference computing the bound explicitly.
- Or an explicit computation using the standard effective constants in Baker's theorem (Waldschmidt's estimates, or Laurent–Mignotte–Nesterenko refinements).

### Why it matters

The exact numerical value is less important than establishing that "Baker's theorem gives an effective positive lower bound" can be backed up by a specific citation or computation if pressed. This is a small research question, not a research program — probably a 1–2 hour task for a number theorist with the right references to hand.

---

## Related claims

- [`music-kernel-06-baker`](music-kernel-06-baker.md) — the primary Baker-theorem application; Debt 3 is a specific sub-question of that.

## Changelog
- 2026-04-20: Claim created consolidating the three Paper 5 § 7.5 debts.
