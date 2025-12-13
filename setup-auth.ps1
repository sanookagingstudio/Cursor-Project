Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Get-Location
$frontend = Join-Path $root "frontend"

if (!(Test-Path $frontend)) { throw "frontend folder not found. Run from repo root." }

# ------------------------------------------------------------
# 0) HARD STOP DEV SERVERS
# ------------------------------------------------------------
Get-Process node -ErrorAction SilentlyContinue | Stop-Process -Force

# ------------------------------------------------------------
# 1) INSTALL / SYNC PACKAGES
# ------------------------------------------------------------
Push-Location $frontend
npm i @supabase/supabase-js@latest --silent
Pop-Location

# ------------------------------------------------------------
# 2) WRITE CANONICAL SUPABASE BROWSER CLIENT
# ------------------------------------------------------------
$clientDir = Join-Path $frontend "src\config"
New-Item -ItemType Directory -Path $clientDir -Force | Out-Null

@"
'use client'

import { createClient } from '@supabase/supabase-js'

export const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)
"@ | Set-Content (Join-Path $clientDir "supabase.ts") -Encoding UTF8

# ------------------------------------------------------------
# 3) SERVER LOGIN ROUTE (NO auth-helpers, NO service-role needed)
#    POST /api/auth/login  { email, password } -> { user, session }
# ------------------------------------------------------------
$apiLoginDir = Join-Path $frontend "app\api\auth\login"
New-Item -ItemType Directory -Path $apiLoginDir -Force | Out-Null

@"
import { NextResponse } from 'next/server'
import { createClient } from '@supabase/supabase-js'

export async function POST(req: Request) {
  try {
    const { email, password } = await req.json()

    const url = process.env.NEXT_PUBLIC_SUPABASE_URL
    const anon = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

    if (!url || !anon) {
      return NextResponse.json({ error: 'Supabase ENV missing' }, { status: 500 })
    }

    const supabase = createClient(url, anon)

    const { data, error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) return NextResponse.json({ error: error.message }, { status: 401 })

    return NextResponse.json({ user: data.user, session: data.session })
  } catch (e: any) {
    return NextResponse.json({ error: e?.message || 'Server error' }, { status: 500 })
  }
}
"@ | Set-Content (Join-Path $apiLoginDir "route.ts") -Encoding UTF8

# ------------------------------------------------------------
# 4) LOGIN PAGE (CLIENT) — SET SESSION + REDIRECT + SAFE JSON HANDLING
#    /auth/login
# ------------------------------------------------------------
$loginDir = Join-Path $frontend "app\auth\login"
New-Item -ItemType Directory -Path $loginDir -Force | Out-Null
$loginPage = Join-Path $loginDir "page.tsx"

@"
'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { supabase } from '@/config/supabase'

export default function LoginPage() {
  const router = useRouter()
  const [mounted, setMounted] = useState(false)
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')

  useEffect(() => {
    setMounted(true)
    ;(async () => {
      const { data } = await supabase.auth.getSession()
      if (data.session) router.replace('/dashboard')
    })()
  }, [router])

  const handleLogin = async () => {
    setError('')
    try {
      const res = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
      })

      const text = await res.text()
      let json: any = {}
      try { json = text ? JSON.parse(text) : {} } catch { json = { error: 'Invalid server response' } }

      if (!res.ok) {
        setError(json?.error || 'Login failed')
        return
      }

      const session = json?.session
      if (!session?.access_token || !session?.refresh_token) {
        setError('Session missing from server')
        return
      }

      const { error: setErr } = await supabase.auth.setSession({
        access_token: session.access_token,
        refresh_token: session.refresh_token,
      })
      if (setErr) {
        setError(setErr.message)
        return
      }

      router.replace('/dashboard')
    } catch (e: any) {
      setError(e?.message || 'fetch failed')
    }
  }

  if (!mounted) return null

  return (
    <div suppressHydrationWarning className="p-6">
      <h2 className="text-xl font-semibold mb-4">Login</h2>

      <div className="flex gap-3 items-center">
        <input
          className="border px-3 py-2 rounded w-[320px]"
          placeholder="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          autoComplete="email"
        />
        <input
          className="border px-3 py-2 rounded w-[320px]"
          type="password"
          placeholder="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          autoComplete="current-password"
        />
        <button
          className="border px-4 py-2 rounded"
          onClick={handleLogin}
        >
          Login
        </button>
      </div>

      {error && <p className="text-red-600 mt-2">{error}</p>}
    </div>
  )
}
"@ | Set-Content $loginPage -Encoding UTF8

# ------------------------------------------------------------
# 5) DASHBOARD GUARD + USER CONTEXT + LOGOUT BUTTON
# ------------------------------------------------------------
$dashDir = Join-Path $frontend "app\dashboard"
New-Item -ItemType Directory -Path $dashDir -Force | Out-Null
$dashPage = Join-Path $dashDir "page.tsx"

