# Phase 3: the wild pilot — does the instrument survive contact with code nobody wrote for it?

*Registered 2026-09-16, committed before any Phase 3 code exists and
before the corpus is cloned or inspected. This is the reality
crossing that killed the Debian claim, the neural-net phantom pilot,
and the load-tracking half of the bridge study. It is attempted now
because, for the first time, the mechanism is understood on both
sides of a boundary (gap-filling closures carry signal, partition
closures provably cannot), the degradation mode is measured and
named (widening, with its own meter), and the protocol has survived
three registered phases. Still no tool.*

## Amendment 1 (logged before second run)

First run: the thin-corpus gate fired — 6 functions passed the
whitelist, because the whitelist omitted **docstrings**
(`Expr(Constant(str))` as a statement), which nearly every function
in this repo carries. A docstring is semantically inert for integer
execution; the whitelist is amended to allow it as a no-op
statement. No other relaxation: `raise`, annotated assignment,
f-strings, and everything else stay excluded. This is a mechanical
repair to a registration oversight, made before any correlation was
computed (the gate stopped the run before statistics).

## Amendment 2 (logged before the quiet-stratum correlation was ever computed)

Second run: viability gates passed (23 included, 16 with ε > 0),
but the widening-quiet stratum landed at **n = 14, one short of the
registered 15**. Per registration: no H-W1 verdict. The harness
never computed the quiet-stratum Spearman, and it has not been
looked at — computing it first and then deciding whether to extend
the corpus would be the forking path this protocol exists to
prevent.

Extension, registered now: a **second corpus source**,
github.com/keon/algorithms, shallow-cloned at whatever commit is
HEAD at execution, same extraction, same whitelist (with Amendment
1), same execution bounds, deduplication across both sources. All
claims, thresholds, and kills are unchanged and are evaluated once,
on the union. If the union stratum still has n < 15, that is the
recorded end of Phase 3: no verdict, no third source, no threshold
lowering.

## Question

On real integer functions written by strangers for their own
reasons, does trajectory phantom mass predict the completeness error
of a standard interval analysis — in the stratum where the toy
results guarantee signal (widening-quiet code)?

## Corpus (rules registered before cloning; hash recorded at execution)

- **Source:** github.com/TheAlgorithms/Python, shallow-cloned at
  whatever commit is HEAD at execution time; the hash is recorded in
  the postscript. One source, no cherry-picking across sources.
- **Extraction:** every module-level `def` in every `.py` file,
  deduplicated by normalized-AST hash.
- **Inclusion (AST whitelist, registered now):** 1–3 parameters, all
  used as integers; body restricted to: integer constants; names;
  `+ − * // %`, unary minus; `abs`, `min`, `max` calls;
  comparisons and `and`/`or` in conditions; `if`/`elif`/`else`;
  `while` (including `while True`), `break`, `continue`;
  `for` over `range(...)` (desugared to `while`); single-name and
  parallel tuple assignment (the `a, b = b, a % b` idiom);
  augmented assignment; `return` of an integer expression. Anything
  else excludes the function. No calls other than the three named
  builtins, no recursion, no floats, no containers, no strings.
- **Execution bounds:** primary input box [−8, 8]^k exhaustively;
  functions that fail to terminate within 10,000 interpreter steps
  on any input, or whose values exceed |x| > 10^6, are retried on
  fallback box [0, 16]^k, then excluded and logged with the reason.
- **Viability gates (registered):** if fewer than 20 functions
  survive inclusion + execution, the corpus is too thin — record
  and stop, no verdict. If fewer than 10 surviving functions have
  ε > 0, record "the wild corpus is essentially complete for
  interval analysis at this box" — itself a finding — and stop, no
  correlation verdict.

## Semantics (conventions registered now)

- **Concrete ground truth:** exhaustive execution of every input in
  the box; at every statement, the set of environment tuples
  reaching it is recorded (the collecting semantics, computed
  exactly, no fixpoint needed).
- **Abstract analysis:** non-relational interval (box) domain with
  **standard interval arithmetic transfer** per operation — the
  real-analyzer convention, registered as a deliberate departure
  from the toys' per-op bca (closed-form transfer is what practice
  uses, and it is additionally blind to correlated expressions like
  `x*x`; ε here is the completeness error of a *realistic*
  analyzer). Guard refinement for variable-versus-constant
  comparisons only; variable–variable guards pass unrefined (sound,
  noted). Loops by standard widening at the loop head (unstable
  bounds jump to ±10^6); `break` paths joined into loop exit; no
  narrowing.

## Quantities (one datum per function)

- **ε** = |γ(exit interval)| − |γ(hull of concrete return set)| —
  counting-measure completeness error at the function's return.
- **P** = Σ over program points of s(point), where s = (product of
  per-variable hull widths) − (number of distinct concrete tuples
  at that point) — the collecting-semantics form of trajectory
  phantom. (Entry phantom is identically 0 here: the input set is
  exactly the box. All phantom is manufactured downstream; the
  input-only variant H1b has no wild analogue, noted.)
- **W** = total widening jump mass, as in Phase 2. Widening-quiet
  means W = 0 (no loops, or loops that stabilized without jumping).
