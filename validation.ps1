$ErrorActionPreference = "Stop"



Write-Host "=== ONEPACK AZ VALIDATION START ===`n"



$onepackPath = Join-Path (Get-Location) "mega_onepack_AZ.ps1"



if (-not (Test-Path $onepackPath)) {

    Write-Host "❌ mega_onepack_AZ.ps1 not found in current directory."

    exit

}



Write-Host "1) Checking PowerShell syntax..."

try {

    $nullAst = $null

    $nullTokens = $null

    [System.Management.Automation.Language.Parser]::ParseFile(

        $onepackPath,

        [ref]$nullTokens,

        [ref]$nullAst

    ) | Out-Null

    Write-Host "   ✅ Syntax OK"

} catch {

    Write-Host "   ❌ Syntax error in mega_onepack_AZ.ps1:"

    Write-Host "      $($_.Exception.Message)"

    exit

}



Write-Host "`n2) Clearing old logs..."

Remove-Item "mega_onepack_AZ.log" -ErrorAction SilentlyContinue

Remove-Item "mega_onepack_AZ_summary.txt" -ErrorAction SilentlyContinue

Write-Host "   ✅ Old logs removed"



Write-Host "`n3) Executing ONEPACK..."

try {

    pwsh -ExecutionPolicy Bypass -File $onepackPath

    Write-Host "   ✅ ONEPACK executed"

} catch {

    Write-Host "   ❌ ONEPACK execution error:"

    Write-Host "      $($_.Exception.Message)"

    exit

}



Write-Host "`n4) Checking generated log files..."

$log = "mega_onepack_AZ.log"

$sum = "mega_onepack_AZ_summary.txt"



if (Test-Path $log) { Write-Host "   ✅ Log exists" } else { Write-Host "   ❌ Log missing" }

if (Test-Path $sum) { Write-Host "   ✅ Summary exists" } else { Write-Host "   ❌ Summary missing"; exit }



Write-Host "`n5) Phase Status:"

$lines = Get-Content $sum

$phaseLines = $lines | Where-Object { $_ -like " - PHASE*" }

if ($phaseLines) {

    foreach ($l in $phaseLines) { Write-Host "   $l" }

} else {

    Write-Host "   ❌ No PHASE lines found in summary."

}



Write-Host "`n6) Log tail (last 30 lines):"

if (Test-Path $log) {

    Get-Content $log -Tail 30 | ForEach-Object { Write-Host "   $_" }

}



Write-Host "`n=== ONEPACK AZ VALIDATION END ==="
