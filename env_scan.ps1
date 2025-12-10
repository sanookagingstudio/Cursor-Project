Write-Host "=== ENV SCAN START ==="



# 1) ค้นหาไฟล์ .env ทั้งหมดในโปรเจกต์

$envFiles = Get-ChildItem -Path . -Filter ".env*" -Recurse



if ($envFiles.Count -eq 0) {

    Write-Host "[ERROR] ไม่พบไฟล์ .env เลย กรุณาวางไฟล์ .env หรือ .env.master"

    exit 1

}



Write-Host "`nพบไฟล์ ENV ดังนี้:"

$envFiles | ForEach-Object { Write-Host " - $($_.FullName)" }



# 2) อ่านค่าตัวแปรที่จำเป็น

$requiredKeys = @(

    "SUPABASE_URL",

    "SUPABASE_ANON_KEY",

    "SUPABASE_SERVICE_ROLE_KEY",

    "DATABASE_URL"

)



$results = @{}



foreach ($file in $envFiles) {

    $lines = Get-Content $file.FullName

    

    foreach ($key in $requiredKeys) {

        $match = $lines | Where-Object { $_ -match "^$key=" }

        if ($match) {

            $value = $match -replace "^$key=", ""

            $masked = if ($value.Length -gt 6) { $value.Substring(0,3) + "*****" + $value.Substring($value.Length-3) } else { $value }

            $results[$key] = @{

                file = $file.FullName

                value = $masked

            }

        }

    }

}



Write-Host "`n=== RESULTS ==="



$missing = @()



foreach ($key in $requiredKeys) {

    if ($results.ContainsKey($key)) {

        Write-Host "[OK] $key : FOUND in $($results[$key].file)"

    } else {

        Write-Host "[MISS] $key : NOT FOUND"

        $missing += $key

    }

}



# 3) สรุปสถานะ

Write-Host "`n=== SUMMARY ==="



if ($missing.Count -eq 0) {

    Write-Host "[SUCCESS] ข้อมูล ENV ครบทั้งหมด — พร้อมสร้าง MEGA ONE PACK"

    exit 0

} else {

    Write-Host "[WARNING] ขาดข้อมูลต่อไปนี้:"

    $missing | ForEach-Object { Write-Host " - $_" }



    Write-Host "`nกรุณา:"

    Write-Host "1) วางไฟล์ .env.master ไว้ในโฟลเดอร์โปรเจกต์"

    Write-Host "2) หรือเพิ่มค่าที่ขาดลงในไฟล์ .env ที่ใช้งาน"

    Write-Host "จากนั้นรันคำสั่งนี้อีกครั้ง"



    exit 1

}



Write-Host "=== ENV SCAN END ==="

