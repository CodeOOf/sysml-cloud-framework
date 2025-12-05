# SysML Diagram Generator Test Suite

## Overview

This test suite validates that the SysML diagram generator produces professional Block Definition Diagram (BDD) style outputs matching the quality and appearance of the [SysML_Python_Visualizer](https://github.com/redasasin4/SysML_Python_Visualizer) reference project.

## Test Coverage

### Professional BDD Style Compliance

Tests ensure all generated PNG diagrams match professional SysML v2 standards:

- **Clean white boxes** with thin black borders (penwidth=1.0)
- **Minimal color coding** - professional black/white appearance
- **Consistent typography** - Helvetica font, readable sizes
- **Professional DPI** - 150 DPI for high-quality output
- **OMG SysML v2 compliant** visual style

### Functional Validation

1. **Documentation Structure Model** - Tests the complete V-Model documentation workflow
   - Validates parsing of 14+ documentation parts
   - Verifies 11+ connections between documents
   - Confirms V-Model phase grouping (01_PMP, 03_SRD, 04_SAD, 06_SDD, 11_DPL)

2. **Filename Attribute Extraction** - Ensures filenames display correctly
   - Validates `attribute filename = "publication/document.md"` syntax
   - Confirms filenames appear in V-Model phases diagram
   - Tests markdown → PDF transformation visualization

3. **V-Model Phase Grouping** - Tests phase clustering and styling
   - Validates professional cluster appearance (white background, black borders)
   - Confirms phase labels and organization
   - Tests inter-phase connections

4. **Multi-Model Generation** - Validates compatibility across workspace
   - Tests 5+ different SysML models from the workspace
   - Ensures consistent professional styling across all diagrams
   - Validates robustness of parser and generator

5. **Professional Style Attributes** - DOT source validation
   - Checks Graphviz DOT output for correct style attributes
   - Ensures NO colorful styling (no #FFE6E6, #E6FFE6, #E6E6FF colors)
   - Confirms white/black professional appearance

## Running Tests

### Run with unittest (verbose)
```powershell
python tests/test_sysml_diagram_generator.py
```

### Run with pytest (cleaner output)
```powershell
pytest tests/test_sysml_diagram_generator.py -v
```

### Run specific test
```powershell
python tests/test_sysml_diagram_generator.py TestSysMLDiagramGenerator.test_professional_bdd_style_compliance
```

## Test Results

All tests should pass with the current implementation. Expected output:

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

## Reference Standards

### SysML_Python_Visualizer Compatibility

The tests ensure compatibility with the reference project's visual style:
- Repository: https://github.com/redasasin4/SysML_Python_Visualizer
- Style: Professional OMG SysML v2 Block Definition Diagrams
- Output: Clean white boxes, thin black borders, minimal color

### OMG SysML v2 Compliance

Tests validate compliance with official SysML v2 standards:
- Professional block diagram appearance
- Clear relationship visualization
- Readable attribute and connection labels
- Industry-standard typography and spacing

## Test Environment

### Required Dependencies
- Python 3.8+
- Pillow (PIL) - for PNG validation
- pytest (optional) - for cleaner test output
- graphviz - for diagram generation

### Test Workspace
Tests use actual SysML models from the workspace:
- `sysml/overall-design/DocumentationStructureModel.sysml`
- `sysml/datacenter/*.sysml`
- `sysml/infrastructure/*.sysml`

This ensures tests validate real-world usage patterns.

## Continuous Integration

These tests should be run:
- Before committing diagram generator changes
- After updating SysML models
- When updating styling or visual appearance
- During CI/CD pipeline for automated validation

## Troubleshooting

### File Permission Errors (Windows)
The test suite includes Windows-safe file cleanup with retry logic to handle file locking issues.

### Graphviz Warnings
The warning "Orthogonal edges do not currently handle edge labels" is expected and does not affect diagram quality.

### Small Diagram Dimensions
Some test models generate minimal diagrams (e.g., requirements documents with few parts). Tests are designed to handle these edge cases.

## Future Enhancements

Potential test additions:
- Performance benchmarking for large models
- Visual regression testing (compare PNG outputs)
- Additional SysML v2 syntax variations
- Custom view types (beyond Tree and Interconnection)
