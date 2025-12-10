import os
import json
import subprocess
from pathlib import Path


def check_and_repair():
    """Self-healing engine - repairs system automatically on backend startup"""
    root = Path(__file__).resolve().parent.parent.parent  # project root
    
    # Ensure versions directory exists
    versions_dir = root / "versions"
    versions_dir.mkdir(exist_ok=True)
    
    # Create meta.json if missing
    meta_file = versions_dir / "meta.json"
    if not meta_file.exists():
        with open(meta_file, "w", encoding="utf-8") as f:
            json.dump({"currentVersion": "v1"}, f, indent=2)
    
    # Create v1.json if missing
    v1_file = versions_dir / "v1.json"
    if not v1_file.exists():
        with open(v1_file, "w", encoding="utf-8") as f:
            json.dump({
                "version": "v1",
                "description": "SAS v1 Master Baseline for FunAging.club",
                "timestamp": "baseline"
            }, f, indent=2)
    
    # Ensure required PowerShell scripts exist
    required_scripts = [
        "new-version.ps1",
        "show-versions.ps1",
        "restore-prev-version.ps1"
    ]
    
    for script in required_scripts:
        script_path = root / script
        if not script_path.exists():
            # Try to restore from git if available
            try:
                subprocess.run(
                    ["git", "checkout", "v1", "--", script],
                    cwd=root,
                    check=False,
                    capture_output=True
                )
            except Exception:
                pass  # Ignore if git restore fails





