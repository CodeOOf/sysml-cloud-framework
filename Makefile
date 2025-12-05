# ============================================================================
# Cross-platform configuration (Linux/macOS/Windows)
# ============================================================================

UNAME_S := $(shell uname -s 2>/dev/null)

ifeq ($(UNAME_S),Linux)
	# Linux
	DATE := $(shell date +%Y-%m-%d)
	PY := .venv/bin/python
	COLOR_RESET := \033[0m
	COLOR_GREEN := \033[32m
	COLOR_YELLOW := \033[33m
	COLOR_RED := \033[31m
	INFO = @printf "$(COLOR_GREEN)[INFO]$(COLOR_RESET) %s\n" "$(1)"
	WARN = @printf "$(COLOR_YELLOW)[WARN]$(COLOR_RESET) %s\n" "$(1)"
	ERR  = @printf "$(COLOR_RED)[ERROR]$(COLOR_RESET) %s\n" "$(1)"
	RM_PUB = rm -rf publication
else ifeq ($(UNAME_S),Darwin)
	# macOS
	DATE := $(shell date +%Y-%m-%d)
	PY := .venv/bin/python
	COLOR_RESET := \033[0m
	COLOR_GREEN := \033[32m
	COLOR_YELLOW := \033[33m
	COLOR_RED := \033[31m
	INFO = @printf "$(COLOR_GREEN)[INFO]$(COLOR_RESET) %s\n" "$(1)"
	WARN = @printf "$(COLOR_YELLOW)[WARN]$(COLOR_RESET) %s\n" "$(1)"
	ERR  = @printf "$(COLOR_RED)[ERROR]$(COLOR_RESET) %s\n" "$(1)"
	RM_PUB = rm -rf publication
else
	# Windows (PowerShell)
	DATE := $(shell powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd")
	PY := .venv/Scripts/python.exe
	INFO = @powershell -NoProfile -Command "Write-Host \"[INFO] $(1)\" -ForegroundColor Green"
	WARN = @powershell -NoProfile -Command "Write-Host \"[WARN] $(1)\" -ForegroundColor Yellow"
	ERR  = @powershell -NoProfile -Command "Write-Host \"[ERROR] $(1)\" -ForegroundColor Red"
	RM_PUB = if exist publication rd /s /q publication
endif

# Get version from latest Git tag, or default to v0.0.0
VERSION := $(shell git describe --tags --abbrev=0 2>/dev/null || echo v0.0.0)

# Root dirs (relative to architecture/)
SYSML_DIR := sysml
PUB_DIR   := publication

PUB_MD := $(notdir $(wildcard $(PUB_DIR)/*.md))

.PHONY: all init setup-submodules docs clean check-encoding pdf setup-submodules-init setup-submodules-update setup-submodules-status

all: clean docs pdf

init:
	$(call INFO, "Creating virtual environment and installing Python dependencies")
	python -m venv .venv
	$(PY) -m pip install -r py-requirements.txt

setup-submodules-init:
	$(call INFO, "Initializing submodules from .submodules.config")
	$(PY) scripts/setup-submodules.py --init

setup-submodules-update:
	$(call INFO, "Updating submodules")
	$(PY) scripts/setup-submodules.py --update

setup-submodules-status:
	$(call INFO, "Submodule status report")
	$(PY) scripts/setup-submodules.py --status

clean:
	$(call WARN, "Removing publication artifacts")
	$(RM_PUB)

docs: check-encoding
	$(call INFO, "Building publication from SysML and domain folders")
	$(PY) scripts/build-docs.py $(SYSML_DIR) $(PUB_DIR) $(SYSML_DIR) fabrications configs library

.PHONY: pdfs
pdfs:
	$(call INFO, "Generating structured PDFs: SEMP, System Design, Subsystems")
	$(PY) scripts/generate-pdfs.py $(PUB_DIR)

pdf: docs pdfs
	$(call INFO, "PDF generation complete")

check-encoding:
	$(call INFO, "Scanning files for UTF-8 compliance")
	$(PY) scripts/check-encoding.py .

pdf:
	$(call INFO, "Generating PDF publication (requires pandoc + xelatex)")
	cd $(PUB_DIR) && pandoc $(PUB_MD) \
		   -o sysml-cloud-framework.pdf \
		   --from markdown --toc --pdf-engine=xelatex \
		   --metadata title="SysML Cloud Framework" \
		   --metadata date="$(DATE)" \
		   --metadata version="$(VERSION)"
