// Latent-ordinariness sweep. Prediction (stated before this run, from
// componentwise negation on products of chains):
//   ordinary ambient  <=> some exponent 0 AND some exponent strictly interior
//   latent (Ap nonempty, not ordinary) <=> ALL exponents strictly interior
// Predicts: no latency anywhere in Div(2^a * 3); latent {6} in Div36;
// latent {6,12} in Div72; latent {6,12,24} in Div144; latent {6,12,18,36}
// in Div216; none in square-free (Div30, Div60 has no all-interior point).
//
// POSTSCRIPT (2026-08-24, header above left as pre-registered): the latency
// rule this sweep "confirmed" is WRONG outside two-prime lattices — every
// algebra in this sweep is two-prime or square-free, exactly the shapes where
// the wrong rule and the right one coincide, so 10/10 confirmation was a
// coverage failure, not a validation. Counterexamples (both directions):
// Div8 elements 2,4 (all-interior, aperture 0 — single chain has no second
// coordinate); Div180 element 30 (5-exponent at chain top, aperture 4 — a
// world can truncate/drop a chain). Corrected rule and full verification:
// wolfram/latency-characterization-correction.mjs; paper Result 6.3.

const gcd = (a, b) => (b ? gcd(b, a % b) : a)

function divAlg(n) {
  const elems = []
  for (let d = 1; d <= n; d++) if (n % d === 0) elems.push(d)
  const leq = (a, b) => b % a === 0
  const meet = gcd
  const impTable = new Map()
  const imp = (a, b) => {
    const key = a + '|' + b
    if (impTable.has(key)) return impTable.get(key)
    let best = null
    for (const c of elems) if (leq(meet(a, c), b)) { if (best === null || leq(best, c)) best = c }
    impTable.set(key, best)
    return best
  }
  return { n, elems, leq, meet, imp, bot: 1, top: n }
}

function nucleiViaMoore(H) {
  const out = []
  const m = H.elems.length
  for (let mask = 0; mask < 1 << m; mask++) {
    if (!(mask & (1 << (m - 1)))) continue // must contain top (last elem)
    const F = []
    for (let i = 0; i < m; i++) if (mask & (1 << i)) F.push(H.elems[i])
    let closed = true
    outer: for (let x = 0; x < F.length; x++)
      for (let y = x + 1; y < F.length; y++)
        if (!F.includes(H.meet(F[x], F[y]))) { closed = false; break outer }
    if (!closed) continue
    const j = {}
    for (const a of H.elems) {
      let least = null
      for (const f of F) if (H.leq(a, f)) { if (least === null || H.leq(f, least)) least = f }
      j[a] = least
    }
    let ok = H.elems.every(a => H.leq(a, j[a]) && j[j[a]] === j[a])
    if (ok) ok = H.elems.every(a => H.elems.every(b => j[H.meet(a, b)] === H.meet(j[a], j[b])))
    if (ok) out.push(j)
  }
  return out
}

const inAperture = (H, j, k) => {
  const botJ = j[H.bot], kJ = j[k]
  const n1 = H.imp(kJ, botJ)
  return n1 !== botJ && H.imp(n1, botJ) !== kJ
}
const ordinary = (H, k) => {
  const n1 = H.imp(k, H.bot)
  return n1 !== H.bot && H.imp(n1, H.bot) !== k
}

function factorize(n) {
  const f = {}
  for (let p = 2; p * p <= n; p++) while (n % p === 0) { f[p] = (f[p] ?? 0) + 1; n /= p }
  if (n > 1) f[n] = (f[n] ?? 0) + 1
  return f
}
function predictLatent(n) {
  // all exponents strictly interior: 1 <= e_i(d) <= a_i - 1 for every prime
  const fn = factorize(n)
  const primes = Object.keys(fn).map(Number)
  const out = []
  for (let d = 2; d < n; d++) {
    if (n % d !== 0) continue
    const fd = factorize(d)
    if (primes.every(p => (fd[p] ?? 0) >= 1 && (fd[p] ?? 0) <= fn[p] - 1)) out.push(d)
  }
  return out
}

for (const n of [12, 24, 48, 96, 36, 72, 144, 216, 30, 60]) {
  const H = divAlg(n)
  const N = nucleiViaMoore(H)
  const ord = H.elems.filter(k => ordinary(H, k))
  const latent = []
  for (const k of H.elems) {
    const ap = N.filter(j => inAperture(H, j, k)).length
    if (ap > 0 && !ord.includes(k)) latent.push({ k, ap })
  }
  const pred = predictLatent(n)
  const got = latent.map(l => l.k)
  const match = JSON.stringify(pred) === JSON.stringify(got)
  console.log(
    `Div${n} (${H.elems.length} elems, ${N.length} nuclei): ordinary {${ord.join(',')}}  ` +
    `latent {${latent.map(l => `${l.k}:ap${l.ap}`).join(', ')}}  ` +
    `predicted {${pred.join(',')}}  ${match ? 'PREDICTION CONFIRMED' : 'PREDICTION FAILED'}`
  )
}
