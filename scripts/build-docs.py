#!/usr/bin/env python3
import os
import sys
import re
import datetime
from pathlib import Path
import graphviz
import shutil
import json

# ----------------------------------------------------------------------
# Naming and path helpers
# ----------------------------------------------------------------------

def to_kebab(name: str) -> str:
    s = re.sub(r'([a-z0-9])([A-Z])', r'\1-\2', name)
    s = re.sub(r'[\s_]+', '-', s)
    return s.lower()

def classify(sysml_path: str):
    p = Path(sysml_path)
    parts = [x.lower() for x in p.parts]
    # domain from path
    if "overall-design" in parts:
        domain = "overall-design"
    elif "datacenter" in parts:
        domain = "datacenter"
    elif "infrastructure" in parts:
        domain = "infrastructure"
    else:
        domain = "introduction"  # default bucket

    stem = p.stem  # PascalCase
    # view classification by filename semantics
    if "Requirements" in p.stem:
        view = "requirements"
    elif "Interfaces" in p.stem:
        view = "interfaces"
    elif "Model" in p.stem or "Architecture" in p.stem:
        view = "model"
    else:
        view = "model"
    return domain, stem, view

# Map source domain → logical publication section
DOMAIN_TO_PUB = {
    "overall-design": "introduction",
    "datacenter": "datacenter",
    "infrastructure": "infrastructure",
    "introduction": "introduction",
}

def output_paths(domain, stem, publication_dir):
    """
    All images are placed under a single images directory:
        <publication_dir>/images

    Markdown files are written directly into <publication_dir>.
    """
    kebab = to_kebab(stem)
    image_dir = os.path.join(publication_dir, "images")
    os.makedirs(image_dir, exist_ok=True)
    return image_dir, kebab

def write_markdown(out_dir, filename, content):
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, filename)
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"✅ Markdown written to {out_path}")
    return out_path

def collect_sysml_files(root):
    p = Path(root)
    if p.is_file() and p.suffix.lower() == ".sysml":
        return [str(p)]
    if p.is_dir():
        return [str(f) for f in p.rglob("*.sysml")]
    return []

# ----------------------------------------------------------------------
# Lightweight SysML textual parser (extend as needed)
# ----------------------------------------------------------------------

def parse_sysml_text(text):
    blocks = []         # [{id,name,stereotype}]
    relationships = []  # [{from,to,type}]
    requirements = []   # [{id,text}]
    interfaces = []     # [{id,type,connects:[]}]
    seen_ids = set()

    def add_block(_id, name, st):
        if _id not in seen_ids:
            blocks.append({"id": _id, "name": name, "stereotype": st})
            seen_ids.add(_id)

    # definitions
    for m in re.finditer(r"\bpart\s+def\s+([A-Za-z_]\w*)", text):
        n = m.group(1); add_block(n, n, "part")
    for m in re.finditer(r"\bblock\s+def\s+([A-Za-z_]\w*)", text):
        n = m.group(1); add_block(n, n, "block")
    for m in re.finditer(r"\binterface\s+def\s+([A-Za-z_]\w*)", text):
        n = m.group(1); add_block(n, n, "interface"); interfaces.append({"id": n, "type": "interface", "connects": []})
    # parts usage
    for m in re.finditer(r"\bpart\s+([A-Za-z_]\w*)\s*:\s*([A-Za-z_]\w*)", text):
        child, parent = m.group(1), m.group(2)
        add_block(parent, parent, "block")
        add_block(child, child, "part")
        relationships.append({"from": parent, "to": child, "type": "part"})
    # relationships (A -> B : relation)
    for m in re.finditer(r"\b([A-Za-z_]\w*)\s*->\s*([A-Za-z_]\w*)\s*:\s*([A-Za-z_]\w+)", text):
        src, dst, rel = m.group(1), m.group(2), m.group(3)
        add_block(src, src, "block")
        add_block(dst, dst, "block")
        relationships.append({"from": src, "to": dst, "type": rel})
    # requirements blocks with relationships
    for m in re.finditer(r"\brequirement\s+([A-Za-z_]\w*)\s*\{([^}]*)\}", text, re.DOTALL):
        rid, body = m.group(1), m.group(2)
        tmatch = re.search(r'Text\s*=\s*"([^"]*)"', body)
        textval = tmatch.group(1) if tmatch else rid
        requirements.append({"id": rid, "text": textval})
        add_block(rid, textval, "requirement")
        for r in re.finditer(r"\brefines\s*=\s*([A-Za-z_]\w*)", body):
            target = r.group(1); add_block(target, target, "block"); relationships.append({"from": rid, "to": target, "type": "refine"})
        for r in re.finditer(r"\bderives\s*=\s*([A-Za-z_]\w*)", body):
            target = r.group(1); add_block(target, target, "block"); relationships.append({"from": rid, "to": target, "type": "deriveReqt"})
        for r in re.finditer(r"\bverifies\s*=\s*([A-Za-z_]\w*)", body):
            target = r.group(1); add_block(target, target, "block"); relationships.append({"from": rid, "to": target, "type": "verify"})
        for r in re.finditer(r"\bsatisfies\s*=\s*([A-Za-z_]\w*)", body):
            target = r.group(1); add_block(target, target, "block"); relationships.append({"from": rid, "to": target, "type": "satisfy"})
        for r in re.finditer(r"\bcopies\s*=\s*([A-Za-z_]\w*)", body):
            target = r.group(1); add_block(target, target, "requirement"); relationships.append({"from": rid, "to": target, "type": "copy"})
    # interface connections: connect Interface -> Node
    for m in re.finditer(r"\bconnect\s+([A-Za-z_]\w*)\s*->\s*([A-Za-z_]\w*)", text):
        iface, target = m.group(1), m.group(2)
        add_block(target, target, "block")
        if iface not in [i["id"] for i in interfaces]:
            interfaces.append({"id": iface, "type": "interface", "connects": []})
            add_block(iface, iface, "interface")
        relationships.append({"from": iface, "to": target, "type": "connects"})

    return blocks, relationships, requirements, interfaces

