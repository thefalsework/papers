# The Critical-Projects List Contains Kubernetes and Misses zlib

## Dependency concentration as a criticality signal

**This paper has moved.** The canonical copy ships with the tool it
describes:

- markdown: [thefalsework/conemass/paper/quiet-criticality.md](https://github.com/thefalsework/conemass/blob/main/paper/quiet-criticality.md)
- tool, dated rankings, and PDF: [github.com/thefalsework/conemass](https://github.com/thefalsework/conemass)

One-paragraph summary: a dependency-graph-only metric (conemass,
harmonic cone-membership mass — "concentration of reach"; derived
under the working name ORACLE, which the registered studies in this
repository retain) ranks
liblzma5 #8 of 63,436 on the last Debian release before the xz
backdoor was disclosed (against #173 by dependent count), ranks
unicode-ident #2 of 84,439 crates (against #3,582), and its head is
largely invisible to the June 2022 OpenSSF criticality-score top-1000.
Offered as a second column next to activity-based scores, not a
replacement; a registered RustSec pooled retrodiction that went
against the metric is reported in full in the paper's limitations.

The study scripts, raw outputs, and registered pre/postscripts behind
the paper remain in this repository under `oracle-scanner/`. Versions
v0.1–v0.5 of the full text are in this file's git history and in the
archival deposit (DOI
[10.5281/zenodo.22261990](https://doi.org/10.5281/zenodo.22261990)).
As of v0.7 (2026-09-05) the metric is named conemass throughout the
public artifacts; the rename changed no computation and no data row.
