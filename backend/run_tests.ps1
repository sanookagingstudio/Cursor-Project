# Phase 1 Testing Script
# Run: .\run_tests.ps1

Write-Host "`n=== Phase 1: Core Foundation - Testing ===" -ForegroundColor Cyan
Write-Host ""

# Check Python
Write-Host "[1/4] Checking Python..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version
    Write-Host "  OK: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: Python not found" -ForegroundColor Red
    exit 1
}

# Check dependencies
Write-Host "[2/4] Checking dependencies..." -ForegroundColor Yellow
try {
    python -c "import fastapi" 2>$null
    Write-Host "  OK: FastAPI installed" -ForegroundColor Green
} catch {
    Write-Host "  WARNING: FastAPI not installed" -ForegroundColor Yellow
    Write-Host "  Run: pip install -r requirements.txt" -ForegroundColor White
}

# Run tests
Write-Host "[3/4] Running tests..." -ForegroundColor Yellow
python test_phase1.py

# Check API server
Write-Host "[4/4] Testing API server..." -ForegroundColor Yellow
Write-Host "  Start server: uvicorn app.main:app --reload" -ForegroundColor White
Write-Host "  Then visit: http://localhost:8000/docs" -ForegroundColor White
Write-Host ""

Write-Host "✅ Testing complete!" -ForegroundColor Green

