# Clear Cache and Rebuild Script
Write-Host "๐งน Clearing cache..." -ForegroundColor Yellow

# Clear Vite cache
if (Test-Path "node_modules\.vite") {
    Remove-Item -Recurse -Force "node_modules\.vite"
    Write-Host "โ… Cleared Vite cache" -ForegroundColor Green
}

# Clear dist
if (Test-Path "dist") {
    Remove-Item -Recurse -Force "dist"
    Write-Host "โ… Cleared dist folder" -ForegroundColor Green
}

Write-Host ""
Write-Host "โ… Cache cleared!" -ForegroundColor Green
Write-Host ""
Write-Host "๐’ก Next steps:" -ForegroundColor Yellow
Write-Host "   1. Restart dev server: npm run dev" -ForegroundColor White
Write-Host "   2. Hard refresh browser: Ctrl + Shift + R" -ForegroundColor White
