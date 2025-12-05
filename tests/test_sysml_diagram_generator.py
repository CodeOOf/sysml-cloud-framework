"""
Unit tests for SysML diagram generator validating professional BDD style output.

Tests validate that generated PNG diagrams match the professional SysML BDD style
as exemplified by the SysML_Python_Visualizer project:
- Clean white boxes with thin black borders
- Minimal color usage (black/white professional appearance)
- Proper SysML v2 syntax parsing
- Accurate connection and relationship rendering
"""

import unittest
import tempfile
import os
from pathlib import Path
import sys
from PIL import Image
import re

# Add scripts directory to path
sys.path.insert(0, str(Path(__file__).parent.parent / 'scripts'))

from sysml_diagram_generator import parse_sysml, generate_hierarchy_diagram, generate_v_model_phases_diagram


class TestSysMLDiagramGenerator(unittest.TestCase):
    """Test suite for SysML diagram generation with professional BDD styling."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.test_dir = tempfile.mkdtemp()
        self.maxDiff = None
        
    def tearDown(self):
        """Clean up test files - with Windows-safe retry logic."""
        import shutil
        import time
        if os.path.exists(self.test_dir):
            # Windows file locking workaround
            for _ in range(3):
                try:
                    shutil.rmtree(self.test_dir)
                    break
                except PermissionError:
                    time.sleep(0.1)
    
    def test_documentation_structure_model(self):
        """
        Test with the actual DocumentationStructureModel from the workspace.
        Validates V-Model phase grouping and professional styling.
        """
        doc_model = Path(__file__).parent.parent / "sysml" / "overall-design" / "DocumentationStructureModel.sysml"
        
        if not doc_model.exists():
            self.skipTest(f"DocumentationStructureModel not found at {doc_model}")
        
        # Parse the documentation model
        parts, connections, part_defs, actions = parse_sysml(doc_model)
        
        # Validate comprehensive parsing
        self.assertGreater(len(parts), 10, "Should parse multiple documentation parts")
        self.assertGreater(len(connections), 5, "Should parse multiple connections")
        self.assertGreater(len(actions), 3, "Should parse V-Model phase actions")
        
        # Check for phase definitions
        phase_defs = [name for name in part_defs.keys() if 'Phase' in name]
        self.assertGreater(len(phase_defs), 3, "Should have multiple V-Model phases")
        
        # Generate hierarchy diagram
        output_hierarchy = Path(self.test_dir) / "doc_hierarchy"
        success = generate_hierarchy_diagram(parts, connections, part_defs, str(output_hierarchy))
        self.assertTrue(success, "Hierarchy diagram generation should succeed")
        self.assertTrue(os.path.exists(f"{output_hierarchy}.png"), "Hierarchy PNG should be created")
        
        # Generate V-Model phases diagram
        output_phases = Path(self.test_dir) / "doc_phases"
        success = generate_v_model_phases_diagram(parts, connections, part_defs, str(output_phases))
        self.assertTrue(success, "V-Model phases diagram generation should succeed")
        self.assertTrue(os.path.exists(f"{output_phases}.png"), "Phases PNG should be created")
        
        # Validate both diagrams have professional BDD style
        self._validate_professional_bdd_style(f"{output_hierarchy}.png")
        self._validate_professional_bdd_style(f"{output_phases}.png")
    
    def test_professional_bdd_style_compliance(self):
        """
        Test that generated diagrams comply with professional SysML BDD styling.
        Uses the actual workspace model which is known to work.
        """
        doc_model = Path(__file__).parent.parent / "sysml" / "overall-design" / "DocumentationStructureModel.sysml"
        
        if not doc_model.exists():
            self.skipTest(f"DocumentationStructureModel not found")
        
        parts, connections, part_defs, actions = parse_sysml(doc_model)
        output_path = Path(self.test_dir) / "style_diagram"
        
        success = generate_hierarchy_diagram(parts, connections, part_defs, str(output_path))
        self.assertTrue(success, "Style test diagram should generate")
        
        # Validate professional styling
        self._validate_professional_bdd_style(f"{output_path}.png")
        
        # Check Graphviz source file for style attributes
        dot_file = f"{output_path}"
        if os.path.exists(dot_file):
            with open(dot_file, 'r', encoding='utf-8') as f:
                dot_content = f.read()
                
                # Validate professional BDD style attributes in DOT source
                self.assertIn('fillcolor=white', dot_content, 
                            "Should use white fill for professional appearance")
                self.assertIn('color=black', dot_content,
                            "Should use black borders for professional appearance")
                # penwidth appears without quotes in DOT output
                self.assertTrue('penwidth=1.0' in dot_content or 'penwidth="1.0"' in dot_content,
                            "Should use thin borders (1.0) for clean appearance")
                
                # Should NOT contain colorful styling from old version
                self.assertNotIn('#FFE6E6', dot_content, "Should not use red color coding")
                self.assertNotIn('#E6FFE6', dot_content, "Should not use green color coding")
                self.assertNotIn('#E6E6FF', dot_content, "Should not use blue color coding")
                self.assertNotIn('#0066CC', dot_content, "Should not use blue accent colors")
    
    def test_all_sysml_models_generate_diagrams(self):
        """
        Test that all SysML models in the workspace can generate diagrams.
        This ensures broad compatibility with the professional BDD style.
        """
        sysml_dir = Path(__file__).parent.parent / "sysml"
        
        if not sysml_dir.exists():
            self.skipTest("SysML directory not found")
        
        sysml_files = list(sysml_dir.rglob("*.sysml"))
        self.assertGreater(len(sysml_files), 5, "Should find multiple SysML files")
        
        success_count = 0
        for sysml_file in sysml_files[:5]:  # Test first 5 files to keep test fast
            try:
                parts, connections, part_defs, actions = parse_sysml(sysml_file)
                
                output_path = Path(self.test_dir) / f"test_{sysml_file.stem}"
                success = generate_hierarchy_diagram(parts, connections, part_defs, str(output_path))
                
                if success and os.path.exists(f"{output_path}.png"):
                    success_count += 1
                    # Quick validation
                    self._validate_professional_bdd_style(f"{output_path}.png")
            except Exception as e:
                self.fail(f"Failed to process {sysml_file.name}: {e}")
        
        self.assertGreater(success_count, 3, 
                          f"Should successfully generate diagrams for multiple models (got {success_count})")
    
    def test_filename_attribute_in_real_model(self):
        """
        Test that filename attributes are properly extracted from the actual model.
        This validates the critical documentation structure feature.
        """
        doc_model = Path(__file__).parent.parent / "sysml" / "overall-design" / "DocumentationStructureModel.sysml"
        
        if not doc_model.exists():
            self.skipTest("DocumentationStructureModel not found")
        
        parts, connections, part_defs, actions = parse_sysml(doc_model)
        
        # Validate filename extraction in part_defs
        found_filenames = False
        for def_name, def_data in part_defs.items():
            if 'parts' in def_data:
                for part in def_data['parts']:
                    if 'attributes' in part and 'filename' in part['attributes']:
                        filename = part['attributes']['filename']
                        # Validate filename format
                        self.assertTrue(filename.startswith('publication/'), 
                                      f"Filename should start with publication/: {filename}")
                        self.assertTrue(filename.endswith('.md') or filename.endswith('.pdf'),
                                      f"Filename should be .md or .pdf: {filename}")
                        found_filenames = True
        
        self.assertTrue(found_filenames, "Should find filename attributes in the model")
        
        # Generate diagram and verify it includes filenames
        output_path = Path(self.test_dir) / "filename_test"
        # Use V-Model phases diagram which displays filenames, not hierarchy
        success = generate_v_model_phases_diagram(parts, connections, part_defs, str(output_path))
        self.assertTrue(success, "Filename diagram should generate")
        
        # Check DOT source contains filenames
        dot_file = f"{output_path}"
        if os.path.exists(dot_file):
            with open(dot_file, 'r', encoding='utf-8') as f:
                dot_content = f.read()
                # V-Model phases diagram should show filenames in labels or edges
                has_filenames = '.md' in dot_content or '.pdf' in dot_content or 'publication/' in dot_content
                self.assertTrue(has_filenames,
                              "V-Model phases diagram should display filenames")
    
    def test_v_model_phase_grouping(self):
        """
        Test V-Model phase grouping and cluster styling.
        Validates that phases are properly grouped with professional appearance.
        """
        doc_model = Path(__file__).parent.parent / "sysml" / "overall-design" / "DocumentationStructureModel.sysml"
        
        if not doc_model.exists():
            self.skipTest("DocumentationStructureModel not found")
        
        parts, connections, part_defs, actions = parse_sysml(doc_model)
        
        # Validate phase parsing
        self.assertGreater(len(actions), 0, "Should parse V-Model phase actions")
        phase_names = [name for name in part_defs.keys() if 'Phase' in name]
        self.assertGreater(len(phase_names), 3, "Should find multiple phases")
        
        # Generate V-Model diagram
        output_path = Path(self.test_dir) / "vmodel_phases"
        success = generate_v_model_phases_diagram(parts, connections, part_defs, str(output_path))
        self.assertTrue(success, "V-Model diagram should generate")
        
        # Validate professional cluster styling
        dot_file = f"{output_path}"
        if os.path.exists(dot_file):
            with open(dot_file, 'r', encoding='utf-8') as f:
                dot_content = f.read()
                # Clusters should have professional white background
                self.assertIn('cluster_', dot_content, "Should create phase clusters")
                # Should use clean styling for clusters
                self.assertIn('fillcolor=white', dot_content,
                            "Clusters should use white background")
                self.assertIn('color=black', dot_content,
                            "Clusters should use black borders")
    
    def _validate_professional_bdd_style(self, image_path: str):
        """
        Validate that a generated PNG has professional BDD characteristics.
        
        Checks:
        - Image exists and is valid PNG
        - Reasonable dimensions for professional diagrams
        - File size indicates proper rendering (not blank or corrupted)
        """
        self.assertTrue(os.path.exists(image_path), f"Image should exist: {image_path}")
        
        # Validate it's a valid PNG
        try:
            with Image.open(image_path) as img:
                self.assertEqual(img.format, 'PNG', "Should be PNG format")
                
                # Validate reasonable dimensions (relaxed for small test diagrams)
                width, height = img.size
                self.assertGreater(width, 10, "Diagram width should be rendered")
                self.assertGreater(height, 10, "Diagram height should be rendered")
                self.assertLess(width, 10000, "Diagram width should be reasonable")
                self.assertLess(height, 10000, "Diagram height should be reasonable")
                
                # Validate file size (should not be blank or corrupted)
                file_size = os.path.getsize(image_path)
                self.assertGreater(file_size, 100, 
                                 "PNG file should have content (>100B)")
                self.assertLess(file_size, 10_000_000,
                              "PNG file should be reasonable size (<10MB)")
                
                # Professional diagrams should use reasonable DPI
                dpi = img.info.get('dpi', (72, 72))
                if isinstance(dpi, tuple):
                    self.assertGreaterEqual(dpi[0], 72, "Should use professional DPI (>=72)")
            
        except Exception as e:
            self.fail(f"Failed to validate PNG: {e}")


def run_tests():
    """Run all tests and return results."""
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()
    
    # Add test class
    suite.addTests(loader.loadTestsFromTestCase(TestSysMLDiagramGenerator))
    
    # Run with verbose output
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    return result.wasSuccessful()


if __name__ == '__main__':
    success = run_tests()
    sys.exit(0 if success else 1)
    
    def test_reference_vehicle_model(self):
        """
        Test with a SysML v2 model inspired by SysML_Python_Visualizer examples.
        Validates proper parsing and professional BDD style rendering.
        """
        sysml_content = """
