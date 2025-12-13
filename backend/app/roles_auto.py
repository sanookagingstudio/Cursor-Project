import os
from fastapi import APIRouter, HTTPException
from supabase import create_client

router = APIRouter(prefix="/api/roles", tags=["roles"])


def supa():
    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
    return create_client(url, key)


def auto(email, password, role):
    s = supa()
    users = s.auth.admin.list_users().users

    for u in users:
        if u.email == email:
            return {"status": "exists", "email": email, "role": role}

    r = s.auth.admin.create_user({
        "email": email,
        "password": password,
        "email_confirm": True,
        "user_metadata": {"role": role}
    })
    if not r.user:
        raise HTTPException(status_code=500)
    return {"status": "created", "email": email, "password": password, "role": role}


@router.post("/init-admin")
def init_admin():
    return auto(os.getenv("ADMIN_EMAIL", "admin@funaging.club"),
                os.getenv("ADMIN_PASSWORD", "Admin1234!"), "admin")


@router.post("/init-staff")
def init_staff():
    return auto("staff@funaging.club", "Staff1234!", "staff")


@router.post("/init-customer")
def init_customer():
    return auto("customer@funaging.club", "Customer1234!", "customer")














