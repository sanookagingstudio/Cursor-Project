import { useState, useEffect } from "react";
import { Link, useNavigate } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { useAuth } from "@/contexts/AuthContext";
import { useToast } from "@/hooks/use-toast";
import { supabase } from "@/integrations/supabase/client";
import { LanguageSwitcher } from "@/components/LanguageSwitcher";
import { useTranslation } from "react-i18next";
import { ArrowLeft } from "lucide-react";

export default function SignUp() {
  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const { signUp, user, userRole } = useAuth();
  const { toast } = useToast();
  const navigate = useNavigate();
  const { t } = useTranslation();

  useEffect(() => {
    if (user && userRole) {
      // User is already logged in, redirect based on role
      if (userRole === 'member') {
        navigate('/member/profile');
      } else if (userRole === 'admin') {
        navigate('/admin/dashboard');
      } else if (userRole === 'staff') {
        navigate('/staff/employee');
      }
    }
  }, [user, userRole, navigate]);

  const handleSignUp = async (e: React.FormEvent) => {
    e.preventDefault();

    if (password !== confirmPassword) {
      toast({
        title: "Passwords don't match",
        description: "Please make sure your passwords match.",
        variant: "destructive",
      });
      return;
    }

    if (password.length < 6) {
      toast({
        title: "Password too short",
        description: "Password must be at least 6 characters.",
        variant: "destructive",
      });
      return;
    }

    setLoading(true);

    const { error } = await signUp(email, password, fullName);

    if (error) {
      // Check if error is about user already registered
      if (error.message.includes('already registered') || error.message.includes('User already registered')) {
        toast({
          title: t('auth.customer.signUpFailed') || "Sign up failed",
          description: t('auth.customer.alreadyRegistered') || "This email is already registered. Please sign in instead.",
          variant: "destructive",
        });
      } else {
        toast({
          title: t('auth.customer.signUpFailed') || "Sign up failed",
          description: error.message,
          variant: "destructive",
        });
      }
      setLoading(false);
    } else {
      // Wait for role to load and check
      setTimeout(async () => {
        const { data: { user } } = await supabase.auth.getUser();
        if (user) {
          const { data: roles } = await supabase
            .from('user_roles')
            .select('role')
            .eq('user_id', user.id);
          
          if (roles && roles.length > 0) {
            const roleList = roles.map(r => r.role);
            toast({
              title: t('auth.customer.accountCreated') || "Account created!",
              description: t('auth.customer.accountCreatedDesc') || "Welcome to FunAging Studio!",
            });
            
            // Redirect based on role
            if (roleList.includes('member')) {
              navigate('/member/profile');
            } else if (roleList.includes('admin')) {
              navigate('/admin/dashboard');
            } else if (roleList.includes('staff')) {
              navigate('/staff/employee');
            }
          }
        }
      }, 500);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-warm p-4 relative">
      <div className="absolute top-4 right-4 z-10">
        <LanguageSwitcher />
      </div>

      <Card className="w-full max-w-md shadow-2xl border-2">
        <CardHeader className="text-center space-y-6 pb-8">
          <Link to="/" className="inline-flex items-center gap-2 text-muted-foreground hover:text-foreground transition-colors">
            <ArrowLeft className="h-4 w-4" />
            <span className="text-sm">{t('auth.customer.backHome')}</span>
          </Link>
          
          <div className="w-20 h-20 rounded-2xl gradient-primary flex items-center justify-center text-white font-bold text-3xl mx-auto shadow-lg">
            FUN
          </div>
          
          <div>
            <div className="inline-block px-6 py-2 rounded-full bg-primary/10 border-2 border-primary mb-4">
              <span className="text-2xl font-bold text-primary">{t('auth.customer.title')}</span>
            </div>
            <CardDescription className="text-lg mt-2">
              {t('auth.customer.joinToday') || 'Join FunAging Studio today'}
            </CardDescription>
          </div>
        </CardHeader>
        
        <CardContent className="space-y-6">
          <form onSubmit={handleSignUp} className="space-y-5">
            <div className="space-y-2">
              <Label htmlFor="fullName" className="text-base font-semibold">
                {t('auth.customer.fullName') || 'Full Name'}
              </Label>
              <Input
                id="fullName"
                type="text"
                placeholder="John Doe"
                className="text-lg h-12 border-2"
                value={fullName}
                onChange={(e) => setFullName(e.target.value)}
                required
              />
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="email" className="text-base font-semibold">
                {t('auth.customer.email')}
              </Label>
              <Input
                id="email"
                type="email"
                placeholder="your@email.com"
                className="text-lg h-12 border-2"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="password" className="text-base font-semibold">
                {t('auth.customer.password')}
              </Label>
              <Input
                id="password"
                type="password"
                placeholder="••••••••"
                className="text-lg h-12 border-2"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                minLength={6}
              />
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="confirmPassword" className="text-base font-semibold">
                {t('auth.customer.confirmPassword') || 'Confirm Password'}
              </Label>
              <Input
                id="confirmPassword"
                type="password"
                placeholder="••••••••"
                className="text-lg h-12 border-2"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                required
                minLength={6}
              />
            </div>
            
            <Button 
              type="submit" 
              size="lg" 
              className="w-full h-14 text-lg font-semibold shadow-lg hover:shadow-xl transition-all" 
              disabled={loading}
            >
              {loading ? "Creating account..." : t('auth.customer.signUpButton') || 'Sign Up'}
            </Button>
          </form>

          <div className="space-y-4">
            <div className="text-center text-base">
              <span className="text-muted-foreground">{t('auth.customer.haveAccount') || 'Already have an account?'} </span>
              <Link to="/sign-in" className="text-primary hover:underline font-semibold text-lg">
                {t('auth.customer.signInButton') || 'Sign in'}
              </Link>
            </div>
            
            <div className="relative">
              <div className="absolute inset-0 flex items-center">
                <span className="w-full border-t-2" />
              </div>
              <div className="relative flex justify-center text-xs uppercase">
                <span className="bg-card px-4 text-muted-foreground font-medium">Other Portals</span>
              </div>
            </div>
            
            <div className="grid grid-cols-2 gap-3 text-center text-sm">
              <Link 
                to="/staff/sign-in" 
                className="p-3 rounded-lg border-2 border-blue-500/30 bg-blue-500/5 hover:bg-blue-500/10 hover:border-blue-500 transition-all"
              >
                <div className="font-semibold text-blue-600">{t('auth.customer.staffPortal')}</div>
                <div className="text-xs text-blue-500">{t('auth.customer.staffLink')}</div>
              </Link>
              
              <Link 
                to="/admin/sign-in" 
                className="p-3 rounded-lg border-2 border-red-500/30 bg-red-500/5 hover:bg-red-500/10 hover:border-red-500 transition-all"
              >
                <div className="font-semibold text-red-600">{t('auth.customer.adminPortal')}</div>
                <div className="text-xs text-red-500">{t('auth.customer.adminLink')}</div>
              </Link>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