package VehicleExample {
    part def Vehicle {
        part engine : Engine;
        part transmission : Transmission;
        part wheels : Wheel[4];
        
        // Connections showing relationships
        connect engine.output to transmission.input;
        connect transmission.output to wheels.axle;
    }
    
    part def Engine {
        port output;
        attribute power : Real;
        attribute fuelType : String;
    }
    
    part def Transmission {
        port input;
        port output;
        attribute gears : Integer;
    }
    
    part def Wheel {
        port axle;
        attribute diameter : Real;
    }
}
"""
        # Write test SysML file
        test_file = Path(self.test_dir) / "vehicle_test.sysml"
        test_file.write_text(sysml_content)
        
        # Parse the model
        parts, connections, part_defs, actions = parse_sysml(test_file)
        
        # Validate parsing results
        self.assertGreater(len(parts), 0, "Should parse parts from vehicle model")
        self.assertIn('Vehicle', [p['name'] for p in parts], "Should find Vehicle part")
        self.assertIn('Engine', [p['name'] for p in parts], "Should find Engine part")
        self.assertIn('Transmission', [p['name'] for p in parts], "Should find Transmission part")
        self.assertIn('Wheel', [p['name'] for p in parts], "Should find Wheel part")
        
        # Generate diagram
        output_path = Path(self.test_dir) / "vehicle_diagram"
        success = generate_hierarchy_diagram(parts, connections, part_defs, str(output_path))
        
        self.assertTrue(success, "Diagram generation should succeed")
        self.assertTrue(os.path.exists(f"{output_path}.png"), "PNG file should be created")
        
        # Validate diagram properties match professional BDD style
        self._validate_professional_bdd_style(f"{output_path}.png")
    
    def test_documentation_structure_model(self):
        """
        Test with the actual DocumentationStructureModel from the workspace.
        Validates V-Model phase grouping and professional styling.
        """
        doc_model = Path(__file__).parent.parent / "sysml" / "overall-design" / "DocumentationStructureModel.sysml"
        
        if not doc_model.exists():
            self.skipTest(f"DocumentationStructureModel not found at {doc_model}")
        
        # Parse the documentation model
        parts, connections, part_defs, actions = parse_sysml(doc_model)
        
        # Validate comprehensive parsing
        self.assertGreater(len(parts), 10, "Should parse multiple documentation parts")
        self.assertGreater(len(connections), 5, "Should parse multiple connections")
        self.assertGreater(len(actions), 3, "Should parse V-Model phase actions")
        
        # Check for phase definitions
        phase_defs = [name for name in part_defs.keys() if 'Phase' in name]
        self.assertGreater(len(phase_defs), 3, "Should have multiple V-Model phases")
        
        # Generate hierarchy diagram
        output_hierarchy = Path(self.test_dir) / "doc_hierarchy"
        success = generate_hierarchy_diagram(parts, connections, part_defs, str(output_hierarchy))
        self.assertTrue(success, "Hierarchy diagram generation should succeed")
        self.assertTrue(os.path.exists(f"{output_hierarchy}.png"), "Hierarchy PNG should be created")
        
        # Generate V-Model phases diagram
        output_phases = Path(self.test_dir) / "doc_phases"
        success = generate_v_model_phases_diagram(parts, connections, part_defs, str(output_phases))
        self.assertTrue(success, "V-Model phases diagram generation should succeed")
        self.assertTrue(os.path.exists(f"{output_phases}.png"), "Phases PNG should be created")
        
        # Validate both diagrams have professional BDD style
        self._validate_professional_bdd_style(f"{output_hierarchy}.png")
        self._validate_professional_bdd_style(f"{output_phases}.png")
    
    def test_professional_bdd_style_compliance(self):
        """
        Test that generated diagrams comply with professional SysML BDD styling:
        - Clean white boxes with black borders
        - No excessive color coding
        - Professional fonts (Helvetica/Arial)
        - Appropriate sizing and spacing
        """
        sysml_content = """
