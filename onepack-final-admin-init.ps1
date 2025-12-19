# ============================================================
# ONE PACK FINAL – SUPABASE ADMIN AUTO INIT (FULL CLEAN BUILD)
# ============================================================

Write-Host "`n=== ONE PACK FINAL START ===" -ForegroundColor Cyan

$targetFiles = @(
    "supabase-admin-init.ps1",
    "supabase-auto-admin-init.ps1",
    "supabase-admin-auto-init.ps1",
    "supabase-admin-onepack.ps1",
    "supabase-admin-final.ps1"
)

Write-Host "[1] Removing old admin init files..." -ForegroundColor Yellow
foreach ($f in $targetFiles) {
    if (Test-Path $f) {
        Remove-Item $f -Force
        Write-Host " - Removed $f" -ForegroundColor DarkGray
    }
}

if (Test-Path "scripts") {
    Remove-Item "scripts" -Recurse -Force
    Write-Host " - Removed old scripts folder" -ForegroundColor DarkGray
}

Write-Host "[2] Creating new scripts folder..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "scripts" | Out-Null

# ============================================================
# CREATE NODE SCRIPT
# ============================================================

$nodeContent = @'
import fetch from "node-fetch";

const url = process.env.SUPABASE_URL;
const serviceKey = process.env.SUPABASE_SERVICE_KEY;
const adminEmail = process.env.ADMIN_EMAIL;
const adminPassword = process.env.ADMIN_PASSWORD;

async function run() {
  try {
    console.log("Checking existing admin user...");

    let res = await fetch(
      url + "/auth/v1/admin/users?email=" + encodeURIComponent(adminEmail),
      {
        headers: {
          apikey: serviceKey,
          Authorization: "Bearer " + serviceKey,
        },
      }
    );

    const data = await res.json();

    if (Array.isArray(data) && data.length > 0) {
      console.log("Admin already exists:", data[0].id);
      return;
    }

    console.log("Creating new admin user...");
    res = await fetch(url + "/auth/v1/admin/users", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        apikey: serviceKey,
        Authorization: "Bearer " + serviceKey,
      },
      body: JSON.stringify({
        email: adminEmail,
        password: adminPassword,
        email_confirm: true,
        user_metadata: { role: "admin" },
        app_metadata: { role: "admin" },
      }),
    });

    const result = await res.json();
    console.log("Result:", result);

  } catch (err) {
    console.error("ERROR:", err);
    process.exit(1);
  }
}

run();
'@

Set-Content -Path "scripts/auto-init-admin.js" -Value $nodeContent -Encoding UTF8 -Force
Write-Host "[3] Node script created." -ForegroundColor Green

# ============================================================
# CREATE POWERSHELL LAUNCHER
# ============================================================

$psContent = @'
Write-Host "== SUPABASE ADMIN INIT ==" -ForegroundColor Cyan

$env:SUPABASE_URL         = "https://klgypptqcegupwtdmuepz.supabase.co"
$env:SUPABASE_SERVICE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtsZ3lwdHFjZWd1cHd0ZG11ZXB6Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MzExNjUzOSwiZXhwIjoyMDc4NjkyNTM5fQ.pQvClFNL6_FpfO_xewpo6qRDiKl8IoVSlu3NOM7ZQ8o"
$env:ADMIN_EMAIL          = "sanookagingstudio@gmail.com"
$env:ADMIN_PASSWORD       = "Ake@8814883"

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Node.js not installed" -ForegroundColor Red
    exit 1
}

Write-Host "Running Supabase Admin Init..." -ForegroundColor Yellow

node scripts/auto-init-admin.js

Write-Host "== DONE ==" -ForegroundColor Green
'@

Set-Content -Path "supabase-admin-final.ps1" -Value $psContent -Encoding UTF8 -Force
Write-Host "[4] PowerShell launcher created." -ForegroundColor Green

# ============================================================
# AUTO RUN
# ============================================================

Write-Host "[5] Running final script..." -ForegroundColor Yellow
powershell -ExecutionPolicy Bypass -File "./supabase-admin-final.ps1"

Write-Host "`n=== ONE PACK FINAL COMPLETE ===" -ForegroundColor Green


























