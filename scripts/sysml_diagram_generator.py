#!/usr/bin/env python3
"""
SysML v2 Diagram Generator - Graphviz Edition
Parses SysML v2 syntax and generates visual diagrams using Graphviz.

Inspired by: SysML_Python_Visualizer (https://github.com/redasasin4/SysML_Python_Visualizer)
This script provides lightweight, fast diagram generation for SysML v2 models.

FEATURES:
- Parses SysML v2 syntax to extract structure
- Generates 2 diagram types: hierarchy (LR) and V-Model phases (TB)
- Shows filenames and connections in editable docs → generated publications flow
- Fast generation without external dependencies
- Color-coded visualizations (blue=docs, green=markdown, red=PDF)

REFERENCES:
- OMG SysML v2: https://www.omgsysml.org/
- SysML_Python_Visualizer: https://github.com/redasasin4/SysML_Python_Visualizer
- Model: Based on documentation generation V-Model phases
  (01_PMP, 03_SRD, 04_SAD, 06_SDD, 11_DPL)

USAGE:
  python sysml_diagram_generator.py model.sysml output_prefix
"""

import re
import sys
from pathlib import Path
from typing import Dict, List, Tuple, Union
import graphviz

def parse_sysml(sysml_input: Union[str, Path]) -> Tuple[Dict, List, Dict, Dict]:
    """Parse SysML v2 file and extract parts, connections, definitions, actions, requirements, actors, and test cases
    
    Args:
        sysml_input: Either a Path object to a .sysml file, or a string containing SysML content
    
    Returns:
        Tuple of (parts, connections, part_defs, action_defs)
        
    Enhanced to support SysML v2 requirements diagrams:
    - actor: stakeholder (stick figure)
    - requirement: requirement definition (wheat/tan color)
    - test case: verification test (green color)
    """
    # Handle both Path objects and string content
    if isinstance(sysml_input, Path):
        with open(sysml_input, 'r', encoding='utf-8') as f:
            content = f.read()
    else:
        content = sysml_input
    
    # Remove comments
    content = re.sub(r'//.*?$', '', content, flags=re.MULTILINE)
    content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
    
    parts = {}  # part_name -> {name, type, parent, element_kind}
    connections = []  # [{from: (part, port), to: (part, port), rel_type}]
    part_defs = {}  # def_name -> {name, parts: [{name, type, attributes}], attributes}
    action_defs = {}  # action_name -> {name}
    
    # Extract actors (stakeholders - stick figures)
    actor_pattern = r"actor\s+'([^']+)'\s*\{"
    for match in re.finditer(actor_pattern, content):
        actor_name = match.group(1)
        parts[actor_name] = {
            'name': actor_name,
            'type': 'Actor',
            'element_kind': 'actor'  # Mark as actor for special rendering
        }
    
    # Extract requirements (wheat/tan color)
    # Pattern: requirement RequirementName {
    requirement_pattern = r'requirement\s+(\w+)\s*\{'
    for match in re.finditer(requirement_pattern, content):
        req_name = match.group(1)
        parts[req_name] = {
            'name': req_name,
            'type': 'Requirement',
            'element_kind': 'requirement'  # Mark as requirement for wheat coloring
        }
    
    # Extract test cases (green color) with verify relationships
    # Pattern: test case TestCaseName { ... verify RequirementName; }
    testcase_block_pattern = r'test\s+case\s+(\w+)\s*\{([^}]+)\}'
    for match in re.finditer(testcase_block_pattern, content):
        test_name = match.group(1)
        test_body = match.group(2)
        parts[test_name] = {
            'name': test_name,
            'type': 'TestCase',
            'element_kind': 'testcase'  # Mark as test case for green coloring
        }
        
        # Extract verify relationship from test body
        verify_match = re.search(r'verify\s+(\w+);', test_body)
        if verify_match:
            req_name = verify_match.group(1)
            connections.append({
                'from': (test_name, ''),
                'to': (req_name, ''),
                'rel_type': 'verify'
            })
    
    # Extract action definitions
    action_pattern = r'action\s+def\s+(\w+)'
    for match in re.finditer(action_pattern, content):
        action_name = match.group(1)
        action_defs[action_name] = {'name': action_name}
    
    # Helper function to recursively extract nested structure
    def extract_nested_structure(body_text):
        """Extract parts and attributes from a block of text"""
        result_parts = []
        
        # Use a more robust pattern that handles nested braces
        # Match: part name : type { attribute... }
        part_block_pattern = r'part\s+(\w+)\s*:\s*(\w+)\s*\{([^}]*(?:\{[^}]*\}[^}]*)*)\}'
        
        for match in re.finditer(part_block_pattern, body_text):
            part_name = match.group(1)
            part_type = match.group(2)
            part_body = match.group(3)
            
            part_info = {
                'name': part_name,
                'type': part_type,
                'attributes': {}
            }
            
            # Extract filename attribute from this part's body
            attr_pattern = r'attribute\s+filename\s*=\s*["\']([^"\']+)["\']'
            for attr_match in re.finditer(attr_pattern, part_body):
                part_info['attributes']['filename'] = attr_match.group(1)
            
            result_parts.append(part_info)
        
        return result_parts
    
    # Extract part definitions
    partdef_pattern = r'part\s+def\s+(\w+)\s*\{((?:[^{}]|(?:\{(?:[^{}]|(?:\{[^{}]*\}))*\}))*)\}'
    for match in re.finditer(partdef_pattern, content):
        def_name = match.group(1)
        def_body = match.group(2)
        
        # Extract nested parts with their attributes
        nested_parts = extract_nested_structure(def_body)
        
        part_defs[def_name] = {
            'name': def_name,
            'parts': nested_parts,
            'attributes': {}
        }
    
    # Extract top-level part instances
    instance_pattern = r'part\s+(\w+)\s*:\s*(\w+)\s*;'
    for match in re.finditer(instance_pattern, content):
        part_name = match.group(1)
        part_type = match.group(2)
        parts[part_name] = {
            'name': part_name,
            'type': part_type,
            'element_kind': 'part'  # Regular part
        }
    
    # Extract simple connections (for actors and requirements)
    # Pattern: connect 'Actor Name' to RequirementName; or connect ActorName to RequirementName;
    simple_connect_pattern = r"connect\s+(?:'([^']+)'|(\w+))\s+to\s+(\w+);"
    for match in re.finditer(simple_connect_pattern, content):
        from_elem = match.group(1) if match.group(1) else match.group(2)
        to_elem = match.group(3)
        connections.append({
            'from': (from_elem, ''),
            'to': (to_elem, ''),
            'rel_type': 'trace'
        })
    
    # Extract satisfy relationships (requirement satisfies another)
    # Pattern: satisfy RequirementA with RequirementB;
    satisfy_pattern = r'satisfy\s+(\w+)\s+with\s+(\w+);'
    for match in re.finditer(satisfy_pattern, content):
        high_level_req = match.group(1)
        satisfying_req = match.group(2)
        connections.append({
            'from': (satisfying_req, ''),
            'to': (high_level_req, ''),
            'rel_type': 'satisfy'
        })
    
    # Extract connections with port info (for existing parts)
    connect_pattern = r'connect\s+(\w+)\.(\w+)\s+to\s+(\w+)\.(\w+);'
    for match in re.finditer(connect_pattern, content):
        connections.append({
            'from': (match.group(1), match.group(2)),
            'to': (match.group(3), match.group(4)),
            'rel_type': 'connect'
        })
    
    return parts, connections, part_defs, action_defs

