#!/usr/bin/env python3
import sys
from pathlib import Path

def load_ignore_file(root):
    """Load ignore patterns from .encodingcheckignore file."""
    ignore_file = Path(root) / ".encodingcheckignore"
    if ignore_file.exists():
        with open(ignore_file, "r", encoding="utf-8") as f:
            lines = [
                line.strip()
                for line in f
                if line.strip() and not line.strip().startswith("#")
            ]
        return set(lines)
    return set()

def check_file(path):
    """Check if a file is UTF-8 encoded."""
    try:
        with open(path, "r", encoding="utf-8") as f:
            f.read()
        return True
    except UnicodeDecodeError as e:
        print(f"❌ Encoding error in {path}: {e}")
        print("   Please re-save this file as UTF-8 (without BOM).")
        return False
    except Exception:
        # Skip binary/unreadable files silently
        return True

def main(root):
    ignore_dirs = load_ignore_file(root)
    if not ignore_dirs:
        print("⚠️  Warning: .encodingcheckignore not found or is empty.")
        print("   Please create .encodingcheckignore with patterns to ignore.")
        return

    bad = []
    for p in Path(root).rglob("*"):
        if p.is_file():
            if any(ig in p.parts for ig in ignore_dirs):
                continue
            ok = check_file(p)
            if not ok:
                bad.append(str(p))

    if bad:
        print(f"\nSummary: {len(bad)} files are not UTF-8.")
        sys.exit(1)
    else:
        print("\n✅ All scanned files are UTF-8 encoded.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: check-encoding.py <root>")
        sys.exit(1)
    main(sys.argv[1])
