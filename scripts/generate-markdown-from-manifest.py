#!/usr/bin/env python3
"""
Generate grouped Markdown files in `publication/` that correspond to the PDFs created
by `scripts/generate-pdfs.py`. Each output file is named with the same base name as
its PDF (including V-Model numeric/abbr prefix) but with `.md` extension.

Usage: python scripts/generate-markdown-from-manifest.py publication
"""
import sys
import os
import json
from pathlib import Path

def prefix_name(filename, phase=None):
    order_map = {
        "ProjectManagement": ("01", "PMP"),
        "StakeholderNeeds": ("02", "SNS"),
        "SystemRequirements": ("03", "SRD"),
        "SystemArchitectureAndDesign": ("04", "SAD"),
        "SubsystemRequirements": ("05", "SSR"),
        "SubsystemDetailedDesign": ("06", "SDD"),
        "Implementation": ("07", "SCI"),
        "Integration": ("08", "ITP"),
        "Verification": ("09", "STP"),
        "Validation": ("10", "SV"),
        "DeploymentAndOM": ("11", "DPL"),
    }
    if not phase:
        return filename
    mapping = order_map.get(phase)
    if not mapping:
        return filename
    num, abbr = mapping
    base, ext = os.path.splitext(filename)
    return f"{num}_{abbr}_{base}{ext}"


def read_manifest(pub_dir):
    manifest_file = Path(pub_dir) / 'manifest.json'
    if not manifest_file.exists():
        print(f"No manifest.json found in {pub_dir}")
        return []
    data = json.loads(manifest_file.read_text(encoding='utf-8'))
    return data


def write_grouped_md(pub_dir, out_name, rel_files):
    out_path = Path(pub_dir) / out_name
    print(f"Writing {out_path} with {len(rel_files)} source files")
    parts = []
    for rel in rel_files:
        src = Path(pub_dir) / rel
        if not src.exists():
            print(f"  Warning: source file not found: {src}")
            continue
        text = src.read_text(encoding='utf-8')
        parts.append(text)
    combined = "\n\n".join(parts)
    out_path.write_text(combined, encoding='utf-8')


def title_name_from_folder(folder_name):
    return ''.join(word.capitalize() for word in folder_name.replace('-', ' ').split())


def main(pub_dir):
    pub = Path(pub_dir)
    if not pub.exists():
        print(f"Publication directory not found: {pub_dir}")
        sys.exit(1)

    manifest = read_manifest(pub_dir)

    # SEMP
    semp = Path(pub.parent) / 'docs' / 'SEMP.md'
    if semp.exists():
        dest = prefix_name('SEMP.md', 'ProjectManagement')
        write_grouped_md(pub_dir, dest, ['SEMP.md'] if (pub / 'SEMP.md').exists() else [str(semp.relative_to(pub))])
    else:
        if (pub / 'SEMP.md').exists():
            dest = prefix_name('SEMP.md', 'ProjectManagement')
            write_grouped_md(pub_dir, dest, ['SEMP.md'])

    # System Design (overall-design)
    system_pages = [p for p in manifest if p.get('domain') == 'overall-design']
    if system_pages:
        system_pages = sorted(system_pages, key=lambda x: x.get('title',''))
        md_list = [p['rel'] for p in system_pages]
        out = prefix_name('SysMLCloudPlatform.md', 'SystemArchitectureAndDesign')
        write_grouped_md(pub_dir, out, md_list)

    # Sub-System Design - Fabrication (datacenter)
    fabrication_pages = [p for p in manifest if p.get('domain') == 'datacenter']
    if fabrication_pages:
        fabrication_pages = sorted(fabrication_pages, key=lambda x: x.get('title',''))
        md_list = [p['rel'] for p in fabrication_pages]
        out = prefix_name('Fabrication.md', 'SystemArchitectureAndDesign')
        write_grouped_md(pub_dir, out, md_list)

    # Sub-System Design - Infrastructure
    infrastructure_pages = [p for p in manifest if p.get('domain') == 'infrastructure']
    if infrastructure_pages:
        infrastructure_pages = sorted(infrastructure_pages, key=lambda x: x.get('title',''))
        md_list = [p['rel'] for p in infrastructure_pages]
        out = prefix_name('Infrastructure.md', 'SystemArchitectureAndDesign')
        write_grouped_md(pub_dir, out, md_list)

    # Requirements PDFs grouped by domain
    req_pages = [p for p in manifest if (
        'requirement' in (p.get('rel') or '').lower()
        or 'requirement' in (p.get('title') or '').lower()
        or 'requirement' in (p.get('source') or '').lower()
    )]
    if req_pages:
        req_groups = {}
        for p in req_pages:
            domain = p.get('domain') or 'other'
            req_groups.setdefault(domain, []).append(p)
        for domain, pages in req_groups.items():
            pages = sorted(pages, key=lambda x: x.get('title',''))
            md_list = [p['rel'] for p in pages]
            if domain == 'overall-design':
                filename = 'SysMLCloudPlatform.md'
            else:
                filename = f"{domain.capitalize()}.md"
            out_pdf = prefix_name(filename, 'SystemRequirements')
            write_grouped_md(pub_dir, out_pdf, md_list)

    # Detailed Design: one MD per top-level subfolder under fabrications/ and configs/
    groups = {}
    for p in manifest:
        src = p.get('source') or ''
        if src.startswith('fabrications') or src.startswith('configs'):
            parts = Path(src).parts
            if len(parts) >= 2:
                key = os.path.join(parts[0], parts[1])
                groups.setdefault(key, []).append(p['rel'])
    for key, files in groups.items():
        parts = key.split(os.sep)
        folder_name = parts[-1] if len(parts) > 1 else key
        title = title_name_from_folder(folder_name)
        filename = f"{title}.md"
        out_pdf = prefix_name(filename, 'SubsystemDetailedDesign')
        write_grouped_md(pub_dir, out_pdf, sorted(files))

    # Done
    print('Grouped markdown generation complete.')

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Usage: generate-markdown-from-manifest.py <publication_dir>')
        sys.exit(1)
    main(sys.argv[1])
