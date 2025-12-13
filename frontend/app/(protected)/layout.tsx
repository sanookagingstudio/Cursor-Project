import { redirect } from 'next/navigation'
import { createServerClient } from '@supabase/auth-helpers-nextjs'
import { cookies } from 'next/headers'

export default async function ProtectedLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const supabase = createServerClient({ cookies })
  const { data } = await supabase.auth.getUser()

  if (!data.user) {
    redirect('/auth/login')
  }

  return (
    <div style={{ display: 'flex' }}>
      <aside style={{ padding: 16 }}>
        <form action="/api/auth/logout" method="post">
          <button type="submit">Logout</button>
        </form>
      </aside>
      <main style={{ flex: 1 }}>{children}</main>
    </div>
  )
}
