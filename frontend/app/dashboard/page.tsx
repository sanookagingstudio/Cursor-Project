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