def generate_hierarchy_diagram(parts: Dict, connections: List, part_defs: Dict, output_file: str):
    """Generate hierarchical diagram showing part composition"""
    dot = graphviz.Digraph(format='png', engine='dot')
    dot.attr(rankdir='LR', splines='ortho', nodesep='0.5', ranksep='1.2', bgcolor='white', dpi='150')
    dot.attr('node', fontname='Helvetica', fontsize='10', style='filled', shape='box')
    dot.attr('edge', fontname='Helvetica', fontsize='9', color='black', arrowhead='vee')
    
    # Professional SysML BDD style with requirements diagram coloring
    def get_style(element_kind: str):
        """
        Returns style for different element types following SysML v2 conventions:
        - actors: stick figures (not boxes)
        - requirements: light brown/wheat (#F5DEB3) - stakeholder requirements
        - testcases: light green (#90EE90) - verification tests
        - regular elements: white background
        """
        if element_kind == 'actor':
            # Actors are stick figures - use special shape
            return {'fillcolor': 'none', 'color': 'black', 'penwidth': '1.0', 'shape': 'none', 'image': None}
        elif element_kind == 'requirement':
            # Requirements: wheat/tan color (SysML v2 convention for stakeholder requirements)
            return {'fillcolor': '#F5DEB3', 'color': '#8B7355', 'penwidth': '1.5', 'shape': 'box'}
        elif element_kind == 'testcase':
            # Test cases: light green (SysML v2 convention for verification)
            return {'fillcolor': '#90EE90', 'color': '#228B22', 'penwidth': '1.5', 'shape': 'box'}
        else:
            # Default: professional white boxes with black borders
            return {'fillcolor': 'white', 'color': 'black', 'penwidth': '1.0', 'shape': 'box'}
    
    # Draw part definitions as cluster groups
    for def_name, def_info in part_defs.items():
        if def_info['parts']:  # Only if has nested parts
            with dot.subgraph(name=f'cluster_{def_name}') as sub:
                sub.attr(style='filled', fillcolor='white', color='black',
                        label=def_name, fontname='Helvetica', fontsize='11',
                        fontcolor='black', penwidth='1.0')
                
                # Add nested parts inside cluster
                for nested in def_info['parts']:
                    node_id = f"{def_name}_{nested['name']}"
                    element_kind = nested.get('element_kind', 'part')
                    style = get_style(element_kind)
                    
                    if element_kind == 'actor':
                        # Actor: use text-based stick figure representation
                        sub.node(node_id, f"    ◯\n    |\n   /|\\\n   / \\\n\n{nested['name']}", 
                                fontname='Monospace', fontsize='10', **style)
                    else:
                        sub.node(node_id, nested['name'], **style)
    
    # Draw top-level instances (actors, requirements, test cases, parts)
    for part_name, part_info in parts.items():
        element_kind = part_info.get('element_kind', 'part')
        style = get_style(element_kind)
        
        if element_kind == 'actor':
            # Actor: use text-based stick figure
            dot.node(part_name, f"    ◯\n    |\n   /|\\\n   / \\\n\n{part_name}", 
                    fontname='Monospace', fontsize='10', **style)
        elif element_kind == 'requirement':
            # Requirement: add «requirement» stereotype
            dot.node(part_name, f"«requirement»\n{part_name}", **style)
        elif element_kind == 'testcase':
            # Test case: add «testCase» stereotype
            dot.node(part_name, f"«testCase»\n{part_name}", **style)
        else:
            # Regular part
            dot.node(part_name, part_name, **style)
    
    # Draw connections with relationship stereotypes
    for conn in connections:
        from_part, from_port = conn['from']
        to_part, to_port = conn['to']
        rel_type = conn.get('rel_type', 'connect')
        
        # Skip if either element doesn't exist
        if from_part not in parts or to_part not in parts:
            continue
        
        # Style based on relationship type
        if rel_type == 'verify':
            label = "«verify»"
            color = '#228B22'  # Green for verification
            style_attrs = {'style': 'dashed'}
        elif rel_type == 'satisfy':
            label = "«satisfy»"
            color = '#8B7355'  # Brown for satisfaction
            style_attrs = {}
        elif rel_type == 'trace':
            label = "«trace»"
            color = '#666666'  # Gray for traceability
            style_attrs = {'style': 'dashed'}
        elif from_port and to_port:
            label = f"{from_port}→{to_port}"
            color = '#0066CC'
            style_attrs = {}
        else:
            label = ""
            color = '#666666'
            style_attrs = {}
        
        dot.edge(from_part, to_part, label=label, color=color, 
                penwidth='2.0', fontcolor=color, **style_attrs)
    
    try:
        dot.render(output_file, cleanup=False)
        print(f"✅ Hierarchy diagram saved: {output_file}.png")
        return True
    except Exception as e:
        print(f"❌ Error rendering diagram: {e}")
        return False

