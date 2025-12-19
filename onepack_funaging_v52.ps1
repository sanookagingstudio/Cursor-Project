# =========================================
# ONEPACK v52 — API ROLE PROTECTION (REAL)
# Backend: FastAPI + Supabase JWT
# =========================================

$ErrorActionPreference = "Continue"

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
Set-Location $scriptDir

Write-Host ""
Write-Host "=== ONEPACK v52 — API ROLE PROTECTION START ===" -ForegroundColor Cyan
Write-Host ""

# -------- PHASE 1: VERIFY ENV --------
Write-Host "[1/6] VERIFY ENV" -ForegroundColor Yellow

$required = @(
    "SUPABASE_URL",
    "SUPABASE_ANON_KEY",
    "SUPABASE_SERVICE_ROLE_KEY"
)

$envMissing = @()
foreach ($k in $required) {
    $envValue = (Get-Item "env:$k" -ErrorAction SilentlyContinue).Value
    if (-not $envValue) {
        Write-Host "  ✖ ENV $k MISSING" -ForegroundColor Red
        $envMissing += $k
    } else {
        Write-Host "  ✔ ENV $k OK" -ForegroundColor Green
    }
}

if ($envMissing.Count -gt 0) {
    Write-Host ""
    Write-Host "  ⚠ Missing required environment variables. Please set them before continuing." -ForegroundColor Yellow
    Write-Host "  Exiting..." -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# -------- PHASE 2: BACKEND DEPENDENCIES --------
Write-Host "[2/6] INSTALL BACKEND DEPENDENCIES" -ForegroundColor Yellow

$backendDir = Join-Path $scriptDir "backend"
if (-not (Test-Path $backendDir)) {
    Write-Host "  ✖ backend directory not found" -ForegroundColor Red
    exit 1
}

Push-Location $backendDir

try {
    Write-Host "  Installing python-jose[cryptography]..." -ForegroundColor Gray
    pip install python-jose[cryptography] --quiet 2>&1 | Out-Null
    
    Write-Host "  Installing httpx..." -ForegroundColor Gray
    pip install httpx --quiet 2>&1 | Out-Null
    
    Write-Host "  Installing fastapi-security..." -ForegroundColor Gray
    pip install fastapi-security --quiet 2>&1 | Out-Null
    
    Write-Host "  ✔ Dependencies installed" -ForegroundColor Green
} catch {
    Write-Host "  ✖ Failed to install dependencies: $($_.Exception.Message)" -ForegroundColor Red
    Pop-Location
    exit 1
}

Pop-Location
Write-Host ""

# -------- PHASE 3: CREATE AUTH MIDDLEWARE --------
Write-Host "[3/6] CREATE AUTH & ROLE GUARD" -ForegroundColor Yellow

$authPath = Join-Path $backendDir "app\auth"
if (-not (Test-Path $authPath)) {
    New-Item -ItemType Directory -Force -Path $authPath | Out-Null
    Write-Host "  ✔ Created auth directory: $authPath" -ForegroundColor Green
} else {
    Write-Host "  ✓ Auth directory already exists" -ForegroundColor Gray
}

$guardFile = Join-Path $authPath "guard.py"
if (Test-Path $guardFile) {
    Write-Host "  ⚠ guard.py already exists, backing up..." -ForegroundColor Yellow
    Copy-Item $guardFile "$guardFile.backup" -Force
}

$guardContent = @'
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import jwt, JWTError
import httpx
import os

security = HTTPBearer()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_ANON_KEY = os.getenv("SUPABASE_ANON_KEY")
JWT_SECRET = SUPABASE_ANON_KEY  # Supabase uses anon key to sign JWT

def get_current_user(
    creds: HTTPAuthorizationCredentials = Depends(security)
):
    """Extract and validate JWT token from Authorization header."""
    token = creds.credentials
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
        return payload
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token"
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Token validation failed: {str(e)}"
        )

def require_role(required_role: str):
    """Dependency factory for role-based access control."""
    async def role_guard(user = Depends(get_current_user)):
        user_id = user.get("sub")
        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid user ID in token"
            )

        try:
            async with httpx.AsyncClient() as client:
                res = await client.get(
                    f"{SUPABASE_URL}/rest/v1/profiles?id=eq.{user_id}&select=role",
                    headers={
                        "apikey": SUPABASE_ANON_KEY,
                        "Authorization": f"Bearer {SUPABASE_ANON_KEY}"
                    },
                    timeout=5.0
                )
                
                if res.status_code != 200:
                    raise HTTPException(
                        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                        detail="Failed to verify user role"
                    )
                
                data = res.json()
                if not data or len(data) == 0:
                    raise HTTPException(
                        status_code=status.HTTP_403_FORBIDDEN,
                        detail="User profile not found"
                    )
                
                user_role = data[0].get("role")
                if user_role != required_role:
                    raise HTTPException(
                        status_code=status.HTTP_403_FORBIDDEN,
                        detail=f"Required role: {required_role}, but user has: {user_role}"
                    )

            return user
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Role verification failed: {str(e)}"
            )
    
    return role_guard
'@

$guardContent | Set-Content -Path $guardFile -Encoding UTF8
Write-Host "  ✔ Auth guard created: $guardFile" -ForegroundColor Green
Write-Host ""

# -------- PHASE 4: PROTECT ROUTES --------
Write-Host "[4/6] APPLY ROLE PROTECTION TO ROUTES" -ForegroundColor Yellow

