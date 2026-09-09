# Build deposit PDFs for the preprints from their authoritative markdown.
# Requires: pandoc (any 3.x) and typst on PATH.
# Usage: powershell -File preprints/build-pdfs.ps1   (from the repo root)
#
# Pipeline: pandoc converts paper.md to a typst body fragment; the shared
# preamble (_typst-wrapper/wrapper.typ) is prepended (UTF-8, no BOM — the
# default Get-Content/Set-Content encodings mangle the math symbols); typst
# compiles the result. Intermediates are removed afterward.

$ErrorActionPreference = "Stop"
$papers = @("perceptron-bridge", "aperture", "four-position-partition")
$utf8 = New-Object System.Text.UTF8Encoding $false

foreach ($p in $papers) {
    $dir = "preprints/$p"
    pandoc "$dir/paper.md" -t typst -o "$dir/_body.typ"
    $txt = [System.IO.File]::ReadAllText("$PWD/preprints/_typst-wrapper/wrapper.typ", $utf8) + "`n" +
           [System.IO.File]::ReadAllText("$PWD/$dir/_body.typ", $utf8)
    [System.IO.File]::WriteAllText("$PWD/$dir/_main.typ", $txt, $utf8)
    typst compile --root . "$dir/_main.typ" "$dir/paper.pdf"
    if ($LASTEXITCODE -ne 0) { throw "typst failed on $p" }
    Remove-Item "$dir/_body.typ", "$dir/_main.typ"
    Write-Output "built $dir/paper.pdf"
}
