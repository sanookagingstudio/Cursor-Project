import axios from "axios";

export const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL,
  withCredentials: true,
});

export interface ApiHealth {
  ok: boolean;
  [key: string]: any;
}

export async function fetchHealth(): Promise<ApiHealth> {
  const res = await api.get("/health");
  return res.data;
}