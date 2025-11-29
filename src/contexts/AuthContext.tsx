import { createContext, useContext, useEffect, useState, ReactNode } from 'react';
import { User, Session } from '@supabase/supabase-js';
import { supabase, isSupabaseConfigured } from '@/integrations/supabase/client';
import { useNavigate } from 'react-router-dom';

type AppRole = 'member' | 'staff' | 'admin';

interface AuthContextType {
  user: User | null;
  session: Session | null;
  loading: boolean;
  userRole: AppRole | null;
  signUp: (email: string, password: string, fullName: string) => Promise<{ error: any }>;
  signIn: (email: string, password: string) => Promise<{ error: any }>;
  signOut: () => Promise<void>;
  hasRole: (role: AppRole) => boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);
  const [userRole, setUserRole] = useState<AppRole | null>(null);
  const navigate = useNavigate();

  useEffect(() => {
    // Check if Supabase is configured
    if (!isSupabaseConfigured()) {
      console.warn('⚠️ Supabase is not configured. Auth features will not work.');
      setLoading(false);
      return;
    }

    try {
      // Set up auth state listener FIRST
      const { data: { subscription } } = supabase.auth.onAuthStateChange(
        async (event, session) => {
          try {
            setSession(session);
            setUser(session?.user ?? null);
            
            if (session?.user) {
              // Fetch user roles
              setTimeout(async () => {
                try {
                  const { data: roles, error } = await supabase
                    .from('user_roles')
                    .select('role')
                    .eq('user_id', session.user.id);
                  
                  if (error) {
                    console.error('Error fetching user roles:', error);
                    return;
                  }
                  
                  if (roles && roles.length > 0) {
                    // Pick highest priority role: admin > staff > member
                    const roleList = roles.map(r => r.role);
                    if (roleList.includes('admin')) {
                      setUserRole('admin');
                    } else if (roleList.includes('staff')) {
                      setUserRole('staff');
                    } else {
                      setUserRole('member');
                    }
                  }
                } catch (error) {
                  console.error('Error in auth state change handler:', error);
                }
              }, 0);
            } else {
              setUserRole(null);
            }
          } catch (error) {
            console.error('Error in auth state change:', error);
          }
        }
      );

      // THEN check for existing session
      supabase.auth.getSession().then(({ data: { session }, error }) => {
        if (error) {
          console.error('Error getting session:', error);
          setLoading(false);
          return;
        }
        
        setSession(session);
        setUser(session?.user ?? null);
        
        if (session?.user) {
          supabase
            .from('user_roles')
            .select('role')
            .eq('user_id', session.user.id)
            .then(({ data: roles, error }) => {
              if (error) {
                console.error('Error fetching user roles:', error);
                setLoading(false);
                return;
              }
              
              if (roles && roles.length > 0) {
                // Pick highest priority role: admin > staff > member
                const roleList = roles.map((r: any) => r.role);
                if (roleList.includes('admin')) {
                  setUserRole('admin');
                } else if (roleList.includes('staff')) {
                  setUserRole('staff');
                } else {
                  setUserRole('member');
                }
              }
              setLoading(false);
            })
            .catch((error) => {
              console.error('Error in getSession promise:', error);
              setLoading(false);
            });
        } else {
          setLoading(false);
        }
      }).catch((error) => {
        console.error('Error getting session:', error);
        setLoading(false);
      });

      return () => subscription.unsubscribe();
    } catch (error) {
      console.error('Error setting up auth:', error);
      setLoading(false);
    }
  }, []);

  const signUp = async (email: string, password: string, fullName: string) => {
    const redirectUrl = `${window.location.origin}/`;
    
    const { error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        emailRedirectTo: redirectUrl,
        data: {
          full_name: fullName,
        }
      }
    });
    
    return { error };
  };

  const signIn = async (email: string, password: string) => {
    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });
    
    return { error };
  };

  const signOut = async () => {
    await supabase.auth.signOut();
    setUserRole(null);
    navigate('/');
  };

  const hasRole = (role: AppRole) => {
    return userRole === role;
  };

  return (
    <AuthContext.Provider value={{
      user,
      session,
      loading,
      userRole,
      signUp,
      signIn,
      signOut,
      hasRole,
    }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}