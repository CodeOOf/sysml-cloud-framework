# Contributing to SysML Cloud Framework

> **Previous**: [README.md](../README.md) → [DOCS_GUIDE.md](DOCS_GUIDE.md)  
> **V-Model Phase**: N/A (Development Guidelines)  
> **Time to read**: 20–30 minutes  
> **Published as**: N/A (Development reference only)  
>  
> **Workflow reminder**: Edit `docs/` (version-controlled source) and `sysml/` (triggers regeneration). Don't edit `publication/` (auto-generated). Run `make docs && make pdf` to regenerate published artifacts.

Thank you for your interest in contributing! This document outlines the process for contributing to the SysML Cloud Framework project.

## Getting Started

1. **Clone the repository** and navigate to the `architecture/` directory.
2. **Set up your environment:**
   ```bash
   make init
   ```
   This creates a `.venv` and installs Python dependencies.

3. **Understand the project's Systems Engineering approach:**
   Read [SEMP.md](SEMP.md) (System Engineering Management Plan) to understand:
   - How SysML models map to infrastructure and operations
   - SE processes, roles, and responsibilities
   - Requirements traceability and validation strategy
   - Configuration management and change control

4. **Check submodule configuration** (optional):
   ```bash
   make setup-submodules-status
   ```
   This shows which folders are committed vs. submodules. See [Submodule Workflows](#submodule-workflows) below.

5. **Familiarize yourself** with the project structure:
   - `sysml/` — SysML model files organized by domain
   - `publication/` — Generated documentation (Markdown, diagrams, PDF)
   - `fabrications/` — Datacenter and rack designs
   - `configs/` — Infrastructure cluster specifications
   - `library/` — Shared Ansible roles, SysML libraries, Terraform modules
   - `scripts/` — Build tooling and utilities
   - `templates/` — LaTeX templates for PDF generation

## Development Workflow

### Before Making Changes

- Review the `README.md` for project overview and requirements.
- Check existing SysML files in `sysml/` to understand naming and structure conventions.
- Ensure all system requirements are installed:
  - Python 3.9+
  - Graphviz (with `dot` on PATH)
  - Pandoc
  - LaTeX/XeLaTeX

### Making Changes

1. **Model changes:** Edit or create `.sysml` files under `sysml/`.
2. **Script changes:** Modify `scripts/build-docs.py` or other utilities as needed.
3. **Documentation changes:** Update `README.md`, `CONTRIBUTING.md`, or other Markdown files.

### Testing Your Changes

1. **Check file encoding:**
   ```bash
   make check-encoding
   ```

2. **Build documentation:**
   ```bash
   make docs
   ```
   This parses SysML files, generates diagrams, and writes Markdown.

3. **Generate PDF** (optional):
   ```bash
   make pdf
   ```

4. **Verify output:**
   - Check `publication/` for generated Markdown and images.
   - Review diagrams for correctness.
   - Ensure the index (`publication/index.md`) includes your new pages.

### Clean Before Rebuilding

```bash
make clean
```
This removes old publication artifacts.

## Code Style & Conventions

### SysML Files

- Use **PascalCase** for file names (e.g., `ClusterArchitectureModel.sysml`).
- Use **UTF-8 encoding** (no BOM) — the checker enforces this.
- Organize files into logical domains:
  - `sysml/overall-design/` — Platform-wide models
  - `sysml/datacenter/` — Datacenter-specific architecture
  - `sysml/infrastructure/` — Infrastructure and cluster models
- Use clear naming for blocks, interfaces, and requirements.

### Python Scripts

- Follow **PEP 8** conventions where practical.
- Add comments for complex parsing or rendering logic.
- Test changes with `make docs` before committing.

## Commit Guidelines

- Write **clear, descriptive commit messages**.
- Reference related issues or features if applicable.
- Ensure `make check-encoding` passes before committing.
- Ensure `python scripts/check-instance-references.py --scope publication,templates` passes to prevent hard-coded example paths in generated docs and templates.
- Include changes to both models and any updated tooling.

Example:
```
Add Kubernetes deployment model to infrastructure domain

- New file: sysml/infrastructure/KubernetesDeploymentModel.sysml
- Updated: scripts/build-docs.py to handle deployment views
- Updated: publication/index.md (auto-generated)
```

### Instance Path Linter

To keep the repository clean and enforce consistent use of placeholder paths:

- **Check for hard-coded example paths locally**:
  ```bash
  python scripts/check-instance-references.py
  ```

- **Check only documentation and templates** (what CI enforces):
  ```bash
  python scripts/check-instance-references.py --scope publication,templates
  ```

- **Auto-fix hard-coded paths** (replaces with `{instance-id}` placeholders):
  ```bash
  python scripts/check-instance-references.py --fix
  ```

- **Auto-fix only scoped paths**:
  ```bash
  python scripts/check-instance-references.py --scope publication,templates --fix
  ```

CI runs the linter on all PRs that touch `publication/` or `templates/` and will fail if hard-coded example paths are detected. Use `--fix` to resolve violations before pushing.

## Submodule Workflows

The SysML Cloud Framework supports **dynamic management of subfolders** inside the top-level content directories. The top-level directories (`fabrications/`, `configs/`, `library/`) are part of this repository; individual subfolders inside them can be:

- **Committed locally** (default for individual development)
- **Linked as git submodules** (recommended for team collaboration and separating concerns)

### Configuration

Edit `.submodules.config` to specify which exact relative paths (usually subfolders under the top-level directories) should be treated as submodules and provide their repository URLs. Example (replace `{instance-id}` with your instance folder name or repo slug):

```ini
# Example (illustrative only — replace placeholders with your instance ids)
[submodule "fabrications/{instance-id}"]
   path = fabrications/{instance-id}
   url = https://github.com/org/fabrications-{instance-id}.git

[submodule "configs/{instance-id}"]
   path = configs/{instance-id}
   url = https://github.com/org/configs-{instance-id}.git

[submodule "library/ansible-roles"]
   path = library/ansible-roles
   url = https://github.com/org/ansible-roles.git
```

### Commands

- **Check status:**
   ```bash
   make setup-submodules-status
   ```
   Shows which configured paths are present as committed folders vs. submodules.

- **Initialize submodules (first-time setup):**
   ```bash
   make setup-submodules-init
   ```
   Adds configured submodules; skips paths that already exist locally as committed folders.

- **Update submodules to latest commits:**
   ```bash
   make setup-submodules-update
   ```

### Workflows

#### Local Development (Committed Subfolders)

1. Keep subfolders (e.g., `fabrications/fabrication-datacenter-a`) committed into this repo.
2. Work directly on those folders; commit and push changes here.
3. Do not set a `url` for those entries in `.submodules.config`.

#### Team Workflow (Separate Repos + Submodules)

1. Create separate Git repositories for one or more subfolders (e.g., `fabrications/fabrication-datacenter-a`).
2. Update `.submodules.config` with the repository URLs for those subfolders.
3. Run `make setup-submodules-init` to add and initialize them as submodules.
4. Each configured submodule is now a separate project with independent versioning.
5. To update a submodule: `cd <submodule-path> && git pull` then commit the parent repo.

### Mixed Mode

You can mix approaches based on needs:
- Keep rarely-changing shared utilities as committed subfolders under `library/`.
- Manage frequently-changing or team-owned components (e.g., a fabrication or cluster spec) as submodules.

Update `.submodules.config` with the chosen subfolder paths and run `make setup-submodules-init` to apply changes.

---

## Reporting Issues

- Use the project's issue tracker to report bugs, request features, or discuss design.
- Include details: what you tried, what failed, and your environment (OS, Python version, tool versions).

## Roadmap & Future Work

See the roadmap section in `README.md` for planned features:
- SysML-to-Terraform generator
- SysML deployment views → Helm chart generator
- VS Code extension for model-repository integration
- Model-based monitoring configuration
- Cloud reference architecture templates

If you'd like to work on any of these, please open an issue or discussion first to coordinate efforts.

## Questions?

If you have questions:
1. Check the `README.md` and existing SysML files for examples.
2. Review `scripts/build-docs.py` comments for parser and rendering details.
3. Open an issue with the `question` label on the project's repository.

---

**Happy modeling!** We look forward to your contributions.

## Next Steps

### To understand the system architecture...
→ Read **[SYSML_ARCHITECTURE_GUIDE.md](SYSML_ARCHITECTURE_GUIDE.md)** (Architecture overview)

### To understand project governance and processes...
→ Read **[SEMP.md](SEMP.md)** (Project Management Plan)

### To see what was delivered...
→ Read **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** (What was built & why)

### To test and deploy your changes...
→ Read **[TESTING_AND_DEPLOYMENT_STRATEGY.md](TESTING_AND_DEPLOYMENT_STRATEGY.md)** (Test & deploy guides)

### Return to the main thread:
→ Back to **[DOCS_GUIDE.md](DOCS_GUIDE.md)**
