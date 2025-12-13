"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { login } from "@/lib/authClient";

export default function LoginPage(){
  const router = useRouter();
  const [email,setEmail]=useState("");
  const [password,setPassword]=useState("");
  const [err,setErr]=useState("");

  const submit = async (e)=>{
    e.preventDefault();
    setErr("");
    try{
      await login(email,password);
      router.replace("/dashboard");
    }catch{
      setErr("Invalid credentials");
    }
  };

  return (
    <div style={{padding:40,maxWidth:420}}>
      <h1>Login</h1>
      <form onSubmit={submit}>
        <input placeholder="email" value={email}
          onChange={e=>setEmail(e.target.value)}
          style={{width:"100%",marginBottom:8}} />
        <input type="password" placeholder="password" value={password}
          onChange={e=>setPassword(e.target.value)}
          style={{width:"100%",marginBottom:8}} />
        <button type="submit">Login</button>
      </form>
      {err && <p style={{color:"crimson"}}>{err}</p>}
    </div>
  );
}
