import os
import psycopg2
from fastapi import APIRouter, Request, HTTPException
from app.routes.auth import verify

router = APIRouter(prefix="/dashboard", tags=["dashboard"])

def get_db():
    return psycopg2.connect(
        host=os.getenv("POSTGRES_HOST","sas_db"),
        dbname=os.getenv("POSTGRES_DB","sas"),
        user=os.getenv("POSTGRES_USER","sas"),
        password=os.getenv("POSTGRES_PASSWORD","sas"),
    )

@router.get("/summary")
def summary(request: Request):
    token = request.cookies.get("fa_session")
    if not token:
        raise HTTPException(status_code=401, detail="unauthorized")

    user = verify(token)
    role = user.get("role")

    conn = get_db()
    cur = conn.cursor()

    cur.execute("SELECT COUNT(*) FROM members")
    members = cur.fetchone()[0]

    cur.execute("SELECT COUNT(*) FROM trips")
    trips = cur.fetchone()[0]

    cur.execute("SELECT COUNT(*) FROM media")
    media = cur.fetchone()[0]

    cur.close()
    conn.close()

    if role == "admin":
        return {
            "role": "admin",
            "total_members": members,
            "upcoming_trips": trips,
            "media_created": media
        }

    if role == "staff":
        return {
            "role": "staff",
            "assigned_members": members,
            "today_tasks": trips
        }

    raise HTTPException(status_code=403, detail="forbidden")
