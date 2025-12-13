import axios from "axios"

export const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:8000",
  withCredentials: true,
})

export type ApiHealth = {
  status: string
  detail?: string
}

export async function fetchHealth(): Promise<ApiHealth> {
  const res = await api.get("/health")
  return res.data
}

export type DashboardSummary = {
  total_members: number
  upcoming_trips: number
  media_created: number
  active_today: number
}

export async function getDashboardSummary(): Promise<DashboardSummary> {
  const res = await api.get("/dashboard/summary")
  return res.data
}

export default api
