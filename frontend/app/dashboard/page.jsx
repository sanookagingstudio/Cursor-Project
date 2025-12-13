"use client";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { me, logout } from "@/lib/authClient";

export default function Dashboard(){
  const router = useRouter();
  const [user,setUser]=useState(null);

  useEffect(()=>{
    me().then(r=>{
      if(!r?.ok){
        router.replace("/auth/login");
      } else {
        setUser(r.user);
      }
    });
  },[]);

  if(!user) return <p>Loading...</p>;

  return (
    <div style={{padding:40}}>
      <h1>Dashboard</h1>

      {user.role === "admin" && (
        <section style={{border:"1px solid #ccc",padding:16,marginBottom:16}}>
          <h2>Admin Panel</h2>
          <ul>
            <li>System Settings</li>
            <li>User Management</li>
            <li>Reports</li>
          </ul>
        </section>
      )}

      {user.role === "staff" && (
        <section style={{border:"1px solid #ccc",padding:16,marginBottom:16}}>
          <h2>Staff Panel</h2>
          <ul>
            <li>Daily Tasks</li>
            <li>Member Support</li>
          </ul>
        </section>
      )}

      <pre>{JSON.stringify(user,null,2)}</pre>

      <button onClick={()=>logout().then(()=>router.replace("/auth/login"))}>
        Logout
      </button>
    </div>
  );
}
