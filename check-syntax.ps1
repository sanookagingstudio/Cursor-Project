$content = Get-Content '.\setup-vercel-full-auto.ps1' -Raw
$open = ($content -split '\{').Count - 1
$close = ($content -split '\}').Count - 1
Write-Host "Open braces: $open"
Write-Host "Close braces: $close"
if ($open -eq $close) {
    Write-Host "Braces are balanced"
} else {
    Write-Host "Braces are NOT balanced"
}


