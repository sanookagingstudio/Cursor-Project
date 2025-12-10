
from fastapi import APIRouter



router = APIRouter()



@router.get("/", summary="Trip placeholder")

async def list_trips():

    return {"items": [], "message": "Trip API placeholder (v6)"}

