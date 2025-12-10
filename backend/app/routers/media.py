
from fastapi import APIRouter



router = APIRouter()



@router.get("/", summary="Media placeholder")

async def media_root():

    return {"items": [], "message": "Media API placeholder (v7)"}

