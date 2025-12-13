# ================================================
# ONEPACK — SUPABASE AUTH DIAGNOSIS FINAL
# (READ-ONLY AUDIT: NO CODE MODIFICATION)
# Run from REPO ROOT
# ================================================
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function H($t){ Write-Host "`n=== $t ===" -ForegroundColor Cyan }
function OK($t){ Write-Host "[OK]  $t" -ForegroundColor Green }
function WN($t){ Write-Host "[WARN] $t" -ForegroundColor Yellow }
function ER($t){ Write-Host "[ERR] $t" -ForegroundColor Red }

$root = (Get-Location).Path

$frontend = Join-Path $root "frontend"
$backend  = Join-Path $root "backend"

if (!(Test-Path $frontend)) { ER "frontend/ not found. Run from repo root."; exit 2 }
OK "Repo root: $root"
OK "Frontend : $frontend"
if (Test-Path $backend) { OK "Backend  : $backend" } else { WN "backend/ not found (OK if frontend-only)" }

# ------------------------------------------------
# A) FIND SUPABASE CLIENT FILES (DUPLICATES)
# ------------------------------------------------
H "A) Supabase client files (duplicates + content sanity)"
$clientFiles = Get-ChildItem -Path $frontend -Recurse -File -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -match '^supabase\.(ts|js|tsx|jsx)$' -or $_.FullName -match '[\\/](config|lib)[\\/]supabase\.(ts|js|tsx|jsx)$' }

if (!$clientFiles) { WN "No obvious supabase client file found under frontend/"; }
else {
  Write-Host ("Found {0} candidate file(s):" -f $clientFiles.Count)
  $clientFiles | ForEach-Object { Write-Host " - $($_.FullName)" }
}

$clientFindings = @()
foreach ($f in $clientFiles) {
  $txt = Get-Content $f.FullName -Raw -ErrorAction SilentlyContinue
  if (!$txt) { continue }
  $hasCreateClient = $txt -match 'createClient\s*\('
  $usesEnv = $txt -match 'process\.env\.NEXT_PUBLIC_SUPABASE_(URL|ANON_KEY)'
  $usesLiteralDollar = $txt -match '\$SUPABASE_(URL|ANON)'
  $hasHardUrl = $txt -match 'https:\/\/[a-z0-9-]+\.supabase\.co'
  $hasImportSupabase = $txt -match '@supabase\/supabase-js'
  $clientFindings += [pscustomobject]@{
    file=$f.FullName
    importSupabase=$hasImportSupabase
    createClient=$hasCreateClient
    usesEnv=$usesEnv
    usesLiteralDollar=$usesLiteralDollar
    hasHardUrl=$hasHardUrl
  }
}

if ($clientFindings.Count -gt 0) {
  $clientFindings | Format-Table -AutoSize | Out-String | Write-Host
  foreach ($row in $clientFindings) {
    if ($row.createClient -and -not $row.usesEnv) { WN "createClient() but NOT using process.env in: $($row.file)" }
    if ($row.usesLiteralDollar) { ER "Literal `$SUPABASE_* detected (will break URL/key): $($row.file)" }
  }
}

# ------------------------------------------------
# B) IMPORT PATH CONSISTENCY (PROJECT-WIDE)
# ------------------------------------------------
H "B) Import path consistency (supabase references)"
$tsFiles = Get-ChildItem -Path $frontend -Recurse -File -Include *.ts,*.tsx,*.js,*.jsx -ErrorAction SilentlyContinue |
  Where-Object { $_.FullName -notmatch '[\\/]node_modules[\\/]' -and $_.FullName -notmatch '[\\/]\.next[\\/]' }

$importHits = @()
foreach ($f in $tsFiles) {
  $matches = Select-String -Path $f.FullName -Pattern 'from\s+[\'"]([^\'"]*supabase[^\'"]*)[\'"]' -AllMatches -ErrorAction SilentlyContinue
  if ($matches) {
    foreach ($m in $matches.Matches) {
      $importHits += [pscustomobject]@{ file=$f.FullName; import=$m.Groups[1].Value }
    }
  }
}

if ($importHits.Count -eq 0) { WN "No imports containing 'supabase' found in frontend source." }
else {
  Write-Host ("Found {0} import line(s) referencing 'supabase':" -f $importHits.Count)
  $importHits | Group-Object import | Sort-Object Count -Descending | ForEach-Object {
    Write-Host (" - {0}  (x{1})" -f $_.Name, $_.Count)
  }
  Write-Host "`nTop files with supabase imports:"
  $importHits | Select-Object -First 30 | Format-Table -AutoSize | Out-String | Write-Host
}

# Detect conflicting alias patterns
$importsUnique = $importHits | Select-Object -ExpandProperty import -Unique
if ($importsUnique | Where-Object { $_ -match '^@\/config\/supabase' } ) { OK "Uses @/config/supabase" }
if ($importsUnique | Where-Object { $_ -match '^@\/hooks\/' } ) { OK "Uses @/hooks/*" }
if ($importsUnique | Where-Object { $_ -match '^@\/src\/config\/supabase' } ) { WN "Uses @/src/config/supabase (likely WRONG if @/* -> ./src/*)" }
if ($importsUnique | Where-Object { $_ -match '^\.{1,2}\/.*supabase' } ) { WN "Uses relative supabase imports (can be OK, but often mismatched)" }

