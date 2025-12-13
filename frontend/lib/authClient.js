export async function login(email, password){
  const base = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000";
  const res = await fetch(base + "/auth/login", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    credentials: "include",
    body: JSON.stringify({ email, password })
  });
  if(!res.ok) throw new Error("LOGIN_FAILED");
  return res.json();
}

export async function me(){
  const base = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000";
  const res = await fetch(base + "/auth/me", { credentials: "include" });
  if(!res.ok) return null;
  return res.json();
}

export async function logout(){
  const base = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000";
  await fetch(base + "/auth/logout", { method:"POST", credentials:"include" });
}
