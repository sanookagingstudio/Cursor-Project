import { NextResponse } from "next/server";

export function middleware(req){
  const { pathname } = req.nextUrl;
  if(!pathname.startsWith("/dashboard")) return NextResponse.next();

  const token = req.cookies.get("fa_session")?.value;
  if(!token){
    const url = req.nextUrl.clone();
    url.pathname = "/auth/login";
    return NextResponse.redirect(url);
  }
  return NextResponse.next();
}

export const config = {
  matcher: ["/dashboard/:path*"],
};
