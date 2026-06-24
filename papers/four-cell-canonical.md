# Four Cells, Not Five: Canonical Decision on the Position Partition

**Chris Brink** · FalseWork (falsework.dev) · June 2026

*Status: project decision record. This note resolves the five-vs-four coherence debt logged against Paper 1 (INDEX v11.9). It does not introduce new mathematics; it records which of two existing descriptions is canonical, why, and what must be brought into line. The formal basis is **[K]** (kernel-checked); the decision and its propagation are governance.*

---

## 1. The debt

Two descriptions of the position structure have coexisted in the corpus:

- **Five universal responses** (Paper 1 prose, the website, the assistant): Infrastructure · Distribution · Exploitation · **Commitment** · Refusal — five peers derived from a decision tree (encounter / non-encounter, then distribute / exploit / commit / refuse).
- **Four-cell partition** (the formal floor, `Positions/Partition.lean`): Infrastructure · Distribution · Exploitation · Refusal — a disjoint, exhaustive partition of a Heyting algebra relative to the kernel `k`.

The four formal names are a clean subset of the five. The entire divergence is **Commitment**: a fifth peer cell in the prose, absent from the partition.

## 2. The decision

**The four-cell partition is canonical. Commitment is not a fifth position; it is a within-cell fidelity gate.**

This is not a stylistic preference. It is forced by the formal floor:

- The partition is provably **disjoint and exhaustive at four cells** (`four_position_partition`, `lattice_four_position_partition`). A fifth peer cell would either break exhaustiveness/disjointness or be empty.
- The attempt to express the four predicates as specializations of one uniform two-parameter term **closed negative** — they are propositional-shape-distinct. There is no parametric family in which "Commitment" is the fifth instance.
- Commitment therefore enters formally only as a **binary fixedness condition operating *within* each cell** (a work goes all the way to the limit of whatever cell it occupies), not as a region of the lattice.

See `position-taking-from-the-kernel-up.md` §2 for the kernel-checked statement.

## 3. What Commitment becomes

Commitment is recast as a **depth/fidelity modifier**: "Commitment-grade" occupancy of one of the four cells — a work that extends its cell's logic to the limit with total fidelity.

The canonical examples relocate, and the relocation matches the framework's own best close readings:

- **Bach, *Art of Fugue*** — formerly "Commitment." Already read in the Bach curriculum as *"Infrastructure at its absolute boundary."* → **Commitment-grade Infrastructure.**
- **Sokurov, *Russian Ark*** — formerly "Commitment," peer of Empire's Refusal. Continuity extended to its limit (one unbroken take). → **Commitment-grade Infrastructure**, *not* a peer of Refusal.
- **Maillart's bridges, Béla Tarr** — likewise Commitment-grade Infrastructure.

The load-bearing pedagogical contrast survives, sharpened. Russian Ark and Empire still share a surface (no conventional cuts) and oppose structurally — but the opposition is no longer "two outside territories, opposite vectors." It is: **Refusal is a genuine cell (`x ≤ kᶜ`); Commitment is maximal-fidelity occupancy of Infrastructure.** They meet *at the boundary from opposite sides* — extension to the limit vs. inversion — which is what the framework already said about Art of Fugue and Interstellar Space.

## 4. Substantive consequence (not just a relabel)

The one place the two models genuinely disagree about a classification is **Russian Ark**: Commitment-peer-of-Refusal (old) vs. Commitment-grade-Infrastructure (canonical). Adopting four cells changes its cell label. This is recorded, not concealed; it is the framework's correction architecture operating on its own taxonomy.

## 5. Propagation checklist

Surfaces still carrying the five-peer framing, to be brought into line:

- [ ] **Assistant system prompt** (`node0000/app/api/assistant/route.ts`) — "THE FIVE UNIVERSAL RESPONSES" → four positions + fidelity gate. *(in progress with this decision)*
- [ ] **`introduction` curriculum** intro section "The Five Universal Positions" (`node0000/db/0166`) — rewrite to four + gate. (Self-contained: the intro has no Commitment-classified item.)
- [ ] **Cinema curriculum** Russian Ark item + `profile_kernel_engagements` (`node0000/db/0129…`) — reclassify to Commitment-grade Infrastructure; reframe the Russian Ark ↔ Empire contrast. *(Cascades through the curriculum's central distinction; executed as the first step of the `/guides` four-cell build.)*
- [ ] **Renderer** (`node0000/app/guides/[slug]/page.tsx`) — display "Commitment" as a modifier, not a peer response, once the data is reclassified.
- [ ] **Paper 1** — replace the five-from-a-decision-tree derivation with the four-cell partition + Commitment-as-gate. (Separate prose task; largest single item.)
- [ ] **`/guides` position-trajectory layer** — build **four** position-rows (Infrastructure, Distribution, Exploitation, Refusal); teach Commitment as a depth modifier *inside* them, never as a fifth row.

## 6. What is unchanged

Infrastructure, Distribution, Exploitation, and Refusal keep their names, definitions, and every classification already resting on them. The five-position prose was never *wrong* about those four; it over-counted by promoting a within-cell intensity to a peer region. Everything written about Commitment as a real artistic stance (total fidelity, extension to the limit) remains true — it is now correctly located as a way of *occupying* a cell rather than as a cell of its own.

---

*Formal record: `lean/FalseWorkPapers/Positions/Partition.lean`. Companions: `position-taking-from-the-kernel-up.md` (§2, the kernel-checked partition and the Commitment gate), `four-position-exposition.md`, `comma-formal-structure-note.md`, `connecting-the-spine.md`.*
