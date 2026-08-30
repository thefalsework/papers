# The referee study: is the AFP anomaly institutional? (Answer: no.)

**Date.** 2026-08-30. **Status.** [computed]; RF3 [H], registered unrun.
Every scored test pre-registered in the script headers before first run;
blind census committed first.

**Verdict (single registered run, postscript in `03-growth.mjs`): RF2
FAILS BY REVERSAL.** The Isabelle distribution grows through Distribution
(G_ED = −0.021, percentile 0), like AFP — same community, opposite
institution, same regime. **The referee hypothesis is dead.** The
six-corpus split is now Mathlib/Go/crates (E grows) vs AFP/Isabelle
distribution (D grows), and every candidate axis so far — maintained vs
frozen, refereed vs open, proofs vs software, entry-grain vs file-grain —
is dead; the reversing pair uniquely shares the Isabelle ecosystem. E > R
held here too (percentile 100), on every corpus measured so far.

## The question

The growth-cell record after four corpora: Exploitation-cell members
out-grow matched Distribution siblings on Mathlib, Go, and crates.io —
maintained and frozen, proofs and software — and the ordering reverses only
on AFP (D > E). The garden/museum axis died on the software pair (frozen
crates grows through E), which leaves one live explanation, the **referee
hypothesis**: *an acceptance gate that admits only finished, self-contained
work exports the corpus's E phase to the outside; growth inside a refereed
archive flows citation-style through interface entries (D).* crates.io is
the control that motivates it: exactly as frozen as AFP, but ungated — and
it grows through E.

## RF2 — the within-community contrast (this study)

The Isabelle **distribution** (src/ theory graph, mirror-isabelle) is
maintained by the same community that populates AFP, in the same logic,
over the same two decades — but continuously refactored, with no per-entry
freeze and no referee at the door. Institution varies; community, domain,
and era are held fixed. Registered prediction (script 03): the
distribution grows through E (G_ED > 0, ≥ 97.5th percentile of the
within-cell label-permutation null). Reversal (D > E, as AFP) would kill
the referee hypothesis: the community, not the gate, would carry the
anomaly.

## Scripts

1. **`01-extract.mjs`** — blind: theory-level import graphs at eleven
   biennial checkpoints, 2006–2026, read straight from the object database
   of a blobless bare clone (bulk blob prefetch; no working tree). One
   plumbing repair logged in the header: checkpoint resolution restricted
   to the first-parent line after the Mercurial-converted history handed
   2010 a grafted side-line commit (jEdit subtree only). Node counts
   monotone, 834 → 1,843.
2. **`02-census.mjs`** — blind pre-check: occupancy counts, cycle
   structure, survival, stratum feasibility only. All eleven graphs are
   perfectly acyclic; 524–1,822 evaluable kernels per checkpoint; survival
   61–99% per baseline; strata feasible everywhere. Import-resolution
   ambiguity ~14% before 2018, ~2.7% after (session-qualified imports
   became standard) — dropped, never guessed; a within-baseline design, so
   a uniform undercount cannot favor either cell.
3. **`03-growth.mjs`** — the registered RF2 run (single run; verdict as
   postscript in its header after execution).

## RF1 — the label sidebar (deferred, descriptive when run)

Within AFP: do the D-cell members that grew describe themselves as
libraries/frameworks (entry titles/abstracts, authored independently of
this program)? Near-tautological if it holds, alarming if it fails;
calibration, not discovery. Requires its own blind resolution pre-check on
the label instrument; deferred until after RF2 reports.

## RF3 — registered, unrun: a refereed archive outside formal proof

Fixed here before any acquisition, per house rules. **Corpus: the RFC
series** (rfc-editor.org text corpus). Regime: heavily refereed (IETF
review), frozen at publication — the referee regime in its purest
non-proof form. Nodes: published RFCs. Edges: RFC-to-RFC citations
extracted from each document's References sections ([RFCnnnn] targets;
normative+informative pooled). **Acquisition gate (all scoring blocked
until passed):** (a) ≥ 95% of RFC texts parse to a references block or are
explicitly counted as pre-standard-format; (b) a blind resolution
pre-check shows the extracted graph is a DAG-after-condensation with ≥ 3
evaluable kernels at ≥ 4 biennial checkpoints. **Registered prediction
(RF3):** growth flows through Distribution (G_ED < 0 at ≤ 2.5th
percentile), the AFP pattern — the referee fingerprint in a second
refereed archive. Design constants inherited from 03 unchanged; horizon
+2 biennial checkpoints; seed 20260830733. If the gate fails, the study is
uninformative and a replacement refereed corpus is registered before
anything else is downloaded.

## Setup

```bash
git clone --bare --filter=blob:none https://github.com/isabelle-prover/mirror-isabelle .scratch_isabelle.git
```

Checkpoint SHAs pinned in `01-extract.mjs`; extracted graphs committed
under `history/` (small). Node ≥ 18, git ≥ 2.45 (GIT_NO_LAZY_FETCH).
