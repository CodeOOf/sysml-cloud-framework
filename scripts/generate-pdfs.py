#!/usr/bin/env python3
"""
Generate structured PDFs for the repository with V-Model phase prefixes.

Naming Convention:
  Filenames follow the SE V-Model ordering with numeric and abbreviation prefixes:
  - 01_PMP_SEMP.pdf — Project Management Plan (System Engineering Management Plan)
  - 04_SAD_SysMLCloudPlatform.pdf — System Architecture & Design (overall-design domain)
  - 04_SAD_Fabrication.pdf — System Architecture & Design (datacenter subsystem)
  - 04_SAD_Infrastructure.pdf — System Architecture & Design (infrastructure subsystem)
  - 06_SDD_FabricationDatacenterA.pdf — Detailed Design Document (fabrication folder)
  - 03_SRD_SysMLCloudPlatform.pdf — System Requirements Document (by domain)
  
  V-Model phases (01-11):
    01_PMP - Project Management Plan
    02_SNS - Stakeholder Needs Statement
    03_SRD - System Requirements Document
    04_SAD - System Architecture & Design
    05_SSR - System/Subsystem Requirements
    06_SDD - Subsystem/Detailed Design Document
    07_SCI - Software/System Code Implementation
    08_ITP - Integration Test Plan
    09_STP - System Test Plan (Verification)
    10_SV  - System Validation
    11_DPL - Deployment Plan / Operations & Maintenance

Usage: scripts/generate-pdfs.py <publication_dir>
"""
import sys
import os
import subprocess
import json
from pathlib import Path

