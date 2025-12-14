#!/usr/bin/env bash
set -e

PORT=${1:-8000}

echo "== SAS Backend – AUTH + RUNNER FULL v2.0 (Unix) =="

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

if [ -d ".venv" ]; then
  echo "Activating .venv..."
  # shellcheck disable=SC1091
  source ".venv/bin/activate"
else
  echo "No .venv found, using global Python..."
fi

export AUTH_ADMIN_EMAIL="${AUTH_ADMIN_EMAIL:-admin@example.com}"
export AUTH_ADMIN_PASSWORD="${AUTH_ADMIN_PASSWORD:-Admin1234!}"
export AUTH_SECRET_KEY="${AUTH_SECRET_KEY:-CHANGE_ME_AUTH_SECRET_KEY}"

echo "[*] Bootstrapping auth (auto-admin + token)..."
python bootstrap_auth.py

echo "[*] Starting backend on port ${PORT} ..."
python -m uvicorn app.main:app --host 0.0.0.0 --port "${PORT}" --reload


















