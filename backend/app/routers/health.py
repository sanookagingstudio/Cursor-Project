"""Health check router"""
from fastapi import APIRouter
from app.core.redis import test_redis_connection
from app.core.db import engine

router = APIRouter()


@router.get("/")
async def health_check():
    """Health check endpoint"""
    redis_ok = test_redis_connection()
    db_ok = False
    
    if engine is not None:
        try:
            with engine.connect() as conn:
                db_ok = True
        except Exception:
            pass
    
    status = "ok" if (redis_ok and db_ok) else "degraded"
    
    return {
        "status": status,
        "redis": "ok" if redis_ok else "error",
        "database": "ok" if db_ok else "error"
    }

