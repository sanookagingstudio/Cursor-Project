
from fastapi import APIRouter



router = APIRouter()



@router.get("/", summary="Office placeholder")

async def office_root():

    return {"items": [], "message": "Office API placeholder (v7)"}

