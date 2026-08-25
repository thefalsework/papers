// Study 10, script 01 — anchors before any Life cone (v1.1 §9).
//
// Must pass, in order, before 02/03/04 are run:
//   1. Div12 = Down(C2 + C1): every element matches the closed form [K];
//      Ap(2) = 1 with the identity as its sole member (kernel-checked
//      upstream: aperture_two_complete).
//   2. Div36 = Down(C2 + C2): every element matches the closed form;
//      |Ap(6)| = 2 (kernel-checked: latent_ordinariness_witness,
//      aperture_six_complete), and element 6 is latent.
//   3. 3-chain: every principal kernel has aperture 0 (chain worlds are
//      chains; chains have no ordinary elements).
//   4. 9-antichain-under-a-top (the v1.0 pyramid, kept as documented
//      negative anchor): the top's kernel is dense at identity, every
//      atom's kernel is regular at identity.
// Exit code 1 on any failure.

import {
  chainUnionPoset, downsetsOf, closedForm, worldVerdict,
  apertureExhaustive,
} from "./ca-lib.mjs";

let allPass = true;
const check = (label, ok) => {
  console.log(`${ok ? "PASS" : "*** FAIL ***"}  ${label}`);
  allPass &&= ok;
};

// ---- 1 & 2: divisor-lattice anchors --------------------------------------
const anchor = (name, chains, primes, expects) => {
  const P = chainUnionPoset(chains);
  const L = downsetsOf(P);
  const chainStart = [];
  let acc = 0;
  for (const a of chains) { chainStart.push(acc); acc += a; }
  let allOK = true;
  const results = new Map();
  for (const B of L) {
    const exps = chains.map((a, c) => {
      let e = 0;
      for (let i = 0; i < a; i++) if (B & (1 << (chainStart[c] + i))) e++;
      return e;
    });
    const div = exps.reduce((m, e, c) => m * primes[c] ** e, 1);
    const st = apertureExhaustive(P, B);
    const cf = closedForm(chains, exps);
    if (st.apSize !== cf) allOK = false;
    results.set(div, st);
  }
  check(`${name}: all ${L.length} elements match the closed form`, allOK);
  for (const [div, want] of Object.entries(expects)) {
    const st = results.get(Number(div));
    const ok = st.apSize === want.ap && st.latent === want.latent;
    check(`${name}: element ${div} |Ap|=${st.apSize} (want ${want.ap}), latent=${st.latent} (want ${want.latent})`, ok);
  }
  return results;
};

const div12 = anchor("Div12 = Down(C2+C1)", [2, 1], [2, 3], {
  2: { ap: 1, latent: false },
});
// Ap(2)'s sole member must be the identity world (S = full)
{
  const P = chainUnionPoset([2, 1]);
  const full = (1 << P.n) - 1;
  const B = P.down[0]; // element 2 = down-set {p1} = principal of chain-2 bottom
  let members = [];
  for (let S = 0; S <= full; S++) if (worldVerdict(P, S, B).ordinary) members.push(S);
  check(`Div12: Ap(2) = {identity}`, members.length === 1 && members[0] === full);
}

anchor("Div36 = Down(C2+C2)", [2, 2], [2, 3], {
  6: { ap: 2, latent: true },
});

// ---- 3: 3-chain — no ordinary elements anywhere --------------------------
{
  const P = chainUnionPoset([3]);
  let anyAp = false;
  for (let x = 0; x < P.n; x++) if (apertureExhaustive(P, P.down[x]).apSize > 0) anyAp = true;
  check("3-chain: every principal kernel has aperture 0", !anyAp);
}

// ---- 4: the v1.0 pyramid (9-antichain under a top) ------------------------
{
  const n = 10;
  const down = [];
  for (let i = 0; i < 9; i++) down.push(1 << i);
  down.push((1 << 10) - 1); // top: above all nine atoms
  const P = { n, down };
  const full = (1 << n) - 1;
  const topV = worldVerdict(P, full, P.down[9]);
  check("pyramid: top kernel dense at identity", topV.dense);
  let atomsRegular = true;
  for (let i = 0; i < 9; i++) {
    const v = worldVerdict(P, full, P.down[i]);
    if (!v.regular || v.dense) atomsRegular = false;
  }
  check("pyramid: all nine atom kernels regular at identity", atomsRegular);
}

console.log(allPass ? "\nANCHORS: ALL PASS — pipeline cleared for Life cones"
                    : "\nANCHORS: FAILURES — stop; do not run 02/03/04");
process.exit(allPass ? 0 : 1);
