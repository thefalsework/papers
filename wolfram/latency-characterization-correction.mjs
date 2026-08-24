// Div180 element-30 check + full violation hunt for the latency characterization.
//
// PRE-REGISTRATION (written before this run, 2026-08-24):
// Claim under test: the paper's Result 6.2 / Corollary 5.3 characterization
//   latent  <=>  every prime exponent strictly interior (0 < e < a)
// is FALSE for >= 3 primes. Predicted counterexample: Div180 = 2^2*3^2*5,
// element 30 = (1,1,1): exponent of 5 is at its chain top (a=1), NOT interior,
// yet |Ap(30)| = 4 by the paper's own closed form (32 - 18 - 18 + 8).
// Mechanism: a coarse world may truncate a chain from below or drop it,
// leaving the image with a zero coordinate next to an interior one -
// world-ordinary by the paper's own ambient rule.
// Predicted corrected characterization (to be tested on every element of all
// 15 lattices, enumeration vs formula vs rule):
//   Ap(k) nonempty <=> some e_c strictly interior AND some OTHER chain c' has e_{c'} < a_{c'}
//   latent         <=> nonempty AND every e_c >= 1  (ambient-ordinary needs a zero exponent)
// Predicted violations of the OLD rule within the 15 tested lattices:
// exactly the elements with all e >= 1, some e interior, some other chain
// e' < a', but NOT all interior. In the 15-lattice set that should be
// Div180 element 30 only (least such shape needs two squared primes + a third prime).
// The closed form itself is NOT under suspicion (it matched enumeration);
// under test is the prose characterization derived from it.

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
  return { n, elems, m, idx, leq, meet, imp, bot: 0 }
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
const ambientOrdinary = (H, k) => {
  const n1 = H.imp[k][H.bot]
  return n1 !== H.bot && H.imp[n1][H.bot] !== k
}

function factorize(n) {
  const f = []
  for (let p = 2; p * p <= n; p++) if (n % p === 0) {
    let a = 0
    while (n % p === 0) { n /= p; a++ }
    f.push([p, a])
  }
  if (n > 1) f.push([n, 1])
  return f
}
const expOf = (d, p) => { let e = 0; while (d % p === 0) { d /= p; e++ } return e }

// Paper's closed form (Theorem 5.1) per-chain counts
function closedForm(fac, d) {
  let N = 1, D = 1, R = 1, DR = 1
  for (const [p, a] of fac) {
    const e = expOf(d, p)
    N *= 2 ** a
    D *= (2 ** e - 1) * 2 ** (a - e) + 1
    R *= 2 ** (a - e) + 2 ** e - 1
    DR *= 2 ** e
  }
  return N - D - R + DR
}

// OLD characterization (paper Result 6.2 / Cor 5.3)
function oldRule(fac, d) {
  const es = fac.map(([p, a]) => [expOf(d, p), a])
  const someZero = es.some(([e]) => e === 0)
  const someInterior = es.some(([e, a]) => e > 0 && e < a)
  const allInterior = es.every(([e, a]) => e > 0 && e < a)
  const ordinary = someZero && someInterior
  const nonempty = ordinary || allInterior
  return { ordinary, latent: allInterior, nonempty }
}

// NEW proposed characterization
function newRule(fac, d) {
  const es = fac.map(([p, a]) => [expOf(d, p), a])
  const someZero = es.some(([e]) => e === 0)
  const someInterior = es.some(([e, a]) => e > 0 && e < a)
  const ordinary = someZero && someInterior
  // nonempty iff exists c interior AND exists c' != c with e' < a'
  let nonempty = false
  for (let c = 0; c < es.length; c++) {
    const [e, a] = es[c]
    if (!(e > 0 && e < a)) continue
    for (let c2 = 0; c2 < es.length; c2++) {
      if (c2 === c) continue
      const [e2, a2] = es[c2]
      if (e2 < a2) { nonempty = true; break }
    }
    if (nonempty) break
  }
  // single-chain case: nonempty iff interior? For one chain, ordinary impossible
  // (chains have no ordinary elements in any world) -> nonempty = false. Handled:
  // loop finds no c2, stays false. Prime-power lattices are chains: Ap always empty?
  // No! Paper: Div8 etc are chains; chains have no ordinary elements in any world
  // (every world is a chain). Formula check will adjudicate.
  const latent = nonempty && !ordinary
  return { ordinary, latent, nonempty }
}

