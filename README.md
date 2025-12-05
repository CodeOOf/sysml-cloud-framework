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

## 📖 Documentation & Learning Path

**Start your journey here:**

→ **[DOCS_GUIDE.md](docs/DOCS_GUIDE.md)** — Choose your reading path based on your role  
→ **[QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md)** — Common commands and setup  
→ **[SYSML_ARCHITECTURE_GUIDE.md](docs/SYSML_ARCHITECTURE_GUIDE.md)** — Technical deep dive

All documentation follows a consistent thread with navigation headers. Pick your entry point based on your needs — architect, developer, or operator.

---

## 📂 Project Structure at a Glance

- `sysml/` — OMG SysML v2 source models
- `publication/` — Generated PDFs, diagrams, and markdown
- `configs/`, `fabrications/` — Infrastructure specifications  
- `library/` — Shared components (Terraform, Ansible, SysML)
- `docs/` — User documentation (editable source)
- `scripts/` — Build automation tools

---

## 🔨 Essential Commands

```bash
make init    # Initialize environment (one-time)
make docs    # Regenerate documentation from SysML models
make pdf     # Generate V-Model-ordered PDFs
make all     # Full rebuild (clean + docs + pdf)
```

See [QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md) for complete command reference.

---

## 🤝 Contributing

Interested in contributing? See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines and workflow.

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
