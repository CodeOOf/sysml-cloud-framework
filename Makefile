# Detect OS
UNAME_S := $(shell uname -s 2>/dev/null)

# Cross-platform DATE
ifeq ($(UNAME_S),Linux)
	DATE := $(shell date +%Y-%m-%d)
else ifeq ($(UNAME_S),Darwin)  # macOS
	DATE := $(shell date +%Y-%m-%d)
else
	# Assume Windows with PowerShell
	DATE := $(shell powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd")
endif

# Get version from latest Git tag, or default to v0.0.0
VERSION := $(shell git describe --tags --abbrev=0 2>/dev/null || echo v0.0.0)

PY := ".venv/Scripts/python.exe"

# Root dirs (relative to architecture/)
SYSML_DIR := sysml
PUB_DIR   := publication

PUB_MD := $(notdir $(wildcard $(PUB_DIR)/*.md))

.PHONY: all init setup-submodules docs clean check-encoding pdf

all: clean docs pdf

init:
	python -m venv .venv
	$(PY) -m pip install -r py-requirements.txt

setup-submodules-init:
	@echo === [Submodules] Initializing from .submodules.config ===
	$(PY) scripts/setup-submodules.py --init

setup-submodules-update:
	@echo === [Submodules] Updating submodules ===
	$(PY) scripts/setup-submodules.py --update

setup-submodules-status:
	@echo === [Submodules] Status report ===
	$(PY) scripts/setup-submodules.py --status

clean:
	@echo === [Clean] Removing publication artifacts ===
	@if exist publication rd /s /q publication

docs: check-encoding
	@echo === [Docs] Building publication from SysML ===
	$(PY) scripts/build-docs.py $(SYSML_DIR) $(PUB_DIR) $(SYSML_DIR)

check-encoding:
	@echo === [Check] Scanning files for UTF-8 compliance ===
	$(PY) scripts/check-encoding.py .

pdf:
	@echo === [Docs] Generating PDF publication ===
	cd $(PUB_DIR) && pandoc $(PUB_MD) \
		   --template="../templates/titlepage.tex" \
		   -o sysml-cloud-platform.pdf \
		   --from markdown --toc --pdf-engine=xelatex \
		   --metadata title="SysML Cloud Platform" \
		   --metadata date="$(DATE)" \
		   --metadata version="$(VERSION)"
