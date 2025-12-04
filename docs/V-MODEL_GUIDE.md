# Publication Naming & V-Model Guide

> **Previous**: [README.md](../README.md) → [DOCS_GUIDE.md](DOCS_GUIDE.md) → [SYSML_ARCHITECTURE_GUIDE.md](SYSML_ARCHITECTURE_GUIDE.md)  
> **V-Model Phase**: Reference (governance & standards)  
> **Time to read**: 10–15 minutes

This document describes the repository's publication naming convention and how documents are grouped into V-Model phases for PDF publication.

## Filenames and pattern

Publications are exported as ordered PDFs aligned with the Systems Engineering V-Model lifecycle. Filenames follow this pattern:

```
<NN>_<ABBR>_<Description>.pdf
```

- `<NN>` = numeric V-Model phase ordering (01–11)
- `<ABBR>` = abbreviated phase name (PMP, SNS, SRD, SAD, SSR, SDD, SCI, ITP, STP, SV, DPL)
- `<Description>` = domain or document title

## Full V-Model Phase Table

| Order | Phase | Abbr | Typical Document / PDF example |
|-------|-------|------|---------------------------------|
| 01 | Project Management | PMP | `01_PMP_SEMP.pdf` (System Engineering Management Plan)
| 02 | Stakeholder Needs | SNS | Stakeholder Needs Statement
| 03 | System Requirements | SRD | `03_SRD_SysMLCloudPlatform.pdf` (System Requirements Document)
| 04 | System Architecture & Design | SAD | `04_SAD_SysMLCloudPlatform.pdf` (System Architecture & Design)
| 05 | Subsystem Requirements | SSR | Subsystem Requirements documents
| 06 | Subsystem Detailed Design | SDD | `06_SDD_FabricationDatacenterA.pdf` (Detailed Design Document)
| 07 | Implementation | SCI | Implementation / Code artifacts
| 08 | Integration | ITP | Integration Test Plan
| 09 | Verification | STP | System Test Plan
| 10 | Validation | SV | System Validation documents
| 11 | Deployment & O&M | DPL | `11_DPL_DeploymentAndOM.pdf` (Deployment & O&M)

## How documents are grouped

- SysML models under `sysml/<domain>/` are converted to Markdown by `scripts/build-docs.py` and then mapped to V-Model phases by `scripts/generate-pdfs.py`.
- Standalone Markdown documents (PMP, ConOps, Integration Plan, etc.) should be placed at the repository root or in `publication/` and named descriptively. The PDF generator uses filename keywords and optional manifest metadata to map files to phases.

## Example outputs

```
01_PMP_SEMP.pdf                     # Project Management Plan
03_SRD_SysMLCloudPlatform.pdf       # System Requirements Document
04_SAD_SysMLCloudPlatform.pdf       # System Architecture & Design
06_SDD_FabricationDatacenterA.pdf   # Detailed Design Document
```

## Regenerating publications locally

```bash
make docs
make pdf
```

Generated PDFs will be placed in the `publication/` folder with the V-Model numeric and abbreviation prefixes.

## Guidelines & Best Practices

- Use descriptive filenames for standalone Markdown documents; include keywords that map to V-Model phases (e.g., "SEMP", "SRD", "SAD", "SDD", "Deployment").
- Prefer adding large, long-form documents to `docs/` or `publication/` and reference them from `README.md` or `docs/DOCS_GUIDE.md`.
- If you need deterministic phase assignment, add mapping metadata to the `publication/manifest.json` or update the keyword list in `scripts/generate-pdfs.py`.

---

See also: `docs/SEMP.md` (SEMP) and `scripts/generate-pdfs.py` (keyword mapping implementation).

## Next Steps

### To follow the full V-Model phases in order...
→ Start with **[SEMP.md](SEMP.md)** (Phase 01: Project Management)  
→ Then read each phase's PDF in order: 03_SRD → 04_SAD → 06_SDD → 11_DPL

### To understand the system requirements...
→ Open **`publication/03_SRD_*.pdf`** (Phase 03: System Requirements)

### To understand the system architecture...
→ Open **`publication/04_SAD_*.pdf`** (Phase 04: System Architecture & Design)

### To see deployment and operations documents...
→ Open **`publication/11_DPL_DeploymentAndOM.pdf`** (Phase 11: Deployment & O&M)

### Return to the main thread:
→ Back to **[DOCS_GUIDE.md](DOCS_GUIDE.md)**
