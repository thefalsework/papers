# -*- coding: utf-8 -*-
import io, subprocess, os
base = r'c:\dev\falsework-papers\papers\paper2-epistemic-dependency'
md = base + r'\paper2.md'
fresh_path = base + r'\paper2.fresh.tex'
out_path = base + r'\paper2.tex'
subprocess.run(['pandoc', md, '--standalone', '--from', 'markdown', '--to', 'latex',
    '-V', 'documentclass=article', '-V', 'geometry:margin=1in', '-V', 'fontsize=11pt',
    '-o', fresh_path], check=True)
with io.open(fresh_path, 'r', encoding='utf-8', newline='') as f:
    s = f.read()
nl = "\r\n" if "\r\n" in s else "\n"
s = s.replace("\r\n", "\n")
preamble = (
    "% Map Unicode glyphs that the text fonts lack to math symbols (XeLaTeX/LuaLaTeX).\n"
    "% If this file is regenerated from paper2.md via pandoc, re-add this block.\n"
    "\\usepackage{newunicodechar}\n"
    "\\newunicodechar{\u266d}{\\ensuremath{\\flat}}\n"
    "\\newunicodechar{\u21d2}{\\ensuremath{\\Rightarrow}}\n"
    "\\newunicodechar{\u2293}{\\ensuremath{\\sqcap}}\n"
    "\\newunicodechar{\u2294}{\\ensuremath{\\sqcup}}\n"
    "\\newunicodechar{\u2264}{\\ensuremath{\\leq}}\n"
    "\\newunicodechar{\u2265}{\\ensuremath{\\geq}}\n"
    "\\newunicodechar{\u2194}{\\ensuremath{\\leftrightarrow}}\n"
    "\\newunicodechar{\u03b4}{\\ensuremath{\\delta}}\n"
    "\\newunicodechar{\u03b9}{\\ensuremath{\\iota}}\n"
    "\\newunicodechar{\u03c7}{\\ensuremath{\\chi}}\n"
    "\\newunicodechar{\u03a3}{\\ensuremath{\\Sigma}}\n"
    "\\newunicodechar{\u0394}{\\ensuremath{\\Delta}}\n"
)
title = ("\\title{Epistemic Dependency as Structural Condition: A Documented Case "
         "Study of AI-Assisted Scholarship and the Maturity of Correction Mechanisms}")
anchor = "  pdfcreator={LaTeX via pandoc}}\n"
assert s.count(anchor) == 1
s = s.replace(anchor, anchor + "\n" + preamble, 1)
ta_old = "\\author{}\n\\date{}\n"
assert s.count(ta_old) == 1
s = s.replace(ta_old, title + "\n\\author{Chris Brink\\\\FalseWork (falsework.dev)}\n\\date{}\n", 1)
bd_old = "\\begin{document}\n"
assert s.count(bd_old) == 1
s = s.replace(bd_old, bd_old + "\\maketitle\n", 1)
sec_old = (
    "\n\\section{Epistemic Dependency as Structural Condition: A Documented Case\n"
    "Study of AI-Assisted Scholarship and the Maturity of Correction\n"
    "Mechanisms}\\label{epistemic-dependency-as-structural-condition-a-documented-case-study-of-ai-assisted-scholarship-and-the-maturity-of-correction-mechanisms}\n"
    "\n\\textbf{Chris Brink}\n\nFalseWork (falsework.dev)\n"
)
assert s.count(sec_old) == 1
s = s.replace(sec_old, "", 1)
if nl == "\r\n":
    s = s.replace("\n", "\r\n")
with io.open(out_path, 'w', encoding='utf-8', newline='') as f:
    f.write(s)
os.remove(fresh_path)
print("graft OK; inchoate-count removed:", "second time Cutting had used" not in s)