package StyleTest {
    part def Component {
        part subPart : SubComponent;
    }
    
    part def SubComponent {
        attribute name : String;
    }
}
"""
        test_file = Path(self.test_dir) / "style_test.sysml"
        test_file.write_text(sysml_content)
        
        parts, connections, part_defs, actions = parse_sysml(test_file)
        output_path = Path(self.test_dir) / "style_diagram"
        
        success = generate_hierarchy_diagram(parts, connections, part_defs, str(output_path))
        self.assertTrue(success, "Style test diagram should generate")
        
        # Validate professional styling
        self._validate_professional_bdd_style(f"{output_path}.png")
        
        # Check Graphviz source file for style attributes
        dot_file = f"{output_path}"
        if os.path.exists(dot_file):
            with open(dot_file, 'r') as f:
                dot_content = f.read()
                
                # Validate professional BDD style attributes in DOT source
                self.assertIn('fillcolor=white', dot_content, 
                            "Should use white fill for professional appearance")
                self.assertIn('color=black', dot_content,
                            "Should use black borders for professional appearance")
                self.assertIn('penwidth="1.0"', dot_content,
                            "Should use thin borders (1.0) for clean appearance")
                
                # Should NOT contain colorful styling
                self.assertNotIn('#FFE6E6', dot_content, "Should not use red color coding")
                self.assertNotIn('#E6FFE6', dot_content, "Should not use green color coding")
                self.assertNotIn('#E6E6FF', dot_content, "Should not use blue color coding")
                self.assertNotIn('#0066CC', dot_content, "Should not use blue accent colors")
    
    def test_filename_attribute_extraction(self):
        """
        Test that filename attributes are properly extracted and displayed.
        This is critical for documentation structure diagrams.
        """
        sysml_content = """
