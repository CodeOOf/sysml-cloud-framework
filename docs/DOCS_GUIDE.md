# Docs Guide — OMG SysML v2 Cloud Platform Architecture

## Short TOC

- [Overview & Quick Start](#overview--quick-start)
- [Documentation Reading Order](#documentation-reading-order)
- [Folder Map](#folder-map)
- [Publication & V-Model Guide](#publication--v-model-guide)
- [Key Links](#key-links)

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