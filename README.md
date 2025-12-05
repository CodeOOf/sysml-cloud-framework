# SysML Cloud Framework
A Model-Driven Framework for Designing and Building Cloud Solutions

> **You are here**: README.md (Project Overview)  
> **Next Steps**: → [DOCS_GUIDE.md](docs/DOCS_GUIDE.md) (pick your reading path)

**Documentation**: Start with [DOCS_GUIDE.md](docs/DOCS_GUIDE.md) | [Quick Reference](docs/QUICK_REFERENCE.md) | [Architecture Guide](docs/SYSML_ARCHITECTURE_GUIDE.md)

---

## 🚀 Quick Start

**1. Install dependencies:**
```bash
# Windows: Install Python, Graphviz, Pandoc, MiKTeX
# Linux: sudo apt install -y python3 python3-venv graphviz pandoc texlive-xetex

make init   # Creates .venv and installs Python packages
```

**2. Build documentation:**
```bash
make docs   # Generate Markdown + diagrams from SysML models
make pdf    # Generate V-Model-ordered PDFs
```

**3. Explore the project:**
- See generated PDFs in `publication/` folder
- Browse SysML source in `sysml/` directory
- Check infrastructure examples in `configs/` and `fabrications/`

---

## 📋 What This Project Does

**Model-driven cloud architecture** — Define your cloud infrastructure and operations in OMG SysML v2, generate implementation artifacts (Terraform, Ansible), and maintain traceability across the entire system.

**Key capabilities:**
- SysML v2 models for infrastructure architecture
- Automated generation of docs, diagrams, and PDFs from models
- Git-native workflow with CI/CD integration
- Template-based consistency for multiple environments
- Traceability from requirements through design to implementation

---

## ⚙️ Installation

See [QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md) for detailed setup instructions.

---

## 🔨 Build Commands

```bash
make init    # Initialize environment (one-time)
make docs    # Build documentation from SysML models
make pdf     # Generate V-Model-ordered PDFs
make clean   # Remove generated artifacts
make all     # Full rebuild (clean + docs + pdf)
```

For workflow details, see [QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md).

---

## 📚 Documentation Navigation

**Editable documentation** lives in the `docs/` folder:
- **[DOCS_GUIDE.md](docs/DOCS_GUIDE.md)** — Start here (guided entry point)
- **[SYSML_ARCHITECTURE_GUIDE.md](docs/SYSML_ARCHITECTURE_GUIDE.md)** — Complete technical reference
- **[PROJECT_INTEGRATION_GUIDE.md](docs/PROJECT_INTEGRATION_GUIDE.md)** — Jira/Git integration
- **[TESTING_AND_DEPLOYMENT_STRATEGY.md](docs/TESTING_AND_DEPLOYMENT_STRATEGY.md)** — Testing and deployment
- **[CONTRIBUTING.md](docs/CONTRIBUTING.md)** — Development guidelines
- **[V-MODEL_GUIDE.md](docs/V-MODEL_GUIDE.md)** — Publication naming & V-Model mapping
- **[SEMP.md](docs/SEMP.md)** — System Engineering Management Plan

**Generated publications** are in the `publication/` folder (auto-generated, do not edit):
- PDFs organized by V-Model phases (01_PMP, 03_SRD, 04_SAD, 06_SDD, 11_DPL, etc.)
- Markdown grouped by publication (derived from SysML models)
- Diagrams (PNG, auto-rendered from SysML and Graphviz)

| Order | Phase | Abbr | Example PDF |
|-------|-------|------|-------------|
| 01 | Project Management | PMP | `01_PMP_SEMP.pdf` |
| 02 | Stakeholder Needs | SNS | Stakeholder Needs Statement |
| 03 | System Requirements | SRD | `03_SRD_SysMLCloudPlatform.pdf` |
| 04 | System Architecture & Design | SAD | `04_SAD_SysMLCloudPlatform.pdf` |
| 05 | Subsystem Requirements | SSR | Subsystem Requirements |
| 06 | Subsystem Detailed Design | SDD | `06_SDD_FabricationDatacenterA.pdf` |
| 07 | Implementation | SCI | Software/Code Implementation |
| 08 | Integration | ITP | Integration Test Plan |
| 09 | Verification | STP | System Test Plan |
| 10 | Validation | SV | System Validation |
| 11 | Deployment & O&M | DPL | `11_DPL_DeploymentAndOM.pdf` |

- **Markdown** — Auto-generated from SysML models
- **Diagrams** — PNG images from SysML (in `publication/images/`)

---

## 📂 Folder Structure

- `sysml/` — OMG SysML v2 source models by domain (overall-design, infrastructure, datacenter)
- `publication/` — Generated documentation, PDFs, and diagrams
- `configs/{instance-id}/` — Infrastructure configurations (example: cluster-a, prod-west)
- `fabrications/{instance-id}/` — Datacenter specifications (example: datacenter-east-1)
- `library/` — Shared SysML, Terraform, and Ansible components
- `docs/` — User documentation
- `scripts/` — Build automation scripts
- `templates/` — Configuration templates

See [SYSML_ARCHITECTURE_GUIDE.md](docs/SYSML_ARCHITECTURE_GUIDE.md) for detailed descriptions.

---

## 📖 Contributing

See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for development guidelines and workflow.

---

## Roadmap

- 🔜 SysML-to-Terraform generator
- 🔜 SysML deployment views → Helm chart generator
- 🔜 VS Code extension for model-repository integration
- 🔜 Model-based monitoring configuration (Prometheus, OpenTelemetry)
- 🔜 Cloud reference architecture templates

---

## Credits

This project builds on the foundation and inspiration from several key open-source projects and standards:

### Diagram Generation Inspiration
**[SysML_Python_Visualizer](https://github.com/redasasin4/SysML_Python_Visualizer)** by [@redasasin4](https://github.com/redasasin4)
- Demonstrated professional SysML v2 block definition diagram (BDD) rendering using Python and Graphviz
- Inspired the visual style and rendering approach for this project's diagram generator
- Professional, minimal aesthetic with clean white boxes and black borders following SysML v2 standards

### SysML v2 Reference Implementation
**[SysML-v2-Release](https://github.com/Systems-Modeling/SysML-v2-Release)** by [Systems-Modeling](https://github.com/Systems-Modeling)
- Official OMG SysML v2 specification and example models
- Reference for SysML v2 syntax, semantics, and best practices
- Foundation for all SysML v2 models in this project

---

## License

See LICENSE file for details.
