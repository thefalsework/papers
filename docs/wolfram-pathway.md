# Wolfram Pathway: the focused plan

**Goal: one email to the Wolfram Institute Computational Metaphysics team, carrying a runnable answer to their open question.**

*August 2026. This is an operational plan, not a paper. It subordinates the full computable-criticism roadmap (`papers/computable-criticism-roadmap.md`) to a single deliverable, and parks everything not on the critical path. Computation is the goal; continued work with the metaphysics team is the direction.*

---

## 1. The open loop being closed

- **Jan 3, 2026** — Stephen Wolfram replies personally to a cold-contact structural analysis of NKS; asks: can it go symbolic? can patterns transfer? what happens under recursive self-application?
- **Apr 4, 2026** — Wolfram forwards the thread to the Wolfram Institute philosophy team.
- **May 3, 2026** — Ellynne Dec (Computational Metaphysics group) sends a four-query specification.
- **May 2026** — The prototype ships (`wolfram/`): all four queries delivered. Her deepest question — *"can it alter the method, improve the core schema, or produce new formal distinctions?"* — deferred to V2, honestly, because a five-work hand-authored corpus cannot support schema mutation: recursion over self-authored data returns its own assumptions.
- **The move now:** the production platform (falsework.dev) has a database of machine-generated structural profiles. Feeding them into the algebra removes the V1 limitation and makes the deferred question *runnable*. The follow-up email presents that, plus one theory bridge written in their vocabulary.

## 2. The email's three artifacts

1. **Machine-fed algebra run.** Transduce existing structural profiles (node0000 DB) into Core v2 JSON (`papers/computable-criticism-roadmap.md` §5.1), load as `Core[...]` heads, rerun Q1–Q4 on a corpus the analyst never hand-authored. Deliverable: updated notebook + results table alongside the V1 reference run.
2. **Comma-shape graduation.** In V1, comma-shape match reduces to hand-authored label equality (the Tymoczko ↔ Cutting match was planted before the code found it — documented in `wolfram/README.md`'s own scope limits). With instance graphs underneath, check claimed comma shapes against structure. Deliverable: even a first crude derivation graduates the algebra's headline capability from articulation to measurement — a result about *their* specification.
3. **The aperture note (arXiv, cs.AI).** Observers-as-nuclei: a nucleus is a coarse-graining operator; its fixed-point algebra is the world at that resolution; the Boolean quotient (¬¬) is the reducibility pocket; ordinary elements live at the reducible/irreducible boundary — and the four-fold opens only there (`allFourCellsInhabited_iff`, [K]). New computable invariant: the **aperture** of a kernel = the set of nuclei under which it stays ordinary (which observers see its four-fold open). Finite, enumerable, prototyped on Div12. Status discipline: [A] mapping, [O] for any formal bridge to dynamical irreducibility — the disanalogy (nuclei are static resolution, Wolfram irreducibility is temporal cost) is stated, not hidden.

## 3. Sequence

| # | Step | Where | Effort | Exit test |
|---|---|---|---|---|
| 1 | Core v2 transduction — backfill script over existing profiles; LLM emits typed graph JSON; no pipeline surgery yet | node0000 | 1–2 sessions | ≥ 10 profiles emit valid `CoreV2` (schema-validated) |
| 2 | WL loader `CoreV2 JSON → Core[...]` + machine-fed rerun of Q1–Q4; notebook captured | `wolfram/` | 1 session | four queries run on machine-fed corpus; results table vs V1 |
| 3 | Aperture prototype — enumerate nuclei on Div12 (+ 1–2 small Heyting algebras); compute kernel ordinariness under each | `wolfram/` | 1 session | aperture computed for the tritone-slot kernel; one figure |
| 4 | Nucleus/aperture note — drafted, edited, posted via the open cs.AI channel | papers repo | 1–2 sessions | on arXiv; courtesy copy to Levin |
| 5 | The Ellynne email — thread history, V2 answer, working-session ask | — | trivial once 1–4 exist | sent |

Total: roughly 2–3 weeks of working sessions. Every step is independently valuable if the email gets no reply.

## 4. Assets already in hand

- **The routing exists.** Ellynne's May spec is an invitation to respond to; this is a reply, not a cold contact.
- **The cs.AI channel is open.** Ilia Levin's endorsement (confirmed May 27, 2026 — correspondence documented in the Paper 2 record; §6 Levin material trimmed at v8.15 for arXiv scope) means future cs.AI postings need no new endorsement. Courtesy copy of the aperture note to Levin maintains the relationship that opened the channel.
- **The V1 artifact is delivered and honest.** Its README states its own limits (articulation, not validation) — which is exactly what makes "the limits are now removed" a strong follow-up.
- **The [K] spine travels.** The four-position partition and ordinariness biconditional are Lean-checked; the metaphysics group can verify in minutes. This is the anti-absorption credential: the framework arrives as a peer programme with its own foundations, not as an application of ruliology.

## 5. Framing discipline for the email

- Thesis sentence: **"Here is the span from your bank to ours — your observers are our nuclei, and the corpus is now machine-fed, so the question you asked in May is now runnable."**
- Complementarity, never deficiency: not "what observer theory is missing" but "the two halves of the bridge, built from opposite banks — ruliad → observer on yours, practice → founding on ours, meeting at the nucleus."
- The absorption guard: every artifact keeps the kernel anchor load-bearing (a schema without a kernel reference is malformed — the algebra's own design commitment). FalseWork is a peer, not a satellite.

## 6. Parked (deliberately, not abandoned)

- **Executor + audit** (roadmap Phase 1 proper) — the platform's most important internal work; the WL algebra's `RemoveAndProject` covers the email's needs. Resume after sending.
- **Reliability studies** (roadmap Phase 3) — still the make-or-break science for the instrument; not blocking this email.
- **Enumeration + computational essay** (roadmap Phase 4) — mention as direction in the email; do not build first.
- **Tarnas / two-red-books outreach** — separate track; written, costs one send, independent of all of the above.
- **Kernel-scale note** (roadmap §4 as standalone paper) — parallel writing whenever; not on this path.

## 7. Failure modes to watch

- **Scope creep at Step 1**: the transduction does not need the removal-test executor, the audit, or pipeline changes — a backfill script over stored profiles suffices for the email.
- **Building Phase 4 because it's fun**: enumeration is the most Wolfram-flavored step and the most tempting; it is not on the critical path.
- **Overclaiming the aperture note**: [A]/[O] tags survive contact with that audience; a flat claim does not.
- **Waiting for perfect**: the email's job is to reopen the loop with runnable substance, not to close the research programme.

---

*Companions: `papers/computable-criticism-roadmap.md` (full spec this plan subordinates), `wolfram/README.md` + `wolfram/design-notes.md` (V1 artifact and its deferred V2 list), `papers/the-bridge-and-the-caviar.md` (the bridge thesis), `lean/FalseWorkPapers/Positions/OrdinaryKernel.lean` (the ordinariness biconditional the aperture note builds on).*
