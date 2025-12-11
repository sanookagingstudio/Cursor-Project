from fastapi import APIRouter

router = APIRouter(prefix="/media", tags=["media"])

@router.get("/ping")
async def media_ping():
    return {"module": "media", "status": "ok"}
