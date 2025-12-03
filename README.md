# SysML Cloud Platform
A Model-Driven Framework for Designing and Building Cloud Solutions
---
## Overview

The SysML Cloud Platform is an open-source, model-driven engineering framework that connects SysML v2 system architecture with cloud infrastructure, technicians, and developers through a Git-native CI/CD workflow.

Its goal is to transform system models into actionable implementation artifacts, enabling organizations to design, build, and evolve their own cloud platforms directly from SysML.

This project provides:
* A structured Git repository optimized for SysML v2 projects
* Tooling and conventions for synchronizing models with code
* Automated pipelines that keep system architecture, software, and infrastructure aligned
* A modular approach adaptable to any organization designing cloud solutions

### Key Features
🔷 SysML-Driven Cloud Design
* Organize full lifecycle architecture in SysML v2
* Support for structural, behavioral, and deployment modeling
* Clear mapping from SysML elements to cloud components

🔷 Git-Native Repository Structure
* A standardized folder layout for model, code, and infrastructure alignment
* Branching and versioning strategy tailored for systems engineering workflows
* Compatible with GitHub, GitLab, Azure DevOps, and any Git provider

🔷 Model-to-Implementation Synchronization
* Automated generation of implementation stubs, documentation, or infrastructure definitions
* Optional round-trip update patterns via model annotations and metadata
* Traceability of architectural decisions and design elements

🔷 CI/CD Integration
* Pipelines for validating SysML models
* Build + deploy workflows derived from system elements
* Hooks for generating artifacts such as:
* Deployment templates (Terraform, Ansible, Helm)
* Interface definitions (OpenAPI, AsyncAPI)
* System documentation

🔷 Open-Source and Extensible
* Fully modular design
* Extensible plugin concept for new cloud providers or modeling tools
* Community-friendly contribution model

### Vision

The SysML Cloud Platform aims to close the gap between systems engineering and cloud software delivery, making SysML a central source of truth for:
* Architecture
* Operations
* Implementation
* Governance

By aligning engineers, developers, and operators through shared models and automated pipelines, the platform supports building reliable and scalable cloud systems from a rigorous architectural foundation.

---

## 📦 Requirements

### Common
- **Python 3.9+**
- **pip** (Python package manager)
- **Graphviz** (for rendering diagrams)
- **Pandoc** (for Markdown → PDF conversion)
- **LaTeX distribution** with XeLaTeX (e.g. TeX Live or MiKTeX)

### Windows
1. Install Python 3 (from python.org).
2. Install Graphviz (from graphviz.org).
3. Ensure dot.exe is on your PATH.
4. Install Pandoc (from pandoc.org).
5. Install MiKTeX (or TeX Live for Windows).
6. Ensure xelatex.exe is on your PATH.

### Linux (Debian/Ubuntu)
```bash
# System packages
sudo apt update
sudo apt install -y python3 python3-venv python3-pip \
    graphviz pandoc texlive-xetex texlive-fonts-recommended
```

## ⚙️ Workflow
### Initialize environment
```bash
make init
```
* Creates .venv
* Installs Python dependencies
### Clean old outputs
```bash
make clean
```
### Build Markdown + diagrams
```bash
make docs
```
* Parses ```.sysml``` files under ```sysml/```
* Generates diagrams (```.png```) with Graphviz
* Writes Markdown pages into ```publication/```

### Generate PDF
```bash
make pdf
```
* Runs Pandoc with XeLaTeX
* Produces publication/sysml-cloud-platform.pdf

### Publication naming & V-Model ordering

The build pipeline produces ordered PDF publications aligned to the SE V-Model with abbreviated phase prefixes. Filenames follow the pattern `<NN>_<PHASE>_<Description>.pdf` where:

- `<NN>` is the numeric V-Model ordering (01–11)
- `<PHASE>` is the abbreviated phase name (PMP, SNS, SRD, SAD, SSR, SDD, SCI, ITP, STP, SV, DPL)
- `<Description>` is a domain or document name

**Example outputs:**

