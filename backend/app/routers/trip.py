
# Trip router (self-healing v5 placeholder)

from fastapi import APIRouter



router = APIRouter()



@router.get("/", summary="List trips (placeholder)")

async def list_trips():

    return {"items": [], "message": "Trip API placeholder (v5)"}

