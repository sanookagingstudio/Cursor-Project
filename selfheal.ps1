$prodPath = "D:\SanookAgingStudio\PROD_funaging_club"

$distPath = "D:\SanookAgingStudio\shadow project\sanook-master-v2-main\dist"

if (!(Test-Path "$prodPath\index.html")) {
    Copy-Item -Recurse -Force "$distPath\*" "$prodPath"
}

try {
    $res = Invoke-WebRequest -Uri "https://funaging.club" -UseBasicParsing -TimeoutSec 10
    if ($res.StatusCode -ne 200) {
        Copy-Item -Recurse -Force "$distPath\*" "$prodPath"
    }
} catch {
    Copy-Item -Recurse -Force "$distPath\*" "$prodPath"
}
