# Sanook Master V2 - Service Script
# Run by Windows Task Scheduler

$ErrorActionPreference = "Continue"
$projectRoot = "D:\SanookAgingStudio\shadow project\sanook-master-v2-main"

# Change to project root
Set-Location $projectRoot

# Start system
& ".\start-system.ps1" -SkipFrontend

# Run monitor in background
Start-Process powershell -ArgumentList "-WindowStyle Hidden", "-File", "`"$projectRoot\monitor-system.ps1`"", "-Silent"