const LATTICES = [6, 8, 12, 24, 48, 96, 192, 36, 72, 144, 216, 30, 60, 120, 180]

console.log('=== PART 1: Div180 element 30, direct enumeration ===')
{
  const H = buildAlg(180)
  const nuclei = enumerateNuclei(H)
  console.log(`Div180: ${H.m} elements, ${nuclei.length} nuclei enumerated`)
  const k = H.idx.get(30)
  console.log(`ambient ordinary(30) = ${ambientOrdinary(H, k)}  (expected false: 30 is dense)`)
  const opening = nuclei.filter(j => inAp(H, j, k))
  console.log(`|Ap(30)| by ENUMERATION = ${opening.length}  (paper's old rule predicts 0; pre-registered prediction 4)`)
  console.log(`|Ap(30)| by CLOSED FORM  = ${closedForm(factorize(180), 30)}`)
  for (const j of opening) {
    const fixed = H.elems.filter((_, i) => j[i] === i)
    console.log(`  opening world: Fix = {${fixed.join(',')}}  j(bot)=${H.elems[j[H.bot]]}  j(30)=${H.elems[j[k]]}`)
  }
}

console.log('\n=== PART 2: violation hunt, all elements of all 15 lattices ===')
let checked = 0, formulaMismatch = 0
const oldViolations = [], newViolations = []
for (const n of LATTICES) {
  const H = buildAlg(n)
  const fac = factorize(n)
  const nuclei = enumerateNuclei(H)
  for (let k = 0; k < H.m; k++) {
    const d = H.elems[k]
    const apSize = nuclei.reduce((s, j) => s + (inAp(H, j, k) ? 1 : 0), 0)
    const cf = closedForm(fac, d)
    if (apSize !== cf) { formulaMismatch++; console.log(`  FORMULA MISMATCH Div${n} d=${d}: enum ${apSize} vs formula ${cf}`) }
    const ord = ambientOrdinary(H, k)
    const latent = !ord && apSize > 0
    const o = oldRule(fac, d), nw = newRule(fac, d)
    if (o.latent !== latent || (o.nonempty) !== (apSize > 0))
      oldViolations.push(`Div${n} d=${d}: actual |Ap|=${apSize} latent=${latent}; OLD predicted nonempty=${o.nonempty} latent=${o.latent}`)
    if (nw.latent !== latent || (nw.nonempty) !== (apSize > 0))
      newViolations.push(`Div${n} d=${d}: actual |Ap|=${apSize} latent=${latent}; NEW predicted nonempty=${nw.nonempty} latent=${nw.latent}`)
    checked++
  }
}
console.log(`elements checked: ${checked}; formula mismatches: ${formulaMismatch}`)
console.log(`OLD characterization violations: ${oldViolations.length}`)
for (const v of oldViolations) console.log('  ' + v)
console.log(`NEW characterization violations: ${newViolations.length}`)
for (const v of newViolations) console.log('  ' + v)

console.log('\n=== PART 3: new rule vs closed-form positivity, formula-only extension ===')
// Larger lattices, formula vs new rule only (enumeration infeasible or unnecessary)
const EXTRA = [360, 900, 1260, 2520, 4500, 44100]
let extraChecked = 0, extraViol = 0
for (const n of EXTRA) {
  const fac = factorize(n)
  for (const d of divisors(n)) {
    const cf = closedForm(fac, d)
    const nw = newRule(fac, d)
    if ((cf > 0) !== nw.nonempty) {
      extraViol++
      console.log(`  DISAGREE Div${n} d=${d}: formula ${cf}, new rule nonempty=${nw.nonempty}`)
    }
    extraChecked++
  }
}
console.log(`formula-vs-new-rule points checked: ${extraChecked}; disagreements: ${extraViol}`)
