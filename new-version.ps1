param(
    [Parameter(Mandatory=\True)]
    [string] \
)

\Stop = "Stop"

Write-Host "=== NEW VERSION START ===" -ForegroundColor Cyan

# ตรวจสถานะ git ต้องไม่มีไฟล์ค้าง
\200 = git status --porcelain
if (-not [string]::IsNullOrWhiteSpace(\200)) {
    Write-Host "พบการเปลี่ยนแปลงที่ยังไม่ได้ commit กรุณา commit ก่อนเรียก new-version.ps1" -ForegroundColor Red
    exit 1
}

# อ่าน meta
\ = ".\versions\meta.json"
\@{currentVersion=0} = Get-Content \ | ConvertFrom-Json
if (-not \@{currentVersion=0}.currentVersion) { \@{currentVersion=0}.currentVersion = 0 }

\ = [int]\@{currentVersion=0}.currentVersion + 1

# อ่าน commit ปัจจุบัน
\ = (git rev-parse HEAD).Trim()

# สร้าง tag ใหม่
\ = "v\"
git tag \ \
git push origin \

# บันทึกไฟล์เวอร์ชัน
\ = [ordered]@{
    version      = \
    tag          = \
    message      = \
    commit       = \
    createdAt    = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
}
\ | ConvertTo-Json | Set-Content -Path ".\versions\v\.json" -Encoding UTF8

# อัปเดต meta
\@{currentVersion=0}.currentVersion = \
\@{currentVersion=0} | ConvertTo-Json | Set-Content -Path \ -Encoding UTF8

Write-Host "สร้างเวอร์ชันใหม่สำเร็จ: v\" -ForegroundColor Green
Write-Host "Tag: \" -ForegroundColor Yellow
Write-Host "Message: \" -ForegroundColor Yellow
Write-Host "=== NEW VERSION END ===" -ForegroundColor Cyan