$routes = @(
    @{ file = "backend\app\routes\office.py"; role = "staff"; endpoint = "/secure" },
    @{ file = "backend\app\routes\media.py"; role = "admin"; endpoint = "/secure" }
)

foreach ($r in $routes) {
    $routeFile = Join-Path $scriptDir $r.file
    if (Test-Path $routeFile) {
        $content = Get-Content $routeFile -Raw
        $modified = $false
        
        # Add import if not present
        if ($content -notmatch "from app\.auth\.guard import") {
            # Find the last import line
            $lines = $content -split "`n"
            $lastImportIndex = -1
            for ($i = 0; $i -lt $lines.Count; $i++) {
                if ($lines[$i] -match "^(import |from )") {
                    $lastImportIndex = $i
                }
            }
            
            if ($lastImportIndex -ge 0) {
                # Insert after last import
                $importLine = "from app.auth.guard import get_current_user, require_role"
                $lines = $lines[0..$lastImportIndex] + $importLine + $lines[($lastImportIndex+1)..($lines.Count-1)]
                $content = $lines -join "`n"
            } else {
                # No imports found, add at the top
                $importLine = "from app.auth.guard import get_current_user, require_role`n"
                $content = $importLine + $content
            }
            $modified = $true
        }
        
        # Add Depends import if not present
        if ($content -match "from fastapi import" -and $content -notmatch "from fastapi import.*Depends") {
            $content = $content -replace "(from fastapi import[^`n]*)", "`$1, Depends"
            $modified = $true
        } elseif ($content -notmatch "from fastapi import") {
            # Add fastapi import with Depends
            $fastapiImport = "from fastapi import Depends`n"
            $content = $fastapiImport + $content
            $modified = $true
        }
        
        # Add protected endpoint if it doesn't exist
        $endpointPattern = "@router\.(get|post|put|delete|patch)\(['""]$($r.endpoint)"
        if ($content -notmatch $endpointPattern) {
            $protectedEndpoint = @"

@router.get("$($r.endpoint)")
async def secure_endpoint(user = Depends(require_role("$($r.role)"))):
    """Protected endpoint requiring $($r.role) role."""
    return {
        "status": "ok",
        "message": "Access granted",
        "user_id": user.get("sub"),
        "role": "$($r.role)"
    }
"@
            # Append before the last line (usually empty or closing)
            $content = $content.TrimEnd() + "`n" + $protectedEndpoint + "`n"
            $modified = $true
            Write-Host "  ✔ Protected $($r.file) with $($r.role) role at $($r.endpoint)" -ForegroundColor Green
        } else {
            Write-Host "  ✓ $($r.file) already has protected endpoint $($r.endpoint)" -ForegroundColor Gray
        }
        
        if ($modified) {
            Set-Content -Path $routeFile -Value $content -Encoding UTF8 -NoNewline
        }
    } else {
        Write-Host "  ⚠ Route file not found: $routeFile" -ForegroundColor Yellow
    }
}

Write-Host ""

# -------- PHASE 5: CREATE __INIT__.PY FOR AUTH MODULE --------
Write-Host "[5/6] CREATE AUTH MODULE INIT" -ForegroundColor Yellow

$authInitFile = Join-Path $authPath "__init__.py"
if (-not (Test-Path $authInitFile)) {
    $initContent = @'
"""Authentication and authorization module for FastAPI."""

from app.auth.guard import get_current_user, require_role

__all__ = ["get_current_user", "require_role"]
'@
    $initContent | Set-Content -Path $authInitFile -Encoding UTF8
    Write-Host "  ✔ Created __init__.py for auth module" -ForegroundColor Green
} else {
    Write-Host "  ✓ __init__.py already exists" -ForegroundColor Gray
}

Write-Host ""

# -------- PHASE 6: HEALTH CHECK --------
Write-Host "[6/6] BACKEND HEALTH CHECK" -ForegroundColor Yellow

try {
    $r = Invoke-WebRequest -Uri "http://127.0.0.1:8000/health" -UseBasicParsing -TimeoutSec 3
    if ($r.StatusCode -eq 200) {
        Write-Host "  ✔ Backend health OK" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Backend returned status code: $($r.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ⚠ Backend health check failed (backend may not be running)" -ForegroundColor Yellow
    Write-Host "    Start backend with: cd backend && uvicorn app.main:app --reload" -ForegroundColor Cyan
}

Write-Host ""

# -------- SUMMARY --------
Write-Host "=== ONEPACK v52 COMPLETE ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Protected endpoints:" -ForegroundColor White
Write-Host "  • /office/secure  => staff role required" -ForegroundColor Gray
Write-Host "  • /media/secure  => admin role required" -ForegroundColor Gray
Write-Host ""
Write-Host "Usage:" -ForegroundColor White
Write-Host "  • Include Authorization header: Bearer <jwt_token>" -ForegroundColor Gray
Write-Host "  • Token must contain valid user ID (sub claim)" -ForegroundColor Gray
Write-Host "  • User profile must exist in Supabase profiles table" -ForegroundColor Gray
Write-Host "  • User role must match required role for endpoint" -ForegroundColor Gray
Write-Host ""
Write-Host "Files created:" -ForegroundColor White
Write-Host "  • backend/app/auth/guard.py" -ForegroundColor Gray
Write-Host "  • backend/app/auth/__init__.py" -ForegroundColor Gray
Write-Host ""
Write-Host "Note: Restart backend server for changes to take effect." -ForegroundColor Yellow
Write-Host ""