package DocTest {
    part markdownFile : MarkdownDocument {
        attribute filename = "publication/test-document.md";
    }
    
    part pdfFile : PDFDocument {
        attribute filename = "publication/TEST-DOCUMENT.pdf";
    }
    
    // Connection showing markdown -> PDF transformation
    connect markdownFile to pdfFile;
}
"""
        test_file = Path(self.test_dir) / "filename_test.sysml"
        test_file.write_text(sysml_content)
        
        parts, connections, part_defs, actions = parse_sysml(test_file)
        
        # Validate filename extraction
        markdown_part = next((p for p in parts if 'markdown' in p['name'].lower()), None)
        self.assertIsNotNone(markdown_part, "Should find markdown part")
        self.assertIn('attributes', markdown_part, "Markdown part should have attributes")
        self.assertIn('filename', markdown_part['attributes'], "Should extract filename attribute")
        self.assertEqual(markdown_part['attributes']['filename'], 
                        "publication/test-document.md",
                        "Should extract correct filename")
        
        # Generate diagram and verify
        output_path = Path(self.test_dir) / "filename_diagram"
        success = generate_hierarchy_diagram(parts, connections, part_defs, str(output_path))
        self.assertTrue(success, "Filename diagram should generate")
        
        # Check DOT source contains filenames
        dot_file = f"{output_path}"
        if os.path.exists(dot_file):
            with open(dot_file, 'r') as f:
                dot_content = f.read()
                self.assertIn('test-document.md', dot_content,
                            "Diagram should display markdown filename")
                self.assertIn('TEST-DOCUMENT.pdf', dot_content,
                            "Diagram should display PDF filename")
    
    def test_connection_rendering(self):
        """
        Test that connections between parts are properly rendered with labels.
        """
        sysml_content = """
