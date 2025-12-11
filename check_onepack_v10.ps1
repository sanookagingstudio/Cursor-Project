Write-Host "=== [1] FILE CHECK: mega_onepack_AZ_v10.ps1 ==="

$path = '.\mega_onepack_AZ_v10.ps1'

if (-not (Test-Path $path)) {
    Write-Host "❌ FILE NOT FOUND: $path"
    exit
}

# Read raw bytes
$raw = Get-Content $path -Raw -Encoding Byte
$txt = [System.Text.Encoding]::UTF8.GetString($raw)

Write-Host "File Size: $([int]$raw.Length) bytes"

# BOM Check
if ($txt.StartsWith([char]0xFEFF)) {
    Write-Host "⚠ BOM FOUND"
} else {
    Write-Host "BOM OK"
}

# Zero-width char check
if ($txt -match '[\u200B\u200C\u200D\u2060]') {
    Write-Host "⚠ ZERO WIDTH CHARS FOUND"
} else {
    Write-Host "ZERO WIDTH OK"
}

# Syntax read check
try {
    Get-Content $path | Out-Null
    Write-Host "Syntax Read: OK"
} catch {
    Write-Host "❌ SYNTAX ERROR"
    Write-Host $_
}

Write-Host "`n=== [2] PROCESS CHECK ==="
Get-Process -Name node,python,uvicorn,vite,next -ErrorAction SilentlyContinue |
Select-Object Name,Id,CPU,StartTime

Write-Host "`n=== [3] RUN ONEPACK DEBUG ==="
try {
    & $path -Verbose -Debug
} catch {
    Write-Host "❌ ERROR WHILE EXECUTING ONEPACK"
    Write-Host $_
}

Write-Host "`n=== [4] LAST 200 LOG LINES ==="
$log = 'mega_onepack_AZ_v10.log'

if (Test-Path $log) {
    Get-Content $log -Tail 200
} else {
    Write-Host "NO LOG FOUND"
}