def parse_sysml_file(path):
    try:
        with open(path, "r", encoding="utf-8") as f:
            return parse_sysml_text(f.read())
    except UnicodeDecodeError as e:
        print(f"❌ Encoding error in {path}: {e}")
        print("   Please re-save this file as UTF-8 (without BOM).")

# ----------------------------------------------------------------------
# Graphviz rendering (formal BDD-like SVGs)
# ----------------------------------------------------------------------

def stereotype_style(st):
    if st == "requirement":
        return {"shape": "box", "style": "filled", "fillcolor": "#FFF2B3"}
    if st == "interface":
        return {"shape": "ellipse", "style": "filled", "fillcolor": "#E6F0FF"}
    if st == "part":
        return {"shape": "box", "style": "rounded,filled", "fillcolor": "#F5F5F5"}
    return {"shape": "box", "style": "filled", "fillcolor": "#FFFFFF"}

def edge_style(reltype):
    dashed = {"style": "dashed"}
    solid = {"style": "solid"}
    if reltype in ("refine", "deriveReqt", "verify", "satisfy", "copy", "connects"):
        return dashed
    return solid

def make_label(stereotype, name):
    return f"«{stereotype}»\\n{name}"

def render_image(name, blocks, relationships, image_full, rankdir="TB", graph_label=None):
    dot = graphviz.Digraph(name=name, format="png")
    dot.attr(
        rankdir=rankdir,
        fontsize="10",
        labelloc="t",
        label=(graph_label or name),
        pad="0.2",
        nodesep="0.4",
        ranksep="0.6",
    )
    for b in blocks:
        st = b.get("stereotype", "block")
        dot.node(
            b["id"],
            label=make_label(st, b.get("name", b.get("id", "Unnamed"))),
            **stereotype_style(st),
        )
    for e in relationships:
        dot.edge(
            e["from"],
            e["to"],
            label=f"«{e.get('type','relation')}»",
            fontsize="9",
            **edge_style(e.get("type", "")),
        )
    base = os.path.splitext(image_full)[0]
    Path(image_full).parent.mkdir(parents=True, exist_ok=True)
    dot.render(base, cleanup=True)
    print(f"✅ Image saved: {image_full}")
    return image_full

# ----------------------------------------------------------------------
# Markdown page rendering
# ----------------------------------------------------------------------

def render_markdown_page(title, diagrams):
    md = []
    md.append(f"# {title}")
    md.append("")
    md.append(f"Generated: {datetime.date.today().isoformat()}")
    md.append("")
    # diagrams: [(section_title, rel_image_path)]
    for section, rel_path in diagrams:
        md.append(f"## {section}")
        md.append(f"![{section}]({rel_path})")
        md.append("")
    return "\n".join(md)

# ----------------------------------------------------------------------
# Orchestration
# ----------------------------------------------------------------------

