export const AUTH_KEY = "funaging_auth";

export function setAuth(user){
  localStorage.setItem(AUTH_KEY, JSON.stringify(user));
}

export function getAuth(){
  const raw = localStorage.getItem(AUTH_KEY);
  return raw ? JSON.parse(raw) : null;
}

export function clearAuth(){
  localStorage.removeItem(AUTH_KEY);
}
