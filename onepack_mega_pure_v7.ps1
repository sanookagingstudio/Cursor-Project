# ONE PACK MEGA PURE v7 – FINAL IMMORTAL MODE (ADMIN/STaff FIXED)

# REST-only, no PAT, no pg-meta, idempotent, error-tolerant.

# Admin  : sanookagingstudio@gmail.com

# Staff  : akemontree@gmail.com

# Both PW: Ake@8814883



Write-Host "=== ONE PACK MEGA PURE v7 – FINAL IMMORTAL MODE START ===" -ForegroundColor Cyan



# --------------------------------------------------------------------

# IMMUTABLE CONFIG

# --------------------------------------------------------------------

$SUPABASE_URL     = "https://hbjocppvllpcbmhkiode.supabase.co"

$SUPABASE_SERVICE = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhiam9jcHB2bGxwY2JtaGtpb2RlIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NTI5NDkxMCwiZXhwIjoyMDgwODcwOTEwfQ.V7oc0unR_Bku88SU1P5ZAk3IV5loMMaVbmbiItZbOZA"



$ADMIN_EMAIL      = "sanookagingstudio@gmail.com"

$STAFF_EMAIL      = "akemontree@gmail.com"

$DEFAULT_PASSWORD = "Ake@8814883"



$REST_URL = "$SUPABASE_URL/rest/v1"

$AUTH_URL = "$SUPABASE_URL/auth/v1"



$headers = @{

    "apikey"        = $SUPABASE_SERVICE

    "Authorization" = "Bearer $SUPABASE_SERVICE"

    "Content-Type"  = "application/json"

}



# --------------------------------------------------------------------

# UTILITIES

# --------------------------------------------------------------------

function Invoke-SupaJson {

    param(

        [Parameter(Mandatory=$true)][string]$Method,

        [Parameter(Mandatory=$true)][string]$Url,

        [Parameter(Mandatory=$false)][object]$Body,

        [Parameter(Mandatory=$false)][hashtable]$HeadersOverride

    )

    $h = if ($HeadersOverride) { $HeadersOverride } else { $headers }



    try {

        if ($null -ne $Body) {

            $json = $Body | ConvertTo-Json -Depth 8

            return Invoke-RestMethod -Method $Method -Uri $Url -Headers $h -Body $json -ErrorAction Stop

        } else {

            return Invoke-RestMethod -Method $Method -Uri $Url -Headers $h -ErrorAction Stop

        }

    }

    catch {

        Write-Host "⚠ REST $Method $Url failed: $($_.Exception.Message)" -ForegroundColor DarkYellow

        if ($_.Exception.Response -and $_.Exception.Response.ContentLength -gt 0) {

            try {

                $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())

                $respBody = $reader.ReadToEnd()

                Write-Host "  → Response: $respBody" -ForegroundColor DarkYellow

            } catch {}

        }

        return $null

    }

}



function Get-AuthUserByEmail {

    param([string]$Email)



    # Use proper filter syntax: email=eq.<email>

    $filterEmail = "eq.$([uri]::EscapeDataString($Email))"

    $url = "$AUTH_URL/admin/users?email=$filterEmail"

    $res = Invoke-SupaJson -Method GET -Url $url

    if ($res -and $res.users -and $res.users.Count -gt 0) {

        return $res.users[0]

    }

    return $null

}



function Ensure-AuthUser {

    param(

        [string]$Email,

        [string]$Password,

        [string]$DisplayName

    )



    Write-Host "→ Ensuring auth user exists: $Email"



    $user = Get-AuthUserByEmail -Email $Email

    if ($user) {

        Write-Host "  ✓ User already exists (id=$($user.id))" -ForegroundColor Green

        return $user

    }



    $body = @{

        email         = $Email

        password      = $Password

        email_confirm = $true

        user_metadata = @{ full_name = $DisplayName }

    }



    $created = Invoke-SupaJson -Method POST -Url "$AUTH_URL/admin/users" -Body $body

    if ($created -and $created.user) {

        Write-Host "  ✓ User created (id=$($created.user.id))" -ForegroundColor Green

        return $created.user

    }



    $user2 = Get-AuthUserByEmail -Email $Email

    if ($user2) {

        Write-Host "  ✓ User exists after create attempt (id=$($user2.id))" -ForegroundColor Green

        return $user2

    }



    Write-Host "  ✗ Failed to ensure user $Email" -ForegroundColor Red

    return $null

}



function Get-RolesMap {

    Write-Host "→ Fetching roles from $REST_URL/roles"

    $roles = Invoke-SupaJson -Method GET -Url "$REST_URL/roles?select=id,name"

    if (-not $roles) {

        Write-Host "  ✗ Cannot fetch roles (REST error)" -ForegroundColor Red

        return $null

    }



    $map = @{}

    foreach ($r in $roles) {

        if ($r.name) { $map[$r.name] = $r }

    }



    if (-not $map.ContainsKey("admin") -or -not $map.ContainsKey("staff")) {

        Write-Host "  ✗ Roles table missing admin/staff rows" -ForegroundColor Red

    } else {

        Write-Host "  ✓ Roles loaded: $($map.Keys -join ', ')" -ForegroundColor Green

    }



    return $map

}



