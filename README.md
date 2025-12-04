# SysML Cloud Platform
A Model-Driven Framework for Designing and Building Cloud Solutions

**Source of Truth**: [OMG SysML v2 Specification](https://www.omg.org/sysml/sysmlv2/) and [SysML v2 Release Repository](https://github.com/Systems-Modeling/SysML-v2-Release)

---
## Overview

The SysML Cloud Platform is an open-source, model-driven engineering framework that connects OMG SysML v2 system architecture with cloud infrastructure, technicians, and developers through a Git-native CI/CD workflow.

Its goal is to transform system models into actionable implementation artifacts, enabling organizations to design, build, and evolve their own cloud platforms directly from SysML v2 (formally adopted by OMG on June 30, 2025).

-### Key Deployment Architecture

This project demonstrates the complete system using examples. Example names `Cluster A` and `Cluster B` are illustrative — real instance folders use dynamic instance IDs under `configs/{instance-id}` and `fabrications/{instance-id}`.

- **Cluster A** (example): Lab-scale development cluster (1 master, 2-3 workers). Replace `A` with your instance id.
- **Cluster B** (example): Production EKS-like cluster (3 HA masters, 5-100+ workers). Replace `B` with your instance id.
- **Shared Library**: Reusable SysML models, Terraform modules, and Ansible roles
- **Template Structure**: Required folder and configuration patterns for all deployments

For detailed architecture documentation, see:
- **[SYSML_ARCHITECTURE_GUIDE.md](SYSML_ARCHITECTURE_GUIDE.md)** — Complete architecture reference
- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** — Quick lookup card for common tasks
- **[INDEX.md](publication/index.md)** — Entry point to all generated documentation
- **[NAVIGATION_GUIDE.md](publication/NAVIGATION_GUIDE.md)** — Guide to publication structure and PDF organization

This project provides:
* A structured Git repository optimized for OMG SysML v2 projects
* Textual SysML models (OMG-compliant syntax) defining infrastructure architecture
* Tooling and conventions for synchronizing models with infrastructure code
* Automated pipelines that keep system architecture, software, and infrastructure aligned
* A modular approach adaptable to any organization designing cloud solutions

### Key Features
🔷 SysML v2-Driven Cloud Design (OMG-Compliant)
* Organize full lifecycle architecture using OMG SysML v2 textual syntax
* Package-based organization: `sysml/overall-design/`, `sysml/infrastructure/`, `sysml/datacenter/`
* Support for structural modeling (classes, attributes, composition)
* Clear mapping from SysML elements to cloud components (Cluster A, Cluster B, datacenters)

🔷 Git-Native Repository Structure
* A standardized folder layout for model, code, and infrastructure alignment
* Branching and versioning strategy tailored for systems engineering workflows
* Compatible with GitHub, GitLab, Azure DevOps, and any Git provider

🔷 Model-to-Implementation Synchronization
* Automated generation of documentation from SysML models
* Terraform modules and Ansible roles derived from and traceable to SysML definitions
* Template-based consistency across clusters and datacenters
* Traceability of architectural decisions and design elements

🔷 CI/CD Integration
* Pipelines for validating SysML models
* Build + deploy workflows derived from system elements
* Hooks for generating artifacts such as:
  - Deployment templates (Terraform, Ansible, Helm)
  - Infrastructure as Code (IaC) configurations
  - System documentation (PDFs with V-Model phases)

🔷 Open-Source and Extensible
* Fully modular design
* Shared library for reusable SysML, Terraform, and Ansible components
* Community-friendly contribution model

### Vision

The SysML Cloud Platform aims to close the gap between systems engineering and cloud software delivery, making OMG SysML v2 a central source of truth for:
* Architecture (Kubernetes clusters, datacenters, networks)
* Operations (monitoring, logging, security policies)
* Implementation (Terraform, Ansible automation)
* Governance (requirements traceability, V-Model alignment)

By aligning engineers, developers, and operators through shared SysML models and automated pipelines, the platform supports building reliable and scalable cloud systems from a rigorous, formal architectural foundation.

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

---

## 📚 Documentation Navigation

### Where to Start

**First Time?** → Start here: [INDEX.md](publication/index.md)

**Need Quick Answers?** → [QUICK_REFERENCE.md](QUICK_REFERENCE.md)

**Want Full Details?** → [SYSML_ARCHITECTURE_GUIDE.md](SYSML_ARCHITECTURE_GUIDE.md)

### Documentation by Purpose

#### For Understanding Requirements
- **[publication/NAVIGATION_GUIDE.md](publication/NAVIGATION_GUIDE.md)** — How requirements are organized and traced through the system
- **[sysml/overall-design/SystemRequirementsDefinition.sysml](sysml/overall-design/SystemRequirementsDefinition.sysml)** — System-level requirements (SYSTEM_REQ_001-010)
- **[sysml/infrastructure/InfrastructureSubSystemRequirements.sysml](sysml/infrastructure/InfrastructureSubSystemRequirements.sysml)** — Infrastructure requirements (INFRA_REQ_001-010)
- **[sysml/datacenter/FabricationSubSystemRequirements.sysml](sysml/datacenter/FabricationSubSystemRequirements.sysml)** — Fabrication/datacenter requirements (FAB_REQ_001-010)
- **[input/README.md](input/README.md)** — External requirement documents structure
- **PDFs**: `03_SRD_*.pdf` — System requirements documents (organized by domain)

#### For Understanding Architecture
- **[sysml/infrastructure/KubernetesClusterArchitecture.sysml](sysml/infrastructure/KubernetesClusterArchitecture.sysml)** — Cluster A and B architecture
- **[sysml/datacenter/DeploymentArchitecture.sysml](sysml/datacenter/DeploymentArchitecture.sysml)** — Multi-datacenter deployment
- **[sysml/library/SharedInfrastructureLibrary.sysml](sysml/library/SharedInfrastructureLibrary.sysml)** — Reusable components
- **[publication/cluster-architecture-model.md](publication/cluster-architecture-model.md)** — Kubernetes cluster design
- **[publication/datacenter-architecture-model.md](publication/datacenter-architecture-model.md)** — Datacenter topology
- **PDFs**: `04_SAD_*.pdf` — System architecture & design documents

#### For Understanding Testing & Deployment
- **[TESTING_AND_DEPLOYMENT_STRATEGY.md](TESTING_AND_DEPLOYMENT_STRATEGY.md)** — Complete testing and deployment procedures
- **[sysml/overall-design/TestingAndDeploymentPlanning.sysml](sysml/overall-design/TestingAndDeploymentPlanning.sysml)** — Test plans and deployment definitions
- **[PROJECT_INTEGRATION_GUIDE.md](PROJECT_INTEGRATION_GUIDE.md)** — Jira/GitLab integration and workflow
- **PDFs**: `08_ITP_*.pdf`, `09_STP_*.pdf`, `11_DPL_*.pdf` — Testing and deployment documents

#### For Project Managers & Stakeholders
- **[publication/index.md](publication/index.md)** — Entry point with overview
- **[01_PMP_SEMP.pdf](publication/01_PMP_SEMP.pdf)** — System Engineering Management Plan
- **[PROJECT_INTEGRATION_GUIDE.md](PROJECT_INTEGRATION_GUIDE.md)** — Jira/issue tracking setup

#### For Infrastructure/DevOps Teams
- **[templates/TERRAFORM_STRUCTURE.md](templates/TERRAFORM_STRUCTURE.md)** — Terraform module organization
- **[templates/ANSIBLE_STRUCTURE.md](templates/ANSIBLE_STRUCTURE.md)** — Ansible playbook organization
- **Per-instance configs**: Use `configs/{instance-id}/` for each infrastructure instance (example: `configs/cluster-a/` or `configs/prod-west/`).
  - Each instance folder SHOULD include a `manifest.json` conforming to `configs/manifest.schema.json`.
  - SysML models and docs reference requirement IDs — tooling resolves instance folders by reading each instance's `manifest.json`.
- **[library/terraform-modules/](library/terraform-modules/)** — Shared Terraform modules
- **[library/ansible-roles/](library/ansible-roles/)** — Shared Ansible roles

-#### For Facilities/Operations Teams
- **Per-instance fabrications**: Use `fabrications/{instance-id}/` for each physical site (example: `fabrications/datacenter-east-1/`).
  - Each instance folder SHOULD include a `manifest.json` conforming to `fabrications/manifest.schema.json`.
  - SysML and documentation reference the manifest `id` and requirement IDs rather than prescriptive example folder names.
- **[publication/floorplan.md](publication/floorplan.md)** — Physical layout
- **[publication/rack-model.md](publication/rack-model.md)** — Rack specifications
- **PDFs**: `06_SDD_FabricationDatacenter*.pdf` — Detailed datacenter design

#### For Vendor Information
- **[vendor-docs/README.md](vendor-docs/README.md)** — Vendor documentation repository structure
- **[vendor-docs/kubernetes/README.md](vendor-docs/kubernetes/README.md)** — Kubernetes references
- **[vendor-docs/terraform/README.md](vendor-docs/terraform/README.md)** — Terraform references
- **[vendor-docs/ansible/README.md](vendor-docs/ansible/README.md)** — Ansible references

### Generated PDF Publications

All PDFs are generated automatically with `make pdf` and follow the V-Model phase naming convention.

| PDF | Phase | Purpose |
|---|---|---|
| `01_PMP_SEMP.pdf` | Project Management | Project management plan and processes |
| `03_SRD_SysMLCloudPlatform.pdf` | System Requirements | Overall system requirements |
| `03_SRD_Infrastructure.pdf` | System Requirements | Infrastructure cluster requirements |
| `03_SRD_Datacenter.pdf` | System Requirements | Datacenter/fabrication requirements |
| `03_SRD_SystemRequirements.pdf` | System Requirements | All requirements consolidated |
| `04_SAD_SysMLCloudPlatform.pdf` | System Architecture & Design | Overall system architecture |
| `04_SAD_Infrastructure.pdf` | System Architecture & Design | Cluster architecture design |
| `04_SAD_Fabrication.pdf` | System Architecture & Design | Datacenter architecture design |
| `04_SAD_SystemArchitectureAndDesign.pdf` | System Architecture & Design | Complete architecture |
| `06_SDD_FabricationDatacenterA.pdf` | Detailed Design | Datacenter A detailed specifications |
| `06_SDD_FabricationDatacenterB.pdf` | Detailed Design | Datacenter B detailed specifications |
| `11_DPL_DeploymentAndOM.pdf` | Deployment & O&M | Deployment procedures and operations |

**View generated PDFs**: Open any PDF in `publication/` folder

### Quick Commands

```bash
# Initialize development environment
make init

# Build documentation from SysML models
make docs

# Generate PDF publications (V-Model-ordered)
make pdf

# Clean generated artifacts
make clean

# Full rebuild (clean + docs + pdf)
make all
```

---

## 🏗️ SysML Architecture Guide

For a detailed walkthrough of how this project uses OMG SysML v2, including:
- Cluster A (lab-scale) and Cluster B (production EKS-like) definitions
- Multi-datacenter deployment topology
- Shared library patterns for reusability
- Traceability from SysML to Terraform to Ansible
- Template structures for consistency

See: **[SYSML_ARCHITECTURE_GUIDE.md](SYSML_ARCHITECTURE_GUIDE.md)**

---

## 📂 Project Structure
```bash
architecture/
├── SYSML_ARCHITECTURE_GUIDE.md      # Complete SysML v2 architecture guide
├── sysml/                           # OMG SysML v2 source files
│   ├── overall-design/              # System-level architecture
│   ├── infrastructure/              # Kubernetes cluster definitions
│   └── datacenter/                  # Datacenter topology
├── publication/                     # Generated Markdown + diagrams + PDFs
├── fabrications/                    # Datacenter models and IaC
│   ├── fabrication-datacenter-a/   # Primary datacenter
│   └── fabrication-datacenter-b/   # Secondary datacenter
├── configs/                         # Cluster configurations and IaC
│   ├── infrastructure-cluster-a/   # Lab cluster
│   └── infrastructure-cluster-b/   # Production cluster
├── library/                         # Shared reusable components
│   ├── sysml-library/              # Shared SysML definitions
│   ├── terraform-modules/          # Shared Terraform modules
│   └── ansible-roles/              # Shared Ansible roles
├── templates/                       # Configuration templates and guidelines
│   ├── TERRAFORM_STRUCTURE.md      # Terraform folder structure
│   ├── ANSIBLE_STRUCTURE.md        # Ansible folder structure
│   └── common_variables.tf         # Common Terraform variables
├── scripts/
│   ├── build-docs.py               # SysML → Markdown + diagrams
│   ├── generate-pdfs.py            # Generate V-Model-ordered PDFs
│   └── check-encoding.py           # UTF-8 validation
├── Makefile                        # Build orchestration (cross-platform)
└── README.md                       # This file
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
