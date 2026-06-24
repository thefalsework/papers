# Start Here — the short, plain-English version

If you've landed in this repository and the front page reads like a wall of jargon, this page is for you. No background needed. About a five-minute read.

---

## The one idea

Some fields are built on a single basic move — and that move creates the whole field precisely *because* it never quite resolves. There's a small permanent gap baked into the foundation, and a surprising amount of what people *do* in the field is really a response to that gap.

That's the whole idea. The rest is working it out carefully, and the clearest place to see it is music.

---

## The music story (the easiest way in)

Western music uses **12 notes** in an octave. Why 12? Not by decree — it falls out of a problem.

Start with the most natural-sounding interval after the octave: the **perfect fifth** (the distance from C to G; physically, a frequency ratio of 3 to 2). Keep stacking fifths — C, G, D, A, and so on — and after twelve steps you *almost* land back where you started, seven octaves up. **Almost.** You miss, by a tiny amount, every time. That miss is real, it's called the **Pythagorean comma**, and no amount of cleverness can make it vanish — it's a fact of arithmetic, not a flaw in anyone's instrument.

So the foundation of tuning has a permanent crack in it: the most natural building-block interval *doesn't close the circle*. Everything in tuning is a way of coping with that crack. **Equal temperament** — the system on every piano — copes by smearing the gap evenly across all twelve notes, so each one is a hair out of tune and none is unbearably so.

Here's the part we actually *proved* (a computer checked the proof, the way it would check a math theorem): **of all the ways you could divide the octave, 12 is the smallest one with a special internal structure** — the smallest where a single "off-center" note, the **tritone**, plays a unique organizing role. 12 isn't arbitrary. It's forced, for a precise reason. (The technical version lives in [`validation/claims/why-twelve-tet.md`](validation/claims/why-twelve-tet.md), but you don't need it.)

---

## The four ways to respond (the lens)

Once you see that music is built around an unclosable gap, you can ask of any piece: **what stance does it take toward that gap?** Four show up again and again:

- **Work inside it.** Use a system that already absorbed the gap and just make music. *(Bach, writing within a single key.)*
- **Spread it around.** Accept the gap and distribute it everywhere so it's never concentrated. *(Equal temperament itself.)*
- **Exploit it.** Make the gap the actual subject — push the system past where it wants to resolve, and use the not-resolving as your material. *(Coltrane's* Giant Steps*.)*
- **Refuse it.** Throw out the founding move entirely and build on a different principle. *(Schoenberg abandoning tonality for twelve-tone rows.)*

That's the lens. The interesting claim is that these same four stances seem to show up **far beyond music** — in film, painting, physics, even mathematics — wherever a field is organized around one of these self-undermining founding moves.

---

## What's proven vs. what's a reading (the honest part)

This matters, and the project is built around being upfront about it:

- **Proven** (machine-checked, not a matter of opinion): the music math — the gap, the role of 12, the special status of the tritone. A computer verified these the way it verifies any theorem.
- **A reading** (interpretation, *not* proven): the bigger claim that the four stances apply across film, painting, physics, and the rest. This is an interpretive lens. It can be illuminating and still be wrong in places. It's offered as "does this help you see your field?" — not "this is settled fact."

If you remember one thing: the *music spine* is hard and checkable; the *cross-everything pattern* is a lens you're invited to test, push on, or break.

---

## You don't have to be a specialist to engage

Most of this repo is built for mathematicians and logicians. You are not obligated to read any of it. If something here made you think — agreed, disagreed, "this is obviously true in *my* field," or "this is obviously false in *my* field" — that reaction is genuinely useful, and you can share it without any technical machinery:

- **Just want to talk about it?** Open a [Discussion](https://github.com/thefalsework/papers/discussions) (no code, no formal claim required — plain questions and pushback welcome).
- **Prefer email?** `chris@falsework.dev`. Say where the lens rings true or false in whatever you know best.
- **Want the narrative version?** [falsework.dev/thesis](https://falsework.dev/thesis) tells the story end to end, no math.

The whole project runs on the bet that an honest framework should be *legible to anyone who's curious* and *testable by anyone who knows a field it touches*. You qualify on at least one of those just by being here.

---

*Next step up in detail: [`papers/INDEX.md`](papers/INDEX.md) (a guided tour of all the papers) or the [main README](README.md) (the full, technical front page).*