def generate_v_model_phases_diagram(parts: Dict, connections: List, part_defs: Dict, output_file: str):
    """Generate V-Model phase grouping diagram with filenames and connections"""
    dot = graphviz.Digraph(format='png', engine='dot')
    dot.attr(rankdir='TB', splines='ortho', nodesep='0.8', ranksep='1.2', bgcolor='white', dpi='150')
    dot.attr('node', fontname='Helvetica', fontsize='10', shape='box')
    dot.attr('edge', fontname='Helvetica', fontsize='9', color='black', arrowhead='vee')
    
    # Build a map of parts to their parent phase for connection tracking
    part_to_phase = {}
    part_attributes = {}
    
    # Group phases based on names
    phases = {}
    for def_name in sorted(part_defs.keys()):
        if 'Phase' in def_name:
            # Extract phase info from name like "Phase01_ProjectManagement"
            match = re.search(r'Phase(\d+)_(.+)', def_name)
            if match:
                phase_num = match.group(1)
                phase_desc = match.group(2)
                # Convert camelCase to spaces
                phase_desc_formatted = re.sub(r'([a-z])([A-Z])', r'\1 \2', phase_desc)
                phase_key = f"{phase_num}: {phase_desc_formatted}"
                
                if phase_key not in phases:
                    phases[phase_key] = {'def': def_name, 'parts': []}
                phases[phase_key]['parts'] = part_defs[def_name]['parts']
                
                # Map parts to phase
                for part in part_defs[def_name]['parts']:
                    part_to_phase[part['name']] = phase_key
    
    # Draw phases as ranked groups
    prev_cluster = None
    prev_phase = None
    
    for phase_key in sorted(phases.keys()):
        phase_info = phases[phase_key]
        def_name = phase_info['def']
        nested_parts = phase_info['parts']
        
        cluster_name = f'cluster_{def_name}'
        with dot.subgraph(name=cluster_name) as sub:
            sub.attr(style='filled', fillcolor='white', color='black',
                    label=phase_key, fontname='Helvetica', fontsize='11',
                    fontcolor='black', penwidth='1.0')
            
            # Add parts grouped by type with filenames
            doc_nodes = []
            md_nodes = []
            pdf_nodes = []
            
            for part in nested_parts:
                node_id = f"{def_name}_{part['name']}"
                # Convert part name from camelCase to readable format
                part_label = re.sub(r'([a-z])([A-Z])', r'\1 \2', part['name'])
                
                # Extract filename if available in part attributes
                filename = ""
                if 'attributes' in part and 'filename' in part['attributes']:
                    filename = part['attributes']['filename']
                    # Extract just the filename from path like "publication/system-requirements-definition.md"
                    filename = filename.split('/')[-1]
                
                # Create display label with filename if available
                display_label = f"{part_label}"
                if filename:
                    display_label = f"{part_label}\n({filename})"
                
                # Professional SysML BDD style - all nodes use consistent styling
                if 'EditableDoc' in part['type'] or 'Doc' in part['name']:
                    doc_nodes.append((node_id, display_label))
                elif 'Markdown' in part['type'] or 'Markdown' in part['name']:
                    md_nodes.append((node_id, display_label, filename))
                    part_attributes[node_id] = {'type': 'markdown', 'filename': filename}
                elif 'PDF' in part['type']:
                    pdf_nodes.append((node_id, display_label, filename))
                    part_attributes[node_id] = {'type': 'pdf', 'filename': filename}
                else:
                    doc_nodes.append((node_id, display_label))
                
                # Professional SysML BDD style - white boxes, black borders
                sub.node(node_id, display_label, shape='box', 
                        style='filled', fillcolor='white', 
                        color='black', penwidth='1.0', fontsize='9')
            
            # Internal layout: docs left, markdown middle, pdf right
            doc_node_ids = [n[0] for n in doc_nodes]
            md_node_ids = [n[0] for n in md_nodes]
            pdf_node_ids = [n[0] for n in pdf_nodes]
            
            if doc_node_ids and md_node_ids:
                for doc in doc_node_ids:
                    for md in md_node_ids:
                        sub.edge(doc, md, style='invis')
            
            # Add visible connections from markdown to PDF with labels showing filenames
            if md_node_ids and pdf_node_ids:
                for md_node_id, md_label, md_filename in md_nodes:
                    for pdf_node_id, pdf_label, pdf_filename in pdf_nodes:
                        # Create label showing the connection flow
                        edge_label = ""
                        if md_filename and pdf_filename:
                            edge_label = f"{md_filename}→{pdf_filename}"
                        elif pdf_filename:
                            edge_label = f"→{pdf_filename}"
                        
                        sub.edge(md_node_id, pdf_node_id, label=edge_label,
                                color='black', penwidth='1.0', style='solid',
                                fontcolor='black', fontsize='8')
        
        # Connect phases in sequence
        if prev_phase and phases[prev_phase]['parts']:
            prev_def = phases[prev_phase]['def']
            prev_first_part = f"{prev_def}_{phases[prev_phase]['parts'][0]['name']}"
            curr_first_part = f"{def_name}_{nested_parts[0]['name']}" if nested_parts else None
            if curr_first_part:
                dot.edge(prev_first_part, curr_first_part, style='dotted', color='black', penwidth='1.0')
        
        prev_cluster = cluster_name
        prev_phase = phase_key
    
    try:
        dot.render(output_file, cleanup=False)
        print(f"✅ V-Model phases diagram saved: {output_file}.png")
        return True
    except Exception as e:
        print(f"❌ Error rendering diagram: {e}")
        return False