- `01_PMP_SEMP.pdf` — Project Management Plan (System Engineering Management Plan)
- `03_SRD_SysMLCloudPlatform.pdf` — System Requirements Document (overall design)
- `03_SRD_Datacenter.pdf` — System Requirements Document (datacenter domain)
- `04_SAD_SysMLCloudPlatform.pdf` — System Architecture & Design (overall design)
- `04_SAD_Fabrication.pdf` — System Architecture & Design (fabrication subsystem)
- `06_SDD_FabricationDatacenterA.pdf` — Detailed Design Document (fabrication folder)

**V-Model Phase Abbreviations:**

| Order | Phase | Abbr | Example |
|-------|-------|------|---------|
| 01 | Project Management | PMP | Project Management Plan |
| 02 | Stakeholder Needs | SNS | Stakeholder Needs Statement |
| 03 | System Requirements | SRD | System Requirements Document |
| 04 | System Architecture & Design | SAD | System Architecture & Design |
| 05 | Subsystem Requirements | SSR | Subsystem Requirements |
| 06 | Subsystem Detailed Design | SDD | Detailed Design Document |
| 07 | Implementation | SCI | Software/Code Implementation |
| 08 | Integration | ITP | Integration Test Plan |
| 09 | Verification | STP | System Test Plan |
| 10 | Validation | SV | System Validation |
| 11 | Deployment & O&M | DPL | Deployment Plan |

**How to make your document appear in the correct publication:**

- Put SysML files under `sysml/<domain>/` (e.g. `sysml/datacenter/`) — `build-docs.py` converts these to markdown.
- Add standalone Markdown documents to the repo root or `publication/` and name them with meaningful terms (e.g. `PMP.md`, `ConOps.md`, `IntegrationPlan.md`). The PDF generator uses keyword matching to group documents into V-Model phases.
- Run `make docs` then `make pdf` to rebuild the publications.

The generator applies phase mapping based on keywords in document filenames and metadata (see `scripts/generate-pdfs.py` for the keyword list). For deterministic mapping, you can customize phase assignments in the script.

## 📂 Project Structure
```bash
architecture/
├── sysml/              # SysML source files
├── publication/        # Generated Markdown + diagrams + PDF
├── fabrications/       # Datacenter & rack models (can be a submodule)
├── configs/            # Infrastructure cluster specs (can be a submodule)
├── library/            # Shared roles, sysml library, terraform modules (can be a submodule)
├── scripts/
│   ├── build-docs.py   # SysML → Markdown + diagrams
│   ├── check-encoding.py
│   └── setup-submodules.py # Manage optional submodules from .submodules.config
├── templates/
│   └── titlepage.tex   # Custom LaTeX template
├── Makefile            # Build automation (includes setup-submodules-* targets)
└── py-requirements.txt # Python dependencies
```

Note: The top-level directories `fabrications/`, `configs/`, and `library/` are part of this repository and remain present during local development. Individual subfolders inside these directories (for example `fabrications/fabrication-datacenter-a`, `configs/infrastructure-cluster-a`, `library/ansible-roles`) can be either committed here or maintained as separate git repositories and linked as submodules.

Configure `.submodules.config` with the exact relative paths of the subfolders you want managed as submodules, then use the `make setup-submodules-init`, `make setup-submodules-update`, and `make setup-submodules-status` targets to manage them.

---

## Documentation

Key documents for understanding and contributing to this project:

- **[SEMP.md](SEMP.md)** — System Engineering Management Plan (INCOSE-aligned) outlining SE processes, roles, traceability, and metrics
- **[CONTRIBUTING.md](CONTRIBUTING.md)** — Development guidelines, coding conventions, and workflow instructions
- **`publication/`** — Generated architecture documentation, requirements, and design models (auto-built from SysML)

---

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to get started, coding conventions, testing, and the development workflow.

---

## Roadmap
* 🔜 SysML-to-Terraform generator
* 🔜 SysML deployment views → Helm chart generator
* 🔜 VS Code extension for model-repository integration
* 🔜 Model-based monitoring configuration (Prometheus, OpenTelemetry)
* 🔜 Cloud reference architecture templates
