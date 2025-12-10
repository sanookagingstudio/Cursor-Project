$ErrorActionPreference = "Stop"

Write-Host "=== Running FunAging.club FULL DIAGNOSTIC ENGINE ===" -ForegroundColor Cyan

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

# Run diagnostic using Python
$pythonScript = @"
import sys
import os
from pathlib import Path

# Get project root
root = Path(r'$root').resolve()
os.chdir(str(root))

# Add backend/app to Python path
sys.path.insert(0, str(root / 'backend' / 'app'))

# Import and run diagnostic
from diagnostic_engine import run_diagnostic
import json

try:
    report = run_diagnostic()
    print(json.dumps(report, indent=2))
except Exception as e:
    print(json.dumps({"error": str(e), "final_status": "ERROR"}, indent=2))
"@

$report = python -c $pythonScript

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error running diagnostic" -ForegroundColor Red
    exit 1
}

Write-Host "`n==== DIAGNOSTIC REPORT ====" -ForegroundColor Yellow
Write-Host $report

Write-Host "`nDiagnostics Completed." -ForegroundColor Green

