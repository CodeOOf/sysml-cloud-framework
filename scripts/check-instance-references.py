#!/usr/bin/env python3
"""
check-instance-references.py

Scan the repository for literal example instance folder references such as
`configs/infrastructure-cluster-a` and `fabrications/fabrication-datacenter-a`.

Usage:
  python scripts/check-instance-references.py                      # prints report, exits 0
  python scripts/check-instance-references.py --fail               # exits non-zero if any matches
  python scripts/check-instance-references.py --scope publication,templates  # limit scanning to these paths

This is a lightweight linter intended to be used in CI to warn or fail when
hard-coded example instance folder names are introduced into source files.
"""
import os
import re
import sys
import argparse
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

PATTERNS = [
    # literal example instance folder names used previously
    r"configs/infrastructure-cluster-[A-Za-z0-9_-]+",
    r"fabrications/fabrication-datacenter-[A-Za-z0-9_-]+",
]

EXCLUDE_DIRS = {".venv", "venv", "node_modules"}


def scan_file(path, regexes):
    matches = []
    try:
        text = path.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return matches
    for i, line in enumerate(text.splitlines(), start=1):
        for rx in regexes:
            if rx.search(line):
                matches.append((i, line.strip()))
    return matches


def walk_roots(roots, regexes):
    findings = {}
    for root in roots:
        if not root.exists():
            continue
        for current_root, dirs, files in os.walk(root):
            # relative path parts from repository root
            try:
                parts = Path(current_root).relative_to(ROOT).parts
            except Exception:
                parts = []
            if any(p in EXCLUDE_DIRS or p == '.git' for p in parts):
                continue
            for f in files:
                if f.endswith(('.png', '.jpg', '.jpeg', '.pyc', '.exe', '.dll', '.class')):
                    continue
                path = Path(current_root) / f
                # skip .git module pointer files
                if path.name == '.git':
                    continue
                rel = path.relative_to(ROOT)
                # skip large generated folders explicitly
                if str(rel).startswith('publication/images'):
                    continue
                matches = scan_file(path, regexes)
                if matches:
                    findings[str(rel)] = matches
    return findings


def main(argv):
    parser = argparse.ArgumentParser(description='Scan repo for example instance folder references')
    parser.add_argument('--fail', action='store_true', help='Exit non-zero if matches found')
    parser.add_argument('--scope', type=str, help='Comma-separated list of repo-relative paths to scan (e.g. publication,templates)')
    args = parser.parse_args(argv)

    regexes = [re.compile(p) for p in PATTERNS]

    if args.scope:
        roots = []
        for part in [s.strip() for s in args.scope.split(',') if s.strip()]:
            roots.append((ROOT / part).resolve())
    else:
        roots = [ROOT]

    findings = walk_roots(roots, regexes)

    if findings:
        print("Hard-coded example instance folder references found:")
        total = 0
        for file, matches in sorted(findings.items()):
            print(f"\nFile: {file}")
            for lineno, line in matches:
                print(f"  {lineno:4d}: {line}")
                total += 1
        print(f"\nTotal occurrences: {total}")
        if args.fail:
            print("\nExiting with non-zero status due to --fail flag.")
            return 2
        return 0

    print("No hard-coded example instance folder references detected.")
    return 0


if __name__ == '__main__':
    rc = main(sys.argv[1:])
    sys.exit(rc)
