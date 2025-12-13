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
