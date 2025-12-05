# Tools & Testing Guide — Validating Project Deliverables

> **Previous**: [SYSML_ARCHITECTURE_GUIDE.md](SYSML_ARCHITECTURE_GUIDE.md)  
> **V-Model Phase**: Cross-phase (All phases)  
> **Time to read**: 15 minutes  
> **Published as**: N/A (Developer reference)  
> **Version**: 1.0  
> **Status**: Approved  
> **Last Updated**: December 5, 2025  
> **Author**: Architecture Team

---

## High-Level Summary

This guide describes how to **validate the project's SysML models and generated deliverables** using the automated test suite and build tools included in this repository.

The project includes several **tools** (scripts and utilities) that:
- **Parse** SysML v2 models and extract structure
- **Generate** professional Block Definition Diagrams (BDD) in PNG format
- **Build** markdown documentation and PDF outputs
- **Validate** diagram styling and model compliance

This guide walks developers through:
1. Running the test suite to verify diagram generation
2. Rebuilding documentation from scratch
3. Understanding the tool pipeline
4. Troubleshooting common issues

---

## Audience & Prerequisites

**Who should read this?**
- **Developers** maintaining the SysML models
- **CI/CD Engineers** integrating automated tests
- **Documentation Contributors** updating models
- **Project Leads** verifying deliverable quality

**Prerequisites:**
- Python 3.8+ installed and configured
- Graphviz installed (`dot` command available)
- Familiarity with [SYSML_ARCHITECTURE_GUIDE.md](SYSML_ARCHITECTURE_GUIDE.md)
- Basic understanding of SysML v2 syntax

**Time to read**: 15 minutes

---

## Tools Overview

### 1. SysML Diagram Generator (`scripts/sysml_diagram_generator.py`)

**Purpose**: Parses SysML v2 files and generates professional PNG diagrams

**Input**: `.sysml` files (SysML v2 syntax)  
**Output**: `.png` diagrams (Graphviz-rendered)  
**Style**: Professional Block Definition Diagrams (white boxes, black borders, minimal color)