@"
'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { supabase } from '@/config/supabase'

type Me = {
  id?: string
  email?: string
  role?: string | null
}

export default function DashboardPage() {
  const router = useRouter()
  const [me, setMe] = useState<Me>({})
  const [loading, setLoading] = useState(true)
  const [err, setErr] = useState('')

  useEffect(() => {
    ;(async () => {
      setErr('')
      setLoading(true)

      const { data: sess } = await supabase.auth.getSession()
      if (!sess.session) {
        router.replace('/auth/login')
        return
      }

      const { data: userData, error: userErr } = await supabase.auth.getUser()
      if (userErr || !userData.user) {
        router.replace('/auth/login')
        return
      }

      const u = userData.user
      const nextMe: Me = { id: u.id, email: u.email || '' }

      try {
        const { data: prof } = await supabase
          .from('profiles')
          .select('role')
          .eq('id', u.id)
          .maybeSingle()
        nextMe.role = (prof as any)?.role ?? null
      } catch {
        nextMe.role = null
      }

      setMe(nextMe)
      setLoading(false)
    })()
  }, [router])

  const logout = async () => {
    setErr('')
    try {
      await supabase.auth.signOut()
      router.replace('/auth/login')
    } catch (e: any) {
      setErr(e?.message || 'logout failed')
    }
  }

  if (loading) return <div className="p-6">Loading...</div>

  return (
    <div className="p-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold">Dashboard</h1>
        <button className="border px-4 py-2 rounded" onClick={logout}>Logout</button>
      </div>

      {err && <p className="text-red-600 mt-2">{err}</p>}

      <div className="mt-6 space-y-2">
        <div><span className="font-semibold">User ID:</span> {me.id}</div>
        <div><span className="font-semibold">Email:</span> {me.email}</div>
        <div><span className="font-semibold">Role:</span> {me.role ?? 'unknown'}</div>
      </div>
    </div>
  )
}
"@ | Set-Content $dashPage -Encoding UTF8

# ------------------------------------------------------------
# 6) OPTIONAL: GUARD OTHER TOP PAGES IF THEY EXIST (Trip/Office/Media/Insights)
#    - inject minimal client guard wrapper if pages exist
# ------------------------------------------------------------
function Ensure-GuardedPage {
  param(
    [string]$pagePath,
    [string]$title
  )
  if (!(Test-Path $pagePath)) { return }

  @"
'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { supabase } from '@/config/supabase'

export default function Page() {
  const router = useRouter()
  const [ready, setReady] = useState(false)

  useEffect(() => {
    ;(async () => {
      const { data } = await supabase.auth.getSession()
      if (!data.session) {
        router.replace('/auth/login')
        return
      }
      setReady(true)
    })()
  }, [router])

  if (!ready) return <div className="p-6">Loading...</div>

  return (
    <div className="p-6">
      <h1 className="text-2xl font-semibold">$title</h1>
    </div>
  )
}
"@ | Set-Content $pagePath -Encoding UTF8
}

Ensure-GuardedPage -pagePath (Join-Path $frontend "app\trip\page.tsx") -title "Trip Planner"
Ensure-GuardedPage -pagePath (Join-Path $frontend "app\office\page.tsx") -title "Office"
Ensure-GuardedPage -pagePath (Join-Path $frontend "app\media\page.tsx") -title "Media Creator"
Ensure-GuardedPage -pagePath (Join-Path $frontend "app\insights\page.tsx") -title "Insights"

# ------------------------------------------------------------
# 7) HARD RESET CACHE
# ------------------------------------------------------------
$nextDir = Join-Path $frontend ".next"
if (Test-Path $nextDir) { Remove-Item $nextDir -Recurse -Force }

# ------------------------------------------------------------
# 8) START DEV
# ------------------------------------------------------------
Push-Location $frontend
Start-Process -FilePath "npm" -ArgumentList "run","dev" -WorkingDirectory $frontend | Out-Null
Pop-Location

# ------------------------------------------------------------
# 9) GIT BACKUP -> COMMIT + PUSH (SAFE: .env.local SHOULD BE GITIGNORED)
# ------------------------------------------------------------
Push-Location $root

if (!(Test-Path (Join-Path $root ".git"))) { throw "This repo is not a git repository (.git missing)." }

git status --porcelain | Out-Null

git add -A
$ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
git commit -m "fix(auth): canonical login session logout guard + user context ($ts)" | Out-Null

# ensure upstream
$branch = (git rev-parse --abbrev-ref HEAD).Trim()
$hasUpstream = $true
try { git rev-parse --abbrev-ref --symbolic-full-name "@{u}" | Out-Null } catch { $hasUpstream = $false }

if (-not $hasUpstream) {
  git push -u origin $branch
} else {
  git push
}

Pop-Location