def process_sysml_files(sysml_files, publication_dir, repo_root=None):
    pages_by_domain = {"introduction": [], "datacenter": [], "infrastructure": []}

    # We render one page per SysML file; Markdown files go in publication_dir, images in publication_dir/images
    for path in sysml_files:
        domain, stem, view = classify(path)
        image_dir, kebab = output_paths(domain, stem, publication_dir)
        title = stem if domain != "overall-design" else "SysML Cloud Framework"
        diagrams = []

        # Parse file
        parsed = parse_sysml_file(path)
        if not parsed:
            continue
        blocks, rels, reqs, ifaces = parsed

        # Decide which diagram(s) to render for the file
        image_name = f"{kebab}.png"
        image_full = os.path.join(image_dir, image_name)
        rel_image_path = f"images/{image_name}"

        if view == "requirements":
            req_blocks = [
                {"id": r["id"], "name": r["text"], "stereotype": "requirement"}
                for r in reqs
            ]
            req_edges = [e for e in rels if e["from"] in {r["id"] for r in reqs}]
            render_image(
                stem + "_REQ",
                req_blocks + blocks,
                req_edges,
                image_full,
                rankdir="LR",
                graph_label=f"{stem} Requirements",
            )
            diagrams.append(("Requirement diagram", rel_image_path))
        elif view == "interfaces":
            iface_blocks = [
                {"id": i["id"], "name": i["id"], "stereotype": "interface"}
                for i in ifaces
            ]
            iface_edges = [e for e in rels if e.get("type") == "connects"]
            render_image(
                stem + "_IFACE",
                iface_blocks + blocks,
                iface_edges,
                image_full,
                rankdir="LR",
                graph_label=f"{stem} Interfaces",
            )
            diagrams.append(("Interface diagram", rel_image_path))
        else:
            render_image(
                stem + "_BDD",
                blocks + ifaces,
                rels,
                image_full,
                rankdir="TB",
                graph_label=f"{stem} Model",
            )
            diagrams.append(("Block definition diagram", rel_image_path))

        # Write page: all markdown files directly in publication_dir
        page_md = render_markdown_page(
            title if domain != "overall-design" else "Introduction", diagrams
        )
        md_filename = f"{to_kebab(stem)}.md"
        write_markdown(publication_dir, md_filename, page_md)

        bucket = DOMAIN_TO_PUB.get(domain, "introduction")
        pages_by_domain[bucket].append(
            {
                "title": title if domain != "overall-design" else "Introduction",
                "rel": md_filename,
                "source": path,
                "domain": domain,
            }
        )

    # Render index with introduction first
    idx = []
    idx.append("# Publication index")
    idx.append("")
    idx.append(f"Generated: {datetime.date.today().isoformat()}")
    idx.append("")
    if pages_by_domain["introduction"]:
        idx.append("## Introduction")
        for p in pages_by_domain["introduction"]:
            idx.append(f"- [{p['title']}]({p['rel']})")
    # If an SEMP.md exists in the repository root, include it under Introduction
    if repo_root:
        semp_src = Path(repo_root) / "SEMP.md"
        if semp_src.exists():
            semp_dst = Path(publication_dir) / "SEMP.md"
            try:
                shutil.copy2(semp_src, semp_dst)
                # avoid duplicate entries
                if not any(p.get('rel') == 'SEMP.md' for p in pages_by_domain['introduction']):
                    idx.append(f"- [System Engineering Management Plan]({semp_dst.name})")
            except Exception as e:
                print(f"⚠️  Failed to copy SEMP.md into publication: {e}")
    if pages_by_domain["datacenter"]:
        idx.append("\n## Datacenter")
        for p in pages_by_domain["datacenter"]:
            idx.append(f"- [{p['title']}]({p['rel']})")
    if pages_by_domain["infrastructure"]:
        idx.append("\n## Infrastructure")
        for p in pages_by_domain["infrastructure"]:
            idx.append(f"- [{p['title']}]({p['rel']})")

    write_markdown(publication_dir, "index.md", "\n".join(idx))

    # Write manifest for downstream PDF generation and grouping
    manifest = []
    for bucket in pages_by_domain:
        for p in pages_by_domain[bucket]:
            manifest.append({
                "title": p.get("title"),
                "rel": p.get("rel"),
                "source": p.get("source"),
                "domain": p.get("domain", ""),
                "section": bucket,
            })
    try:
        with open(os.path.join(publication_dir, "manifest.json"), "w", encoding="utf-8") as mf:
            json.dump(manifest, mf, indent=2)
        print(f"✅ Manifest written: {os.path.join(publication_dir, 'manifest.json')}")
    except Exception as e:
        print(f"⚠️  Failed to write manifest.json: {e}")

# ----------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: build-docs.py <sysml_root> <publication_dir> <input root or files...>")
        print("Example: scripts/build-docs.py architecture/sysml architecture/publication architecture/sysml")
        sys.exit(1)

    sysml_root = sys.argv[1]
    publication_dir = sys.argv[2]
    inputs = sys.argv[3:]

    # Discover .sysml files across inputs (folders or files)
    all_files = []
    for inp in inputs:
        all_files.extend(collect_sysml_files(inp))
    if not all_files:
        print("❌ No SysML files found.")
        sys.exit(1)

    # Sort for reproducible output (OverallDesign first if present)
    def sort_key(p):
        domain, stem, view = classify(p)
        order = {"overall-design": 0, "datacenter": 1, "infrastructure": 2, "introduction": 3}
        return (order.get(domain, 9), stem.lower(), view)

    all_files = sorted(set(all_files), key=sort_key)

    print(f"-> Rendering {len(all_files)} SysML files from {sysml_root}")
    repo_root = Path(sysml_root).parent
    process_sysml_files(all_files, publication_dir, repo_root=repo_root)
    print("✅ Documentation build complete.")