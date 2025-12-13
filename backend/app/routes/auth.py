import os, json, base64, hmac, hashlib, time
from fastapi import APIRouter, Request, Response, HTTPException
from pydantic import BaseModel

router = APIRouter(prefix="/auth", tags=["auth"])

AUTH_SECRET = os.getenv("AUTH_SECRET")
ADMIN_EMAIL = os.getenv("AUTH_ADMIN_EMAIL")
ADMIN_PASSWORD = os.getenv("AUTH_ADMIN_PASSWORD")
STAFF_EMAIL = os.getenv("AUTH_STAFF_EMAIL")
STAFF_PASSWORD = os.getenv("AUTH_STAFF_PASSWORD")

COOKIE_NAME = os.getenv("AUTH_COOKIE", "fa_session")
COOKIE_SECURE = os.getenv("AUTH_COOKIE_SECURE", "0") == "1"
COOKIE_SAMESITE = os.getenv("AUTH_COOKIE_SAMESITE", "lax")

def _require_env():
    missing = []
    for k,v in [
        ("AUTH_SECRET", AUTH_SECRET),
        ("AUTH_ADMIN_EMAIL", ADMIN_EMAIL),
        ("AUTH_ADMIN_PASSWORD", ADMIN_PASSWORD),
        ("AUTH_STAFF_EMAIL", STAFF_EMAIL),
        ("AUTH_STAFF_PASSWORD", STAFF_PASSWORD),
    ]:
        if not v:
            missing.append(k)
    if missing:
        raise RuntimeError("MISSING_ENV:" + ",".join(missing))

def _b64(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).decode("utf-8").rstrip("=")

def _b64d(s: str) -> bytes:
    pad = "=" * (-len(s) % 4)
    return base64.urlsafe_b64decode((s + pad).encode("utf-8"))

def sign(payload: dict) -> str:
    raw = json.dumps(payload, separators=(",", ":"), ensure_ascii=False).encode("utf-8")
    sig = hmac.new(AUTH_SECRET.encode("utf-8"), raw, hashlib.sha256).digest()
    return f"{_b64(raw)}.{_b64(sig)}"

def verify(token: str) -> dict:
    try:
        parts = token.split(".")
        if len(parts) != 2:
            raise ValueError("bad token")
        raw = _b64d(parts[0])
        sig = _b64d(parts[1])
        exp_sig = hmac.new(AUTH_SECRET.encode("utf-8"), raw, hashlib.sha256).digest()
        if not hmac.compare_digest(sig, exp_sig):
            raise ValueError("bad sig")
        payload = json.loads(raw.decode("utf-8"))
        if payload.get("exp") and time.time() > float(payload["exp"]):
            raise ValueError("expired")
        return payload
    except Exception:
        raise HTTPException(status_code=401, detail="unauthorized")

class LoginIn(BaseModel):
    email: str
    password: str

@router.get("/ping")
def ping():
    return {"auth": "ok"}

@router.post("/login")
def login(data: LoginIn, response: Response):
    _require_env()

    role = None
    if data.email == ADMIN_EMAIL and data.password == ADMIN_PASSWORD:
        role = "admin"
    elif data.email == STAFF_EMAIL and data.password == STAFF_PASSWORD:
        role = "staff"
    else:
        raise HTTPException(status_code=401, detail="invalid_credentials")

    payload = {
        "sub": data.email,
        "role": role,
        "iat": int(time.time()),
        "exp": int(time.time()) + 60*60*24*7,
    }
    token = sign(payload)

    response.set_cookie(
        key=COOKIE_NAME,
        value=token,
        httponly=True,
        secure=COOKIE_SECURE,
        samesite=COOKIE_SAMESITE,
        path="/",
        max_age=60*60*24*7,
    )
    return {"ok": True, "redirect": "/dashboard", "role": role}

@router.get("/me")
def me(request: Request):
    _require_env()
    token = request.cookies.get(COOKIE_NAME)
    if not token:
        raise HTTPException(status_code=401, detail="unauthorized")
    payload = verify(token)
    return {"ok": True, "user": {"email": payload.get("sub"), "role": payload.get("role")}}

@router.post("/logout")
def logout(response: Response):
    response.delete_cookie(key=COOKIE_NAME, path="/")
    return {"ok": True}
