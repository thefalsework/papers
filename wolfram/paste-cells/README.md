# Multi-Cell Workflow for Wolfram Cloud

Wolfram Cloud has a per-cell output-size limit that the single-file
`wolfram-bundle.wl` exceeds when section 6 (visualisations) is included.
This directory provides a cell-by-cell version that fits safely under the
limit. Each `.wl` file is the contents of one cloud notebook cell.

## Workflow

1. Open a fresh Wolfram Cloud notebook.
2. For each file `1-setup.wl` ... `5-vis-self-transfer.wl`, in order:
   - Open the `.wl` file in any editor.
   - Copy its entire contents.
   - Paste into a new cell in the cloud notebook.
   - Press `Shift+Enter` to evaluate.
   - Wait until output appears below the cell before pasting the next one.

Total: five cells, each with bounded output. Each visualisation cell is
self-contained (re-runs the query it needs), so visualisations can be
re-evaluated independently if any one fails.

## Cell layout

| Cell | File | What it does | Output size |
|------|------|--------------|------------|
| 1 | `1-setup.wl` | Loads algebra, kernels, and four cores | small |
| 2 | `2-queries.wl` | Runs Q1 through Q4 with text output | medium |
| 3 | `3-vis-transfer.wl` | Renders the Tymoczko ↔ Cutting transfer network | small + 1 graph |
| 4 | `4-vis-removal.wl` | Renders the Tymoczko removal cascade | small + 1 graph |
| 5 | `5-vis-self-transfer.wl` | Renders the methodology self-transfer graph | small + 1 graph |

## If the single-file bundle works locally

If you are running Mathematica or Wolfram Engine locally (not the cloud),
the all-in-one `wolfram-bundle.wl` runs fine in a single cell — the
output-size limit only applies to the cloud session. The multi-cell
version is for cloud reliability.
