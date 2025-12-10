
# Office router (self-healing v5 placeholder)

from fastapi import APIRouter



router = APIRouter()



@router.get("/", summary="Office API placeholder")

async def office_root():

    return {"items": [], "message": "Office API placeholder (v5)"}

