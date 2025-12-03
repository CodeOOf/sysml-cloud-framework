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

The build pipeline now produces ordered PDF publications aligned to the V-Model. Filenames are prefixed with a numeric ordering to make the lifecycle ordering explicit. Example outputs:

- `01_SEMP.pdf` (Project Management)
- `02_StakeholderNeeds.pdf` (Stakeholder needs and Scenarios)
- `03_Requirements_SysMLCloudPlatform.pdf` (System requirements)
- `04_SystemDesign_SysMLCloudPlatform.pdf` (System architecture & design)
- `04_SubSystemDesign_Fabrication.pdf` (Subsystem architecture — Fabrication)
- `06_DetailedDesign_FabricationDatacenterA.pdf` (Detailed designs)
- `03_Requirements_Datacenter.pdf` (Domain requirements)

How to make your document appear in the correct publication:
- Put SysML files under `sysml/<domain>/` (e.g. `sysml/datacenter/`) — `build-docs.py` converts these to markdown.
- Add standalone Markdown documents to the repo root or `publication/` and name them with meaningful terms (e.g. `PMP.md`, `ConOps.md`, `IntegrationPlan.md`). The PDF generator uses simple keyword matching to group documents into V-Model phases (you can customize keywords in `scripts/generate-pdfs.py`).
- Run `make docs` then `make pdf` to rebuild the publications.

If you want different behavior (for example, stricter grouping rules or custom prefixes), I can add a small configuration file to control phase mappings.

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
