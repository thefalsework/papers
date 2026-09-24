# The falsework inequality

**What an observer can perceive of a structure's load is bounded by its
blur — stated, proved, kernel-checked, and measured.**

Chris Brink · 2026-09-23 · v0.2 (v0.2, same day: "phantom mass" on
cones renamed **phantom count** after an external review — the aperture
papers' phantom mass is the *interval cardinality* |[k, jk]|, which on
the subset lattice is 2^p, not p; the two are related by a logarithm,
not identical, and the first version wrongly called them "the same
invariant." The "prices the blur before any ranking is run" sentence
also softened to what it can support. No theorem or measurement
changed.)

This note connects the two halves of the falsework program with a
theorem. One half studies *observers*: nuclei on Heyting algebras,
with invariants (aperture, co-aperture, phantom mass) measuring what
coarse-graining destroys. The other half studies *load*: conemass, a
dependency-graph ranking validated on package ecosystems and proof
corpora, measuring where structure concentrates dependence. Both are
functionals on the same object — down-sets of a partial order. The
theorem below is the handshake: the observer invariant bounds the
distortion of the load instrument, with constant 2, and the bound is
tight.

## Statement

Finite node set \(V\); each node \(u\) has a dependency cone
\(C_u \subseteq V\). The **conemass field** is

\[\mathrm{cm}(x) \;=\; \sum_{u\,:\,x \in C_u} \frac{1}{|C_u|},\]

exactly what the conemass tool computes. An **observer** is any blur
\(J\) with \(C_u \subseteq JC_u\) — inflationarity, the axiom every
nucleus satisfies, so every Heyting observer applied to cones
qualifies (and so do inflationary non-nuclei, e.g. partition
closures). Its **phantom count** on cone \(u\) is
\(p_u = |JC_u| - |C_u|\) — the number of elements it cannot separate
from the cone. (Relation to the aperture papers' **phantom mass**,
which is the interval cardinality \(|[k, jk]|\): on the subset lattice
the interval \([C_u, JC_u]\) has \(2^{p_u}\) elements, so
\(p_u = \log_2\) of the phantom mass — the same phenomenon on two
scales, not the same number. v0.1 wrongly called them the same
invariant.) The observer's perceived load is \(\mathrm{cm}_J\), the
conemass field of the blurred cones.

**Theorem (falsework inequality).**

\[\big\lVert \mathrm{cm}_J - \mathrm{cm} \big\rVert_1 \;\le\;
\sum_{u} \frac{2\,p_u}{|C_u| + p_u},\]

and per nonempty cone the bound holds with equality — the constant 2
is tight, not an artifact of the estimate.

## Proof

The error field decomposes per cone; the triangle inequality reduces
the claim to one cone \(u\). Members \(x \in C_u\): credit shrinks
from \(1/|C_u|\) to \(1/|JC_u|\), a loss of
\(p_u/(|C_u|\,|JC_u|)\) each, totalling \(p_u/|JC_u|\). Phantoms
\(x \in JC_u \setminus C_u\): spurious credit \(1/|JC_u|\) each,
totalling \(p_u/|JC_u|\). Everyone else: zero. Sum:
\(2p_u/|JC_u| = 2p_u/(|C_u|+p_u)\). ∎

The proof is elementary — counting plus one triangle inequality. That
is the finding, not a caveat: the bridge between observer invariants
and load invariants required no machinery because both halves were
already measures on the lattice of down-sets.

## Corollaries (all kernel-checked)

1. **Perfect observers.** Zero phantom count on every cone ⟹ load
   perceived exactly. The pocket-of-reducibility statement in
   structural form.
2. **Conservation ⟺ density.** Total mass equals the number of
   nonempty cones, so an observer conserves total load *iff* it
   preserves empty cones — density, \(j\bot=\bot\) in nucleus
   language. Non-dense observers mint exactly one unit per inflated
   empty cone: **the mass budget audits the observer.**
3. **Monotonicity.** Total load never decreases under blur — observers
   mint or move mass, never destroy it.
4. **Schur flattening.** Per cone, for every convex \(\varphi\) with
   \(\varphi(0)=0\), the \(\varphi\)-sum of blurred credit is at most
   that of true credit: observers can only flatten a cone's
   contribution, never sharpen it.

## Lean artifact

`lean/FalseWorkPapers/Lattice/FalseworkInequality.lean` in
github.com/thefalsework/papers — nine kernel-checked declarations:
`falsework_inequality`, `sum_abs_err_eq` (tightness),
`sum_abs_err_le`, `perfect_observer`, `mass_conserved`,
`mass_conserved_iff_dense`, `total_mass_mono`, `schur_flattening`,
`falsework_inequality_observer` (single-operator form). Lean 4,
Mathlib, `lake build` clean.

## Measured against reality

Registered study `oracle-scanner/11-falsework-tightness.mjs`: Debian
bookworm (63,353 components, cap-200 cones — the published conemass
configuration), two natural partition-closure observers. Partition
closures are inflationary and dense but not nuclei — the theorem's
generality is doing real work here.

| observer | classes | ‖·‖₁ actual | bound | ratio | conservation gap | top-40 head survival |
|---|---|---|---|---|---|---|
| name-stem blur (fine) | 60,304 | 24,501 | 25,820 | **1.05×** | 1.5e-9 | 29/40 |
| section blur (coarse) | 58 | 92,862 | 108,001 | **1.16×** | 1.1e-9 | 0/40 |

Three readings. The bound is nearly an identity *in aggregate*, not
just per cone — cross-cone cancellation, the only slack the proof
admits, is almost absent on a real graph (the registered guess was
2–20× slack; wrong in the favorable direction, reported as
registered). Conservation holds to float epsilon, as the density
corollary demands of partition closures. And the operational reading:
a version-blind observer still sees 29/40 of the true criticality
head, while a section-level observer sees none of it. (v0.1 claimed
the bound "prices the blur before any ranking is run"; softened —
computing \(p_u\) requires the true cones, at which point the fields
are cheap, so the bound saves no computation. Its value is analytic:
it says *why* distortion is controlled, identifies which cones
dominate the error, and bounds total distortion without comparing the
two rankings — but head survival, the triage-relevant quantity, must
still be measured, as the 29/40-vs-0/40 split shows.)

## Open: the converse question

Which load fields are achievable as \(\mathrm{cm}_J\) for some
observer \(J\) of a fixed structure \(C\)? Necessary conditions now
proven: total mass monotone (corollary 3), per-cone flattening
(corollary 4), and for partition observers the perceived field is
constant on classes. A characterization — load fields as an
order-ideal under majorization-like dominance, or a counterexample to
any clean description — is the natural second theorem. Not attempted
here.

## Honest positioning

The mathematics is elementary; a referee would call it an exercise.
Its value is architectural: the phantom invariants were defined for
logical reasons (what a nucleus cannot distinguish) and conemass for
empirical ones (where dependency load concentrates), and this note
proves the first is the price of misperceiving the second — with the constant
tight, the conservation boundary exactly the classical density
condition of pointfree topology, and the bound within 16% of measured
truth on a 63K-node production graph. One theorem, both halves of the
program under it.