# Read tsconfig paths
H "B2) tsconfig.json alias check (@/*)"
$tsconfig = Join-Path $frontend "tsconfig.json"
if (!(Test-Path $tsconfig)) { WN "frontend/tsconfig.json not found"; }
else {
  try {
    $json = Get-Content $tsconfig -Raw | ConvertFrom-Json
    $baseUrl = $json.compilerOptions.baseUrl
    $paths = $json.compilerOptions.paths
    Write-Host "baseUrl: $baseUrl"
    if ($paths) {
      ($paths | ConvertTo-Json -Depth 10) | Write-Host
    } else {
      WN "No compilerOptions.paths configured"
    }
  } catch {
    ER "Failed to parse tsconfig.json: $($_.Exception.Message)"
  }
}

# ------------------------------------------------
# C) ENV CHECK (FILES + SANITY)
# ------------------------------------------------
H "C) Env check (.env.local + duplicates + sanity)"
$envCandidates = @(
  Join-Path $root ".env.local",
  Join-Path $root ".env",
  Join-Path $frontend ".env.local",
  Join-Path $frontend ".env",
  Join-Path $frontend ".env.local.backup",
  Join-Path $frontend ".env.production",
  Join-Path $frontend ".env.development"
) | Where-Object { Test-Path $_ }

if ($envCandidates.Count -eq 0) { WN "No env files found in root/ or frontend/"; }
else {
  OK "Env files found:"
  $envCandidates | ForEach-Object { Write-Host " - $_" }
}

function ReadEnvValue($path, $key){
  if (!(Test-Path $path)) { return $null }
  $lines = Get-Content $path -ErrorAction SilentlyContinue
  foreach ($ln in $lines) {
    if ($ln -match "^\s*$key\s*=\s*(.+)\s*$") {
      $v = $Matches[1].Trim()
      $v = $v.Trim('"').Trim("'")
      return $v
    }
  }
  return $null
}

$envFront = Join-Path $frontend ".env.local"
$SUPABASE_URL = ReadEnvValue $envFront "NEXT_PUBLIC_SUPABASE_URL"
$SUPABASE_ANON = ReadEnvValue $envFront "NEXT_PUBLIC_SUPABASE_ANON_KEY"

Write-Host "frontend/.env.local NEXT_PUBLIC_SUPABASE_URL      : " -NoNewline
if ($SUPABASE_URL) { OK $SUPABASE_URL } else { ER "MISSING" }
Write-Host "frontend/.env.local NEXT_PUBLIC_SUPABASE_ANON_KEY : " -NoNewline
if ($SUPABASE_ANON) { OK ("present (len={0})" -f $SUPABASE_ANON.Length) } else { ER "MISSING" }

if ($SUPABASE_URL) {
  if ($SUPABASE_URL -notmatch '^https:\/\/[a-z0-9-]+\.supabase\.co$') { WN "URL format unexpected: $SUPABASE_URL" } else { OK "URL format looks valid" }
}
if ($SUPABASE_ANON) {
  if ($SUPABASE_ANON.Length -lt 50) { ER "ANON key too short (likely wrong field)" }
  if ($SUPABASE_ANON -notmatch '^eyJ') { WN "Key does not start with eyJ (may still work if new publishable format, but legacy anon usually starts eyJ)" } else { OK "Key looks like JWT (legacy anon/service_role style)" }
}

# quick dotenv load check via node (if node available)
H "C2) Node dotenv load check (if node exists)"
try {
  $node = (Get-Command node -ErrorAction Stop).Source
  OK "node: $node"
  $cmd = "require('dotenv').config({path:'frontend/.env.local'}); console.log('URL=',process.env.NEXT_PUBLIC_SUPABASE_URL||''); console.log('ANON_LEN=',(process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY||'').length);"
  node -e $cmd
} catch {
  WN "node not available or dotenv not installed in this context (OK): $($_.Exception.Message)"
}

