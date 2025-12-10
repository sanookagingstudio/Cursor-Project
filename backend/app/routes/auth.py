from fastapi import APIRouter
from app.core.config import get_settings
import httpx

router = APIRouter(prefix='/auth', tags=['auth'])
settings = get_settings()

@router.get('/profile')
async def get_profile(user_id: str):
    async with httpx.AsyncClient() as c:
        r = await c.get(
            f"{settings.supabase_url}/rest/v1/user_profiles",
            headers={ "apikey": settings.supabase_anon_key,
                      "Authorization": f"Bearer {settings.supabase_service_role_key}" },
            params={ "id": f"eq.{user_id}", "select":"*" }
        )
    return r.json()
