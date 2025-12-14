import os
import psycopg2
from fastapi import APIRouter, Request, HTTPException
from app.routes.auth import verify

router = APIRouter(prefix="/dashboard", tags=["dashboard"])

def db():
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
        raise HTTPException(status_code=401)

    user = verify(token)
    role = user.get("role")

    c = db()
    cur = c.cursor()
    cur.execute("select count(*) from members"); members = cur.fetchone()[0]
    cur.execute("select count(*) from trips"); trips = cur.fetchone()[0]
    cur.execute("select count(*) from media"); media = cur.fetchone()[0]
    cur.close(); c.close()

    if role == "admin":
        return {
            "role":"admin",
            "total_members":members,
            "upcoming_trips":trips,
            "media_created":media
        }
    if role == "staff":
        return {
            "role":"staff",
            "assigned_members":members,
            "today_tasks":trips
        }
    raise HTTPException(status_code=403)
