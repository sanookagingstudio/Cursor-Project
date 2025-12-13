"use client";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { me, logout } from "@/lib/authClient";

export default function Dashboard(){
  const router = useRouter();
  const [user,setUser]=useState(null);
  const [data,setData]=useState(null);

  useEffect(()=>{
    me().then(r=>{
      if(!r?.ok){
        router.replace("/auth/login");
      } else {
        setUser(r.user);
        fetchSummary();
      }
    });
  },[]);

  const fetchSummary = async ()=>{
    const base = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000";
    const res = await fetch(base + "/dashboard/summary", { credentials:"include" });
    if(res.ok){
      setData(await res.json());
    }
  };

  if(!user || !data) return <p>Loading...</p>;

  return (
    <div style={{padding:40}}>
      <h1>Dashboard ({data.role})</h1>

      {data.role === "admin" && (
        <ul>
          <li>Total Members: {data.total_members}</li>
          <li>Active Staff: {data.active_staff}</li>
          <li>Reports Today: {data.reports_today}</li>
        </ul>
      )}

      {data.role === "staff" && (
        <ul>
          <li>Assigned Tasks: {data.assigned_tasks}</li>
          <li>Completed Today: {data.completed_today}</li>
        </ul>
      )}

      <button onClick={()=>logout().then(()=>router.replace("/auth/login"))}>
        Logout
      </button>
    </div>
  );
}
