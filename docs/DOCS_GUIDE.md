# Docs Guide — Portal & Navigation

> **Purpose**: This guide is your entry point into the documentation. Based on your role or goal, pick a path below. Each document will guide you to the next one.
>
> **📝 Important**: Documentation in the `docs/` folder is **editable and version-controlled**. Generated publications in `publication/` are **auto-generated** (do not edit directly; regenerate with `make docs` and `make pdf`).

---

## Pick Your Path

### 👤 I'm New — Where Do I Start?

1. **[README.md](../README.md)** — 2-minute overview (what this project is)
2. **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** — 5-minute quick start (install & build commands)
3. **[SYSML_ARCHITECTURE_GUIDE.md](SYSML_ARCHITECTURE_GUIDE.md)** — 30-minute deep dive (how the system works)

Then, based on your next goal:
- **Want to build/deploy?** → Jump to [TESTING_AND_DEPLOYMENT_STRATEGY.md](TESTING_AND_DEPLOYMENT_STRATEGY.md)
- **Want to understand the plan?** → Go to [SEMP.md](SEMP.md) (Project Management)
- **Want to extend the models?** → See [SYSML_ARCHITECTURE_GUIDE.md](SYSML_ARCHITECTURE_GUIDE.md) → [CONTRIBUTING.md](CONTRIBUTING.md)

---

### 🏗️ I'm an Architect — How Is This Designed?

1. **[README.md](../README.md)** — Project overview
2. **[SYSML_ARCHITECTURE_GUIDE.md](SYSML_ARCHITECTURE_GUIDE.md)** — Full technical architecture
3. **[V-MODEL_GUIDE.md](V-MODEL_GUIDE.md)** — Publication structure and V-Model phases
4. **Then**, follow the V-Model phases in order from `publication/`:
   - Phase 03 (SRD) — System Requirements
   - Phase 04 (SAD) — System Architecture & Design
   - Phase 06 (SDD) — Subsystem Detailed Design

---

### 🔧 I Want to Deploy This

1. **[README.md](../README.md)** — Project overview
2. **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** — Install & build
3. **[TESTING_AND_DEPLOYMENT_STRATEGY.md](TESTING_AND_DEPLOYMENT_STRATEGY.md)** — Deployment steps & verification
4. **Then**, reference the implementation in `configs/`, `library/`, and per-instance `fabrications/`

---

### 📖 I Want to Read Everything in Order (V-Model Path)

Follow this reading thread from project initiation through deployment:

1. **[README.md](../README.md)** — Overview
2. **[DOCS_GUIDE.md](DOCS_GUIDE.md)** (this file) — You are here
3. **[SEMP.md](SEMP.md)** — Phase 01 (PMP): Project Management Plan
4. **[SYSML_ARCHITECTURE_GUIDE.md](SYSML_ARCHITECTURE_GUIDE.md)** — Architecture context (spans SRD → SAD)
5. **`publication/03_SRD_*.pdf`** — Phase 03 (SRD): System Requirements Definition
6. **`publication/04_SAD_*.pdf`** — Phase 04 (SAD): System Architecture & Design
7. **`publication/06_SDD_*.pdf`** — Phase 06 (SDD): Subsystem Detailed Design
8. **[TESTING_AND_DEPLOYMENT_STRATEGY.md](TESTING_AND_DEPLOYMENT_STRATEGY.md)** — Phases 08–11 (ITP, STP, SV, DPL): Testing & Deployment

---

## 📂 Folder Map

**Editable Documentation:**
- **`docs/`** — Authoritative, version-controlled user-facing documentation. Edit these files directly. Includes architecture guides, contributing guidelines, project management plans, and deployment strategies.

**Source Models & Implementation:**
- **`sysml/`** — SysML v2 source models. Changes here trigger `publication/` regeneration via `make docs` and `make pdf`.
- **`configs/`** — Per-instance infrastructure-as-code (Terraform, Ansible). Your actual deployments.
- **`fabrications/`** — Per-instance datacenter & rack specifications.
- **`library/`** — Shared SysML, Terraform, and Ansible components.
- **`scripts/`** — Build and automation (do not edit generated scripts).

**Generated Publications (Read-Only):**
- **`publication/`** — Auto-generated artifacts from `sysml/` models and scripts. Includes:
  - PDFs organized by V-Model phases (01_PMP, 03_SRD, 04_SAD, 06_SDD, 11_DPL, etc.)
  - Grouped markdown files matching PDF structure
  - Diagrams (PNG, SVG) rendered from SysML and Graphviz
  - JSON manifests mapping markdown to publications
  - **⚠️ Do not edit files in `publication/` — regenerate with `make docs && make pdf`**

---

## 🎯 Document Authoring Template

Every document should follow this structure:

1. **Header** — Title, Version, V-Model Phase, Author, Last Updated
2. **Summary** — 1–3 paragraphs: what this is and why it matters
3. **Audience & Prerequisites** — Who should read this and what background is needed
4. **Main Content** — The detailed material (broken into logical sections)
5. **Verification & Tests** — How to validate the content
6. **Next Steps** — Where to read next, based on reader role/goal

See **[DOC_TEMPLATE.md](DOC_TEMPLATE.md)** for a full markdown example.

---

---

## Overview & Quick Start

This repository demonstrates a production-ready architecture for cloud infrastructure using OMG SysML v2. Start with the quick reference, then dive into the architecture guide.

Quick commands:

```bash
make init
make docs
make pdf
```

---

## Documentation Reading Order

1. `QUICK_REFERENCE.md` — start here (5 min)
2. `SYSML_ARCHITECTURE_GUIDE.md` — full architecture (30 min)
3. `IMPLEMENTATION_SUMMARY.md` — what was built (15 min)
4. `DOCS_GUIDE.md` — this overview and folder map

---

## Folder Map

- `sysml/` — SysML v2 source models
- `publication/` — Generated documentation and PDFs
- `configs/{instance-id}/` — Per-instance IaC
- `fabrications/{instance-id}/` — Per-instance datacenter specs
- `library/` — Shared components
- `docs/` — User documentation (this folder)
- `scripts/` — Build & tooling

---

## Publication & V-Model Guide

See the detailed publication naming and V-Model mapping in `docs/V-MODEL_GUIDE.md`.

---

## Key Links

- [Quick Reference](QUICK_REFERENCE.md)
- [Full Architecture Guide](SYSML_ARCHITECTURE_GUIDE.md)
- [V-Model Publication Guide](V-MODEL_GUIDE.md)
- [SEMP (management plan)](SEMP.md)

---

If you want the original `INDEX.md` content moved or adjusted, tell me where to place it or what to trim.