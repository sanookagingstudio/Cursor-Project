Param()

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$envFile = Join-Path $root "admin_env.json"
$backend = Join-Path $root "..\backend"
$frontend = Join-Path $root "..\frontend"

$env = Get-Content $envFile | ConvertFrom-Json
foreach ($i in $env.PSObject.Properties) {
  Set-Item -Path "env:\$($i.Name)" -Value "$($i.Value)"
}

Set-Location $backend
pip install -r requirements.txt | Out-Null
Start-Process powershell "-Command uvicorn app.main:app --host 0.0.0.0 --port 8000"

Set-Location $frontend
npm install | Out-Null
npm run dev
