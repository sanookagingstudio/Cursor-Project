Write-Host "=== VALIDATE SUPABASE (STUB) ==="
$supUrl = (Get-Item "env:SUPABASE_URL" -ErrorAction SilentlyContinue).Value
$supAnon = (Get-Item "env:SUPABASE_ANON_KEY" -ErrorAction SilentlyContinue).Value
if (-not $supUrl -or -not $supAnon) {
  Write-Host "Supabase ENV missing"
} else {
  Write-Host "Supabase ENV detected, add real validation logic here."
}
