# SysML Cloud Platform
A Model-Driven Framework for Designing and Building Cloud Solutions

**Documentation**: Start with [INDEX.md](docs/INDEX.md) | [Quick Reference](docs/QUICK_REFERENCE.md) | [Architecture Guide](docs/SYSML_ARCHITECTURE_GUIDE.md)

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

Full documentation is in the `docs/` folder:
- **[INDEX.md](docs/INDEX.md)** — Start here (guided entry point)
- **[SYSML_ARCHITECTURE_GUIDE.md](docs/SYSML_ARCHITECTURE_GUIDE.md)** — Complete technical reference
- **[PROJECT_INTEGRATION_GUIDE.md](docs/PROJECT_INTEGRATION_GUIDE.md)** — Jira/Git integration
- **[TESTING_AND_DEPLOYMENT_STRATEGY.md](docs/TESTING_AND_DEPLOYMENT_STRATEGY.md)** — Testing and deployment
- **[CONTRIBUTING.md](docs/CONTRIBUTING.md)** — Development guidelines

Generated publications (in `publication/` folder):
- **PDFs** — V-Model-ordered documentation (01_PMP_SEMP.pdf, 03_SRD_*, 04_SAD_*, 06_SDD_*, 11_DPL_*)
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
