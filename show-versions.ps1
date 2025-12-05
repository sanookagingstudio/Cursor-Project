\Stop = "Stop"

Write-Host "=== SHOW VERSIONS ===" -ForegroundColor Cyan

if (-not (Test-Path ".\versions")) {
    Write-Host "ยังไม่มีโฟลเดอร์ versions" -ForegroundColor Red
    exit 1
}

\ = Get-ChildItem ".\versions" -Filter "v*.json" | Sort-Object Name
if (-not \) {
    Write-Host "ยังไม่มีเวอร์ชันที่บันทึกไว้" -ForegroundColor Yellow
    exit 0
}

foreach (\ in \) {
    \ = Get-Content \.FullName | ConvertFrom-Json
    Write-Host ("v{0} | {1} | {2}" -f \.version, \.tag, \.message) -ForegroundColor Green
}
