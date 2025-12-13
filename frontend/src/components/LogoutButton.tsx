'use client'
import { supabase } from '@/lib/supabase'

export function LogoutButton() {
  return <button onClick={() => supabase.auth.signOut()}>Logout</button>
}