def run_pandoc(md_files, out_pdf, pub_dir):
    if not md_files:
        print(f"[WARN] No source files for {out_pdf}")
        return False
    # If we're running pandoc with cwd=pub_dir then write output filename only
    out_path = Path(out_pdf)
    out_name = out_path.name if pub_dir and str(out_path).startswith(str(Path(pub_dir))) else str(out_path)
    cmd = [
        "pandoc",
        *md_files,
        "-o", out_name,
        "--from", "markdown",
        "--toc",
        "--pdf-engine=xelatex",
    ]
    print(f"-> Running: {' '.join(cmd)} (cwd={pub_dir})")
    try:
        subprocess.check_call(cmd, cwd=pub_dir)
        print(f"[OK] PDF generated: {out_pdf}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"[ERROR] pandoc failed: {e}")
        return False


def prefix_name(filename, phase=None):
    """Return a filename prefixed with the numeric ordering and abbreviated phase name based on V-Model phase.

    phase: optional V-Model phase key (e.g., 'ProjectManagement', 'SystemRequirements')
    If phase is None, no prefix is added.
    
    Abbreviations follow SE V-Model conventions:
      01_PMP - Project Management Plan
      02_SNS - Stakeholder Needs Statement
      03_SRD - System Requirements Document
      04_SAD - System Architecture & Design
      05_SSR - System/Subsystem Requirements
      06_SDD - Subsystem Detailed Design / Detailed Design Document
      07_SCI - Software/System Code Implementation
      08_ITP - Integration Test Plan / Integration
      09_STP - System Test Plan / Verification
      10_SV  - System Validation
      11_DPL - Deployment Plan / Operations & Maintenance
    """
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
    # Insert prefix before file extension, e.g., "01_PMP_SEMP.pdf"
    base, ext = os.path.splitext(filename)
    return f"{num}_{abbr}_{base}{ext}"


def main(pub_dir):
    pub = Path(pub_dir)
    if not pub.exists():
        print(f"Publication directory not found: {pub_dir}")
        return

    manifest_file = pub / "manifest.json"
    manifest = []
    if manifest_file.exists():
        manifest = json.loads(manifest_file.read_text(encoding="utf-8"))

    # 1) SEMP
    semp_src = Path(pub.parent) / "SEMP.md"
    if semp_src.exists():
        semp_dst = pub / "SEMP.md"
        semp_dst.write_bytes(semp_src.read_bytes())
        out = prefix_name("SEMP.pdf", "ProjectManagement")
        run_pandoc([semp_dst.name], str(pub / out), str(pub))
    else:
        print("[INFO] No SEMP.md found at repo root; skipping SEMP PDF")

    # 2) System Design (overall-design domain) -> SAD_SysMLCloudPlatform.pdf
    system_pages = [p for p in manifest if p.get("domain") == "overall-design"]
    if system_pages:
        # sort by title
        system_pages = sorted(system_pages, key=lambda x: x.get("title",""))
        md_list = [p["rel"] for p in system_pages]
        out = prefix_name("SysMLCloudPlatform.pdf", "SystemArchitectureAndDesign")
        run_pandoc(md_list, str(pub / out), str(pub))
    else:
        print("ℹ️  No overall-design pages found for System Design PDF")

    # 2a) Sub-System Design PDFs
    # Fabrication (datacenter domain) -> SAD_Fabrication.pdf
    fabrication_pages = [p for p in manifest if p.get("domain") == "datacenter"]
    if fabrication_pages:
        fabrication_pages = sorted(fabrication_pages, key=lambda x: x.get("title",""))
        out = prefix_name("Fabrication.pdf", "SystemArchitectureAndDesign")
        run_pandoc([p["rel"] for p in fabrication_pages], str(pub / out), str(pub))
    else:
        print("[INFO] No datacenter (Fabrication) pages found for Fabrication Sub-System PDF")

    # Infrastructure (infrastructure domain) -> SAD_Infrastructure.pdf
    infrastructure_pages = [p for p in manifest if p.get("domain") == "infrastructure"]
    if infrastructure_pages:
        infrastructure_pages = sorted(infrastructure_pages, key=lambda x: x.get("title",""))
        out = prefix_name("Infrastructure.pdf", "SystemArchitectureAndDesign")
        run_pandoc([p["rel"] for p in infrastructure_pages], str(pub / out), str(pub))
    else:
        print("[INFO] No infrastructure pages found for Infrastructure Sub-System PDF")

    # Requirements PDFs: collect pages that are requirements (rel/title/source contains 'requirement')
    req_pages = [p for p in manifest if (
        'requirement' in (p.get('rel') or '').lower()
        or 'requirement' in (p.get('title') or '').lower()
        or 'requirement' in (p.get('source') or '').lower()
    )]
    if req_pages:
        # group requirement pages by domain
        req_groups = {}
        for p in req_pages:
            domain = p.get('domain') or 'other'
            req_groups.setdefault(domain, []).append(p)

        for domain, pages in req_groups.items():
            pages = sorted(pages, key=lambda x: x.get('title',''))
            md_list = [p['rel'] for p in pages]
            if domain == 'overall-design':
                filename = 'SysMLCloudPlatform.pdf'
            else:
                filename = f"{domain.capitalize()}.pdf"
            out_pdf = prefix_name(filename, "SystemRequirements")
            run_pandoc(md_list, str(pub / out_pdf), str(pub))
    else:
        print("[INFO] No requirements pages found to build Requirements PDFs")

    # 3) Detailed Design: one PDF per technical publication folder under fabrications/ and configs/
    # group by top-level subfolder under fabrications/ or configs/
    groups = {}
    for p in manifest:
        src = p.get("source") or ""
        if src.startswith("fabrications") or src.startswith("configs"):
            parts = Path(src).parts
            if len(parts) >= 2:
                key = os.path.join(parts[0], parts[1])
                groups.setdefault(key, []).append(p["rel"])

    for key, files in groups.items():
        # Extract folder name (e.g., "fabrication-datacenter-a" from "fabrications/fabrication-datacenter-a")
        parts = key.split(os.sep)
        folder_name = parts[-1] if len(parts) > 1 else key
        # Convert to title case: fabrication-datacenter-a -> FabricationDatacenterA
        title_name = ''.join(word.capitalize() for word in folder_name.replace('-', ' ').split())
        filename = f"{title_name}.pdf"
        out_pdf = prefix_name(filename, "SubsystemDetailedDesign")
        run_pandoc(sorted(files), str(pub / out_pdf), str(pub))

    # 4) V-Model grouping: produce one PDF per V-Model phase by keyword mapping
    # Mapping based on typical documents supplied by the user.
    vmodel_phases = [
        ("ProjectManagement", ["semp", "pmp", "risk", "config"]),
        ("StakeholderNeeds", ["conops", "strs", "scenarios", "stakeholder"]),
        ("SystemRequirements", ["syrs", "system requirements", "syrs", "requirements", "rtm", "srvm"]),
        ("SystemArchitectureAndDesign", ["sad", "sdd", "icd", "sysml", "architecture", "design", "views"]),
        ("SubsystemRequirements", ["ssrs", "derived requirements", "derived"]),
        ("SubsystemDetailedDesign", ["ssdd", "ddd", "dds", "cds", "detailed design"]),
        ("Implementation", ["code", "build", "implementation", "build records"]),
        ("Integration", ["integration plan", "integration"]),
        ("Verification", ["verification plan", "verification", "test report", "test procedure"]),
        ("Validation", ["validation", "validation plan", "scenario", "validation report"]),
        ("DeploymentAndOM", ["deployment", "manual", "maintenance", "ops", "o&m", "o&m"]),
    ]

    # helper: check if any keyword matches a manifest entry
    def matches_keywords(entry, keywords):
        hay = " ".join([
            (entry.get("rel") or ""),
            (entry.get("title") or ""),
            (entry.get("source") or ""),
            (entry.get("domain") or ""),
            (entry.get("section") or ""),
        ]).lower()
        for kw in keywords:
            if kw in hay:
                return True
        return False

    for phase_name, keywords in vmodel_phases:
        matched = [p for p in manifest if matches_keywords(p, keywords)]
        if matched:
            matched = sorted(matched, key=lambda x: x.get('title',''))
            md_list = [p['rel'] for p in matched]
            out_pdf_name = prefix_name(f"{phase_name}.pdf", phase_name)
            run_pandoc(md_list, str(pub / out_pdf_name), str(pub))
        else:
            print(f"[INFO] No documents found for V-Model phase: {phase_name}")

    print("[OK] All PDFs processed.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: generate-pdfs.py <publication_dir>")
        sys.exit(1)
    main(sys.argv[1])
