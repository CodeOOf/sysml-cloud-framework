#!/usr/bin/env python3
"""
Generate separate PDFs:
 - SEMP.pdf (from SEMP.md)
 - System Design PDF (from overall-design pages)
 - Sub-system PDFs (one per subfolder under fabrications/ and configs/)

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
    cmd = [
        "pandoc",
        *md_files,
        "--template=../templates/titlepage.tex",
        "-o", out_pdf,
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

    # 2) System Design (overall-design domain)
    system_pages = [p for p in manifest if p.get("domain") == "overall-design"]
    if system_pages:
        # sort by title
        system_pages = sorted(system_pages, key=lambda x: x.get("title",""))
        md_list = [p["rel"] for p in system_pages]
        run_pandoc(md_list, str(pub / "system-design.pdf"), str(pub))
    else:
        print("ℹ️  No overall-design pages found for System Design PDF")

    # 3) Sub-systems: fabrications and configs
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
        name = key.replace(os.sep, "-")
        out_pdf = pub / f"{name}.pdf"
        run_pandoc(sorted(files), str(out_pdf), str(pub))

    print("✅ All PDFs processed.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: generate-pdfs.py <publication_dir>")
        sys.exit(1)
    main(sys.argv[1])
