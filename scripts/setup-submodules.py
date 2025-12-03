#!/usr/bin/env python3
"""
Dynamic Git Submodule Manager

This script allows folders to be managed as either:
  1. Committed folders in this repo (default/local development)
  2. Git submodules (team/production workflows)

It reads .submodules.config and initializes git submodules for folders
that have repository URLs configured.

Usage:
  python scripts/setup-submodules.py [--init] [--update] [--status]

  --init      Initialize submodules (first-time setup)
  --update    Update submodules to latest commits
  --status    Show status of configured submodules
  --help      Show this message
"""

import sys
import os
import subprocess
import configparser
from pathlib import Path

def read_submodules_config(root):
    """Parse .submodules.config and return list of configured submodules."""
    config_file = Path(root) / ".submodules.config"
    if not config_file.exists():
        print(f"⚠️  Config file not found: {config_file}")
        return []

    config = configparser.ConfigParser()
    config.read(config_file)

    submodules = []
    for section in config.sections():
        if section.startswith("submodule "):
            name = section.replace('submodule "', '').rstrip('"')
            path = config.get(section, "path").strip()
            url = config.get(section, "url").strip()

            if not url:
                print(f"⏭️  Skipping '{name}' (no URL configured)")
                continue

            submodules.append({
                "name": name,
                "path": path,
                "url": url
            })

    return submodules

def run_git_command(cmd, cwd=None):
    """Execute a git command and return success/failure."""
    try:
        result = subprocess.run(
            cmd,
            cwd=cwd,
            capture_output=True,
            text=True,
            shell=True
        )
        return result.returncode == 0, result.stdout, result.stderr
    except Exception as e:
        return False, "", str(e)

def init_submodules(root, submodules):
    """Initialize git submodules."""
    print("\n🔄 Initializing submodules...")
    for sm in submodules:
        path = Path(root) / sm["path"]
        if path.exists() and path.is_dir():
            # Folder already exists locally (committed), skip
            print(f"✅ {sm['path']}: already exists locally (committed)")
            continue

        print(f"📦 Adding {sm['path']} as submodule...")
        cmd = f'git submodule add {sm["url"]} {sm["path"]}'
        success, stdout, stderr = run_git_command(cmd, root)
        if success:
            print(f"✅ {sm['path']}: initialized")
        else:
            print(f"❌ {sm['path']}: {stderr}")

def update_submodules(root):
    """Update all initialized submodules."""
    print("\n🔄 Updating submodules...")
    cmd = "git submodule update --remote --merge"
    success, stdout, stderr = run_git_command(cmd, root)
    if success:
        print("✅ All submodules updated")
    else:
        print(f"❌ Update failed: {stderr}")

def status_submodules(root, submodules):
    """Show status of configured submodules."""
    print("\n📋 Submodule Status:")
    print(f"{'Path':<30} {'Status':<20} {'URL':<50}")
    print("-" * 100)

    for sm in submodules:
        path = Path(root) / sm["path"]
        if path.exists() and path.is_dir():
            # Check if it's a submodule
            git_dir = path / ".git"
            is_submodule = git_dir.is_file() or (
                git_dir.is_dir() and (Path(root) / ".gitmodules").exists()
            )
            status = "submodule" if is_submodule else "committed"
        else:
            status = "missing"

        url_display = sm["url"][:47] + "..." if len(sm["url"]) > 50 else sm["url"]
        print(f"{sm['path']:<30} {status:<20} {url_display:<50}")

def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(0)

    root = Path(__file__).parent.parent

    submodules = read_submodules_config(root)
    if not submodules:
        print("No submodules to configure.")
        sys.exit(0)

    arg = sys.argv[1].lower()

    if arg == "--init":
        init_submodules(root, submodules)
    elif arg == "--update":
        update_submodules(root)
    elif arg == "--status":
        status_submodules(root, submodules)
    elif arg in ("--help", "-h"):
        print(__doc__)
    else:
        print(f"Unknown option: {arg}")
        print(__doc__)
        sys.exit(1)

if __name__ == "__main__":
    main()
