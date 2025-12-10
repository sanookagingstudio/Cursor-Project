
# Health router (self-healing v5)

from fastapi import APIRouter



router = APIRouter()



@router.get("/", summary="Health check")

async def get_health():

    return {"status": "ok"}