- **Normalized forms (scale-confound guard, registered):**
  ε′ = ε / |γ(exit interval)|; P′ = P / Σ hull sizes. Functions
  differ wildly in value ranges; a raw cross-function correlation
  could be pure scale. Both raw and normalized are computed; the
  pass requires both.

## Hand anchors (asserted before the sweep)

- **A-corr:** `f(x): return x * x` on [−8, 8] — every concrete set
  is exactly representable per variable, but interval arithmetic is
  blind to the correlation: exit interval [−64, 64] against true
  hull [0, 64], ε = 64 > 0. The realistic analyzer's
  expression-level incompleteness exists and is measured.
- **A-complete:** `f(x): return x + 1` — ε = 0.
- Soundness assertion on every run: concrete return set ⊆ γ(exit
  interval); any violation is an interpreter bug, stop.

## Registered claims

- **H-W1 (primary).** Among widening-quiet functions (requires
  stratum n ≥ 15, else no verdict): Spearman(P, ε) ≥ 0.40 raw AND
  Spearman(P′, ε′) ≥ 0.25 normalized.
- **Attenuated band:** raw in [0.25, 0.40) — recorded, no verdict
  spin.
- **K-W1 (the kill).** Raw Spearman < 0.25 among widening-quiet
  functions. This is the stratum where the toys guarantee signal;
  decoupling here means **the instrument is toy-bound**, and the
  autopsy question (registered) is whether wild operation
  distributions — correlated guards and arithmetic, which random
  op-compositions do not have — are the mechanism. The note's
  abstract reports the death.
- **D-secondary (descriptive, no claims):** full-corpus pooled
  Spearman; Spearman(W, ε) among widening-active functions;
  ε = 0 rate; exclusion table with reasons.

## Postscript (2026-09-16, after the union run)

**Phase 3 ends with no verdict on H-W1, by its own registered
rules.** Corpus: TheAlgorithms/Python @ `351805cd` plus
keon/algorithms @ `7f71a911` (Amendment 2). 26 functions passed the
whitelist across both sources after dedup; 23 were included (3
excluded: 1 raises on the box, 2 exceed the magnitude cap on both
boxes). Both viability gates passed — 23 ≥ 20 included, 16 ≥ 10
with ε > 0. The widening-quiet stratum landed at **n = 14 against
the registered minimum of 15**, on both the single-source and union
corpora (the second source contributed one new whitelist function
and it was excluded on magnitude). Per Amendment 2, that is the
end: no verdict, no third source, no threshold lowering.

**The quiet-stratum Spearman was never computed and is not reported
anywhere, including here.** At n = 14 it could only function as an
unregistered verdict wearing a descriptive costume. Anyone who
wants it can rerun the committed harness and remove the gate; the
pre-registered answer to "did the instrument survive contact with
the wild?" is *the pilot was underpowered to say*, and that is the
honest headline.

**Descriptives (registered as D-secondary, no claims):**

- Pooled Spearman(P, ε), all 23 functions: **+0.710**.
- Spearman(W, ε), widening-active stratum (n = 9): **+0.489** —
  numerically close to Phase 2's +0.491 for the same quantity on
  toys, recorded as a coincidence until someone tests it.
- ε > 0 in 16/23 (70%): wild integer code at this box is *not*
  mostly complete for interval analysis.

**The granularity lesson (descriptive, and the real finding).** The
per-function table shows a mechanism the toys could not show. In
wild straight-line code, several functions carry **ε > 0 with P
identically 0**: `eval_quadratic_polynomial` (ε = 64),
`algebraic_sum` (16), bisection's `equation` (64), Simpson
integration's `f` (64), `sigmoid_derivative` — `x * (1 - x)` —
(72), and `hexagonal_num` (136) — all polynomial-shaped
expressions. These are the A-corr anchor's
mechanism at corpus scale: closed-form interval transfer is blind
to *correlated occurrences of the same variable inside one
expression* (`x*x` evaluates to [−64, 64] when the truth is
[0, 64]), and that conflation happens *inside* expression
evaluation, between statements' collecting sets — where
statement-level phantom mass cannot see it, because every
per-statement concrete set is exactly box-representable. Phantom
mass, as defined on the collecting semantics, measures conflation
*of states between program points*; wild code's dominant
incompleteness source in the loop-free stratum is conflation *of
subexpression occurrences within a point*. This is the same lesson
Phase 1 taught about partition domains, one level down: the
instrument sees exactly the conflation that lives at its own
granularity, and nothing finer. A Phase 4, if ever registered,
would need an expression-level phantom (per-node bca-vs-transfer
residual) — which is a different instrument, and is not being
claimed by this one.

Duplicate note: `count_divisors` appears twice (Euler 012 sol1 and
sol2) with identical statistics; the AST-dump dedup key
distinguishes them on incidental text. Logged, not repaired —
removing one changes no gate or descriptive materially, and
post-hoc dedup rule changes are exactly the kind of knob this
protocol forbids touching after results exist.

## Non-claims

No tool. No relational domains, no narrowing, no claim about
industrial analyzers or programs beyond this AST subset and these
boxes. Corpus yield is unknown at registration; thin-corpus and
mostly-complete outcomes are recorded as findings, not failures of
the instrument. One run; repairs logged with their nature.
