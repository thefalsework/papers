# Humanities Bundle — printable PDFs

Four approachable documents for a general / humanities reader, rendered as US Letter PDFs via Pandoc → Typst.

| PDF | Source |
|---|---|
| `01-start-here.pdf` | [`../../START-HERE.md`](../../START-HERE.md) |
| `02-field-guide.pdf` | [`../field-guide.md`](../field-guide.md) |
| `03-bach-at-the-kernel.pdf` | [`../bach-at-the-kernel.md`](../bach-at-the-kernel.md) |
| `04-position-taking-from-the-kernel-up.pdf` | [`../position-taking-from-the-kernel-up.md`](../position-taking-from-the-kernel-up.md) |

Rebuild (PowerShell, from repo root):

```powershell
powershell -File papers/printables/humanities-bundle/build.ps1
```

Requires: Pandoc 3.x, Typst 0.14+.
