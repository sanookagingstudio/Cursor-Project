# =====================================================
# ONEPACK v56 — FIX LOGIN FORM (CLIENT MODE)
# =====================================================

$ErrorActionPreference = "Continue"

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
Set-Location $scriptDir

Write-Host ""
Write-Host "=== ONEPACK v56 — FIX LOGIN FORM ===" -ForegroundColor Cyan
Write-Host ""

$frontendDir = Join-Path $scriptDir "frontend"
if (-not (Test-Path $frontendDir)) {
    Write-Host "  ✖ frontend directory not found" -ForegroundColor Red
    exit 1
}

$loginPath = Join-Path $frontendDir "app\auth\login\page.tsx"

# -------- PHASE 1: PATCH /auth/login PAGE --------
Write-Host "[1/3] PATCH /auth/login PAGE" -ForegroundColor Yellow

# Ensure directory exists
$loginDir = Split-Path $loginPath
if (-not (Test-Path $loginDir)) {
    New-Item -ItemType Directory -Force -Path $loginDir | Out-Null
    Write-Host "  ✔ Created auth/login directory" -ForegroundColor Green
} else {
    Write-Host "  ✓ auth/login directory already exists" -ForegroundColor Gray
}

if (Test-Path $loginPath) {
    Write-Host "  ⚠ Login page already exists, backing up..." -ForegroundColor Yellow
    Copy-Item $loginPath "$loginPath.backup" -Force
}

$loginContent = @'
'use client'

import { useState } from 'react'
import { supabase } from '@/config/supabase'
import { useRouter } from 'next/navigation'

export default function LoginPage() {
  const router = useRouter()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError(null)

    if (!supabase) {
      setError('Supabase client not initialized. Check your environment variables.')
      setLoading(false)
      return
    }

    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })

    setLoading(false)

    if (error) {
      setError(error.message)
    } else {
      router.push('/dashboard')
    }
  }

  return (
    <div style={{ maxWidth: 360, margin: '40px auto', padding: '20px' }}>
      <h2>Login</h2>

      <form onSubmit={handleLogin}>
        <input
          type="email"
          placeholder="email"
          value={email}
          onChange={e => setEmail(e.target.value)}
          required
          style={{ width: '100%', padding: '8px', marginBottom: 8, boxSizing: 'border-box' }}
        />

        <input
          type="password"
          placeholder="password"
          value={password}
          onChange={e => setPassword(e.target.value)}
          required
          style={{ width: '100%', padding: '8px', marginBottom: 8, boxSizing: 'border-box' }}
        />

        <button 
          type="submit"
          disabled={loading} 
          style={{ width: '100%', padding: '10px', marginBottom: 8 }}
        >
          {loading ? 'Logging in…' : 'Login'}
        </button>
      </form>

      {error && <p style={{ color: 'red', marginTop: 8 }}>{error}</p>}
    </div>
  )
}
'@

$loginContent | Set-Content -Path $loginPath -Encoding UTF8
Write-Host "  ✔ Login page fixed (client component)" -ForegroundColor Green
Write-Host "    • Added Supabase null check" -ForegroundColor Gray
Write-Host "    • Added form validation (required fields)" -ForegroundColor Gray
Write-Host "    • Improved styling and layout" -ForegroundColor Gray
Write-Host ""

# -------- PHASE 2: CLEAR CACHE --------
Write-Host "[2/3] CLEAR CACHE" -ForegroundColor Yellow

$nextCacheDir = Join-Path $frontendDir ".next"
if (Test-Path $nextCacheDir) {
    Write-Host "  Removing .next cache directory..." -ForegroundColor Gray
    try {
        Remove-Item -Recurse -Force $nextCacheDir -ErrorAction Stop
        Write-Host "  ✔ Cache cleared" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠ Could not fully remove .next cache: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "    Some files may be locked. Try closing the dev server first." -ForegroundColor Cyan
    }
} else {
    Write-Host "  ✓ .next cache directory not found (nothing to clear)" -ForegroundColor Gray
}
Write-Host ""

# -------- PHASE 3: RESTART FRONTEND --------
Write-Host "[3/3] RESTART FRONTEND" -ForegroundColor Yellow

Write-Host "  Stopping existing Node processes..." -ForegroundColor Gray
try {
    $nodeProcesses = Get-Process node -ErrorAction SilentlyContinue | Where-Object {
        $_.Path -like "*node.exe*"
    }
    
    if ($nodeProcesses) {
        $processCount = $nodeProcesses.Count
        $nodeProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Write-Host "  ✔ Stopped $processCount Node process(es)" -ForegroundColor Green
    } else {
        Write-Host "  ✓ No existing Node processes found" -ForegroundColor Gray
    }
} catch {
    Write-Host "  ⚠ Could not stop processes: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "  Starting frontend dev server..." -ForegroundColor Gray
Write-Host "  Note: Dev server will run in this window. Press Ctrl+C to stop." -ForegroundColor Cyan
Write-Host ""

Push-Location $frontendDir
try {
    npm run dev
} catch {
    Write-Host ""
    Write-Host "  ✖ Dev server failed to start: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Troubleshooting:" -ForegroundColor Yellow
    Write-Host "    1. Check if port 3000 is already in use" -ForegroundColor Gray
    Write-Host "    2. Verify package.json has 'dev' script" -ForegroundColor Gray
    Write-Host "    3. Check Node.js and npm are installed correctly" -ForegroundColor Gray
    Write-Host ""
    Pop-Location
    exit 1
}

# This won't be reached if dev server runs successfully (it blocks)
Pop-Location

Write-Host ""
Write-Host "=== ONEPACK v56 COMPLETE ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Login form fixed:" -ForegroundColor White
Write-Host "  • Login page created at /auth/login" -ForegroundColor Gray
Write-Host "  • Client component with form handling" -ForegroundColor Gray
Write-Host "  • Supabase authentication integrated" -ForegroundColor Gray
Write-Host "  • Error handling and loading states" -ForegroundColor Gray
Write-Host ""
Write-Host "Access:" -ForegroundColor White
Write-Host "  • Login: http://localhost:3000/auth/login" -ForegroundColor Gray
Write-Host "  • After login: redirects to /dashboard" -ForegroundColor Gray
Write-Host ""
