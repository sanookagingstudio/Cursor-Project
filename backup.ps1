# Quick Backup Script - ใช้งานง่ายขึ้น
# รัน: .\backup.ps1

$message = "Auto backup - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
.\onepack.ps1 -Action backup -Message $message

