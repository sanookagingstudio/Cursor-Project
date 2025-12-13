from fastapi import APIRouter, Request, HTTPException
from app.routes.auth import verify

router = APIRouter(prefix="/dashboard", tags=["dashboard"])

@router.get("/summary")
def summary(request: Request):
    token = request.cookies.get("fa_session")
    if not token:
        raise HTTPException(status_code=401, detail="unauthorized")

    user = verify(token)

    if user.get("role") == "admin":
        return {
            "role": "admin",
            "total_members": 128,
            "active_staff": 7,
            "reports_today": 3
        }
    elif user.get("role") == "staff":
        return {
            "role": "staff",
            "assigned_tasks": 5,
            "completed_today": 2
        }
    else:
        raise HTTPException(status_code=403, detail="forbidden")
