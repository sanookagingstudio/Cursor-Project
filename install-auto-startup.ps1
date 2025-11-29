# Sanook Master V2 - Install Auto-Startup
# Install Auto-Startup Service

$ErrorActionPreference = "Continue"

# Check Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "Error: Must run as Administrator" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

# Get project root
$scriptPath = $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptPath

Write-Host "Installing Auto-Startup..." -ForegroundColor Cyan
Write-Host "Project Root: $projectRoot" -ForegroundColor Yellow
Write-Host ""

# Check if files exist
if (-not (Test-Path "$projectRoot\start-system.ps1")) {
    Write-Host "Error: start-system.ps1 not found" -ForegroundColor Red
    exit 1
}

# Create service script
$serviceScript = Join-Path $projectRoot "sanook-service.ps1"
$serviceScriptContent = @'
# Sanook Master V2 - Service Script
# Run by Windows Task Scheduler

$ErrorActionPreference = "Continue"
$projectRoot = "{PROJECT_ROOT}"

# Change to project root
Set-Location $projectRoot

# Start system
& ".\start-system.ps1" -SkipFrontend

# Run monitor in background
Start-Process powershell -ArgumentList "-WindowStyle Hidden", "-File", "`"$projectRoot\monitor-system.ps1`"", "-Silent"
'@

# Replace placeholder with actual path
$serviceScriptContent = $serviceScriptContent -replace "{PROJECT_ROOT}", $projectRoot

$serviceScriptContent | Out-File -FilePath $serviceScript -Encoding UTF8 -Force

Write-Host "Created service script: $serviceScript" -ForegroundColor Green
Write-Host ""

# Create Task Scheduler
Write-Host "Creating Task Scheduler..." -ForegroundColor Yellow

$taskName = "SanookMasterV2-AutoStart"
$serviceDescription = "Auto-startup service for Sanook Master V2 system (Backend, Celery, Redis)"

# Remove old task if exists
Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue

# Create new task
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$serviceScript`""
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

try {
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description $serviceDescription
    
    Write-Host "Task Scheduler created: $taskName" -ForegroundColor Green
    Write-Host ""
    Write-Host "Task Info:" -ForegroundColor Cyan
    $task = Get-ScheduledTask -TaskName $taskName
    Write-Host "  Task Name: $($task.TaskName)" -ForegroundColor Gray
    Write-Host "  State: $($task.State)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Task will start automatically on boot" -ForegroundColor Green
    Write-Host ""
    Write-Host "Tips:" -ForegroundColor Yellow
    Write-Host "  - Check status: .\check-auto-startup.ps1" -ForegroundColor Gray
    Write-Host "  - Check system: .\check-system.ps1" -ForegroundColor Gray
    Write-Host "  - View logs: system-monitor.log" -ForegroundColor Gray
    Write-Host "  - Remove task: Unregister-ScheduledTask -TaskName `"$taskName`"" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Installation completed!" -ForegroundColor Green
} catch {
    Write-Host "Error: Cannot create task" -ForegroundColor Red
    Write-Host "  $($_.Exception.Message)" -ForegroundColor Yellow
    exit 1
}
