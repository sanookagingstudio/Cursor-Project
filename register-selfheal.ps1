$taskName = "FunagingClubSelfHeal"
$scriptPath = "D:\SanookAgingStudio\shadow project\sanook-master-v2-main\selfheal.ps1"

Write-Host "Registering self-healing scheduled task..." -ForegroundColor Cyan

# Remove existing task if it exists
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Write-Host "Removing existing task..." -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
}

# Use batch file wrapper to avoid path escaping issues
$batchPath = "D:\SanookAgingStudio\shadow project\sanook-master-v2-main\run-selfheal.bat"

# Create the batch file wrapper if it doesn't exist
if (!(Test-Path $batchPath)) {
    $batchContent = "@echo off`npowershell.exe -ExecutionPolicy Bypass -File `"$scriptPath`""
    Set-Content -Path $batchPath -Value $batchContent
    Write-Host "Created batch file wrapper: $batchPath" -ForegroundColor Gray
}

# Create the task using the batch file (simpler path handling)
$commandToRun = "`"$batchPath`""

# Build schtasks command
$schtasksCmd = "schtasks /Create /TN `"$taskName`" /SC MINUTE /MO 5 /TR $commandToRun /F"

Write-Host "Executing: $schtasksCmd" -ForegroundColor Gray

try {
    $output = cmd.exe /c $schtasksCmd 2>&1
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -eq 0) {
        Write-Host "SUCCESS: Scheduled task '$taskName' created!" -ForegroundColor Green
        Write-Host "The task will run every 5 minutes." -ForegroundColor Cyan
        
        # Verify the task
        Start-Sleep -Seconds 1
        try {
            $task = Get-ScheduledTask -TaskName $taskName -ErrorAction Stop
            Write-Host "Task verified in Task Scheduler (State: $($task.State))" -ForegroundColor Green
        } catch {
            Write-Host "Note: Task created but verification unavailable" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Failed to create task. Exit code: $exitCode" -ForegroundColor Red
        Write-Host "Output: $output" -ForegroundColor Red
        Write-Host "You may need to run PowerShell as Administrator." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
}
