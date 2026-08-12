// Test the generalized product law suggested by the Wolfram Cloud run of
// aperture-scaling.wl (2026-08-11), whose Div72 ambient apertures (9, 7, 9)
// were not pre-registered: for kernel p^i in Div(p^a * q^b) (exponent 0
// at q),
//   |Ap(p^i)| =? (2^i - 1)(2^(a-i) - 1) * (2^b - 1)
// i.e. nonempty-down-set counts below/above on the kernel's chain times
// (2^b - 1) on the other chain. Checked against Div36/72/144/216/60.
//
// RESULT (this file's run, 2026-08-11): exact on all 13 two-prime points.
// FAILS on three-prime Div60: Ap(2) = 3 observed vs 1 predicted. Note
// 3 = 4 - 1 = (nucleus count of the complementary factor C_2 x C_2) - 1,
// and in the two-prime case (2^b - 1) IS (chain nuclei - 1), so Div60 is
// the first point where the two readings separate and it picks the
// complement-nuclei one. One test point; recorded as a lead, not a law.

const gcd = (a, b) => (b ? gcd(b, a % b) : a)
function divAlg(n) {
  const elems = []
  for (let d = 1; d <= n; d++) if (n % d === 0) elems.push(d)
  const leq = (a, b) => b % a === 0
  const meet = gcd
  const cache = new Map()
  const imp = (a, b) => {
    const key = a + '|' + b
    if (cache.has(key)) return cache.get(key)
    let best = null
    for (const c of elems) if (leq(meet(a, c), b)) { if (best === null || leq(best, c)) best = c }
    cache.set(key, best)
    return best
  }
  return { n, elems, leq, meet, imp, bot: 1, top: n }
}
function nuclei(H) {
  const out = []
  const m = H.elems.length
  for (let mask = 0; mask < 1 << m; mask++) {
    if (!(mask & (1 << (m - 1)))) continue
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
const inAp = (H, j, k) => {
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

for (const n of [36, 72, 144, 216, 60]) {
  const H = divAlg(n)
  const N = nuclei(H)
  const fn = factorize(n)
  console.log(`Div${n}:`)
  for (const k of H.elems) {
    if (!ordinary(H, k)) continue
    const ap = N.filter(j => inAp(H, j, k)).length
    // generalized prediction if k = p^i (pure prime power, exponent 0 elsewhere)
    const fk = factorize(k)
    let pred = '-'
    const primes = Object.keys(fk).map(Number)
    if (primes.length === 1) {
      const p = primes[0], i = fk[p], a = fn[p]
      let val = (2 ** i - 1) * (2 ** (a - i) - 1)
      for (const q of Object.keys(fn).map(Number)) if (q !== p) val *= 2 ** fn[q] - 1
      pred = val
    }
    console.log(`  Ap(${k}) = ${ap}   generalized-law prediction: ${pred}${pred !== '-' ? (pred === ap ? '  MATCH' : '  MISMATCH') : ''}`)
  }
}
