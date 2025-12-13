"use client";

export class ApiClient {
  base: string;

  constructor(baseUrl?: string) {
    this.base = baseUrl ?? process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8000";
  }

  async request(path: string, options: RequestInit = {}) {
    const url = `${this.base}${path}`;

    try {
      const res = await fetch(url, {
        cache: "no-store",
        ...options,
      });

      if (!res.ok) {
        throw new Error(`API Error (${res.status})`);
      }

      return await res.json();
    } catch (err) {
      console.error("API Request Failed:", err);
      return null;
    }
  }

  get(path: string) {
    return this.request(path, { method: "GET" });
  }

  post(path: string, body: any) {
    return this.request(path, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });
  }
}

// global client instance
export const api = new ApiClient();

export async function fetchHealth() {
  try {
    const url = `${api.base}/health`;
    const res = await fetch(url, { cache: "no-store" });
    return res.ok;
  } catch {
    return false;
  }
}





