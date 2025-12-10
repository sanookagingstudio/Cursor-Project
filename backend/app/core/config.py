import os
from functools import lru_cache
from pydantic import BaseSettings

class Settings(BaseSettings):
    project_name: str = os.getenv("PROJECT_NAME")
    supabase_url: str = os.getenv("SUPABASE_URL")
    supabase_anon_key: str = os.getenv("SUPABASE_ANON_KEY")
    supabase_service_role_key: str = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
    database_url: str = os.getenv("DATABASE_URL")

@lru_cache()
def get_settings():
    return Settings()
