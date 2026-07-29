# Rebuild the four humanities-bundle PDFs (Pandoc → Typst).
$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$repo = Resolve-Path (Join-Path $here "..\..\..")
$typst = (Get-Command typst).Source
$preamble = Join-Path $here "_preamble.typ"

$jobs = @(
  @{ Out = "01-start-here.pdf";            Src = "START-HERE.md" },
  @{ Out = "02-field-guide.pdf";           Src = "papers\field-guide.md" },
  @{ Out = "03-bach-at-the-kernel.pdf";    Src = "papers\bach-at-the-kernel.md" },
  @{ Out = "04-position-taking-from-the-kernel-up.pdf"; Src = "papers\position-taking-from-the-kernel-up.md" }
)

foreach ($j in $jobs) {
  $src = Join-Path $repo $j.Src
  $body = Join-Path $here ("_" + [IO.Path]::GetFileNameWithoutExtension($j.Out) + ".body.typ")
  $merged = Join-Path $here ("_" + [IO.Path]::GetFileNameWithoutExtension($j.Out) + ".typ")
  $pdf = Join-Path $here $j.Out

  Write-Host "Converting $($j.Src) ..."
  & pandoc -t typst -f markdown -o $body $src
  if ($LASTEXITCODE -ne 0) { throw "pandoc failed for $($j.Src)" }

  # Pandoc emits a level-1 title as `= Title` (Typst markup heading).
  # Keep as-is; preamble sets heading styles.
  $bodyText = Get-Content -Raw -Path $body
  $combined = (Get-Content -Raw -Path $preamble) + "`n" + $bodyText
  [System.IO.File]::WriteAllText($merged, $combined)

  & $typst compile $merged $pdf
  if ($LASTEXITCODE -ne 0) { throw "typst failed for $($j.Out)" }

  Remove-Item $body -ErrorAction SilentlyContinue
  # Keep merged .typ only on failure; delete on success
  Remove-Item $merged -ErrorAction SilentlyContinue
  $len = (Get-Item $pdf).Length
  Write-Host "  -> $($j.Out) ($([math]::Round($len/1KB,1)) KB)"
}

Get-ChildItem $here -Filter "_*.typ" | Where-Object { $_.Name -ne "_preamble.typ" } | Remove-Item -Force -ErrorAction SilentlyContinue
Get-ChildItem $here -Filter "_test*" | Remove-Item -Force -ErrorAction SilentlyContinue
Write-Host "Done."
