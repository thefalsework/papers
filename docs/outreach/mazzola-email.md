# Outreach email — Guerino Mazzola

**Target:** Prof. Guerino Mazzola (author, *The Topos of Music*)
**Attachment:** `mazzola-bridge-note.pdf` (rendered from
`preprints/four-position-partition/music-anchor/mazzola-bridge-note.md`)
**Send rule:** lead with the note alone; the four-position-partition
paper is the follow-up only if he engages.

---

**Subject:** A kernel-checked four-position partition on the subgroup lattice of ℤ/12 — one topos question for you

Dear Professor Mazzola,

I'm writing with a precise question that sits squarely in the world your *Topos of Music* built, and that I can't answer from outside your framework.

I've been working on a small theorem — a four-position partition of morphisms in any elementary topos carrying a non-trivial distinction structure (D, η, ι), where the cells are determined entirely by where Im(D f) sits in the Heyting algebra Sub(D Y) relative to the kernel image Im(η). The Exploitation cell exists only when double negation is strict. The theorem and its proof are formalized in Lean and kernel-checked against Mathlib.

It instantiates, non-vacuously and machine-checked, on an entirely standard piece of music mathematics: the subgroup lattice of ℤ/12 — the transposition-symmetric pitch-class sets. With the tritone as kernel, the four cells land on the tritone, augmented triad, diminished seventh, and whole-tone/chromatic; the tritone turns out to be the *unique* kernel in that lattice at which all four cells are inhabited, and it is not a chosen parameter but the kernel image of a concrete idempotent closure operator I can exhibit.

What I cannot determine on my own is whether this finite instance is a *slice of a canonical music topos* rather than a bespoke construction. Precisely: is there an object in your denotator / local-composition framework whose subobject lattice is the subgroup lattice of ℤ/12, with my closure operator arising as an idempotent monad (a sheafification or symmetrization) on it? If so, the music classification would be a structural consequence of your apparatus rather than something that merely agrees with it.

I've attached a short, self-contained note (about five pages) that states exactly what is proven, what is not, and the three sub-questions I'd value your judgment on. It assumes nothing about my broader program. I'd be grateful for your eye on whether the bridge holds — it's the kind of thing you'd likely see in an afternoon that I could chase for months.

With appreciation,

Chris Brink
falsework.dev
