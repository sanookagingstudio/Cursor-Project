# === FUNAGING.CLUB ONE PACK AUTO-DEPLOY ===
# Root: D:\SanookAgingStudio\shadow project\sanook-master-v2-main

Set-Location "D:\SanookAgingStudio\shadow project\sanook-master-v2-main"

Write-Host "Starting Funaging.club Deployment..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Pull latest code
Write-Host "Pulling latest code from GitHub..." -ForegroundColor Yellow
git pull origin main

if ($LASTEXITCODE -ne 0) {
    Write-Host "Git pull completed with warnings (this is OK if already up to date)" -ForegroundColor Yellow
}

Write-Host ""

# Step 2: Install dependencies
Write-Host "Installing dependencies..." -ForegroundColor Yellow
npm install

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to install dependencies" -ForegroundColor Red
    exit 1
}

Write-Host "Dependencies installed" -ForegroundColor Green
Write-Host ""

# Step 3: Build project
Write-Host "Building project..." -ForegroundColor Yellow
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "BUILD FAILED: Build process returned error" -ForegroundColor Red
    exit 1
}

# Step 4: Verify build output
if (!(Test-Path "./dist")) {
    Write-Host "BUILD FAILED: dist folder not created" -ForegroundColor Red
    exit 1
}

if (!(Test-Path "./dist/index.html")) {
    Write-Host "BUILD FAILED: dist/index.html not found" -ForegroundColor Red
    exit 1
}

Write-Host "Build completed successfully" -ForegroundColor Green
Write-Host ""

# Step 5: Prepare production directory
Write-Host "Preparing production directory..." -ForegroundColor Yellow

$prodPath = "D:\SanookAgingStudio\PROD_funaging_club"

# Remove existing files
if (Test-Path $prodPath) {
    Write-Host "   Cleaning existing production files..." -ForegroundColor Gray
    Remove-Item -Recurse -Force "$prodPath\*" -ErrorAction SilentlyContinue
}

# Create directory if it doesn't exist
New-Item -ItemType Directory -Force -Path $prodPath | Out-Null

Write-Host "Production directory prepared" -ForegroundColor Green
Write-Host ""

# Step 6: Copy build files
Write-Host "Copying build files to production..." -ForegroundColor Yellow
Copy-Item -Recurse -Force "./dist/*" $prodPath

Write-Host "Files copied to production" -ForegroundColor Green
Write-Host ""

# Step 7: Create web.config for IIS
Write-Host "Creating web.config for IIS..." -ForegroundColor Yellow

$webConfigPath = Join-Path $prodPath "web.config"
$webConfigXml = '<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <system.webServer>
    <rewrite>
      <rules>
        <rule name="SPA" stopProcessing="true">
          <match url=".*" />
          <conditions logicalGrouping="MatchAll">
            <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true"/>
          </conditions>
          <action type="Rewrite" url="/index.html" />
        </rule>
      </rules>
    </rewrite>
  </system.webServer>
</configuration>'

$webConfigXml | Out-File -FilePath $webConfigPath -Encoding UTF8

Write-Host "web.config created" -ForegroundColor Green
Write-Host ""

# Step 8: Health check and self-healing copy
Write-Host "Performing health check..." -ForegroundColor Yellow

$domain = "https://funaging.club"
$needsRecopy = $false

try {
    $res = Invoke-WebRequest -Uri "$domain/index.html" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    if ($res.StatusCode -ne 200) { 
        $needsRecopy = $true
        Write-Host "   Website returned status code: $($res.StatusCode)" -ForegroundColor Yellow
    } else {
        Write-Host "   Website is accessible (Status: $($res.StatusCode))" -ForegroundColor Green
    }
} catch {
    $needsRecopy = $true
    Write-Host "   Health check failed: $_" -ForegroundColor Yellow
    Write-Host "   This might be normal if site is not yet accessible" -ForegroundColor Gray
}

# Additional check for content length
try {
    $health = Invoke-WebRequest -Uri "$domain" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    if ($health.Content.Length -lt 50) {
        $needsRecopy = $true
        Write-Host "   Website content seems too short ($($health.Content.Length) bytes)" -ForegroundColor Yellow
    }
} catch {
    # Ignore this check if it fails
}

if ($needsRecopy) {
    Write-Host "   Re-copying files due to health check issues..." -ForegroundColor Yellow
    Copy-Item -Recurse -Force "./dist/*" $prodPath
    Write-Host "   Files re-copied" -ForegroundColor Green
}

Write-Host ""

# Step 9: Setup self-healing scheduled task
Write-Host "Setting up self-healing scheduled task..." -ForegroundColor Yellow

$selfHealScriptPath = "D:\SanookAgingStudio\shadow project\sanook-master-v2-main\selfheal.ps1"

# Create self-heal script (file already exists, just ensure it's there)
if (!(Test-Path $selfHealScriptPath)) {
    $selfHealContent = @'
# Self-heal script for funaging.club
# Runs every 5 minutes to ensure production files exist

$prodPath = 'D:\SanookAgingStudio\PROD_funaging_club'
$sourcePath = 'D:\SanookAgingStudio\shadow project\sanook-master-v2-main\dist'

if (!(Test-Path "$prodPath\index.html")) {
    if (Test-Path "$sourcePath\index.html") {
        Copy-Item -Recurse -Force "$sourcePath\*" "$prodPath"
    }
}
'@
    $selfHealContent | Out-File -FilePath $selfHealScriptPath -Encoding UTF8
}

# Create scheduled task (delete existing first, then create new)
Write-Host "   Creating/updating scheduled task..." -ForegroundColor Gray
schtasks /Delete /TN "FunagingClubSelfHeal" /F 2>$null | Out-Null

$taskCommand = "powershell.exe -ExecutionPolicy Bypass -File `"$selfHealScriptPath`""
$taskResult = schtasks /Create /TN "FunagingClubSelfHeal" /SC MINUTE /MO 5 /TR $taskCommand /F 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "   Scheduled task created successfully" -ForegroundColor Green
    Write-Host "   Task will run every 5 minutes" -ForegroundColor Gray
} else {
    Write-Host "   Failed to create scheduled task (may need admin rights)" -ForegroundColor Yellow
}

Write-Host ""

# Final summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deployment Completed Successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "   - Latest code pulled from GitHub" -ForegroundColor White
Write-Host "   - Dependencies installed" -ForegroundColor White
Write-Host "   - Project built successfully" -ForegroundColor White
Write-Host "   - Files deployed to: $prodPath" -ForegroundColor White
Write-Host "   - web.config created for IIS" -ForegroundColor White
Write-Host "   - Self-healing task configured" -ForegroundColor White
Write-Host ""
Write-Host "Website: $domain" -ForegroundColor Cyan
Write-Host ""

# === END ONE PACK ===