# ------------------------------------------------
# STEP 1-2) CLIENT/SERVER BOUNDARY + createClient usage
# ------------------------------------------------
H "STEP 1-2) Client/Server boundary + createClient usage"
$createClientHits = @()
foreach ($f in $tsFiles) {
  $raw = Get-Content $f.FullName -Raw -ErrorAction SilentlyContinue
  if (!$raw) { continue }
  if ($raw -match 'createClient\s*\(' -or $raw -match 'supabase\.auth\.' -or $raw -match 'signInWithPassword') {
    $hasUseClient = $raw -match '^[\s\r\n]*[\'"]use client[\'"]\s*;' -or $raw -match '^[\s\r\n]*[\'"]use client[\'"]\s*'
    $isAppDir = $f.FullName -match '[\\/]frontend[\\/]app[\\/]'
    $isApiRoute = $f.FullName -match '[\\/]frontend[\\/]app[\\/]api[\\/]'
    $createClientHits += [pscustomobject]@{
      file=$f.FullName
      appDir=$isAppDir
      apiRoute=$isApiRoute
      useClient=$hasUseClient
      hasCreateClient=($raw -match 'createClient\s*\(')
      hasSignIn=($raw -match 'signInWithPassword')
    }
  }
}
if ($createClientHits.Count -eq 0) { WN "No createClient/auth usage found in source (unexpected)"; }
else {
  $createClientHits | Format-Table -AutoSize | Out-String | Write-Host
  foreach ($r in $createClientHits) {
    if ($r.apiRoute -and $r.hasSignIn) { ER "signInWithPassword used inside app/api route (WRONG CONTEXT): $($r.file)" }
    if ($r.appDir -and -not $r.apiRoute -and $r.hasCreateClient -and -not $r.useClient) { WN "createClient in app/ file WITHOUT 'use client' (SSR boundary risk): $($r.file)" }
  }
}

# ------------------------------------------------
# STEP 3) LOGIN PAGE QUICK INSPECT
# ------------------------------------------------
H "STEP 3) Login page quick inspect"
$login = Join-Path $frontend "app\auth\login\page.tsx"
if (!(Test-Path $login)) { WN "Login page not found at: $login" }
else {
  OK "Found: $login"
  $raw = Get-Content $login -Raw
  $hasUseClient = $raw -match '^[\s\r\n]*[\'"]use client[\'"]'
  if ($hasUseClient) { OK "Login page has 'use client'" } else { ER "Login page missing 'use client' (will break signIn in app router)" }
  if ($raw -match 'signInWithPassword') { OK "Uses signInWithPassword" } else { ER "No signInWithPassword call found" }
  if ($raw -match 'createClient' -or $raw -match 'supabase') { OK "Has supabase usage" } else { ER "No supabase usage detected" }
  Write-Host "`n--- login/page.tsx (first 120 lines) ---"
  (Get-Content $login | Select-Object -First 120) | ForEach-Object { Write-Host $_ }
}

# ------------------------------------------------
# STEP 4) SUPABASE NETWORK TEST (settings endpoint)
# ------------------------------------------------
H "STEP 4) Supabase network test (auth settings endpoint)"
if (!$SUPABASE_URL -or !$SUPABASE_ANON) {
  ER "Missing URL/ANON in frontend/.env.local => cannot test network"
} else {
  $settingsUrl = "$SUPABASE_URL/auth/v1/settings"
  try {
    $r = Invoke-WebRequest -Uri $settingsUrl -Headers @{ apikey = $SUPABASE_ANON } -UseBasicParsing -TimeoutSec 10
    OK "$settingsUrl => $($r.StatusCode)"
  } catch {
    ER "$settingsUrl => FAILED"
    ER $_.Exception.Message
  }
  try {
    $restUrl = "$SUPABASE_URL/rest/v1/"
    $r2 = Invoke-WebRequest -Uri $restUrl -Headers @{ apikey = $SUPABASE_ANON } -UseBasicParsing -TimeoutSec 10
    OK "$restUrl => $($r2.StatusCode)"
  } catch {
    WN "REST root probe failed (may be OK depending on config): $($_.Exception.Message)"
  }
}

# ------------------------------------------------
# SUMMARY: Probable root causes ranking (heuristic)
# ------------------------------------------------
H "SUMMARY (heuristic ranking)"
$score = [ordered]@{
  "Duplicate/mismatched supabase client files" = 0
  "Import path mismatch (@ alias vs physical location)" = 0
  "Env missing/invalid (URL/ANON)" = 0
  "SSR boundary misuse (missing 'use client')" = 0
  "Supabase network blocked/failed (settings endpoint)" = 0
}

if ($clientFiles.Count -gt 1) { $score["Duplicate/mismatched supabase client files"] += 3 }
if ($importsUnique | Where-Object { $_ -match '^@\/src\/config\/supabase' }) { $score["Import path mismatch (@ alias vs physical location)"] += 3 }
if (!$SUPABASE_URL -or !$SUPABASE_ANON) { $score["Env missing/invalid (URL/ANON)"] += 5 }
if ($SUPABASE_URL -and $SUPABASE_URL -notmatch '^https:\/\/[a-z0-9-]+\.supabase\.co$') { $score["Env missing/invalid (URL/ANON)"] += 3 }
if ($SUPABASE_ANON -and $SUPABASE_ANON.Length -lt 50) { $score["Env missing/invalid (URL/ANON)"] += 5 }
if ($createClientHits | Where-Object { $_.appDir -and -not $_.apiRoute -and $_.hasCreateClient -and -not $_.useClient }) { $score["SSR boundary misuse (missing 'use client')"] += 3 }

Write-Host ""
$score.GetEnumerator() | Sort-Object Value -Descending | ForEach-Object {
  "{0} : {1}" -f $_.Key, $_.Value | Write-Host
}

Write-Host "`n=== END REPORT ===`n"
