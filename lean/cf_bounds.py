from fractions import Fraction

A,B = 5953011031984665464908921, 10176739654721465574490112
C,D = 347352544090073572470703, 593802984359051183388672

def pipeline(lo, hi, depth=7):
    data = []
    for step in range(depth):
        inv_lo, inv_hi = 1/hi, 1/lo
        a = int(inv_lo)
        f_lo, f_hi = inv_lo - a, inv_hi - a
        data.append({
            'step': step, 'floor': a,
            'x_lo': lo, 'x_hi': hi,
            'inv_lo': inv_lo, 'inv_hi': inv_hi,
            'f_lo': f_lo, 'f_hi': f_hi,
        })
        lo, hi = f_lo, f_hi
    return data

data = pipeline(Fraction(A,B), Fraction(C,D))
for d in data:
    s = d['step']
    print(f"-- step {s} floor {d['floor']}")
    print(f"-- x in ({d['x_lo'].numerator} / {d['x_lo'].denominator}, {d['x_hi'].numerator} / {d['x_hi'].denominator})")
    print(f"-- inv in ({d['inv_lo'].numerator} / {d['inv_lo'].denominator}, {d['inv_hi'].numerator} / {d['inv_hi'].denominator})")
    print(f"-- next fract ({d['f_lo'].numerator} / {d['f_lo'].denominator}, {d['f_hi'].numerator} / {d['f_hi'].denominator})")
    print()
