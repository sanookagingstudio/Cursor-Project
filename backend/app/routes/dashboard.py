from fastapi import APIRouter
router = APIRouter(prefix="/dashboard", tags=["dashboard"])

@router.get("/summary")
def summary():
    return {
        "total_members": 0,
        "upcoming_trips": 0,
        "media_created": 0,
        "active_today": 0
    }
