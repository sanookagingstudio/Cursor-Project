import os
from pathlib import Path

from app.auth import ensure_initial_admin_and_token  # type: ignore

if __name__ == "__main__":
    print("== AUTH bootstrap starting ==")
    ensure_initial_admin_and_token()
    base_dir = Path(__file__).resolve().parent / "app"
    token_path = base_dir / "admin_token.txt"
    if token_path.exists():
        print(f"[OK] Admin token saved at: {token_path}")
        print(token_path.read_text()[:80] + "...")
    else:
        print("[WARN] Admin token file not found after bootstrap")
