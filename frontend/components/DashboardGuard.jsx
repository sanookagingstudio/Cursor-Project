import { useEffect } from "react";
import { useRouter } from "next/router";
import { getAuth } from "../lib/auth";

export default function DashboardGuard({ children }){
  const router = useRouter();

  useEffect(() => {
    const auth = getAuth();
    if(!auth){
      router.replace("/auth/login");
    }
  }, []);

  return children;
}