**Key Features**:
- Automatic element kind detection (parts, requirements, actors, test cases)
- SysML v2 color coding:
  - **White boxes**: Regular parts (professional BDD style)
  - **Wheat/tan boxes (#F5DEB3)**: Requirements (per SysML v2 standard)
  - **Green boxes (#90EE90)**: Test cases (per SysML v2 standard)
  - **No fill**: Actors/stakeholders (stick figure representation)
- Relationship visualization with stereotypes («trace», «satisfy», «verify»)
- Automatic layout optimization for clarity

**Usage**:
```bash
python scripts/sysml_diagram_generator.py <sysml_file> [output_prefix]
```

**Example**:
```bash
python scripts/sysml_diagram_generator.py sysml/overall-design/StakeholderRequirements.sysml publication/images/stakeholder-requirements
```

**Output**:
```
📖 Parsing: sysml/overall-design/StakeholderRequirements.sysml
   Found 29 parts, 0 definitions, 32 connections, 0 actions
🎨 Generating requirements diagram...
✅ Hierarchy diagram saved: publication/images/stakeholder-requirements.png
✅ Done!
```

### 2. Documentation Builder (`scripts/build-docs.py`)

**Purpose**: Processes all SysML models and generates markdown documentation with diagrams

**Input**: 
- SysML source files (from `sysml/` directories)
- Diagram generator output (PNG images)

**Output**: 
- Markdown documentation (`.md` files)
- Integrated diagrams in each document

**Key Features**:
- Batch processes all SysML models in specified directories
- Auto-generates markdown with embedded diagrams
- Creates visual manifest of all models
- Generates `index.md` linking all documentation

**Usage**:
```bash
python scripts/build-docs.py <source_dir> <output_dir> <model_dirs>...
```

**Example** (regenerate all documentation):
```bash
python scripts/build-docs.py sysml publication sysml
```

**Output**:
```
-> Rendering 21 SysML files from sysml
✅ Image saved: publication/images/stakeholder-requirements.png
✅ Markdown written to publication/stakeholder-requirements.md
[... additional files ...]
✅ Documentation build complete.
```

### 3. PDF Generator (`scripts/generate-pdfs.py`)

**Purpose**: Converts markdown documentation to professional PDF format for distribution

**Input**: Markdown files with embedded images  
**Output**: PDF files with V-Model naming convention (e.g., `02_SNS_StakeholderNeeds.pdf`)

**Key Features**:
- Pandoc-based conversion with xelatex engine
- Professional typography and formatting
- Image embedding in PDFs
- V-Model phase naming (01_PMP, 02_SNS, 03_SRD, etc.)

**Usage**:
```bash
python scripts/generate-pdfs.py <documentation_dir>
```

**Example**:
```bash
python scripts/generate-pdfs.py publication
```

**Output**:
```
[OK] PDF generated: publication/01_PMP_SEMP.pdf
[OK] PDF generated: publication/02_SNS_StakeholderNeeds.pdf
[OK] PDF generated: publication/03_SRD_Datacenter.pdf
[... additional PDFs ...]
[OK] All PDFs processed.
```

---

## Test Suite — Validating Diagram Generation

### Overview

The test suite validates:
- ✅ Diagram generator produces professional BDD-style output
- ✅ PNG diagrams match reference project visual standards
- ✅ Style attributes are correct (white/black professional appearance)
- ✅ All SysML models in workspace generate successfully
- ✅ Filenames and connections extract correctly
- ✅ V-Model phase grouping displays properly

### Running Tests

#### Option 1: Run with Python's unittest (verbose, no dependencies)
```powershell
python tests/test_sysml_diagram_generator.py
```

#### Option 2: Run with pytest (cleaner, requires pytest package)
```powershell
python -m pytest tests/test_sysml_diagram_generator.py -v
```

#### Option 3: Run a specific test
```powershell
python tests/test_sysml_diagram_generator.py TestSysMLDiagramGenerator.test_professional_bdd_style_compliance
```

### Test Coverage

#### Test 1: Multi-Model Generation
**Name**: `test_all_sysml_models_generate_diagrams`  
**What it tests**: All SysML models in the workspace generate without errors

**Check**:
```bash
python tests/test_sysml_diagram_generator.py TestSysMLDiagramGenerator.test_all_sysml_models_generate_diagrams
```

**Expected**: ✅ PASS — All 21 SysML models generate diagrams successfully

#### Test 2: Documentation Structure
**Name**: `test_documentation_structure_model`  
**What it tests**: DocumentationStructureModel parses correctly with proper part count

**Check**:
```bash
python tests/test_sysml_diagram_generator.py TestSysMLDiagramGenerator.test_documentation_structure_model
```

**Expected**: ✅ PASS — Model contains 16 parts, 9 definitions, 14 connections, 7 actions

#### Test 3: Filename Extraction
**Name**: `test_filename_attribute_in_real_model`  
**What it tests**: Filename attributes extract correctly from real SysML model

**Check**:
```bash
python tests/test_sysml_diagram_generator.py TestSysMLDiagramGenerator.test_filename_attribute_in_real_model
```

**Expected**: ✅ PASS — Filenames like "publication/SEMP.md" extract correctly

#### Test 4: Professional BDD Style
**Name**: `test_professional_bdd_style_compliance`  
**What it tests**: Generated Graphviz DOT code uses white/black professional styling

**Check**:
```bash
python tests/test_sysml_diagram_generator.py TestSysMLDiagramGenerator.test_professional_bdd_style_compliance
```

**Expected**: ✅ PASS — All nodes have white fill, black borders; no colorful styling

#### Test 5: V-Model Phase Grouping
**Name**: `test_v_model_phase_grouping`  
**What it tests**: V-Model phases display correctly in grouped diagram

**Check**:
```bash
python tests/test_sysml_diagram_generator.py TestSysMLDiagramGenerator.test_v_model_phase_grouping
```

**Expected**: ✅ PASS — Phases 01_PMP, 03_SRD, 04_SAD, 06_SDD, 11_DPL cluster correctly

### Expected Test Results

When all tests pass:
```
test_all_sysml_models_generate_diagrams ... ok
test_documentation_structure_model ... ok
test_filename_attribute_in_real_model ... ok
test_professional_bdd_style_compliance ... ok
test_v_model_phase_grouping ... ok

----------------------------------------------------------------------
Ran 5 tests in ~4s

OK
```

### Interpreting Test Failures

| Failure | Likely Cause | Solution |
|---------|-------------|----------|
| `FileNotFoundError` | SysML file missing | Check file path in workspace |
| `AssertionError: Found N parts` | Model structure changed | Re-run tests to update baseline |
| `Color mismatch` | Styling changed | Verify `get_style()` function in diagram generator |
| `Graphviz error` | Dot engine issue | Ensure Graphviz is installed and in PATH |
| `PNG generation failed` | Output directory missing | Create `publication/images/` if missing |

---

## Typical Workflow — Rebuild Everything

When you update SysML models, use this workflow to regenerate all deliverables:

### Step 1: Rebuild Diagrams and Markdown
```bash
python scripts/build-docs.py sysml publication sysml
```

This:
- Parses all `.sysml` files
- Generates PNG diagrams for each
- Creates markdown with embedded diagrams
- Updates `publication/index.md`

### Step 2: Generate PDFs
```bash
python scripts/generate-pdfs.py publication
```

This:
- Converts all markdown to PDF
- Applies V-Model phase naming
- Outputs to `publication/*.pdf`

### Step 3: Run Validation Tests
```bash
python tests/test_sysml_diagram_generator.py
```

This validates:
- All diagrams generated successfully
- Professional styling maintained
- No regressions introduced

**Complete workflow (one-liner)**:
```powershell
python scripts/build-docs.py sysml publication sysml; python scripts/generate-pdfs.py publication; python tests/test_sysml_diagram_generator.py
```

---

## Requirements Diagrams — Special Handling

Requirements models (using `requirement`, `actor`, `test case` keywords) generate **single-file output**:

**Input**: `sysml/overall-design/StakeholderRequirements.sysml`  
**Output**: `publication/images/stakeholder-requirements.png` (requirements diagram)

**NOT generated** (by design):
- No `_hierarchy.png` file
- No `_phases.png` file

This is intentional — requirements diagrams need single unified visualization.

**Example**: Actor → Requirement → Test Case relationships:
```sysml
actor 'Business Unit Manager' { ... }

requirement CostReduction {
  text = "Reduce costs by 30%";
}

test case VerifyCostReduction {
  verify CostReduction;
}

connect 'Business Unit Manager' to CostReduction;  // «trace»
```

This generates a single diagram showing stakeholders, their requirements, and verification tests.

---

## Verification & Validation

### Quick Validation Checklist

After running the tools, verify:

- [ ] **Diagrams generated**: Check `publication/images/*.png` exist
- [ ] **No hierarchy files**: No `*_hierarchy.png` or `*_phases.png` for requirements models
- [ ] **PDFs created**: Check `publication/*.pdf` files generated
- [ ] **Markdown created**: Check `publication/*.md` files present
- [ ] **Tests pass**: Run test suite with no failures
- [ ] **No errors**: Check console for error messages

### Visual Verification

Open any generated PNG and check:
- ✅ **White boxes** for regular parts (professional appearance)
- ✅ **Wheat/tan boxes** for requirements (SysML v2 standard)
- ✅ **Green boxes** for test cases (SysML v2 standard)
- ✅ **Black borders** on all elements
- ✅ **Clear relationships** with labeled edges
- ✅ **Readable text** at 150 DPI

### Command to Check Diagram Quality

```bash
# Count generated diagrams
Get-ChildItem publication/images/*.png | Measure-Object

# Verify no unwanted files
Get-ChildItem publication/images/*_hierarchy.png -ErrorAction SilentlyContinue

# Check PDF generation
Get-ChildItem publication/*.pdf | Select-Object Name, Length
```

---

## Troubleshooting

### Issue: "Graphviz not found" or "dot command not recognized"

**Cause**: Graphviz is not installed or not in system PATH

**Solution**:
1. **Windows**: Download from https://graphviz.org/download/
2. **Linux**: `sudo apt-get install graphviz`
3. **macOS**: `brew install graphviz`
4. **Verify**: Run `dot -V` in terminal

### Issue: Python module errors (PIL, graphviz package)

**Cause**: Missing dependencies

**Solution**:
```bash
pip install pillow graphviz
```

### Issue: "No such file or directory" errors

**Cause**: Working directory is wrong or paths are incorrect

**Solution**:
```bash
# Ensure you're in the architecture directory
cd path/to/private-cloud-project/architecture

# Then run tools
python scripts/build-docs.py sysml publication sysml
```

### Issue: Tests fail with "AssertionError"

**Cause**: SysML model structure changed

**Solution**:
1. Check if model was intentionally modified
2. Update test baseline if modifications are correct
3. Run individual test to diagnose: `python tests/test_sysml_diagram_generator.py TestSysMLDiagramGenerator.<test_name>`

### Issue: PDF generation fails with font warnings

**Cause**: xelatex rendering warnings (cosmetic, not critical)

**Solution**: PDFs are still generated successfully; warnings are normal for complex documents

---

## Next Steps

### If you want to understand the SysML models...

→ Read **[SYSML_ARCHITECTURE_GUIDE.md](SYSML_ARCHITECTURE_GUIDE.md)** (Architecture overview)

### If you want to modify models and see changes...

→ Follow the **Typical Workflow — Rebuild Everything** section above

### If you want to add new tests...

→ Edit `tests/test_sysml_diagram_generator.py` and follow existing test patterns

### If you want documentation on all deliverables...

→ Go to **[DOCS_GUIDE.md](DOCS_GUIDE.md)** for the complete thread

### If you want to return to the main documentation thread...

→ Go back to **[DOCS_GUIDE.md](DOCS_GUIDE.md)** or **[README.md](../README.md)**

---

## Reference

- **Graphviz Documentation**: https://graphviz.org/documentation/
- **SysML v2 Standard**: https://www.omgsysml.org/
- **SysML_Python_Visualizer Reference**: https://github.com/redasasin4/SysML_Python_Visualizer
- **Pandoc Documentation**: https://pandoc.org/
