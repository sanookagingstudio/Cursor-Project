import os
import json
import subprocess
import shutil
from pathlib import Path

try:
    from supabase import create_client
    SUPABASE_AVAILABLE = True
except ImportError:
    SUPABASE_AVAILABLE = False

REPORT = {
    "versions": {},
    "scripts": {},
    "backend": {},
    "supabase": {},
    "git": {},
    "final_status": "UNKNOWN"
}


def safe(cmd):
    """Safely execute shell command and return output"""
    try:
        return subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT).decode()
    except Exception:
        return ""


def check_file(path):
    """Check if file exists"""
    return os.path.exists(path)


def repair_file(target_path, content):
    """Create or repair a file with given content"""
    folder = os.path.dirname(target_path)
    if folder and not os.path.exists(folder):
        os.makedirs(folder, exist_ok=True)
    with open(target_path, "w", encoding="utf-8") as f:
        f.write(content)


# 1) ตรวจระบบ versions/
def check_versions():
    REPORT["versions"]["meta.json"] = check_file("versions/meta.json")
    REPORT["versions"]["v1.json"] = check_file("versions/v1.json")

    if not REPORT["versions"]["meta.json"]:
        repair_file("versions/meta.json", json.dumps({"currentVersion": "v1"}, indent=2))

    if not REPORT["versions"]["v1.json"]:
        repair_file("versions/v1.json", json.dumps({
            "version": "v1",
            "description": "baseline"
        }, indent=2))


# 2) ตรวจ scripts
def check_scripts():
    req = ["new-version.ps1", "show-versions.ps1", "restore-prev-version.ps1"]
    for s in req:
        exists = check_file(s)
        REPORT["scripts"][s] = exists
        # ถ้าไฟล์หาย → เขียนสคริปต์ restored แบบ minimal
        if not exists:
            restore_map = {
                "new-version.ps1": "param([string]$msg)\nWrite-Host 'new version placeholder'",
                "show-versions.ps1": "Write-Host 'show versions placeholder'",
                "restore-prev-version.ps1": "Write-Host 'restore version placeholder'"
            }
            repair_file(s, restore_map[s])


# 3) ตรวจ backend รากฐาน
def check_backend():
    files = [
        "backend/app/main.py",
        "backend/app/self_heal.py",
        "backend/app/roles_auto.py"
    ]
    for f in files:
        REPORT["backend"][f] = check_file(f)


# 4) ตรวจ git baseline
def check_git():
    tags = safe("git tag")
    REPORT["git"]["tags"] = tags.strip()
    REPORT["git"]["has_v1"] = "v1" in tags


# 5) ตรวจ supabase การสร้าง role (ถ้า env ไม่ครบ → ข้าม)
def check_supabase():
    url = os.getenv("SUPABASE_URL")
    service_role = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

    if not url or not service_role:
        REPORT["supabase"]["status"] = "missing_env"
        return

    if not SUPABASE_AVAILABLE:
        REPORT["supabase"]["status"] = "supabase_not_installed"
        return

    try:
        client = create_client(url, service_role)
        users = client.auth.admin.list_users().users
        REPORT["supabase"]["users_count"] = len(users)
        REPORT["supabase"]["status"] = "connected"
    except Exception as e:
        REPORT["supabase"]["status"] = f"connection_error: {str(e)}"


# 6) รวบรวมผล
def run_diagnostic():
    """Run full diagnostic and return report"""
    # Get project root (assuming diagnostic_engine.py is in backend/app/)
    root = Path(__file__).resolve().parent.parent.parent
    os.chdir(root)
    
    check_versions()
    check_scripts()
    check_backend()
    check_git()
    check_supabase()
    
    # Determine final status
    all_ok = (
        REPORT["versions"].get("meta.json", False) and
        REPORT["versions"].get("v1.json", False) and
        all(REPORT["scripts"].values()) and
        all(REPORT["backend"].values())
    )
    
    REPORT["final_status"] = "OK" if all_ok else "NEEDS_REPAIR"
    return REPORT

















