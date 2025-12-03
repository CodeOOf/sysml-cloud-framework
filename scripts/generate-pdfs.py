#!/usr/bin/env python3
"""
Generate structured PDFs for the repository with clear naming standards.

Naming Convention:
 - SEMP.pdf (from `SEMP.md`) — System Engineering Management Plan
 - SystemDesign_SysMLCloudPlatform.pdf — System-level design from overall-design domain
 - SubSystemDesign_Fabrication.pdf — Datacenter domain (Fabrication subsystem)
 - SubSystemDesign_Infrastructure.pdf — Infrastructure domain (Infrastructure subsystem)
 - DetailedDesign_<FolderName>.pdf — Technical publications (one per folder under fabrications/ and configs/)

Usage: scripts/generate-pdfs.py <publication_dir>
"""
import sys
import os
import subprocess
import json
from pathlib import Path

def run_pandoc(md_files, out_pdf, pub_dir):
    if not md_files:
        print(f"⚠️  No source files for {out_pdf}")
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
        print(f"✅ PDF generated: {out_pdf}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ pandoc failed: {e}")
        return False


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
        run_pandoc([semp_dst.name], str(pub / "SEMP.pdf"), str(pub))
    else:
        print("ℹ️  No SEMP.md found at repo root; skipping SEMP PDF")

    # 2) System Design (overall-design domain) -> SystemDesign_SysMLCloudPlatform.pdf
    system_pages = [p for p in manifest if p.get("domain") == "overall-design"]
    if system_pages:
        # sort by title
        system_pages = sorted(system_pages, key=lambda x: x.get("title",""))
        md_list = [p["rel"] for p in system_pages]
        run_pandoc(md_list, str(pub / "SystemDesign_SysMLCloudPlatform.pdf"), str(pub))
    else:
        print("ℹ️  No overall-design pages found for System Design PDF")

    # 2a) Sub-System Design PDFs
    # Fabrication (datacenter domain) -> SubSystemDesign_Fabrication.pdf
    fabrication_pages = [p for p in manifest if p.get("domain") == "datacenter"]
    if fabrication_pages:
        fabrication_pages = sorted(fabrication_pages, key=lambda x: x.get("title",""))
        run_pandoc([p["rel"] for p in fabrication_pages], str(pub / "SubSystemDesign_Fabrication.pdf"), str(pub))
    else:
        print("ℹ️  No datacenter (Fabrication) pages found for Fabrication Sub-System PDF")

    # Infrastructure (infrastructure domain) -> SubSystemDesign_Infrastructure.pdf
    infrastructure_pages = [p for p in manifest if p.get("domain") == "infrastructure"]
    if infrastructure_pages:
        infrastructure_pages = sorted(infrastructure_pages, key=lambda x: x.get("title",""))
        run_pandoc([p["rel"] for p in infrastructure_pages], str(pub / "SubSystemDesign_Infrastructure.pdf"), str(pub))
    else:
        print("ℹ️  No infrastructure pages found for Infrastructure Sub-System PDF")

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
                out_pdf = pub / 'Requirements_SysMLCloudPlatform.pdf'
            else:
                out_pdf = pub / f"Requirements_{domain.capitalize()}.pdf"
            run_pandoc(md_list, str(out_pdf), str(pub))
    else:
        print("ℹ️  No requirements pages found to build Requirements PDFs")

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
        out_pdf = pub / f"DetailedDesign_{title_name}.pdf"
        run_pandoc(sorted(files), str(out_pdf), str(pub))

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
            out_pdf = pub / f"{phase_name}.pdf"
            run_pandoc(md_list, str(out_pdf), str(pub))
        else:
            print(f"ℹ️  No documents found for V-Model phase: {phase_name}")

    print("✅ All PDFs processed.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: generate-pdfs.py <publication_dir>")
        sys.exit(1)
    main(sys.argv[1])
