Write-Host "=== FunAging Backend Forensic Scan ===" -ForegroundColor Cyan

Write-Host "`n[1] Current directory:" -ForegroundColor Yellow
Get-Location

Write-Host "`n[2] Git repo root (if any):" -ForegroundColor Yellow
try {
    git rev-parse --show-toplevel
} catch {
    Write-Host "!! Not a git repository in this folder" -ForegroundColor Red
}

Write-Host "`n[3] git remote -v:" -ForegroundColor Yellow
try {
    git remote -v
} catch {
    Write-Host "!! git remote command failed" -ForegroundColor Red
}

Write-Host "`n[4] git status -sb:" -ForegroundColor Yellow
try {
    git status -sb
} catch {
    Write-Host "!! git status command failed" -ForegroundColor Red
}

Write-Host "`n[5] Top-level items in this folder:" -ForegroundColor Yellow
Get-ChildItem -Name

Write-Host "`n[6] backend folder check:" -ForegroundColor Yellow
if (Test-Path "backend") {
    Write-Host "backend/ exists. Listing depth 2..." -ForegroundColor Green
    Get-ChildItem backend -Recurse -Depth 2 | Select-Object FullName
} else {
    Write-Host "!! backend folder NOT found in this directory" -ForegroundColor Red
}

Write-Host "`n[7] docker / compose files:" -ForegroundColor Yellow
Get-ChildItem -Name | Where-Object { $_ -like "docker*" -or $_ -like "compose*" -or $_ -like "*sas*.yml" }

Write-Host "`n[8] package.json / next.config check (frontend hint):" -ForegroundColor Yellow
if (Test-Path "package.json") {
    Write-Host "package.json found in this folder" -ForegroundColor Green
} else {
    Write-Host "package.json NOT found in this folder" -ForegroundColor Red
}

Write-Host "`n=== Forensic scan finished ===" -ForegroundColor Cyan













