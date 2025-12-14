#!/bin/bash
# ADMIN ONE PACK - Run Script (Bash)
# Starts both backend and frontend with environment variables from admin_env.json

set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$ROOT/.." && pwd)"
BACK="$PROJECT_ROOT/backend"
FRONT="$PROJECT_ROOT"
ENV="$ROOT/admin_env.json"

echo "🚀 ADMIN ONE PACK - Starting Services..."
echo ""

# Check if env file exists
if [ ! -f "$ENV" ]; then
    echo "❌ Error: admin_env.json not found at $ENV"
    exit 1
fi

# Load environment variables from JSON
echo "📋 Loading environment variables from admin_env.json..."

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "⚠️  jq not found. Installing jq..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install jq
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install -y jq
    else
        echo "❌ Please install jq manually: https://stedolan.github.io/jq/download/"
        exit 1
    fi
fi

# Export environment variables
while IFS='=' read -r key value; do
    if [[ "$value" != "<PASTE_ANON_KEY_HERE>" ]]; then
        export "$key=$value"
        echo "   ✅ $key = ${value:0:50}..."
    else
        echo "   ⚠️  $key = [NOT SET - Please update admin_env.json]"
    fi
done < <(jq -r "to_entries|map(\"\(.key)=\(.value)\")|.[]" "$ENV")

echo ""

# Start Backend
echo "🔧 Starting Backend (FastAPI)..."
cd "$BACK"

if [ ! -f "requirements.txt" ]; then
    echo "❌ Error: backend/requirements.txt not found"
    exit 1
fi

echo "   Installing Python dependencies..."
pip install -q -r requirements.txt

echo "   Starting uvicorn server on port 8000..."
nohup uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload > /tmp/backend.log 2>&1 &
BACKEND_PID=$!

sleep 2

# Start Frontend
echo "🎨 Starting Frontend (Vite React)..."
cd "$FRONT"

if [ ! -f "package.json" ]; then
    echo "❌ Error: package.json not found"
    exit 1
fi

echo "   Installing Node dependencies..."
npm install --silent

echo "   Starting Vite dev server on port 8080..."
echo ""
echo "✅ Services starting..."
echo ""
echo "📝 Access URLs:"
echo "   Frontend: http://localhost:8080"
echo "   Backend API: http://localhost:8000"
echo "   API Docs: http://localhost:8000/docs"
echo ""
echo "Backend PID: $BACKEND_PID"
echo "Press Ctrl+C to stop all services"

# Trap to kill backend on exit
trap "kill $BACKEND_PID 2>/dev/null || true" EXIT

# Run frontend in current process
npm run dev



















