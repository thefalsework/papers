# Regenerate paper2.tex for arXiv from paper2.md.
# Requires: pandoc 3.x, XeLaTeX or LuaLaTeX (arXiv: select XeLaTeX).
# Usage: .\build-paper2-arxiv.ps1
# Optional compile: .\build-paper2-arxiv.ps1 -Compile

param(
    [switch]$Compile
)

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Content, $utf8)
}

$ErrorActionPreference = "Stop"
$Dir = $PSScriptRoot
$Md = Join-Path $Dir "paper2.md"
$Body = Join-Path $Dir "paper2-body.tmp.md"
$Raw = Join-Path $Dir "paper2.raw.tex"
$Out = Join-Path $Dir "paper2.tex"
$Preamble = Join-Path $Dir "arxiv-preamble.tex"
$Meta = Join-Path $Dir "arxiv-metadata.yaml"

# Skip markdown title block (lines 1-7); version note re-injected after \maketitle.
$lines = Get-Content $Md -Encoding UTF8
$versionLine = $lines[6]
$bodyLines = $lines[7..($lines.Length - 1)]
Set-Content -Path $Body -Value $bodyLines -Encoding UTF8

# Version note: markdown italics -> LaTeX emph; escape # for TeX
$versionTex = $versionLine -replace '^\*', '\emph{' -replace '\*$', '}' `
    -replace '---', '---' `
    -replace '#', '\#'
# Status tags in version note
$versionTex = $versionTex -replace '\[K\]/\[C\]/\[A\]/\[O\]', '\statustag{K}/\statustag{C}/\statustag{A}/\statustag{O}'

Write-Host "pandoc -> paper2.raw.tex"
& pandoc $Body `
    -o $Raw `
    --standalone `
    --from markdown `
    --to latex `
    --metadata-file $Meta `
    --include-in-header $Preamble `
    --shift-heading-level-by=-1

Remove-Item $Body -Force

$tex = Get-Content $Raw -Raw -Encoding UTF8

# --- Status tags: pandoc escapes brackets as {[}K{]} ---
$tex = $tex -replace '\\textbf\{\{[\[]\}K\{[\]]\}\}', '\textbf{\statustag{K}}'
$tex = $tex -replace '\\textbf\{\{[\[]\}C\{[\]]\}\}', '\textbf{\statustag{C}}'
$tex = $tex -replace '\\textbf\{\{[\[]\}A\{[\]]\}\}', '\textbf{\statustag{A}}'
$tex = $tex -replace '\\textbf\{\{[\[]\}O\{[\]]\}\}', '\textbf{\statustag{O}}'
$tex = $tex -replace '\{[\[]\}K\{[\]]\}\+\{[\[]\}C\{[\]]\}', '\statustagpair{K}{C}'
$tex = $tex -replace '\{[\[]\}K\{[\]]\}/\{[\[]\}C\{[\]]\}/\{[\[]\}A\{[\]]\}/\{[\[]\}O\{[\]]\}', '\statustag{K}/\statustag{C}/\statustag{A}/\statustag{O}'
$tex = $tex -replace '\{[\[]\}K\{[\]]\}', '\statustag{K}'
$tex = $tex -replace '\{[\[]\}C\{[\]]\}', '\statustag{C}'
$tex = $tex -replace '\{[\[]\}A\{[\]]\}', '\statustag{A}'
$tex = $tex -replace '\{[\[]\}O\{[\]]\}', '\statustag{O}'

# Abstract environment (arXiv convention)
$tex = $tex -replace '\\section\{Abstract\}\\label\{abstract\}', '\begin{abstract}'
$tex = $tex -replace '(\\begin\{abstract\}[\s\S]*?)(\r?\n\\section\{1\.)', "`$1`n\end{abstract}`$2"

# Inject version note after \maketitle
$tex = $tex -replace '(\\maketitle\s*)', "`$1`n$versionTex`n`n"

# Enable section numbering (pandoc disables by default)
$tex = $tex -replace [regex]::Escape('\setcounter{secnumdepth}{-\maxdimen} % remove section numbering') + '\s*\r?\n', ''

# Remove duplicate pandoc hypersetup (options merged in arxiv-preamble.tex)
$tex = $tex -replace '(?ms)\\hypersetup\{\s*pdftitle=\{[^}]+\},\s*pdfauthor=\{[^}]+\},\s*hidelinks,\s*pdfcreator=\{LaTeX via pandoc\}\}\s*', ''

# Appendix heading (pandoc may line-break long titles)
$tex = $tex -replace '\\section\{Appendix: Pre-submission revision\r?\nrecord\}', '\appendix\section{Pre-submission revision record}'

Write-Utf8NoBom -Path $Out -Content $tex
Remove-Item $Raw -Force

Write-Host "Wrote $Out"

if ($Compile) {
    $tectonic = Join-Path (Split-Path (Split-Path $Dir)) ".tools\tectonic.exe"
    if (-not (Test-Path $tectonic)) {
        Write-Error "tectonic not found at $tectonic"
    }
    Write-Host "tectonic compile..."
    & $tectonic --outdir $Dir $Out
    Write-Host "PDF: $(Join-Path $Dir 'paper2.pdf')"
}
