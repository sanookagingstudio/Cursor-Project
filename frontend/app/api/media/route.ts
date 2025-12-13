import { NextResponse } from "next/server";

const BACKEND_URL = process.env.NEXT_PUBLIC_BACKEND_URL || "http://127.0.0.1:8000";

export async function GET() {
  try {
    const res = await fetch(`${BACKEND_URL}/media/ping`);
    const data = await res.json().catch(() => ({}));
    return NextResponse.json({ ok: true, upstream: data }, { status: 200 });
  } catch (e) {
    return NextResponse.json({ ok: false, error: "Media ping failed" }, { status: 500 });
  }
}
