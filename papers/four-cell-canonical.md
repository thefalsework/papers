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

Commitment is recast as a binary **fidelity gate** (`commitment_yes`) that applies *within* a cell — TRUE when a work pursues its cell's logic to that cell's structural limit (the boundary approached without further iteration producing new content). It is cell-independent in principle.

The works previously called "Commitment" do **not** relocate to Infrastructure. They were characterized by the framework's own term `outside_coherence` — "kernel logic extended to its asymptotic limit, boundary approached without being crossed" — which is *literally* the closure-residue predicate `x ≤ kᶜᶜ ∧ x ⊄ k`, i.e. **Exploitation**. So the systematic, structurally-derivable mapping is **(Exploitation, `commitment_yes` = true)**, with some genuinely-refusing works instead **(Refusal, `commitment_yes` = true)**:

- **Sokurov, *Russian Ark*** — formerly "Commitment," peer of Empire's Refusal → **(Exploitation, commitment-yes)**: the cut's continuity-management closure exploited past the standard stopping point.
- **Maillart's bridges, Béla Tarr, Rothko (image-pole), Partch** — likewise **(Exploitation, commitment-yes)** (per `comma-formal-structure-note.md` §5.5).
- **Bach, *Art of Fugue*** — *not* in the systematic commitment list. The Bach trajectory's pedagogical framing ("Infrastructure at its absolute boundary") is an allowed per-work divergence (migration 0171: such reads live in trajectory framing, not the DB cell).

**This mapping was already decided and implemented** — it is the May-2026 architecture in `comma-formal-structure-note.md` (revised 2026-05-10) and live migrations `0170–0173` (which add `commitment_yes`/`commitment_yes_reasoning`, remap `commitment → exploitation`, and drop the `commitment` response type). This note records and propagates that decision; it does not originate it.

The load-bearing pedagogical contrast survives, sharpened. Russian Ark and Empire share a surface (no conventional cuts) and oppose structurally, but as **disjoint Heyting regions**: Russian Ark works the closure-residue to its limit (Exploitation, `x ≤ kᶜᶜ ∧ x ⊄ k`); Empire refuses the kernel (Refusal, `x ≤ kᶜ`). Both are *outside the kernel's interior* — `kᶜᶜ ⊓ kᶜ = ⊥` makes them disjoint — which is why one is not the other.

## 4. Substantive consequence (not just a relabel)

The one place the two models genuinely disagree about a classification is **Russian Ark**: Commitment-peer-of-Refusal (old five-cell) vs. **(Exploitation, commitment-yes)** (canonical four-cell). Adopting four cells changes its cell label to Exploitation with the gate set. This is recorded, not concealed; it is the framework's correction architecture operating on its own taxonomy — and it is already the state of the database.

## 5. Propagation checklist

Surfaces still carrying the five-peer framing, to be brought into line:

- [ ] **Assistant system prompt** (`node0000/app/api/assistant/route.ts`) — "THE FIVE UNIVERSAL RESPONSES" → four positions + fidelity gate. *(in progress with this decision)*
- [ ] **`introduction` curriculum** intro section "The Five Universal Positions" (`node0000/db/0166`) — rewrite to four + gate. (Self-contained: the intro has no Commitment-classified item.)
- [x] **DB taxonomy + engagements** — done in migrations `0170–0173`: `commitment_yes` gate added, `commitment → exploitation` remapped, `commitment` response type dropped. Russian Ark is **(Exploitation, commitment-yes)** in the DB.
- [ ] **Cinema curriculum** Russian Ark item framing prose (`node0000/db/0129…`) — reframe the Russian Ark ↔ Empire contrast to Exploitation-at-limit vs. Refusal (the engagement cell is already correct via 0171; only the framing text still reads "Commitment"). *(Executed in the `/guides` four-cell build.)*
- [ ] **Renderer** (`node0000/app/guides/[slug]/page.tsx`) — display "Commitment" as a modifier, not a peer response, once the data is reclassified.
- [ ] **Paper 1** — replace the five-from-a-decision-tree derivation with the four-cell partition + Commitment-as-gate. (Separate prose task; largest single item.)
- [ ] **`/guides` position-trajectory layer** — build **four** position-rows (Infrastructure, Distribution, Exploitation, Refusal); teach Commitment as a depth modifier *inside* them, never as a fifth row.

## 6. What is unchanged

Infrastructure, Distribution, Exploitation, and Refusal keep their names, definitions, and every classification already resting on them. The five-position prose was never *wrong* about those four; it over-counted by promoting a within-cell intensity to a peer region. Everything written about Commitment as a real artistic stance (total fidelity, extension to the limit) remains true — it is now correctly located as a way of *occupying* a cell rather than as a cell of its own.

---

*Formal record: `lean/FalseWorkPapers/Positions/Partition.lean`. Companions: `position-taking-from-the-kernel-up.md` (§2, the kernel-checked partition and the Commitment gate), `four-position-exposition.md`, `comma-formal-structure-note.md`, `connecting-the-spine.md`.*