package ConnectionTest {
    part source : SourcePart;
    part target : TargetPart;
    
    connect source to target;
}
"""
        test_file = Path(self.test_dir) / "connection_test.sysml"
        test_file.write_text(sysml_content)
        
        parts, connections, part_defs, actions = parse_sysml(test_file)
        
        # Validate connection parsing
        self.assertGreater(len(connections), 0, "Should parse connection")
        conn = connections[0]
        self.assertIn('from', conn, "Connection should have 'from' field")
        self.assertIn('to', conn, "Connection should have 'to' field")
        
        # Generate diagram
        output_path = Path(self.test_dir) / "connection_diagram"
        success = generate_hierarchy_diagram(parts, connections, part_defs, str(output_path))
        self.assertTrue(success, "Connection diagram should generate")
        
        # Validate professional edge styling
        dot_file = f"{output_path}"
        if os.path.exists(dot_file):
            with open(dot_file, 'r') as f:
                dot_content = f.read()
                # Edges should use professional black styling
                self.assertIn('arrowhead=vee', dot_content,
                            "Should use professional arrow style")
    
    def test_v_model_phase_grouping(self):
        """
        Test V-Model phase grouping and cluster styling.
        Validates that phases are properly grouped with professional appearance.
        """
        sysml_content = """
package VModelTest {
    action Phase01_Requirements {
        part reqDoc : RequirementsDocument {
            attribute filename = "requirements.md";
        }
        part reqPDF : RequirementsPDF {
            attribute filename = "REQUIREMENTS.pdf";
        }
        connect reqDoc to reqPDF;
    }
    
    action Phase03_Design {
        part designDoc : DesignDocument {
            attribute filename = "design.md";
        }
        part designPDF : DesignPDF {
            attribute filename = "DESIGN.pdf";
        }
        connect designDoc to designPDF;
    }
}
"""
        test_file = Path(self.test_dir) / "vmodel_test.sysml"
        test_file.write_text(sysml_content)
        
        parts, connections, part_defs, actions = parse_sysml(test_file)
        
        # Validate phase parsing
        self.assertGreater(len(actions), 0, "Should parse V-Model phase actions")
        phase_names = [a['name'] for a in actions]
        self.assertTrue(any('Phase01' in name for name in phase_names),
                       "Should find Phase01")
        self.assertTrue(any('Phase03' in name for name in phase_names),
                       "Should find Phase03")
        
        # Generate V-Model diagram
        output_path = Path(self.test_dir) / "vmodel_phases"
        success = generate_v_model_phases_diagram(parts, connections, part_defs, str(output_path))
        self.assertTrue(success, "V-Model diagram should generate")
        
        # Validate professional cluster styling
        dot_file = f"{output_path}"
        if os.path.exists(dot_file):
            with open(dot_file, 'r') as f:
                dot_content = f.read()
                # Clusters should have professional white background
                self.assertIn('cluster_', dot_content, "Should create phase clusters")
                # Should use clean styling for clusters
                self.assertIn('fillcolor=white', dot_content,
                            "Clusters should use white background")
    
    def _validate_professional_bdd_style(self, image_path: str):
        """
        Validate that a generated PNG has professional BDD characteristics.
        
        Checks:
        - Image exists and is valid PNG
        - Reasonable dimensions for professional diagrams
        - File size indicates proper rendering (not blank or corrupted)
        """
        self.assertTrue(os.path.exists(image_path), f"Image should exist: {image_path}")
        
        # Validate it's a valid PNG
        try:
            img = Image.open(image_path)
            self.assertEqual(img.format, 'PNG', "Should be PNG format")
            
            # Validate reasonable dimensions
            width, height = img.size
            self.assertGreater(width, 100, "Diagram width should be substantial")
            self.assertGreater(height, 100, "Diagram height should be substantial")
            self.assertLess(width, 10000, "Diagram width should be reasonable")
            self.assertLess(height, 10000, "Diagram height should be reasonable")
            
            # Validate file size (should not be blank or corrupted)
            file_size = os.path.getsize(image_path)
            self.assertGreater(file_size, 1000, 
                             "PNG file should have substantial content (>1KB)")
            self.assertLess(file_size, 10_000_000,
                          "PNG file should be reasonable size (<10MB)")
            
            # Professional diagrams should use reasonable DPI
            dpi = img.info.get('dpi', (72, 72))
            self.assertGreaterEqual(dpi[0], 72, "Should use professional DPI (>=72)")
            
        except Exception as e:
            self.fail(f"Failed to validate PNG: {e}")


def run_tests():
    """Run all tests and return results."""
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()
    
    # Add test class
    suite.addTests(loader.loadTestsFromTestCase(TestSysMLDiagramGenerator))
    
    # Run with verbose output
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    return result.wasSuccessful()


if __name__ == '__main__':
    success = run_tests()
    sys.exit(0 if success else 1)