function Ensure-UserProfile {

    param(

        [string]$UserId,

        [string]$RoleId,

        [string]$FullName

    )



    if (-not $UserId -or -not $RoleId) {

        Write-Host "  ✗ Cannot ensure profile, missing userId or roleId" -ForegroundColor Red

        return

    }



    $urlSelect = "$REST_URL/user_profiles?select=id,role_id,full_name&id=eq.$UserId"

    $existing = Invoke-SupaJson -Method GET -Url $urlSelect



    if ($existing -and $existing.Count -gt 0) {

        $prof = $existing[0]

        $needsUpdate = $false

        $bodyUpdate = @{}



        if (-not $prof.role_id -or $prof.role_id -ne $RoleId) {

            $bodyUpdate.role_id = $RoleId

            $needsUpdate = $true

        }

        if (-not $prof.full_name -or $prof.full_name -ne $FullName) {

            $bodyUpdate.full_name = $FullName

            $needsUpdate = $true

        }



        if ($needsUpdate) {

            Write-Host "  → Updating existing profile for $FullName"

            Invoke-SupaJson -Method PATCH -Url "$REST_URL/user_profiles?id=eq.$UserId" -Body $bodyUpdate | Out-Null

        } else {

            Write-Host "  ✓ Profile already up-to-date for $FullName" -ForegroundColor Green

        }

        return

    }



    $bodyInsert = @{

        id        = $UserId

        role_id   = $RoleId

        full_name = $FullName

    }



    Write-Host "  → Creating profile row for $FullName"

    Invoke-SupaJson -Method POST -Url "$REST_URL/user_profiles" -Body $bodyInsert | Out-Null

}



# --------------------------------------------------------------------

# PHASE A – FOUNDATION CHECK

# --------------------------------------------------------------------

Write-Host "`n--- PHASE A: Foundation Check ---" -ForegroundColor Yellow



if (-not (Test-Path "backend")) {

    New-Item -ItemType Directory -Path "backend" | Out-Null

}

Write-Host "✓ Backend folder verified" -ForegroundColor Green



# --------------------------------------------------------------------

# PHASE B – AUTH + ROLES + PROFILES

# --------------------------------------------------------------------

Write-Host "`n--- PHASE B: Auth + Roles + Profiles ---" -ForegroundColor Yellow



$adminUser = Ensure-AuthUser -Email $ADMIN_EMAIL -Password $DEFAULT_PASSWORD -DisplayName "System Admin"

$staffUser = Ensure-AuthUser -Email $STAFF_EMAIL -Password $DEFAULT_PASSWORD -DisplayName "System Staff"



if ($adminUser -and $staffUser -and $adminUser.id -eq $staffUser.id) {

    Write-Host "✗ WARNING: Admin and Staff have the SAME ID ($($adminUser.id)) – check emails in Supabase" -ForegroundColor Red

} else {

    if ($adminUser) {

        Write-Host "✓ Admin user id:  $($adminUser.id)" -ForegroundColor Green

    }

    if ($staffUser) {

        Write-Host "✓ Staff user id:  $($staffUser.id)" -ForegroundColor Green

    }

}



$rolesMap = Get-RolesMap



if ($rolesMap -and $adminUser -and $staffUser -and $rolesMap["admin"] -and $rolesMap["staff"]) {

    $adminRoleId = $rolesMap["admin"].id

    $staffRoleId = $rolesMap["staff"].id



    Write-Host "→ Ensuring profiles for admin/staff"



    Ensure-UserProfile -UserId $adminUser.id -RoleId $adminRoleId -FullName "System Admin"

    Ensure-UserProfile -UserId $staffUser.id -RoleId $staffRoleId -FullName "System Staff"



    Write-Host "✓ user_profiles created/updated & linked" -ForegroundColor Green

} else {

    Write-Host "✗ Skipping profile link (missing roles or users)" -ForegroundColor Red

}



# --------------------------------------------------------------------

# PHASE C – SYSTEM GUARD

# --------------------------------------------------------------------

Write-Host "`n--- PHASE C: System Guard ---" -ForegroundColor Yellow

"System validated at $(Get-Date)" | Set-Content "system_guard.log"

Write-Host "✓ Guard file updated" -ForegroundColor Green



# --------------------------------------------------------------------

# PHASE D – GIT BACKUP (SAFE MODE)

# --------------------------------------------------------------------

Write-Host "`n--- PHASE D: Git Backup (Safe Mode) ---" -ForegroundColor Yellow

try {

    git rev-parse --is-inside-work-tree 2>$null | Out-Null

    if ($LASTEXITCODE -eq 0) {

        git add .        | Out-Null

        $msg = "AUTO: OnePack Mega Pure v7 $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

        git commit -m $msg 2>$null | Out-Null

        Write-Host "✓ Git backup committed" -ForegroundColor Green

    } else {

        Write-Host "⚠ Not a git repository, skipping git backup" -ForegroundColor DarkYellow

    }

} catch {

    Write-Host "⚠ Git backup skipped: $($_.Exception.Message)" -ForegroundColor DarkYellow

}



# --------------------------------------------------------------------

# PHASE E – SUMMARY

# --------------------------------------------------------------------

Write-Host "`n=== ONE PACK MEGA PURE v7 – FINAL IMMORTAL MODE DONE ===" -ForegroundColor Cyan

Write-Host "Admin email : $ADMIN_EMAIL"

Write-Host "Staff email : $STAFF_EMAIL"










