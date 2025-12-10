import httpx
from .config import get_settings

_settings = get_settings()

class SupabaseClient:
    def __init__(self):
        self.enabled = bool(_settings.supabase_url and _settings.supabase_anon_key)
        self.url = _settings.supabase_url.rstrip('/') if self.enabled else None
        self.key = _settings.supabase_anon_key

    async def select(self, table: str, params=None):
        if not self.enabled:
            return {"data": [], "error": "Supabase disabled"}
        headers = {"apikey": self.key, "Authorization": f"Bearer {self.key}"}
        async with httpx.AsyncClient() as c:
            r = await c.get(f"{self.url}/rest/v1/{table}", headers=headers, params=params or {})
        r.raise_for_status()
        return {"data": r.json(), "error": None}

supabase_client = SupabaseClient()
