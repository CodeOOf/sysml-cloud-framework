# Publication Naming & V-Model Guide

> **Previous**: [README.md](../README.md) → [DOCS_GUIDE.md](DOCS_GUIDE.md) → [SYSML_ARCHITECTURE_GUIDE.md](SYSML_ARCHITECTURE_GUIDE.md)  
> **V-Model Phase**: Reference (governance & standards)  
> **Time to read**: 10–15 minutes  
> **Published as**: N/A (Governance reference — describes how ALL publications are organized)

This document describes the repository's publication naming convention and how documents are grouped into V-Model phases for PDF publication.

## V-Model Documentation Structure

![Documentation Structure by V-Model Phase](../publication/images/documentation-structure-model_phases.png)

The diagram above shows the complete documentation lifecycle organized by V-Model phases:
- **Navigation Docs** (top) — Entry points: README, DOCS_GUIDE, QUICK_REFERENCE, V-MODEL_GUIDE, CONTRIBUTING
- **Phase 01 (PMP)** — SEMP.md → 01_PMP_SEMP.pdf
- **Phase 02 (SNS)** — Stakeholder needs analysis → business-concerns.md, product-strategy.md → 02_SNS_StakeholderNeeds.pdf
- **Phase 03 (SRD)** — SYSML_ARCHITECTURE_GUIDE (context) → system-requirements-definition.md → 03_SRD_*.pdf
- **Phase 04 (SAD)** — SYSML_ARCHITECTURE_GUIDE (context) → platform-model.md, platform-interfaces.md → 04_SAD_*.pdf
- **Phase 06 (SDD)** — rack-model.md, network-model.md, virtualization-model.md → 06_SDD_*.pdf
- **Phase 11 (DPL)** — TESTING_AND_DEPLOYMENT_STRATEGY (context) → testing-and-deployment-planning.md → 11_DPL_*.pdf
- **Build Process** — BuildDocs action generates markdown from SysML models and groups them into PDFs

Each editable doc (docs/) provides context, while generated markdown (publication/) contains formal requirements/design from SysML models.

---

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
| 02 | Stakeholder Needs | SNS | `02_SNS_StakeholderNeeds.pdf` (Stakeholder Needs Analysis)
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
02_SNS_StakeholderNeeds.pdf         # Stakeholder Needs Analysis
03_SRD_SysMLCloudPlatform.pdf       # System Requirements Document
04_SAD_SysMLCloudPlatform.pdf       # System Architecture & Design
06_SDD_FabricationDatacenterA.pdf   # Detailed Design Document
11_DPL_DeploymentAndOM.pdf          # Deployment & Operations
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
→ Continue with **`publication/02_SNS_StakeholderNeeds.pdf`** (Phase 02: Stakeholder Needs)  
→ Then read each phase's PDF in order: 03_SRD → 04_SAD → 06_SDD → 11_DPL

### To understand stakeholder concerns and product strategy...
→ Open **`publication/02_SNS_StakeholderNeeds.pdf`** (Phase 02: Stakeholder Needs)  
→ Or read markdown: [stakeholder-needs-analysis.md](../publication/stakeholder-needs-analysis.md), [business-concerns.md](../publication/business-concerns.md), [product-strategy.md](../publication/product-strategy.md)

### To understand the system requirements...
→ Open **`publication/03_SRD_*.pdf`** (Phase 03: System Requirements)

### To understand the system architecture...
→ Open **`publication/04_SAD_*.pdf`** (Phase 04: System Architecture & Design)

### To see deployment and operations documents...
→ Open **`publication/11_DPL_DeploymentAndOM.pdf`** (Phase 11: Deployment & O&M)

### Return to the main thread:
→ Back to **[DOCS_GUIDE.md](DOCS_GUIDE.md)**
