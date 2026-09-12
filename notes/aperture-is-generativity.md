# The Aperture Is a Generativity Count

*2026-09-12, written the afternoon the bridge-study Phase 2–3 runs
completed. This note records an identity, not a new result: two
statements that emerged separately in the bridge study are the same
theorem read at two layers, and the chain connecting them is
kernel-checked except for one link.*

## The identity

Two phrasings appeared in the Phase 2–3 analysis:

1. *"The four-cell condition in graph clothes"* — a sub-ecosystem S
   counts toward aperture(↓p) when p's dependency shadow, seen
   within S, has both an outsider and a hanger-on.
2. *"The number of perspectives from which a position remains a
   generative distinction."*

These are identical. The chain, with grades:

- **[K]** `lattice_four_position_partition` (Layer L): for a kernel
  `a` and any nonzero `x`, exactly one of Infrastructure (`x ≤ a`),
  Distribution (`x` meets both `a` and `aᶜ`), Exploitation
  (`x ≤ aᶜᶜ`, `x ≰ a`), Refusal (`x ≤ aᶜ`) holds.
- **[K]** `allFourCellsInhabited_iff`: all four cells are inhabited
  ⟺ `a` is ordinary (`a ≠ ⊥`, `aᶜ ≠ ⊥`, `aᶜᶜ ≠ a`). The Refusal
  cell is inhabited exactly by non-density (witness `aᶜ`), the
  Exploitation cell exactly by non-regularity (witness `aᶜᶜ`),
  Distribution by their join. *Non-degeneracy is ordinariness* —
  the wound is a womb iff the element is ordinary.
- **[K]** `Opens j k` (the aperture's membership predicate) is by
  definition ordinariness of `j k` in the observer's world `Fix j`.
- **[verified, Lean pending]** Bridge-study E5: on down-set
  algebras, `Opens j_S (↓p)` ⟺ the trace `↓p ∩ S` is ordinary in
  `D(S)` — checked exhaustively on 92 algebras, every cone, every
  observer; not yet a Lean theorem.

Substituting: **aperture(↓p) = the number of stagings S in which
p's shadow splits S's world into four inhabited positions.** The
per-staging predicate is (1); the count is (2). One theorem, two
layers.

## The graph dictionary of the four positions

Relative to a package p and a staging S, with T = ↓p ∩ S:

- **Infrastructure — the commons.** Packages inside p's shadow.
- **Exploitation — the tenants.** Packages outside the shadow all
  of whose needs are entangled with it: they lean wholly on the
  commons without being it. (The ¬¬-residue; empty exactly where
  the algebra is Boolean, i.e. where no one leans.)
- **Refusal — the independents.** Packages sharing nothing with
  the shadow.
- **Distribution — the traders.** Packages straddling: some needs
  in the commons, some independent. (At the node level this cell
  can be empty; the theorem's witness is element-level, `T ⊔ ¬T`.)

## The demo (xz motif, computed 2026-09-12)

liblzma has 21 qualifying stagings. In the largest one — glibc
excluded, as it must be: the universal base collapses every
partition (H1), which is why glibc's aperture is 0 — the four
positions of the ecosystem relative to liblzma are:

    Infrastructure:  liblzma
    Exploitation:    libsystemd, sshd
    Refusal:         app2, app3, libssl
    Distribution:    (empty at node level)

The Exploitation cell is the attack chain. The actual xz backdoor
propagated liblzma → libsystemd → sshd; the cell that the
four-position theorem has called "Exploitation" since its
topos-theoretic beginnings — named years before any dependency
graph entered this program — contains exactly the packages through
which the exploit traveled. Structurally this is not a coincidence:
Exploitation = wholly inside the double-negation closure of the
commons without being the commons = compromised through it.

## What this reframes

- **The aperture's meaning, stated exactly.** Not "importance," not
  load: the number of vantage points from which a package's position
  still generates the full four-position structure. The Phase 3
  depth test showed this is no known centrality (best competitor:
  betweenness at median |ρ| = 0.51) and that it does *not* track
  load at scale (E9 failed, recorded).
- **The quiet-criticality inversion (post hoc, unregistered).** Deep
  infrastructure like liblzma is *rarely generative*: from most
  stagings it is conflated behind its interface. Low aperture at
  high load — heavy and indistinct — is a candidate signature of
  the xz position. This is a hypothesis formed after seeing the
  data; it inherits nothing from the failed E9 and would need its
  own registered spec.
- **The loop back to the program's origin.** The four positions —
  Infrastructure, Distribution, Exploitation, Refusal — began as a
  partition of positions relative to a kernel in the original
  FalseWork dictionary. The bridge study now shows the same four
  positions materialize inside dependency graphs, package by
  package, staging by staging, with the aperture counting the
  stagings in which the full society exists. Position over
  properties, all the way down.

## Missing link

One item separates this note from a theorem: E5 in Lean (the trace
characterization). Everything on either side of it is already
kernel-checked.
