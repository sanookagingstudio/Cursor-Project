#!/usr/bin/env bash
set -e

echo "== AUTH SELF-TEST (Unix) =="

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

TOKEN_PATH="$ROOT_DIR/app/admin_token.txt"

if [ -f "$TOKEN_PATH" ]; then
  echo "✅ admin_token.txt found. First 60 chars:"
  head -c 60 "$TOKEN_PATH"
  echo ""
else
  echo "❌ admin_token.txt NOT found at $TOKEN_PATH"
fi

echo "[*] Checking /health ..."
if curl -sS "http://localhost:8000/health" ; then
  echo "✅ /health OK"
else
  echo "❌ /health FAILED"
fi

echo "[*] Testing login with default admin..."
LOGIN_JSON='{"email":"admin@example.com","password":"Admin1234!"}'
LOGIN_RESP=$(curl -sS -X POST "http://localhost:8000/auth/login" -H "Content-Type: application/json" -d "$LOGIN_JSON" || echo "")
if echo "$LOGIN_RESP" | grep -q "access_token"; then
  echo "✅ Login successful"
  TOKEN=$(echo "$LOGIN_RESP" | python -c "import sys, json; print(json.load(sys.stdin)['access_token'])")
  echo "Token (first 60): ${TOKEN:0:60}"

  echo "[*] Calling /auth/me ..."
  ME_RESP=$(curl -sS "http://localhost:8000/auth/me" -H "Authorization: Bearer $TOKEN" || echo "")
  echo "✅ /auth/me: $ME_RESP"
else
  echo "❌ Login FAILED: $LOGIN_RESP"
fi






