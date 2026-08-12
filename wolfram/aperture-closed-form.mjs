// Closed-form aperture test, every element of every lattice.
//
// THE CLOSED FORM (derived 2026-08-11, then verified):
//   |Ap(k)| = prod N_c - prod D_c - prod R_c + prod DR_c
// with per-prime-chain counts (chain height a, kernel exponent e):
//   N  = 2^a                        (nuclei on the chain)
//   D  = (2^e - 1) 2^(a-e) + 1      (worlds where j(e) is dense)
//   R  = 2^(a-e) + 2^e - 1          (worlds where j(e) is regular)
//   DR = 2^e                        (worlds where it is both)
//
// Derivation: (1) nuclei on a product H = A x B factor componentwise -
// PROVABLE, not just observed: for a nucleus j, (a,b) = (a,T) ^ (T,b)
// and meet-preservation give j(a,b) = j(a,T) ^ j(T,b) = (jA a, jB b)
// with jA(a) = pi_A j(a,T) a nucleus on A; (2) density and regularity
// in a product world are coordinate-local (negation is componentwise);
// (3) the chain counts D/R/DR are elementary down-set counts; so
// inclusion-exclusion over "all coordinates dense" / "all coordinates
// regular" gives the formula.
//
// RESULT (2026-08-11): exact on all 164 elements of all 15 divisor
// lattices tested (6, 8, 12, 24, 48, 96, 192, 36, 72, 144, 216, 30,
// 60, 120, 180), zero mismatches - including all 109 zero-aperture
// elements, where the inclusion-exclusion must cancel exactly, and
// every mixed (non-prime-power) kernel. Subsumes the two-prime product
// law, the latency characterization, and the latent aperture sizes
// previously reported as unfitted data.

function divisors(n) {
  const d = []
  for (let i = 1; i <= n; i++) if (n % i === 0) d.push(i)
  return d
}
const gcdf = (a, b) => (b ? gcdf(b, a % b) : a)
function buildAlg(n) {
  const elems = divisors(n)
  const m = elems.length
  const idx = new Map(elems.map((e, i) => [e, i]))
  const leq = Array.from({ length: m }, (_, i) =>
    Array.from({ length: m }, (_, j) => elems[j] % elems[i] === 0))
  const meet = Array.from({ length: m }, (_, i) =>
    Array.from({ length: m }, (_, j) => idx.get(gcdf(elems[i], elems[j]))))
  const imp = Array.from({ length: m }, (_, i) =>
    Array.from({ length: m }, (_, j) => {
      let best = -1
      for (let c = 0; c < m; c++)
        if (leq[meet[i][c]][j]) { if (best === -1 || leq[best][c]) best = c }
      return best
    }))
  return { n, elems, m, leq, meet, imp, bot: 0 }
}
function enumerateNuclei(H) {
  const { m, meet, leq } = H
  const out = []
  const topBit = 1 << (m - 1)
  for (let mask = 0; mask < 1 << m; mask++) {
    if (!(mask & topBit)) continue
    const members = []
    for (let i = 0; i < m; i++) if (mask & (1 << i)) members.push(i)
    let closed = true
    outer: for (let x = 0; x < members.length; x++)
      for (let y = x + 1; y < members.length; y++)
        if (!(mask & (1 << meet[members[x]][members[y]]))) { closed = false; break outer }
    if (!closed) continue
    const j = new Array(m)
    for (let a = 0; a < m; a++) {
      let least = -1
      for (const f of members) if (leq[a][f]) { if (least === -1 || leq[f][least]) least = f }
      j[a] = least
    }
    let ok = true
    for (let a = 0; a < m && ok; a++) ok = leq[a][j[a]] && j[j[a]] === j[a]
    for (let a = 0; a < m && ok; a++)
      for (let b = 0; b < m && ok; b++) ok = j[meet[a][b]] === meet[j[a]][j[b]]
    if (ok) out.push(j)
  }
  return out
}
const inAp = (H, j, k) => {
  const botJ = j[H.bot], kJ = j[k]
  const n1 = H.imp[kJ][botJ]
  return n1 !== botJ && H.imp[n1][botJ] !== kJ
}
function factorize(n) {
  const f = {}
  for (let p = 2; p * p <= n; p++) while (n % p === 0) { f[p] = (f[p] ?? 0) + 1; n /= p }
  if (n > 1) f[n] = (f[n] ?? 0) + 1
  return f
}
function closedForm(n, k) {
  const fn = factorize(n)
  let N = 1, D = 1, R = 1, DR = 1
  for (const [p, a] of Object.entries(fn).map(([p, a]) => [Number(p), a])) {
    let e = 0, kk = k
    while (kk % p === 0) { e++; kk /= p }
    N *= 2 ** a
    D *= (2 ** e - 1) * 2 ** (a - e) + 1
    R *= 2 ** (a - e) + 2 ** e - 1
    DR *= 2 ** e
  }
  return N - D - R + DR
}

let total = 0, mismatches = 0, zeros = 0, nonzeros = 0
const lattices = [6, 8, 12, 24, 48, 96, 192, 36, 72, 144, 216, 30, 60, 120, 180]
for (const n of lattices) {
  const H = buildAlg(n)
  const N = enumerateNuclei(H)
  const rows = []
  let z = 0, nz = 0
  for (let ki = 0; ki < H.m; ki++) {
    const measured = N.filter(j => inAp(H, j, ki)).length
    const predicted = closedForm(n, H.elems[ki])
    total++
    if (measured === 0) { z++; zeros++ } else { nz++; nonzeros++ }
    if (measured !== predicted) {
      mismatches++
      rows.push(`  MISMATCH Ap(${H.elems[ki]}): measured ${measured}, closed form ${predicted}`)
    }
  }
  console.log(`Div${n}: ${H.m} elements (${z} zero-aperture, ${nz} nonzero), ` +
    `${N.length} nuclei — ` +
    (rows.length ? 'FAILURES:' : 'closed form exact on all elements'))
  rows.forEach(r => console.log(r))
}
console.log(`\n${total} elements checked across ${lattices.length} lattices, ` +
  `${mismatches} mismatches`)
console.log(`zero-aperture elements (inclusion-exclusion must cancel exactly): ` +
  `${zeros}; nonzero: ${nonzeros}`)