def main():
    if len(sys.argv) < 2:
        print("Usage: sysml_diagram_generator.py <sysml_file> [output_prefix]")
        sys.exit(1)
    
    sysml_file = Path(sys.argv[1])
    output_prefix = sys.argv[2] if len(sys.argv) > 2 else str(sysml_file.stem)
    
    if not sysml_file.exists():
        print(f"❌ File not found: {sysml_file}")
        sys.exit(1)
    
    print(f"📖 Parsing: {sysml_file}")
    
    parts, connections, part_defs, action_defs = parse_sysml(sysml_file)
    
    print(f"   Found {len(parts)} parts, {len(part_defs)} definitions, {len(connections)} connections, {len(action_defs)} actions")
    
    # Determine if this is a requirements model or regular model
    is_requirements_model = any(
        p.get('element_kind') in ['requirement', 'actor', 'testcase'] 
        for p in parts.values()
    )
    
    # Generate diagrams based on model type
    if is_requirements_model:
        # For requirements models, only generate main hierarchy diagram
        # (phases diagram not applicable)
        print(f"🎨 Generating requirements diagram...")
        generate_hierarchy_diagram(parts, connections, part_defs, output_prefix)
    else:
        # For regular models, generate both hierarchy and phases diagrams
        print(f"🎨 Generating hierarchy diagram...")
        generate_hierarchy_diagram(parts, connections, part_defs, output_prefix + "_hierarchy")
        
        print(f"🎨 Generating V-Model phases diagram...")
        generate_v_model_phases_diagram(parts, connections, part_defs, output_prefix + "_phases")
    
    print("✅ Done!")

if __name__ == '__main__':
    main()
